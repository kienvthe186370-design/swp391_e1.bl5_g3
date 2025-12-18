package utils;

import java.util.*;

public class OrderStatusValidator {
    
    // Map trạng thái có thể chuyển đến
    private static final Map<String, List<String>> TRANSITIONS = new HashMap<>();
    
    // Tên hiển thị của các status
    private static final Map<String, String> STATUS_NAMES = new LinkedHashMap<>();
    
    static {
        TRANSITIONS.put("Pending", Arrays.asList("Confirmed", "Cancelled"));
        TRANSITIONS.put("Confirmed", Arrays.asList("Processing", "Cancelled"));
        TRANSITIONS.put("Processing", Arrays.asList("Shipping", "Cancelled"));
        TRANSITIONS.put("Shipping", Arrays.asList("Delivered", "Cancelled"));
        TRANSITIONS.put("Delivered", Collections.emptyList());
        TRANSITIONS.put("Cancelled", Collections.emptyList());
        
        STATUS_NAMES.put("Pending", "Chờ xử lý");
        STATUS_NAMES.put("Confirmed", "Đã xác nhận");
        STATUS_NAMES.put("Processing", "Đang xử lý");
        STATUS_NAMES.put("Shipping", "Đang giao hàng");
        STATUS_NAMES.put("Delivered", "Đã giao");
        STATUS_NAMES.put("Cancelled", "Đã hủy");
    }
    
    /**
     * Kiểm tra có thể chuyển status không
     */
    public static boolean canTransition(String fromStatus, String toStatus, String role, boolean isCustomer) {
        // Customer chỉ có thể hủy đơn Pending
        if (isCustomer) {
            return "Pending".equals(fromStatus) && "Cancelled".equals(toStatus);
        }
        
        // Kiểm tra transition hợp lệ
        List<String> allowed = TRANSITIONS.get(fromStatus);
        if (allowed == null || !allowed.contains(toStatus)) {
            return false;
        }
        
        // Chỉ Shipper mới được cập nhật trạng thái "Đã giao"
        if ("Delivered".equals(toStatus) && !"Shipper".equalsIgnoreCase(role)) {
            return false;
        }
        
        // Seller không được hủy đơn (chỉ SellerManager trở lên mới được hủy)
        if ("Seller".equalsIgnoreCase(role) && "Cancelled".equals(toStatus)) {
            return false;
        }
        
        return RolePermission.canUpdateOrderStatus(role);
    }
    
    /**
     * Lấy danh sách status có thể chuyển đến
     */
    public static Map<String, String> getAvailableTransitions(String currentStatus, String role) {
        Map<String, String> result = new LinkedHashMap<>();
        List<String> allowed = TRANSITIONS.get(currentStatus);
        
        if (allowed == null) return result;
        
        for (String status : allowed) {
            if (canTransition(currentStatus, status, role, false)) {
                result.put(status, getStatusDisplayName(status));
            }
        }
        
        return result;
    }
    
    /**
     * Lấy tên hiển thị của status
     */
    public static String getStatusDisplayName(String status) {
        return STATUS_NAMES.getOrDefault(status, status);
    }
    
    /**
     * Lấy tất cả status names
     */
    public static Map<String, String> getAllStatusNames() {
        return new LinkedHashMap<>(STATUS_NAMES);
    }
    
    /**
     * Lấy CSS class cho badge status
     */
    public static String getStatusBadgeClass(String status) {
        if (status == null) return "secondary";
        switch (status) {
            case "Pending": return "secondary";
            case "Confirmed": return "info";
            case "Processing": return "primary";
            case "Shipping": return "warning";
            case "Delivered": return "success";
            case "Cancelled": return "danger";
            default: return "secondary";
        }
    }
}
