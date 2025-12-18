package controller;

import DAO.VoucherDAO;
import entity.Customer;
import entity.Voucher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.json.JSONObject;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;

@WebServlet(urlPatterns = {"/api/voucher"})
public class VoucherApiServlet extends HttpServlet {
    
    private VoucherDAO voucherDAO = new VoucherDAO();
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        String voucherCode = request.getParameter("voucherCode");
        String subtotalStr = request.getParameter("subtotal");
        
        JSONObject result = new JSONObject();
        
        if (voucherCode == null || voucherCode.trim().isEmpty()) {
            result.put("success", false);
            result.put("message", "Vui lòng nhập mã voucher");
            out.print(result.toString());
            return;
        }
        
        // Get customer from session
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        
        if (customer == null) {
            result.put("success", false);
            result.put("message", "Vui lòng đăng nhập để sử dụng voucher");
            out.print(result.toString());
            return;
        }
        
        int customerID = customer.getCustomerID();
        
        BigDecimal subtotal = BigDecimal.ZERO;
        try {
            if (subtotalStr != null && !subtotalStr.isEmpty()) {
                subtotal = new BigDecimal(subtotalStr);
            }
        } catch (NumberFormatException e) {
            // Use zero
        }
        
        try {
            // Validate voucher for this specific customer
            Voucher voucher = voucherDAO.validateVoucherForCustomer(voucherCode.trim(), customerID, subtotal);
            
            if (voucher == null) {
                // Check specific reason
                Voucher basicVoucher = voucherDAO.getVoucherByCode(voucherCode.trim());
                
                if (basicVoucher == null) {
                    result.put("success", false);
                    result.put("message", "Mã voucher không tồn tại");
                } else if (!basicVoucher.isValid()) {
                    result.put("success", false);
                    result.put("message", "Mã voucher đã hết hạn hoặc không còn hiệu lực");
                } else if (subtotal.compareTo(basicVoucher.getMinOrderValue()) < 0) {
                    result.put("success", false);
                    result.put("message", "Đơn hàng tối thiểu " + formatCurrency(basicVoucher.getMinOrderValue()) + "đ để sử dụng voucher này");
                } else if (basicVoucher.getMaxUsagePerCustomer() != null) {
                    int usageCount = voucherDAO.getCustomerVoucherUsageCount(basicVoucher.getVoucherID(), customerID);
                    if (usageCount >= basicVoucher.getMaxUsagePerCustomer()) {
                        result.put("success", false);
                        result.put("message", "Bạn đã sử dụng hết lượt áp dụng voucher này");
                    } else {
                        result.put("success", false);
                        result.put("message", "Không thể áp dụng voucher này");
                    }
                } else {
                    result.put("success", false);
                    result.put("message", "Không thể áp dụng voucher này");
                }
                
                out.print(result.toString());
                return;
            }
            
            // Calculate discount
            BigDecimal discount = voucher.calculateDiscount(subtotal);
            
            result.put("success", true);
            result.put("discount", discount);
            result.put("voucherCode", voucher.getVoucherCode());
            result.put("voucherName", voucher.getVoucherName());
            result.put("message", "Áp dụng voucher thành công! Giảm " + formatCurrency(discount) + "đ");
            
            out.print(result.toString());
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "Lỗi hệ thống: " + e.getMessage());
            out.print(result.toString());
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
    
    private String formatCurrency(BigDecimal amount) {
        if (amount == null) return "0";
        return String.format("%,d", amount.longValue());
    }
}
