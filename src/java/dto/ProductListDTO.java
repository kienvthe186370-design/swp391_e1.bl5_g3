package dto;

import entity.Product;
import java.math.BigDecimal;

/**
 * DTO cho việc hiển thị Product trong list
 * Chứa thông tin tổng hợp từ nhiều bảng
 */
public class ProductListDTO {
    private Product product;
    private String mainImageUrl;      // Ảnh đại diện (main)
    private String categoryName;      // Tên danh mục
    private String brandName;         // Tên thương hiệu
    private int variantCount;         // Số lượng biến thể
    private BigDecimal minPrice;      // Giá thấp nhất
    private BigDecimal maxPrice;      // Giá cao nhất
    private int totalStock;           // Tổng tồn kho
    private int reservedStock;        // Tổng stock đang giữ
    
    // Constructor mặc định
    public ProductListDTO() {
    }
    
    // Constructor đầy đủ
    public ProductListDTO(Product product, String mainImageUrl, String categoryName, 
                          String brandName, int variantCount, BigDecimal minPrice, 
                          BigDecimal maxPrice, int totalStock, int reservedStock) {
        this.product = product;
        this.mainImageUrl = mainImageUrl;
        this.categoryName = categoryName;
        this.brandName = brandName;
        this.variantCount = variantCount;
        this.minPrice = minPrice;
        this.maxPrice = maxPrice;
        this.totalStock = totalStock;
        this.reservedStock = reservedStock;
    }
    
    // Getters and Setters
    public Product getProduct() {
        return product;
    }
    
    public void setProduct(Product product) {
        this.product = product;
    }
    
    public String getMainImageUrl() {
        return mainImageUrl;
    }
    
    public void setMainImageUrl(String mainImageUrl) {
        this.mainImageUrl = mainImageUrl;
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
    
    public int getVariantCount() {
        return variantCount;
    }
    
    public void setVariantCount(int variantCount) {
        this.variantCount = variantCount;
    }
    
    public BigDecimal getMinPrice() {
        return minPrice;
    }
    
    public void setMinPrice(BigDecimal minPrice) {
        this.minPrice = minPrice;
    }
    
    public BigDecimal getMaxPrice() {
        return maxPrice;
    }
    
    public void setMaxPrice(BigDecimal maxPrice) {
        this.maxPrice = maxPrice;
    }
    
    public int getTotalStock() {
        return totalStock;
    }
    
    public void setTotalStock(int totalStock) {
        this.totalStock = totalStock;
    }
    
    public int getReservedStock() {
        return reservedStock;
    }
    
    public void setReservedStock(int reservedStock) {
        this.reservedStock = reservedStock;
    }
    
    // Helper methods
    public int getAvailableStock() {
        return totalStock - reservedStock;
    }
    
    public String getPriceRangeFormatted() {
        if (minPrice == null || maxPrice == null) {
            return "0đ";
        }
        if (minPrice.equals(maxPrice)) {
            return formatPrice(minPrice);
        }
        return formatPrice(minPrice) + " - " + formatPrice(maxPrice);
    }
    
    private String formatPrice(BigDecimal price) {
        return String.format("%,.0fđ", price);
    }
    
    public String getStockStatus() {
        int available = getAvailableStock();
        if (available <= 0) {
            return "out_of_stock";
        } else if (available <= 10) {
            return "low_stock";
        } else {
            return "in_stock";
        }
    }
    
    public String getStockStatusLabel() {
        String status = getStockStatus();
        switch (status) {
            case "out_of_stock":
                return "Hết hàng";
            case "low_stock":
                return "Sắp hết";
            case "in_stock":
                return "Còn hàng";
            default:
                return "";
        }
    }
    
    @Override
    public String toString() {
        return "ProductListDTO{" +
                "productID=" + (product != null ? product.getProductID() : "null") +
                ", productName='" + (product != null ? product.getProductName() : "null") + '\'' +
                ", categoryName='" + categoryName + '\'' +
                ", brandName='" + brandName + '\'' +
                ", variantCount=" + variantCount +
                ", priceRange=" + getPriceRangeFormatted() +
                ", totalStock=" + totalStock +
                '}';
    }
}