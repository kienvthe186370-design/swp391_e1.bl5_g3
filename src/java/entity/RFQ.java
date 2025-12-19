package entity;

import java.sql.Timestamp;
import java.util.List;

/**
 * RFQ Entity - Request for Quotation (Yêu cầu báo giá bán buôn)
 * 
 * Status Flow (sau khi tách Quotation):
 * Draft -> Pending -> [Auto-assign] -> Reviewing
 *       -> DateProposed <-> DateCountered (max 3 lần)
 *       -> DateAccepted -> QuotationCreated -> Completed
 *       -> Cancelled
 */
public class RFQ {
    
    // Status constants
    public static final String STATUS_DRAFT = "Draft";
    public static final String STATUS_PENDING = "Pending";
    public static final String STATUS_REVIEWING = "Reviewing";
    public static final String STATUS_DATE_PROPOSED = "DateProposed";
    public static final String STATUS_DATE_COUNTERED = "DateCountered";
    public static final String STATUS_DATE_ACCEPTED = "DateAccepted";
    public static final String STATUS_QUOTATION_CREATED = "QuotationCreated";
    public static final String STATUS_COMPLETED = "Completed";
    public static final String STATUS_CANCELLED = "Cancelled";
    
    // Legacy status constants (for backward compatibility with RFQDAO)
    @Deprecated
    public static final String STATUS_QUOTED = "Quoted";
    @Deprecated
    public static final String STATUS_QUOTE_ACCEPTED = "QuoteAccepted";
    @Deprecated
    public static final String STATUS_QUOTE_REJECTED = "QuoteRejected";
    @Deprecated
    public static final String STATUS_QUOTE_EXPIRED = "QuoteExpired";
    
    // Max negotiation count for date
    public static final int DEFAULT_MAX_DATE_NEGOTIATION = 3;

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
    private String deliveryStreet;
    private String deliveryCity;
    private String deliveryCityId;
    private String deliveryDistrict;
    private String deliveryDistrictId;
    private String deliveryWard;
    private String deliveryWardId;
    private Timestamp requestedDeliveryDate;
    private String deliveryInstructions;
    
    // Date Negotiation (Thương lượng ngày giao)
    private Timestamp proposedDeliveryDate;      // Seller đề xuất
    private String dateChangeReason;             // Lý do seller đổi ngày
    private Timestamp customerCounterDate;       // Customer đề xuất ngược
    private String customerCounterDateNote;      // Ghi chú customer
    private int dateNegotiationCount;            // Số lần đã thương lượng
    private int maxDateNegotiationCount;         // Tối đa 3 lần
    
    // Payment Preference
    private String paymentTermsPreference;
    
    // Status & Assignment
    private String status;
    private Integer assignedTo;
    
    // Notes
    private String customerNotes;
    private String sellerNotes;
    private String rejectionReason;
    
    // Timestamps
    private Timestamp createdDate;
    private Timestamp updatedDate;
    
    // Related objects
    private Customer customer;
    private String customerName;
    private Employee assignedEmployee;
    private String assignedName;
    private List<RFQItem> items;
    private List<RFQHistory> history;
    
    // Quotation reference (nếu đã tạo báo giá)
    private Quotation quotation;

    public RFQ() {
        this.dateNegotiationCount = 0;
        this.maxDateNegotiationCount = DEFAULT_MAX_DATE_NEGOTIATION;
    }

    // ==================== GETTERS & SETTERS ====================
    
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

    public String getDeliveryStreet() { return deliveryStreet; }
    public void setDeliveryStreet(String deliveryStreet) { this.deliveryStreet = deliveryStreet; }

    public String getDeliveryCity() { return deliveryCity; }
    public void setDeliveryCity(String deliveryCity) { this.deliveryCity = deliveryCity; }

    public String getDeliveryCityId() { return deliveryCityId; }
    public void setDeliveryCityId(String deliveryCityId) { this.deliveryCityId = deliveryCityId; }

    public String getDeliveryDistrict() { return deliveryDistrict; }
    public void setDeliveryDistrict(String deliveryDistrict) { this.deliveryDistrict = deliveryDistrict; }

    public String getDeliveryDistrictId() { return deliveryDistrictId; }
    public void setDeliveryDistrictId(String deliveryDistrictId) { this.deliveryDistrictId = deliveryDistrictId; }

    public String getDeliveryWard() { return deliveryWard; }
    public void setDeliveryWard(String deliveryWard) { this.deliveryWard = deliveryWard; }

    public String getDeliveryWardId() { return deliveryWardId; }
    public void setDeliveryWardId(String deliveryWardId) { this.deliveryWardId = deliveryWardId; }

    public Timestamp getRequestedDeliveryDate() { return requestedDeliveryDate; }
    public void setRequestedDeliveryDate(Timestamp requestedDeliveryDate) { this.requestedDeliveryDate = requestedDeliveryDate; }

    public String getDeliveryInstructions() { return deliveryInstructions; }
    public void setDeliveryInstructions(String deliveryInstructions) { this.deliveryInstructions = deliveryInstructions; }

