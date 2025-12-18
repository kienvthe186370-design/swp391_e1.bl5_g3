package controller;

import DAO.RFQDAONew;
import DAO.QuotationDAO;
import entity.Employee;
import entity.RFQ;
import entity.RFQItem;
import entity.Quotation;
import entity.QuotationItem;
import utils.RolePermission;
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
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

/**
 * SellerQuotationController - Quản lý Quotation cho Seller
 * 
 * URL Patterns:
 * - /admin/quotations (GET) - Danh sách Quotation
 * - /admin/quotations/detail (GET) - Chi tiết Quotation
 * - /admin/quotations/form (GET) - Form tạo Quotation
 * - /admin/quotations/create (POST) - Tạo Quotation mới
 * - /admin/quotations/counter (POST) - Counter giá
 */
@WebServlet(name = "SellerQuotationController", urlPatterns = {"/admin/quotations", "/admin/quotations/*"})
public class SellerQuotationController extends HttpServlet {

    private RFQDAONew rfqDAO = new RFQDAONew();
    private QuotationDAO quotationDAO = new QuotationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        if (pathInfo == null) pathInfo = "";
        
        // Cũng check action parameter để hỗ trợ URL dạng ?action=detail&id=1
        String action = request.getParameter("action");

        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        if (employee == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Check permission
        if (!RolePermission.canProcessRFQ(employee.getRole())) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=access_denied");
            return;
        }

        // Ưu tiên action parameter
        if ("detail".equals(action) || "/detail".equals(pathInfo)) {
            showQuotationDetail(request, response, employee);
        } else if ("form".equals(action) || "/form".equals(pathInfo)) {
            showQuotationForm(request, response, employee);
        } else {
            showQuotationList(request, response, employee);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String pathInfo = request.getPathInfo();

        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        if (employee == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (!RolePermission.canProcessRFQ(employee.getRole())) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=access_denied");
            return;
        }

        switch (pathInfo) {
            case "/create":
                createQuotation(request, response, employee);
                break;
            case "/counter":
                counterPrice(request, response, employee);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/quotations");
        }
    }

    private void showQuotationList(HttpServletRequest request, HttpServletResponse response, Employee employee)
            throws ServletException, IOException {

        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (Exception ignored) {}
        int pageSize = 5;

        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");

        // Seller chỉ xem Quotation do mình tạo
        List<Quotation> quotations = quotationDAO.searchQuotations(keyword, status, 
                                                                    employee.getEmployeeID(), page, pageSize);
        int totalCount = quotationDAO.countQuotations(keyword, status, employee.getEmployeeID());
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        if (totalPages < 1) totalPages = 1; // Luôn có ít nhất 1 trang

        // Load RFQ info for each quotation
        for (Quotation q : quotations) {
            RFQ rfq = rfqDAO.getRFQById(q.getRfqID());
            q.setRfq(rfq);
        }

        // Stats count
        int sentCount = quotationDAO.countQuotations(null, Quotation.STATUS_SENT, employee.getEmployeeID());
        int negotiatingCount = quotationDAO.countQuotations(null, Quotation.STATUS_CUSTOMER_COUNTERED, employee.getEmployeeID())
                             + quotationDAO.countQuotations(null, Quotation.STATUS_SELLER_COUNTERED, employee.getEmployeeID());
        int paidCount = quotationDAO.countQuotations(null, Quotation.STATUS_PAID, employee.getEmployeeID());
        int rejectedCount = quotationDAO.countQuotations(null, Quotation.STATUS_REJECTED, employee.getEmployeeID());

        request.setAttribute("quotations", quotations);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("keyword", keyword);
        request.setAttribute("status", status);
        request.setAttribute("sentCount", sentCount);
        request.setAttribute("negotiatingCount", negotiatingCount);
        request.setAttribute("paidCount", paidCount);
        request.setAttribute("rejectedCount", rejectedCount);

        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-quotation-list.jsp")
               .forward(request, response);
    }

