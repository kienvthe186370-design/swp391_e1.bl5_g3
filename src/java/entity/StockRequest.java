package entity;

import java.sql.Timestamp;
import java.util.List;

/**
 * StockRequest Entity - Yêu cầu nhập kho từ Seller gửi Admin
 * 
 * Status Flow:
 * Pending -> Completed (Admin approve và tự động cập nhật Stock)
 */
public class StockRequest {
    
    public static final String STATUS_PENDING = "Pending";
    public static final String STATUS_COMPLETED = "Completed";
    
    private int stockRequestID;
    private String requestCode;
    private int rfqID;
    private int requestedBy;
    private String status;
    private String notes;
    private String adminNotes;
    private Integer completedBy;
    private Timestamp completedDate;
    private Timestamp createdDate;
    private Timestamp updatedDate;
    
    // Related objects
    private RFQ rfq;
    private String rfqCode;
    private Employee requestedByEmployee;
    private String requestedByName;
    private Employee completedByEmployee;
    private String completedByName;
    private List<StockRequestItem> items;
    
    public StockRequest() {
        this.status = STATUS_PENDING;
    }

    // Getters and Setters
    public int getStockRequestID() { return stockRequestID; }
    public void setStockRequestID(int stockRequestID) { this.stockRequestID = stockRequestID; }

    public String getRequestCode() { return requestCode; }
    public void setRequestCode(String requestCode) { this.requestCode = requestCode; }

    public int getRfqID() { return rfqID; }
    public void setRfqID(int rfqID) { this.rfqID = rfqID; }

    public int getRequestedBy() { return requestedBy; }
    public void setRequestedBy(int requestedBy) { this.requestedBy = requestedBy; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public String getAdminNotes() { return adminNotes; }
    public void setAdminNotes(String adminNotes) { this.adminNotes = adminNotes; }

    public Integer getCompletedBy() { return completedBy; }
    public void setCompletedBy(Integer completedBy) { this.completedBy = completedBy; }

    public Timestamp getCompletedDate() { return completedDate; }
    public void setCompletedDate(Timestamp completedDate) { this.completedDate = completedDate; }

    public Timestamp getCreatedDate() { return createdDate; }
    public void setCreatedDate(Timestamp createdDate) { this.createdDate = createdDate; }

    public Timestamp getUpdatedDate() { return updatedDate; }
    public void setUpdatedDate(Timestamp updatedDate) { this.updatedDate = updatedDate; }

    public RFQ getRfq() { return rfq; }
    public void setRfq(RFQ rfq) { this.rfq = rfq; }

    public String getRfqCode() { return rfqCode; }
    public void setRfqCode(String rfqCode) { this.rfqCode = rfqCode; }

    public Employee getRequestedByEmployee() { return requestedByEmployee; }
    public void setRequestedByEmployee(Employee requestedByEmployee) { this.requestedByEmployee = requestedByEmployee; }

    public String getRequestedByName() { return requestedByName; }
    public void setRequestedByName(String requestedByName) { this.requestedByName = requestedByName; }

    public Employee getCompletedByEmployee() { return completedByEmployee; }
    public void setCompletedByEmployee(Employee completedByEmployee) { this.completedByEmployee = completedByEmployee; }

    public String getCompletedByName() { return completedByName; }
    public void setCompletedByName(String completedByName) { this.completedByName = completedByName; }

    public List<StockRequestItem> getItems() { return items; }
    public void setItems(List<StockRequestItem> items) { this.items = items; }

    // Helper methods
    public String getStatusDisplayName() {
        if (STATUS_PENDING.equals(status)) return "Chờ duyệt";
        if (STATUS_COMPLETED.equals(status)) return "Đã nhập kho";
        return status;
    }
    
    public String getStatusBadgeClass() {
        if (STATUS_PENDING.equals(status)) return "warning";
        if (STATUS_COMPLETED.equals(status)) return "success";
        return "secondary";
    }
    
    public boolean isPending() {
        return STATUS_PENDING.equals(status);
    }
    
    public boolean isCompleted() {
        return STATUS_COMPLETED.equals(status);
    }
}
