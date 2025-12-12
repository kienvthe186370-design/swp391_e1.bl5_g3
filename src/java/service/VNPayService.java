package service;

import config.VNPayConfig;
import jakarta.servlet.http.HttpServletRequest;
import java.io.UnsupportedEncodingException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * VNPay Payment Service - THEO ĐÚNG CODE DEMO VNPAY CHÍNH THỨC
 * 
 * QUAN TRỌNG - Quy tắc hash của VNPay:
 * 1. Sort params theo alphabet (key RAW)
 * 2. Hash data: key=URLEncode(value) - KEY KHÔNG ENCODE
 * 3. Query string: URLEncode(key)=URLEncode(value) - CẢ HAI ENCODE
 * 4. Sử dụng HMAC-SHA512
 * 5. Charset: US-ASCII
 */
public class VNPayService {

    /**
     * Tạo URL thanh toán VNPay - THEO ĐÚNG CODE DEMO
     */
    public String createPaymentUrl(HttpServletRequest request, String orderCode, BigDecimal amount, String orderInfo, String returnUrl) {
        System.out.println("\n========== VNPAY CREATE PAYMENT URL ==========");
        System.out.println("[CREATE] Order Code: " + orderCode);
        System.out.println("[CREATE] Amount: " + amount + " VND");
        System.out.println("[CREATE] Return URL: " + returnUrl);
        
        String vnp_Version = "2.1.0";
        String vnp_Command = "pay";
        String vnp_TmnCode = VNPayConfig.VNP_TMN_CODE;
        String vnp_TxnRef = orderCode;
        String vnp_IpAddr = getIpAddress(request);
        long vnpAmount = amount.multiply(BigDecimal.valueOf(100)).longValue();
        
        // Timezone Vietnam (GMT+7)
        Calendar cld = Calendar.getInstance(TimeZone.getTimeZone("Etc/GMT+7"));
        SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
        String vnp_CreateDate = formatter.format(cld.getTime());
        cld.add(Calendar.MINUTE, 15);
        String vnp_ExpireDate = formatter.format(cld.getTime());

        // Build params map (RAW values)
        Map<String, String> vnp_Params = new HashMap<>();
        vnp_Params.put("vnp_Version", vnp_Version);
        vnp_Params.put("vnp_Command", vnp_Command);
        vnp_Params.put("vnp_TmnCode", vnp_TmnCode);
        vnp_Params.put("vnp_Amount", String.valueOf(vnpAmount));
        vnp_Params.put("vnp_CurrCode", "VND");
        vnp_Params.put("vnp_TxnRef", vnp_TxnRef);
        vnp_Params.put("vnp_OrderInfo", "Thanh toan don hang " + vnp_TxnRef);
        vnp_Params.put("vnp_OrderType", "other");
        vnp_Params.put("vnp_Locale", "vn");
        vnp_Params.put("vnp_ReturnUrl", returnUrl);
        vnp_Params.put("vnp_IpAddr", vnp_IpAddr);
        vnp_Params.put("vnp_CreateDate", vnp_CreateDate);
        vnp_Params.put("vnp_ExpireDate", vnp_ExpireDate);

        System.out.println("[CREATE] IP Address: " + vnp_IpAddr);
        System.out.println("[CREATE] Create Date: " + vnp_CreateDate);
        System.out.println("[CREATE] Expire Date: " + vnp_ExpireDate);
        System.out.println("[CREATE] All params (RAW):");
        vnp_Params.forEach((k, v) -> System.out.println("  " + k + " = " + v));

        // THEO ĐÚNG CODE DEMO VNPAY:
        // 1. Sort field names
        List<String> fieldNames = new ArrayList<>(vnp_Params.keySet());
        Collections.sort(fieldNames);
        
        System.out.println("[CREATE] Sorted keys: " + fieldNames);
        
        // 2. Build hash data và query string
        StringBuilder hashData = new StringBuilder();
        StringBuilder query = new StringBuilder();
        Iterator<String> itr = fieldNames.iterator();
        
        while (itr.hasNext()) {
            String fieldName = itr.next();
            String fieldValue = vnp_Params.get(fieldName);
            if (fieldValue != null && fieldValue.length() > 0) {
                try {
                    // Build hash data: key RAW, value ENCODED
                    hashData.append(fieldName);
                    hashData.append('=');
                    hashData.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                    
                    // Build query: cả key và value đều ENCODED
                    query.append(URLEncoder.encode(fieldName, StandardCharsets.US_ASCII.toString()));
                    query.append('=');
                    query.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                    
                    if (itr.hasNext()) {
                        query.append('&');
                        hashData.append('&');
                    }
                } catch (UnsupportedEncodingException e) {
                    e.printStackTrace();
                }
            }
        }
        
        String hashDataStr = hashData.toString();
        System.out.println("[CREATE] Hash Data String:");
        System.out.println(hashDataStr);
        System.out.println("[CREATE] Hash Data Length: " + hashDataStr.length());
        
        // 3. Tính HMAC-SHA512
        String vnp_SecureHash = VNPayConfig.hmacSHA512(VNPayConfig.VNP_HASH_SECRET, hashDataStr);
        System.out.println("[CREATE] Secure Hash: " + vnp_SecureHash);
        System.out.println("[CREATE] Hash Length: " + vnp_SecureHash.length() + " (expected: 128)");
        
        // 4. Build final URL
        String queryUrl = query.toString();
        queryUrl += "&vnp_SecureHash=" + vnp_SecureHash;
        String paymentUrl = VNPayConfig.VNP_URL + "?" + queryUrl;
        
        System.out.println("[CREATE] Final Payment URL:");
        System.out.println(paymentUrl);
        System.out.println("==============================================\n");
        
        return paymentUrl;
    }
    
