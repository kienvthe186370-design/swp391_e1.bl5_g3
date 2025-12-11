package controller;

import DAO.CustomerDAO;
import entity.OTPCode;
import entity.OTPResult;
import utils.ValidationUtil;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "ResetPasswordServlet", urlPatterns = {"/reset-password"})
public class ResetPasswordServlet extends HttpServlet {

    private OTPService otpService = new OTPService();
    private CustomerDAO customerDAO = new CustomerDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pendingEmail") == null) {
            response.sendRedirect("forgot-password");
            return;
        }

        String email = (String) session.getAttribute("pendingEmail");
        Boolean otpVerified = (Boolean) session.getAttribute("otpVerified");

        // Lấy OTP hiện tại để hiển thị thời gian còn lại
        OTPCode currentOTP = otpService.getCurrentOTP(email, OTPCode.TYPE_RESET_PASSWORD);
        if (currentOTP != null) {
            request.setAttribute("remainingSeconds", currentOTP.getRemainingSeconds());
        }

        request.setAttribute("email", email);
        request.setAttribute("otpVerified", otpVerified != null && otpVerified);
        request.getRequestDispatcher("reset-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pendingEmail") == null) {
            response.sendRedirect("forgot-password");
            return;
        }

        String email = (String) session.getAttribute("pendingEmail");
        Boolean otpVerified = (Boolean) session.getAttribute("otpVerified");

        // Nếu chưa verify OTP, xử lý verify OTP trước
        if (otpVerified == null || !otpVerified) {
            String inputOTP = request.getParameter("otp");
            OTPResult result = otpService.verifyOTP(email, inputOTP, OTPCode.TYPE_RESET_PASSWORD);

            if (result.isSuccess()) {
                session.setAttribute("otpVerified", true);
                request.setAttribute("otpVerified", true);
                request.setAttribute("email", email);
                request.getRequestDispatcher("reset-password.jsp").forward(request, response);
            } else {
                request.setAttribute("error", result.getMessage());
                request.setAttribute("email", email);
                request.setAttribute("otpVerified", false);

                OTPCode currentOTP = otpService.getCurrentOTP(email, OTPCode.TYPE_RESET_PASSWORD);
                if (currentOTP != null) {
                    request.setAttribute("remainingSeconds", currentOTP.getRemainingSeconds());
                }

                request.getRequestDispatcher("reset-password.jsp").forward(request, response);
            }
            return;
        }

        // Đã verify OTP, xử lý đổi mật khẩu
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validate password
        String passwordError = ValidationUtil.getPasswordError(newPassword);
        if (passwordError != null) {
            request.setAttribute("error", passwordError);
            request.setAttribute("email", email);
            request.setAttribute("otpVerified", true);
            request.getRequestDispatcher("reset-password.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp");
            request.setAttribute("email", email);
            request.setAttribute("otpVerified", true);
            request.getRequestDispatcher("reset-password.jsp").forward(request, response);
            return;
        }

        // Đổi mật khẩu
        boolean success = customerDAO.resetPassword(email, newPassword);

        if (success) {
            // Xóa session tạm
            session.removeAttribute("pendingEmail");
            session.removeAttribute("otpType");
            session.removeAttribute("otpVerified");

            request.setAttribute("success", "Mật khẩu đã được đổi thành công! Vui lòng đăng nhập.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Không thể đổi mật khẩu. Vui lòng thử lại.");
            request.setAttribute("email", email);
            request.setAttribute("otpVerified", true);
            request.getRequestDispatcher("reset-password.jsp").forward(request, response);
        }
    }
}
