package controller;

import DAO.CustomerDAO;
import entity.OTPCode;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "ForgotPasswordServlet", urlPatterns = {"/forgot-password"})
public class ForgotPasswordServlet extends HttpServlet {
    private OTPService otpService = new OTPService();
    private CustomerDAO customerDAO = new CustomerDAO();

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

        email = email.trim();

        // Kiểm tra email có tồn tại hay không
        boolean emailExists = customerDAO.isEmailExists(email);
        if (emailExists) {
            // Tạo và gửi OTP
            otpService.createAndSendOTP(email, OTPCode.TYPE_RESET_PASSWORD);
            // Lưu email vào session
            HttpSession session = request.getSession();
            session.setAttribute("pendingEmail", email);
            session.setAttribute("otpType", OTPCode.TYPE_RESET_PASSWORD);
            // Chuyển thẳng đến trang reset password
            response.sendRedirect("reset-password");
        } else {
            // Vẫn hiển thị thông báo giống nhau để bảo mật dù mail có tồn tại hay là không.
            request.setAttribute("success", "Nếu email tồn tại trong hệ thống, bạn sẽ nhận được mã OTP.");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
        }
    }
}
