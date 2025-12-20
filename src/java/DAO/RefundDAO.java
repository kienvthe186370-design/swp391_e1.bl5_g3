package DAO;

import entity.*;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho quản lý yêu cầu hoàn tiền
 */
public class RefundDAO extends DBContext {

    // ==================== TẠO YÊU CẦU HOÀN TIỀN ====================
    
    /**
     * Tạo yêu cầu hoàn tiền mới
     */
    public int createRefundRequest(RefundRequest request) {
        String sql = "INSERT INTO RefundRequests (OrderID, CustomerID, RefundReason, RefundStatus, " +
                     "RefundAmount, RequestDate) VALUES (?, ?, ?, 'Pending', ?, GETDATE())";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, request.getOrderID());
            ps.setInt(2, request.getCustomerID());
            ps.setString(3, request.getRefundReason());
            ps.setBigDecimal(4, request.getRefundAmount());
            
            int affected = ps.executeUpdate();
            if (affected > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }
    
    /**
     * Thêm item vào yêu cầu hoàn tiền
     */
    public boolean addRefundItem(RefundItem item) {
        String sql = "INSERT INTO RefundItems (RefundRequestID, OrderDetailID, Quantity, ItemReason) " +
                     "VALUES (?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, item.getRefundRequestID());
            ps.setInt(2, item.getOrderDetailID());
            ps.setInt(3, item.getQuantity());
            ps.setString(4, item.getItemReason());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Thêm media (hình ảnh) vào yêu cầu hoàn tiền
     */
    public boolean addRefundMedia(RefundMedia media) {
        String sql = "INSERT INTO RefundMedia (RefundRequestID, MediaURL, MediaType) VALUES (?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, media.getRefundRequestID());
            ps.setString(2, media.getMediaURL());
            ps.setString(3, media.getMediaType());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ==================== LẤY YÊU CẦU HOÀN TIỀN ====================
    
    /**
     * Lấy yêu cầu hoàn tiền theo ID (đầy đủ thông tin)
     */
    public RefundRequest getRefundRequestById(int refundRequestId) {
        String sql = "SELECT r.*, o.OrderCode, c.FullName as CustomerName, c.Email as CustomerEmail, " +
                     "e.FullName as ProcessorName " +
                     "FROM RefundRequests r " +
                     "LEFT JOIN Orders o ON r.OrderID = o.OrderID " +
                     "LEFT JOIN Customers c ON r.CustomerID = c.CustomerID " +
                     "LEFT JOIN Employees e ON r.ProcessedBy = e.EmployeeID " +
                     "WHERE r.RefundRequestID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, refundRequestId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                RefundRequest request = mapResultSetToRefundRequest(rs);
                
                // Load customer
                Customer customer = new Customer();
                customer.setCustomerID(rs.getInt("CustomerID"));
                customer.setFullName(rs.getString("CustomerName"));
                customer.setEmail(rs.getString("CustomerEmail"));
                request.setCustomer(customer);
                
                // Load order info
                Order order = new Order();
                order.setOrderID(rs.getInt("OrderID"));
                order.setOrderCode(rs.getString("OrderCode"));
                request.setOrder(order);
                
                // Load processor
                if (request.getProcessedBy() != null) {
                    Employee processor = new Employee();
                    processor.setEmployeeID(request.getProcessedBy());
                    processor.setFullName(rs.getString("ProcessorName"));
                    request.setProcessor(processor);
                }
                
                // Load items và media
                request.setRefundItems(getRefundItemsByRequestId(refundRequestId));
                request.setRefundMedia(getRefundMediaByRequestId(refundRequestId));
                
                return request;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Lấy danh sách yêu cầu hoàn tiền theo Customer
     */
    public List<RefundRequest> getRefundRequestsByCustomer(int customerId) {
        List<RefundRequest> requests = new ArrayList<>();
        String sql = "SELECT r.*, o.OrderCode FROM RefundRequests r " +
                     "LEFT JOIN Orders o ON r.OrderID = o.OrderID " +
                     "WHERE r.CustomerID = ? ORDER BY r.RequestDate DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                RefundRequest request = mapResultSetToRefundRequest(rs);
                Order order = new Order();
                order.setOrderID(rs.getInt("OrderID"));
                order.setOrderCode(rs.getString("OrderCode"));
                request.setOrder(order);
                requests.add(request);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return requests;
    }
    
    /**
     * Lấy danh sách yêu cầu hoàn tiền theo Order
     */
    public RefundRequest getRefundRequestByOrderId(int orderId) {
        String sql = "SELECT * FROM RefundRequests WHERE OrderID = ? ORDER BY RequestDate DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToRefundRequest(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Lấy tất cả yêu cầu hoàn tiền (cho Admin)
     */
    public List<RefundRequest> getAllRefundRequests(String status, int page, int pageSize) {
        List<RefundRequest> requests = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT r.*, o.OrderCode, c.FullName as CustomerName, c.Email as CustomerEmail ");
        sql.append("FROM RefundRequests r ");
        sql.append("LEFT JOIN Orders o ON r.OrderID = o.OrderID ");
        sql.append("LEFT JOIN Customers c ON r.CustomerID = c.CustomerID ");
        sql.append("WHERE 1=1 ");
        
        if (status != null && !status.isEmpty()) {
            sql.append("AND r.RefundStatus = ? ");
        }
        
        sql.append("ORDER BY r.RequestDate DESC ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int idx = 1;
            if (status != null && !status.isEmpty()) {
                ps.setString(idx++, status);
            }
            ps.setInt(idx++, (page - 1) * pageSize);
            ps.setInt(idx, pageSize);
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                RefundRequest request = mapResultSetToRefundRequest(rs);
                
                Customer customer = new Customer();
                customer.setCustomerID(rs.getInt("CustomerID"));
                customer.setFullName(rs.getString("CustomerName"));
                customer.setEmail(rs.getString("CustomerEmail"));
                request.setCustomer(customer);
                
                Order order = new Order();
                order.setOrderID(rs.getInt("OrderID"));
                order.setOrderCode(rs.getString("OrderCode"));
                request.setOrder(order);
                
                requests.add(request);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return requests;
    }
    
    /**
     * Đếm tổng số yêu cầu hoàn tiền
     */
    public int countRefundRequests(String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM RefundRequests WHERE 1=1 ");
        if (status != null && !status.isEmpty()) {
            sql.append("AND RefundStatus = ?");
        }
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            if (status != null && !status.isEmpty()) {
                ps.setString(1, status);
            }
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ==================== CẬP NHẬT TRẠNG THÁI ====================
    
    /**
     * Duyệt yêu cầu hoàn tiền
     */
    public boolean approveRefundRequest(int refundRequestId, int processedBy, String adminNotes) {
        String sql = "UPDATE RefundRequests SET RefundStatus = 'Approved', ProcessedBy = ?, " +
                     "ProcessedDate = GETDATE(), AdminNotes = ? WHERE RefundRequestID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, processedBy);
            ps.setString(2, adminNotes);
            ps.setInt(3, refundRequestId);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Từ chối yêu cầu hoàn tiền
     */
    public boolean rejectRefundRequest(int refundRequestId, int processedBy, String adminNotes) {
        String sql = "UPDATE RefundRequests SET RefundStatus = 'Rejected', ProcessedBy = ?, " +
                     "ProcessedDate = GETDATE(), AdminNotes = ? WHERE RefundRequestID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, processedBy);
            ps.setString(2, adminNotes);
            ps.setInt(3, refundRequestId);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Cập nhật trạng thái hoàn tiền đã hoàn thành
     * Chỉ có thể complete khi trạng thái hiện tại là Approved
     * Khi hoàn tiền thành công: tăng Stock và giảm ReservedStock
     */
    public boolean completeRefund(int refundRequestId) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            // 1. Update RefundRequest status
            String updateStatusSql = "UPDATE RefundRequests SET RefundStatus = 'Completed', " +
                         "ProcessedDate = GETDATE() WHERE RefundRequestID = ? AND RefundStatus = 'Approved'";
            
            try (PreparedStatement ps = conn.prepareStatement(updateStatusSql)) {
                ps.setInt(1, refundRequestId);
                int updated = ps.executeUpdate();
                if (updated == 0) {
                    conn.rollback();
                    System.out.println("[RefundDAO] completeRefund - RefundID: " + refundRequestId + " - Status not Approved or not found");
                    return false;
                }
            }
            
            // 2. Hoàn lại Stock và giảm ReservedStock cho các sản phẩm trong RefundItems
            // Join RefundItems -> OrderDetails để lấy VariantID
            String restoreStockSql = "UPDATE pv SET " +
                         "pv.Stock = pv.Stock + ri.Quantity, " +
                         "pv.ReservedStock = CASE WHEN pv.ReservedStock >= ri.Quantity THEN pv.ReservedStock - ri.Quantity ELSE 0 END " +
                         "FROM ProductVariants pv " +
                         "INNER JOIN OrderDetails od ON pv.VariantID = od.VariantID " +
                         "INNER JOIN RefundItems ri ON od.OrderDetailID = ri.OrderDetailID " +
                         "WHERE ri.RefundRequestID = ?";
            
            try (PreparedStatement ps = conn.prepareStatement(restoreStockSql)) {
                ps.setInt(1, refundRequestId);
                int stockUpdated = ps.executeUpdate();
                System.out.println("[RefundDAO] completeRefund - RefundID: " + refundRequestId + 
                                   ", Stock restored for " + stockUpdated + " variants");
            }
            
            conn.commit();
            System.out.println("[RefundDAO] completeRefund - RefundID: " + refundRequestId + " - SUCCESS");
            return true;
            
        } catch (SQLException e) {
            System.out.println("[RefundDAO] completeRefund ERROR: " + e.getMessage());
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        return false;
    }

    // ==================== HELPER METHODS ====================
    
    private RefundRequest mapResultSetToRefundRequest(ResultSet rs) throws SQLException {
        RefundRequest request = new RefundRequest();
        request.setRefundRequestID(rs.getInt("RefundRequestID"));
        request.setOrderID(rs.getInt("OrderID"));
        request.setCustomerID(rs.getInt("CustomerID"));
        request.setRefundReason(rs.getString("RefundReason"));
        request.setRefundStatus(rs.getString("RefundStatus"));
        request.setRefundAmount(rs.getBigDecimal("RefundAmount"));
        request.setAdminNotes(rs.getString("AdminNotes"));
        request.setRequestDate(rs.getTimestamp("RequestDate"));
        
        int processedBy = rs.getInt("ProcessedBy");
        request.setProcessedBy(rs.wasNull() ? null : processedBy);
        
        request.setProcessedDate(rs.getTimestamp("ProcessedDate"));
        return request;
    }
    
    private List<RefundItem> getRefundItemsByRequestId(int refundRequestId) {
        List<RefundItem> items = new ArrayList<>();
        String sql = "SELECT ri.*, od.ProductName, od.SKU, od.UnitPrice, " +
                     "(SELECT TOP 1 pi.ImageURL FROM ProductImages pi " +
                     " JOIN ProductVariants pv ON pi.ProductID = pv.ProductID " +
                     " WHERE pv.VariantID = od.VariantID) as ProductImage " +
                     "FROM RefundItems ri " +
                     "LEFT JOIN OrderDetails od ON ri.OrderDetailID = od.OrderDetailID " +
                     "WHERE ri.RefundRequestID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, refundRequestId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                RefundItem item = new RefundItem();
                item.setRefundItemID(rs.getInt("RefundItemID"));
                item.setRefundRequestID(rs.getInt("RefundRequestID"));
                item.setOrderDetailID(rs.getInt("OrderDetailID"));
                item.setQuantity(rs.getInt("Quantity"));
                item.setItemReason(rs.getString("ItemReason"));
                
                // Load order detail info
                OrderDetail od = new OrderDetail();
                od.setOrderDetailID(rs.getInt("OrderDetailID"));
                od.setProductName(rs.getString("ProductName"));
                od.setSku(rs.getString("SKU"));
                od.setUnitPrice(rs.getBigDecimal("UnitPrice"));
                od.setProductImage(rs.getString("ProductImage"));
                item.setOrderDetail(od);
                
                items.add(item);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return items;
    }
    
    private List<RefundMedia> getRefundMediaByRequestId(int refundRequestId) {
        List<RefundMedia> mediaList = new ArrayList<>();
        String sql = "SELECT * FROM RefundMedia WHERE RefundRequestID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, refundRequestId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                RefundMedia media = new RefundMedia();
                media.setMediaID(rs.getInt("MediaID"));
                media.setRefundRequestID(rs.getInt("RefundRequestID"));
                media.setMediaURL(rs.getString("MediaURL"));
                media.setMediaType(rs.getString("MediaType"));
                mediaList.add(media);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return mediaList;
    }
    
    /**
     * Kiểm tra đơn hàng đã có yêu cầu hoàn tiền chưa
     */
    public boolean hasRefundRequest(int orderId) {
        String sql = "SELECT COUNT(*) FROM RefundRequests WHERE OrderID = ? AND RefundStatus != 'Rejected'";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy danh sách yêu cầu hoàn tiền theo Seller được assign
     */
    public List<RefundRequest> getRefundRequestsBySeller(int sellerId, String status, int page, int pageSize) {
        List<RefundRequest> requests = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT r.*, o.OrderCode, c.FullName as CustomerName, c.Email as CustomerEmail ");
        sql.append("FROM RefundRequests r ");
        sql.append("INNER JOIN Orders o ON r.OrderID = o.OrderID ");
        sql.append("LEFT JOIN Customers c ON r.CustomerID = c.CustomerID ");
        sql.append("WHERE o.AssignedTo = ? ");
        
        if (status != null && !status.isEmpty()) {
            sql.append("AND r.RefundStatus = ? ");
        }
        
        sql.append("ORDER BY r.RequestDate DESC ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int idx = 1;
            ps.setInt(idx++, sellerId);
            if (status != null && !status.isEmpty()) {
                ps.setString(idx++, status);
            }
            ps.setInt(idx++, (page - 1) * pageSize);
            ps.setInt(idx, pageSize);
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                RefundRequest request = mapResultSetToRefundRequest(rs);
                
                Customer customer = new Customer();
                customer.setCustomerID(rs.getInt("CustomerID"));
                customer.setFullName(rs.getString("CustomerName"));
                customer.setEmail(rs.getString("CustomerEmail"));
                request.setCustomer(customer);
                
                Order order = new Order();
                order.setOrderID(rs.getInt("OrderID"));
                order.setOrderCode(rs.getString("OrderCode"));
                request.setOrder(order);
                
                requests.add(request);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return requests;
    }
    
    /**
     * Đếm số yêu cầu hoàn tiền theo Seller
     */
    public int countRefundRequestsBySeller(int sellerId, String status) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM RefundRequests r ");
        sql.append("INNER JOIN Orders o ON r.OrderID = o.OrderID ");
        sql.append("WHERE o.AssignedTo = ? ");
        
        if (status != null && !status.isEmpty()) {
            sql.append("AND r.RefundStatus = ?");
        }
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int idx = 1;
            ps.setInt(idx++, sellerId);
            if (status != null && !status.isEmpty()) {
                ps.setString(idx, status);
            }
            
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
     * Kiểm tra Seller có quyền xử lý refund request này không
     */
    public boolean canSellerProcessRefund(int sellerId, int refundRequestId) {
        String sql = "SELECT COUNT(*) FROM RefundRequests r " +
                     "INNER JOIN Orders o ON r.OrderID = o.OrderID " +
                     "WHERE r.RefundRequestID = ? AND o.AssignedTo = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, refundRequestId);
            ps.setInt(2, sellerId);
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}