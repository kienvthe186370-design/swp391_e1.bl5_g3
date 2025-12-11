package config;

/**
 * Cấu hình VNPay Sandbox
 * Đăng ký tại: https://sandbox.vnpayment.vn/merchantv2/
 */
public class VNPayConfig {
    
    // ===== SANDBOX CONFIG - Thay đổi khi deploy production =====
    public static final String VNP_PAY_URL = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    public static final String VNP_RETURN_URL = "http://localhost:9999/PickleballShop/vnpay-return";
    
    // Thông tin merchant - LẤY TỪ VNPay Sandbox Portal
    public static final String VNP_TMN_CODE = "JPM54ZEY"; 
    public static final String VNP_HASH_SECRET = "AZHEI6RHI813FBL5WQ3YZM2NQZ27KR4O"; 
    
    // API Version
    public static final String VNP_VERSION = "2.1.0";
    public static final String VNP_COMMAND = "pay";
    public static final String VNP_CURR_CODE = "VND";
    public static final String VNP_LOCALE = "vn";
    public static final String VNP_ORDER_TYPE = "other";
    
    // Response codes
    public static final String VNP_RESPONSE_CODE_SUCCESS = "00";
    public static final String VNP_TRANSACTION_STATUS_SUCCESS = "00";
}
