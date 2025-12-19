package entity;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

/**
 * Quotation Entity - Đơn báo giá (tách từ RFQ)
 * 
 * Status Flow:
 * Created -> Sent -> CustomerCountered <-> SellerCountered (max 3 lần)
 *                 -> Accepted -> Paid
 *                 -> Rejected
 *                 -> Expired
 */
public class Quotation {
    
    // Status constants
    public static final String STATUS_CREATED = "Created";
    public static final String STATUS_SENT = "Sent";
    public static final String STATUS_CUSTOMER_COUNTERED = "CustomerCountered";
    public static final String STATUS_SELLER_COUNTERED = "SellerCountered";
    public static final String STATUS_ACCEPTED = "Accepted";
    public static final String STATUS_REJECTED = "Rejected";
    public static final String STATUS_EXPIRED = "Expired";
    public static final String STATUS_PAID = "Paid";
    
    // Max negotiation count
    public static final int DEFAULT_MAX_NEGOTIATION = 3;

    private int quotationID;
    private String quotationCode;
    private int rfqID;
    
    // Pricing
    private BigDecimal subtotalAmount;
    private BigDecimal shippingFee;
    private BigDecimal taxAmount;
    private BigDecimal totalAmount;
    
    // Quotation Details
    private Timestamp quotationSentDate;
    private Timestamp quotationValidUntil;
    private String quotationTerms;
    private String warrantyTerms;
    private String paymentMethod;
    
    // Shipping Method
    private String shippingCarrierId;
    private String shippingCarrierName;
    private String shippingServiceName;
    private int estimatedDeliveryDays;
    
    // Price Negotiation
    private int negotiationCount;
    private int maxNegotiationCount;
    private BigDecimal customerCounterPrice;
    private String customerCounterNote;
    private BigDecimal sellerCounterPrice;
    private String sellerCounterNote;
    
    // Status
    private String status;
    private String sellerNotes;
    private String rejectionReason;
    
    // Audit
    private Integer createdBy;
    private Timestamp createdDate;
    private Timestamp updatedDate;
    
    // Related objects
    private RFQ rfq;
    private Employee createdByEmployee;
    private List<QuotationItem> items;
    private List<QuotationHistory> history;

    public Quotation() {
        this.negotiationCount = 0;
        this.maxNegotiationCount = DEFAULT_MAX_NEGOTIATION;
    }

    // ==================== GETTERS & SETTERS ====================
    
    public int getQuotationID() { return quotationID; }
    public void setQuotationID(int quotationID) { this.quotationID = quotationID; }

    public String getQuotationCode() { return quotationCode; }
    public void setQuotationCode(String quotationCode) { this.quotationCode = quotationCode; }

    public int getRfqID() { return rfqID; }
    public void setRfqID(int rfqID) { this.rfqID = rfqID; }

    public BigDecimal getSubtotalAmount() { return subtotalAmount; }
    public void setSubtotalAmount(BigDecimal subtotalAmount) { this.subtotalAmount = subtotalAmount; }

    public BigDecimal getShippingFee() { return shippingFee; }
    public void setShippingFee(BigDecimal shippingFee) { this.shippingFee = shippingFee; }