    public Timestamp getProposedDeliveryDate() { return proposedDeliveryDate; }
    public void setProposedDeliveryDate(Timestamp proposedDeliveryDate) { this.proposedDeliveryDate = proposedDeliveryDate; }

    public String getDateChangeReason() { return dateChangeReason; }
    public void setDateChangeReason(String dateChangeReason) { this.dateChangeReason = dateChangeReason; }

    public Timestamp getCustomerCounterDate() { return customerCounterDate; }
    public void setCustomerCounterDate(Timestamp customerCounterDate) { this.customerCounterDate = customerCounterDate; }

    public String getCustomerCounterDateNote() { return customerCounterDateNote; }
    public void setCustomerCounterDateNote(String customerCounterDateNote) { this.customerCounterDateNote = customerCounterDateNote; }

    public int getDateNegotiationCount() { return dateNegotiationCount; }
    public void setDateNegotiationCount(int dateNegotiationCount) { this.dateNegotiationCount = dateNegotiationCount; }

    public int getMaxDateNegotiationCount() { return maxDateNegotiationCount; }
    public void setMaxDateNegotiationCount(int maxDateNegotiationCount) { this.maxDateNegotiationCount = maxDateNegotiationCount; }

    public String getPaymentTermsPreference() { return paymentTermsPreference; }
    public void setPaymentTermsPreference(String paymentTermsPreference) { this.paymentTermsPreference = paymentTermsPreference; }

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

    public Timestamp getCreatedDate() { return createdDate; }
    public void setCreatedDate(Timestamp createdDate) { this.createdDate = createdDate; }

    public Timestamp getUpdatedDate() { return updatedDate; }
    public void setUpdatedDate(Timestamp updatedDate) { this.updatedDate = updatedDate; }

