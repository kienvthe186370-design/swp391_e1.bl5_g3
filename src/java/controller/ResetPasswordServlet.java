package controller;

import DAO.CustomerDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "ResetPasswordServlet", urlPatterns = {"/reset-password"})
public class ResetPasswordServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("resetEmail");
        
        String token = request.getParameter("token");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        
        if (email == null) {
            response.sendRedirect("forgot-password");
            return;
        }
        
        if (token == null || token.trim().isEmpty() ||
            newPassword == null || newPassword.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng điền đầy đủ thông tin");
            request.setAttribute("showTokenForm", true);
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }
        
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp");
            request.setAttribute("showTokenForm", true);
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }
        
        if (newPassword.length() < 6) {
            request.setAttribute("error", "Mật khẩu phải có ít nhất 6 ký tự");
            request.setAttribute("showTokenForm", true);
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }
        
        CustomerDAO dao = new CustomerDAO();
        
        if (!dao.verifyResetToken(email, token)) {
            request.setAttribute("error", "Mã xác nhận không đúng hoặc đã hết hạn");
            request.setAttribute("showTokenForm", true);
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }
        
        if (dao.resetPassword(email, newPassword)) {
            session.removeAttribute("resetEmail");
            request.setAttribute("success", "Đặt lại mật khẩu thành công! Vui lòng đăng nhập.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Có lỗi xảy ra. Vui lòng thử lại.");
            request.setAttribute("showTokenForm", true);
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
        }
    }
}
