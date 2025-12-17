
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
    
    /**
     * Kích hoạt email cho customer (set IsEmailVerified = 1)
     */
    public boolean verifyEmail(String email) {
        String sql = "UPDATE Customers SET IsEmailVerified = 1 WHERE Email = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, email);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            Logger.getLogger(CustomerDAO.class.getName()).log(Level.SEVERE, null, e);
            return false;
        }
    }
    
    /**
     * Lấy customer theo email
     */
    public Customer getCustomerByEmail(String email) {
        String sql = "SELECT * FROM Customers WHERE Email = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToCustomer(rs);
            }
        } catch (SQLException e) {
            Logger.getLogger(CustomerDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return null;
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
        
        // New fields - handle if columns don't exist
        try {
            customer.setGender(rs.getString("Gender"));
        } catch (SQLException e) { /* Column may not exist */ }
        try {
            customer.setDateOfBirth(rs.getDate("DateOfBirth"));
        } catch (SQLException e) { /* Column may not exist */ }
        try {
            customer.setAvatar(rs.getString("Avatar"));
        } catch (SQLException e) { /* Column may not exist */ }
        
        // Google OAuth fields
        try {
            customer.setGoogleId(rs.getString("GoogleID"));
        } catch (SQLException e) { /* Column may not exist */ }
        try {
            customer.setLoginProvider(rs.getString("LoginProvider"));
        } catch (SQLException e) { /* Column may not exist */ }
        
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
        sql.append("ORDER BY CreatedDate DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        
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
     * Cập nhật thông tin khách hàng (cho admin)
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
     * Cập nhật thông tin profile khách hàng (cho customer tự cập nhật)
     * Có fallback nếu columns Gender, DateOfBirth chưa tồn tại
     */
    public boolean updateProfile(int customerID, String fullName, String phone, String gender, java.sql.Date dateOfBirth) {
        // Try full update first (with Gender, DateOfBirth)
        String sql = "UPDATE Customers SET FullName = ?, Phone = ?, Gender = ?, DateOfBirth = ? WHERE CustomerID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, fullName);
            ps.setString(2, phone);
            ps.setString(3, gender);
            if (dateOfBirth != null) {
                ps.setDate(4, dateOfBirth);
            } else {
                ps.setNull(4, Types.DATE);
            }
            ps.setInt(5, customerID);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            // If columns don't exist, fallback to basic update
            Logger.getLogger(CustomerDAO.class.getName()).log(Level.WARNING, "Full update failed, trying basic update: " + e.getMessage());
            return updateProfileBasic(customerID, fullName, phone);
        }
    }
    
    /**
     * Fallback: Cập nhật chỉ FullName và Phone (khi columns mới chưa tồn tại)
     */
    private boolean updateProfileBasic(int customerID, String fullName, String phone) {
        String sql = "UPDATE Customers SET FullName = ?, Phone = ? WHERE CustomerID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, fullName);
            ps.setString(2, phone);
            ps.setInt(3, customerID);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            Logger.getLogger(CustomerDAO.class.getName()).log(Level.SEVERE, null, e);
            return false;
        }
    }
    
    /**
     * Cập nhật avatar khách hàng
     * Trả về false nếu column Avatar chưa tồn tại
     */
    public boolean updateAvatar(int customerID, String avatarPath) {
        String sql = "UPDATE Customers SET Avatar = ? WHERE CustomerID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, avatarPath);
            ps.setInt(2, customerID);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            Logger.getLogger(CustomerDAO.class.getName()).log(Level.WARNING, "Avatar column may not exist: " + e.getMessage());
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
    
    // ==================== GOOGLE LOGIN METHODS ====================
    
    /**
     * Tìm customer theo Google ID
     * Trả về null nếu column GoogleID chưa tồn tại
     */
    public Customer findByGoogleId(String googleId) {
        if (googleId == null || googleId.isEmpty()) return null;
        
        String sql = "SELECT * FROM Customers WHERE GoogleID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, googleId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToCustomer(rs);
            }
        } catch (SQLException e) {
            // Column may not exist - this is OK, just return null
            System.out.println("[CustomerDAO] findByGoogleId: Column may not exist - " + e.getMessage());
        }
        return null;
    }
    
    /**
     * Liên kết tài khoản Google với customer hiện có
     * Trả về true nếu thành công, false nếu columns chưa tồn tại
     */
    public boolean linkGoogleAccount(int customerID, String googleId) {
        String sql = "UPDATE Customers SET GoogleID = ?, LoginProvider = 'google' WHERE CustomerID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, googleId);
            ps.setInt(2, customerID);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            // Columns may not exist - this is OK for existing accounts
            System.out.println("[CustomerDAO] linkGoogleAccount: Columns may not exist - " + e.getMessage());
            return true; // Return true so login can continue
        }
    }
    
    /**
     * Tạo customer mới từ Google account
     * Có fallback nếu columns GoogleID, LoginProvider, Avatar chưa tồn tại
     */
    public Customer createGoogleCustomer(String googleId, String email, String fullName, String avatar) {
        // Generate a random password hash for Google users (they won't use it)
        String randomPasswordHash = utils.PasswordUtil.hashPassword("GOOGLE_" + googleId + "_" + System.currentTimeMillis());
        
        // Try full insert first (with GoogleID, Avatar, LoginProvider)
        String sql = "INSERT INTO Customers (FullName, Email, PasswordHash, GoogleID, Avatar, LoginProvider, IsEmailVerified, IsActive, CreatedDate) " +
                     "VALUES (?, ?, ?, ?, ?, 'google', 1, 1, GETDATE())";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, randomPasswordHash);
            ps.setString(4, googleId);
            ps.setString(5, avatar);
            
            int rowsAffected = ps.executeUpdate();
            System.out.println("[CustomerDAO] createGoogleCustomer - rows affected: " + rowsAffected);
            
            if (rowsAffected > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    int customerID = rs.getInt(1);
                    System.out.println("[CustomerDAO] Created Google customer with ID: " + customerID);
                    return getCustomerById(customerID);
                }
            }
        } catch (SQLException e) {
            System.err.println("[CustomerDAO] Full insert failed: " + e.getMessage());
            e.printStackTrace();
            // Fallback: create basic customer without Google-specific columns
            return createGoogleCustomerBasic(email, fullName, randomPasswordHash);
        }
        return null;
    }
    
    /**
     * Fallback: Tạo customer cơ bản khi columns Google chưa tồn tại
     */
    private Customer createGoogleCustomerBasic(String email, String fullName, String passwordHash) {
        String sql = "INSERT INTO Customers (FullName, Email, PasswordHash, IsEmailVerified, IsActive, CreatedDate) " +
                     "VALUES (?, ?, ?, 1, 1, GETDATE())";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, passwordHash);
            
            int rowsAffected = ps.executeUpdate();
            System.out.println("[CustomerDAO] createGoogleCustomerBasic - rows affected: " + rowsAffected);
            
            if (rowsAffected > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    int customerID = rs.getInt(1);
                    System.out.println("[CustomerDAO] Created basic customer with ID: " + customerID);
                    return getCustomerById(customerID);
                }
            }
        } catch (SQLException e) {
            Logger.getLogger(CustomerDAO.class.getName()).log(Level.SEVERE, "Failed to create basic customer", e);
        }
        return null;
    }
    
    /**
     * Cập nhật last login (public method for Google login)
     */
    public void updateLastLogin(int customerID) {
        String sql = "UPDATE Customers SET LastLogin = GETDATE() WHERE CustomerID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, customerID);
            ps.executeUpdate();
        } catch (SQLException e) {
            Logger.getLogger(CustomerDAO.class.getName()).log(Level.SEVERE, null, e);
        }
    }
}
