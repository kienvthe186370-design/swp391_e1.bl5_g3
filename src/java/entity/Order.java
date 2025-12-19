package entity;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

public class Order {
    private int orderID;
    private String orderCode;
    private int customerID;
    private Integer addressID;
    
    // Thông tin tiền
    private BigDecimal subtotalAmount;
    private BigDecimal discountAmount;
    private BigDecimal voucherDiscount;
    private BigDecimal shippingFee;
    private BigDecimal totalAmount;
    private BigDecimal totalCost;
    private BigDecimal totalProfit;
    
    // Voucher & Payment
    private Integer voucherID;
    private String paymentMethod;
    private String paymentStatus;
    private String paymentToken;
    private Timestamp paymentExpiry;
    
    // Status & Assignment
    private String orderStatus;
    private Integer assignedTo;      // Seller được phân công
    private Integer assignedBy;      // Manager phân công
    private Timestamp assignedDate;  // Ngày phân công
    
    // Notes
    private String notes;
    private String cancelReason;
    
    // RFQ/Quotation Reference
    private Integer rfqID;
    private Integer quotationID;
    
    // Timestamps
    private Timestamp orderDate;
    private Timestamp updatedDate;
    
    // Relationships (để hiển thị)
    private Customer customer;
    private CustomerAddress address;
    private Employee assignedSeller;
    private Employee assignedByEmployee;
    private List<OrderDetail> orderDetails;
    private List<OrderStatusHistory> statusHistory;
    private Shipping shipping;
    private RFQ rfq; // Thông tin RFQ nếu đơn hàng từ RFQ

    public Order() {
    }

    // Getters and Setters
    public int getOrderID() {
        return orderID;
    }

    public void setOrderID(int orderID) {
        this.orderID = orderID;
    }

    public String getOrderCode() {
        return orderCode;
    }

    public void setOrderCode(String orderCode) {
        this.orderCode = orderCode;
    }

    public int getCustomerID() {
        return customerID;
    }

    public void setCustomerID(int customerID) {
        this.customerID = customerID;
    }

    public Integer getAddressID() {
        return addressID;
    }

    public void setAddressID(Integer addressID) {
        this.addressID = addressID;
    }

    public BigDecimal getSubtotalAmount() {
        return subtotalAmount;
    }

    public void setSubtotalAmount(BigDecimal subtotalAmount) {
        this.subtotalAmount = subtotalAmount;
    }

    public BigDecimal getDiscountAmount() {
        return discountAmount;
    }

    public void setDiscountAmount(BigDecimal discountAmount) {
        this.discountAmount = discountAmount;
    }

    public BigDecimal getVoucherDiscount() {
        return voucherDiscount;
    }

    public void setVoucherDiscount(BigDecimal voucherDiscount) {
        this.voucherDiscount = voucherDiscount;
    }

    public BigDecimal getShippingFee() {
        return shippingFee;
    }

    public void setShippingFee(BigDecimal shippingFee) {
        this.shippingFee = shippingFee;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public BigDecimal getTotalCost() {
        return totalCost;
    }

    public void setTotalCost(BigDecimal totalCost) {
        this.totalCost = totalCost;
    }

    public BigDecimal getTotalProfit() {
        return totalProfit;
    }

    public void setTotalProfit(BigDecimal totalProfit) {
        this.totalProfit = totalProfit;
    }

    public Integer getVoucherID() {
        return voucherID;
    }

    public void setVoucherID(Integer voucherID) {
        this.voucherID = voucherID;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getPaymentToken() {
        return paymentToken;
    }

    public void setPaymentToken(String paymentToken) {
        this.paymentToken = paymentToken;
    }

    public Timestamp getPaymentExpiry() {
        return paymentExpiry;
    }

    public void setPaymentExpiry(Timestamp paymentExpiry) {
        this.paymentExpiry = paymentExpiry;
    }

    public String getOrderStatus() {
        return orderStatus;
    }

    public void setOrderStatus(String orderStatus) {
        this.orderStatus = orderStatus;
    }

    public Integer getAssignedTo() {
        return assignedTo;
    }

    public void setAssignedTo(Integer assignedTo) {
        this.assignedTo = assignedTo;
    }

    public Integer getAssignedBy() {
        return assignedBy;
    }

    public void setAssignedBy(Integer assignedBy) {
        this.assignedBy = assignedBy;
    }

    public Timestamp getAssignedDate() {
        return assignedDate;
    }

    public void setAssignedDate(Timestamp assignedDate) {
        this.assignedDate = assignedDate;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public String getCancelReason() {
        return cancelReason;
    }

    public void setCancelReason(String cancelReason) {
        this.cancelReason = cancelReason;
    }

    public Integer getRfqID() {
        return rfqID;
    }

    public void setRfqID(Integer rfqID) {
        this.rfqID = rfqID;
    }

    public Integer getQuotationID() {
        return quotationID;
    }

    public void setQuotationID(Integer quotationID) {
        this.quotationID = quotationID;
    }

    public Timestamp getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(Timestamp orderDate) {
        this.orderDate = orderDate;
    }

    public Timestamp getUpdatedDate() {
        return updatedDate;
    }

    public void setUpdatedDate(Timestamp updatedDate) {
        this.updatedDate = updatedDate;
    }

    public Customer getCustomer() {
        return customer;
    }

    public void setCustomer(Customer customer) {
        this.customer = customer;
    }

    public CustomerAddress getAddress() {
        return address;
    }

    public void setAddress(CustomerAddress address) {
        this.address = address;
    }

    public Employee getAssignedSeller() {
        return assignedSeller;
    }

    public void setAssignedSeller(Employee assignedSeller) {
        this.assignedSeller = assignedSeller;
    }

    public Employee getAssignedByEmployee() {
        return assignedByEmployee;
    }

    public void setAssignedByEmployee(Employee assignedByEmployee) {
        this.assignedByEmployee = assignedByEmployee;
    }

    public List<OrderDetail> getOrderDetails() {
        return orderDetails;
    }

    public void setOrderDetails(List<OrderDetail> orderDetails) {
        this.orderDetails = orderDetails;
    }

    public List<OrderStatusHistory> getStatusHistory() {
        return statusHistory;
    }

    public void setStatusHistory(List<OrderStatusHistory> statusHistory) {
        this.statusHistory = statusHistory;
    }

    public Shipping getShipping() {
        return shipping;
    }

    public void setShipping(Shipping shipping) {
        this.shipping = shipping;
    }

    public RFQ getRfq() {
        return rfq;
    }

    public void setRfq(RFQ rfq) {
        this.rfq = rfq;
    }
}
