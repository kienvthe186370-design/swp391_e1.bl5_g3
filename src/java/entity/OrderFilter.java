package entity;

import java.util.Date;

public class OrderFilter {
    private String searchKeyword;      // Tìm theo mã đơn, tên KH, SĐT
    private String orderStatus;        // Filter theo status
    private String paymentStatus;
    private String paymentMethod;
    private Integer customerId;
    private Integer assignedTo;        // Filter theo seller
    private Boolean unassignedOnly;    // Chỉ lấy đơn chưa phân công
    private Date fromDate;
    private Date toDate;
    private String sortBy;             // orderDate, totalAmount, orderStatus
    private String sortOrder;          // ASC, DESC

    public OrderFilter() {
        this.sortBy = "orderDate";
        this.sortOrder = "DESC";
    }

    // Getters and Setters
    public String getSearchKeyword() {
        return searchKeyword;
    }

    public void setSearchKeyword(String searchKeyword) {
        this.searchKeyword = searchKeyword;
    }

    public String getOrderStatus() {
        return orderStatus;
    }

    public void setOrderStatus(String orderStatus) {
        this.orderStatus = orderStatus;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public Integer getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Integer customerId) {
        this.customerId = customerId;
    }

    public Integer getAssignedTo() {
        return assignedTo;
    }

    public void setAssignedTo(Integer assignedTo) {
        this.assignedTo = assignedTo;
    }

    public Boolean getUnassignedOnly() {
        return unassignedOnly;
    }

    public void setUnassignedOnly(Boolean unassignedOnly) {
        this.unassignedOnly = unassignedOnly;
    }

    public Date getFromDate() {
        return fromDate;
    }

    public void setFromDate(Date fromDate) {
        this.fromDate = fromDate;
    }

    public Date getToDate() {
        return toDate;
    }

    public void setToDate(Date toDate) {
        this.toDate = toDate;
    }

    public String getSortBy() {
        return sortBy;
    }

    public void setSortBy(String sortBy) {
        this.sortBy = sortBy;
    }

    public String getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(String sortOrder) {
        this.sortOrder = sortOrder;
    }
}