    /**
     * Lấy IP address của client
     */
    private String getIpAddress(HttpServletRequest request) {
        String ipAddress;
        try {
            ipAddress = request.getHeader("X-FORWARDED-FOR");
            if (ipAddress == null || ipAddress.isEmpty()) {
                ipAddress = request.getRemoteAddr();
            }
            // Loại bỏ ::ffff: prefix (IPv6 mapped IPv4)
            if (ipAddress != null && ipAddress.contains("::ffff:")) {
                ipAddress = ipAddress.replace("::ffff:", "");
            }
            // Nếu có nhiều IP (proxy chain), lấy IP đầu tiên
            if (ipAddress != null && ipAddress.contains(",")) {
                ipAddress = ipAddress.split(",")[0].trim();
            }
        } catch (Exception e) {
            ipAddress = "127.0.0.1";
        }
        return ipAddress;
    }

    /**
     * Validate callback từ VNPay - THEO ĐÚNG CODE DEMO
     * 
     * Code demo VNPay (vnpay_return.jsp):
     * - Lấy tất cả params
     * - Remove vnp_SecureHash và vnp_SecureHashType
     * - Gọi Config.hashAllFields(fields) để tính hash
     * - So sánh với vnp_SecureHash nhận được
     */
    public boolean validateCallback(Map<String, String> params) {
        System.out.println("\n========== VNPAY VALIDATE CALLBACK ==========");
        System.out.println("[VALIDATE] Total params received: " + params.size());
        
        // Lấy hash từ VNPay
        String vnp_SecureHash = params.get("vnp_SecureHash");
        System.out.println("[VALIDATE] Received SecureHash: " + vnp_SecureHash);
        
        if (vnp_SecureHash == null || vnp_SecureHash.isEmpty()) {
            System.out.println("[VALIDATE] ERROR: vnp_SecureHash is NULL or empty");
            return false;
        }

        // THEO CODE DEMO: Copy params và loại bỏ hash fields
        Map<String, String> fields = new HashMap<>();
        for (Map.Entry<String, String> entry : params.entrySet()) {
            String fieldName = entry.getKey();
            String fieldValue = entry.getValue();
            if (fieldValue != null && fieldValue.length() > 0) {
                fields.put(fieldName, fieldValue);
            }
        }
        
        // Remove hash fields
        fields.remove("vnp_SecureHash");
        fields.remove("vnp_SecureHashType");
        
        System.out.println("[VALIDATE] Params for hash (after remove hash fields): " + fields.size());
        fields.forEach((k, v) -> System.out.println("  " + k + " = " + v));

        // Tính hash theo chuẩn VNPay
        String signValue = hashAllFields(fields);
        
        System.out.println("[VALIDATE] Calculated Hash: " + signValue);
        System.out.println("[VALIDATE] Received Hash:   " + vnp_SecureHash);
        
        // So sánh
        boolean isValid = signValue.equals(vnp_SecureHash);
        System.out.println("[VALIDATE] Hash Match: " + (isValid ? "YES ✓" : "NO ✗"));
        
        if (!isValid) {
            System.out.println("[VALIDATE] DEBUG - Kiểm tra:");
            System.out.println("  1. TmnCode: " + VNPayConfig.VNP_TMN_CODE);
            System.out.println("  2. Secret Key Length: " + VNPayConfig.VNP_HASH_SECRET.length());
            System.out.println("  3. Có thể hash đã được sử dụng (one-time use)");
        }
        
        System.out.println("=============================================\n");
        
        return isValid;
    }
    
