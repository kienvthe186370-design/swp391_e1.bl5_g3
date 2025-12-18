package controller;

import DAO.RFQDAO;
import DAO.OrderDAO;
import DAO.CustomerAddressDAO;
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
 * Servlet xử lý callback từ VNPay cho thanh toán RFQ
 * Sau khi thanh toán thành công, tự động tạo đơn hàng (Order) từ RFQ
 */
@WebServlet(name = "RFQPaymentCallbackServlet", urlPatterns = {"/rfq/payment-callback"})
public class RFQPaymentCallbackServlet extends HttpServlet {
    
    private VNPayService vnPayService = new VNPayService();
    private RFQDAO rfqDAO = new RFQDAO();
    private OrderDAO orderDAO = new OrderDAO();
    private CustomerAddressDAO addressDAO = new CustomerAddressDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("\n========== RFQ PAYMENT CALLBACK ==========");
        
        HttpSession session = request.getSession();
        
        // Get all parameters from VNPay
        Map<String, String> params = new HashMap<>();
        Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            String paramValue = request.getParameter(paramName);
            params.put(paramName, paramValue);
            System.out.println("[RFQ Callback] " + paramName + " = " + paramValue);
        }
        
        // Get response info
        String vnp_ResponseCode = params.get("vnp_ResponseCode");
        String vnp_TxnRef = params.get("vnp_TxnRef"); // RFQ Code
        String vnp_Amount = params.get("vnp_Amount");
        String vnp_TransactionNo = params.get("vnp_TransactionNo");
        
        // Validate callback
        boolean isValid = vnPayService.validateCallback(params);
        boolean isSuccess = vnPayService.isPaymentSuccess(vnp_ResponseCode);
        String message = vnPayService.getPaymentMessage(vnp_ResponseCode);
        
        System.out.println("[RFQ Callback] Valid: " + isValid);
        System.out.println("[RFQ Callback] Success: " + isSuccess);
        System.out.println("[RFQ Callback] Message: " + message);
        
        // Get pending RFQ from session
        Integer pendingRFQID = (Integer) session.getAttribute("pendingRFQID");
        String paymentMethod = (String) session.getAttribute("rfqPaymentMethod");
        BigDecimal paymentAmount = (BigDecimal) session.getAttribute("rfqPaymentAmount");
        
        // Clear session attributes
        session.removeAttribute("pendingRFQID");
        session.removeAttribute("rfqPaymentMethod");
        session.removeAttribute("rfqPaymentAmount");
        
        // Debug log for session data
        StringBuilder debugLog = new StringBuilder();
        debugLog.append("Session pendingRFQID: ").append(pendingRFQID).append("\n");
        debugLog.append("vnp_TxnRef: ").append(vnp_TxnRef).append("\n");
        
        if (pendingRFQID == null) {
            // Try to find RFQ by code - vnp_TxnRef may contain timestamp suffix
            String rfqCode = vnp_TxnRef;
            if (rfqCode != null && rfqCode.contains("_")) {
                rfqCode = rfqCode.substring(0, rfqCode.indexOf("_"));
            }
            debugLog.append("Extracted RFQ Code: ").append(rfqCode).append("\n");
            
            RFQ rfq = rfqDAO.getRFQByCode(rfqCode);
            if (rfq != null) {
                pendingRFQID = rfq.getRfqID();
                paymentMethod = rfq.getPaymentMethod();
                debugLog.append("Found RFQ ID: ").append(pendingRFQID).append("\n");
            } else {
                debugLog.append("RFQ not found by code!\n");
            }
        }
        
        debugLog.append("isValid: ").append(isValid).append("\n");
        debugLog.append("isSuccess: ").append(isSuccess).append("\n");
        debugLog.append("pendingRFQID after lookup: ").append(pendingRFQID).append("\n");
        
        if (pendingRFQID != null && isValid && isSuccess) {
            // Payment successful
            debugLog.append("=== PAYMENT SUCCESS - Processing ===\n");
            System.out.println("[RFQ Callback] Loading RFQ ID: " + pendingRFQID);
            RFQ rfq = rfqDAO.getRFQById(pendingRFQID);
            
            if (rfq != null) {
                System.out.println("[RFQ Callback] RFQ loaded: " + rfq.getRfqCode());
                System.out.println("[RFQ Callback] RFQ Status: " + rfq.getStatus());
                System.out.println("[RFQ Callback] RFQ PaymentMethod: " + rfq.getPaymentMethod());
                System.out.println("[RFQ Callback] RFQ Items: " + (rfq.getItems() != null ? rfq.getItems().size() : 0));
                System.out.println("[RFQ Callback] SubtotalAmount: " + rfq.getSubtotalAmount());
                System.out.println("[RFQ Callback] TotalAmount: " + rfq.getTotalAmount());
                
                // Debug: Log each item details
                if (rfq.getItems() != null) {
                    for (entity.RFQItem item : rfq.getItems()) {
                        System.out.println("[RFQ Callback] Item: " + item.getProductName() + 
                                          " | VariantID: " + item.getVariantID() + 
                                          " | Qty: " + item.getQuantity() + 
                                          " | UnitPrice: " + item.getUnitPrice() +
                                          " | CostPrice: " + item.getCostPrice() +
                                          " | Subtotal: " + item.getSubtotal());
                    }
                }
                
                // 1. Tạo địa chỉ giao hàng từ thông tin RFQ
                Integer addressID = createAddressFromRFQ(rfq);
                System.out.println("[RFQ Callback] Created AddressID: " + addressID);
                
                // 2. Tạo đơn hàng từ RFQ
                System.out.println("[RFQ Callback] Creating order from RFQ...");
                int orderID = orderDAO.createOrderFromRFQ(rfq, addressID, vnp_TransactionNo);
                System.out.println("[RFQ Callback] Order creation result: " + orderID);
                
                if (orderID > 0) {
                    System.out.println("[RFQ Callback] Created Order ID: " + orderID + " from RFQ: " + rfq.getRfqCode());
                    debugLog.append("Created Order ID: ").append(orderID).append("\n");
                    
                    // 3. Update RFQ status to Completed với Order ID và ghi lại số tiền thanh toán
                    BigDecimal actualPaymentAmount = paymentAmount != null ? paymentAmount : rfq.getTotalAmount();
                    boolean statusUpdated = rfqDAO.completeRFQ(pendingRFQID, orderID, actualPaymentAmount, vnp_TransactionNo);
                    debugLog.append("Status update result: ").append(statusUpdated).append("\n");
                    if (!statusUpdated) {
                        String error = rfqDAO.getLastCompleteError();
                        debugLog.append("Status update ERROR: ").append(error != null ? error : "Unknown").append("\n");
                    }
                    System.out.println("[RFQ Callback] Status update result: " + statusUpdated);
                    
                    // Set success attributes
                    request.setAttribute("success", true);
                    request.setAttribute("rfq", rfq);
                    request.setAttribute("orderID", orderID);
                    request.setAttribute("paymentMethod", paymentMethod);
                    request.setAttribute("paymentAmount", paymentAmount);
                    request.setAttribute("transactionNo", vnp_TransactionNo);
                    request.setAttribute("message", "Thanh toán thành công! Đơn hàng đã được tạo.");
                    request.setAttribute("debugLog", debugLog.toString());
                    
                    // Payment method is always BankTransfer (full payment via VNPay)
                } else {
                    // Order creation failed but payment succeeded
                    System.err.println("[RFQ Callback] Failed to create order from RFQ: " + rfq.getRfqCode());
                    debugLog.append("Order creation FAILED!\n");
                    
                    boolean statusUpdated = rfqDAO.completeRFQ(pendingRFQID, vnp_TransactionNo);
                    debugLog.append("Status update (no order) result: ").append(statusUpdated).append("\n");
                    
                    request.setAttribute("success", true);
                    request.setAttribute("rfq", rfq);
                    request.setAttribute("paymentMethod", paymentMethod);
                    request.setAttribute("paymentAmount", paymentAmount);
                    request.setAttribute("transactionNo", vnp_TransactionNo);
                    request.setAttribute("message", "Thanh toán thành công! Vui lòng liên hệ hỗ trợ để hoàn tất đơn hàng.");
                    request.setAttribute("debugLog", debugLog.toString());
                }
            } else {
                debugLog.append("RFQ object is NULL after loading!\n");
                request.setAttribute("success", false);
                request.setAttribute("message", "Không tìm thấy thông tin RFQ");
                request.setAttribute("debugLog", debugLog.toString());
            }
        } else {
            // Payment failed or invalid
            debugLog.append("=== PAYMENT FAILED or INVALID ===\n");
            debugLog.append("Reason: pendingRFQID=").append(pendingRFQID)
                    .append(", isValid=").append(isValid)
                    .append(", isSuccess=").append(isSuccess).append("\n");
            
            request.setAttribute("success", false);
            request.setAttribute("message", message != null ? message : "Thanh toán thất bại");
            request.setAttribute("errorCode", vnp_ResponseCode);
            request.setAttribute("debugLog", debugLog.toString());
        }
        
        request.setAttribute("rfqCode", vnp_TxnRef);
        request.getRequestDispatcher("/customer/rfq-payment-result.jsp").forward(request, response);
    }
    
    /**
     * Tạo địa chỉ giao hàng từ thông tin RFQ
     * @param rfq RFQ chứa thông tin giao hàng
     * @return AddressID nếu tạo thành công, null nếu thất bại
     */
    private Integer createAddressFromRFQ(RFQ rfq) {
        try {
            CustomerAddress address = new CustomerAddress();
            address.setCustomerID(rfq.getCustomerID());
            address.setRecipientName(rfq.getContactPerson());
            address.setPhone(rfq.getContactPhone());
            address.setStreet(rfq.getDeliveryAddress());
            
            // Parse city/district/ward from delivery address or use stored IDs
            // For now, use a simple approach - store full address in street
            address.setWard("");
            address.setDistrict("");
            address.setCity("");
            address.setDefault(false);
            
            int addressID = addressDAO.addAddress(address);
            if (addressID > 0) {
                System.out.println("[RFQ Callback] Created address ID: " + addressID + " for customer: " + rfq.getCustomerID());
                return addressID;
            }
        } catch (Exception e) {
            System.err.println("[RFQ Callback] Failed to create address: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
}
