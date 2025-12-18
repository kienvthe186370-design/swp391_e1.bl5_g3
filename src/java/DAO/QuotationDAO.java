package DAO;

import entity.Employee;
import entity.Quotation;
import entity.QuotationItem;
import entity.QuotationHistory;
import entity.RFQItem;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * QuotationDAO - Data Access Object for Quotation operations
 */
public class QuotationDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(QuotationDAO.class.getName());

    /**
     * Generate Quotation Code: QTyyyyMMdd0001
     */
    public String generateQuotationCode(Connection conn) throws SQLException {
        String sql = "SELECT dbo.fn_GenerateQuotationCode()";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getString(1);
            }
        }
        // Fallback
        return "QT" + new java.text.SimpleDateFormat("yyyyMMdd").format(new java.util.Date()) + "0001";
    }

    /**
     * Tạo Quotation mới
     */
    public int createQuotation(Quotation quotation, List<QuotationItem> items) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            String code = generateQuotationCode(conn);
            
            String sql = "INSERT INTO Quotations (QuotationCode, RFQID, SubtotalAmount, ShippingFee, " +
                        "TaxAmount, TotalAmount, QuotationSentDate, QuotationValidUntil, QuotationTerms, " +
                        "WarrantyTerms, PaymentMethod, ShippingCarrierId, ShippingCarrierName, " +
                        "ShippingServiceName, EstimatedDeliveryDays, Status, SellerNotes, CreatedBy, " +
                        "CreatedDate, UpdatedDate) " +
                        "VALUES (?, ?, ?, ?, ?, ?, GETDATE(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";
            
            int quotationID;
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                int idx = 1;
                ps.setString(idx++, code);
                ps.setInt(idx++, quotation.getRfqID());
                ps.setBigDecimal(idx++, quotation.getSubtotalAmount());
                ps.setBigDecimal(idx++, quotation.getShippingFee());
                ps.setBigDecimal(idx++, quotation.getTaxAmount());
                ps.setBigDecimal(idx++, quotation.getTotalAmount());
                ps.setTimestamp(idx++, quotation.getQuotationValidUntil());
                ps.setString(idx++, quotation.getQuotationTerms());
                ps.setString(idx++, quotation.getWarrantyTerms());
                ps.setString(idx++, quotation.getPaymentMethod());
                ps.setString(idx++, quotation.getShippingCarrierId());
                ps.setString(idx++, quotation.getShippingCarrierName());
                ps.setString(idx++, quotation.getShippingServiceName());
                ps.setInt(idx++, quotation.getEstimatedDeliveryDays());
                ps.setString(idx++, Quotation.STATUS_SENT);
                ps.setString(idx++, quotation.getSellerNotes());
                ps.setInt(idx++, quotation.getCreatedBy());
                
                ps.executeUpdate();
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    quotationID = rs.getInt(1);
                } else {
                    throw new SQLException("Failed to get generated QuotationID");
                }
            }
            
            // Insert QuotationItems
            String itemSql = "INSERT INTO QuotationItems (QuotationID, RFQItemID, CostPrice, " +
                            "ProfitMarginPercent, UnitPrice, Subtotal, Notes) VALUES (?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(itemSql)) {
                for (QuotationItem item : items) {
                    ps.setInt(1, quotationID);
                    ps.setInt(2, item.getRfqItemID());
                    ps.setBigDecimal(3, item.getCostPrice());
                    ps.setBigDecimal(4, item.getProfitMarginPercent());
                    ps.setBigDecimal(5, item.getUnitPrice());
                    ps.setBigDecimal(6, item.getSubtotal());
                    ps.setString(7, item.getNotes());
                    ps.addBatch();
                }
                ps.executeBatch();
            }
            
            // Insert History
            insertHistory(conn, quotationID, null, Quotation.STATUS_SENT, "Quotation Created", 
                         "Tạo và gửi báo giá", quotation.getCreatedBy(), "employee");
            
            // Update RFQ status
            updateRFQStatus(conn, quotation.getRfqID(), "QuotationCreated");
            
            conn.commit();
            return quotationID;
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "createQuotation failed", e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return -1;
        } finally {
            closeConnection(conn);
        }
    }

    /**
     * Lấy Quotation theo ID
     */
    public Quotation getQuotationById(int quotationID) {
        String sql = "SELECT q.*, e.FullName as CreatedByName " +
                    "FROM Quotations q " +
                    "LEFT JOIN Employees e ON q.CreatedBy = e.EmployeeID " +
                    "WHERE q.QuotationID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quotationID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Quotation q = mapResultSetToQuotation(rs);
                q.setItems(getQuotationItems(quotationID));
                return q;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "getQuotationById failed", e);
        }
        return null;
    }

    /**
     * Lấy Quotation theo RFQID
     */
    public Quotation getQuotationByRFQId(int rfqID) {
        String sql = "SELECT q.*, e.FullName as CreatedByName " +
                    "FROM Quotations q " +
                    "LEFT JOIN Employees e ON q.CreatedBy = e.EmployeeID " +
                    "WHERE q.RFQID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rfqID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Quotation q = mapResultSetToQuotation(rs);
                q.setItems(getQuotationItems(q.getQuotationID()));
                return q;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "getQuotationByRFQId failed", e);
        }
        return null;
    }

    /**
     * Lấy Quotation theo QuotationCode
     */
    public Quotation getQuotationByCode(String quotationCode) {
        String sql = "SELECT q.*, e.FullName as CreatedByName " +
                    "FROM Quotations q " +
                    "LEFT JOIN Employees e ON q.CreatedBy = e.EmployeeID " +
                    "WHERE q.QuotationCode = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, quotationCode);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Quotation q = mapResultSetToQuotation(rs);
                q.setItems(getQuotationItems(q.getQuotationID()));
                return q;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "getQuotationByCode failed", e);
        }
        return null;
    }

    /**
     * Lấy danh sách QuotationItems
     */
    public List<QuotationItem> getQuotationItems(int quotationID) {
        List<QuotationItem> items = new ArrayList<>();
        String sql = "SELECT qi.*, ri.ProductName, ri.SKU, ri.Quantity, ri.ProductID, ri.VariantID, " +
                    "(SELECT TOP 1 pi.ImageURL FROM ProductImages pi WHERE pi.ProductID = ri.ProductID " +
                    "AND pi.ImageType = 'main' ORDER BY pi.SortOrder) as ProductImage " +
                    "FROM QuotationItems qi " +
                    "JOIN RFQItems ri ON qi.RFQItemID = ri.RFQItemID " +
                    "WHERE qi.QuotationID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quotationID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                items.add(mapResultSetToQuotationItem(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "getQuotationItems failed", e);
        }
        return items;
    }

    /**
     * Customer counter giá
     */
    public boolean customerCounterPrice(int quotationID, BigDecimal counterPrice, String note, int customerID) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            Quotation q = getQuotationById(quotationID);
            if (q == null || !q.canCustomerCounter()) {
                return false;
            }
            
            String sql = "UPDATE Quotations SET CustomerCounterPrice = ?, CustomerCounterNote = ?, " +
                        "NegotiationCount = NegotiationCount + 1, Status = ?, UpdatedDate = GETDATE() " +
                        "WHERE QuotationID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setBigDecimal(1, counterPrice);
                ps.setString(2, note);
                ps.setString(3, Quotation.STATUS_CUSTOMER_COUNTERED);
                ps.setInt(4, quotationID);
                ps.executeUpdate();
            }
            
            insertHistory(conn, quotationID, q.getStatus(), Quotation.STATUS_CUSTOMER_COUNTERED, 
                         "Customer Counter", "KH đề xuất giá: " + counterPrice + " VND. " + note, 
                         customerID, "customer");
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "customerCounterPrice failed", e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            closeConnection(conn);
        }
    }

    /**
     * Seller counter giá
     */
    public boolean sellerCounterPrice(int quotationID, BigDecimal counterPrice, String note, int employeeID) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            Quotation q = getQuotationById(quotationID);
            if (q == null || !q.canSellerCounter()) {
                return false;
            }
            
            String sql = "UPDATE Quotations SET SellerCounterPrice = ?, SellerCounterNote = ?, " +
                        "TotalAmount = ?, NegotiationCount = NegotiationCount + 1, Status = ?, " +
                        "UpdatedDate = GETDATE() WHERE QuotationID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setBigDecimal(1, counterPrice);
                ps.setString(2, note);
                ps.setBigDecimal(3, counterPrice); // Update total to new price
                ps.setString(4, Quotation.STATUS_SELLER_COUNTERED);
                ps.setInt(5, quotationID);
                ps.executeUpdate();
            }
            
            insertHistory(conn, quotationID, q.getStatus(), Quotation.STATUS_SELLER_COUNTERED, 
                         "Seller Counter", "Seller đề xuất giá: " + counterPrice + " VND. " + note, 
                         employeeID, "employee");
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "sellerCounterPrice failed", e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            closeConnection(conn);
        }
    }

    /**
     * Customer chấp nhận báo giá
     */
    public boolean acceptQuotation(int quotationID, int customerID) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            Quotation q = getQuotationById(quotationID);
            if (q == null || !q.canAccept()) {
                return false;
            }
            
            String sql = "UPDATE Quotations SET Status = ?, UpdatedDate = GETDATE() WHERE QuotationID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, Quotation.STATUS_ACCEPTED);
                ps.setInt(2, quotationID);
                ps.executeUpdate();
            }
            
            insertHistory(conn, quotationID, q.getStatus(), Quotation.STATUS_ACCEPTED, 
                         "Accepted", "Khách hàng chấp nhận báo giá", customerID, "customer");
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "acceptQuotation failed", e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            closeConnection(conn);
        }
    }

    /**
     * Customer từ chối báo giá
     */
    public boolean rejectQuotation(int quotationID, String reason, int customerID) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            Quotation q = getQuotationById(quotationID);
            String oldStatus = q != null ? q.getStatus() : null;
            
            String sql = "UPDATE Quotations SET Status = ?, RejectionReason = ?, UpdatedDate = GETDATE() " +
                        "WHERE QuotationID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, Quotation.STATUS_REJECTED);
                ps.setString(2, reason);
                ps.setInt(3, quotationID);
                ps.executeUpdate();
            }
            
            insertHistory(conn, quotationID, oldStatus, Quotation.STATUS_REJECTED, 
                         "Rejected", "Khách hàng từ chối: " + reason, customerID, "customer");
            
            // Update RFQ status to Cancelled
            if (q != null) {
                updateRFQStatus(conn, q.getRfqID(), "Cancelled");
            }
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "rejectQuotation failed", e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            closeConnection(conn);
        }
    }

    /**
     * Đánh dấu đã thanh toán (với customerID)
     */
    public boolean markAsPaid(int quotationID, int customerID) {
        return markAsPaid(quotationID, null, customerID);
    }

    /**
     * Đánh dấu đã thanh toán (với transactionNo từ VNPay)
     */
    public boolean markAsPaid(int quotationID, String transactionNo) {
        return markAsPaid(quotationID, transactionNo, null);
    }

    /**
     * Đánh dấu đã thanh toán
     */
    private boolean markAsPaid(int quotationID, String transactionNo, Integer customerID) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            Quotation q = getQuotationById(quotationID);
            String oldStatus = q != null ? q.getStatus() : null;
            
            String sql = "UPDATE Quotations SET Status = ?, UpdatedDate = GETDATE() WHERE QuotationID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, Quotation.STATUS_PAID);
                ps.setInt(2, quotationID);
                ps.executeUpdate();
            }
            
            String notes = "Thanh toán thành công";
            if (transactionNo != null) {
                notes += " - Mã GD: " + transactionNo;
            }
            
            // Get customerID from RFQ if not provided
            int custID = customerID != null ? customerID : 0;
            if (custID == 0 && q != null) {
                // Load RFQ to get customerID
                try {
                    String rfqSql = "SELECT CustomerID FROM RFQs WHERE RFQID = ?";
                    try (PreparedStatement ps = conn.prepareStatement(rfqSql)) {
                        ps.setInt(1, q.getRfqID());
                        ResultSet rs = ps.executeQuery();
                        if (rs.next()) {
                            custID = rs.getInt("CustomerID");
                        }
                    }
                } catch (SQLException ignored) {}
            }
            
            insertHistory(conn, quotationID, oldStatus, Quotation.STATUS_PAID, 
                         "Paid", notes, custID, "customer");
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "markAsPaid failed", e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            closeConnection(conn);
        }
    }

    /**
     * Tìm kiếm Quotations cho Seller
     */
    public List<Quotation> searchQuotations(String keyword, String status, Integer createdBy, 
                                            int page, int pageSize) {
        List<Quotation> quotations = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT q.*, e.FullName as CreatedByName, r.RFQCode, c.FullName as CustomerName ");
        sql.append("FROM Quotations q ");
        sql.append("JOIN RFQs r ON q.RFQID = r.RFQID ");
        sql.append("JOIN Customers c ON r.CustomerID = c.CustomerID ");
        sql.append("LEFT JOIN Employees e ON q.CreatedBy = e.EmployeeID ");
        sql.append("WHERE 1=1 ");
        
        List<Object> params = new ArrayList<>();
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (q.QuotationCode LIKE ? OR r.RFQCode LIKE ? OR c.FullName LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw); params.add(kw);
        }
        if (status != null && !status.isEmpty()) {
            sql.append("AND q.Status = ? ");
            params.add(status);
        }
        if (createdBy != null) {
            sql.append("AND q.CreatedBy = ? ");
            params.add(createdBy);
        }
        
        sql.append("ORDER BY q.CreatedDate DESC ");
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
                Quotation q = mapResultSetToQuotation(rs);
                q.setItems(getQuotationItems(q.getQuotationID()));
                quotations.add(q);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "searchQuotations failed", e);
        }
        return quotations;
    }

    /**
     * Đếm số Quotations
     */
    public int countQuotations(String keyword, String status, Integer createdBy) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM Quotations q ");
        sql.append("JOIN RFQs r ON q.RFQID = r.RFQID ");
        sql.append("JOIN Customers c ON r.CustomerID = c.CustomerID ");
        sql.append("WHERE 1=1 ");
        
        List<Object> params = new ArrayList<>();
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (q.QuotationCode LIKE ? OR r.RFQCode LIKE ? OR c.FullName LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw); params.add(kw);
        }
        if (status != null && !status.isEmpty()) {
            sql.append("AND q.Status = ? ");
            params.add(status);
        }
        if (createdBy != null) {
            sql.append("AND q.CreatedBy = ? ");
            params.add(createdBy);
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
            LOGGER.log(Level.SEVERE, "countQuotations failed", e);
        }
        return 0;
    }

    /**
     * Lấy danh sách Quotations cho Customer
     */
    public List<Quotation> getCustomerQuotations(int customerID, String keyword, String status, 
                                                  int page, int pageSize) {
        List<Quotation> quotations = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT q.*, e.FullName as CreatedByName, r.RFQCode ");
        sql.append("FROM Quotations q ");
        sql.append("JOIN RFQs r ON q.RFQID = r.RFQID ");
        sql.append("LEFT JOIN Employees e ON q.CreatedBy = e.EmployeeID ");
        sql.append("WHERE r.CustomerID = ? ");
        
        List<Object> params = new ArrayList<>();
        params.add(customerID);
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (q.QuotationCode LIKE ? OR r.RFQCode LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw);
        }
        if (status != null && !status.isEmpty()) {
            sql.append("AND q.Status = ? ");
            params.add(status);
        }
        
        sql.append("ORDER BY q.CreatedDate DESC ");
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
                Quotation q = mapResultSetToQuotation(rs);
                quotations.add(q);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "getCustomerQuotations failed", e);
        }
        return quotations;
    }

    public int countCustomerQuotations(int customerID, String keyword, String status) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM Quotations q ");
        sql.append("JOIN RFQs r ON q.RFQID = r.RFQID ");
        sql.append("WHERE r.CustomerID = ? ");
        
        List<Object> params = new ArrayList<>();
        params.add(customerID);
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (q.QuotationCode LIKE ? OR r.RFQCode LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw);
        }
        if (status != null && !status.isEmpty()) {
            sql.append("AND q.Status = ? ");
            params.add(status);
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
            LOGGER.log(Level.SEVERE, "countCustomerQuotations failed", e);
        }
        return 0;
    }

    /**
     * Lấy lịch sử Quotation
     */
    public List<QuotationHistory> getQuotationHistory(int quotationID) {
        List<QuotationHistory> history = new ArrayList<>();
        String sql = "SELECT h.*, " +
                    "CASE WHEN h.ChangedByType = 'customer' THEN c.FullName " +
                    "     WHEN h.ChangedByType = 'employee' THEN e.FullName " +
                    "     ELSE 'System' END as ChangedByName " +
                    "FROM QuotationHistory h " +
                    "LEFT JOIN Customers c ON h.ChangedByType = 'customer' AND h.ChangedBy = c.CustomerID " +
                    "LEFT JOIN Employees e ON h.ChangedByType = 'employee' AND h.ChangedBy = e.EmployeeID " +
                    "WHERE h.QuotationID = ? ORDER BY h.ChangedDate DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quotationID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                QuotationHistory h = new QuotationHistory();
                h.setHistoryID(rs.getInt("HistoryID"));
                h.setQuotationID(rs.getInt("QuotationID"));
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
            LOGGER.log(Level.SEVERE, "getQuotationHistory failed", e);
        }
        return history;
    }

    // ==================== HELPER METHODS ====================
    
    private void insertHistory(Connection conn, int quotationID, String oldStatus, String newStatus,
                               String action, String notes, Integer changedBy, String changedByType) 
                               throws SQLException {
        String sql = "INSERT INTO QuotationHistory (QuotationID, OldStatus, NewStatus, Action, Notes, " +
                    "ChangedBy, ChangedByType, ChangedDate) VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE())";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quotationID);
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

    private void updateRFQStatus(Connection conn, int rfqID, String status) throws SQLException {
        String sql = "UPDATE RFQs SET Status = ?, UpdatedDate = GETDATE() WHERE RFQID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, rfqID);
            ps.executeUpdate();
        }
    }

    private Quotation mapResultSetToQuotation(ResultSet rs) throws SQLException {
        Quotation q = new Quotation();
        q.setQuotationID(rs.getInt("QuotationID"));
        q.setQuotationCode(rs.getString("QuotationCode"));
        q.setRfqID(rs.getInt("RFQID"));
        q.setSubtotalAmount(rs.getBigDecimal("SubtotalAmount"));
        q.setShippingFee(rs.getBigDecimal("ShippingFee"));
        q.setTaxAmount(rs.getBigDecimal("TaxAmount"));
        q.setTotalAmount(rs.getBigDecimal("TotalAmount"));
        q.setQuotationSentDate(rs.getTimestamp("QuotationSentDate"));
        q.setQuotationValidUntil(rs.getTimestamp("QuotationValidUntil"));
        q.setQuotationTerms(rs.getString("QuotationTerms"));
        q.setWarrantyTerms(rs.getString("WarrantyTerms"));
        q.setPaymentMethod(rs.getString("PaymentMethod"));
        q.setShippingCarrierId(rs.getString("ShippingCarrierId"));
        q.setShippingCarrierName(rs.getString("ShippingCarrierName"));
        q.setShippingServiceName(rs.getString("ShippingServiceName"));
        q.setEstimatedDeliveryDays(rs.getInt("EstimatedDeliveryDays"));
        q.setNegotiationCount(rs.getInt("NegotiationCount"));
        q.setMaxNegotiationCount(rs.getInt("MaxNegotiationCount"));
        q.setCustomerCounterPrice(rs.getBigDecimal("CustomerCounterPrice"));
        q.setCustomerCounterNote(rs.getString("CustomerCounterNote"));
        q.setSellerCounterPrice(rs.getBigDecimal("SellerCounterPrice"));
        q.setSellerCounterNote(rs.getString("SellerCounterNote"));
        q.setStatus(rs.getString("Status"));
        q.setSellerNotes(rs.getString("SellerNotes"));
        q.setRejectionReason(rs.getString("RejectionReason"));
        q.setCreatedBy(rs.getObject("CreatedBy") != null ? rs.getInt("CreatedBy") : null);
        q.setCreatedDate(rs.getTimestamp("CreatedDate"));
        q.setUpdatedDate(rs.getTimestamp("UpdatedDate"));
        
        // Try to get joined fields
        try { q.setCreatedByEmployee(new Employee()); } catch (Exception ignored) {}
        
        return q;
    }

    private QuotationItem mapResultSetToQuotationItem(ResultSet rs) throws SQLException {
        QuotationItem item = new QuotationItem();
        item.setQuotationItemID(rs.getInt("QuotationItemID"));
        item.setQuotationID(rs.getInt("QuotationID"));
        item.setRfqItemID(rs.getInt("RFQItemID"));
        item.setCostPrice(rs.getBigDecimal("CostPrice"));
        item.setProfitMarginPercent(rs.getBigDecimal("ProfitMarginPercent"));
        item.setUnitPrice(rs.getBigDecimal("UnitPrice"));
        item.setSubtotal(rs.getBigDecimal("Subtotal"));
        item.setNotes(rs.getString("Notes"));
        
        // From RFQItem join
        item.setProductName(rs.getString("ProductName"));
        item.setSku(rs.getString("SKU"));
        item.setQuantity(rs.getInt("Quantity"));
        try {
            item.setProductImage(rs.getString("ProductImage"));
        } catch (SQLException ignored) {}
        
        return item;
    }

    /**
     * Lấy giá vốn trung bình của variant (từ StockReceipts)
     */
    public BigDecimal getWeightedAverageCost(int variantID) {
        String sql = "SELECT CASE WHEN SUM(Quantity) > 0 " +
                    "THEN SUM(Quantity * UnitCost) / SUM(Quantity) ELSE 0 END as WAC " +
                    "FROM StockReceipts WHERE VariantID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, variantID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getBigDecimal("WAC");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "getWeightedAverageCost failed", e);
        }
        return BigDecimal.ZERO;
    }

    /**
     * Lấy min profit margin từ ProductVariants
     */
    public BigDecimal getProfitMarginTarget(int variantID) {
        String sql = "SELECT ProfitMarginTarget FROM ProductVariants WHERE VariantID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, variantID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                BigDecimal target = rs.getBigDecimal("ProfitMarginTarget");
                return target != null ? target : new BigDecimal("10"); // Default 10%
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "getProfitMarginTarget failed", e);
        }
        return new BigDecimal("10");
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
