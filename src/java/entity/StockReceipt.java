package entity;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Stock Receipt entity - Phiếu nhập kho
 * Mapping với bảng StockReceipts
 */
public class StockReceipt {
    
    private int receiptId;
    private int variantId;
    private int quantity;
    private BigDecimal unitCost;
    private Timestamp receiptDate;
    private Integer createdBy;
    
    // Default constructor
    public StockReceipt() {
    }
    
    // Full constructor
    public StockReceipt(int receiptId, int variantId, int quantity, 
                        BigDecimal unitCost, Timestamp receiptDate, Integer createdBy) {
        this.receiptId = receiptId;
        this.variantId = variantId;
        this.quantity = quantity;
        this.unitCost = unitCost;
        this.receiptDate = receiptDate;
        this.createdBy = createdBy;
    }
    
    // Constructor for insert (without receiptId)
    public StockReceipt(int variantId, int quantity, BigDecimal unitCost, Integer createdBy) {
        this.variantId = variantId;
        this.quantity = quantity;
        this.unitCost = unitCost;
        this.createdBy = createdBy;
    }
    
    // Getters & Setters
    public int getReceiptId() { return receiptId; }
    public void setReceiptId(int receiptId) { this.receiptId = receiptId; }
    
    public int getVariantId() { return variantId; }
    public void setVariantId(int variantId) { this.variantId = variantId; }
    
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    
    public BigDecimal getUnitCost() { return unitCost; }
    public void setUnitCost(BigDecimal unitCost) { this.unitCost = unitCost; }
    
    public Timestamp getReceiptDate() { return receiptDate; }
    public void setReceiptDate(Timestamp receiptDate) { this.receiptDate = receiptDate; }
    
    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }
    
    @Override
    public String toString() {
        return "StockReceipt{" + 
               "receiptId=" + receiptId + 
               ", variantId=" + variantId + 
               ", quantity=" + quantity + 
               ", unitCost=" + unitCost + 
               "}";
    }
}
