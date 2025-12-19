package controller;

import DAO.QuotationDAO;
import DAO.RFQDAONew;
import config.VNPayConfig;
import entity.Customer;
import entity.Quotation;
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
 * Servlet xử lý thanh toán Quotation qua VNPay
 * - Thanh toán 100% qua VNPay
 * - Status chỉ đổi SAU KHI thanh toán thành công (trong QuotationPaymentCallbackServlet)
 */
@WebServlet(name = "QuotationPaymentServlet", urlPatterns = {"/quotation/payment"})
public class QuotationPaymentServlet extends HttpServlet {
    
    private QuotationDAO quotationDAO = new QuotationDAO();
    private RFQDAONew rfqDAO = new RFQDAONew();
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
            int quotationID = Integer.parseInt(request.getParameter("quotationId"));
            Quotation quotation = quotationDAO.getQuotationById(quotationID);
            
            // Validate Quotation
            if (quotation == null) {
                response.sendRedirect(request.getContextPath() + "/quotation/list?error=invalid_quotation");
                return;
            }
            
            // Load RFQ to check customer ownership
            RFQ rfq = rfqDAO.getRFQById(quotation.getRfqID());
            if (rfq == null || rfq.getCustomerID() != customer.getCustomerID()) {
                response.sendRedirect(request.getContextPath() + "/quotation/list?error=access_denied");
                return;
            }

            // Check status - must be Accepted
            if (!Quotation.STATUS_ACCEPTED.equals(quotation.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/quotation/detail?id=" + quotationID + "&error=invalid_status");
                return;
            }
            
            // Check if expired
            if (quotation.isExpired()) {
                response.sendRedirect(request.getContextPath() + "/quotation/detail?id=" + quotationID + "&error=expired");
                return;
            }
            
            // Get total amount
            BigDecimal totalAmount = quotation.getTotalAmount();
            if (totalAmount == null || totalAmount.compareTo(BigDecimal.ZERO) <= 0) {
                response.sendRedirect(request.getContextPath() + "/quotation/detail?id=" + quotationID + "&error=invalid_amount");
                return;
            }
            
            // Pay 100% via VNPay
            BigDecimal paymentAmount = totalAmount;
            String orderInfo = "Thanh toan bao gia " + quotation.getQuotationCode();
            
            // Store Quotation info in session for callback
            session.setAttribute("pendingQuotationID", quotationID);
            session.setAttribute("quotationPaymentAmount", paymentAmount);
            
            // Create VNPay payment URL
            String returnUrl = VNPayConfig.getReturnUrl(request).replace("/vnpay-callback", "/quotation/payment-callback");
            String paymentUrl = vnPayService.createPaymentUrl(
                request,
                quotation.getQuotationCode(),
                paymentAmount,
                orderInfo,
                returnUrl
            );
            
            System.out.println("[Quotation Payment] Quotation: " + quotation.getQuotationCode());
            System.out.println("[Quotation Payment] RFQ: " + rfq.getRfqCode());
            System.out.println("[Quotation Payment] Total Amount: " + totalAmount);
            System.out.println("[Quotation Payment] Redirecting to VNPay...");
            
            response.sendRedirect(paymentUrl);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/quotation/list?error=invalid_id");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/quotation/list?error=payment_error");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/quotation/list");
    }
}
