package utils;

import entity.OTPCode;
import java.security.SecureRandom;
import java.sql.Timestamp;

public class OTPUtil {

    private static final SecureRandom random = new SecureRandom();

    public static String generateOTP() {
        int otp = random.nextInt(1000000); // gen ra từ 0 đến 999999
        return String.format("%06d", otp); // Chắc chắn có mỗi 6 số 
    }

    public static Timestamp calculateExpiry(String otpType) {
        long currentTime = System.currentTimeMillis();
        int minutes;

        if (OTPCode.TYPE_VERIFY_EMAIL.equals(otpType)) {
            minutes = OTPCode.VERIFY_EMAIL_EXPIRY_MINUTES; // 10 phút
        } else if (OTPCode.TYPE_RESET_PASSWORD.equals(otpType)) {
            minutes = OTPCode.RESET_PASSWORD_EXPIRY_MINUTES; // 5 phút
        } else {
            minutes = 5; // Default 5 phút
        }

        return new Timestamp(currentTime + (minutes * 60 * 1000));
    }

    public static boolean isValidOTPFormat(String otp) {
        if (otp == null) {
            return false;
        }
        return otp.matches("\\d{6}"); //format otp
    }
}
