package entity;

import java.sql.Timestamp;

public class OrderStatusHistory {
    private int historyID;
    private int orderID;
    private String oldStatus;
    private String newStatus;
    private String notes;
    private Integer changedBy;
    private Timestamp changedDate;
    
    // Relationship
    private Employee changedByEmployee;

    public OrderStatusHistory() {
    }

    // Getters and Setters
    public int getHistoryID() {
        return historyID;
    }

    public void setHistoryID(int historyID) {
        this.historyID = historyID;
    }

    public int getOrderID() {
        return orderID;
    }

    public void setOrderID(int orderID) {
        this.orderID = orderID;
    }

    public String getOldStatus() {
        return oldStatus;
    }

    public void setOldStatus(String oldStatus) {
        this.oldStatus = oldStatus;
    }

    public String getNewStatus() {
        return newStatus;
    }

    public void setNewStatus(String newStatus) {
        this.newStatus = newStatus;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public Integer getChangedBy() {
        return changedBy;
    }

    public void setChangedBy(Integer changedBy) {
        this.changedBy = changedBy;
    }

    public Timestamp getChangedDate() {
        return changedDate;
    }

    public void setChangedDate(Timestamp changedDate) {
        this.changedDate = changedDate;
    }

    public Employee getChangedByEmployee() {
        return changedByEmployee;
    }

    public void setChangedByEmployee(Employee changedByEmployee) {
        this.changedByEmployee = changedByEmployee;
    }
}
