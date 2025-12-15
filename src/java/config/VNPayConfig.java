package config;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;

public class VNPayConfig {
    // ========== THÔNG TIN TỪ EMAIL VNPAY - TÀI KHOẢN SANDBOX CỦA BẠN ==========
    // Terminal ID / Mã Website (vnp_TmnCode): 3I7NOYZN
    // Secret Key / Chuỗi bí mật tạo checksum (vnp_HashSecret): KSA167UQO0NE97QB6061MIKKMI7UPJ4K
    // ===========================================================================
    public static final String VNP_TMN_CODE = "3I7NOYZN";
    public static final String VNP_HASH_SECRET = "KSA167UQO0NE97QB6061MIKKMI7UPJ4K";

    public static final String VNP_URL = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    public static final String VNP_API_URL = "https://sandbox.vnpayment.vn/merchant_webapi/api/transaction";
    public static final String VNP_VERSION = "2.1.0";
    public static final String VNP_COMMAND = "pay";
    public static final String VNP_CURRENCY = "VND";
    public static final String VNP_LOCALE = "vn";
    public static final String VNP_ORDER_TYPE = "other";
    
    // Cloudflare Tunnel URL - Set this when using tunnel for VNPay callback
    // Set to null or empty to use auto-detect from request (RECOMMENDED)
    // Example: "https://tunnel.yourdomain.com" for production with tunnel
    public static final String TUNNEL_BASE_URL = ""; // Empty = auto-detect
    
    // Helper method to get return URL - Auto detects port from request
    public static String getReturnUrl(jakarta.servlet.http.HttpServletRequest request) {
        // If tunnel URL is configured, use it (for production with Cloudflare tunnel)
        if (TUNNEL_BASE_URL != null && !TUNNEL_BASE_URL.isEmpty()) {
            return TUNNEL_BASE_URL + request.getContextPath() + "/vnpay-callback";
        }
        
        // Auto-detect from request (works with any port: 8080, 9999, etc.)
        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int serverPort = request.getServerPort();
        String contextPath = request.getContextPath();
        
        StringBuilder url = new StringBuilder();
        url.append(scheme).append("://").append(serverName);
        
        // Only add port if not default (80 for http, 443 for https)
        if ((scheme.equals("http") && serverPort != 80) || 
            (scheme.equals("https") && serverPort != 443)) {
            url.append(":").append(serverPort);
        }
        
        url.append(contextPath).append("/vnpay-callback");
        
        System.out.println("[VNPayConfig] Auto-detected Return URL: " + url.toString());
        return url.toString();
    }

    public static String hmacSHA512(String key, String data) {
        try {
            System.out.println("[VNPAY-HMAC] Input Data: " + data);
            System.out.println("[VNPAY-HMAC] Secret Key Length: " + key.length());
            
            Mac hmac512 = Mac.getInstance("HmacSHA512");
            SecretKeySpec secretKey = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512");
            hmac512.init(secretKey);
            byte[] result = hmac512.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : result) {
                sb.append(String.format("%02x", b));
            }
            String hash = sb.toString();
            System.out.println("[VNPAY-HMAC] Output Hash: " + hash);
            return hash;
        } catch (Exception e) {
            System.err.println("[VNPAY-HMAC] ERROR: " + e.getMessage());
            e.printStackTrace();
            return "";
        }
    }

    /**
     * Hash all fields according to VNPAY standard - THEO ĐÚNG CODE DEMO
     * 
     * QUAN TRỌNG: 
     * - Hash data: key=URLEncode(value) - KEY KHÔNG ENCODE, VALUE ENCODE
     * - Sort theo alphabet
     * - Charset: US-ASCII
     */
    public static String hashAllFields(Map<String, String> fields) {
        System.out.println("\n========== VNPAY HASH ALL FIELDS ==========");
        System.out.println("[VNPAY-HASH] Total fields: " + fields.size());
        
        List<String> fieldNames = new ArrayList<>(fields.keySet());
        Collections.sort(fieldNames);
        
        System.out.println("[VNPAY-HASH] Sorted field names: " + fieldNames);
        
        StringBuilder hashData = new StringBuilder();
        Iterator<String> itr = fieldNames.iterator();
        while (itr.hasNext()) {
            String fieldName = itr.next();
            String fieldValue = fields.get(fieldName);
            if (fieldValue != null && !fieldValue.isEmpty()) {
                try {
                    // THEO CODE DEMO: key RAW, value URL ENCODED
                    hashData.append(fieldName);
                    hashData.append("=");
                    hashData.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                    System.out.println("[VNPAY-HASH] " + fieldName + " = " + URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                    if (itr.hasNext()) {
                        hashData.append("&");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        String hashString = hashData.toString();
        System.out.println("[VNPAY-HASH] Final Hash String: " + hashString);
        System.out.println("[VNPAY-HASH] Hash String Length: " + hashString.length());
        
        String hash = hmacSHA512(VNP_HASH_SECRET, hashString);
        System.out.println("[VNPAY-HASH] Final Hash: " + hash);
        System.out.println("==========================================\n");
        return hash;
    }

    public static String getRandomNumber(int len) {
        Random rnd = new Random();
        String chars = "0123456789";
        StringBuilder sb = new StringBuilder(len);
        for (int i = 0; i < len; i++) {
            sb.append(chars.charAt(rnd.nextInt(chars.length())));
        }
        return sb.toString();
    }

    public static String getIpAddress(jakarta.servlet.http.HttpServletRequest request) {
        String ipAddress = request.getHeader("X-FORWARDED-FOR");
        if (ipAddress == null || ipAddress.isEmpty()) {
            ipAddress = request.getRemoteAddr();
        }
        return ipAddress;
    }
}
