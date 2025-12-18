
package DAO;

import entity.Employee;
import utils.PasswordUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class EmployeeDAO extends DBContext {
    
    private static final Logger LOGGER = Logger.getLogger(EmployeeDAO.class.getName());
    
    public Employee login(String email, String password) {
        String sql = "SELECT * FROM Employees WHERE Email = ? AND IsActive = 1";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                String hashedPassword = rs.getString("PasswordHash");
                if (PasswordUtil.verifyPassword(password, hashedPassword)) {
                    Employee employee = mapResultSetToEmployee(rs);
                    updateLastLogin(employee.getEmployeeID());
                    return employee;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, null, e);
        }
        return null;
    }
    
    public Employee getEmployeeById(int employeeID) {
        String sql = "SELECT * FROM Employees WHERE EmployeeID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, employeeID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToEmployee(rs);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, null, e);
        }
        return null;
    }
    
    public boolean isEmailExists(String email) {
        String sql = "SELECT COUNT(*) FROM Employees WHERE Email = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, null, e);
        }
        return false;
    }
    
    /**
     * Kiểm tra email đã tồn tại cho nhân viên khác (không tính nhân viên hiện tại)
     */
    public boolean isEmailExistsForOtherEmployee(String email, int excludeEmployeeID) {
        String sql = "SELECT COUNT(*) FROM Employees WHERE Email = ? AND EmployeeID != ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, email);
            ps.setInt(2, excludeEmployeeID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, null, e);
        }
        return false;
    }
    
    /**
     * Lấy danh sách nhân viên với filter và pagination (cho admin)
     */
    public List<Employee> getAllEmployees(String search, Boolean isActive, String role, int page, int pageSize) {
        List<Employee> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT * FROM Employees WHERE 1=1 AND Role != 'Admin' ");
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (FullName LIKE ? OR Email LIKE ? OR Phone LIKE ?) ");
        }
        if (isActive != null) {
            sql.append("AND IsActive = ? ");
        }
        if (role != null && !role.trim().isEmpty()) {
            sql.append("AND Role = ? ");
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
            if (role != null && !role.trim().isEmpty()) {
                ps.setString(paramIndex++, role);
            }
            ps.setInt(paramIndex++, (page - 1) * pageSize);
            ps.setInt(paramIndex++, pageSize);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToEmployee(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, null, e);
        }
        return list;
    }
    
    /**
     * Đếm tổng số nhân viên với filter
     */
    public int getTotalEmployees(String search, Boolean isActive, String role) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM Employees WHERE 1=1 AND Role != 'Admin' ");
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (FullName LIKE ? OR Email LIKE ? OR Phone LIKE ?) ");
        }
        if (isActive != null) {
            sql.append("AND IsActive = ? ");
        }
        if (role != null && !role.trim().isEmpty()) {
            sql.append("AND Role = ? ");
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
            if (role != null && !role.trim().isEmpty()) {
                ps.setString(paramIndex++, role);
            }
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, null, e);
        }
        return 0;
    }
    
    /**
     * Lấy thống kê nhân viên: [0]=total, [1]=active, [2]=locked
     */
    public int[] getEmployeeStats() {
        String sql = "SELECT COUNT(*) as Total, " +
                     "SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END) as Active, " +
                     "SUM(CASE WHEN IsActive = 0 THEN 1 ELSE 0 END) as Locked " +
                     "FROM Employees WHERE Role != 'Admin'";
        int[] stats = new int[3];
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                stats[0] = rs.getInt("Total");
                stats[1] = rs.getInt("Active");
                stats[2] = rs.getInt("Locked");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, null, e);
        }
        return stats;
    }
    
    /**
     * Tạo nhân viên mới
     */
    public boolean createEmployee(String fullName, String email, String password, String phone, String role) {
        return createEmployee(fullName, email, password, phone, role, false);
    }

    /**
     * Tạo nhân viên mới với tùy chọn bắt buộc đổi mật khẩu
     */
    public boolean createEmployee(String fullName, String email, String password, String phone, String role, boolean mustChangePassword) {
        String sql = "INSERT INTO Employees (FullName, Email, PasswordHash, Phone, Role, IsActive, MustChangePassword, CreatedDate) "
                   + "VALUES (?, ?, ?, ?, ?, 1, ?, GETDATE())";
        
        // DEBUG LOG
        System.out.println("========== CREATE EMPLOYEE DEBUG ==========");
        System.out.println("FullName: [" + fullName + "]");
        System.out.println("Email: [" + email + "]");
        System.out.println("Phone: [" + phone + "]");
        System.out.println("Role: [" + role + "]");
        System.out.println("MustChangePassword: " + mustChangePassword);
        System.out.println("============================================");
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, PasswordUtil.hashPassword(password));
            // Xử lý phone null đúng cách
            if (phone != null && !phone.trim().isEmpty()) {
                ps.setString(4, phone.trim());
            } else {
                ps.setNull(4, java.sql.Types.VARCHAR);
            }
            ps.setString(5, role);
            ps.setBoolean(6, mustChangePassword);
            
            int result = ps.executeUpdate();
            System.out.println("Create result: " + result);
            return result > 0;
        } catch (SQLException e) {
            System.out.println("========== SQL ERROR ==========");
            System.out.println("SQLState: " + e.getSQLState());
            System.out.println("ErrorCode: " + e.getErrorCode());
            System.out.println("Message: " + e.getMessage());
            System.out.println("===============================");
            LOGGER.log(Level.SEVERE, "Error creating employee: " + e.getMessage(), e);
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Cập nhật thông tin nhân viên
     */
    public boolean updateEmployee(int employeeID, String fullName, String email, String phone, String role, boolean isActive) {
        String sql = "UPDATE Employees SET FullName = ?, Email = ?, Phone = ?, Role = ?, IsActive = ? WHERE EmployeeID = ?";
        
        // DEBUG LOG
        System.out.println("========== UPDATE EMPLOYEE DEBUG ==========");
        System.out.println("EmployeeID: " + employeeID);
        System.out.println("FullName: [" + fullName + "]");
        System.out.println("Email: [" + email + "]");
        System.out.println("Phone: [" + phone + "]");
        System.out.println("Role: [" + role + "]");
        System.out.println("Role length: " + (role != null ? role.length() : "null"));
        System.out.println("IsActive: " + isActive);
        System.out.println("============================================");
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, fullName);
            ps.setString(2, email);
            // Xử lý phone null đúng cách
            if (phone != null && !phone.trim().isEmpty()) {
                ps.setString(3, phone.trim());
            } else {
                ps.setNull(3, java.sql.Types.VARCHAR);
            }
            ps.setString(4, role);
            ps.setBoolean(5, isActive);
            ps.setInt(6, employeeID);
            
            int result = ps.executeUpdate();
            System.out.println("Update result: " + result);
            return result > 0;
        } catch (SQLException e) {
            System.out.println("========== SQL ERROR ==========");
            System.out.println("SQLState: " + e.getSQLState());
            System.out.println("ErrorCode: " + e.getErrorCode());
            System.out.println("Message: " + e.getMessage());
            System.out.println("===============================");
            LOGGER.log(Level.SEVERE, "Error updating employee ID " + employeeID + ": " + e.getMessage(), e);
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Cập nhật mật khẩu nhân viên
     */
    public boolean updatePassword(int employeeID, String newPassword) {
        String sql = "UPDATE Employees SET PasswordHash = ? WHERE EmployeeID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, PasswordUtil.hashPassword(newPassword));
            ps.setInt(2, employeeID);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, null, e);
            return false;
        }
    }
    
    /**
     * Khóa/Mở khóa tài khoản nhân viên
     */
    public boolean setEmployeeActiveStatus(int employeeID, boolean isActive) {
        String sql = "UPDATE Employees SET IsActive = ? WHERE EmployeeID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setBoolean(1, isActive);
            ps.setInt(2, employeeID);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, null, e);
            return false;
        }
    }
    
    private void updateLastLogin(int employeeID) {
        String sql = "UPDATE Employees SET LastLogin = GETDATE() WHERE EmployeeID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, employeeID);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, null, e);
        }
    }
    
    private Employee mapResultSetToEmployee(ResultSet rs) throws SQLException {
        Employee employee = new Employee();
        employee.setEmployeeID(rs.getInt("EmployeeID"));
        employee.setFullName(rs.getString("FullName"));
        employee.setEmail(rs.getString("Email"));
        employee.setPasswordHash(rs.getString("PasswordHash"));
        employee.setPhone(rs.getString("Phone"));
        employee.setAvatar(rs.getString("Avatar"));
        employee.setRole(rs.getString("Role"));
        employee.setActive(rs.getBoolean("IsActive"));
        employee.setCreatedDate(rs.getTimestamp("CreatedDate"));
        employee.setLastLogin(rs.getTimestamp("LastLogin"));
        try {
            employee.setMustChangePassword(rs.getBoolean("MustChangePassword"));
        } catch (SQLException e) {
            employee.setMustChangePassword(false);
        }
        return employee;
    }

    /**
     * Cập nhật trạng thái bắt buộc đổi mật khẩu
     */
    public boolean setMustChangePassword(int employeeID, boolean mustChangePassword) {
        String sql = "UPDATE Employees SET MustChangePassword = ? WHERE EmployeeID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setBoolean(1, mustChangePassword);
            ps.setInt(2, employeeID);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, null, e);
            return false;
        }
    }

    /**
     * Cập nhật mật khẩu và tắt cờ bắt buộc đổi mật khẩu
     */
    public boolean updatePasswordAndClearMustChange(int employeeID, String newPassword) {
        String sql = "UPDATE Employees SET PasswordHash = ?, MustChangePassword = 0 WHERE EmployeeID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, PasswordUtil.hashPassword(newPassword));
            ps.setInt(2, employeeID);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, null, e);
            return false;
        }
    }
}
