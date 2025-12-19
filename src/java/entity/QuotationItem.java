package entity;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * QuotationItem Entity - Chi tiết báo giá cho từng sản phẩm
 */
public class QuotationItem {
    
    private int quotationItemID;
    private int quotationID;
    private int rfqItemID;
    
    // Pricing (Seller điền khi tạo báo giá)
    private BigDecimal costPrice;           // Giá vốn
    private BigDecimal profitMarginPercent; // % lợi nhuận
    private BigDecimal unitPrice;           // Đơn giá bán
    private BigDecimal subtotal;            // Thành tiền
    private String notes;                   // Ghi chú
    
    // Related objects (từ RFQItem)
    private RFQItem rfqItem;
    
    // Transient fields (không lưu DB, chỉ để hiển thị)
    private String productName;
    private String sku;
    private int quantity;
    private String productImage;
    private BigDecimal minProfitMargin; // Min profit margin từ stock management

    public QuotationItem() {}

    // ==================== GETTERS & SETTERS ====================
    
    public int getQuotationItemID() { return quotationItemID; }
    public void setQuotationItemID(int quotationItemID) { this.quotationItemID = quotationItemID; }

    public int getQuotationID() { return quotationID; }
    public void setQuotationID(int quotationID) { this.quotationID = quotationID; }

    public int getRfqItemID() { return rfqItemID; }
    public void setRfqItemID(int rfqItemID) { this.rfqItemID = rfqItemID; }

    public BigDecimal getCostPrice() { return costPrice; }
    public void setCostPrice(BigDecimal costPrice) { this.costPrice = costPrice; }

    public BigDecimal getProfitMarginPercent() { return profitMarginPercent; }
    public void setProfitMarginPercent(BigDecimal profitMarginPercent) { this.profitMarginPercent = profitMarginPercent; }

    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }

    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public RFQItem getRfqItem() { return rfqItem; }
    public void setRfqItem(RFQItem rfqItem) { 
        this.rfqItem = rfqItem;
        if (rfqItem != null) {
            this.productName = rfqItem.getProductName();
            this.sku = rfqItem.getSku();
            this.quantity = rfqItem.getQuantity();
            this.productImage = rfqItem.getProductImage();
        }
    }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public String getProductImage() { return productImage; }
    public void setProductImage(String productImage) { this.productImage = productImage; }

    public BigDecimal getMinProfitMargin() { return minProfitMargin; }
    public void setMinProfitMargin(BigDecimal minProfitMargin) { this.minProfitMargin = minProfitMargin; }

    // ==================== HELPER METHODS ====================
    
    /**
     * Tính đơn giá bán từ giá vốn và % lợi nhuận
     * UnitPrice = CostPrice * (1 + ProfitMarginPercent/100)
     */
    public void calculateUnitPrice() {
        if (costPrice != null && profitMarginPercent != null) {
            BigDecimal multiplier = BigDecimal.ONE.add(
                profitMarginPercent.divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP)
            );
            this.unitPrice = costPrice.multiply(multiplier).setScale(0, RoundingMode.HALF_UP);
            calculateSubtotal();
        }
    }
    
    /**
     * Tính thành tiền
     * Subtotal = UnitPrice * Quantity
     */
    public void calculateSubtotal() {
        if (unitPrice != null && quantity > 0) {
            this.subtotal = unitPrice.multiply(BigDecimal.valueOf(quantity));
        }
    }
    
    /**
     * Tính % lợi nhuận từ giá vốn và đơn giá bán
     * ProfitMarginPercent = ((UnitPrice - CostPrice) / CostPrice) * 100
     */
    public void calculateProfitMargin() {
        if (costPrice != null && unitPrice != null && costPrice.compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal profit = unitPrice.subtract(costPrice);
            this.profitMarginPercent = profit.divide(costPrice, 4, RoundingMode.HALF_UP)
                                             .multiply(BigDecimal.valueOf(100))
                                             .setScale(2, RoundingMode.HALF_UP);
        }
    }
    
    /**
     * Lấy lợi nhuận trên mỗi sản phẩm
     */
    public BigDecimal getProfitPerUnit() {
        if (unitPrice != null && costPrice != null) {
            return unitPrice.subtract(costPrice);
        }
        return BigDecimal.ZERO;
    }
    
    /**
     * Lấy tổng lợi nhuận
     */
    public BigDecimal getTotalProfit() {
        return getProfitPerUnit().multiply(BigDecimal.valueOf(quantity));
    }
}
