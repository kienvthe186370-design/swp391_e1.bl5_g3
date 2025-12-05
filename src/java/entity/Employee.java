package entity;

import java.sql.Timestamp;

public class Employee {
    private int employeeID;
    private String fullName;
    private String email;
    private String passwordHash;
    private String phone;
    private String avatar;
    private String role; // Admin, Staff, Marketer, Seller, SellerManager
    private boolean isActive;
    private Timestamp createdDate;
    private Timestamp lastLogin;

    public Employee() {
    }

    public Employee(int employeeID, String fullName, String email, String passwordHash, 
                   String phone, String role, boolean isActive) {
        this.employeeID = employeeID;
        this.fullName = fullName;
        this.email = email;
        this.passwordHash = passwordHash;
        this.phone = phone;
        this.role = role;
        this.isActive = isActive;   
        
        
        
        
        
    }

    // Getters and Setters
    public int getEmployeeID() { return employeeID; }
    public void setEmployeeID(int employeeID) { this.employeeID = employeeID; }
    
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    
    public String getAvatar() { return avatar; }
    public void setAvatar(String avatar) { this.avatar = avatar; }
    
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    
    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
    
    public Timestamp getCreatedDate() { return createdDate; }
    public void setCreatedDate(Timestamp createdDate) { this.createdDate = createdDate; }
    
    public Timestamp getLastLogin() { return lastLogin; }
    public void setLastLogin(Timestamp lastLogin) { this.lastLogin = lastLogin; }
}
