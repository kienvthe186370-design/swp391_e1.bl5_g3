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
        int seconds;

        if (OTPCode.TYPE_VERIFY_EMAIL.equals(otpType)) {
            seconds = OTPCode.VERIFY_EMAIL_EXPIRY_SECONDS; // 200 giây
        } else if (OTPCode.TYPE_RESET_PASSWORD.equals(otpType)) {
            seconds = OTPCode.RESET_PASSWORD_EXPIRY_SECONDS; // 200 giây
        } else {
            seconds = 200; // Default 200 giây
        }

        return new Timestamp(currentTime + (seconds * 1000));
    }

    public static boolean isValidOTPFormat(String otp) {
        if (otp == null) {
            return false;
        }
        return otp.matches("\\d{6}"); //format otp
    }
}
