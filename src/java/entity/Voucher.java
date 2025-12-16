/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package entity;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 *
 * @author xuand
 */
public class Voucher {

    private int voucherID;
    private String voucherCode;
    private String voucherName;
    private String description;
    private String discountType;
    private BigDecimal discountValue;
    private BigDecimal minOrderValue;
    private BigDecimal maxDiscountAmount;
    private Integer maxUsage;
    private int usedCount;
    private Timestamp startDate;
    private Timestamp endDate;
    private boolean isActive;
    private boolean isPrivate;
    private Integer createdBy;
    private Timestamp createdDate;

    public Voucher() {
    }

    public Voucher(int voucherID, String voucherCode, String voucherName, String description, String discountType, BigDecimal discountValue, BigDecimal minOrderValue, BigDecimal maxDiscountAmount, Integer maxUsage, int usedCount, Timestamp startDate, Timestamp endDate, boolean isActive, boolean isPrivate, Integer createdBy, Timestamp createdDate) {
        this.voucherID = voucherID;
        this.voucherCode = voucherCode;
        this.voucherName = voucherName;
        this.description = description;
        this.discountType = discountType;
        this.discountValue = discountValue;
        this.minOrderValue = minOrderValue;
        this.maxDiscountAmount = maxDiscountAmount;
        this.maxUsage = maxUsage;
        this.usedCount = usedCount;
        this.startDate = startDate;
        this.endDate = endDate;
        this.isActive = isActive;
        this.isPrivate = isPrivate;
        this.createdBy = createdBy;
        this.createdDate = createdDate;
    }

    public String getDiscountType() {
        return discountType;
    }

    public void setDiscountType(String discountType) {
        this.discountType = discountType;
    }

    public int getVoucherID() {
        return voucherID;
    }

    public void setVoucherID(int voucherID) {
        this.voucherID = voucherID;
    }

    public String getVoucherCode() {
        return voucherCode;
    }

    public void setVoucherCode(String voucherCode) {
        this.voucherCode = voucherCode;
    }

    public String getVoucherName() {
        return voucherName;
    }

    public void setVoucherName(String voucherName) {
        this.voucherName = voucherName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public BigDecimal getDiscountValue() {
        return discountValue;
    }

    public void setDiscountValue(BigDecimal discountValue) {
        this.discountValue = discountValue;
    }

    public BigDecimal getMinOrderValue() {
        return minOrderValue;
    }

    public void setMinOrderValue(BigDecimal minOrderValue) {
        this.minOrderValue = minOrderValue;
    }

    public BigDecimal getMaxDiscountAmount() {
        return maxDiscountAmount;
    }

    public void setMaxDiscountAmount(BigDecimal maxDiscountAmount) {
        this.maxDiscountAmount = maxDiscountAmount;
    }

    public Integer getMaxUsage() {
        return maxUsage;
    }

    public void setMaxUsage(Integer maxUsage) {
        this.maxUsage = maxUsage;
    }

    public int getUsedCount() {
        return usedCount;
    }

    public void setUsedCount(int usedCount) {
        this.usedCount = usedCount;
    }

    public Timestamp getStartDate() {
        return startDate;
    }

    public void setStartDate(Timestamp startDate) {
        this.startDate = startDate;
    }

    public Timestamp getEndDate() {
        return endDate;
    }

    public void setEndDate(Timestamp endDate) {
        this.endDate = endDate;
    }

    public boolean isIsActive() {
        return isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }

    public boolean isIsPrivate() {
        return isPrivate;
    }

    public void setIsPrivate(boolean isPrivate) {
        this.isPrivate = isPrivate;
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

    @Override
    public String toString() {
        return "Voucher{" + "voucherID=" + voucherID + ", voucherCode=" + voucherCode + ", voucherName=" + voucherName + ", description=" + description + ", discountType=" + discountType + ", discountValue=" + discountValue + ", minOrderValue=" + minOrderValue + ", maxDiscountAmount=" + maxDiscountAmount + ", maxUsage=" + maxUsage + ", usedCount=" + usedCount + ", startDate=" + startDate + ", endDate=" + endDate + ", isActive=" + isActive + ", isPrivate=" + isPrivate + ", createdBy=" + createdBy + ", createdDate=" + createdDate + '}';
    }

    /**
     * Check if voucher is valid (active, within date range, usage not exceeded)
     */
    public boolean isValid() {
        if (!isActive) {
            return false;
        }

        Timestamp now = new Timestamp(System.currentTimeMillis());
        if (startDate != null && now.before(startDate)) {
            return false;
        }
        if (endDate != null && now.after(endDate)) {
            return false;
        }

        if (maxUsage != null && usedCount >= maxUsage) {
            return false;
        }

        return true;
    }

    /**
     * Calculate discount amount based on subtotal
     */
    public BigDecimal calculateDiscount(BigDecimal subtotal) {
        if (subtotal == null || discountValue == null) {
            return BigDecimal.ZERO;
        }

        BigDecimal discount = BigDecimal.ZERO;

        if ("percentage".equalsIgnoreCase(discountType)) {
            // Percentage discount: subtotal * discountValue / 100
            discount = subtotal.multiply(discountValue).divide(new BigDecimal("100"));

            // Apply max discount limit if exists
            if (maxDiscountAmount != null && discount.compareTo(maxDiscountAmount) > 0) {
                discount = maxDiscountAmount;
            }
        } else if ("fixed".equalsIgnoreCase(discountType)) {
            // Fixed amount discount
            discount = discountValue;

            // Discount cannot exceed subtotal
            if (discount.compareTo(subtotal) > 0) {
                discount = subtotal;
            }
        }

        return discount;
    }
}
