/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package entity;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Entity class for CartItem
 * Represents an item in a shopping cart
 * @author xuand
 */
public class CartItem {
    // Database fields
    private int cartItemID;
    private int cartID;
    private int productID;
    private Integer variantID;          // Nullable - for products with variants
    private int quantity;
    private BigDecimal price;           // Price at time of adding to cart
    private Timestamp addedDate;
    
    // Additional fields (joined from other tables)
    private String productName;
    private String productImage;
    private String variantName;         // e.g., "Red - Size M"
    private String variantSKU;
    private int availableStock;
    private String categoryName;
    private String brandName;
    private boolean isProductActive;    // Product active status
    private boolean isVariantActive;    // Variant active status (if has variant)
    
    // Constructors
    public CartItem() {
    }
    
    public CartItem(int cartItemID, int cartID, int productID, Integer variantID, 
                    int quantity, BigDecimal price, Timestamp addedDate) {
        this.cartItemID = cartItemID;
        this.cartID = cartID;
        this.productID = productID;
        this.variantID = variantID;
        this.quantity = quantity;
        this.price = price;
        this.addedDate = addedDate;
    }
    
    // Getters and Setters
    public int getCartItemID() {
        return cartItemID;
    }
    
    public void setCartItemID(int cartItemID) {
        this.cartItemID = cartItemID;
    }
    
    public int getCartID() {
        return cartID;
    }
    
    public void setCartID(int cartID) {
        this.cartID = cartID;
    }
    
    public int getProductID() {
        return productID;
    }
    
    public void setProductID(int productID) {
        this.productID = productID;
    }
    
    public Integer getVariantID() {
        return variantID;
    }
    
    public void setVariantID(Integer variantID) {
        this.variantID = variantID;
    }
    
    public int getQuantity() {
        return quantity;
    }
    
    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
    
    public BigDecimal getPrice() {
        return price;
    }
    
    public void setPrice(BigDecimal price) {
        this.price = price;
    }
    
    public Timestamp getAddedDate() {
        return addedDate;
    }
    
    public void setAddedDate(Timestamp addedDate) {
        this.addedDate = addedDate;
    }
    
    public String getProductName() {
        return productName;
    }
    
    public void setProductName(String productName) {
        this.productName = productName;
    }
    
    public String getProductImage() {
        return productImage;
    }
    
    public void setProductImage(String productImage) {
        this.productImage = productImage;
    }
    
    public String getVariantName() {
        return variantName;
    }
    
    public void setVariantName(String variantName) {
        this.variantName = variantName;
    }
    
    public String getVariantSKU() {
        return variantSKU;
    }
    
    public void setVariantSKU(String variantSKU) {
        this.variantSKU = variantSKU;
    }
    
    public int getAvailableStock() {
        return availableStock;
    }
    
    public void setAvailableStock(int availableStock) {
        this.availableStock = availableStock;
    }
    
    public String getCategoryName() {
        return categoryName;
    }
    
    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }
    
    public String getBrandName() {
        return brandName;
    }
    
    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }
    
    public boolean isProductActive() {
        return isProductActive;
    }
    
    public void setProductActive(boolean productActive) {
        isProductActive = productActive;
    }
    
    public boolean isVariantActive() {
        return isVariantActive;
    }
    
    public void setVariantActive(boolean variantActive) {
        isVariantActive = variantActive;
    }
    
    // Helper Methods
    
    /**
     * Calculate total price for this item (price × quantity)
     * @return Total amount
     */
    public BigDecimal getTotal() {
        if (price == null) {
            return BigDecimal.ZERO;
        }
        return price.multiply(new BigDecimal(quantity));
    }
    
    /**
     * Check if item has variant
     * @return true if variantID is not null
     */
    public boolean hasVariant() {
        return variantID != null;
    }
    
    /**
     * Check if item is in stock
     * @return true if available stock > 0
     */
    public boolean isInStock() {
        return availableStock > 0;
    }
    
    /**
     * Check if product is available for purchase
     * Product must be active and (if has variant, variant must be active)
     * @return true if available
     */
    public boolean isAvailable() {
        if (!isProductActive) {
            return false;
        }
        if (hasVariant() && !isVariantActive) {
            return false;
        }
        return true;
    }
    
    /**
     * Check if requested quantity is available
     * @return true if quantity <= availableStock
     */
    public boolean isQuantityAvailable() {
        return quantity <= availableStock;
    }
    
    /**
     * Check if stock is low (less than 10)
     * @return true if stock is low
     */
    public boolean isLowStock() {
        return availableStock > 0 && availableStock < 10;
    }
    
    /**
     * Get display name (product name + variant if exists)
     * @return Display name
     */
    public String getDisplayName() {
        if (variantName != null && !variantName.trim().isEmpty()) {
            return productName + " - " + variantName;
        }
        return productName;
    }
    
    /**
     * Get formatted price string
     * @return Formatted price (e.g., "500,000₫")
     */
    public String getFormattedPrice() {
        if (price == null) {
            return "0₫";
        }
        return String.format("%,d₫", price.longValue());
    }
    
    /**
     * Get formatted total string
     * @return Formatted total (e.g., "1,000,000₫")
     */
    public String getFormattedTotal() {
        return String.format("%,d₫", getTotal().longValue());
    }
    
    @Override
    public String toString() {
        return "CartItem{" +
                "cartItemID=" + cartItemID +
                ", productID=" + productID +
                ", productName='" + productName + '\'' +
                ", variantID=" + variantID +
                ", variantName='" + variantName + '\'' +
                ", quantity=" + quantity +
                ", price=" + price +
                ", total=" + getTotal() +
                ", availableStock=" + availableStock +
                '}';
    }
}

