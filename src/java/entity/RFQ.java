package entity;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

/**
 * RFQ Entity - Request for Quotation (Yêu cầu báo giá bán buôn)
 * Status Flow (theo diagram):
 * PENDING -> DATE_PROPOSED -> DATE_ACCEPTED/DATE_REJECTED
 * PENDING -> QUOTED -> QUOTE_ACCEPTED/QUOTE_REJECTED
 * QUOTE_ACCEPTED -> COMPLETED (checkout)
 */
public class RFQ {
    // Status constants
    public static final String STATUS_PENDING = "Pending";
    public static final String STATUS_REVIEWING = "Reviewing";
    public static final String STATUS_DATE_PROPOSED = "DateProposed";
    public static final String STATUS_DATE_ACCEPTED = "DateAccepted";
    public static final String STATUS_DATE_REJECTED = "DateRejected";
    public static final String STATUS_QUOTED = "Quoted";
    public static final String STATUS_QUOTE_ACCEPTED = "QuoteAccepted";
    public static final String STATUS_QUOTE_REJECTED = "QuoteRejected";
    public static final String STATUS_COMPLETED = "Completed";
    public static final String STATUS_CANCELLED = "Cancelled";

    private int rfqID;
    private String rfqCode;
    private int customerID;
    
    // Company Info
    private String companyName;
    private String taxID;
    private String businessType;
    
    // Contact Info
    private String contactPerson;
    private String contactPhone;
    private String contactEmail;
    private String alternativeContact;
    
    // Delivery Info
    private String deliveryAddress;
    private String deliveryCityId;
    private String deliveryDistrictId;
    private String deliveryWardId;
    private Timestamp requestedDeliveryDate;
    private Timestamp proposedDeliveryDate;
    private String deliveryInstructions;
    
    // Pricing
    private BigDecimal subtotalAmount;
    private BigDecimal shippingFee;
    private BigDecimal taxAmount;
    private BigDecimal totalAmount;
    
    // Quotation Info
    private Timestamp quotationSentDate;
    private Timestamp quotationValidUntil;
    private String quotationTerms;
    private String warrantyTerms;
    private String paymentMethod;
    
    // Status Management
    private String status;
    private Integer assignedTo;
    
    // Notes
    private String customerNotes;
    private String sellerNotes;
    private String rejectionReason;
    private String dateChangeReason;
    
    // Timestamps
    private Timestamp createdDate;
    private Timestamp updatedDate;
    
    // Related objects
    private Customer customer;
    private Employee assignedEmployee;
    private List<RFQItem> items;
    private List<RFQHistory> history;

    public RFQ() {}

    // Getters and Setters
    public int getRfqID() { return rfqID; }
    public void setRfqID(int rfqID) { this.rfqID = rfqID; }

    public String getRfqCode() { return rfqCode; }
    public void setRfqCode(String rfqCode) { this.rfqCode = rfqCode; }

