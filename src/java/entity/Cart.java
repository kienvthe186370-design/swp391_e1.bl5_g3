/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package entity;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Entity class for Cart
 * Represents a shopping cart for a customer
 * @author xuand
 */
public class Cart {
    private int cartID;
    private int customerID;
    private Timestamp createdDate;
    private Timestamp updatedDate;
    private List<CartItem> items;
    
    // Constructors
    public Cart() {
        this.items = new ArrayList<>();
    }
    
    public Cart(int cartID, int customerID, Timestamp createdDate, Timestamp updatedDate) {
        this.cartID = cartID;
        this.customerID = customerID;
        this.createdDate = createdDate;
        this.updatedDate = updatedDate;
        this.items = new ArrayList<>();
    }
    
    // Getters and Setters
    public int getCartID() {
        return cartID;
    }
    
    public void setCartID(int cartID) {
        this.cartID = cartID;
    }
    
    public int getCustomerID() {
        return customerID;
    }
    
    public void setCustomerID(int customerID) {
        this.customerID = customerID;
    }
    
    public Timestamp getCreatedDate() {
        return createdDate;
    }
    
    public void setCreatedDate(Timestamp createdDate) {
        this.createdDate = createdDate;
    }
    
    public Timestamp getUpdatedDate() {
        return updatedDate;
    }
    
    public void setUpdatedDate(Timestamp updatedDate) {
        this.updatedDate = updatedDate;
    }
    
    public List<CartItem> getItems() {
        return items;
    }
    
    public void setItems(List<CartItem> items) {
        this.items = items;
    }
    
    // Helper Methods
    
    /**
     * Calculate subtotal (sum of all items)
     * @return Subtotal amount
     */
    public BigDecimal getSubtotal() {
        if (items == null || items.isEmpty()) {
            return BigDecimal.ZERO;
        }
        
        return items.stream()
                .map(CartItem::getTotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
    
    /**
     * Get total number of items in cart
     * @return Total quantity of all items
     */
    public int getTotalItems() {
        if (items == null || items.isEmpty()) {
            return 0;
        }
        
        return items.stream()
                .mapToInt(CartItem::getQuantity)
                .sum();
    }
    
    /**
     * Get total number of unique products
     * @return Number of different products
     */
    public int getUniqueProductCount() {
        if (items == null || items.isEmpty()) {
            return 0;
        }
        
        return items.size();
    }
    
    /**
     * Check if cart is empty
     * @return true if cart has no items
     */
    public boolean isEmpty() {
        return items == null || items.isEmpty();
    }
    
    /**
     * Add item to cart (for in-memory operations)
     * @param item CartItem to add
     */
    public void addItem(CartItem item) {
        if (items == null) {
            items = new ArrayList<>();
        }
        items.add(item);
    }
    
    /**
     * Remove item from cart (for in-memory operations)
     * @param cartItemID ID of item to remove
     * @return true if item was removed
     */
    public boolean removeItem(int cartItemID) {
        if (items == null) {
            return false;
        }
        
        return items.removeIf(item -> item.getCartItemID() == cartItemID);
    }
    
    /**
     * Find item by product and variant
     * @param productID Product ID
     * @param variantID Variant ID (can be null)
     * @return CartItem if found, null otherwise
     */
    public CartItem findItem(int productID, Integer variantID) {
        if (items == null) {
            return null;
        }
        
        return items.stream()
                .filter(item -> item.getProductID() == productID)
                .filter(item -> {
                    if (variantID == null) {
                        return item.getVariantID() == null;
                    } else {
                        return variantID.equals(item.getVariantID());
                    }
                })
                .findFirst()
                .orElse(null);
    }
    
    /**
     * Clear all items from cart
     */
    public void clear() {
        if (items != null) {
            items.clear();
        }
    }
    
    @Override
    public String toString() {
        return "Cart{" +
                "cartID=" + cartID +
                ", customerID=" + customerID +
                ", itemCount=" + getTotalItems() +
                ", subtotal=" + getSubtotal() +
                ", createdDate=" + createdDate +
                ", updatedDate=" + updatedDate +
                '}';
    }
}
