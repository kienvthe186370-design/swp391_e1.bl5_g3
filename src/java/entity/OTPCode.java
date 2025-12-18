package entity;

import java.sql.Timestamp;

public class OTPCode {

    private int otpId;
    private String email;
    private String otpCode;
    private String otpType;
    private Timestamp createdAt;
    private Timestamp expiresAt;
    private boolean isUsed;
    private int attempts;

    public static final String TYPE_VERIFY_EMAIL = "VERIFY_EMAIL";
    public static final String TYPE_RESET_PASSWORD = "RESET_PASSWORD";

    public static final int MAX_ATTEMPTS = 5;
    public static final int VERIFY_EMAIL_EXPIRY_SECONDS = 200; // 200 giây cho verify email
    public static final int RESET_PASSWORD_EXPIRY_SECONDS = 200; // 200 giây cho reset password
    public static final int COOLDOWN_SECONDS = 60;

    public OTPCode() {
    }

    public int getOtpId() {
        return otpId;
    }

    public void setOtpId(int otpId) {
        this.otpId = otpId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getOtpCode() {
        return otpCode;
    }

    public void setOtpCode(String otpCode) {
        this.otpCode = otpCode;
    }

    public String getOtpType() {
        return otpType;
    }

    public void setOtpType(String otpType) {
        this.otpType = otpType;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getExpiresAt() {
        return expiresAt;
    }

    public void setExpiresAt(Timestamp expiresAt) {
        this.expiresAt = expiresAt;
    }

    public boolean isUsed() {
        return isUsed;
    }

    public void setUsed(boolean used) {
        isUsed = used;
    }

    public int getAttempts() {
        return attempts;
    }

    public void setAttempts(int attempts) {
        this.attempts = attempts;
    }

    public boolean isExpired() {
        return expiresAt != null && expiresAt.before(new Timestamp(System.currentTimeMillis())); // kiểm tra hết hạn
    }

    public boolean hasExceededMaxAttempts() {
        return attempts >= MAX_ATTEMPTS;
    }

    public long getRemainingSeconds() {
        if (expiresAt == null) {
            return 0;
        }
        long remaining = (expiresAt.getTime() - System.currentTimeMillis()) / 1000; // đếm giây hết hạn
        return Math.max(0, remaining);
    }

    public int getRemainingAttempts() {
        return Math.max(0, MAX_ATTEMPTS - attempts);
    }
}
