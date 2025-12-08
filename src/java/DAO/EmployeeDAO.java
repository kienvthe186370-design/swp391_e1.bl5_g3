package DAO;

import entity.Employee;
import utils.PasswordUtil;
import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class EmployeeDAO extends DBContext {
    
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
            Logger.getLogger(EmployeeDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return null;
    }
    
    public Employee getEmployeeById(int employeeID) {
        String sql = "SELECT * FROM Employees WHERE EmployeeID = ? AND IsActive = 1";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, employeeID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToEmployee(rs);
            }
        } catch (SQLException e) {
            Logger.getLogger(EmployeeDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return null;
    }
    
    private void updateLastLogin(int employeeID) {
        String sql = "UPDATE Employees SET LastLogin = GETDATE() WHERE EmployeeID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, employeeID);
            ps.executeUpdate();
        } catch (SQLException e) {
            Logger.getLogger(EmployeeDAO.class.getName()).log(Level.SEVERE, null, e);
        }
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
            Logger.getLogger(EmployeeDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return false;
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
        return employee;
    }
}
