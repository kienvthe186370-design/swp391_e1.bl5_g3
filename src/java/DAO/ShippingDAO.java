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

    // ==================== SHIPPER MANAGEMENT ====================
    
    /**
     * Phân công shipper cho đơn hàng
     */
    public boolean assignShipper(int shippingID, int shipperID, String trackingCode) {
        String sql = "UPDATE Shipping SET ShipperID = ?, TrackingCode = ?, ShippedDate = GETDATE() WHERE ShippingID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, shipperID);
            ps.setString(2, trackingCode);
            ps.setInt(3, shippingID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            Logger.getLogger(ShippingDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return false;
    }
    
    /**
     * Lấy danh sách đơn hàng theo ShipperID
     */
    public List<Shipping> getShippingsByShipperId(int shipperID) {
        List<Shipping> list = new ArrayList<>();
        String sql = "SELECT s.*, o.OrderCode, o.OrderStatus, o.TotalAmount, o.PaymentMethod, o.PaymentStatus, " +
                     "ca.RecipientName, ca.Phone, ca.Street, ca.Ward, ca.District, ca.City " +
                     "FROM Shipping s " +
                     "INNER JOIN Orders o ON s.OrderID = o.OrderID " +
                     "LEFT JOIN CustomerAddresses ca ON o.AddressID = ca.AddressID " +
                     "WHERE s.ShipperID = ? AND o.OrderStatus = 'Shipping' " +
                     "ORDER BY s.ShippedDate DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, shipperID);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Shipping shipping = mapShippingWithOrder(rs);
                list.add(shipping);
            }
        } catch (SQLException e) {
            Logger.getLogger(ShippingDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return list;
    }
    
    /**
     * Lấy danh sách đơn chưa phân shipper
     */
    public List<Shipping> getUnassignedShippings() {
        List<Shipping> list = new ArrayList<>();
        String sql = "SELECT s.*, o.OrderCode, o.OrderStatus, o.TotalAmount, o.PaymentMethod, o.PaymentStatus, " +
                     "ca.RecipientName, ca.Phone, ca.Street, ca.Ward, ca.District, ca.City " +
                     "FROM Shipping s " +
                     "INNER JOIN Orders o ON s.OrderID = o.OrderID " +
                     "LEFT JOIN CustomerAddresses ca ON o.AddressID = ca.AddressID " +
                     "WHERE s.ShipperID IS NULL AND o.OrderStatus = 'Shipping' " +
                     "ORDER BY o.OrderDate ASC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Shipping shipping = mapShippingWithOrder(rs);
                list.add(shipping);
            }
        } catch (SQLException e) {
            Logger.getLogger(ShippingDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return list;
    }
    
    /**
     * Lấy danh sách đơn đã phân shipper (đang vận chuyển)
     */
    public List<Shipping> getAssignedShippings() {
        List<Shipping> list = new ArrayList<>();
        String sql = "SELECT s.*, o.OrderCode, o.OrderStatus, o.TotalAmount, o.PaymentMethod, o.PaymentStatus, " +
                     "ca.RecipientName, ca.Phone, ca.Street, ca.Ward, ca.District, ca.City, " +
                     "e.FullName as ShipperName " +
                     "FROM Shipping s " +
                     "INNER JOIN Orders o ON s.OrderID = o.OrderID " +
                     "LEFT JOIN CustomerAddresses ca ON o.AddressID = ca.AddressID " +
                     "LEFT JOIN Employees e ON s.ShipperID = e.EmployeeID " +
                     "WHERE s.ShipperID IS NOT NULL AND o.OrderStatus = 'Shipping' " +
                     "ORDER BY o.OrderDate DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Shipping shipping = mapShippingWithOrder(rs);
                // Thêm tên shipper
                shipping.setShipperName(rs.getString("ShipperName"));
                list.add(shipping);
            }
        } catch (SQLException e) {
            Logger.getLogger(ShippingDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return list;
    }
    
    /**
     * Cập nhật shipper cho đơn hàng (thay đổi phân công)
     */
    public boolean updateShipperAssignment(int shippingId, int newShipperId) {
        String sql = "UPDATE Shipping SET ShipperID = ? WHERE ShippingID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, newShipperId);
            ps.setInt(2, shippingId);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            Logger.getLogger(ShippingDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return false;
    }
    
    /**
     * Đếm số đơn đang giao của shipper
     */
    public int countActiveOrdersByShipper(int shipperID) {
        String sql = "SELECT COUNT(*) FROM Shipping s " +
                     "INNER JOIN Orders o ON s.OrderID = o.OrderID " +
                     "WHERE s.ShipperID = ? AND o.OrderStatus = 'Shipping'";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, shipperID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            Logger.getLogger(ShippingDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return 0;
    }
    
    /**
     * Đếm số đơn đã giao hôm nay của shipper
     */
    public int countDeliveredTodayByShipper(int shipperID) {
        String sql = "SELECT COUNT(*) FROM Shipping s " +
                     "INNER JOIN Orders o ON s.OrderID = o.OrderID " +
                     "WHERE s.ShipperID = ? AND o.OrderStatus = 'Delivered' " +
                     "AND CAST(s.DeliveredDate AS DATE) = CAST(GETDATE() AS DATE)";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, shipperID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            Logger.getLogger(ShippingDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return 0;
    }
    
    /**
     * Lấy shipping với thông tin shipper
     */
    public Shipping getShippingWithShipper(int shippingID) {
        String sql = "SELECT s.*, e.FullName as ShipperName, e.Phone as ShipperPhone " +
                     "FROM Shipping s " +
                     "LEFT JOIN Employees e ON s.ShipperID = e.EmployeeID " +
                     "WHERE s.ShippingID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, shippingID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Shipping shipping = new Shipping();
                shipping.setShippingID(rs.getInt("ShippingID"));
                shipping.setOrderID(rs.getInt("OrderID"));
                shipping.setTrackingCode(rs.getString("TrackingCode"));
                shipping.setShippingFee(rs.getBigDecimal("ShippingFee"));
                shipping.setShippedDate(rs.getTimestamp("ShippedDate"));
                shipping.setDeliveredDate(rs.getTimestamp("DeliveredDate"));
                shipping.setGoshipStatus(rs.getString("GoshipStatus"));
                
                int shipperID = rs.getInt("ShipperID");
                if (!rs.wasNull()) {
                    shipping.setShipperID(shipperID);
                    entity.Employee shipper = new entity.Employee();
                    shipper.setEmployeeID(shipperID);
                    shipper.setFullName(rs.getString("ShipperName"));
                    shipper.setPhone(rs.getString("ShipperPhone"));
                    shipping.setShipper(shipper);
                }
                
                return shipping;
            }
        } catch (SQLException e) {
            Logger.getLogger(ShippingDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return null;
    }
    
    /**
     * Helper: Map ResultSet to Shipping with Order info
     */
    private Shipping mapShippingWithOrder(ResultSet rs) throws SQLException {
        Shipping shipping = new Shipping();
        shipping.setShippingID(rs.getInt("ShippingID"));
        shipping.setOrderID(rs.getInt("OrderID"));
        shipping.setTrackingCode(rs.getString("TrackingCode"));
        shipping.setShippingFee(rs.getBigDecimal("ShippingFee"));
        shipping.setShippedDate(rs.getTimestamp("ShippedDate"));
        shipping.setDeliveredDate(rs.getTimestamp("DeliveredDate"));
        shipping.setGoshipStatus(rs.getString("GoshipStatus"));
        shipping.setCarrierName(rs.getString("CarrierName"));
        
        int shipperID = rs.getInt("ShipperID");
        if (!rs.wasNull()) {
            shipping.setShipperID(shipperID);
        }
        
        // Set order info directly on shipping for display
        shipping.setOrderCode(rs.getString("OrderCode"));
        shipping.setOrderStatus(rs.getString("OrderStatus"));
        shipping.setTotalAmount(rs.getBigDecimal("TotalAmount"));
        shipping.setPaymentMethod(rs.getString("PaymentMethod"));
        shipping.setPaymentStatus(rs.getString("PaymentStatus"));
        
        // Address info
        entity.CustomerAddress address = new entity.CustomerAddress();
        address.setRecipientName(rs.getString("RecipientName"));
        address.setPhone(rs.getString("Phone"));
        address.setStreet(rs.getString("Street"));
        address.setWard(rs.getString("Ward"));
        address.setDistrict(rs.getString("District"));
        address.setCity(rs.getString("City"));
        shipping.setAddress(address);
        
        return shipping;
    }
    
    // ==================== SHIPPER MONITORING ====================
    
    /**
     * Lấy danh sách shipper với thống kê chi tiết
     * Returns: [EmployeeID, FullName, Phone, ActiveOrders, DeliveredTotal]
     */
    public List<Object[]> getShippersWithStats() {
        List<Object[]> result = new ArrayList<>();
        String sql = "SELECT e.EmployeeID, e.FullName, e.Phone, " +
                     "ISNULL((SELECT COUNT(*) FROM Shipping s INNER JOIN Orders o ON s.OrderID = o.OrderID " +
                     "        WHERE s.ShipperID = e.EmployeeID AND o.OrderStatus = 'Shipping'), 0) as ActiveOrders, " +
                     "ISNULL((SELECT COUNT(*) FROM Shipping s INNER JOIN Orders o ON s.OrderID = o.OrderID " +
                     "        WHERE s.ShipperID = e.EmployeeID AND o.OrderStatus = 'Delivered'), 0) as DeliveredTotal " +
                     "FROM Employees e WHERE e.Role = 'Shipper' AND e.IsActive = 1 " +
                     "ORDER BY ActiveOrders DESC, DeliveredTotal DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Object[] row = new Object[5];
                row[0] = rs.getInt("EmployeeID");
                row[1] = rs.getString("FullName");
                row[2] = rs.getString("Phone");
                row[3] = rs.getInt("ActiveOrders");
                row[4] = rs.getInt("DeliveredTotal");
                result.add(row);
            }
        } catch (SQLException e) {
            Logger.getLogger(ShippingDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return result;
    }
    
    /**
     * Lấy đơn hàng của shipper với filter
     */
    public List<Shipping> getShipperOrdersFiltered(int shipperId, String tab, int page, int pageSize) {
        List<Shipping> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT s.*, o.OrderCode, o.OrderStatus, o.TotalAmount, o.PaymentMethod, o.PaymentStatus, ");
        sql.append("ca.RecipientName, ca.Phone, ca.Street, ca.Ward, ca.District, ca.City ");
        sql.append("FROM Shipping s ");
        sql.append("INNER JOIN Orders o ON s.OrderID = o.OrderID ");
        sql.append("LEFT JOIN CustomerAddresses ca ON o.AddressID = ca.AddressID ");
        sql.append("WHERE s.ShipperID = ? ");
        
        // Tab filter
        if ("active".equals(tab)) {
            sql.append("AND o.OrderStatus = 'Shipping' ");
        } else if ("delivered".equals(tab)) {
            sql.append("AND o.OrderStatus = 'Delivered' ");
        }
        // "all" không filter
        
        sql.append("ORDER BY o.OrderDate DESC ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            ps.setInt(1, shipperId);
            ps.setInt(2, (page - 1) * pageSize);
            ps.setInt(3, pageSize);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapShippingWithOrder(rs));
            }
        } catch (SQLException e) {
            Logger.getLogger(ShippingDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return list;
    }
    
    /**
     * Đếm đơn hàng của shipper theo tab
     */
    public int countShipperOrdersFiltered(int shipperId, String tab) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM Shipping s ");
        sql.append("INNER JOIN Orders o ON s.OrderID = o.OrderID ");
        sql.append("WHERE s.ShipperID = ? ");
        
        if ("active".equals(tab)) {
            sql.append("AND o.OrderStatus = 'Shipping' ");
        } else if ("delivered".equals(tab)) {
            sql.append("AND o.OrderStatus = 'Delivered' ");
        }
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            ps.setInt(1, shipperId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            Logger.getLogger(ShippingDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return 0;
    }
    
    /**
     * Đếm tổng số shipper
     */
    public int countTotalShippers() {
        String sql = "SELECT COUNT(*) FROM Employees WHERE Role = 'Shipper' AND IsActive = 1";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            Logger.getLogger(ShippingDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return 0;
    }
    
    /**
     * Đếm shipper đang có đơn giao
     */
    public int countActiveShippers() {
        String sql = "SELECT COUNT(DISTINCT s.ShipperID) FROM Shipping s " +
                     "INNER JOIN Orders o ON s.OrderID = o.OrderID " +
                     "WHERE o.OrderStatus = 'Shipping'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            Logger.getLogger(ShippingDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return 0;
    }
    
    /**
     * Đếm tổng đơn đang vận chuyển
     */
    public int countTotalShippingOrders() {
        String sql = "SELECT COUNT(*) FROM Shipping s " +
                     "INNER JOIN Orders o ON s.OrderID = o.OrderID " +
                     "WHERE o.OrderStatus = 'Shipping'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            Logger.getLogger(ShippingDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return 0;
    }
}
