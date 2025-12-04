package controller;

import DAO.CustomerDAO;
import utils.EmailUtil;
import utils.PasswordUtil;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "ForgotPasswordServlet", urlPatterns = {"/forgot-password"})
public class ForgotPasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập email");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }
        
        CustomerDAO dao = new CustomerDAO();
        
        if (!dao.isEmailExists(email)) {
            request.setAttribute("error", "Email không tồn tại trong hệ thống");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }
        
        String resetToken = PasswordUtil.generateToken();
        
        if (dao.savePasswordResetToken(email, resetToken)) {
            HttpSession session = request.getSession();
            session.setAttribute("resetEmail", email);
            session.setAttribute("resetToken", resetToken); // Lưu token vào session để hiển thị
            
            // Gửi email (hiện tại chỉ log ra console)
            EmailUtil.sendPasswordResetEmail(email, resetToken);
            
            request.setAttribute("success", "Mã xác nhận: " + resetToken + " (Kiểm tra console hoặc database)");
            request.setAttribute("showTokenForm", true);
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Có lỗi xảy ra. Vui lòng thử lại.");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
        }
    }
}
