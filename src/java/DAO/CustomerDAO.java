
package DAO;

import entity.Customer;
import utils.PasswordUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
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
    
    /**
     * Tạo khách hàng mới (cho admin) - có thể set IsEmailVerified
     */
    public boolean createCustomer(String fullName, String email, String password, String phone, boolean isEmailVerified) {
        String sql = "INSERT INTO Customers (FullName, Email, PasswordHash, Phone, IsEmailVerified, IsActive, CreatedDate) "
                   + "VALUES (?, ?, ?, ?, ?, 1, GETDATE())";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, PasswordUtil.hashPassword(password));
            ps.setString(4, phone);
            ps.setBoolean(5, isEmailVerified);
            
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
    
    /**
     * Lấy danh sách khách hàng với filter và pagination (cho admin)
     */
    public List<Customer> getAllCustomers(String search, Boolean isActive, Boolean isEmailVerified, int page, int pageSize) {
        List<Customer> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT * FROM Customers WHERE 1=1 ");
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (FullName LIKE ? OR Email LIKE ? OR Phone LIKE ?) ");
        }
        if (isActive != null) {
            sql.append("AND IsActive = ? ");
        }
        if (isEmailVerified != null) {
            sql.append("AND IsEmailVerified = ? ");
        }
        sql.append("ORDER BY CreatedDate ASC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                String searchTerm = "%" + search.trim() + "%";
                ps.setString(paramIndex++, searchTerm);
                ps.setString(paramIndex++, searchTerm);
                ps.setString(paramIndex++, searchTerm);
            }
            if (isActive != null) {
                ps.setBoolean(paramIndex++, isActive);
            }
            if (isEmailVerified != null) {
                ps.setBoolean(paramIndex++, isEmailVerified);
            }
            ps.setInt(paramIndex++, (page - 1) * pageSize);
            ps.setInt(paramIndex++, pageSize);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToCustomer(rs));
            }
        } catch (SQLException e) {
            Logger.getLogger(CustomerDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return list;
    }
    
    /**
     * Lấy thông tin chi tiết khách hàng theo ID
     */
    public Customer getCustomerById(int customerID) {
        String sql = "SELECT * FROM Customers WHERE CustomerID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, customerID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToCustomer(rs);
            }
        } catch (SQLException e) {
            Logger.getLogger(CustomerDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return null;
    }
    
    /**
     * Cập nhật thông tin khách hàng
     */
    public boolean updateCustomer(int customerID, String fullName, String phone, boolean isEmailVerified) {
        String sql = "UPDATE Customers SET FullName = ?, Phone = ?, IsEmailVerified = ? WHERE CustomerID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, fullName);
            ps.setString(2, phone);
            ps.setBoolean(3, isEmailVerified);
            ps.setInt(4, customerID);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            Logger.getLogger(CustomerDAO.class.getName()).log(Level.SEVERE, null, e);
            return false;
        }
    }
    
    /**
     * Cập nhật mật khẩu khách hàng
     */
    public boolean updatePassword(int customerID, String newPassword) {
        String sql = "UPDATE Customers SET PasswordHash = ? WHERE CustomerID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, PasswordUtil.hashPassword(newPassword));
            ps.setInt(2, customerID);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            Logger.getLogger(CustomerDAO.class.getName()).log(Level.SEVERE, null, e);
            return false;
        }
    }
    
    /**
     * Khóa/Mở khóa tài khoản khách hàng
     */
    public boolean setCustomerActiveStatus(int customerID, boolean isActive) {
        String sql = "UPDATE Customers SET IsActive = ? WHERE CustomerID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setBoolean(1, isActive);
            ps.setInt(2, customerID);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            Logger.getLogger(CustomerDAO.class.getName()).log(Level.SEVERE, null, e);
            return false;
        }
    }
    
    /**
     * Lấy thống kê khách hàng: [0]=total, [1]=active, [2]=locked
     */
    public int[] getCustomerStats() {
        int[] stats = new int[3];
        String sql = "SELECT " +
                     "COUNT(*) as Total, " +
                     "SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END) as Active, " +
                     "SUM(CASE WHEN IsActive = 0 THEN 1 ELSE 0 END) as Locked " +
                     "FROM Customers";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                stats[0] = rs.getInt("Total");
                stats[1] = rs.getInt("Active");
                stats[2] = rs.getInt("Locked");
            }
        } catch (SQLException e) {
            Logger.getLogger(CustomerDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return stats;
    }
    
    /**
     * Đếm tổng số khách hàng (cho pagination)
     */
    public int getTotalCustomers(String search, Boolean isActive, Boolean isEmailVerified) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM Customers WHERE 1=1 ");
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (FullName LIKE ? OR Email LIKE ? OR Phone LIKE ?) ");
        }
        if (isActive != null) {
            sql.append("AND IsActive = ? ");
        }
        if (isEmailVerified != null) {
            sql.append("AND IsEmailVerified = ? ");
        }
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                String searchTerm = "%" + search.trim() + "%";
                ps.setString(paramIndex++, searchTerm);
                ps.setString(paramIndex++, searchTerm);
                ps.setString(paramIndex++, searchTerm);
            }
            if (isActive != null) {
                ps.setBoolean(paramIndex++, isActive);
            }
            if (isEmailVerified != null) {
                ps.setBoolean(paramIndex++, isEmailVerified);
            }
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            Logger.getLogger(CustomerDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return 0;
    }
}
