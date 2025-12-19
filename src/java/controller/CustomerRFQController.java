package controller;

import DAO.RFQDAONew;
import DAO.QuotationDAO;
import DAO.ProductDAO;
import entity.RFQ;
import entity.RFQItem;
import entity.Quotation;
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
 * 
 * Luồng mới (đã tách Quotation):
 * 1. Customer tạo RFQ -> Auto-assign cho Seller
 * 2. Thương lượng ngày giao (max 3 lần)
 * 3. Seller tạo Quotation (xử lý ở SellerQuotationController)
 * 4. Customer xem/thương lượng Quotation (xử lý ở CustomerQuotationController)
 * 
 * URL Patterns:
 * - /rfq/form (GET) - Hiển thị form tạo RFQ
 * - /rfq/confirm (POST) - Xác nhận trước khi submit
 * - /rfq/submit (POST) - Submit RFQ mới
 * - /rfq/list (GET) - Danh sách RFQ của customer
 * - /rfq/detail (GET) - Chi tiết RFQ
 * - /rfq/accept-date (POST) - Chấp nhận ngày giao đề xuất
 * - /rfq/counter-date (POST) - Counter ngày giao
 * - /rfq/cancel (POST) - Hủy RFQ
 */
@WebServlet(name = "CustomerRFQController", urlPatterns = {"/rfq/*"})
public class CustomerRFQController extends HttpServlet {

    private RFQDAONew rfqDAO = new RFQDAONew();
    private QuotationDAO quotationDAO = new QuotationDAO();
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
            case "/form":
                // Edit draft - quay lại form với dữ liệu đã nhập
                editDraftRFQ(request, response, customer);
                break;
            case "/confirm":
                confirmRFQ(request, response, customer);
                break;
            case "/submit":
                submitRFQ(request, response, customer);
                break;
            case "/accept-date":
                acceptDate(request, response, customer);
                break;
            case "/counter-date":
                counterDate(request, response, customer);
                break;
            case "/cancel":
                cancelRFQ(request, response, customer);
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
    
