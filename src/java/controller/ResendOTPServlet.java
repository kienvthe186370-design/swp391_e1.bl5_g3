package controller;

import entity.OTPCode;
import entity.OTPResult;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.json.JSONObject;

@WebServlet(name = "ResendOTPServlet", urlPatterns = {"/resend-otp"})
public class ResendOTPServlet extends HttpServlet {

    private OTPService otpService = new OTPService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        JSONObject jsonResponse = new JSONObject();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pendingEmail") == null) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Phiên làm việc đã hết hạn. Vui lòng thử lại.");
            sendJsonResponse(response, jsonResponse);
            return;
        }

        String email = (String) session.getAttribute("pendingEmail");
        String otpType = (String) session.getAttribute("otpType");
        if (otpType == null) {
            otpType = OTPCode.TYPE_VERIFY_EMAIL;
        }

        OTPResult result = otpService.resendOTP(email, otpType);

        jsonResponse.put("success", result.isSuccess());
        jsonResponse.put("message", result.getMessage());
        if (!result.isSuccess() && result.getRemainingSeconds() > 0) {
            jsonResponse.put("cooldownSeconds", result.getRemainingSeconds());
        }

        sendJsonResponse(response, jsonResponse);
    }

    private void sendJsonResponse(HttpServletResponse response, JSONObject json)
            throws IOException {
        PrintWriter out = response.getWriter();
        out.print(json.toString());
        out.flush();
    }
}