    public Customer getCustomer() { return customer; }
    public void setCustomer(Customer customer) { this.customer = customer; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public Employee getAssignedEmployee() { return assignedEmployee; }
    public void setAssignedEmployee(Employee assignedEmployee) { this.assignedEmployee = assignedEmployee; }

    public String getAssignedName() { return assignedName; }
    public void setAssignedName(String assignedName) { this.assignedName = assignedName; }

    // Alias for assignedTo (backward compatibility)
    public Integer getAssignedSellerID() { return assignedTo; }
    public void setAssignedSellerID(Integer assignedSellerID) { this.assignedTo = assignedSellerID; }

    // ==================== BACKWARD COMPATIBILITY (DEPRECATED) ====================
    // Các field này đã chuyển sang Quotation entity
    // Giữ lại để RFQDAO cũ không bị lỗi compile
    
    private String paymentMethod;
    private String shippingCarrierId;
    private String shippingCarrierName;
    private String shippingServiceName;
    private java.math.BigDecimal shippingFee;
    private int estimatedDeliveryDays;
    
    @Deprecated
    public String getPaymentMethod() { return paymentMethod; }
    @Deprecated
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    
    @Deprecated
    public String getShippingCarrierId() { return shippingCarrierId; }
    @Deprecated
    public void setShippingCarrierId(String shippingCarrierId) { this.shippingCarrierId = shippingCarrierId; }
    
    @Deprecated
    public String getShippingCarrierName() { return shippingCarrierName; }
    @Deprecated
    public void setShippingCarrierName(String shippingCarrierName) { this.shippingCarrierName = shippingCarrierName; }
    
    @Deprecated
    public String getShippingServiceName() { return shippingServiceName; }
    @Deprecated
    public void setShippingServiceName(String shippingServiceName) { this.shippingServiceName = shippingServiceName; }
    
    @Deprecated
    public java.math.BigDecimal getShippingFee() { return shippingFee; }
    @Deprecated
    public void setShippingFee(java.math.BigDecimal shippingFee) { this.shippingFee = shippingFee; }
    
    @Deprecated
    public int getEstimatedDeliveryDays() { return estimatedDeliveryDays; }
    @Deprecated
    public void setEstimatedDeliveryDays(int estimatedDeliveryDays) { this.estimatedDeliveryDays = estimatedDeliveryDays; }
    
    // Legacy amount fields (for backward compatibility with RFQDAO)
    private java.math.BigDecimal subtotalAmount;
    private java.math.BigDecimal taxAmount;
    private java.math.BigDecimal totalAmount;
    private java.sql.Timestamp quotationSentDate;
    private java.sql.Timestamp quotationValidUntil;
    private String quotationTerms;
    private String warrantyTerms;
    
    @Deprecated
    public java.math.BigDecimal getTotalAmount() { return totalAmount; }
    @Deprecated
    public void setTotalAmount(java.math.BigDecimal totalAmount) { this.totalAmount = totalAmount; }
    @Deprecated
    public java.math.BigDecimal getSubtotalAmount() { return subtotalAmount; }
    @Deprecated
    public void setSubtotalAmount(java.math.BigDecimal subtotalAmount) { this.subtotalAmount = subtotalAmount; }
    @Deprecated
    public java.math.BigDecimal getTaxAmount() { return taxAmount; }
    @Deprecated
    public void setTaxAmount(java.math.BigDecimal taxAmount) { this.taxAmount = taxAmount; }
    @Deprecated
    public java.sql.Timestamp getQuotationSentDate() { return quotationSentDate; }
    @Deprecated
    public void setQuotationSentDate(java.sql.Timestamp quotationSentDate) { this.quotationSentDate = quotationSentDate; }
    @Deprecated
    public java.sql.Timestamp getQuotationValidUntil() { return quotationValidUntil; }
    @Deprecated
    public void setQuotationValidUntil(java.sql.Timestamp quotationValidUntil) { this.quotationValidUntil = quotationValidUntil; }
    @Deprecated
    public String getQuotationTerms() { return quotationTerms; }
    @Deprecated
    public void setQuotationTerms(String quotationTerms) { this.quotationTerms = quotationTerms; }
    @Deprecated
    public String getWarrantyTerms() { return warrantyTerms; }
    @Deprecated
    public void setWarrantyTerms(String warrantyTerms) { this.warrantyTerms = warrantyTerms; }

    public List<RFQItem> getItems() { return items; }
    public void setItems(List<RFQItem> items) { this.items = items; }

    public List<RFQHistory> getHistory() { return history; }
    public void setHistory(List<RFQHistory> history) { this.history = history; }

    public Quotation getQuotation() { return quotation; }
    public void setQuotation(Quotation quotation) { this.quotation = quotation; }

    // ==================== HELPER METHODS ====================
    
    /**
     * Kiểm tra có thể thương lượng ngày không
     */
    public boolean canNegotiateDate() {
        return dateNegotiationCount < maxDateNegotiationCount
            && (STATUS_REVIEWING.equals(status) 
                || STATUS_DATE_PROPOSED.equals(status) 
                || STATUS_DATE_COUNTERED.equals(status));
    }
    
    /**
     * Kiểm tra seller có thể đề xuất ngày không
     */
    public boolean canSellerProposeDate() {
        return canNegotiateDate() 
            && (STATUS_REVIEWING.equals(status) || STATUS_DATE_COUNTERED.equals(status));
    }
    
    /**
     * Kiểm tra customer có thể counter ngày không
     */
    public boolean canCustomerCounterDate() {
        return canNegotiateDate() && STATUS_DATE_PROPOSED.equals(status);
    }
    
    /**
     * Kiểm tra customer có thể accept ngày không
     */
    public boolean canAcceptDate() {
        return STATUS_DATE_PROPOSED.equals(status);
    }
    
    /**
     * Kiểm tra có thể tạo báo giá không
     * Cho phép tạo báo giá khi:
     * - Đang review (không cần thương lượng ngày)
     * - Hoặc đã chấp nhận ngày
     */
    public boolean canCreateQuotation() {
        return STATUS_REVIEWING.equals(status) || STATUS_DATE_ACCEPTED.equals(status);
    }
    
    /**
     * Lấy số lần thương lượng ngày còn lại
     */
    public int getRemainingDateNegotiations() {
        return maxDateNegotiationCount - dateNegotiationCount;
    }
    
    /**
     * Lấy ngày giao hàng cuối cùng (đã thống nhất hoặc yêu cầu ban đầu)
     */
    public Timestamp getFinalDeliveryDate() {
        if (STATUS_DATE_ACCEPTED.equals(status) && proposedDeliveryDate != null) {
            return proposedDeliveryDate;
        }
        return requestedDeliveryDate;
    }
    
    /**
     * Lấy tên hiển thị của status
     */
    public String getStatusDisplayName() {
        if (status == null) return "";
        switch (status) {
            case STATUS_DRAFT: return "Bản nháp";
            case STATUS_PENDING: return "Chờ xử lý";
            case STATUS_REVIEWING: return "Đang xem xét";
            case STATUS_DATE_PROPOSED: return "Đề xuất ngày mới";
            case STATUS_DATE_COUNTERED: return "KH đề xuất ngày";
            case STATUS_DATE_ACCEPTED: return "Đã chấp nhận ngày";
            case STATUS_QUOTATION_CREATED: return "Đã tạo báo giá";
            case STATUS_COMPLETED: return "Hoàn thành";
            case STATUS_CANCELLED: return "Đã hủy";
            default: return status;
        }
    }
    
    /**
     * Lấy CSS class cho badge status
     */
    public String getStatusBadgeClass() {
        if (status == null) return "secondary";
        switch (status) {
            case STATUS_DRAFT: return "secondary";
            case STATUS_PENDING: return "info";
            case STATUS_REVIEWING: return "primary";
            case STATUS_DATE_PROPOSED: return "warning";
            case STATUS_DATE_COUNTERED: return "warning";
            case STATUS_DATE_ACCEPTED: return "success";
            case STATUS_QUOTATION_CREATED: return "info";
            case STATUS_COMPLETED: return "success";
            case STATUS_CANCELLED: return "danger";
            default: return "secondary";
        }
    }
}