    public int getCustomerID() { return customerID; }
    public void setCustomerID(int customerID) { this.customerID = customerID; }

    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }

    public String getTaxID() { return taxID; }
    public void setTaxID(String taxID) { this.taxID = taxID; }

    public String getBusinessType() { return businessType; }
    public void setBusinessType(String businessType) { this.businessType = businessType; }

    public String getContactPerson() { return contactPerson; }
    public void setContactPerson(String contactPerson) { this.contactPerson = contactPerson; }

    public String getContactPhone() { return contactPhone; }
    public void setContactPhone(String contactPhone) { this.contactPhone = contactPhone; }

    public String getContactEmail() { return contactEmail; }
    public void setContactEmail(String contactEmail) { this.contactEmail = contactEmail; }

    public String getAlternativeContact() { return alternativeContact; }
    public void setAlternativeContact(String alternativeContact) { this.alternativeContact = alternativeContact; }

    public String getDeliveryAddress() { return deliveryAddress; }
    public void setDeliveryAddress(String deliveryAddress) { this.deliveryAddress = deliveryAddress; }

    public String getDeliveryCityId() { return deliveryCityId; }
    public void setDeliveryCityId(String deliveryCityId) { this.deliveryCityId = deliveryCityId; }

    public String getDeliveryDistrictId() { return deliveryDistrictId; }
    public void setDeliveryDistrictId(String deliveryDistrictId) { this.deliveryDistrictId = deliveryDistrictId; }

    public String getDeliveryWardId() { return deliveryWardId; }
    public void setDeliveryWardId(String deliveryWardId) { this.deliveryWardId = deliveryWardId; }

    public Timestamp getRequestedDeliveryDate() { return requestedDeliveryDate; }
    public void setRequestedDeliveryDate(Timestamp requestedDeliveryDate) { this.requestedDeliveryDate = requestedDeliveryDate; }

    public Timestamp getProposedDeliveryDate() { return proposedDeliveryDate; }
    public void setProposedDeliveryDate(Timestamp proposedDeliveryDate) { this.proposedDeliveryDate = proposedDeliveryDate; }

    public String getDeliveryInstructions() { return deliveryInstructions; }
    public void setDeliveryInstructions(String deliveryInstructions) { this.deliveryInstructions = deliveryInstructions; }

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

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Integer getAssignedTo() { return assignedTo; }
    public void setAssignedTo(Integer assignedTo) { this.assignedTo = assignedTo; }

    public String getCustomerNotes() { return customerNotes; }
    public void setCustomerNotes(String customerNotes) { this.customerNotes = customerNotes; }

    public String getSellerNotes() { return sellerNotes; }
    public void setSellerNotes(String sellerNotes) { this.sellerNotes = sellerNotes; }

    public String getRejectionReason() { return rejectionReason; }
    public void setRejectionReason(String rejectionReason) { this.rejectionReason = rejectionReason; }

    public String getDateChangeReason() { return dateChangeReason; }
    public void setDateChangeReason(String dateChangeReason) { this.dateChangeReason = dateChangeReason; }

    public Timestamp getCreatedDate() { return createdDate; }
    public void setCreatedDate(Timestamp createdDate) { this.createdDate = createdDate; }

    public Timestamp getUpdatedDate() { return updatedDate; }
    public void setUpdatedDate(Timestamp updatedDate) { this.updatedDate = updatedDate; }

    public Customer getCustomer() { return customer; }
    public void setCustomer(Customer customer) { this.customer = customer; }

    public Employee getAssignedEmployee() { return assignedEmployee; }
    public void setAssignedEmployee(Employee assignedEmployee) { this.assignedEmployee = assignedEmployee; }

    public List<RFQItem> getItems() { return items; }
    public void setItems(List<RFQItem> items) { this.items = items; }

    public List<RFQHistory> getHistory() { return history; }
    public void setHistory(List<RFQHistory> history) { this.history = history; }
    
    // Helper methods
    public boolean canProposeDate() {
        return STATUS_PENDING.equals(status) || STATUS_REVIEWING.equals(status);
    }
    
    public boolean canCreateQuote() {
        // Cho phép tạo báo giá ngay khi đơn đang chờ xử lý
        // hoặc sau khi khách đã chấp nhận ngày giao mới
        return STATUS_PENDING.equals(status) || STATUS_DATE_ACCEPTED.equals(status);
    }
    
    public boolean canAcceptQuote() {
        return STATUS_QUOTED.equals(status);
    }
    
    public String getStatusDisplayName() {
        switch (status) {
            case STATUS_PENDING: return "Chờ xử lý";
            case STATUS_REVIEWING: return "Đang xem xét";
            case STATUS_DATE_PROPOSED: return "Đề xuất ngày mới";
            case STATUS_DATE_ACCEPTED: return "Đã chấp nhận ngày";
            case STATUS_DATE_REJECTED: return "Từ chối ngày mới";
            case STATUS_QUOTED: return "Đã báo giá";
            case STATUS_QUOTE_ACCEPTED: return "Đã thanh toán";
            case STATUS_QUOTE_REJECTED: return "Từ chối báo giá";
            case STATUS_COMPLETED: return "Hoàn thành";
            case STATUS_CANCELLED: return "Đã hủy";
            default: return status;
        }
    }
}
