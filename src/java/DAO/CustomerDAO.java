package DAO;

import entity.Customer;
import utils.PasswordUtil;
import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CustomerDAO extends DBContext {
    
    public Customer login(String email, String password) {
        String sql = "SELECT * FROM Customers WHERE Email = ? AND IsActive = 1";
        try (Connection conn = getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                String hashedPassword = rs.getString("PasswordHash");
                if (PasswordUtil.verifyPassword(password, hashedPassword)) {
                    Customer customer = mapResultSetToCustomer(rs);
                    updateLastLogin(customer.getCustomerID());
                    return customer;
                }
            }
        } catch (SQLException e) {
            Logger.getLogger(CustomerDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return null;
    }
    
    public boolean register(String fullName, String email, String password, String phone) {
        String sql = "INSERT INTO Customers (FullName, Email, PasswordHash, Phone, IsEmailVerified, IsActive, CreatedDate) "
                   + "VALUES (?, ?, ?, ?, 0, 1, GETDATE())";
        try (Connection conn = getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, PasswordUtil.hashPassword(password));
            ps.setString(4, phone);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            Logger.getLogger(CustomerDAO.class.getName()).log(Level.SEVERE, null, e);
            return false;
        }
    }
    
    public boolean isEmailExists(String email) {
        String sql = "SELECT COUNT(*) FROM Customers WHERE Email = ?";
        try (Connection conn = getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            Logger.getLogger(CustomerDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return false;
    }
    
    public boolean savePasswordResetToken(String email, String token) {
        String sql = "UPDATE Customers SET VerificationToken = ?, TokenExpiry = DATEADD(MINUTE, 30, GETDATE()) "
                   + "WHERE Email = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, token);
            ps.setString(2, email);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            Logger.getLogger(CustomerDAO.class.getName()).log(Level.SEVERE, null, e);
            return false;
        }
    }
    
    public boolean verifyResetToken(String email, String token) {
        String sql = "SELECT COUNT(*) FROM Customers WHERE Email = ? AND VerificationToken = ? "
                   + "AND TokenExpiry > GETDATE()";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, email);
            ps.setString(2, token);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            Logger.getLogger(CustomerDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return false;
    }
    
    public boolean resetPassword(String email, String newPassword) {
        String sql = "UPDATE Customers SET PasswordHash = ?, VerificationToken = NULL, TokenExpiry = NULL "
                   + "WHERE Email = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, PasswordUtil.hashPassword(newPassword));
            ps.setString(2, email);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            Logger.getLogger(CustomerDAO.class.getName()).log(Level.SEVERE, null, e);
            return false;
        }
    }
    
    private void updateLastLogin(int customerID) {
        String sql = "UPDATE Customers SET LastLogin = GETDATE() WHERE CustomerID = ?";
        try (Connection conn = getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, customerID);
            ps.executeUpdate();
        } catch (SQLException e) {
            Logger.getLogger(CustomerDAO.class.getName()).log(Level.SEVERE, null, e);
        }
    }
    
    private Customer mapResultSetToCustomer(ResultSet rs) throws SQLException {
        Customer customer = new Customer();
        customer.setCustomerID(rs.getInt("CustomerID"));
        customer.setFullName(rs.getString("FullName"));
        customer.setEmail(rs.getString("Email"));
        customer.setPasswordHash(rs.getString("PasswordHash"));
        customer.setPhone(rs.getString("Phone"));
        customer.setEmailVerified(rs.getBoolean("IsEmailVerified"));
        customer.setActive(rs.getBoolean("IsActive"));
        customer.setCreatedDate(rs.getTimestamp("CreatedDate"));
        customer.setLastLogin(rs.getTimestamp("LastLogin"));
        return customer;
    }
}
