package entity;

/**
 * StockRequestItem Entity - Chi tiết sản phẩm trong yêu cầu nhập kho
 */
public class StockRequestItem {
    
    private int stockRequestItemID;
    private int stockRequestID;
    private int productID;
    private Integer variantID;
    private String productName;
    private String sku;
    private int requestedQuantity;          // Số lượng Seller yêu cầu (có thể chỉnh)
    private int originalRequestedQuantity;  // Số lượng gốc Seller yêu cầu (không đổi)
    private Integer approvedQuantity;       // Số lượng Admin duyệt
    private int currentStock;               // Tồn kho tại thời điểm tạo yêu cầu
    private int rfqQuantity;                // Số lượng trong RFQ
    
    // Related objects
    private String productImage;
    
    public StockRequestItem() {}

    // Getters and Setters
    public int getStockRequestItemID() { return stockRequestItemID; }
    public void setStockRequestItemID(int stockRequestItemID) { this.stockRequestItemID = stockRequestItemID; }

    public int getStockRequestID() { return stockRequestID; }
    public void setStockRequestID(int stockRequestID) { this.stockRequestID = stockRequestID; }

    public int getProductID() { return productID; }
    public void setProductID(int productID) { this.productID = productID; }

    public Integer getVariantID() { return variantID; }
    public void setVariantID(Integer variantID) { this.variantID = variantID; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }

    public int getRequestedQuantity() { return requestedQuantity; }
    public void setRequestedQuantity(int requestedQuantity) { this.requestedQuantity = requestedQuantity; }

    public int getCurrentStock() { return currentStock; }
    public void setCurrentStock(int currentStock) { this.currentStock = currentStock; }

    public int getRfqQuantity() { return rfqQuantity; }
    public void setRfqQuantity(int rfqQuantity) { this.rfqQuantity = rfqQuantity; }

    public String getProductImage() { return productImage; }
    public void setProductImage(String productImage) { this.productImage = productImage; }

    public int getOriginalRequestedQuantity() { return originalRequestedQuantity; }
    public void setOriginalRequestedQuantity(int originalRequestedQuantity) { this.originalRequestedQuantity = originalRequestedQuantity; }

    public Integer getApprovedQuantity() { return approvedQuantity; }
    public void setApprovedQuantity(Integer approvedQuantity) { this.approvedQuantity = approvedQuantity; }
    
    // Helper: Tính số lượng thiếu
    public int getShortageQuantity() {
        return Math.max(0, rfqQuantity - currentStock);
    }
    
    // Helper: Lấy số lượng thực tế được nhập (ưu tiên approvedQuantity nếu có)
    public int getActualImportQuantity() {
        return approvedQuantity != null ? approvedQuantity : requestedQuantity;
    }
}
