/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Entity for DiscountCampaigns (Chiến dịch giảm giá)
 */
public class DiscountCampaign {
    
    private int discountID;
    private String campaignName;
    private String discountType; 
    private BigDecimal discountValue;
    private BigDecimal maxDiscountAmount;
    private String appliedToType; 
    private Integer appliedToID; 
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private boolean isActive;
    private Integer createdBy;
    private LocalDateTime createdDate;
    private String createdByName;
    private String appliedToName; 
    
    public DiscountCampaign() {
    }

    public DiscountCampaign(int discountID, String campaignName, String discountType, BigDecimal discountValue, BigDecimal maxDiscountAmount, String appliedToType, Integer appliedToID, LocalDateTime startDate, LocalDateTime endDate, boolean isActive, Integer createdBy, LocalDateTime createdDate, String createdByName, String appliedToName) {
        this.discountID = discountID;
        this.campaignName = campaignName;
        this.discountType = discountType;
        this.discountValue = discountValue;
        this.maxDiscountAmount = maxDiscountAmount;
        this.appliedToType = appliedToType;
        this.appliedToID = appliedToID;
        this.startDate = startDate;
        this.endDate = endDate;
        this.isActive = isActive;
        this.createdBy = createdBy;
        this.createdDate = createdDate;
        this.createdByName = createdByName;
        this.appliedToName = appliedToName;
    }

    // Getters and Setters
    public int getDiscountID() {
        return discountID;
    }

    public void setDiscountID(int discountID) {
        this.discountID = discountID;
    }

    public String getCampaignName() {
        return campaignName;
    }

    public void setCampaignName(String campaignName) {
        this.campaignName = campaignName;
    }

    public String getDiscountType() {
        return discountType;
    }

    public void setDiscountType(String discountType) {
        this.discountType = discountType;
    }

    public BigDecimal getDiscountValue() {
        return discountValue;
    }

    public void setDiscountValue(BigDecimal discountValue) {
        this.discountValue = discountValue;
    }

    public BigDecimal getMaxDiscountAmount() {
        return maxDiscountAmount;
    }

    public void setMaxDiscountAmount(BigDecimal maxDiscountAmount) {
        this.maxDiscountAmount = maxDiscountAmount;
    }

    public String getAppliedToType() {
        return appliedToType;
    }

    public void setAppliedToType(String appliedToType) {
        this.appliedToType = appliedToType;
    }

    public Integer getAppliedToID() {
        return appliedToID;
    }

    public void setAppliedToID(Integer appliedToID) {
        this.appliedToID = appliedToID;
    }

    public LocalDateTime getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDateTime startDate) {
        this.startDate = startDate;
    }

    public LocalDateTime getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDateTime endDate) {
        this.endDate = endDate;
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

    public LocalDateTime getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(LocalDateTime createdDate) {
        this.createdDate = createdDate;
    }

    public String getCreatedByName() {
        return createdByName;
    }

    public void setCreatedByName(String createdByName) {
        this.createdByName = createdByName;
    }

    public String getAppliedToName() {
        return appliedToName;
    }

    public void setAppliedToName(String appliedToName) {
        this.appliedToName = appliedToName;
    }
    
    /**
     * Check if campaign is currently active
     */
    public boolean isCurrentlyActive() {
        if (!isActive) return false;
        
        LocalDateTime now = LocalDateTime.now();
        return !now.isBefore(startDate) && !now.isAfter(endDate);
    }
    
    /**
     * Get status display text
     */
    public String getStatusText() {
        if (!isActive) return "Tắt";
        
        LocalDateTime now = LocalDateTime.now();
        if (now.isBefore(startDate)) return "Chưa bắt đầu";
        if (now.isAfter(endDate)) return "Đã kết thúc";
        return "Đang diễn ra";
    }
    
    /**
     * Get applied scope display text
     */
    public String getAppliedToText() {
        if (appliedToName != null && !appliedToName.isEmpty()) {
            return appliedToName;
        }
        
        switch (appliedToType) {
            case "all":
                return "Tất cả sản phẩm";
            case "category":
                return "Danh mục #" + appliedToID;
            case "product":
                return "Sản phẩm #" + appliedToID;
            case "brand":
                return "Thương hiệu #" + appliedToID;
            default:
                return "N/A";
        }
    }
}
