package controller;

import DAO.RFQDAO;
import config.VNPayConfig;
import entity.Customer;
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

/**
 * Servlet xử lý thanh toán RFQ qua VNPay
 * - BankTransfer: Thanh toán 100% qua VNPay
 * - Status chỉ đổi SAU KHI thanh toán thành công (trong RFQPaymentCallbackServlet)
 */
@WebServlet(name = "RFQPaymentServlet", urlPatterns = {"/rfq/payment"})
public class RFQPaymentServlet extends HttpServlet {
    
    private RFQDAO rfqDAO = new RFQDAO();
    private VNPayService vnPayService = new VNPayService();
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        try {
            int rfqID = Integer.parseInt(request.getParameter("rfqId"));
            RFQ rfq = rfqDAO.getRFQById(rfqID);
            
            // Validate RFQ
            if (rfq == null || rfq.getCustomerID() != customer.getCustomerID()) {
                response.sendRedirect(request.getContextPath() + "/rfq/list?error=invalid_rfq");
                return;
            }
            
            // Check status - must be Quoted
            if (!RFQ.STATUS_QUOTED.equals(rfq.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/rfq/detail?id=" + rfqID + "&error=invalid_status");
                return;
            }
            
            // Get total amount
            BigDecimal totalAmount = rfq.getTotalAmount();
            if (totalAmount == null || totalAmount.compareTo(BigDecimal.ZERO) <= 0) {
                response.sendRedirect(request.getContextPath() + "/rfq/detail?id=" + rfqID + "&error=invalid_amount");
                return;
            }
            
            // BankTransfer: Pay 100% via VNPay
            BigDecimal paymentAmount = totalAmount;
            String orderInfo = "Thanh toan don hang " + rfq.getRfqCode();
            
            // Store RFQ info in session for callback
            // Status will only change AFTER successful payment in RFQPaymentCallbackServlet
            session.setAttribute("pendingRFQID", rfqID);
            session.setAttribute("rfqPaymentMethod", "BankTransfer");
            session.setAttribute("rfqPaymentAmount", paymentAmount);
            
            // DO NOT update status here - status will be updated in callback after successful payment
            
            // Create VNPay payment URL
            String returnUrl = VNPayConfig.getReturnUrl(request).replace("/vnpay-callback", "/rfq/payment-callback");
            String paymentUrl = vnPayService.createPaymentUrl(
                request,
                rfq.getRfqCode(),
                paymentAmount,
                orderInfo,
                returnUrl
            );
            
            System.out.println("[RFQ Payment] RFQ: " + rfq.getRfqCode());
            System.out.println("[RFQ Payment] Payment Method: BankTransfer (VNPay)");
            System.out.println("[RFQ Payment] Total Amount: " + totalAmount);
            System.out.println("[RFQ Payment] Payment Amount: " + paymentAmount);
            System.out.println("[RFQ Payment] Status will change AFTER successful payment");
            System.out.println("[RFQ Payment] Redirecting to VNPay...");
            
            response.sendRedirect(paymentUrl);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/rfq/list?error=invalid_id");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/rfq/list?error=payment_error");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect GET requests to list
        response.sendRedirect(request.getContextPath() + "/rfq/list");
    }
}
