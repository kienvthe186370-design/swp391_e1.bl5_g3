package entity;

/**
 * Product status enum - calculated from variant/stock data
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
    
    public String getCode() { return code; }
    public String getAdminLabel() { return adminLabel; }
    public String getCustomerBadge() { return customerBadge; }
    
    public boolean hasBadge() { return customerBadge != null; }
    
    public static ProductStatus fromCode(String code) {
        if(code == null) return null;
        for (ProductStatus status : values()) {
            if (status.code.equals(code)) return status;
        }
        return null;
    }
}
