package controller;

import DAO.OTPDAO;
import DAO.CustomerDAO;
import entity.OTPCode;
import entity.OTPResult;
import utils.OTPUtil;
import utils.EmailUtil;
import java.sql.Timestamp;

public class OTPService {

    private OTPDAO otpDAO;
    private CustomerDAO customerDAO;

    public OTPService() {
        this.otpDAO = new OTPDAO();
        this.customerDAO = new CustomerDAO();
    }

    public OTPResult createAndSendOTP(String email, String otpType) {
        if (isInCooldown(email, otpType)) {
            long remaining = getCooldownRemaining(email, otpType);
            return OTPResult.cooldown(remaining);
        }
        // Vô hiệu hóa OTP cũ
        otpDAO.invalidateOldOTPs(email, otpType);

        // Tạo OTP mới
        String otpCode = OTPUtil.generateOTP();
        Timestamp expiry = OTPUtil.calculateExpiry(otpType);

        // Lưu vào database
        boolean saved = otpDAO.saveOTP(email, otpCode, otpType, expiry);
        if (!saved) {
            return OTPResult.error(OTPResult.ERROR_EMAIL_SEND_FAILED,
                    "Không thể tạo mã OTP. Vui lòng thử lại.");
        }

        // Gửi email
        if (OTPCode.TYPE_VERIFY_EMAIL.equals(otpType)) {
            EmailUtil.sendVerificationOTP(email, otpCode);
        } else {
            EmailUtil.sendPasswordResetOTP(email, otpCode);
        }

        // Log OTP để debug
        System.out.println("=== OTP CREATED ===");
        System.out.println("Email: " + email);
        System.out.println("OTP: " + otpCode);
        System.out.println("Type: " + otpType);
        System.out.println("Expires: " + expiry);
        System.out.println("==================");

        return OTPResult.success("Mã OTP đã được gửi đến email của bạn.");
    }

    public OTPResult verifyOTP(String email, String inputOTP, String otpType) {
        if (inputOTP == null || inputOTP.trim().isEmpty()) {
            return OTPResult.error(OTPResult.ERROR_INVALID, "Vui lòng nhập mã OTP.");
        }

        OTPCode otp = otpDAO.getOTP(email, otpType);

        if (otp == null) {
            return OTPResult.error(OTPResult.ERROR_INVALID, "Không tìm thấy mã OTP. Vui lòng yêu cầu mã mới.");
        }

        if (otp.isExpired()) {
            return OTPResult.error(OTPResult.ERROR_EXPIRED, "Mã OTP đã hết hạn. Vui lòng yêu cầu mã mới.");
        }

        if (otp.hasExceededMaxAttempts()) {
            return OTPResult.error(OTPResult.ERROR_MAX_ATTEMPTS, "Bạn đã nhập sai quá nhiều lần. Vui lòng yêu cầu mã mới.");
        }

        if (!otp.getOtpCode().equals(inputOTP.trim())) {
            otpDAO.incrementAttempts(otp.getOtpId());
            int remaining = otp.getRemainingAttempts() - 1;

            if (remaining <= 0) {
                return OTPResult.error(OTPResult.ERROR_MAX_ATTEMPTS, "Bạn đã nhập sai quá nhiều lần. Vui lòng yêu cầu mã mới.", 0);
            }

            return OTPResult.error(OTPResult.ERROR_INVALID, "Mã OTP không chính xác. Còn " + remaining + " lần thử.", remaining);
        }

        otpDAO.markAsUsed(otp.getOtpId());
        return OTPResult.success("Xác thực thành công!");
    }

    public OTPResult resendOTP(String email, String otpType) {
        return createAndSendOTP(email, otpType);
    }

    public boolean isInCooldown(String email, String otpType) {
        Timestamp lastOTP = otpDAO.getLastOTPTime(email, otpType);
        if (lastOTP == null) {
            return false;
        }
        long elapsed = System.currentTimeMillis() - lastOTP.getTime();
        return elapsed < (OTPCode.COOLDOWN_SECONDS * 1000);
    }

    public long getCooldownRemaining(String email, String otpType) {
        Timestamp lastOTP = otpDAO.getLastOTPTime(email, otpType);
        if (lastOTP == null) {
            return 0;
        }
        long elapsed = System.currentTimeMillis() - lastOTP.getTime();
        long remaining = (OTPCode.COOLDOWN_SECONDS * 1000) - elapsed;
        return Math.max(0, remaining / 1000);
    }

    public OTPCode getCurrentOTP(String email, String otpType) {
        return otpDAO.getOTP(email, otpType);
    }
}
