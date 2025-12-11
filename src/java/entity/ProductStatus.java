package entity;

/**
 * Enum representing product status based on variant availability and stock
 * Status is calculated dynamically, not stored in database
 */
public enum ProductStatus {
    DRAFT("draft", "Nháp", "Sắp ra mắt"),
    OUT_OF_STOCK("out_of_stock", "Hết hàng", "Hết hàng"),
    IN_STOCK("in_stock", "Còn hàng", null);
    
    private final String code;
    private final String adminLabel;
    private final String customerBadge;
    
    ProductStatus(String code, String adminLabel, String customerBadge) {
        this.code = code;
        this.adminLabel = adminLabel;
        this.customerBadge = customerBadge;
    }
    
    /**
     * Get status code for use in filters and data transfer
     * @return Status code (e.g., "draft", "out_of_stock", "in_stock")
     */
    public String getCode() {
        return code;
    }
    
    /**
     * Get label for display in admin interface
     * @return Admin label (e.g., "Nháp", "Hết hàng", "Còn hàng")
     */
    public String getAdminLabel() {
        return adminLabel;
    }
    
    /**
     * Get badge text for customer-facing pages
     * @return Badge text or null if no badge should be displayed
     */
    public String getCustomerBadge() {
        return customerBadge;
    }
    
    /**
     * Check if this status should display a badge on customer pages
     * @return true if badge should be shown, false otherwise
     */
    public boolean hasBadge() {
        return customerBadge != null;
    }
    
    /**
     * Get ProductStatus from code string
     * @param code Status code
     * @return ProductStatus enum or null if not found
     */
    public static ProductStatus fromCode(String code) {
        if (code == null) {
            return null;
        }
        for (ProductStatus status : values()) {
            if (status.code.equals(code)) {
                return status;
            }
        }
        return null;
    }
}
