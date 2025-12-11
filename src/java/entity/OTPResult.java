package entity;

public class OTPResult {

    private boolean success;
    private String message;
    private String errorCode;
    private int remainingAttempts;
    private long remainingSeconds;

    public static final String ERROR_INVALID = "INVALID_OTP";
    public static final String ERROR_EXPIRED = "EXPIRED_OTP";
    public static final String ERROR_MAX_ATTEMPTS = "MAX_ATTEMPTS";
    public static final String ERROR_COOLDOWN = "COOLDOWN";
    public static final String ERROR_EMAIL_NOT_FOUND = "EMAIL_NOT_FOUND";
    public static final String ERROR_EMAIL_SEND_FAILED = "EMAIL_SEND_FAILED";
    public static final String ERROR_ALREADY_VERIFIED = "ALREADY_VERIFIED";

    private OTPResult() {
    }

    public static OTPResult success(String message) {
        OTPResult result = new OTPResult();
        result.success = true;
        result.message = message;
        return result;
    }

    public static OTPResult error(String errorCode, String message) {
        OTPResult result = new OTPResult();
        result.success = false;
        result.errorCode = errorCode;
        result.message = message;
        return result;
    }

    public static OTPResult error(String errorCode, String message, int remainingAttempts) {
        OTPResult result = error(errorCode, message);
        result.remainingAttempts = remainingAttempts;
        return result;
    }

    public static OTPResult cooldown(long remainingSeconds) {
        OTPResult result = new OTPResult();
        result.success = false;
        result.errorCode = ERROR_COOLDOWN;
        result.message = "Vui lòng đợi " + remainingSeconds + " giây trước khi yêu cầu mã mới.";
        result.remainingSeconds = remainingSeconds;
        return result;
    }

    public boolean isSuccess() {
        return success;
    }

    public String getMessage() {
        return message;
    }

    public String getErrorCode() {
        return errorCode;
    }

    public int getRemainingAttempts() {
        return remainingAttempts;
    }

    public long getRemainingSeconds() {
        return remainingSeconds;
    }

    public void setRemainingAttempts(int remainingAttempts) {
        this.remainingAttempts = remainingAttempts;
    }

    public void setRemainingSeconds(long remainingSeconds) {
        this.remainingSeconds = remainingSeconds;
    }
}
