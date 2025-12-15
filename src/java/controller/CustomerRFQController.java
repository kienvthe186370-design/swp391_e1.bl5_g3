package controller;

import DAO.RFQDAO;
import DAO.ProductDAO;
import entity.RFQ;
import entity.RFQItem;
import entity.Customer;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * CustomerRFQController - Xử lý các request RFQ từ phía Customer
 * URL Patterns:
 * - /rfq/form (GET) - Hiển thị form tạo RFQ
 * - /rfq/submit (POST) - Submit RFQ mới
 * - /rfq/list (GET) - Danh sách RFQ của customer
 * - /rfq/detail (GET) - Chi tiết RFQ
 * - /rfq/accept-date (POST) - Chấp nhận ngày giao mới
 * - /rfq/reject-date (POST) - Từ chối ngày giao mới
 * - /rfq/accept-quote (POST) - Chấp nhận báo giá
 * - /rfq/reject-quote (POST) - Từ chối báo giá
 */
@WebServlet(name = "CustomerRFQController", urlPatterns = {"/rfq/*"})
public class CustomerRFQController extends HttpServlet {

    private RFQDAO rfqDAO = new RFQDAO();
    private ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        if (pathInfo == null) pathInfo = "/list";
        
        // Check login
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login?redirect=rfq");
            return;
        }
        
        switch (pathInfo) {
            case "/form":
                showRFQForm(request, response, customer);
                break;
            case "/list":
                showRFQList(request, response, customer);
                break;
            case "/detail":
                showRFQDetail(request, response, customer);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/rfq/list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String pathInfo = request.getPathInfo();
        
        // Check login
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        switch (pathInfo) {
            case "/submit":
                submitRFQ(request, response, customer);
                break;
            case "/accept-date":
                acceptDate(request, response, customer);
                break;
            case "/reject-date":
                rejectDate(request, response, customer);
                break;
            case "/accept-quote":
                acceptQuote(request, response, customer);
                break;
            case "/reject-quote":
                rejectQuote(request, response, customer);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/rfq/list");
        }
    }

    private void showRFQForm(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        // Load products for selection (active products only)
        List<Map<String, Object>> products = productDAO.getProducts(null, null, null, true, "name", "asc", 1, 1000);
        request.setAttribute("products", products);
        request.setAttribute("customer", customer);
        request.getRequestDispatcher("/customer/rfq-form.jsp").forward(request, response);
    }

    private void showRFQList(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");
        String paymentMethod = request.getParameter("paymentMethod");
        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (Exception e) {}
        
        int pageSize = 5;
        List<RFQ> rfqs = rfqDAO.searchRFQs(keyword, status, null, customer.getCustomerID(), paymentMethod, page, pageSize);
        int totalCount = rfqDAO.countRFQs(keyword, status, null, customer.getCustomerID(), paymentMethod);
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        
        request.setAttribute("rfqs", rfqs);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("keyword", keyword);
        request.setAttribute("status", status);
        request.setAttribute("paymentMethod", paymentMethod);
        
        request.getRequestDispatcher("/customer/rfq-list.jsp").forward(request, response);
    }

    private void showRFQDetail(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        int rfqID = Integer.parseInt(request.getParameter("id"));
        RFQ rfq = rfqDAO.getRFQById(rfqID);
        
        // Security check - only owner can view
        if (rfq == null || rfq.getCustomerID() != customer.getCustomerID()) {
            response.sendRedirect(request.getContextPath() + "/rfq/list");
            return;
        }
        
        rfq.setHistory(rfqDAO.getRFQHistory(rfqID));
        request.setAttribute("rfq", rfq);
        request.getRequestDispatcher("/customer/rfq-detail.jsp").forward(request, response);
    }

    private void submitRFQ(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        try {
            RFQ rfq = new RFQ();
            rfq.setCustomerID(customer.getCustomerID());
            rfq.setCompanyName(request.getParameter("companyName"));
            rfq.setTaxID(request.getParameter("taxID"));
            rfq.setBusinessType(request.getParameter("businessType"));
            rfq.setContactPerson(request.getParameter("contactPerson"));
            rfq.setContactPhone(request.getParameter("contactPhone"));
            rfq.setContactEmail(request.getParameter("contactEmail"));
            rfq.setAlternativeContact(request.getParameter("alternativeContact"));
            rfq.setDeliveryAddress(request.getParameter("deliveryAddress"));
            rfq.setDeliveryCityId(request.getParameter("deliveryCityId"));
            rfq.setDeliveryDistrictId(request.getParameter("deliveryDistrictId"));
            rfq.setDeliveryWardId(request.getParameter("deliveryWardId"));
            rfq.setDeliveryInstructions(request.getParameter("deliveryInstructions"));
            rfq.setCustomerNotes(request.getParameter("customerNotes"));
            rfq.setPaymentMethod(request.getParameter("preferredPaymentMethod"));
            
            // Parse delivery date
            String deliveryDateStr = request.getParameter("requestedDeliveryDate");
            if (deliveryDateStr != null && !deliveryDateStr.isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                rfq.setRequestedDeliveryDate(new Timestamp(sdf.parse(deliveryDateStr).getTime()));
            }
            
            // Parse products
            List<RFQItem> items = new ArrayList<>();
            String[] productIds = request.getParameterValues("productId");
            String[] variantIds = request.getParameterValues("variantId");
            String[] quantities = request.getParameterValues("quantity");
            String[] specialReqs = request.getParameterValues("specialRequirements");
            
            // Minimum quantity for wholesale orders
            final int MIN_QUANTITY = 20;
            
            if (productIds != null) {
                for (int i = 0; i < productIds.length; i++) {
                    if (productIds[i] != null && !productIds[i].isEmpty()) {
                        RFQItem item = new RFQItem();
                        item.setProductID(Integer.parseInt(productIds[i]));
                        if (variantIds != null && i < variantIds.length && !variantIds[i].isEmpty()) {
                            item.setVariantID(Integer.parseInt(variantIds[i]));
                        }
                        int quantity = Integer.parseInt(quantities[i]);
                        
                        // Validate minimum quantity
                        if (quantity < MIN_QUANTITY) {
                            request.setAttribute("error", "Số lượng tối thiểu cho mỗi sản phẩm là " + MIN_QUANTITY + ". Vui lòng kiểm tra lại.");
                            showRFQForm(request, response, customer);
                            return;
                        }
                        
                        item.setQuantity(quantity);
                        if (specialReqs != null && i < specialReqs.length) {
                            item.setSpecialRequirements(specialReqs[i]);
                        }
                        
                        // Get product info for snapshot
                        Map<String, Object> product = productDAO.getProductById(item.getProductID());
                        if (product != null) {
                            item.setProductName((String) product.get("productName"));
                            // SKU will be set from variant if available
                        }
                        
                        items.add(item);
                    }
                }
            }
            
            if (items.isEmpty()) {
                request.setAttribute("error", "Vui lòng chọn ít nhất 1 sản phẩm");
                showRFQForm(request, response, customer);
                return;
            }
            
            int rfqID = rfqDAO.createRFQ(rfq, items);
            if (rfqID > 0) {
                response.sendRedirect(request.getContextPath() + "/rfq/detail?id=" + rfqID + "&success=created");
            } else {
                request.setAttribute("error", "Có lỗi xảy ra, vui lòng thử lại");
                showRFQForm(request, response, customer);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            showRFQForm(request, response, customer);
        }
    }

    private void acceptDate(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        int rfqID = Integer.parseInt(request.getParameter("rfqId"));
        RFQ rfq = rfqDAO.getRFQById(rfqID);
        
        if (rfq != null && rfq.getCustomerID() == customer.getCustomerID() 
            && RFQ.STATUS_DATE_PROPOSED.equals(rfq.getStatus())) {
            rfqDAO.acceptProposedDate(rfqID, customer.getCustomerID());
        }
        
        response.sendRedirect(request.getContextPath() + "/rfq/detail?id=" + rfqID);
    }

    private void rejectDate(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        int rfqID = Integer.parseInt(request.getParameter("rfqId"));
        String reason = request.getParameter("reason");
        RFQ rfq = rfqDAO.getRFQById(rfqID);
        
        if (rfq != null && rfq.getCustomerID() == customer.getCustomerID() 
            && RFQ.STATUS_DATE_PROPOSED.equals(rfq.getStatus())) {
            rfqDAO.rejectProposedDate(rfqID, reason, customer.getCustomerID());
        }
        
        response.sendRedirect(request.getContextPath() + "/rfq/detail?id=" + rfqID);
    }

    private void acceptQuote(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        int rfqID = Integer.parseInt(request.getParameter("rfqId"));
        RFQ rfq = rfqDAO.getRFQById(rfqID);
        
        if (rfq != null && rfq.getCustomerID() == customer.getCustomerID() 
            && RFQ.STATUS_QUOTED.equals(rfq.getStatus())) {
            rfqDAO.acceptQuotation(rfqID, customer.getCustomerID());
            // Redirect to checkout with RFQ
            response.sendRedirect(request.getContextPath() + "/checkout?rfqId=" + rfqID);
            return;
        }
        
        response.sendRedirect(request.getContextPath() + "/rfq/detail?id=" + rfqID);
    }

    private void rejectQuote(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        int rfqID = Integer.parseInt(request.getParameter("rfqId"));
        String reason = request.getParameter("reason");
        RFQ rfq = rfqDAO.getRFQById(rfqID);
        
        if (rfq != null && rfq.getCustomerID() == customer.getCustomerID() 
            && RFQ.STATUS_QUOTED.equals(rfq.getStatus())) {
            rfqDAO.rejectQuotation(rfqID, reason, customer.getCustomerID());
        }
        
        response.sendRedirect(request.getContextPath() + "/rfq/detail?id=" + rfqID);
    }
}
