package controller;

import DAO.RFQDAO;
import entity.RFQ;
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
 */
@WebServlet(name = "RFQPaymentCallbackServlet", urlPatterns = {"/rfq/payment-callback"})
public class RFQPaymentCallbackServlet extends HttpServlet {
    
    private VNPayService vnPayService = new VNPayService();
    private RFQDAO rfqDAO = new RFQDAO();
    
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
        
        if (pendingRFQID == null) {
            // Try to find RFQ by code
            RFQ rfq = rfqDAO.getRFQByCode(vnp_TxnRef);
            if (rfq != null) {
                pendingRFQID = rfq.getRfqID();
                paymentMethod = rfq.getPaymentMethod();
            }
        }
        
        if (pendingRFQID != null && isValid && isSuccess) {
            // Payment successful
            RFQ rfq = rfqDAO.getRFQById(pendingRFQID);
            
            if (rfq != null) {
                // Update RFQ status to Completed
                rfqDAO.completeRFQ(pendingRFQID, vnp_TransactionNo);
                
                // Set success attributes
                request.setAttribute("success", true);
                request.setAttribute("rfq", rfq);
                request.setAttribute("paymentMethod", paymentMethod);
                request.setAttribute("paymentAmount", paymentAmount);
                request.setAttribute("transactionNo", vnp_TransactionNo);
                request.setAttribute("message", "Thanh toán thành công!");
                
                if ("COD".equals(paymentMethod)) {
                    request.setAttribute("remainingAmount", rfq.getTotalAmount().subtract(paymentAmount));
                    request.setAttribute("codMessage", "Số tiền còn lại sẽ thanh toán khi nhận hàng.");
                }
            }
        } else {
            // Payment failed
            request.setAttribute("success", false);
            request.setAttribute("message", message != null ? message : "Thanh toán thất bại");
            request.setAttribute("errorCode", vnp_ResponseCode);
            
            // Revert RFQ status if needed
            if (pendingRFQID != null) {
                // Optionally revert status back to Quoted
                // rfqDAO.revertToQuoted(pendingRFQID);
            }
        }
        
        request.setAttribute("rfqCode", vnp_TxnRef);
        request.getRequestDispatcher("/customer/rfq-payment-result.jsp").forward(request, response);
    }
}
