package entity;

import java.sql.Timestamp;

/**
 * Entity cho bảng ShippingTracking - lưu lịch sử trạng thái vận chuyển
 */
public class ShippingTracking {
    
    private int trackingID;
    private int shippingID;
    private String statusCode;          // picking, picked, delivering, delivered, etc.
    private String statusDescription;   // Mô tả tiếng Việt
    private String location;            // Vị trí (tùy chọn)
    private String notes;               // Ghi chú của shipper
    private Integer updatedBy;          // ShipperID
    private Timestamp createdAt;
    
    // Related objects
    private Employee shipper;
    
    // Status code constants
    public static final String STATUS_PICKING = "picking";
    public static final String STATUS_PICKED = "picked";
    public static final String STATUS_DELIVERING = "delivering";
    public static final String STATUS_DELIVERED = "delivered";
    public static final String STATUS_DELIVERY_FAILED = "delivery_failed";
    public static final String STATUS_RETURNING = "returning";
    public static final String STATUS_RETURNED = "returned";
    
    public ShippingTracking() {}
    
    // Getters and Setters
    public int getTrackingID() { return trackingID; }
    public void setTrackingID(int trackingID) { this.trackingID = trackingID; }
    
    public int getShippingID() { return shippingID; }
    public void setShippingID(int shippingID) { this.shippingID = shippingID; }
    
    public String getStatusCode() { return statusCode; }
    public void setStatusCode(String statusCode) { this.statusCode = statusCode; }
    
    public String getStatusDescription() { return statusDescription; }
    public void setStatusDescription(String statusDescription) { this.statusDescription = statusDescription; }
    
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    
    public Integer getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(Integer updatedBy) { this.updatedBy = updatedBy; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    public Employee getShipper() { return shipper; }
    public void setShipper(Employee shipper) { this.shipper = shipper; }
    
    /**
     * Lấy tên tiếng Việt của status code
     */
    public static String getVietnameseName(String statusCode) {
        if (statusCode == null) return "Không xác định";
        switch (statusCode.toLowerCase()) {
            case STATUS_PICKING: return "Đang lấy hàng";
            case STATUS_PICKED: return "Đã lấy hàng";
            case STATUS_DELIVERING: return "Đang giao hàng";
            case STATUS_DELIVERED: return "Giao thành công";
            case STATUS_DELIVERY_FAILED: return "Giao thất bại";
            case STATUS_RETURNING: return "Đang hoàn hàng";
            case STATUS_RETURNED: return "Đã hoàn hàng";
            default: return statusCode;
        }
    }
    
    /**
     * Kiểm tra status có hợp lệ không
     */
    public static boolean isValidStatus(String statusCode) {
        if (statusCode == null) return false;
        switch (statusCode.toLowerCase()) {
            case STATUS_PICKING:
            case STATUS_PICKED:
            case STATUS_DELIVERING:
            case STATUS_DELIVERED:
            case STATUS_DELIVERY_FAILED:
            case STATUS_RETURNING:
            case STATUS_RETURNED:
                return true;
            default:
                return false;
        }
    }
    
    /**
     * Lấy danh sách status tiếp theo hợp lệ
     */
    public static String[] getNextValidStatuses(String currentStatus) {
        if (currentStatus == null) return new String[]{STATUS_PICKING};
        switch (currentStatus.toLowerCase()) {
            case STATUS_PICKING:
                return new String[]{STATUS_PICKED};
            case STATUS_PICKED:
                return new String[]{STATUS_DELIVERING};
            case STATUS_DELIVERING:
                return new String[]{STATUS_DELIVERED, STATUS_DELIVERY_FAILED};
            case STATUS_DELIVERY_FAILED:
                return new String[]{STATUS_DELIVERING, STATUS_RETURNING};
            case STATUS_RETURNING:
                return new String[]{STATUS_RETURNED};
            case STATUS_DELIVERED:
            case STATUS_RETURNED:
                return new String[]{}; // Final states
            default:
                return new String[]{};
        }
    }
}
