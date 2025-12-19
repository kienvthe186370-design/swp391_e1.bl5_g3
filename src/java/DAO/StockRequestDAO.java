package DAO;

import entity.StockRequest;
import entity.StockRequestItem;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * StockRequestDAO - Data Access Object for Stock Request operations
 */
public class StockRequestDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(StockRequestDAO.class.getName());
    private String lastError = null;
    
    public String getLastError() { return lastError; }

    // ==================== GENERATE CODE ====================
    
    private String generateRequestCode(Connection conn) throws SQLException {
        String date = new java.text.SimpleDateFormat("yyyyMMdd").format(new java.util.Date());
        String sql = "SELECT ISNULL(MAX(CAST(RIGHT(RequestCode, 3) AS INT)), 0) + 1 " +
                    "FROM StockRequests WHERE RequestCode LIKE 'SR" + date + "%'";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                int seq = rs.getInt(1);
                return "SR" + date + String.format("%03d", seq);
            }
        }
        return "SR" + date + "001";
    }

    // ==================== CREATE ====================
    
    /**
     * Tạo yêu cầu nhập kho mới
     * @return StockRequestID nếu thành công, -1 nếu thất bại
     */
    public int createStockRequest(StockRequest request, List<StockRequestItem> items) {
        lastError = null;
        Connection conn = null;
        try {
            conn = getConnection();
            if (conn == null) {
                lastError = "Database connection failed";
                return -1;
            }
            conn.setAutoCommit(false);
            
            // Check if RFQ already has a stock request
            if (hasStockRequestForRFQ(request.getRfqID())) {
                lastError = "RFQ này đã có yêu cầu nhập kho";
                return -1;
            }
            
            // Generate code
            String requestCode = generateRequestCode(conn);
            
            // Insert StockRequest
            String sql = "INSERT INTO StockRequests (RequestCode, RFQID, RequestedBy, Status, Notes, CreatedDate, UpdatedDate) " +
                        "VALUES (?, ?, ?, 'Pending', ?, GETDATE(), GETDATE())";
            
            int requestID;
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, requestCode);
                ps.setInt(2, request.getRfqID());
                ps.setInt(3, request.getRequestedBy());
                ps.setString(4, request.getNotes());
                
                ps.executeUpdate();
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    requestID = rs.getInt(1);
                } else {
                    throw new SQLException("Failed to get generated StockRequestID");
                }
            }
            
            // Insert items
            String itemSql = "INSERT INTO StockRequestItems (StockRequestID, ProductID, VariantID, ProductName, SKU, " +
                            "RequestedQuantity, OriginalRequestedQuantity, CurrentStock, RFQQuantity) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(itemSql)) {
                for (StockRequestItem item : items) {
                    ps.setInt(1, requestID);
                    ps.setInt(2, item.getProductID());
                    if (item.getVariantID() != null) {
                        ps.setInt(3, item.getVariantID());
                    } else {
                        ps.setNull(3, Types.INTEGER);
                    }
                    ps.setString(4, item.getProductName());
                    ps.setString(5, item.getSku());
                    ps.setInt(6, item.getRequestedQuantity());
                    ps.setInt(7, item.getRequestedQuantity()); // OriginalRequestedQuantity = RequestedQuantity lúc tạo
                    ps.setInt(8, item.getCurrentStock());
                    ps.setInt(9, item.getRfqQuantity());
                    ps.addBatch();
                }
                ps.executeBatch();
            }
            
            conn.commit();
            return requestID;
            
        } catch (SQLException e) {
            lastError = "SQL Error: " + e.getMessage();
            LOGGER.log(Level.SEVERE, "createStockRequest failed", e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return -1;
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { LOGGER.log(Level.WARNING, "Failed to close connection", e); }
            }
        }
    }

    // ==================== CHECK ====================
    
    /**
     * Kiểm tra RFQ đã có yêu cầu nhập kho chưa
     */
    public boolean hasStockRequestForRFQ(int rfqID) {
        String sql = "SELECT COUNT(*) FROM StockRequests WHERE RFQID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rfqID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "hasStockRequestForRFQ failed", e);
        }
        return false;
    }
    
    /**
     * Lấy StockRequest theo RFQID
     */
    public StockRequest getStockRequestByRFQID(int rfqID) {
        String sql = "SELECT sr.*, r.RFQCode, e1.FullName as RequestedByName, e2.FullName as CompletedByName " +
                    "FROM StockRequests sr " +
                    "LEFT JOIN RFQs r ON sr.RFQID = r.RFQID " +
                    "LEFT JOIN Employees e1 ON sr.RequestedBy = e1.EmployeeID " +
                    "LEFT JOIN Employees e2 ON sr.CompletedBy = e2.EmployeeID " +
                    "WHERE sr.RFQID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rfqID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                StockRequest sr = mapResultSetToStockRequest(rs);
                sr.setItems(getStockRequestItems(sr.getStockRequestID()));
                return sr;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "getStockRequestByRFQID failed", e);
        }
        return null;
    }

    // ==================== GET ====================
    
    /**
     * Lấy StockRequest theo ID
     */
    public StockRequest getStockRequestById(int requestID) {
        String sql = "SELECT sr.*, r.RFQCode, e1.FullName as RequestedByName, e2.FullName as CompletedByName " +
                    "FROM StockRequests sr " +
                    "LEFT JOIN RFQs r ON sr.RFQID = r.RFQID " +
                    "LEFT JOIN Employees e1 ON sr.RequestedBy = e1.EmployeeID " +
                    "LEFT JOIN Employees e2 ON sr.CompletedBy = e2.EmployeeID " +
                    "WHERE sr.StockRequestID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, requestID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                StockRequest sr = mapResultSetToStockRequest(rs);
                sr.setItems(getStockRequestItems(requestID));
                return sr;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "getStockRequestById failed", e);
        }
        return null;
    }
    
    /**
     * Lấy danh sách items của StockRequest
     */
    public List<StockRequestItem> getStockRequestItems(int requestID) {
        List<StockRequestItem> items = new ArrayList<>();
        String sql = "SELECT sri.*, " +
                    "(SELECT TOP 1 pi.ImageURL FROM ProductImages pi WHERE pi.ProductID = sri.ProductID " +
                    "ORDER BY pi.SortOrder) as ProductImage " +
                    "FROM StockRequestItems sri WHERE sri.StockRequestID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, requestID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                items.add(mapResultSetToItem(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "getStockRequestItems failed", e);
        }
        return items;
    }

    // ==================== SEARCH ====================
    
    /**
     * Tìm kiếm StockRequests với filters
     * @param requestedBy null = tất cả, có giá trị = chỉ của seller đó
     * @param status null = tất cả
     */
    public List<StockRequest> searchStockRequests(String keyword, String status, Integer requestedBy, 
                                                   int page, int pageSize) {
        List<StockRequest> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT sr.*, r.RFQCode, e1.FullName as RequestedByName, e2.FullName as CompletedByName ");
        sql.append("FROM StockRequests sr ");
        sql.append("LEFT JOIN RFQs r ON sr.RFQID = r.RFQID ");
        sql.append("LEFT JOIN Employees e1 ON sr.RequestedBy = e1.EmployeeID ");
        sql.append("LEFT JOIN Employees e2 ON sr.CompletedBy = e2.EmployeeID ");
        sql.append("WHERE 1=1 ");
        
        List<Object> params = new ArrayList<>();
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (sr.RequestCode LIKE ? OR r.RFQCode LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw);
        }
        if (status != null && !status.isEmpty()) {
            sql.append("AND sr.Status = ? ");
            params.add(status);
        }
        if (requestedBy != null) {
            sql.append("AND sr.RequestedBy = ? ");
            params.add(requestedBy);
        }
        
        sql.append("ORDER BY sr.CreatedDate DESC ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * pageSize);
        params.add(pageSize);
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToStockRequest(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "searchStockRequests failed", e);
        }
        return list;
    }
    
    /**
     * Đếm tổng số StockRequests theo filter
     */
    public int countStockRequests(String keyword, String status, Integer requestedBy) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM StockRequests sr ");
        sql.append("LEFT JOIN RFQs r ON sr.RFQID = r.RFQID ");
        sql.append("WHERE 1=1 ");
        
        List<Object> params = new ArrayList<>();
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (sr.RequestCode LIKE ? OR r.RFQCode LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw);
        }
        if (status != null && !status.isEmpty()) {
            sql.append("AND sr.Status = ? ");
            params.add(status);
        }
        if (requestedBy != null) {
            sql.append("AND sr.RequestedBy = ? ");
            params.add(requestedBy);
        }
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "countStockRequests failed", e);
        }
        return 0;
    }

    // ==================== STATISTICS ====================
    
    /**
     * Đếm số yêu cầu Pending (cho Admin badge)
     */
    public int countPendingRequests() {
        String sql = "SELECT COUNT(*) FROM StockRequests WHERE Status = 'Pending'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "countPendingRequests failed", e);
        }
        return 0;
    }
    
    /**
     * Đếm số yêu cầu Completed của Seller (cho Seller badge)
     * Chỉ đếm những yêu cầu completed trong 7 ngày gần đây
     */
    public int countCompletedRequestsBySeller(int sellerID) {
        String sql = "SELECT COUNT(*) FROM StockRequests " +
                    "WHERE RequestedBy = ? AND Status = 'Completed' " +
                    "AND CompletedDate >= DATEADD(day, -7, GETDATE())";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sellerID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "countCompletedRequestsBySeller failed", e);
        }
        return 0;
    }

    // ==================== APPROVE (ADMIN) ====================
    
    /**
     * Admin approve yêu cầu nhập kho với số lượng có thể chỉnh sửa
     * Tự động cập nhật Stock của các sản phẩm
     * Giá nhập sẽ lấy từ CostPrice của ProductVariants
     * @param approvedQuantities Map<StockRequestItemID, ApprovedQuantity> - số lượng admin duyệt cho từng item
     */
    public boolean approveStockRequest(int requestID, int adminID, String adminNotes, 
                                       java.util.Map<Integer, Integer> approvedQuantities) {
        lastError = null;
        Connection conn = null;
        try {
            conn = getConnection();
            if (conn == null) {
                lastError = "Database connection failed";
                return false;
            }
            conn.setAutoCommit(false);
            
            // Get request
            StockRequest request = getStockRequestById(requestID);
            if (request == null) {
                lastError = "Không tìm thấy yêu cầu";
                return false;
            }
            if (!request.isPending()) {
                lastError = "Yêu cầu đã được xử lý";
                return false;
            }
            
            // Update Stock for each item và lưu ApprovedQuantity
            String updateStockSql = "UPDATE ProductVariants SET Stock = Stock + ? WHERE VariantID = ?";
            String updateStockByProductSql = "UPDATE ProductVariants SET Stock = Stock + ? " +
                                             "WHERE ProductID = ? AND VariantID = (SELECT MIN(VariantID) FROM ProductVariants WHERE ProductID = ?)";
            String updateItemSql = "UPDATE StockRequestItems SET ApprovedQuantity = ? WHERE StockRequestItemID = ?";
            String insertReceiptSql = "INSERT INTO StockReceipts (VariantID, Quantity, UnitCost, ReceiptDate, CreatedBy) VALUES (?, ?, ?, GETDATE(), ?)";
            String getVariantIdSql = "SELECT MIN(VariantID) FROM ProductVariants WHERE ProductID = ?";
            String getCostPriceSql = "SELECT ISNULL(CostPrice, 1) FROM ProductVariants WHERE VariantID = ?";
            
            try (PreparedStatement ps1 = conn.prepareStatement(updateStockSql);
                 PreparedStatement ps2 = conn.prepareStatement(updateStockByProductSql);
                 PreparedStatement ps3 = conn.prepareStatement(updateItemSql);
                 PreparedStatement ps4 = conn.prepareStatement(insertReceiptSql);
                 PreparedStatement ps5 = conn.prepareStatement(getVariantIdSql);
                 PreparedStatement ps6 = conn.prepareStatement(getCostPriceSql)) {
                
                for (StockRequestItem item : request.getItems()) {
                    // Lấy số lượng admin duyệt (nếu không có thì dùng số lượng seller yêu cầu)
                    int quantityToImport = item.getRequestedQuantity();
                    if (approvedQuantities != null && approvedQuantities.containsKey(item.getStockRequestItemID())) {
                        quantityToImport = approvedQuantities.get(item.getStockRequestItemID());
                    }
                    
                    // Cập nhật ApprovedQuantity
                    ps3.setInt(1, quantityToImport);
                    ps3.setInt(2, item.getStockRequestItemID());
                    ps3.executeUpdate();
                    
                    // Xác định VariantID để cập nhật
                    Integer variantIdToUpdate = item.getVariantID();
                    
                    // Cập nhật Stock
                    if (variantIdToUpdate != null) {
                        ps1.setInt(1, quantityToImport);
                        ps1.setInt(2, variantIdToUpdate);
                        ps1.executeUpdate();
                    } else {
                        // Nếu không có VariantID, lấy variant đầu tiên của product
                        ps5.setInt(1, item.getProductID());
                        ResultSet rs = ps5.executeQuery();
                        if (rs.next()) {
                            variantIdToUpdate = rs.getInt(1);
                        }
                        
                        ps2.setInt(1, quantityToImport);
                        ps2.setInt(2, item.getProductID());
                        ps2.setInt(3, item.getProductID());
                        ps2.executeUpdate();
                    }
                    
                    // Lấy CostPrice từ ProductVariants
                    java.math.BigDecimal unitCost = java.math.BigDecimal.ONE;
                    if (variantIdToUpdate != null) {
                        ps6.setInt(1, variantIdToUpdate);
                        ResultSet rsPrice = ps6.executeQuery();
                        if (rsPrice.next()) {
                            unitCost = rsPrice.getBigDecimal(1);
                            if (unitCost == null || unitCost.compareTo(java.math.BigDecimal.ZERO) <= 0) {
                                unitCost = java.math.BigDecimal.ONE;
                            }
                        }
                    }
                    
                    // Ghi vào lịch sử nhập kho (StockReceipts) với giá vốn từ ProductVariants
                    if (variantIdToUpdate != null && quantityToImport > 0) {
                        ps4.setInt(1, variantIdToUpdate);
                        ps4.setInt(2, quantityToImport);
                        ps4.setBigDecimal(3, unitCost);
                        ps4.setInt(4, adminID);
                        ps4.executeUpdate();
                    }
                }
            }
            
            // Update StockRequest status
            String sql = "UPDATE StockRequests SET Status = 'Completed', CompletedBy = ?, " +
                        "AdminNotes = ?, CompletedDate = GETDATE(), UpdatedDate = GETDATE() " +
                        "WHERE StockRequestID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, adminID);
                ps.setString(2, adminNotes);
                ps.setInt(3, requestID);
                ps.executeUpdate();
            }
            
            conn.commit();
            return true;
            
        } catch (SQLException e) {
            lastError = "SQL Error: " + e.getMessage();
            LOGGER.log(Level.SEVERE, "approveStockRequest failed", e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { LOGGER.log(Level.WARNING, "Failed to close connection", e); }
            }
        }
    }
    
    /**
     * Admin approve yêu cầu nhập kho (backward compatible - dùng số lượng seller yêu cầu)
     */
    public boolean approveStockRequest(int requestID, int adminID, String adminNotes) {
        return approveStockRequest(requestID, adminID, adminNotes, null);
    }

    // ==================== HELPER METHODS ====================
    
    private StockRequest mapResultSetToStockRequest(ResultSet rs) throws SQLException {
        StockRequest sr = new StockRequest();
        sr.setStockRequestID(rs.getInt("StockRequestID"));
        sr.setRequestCode(rs.getString("RequestCode"));
        sr.setRfqID(rs.getInt("RFQID"));
        sr.setRequestedBy(rs.getInt("RequestedBy"));
        sr.setStatus(rs.getString("Status"));
        sr.setNotes(rs.getString("Notes"));
        sr.setAdminNotes(rs.getString("AdminNotes"));
        sr.setCompletedBy(rs.getObject("CompletedBy") != null ? rs.getInt("CompletedBy") : null);
        sr.setCompletedDate(rs.getTimestamp("CompletedDate"));
        sr.setCreatedDate(rs.getTimestamp("CreatedDate"));
        sr.setUpdatedDate(rs.getTimestamp("UpdatedDate"));
        
        // Related
        try { sr.setRfqCode(rs.getString("RFQCode")); } catch (SQLException e) {}
        try { sr.setRequestedByName(rs.getString("RequestedByName")); } catch (SQLException e) {}
        try { sr.setCompletedByName(rs.getString("CompletedByName")); } catch (SQLException e) {}
        
        return sr;
    }
    
    private StockRequestItem mapResultSetToItem(ResultSet rs) throws SQLException {
        StockRequestItem item = new StockRequestItem();
        item.setStockRequestItemID(rs.getInt("StockRequestItemID"));
        item.setStockRequestID(rs.getInt("StockRequestID"));
        item.setProductID(rs.getInt("ProductID"));
        item.setVariantID(rs.getObject("VariantID") != null ? rs.getInt("VariantID") : null);
        item.setProductName(rs.getString("ProductName"));
        item.setSku(rs.getString("SKU"));
        item.setRequestedQuantity(rs.getInt("RequestedQuantity"));
        item.setCurrentStock(rs.getInt("CurrentStock"));
        item.setRfqQuantity(rs.getInt("RFQQuantity"));
        try { item.setOriginalRequestedQuantity(rs.getInt("OriginalRequestedQuantity")); } catch (SQLException e) { 
            item.setOriginalRequestedQuantity(item.getRequestedQuantity()); 
        }
        try { 
            int approved = rs.getInt("ApprovedQuantity");
            item.setApprovedQuantity(rs.wasNull() ? null : approved); 
        } catch (SQLException e) {}
        try { item.setProductImage(rs.getString("ProductImage")); } catch (SQLException e) {}
        return item;
    }
}
