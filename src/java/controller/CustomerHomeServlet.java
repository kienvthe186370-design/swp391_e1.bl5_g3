package controller;

import entity.Customer;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * CustomerHomeServlet - Redirect customer về trang chủ chung
 * Customer sẽ dùng chung trang index.jsp với guest, chỉ khác ở header (hiển thị tên, giỏ hàng, etc.)
 */
@WebServlet(name = "CustomerHomeServlet", urlPatterns = {"/customer/home"})
public class CustomerHomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Redirect về trang chủ chung - header.jsp sẽ tự động hiển thị thông tin customer nếu đã đăng nhập
        response.sendRedirect(request.getContextPath() + "/Home");
    }
}
