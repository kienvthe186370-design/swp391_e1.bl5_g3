package entity;

import java.sql.Timestamp;

/**
 * Wishlist entity - Danh sách yêu thích của khách hàng
 */
public class Wishlist {
    private int wishlistID;
    private int customerID;
    private int productID;
    private Timestamp addedDate;
    
    // Thông tin sản phẩm (để hiển thị)
    private String productName;
    private String productImage;
    private java.math.BigDecimal price;
    private java.math.BigDecimal finalPrice;
    private boolean hasPromotion;
    private int discountPercent;
    private int totalStock;
    private String brandName;

    public Wishlist() {}

    public Wishlist(int wishlistID, int customerID, int productID, Timestamp addedDate) {
        this.wishlistID = wishlistID;
        this.customerID = customerID;
        this.productID = productID;
        this.addedDate = addedDate;
    }

    // Getters & Setters
    public int getWishlistID() { return wishlistID; }
    public void setWishlistID(int wishlistID) { this.wishlistID = wishlistID; }

    public int getCustomerID() { return customerID; }
    public void setCustomerID(int customerID) { this.customerID = customerID; }

    public int getProductID() { return productID; }
    public void setProductID(int productID) { this.productID = productID; }

    public Timestamp getAddedDate() { return addedDate; }
    public void setAddedDate(Timestamp addedDate) { this.addedDate = addedDate; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getProductImage() { return productImage; }
    public void setProductImage(String productImage) { this.productImage = productImage; }

    public java.math.BigDecimal getPrice() { return price; }
    public void setPrice(java.math.BigDecimal price) { this.price = price; }

    public java.math.BigDecimal getFinalPrice() { return finalPrice; }
    public void setFinalPrice(java.math.BigDecimal finalPrice) { this.finalPrice = finalPrice; }

    public boolean isHasPromotion() { return hasPromotion; }
    public void setHasPromotion(boolean hasPromotion) { this.hasPromotion = hasPromotion; }

    public int getDiscountPercent() { return discountPercent; }
    public void setDiscountPercent(int discountPercent) { this.discountPercent = discountPercent; }

    public int getTotalStock() { return totalStock; }
    public void setTotalStock(int totalStock) { this.totalStock = totalStock; }

    public String getBrandName() { return brandName; }
    public void setBrandName(String brandName) { this.brandName = brandName; }
}
