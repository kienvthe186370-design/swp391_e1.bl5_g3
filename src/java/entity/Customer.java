package entity;

import java.sql.Timestamp;

public class Customer {
    private int customerID;
    private String fullName;
    private String email;
    private String passwordHash;
    private String phone;
    private boolean isEmailVerified;
    private String verificationToken;
    private Timestamp tokenExpiry;
    private boolean isActive;
    private Timestamp createdDate;
    private Timestamp lastLogin;

    public Customer() {
    }

    public Customer(int customerID, String fullName, String email, String passwordHash, 
                   String phone, boolean isEmailVerified, boolean isActive) {
        this.customerID = customerID;
        this.fullName = fullName;
        this.email = email;
        this.passwordHash = passwordHash;
        this.phone = phone;
        this.isEmailVerified = isEmailVerified;
        this.isActive = isActive;
    }

    // Getters and Setters
    public int getCustomerID() { return customerID; }
    public void setCustomerID(int customerID) { this.customerID = customerID; }
    
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    
    public boolean isEmailVerified() { return isEmailVerified; }
    public void setEmailVerified(boolean emailVerified) { isEmailVerified = emailVerified; }
    
    public String getVerificationToken() { return verificationToken; }
    public void setVerificationToken(String verificationToken) { this.verificationToken = verificationToken; }
    
    public Timestamp getTokenExpiry() { return tokenExpiry; }
    public void setTokenExpiry(Timestamp tokenExpiry) { this.tokenExpiry = tokenExpiry; }
    
    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
    
    public Timestamp getCreatedDate() { return createdDate; }
    public void setCreatedDate(Timestamp createdDate) { this.createdDate = createdDate; }
    
    public Timestamp getLastLogin() { return lastLogin; }
    public void setLastLogin(Timestamp lastLogin) { this.lastLogin = lastLogin; }
}
