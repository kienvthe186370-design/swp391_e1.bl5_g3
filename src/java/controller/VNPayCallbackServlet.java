package controller;

import DAO.OrderDAO;
import DAO.PaymentDAO;
import DAO.ShippingDAO;
import entity.Order;
import entity.Payment;
import entity.Shipping;
import service.VNPayService;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.util.*;

@WebServlet(name = "VNPayCallbackServlet", urlPatterns = {"/vnpay-callback"})
public class VNPayCallbackServlet extends HttpServlet {
    
    private VNPayService vnPayService = new VNPayService();
    private OrderDAO orderDAO = new OrderDAO();
    private PaymentDAO paymentDAO = new PaymentDAO();
    private ShippingDAO shippingDAO = new ShippingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("\n========== VNPAY CALLBACK SERVLET ==========");
        System.out.println("[CALLBACK] Request URL: " + request.getRequestURL());
        System.out.println("[CALLBACK] Query String: " + request.getQueryString());
        
        // Get all parameters from VNPay
        Map<String, String> params = new HashMap<>();
        Enumeration<String> paramNames = request.getParameterNames();
        
        System.out.println("[CALLBACK] All Parameters:");
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            String paramValue = request.getParameter(paramName);
            System.out.println("  " + paramName + " = " + paramValue);
            if (paramValue != null && !paramValue.isEmpty()) {
                params.put(paramName, paramValue);
            }
        }
        
        // Extract important fields
             String vnpTxnRef = params.get("vnp_TxnRef");
        // vnp_TxnRef có format: orderCode_timestamp, cần lấy phần orderCode
        String orderCode = vnpTxnRef;
        if (vnpTxnRef != null && vnpTxnRef.contains("_")) {
            orderCode = vnpTxnRef.substring(0, vnpTxnRef.lastIndexOf("_"));
        }
        String responseCode = params.get("vnp_ResponseCode");
        String transactionNo = params.get("vnp_TransactionNo");
        String amountStr = params.get("vnp_Amount");

        
        System.out.println("[CALLBACK] Order Code: " + orderCode);
        System.out.println("[CALLBACK] Response Code: " + responseCode);
        System.out.println("[CALLBACK] Transaction No: " + transactionNo);
        
        // Validate callback signature
        boolean isValid = vnPayService.validateCallback(params);
        boolean isSuccess = vnPayService.isPaymentSuccess(responseCode);
        String message = vnPayService.getPaymentMessage(responseCode);
        
        System.out.println("[CALLBACK] Signature Valid: " + isValid);
        System.out.println("[CALLBACK] Payment Success: " + isSuccess);
        System.out.println("[CALLBACK] Message: " + message);
        
        // Get order from database
        Order order = orderDAO.getOrderByCode(orderCode);
        
        if (order == null) {
            System.err.println("[CALLBACK] ERROR: Order not found for code: " + orderCode);
            response.sendRedirect("checkout-result.jsp?status=failed&message=" + 
                java.net.URLEncoder.encode("Không tìm thấy đơn hàng", "UTF-8"));
            return;
        }
        
        // Get payment record
        Payment payment = paymentDAO.getPaymentByOrderId(order.getOrderID());
        
        if (isValid && isSuccess) {
            // ===== PAYMENT SUCCESS =====
            System.out.println("[CALLBACK] Processing successful payment...");
            
            // Update Payment record
            if (payment != null) {
                paymentDAO.updatePaymentStatus(payment.getPaymentID(), "Success", transactionNo);
                System.out.println("[CALLBACK] Updated Payment ID " + payment.getPaymentID() + " to Success");
            }
            
            // Update Order status
            orderDAO.updatePaymentStatus(order.getOrderID(), "Paid", transactionNo);
            orderDAO.updateOrderStatus(order.getOrderID(), "Confirmed");
            System.out.println("[CALLBACK] Updated Order ID " + order.getOrderID() + " to Paid/Confirmed");
            
            // Update Shipping status (optional - can trigger shipment creation here)
            Shipping shipping = shippingDAO.getShippingByOrderId(order.getOrderID());
            if (shipping != null) {
                System.out.println("[CALLBACK] Shipping record found: " + shipping.getShippingID());
            }
            
            System.out.println("[CALLBACK] Redirecting to success page");
            response.sendRedirect("checkout-result.jsp?orderCode=" + orderCode + 
                "&status=success&message=" + java.net.URLEncoder.encode(message, "UTF-8"));
            
        } else {
            // ===== PAYMENT FAILED =====
            System.out.println("[CALLBACK] Processing failed payment...");
            
            // Update Payment record
            if (payment != null) {
                paymentDAO.updatePaymentStatus(payment.getPaymentID(), "Failed", transactionNo);
                System.out.println("[CALLBACK] Updated Payment ID " + payment.getPaymentID() + " to Failed");
            }
            
            // Update Order status
            orderDAO.updatePaymentStatus(order.getOrderID(), "Unpaid", transactionNo);
            orderDAO.updateOrderStatus(order.getOrderID(), "Cancelled");
            System.out.println("[CALLBACK] Updated Order ID " + order.getOrderID() + " to Unpaid/Cancelled");
            
            System.out.println("[CALLBACK] Redirecting to failed page");
            response.sendRedirect("checkout-result.jsp?orderCode=" + orderCode + 
                "&status=failed&message=" + java.net.URLEncoder.encode(message, "UTF-8"));
        }
        
        System.out.println("============================================\n");
    }
}