    private void showQuotationDetail(HttpServletRequest request, HttpServletResponse response, Employee employee)
            throws ServletException, IOException {

        try {
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/quotations");
                return;
            }
            
            int quotationID = Integer.parseInt(idParam);
            Quotation quotation = quotationDAO.getQuotationById(quotationID);

            if (quotation == null) {
                response.sendRedirect(request.getContextPath() + "/admin/quotations");
                return;
            }

            // Load RFQ info
            RFQ rfq = rfqDAO.getRFQById(quotation.getRfqID());
            quotation.setRfq(rfq);

            // Load items and history
            quotation.setItems(quotationDAO.getQuotationItems(quotationID));
            quotation.setHistory(quotationDAO.getQuotationHistory(quotationID));

            request.setAttribute("quotation", quotation);
            request.getRequestDispatcher("/AdminLTE-3.2.0/quotation-detail.jsp")
                   .forward(request, response);
                   
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/quotations");
        }
    }

    private void showQuotationForm(HttpServletRequest request, HttpServletResponse response, Employee employee)
            throws ServletException, IOException {

        int rfqID = Integer.parseInt(request.getParameter("rfqId"));
        RFQ rfq = rfqDAO.getRFQById(rfqID);

        if (rfq == null) {
            response.sendRedirect(request.getContextPath() + "/admin/rfq");
            return;
        }

        // Security check - Seller chỉ tạo quotation cho RFQ được assign
        if (!rfqDAO.isRFQAssignedToSeller(rfqID, employee.getEmployeeID())) {
            response.sendRedirect(request.getContextPath() + "/admin/rfq?error=access_denied");
            return;
        }

        // Check if can create quotation
        if (!rfq.canCreateQuotation()) {
            response.sendRedirect(request.getContextPath() + "/admin/rfq/detail?id=" + rfqID + "&error=cannot_create_quotation");
            return;
        }

        // Check if quotation already exists
        Quotation existingQuotation = quotationDAO.getQuotationByRFQId(rfqID);
        if (existingQuotation != null) {
            response.sendRedirect(request.getContextPath() + "/admin/quotations/detail?id=" + existingQuotation.getQuotationID());
            return;
        }

        // Load cost prices for items
        for (RFQItem item : rfq.getItems()) {
            if (item.getVariantID() != null && item.getCostPrice() == null) {
                item.setCostPrice(quotationDAO.getWeightedAverageCost(item.getVariantID()));
            }
        }

        // Calculate total weight for shipping
        int totalWeight = 0;
        for (RFQItem item : rfq.getItems()) {
            totalWeight += item.getQuantity() * 500; // Default 500g per item
        }

        request.setAttribute("rfq", rfq);
        request.setAttribute("totalWeight", totalWeight);
        request.setAttribute("deliveryCityId", rfq.getDeliveryCityId() != null ? rfq.getDeliveryCityId() : "");
        request.setAttribute("deliveryDistrictId", rfq.getDeliveryDistrictId() != null ? rfq.getDeliveryDistrictId() : "");

        request.getRequestDispatcher("/AdminLTE-3.2.0/quotation-form.jsp")
               .forward(request, response);
    }

    private void createQuotation(HttpServletRequest request, HttpServletResponse response, Employee employee)
            throws ServletException, IOException {

        try {
            int rfqID = Integer.parseInt(request.getParameter("rfqId"));
            RFQ rfq = rfqDAO.getRFQById(rfqID);

            if (rfq == null || !rfq.canCreateQuotation()) {
                response.sendRedirect(request.getContextPath() + "/admin/rfq");
                return;
            }

            // Security check
            if (!rfqDAO.isRFQAssignedToSeller(rfqID, employee.getEmployeeID())) {
                response.sendRedirect(request.getContextPath() + "/admin/rfq?error=access_denied");
                return;
            }

            // Parse quotation data
            Quotation quotation = new Quotation();
            quotation.setRfqID(rfqID);
            quotation.setCreatedBy(employee.getEmployeeID());

            // Shipping info
            quotation.setShippingCarrierId(request.getParameter("shippingCarrierId"));
            quotation.setShippingCarrierName(request.getParameter("shippingCarrierName"));
            quotation.setShippingServiceName(request.getParameter("shippingServiceName"));
            
            String estimatedDaysStr = request.getParameter("estimatedDeliveryDays");
            quotation.setEstimatedDeliveryDays(estimatedDaysStr != null && !estimatedDaysStr.isEmpty() 
                                                ? Integer.parseInt(estimatedDaysStr) : 3);

            // Pricing
            BigDecimal shippingFee = new BigDecimal(request.getParameter("shippingFee"));
            BigDecimal taxPercent = new BigDecimal(request.getParameter("taxPercent"));
            quotation.setShippingFee(shippingFee);

            // Payment & Terms
            quotation.setPaymentMethod(request.getParameter("paymentMethod"));
            quotation.setQuotationTerms(request.getParameter("additionalTerms"));
            quotation.setWarrantyTerms(request.getParameter("warrantyTerms"));
            quotation.setSellerNotes(request.getParameter("sellerNotes"));

            // Valid until (default 7 days)
            String validUntilStr = request.getParameter("validUntil");
            if (validUntilStr != null && !validUntilStr.isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                quotation.setQuotationValidUntil(new Timestamp(sdf.parse(validUntilStr).getTime()));
            } else {
                Calendar cal = Calendar.getInstance();
                cal.add(Calendar.DAY_OF_MONTH, 7);
                quotation.setQuotationValidUntil(new Timestamp(cal.getTimeInMillis()));
            }

            // Parse item pricing
            List<QuotationItem> items = new ArrayList<>();
            List<RFQItem> rfqItems = rfq.getItems();
            BigDecimal subtotal = BigDecimal.ZERO;

            for (int i = 0; i < rfqItems.size(); i++) {
                RFQItem rfqItem = rfqItems.get(i);
                QuotationItem qItem = new QuotationItem();
                qItem.setRfqItemID(rfqItem.getRfqItemID());

                // Get cost price
                BigDecimal costPrice = quotationDAO.getWeightedAverageCost(rfqItem.getVariantID());
                if (costPrice == null || costPrice.compareTo(BigDecimal.ZERO) == 0) {
                    costPrice = new BigDecimal("100000"); // Default cost
                }
                qItem.setCostPrice(costPrice);

                // Get profit margin from form
                String profitMarginStr = request.getParameter("items[" + i + "][profitMargin]");
                BigDecimal profitMargin = (profitMarginStr != null && !profitMarginStr.isEmpty()) 
                                          ? new BigDecimal(profitMarginStr) : new BigDecimal("20");
                qItem.setProfitMarginPercent(profitMargin);

                // Calculate unit price
                BigDecimal margin = BigDecimal.ONE.add(profitMargin.divide(BigDecimal.valueOf(100)));
                BigDecimal unitPrice = costPrice.multiply(margin);
                qItem.setUnitPrice(unitPrice);

                // Calculate subtotal
                BigDecimal itemSubtotal = unitPrice.multiply(BigDecimal.valueOf(rfqItem.getQuantity()));
                qItem.setSubtotal(itemSubtotal);
                subtotal = subtotal.add(itemSubtotal);

                // Notes
                String notesStr = request.getParameter("items[" + i + "][notes]");
                qItem.setNotes(notesStr);

                items.add(qItem);
            }

            // Calculate totals
            BigDecimal taxAmount = subtotal.multiply(taxPercent).divide(BigDecimal.valueOf(100));
            BigDecimal totalAmount = subtotal.add(shippingFee).add(taxAmount);

            quotation.setSubtotalAmount(subtotal);
            quotation.setTaxAmount(taxAmount);
            quotation.setTotalAmount(totalAmount);

            // Create quotation
            int quotationID = quotationDAO.createQuotation(quotation, items);

            if (quotationID > 0) {
                response.sendRedirect(request.getContextPath() + "/admin/quotations/detail?id=" + quotationID + "&success=created");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/quotations/form?rfqId=" + rfqID + "&error=create_failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/rfq?error=quotation_failed");
        }
    }

    private void counterPrice(HttpServletRequest request, HttpServletResponse response, Employee employee)
            throws ServletException, IOException {

        try {
            int quotationID = Integer.parseInt(request.getParameter("quotationId"));
            String counterPriceStr = request.getParameter("counterPrice");
            String note = request.getParameter("note");

            BigDecimal counterPrice = new BigDecimal(counterPriceStr);

            boolean success = quotationDAO.sellerCounterPrice(quotationID, counterPrice, note, employee.getEmployeeID());

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/quotations/detail?id=" + quotationID + "&success=countered");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/quotations/detail?id=" + quotationID + "&error=counter_failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/quotations?error=counter_failed");
        }
    }
}
