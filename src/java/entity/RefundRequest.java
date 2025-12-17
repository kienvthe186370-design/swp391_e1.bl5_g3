package entity;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

/**
 * Entity cho yêu cầu hoàn tiền
 */
public class RefundRequest {
    private int refundRequestID;
    private int orderID;
    private int customerID;
    private String refundReason;
    private String refundStatus; // Pending, Approved, Rejected, Processing, Completed
    private BigDecimal refundAmount;
    private String adminNotes;
    private Timestamp requestDate;
    private Integer processedBy;
    private Timestamp processedDate;
    
    // Relationships
    private Order order;
    private Customer customer;
    private Employee processor;
    private List<RefundItem> refundItems;
    private List<RefundMedia> refundMedia;

    public RefundRequest() {}

    // Getters and Setters
    public int getRefundRequestID() { return refundRequestID; }
    public void setRefundRequestID(int refundRequestID) { this.refundRequestID = refundRequestID; }

    public int getOrderID() { return orderID; }
    public void setOrderID(int orderID) { this.orderID = orderID; }

    public int getCustomerID() { return customerID; }
    public void setCustomerID(int customerID) { this.customerID = customerID; }

    public String getRefundReason() { return refundReason; }
    public void setRefundReason(String refundReason) { this.refundReason = refundReason; }

    public String getRefundStatus() { return refundStatus; }
    public void setRefundStatus(String refundStatus) { this.refundStatus = refundStatus; }

    public BigDecimal getRefundAmount() { return refundAmount; }
    public void setRefundAmount(BigDecimal refundAmount) { this.refundAmount = refundAmount; }

    public String getAdminNotes() { return adminNotes; }
    public void setAdminNotes(String adminNotes) { this.adminNotes = adminNotes; }

    public Timestamp getRequestDate() { return requestDate; }
    public void setRequestDate(Timestamp requestDate) { this.requestDate = requestDate; }

    public Integer getProcessedBy() { return processedBy; }
    public void setProcessedBy(Integer processedBy) { this.processedBy = processedBy; }

    public Timestamp getProcessedDate() { return processedDate; }
    public void setProcessedDate(Timestamp processedDate) { this.processedDate = processedDate; }

    public Order getOrder() { return order; }
    public void setOrder(Order order) { this.order = order; }

    public Customer getCustomer() { return customer; }
    public void setCustomer(Customer customer) { this.customer = customer; }

    public Employee getProcessor() { return processor; }
    public void setProcessor(Employee processor) { this.processor = processor; }

    public List<RefundItem> getRefundItems() { return refundItems; }
    public void setRefundItems(List<RefundItem> refundItems) { this.refundItems = refundItems; }

    public List<RefundMedia> getRefundMedia() { return refundMedia; }
    public void setRefundMedia(List<RefundMedia> refundMedia) { this.refundMedia = refundMedia; }
}
