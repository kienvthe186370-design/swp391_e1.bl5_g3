package entity;

import java.math.BigDecimal;

/**
 * RFQItem Entity - Chi tiết sản phẩm trong RFQ
 */
public class RFQItem {
    private int rfqItemID;
    private int rfqID;
    private int productID;
    private Integer variantID;
    
    // Product Snapshot
    private String productName;
    private String sku;
    private String productImage;
    
    // Quantity
    private int quantity;
    
    // Pricing (Seller fills)
    private BigDecimal costPrice;
    private BigDecimal profitMarginPercent;
    private BigDecimal unitPrice;
    private BigDecimal subtotal;
    
    // Min profit margin from stock management (ProfitMarginTarget)
    private BigDecimal minProfitMargin;
    
    // Special Requirements
    private String specialRequirements;
    private String notes;
    
    // Related objects
    private Product product;
    private ProductVariant variant;

    public RFQItem() {}

    // Getters and Setters
    public int getRfqItemID() { return rfqItemID; }
    public void setRfqItemID(int rfqItemID) { this.rfqItemID = rfqItemID; }

    public int getRfqID() { return rfqID; }
    public void setRfqID(int rfqID) { this.rfqID = rfqID; }

    public int getProductID() { return productID; }
    public void setProductID(int productID) { this.productID = productID; }

    public Integer getVariantID() { return variantID; }
    public void setVariantID(Integer variantID) { this.variantID = variantID; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }

    public String getProductImage() { return productImage; }
    public void setProductImage(String productImage) { this.productImage = productImage; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public BigDecimal getCostPrice() { return costPrice; }
    public void setCostPrice(BigDecimal costPrice) { this.costPrice = costPrice; }

    public BigDecimal getProfitMarginPercent() { return profitMarginPercent; }
    public void setProfitMarginPercent(BigDecimal profitMarginPercent) { this.profitMarginPercent = profitMarginPercent; }

    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }

    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }

    public String getSpecialRequirements() { return specialRequirements; }
    public void setSpecialRequirements(String specialRequirements) { this.specialRequirements = specialRequirements; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }

    public ProductVariant getVariant() { return variant; }
    public void setVariant(ProductVariant variant) { this.variant = variant; }
    
    public BigDecimal getMinProfitMargin() { return minProfitMargin; }
    public void setMinProfitMargin(BigDecimal minProfitMargin) { this.minProfitMargin = minProfitMargin; }
    
    /**
     * Calculate unit price from cost price and profit margin
     */
    public void calculateUnitPrice() {
        if (costPrice != null && profitMarginPercent != null) {
            BigDecimal margin = BigDecimal.ONE.add(profitMarginPercent.divide(BigDecimal.valueOf(100)));
            this.unitPrice = costPrice.multiply(margin);
            this.subtotal = unitPrice.multiply(BigDecimal.valueOf(quantity));
        }
    }
}
