package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * RFQPaymentCallbackServlet - DEPRECATED
 * 
 * Với luồng mới (tách RFQ và Quotation), thanh toán được thực hiện qua Quotation.
 * Sử dụng QuotationPaymentCallbackServlet thay thế.
 * 
 * File này giữ lại để backward compatibility.
 */
@WebServlet(name = "RFQPaymentCallbackServlet", urlPatterns = {"/rfq/payment-callback"})
public class RFQPaymentCallbackServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect to quotation list
        response.sendRedirect(request.getContextPath() + "/quotation/list?info=callback_deprecated");
    }
}
