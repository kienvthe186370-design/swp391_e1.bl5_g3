/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package entity;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 *
 * @author ASUS
 */


public class Product {
    private int productID;
    private String productName;
    private int categoryID;
    private Integer brandID; // nullable
    private String description;
    private String specifications;
    private boolean isActive;
    private Integer createdBy;
    private Timestamp createdDate;
    private Timestamp updatedDate;
    
    // Constructor mặc định
    public Product() {
    }
    
    // Constructor đầy đủ
    public Product(int productID, String productName, int categoryID, Integer brandID, 
                   String description, String specifications, boolean isActive, 
                   Integer createdBy, Timestamp createdDate, Timestamp updatedDate) {
        this.productID = productID;
        this.productName = productName;
        this.categoryID = categoryID;
        this.brandID = brandID;
        this.description = description;
        this.specifications = specifications;
        this.isActive = isActive;
        this.createdBy = createdBy;
        this.createdDate = createdDate;
        this.updatedDate = updatedDate;
    }
    
    // Getters and Setters
    public int getProductID() {
        return productID;
    }
    
    public void setProductID(int productID) {
        this.productID = productID;
    }
    
    public String getProductName() {
        return productName;
    }
    
    public void setProductName(String productName) {
        this.productName = productName;
    }
    
    public int getCategoryID() {
        return categoryID;
    }
    
    public void setCategoryID(int categoryID) {
        this.categoryID = categoryID;
    }
    
    public Integer getBrandID() {
        return brandID;
    }
    
    public void setBrandID(Integer brandID) {
        this.brandID = brandID;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getSpecifications() {
        return specifications;
    }
    
    public void setSpecifications(String specifications) {
        this.specifications = specifications;
    }
    
    public boolean isActive() {
        return isActive;
    }
    
    public void setActive(boolean active) {
        isActive = active;
    }
    
    public Integer getCreatedBy() {
        return createdBy;
    }
    
    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
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
    
    @Override
    public String toString() {
        return "Product{" +
                "productID=" + productID +
                ", productName='" + productName + '\'' +
                ", categoryID=" + categoryID +
                ", brandID=" + brandID +
                ", isActive=" + isActive +
                ", createdDate=" + createdDate +
                '}';
    }
}