    public BigDecimal getTaxAmount() { return taxAmount; }
    public void setTaxAmount(BigDecimal taxAmount) { this.taxAmount = taxAmount; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public Timestamp getQuotationSentDate() { return quotationSentDate; }
    public void setQuotationSentDate(Timestamp quotationSentDate) { this.quotationSentDate = quotationSentDate; }

    public Timestamp getQuotationValidUntil() { return quotationValidUntil; }
    public void setQuotationValidUntil(Timestamp quotationValidUntil) { this.quotationValidUntil = quotationValidUntil; }

    public String getQuotationTerms() { return quotationTerms; }
    public void setQuotationTerms(String quotationTerms) { this.quotationTerms = quotationTerms; }

    public String getWarrantyTerms() { return warrantyTerms; }
    public void setWarrantyTerms(String warrantyTerms) { this.warrantyTerms = warrantyTerms; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getShippingCarrierId() { return shippingCarrierId; }
    public void setShippingCarrierId(String shippingCarrierId) { this.shippingCarrierId = shippingCarrierId; }

    public String getShippingCarrierName() { return shippingCarrierName; }
    public void setShippingCarrierName(String shippingCarrierName) { this.shippingCarrierName = shippingCarrierName; }

    public String getShippingServiceName() { return shippingServiceName; }
    public void setShippingServiceName(String shippingServiceName) { this.shippingServiceName = shippingServiceName; }

    public int getEstimatedDeliveryDays() { return estimatedDeliveryDays; }
    public void setEstimatedDeliveryDays(int estimatedDeliveryDays) { this.estimatedDeliveryDays = estimatedDeliveryDays; }

    public int getNegotiationCount() { return negotiationCount; }
    public void setNegotiationCount(int negotiationCount) { this.negotiationCount = negotiationCount; }

    public int getMaxNegotiationCount() { return maxNegotiationCount; }
    public void setMaxNegotiationCount(int maxNegotiationCount) { this.maxNegotiationCount = maxNegotiationCount; }

    public BigDecimal getCustomerCounterPrice() { return customerCounterPrice; }
    public void setCustomerCounterPrice(BigDecimal customerCounterPrice) { this.customerCounterPrice = customerCounterPrice; }

    public String getCustomerCounterNote() { return customerCounterNote; }
    public void setCustomerCounterNote(String customerCounterNote) { this.customerCounterNote = customerCounterNote; }

    public BigDecimal getSellerCounterPrice() { return sellerCounterPrice; }
    public void setSellerCounterPrice(BigDecimal sellerCounterPrice) { this.sellerCounterPrice = sellerCounterPrice; }

    public String getSellerCounterNote() { return sellerCounterNote; }
    public void setSellerCounterNote(String sellerCounterNote) { this.sellerCounterNote = sellerCounterNote; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getSellerNotes() { return sellerNotes; }
    public void setSellerNotes(String sellerNotes) { this.sellerNotes = sellerNotes; }

    public String getRejectionReason() { return rejectionReason; }
    public void setRejectionReason(String rejectionReason) { this.rejectionReason = rejectionReason; }

    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }

    public Timestamp getCreatedDate() { return createdDate; }
    public void setCreatedDate(Timestamp createdDate) { this.createdDate = createdDate; }

    public Timestamp getUpdatedDate() { return updatedDate; }
    public void setUpdatedDate(Timestamp updatedDate) { this.updatedDate = updatedDate; }

    public RFQ getRfq() { return rfq; }
    public void setRfq(RFQ rfq) { this.rfq = rfq; }

    public Employee getCreatedByEmployee() { return createdByEmployee; }
    public void setCreatedByEmployee(Employee createdByEmployee) { this.createdByEmployee = createdByEmployee; }

    public List<QuotationItem> getItems() { return items; }
    public void setItems(List<QuotationItem> items) { this.items = items; }

    public List<QuotationHistory> getHistory() { return history; }
    public void setHistory(List<QuotationHistory> history) { this.history = history; }

    // ==================== HELPER METHODS ====================
    
    /**
     * Kiểm tra có thể thương lượng giá không
     */
    public boolean canNegotiate() {
        return negotiationCount < maxNegotiationCount 
            && (STATUS_SENT.equals(status) 
                || STATUS_CUSTOMER_COUNTERED.equals(status) 
                || STATUS_SELLER_COUNTERED.equals(status));
    }
    
    /**
     * Kiểm tra customer có thể counter không
     */
    public boolean canCustomerCounter() {
        return canNegotiate() 
            && (STATUS_SENT.equals(status) || STATUS_SELLER_COUNTERED.equals(status));
    }
    
    /**
     * Kiểm tra seller có thể counter không
     */
    public boolean canSellerCounter() {
        return canNegotiate() && STATUS_CUSTOMER_COUNTERED.equals(status);
    }
    
    /**
     * Kiểm tra customer có thể accept không
     */
    public boolean canAccept() {
        return STATUS_SENT.equals(status) 
            || STATUS_SELLER_COUNTERED.equals(status);
    }
    
    /**
     * Kiểm tra báo giá đã hết hạn chưa
     */
    public boolean isExpired() {
        if (quotationValidUntil == null) return false;
        return new java.util.Date().after(quotationValidUntil);
    }
    
    /**
     * Lấy số lần thương lượng còn lại
     */
    public int getRemainingNegotiations() {
        return maxNegotiationCount - negotiationCount;
    }
    
    /**
     * Lấy tên hiển thị của status
     */
    public String getStatusDisplayName() {
        if (status == null) return "";
        switch (status) {
            case STATUS_CREATED: return "Đã tạo";
            case STATUS_SENT: return "Đã gửi";
            case STATUS_CUSTOMER_COUNTERED: return "KH đề xuất giá";
            case STATUS_SELLER_COUNTERED: return "Seller đề xuất giá";
            case STATUS_ACCEPTED: return "Đã chấp nhận";
            case STATUS_REJECTED: return "Đã từ chối";
            case STATUS_EXPIRED: return "Hết hạn";
            case STATUS_PAID: return "Đã thanh toán";
            default: return status;
        }
    }
    
    /**
     * Lấy CSS class cho badge status
     */
    public String getStatusBadgeClass() {
        if (status == null) return "secondary";
        switch (status) {
            case STATUS_CREATED: return "info";
            case STATUS_SENT: return "primary";
            case STATUS_CUSTOMER_COUNTERED: return "warning";
            case STATUS_SELLER_COUNTERED: return "warning";
            case STATUS_ACCEPTED: return "info"; // Xanh dương - chờ thanh toán
            case STATUS_REJECTED: return "danger";
            case STATUS_EXPIRED: return "secondary";
            case STATUS_PAID: return "success"; // Xanh lá - hoàn thành
            default: return "secondary";
        }
    }
}
