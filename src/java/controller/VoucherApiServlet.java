package controller;

import DAO.VoucherDAO;
import entity.Voucher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
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
        
        BigDecimal subtotal = BigDecimal.ZERO;
        try {
            if (subtotalStr != null && !subtotalStr.isEmpty()) {
                subtotal = new BigDecimal(subtotalStr);
            }
        } catch (NumberFormatException e) {
            // Use zero
        }
        
        try {
            Voucher voucher = voucherDAO.getVoucherByCode(voucherCode.trim());
            
            if (voucher == null) {
                result.put("success", false);
                result.put("message", "Mã voucher không tồn tại");
                out.print(result.toString());
                return;
            }
            
            // Check if voucher is valid
            if (!voucher.isValid()) {
                result.put("success", false);
                result.put("message", "Mã voucher đã hết hạn hoặc không còn hiệu lực");
                out.print(result.toString());
                return;
            }
            
            // Check minimum order value
            if (voucher.getMinOrderValue() != null && subtotal.compareTo(voucher.getMinOrderValue()) < 0) {
                result.put("success", false);
                result.put("message", "Đơn hàng tối thiểu " + formatCurrency(voucher.getMinOrderValue()) + "đ để sử dụng voucher này");
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
