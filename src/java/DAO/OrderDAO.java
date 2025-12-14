package DAO;

import entity.*;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO extends DBContext {

    // ==================== LẤY ĐƠN HÀNG ====================
    
    /**
     * Lấy đơn hàng theo ID (bao gồm details, history, customer, address)
     */
    public Order getOrderById(int orderId) {
        String sql = "SELECT o.*, c.FullName as CustomerName, c.Email as CustomerEmail, c.Phone as CustomerPhone, " +
                     "e.FullName as SellerName, e.Email as SellerEmail " +
                     "FROM Orders o " +
                     "LEFT JOIN Customers c ON o.CustomerID = c.CustomerID " +
                     "LEFT JOIN Employees e ON o.AssignedTo = e.EmployeeID " +
                     "WHERE o.OrderID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Order order = mapResultSetToOrder(rs);
                
                // Load customer
                Customer customer = new Customer();
                customer.setCustomerID(rs.getInt("CustomerID"));
                customer.setFullName(rs.getString("CustomerName"));
                customer.setEmail(rs.getString("CustomerEmail"));
                customer.setPhone(rs.getString("CustomerPhone"));
                order.setCustomer(customer);
                
                // Load assigned seller
                if (order.getAssignedTo() != null) {
                    Employee seller = new Employee();
                    seller.setEmployeeID(order.getAssignedTo());
                    seller.setFullName(rs.getString("SellerName"));
                    seller.setEmail(rs.getString("SellerEmail"));
                    order.setAssignedSeller(seller);
                }
                
                // Load address
                if (order.getAddressID() != null) {
                    order.setAddress(getAddressById(order.getAddressID()));
                }
                
                // Load order details
                order.setOrderDetails(getOrderDetailsByOrderId(orderId));
                
                // Load status history
                order.setStatusHistory(getStatusHistoryByOrderId(orderId));
                
                // Load shipping info
                order.setShipping(getShippingByOrderId(orderId));
                
                return order;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Lấy đơn hàng theo OrderCode
     */
    public Order getOrderByCode(String orderCode) {
        String sql = "SELECT OrderID FROM Orders WHERE OrderCode = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, orderCode);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return getOrderById(rs.getInt("OrderID"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ==================== DANH SÁCH VỚI FILTER ====================
    
    /**
     * Lấy danh sách với filter, search, sort, paging
     */
    public List<Order> getOrders(OrderFilter filter, int page, int pageSize) {
        List<Order> orders = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT o.*, c.FullName as CustomerName, c.Email as CustomerEmail, c.Phone as CustomerPhone, ");
        sql.append("e.FullName as SellerName ");
        sql.append("FROM Orders o ");
        sql.append("LEFT JOIN Customers c ON o.CustomerID = c.CustomerID ");
        sql.append("LEFT JOIN Employees e ON o.AssignedTo = e.EmployeeID ");
        sql.append("WHERE 1=1 ");
        
        // Build WHERE clause
        sql.append(buildWhereClause(filter));
        
        // Sort
        sql.append(" ORDER BY ");
        if (filter.getSortBy() != null) {
            switch (filter.getSortBy()) {
                case "totalAmount":
                    sql.append("o.TotalAmount");
                    break;
                case "orderStatus":
                    sql.append("o.OrderStatus");
                    break;
                default:
                    sql.append("o.OrderDate");
            }
        } else {
            sql.append("o.OrderDate");
        }
        sql.append(" ").append("DESC".equalsIgnoreCase(filter.getSortOrder()) ? "DESC" : "ASC");
        
        // Paging
        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = setFilterParameters(ps, filter, 1);
            ps.setInt(paramIndex++, (page - 1) * pageSize);
            ps.setInt(paramIndex, pageSize);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Order order = mapResultSetToOrder(rs);
                
                // Load customer
                Customer customer = new Customer();
                customer.setCustomerID(rs.getInt("CustomerID"));
                customer.setFullName(rs.getString("CustomerName"));
                customer.setEmail(rs.getString("CustomerEmail"));
                customer.setPhone(rs.getString("CustomerPhone"));
                order.setCustomer(customer);
                
                // Load assigned seller
                if (order.getAssignedTo() != null) {
                    Employee seller = new Employee();
                    seller.setEmployeeID(order.getAssignedTo());
                    seller.setFullName(rs.getString("SellerName"));
                    order.setAssignedSeller(seller);
                }
                
                orders.add(order);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return orders;
    }
    
    /**
     * Đếm tổng số đơn (cho paging)
     */
    public int countOrders(OrderFilter filter) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM Orders o ");
        sql.append("LEFT JOIN Customers c ON o.CustomerID = c.CustomerID ");
        sql.append("WHERE 1=1 ");
        sql.append(buildWhereClause(filter));
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            setFilterParameters(ps, filter, 1);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    /**
     * Lấy đơn hàng theo Customer (cho trang customer)
     */
    public List<Order> getOrdersByCustomer(int customerId, int page, int pageSize) {
        OrderFilter filter = new OrderFilter();
        filter.setCustomerId(customerId);
        return getOrders(filter, page, pageSize);
    }
    
    public int countOrdersByCustomer(int customerId) {
        OrderFilter filter = new OrderFilter();
        filter.setCustomerId(customerId);
        return countOrders(filter);
    }
    
    /**
     * Lấy đơn hàng theo Seller được phân công
     */
    public List<Order> getOrdersBySeller(int sellerId, OrderFilter filter, int page, int pageSize) {
        if (filter == null) {
            filter = new OrderFilter();
        }
        filter.setAssignedTo(sellerId);
        return getOrders(filter, page, pageSize);
    }
    
    public int countOrdersBySeller(int sellerId, OrderFilter filter) {
        if (filter == null) {
            filter = new OrderFilter();
        }
        filter.setAssignedTo(sellerId);
        return countOrders(filter);
    }
    
    /**
     * Lấy đơn chưa phân công
     */
    public List<Order> getUnassignedOrders() {
        OrderFilter filter = new OrderFilter();
        filter.setUnassignedOnly(true);
        return getOrders(filter, 1, 1000);
    }
    
    public int countUnassignedOrders() {
        OrderFilter filter = new OrderFilter();
        filter.setUnassignedOnly(true);
        return countOrders(filter);
    }

    // ==================== CẬP NHẬT ====================
    
    /**
     * Cập nhật trạng thái đơn hàng (tự động log history)
     */
    public boolean updateOrderStatus(int orderId, String newStatus, Integer changedById, String note) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            // Lấy status hiện tại
            String oldStatus = null;
            String getStatusSql = "SELECT OrderStatus FROM Orders WHERE OrderID = ?";
            try (PreparedStatement ps = conn.prepareStatement(getStatusSql)) {
                ps.setInt(1, orderId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    oldStatus = rs.getString("OrderStatus");
                }
            }
            
            // Cập nhật status
            String updateSql = "UPDATE Orders SET OrderStatus = ?, UpdatedDate = GETDATE()";
            if ("Cancelled".equals(newStatus) && note != null) {
                updateSql += ", CancelReason = ?";
            }
            updateSql += " WHERE OrderID = ?";
            
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                int idx = 1;
                ps.setString(idx++, newStatus);
                if ("Cancelled".equals(newStatus) && note != null) {
                    ps.setString(idx++, note);
                }
                ps.setInt(idx, orderId);
                ps.executeUpdate();
            }
            
            // Log history
            String historySql = "INSERT INTO OrderStatusHistory (OrderID, OldStatus, NewStatus, Notes, ChangedBy, ChangedDate) " +
                               "VALUES (?, ?, ?, ?, ?, GETDATE())";
            try (PreparedStatement ps = conn.prepareStatement(historySql)) {
                ps.setInt(1, orderId);
                ps.setString(2, oldStatus);
                ps.setString(3, newStatus);
                ps.setString(4, note);
                if (changedById != null) {
                    ps.setInt(5, changedById);
                } else {
                    ps.setNull(5, Types.INTEGER);
                }
                ps.executeUpdate();
            }
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    /**
     * Phân đơn cho Seller
     */
    public boolean assignOrderToSeller(int orderId, int sellerId, int assignedById) {
        // Thử với cột AssignedBy và AssignedDate trước
        String sql = "UPDATE Orders SET AssignedTo = ?, UpdatedDate = GETDATE() WHERE OrderID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, sellerId);
            ps.setInt(2, orderId);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Chuyển đơn sang Seller khác
     */
    public boolean reassignOrder(int orderId, int newSellerId, int assignedById) {
        return assignOrderToSeller(orderId, newSellerId, assignedById);
    }
    
    /**
     * Cập nhật ghi chú nội bộ
     */
    public boolean updateInternalNote(int orderId, String note) {
        String sql = "UPDATE Orders SET Notes = ?, UpdatedDate = GETDATE() WHERE OrderID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, note);
            ps.setInt(2, orderId);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ==================== THỐNG KÊ CHO PHÂN ĐƠN ====================
    
    /**
     * Đếm đơn đang xử lý của seller (Pending, Confirmed, Processing)
     */
    public int countActiveOrdersBySeller(int sellerId) {
        String sql = "SELECT COUNT(*) FROM Orders WHERE AssignedTo = ? " +
                     "AND OrderStatus IN ('Pending', 'Confirmed', 'Processing', 'Shipping')";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, sellerId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    /**
     * Lấy seller có ít đơn active nhất
     */
    public Employee getSellerWithLeastActiveOrders() {
        String sql = "SELECT TOP 1 e.EmployeeID, e.FullName, e.Email, " +
                     "ISNULL((SELECT COUNT(*) FROM Orders o WHERE o.AssignedTo = e.EmployeeID " +
                     "AND o.OrderStatus IN ('Pending', 'Confirmed', 'Processing', 'Shipping')), 0) as ActiveOrders " +
                     "FROM Employees e WHERE e.Role = 'Seller' AND e.IsActive = 1 " +
                     "ORDER BY ActiveOrders ASC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Employee seller = new Employee();
                seller.setEmployeeID(rs.getInt("EmployeeID"));
                seller.setFullName(rs.getString("FullName"));
                seller.setEmail(rs.getString("Email"));
                return seller;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Lấy danh sách seller với số đơn active
     */
    public List<Employee> getSellersWithOrderCount() {
        List<Employee> sellers = new ArrayList<>();
        String sql = "SELECT e.EmployeeID, e.FullName, e.Email, e.Phone, " +
                     "ISNULL((SELECT COUNT(*) FROM Orders o WHERE o.AssignedTo = e.EmployeeID " +
                     "AND o.OrderStatus IN ('Pending', 'Confirmed', 'Processing', 'Shipping')), 0) as ActiveOrders " +
                     "FROM Employees e WHERE e.Role = 'Seller' AND e.IsActive = 1 " +
                     "ORDER BY ActiveOrders ASC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Employee seller = new Employee();
                seller.setEmployeeID(rs.getInt("EmployeeID"));
                seller.setFullName(rs.getString("FullName"));
                seller.setEmail(rs.getString("Email"));
                seller.setPhone(rs.getString("Phone"));
                // Store active orders count in a custom way - we'll use a wrapper or attribute
                sellers.add(seller);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return sellers;
    }
    
    /**
     * Lấy danh sách seller với số đơn active (trả về Object array)
     */
    public List<Object[]> getSellersWithActiveOrderCount() {
        List<Object[]> result = new ArrayList<>();
        String sql = "SELECT e.EmployeeID, e.FullName, e.Email, e.Phone, " +
                     "ISNULL((SELECT COUNT(*) FROM Orders o WHERE o.AssignedTo = e.EmployeeID " +
                     "AND o.OrderStatus IN ('Pending', 'Confirmed', 'Processing', 'Shipping')), 0) as ActiveOrders " +
                     "FROM Employees e WHERE e.Role = 'Seller' AND e.IsActive = 1 " +
                     "ORDER BY ActiveOrders ASC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Object[] row = new Object[5];
                row[0] = rs.getInt("EmployeeID");
                row[1] = rs.getString("FullName");
                row[2] = rs.getString("Email");
                row[3] = rs.getString("Phone");
                row[4] = rs.getInt("ActiveOrders");
                result.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    // ==================== SHIPPING ====================
    
    /**
     * Cập nhật thông tin shipping
     */
    public boolean updateShippingInfo(int orderId, String trackingCode, String goshipOrderCode) {
        // Check if shipping record exists
        String checkSql = "SELECT ShippingID FROM Shipping WHERE OrderID = ?";
        String insertSql = "INSERT INTO Shipping (OrderID, TrackingCode, GoshipOrderCode) VALUES (?, ?, ?)";
        String updateSql = "UPDATE Shipping SET TrackingCode = ?, GoshipOrderCode = ? WHERE OrderID = ?";
        
        try (Connection conn = getConnection()) {
            boolean exists = false;
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, orderId);
                exists = ps.executeQuery().next();
            }
            
            String sql = exists ? updateSql : insertSql;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                if (exists) {
                    ps.setString(1, trackingCode);
                    ps.setString(2, goshipOrderCode);
                    ps.setInt(3, orderId);
                } else {
                    ps.setInt(1, orderId);
                    ps.setString(2, trackingCode);
                    ps.setString(3, goshipOrderCode);
                }
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ==================== HELPER METHODS ====================
    
    private Order mapResultSetToOrder(ResultSet rs) throws SQLException {
        Order order = new Order();
        order.setOrderID(rs.getInt("OrderID"));
        order.setOrderCode(rs.getString("OrderCode"));
        order.setCustomerID(rs.getInt("CustomerID"));
        
        int addressId = rs.getInt("AddressID");
        order.setAddressID(rs.wasNull() ? null : addressId);
        
        order.setSubtotalAmount(rs.getBigDecimal("SubtotalAmount"));
        order.setDiscountAmount(rs.getBigDecimal("DiscountAmount"));
        order.setVoucherDiscount(rs.getBigDecimal("VoucherDiscount"));
        order.setShippingFee(rs.getBigDecimal("ShippingFee"));
        order.setTotalAmount(rs.getBigDecimal("TotalAmount"));
        order.setTotalCost(rs.getBigDecimal("TotalCost"));
        order.setTotalProfit(rs.getBigDecimal("TotalProfit"));
        
        int voucherId = rs.getInt("VoucherID");
        order.setVoucherID(rs.wasNull() ? null : voucherId);
        
        order.setPaymentMethod(rs.getString("PaymentMethod"));
        order.setPaymentStatus(rs.getString("PaymentStatus"));
        order.setPaymentToken(rs.getString("PaymentToken"));
        order.setPaymentExpiry(rs.getTimestamp("PaymentExpiry"));
        
        order.setOrderStatus(rs.getString("OrderStatus"));
        
        int assignedTo = rs.getInt("AssignedTo");
        order.setAssignedTo(rs.wasNull() ? null : assignedTo);
        
        // AssignedBy và AssignedDate có thể chưa tồn tại trong DB
        try {
            int assignedBy = rs.getInt("AssignedBy");
            order.setAssignedBy(rs.wasNull() ? null : assignedBy);
        } catch (SQLException e) {
            // Column không tồn tại, bỏ qua
        }
        
        try {
            order.setAssignedDate(rs.getTimestamp("AssignedDate"));
        } catch (SQLException e) {
            // Column không tồn tại, bỏ qua
        }
        
        order.setNotes(rs.getString("Notes"));
        order.setCancelReason(rs.getString("CancelReason"));
        order.setOrderDate(rs.getTimestamp("OrderDate"));
        order.setUpdatedDate(rs.getTimestamp("UpdatedDate"));
        
        return order;
    }
    
    private String buildWhereClause(OrderFilter filter) {
        StringBuilder where = new StringBuilder();
        
        if (filter.getSearchKeyword() != null && !filter.getSearchKeyword().trim().isEmpty()) {
            where.append(" AND (o.OrderCode LIKE ? OR c.FullName LIKE ? OR c.Phone LIKE ?)");
        }
        
        if (filter.getOrderStatus() != null && !filter.getOrderStatus().trim().isEmpty()) {
            where.append(" AND o.OrderStatus = ?");
        }
        
        if (filter.getPaymentStatus() != null && !filter.getPaymentStatus().trim().isEmpty()) {
            where.append(" AND o.PaymentStatus = ?");
        }
        
        if (filter.getPaymentMethod() != null && !filter.getPaymentMethod().trim().isEmpty()) {
            where.append(" AND o.PaymentMethod = ?");
        }
        
        if (filter.getCustomerId() != null) {
            where.append(" AND o.CustomerID = ?");
        }
        
        if (filter.getAssignedTo() != null) {
            where.append(" AND o.AssignedTo = ?");
        }
        
        if (Boolean.TRUE.equals(filter.getUnassignedOnly())) {
            where.append(" AND o.AssignedTo IS NULL");
        }
        
        if (filter.getFromDate() != null) {
            where.append(" AND o.OrderDate >= ?");
        }
        
        if (filter.getToDate() != null) {
            where.append(" AND o.OrderDate <= ?");
        }
        
        return where.toString();
    }
    
    private int setFilterParameters(PreparedStatement ps, OrderFilter filter, int startIndex) throws SQLException {
        int idx = startIndex;
        
        if (filter.getSearchKeyword() != null && !filter.getSearchKeyword().trim().isEmpty()) {
            String keyword = "%" + filter.getSearchKeyword().trim() + "%";
            ps.setString(idx++, keyword);
            ps.setString(idx++, keyword);
            ps.setString(idx++, keyword);
        }
        
        if (filter.getOrderStatus() != null && !filter.getOrderStatus().trim().isEmpty()) {
            ps.setString(idx++, filter.getOrderStatus());
        }
        
        if (filter.getPaymentStatus() != null && !filter.getPaymentStatus().trim().isEmpty()) {
            ps.setString(idx++, filter.getPaymentStatus());
        }
        
        if (filter.getPaymentMethod() != null && !filter.getPaymentMethod().trim().isEmpty()) {
            ps.setString(idx++, filter.getPaymentMethod());
        }
        
        if (filter.getCustomerId() != null) {
            ps.setInt(idx++, filter.getCustomerId());
        }
        
        if (filter.getAssignedTo() != null) {
            ps.setInt(idx++, filter.getAssignedTo());
        }
        
        if (filter.getFromDate() != null) {
            ps.setTimestamp(idx++, new Timestamp(filter.getFromDate().getTime()));
        }
        
        if (filter.getToDate() != null) {
            ps.setTimestamp(idx++, new Timestamp(filter.getToDate().getTime()));
        }
        
        return idx;
    }
    
    private CustomerAddress getAddressById(int addressId) {
        String sql = "SELECT * FROM CustomerAddresses WHERE AddressID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, addressId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                CustomerAddress address = new CustomerAddress();
                address.setAddressID(rs.getInt("AddressID"));
                address.setCustomerID(rs.getInt("CustomerID"));
                address.setRecipientName(rs.getString("RecipientName"));
                address.setPhone(rs.getString("Phone"));
                address.setStreet(rs.getString("Street"));
                address.setWard(rs.getString("Ward"));
                address.setDistrict(rs.getString("District"));
                address.setCity(rs.getString("City"));
                address.setDefault(rs.getBoolean("IsDefault"));
                return address;
            }
        } catch (SQLException e) {
            // Bảng có thể chưa tồn tại, trả về null
            System.out.println("CustomerAddresses table may not exist: " + e.getMessage());
        }
        return null;
    }
    
    private List<OrderDetail> getOrderDetailsByOrderId(int orderId) {
        List<OrderDetail> details = new ArrayList<>();
        String sql = "SELECT od.*, " +
                     "(SELECT TOP 1 pi.ImageURL FROM ProductImages pi WHERE pi.ProductID = p.ProductID AND pi.IsPrimary = 1) as ProductImage " +
                     "FROM OrderDetails od " +
                     "LEFT JOIN ProductVariants pv ON od.VariantID = pv.VariantID " +
                     "LEFT JOIN Products p ON pv.ProductID = p.ProductID " +
                     "WHERE od.OrderID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                OrderDetail detail = new OrderDetail();
                detail.setOrderDetailID(rs.getInt("OrderDetailID"));
                detail.setOrderID(rs.getInt("OrderID"));
                detail.setVariantID(rs.getInt("VariantID"));
                detail.setProductName(rs.getString("ProductName"));
                detail.setSku(rs.getString("SKU"));
                detail.setQuantity(rs.getInt("Quantity"));
                detail.setCostPrice(rs.getBigDecimal("CostPrice"));
                detail.setUnitPrice(rs.getBigDecimal("UnitPrice"));
                detail.setDiscountAmount(rs.getBigDecimal("DiscountAmount"));
                detail.setFinalPrice(rs.getBigDecimal("FinalPrice"));
                detail.setReviewed(rs.getBoolean("IsReviewed"));
                detail.setProductImage(rs.getString("ProductImage"));
                details.add(detail);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return details;
    }
    
    private List<OrderStatusHistory> getStatusHistoryByOrderId(int orderId) {
        List<OrderStatusHistory> history = new ArrayList<>();
        String sql = "SELECT h.*, e.FullName as ChangedByName FROM OrderStatusHistory h " +
                     "LEFT JOIN Employees e ON h.ChangedBy = e.EmployeeID " +
                     "WHERE h.OrderID = ? ORDER BY h.ChangedDate DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                OrderStatusHistory h = new OrderStatusHistory();
                h.setHistoryID(rs.getInt("HistoryID"));
                h.setOrderID(rs.getInt("OrderID"));
                h.setOldStatus(rs.getString("OldStatus"));
                h.setNewStatus(rs.getString("NewStatus"));
                h.setNotes(rs.getString("Notes"));
                
                int changedBy = rs.getInt("ChangedBy");
                h.setChangedBy(rs.wasNull() ? null : changedBy);
                
                h.setChangedDate(rs.getTimestamp("ChangedDate"));
                
                if (h.getChangedBy() != null) {
                    Employee emp = new Employee();
                    emp.setEmployeeID(h.getChangedBy());
                    emp.setFullName(rs.getString("ChangedByName"));
                    h.setChangedByEmployee(emp);
                }
                
                history.add(h);
            }
        } catch (SQLException e) {
            // Bảng có thể chưa tồn tại, trả về list rỗng
            System.out.println("OrderStatusHistory table may not exist: " + e.getMessage());
        }
        return history;
    }
    
    private Shipping getShippingByOrderId(int orderId) {
        String sql = "SELECT * FROM Shipping WHERE OrderID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Shipping shipping = new Shipping();
                shipping.setShippingID(rs.getInt("ShippingID"));
                shipping.setOrderID(rs.getInt("OrderID"));
                
                int carrierId = rs.getInt("CarrierID");
                shipping.setCarrierID(rs.wasNull() ? null : carrierId);
                
                int rateId = rs.getInt("RateID");
                shipping.setRateID(rs.wasNull() ? null : rateId);
                
                shipping.setTrackingCode(rs.getString("TrackingCode"));
                shipping.setShippingFee(rs.getBigDecimal("ShippingFee"));
                shipping.setEstimatedDelivery(rs.getString("EstimatedDelivery"));
                shipping.setShippedDate(rs.getTimestamp("ShippedDate"));
                shipping.setDeliveredDate(rs.getTimestamp("DeliveredDate"));
                shipping.setGoshipOrderCode(rs.getString("GoshipOrderCode"));
                shipping.setGoshipStatus(rs.getString("GoshipStatus"));
                return shipping;
            }
        } catch (SQLException e) {
            // Bảng có thể chưa tồn tại, trả về null
            System.out.println("Shipping table may not exist: " + e.getMessage());
        }
        return null;
    }
    
    // ==================== TẠO ĐƠN HÀNG (CHO CHECKOUT) ====================
    
    /**
     * Tạo mã đơn hàng unique
     */
    public String generateOrderCode() {
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyyMMdd");
        String dateStr = sdf.format(new java.util.Date());
        String prefix = "ORD-" + dateStr + "-";
        
        String sql = "SELECT TOP 1 OrderCode FROM Orders WHERE OrderCode LIKE ? ORDER BY OrderID DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, prefix + "%");
            ResultSet rs = ps.executeQuery();
            
            int nextNum = 1;
            if (rs.next()) {
                String lastCode = rs.getString("OrderCode");
                String numPart = lastCode.substring(lastCode.lastIndexOf("-") + 1);
                try {
                    nextNum = Integer.parseInt(numPart) + 1;
                } catch (NumberFormatException e) {
                    nextNum = 1;
                }
            }
            return prefix + String.format("%03d", nextNum);
        } catch (SQLException e) {
            e.printStackTrace();
            // Fallback: dùng timestamp
            return "ORD-" + System.currentTimeMillis();
        }
    }
    
    /**
     * Tạo đơn hàng mới với chi tiết
     */
    public int createOrder(Order order, List<OrderDetail> orderDetails) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            // Insert Order
            String orderSql = "INSERT INTO Orders (OrderCode, CustomerID, AddressID, SubtotalAmount, DiscountAmount, " +
                             "VoucherDiscount, ShippingFee, TotalAmount, TotalCost, TotalProfit, VoucherID, " +
                             "PaymentMethod, PaymentStatus, OrderStatus, Notes, OrderDate, UpdatedDate) " +
                             "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";
            
            int orderID = -1;
            try (PreparedStatement ps = conn.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, order.getOrderCode());
                ps.setInt(2, order.getCustomerID());
                if (order.getAddressID() != null) {
                    ps.setInt(3, order.getAddressID());
                } else {
                    ps.setNull(3, Types.INTEGER);
                }
                ps.setBigDecimal(4, order.getSubtotalAmount());
                ps.setBigDecimal(5, order.getDiscountAmount());
                ps.setBigDecimal(6, order.getVoucherDiscount());
                ps.setBigDecimal(7, order.getShippingFee());
                ps.setBigDecimal(8, order.getTotalAmount());
                ps.setBigDecimal(9, order.getTotalCost());
                ps.setBigDecimal(10, order.getTotalProfit());
                if (order.getVoucherID() != null) {
                    ps.setInt(11, order.getVoucherID());
                } else {
                    ps.setNull(11, Types.INTEGER);
                }
                ps.setString(12, order.getPaymentMethod());
                ps.setString(13, order.getPaymentStatus());
                ps.setString(14, order.getOrderStatus());
                ps.setString(15, order.getNotes());
                
                int affectedRows = ps.executeUpdate();
                if (affectedRows > 0) {
                    ResultSet rs = ps.getGeneratedKeys();
                    if (rs.next()) {
                        orderID = rs.getInt(1);
                    }
                }
            }
            
            if (orderID <= 0) {
                conn.rollback();
                return -1;
            }
            
            // Insert OrderDetails
            String detailSql = "INSERT INTO OrderDetails (OrderID, VariantID, ProductName, SKU, Quantity, " +
                              "CostPrice, UnitPrice, DiscountAmount, FinalPrice, IsReviewed) " +
                              "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0)";
            
            try (PreparedStatement ps = conn.prepareStatement(detailSql)) {
                for (OrderDetail detail : orderDetails) {
                    ps.setInt(1, orderID);
                    ps.setInt(2, detail.getVariantID());
                    ps.setString(3, detail.getProductName());
                    ps.setString(4, detail.getSku());
                    ps.setInt(5, detail.getQuantity());
                    ps.setBigDecimal(6, detail.getCostPrice());
                    ps.setBigDecimal(7, detail.getUnitPrice());
                    ps.setBigDecimal(8, detail.getDiscountAmount() != null ? detail.getDiscountAmount() : java.math.BigDecimal.ZERO);
                    ps.setBigDecimal(9, detail.getFinalPrice());
                    ps.addBatch();
                }
                ps.executeBatch();
            }
            
            // Insert initial status history
            String historySql = "INSERT INTO OrderStatusHistory (OrderID, OldStatus, NewStatus, Notes, ChangedDate) " +
                               "VALUES (?, NULL, 'Pending', N'Đơn hàng mới được tạo', GETDATE())";
            try (PreparedStatement ps = conn.prepareStatement(historySql)) {
                ps.setInt(1, orderID);
                ps.executeUpdate();
            } catch (SQLException e) {
                // Bảng có thể chưa tồn tại, bỏ qua
                System.out.println("OrderStatusHistory insert skipped: " + e.getMessage());
            }
            
            conn.commit();
            return orderID;
            
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            return -1;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    /**
     * Cập nhật payment status của đơn hàng
     */
    public boolean updatePaymentStatus(int orderId, String paymentStatus) {
        String sql = "UPDATE Orders SET PaymentStatus = ?, UpdatedDate = GETDATE() WHERE OrderID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, paymentStatus);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Cập nhật payment status với transaction ID (cho VNPay callback)
     */
    public boolean updatePaymentStatus(int orderId, String paymentStatus, String transactionId) {
        String sql = "UPDATE Orders SET PaymentStatus = ?, PaymentToken = ?, UpdatedDate = GETDATE() WHERE OrderID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, paymentStatus);
            ps.setString(2, transactionId);
            ps.setInt(3, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Cập nhật trạng thái đơn hàng (không cần log history - dùng cho VNPay callback)
     */
    public boolean updateOrderStatus(int orderId, String newStatus) {
        String sql = "UPDATE Orders SET OrderStatus = ?, UpdatedDate = GETDATE() WHERE OrderID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, newStatus);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Cập nhật payment token (cho VNPay)
     */
    public boolean updatePaymentToken(int orderId, String paymentToken, java.sql.Timestamp expiry) {
        String sql = "UPDATE Orders SET PaymentToken = ?, PaymentExpiry = ?, UpdatedDate = GETDATE() WHERE OrderID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, paymentToken);
            ps.setTimestamp(2, expiry);
            ps.setInt(3, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Lấy đơn hàng theo CustomerID với paging (không cần filter)
     */
    public List<Order> getOrdersByCustomerId(int customerId, int page, int pageSize) {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT o.*, c.FullName as CustomerName, c.Email as CustomerEmail, c.Phone as CustomerPhone " +
                     "FROM Orders o " +
                     "LEFT JOIN Customers c ON o.CustomerID = c.CustomerID " +
                     "WHERE o.CustomerID = ? " +
                     "ORDER BY o.OrderDate DESC " +
                     "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, customerId);
            ps.setInt(2, (page - 1) * pageSize);
            ps.setInt(3, pageSize);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Order order = mapResultSetToOrder(rs);
                
                Customer customer = new Customer();
                customer.setCustomerID(rs.getInt("CustomerID"));
                customer.setFullName(rs.getString("CustomerName"));
                customer.setEmail(rs.getString("CustomerEmail"));
                customer.setPhone(rs.getString("CustomerPhone"));
                order.setCustomer(customer);
                
                // Load order details for display
                order.setOrderDetails(getOrderDetailsByOrderId(order.getOrderID()));
                
                orders.add(order);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return orders;
    }
    
    /**
     * Đếm số đơn hàng của customer
     */
    public int countOrdersByCustomerId(int customerId) {
        String sql = "SELECT COUNT(*) FROM Orders WHERE CustomerID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    /**
     * Lấy đơn hàng theo Goship order code (dùng cho webhook)
     */
    public Order getOrderByGoshipCode(String goshipOrderCode) {
        String sql = "SELECT o.OrderID FROM Orders o " +
                     "INNER JOIN Shipping s ON o.OrderID = s.OrderID " +
                     "WHERE s.GoshipOrderCode = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, goshipOrderCode);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return getOrderById(rs.getInt("OrderID"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Cập nhật Goship info cho shipping của order
     */
    public boolean updateOrderGoshipInfo(int orderId, String goshipOrderCode, String trackingCode) {
        String sql = "UPDATE Shipping SET GoshipOrderCode = ?, TrackingCode = ?, ShippedDate = GETDATE() " +
                     "WHERE OrderID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, goshipOrderCode);
            ps.setString(2, trackingCode);
            ps.setInt(3, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
