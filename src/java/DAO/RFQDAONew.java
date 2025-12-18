package DAO;

import entity.RFQ;
import entity.RFQItem;
import entity.RFQHistory;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * RFQDAO - Data Access Object for RFQ operations (NEW VERSION)
 * Đã tách Quotation sang QuotationDAO
 * 
 * Luồng mới:
 * 1. Customer tạo RFQ -> Auto-assign cho Seller có ít đơn nhất
 * 2. Seller xử lý RFQ (thương lượng ngày giao - max 3 lần)
 * 3. Tạo Quotation riêng (QuotationDAO)
 * 4. Thương lượng giá (max 3 lần)
 * 5. Thanh toán -> Tạo Order
 */
public class RFQDAONew extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(RFQDAONew.class.getName());
    private String lastError = null;
    
    public String getLastError() { return lastError; }

    // ==================== CREATE RFQ ====================
    
    /**
     * Generate RFQ Code: RFQyyyyMMdd0001
     */
    private String generateRFQCode(Connection conn) throws SQLException {
        String date = new java.text.SimpleDateFormat("yyyyMMdd").format(new java.util.Date());
        String sql = "SELECT ISNULL(MAX(CAST(RIGHT(RFQCode, 4) AS INT)), 0) + 1 " +
                    "FROM RFQs WHERE RFQCode LIKE 'RFQ" + date + "%'";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                int seq = rs.getInt(1);
                return "RFQ" + date + String.format("%04d", seq);
            }
        }
        return "RFQ" + date + "0001";
    }

    /**
     * Tạo RFQ mới với auto-assign cho Seller
     * @return RFQID nếu thành công, -1 nếu thất bại
     */
    public int createRFQ(RFQ rfq, List<RFQItem> items) {
        lastError = null;
        Connection conn = null;
        try {
            conn = getConnection();
            if (conn == null) {
                lastError = "Database connection failed";
                return -1;
            }
            conn.setAutoCommit(false);
            
            // 1. Generate RFQ Code
            String rfqCode = generateRFQCode(conn);
            
            // 2. Auto-assign to Seller with least RFQs
            Integer assignedTo = autoAssignSeller(conn);
            String initialStatus = (assignedTo != null) ? RFQ.STATUS_REVIEWING : RFQ.STATUS_PENDING;
            
            // 3. Insert RFQ
            // Cấu trúc DB: RFQs có đầy đủ các cột địa chỉ để hỗ trợ API Goship
            String sql = "INSERT INTO RFQs (RFQCode, CustomerID, CompanyName, TaxID, BusinessType, " +
                        "ContactPerson, ContactPhone, ContactEmail, AlternativeContact, " +
                        "DeliveryAddress, DeliveryStreet, DeliveryCity, DeliveryCityId, " +
                        "DeliveryDistrict, DeliveryDistrictId, DeliveryWard, DeliveryWardId, " +
                        "RequestedDeliveryDate, DeliveryInstructions, PaymentTermsPreference, " +
                        "Status, AssignedTo, CustomerNotes, DateNegotiationCount, MaxDateNegotiationCount, " +
                        "CreatedDate, UpdatedDate) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 3, GETDATE(), GETDATE())";
            
            int rfqID;
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                int idx = 1;
                ps.setString(idx++, rfqCode);
                ps.setInt(idx++, rfq.getCustomerID());
                ps.setString(idx++, rfq.getCompanyName());
                ps.setString(idx++, rfq.getTaxID());
                ps.setString(idx++, rfq.getBusinessType());
                ps.setString(idx++, rfq.getContactPerson());
                ps.setString(idx++, rfq.getContactPhone());
                ps.setString(idx++, rfq.getContactEmail());
                ps.setString(idx++, rfq.getAlternativeContact());
                ps.setString(idx++, rfq.getDeliveryAddress());
                ps.setString(idx++, rfq.getDeliveryStreet());
                ps.setString(idx++, rfq.getDeliveryCity());
                ps.setString(idx++, rfq.getDeliveryCityId());
                ps.setString(idx++, rfq.getDeliveryDistrict());
                ps.setString(idx++, rfq.getDeliveryDistrictId());
                ps.setString(idx++, rfq.getDeliveryWard());
                ps.setString(idx++, rfq.getDeliveryWardId());
                ps.setTimestamp(idx++, rfq.getRequestedDeliveryDate());
                ps.setString(idx++, rfq.getDeliveryInstructions());
                ps.setString(idx++, rfq.getPaymentTermsPreference());
                ps.setString(idx++, initialStatus);
                if (assignedTo != null) {
                    ps.setInt(idx++, assignedTo);
                } else {
                    ps.setNull(idx++, Types.INTEGER);
                }
                ps.setString(idx++, rfq.getCustomerNotes());
                
                ps.executeUpdate();
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    rfqID = rs.getInt(1);
                } else {
                    throw new SQLException("Failed to get generated RFQID");
                }
            }
            
            // 4. Insert RFQ Items
            String itemSql = "INSERT INTO RFQItems (RFQID, ProductID, VariantID, ProductName, SKU, " +
                            "Quantity, SpecialRequirements) VALUES (?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(itemSql)) {
                for (RFQItem item : items) {
                    ps.setInt(1, rfqID);
                    ps.setInt(2, item.getProductID());
                    if (item.getVariantID() != null) {
                        ps.setInt(3, item.getVariantID());
                    } else {
                        ps.setNull(3, Types.INTEGER);
                    }
                    ps.setString(4, item.getProductName());
                    ps.setString(5, item.getSku());
                    ps.setInt(6, item.getQuantity());
                    ps.setString(7, item.getSpecialRequirements());
                    ps.addBatch();
                }
                ps.executeBatch();
            }
            
            // 5. Insert History
            String historyNote = "Khách hàng tạo yêu cầu báo giá";
            if (assignedTo != null) {
                historyNote += ". Tự động phân công cho Seller #" + assignedTo;
            }
            insertHistory(conn, rfqID, null, initialStatus, "RFQ Created", 
                         historyNote, rfq.getCustomerID(), "customer");
            
            conn.commit();
            return rfqID;
            
        } catch (SQLException e) {
            lastError = "SQL Error: " + e.getMessage();
            LOGGER.log(Level.SEVERE, "createRFQ failed", e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return -1;
        } finally {
            closeConnection(conn);
        }
    }

    /**
     * Auto-assign RFQ cho Seller có ít đơn nhất
     * Nếu bằng nhau thì theo EmployeeID từ nhỏ đến lớn
     */
    private Integer autoAssignSeller(Connection conn) throws SQLException {
        // Bảng Employees có cột IsActive (bit), không phải Status
        String sql = "SELECT TOP 1 e.EmployeeID " +
                    "FROM Employees e " +
                    "WHERE e.Role = 'Seller' AND e.IsActive = 1 " +
                    "ORDER BY (SELECT COUNT(*) FROM RFQs r WHERE r.AssignedTo = e.EmployeeID " +
                    "AND r.Status NOT IN ('Completed', 'Cancelled')) ASC, e.EmployeeID ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("EmployeeID");
            }
        }
        return null;
    }

    // ==================== GET RFQ ====================
    
    /**
     * Lấy RFQ theo ID
     */
    public RFQ getRFQById(int rfqID) {
        String sql = "SELECT r.*, c.FullName as CustomerName, e.FullName as AssignedName " +
                    "FROM RFQs r " +
                    "LEFT JOIN Customers c ON r.CustomerID = c.CustomerID " +
                    "LEFT JOIN Employees e ON r.AssignedTo = e.EmployeeID " +
                    "WHERE r.RFQID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rfqID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                RFQ rfq = mapResultSetToRFQ(rs);
                rfq.setItems(getRFQItems(rfqID));
                return rfq;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "getRFQById failed", e);
        }
        return null;
    }

    /**
     * Lấy danh sách RFQ Items
     */
    public List<RFQItem> getRFQItems(int rfqID) {
        List<RFQItem> items = new ArrayList<>();
        String sql = "SELECT ri.*, " +
                    "(SELECT TOP 1 pi.ImageURL FROM ProductImages pi WHERE pi.ProductID = ri.ProductID " +
                    "AND pi.ImageType = 'main' ORDER BY pi.SortOrder) as ProductImage " +
                    "FROM RFQItems ri WHERE ri.RFQID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rfqID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                items.add(mapResultSetToRFQItem(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "getRFQItems failed", e);
        }
        return items;
    }

    /**
     * Lấy lịch sử RFQ
     */
    public List<RFQHistory> getRFQHistory(int rfqID) {
        List<RFQHistory> history = new ArrayList<>();
        String sql = "SELECT h.*, " +
                    "CASE WHEN h.ChangedByType = 'customer' THEN c.FullName " +
                    "     WHEN h.ChangedByType = 'employee' THEN e.FullName " +
                    "     ELSE 'System' END as ChangedByName " +
                    "FROM RFQHistory h " +
                    "LEFT JOIN Customers c ON h.ChangedByType = 'customer' AND h.ChangedBy = c.CustomerID " +
                    "LEFT JOIN Employees e ON h.ChangedByType = 'employee' AND h.ChangedBy = e.EmployeeID " +
                    "WHERE h.RFQID = ? ORDER BY h.ChangedDate DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rfqID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                RFQHistory h = new RFQHistory();
                h.setHistoryID(rs.getInt("HistoryID"));
                h.setRfqID(rs.getInt("RFQID"));
                h.setOldStatus(rs.getString("OldStatus"));
                h.setNewStatus(rs.getString("NewStatus"));
                h.setAction(rs.getString("Action"));
                h.setNotes(rs.getString("Notes"));
                h.setChangedBy(rs.getObject("ChangedBy") != null ? rs.getInt("ChangedBy") : null);
                h.setChangedByType(rs.getString("ChangedByType"));
                h.setChangedDate(rs.getTimestamp("ChangedDate"));
                h.setChangedByName(rs.getString("ChangedByName"));
                history.add(h);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "getRFQHistory failed", e);
        }
        return history;
    }

    // ==================== SEARCH RFQ ====================
    
    /**
     * Tìm kiếm RFQ với filters
     */
    public List<RFQ> searchRFQs(String keyword, String status, Integer assignedTo, 
                                 Integer customerID, int page, int pageSize) {
        List<RFQ> rfqs = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT r.*, c.FullName as CustomerName, e.FullName as AssignedName ");
        sql.append("FROM RFQs r ");
        sql.append("LEFT JOIN Customers c ON r.CustomerID = c.CustomerID ");
        sql.append("LEFT JOIN Employees e ON r.AssignedTo = e.EmployeeID ");
        sql.append("WHERE 1=1 ");
        
        List<Object> params = new ArrayList<>();
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (r.RFQCode LIKE ? OR r.CompanyName LIKE ? OR c.FullName LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw); params.add(kw);
        }
        if (status != null && !status.isEmpty()) {
            sql.append("AND r.Status = ? ");
            params.add(status);
        }
        if (assignedTo != null) {
            if (assignedTo == 0) {
                sql.append("AND r.AssignedTo IS NULL ");
            } else {
                sql.append("AND r.AssignedTo = ? ");
                params.add(assignedTo);
            }
        }
        if (customerID != null) {
            sql.append("AND r.CustomerID = ? ");
            params.add(customerID);
        }
        
        sql.append("ORDER BY r.CreatedDate DESC ");
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
                rfqs.add(mapResultSetToRFQ(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "searchRFQs failed", e);
        }
        return rfqs;
    }

    /**
     * Đếm tổng số RFQ theo filter
     */
    public int countRFQs(String keyword, String status, Integer assignedTo, Integer customerID) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM RFQs r ");
        sql.append("LEFT JOIN Customers c ON r.CustomerID = c.CustomerID ");
        sql.append("WHERE 1=1 ");
        
        List<Object> params = new ArrayList<>();
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (r.RFQCode LIKE ? OR r.CompanyName LIKE ? OR c.FullName LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw); params.add(kw);
        }
        if (status != null && !status.isEmpty()) {
            sql.append("AND r.Status = ? ");
            params.add(status);
        }
        if (assignedTo != null) {
            if (assignedTo == 0) {
                sql.append("AND r.AssignedTo IS NULL ");
            } else {
                sql.append("AND r.AssignedTo = ? ");
                params.add(assignedTo);
            }
        }
        if (customerID != null) {
            sql.append("AND r.CustomerID = ? ");
            params.add(customerID);
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
            LOGGER.log(Level.SEVERE, "countRFQs failed", e);
        }
        return 0;
    }

    // ==================== DATE NEGOTIATION ====================
    
    /**
     * Seller đề xuất ngày giao hàng mới
     */
    public boolean proposeDeliveryDate(int rfqID, Timestamp proposedDate, String reason, int employeeID) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            RFQ rfq = getRFQById(rfqID);
            if (rfq == null || !rfq.canSellerProposeDate()) {
                lastError = "Không thể đề xuất ngày giao cho RFQ này";
                return false;
            }
            
            String oldStatus = rfq.getStatus();
            
            String sql = "UPDATE RFQs SET ProposedDeliveryDate = ?, DateChangeReason = ?, " +
                        "DateNegotiationCount = DateNegotiationCount + 1, Status = ?, " +
                        "UpdatedDate = GETDATE() WHERE RFQID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setTimestamp(1, proposedDate);
                ps.setString(2, reason);
                ps.setString(3, RFQ.STATUS_DATE_PROPOSED);
                ps.setInt(4, rfqID);
                ps.executeUpdate();
            }
            
            // Format ngày chỉ hiển thị dd/MM/yyyy
            String formattedDate = new java.text.SimpleDateFormat("dd/MM/yyyy").format(proposedDate);
            insertHistory(conn, rfqID, oldStatus, RFQ.STATUS_DATE_PROPOSED, "Date Proposed", 
                         "Seller đề xuất ngày giao: " + formattedDate + ". Lý do: " + reason, 
                         employeeID, "employee");
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            lastError = e.getMessage();
            LOGGER.log(Level.SEVERE, "proposeDeliveryDate failed", e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            closeConnection(conn);
        }
    }

    /**
     * Customer counter ngày giao hàng
     */
    public boolean customerCounterDate(int rfqID, Timestamp counterDate, String note, int customerID) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            RFQ rfq = getRFQById(rfqID);
            if (rfq == null || !rfq.canCustomerCounterDate()) {
                lastError = "Không thể đề xuất ngày giao cho RFQ này";
                return false;
            }
            
            String oldStatus = rfq.getStatus();
            
            String sql = "UPDATE RFQs SET CustomerCounterDate = ?, CustomerCounterDateNote = ?, " +
                        "DateNegotiationCount = DateNegotiationCount + 1, Status = ?, " +
                        "UpdatedDate = GETDATE() WHERE RFQID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setTimestamp(1, counterDate);
                ps.setString(2, note);
                ps.setString(3, RFQ.STATUS_DATE_COUNTERED);
                ps.setInt(4, rfqID);
                ps.executeUpdate();
            }
            
            insertHistory(conn, rfqID, oldStatus, RFQ.STATUS_DATE_COUNTERED, "Customer Counter Date", 
                         "KH đề xuất ngày giao: " + counterDate + ". " + (note != null ? note : ""), 
                         customerID, "customer");
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            lastError = e.getMessage();
            LOGGER.log(Level.SEVERE, "customerCounterDate failed", e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            closeConnection(conn);
        }
    }

    /**
     * Customer chấp nhận ngày giao đề xuất
     */
    public boolean acceptProposedDate(int rfqID, int customerID) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            RFQ rfq = getRFQById(rfqID);
            if (rfq == null || !rfq.canAcceptDate()) {
                lastError = "Không thể chấp nhận ngày giao cho RFQ này";
                return false;
            }
            
            String oldStatus = rfq.getStatus();
            
            String sql = "UPDATE RFQs SET Status = ?, UpdatedDate = GETDATE() WHERE RFQID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, RFQ.STATUS_DATE_ACCEPTED);
                ps.setInt(2, rfqID);
                ps.executeUpdate();
            }
            
            insertHistory(conn, rfqID, oldStatus, RFQ.STATUS_DATE_ACCEPTED, "Date Accepted", 
                         "KH chấp nhận ngày giao: " + rfq.getProposedDeliveryDate(), 
                         customerID, "customer");
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            lastError = e.getMessage();
            LOGGER.log(Level.SEVERE, "acceptProposedDate failed", e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            closeConnection(conn);
        }
    }

    // ==================== CANCEL RFQ ====================
    
    /**
     * Hủy RFQ
     */
    public boolean cancelRFQ(int rfqID, String reason, int changedBy, String changedByType) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            RFQ rfq = getRFQById(rfqID);
            String oldStatus = rfq != null ? rfq.getStatus() : null;
            
            String sql = "UPDATE RFQs SET Status = ?, RejectionReason = ?, UpdatedDate = GETDATE() WHERE RFQID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, RFQ.STATUS_CANCELLED);
                ps.setString(2, reason);
                ps.setInt(3, rfqID);
                ps.executeUpdate();
            }
            
            String actionBy = "customer".equals(changedByType) ? "Khách hàng" : "Seller";
            insertHistory(conn, rfqID, oldStatus, RFQ.STATUS_CANCELLED, "Cancelled", 
                         actionBy + " hủy RFQ. Lý do: " + reason, changedBy, changedByType);
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            lastError = e.getMessage();
            LOGGER.log(Level.SEVERE, "cancelRFQ failed", e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            closeConnection(conn);
        }
    }

    // ==================== UPDATE STATUS ====================
    
    /**
     * Cập nhật status RFQ (dùng cho QuotationDAO khi tạo quotation)
     */
    public boolean updateStatus(int rfqID, String newStatus, String action, String notes, 
                                int changedBy, String changedByType) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            RFQ rfq = getRFQById(rfqID);
            String oldStatus = rfq != null ? rfq.getStatus() : null;
            
            String sql = "UPDATE RFQs SET Status = ?, UpdatedDate = GETDATE() WHERE RFQID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, newStatus);
                ps.setInt(2, rfqID);
                ps.executeUpdate();
            }
            
            insertHistory(conn, rfqID, oldStatus, newStatus, action, notes, changedBy, changedByType);
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            lastError = e.getMessage();
            LOGGER.log(Level.SEVERE, "updateStatus failed", e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            closeConnection(conn);
        }
    }

    /**
     * Cập nhật seller notes
     */
    public boolean updateSellerNotes(int rfqID, String notes, int employeeID) {
        String sql = "UPDATE RFQs SET SellerNotes = ?, UpdatedDate = GETDATE() WHERE RFQID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, notes);
            ps.setInt(2, rfqID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "updateSellerNotes failed", e);
            return false;
        }
    }

    // ==================== STATISTICS ====================
    
    /**
     * Lấy thống kê RFQ theo status
     */
    public int[] getRFQStatistics(Integer assignedTo) {
        int[] stats = new int[5]; // [pending, reviewing, dateNegotiating, quotationCreated, completed]
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT Status, COUNT(*) as Cnt FROM RFQs WHERE 1=1 ");
        
        List<Object> params = new ArrayList<>();
        if (assignedTo != null) {
            sql.append("AND AssignedTo = ? ");
            params.add(assignedTo);
        }
        sql.append("GROUP BY Status");
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                String status = rs.getString("Status");
                int count = rs.getInt("Cnt");
                switch (status) {
                    case RFQ.STATUS_PENDING: stats[0] = count; break;
                    case RFQ.STATUS_REVIEWING: stats[1] = count; break;
                    case RFQ.STATUS_DATE_PROPOSED:
                    case RFQ.STATUS_DATE_COUNTERED:
                    case RFQ.STATUS_DATE_ACCEPTED: stats[2] += count; break;
                    case RFQ.STATUS_QUOTATION_CREATED: stats[3] = count; break;
                    case RFQ.STATUS_COMPLETED: stats[4] = count; break;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "getRFQStatistics failed", e);
        }
        return stats;
    }


    // ==================== HELPER METHODS ====================
    
    /**
     * Insert history record
     */
    private void insertHistory(Connection conn, int rfqID, String oldStatus, String newStatus,
                               String action, String notes, Integer changedBy, String changedByType) 
                               throws SQLException {
        String sql = "INSERT INTO RFQHistory (RFQID, OldStatus, NewStatus, Action, Notes, " +
                    "ChangedBy, ChangedByType, ChangedDate) VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE())";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rfqID);
            ps.setString(2, oldStatus);
            ps.setString(3, newStatus);
            ps.setString(4, action);
            ps.setString(5, notes);
            if (changedBy != null) {
                ps.setInt(6, changedBy);
            } else {
                ps.setNull(6, Types.INTEGER);
            }
            ps.setString(7, changedByType);
            ps.executeUpdate();
        }
    }

    /**
     * Map ResultSet to RFQ entity
     */
    private RFQ mapResultSetToRFQ(ResultSet rs) throws SQLException {
        RFQ rfq = new RFQ();
        rfq.setRfqID(rs.getInt("RFQID"));
        rfq.setRfqCode(rs.getString("RFQCode"));
        rfq.setCustomerID(rs.getInt("CustomerID"));
        rfq.setCompanyName(rs.getString("CompanyName"));
        rfq.setTaxID(rs.getString("TaxID"));
        rfq.setBusinessType(rs.getString("BusinessType"));
        rfq.setContactPerson(rs.getString("ContactPerson"));
        rfq.setContactPhone(rs.getString("ContactPhone"));
        rfq.setContactEmail(rs.getString("ContactEmail"));
        rfq.setAlternativeContact(rs.getString("AlternativeContact"));
        rfq.setDeliveryAddress(rs.getString("DeliveryAddress"));
        
        // Delivery location details
        try {
            rfq.setDeliveryStreet(rs.getString("DeliveryStreet"));
            rfq.setDeliveryCity(rs.getString("DeliveryCity"));
            rfq.setDeliveryCityId(rs.getString("DeliveryCityId"));
            rfq.setDeliveryDistrict(rs.getString("DeliveryDistrict"));
            rfq.setDeliveryDistrictId(rs.getString("DeliveryDistrictId"));
            rfq.setDeliveryWard(rs.getString("DeliveryWard"));
            rfq.setDeliveryWardId(rs.getString("DeliveryWardId"));
        } catch (SQLException ignored) {}
        
        rfq.setRequestedDeliveryDate(rs.getTimestamp("RequestedDeliveryDate"));
        rfq.setDeliveryInstructions(rs.getString("DeliveryInstructions"));
        
        // Date negotiation
        try {
            rfq.setProposedDeliveryDate(rs.getTimestamp("ProposedDeliveryDate"));
            rfq.setDateChangeReason(rs.getString("DateChangeReason"));
            rfq.setCustomerCounterDate(rs.getTimestamp("CustomerCounterDate"));
            rfq.setCustomerCounterDateNote(rs.getString("CustomerCounterDateNote"));
            rfq.setDateNegotiationCount(rs.getInt("DateNegotiationCount"));
            rfq.setMaxDateNegotiationCount(rs.getInt("MaxDateNegotiationCount"));
        } catch (SQLException ignored) {
            rfq.setDateNegotiationCount(0);
            rfq.setMaxDateNegotiationCount(3);
        }
        
        try {
            rfq.setPaymentTermsPreference(rs.getString("PaymentTermsPreference"));
        } catch (SQLException ignored) {}
        
        rfq.setStatus(rs.getString("Status"));
        
        // AssignedTo
        int assignedTo = rs.getInt("AssignedTo");
        if (!rs.wasNull()) {
            rfq.setAssignedTo(assignedTo);
        }
        
        rfq.setCustomerNotes(rs.getString("CustomerNotes"));
        
        try {
            rfq.setSellerNotes(rs.getString("SellerNotes"));
            rfq.setRejectionReason(rs.getString("RejectionReason"));
        } catch (SQLException ignored) {}
        
        rfq.setCreatedDate(rs.getTimestamp("CreatedDate"));
        rfq.setUpdatedDate(rs.getTimestamp("UpdatedDate"));
        
        // Joined fields
        try {
            rfq.setCustomerName(rs.getString("CustomerName"));
            rfq.setAssignedName(rs.getString("AssignedName"));
        } catch (SQLException ignored) {}
        
        return rfq;
    }

    /**
     * Map ResultSet to RFQItem entity
     */
    private RFQItem mapResultSetToRFQItem(ResultSet rs) throws SQLException {
        RFQItem item = new RFQItem();
        item.setRfqItemID(rs.getInt("RFQItemID"));
        item.setRfqID(rs.getInt("RFQID"));
        item.setProductID(rs.getInt("ProductID"));
        
        int variantID = rs.getInt("VariantID");
        if (!rs.wasNull()) {
            item.setVariantID(variantID);
        }
        
        item.setProductName(rs.getString("ProductName"));
        item.setSku(rs.getString("SKU"));
        item.setQuantity(rs.getInt("Quantity"));
        item.setSpecialRequirements(rs.getString("SpecialRequirements"));
        
        try {
            item.setProductImage(rs.getString("ProductImage"));
        } catch (SQLException ignored) {}
        
        return item;
    }

    // ==================== CUSTOMER METHODS ====================
    
    /**
     * Lấy danh sách RFQ của customer
     */
    public List<RFQ> getCustomerRFQs(int customerID, String keyword, String status, 
                                      int page, int pageSize) {
        return searchRFQs(keyword, status, null, customerID, page, pageSize);
    }

    /**
     * Đếm số RFQ của customer
     */
    public int countCustomerRFQs(int customerID, String keyword, String status) {
        return countRFQs(keyword, status, null, customerID);
    }

    // ==================== SELLER METHODS ====================
    
    /**
     * Lấy danh sách RFQ được assign cho seller
     */
    public List<RFQ> getSellerRFQs(int sellerID, String keyword, String status, 
                                    int page, int pageSize) {
        return searchRFQs(keyword, status, sellerID, null, page, pageSize);
    }

    /**
     * Đếm số RFQ được assign cho seller
     */
    public int countSellerRFQs(int sellerID, String keyword, String status) {
        return countRFQs(keyword, status, sellerID, null);
    }

    /**
     * Assign RFQ cho seller (manual assign nếu cần)
     */
    public boolean assignRFQ(int rfqID, int employeeID, int changedBy) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            RFQ rfq = getRFQById(rfqID);
            String oldStatus = rfq != null ? rfq.getStatus() : null;
            String newStatus = RFQ.STATUS_REVIEWING;
            
            String sql = "UPDATE RFQs SET AssignedTo = ?, Status = ?, UpdatedDate = GETDATE() WHERE RFQID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, employeeID);
                ps.setString(2, newStatus);
                ps.setInt(3, rfqID);
                ps.executeUpdate();
            }
            
            insertHistory(conn, rfqID, oldStatus, newStatus, "Assigned", 
                         "Phân công xử lý RFQ cho Seller #" + employeeID, changedBy, "employee");
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "assignRFQ failed", e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            closeConnection(conn);
        }
    }

    /**
     * Kiểm tra RFQ có thuộc về seller không
     */
    public boolean isRFQAssignedToSeller(int rfqID, int sellerID) {
        String sql = "SELECT 1 FROM RFQs WHERE RFQID = ? AND AssignedTo = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rfqID);
            ps.setInt(2, sellerID);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "isRFQAssignedToSeller failed", e);
            return false;
        }
    }

    /**
     * Kiểm tra RFQ có thuộc về customer không
     */
    public boolean isRFQOwnedByCustomer(int rfqID, int customerID) {
        String sql = "SELECT 1 FROM RFQs WHERE RFQID = ? AND CustomerID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rfqID);
            ps.setInt(2, customerID);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "isRFQOwnedByCustomer failed", e);
            return false;
        }
    }

    /**
     * Hoàn thành RFQ sau khi thanh toán Quotation thành công
     * @param rfqID ID của RFQ
     * @param orderID ID của Order đã tạo
     * @return true nếu thành công
     */
    public boolean completeRFQ(int rfqID, int orderID) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            RFQ rfq = getRFQById(rfqID);
            String oldStatus = rfq != null ? rfq.getStatus() : null;
            
            String sql = "UPDATE RFQs SET Status = ?, UpdatedDate = GETDATE() WHERE RFQID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, RFQ.STATUS_COMPLETED);
                ps.setInt(2, rfqID);
                ps.executeUpdate();
            }
            
            String notes = "RFQ hoàn thành. Đơn hàng #" + orderID + " đã được tạo.";
            insertHistory(conn, rfqID, oldStatus, RFQ.STATUS_COMPLETED, "Completed", notes, null, "system");
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "completeRFQ failed", e);
            lastError = e.getMessage();
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            closeConnection(conn);
        }
    }

    /**
     * Close connection helper
     */
    private void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error closing connection", e);
            }
        }
    }
}
