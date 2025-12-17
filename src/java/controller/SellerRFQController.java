package controller;

import DAO.RFQDAO;
import DAO.ProductDAO;
import entity.RFQ;
import entity.RFQItem;
import entity.Employee;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.List;

/**
 * SellerRFQController - Xử lý các request RFQ từ phía Seller Manager
 * URL Patterns:
 * - /admin/rfq (GET) - Danh sách RFQ
 * - /admin/rfq/detail (GET) - Chi tiết RFQ
 * - /admin/rfq/assign (POST) - Phân công RFQ
 * - /admin/rfq/propose-date (POST) - Đề xuất ngày giao mới
 * - /admin/rfq/quotation-form (GET) - Form tạo báo giá
 * - /admin/rfq/send-quotation (POST) - Gửi báo giá
 */
@WebServlet(name = "SellerRFQController", urlPatterns = {"/admin/rfq", "/admin/rfq/*"})
public class SellerRFQController extends HttpServlet {

    private RFQDAO rfqDAO = new RFQDAO();
    private ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        if (pathInfo == null) pathInfo = "";
        
        // Check login
        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        if (employee == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        switch (pathInfo) {
            case "":
            case "/":
            case "/list":
                showRFQList(request, response, employee);
                break;
            case "/detail":
                showRFQDetail(request, response, employee);
                break;
            case "/quotation-form":
                showQuotationForm(request, response, employee);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/rfq");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String pathInfo = request.getPathInfo();
        
        // Check login
        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        if (employee == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        switch (pathInfo) {
            case "/assign":
                assignRFQ(request, response, employee);
                break;
            case "/assign-to-me":
                assignToMe(request, response, employee);
                break;
            case "/propose-date":
                proposeDate(request, response, employee);
                break;
            case "/send-quotation":
                sendQuotation(request, response, employee);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/rfq");
        }
    }

    private void showRFQList(HttpServletRequest request, HttpServletResponse response, Employee employee)
            throws ServletException, IOException {
        
        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");
        // Bỏ filter phân công
        Integer assignedTo = null;
        
        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (Exception e) {}
        
        int pageSize = 5;
        List<RFQ> rfqs = rfqDAO.searchRFQs(keyword, status, assignedTo, null, page, pageSize);
        int totalCount = rfqDAO.countRFQs(keyword, status, assignedTo, null);
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        
        // Statistics
        int[] stats = rfqDAO.getRFQStatistics();
        int cancelledCount = rfqDAO.countRFQs(null, RFQ.STATUS_CANCELLED, null, null);
        
        request.setAttribute("rfqs", rfqs);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("keyword", keyword);
        request.setAttribute("status", status);
        request.setAttribute("assignedTo", null);
        request.setAttribute("pendingCount", stats[0]);
        request.setAttribute("processingCount", stats[1]);
        request.setAttribute("quotedCount", stats[2]);
        request.setAttribute("completedCount", stats[3]);
        request.setAttribute("cancelledCount", cancelledCount);
        
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-rfq-list.jsp").forward(request, response);
    }

    private void showRFQDetail(HttpServletRequest request, HttpServletResponse response, Employee employee)
            throws ServletException, IOException {
        
        int rfqID = Integer.parseInt(request.getParameter("id"));
        RFQ rfq = rfqDAO.getRFQById(rfqID);
        
        if (rfq == null) {
            response.sendRedirect(request.getContextPath() + "/admin/rfq");
            return;
        }
        
        rfq.setHistory(rfqDAO.getRFQHistory(rfqID));
        
        // Load cost prices for items
        for (RFQItem item : rfq.getItems()) {
            if (item.getVariantID() != null && item.getCostPrice() == null) {
                item.setCostPrice(rfqDAO.getWeightedAverageCost(item.getVariantID()));
            }
        }
        
        request.setAttribute("rfq", rfq);
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-rfq-detail.jsp").forward(request, response);
    }

    private void showQuotationForm(HttpServletRequest request, HttpServletResponse response, Employee employee)
            throws ServletException, IOException {
        
        int rfqID = Integer.parseInt(request.getParameter("rfqId"));
        RFQ rfq = rfqDAO.getRFQById(rfqID);
        
        if (rfq == null || !rfq.canCreateQuote()) {
            response.sendRedirect(request.getContextPath() + "/admin/rfq");
            return;
        }
        
        // Load cost prices and min profit margin for items, calculate total weight
        int totalWeight = 0;
        for (RFQItem item : rfq.getItems()) {
            if (item.getVariantID() != null) {
                item.setCostPrice(rfqDAO.getWeightedAverageCost(item.getVariantID()));
                // Load min profit margin from stock management (ProfitMarginTarget)
                item.setMinProfitMargin(rfqDAO.getProfitMarginTarget(item.getVariantID()));
            }
            // Default weight: 500g per item (can be customized later)
            totalWeight += item.getQuantity() * 500;
        }
        
        // Get delivery city/district IDs from RFQ
        String deliveryCityId = rfq.getDeliveryCityId() != null ? rfq.getDeliveryCityId() : "";
        String deliveryDistrictId = rfq.getDeliveryDistrictId() != null ? rfq.getDeliveryDistrictId() : "";
        
        request.setAttribute("rfq", rfq);
        request.setAttribute("totalWeight", totalWeight);
        request.setAttribute("deliveryCityId", deliveryCityId);
        request.setAttribute("deliveryDistrictId", deliveryDistrictId);
        request.getRequestDispatcher("/AdminLTE-3.2.0/quotation-form.jsp").forward(request, response);
    }

    private void assignRFQ(HttpServletRequest request, HttpServletResponse response, Employee employee)
            throws ServletException, IOException {
        
        int rfqID = Integer.parseInt(request.getParameter("rfqId"));
        int assignTo = Integer.parseInt(request.getParameter("assignTo"));
        
        rfqDAO.assignRFQ(rfqID, assignTo, employee.getEmployeeID());
        
        response.sendRedirect(request.getContextPath() + "/admin/rfq/detail?id=" + rfqID);
    }

    private void assignToMe(HttpServletRequest request, HttpServletResponse response, Employee employee)
            throws ServletException, IOException {
        
        int rfqID = Integer.parseInt(request.getParameter("id"));
        rfqDAO.assignRFQ(rfqID, employee.getEmployeeID(), employee.getEmployeeID());
        
        response.sendRedirect(request.getContextPath() + "/admin/rfq/detail?id=" + rfqID);
    }

    private void proposeDate(HttpServletRequest request, HttpServletResponse response, Employee employee)
            throws ServletException, IOException {
        
        try {
            int rfqID = Integer.parseInt(request.getParameter("rfqId"));
            String proposedDateStr = request.getParameter("proposedDate");
            String reason = request.getParameter("reason");
            
            // Support both dd/MM/yyyy and yyyy-MM-dd formats
            SimpleDateFormat sdf;
            if (proposedDateStr.contains("/")) {
                sdf = new SimpleDateFormat("dd/MM/yyyy");
            } else {
                sdf = new SimpleDateFormat("yyyy-MM-dd");
            }
            Timestamp proposedDate = new Timestamp(sdf.parse(proposedDateStr).getTime());
            
            rfqDAO.proposeDeliveryDate(rfqID, proposedDate, reason, employee.getEmployeeID());
            
            response.sendRedirect(request.getContextPath() + "/admin/rfq/detail?id=" + rfqID + "&success=date_proposed");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/rfq?error=propose_failed");
        }
    }

    private void sendQuotation(HttpServletRequest request, HttpServletResponse response, Employee employee)
            throws ServletException, IOException {
        
        try {
            int rfqID = Integer.parseInt(request.getParameter("rfqId"));
            RFQ rfq = rfqDAO.getRFQById(rfqID);
            
            if (rfq == null || !rfq.canCreateQuote()) {
                response.sendRedirect(request.getContextPath() + "/admin/rfq");
                return;
            }
            
            // Parse quotation data
            BigDecimal shippingFee = new BigDecimal(request.getParameter("shippingFee"));
            BigDecimal taxPercent = new BigDecimal(request.getParameter("taxPercent"));
            String validUntilStr = request.getParameter("quotationValidUntil");
            String paymentMethod = request.getParameter("paymentMethod");
            String quotationTerms = request.getParameter("additionalTerms");
            String warrantyTerms = request.getParameter("warrantyTerms");
            
            // Support both dd/MM/yyyy and yyyy-MM-dd formats
            SimpleDateFormat sdf;
            if (validUntilStr.contains("/")) {
                sdf = new SimpleDateFormat("dd/MM/yyyy");
            } else {
                sdf = new SimpleDateFormat("yyyy-MM-dd");
            }
            Timestamp validUntil = new Timestamp(sdf.parse(validUntilStr).getTime());
            
            // Parse item pricing
            List<RFQItem> items = rfq.getItems();
            for (int i = 0; i < items.size(); i++) {
                RFQItem item = items.get(i);
                String profitMarginStr = request.getParameter("items[" + i + "][profitMargin]");
                String notesStr = request.getParameter("items[" + i + "][notes]");
                
                if (profitMarginStr != null && !profitMarginStr.isEmpty()) {
                    item.setProfitMarginPercent(new BigDecimal(profitMarginStr));
                }
                if (notesStr != null) {
                    item.setNotes(notesStr);
                }
                
                // Get cost price if not set
                if (item.getCostPrice() == null && item.getVariantID() != null) {
                    item.setCostPrice(rfqDAO.getWeightedAverageCost(item.getVariantID()));
                }
            }
            
            // Calculate tax amount
            BigDecimal subtotal = BigDecimal.ZERO;
            for (RFQItem item : items) {
                item.calculateUnitPrice();
                subtotal = subtotal.add(item.getSubtotal());
            }
            BigDecimal taxAmount = subtotal.multiply(taxPercent).divide(BigDecimal.valueOf(100));
            
            boolean success = rfqDAO.sendQuotation(rfqID, items, shippingFee, taxAmount, 
                                                    validUntil, paymentMethod, quotationTerms, 
                                                    warrantyTerms, employee.getEmployeeID());
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/rfq/detail?id=" + rfqID + "&success=quotation_sent");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/rfq/quotation-form?rfqId=" + rfqID + "&error=send_failed");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/rfq?error=quotation_failed");
        }
    }
}