    /**
     * Hash all fields - THEO ĐÚNG CODE DEMO VNPAY
     * 
     * QUAN TRỌNG: Trong callback, VNPay gửi params đã được URL encode
     * Code demo IPN: encode cả fieldName và fieldValue khi đọc từ request
     * Code demo Return: KHÔNG encode, dùng RAW values
     * 
     * Vì servlet container tự động decode params, ta cần encode lại
     */
    private String hashAllFields(Map<String, String> fields) {
        // Sort field names
        List<String> fieldNames = new ArrayList<>(fields.keySet());
        Collections.sort(fieldNames);
        
        System.out.println("[HASH] Sorted fields: " + fieldNames);
        
        StringBuilder hashData = new StringBuilder();
        Iterator<String> itr = fieldNames.iterator();
        
        while (itr.hasNext()) {
            String fieldName = itr.next();
            String fieldValue = fields.get(fieldName);
            if (fieldValue != null && fieldValue.length() > 0) {
                try {
                    // THEO CODE DEMO: key RAW, value ENCODED
                    hashData.append(fieldName);
                    hashData.append('=');
                    hashData.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                    if (itr.hasNext()) {
                        hashData.append('&');
                    }
                } catch (UnsupportedEncodingException e) {
                    e.printStackTrace();
                }
            }
        }
        
        String hashDataStr = hashData.toString();
        System.out.println("[HASH] Hash Data String:");
        System.out.println(hashDataStr);
        
        return VNPayConfig.hmacSHA512(VNPayConfig.VNP_HASH_SECRET, hashDataStr);
    }

    /**
     * Kiểm tra response code có phải thành công không
     */
    public boolean isPaymentSuccess(String responseCode) {
        return "00".equals(responseCode);
    }

    /**
     * Lấy message từ response code
     */
    public String getPaymentMessage(String responseCode) {
        switch (responseCode) {
            case "00": return "Giao dich thanh cong";
            case "07": return "Tru tien thanh cong nhung giao dich bi nghi ngo";
            case "09": return "Chua dang ky InternetBanking";
            case "10": return "Xac thuc khong dung qua 3 lan";
            case "11": return "Het han thanh toan";
            case "12": return "Tai khoan bi khoa";
            case "13": return "OTP khong dung";
            case "24": return "Huy giao dich";
            case "51": return "Khong du so du";
            case "65": return "Vuot han muc giao dich";
            case "75": return "Ngan hang bao tri";
            case "79": return "Sai mat khau qua nhieu lan";
            case "97": return "Chu ky khong hop le";
            case "99": return "Loi khong xac dinh";
            default: return "Loi: " + responseCode;
        }
    }
}
