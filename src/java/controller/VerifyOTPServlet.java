package controller;

import DAO.CustomerDAO;
import entity.OTPCode;
import entity.OTPResult;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "VerifyOTPServlet", urlPatterns = {"/verify-otp"})
public class VerifyOTPServlet extends HttpServlet {

    private OTPService otpService = new OTPService();
    private CustomerDAO customerDAO = new CustomerDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pendingEmail") == null) {
            response.sendRedirect("register");
            return;
        }

        String email = (String) session.getAttribute("pendingEmail");
        String otpType = (String) session.getAttribute("otpType");
        if (otpType == null) {
            otpType = OTPCode.TYPE_VERIFY_EMAIL;
        }

        // cái này để lấy OTP hiện tại để hiển thị thời gian còn lại
        OTPCode currentOTP = otpService.getCurrentOTP(email, otpType);
        if (currentOTP != null) {
            request.setAttribute("remainingSeconds", currentOTP.getRemainingSeconds());
        }

        request.setAttribute("email", email);
        request.setAttribute("otpType", otpType);
        request.getRequestDispatcher("verify-otp.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pendingEmail") == null) {
            response.sendRedirect("register");
            return;
        }

        String email = (String) session.getAttribute("pendingEmail");
        String otpType = (String) session.getAttribute("otpType");
        if (otpType == null) {
            otpType = OTPCode.TYPE_VERIFY_EMAIL;
        }

        String inputOTP = request.getParameter("otp");

        // Xác thực OTP
        OTPResult result = otpService.verifyOTP(email, inputOTP, otpType);

        if (result.isSuccess()) {
            if (OTPCode.TYPE_VERIFY_EMAIL.equals(otpType)) {
                // kích hoạt tài khoản
                customerDAO.verifyEmail(email);

                // Xóa session 
                session.removeAttribute("pendingEmail");
                session.removeAttribute("otpType");

                request.setAttribute("success", "Tài khoản đã được kích hoạt thành công! Vui lòng đăng nhập.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            } else {
                // cái này dùng reset password - chuyển đến bước nhập mật khẩu mới
                session.setAttribute("otpVerified", true);
                response.sendRedirect("reset-password");
            }
        } else {
            request.setAttribute("error", result.getMessage());
            request.setAttribute("remainingAttempts", result.getRemainingAttempts());

            OTPCode currentOTP = otpService.getCurrentOTP(email, otpType);
            if (currentOTP != null) {
                request.setAttribute("remainingSeconds", currentOTP.getRemainingSeconds());
            }

            request.setAttribute("email", email);
            request.setAttribute("otpType", otpType);
            request.getRequestDispatcher("verify-otp.jsp").forward(request, response);
        }
    }
}
