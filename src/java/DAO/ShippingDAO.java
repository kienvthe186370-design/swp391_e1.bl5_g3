package DAO;

import entity.Shipping;
import entity.ShippingCarrier;
import entity.ShippingRate;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ShippingDAO extends DBContext {

    /**
     * Lấy tất cả carriers đang active
     */
    public List<ShippingCarrier> getActiveCarriers() {
        List<ShippingCarrier> carriers = new ArrayList<>();
        String sql = "SELECT * FROM ShippingCarriers WHERE IsActive = 1";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                ShippingCarrier carrier = new ShippingCarrier();
                carrier.setCarrierID(rs.getInt("CarrierID"));
                carrier.setCarrierName(rs.getString("CarrierName"));
                carrier.setActive(rs.getBoolean("IsActive"));
                carriers.add(carrier);
            }
        } catch (SQLException e) {
            Logger.getLogger(ShippingDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return carriers;
    }

    /**
     * Lấy tất cả shipping rates đang active
     */
    public List<ShippingRate> getActiveShippingRates() {
        List<ShippingRate> rates = new ArrayList<>();
        String sql = "SELECT r.*, c.CarrierName FROM ShippingRates r " +
                     "INNER JOIN ShippingCarriers c ON r.CarrierID = c.CarrierID " +
                     "WHERE r.IsActive = 1 AND c.IsActive = 1 ORDER BY r.BasePrice ASC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                ShippingRate rate = new ShippingRate();
                rate.setRateID(rs.getInt("RateID"));
                rate.setCarrierID(rs.getInt("CarrierID"));
                rate.setServiceName(rs.getString("ServiceName"));
                rate.setBasePrice(rs.getBigDecimal("BasePrice"));
                rate.setEstimatedDelivery(rs.getString("EstimatedDelivery"));
                rate.setActive(rs.getBoolean("IsActive"));
                
                ShippingCarrier carrier = new ShippingCarrier();
                carrier.setCarrierID(rs.getInt("CarrierID"));
                carrier.setCarrierName(rs.getString("CarrierName"));
                rate.setCarrier(carrier);
                
                rates.add(rate);
            }
        } catch (SQLException e) {
            Logger.getLogger(ShippingDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return rates;
    }

    /**
     * Lấy shipping rate theo ID
     */
    public ShippingRate getShippingRateById(int rateID) {
        String sql = "SELECT r.*, c.CarrierName FROM ShippingRates r " +
                     "INNER JOIN ShippingCarriers c ON r.CarrierID = c.CarrierID " +
                     "WHERE r.RateID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, rateID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                ShippingRate rate = new ShippingRate();
                rate.setRateID(rs.getInt("RateID"));
                rate.setCarrierID(rs.getInt("CarrierID"));
                rate.setServiceName(rs.getString("ServiceName"));
                rate.setBasePrice(rs.getBigDecimal("BasePrice"));
                rate.setEstimatedDelivery(rs.getString("EstimatedDelivery"));
                rate.setActive(rs.getBoolean("IsActive"));
                
                ShippingCarrier carrier = new ShippingCarrier();
                carrier.setCarrierID(rs.getInt("CarrierID"));
                carrier.setCarrierName(rs.getString("CarrierName"));
                rate.setCarrier(carrier);
                
                return rate;
            }
        } catch (SQLException e) {
            Logger.getLogger(ShippingDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return null;
    }

    /**
     * Tạo bản ghi shipping cho order
     */
    public int createShipping(Shipping shipping) {
        String sql = "INSERT INTO Shipping (OrderID, CarrierID, RateID, TrackingCode, ShippingFee, EstimatedDelivery, GoshipCarrierId, CarrierName) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, shipping.getOrderID());
            if (shipping.getCarrierID() != null) {
                ps.setInt(2, shipping.getCarrierID());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            if (shipping.getRateID() != null) {
                ps.setInt(3, shipping.getRateID());
            } else {
                ps.setNull(3, Types.INTEGER);
            }
            ps.setString(4, shipping.getTrackingCode());
            ps.setBigDecimal(5, shipping.getShippingFee());
            ps.setString(6, shipping.getEstimatedDelivery());
            ps.setString(7, shipping.getGoshipCarrierId());
            ps.setString(8, shipping.getCarrierName());
            
            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            Logger.getLogger(ShippingDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return -1;
    }

    /**
     * Lấy shipping info theo OrderID
     */
    public Shipping getShippingByOrderId(int orderID) {
        String sql = "SELECT s.*, c.CarrierName, r.ServiceName as RateServiceName " +
                     "FROM Shipping s " +
                     "LEFT JOIN ShippingCarriers c ON s.CarrierID = c.CarrierID " +
                     "LEFT JOIN ShippingRates r ON s.RateID = r.RateID " +
                     "WHERE s.OrderID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, orderID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Shipping shipping = new Shipping();
                shipping.setShippingID(rs.getInt("ShippingID"));
                shipping.setOrderID(rs.getInt("OrderID"));
                
                int carrierID = rs.getInt("CarrierID");
                shipping.setCarrierID(rs.wasNull() ? null : carrierID);
                
                int rateID = rs.getInt("RateID");
                shipping.setRateID(rs.wasNull() ? null : rateID);
                
                shipping.setTrackingCode(rs.getString("TrackingCode"));
                shipping.setShippingFee(rs.getBigDecimal("ShippingFee"));
                shipping.setEstimatedDelivery(rs.getString("EstimatedDelivery"));
                shipping.setShippedDate(rs.getTimestamp("ShippedDate"));
                shipping.setDeliveredDate(rs.getTimestamp("DeliveredDate"));
                
                // Goship fields
                shipping.setGoshipOrderCode(rs.getString("GoshipOrderCode"));
                shipping.setGoshipStatus(rs.getString("GoshipStatus"));
                shipping.setGoshipCarrierId(rs.getString("GoshipCarrierId"));
                shipping.setCarrierName(rs.getString("CarrierName"));
                
                if (shipping.getCarrierID() != null) {
                    ShippingCarrier carrier = new ShippingCarrier();
                    carrier.setCarrierID(shipping.getCarrierID());
                    carrier.setCarrierName(rs.getString("CarrierName"));
                    shipping.setCarrier(carrier);
                }
                
                return shipping;
            }
        } catch (SQLException e) {
            Logger.getLogger(ShippingDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return null;
    }

    /**
     * Cập nhật tracking code
     */
    public boolean updateTrackingCode(int shippingID, String trackingCode) {
        String sql = "UPDATE Shipping SET TrackingCode = ?, ShippedDate = GETDATE() WHERE ShippingID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, trackingCode);
            ps.setInt(2, shippingID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            Logger.getLogger(ShippingDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return false;
    }
    
    /**
     * Cập nhật Goship order code và tracking
     */
    public boolean updateGoshipInfo(int shippingID, String goshipOrderCode, String trackingCode) {
        String sql = "UPDATE Shipping SET GoshipOrderCode = ?, TrackingCode = ?, ShippedDate = GETDATE() WHERE ShippingID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, goshipOrderCode);
            ps.setString(2, trackingCode);
            ps.setInt(3, shippingID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            Logger.getLogger(ShippingDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return false;
    }
    
    /**
     * Cập nhật Goship status
     */
    public boolean updateGoshipStatus(int shippingID, String goshipStatus) {
        String sql = "UPDATE Shipping SET GoshipStatus = ? WHERE ShippingID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, goshipStatus);
            ps.setInt(2, shippingID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            Logger.getLogger(ShippingDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return false;
    }
    
    /**
     * Cập nhật ngày giao hàng
     */
    public boolean updateDeliveredDate(int shippingID) {
        String sql = "UPDATE Shipping SET DeliveredDate = GETDATE() WHERE ShippingID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, shippingID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            Logger.getLogger(ShippingDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return false;
    }
    
    /**
     * Lấy shipping theo Goship order code
     */
    public Shipping getShippingByGoshipCode(String goshipOrderCode) {
        String sql = "SELECT s.*, c.CarrierName FROM Shipping s " +
                     "LEFT JOIN ShippingCarriers c ON s.CarrierID = c.CarrierID " +
                     "WHERE s.GoshipOrderCode = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, goshipOrderCode);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Shipping shipping = new Shipping();
                shipping.setShippingID(rs.getInt("ShippingID"));
                shipping.setOrderID(rs.getInt("OrderID"));
                shipping.setTrackingCode(rs.getString("TrackingCode"));
                shipping.setShippingFee(rs.getBigDecimal("ShippingFee"));
                shipping.setGoshipOrderCode(rs.getString("GoshipOrderCode"));
                shipping.setGoshipStatus(rs.getString("GoshipStatus"));
                shipping.setShippedDate(rs.getTimestamp("ShippedDate"));
                shipping.setDeliveredDate(rs.getTimestamp("DeliveredDate"));
                return shipping;
            }
        } catch (SQLException e) {
            Logger.getLogger(ShippingDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return null;
    }
}
