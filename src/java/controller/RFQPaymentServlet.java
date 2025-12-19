package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * RFQPaymentServlet - DEPRECATED
 * 
 * Với luồng mới (tách RFQ và Quotation), thanh toán được thực hiện qua Quotation.
 * Sử dụng QuotationPaymentServlet thay thế.
 * 
 * File này giữ lại để backward compatibility, redirect sang quotation payment.
 */
@WebServlet(name = "RFQPaymentServlet", urlPatterns = {"/rfq/payment"})
public class RFQPaymentServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect to quotation list - thanh toán qua Quotation
        response.sendRedirect(request.getContextPath() + "/quotation/list?info=use_quotation_payment");
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/quotation/list");
    }
}
