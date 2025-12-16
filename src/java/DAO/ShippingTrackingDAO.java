package DAO;

import entity.ShippingTracking;
import entity.Employee;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho ShippingTracking - quản lý lịch sử tracking
 */
public class ShippingTrackingDAO {
    
    /**
     * Tạo tracking record mới
     */
    public int createTracking(ShippingTracking tracking) {
        String sql = "INSERT INTO ShippingTracking (ShippingID, StatusCode, StatusDescription, Location, Notes, UpdatedBy) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, tracking.getShippingID());
            ps.setString(2, tracking.getStatusCode());
            ps.setString(3, tracking.getStatusDescription());
            ps.setString(4, tracking.getLocation());
            ps.setString(5, tracking.getNotes());
            if (tracking.getUpdatedBy() != null) {
                ps.setInt(6, tracking.getUpdatedBy());
            } else {
                ps.setNull(6, Types.INTEGER);
            }
            
            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
                // Nếu không lấy được ID, vẫn return 1 để biết insert thành công
                return 1;
            }
        } catch (Exception e) {
            System.err.println("[ShippingTrackingDAO] Error creating tracking: " + e.getMessage());
            e.printStackTrace();
        }
        return -1;
    }
    
    /**
     * Lấy lịch sử tracking theo ShippingID (mới nhất trước)
     */
    public List<ShippingTracking> getTrackingHistory(int shippingID) {
        List<ShippingTracking> list = new ArrayList<>();
        String sql = "SELECT t.*, e.FullName as ShipperName " +
                     "FROM ShippingTracking t " +
                     "LEFT JOIN Employees e ON t.UpdatedBy = e.EmployeeID " +
                     "WHERE t.ShippingID = ? " +
                     "ORDER BY t.CreatedAt DESC";
        
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, shippingID);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                ShippingTracking tracking = mapResultSet(rs);
                list.add(tracking);
            }
        } catch (Exception e) {
            System.err.println("[ShippingTrackingDAO] Error getting history: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }
    
    /**
     * Lấy tracking mới nhất của một shipping
     */
    public ShippingTracking getLatestTracking(int shippingID) {
        String sql = "SELECT TOP 1 t.*, e.FullName as ShipperName " +
                     "FROM ShippingTracking t " +
                     "LEFT JOIN Employees e ON t.UpdatedBy = e.EmployeeID " +
                     "WHERE t.ShippingID = ? " +
                     "ORDER BY t.CreatedAt DESC";
        
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, shippingID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSet(rs);
            }
        } catch (Exception e) {
            System.err.println("[ShippingTrackingDAO] Error getting latest: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Lấy tracking theo OrderID
     */
    public List<ShippingTracking> getTrackingByOrderId(int orderID) {
        List<ShippingTracking> list = new ArrayList<>();
        String sql = "SELECT t.*, e.FullName as ShipperName " +
                     "FROM ShippingTracking t " +
                     "INNER JOIN Shipping s ON t.ShippingID = s.ShippingID " +
                     "LEFT JOIN Employees e ON t.UpdatedBy = e.EmployeeID " +
                     "WHERE s.OrderID = ? " +
                     "ORDER BY t.CreatedAt DESC";
        
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, orderID);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                ShippingTracking tracking = mapResultSet(rs);
                list.add(tracking);
            }
        } catch (Exception e) {
            System.err.println("[ShippingTrackingDAO] Error getting by orderID: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }
    
    /**
     * Map ResultSet to ShippingTracking
     */
    private ShippingTracking mapResultSet(ResultSet rs) throws SQLException {
        ShippingTracking tracking = new ShippingTracking();
        tracking.setTrackingID(rs.getInt("TrackingID"));
        tracking.setShippingID(rs.getInt("ShippingID"));
        tracking.setStatusCode(rs.getString("StatusCode"));
        tracking.setStatusDescription(rs.getString("StatusDescription"));
        tracking.setLocation(rs.getString("Location"));
        tracking.setNotes(rs.getString("Notes"));
        
        int updatedBy = rs.getInt("UpdatedBy");
        if (!rs.wasNull()) {
            tracking.setUpdatedBy(updatedBy);
            
            // Set shipper info if available
            try {
                String shipperName = rs.getString("ShipperName");
                if (shipperName != null) {
                    Employee shipper = new Employee();
                    shipper.setEmployeeID(updatedBy);
                    shipper.setFullName(shipperName);
                    tracking.setShipper(shipper);
                }
            } catch (SQLException ignored) {}
        }
        
        tracking.setCreatedAt(rs.getTimestamp("CreatedAt"));
        return tracking;
    }
}