    /**
     * Edit draft RFQ - quay lại form với dữ liệu đã nhập trước đó
     */
    private void editDraftRFQ(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        try {
            // Build RFQ từ request parameters (dữ liệu draft)
            RFQData data = buildRFQFromRequest(request, customer);
            RFQ draftRfq = data.getRfq();
            draftRfq.setItems(data.getItems());
            
            // Load products for selection
            List<Map<String, Object>> products = productDAO.getProducts(null, null, null, true, "name", "asc", 1, 1000);
            
            request.setAttribute("products", products);
            request.setAttribute("customer", customer);
            request.setAttribute("draftRfq", draftRfq);
            request.setAttribute("isEditDraft", true);
            
            request.getRequestDispatcher("/customer/rfq-form.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            // Nếu có lỗi, quay về form trống
            showRFQForm(request, response, customer);
        }
    }

    private void showRFQList(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");
        String sortBy = request.getParameter("sortBy");
        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (Exception e) {}
        
        int pageSize = 5;
        List<RFQ> rfqs = rfqDAO.getCustomerRFQsWithSort(customer.getCustomerID(), keyword, status, sortBy, page, pageSize);
        int totalCount = rfqDAO.countCustomerRFQs(customer.getCustomerID(), keyword, status);
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        if (totalPages < 1) totalPages = 1;
        
        request.setAttribute("rfqs", rfqs);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("keyword", keyword);
        request.setAttribute("status", status);
        request.setAttribute("sortBy", sortBy);
        
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
        
        // Load Quotation if exists
        Quotation quotation = quotationDAO.getQuotationByRFQId(rfqID);
        if (quotation != null) {
            rfq.setQuotation(quotation);
        }
        
        request.setAttribute("rfq", rfq);
        request.getRequestDispatcher("/customer/rfq-detail.jsp").forward(request, response);
    }

    private void submitRFQ(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        try {
            RFQData data = buildRFQFromRequest(request, customer);
            RFQ rfq = data.getRfq();
            List<RFQItem> items = data.getItems();
            
            int rfqID = rfqDAO.createRFQ(rfq, items);
            
            if (rfqID > 0) {
                response.sendRedirect(request.getContextPath() + "/rfq/detail?id=" + rfqID + "&success=created");
            } else {
                String lastError = rfqDAO.getLastError();
                request.setAttribute("error", "Có lỗi xảy ra khi tạo RFQ. " + (lastError != null ? lastError : ""));
                showRFQForm(request, response, customer);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi: " + e.getMessage());
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
        rfq.setPaymentTermsPreference(request.getParameter("paymentTermsPreference"));
        
        String deliveryDateStr = request.getParameter("requestedDeliveryDate");
        if (deliveryDateStr != null && !deliveryDateStr.isEmpty()) {
            SimpleDateFormat sdf;
            if (deliveryDateStr.contains("/")) {
                sdf = new SimpleDateFormat("dd/MM/yyyy");
            } else {
                sdf = new SimpleDateFormat("yyyy-MM-dd");
            }
            rfq.setRequestedDeliveryDate(new Timestamp(sdf.parse(deliveryDateStr).getTime()));
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
                        throw new Exception("Số lượng tối thiểu cho mỗi sản phẩm là " + MIN_QUANTITY);
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

        public RFQ getRfq() { return rfq; }
        public List<RFQItem> getItems() { return items; }
    }

    // ==================== DATE NEGOTIATION ====================

    private void acceptDate(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        int rfqID = Integer.parseInt(request.getParameter("rfqId"));
        
        // Security check
        if (!rfqDAO.isRFQOwnedByCustomer(rfqID, customer.getCustomerID())) {
            response.sendRedirect(request.getContextPath() + "/rfq/list");
            return;
        }
        
        RFQ rfq = rfqDAO.getRFQById(rfqID);
        if (rfq != null && rfq.canAcceptDate()) {
            rfqDAO.acceptProposedDate(rfqID, customer.getCustomerID());
            response.sendRedirect(request.getContextPath() + "/rfq/detail?id=" + rfqID + "&success=date_accepted");
        } else {
            response.sendRedirect(request.getContextPath() + "/rfq/detail?id=" + rfqID + "&error=cannot_accept");
        }
    }

    private void counterDate(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        try {
            int rfqID = Integer.parseInt(request.getParameter("rfqId"));
            String counterDateStr = request.getParameter("counterDate");
            String note = request.getParameter("note");
            
            // Security check
            if (!rfqDAO.isRFQOwnedByCustomer(rfqID, customer.getCustomerID())) {
                response.sendRedirect(request.getContextPath() + "/rfq/list");
                return;
            }
            
            RFQ rfq = rfqDAO.getRFQById(rfqID);
            if (rfq == null || !rfq.canCustomerCounterDate()) {
                response.sendRedirect(request.getContextPath() + "/rfq/detail?id=" + rfqID + "&error=cannot_counter");
                return;
            }
            
            // Parse date
            SimpleDateFormat sdf;
            if (counterDateStr.contains("/")) {
                sdf = new SimpleDateFormat("dd/MM/yyyy");
            } else {
                sdf = new SimpleDateFormat("yyyy-MM-dd");
            }
            Timestamp counterDate = new Timestamp(sdf.parse(counterDateStr).getTime());
            
            boolean success = rfqDAO.customerCounterDate(rfqID, counterDate, note, customer.getCustomerID());
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/rfq/detail?id=" + rfqID + "&success=date_countered");
            } else {
                response.sendRedirect(request.getContextPath() + "/rfq/detail?id=" + rfqID + "&error=counter_failed");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/rfq/list?error=counter_failed");
        }
    }

    private void cancelRFQ(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        int rfqID = Integer.parseInt(request.getParameter("rfqId"));
        String reason = request.getParameter("reason");
        
        // Security check
        if (!rfqDAO.isRFQOwnedByCustomer(rfqID, customer.getCustomerID())) {
            response.sendRedirect(request.getContextPath() + "/rfq/list");
            return;
        }
        
        rfqDAO.cancelRFQ(rfqID, reason, customer.getCustomerID(), "customer");
        response.sendRedirect(request.getContextPath() + "/rfq/detail?id=" + rfqID + "&success=cancelled");
    }
}
