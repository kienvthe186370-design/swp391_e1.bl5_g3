package controller;

import DAO.QuotationDAO;
import DAO.RFQDAONew;
import DAO.OrderDAO;
import DAO.CustomerAddressDAO;
import entity.Quotation;
import entity.RFQ;
import entity.CustomerAddress;
import service.VNPayService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

/**
 * Servlet xử lý callback từ VNPay cho thanh toán Quotation
 * Sau khi thanh toán thành công:
 * 1. Cập nhật Quotation status -> Paid
 * 2. Cập nhật RFQ status -> Completed
 * 3. Tạo đơn hàng (Order) từ Quotation
 */
@WebServlet(name = "QuotationPaymentCallbackServlet", urlPatterns = {"/quotation/payment-callback"})
public class QuotationPaymentCallbackServlet extends HttpServlet {
    
    private VNPayService vnPayService = new VNPayService();
    private QuotationDAO quotationDAO = new QuotationDAO();
    private RFQDAONew rfqDAO = new RFQDAONew();
    private OrderDAO orderDAO = new OrderDAO();
    private CustomerAddressDAO addressDAO = new CustomerAddressDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("\n========== QUOTATION PAYMENT CALLBACK ==========");
        
        HttpSession session = request.getSession();
        
        // Get all parameters from VNPay
        Map<String, String> params = new HashMap<>();
        Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            String paramValue = request.getParameter(paramName);
            params.put(paramName, paramValue);
            System.out.println("[Quotation Callback] " + paramName + " = " + paramValue);
        }

        // Get response info
        String vnp_ResponseCode = params.get("vnp_ResponseCode");
        String vnp_TxnRef = params.get("vnp_TxnRef"); // Quotation Code
        String vnp_Amount = params.get("vnp_Amount");
        String vnp_TransactionNo = params.get("vnp_TransactionNo");
        
        // Validate callback
        boolean isValid = vnPayService.validateCallback(params);
        boolean isSuccess = vnPayService.isPaymentSuccess(vnp_ResponseCode);
        String message = vnPayService.getPaymentMessage(vnp_ResponseCode);
        
        System.out.println("[Quotation Callback] Valid: " + isValid);
        System.out.println("[Quotation Callback] Success: " + isSuccess);
        System.out.println("[Quotation Callback] Message: " + message);
        
        // Get pending Quotation from session
        Integer pendingQuotationID = (Integer) session.getAttribute("pendingQuotationID");
        BigDecimal paymentAmount = (BigDecimal) session.getAttribute("quotationPaymentAmount");
        
        // Clear session attributes
        session.removeAttribute("pendingQuotationID");
        session.removeAttribute("quotationPaymentAmount");
        
        StringBuilder debugLog = new StringBuilder();
        debugLog.append("Session pendingQuotationID: ").append(pendingQuotationID).append("\n");
        debugLog.append("vnp_TxnRef: ").append(vnp_TxnRef).append("\n");
        
        if (pendingQuotationID == null) {
            // Try to find Quotation by code
            String quotationCode = vnp_TxnRef;
            if (quotationCode != null && quotationCode.contains("_")) {
                quotationCode = quotationCode.substring(0, quotationCode.indexOf("_"));
            }
            debugLog.append("Extracted Quotation Code: ").append(quotationCode).append("\n");
            
            Quotation quotation = quotationDAO.getQuotationByCode(quotationCode);
            if (quotation != null) {
                pendingQuotationID = quotation.getQuotationID();
                debugLog.append("Found Quotation ID: ").append(pendingQuotationID).append("\n");
            }
        }
        
        if (pendingQuotationID != null && isValid && isSuccess) {
            // Payment successful
            debugLog.append("=== PAYMENT SUCCESS - Processing ===\n");
            
            Quotation quotation = quotationDAO.getQuotationById(pendingQuotationID);
            
            if (quotation != null) {
                System.out.println("[Quotation Callback] Quotation loaded: " + quotation.getQuotationCode());
                
                // Load RFQ
                RFQ rfq = rfqDAO.getRFQById(quotation.getRfqID());
                quotation.setRfq(rfq);
                
                if (rfq != null) {
                    System.out.println("[Quotation Callback] RFQ: " + rfq.getRfqCode());
                    System.out.println("[Quotation Callback] RFQ AssignedTo (Seller): " + rfq.getAssignedTo());
                    debugLog.append("RFQ AssignedTo: ").append(rfq.getAssignedTo()).append("\n");
                    
                    // 1. Create delivery address from RFQ
                    Integer addressID = createAddressFromRFQ(rfq);
                    System.out.println("[Quotation Callback] Created AddressID: " + addressID);
                    
                    // 2. Create Order from Quotation
                    System.out.println("[Quotation Callback] Creating order from Quotation...");
                    int orderID = orderDAO.createOrderFromQuotation(quotation, rfq, addressID, vnp_TransactionNo);
                    System.out.println("[Quotation Callback] Order creation result: " + orderID);
                    
                    if (orderID > 0) {
                        debugLog.append("Created Order ID: ").append(orderID).append("\n");
                        
                        // 3. Update Quotation status to Paid
                        boolean quotationUpdated = quotationDAO.markAsPaid(pendingQuotationID, vnp_TransactionNo);
                        debugLog.append("Quotation status update: ").append(quotationUpdated).append("\n");
                        
                        // 4. Update RFQ status to Completed with Order ID
                        boolean rfqUpdated = rfqDAO.completeRFQ(rfq.getRfqID(), orderID);
                        debugLog.append("RFQ status update: ").append(rfqUpdated).append("\n");
                        
                        // Set success attributes
                        request.setAttribute("success", true);
                        request.setAttribute("quotation", quotation);
                        request.setAttribute("rfq", rfq);
                        request.setAttribute("orderID", orderID);
                        request.setAttribute("paymentAmount", paymentAmount != null ? paymentAmount : quotation.getTotalAmount());
                        request.setAttribute("transactionNo", vnp_TransactionNo);
                        request.setAttribute("message", "Thanh toán thành công! Đơn hàng đã được tạo.");
                    } else {
                        // Order creation failed
                        debugLog.append("Order creation FAILED!\n");
                        
                        // Still mark quotation as paid
                        quotationDAO.markAsPaid(pendingQuotationID, vnp_TransactionNo);
                        
                        request.setAttribute("success", true);
                        request.setAttribute("quotation", quotation);
                        request.setAttribute("rfq", rfq);
                        request.setAttribute("paymentAmount", paymentAmount);
                        request.setAttribute("transactionNo", vnp_TransactionNo);
                        request.setAttribute("message", "Thanh toán thành công! Vui lòng liên hệ hỗ trợ để hoàn tất đơn hàng.");
                    }
                } else {
                    debugLog.append("RFQ not found!\n");
                    request.setAttribute("success", false);
                    request.setAttribute("message", "Không tìm thấy thông tin RFQ");
                }
            } else {
                debugLog.append("Quotation object is NULL!\n");
                request.setAttribute("success", false);
                request.setAttribute("message", "Không tìm thấy thông tin báo giá");
            }
        } else {
            // Payment failed or invalid
            debugLog.append("=== PAYMENT FAILED or INVALID ===\n");
            request.setAttribute("success", false);
            request.setAttribute("message", message != null ? message : "Thanh toán thất bại");
            request.setAttribute("errorCode", vnp_ResponseCode);
        }
        
        request.setAttribute("quotationCode", vnp_TxnRef);
        request.setAttribute("debugLog", debugLog.toString());
        request.getRequestDispatcher("/customer/quotation-payment-result.jsp").forward(request, response);
    }

    /**
     * Tạo địa chỉ giao hàng từ thông tin RFQ
     */
    private Integer createAddressFromRFQ(RFQ rfq) {
        try {
            CustomerAddress address = new CustomerAddress();
            address.setCustomerID(rfq.getCustomerID());
            address.setRecipientName(rfq.getContactPerson());
            address.setPhone(rfq.getContactPhone());
            address.setStreet(rfq.getDeliveryAddress());
            address.setWard("");
            address.setDistrict("");
            address.setCity("");
            address.setDefault(false);
            
            int addressID = addressDAO.addAddress(address);
            if (addressID > 0) {
                System.out.println("[Quotation Callback] Created address ID: " + addressID);
                return addressID;
            }
        } catch (Exception e) {
            System.err.println("[Quotation Callback] Failed to create address: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
}
