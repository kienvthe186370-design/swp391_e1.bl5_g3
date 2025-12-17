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
 * - /rfq/confirm (POST) - Xác nhận trước khi submit
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
            case "/edit":
                editDraftRFQ(request, response, customer);
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
            case "/confirm":
                confirmRFQ(request, response, customer);
                break;
            case "/submit":
                submitRFQ(request, response, customer);
                break;
            case "/save-draft":
                saveDraft(request, response, customer);
                break;
            case "/edit-draft":
                editDraftFromConfirm(request, response, customer);
                break;
            case "/submit-draft":
                submitDraft(request, response, customer);
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
        
        // Check and update if quotation has expired
        if (RFQ.STATUS_QUOTED.equals(rfq.getStatus()) && rfq.isQuoteExpired()) {
            rfqDAO.checkAndExpireQuotation(rfqID);
            rfq = rfqDAO.getRFQById(rfqID); // Reload after update
        }
        
        rfq.setHistory(rfqDAO.getRFQHistory(rfqID));
        request.setAttribute("rfq", rfq);
        request.getRequestDispatcher("/customer/rfq-detail.jsp").forward(request, response);
    }

    private void submitRFQ(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        try {
            System.out.println("[CustomerRFQ] === START submitRFQ ===");
            RFQData data = buildRFQFromRequest(request, customer);
            RFQ rfq = data.getRfq();
            List<RFQItem> items = data.getItems();
            
            System.out.println("[CustomerRFQ] RFQ Data:");
            System.out.println("  - CustomerID: " + rfq.getCustomerID());
            System.out.println("  - CompanyName: " + rfq.getCompanyName());
            System.out.println("  - ContactPerson: " + rfq.getContactPerson());
            System.out.println("  - DeliveryAddress: " + rfq.getDeliveryAddress());
            System.out.println("  - PaymentMethod: " + rfq.getPaymentMethod());
            System.out.println("  - ShippingCarrierId: " + rfq.getShippingCarrierId());
            System.out.println("  - Items count: " + items.size());
            
            int rfqID = rfqDAO.createRFQ(rfq, items);
            System.out.println("[CustomerRFQ] createRFQ result: " + rfqID);
            
            if (rfqID > 0) {
                response.sendRedirect(request.getContextPath() + "/rfq/detail?id=" + rfqID + "&success=created");
            } else {
                String lastError = rfqDAO.getLastError();
                request.setAttribute("error", "Có lỗi xảy ra khi tạo RFQ. " + (lastError != null ? lastError : "Vui lòng kiểm tra log server."));
                showRFQForm(request, response, customer);
            }
            
        } catch (Exception e) {
            System.err.println("[CustomerRFQ] ERROR in submitRFQ: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Lỗi: " + e.getClass().getSimpleName() + " - " + e.getMessage());
            showRFQForm(request, response, customer);
        }
    }

    private void confirmRFQ(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        try {
            RFQData data = buildRFQFromRequest(request, customer);
            RFQ rfq = data.getRfq();
            rfq.setStatus(null);
            rfq.setHistory(null);
            
            request.setAttribute("rfq", rfq);
            request.setAttribute("isDraft", true);
            request.getRequestDispatcher("/customer/rfq-detail.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi khi xác nhận: " + e.getMessage());
            showRFQForm(request, response, customer);
        }
    }

    private RFQData buildRFQFromRequest(HttpServletRequest request, Customer customer) throws Exception {
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
        rfq.setDeliveryStreet(request.getParameter("deliveryStreet"));
        rfq.setDeliveryCity(request.getParameter("deliveryCity"));
        rfq.setDeliveryCityId(request.getParameter("deliveryCityId"));
        rfq.setDeliveryDistrict(request.getParameter("deliveryDistrict"));
        rfq.setDeliveryDistrictId(request.getParameter("deliveryDistrictId"));
        rfq.setDeliveryWard(request.getParameter("deliveryWard"));
        rfq.setDeliveryWardId(request.getParameter("deliveryWardId"));
        rfq.setDeliveryInstructions(request.getParameter("deliveryInstructions"));
        rfq.setCustomerNotes(request.getParameter("customerNotes"));
        rfq.setPaymentMethod(request.getParameter("preferredPaymentMethod"));
        
        String deliveryDateStr = request.getParameter("requestedDeliveryDate");
        if (deliveryDateStr != null && !deliveryDateStr.isEmpty()) {
            // Support both dd/MM/yyyy and yyyy-MM-dd formats
            SimpleDateFormat sdf;
            if (deliveryDateStr.contains("/")) {
                sdf = new SimpleDateFormat("dd/MM/yyyy");
            } else {
                sdf = new SimpleDateFormat("yyyy-MM-dd");
            }
            rfq.setRequestedDeliveryDate(new Timestamp(sdf.parse(deliveryDateStr).getTime()));
        }
        
        // Shipping method info
        rfq.setShippingCarrierId(request.getParameter("shippingCarrierId"));
        rfq.setShippingCarrierName(request.getParameter("shippingCarrierName"));
        rfq.setShippingServiceName(request.getParameter("shippingServiceName"));
        
        String shippingFeeStr = request.getParameter("shippingFee");
        if (shippingFeeStr != null && !shippingFeeStr.isEmpty()) {
            try {
                rfq.setShippingFee(new java.math.BigDecimal(shippingFeeStr));
            } catch (NumberFormatException e) {
                // Ignore invalid shipping fee
            }
        }
        
        String estimatedDaysStr = request.getParameter("estimatedDeliveryDays");
        if (estimatedDaysStr != null && !estimatedDaysStr.isEmpty()) {
            try {
                rfq.setEstimatedDeliveryDays(Integer.parseInt(estimatedDaysStr));
            } catch (NumberFormatException e) {
                rfq.setEstimatedDeliveryDays(3); // Default
            }
        }
        
        List<RFQItem> items = new ArrayList<>();
        String[] productIds = request.getParameterValues("productId");
        String[] variantIds = request.getParameterValues("variantId");
        String[] quantities = request.getParameterValues("quantity");
        String[] specialReqs = request.getParameterValues("specialRequirements");
        
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
                    
                    if (quantity < MIN_QUANTITY) {
                        throw new Exception("Số lượng tối thiểu cho mỗi sản phẩm là " + MIN_QUANTITY + ". Vui lòng kiểm tra lại.");
                    }
                    
                    item.setQuantity(quantity);
                    if (specialReqs != null && i < specialReqs.length) {
                        item.setSpecialRequirements(specialReqs[i]);
                    }
                    
                    // Get product name and image
                    Map<String, Object> product = productDAO.getProductById(item.getProductID());
                    if (product != null) {
                        item.setProductName((String) product.get("productName"));
                        item.setProductImage((String) product.get("mainImageUrl"));
                    }
                    
                    // Get variant SKU
                    if (item.getVariantID() != null) {
                        Map<String, Object> variant = productDAO.getVariantById(item.getVariantID());
                        if (variant != null) {
                            item.setSku((String) variant.get("sku"));
                        }
                    }
                    
                    items.add(item);
                }
            }
        }
        
        if (items.isEmpty()) {
            throw new Exception("Vui lòng chọn ít nhất 1 sản phẩm");
        }

        // Gán danh sách item vào RFQ để JSP (rfq-detail) hiển thị được sản phẩm khi đang ở bước xác nhận
        rfq.setItems(items);
        
        return new RFQData(rfq, items);
    }
    
    private static class RFQData {
        private final RFQ rfq;
        private final List<RFQItem> items;

        public RFQData(RFQ rfq, List<RFQItem> items) {
            this.rfq = rfq;
            this.items = items;
        }

        public RFQ getRfq() {
            return rfq;
        }

        public List<RFQItem> getItems() {
            return items;
        }
    }

    private void editDraftRFQ(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        int rfqID = Integer.parseInt(request.getParameter("id"));
        RFQ rfq = rfqDAO.getRFQById(rfqID);
        
        // Security check - only owner can edit and only Draft status
        if (rfq == null || rfq.getCustomerID() != customer.getCustomerID() || !RFQ.STATUS_DRAFT.equals(rfq.getStatus())) {
            response.sendRedirect(request.getContextPath() + "/rfq/list");
            return;
        }
        
        // Load products for selection
        List<Map<String, Object>> products = productDAO.getProducts(null, null, null, true, "name", "asc", 1, 1000);
        request.setAttribute("products", products);
        request.setAttribute("customer", customer);
        request.setAttribute("draftRfq", rfq);
        request.getRequestDispatcher("/customer/rfq-form.jsp").forward(request, response);
    }
    
    private void editDraftFromConfirm(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        // Lấy dữ liệu từ form confirm và chuyển về form để chỉnh sửa
        try {
            RFQData data = buildRFQFromRequest(request, customer);
            RFQ rfq = data.getRfq();
            
            // Lấy draftRfqId nếu có
            String draftRfqIdStr = request.getParameter("draftRfqId");
            if (draftRfqIdStr != null && !draftRfqIdStr.isEmpty()) {
                rfq.setRfqID(Integer.parseInt(draftRfqIdStr));
            }
            
            List<Map<String, Object>> products = productDAO.getProducts(null, null, null, true, "name", "asc", 1, 1000);
            request.setAttribute("products", products);
            request.setAttribute("customer", customer);
            request.setAttribute("draftRfq", rfq);
            request.getRequestDispatcher("/customer/rfq-form.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/rfq/form");
        }
    }
    
    private void saveDraft(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        try {
            RFQData data = buildRFQFromRequest(request, customer);
            RFQ rfq = data.getRfq();
            List<RFQItem> items = data.getItems();
            
            // Check if updating existing draft
            String draftRfqIdStr = request.getParameter("draftRfqId");
            int rfqID;
            
            if (draftRfqIdStr != null && !draftRfqIdStr.isEmpty()) {
                int existingId = Integer.parseInt(draftRfqIdStr);
                RFQ existingRfq = rfqDAO.getRFQById(existingId);
                if (existingRfq != null && existingRfq.getCustomerID() == customer.getCustomerID() 
                    && RFQ.STATUS_DRAFT.equals(existingRfq.getStatus())) {
                    // Update existing draft
                    rfqDAO.updateDraftRFQ(existingId, rfq, items);
                    rfqID = existingId;
                } else {
                    rfqID = rfqDAO.createDraftRFQ(rfq, items);
                }
            } else {
                rfqID = rfqDAO.createDraftRFQ(rfq, items);
            }
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":true,\"rfqId\":" + rfqID + "}");
        } catch (Exception e) {
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":false,\"error\":\"" + e.getMessage() + "\"}");
        }
    }
    
    private void submitDraft(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        int rfqID = Integer.parseInt(request.getParameter("rfqId"));
        RFQ rfq = rfqDAO.getRFQById(rfqID);
        
        // Security check
        if (rfq == null || rfq.getCustomerID() != customer.getCustomerID() || !RFQ.STATUS_DRAFT.equals(rfq.getStatus())) {
            response.sendRedirect(request.getContextPath() + "/rfq/list");
            return;
        }
        
        // Submit draft - change status to Pending
        boolean success = rfqDAO.submitDraftRFQ(rfqID);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/rfq/detail?id=" + rfqID + "&success=created");
        } else {
            response.sendRedirect(request.getContextPath() + "/rfq/detail?id=" + rfqID + "&error=submit_failed");
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
            
            // Check if quotation has expired
            if (rfq.isQuoteExpired()) {
                rfqDAO.checkAndExpireQuotation(rfqID);
                response.sendRedirect(request.getContextPath() + "/rfq/detail?id=" + rfqID + "&error=quote_expired");
                return;
            }
            
            // Redirect to RFQ detail page - customer will use the payment form there
            // Status will only change to QuoteAccepted AFTER successful payment in RFQPaymentCallbackServlet
            response.sendRedirect(request.getContextPath() + "/rfq/detail?id=" + rfqID);
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
