package entity;

import java.sql.Timestamp;

/**
 * RFQHistory Entity - Audit log cho RFQ
 */
public class RFQHistory {
    private int historyID;
    private int rfqID;
    private String oldStatus;
    private String newStatus;
    private String action;
    private String notes;
    private Integer changedBy;
    private String changedByType; // "customer" or "employee"
    private Timestamp changedDate;
    
    // Related
    private String changedByName;

    public RFQHistory() {}

    // Getters and Setters
    public int getHistoryID() { return historyID; }
    public void setHistoryID(int historyID) { this.historyID = historyID; }

    public int getRfqID() { return rfqID; }
    public void setRfqID(int rfqID) { this.rfqID = rfqID; }

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
}
