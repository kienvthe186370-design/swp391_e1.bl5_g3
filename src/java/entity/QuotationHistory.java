package entity;

import java.sql.Timestamp;

/**
 * QuotationHistory Entity - Lịch sử thay đổi báo giá
 */
public class QuotationHistory {
    
    private int historyID;
    private int quotationID;
    private String oldStatus;
    private String newStatus;
    private String action;
    private String notes;
    private Integer changedBy;
    private String changedByType; // 'customer', 'employee', 'system'
    private Timestamp changedDate;
    private java.math.BigDecimal priceChange; // Giá thay đổi (nếu có)
    
    // Related objects
    private String changedByName; // Tên người thay đổi (để hiển thị)

    public QuotationHistory() {}

    // ==================== GETTERS & SETTERS ====================
    
    public int getHistoryID() { return historyID; }
    public void setHistoryID(int historyID) { this.historyID = historyID; }

    public int getQuotationID() { return quotationID; }
    public void setQuotationID(int quotationID) { this.quotationID = quotationID; }

    public String getOldStatus() { return oldStatus; }
    public void setOldStatus(String oldStatus) { this.oldStatus = oldStatus; }

    public String getNewStatus() { return newStatus; }
    public void setNewStatus(String newStatus) { this.newStatus = newStatus; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Integer getChangedBy() { return changedBy; }
    public void setChangedBy(Integer changedBy) { this.changedBy = changedBy; }

    public String getChangedByType() { return changedByType; }
    public void setChangedByType(String changedByType) { this.changedByType = changedByType; }

    public Timestamp getChangedDate() { return changedDate; }
    public void setChangedDate(Timestamp changedDate) { this.changedDate = changedDate; }

    public String getChangedByName() { return changedByName; }
    public void setChangedByName(String changedByName) { this.changedByName = changedByName; }

    public java.math.BigDecimal getPriceChange() { return priceChange; }
    public void setPriceChange(java.math.BigDecimal priceChange) { this.priceChange = priceChange; }

    // ==================== HELPER METHODS ====================
    
    /**
     * Lấy icon cho action
     */
    public String getActionIcon() {
        if (action == null) return "fas fa-circle";
        
        if (action.contains("Created") || action.contains("Tạo")) {
            return "fas fa-plus-circle text-info";
        } else if (action.contains("Sent") || action.contains("Gửi")) {
            return "fas fa-paper-plane text-primary";
        } else if (action.contains("Counter") || action.contains("Đề xuất")) {
            return "fas fa-exchange-alt text-warning";
        } else if (action.contains("Accept") || action.contains("Chấp nhận")) {
            return "fas fa-check-circle text-success";
        } else if (action.contains("Reject") || action.contains("Từ chối")) {
            return "fas fa-times-circle text-danger";
        } else if (action.contains("Paid") || action.contains("Thanh toán")) {
            return "fas fa-money-bill-wave text-success";
        } else if (action.contains("Expired") || action.contains("Hết hạn")) {
            return "fas fa-clock text-secondary";
        }
        
        return "fas fa-circle";
    }
    
    /**
     * Lấy tên hiển thị của người thay đổi
     */
    public String getChangedByDisplayName() {
        if (changedByName != null && !changedByName.isEmpty()) {
            return changedByName;
        }
        if ("system".equals(changedByType)) {
            return "Hệ thống";
        }
        if ("customer".equals(changedByType)) {
            return "Khách hàng";
        }
        if ("employee".equals(changedByType)) {
            return "Nhân viên";
        }
        return "N/A";
    }
}
