package DAO;

import entity.RFQ;
import entity.RFQItem;
import entity.RFQHistory;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * RFQDAO - Data Access Object for RFQ operations
 */
public class RFQDAO extends DBContext {

    private String lastError = null;
    
    public String getLastError() {
        return lastError;
    }
    
    /**
     * Tạo RFQ mới với transaction
     * @return RFQID nếu thành công, -1 nếu thất bại
     */
    public int createRFQ(RFQ rfq, List<RFQItem> items) {
        lastError = null;
        Connection conn = null;
        System.out.println("[RFQDAO] === START createRFQ ===");
        try {
            conn = getConnection();
            if (conn == null) {
                lastError = "Database connection failed - Connection is NULL";
                System.err.println("[RFQDAO] ERROR: Connection is NULL!");
                return -1;
            }
            conn.setAutoCommit(false);
            System.out.println("[RFQDAO] Connection OK, autoCommit=false");
            
            // 1. Generate RFQ Code
            String rfqCode = generateRFQCode(conn);
            System.out.println("[RFQDAO] Generated RFQ Code: " + rfqCode);
            
            // 2. Insert RFQ - check if new columns exist
            boolean hasDeliveryIds = checkColumnExists(conn, "RFQs", "DeliveryCityId");
            boolean hasShippingCarrier = checkColumnExists(conn, "RFQs", "ShippingCarrierId");
            System.out.println("[RFQDAO] hasDeliveryIds=" + hasDeliveryIds + ", hasShippingCarrier=" + hasShippingCarrier);
            
            String sql;
            if (hasDeliveryIds && hasShippingCarrier) {
                sql = "INSERT INTO RFQs (RFQCode, CustomerID, CompanyName, TaxID, BusinessType, " +
                      "ContactPerson, ContactPhone, ContactEmail, AlternativeContact, " +
                      "DeliveryAddress, DeliveryCityId, DeliveryDistrictId, DeliveryWardId, " +
                      "RequestedDeliveryDate, DeliveryInstructions, PaymentMethod, " +
                      "ShippingCarrierId, ShippingCarrierName, ShippingServiceName, ShippingFee, EstimatedDeliveryDays, " +
                      "Status, CustomerNotes, CreatedDate, UpdatedDate) " +
                      "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";
            } else if (hasDeliveryIds) {
                sql = "INSERT INTO RFQs (RFQCode, CustomerID, CompanyName, TaxID, BusinessType, " +
                      "ContactPerson, ContactPhone, ContactEmail, AlternativeContact, " +
                      "DeliveryAddress, DeliveryCityId, DeliveryDistrictId, DeliveryWardId, " +
                      "RequestedDeliveryDate, DeliveryInstructions, PaymentMethod, " +
                      "Status, CustomerNotes, CreatedDate, UpdatedDate) " +
                      "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";
            } else {
                sql = "INSERT INTO RFQs (RFQCode, CustomerID, CompanyName, TaxID, BusinessType, " +
                      "ContactPerson, ContactPhone, ContactEmail, AlternativeContact, " +
                      "DeliveryAddress, RequestedDeliveryDate, DeliveryInstructions, PaymentMethod, " +
                      "Status, CustomerNotes, CreatedDate, UpdatedDate) " +
                      "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";
            }
            
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
                if (hasDeliveryIds) {
                    ps.setString(idx++, rfq.getDeliveryCityId());
                    ps.setString(idx++, rfq.getDeliveryDistrictId());
                    ps.setString(idx++, rfq.getDeliveryWardId());
                }
                ps.setTimestamp(idx++, rfq.getRequestedDeliveryDate());
                ps.setString(idx++, rfq.getDeliveryInstructions());
                ps.setString(idx++, rfq.getPaymentMethod());
                if (hasShippingCarrier) {
                    ps.setString(idx++, rfq.getShippingCarrierId());
                    ps.setString(idx++, rfq.getShippingCarrierName());
                    ps.setString(idx++, rfq.getShippingServiceName());
                    if (rfq.getShippingFee() != null) {
                        ps.setBigDecimal(idx++, rfq.getShippingFee());
                    } else {
                        ps.setNull(idx++, Types.DECIMAL);
                    }
                    ps.setInt(idx++, rfq.getEstimatedDeliveryDays());
                }
                ps.setString(idx++, RFQ.STATUS_PENDING);
                ps.setString(idx++, rfq.getCustomerNotes());
                
                ps.executeUpdate();
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    rfqID = rs.getInt(1);
                } else {
                    throw new SQLException("Failed to get generated RFQID");
                }
            }
            
            // 3. Insert RFQ Items
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
            
            // 4. Insert History
            insertHistory(conn, rfqID, null, RFQ.STATUS_PENDING, "RFQ Created", 
                         "Khách hàng tạo yêu cầu báo giá", rfq.getCustomerID(), "customer");
            
            conn.commit();
            return rfqID;
            
        } catch (SQLException e) {
            lastError = "SQL Error: " + e.getMessage() + " (Code: " + e.getErrorCode() + ", State: " + e.getSQLState() + ")";
            System.err.println("[RFQDAO] createRFQ failed: " + e.getMessage());
            System.err.println("[RFQDAO] SQL State: " + e.getSQLState());
            System.err.println("[RFQDAO] Error Code: " + e.getErrorCode());
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) {}
            }
            return -1;
        } finally {
            closeConnection(conn);
        }
    }

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
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return null;
    }

    /**
     * Lấy danh sách RFQ Items
     */
    public List<RFQItem> getRFQItems(int rfqID) {
        List<RFQItem> items = new ArrayList<>();
        String sql = "SELECT ri.*, p.ProductName as PName, pv.SKU as VSKU, " +
                    "(SELECT TOP 1 pi.ImageURL FROM ProductImages pi WHERE pi.ProductID = ri.ProductID AND pi.ImageType = 'main' ORDER BY pi.SortOrder) as ProductImage " +
                    "FROM RFQItems ri " +
                    "LEFT JOIN Products p ON ri.ProductID = p.ProductID " +
                    "LEFT JOIN ProductVariants pv ON ri.VariantID = pv.VariantID " +
                    "WHERE ri.RFQID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rfqID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                items.add(mapResultSetToRFQItem(rs));
            }
        } catch (SQLException e) {
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return items;
    }

    /**
     * Tìm kiếm RFQ với filters (backward compatible)
     */
    public List<RFQ> searchRFQs(String keyword, String status, Integer assignedTo, 
                                 Integer customerID, int page, int pageSize) {
        return searchRFQs(keyword, status, assignedTo, customerID, null, page, pageSize);
    }
    
    /**
     * Tìm kiếm RFQ với filters bao gồm paymentMethod
     */
    public List<RFQ> searchRFQs(String keyword, String status, Integer assignedTo, 
                                 Integer customerID, String paymentMethod, int page, int pageSize) {
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
                // Special case: unassigned RFQs
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
        if (paymentMethod != null && !paymentMethod.isEmpty()) {
            sql.append("AND r.PaymentMethod = ? ");
            params.add(paymentMethod);
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
                RFQ rfq = mapResultSetToRFQ(rs);
                System.out.println("[RFQDAO] Found RFQ: " + rfq.getRfqCode() + " - Status: " + rfq.getStatus());
                rfqs.add(rfq);
            }
        } catch (SQLException e) {
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
            e.printStackTrace();
        }
        System.out.println("[RFQDAO] searchRFQs returned " + rfqs.size() + " results");
        return rfqs;
    }

    /**
     * Đếm tổng số RFQ theo filter (backward compatible)
     */
    public int countRFQs(String keyword, String status, Integer assignedTo, Integer customerID) {
        return countRFQs(keyword, status, assignedTo, customerID, null);
    }
    
    /**
     * Đếm tổng số RFQ theo filter bao gồm paymentMethod
     */
    public int countRFQs(String keyword, String status, Integer assignedTo, Integer customerID, String paymentMethod) {
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
        if (paymentMethod != null && !paymentMethod.isEmpty()) {
            sql.append("AND r.PaymentMethod = ? ");
            params.add(paymentMethod);
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
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Lấy thống kê RFQ theo status
     */
    public int[] getRFQStatistics() {
        int[] stats = new int[4]; // [pending, reviewing, quoted, completed]
        String sql = "SELECT Status, COUNT(*) as Cnt FROM RFQs GROUP BY Status";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String status = rs.getString("Status");
                int count = rs.getInt("Cnt");
                switch (status) {
                    case RFQ.STATUS_PENDING: stats[0] = count; break;
                    case RFQ.STATUS_REVIEWING:
                    case RFQ.STATUS_DATE_PROPOSED:
                    case RFQ.STATUS_DATE_ACCEPTED: stats[1] += count; break;
                    case RFQ.STATUS_QUOTED: stats[2] = count; break;
                    case RFQ.STATUS_COMPLETED: stats[3] = count; break;
                }
            }
        } catch (SQLException e) {
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return stats;
    }


    /**
     * Assign RFQ cho employee
     */
    public boolean assignRFQ(int rfqID, int employeeID, int changedBy) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            RFQ rfq = getRFQById(rfqID);
            String oldStatus = rfq.getStatus();
            String newStatus = RFQ.STATUS_REVIEWING;
            
            String sql = "UPDATE RFQs SET AssignedTo = ?, Status = ?, UpdatedDate = GETDATE() WHERE RFQID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, employeeID);
                ps.setString(2, newStatus);
                ps.setInt(3, rfqID);
                ps.executeUpdate();
            }
            
            insertHistory(conn, rfqID, oldStatus, newStatus, "Assigned", 
                         "Phân công xử lý RFQ", changedBy, "employee");
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            closeConnection(conn);
        }
    }

    /**
     * Đề xuất ngày giao hàng mới
     */
    public boolean proposeDeliveryDate(int rfqID, Timestamp proposedDate, String reason, int employeeID) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            RFQ rfq = getRFQById(rfqID);
            String oldStatus = rfq.getStatus();
            
            // Check if DateChangeReason column exists
            boolean hasDateChangeReason = checkColumnExists(conn, "RFQs", "DateChangeReason");
            
            String sql;
            if (hasDateChangeReason) {
                sql = "UPDATE RFQs SET ProposedDeliveryDate = ?, DateChangeReason = ?, " +
                      "Status = ?, UpdatedDate = GETDATE() WHERE RFQID = ?";
            } else {
                sql = "UPDATE RFQs SET ProposedDeliveryDate = ?, " +
                      "Status = ?, UpdatedDate = GETDATE() WHERE RFQID = ?";
            }
            
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setTimestamp(1, proposedDate);
                if (hasDateChangeReason) {
                    ps.setString(2, reason);
                    ps.setString(3, RFQ.STATUS_DATE_PROPOSED);
                    ps.setInt(4, rfqID);
                } else {
                    ps.setString(2, RFQ.STATUS_DATE_PROPOSED);
                    ps.setInt(3, rfqID);
                }
                ps.executeUpdate();
            }
            
            insertHistory(conn, rfqID, oldStatus, RFQ.STATUS_DATE_PROPOSED, "Date Proposed", 
                         "Đề xuất ngày giao: " + proposedDate + ". Lý do: " + reason, employeeID, "employee");
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            closeConnection(conn);
        }
    }

    /**
     * Customer chấp nhận ngày mới
     */
    public boolean acceptProposedDate(int rfqID, int customerID) {
        return updateStatusWithHistory(rfqID, RFQ.STATUS_DATE_ACCEPTED, 
                "Date Accepted", "Khách hàng chấp nhận ngày giao mới", customerID, "customer");
    }

    /**
     * Customer từ chối ngày mới - Hủy đơn RFQ
     */
    public boolean rejectProposedDate(int rfqID, String reason, int customerID) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            RFQ rfq = getRFQById(rfqID);
            String oldStatus = rfq.getStatus();
            
            String sql = "UPDATE RFQs SET Status = ?, RejectionReason = ?, UpdatedDate = GETDATE() WHERE RFQID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, RFQ.STATUS_CANCELLED);
                ps.setString(2, reason);
                ps.setInt(3, rfqID);
                ps.executeUpdate();
            }
            
            insertHistory(conn, rfqID, oldStatus, RFQ.STATUS_CANCELLED, "Date Rejected", 
                         "Khách hàng từ chối ngày giao mới. Đơn đã hủy. Lý do: " + reason, customerID, "customer");
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            closeConnection(conn);
        }
    }

    /**
     * Gửi báo giá
     */
    public boolean sendQuotation(int rfqID, List<RFQItem> items, BigDecimal shippingFee, 
                                  BigDecimal taxAmount, Timestamp validUntil, 
                                  String paymentMethod, String quotationTerms, 
                                  String warrantyTerms, int employeeID) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            RFQ rfq = getRFQById(rfqID);
            String oldStatus = rfq.getStatus();
            
            // Calculate totals
            BigDecimal subtotal = BigDecimal.ZERO;
            for (RFQItem item : items) {
                item.calculateUnitPrice();
                subtotal = subtotal.add(item.getSubtotal());
            }
            BigDecimal total = subtotal.add(shippingFee != null ? shippingFee : BigDecimal.ZERO)
                                       .add(taxAmount != null ? taxAmount : BigDecimal.ZERO);
            
            // Check if PaymentMethod column exists
            boolean hasPaymentMethod = checkColumnExists(conn, "RFQs", "PaymentMethod");
            
            // Update RFQ
            String sql;
            if (hasPaymentMethod) {
                sql = "UPDATE RFQs SET SubtotalAmount = ?, ShippingFee = ?, TaxAmount = ?, " +
                      "TotalAmount = ?, QuotationSentDate = GETDATE(), QuotationValidUntil = ?, " +
                      "PaymentMethod = ?, QuotationTerms = ?, WarrantyTerms = ?, " +
                      "Status = ?, UpdatedDate = GETDATE() WHERE RFQID = ?";
            } else {
                sql = "UPDATE RFQs SET SubtotalAmount = ?, ShippingFee = ?, TaxAmount = ?, " +
                      "TotalAmount = ?, QuotationSentDate = GETDATE(), QuotationValidUntil = ?, " +
                      "QuotationTerms = ?, WarrantyTerms = ?, " +
                      "Status = ?, UpdatedDate = GETDATE() WHERE RFQID = ?";
            }
            
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setBigDecimal(1, subtotal);
                ps.setBigDecimal(2, shippingFee);
                ps.setBigDecimal(3, taxAmount);
                ps.setBigDecimal(4, total);
                ps.setTimestamp(5, validUntil);
                if (hasPaymentMethod) {
                    ps.setString(6, paymentMethod);
                    ps.setString(7, quotationTerms);
                    ps.setString(8, warrantyTerms);
                    ps.setString(9, RFQ.STATUS_QUOTED);
                    ps.setInt(10, rfqID);
                } else {
                    ps.setString(6, quotationTerms);
                    ps.setString(7, warrantyTerms);
                    ps.setString(8, RFQ.STATUS_QUOTED);
                    ps.setInt(9, rfqID);
                }
                ps.executeUpdate();
            }
            
            // Check if Notes column exists in RFQItems
            boolean hasNotes = checkColumnExists(conn, "RFQItems", "Notes");
            
            // Update RFQ Items with pricing
            String itemSql;
            if (hasNotes) {
                itemSql = "UPDATE RFQItems SET CostPrice = ?, ProfitMarginPercent = ?, " +
                          "UnitPrice = ?, Subtotal = ?, Notes = ? WHERE RFQItemID = ?";
            } else {
                itemSql = "UPDATE RFQItems SET CostPrice = ?, ProfitMarginPercent = ?, " +
                          "UnitPrice = ?, Subtotal = ? WHERE RFQItemID = ?";
            }
            
            try (PreparedStatement ps = conn.prepareStatement(itemSql)) {
                for (RFQItem item : items) {
                    ps.setBigDecimal(1, item.getCostPrice());
                    ps.setBigDecimal(2, item.getProfitMarginPercent());
                    ps.setBigDecimal(3, item.getUnitPrice());
                    ps.setBigDecimal(4, item.getSubtotal());
                    if (hasNotes) {
                        ps.setString(5, item.getNotes());
                        ps.setInt(6, item.getRfqItemID());
                    } else {
                        ps.setInt(5, item.getRfqItemID());
                    }
                    ps.addBatch();
                }
                ps.executeBatch();
            }
            
            // Format total amount without decimal places
            String formattedTotal = String.format("%,.0f", total);
            insertHistory(conn, rfqID, oldStatus, RFQ.STATUS_QUOTED, "Quotation Sent", 
                         "Gửi báo giá: " + formattedTotal + " VND", employeeID, "employee");
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            closeConnection(conn);
        }
    }

    /**
     * Customer chấp nhận báo giá
     */
    public boolean acceptQuotation(int rfqID, int customerID) {
        return updateStatusWithHistory(rfqID, RFQ.STATUS_QUOTE_ACCEPTED, 
                "Quote Accepted", "Khách hàng chấp nhận báo giá", customerID, "customer");
    }

    /**
     * Customer từ chối báo giá
     */
    public boolean rejectQuotation(int rfqID, String reason, int customerID) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            RFQ rfq = getRFQById(rfqID);
            String oldStatus = rfq.getStatus();
            
            String sql = "UPDATE RFQs SET Status = ?, RejectionReason = ?, UpdatedDate = GETDATE() WHERE RFQID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, RFQ.STATUS_QUOTE_REJECTED);
                ps.setString(2, reason);
                ps.setInt(3, rfqID);
                ps.executeUpdate();
            }
            
            insertHistory(conn, rfqID, oldStatus, RFQ.STATUS_QUOTE_REJECTED, "Quote Rejected", 
                         "Khách hàng từ chối báo giá. Lý do: " + reason, customerID, "customer");
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            closeConnection(conn);
        }
    }

    /**
     * Hoàn thành RFQ (sau khi checkout)
     */
    // Store last error for debugging
    private String lastCompleteError = null;
    
    public String getLastCompleteError() {
        return lastCompleteError;
    }
    
    public boolean completeRFQ(int rfqID, int orderID) {
        return completeRFQ(rfqID, orderID, null, null);
    }
    
    public boolean completeRFQ(int rfqID, int orderID, java.math.BigDecimal paymentAmount, String transactionNo) {
        Connection conn = null;
        lastCompleteError = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            // Get old status and total amount
            String oldStatus = "Quoted";
            java.math.BigDecimal totalAmount = null;
            String getStatusSql = "SELECT Status, TotalAmount FROM RFQs WHERE RFQID = ?";
            try (PreparedStatement ps = conn.prepareStatement(getStatusSql)) {
                ps.setInt(1, rfqID);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        oldStatus = rs.getString("Status");
                        totalAmount = rs.getBigDecimal("TotalAmount");
                    }
                }
            }
            
            // Use totalAmount if paymentAmount not provided
            if (paymentAmount == null && totalAmount != null) {
                paymentAmount = totalAmount;
            }
            
            System.out.println("[RFQDAO.completeRFQ] RFQID: " + rfqID + ", OldStatus: " + oldStatus + ", OrderID: " + orderID);
            
            String sql = "UPDATE RFQs SET Status = ?, UpdatedDate = GETDATE() WHERE RFQID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, RFQ.STATUS_COMPLETED);
                ps.setInt(2, rfqID);
                int rowsUpdated = ps.executeUpdate();
                System.out.println("[RFQDAO.completeRFQ] Rows updated: " + rowsUpdated);
                if (rowsUpdated == 0) {
                    lastCompleteError = "No rows updated - RFQID may not exist";
                    conn.rollback();
                    return false;
                }
            }
            
            // Insert payment history
            try {
                String historySql = "INSERT INTO RFQHistory (RFQID, OldStatus, NewStatus, Action, Notes, ChangedBy, ChangedByType, ChangedDate) " +
                                   "VALUES (?, ?, ?, ?, ?, 0, 'customer', GETDATE())";
                try (PreparedStatement historyPs = conn.prepareStatement(historySql)) {
                    historyPs.setInt(1, rfqID);
                    historyPs.setString(2, oldStatus);
                    historyPs.setString(3, RFQ.STATUS_COMPLETED);
                    historyPs.setString(4, "Payment Received");
                    
                    // Format payment amount
                    String notes;
                    if (paymentAmount != null) {
                        java.text.NumberFormat formatter = java.text.NumberFormat.getInstance(new java.util.Locale("vi", "VN"));
                        notes = "Khách hàng đã thanh toán: " + formatter.format(paymentAmount) + " đ";
                        if (transactionNo != null && !transactionNo.isEmpty()) {
                            notes += " (Mã GD: " + transactionNo + ")";
                        }
                        if (orderID > 0) {
                            notes += ". Đơn hàng #" + orderID + " đã được tạo.";
                        }
                    } else {
                        notes = "RFQ hoàn thành. Order ID: " + orderID;
                    }
                    
                    historyPs.setString(5, notes);
                    historyPs.executeUpdate();
                }
            } catch (SQLException historyEx) {
                System.err.println("[RFQDAO.completeRFQ] History insert failed (non-fatal): " + historyEx.getMessage());
            }
            
            conn.commit();
            System.out.println("[RFQDAO.completeRFQ] Committed successfully");
            return true;
        } catch (SQLException e) {
            lastCompleteError = "SQL Error: " + e.getMessage() + " (Code: " + e.getErrorCode() + ", State: " + e.getSQLState() + ")";
            System.err.println("[RFQDAO.completeRFQ] ERROR: " + lastCompleteError);
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            closeConnection(conn);
        }
    }
    
    /**
     * Hoàn thành RFQ sau khi thanh toán VNPay
     */
    public boolean completeRFQ(int rfqID, String transactionNo) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            RFQ rfq = getRFQById(rfqID);
            String oldStatus = rfq.getStatus();
            
            String sql = "UPDATE RFQs SET Status = ?, UpdatedDate = GETDATE() WHERE RFQID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, RFQ.STATUS_COMPLETED);
                ps.setInt(2, rfqID);
                ps.executeUpdate();
            }
            
            insertHistory(conn, rfqID, oldStatus, RFQ.STATUS_COMPLETED, "Completed", 
                         "Thanh toán thành công. Transaction: " + transactionNo, null, "system");
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            closeConnection(conn);
        }
    }
    
    /**
     * Cập nhật các báo giá đã hết hạn thành QuoteExpired
     * @return số lượng RFQ đã được cập nhật
     */
    public int expireQuotations() {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            // Find all quoted RFQs that have expired
            String selectSql = "SELECT RFQID FROM RFQs WHERE Status = ? AND QuotationValidUntil < GETDATE()";
            List<Integer> expiredIds = new ArrayList<>();
            
            try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                ps.setString(1, RFQ.STATUS_QUOTED);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    expiredIds.add(rs.getInt("RFQID"));
                }
            }
            
            if (expiredIds.isEmpty()) {
                conn.commit();
                return 0;
            }
            
            // Update status to QuoteExpired
            String updateSql = "UPDATE RFQs SET Status = ?, UpdatedDate = GETDATE() WHERE RFQID = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                for (int rfqId : expiredIds) {
                    ps.setString(1, RFQ.STATUS_QUOTE_EXPIRED);
                    ps.setInt(2, rfqId);
                    ps.addBatch();
                }
                ps.executeBatch();
            }
            
            // Insert history for each expired RFQ
            for (int rfqId : expiredIds) {
                insertHistory(conn, rfqId, RFQ.STATUS_QUOTED, RFQ.STATUS_QUOTE_EXPIRED, 
                             "Quote Expired", "Báo giá đã hết hạn", null, "system");
            }
            
            conn.commit();
            return expiredIds.size();
        } catch (SQLException e) {
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return 0;
        } finally {
            closeConnection(conn);
        }
    }
    
    /**
     * Kiểm tra và cập nhật nếu RFQ đã hết hạn báo giá
     * @return true nếu RFQ đã hết hạn và được cập nhật
     */
    public boolean checkAndExpireQuotation(int rfqID) {
        Connection conn = null;
        try {
            conn = getConnection();
            
            // Check if this RFQ is quoted and expired
            String checkSql = "SELECT 1 FROM RFQs WHERE RFQID = ? AND Status = ? AND QuotationValidUntil < GETDATE()";
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, rfqID);
                ps.setString(2, RFQ.STATUS_QUOTED);
                ResultSet rs = ps.executeQuery();
                if (!rs.next()) {
                    return false; // Not expired
                }
            }
            
            conn.setAutoCommit(false);
            
            // Update status
            String updateSql = "UPDATE RFQs SET Status = ?, UpdatedDate = GETDATE() WHERE RFQID = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, RFQ.STATUS_QUOTE_EXPIRED);
                ps.setInt(2, rfqID);
                ps.executeUpdate();
            }
            
            insertHistory(conn, rfqID, RFQ.STATUS_QUOTED, RFQ.STATUS_QUOTE_EXPIRED, 
                         "Quote Expired", "Báo giá đã hết hạn", null, "system");
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            closeConnection(conn);
        }
    }

    /**
     * Lấy RFQ theo mã code
     */
    public RFQ getRFQByCode(String rfqCode) {
        String sql = "SELECT * FROM RFQs WHERE RFQCode = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, rfqCode);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                RFQ rfq = mapResultSetToRFQ(rs);
                rfq.setItems(getRFQItems(rfq.getRfqID()));
                return rfq;
            }
        } catch (SQLException e) {
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return null;
    }

    /**
     * Lấy lịch sử RFQ
     */
    public List<RFQHistory> getRFQHistory(int rfqID) {
        List<RFQHistory> history = new ArrayList<>();
        String sql = "SELECT * FROM RFQHistory WHERE RFQID = ? ORDER BY ChangedDate DESC";
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
                h.setChangedBy(rs.getInt("ChangedBy"));
                if (rs.wasNull()) h.setChangedBy(null);
                h.setChangedByType(rs.getString("ChangedByType"));
                h.setChangedDate(rs.getTimestamp("ChangedDate"));
                history.add(h);
            }
        } catch (SQLException e) {
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return history;
    }

    /**
     * Danh sách đơn báo giá (có filter keyword + status)
     * - Nếu status null: lấy các trạng thái liên quan báo giá (Quoted, QuoteAccepted, QuoteRejected)
     * - Nếu status không null: lọc chính xác trạng thái
     */
    public List<RFQ> getQuotations(String keyword, String status, int page, int pageSize) {
        List<RFQ> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT r.*, c.FullName as CustomerName, e.FullName as AssignedName ");
        sql.append("FROM RFQs r ");
        sql.append("LEFT JOIN Customers c ON r.CustomerID = c.CustomerID ");
        sql.append("LEFT JOIN Employees e ON r.AssignedTo = e.EmployeeID ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        // Chỉ lấy các trạng thái liên quan báo giá
        if (status == null || status.isEmpty()) {
            sql.append("AND r.Status IN (?, ?, ?) ");
            params.add(RFQ.STATUS_QUOTED);
            params.add(RFQ.STATUS_QUOTE_REJECTED);
            params.add(RFQ.STATUS_COMPLETED);
        } else {
            sql.append("AND r.Status = ? ");
            params.add(status);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            String kw = "%" + keyword.trim() + "%";
            sql.append("AND (r.RFQCode LIKE ? OR r.CompanyName LIKE ? OR c.FullName LIKE ?) ");
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        sql.append("ORDER BY r.CreatedDate DESC ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int idx = 1;
            for (Object p : params) {
                if (p instanceof String) ps.setString(idx++, (String) p);
            }
            ps.setInt(idx++, (page - 1) * pageSize);
            ps.setInt(idx, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToRFQ(rs));
                }
            }
        } catch (SQLException e) {
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return list;
    }

    /**
     * Đếm số đơn báo giá theo filter
     */
    public int countQuotations(String keyword, String status) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM RFQs r ");
        sql.append("LEFT JOIN Customers c ON r.CustomerID = c.CustomerID ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (status == null || status.isEmpty()) {
            sql.append("AND r.Status IN (?, ?, ?) ");
            params.add(RFQ.STATUS_QUOTED);
            params.add(RFQ.STATUS_QUOTE_REJECTED);
            params.add(RFQ.STATUS_COMPLETED);
        } else {
            sql.append("AND r.Status = ? ");
            params.add(status);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            String kw = "%" + keyword.trim() + "%";
            sql.append("AND (r.RFQCode LIKE ? OR r.CompanyName LIKE ? OR c.FullName LIKE ?) ");
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int idx = 1;
            for (Object p : params) {
                if (p instanceof String) ps.setString(idx++, (String) p);
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return 0;
    }

    /**
     * Lấy giá vốn trung bình của variant
     */
    public BigDecimal getWeightedAverageCost(int variantID) {
        String sql = "SELECT SUM(Quantity * UnitCost) / NULLIF(SUM(Quantity), 0) as AvgCost " +
                    "FROM StockReceipts WHERE VariantID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, variantID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                BigDecimal cost = rs.getBigDecimal("AvgCost");
                return cost != null ? cost : BigDecimal.ZERO;
            }
        } catch (SQLException e) {
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return BigDecimal.ZERO;
    }
    
    /**
     * Lấy % lợi nhuận mong muốn (ProfitMarginTarget) của variant từ quản lý kho
     * Default là 30% nếu chưa thiết lập
     */
    public BigDecimal getProfitMarginTarget(int variantID) {
        String sql = "SELECT ProfitMarginTarget FROM ProductVariants WHERE VariantID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, variantID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                BigDecimal target = rs.getBigDecimal("ProfitMarginTarget");
                return target != null ? target : new BigDecimal("30");
            }
        } catch (SQLException e) {
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return new BigDecimal("30"); // Default 30%
    }

    // ==================== HELPER METHODS ====================

    private String generateRFQCode(Connection conn) throws SQLException {
        String prefix = "RFQ-";
        int year = java.time.Year.now().getValue();
        // Get MAX number from existing RFQ codes for this year
        String sql = "SELECT ISNULL(MAX(CAST(RIGHT(RFQCode, 5) AS INT)), 0) + 1 as NextNum " +
                     "FROM RFQs WHERE RFQCode LIKE ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, prefix + year + "-%");
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int nextNum = rs.getInt("NextNum");
                return prefix + year + "-" + String.format("%05d", nextNum);
            }
        }
        return prefix + year + "-" + String.format("%05d", 1);
    }

    private boolean updateStatusWithHistory(int rfqID, String newStatus, String action, 
                                            String notes, Integer changedBy, String changedByType) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            RFQ rfq = getRFQById(rfqID);
            String oldStatus = rfq.getStatus();
            
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
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            closeConnection(conn);
        }
    }

    private void insertHistory(Connection conn, int rfqID, String oldStatus, String newStatus, 
                               String action, String notes, Integer changedBy, String changedByType) throws SQLException {
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

    private void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (SQLException e) {
                Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
            }
        }
    }

    /**
     * Check if a column exists in the ResultSet
     */
    private boolean hasColumn(ResultSet rs, String columnName) {
        try {
            ResultSetMetaData meta = rs.getMetaData();
            int columns = meta.getColumnCount();
            for (int i = 1; i <= columns; i++) {
                if (columnName.equalsIgnoreCase(meta.getColumnName(i))) {
                    return true;
                }
            }
        } catch (SQLException e) {
            // Ignore
        }
        return false;
    }

    /**
     * Check if a column exists in a table
     */
    private boolean checkColumnExists(Connection conn, String tableName, String columnName) {
        // Thêm schema prefix 'dbo.' nếu chưa có để OBJECT_ID() hoạt động đúng
        String fullTableName = tableName.contains(".") ? tableName : "dbo." + tableName;
        String sql = "SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(?) AND name = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullTableName);
            ps.setString(2, columnName);
            ResultSet rs = ps.executeQuery();
            boolean exists = rs.next();
            System.out.println("[RFQDAO] checkColumnExists: " + fullTableName + "." + columnName + " = " + exists);
            return exists;
        } catch (SQLException e) {
            System.err.println("[RFQDAO] checkColumnExists error: " + e.getMessage());
            return false;
        }
    }

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
        // Delivery IDs may not exist in older databases
        if (hasColumn(rs, "DeliveryCityId")) {
            rfq.setDeliveryCityId(rs.getString("DeliveryCityId"));
        }
        if (hasColumn(rs, "DeliveryDistrictId")) {
            rfq.setDeliveryDistrictId(rs.getString("DeliveryDistrictId"));
        }
        if (hasColumn(rs, "DeliveryWardId")) {
            rfq.setDeliveryWardId(rs.getString("DeliveryWardId"));
        }
        rfq.setRequestedDeliveryDate(rs.getTimestamp("RequestedDeliveryDate"));
        rfq.setProposedDeliveryDate(rs.getTimestamp("ProposedDeliveryDate"));
        rfq.setDeliveryInstructions(rs.getString("DeliveryInstructions"));
        rfq.setSubtotalAmount(rs.getBigDecimal("SubtotalAmount"));
        rfq.setShippingFee(rs.getBigDecimal("ShippingFee"));
        rfq.setTaxAmount(rs.getBigDecimal("TaxAmount"));
        rfq.setTotalAmount(rs.getBigDecimal("TotalAmount"));
        rfq.setQuotationSentDate(rs.getTimestamp("QuotationSentDate"));
        rfq.setQuotationValidUntil(rs.getTimestamp("QuotationValidUntil"));
        rfq.setQuotationTerms(rs.getString("QuotationTerms"));
        rfq.setWarrantyTerms(rs.getString("WarrantyTerms"));
        // PaymentMethod may not exist in older databases
        if (hasColumn(rs, "PaymentMethod")) {
            rfq.setPaymentMethod(rs.getString("PaymentMethod"));
        }
        // Shipping carrier fields may not exist in older databases
        if (hasColumn(rs, "ShippingCarrierId")) {
            rfq.setShippingCarrierId(rs.getString("ShippingCarrierId"));
        }
        if (hasColumn(rs, "ShippingCarrierName")) {
            rfq.setShippingCarrierName(rs.getString("ShippingCarrierName"));
        }
        if (hasColumn(rs, "ShippingServiceName")) {
            rfq.setShippingServiceName(rs.getString("ShippingServiceName"));
        }
        if (hasColumn(rs, "EstimatedDeliveryDays")) {
            rfq.setEstimatedDeliveryDays(rs.getInt("EstimatedDeliveryDays"));
        }
        rfq.setStatus(rs.getString("Status"));
        int assignedTo = rs.getInt("AssignedTo");
        rfq.setAssignedTo(rs.wasNull() ? null : assignedTo);
        rfq.setCustomerNotes(rs.getString("CustomerNotes"));
        rfq.setSellerNotes(rs.getString("SellerNotes"));
        rfq.setRejectionReason(rs.getString("RejectionReason"));
        // DateChangeReason may not exist in older databases
        if (hasColumn(rs, "DateChangeReason")) {
            rfq.setDateChangeReason(rs.getString("DateChangeReason"));
        }
        rfq.setCreatedDate(rs.getTimestamp("CreatedDate"));
        rfq.setUpdatedDate(rs.getTimestamp("UpdatedDate"));
        return rfq;
    }

    // ==================== DRAFT RFQ METHODS ====================
    
    /**
     * Tạo Draft RFQ (chưa gửi, chỉ lưu nháp)
     */
    public int createDraftRFQ(RFQ rfq, List<RFQItem> items) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            String rfqCode = generateRFQCode(conn);
            boolean hasDeliveryIds = checkColumnExists(conn, "RFQs", "DeliveryCityId");
            boolean hasShippingCarrier = checkColumnExists(conn, "RFQs", "ShippingCarrierId");
            
            String sql;
            if (hasDeliveryIds && hasShippingCarrier) {
                sql = "INSERT INTO RFQs (RFQCode, CustomerID, CompanyName, TaxID, BusinessType, " +
                      "ContactPerson, ContactPhone, ContactEmail, AlternativeContact, " +
                      "DeliveryAddress, DeliveryCityId, DeliveryDistrictId, DeliveryWardId, " +
                      "RequestedDeliveryDate, DeliveryInstructions, PaymentMethod, " +
                      "ShippingCarrierId, ShippingCarrierName, ShippingServiceName, ShippingFee, EstimatedDeliveryDays, " +
                      "Status, CustomerNotes, CreatedDate, UpdatedDate) " +
                      "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";
            } else {
                sql = "INSERT INTO RFQs (RFQCode, CustomerID, CompanyName, TaxID, BusinessType, " +
                      "ContactPerson, ContactPhone, ContactEmail, AlternativeContact, " +
                      "DeliveryAddress, RequestedDeliveryDate, DeliveryInstructions, PaymentMethod, " +
                      "Status, CustomerNotes, CreatedDate, UpdatedDate) " +
                      "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";
            }
            
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
                if (hasDeliveryIds) {
                    ps.setString(idx++, rfq.getDeliveryCityId());
                    ps.setString(idx++, rfq.getDeliveryDistrictId());
                    ps.setString(idx++, rfq.getDeliveryWardId());
                }
                ps.setTimestamp(idx++, rfq.getRequestedDeliveryDate());
                ps.setString(idx++, rfq.getDeliveryInstructions());
                ps.setString(idx++, rfq.getPaymentMethod());
                if (hasShippingCarrier) {
                    ps.setString(idx++, rfq.getShippingCarrierId());
                    ps.setString(idx++, rfq.getShippingCarrierName());
                    ps.setString(idx++, rfq.getShippingServiceName());
                    if (rfq.getShippingFee() != null) {
                        ps.setBigDecimal(idx++, rfq.getShippingFee());
                    } else {
                        ps.setNull(idx++, Types.DECIMAL);
                    }
                    ps.setInt(idx++, rfq.getEstimatedDeliveryDays());
                }
                ps.setString(idx++, RFQ.STATUS_DRAFT);
                ps.setString(idx++, rfq.getCustomerNotes());
                
                ps.executeUpdate();
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    rfqID = rs.getInt(1);
                } else {
                    throw new SQLException("Failed to get generated RFQID");
                }
            }
            
            // Insert RFQ Items
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
            
            conn.commit();
            return rfqID;
            
        } catch (SQLException e) {
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) {}
            }
            return -1;
        } finally {
            closeConnection(conn);
        }
    }
    
    /**
     * Cập nhật Draft RFQ
     */
    public boolean updateDraftRFQ(int rfqID, RFQ rfq, List<RFQItem> items) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            boolean hasDeliveryIds = checkColumnExists(conn, "RFQs", "DeliveryCityId");
            boolean hasShippingCarrier = checkColumnExists(conn, "RFQs", "ShippingCarrierId");
            
            StringBuilder sql = new StringBuilder("UPDATE RFQs SET ");
            sql.append("CompanyName = ?, TaxID = ?, BusinessType = ?, ");
            sql.append("ContactPerson = ?, ContactPhone = ?, ContactEmail = ?, AlternativeContact = ?, ");
            sql.append("DeliveryAddress = ?, ");
            if (hasDeliveryIds) {
                sql.append("DeliveryCityId = ?, DeliveryDistrictId = ?, DeliveryWardId = ?, ");
            }
            sql.append("RequestedDeliveryDate = ?, DeliveryInstructions = ?, PaymentMethod = ?, ");
            if (hasShippingCarrier) {
                sql.append("ShippingCarrierId = ?, ShippingCarrierName = ?, ShippingServiceName = ?, ShippingFee = ?, EstimatedDeliveryDays = ?, ");
            }
            sql.append("CustomerNotes = ?, UpdatedDate = GETDATE() WHERE RFQID = ? AND Status = ?");
            
            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                int idx = 1;
                ps.setString(idx++, rfq.getCompanyName());
                ps.setString(idx++, rfq.getTaxID());
                ps.setString(idx++, rfq.getBusinessType());
                ps.setString(idx++, rfq.getContactPerson());
                ps.setString(idx++, rfq.getContactPhone());
                ps.setString(idx++, rfq.getContactEmail());
                ps.setString(idx++, rfq.getAlternativeContact());
                ps.setString(idx++, rfq.getDeliveryAddress());
                if (hasDeliveryIds) {
                    ps.setString(idx++, rfq.getDeliveryCityId());
                    ps.setString(idx++, rfq.getDeliveryDistrictId());
                    ps.setString(idx++, rfq.getDeliveryWardId());
                }
                ps.setTimestamp(idx++, rfq.getRequestedDeliveryDate());
                ps.setString(idx++, rfq.getDeliveryInstructions());
                ps.setString(idx++, rfq.getPaymentMethod());
                if (hasShippingCarrier) {
                    ps.setString(idx++, rfq.getShippingCarrierId());
                    ps.setString(idx++, rfq.getShippingCarrierName());
                    ps.setString(idx++, rfq.getShippingServiceName());
                    if (rfq.getShippingFee() != null) {
                        ps.setBigDecimal(idx++, rfq.getShippingFee());
                    } else {
                        ps.setNull(idx++, Types.DECIMAL);
                    }
                    ps.setInt(idx++, rfq.getEstimatedDeliveryDays());
                }
                ps.setString(idx++, rfq.getCustomerNotes());
                ps.setInt(idx++, rfqID);
                ps.setString(idx++, RFQ.STATUS_DRAFT);
                ps.executeUpdate();
            }
            
            // Delete old items and insert new ones
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM RFQItems WHERE RFQID = ?")) {
                ps.setInt(1, rfqID);
                ps.executeUpdate();
            }
            
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
            
            conn.commit();
            return true;
            
        } catch (SQLException e) {
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) {}
            }
            return false;
        } finally {
            closeConnection(conn);
        }
    }
    
    /**
     * Submit Draft RFQ - chuyển từ Draft sang Pending
     */
    public boolean submitDraftRFQ(int rfqID) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            String sql = "UPDATE RFQs SET Status = ?, UpdatedDate = GETDATE() WHERE RFQID = ? AND Status = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, RFQ.STATUS_PENDING);
                ps.setInt(2, rfqID);
                ps.setString(3, RFQ.STATUS_DRAFT);
                int updated = ps.executeUpdate();
                if (updated == 0) {
                    return false;
                }
            }
            
            insertHistory(conn, rfqID, RFQ.STATUS_DRAFT, RFQ.STATUS_PENDING, "RFQ Submitted", 
                         "Khách hàng gửi yêu cầu báo giá", null, "customer");
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            closeConnection(conn);
        }
    }

    // ==================== CUSTOMER QUOTATION METHODS ====================
    
    /**
     * Lấy danh sách đơn báo giá của customer (status: Quoted, Completed, QuoteRejected)
     */
    public List<RFQ> getCustomerQuotations(int customerID, String keyword, String status, int page, int pageSize) {
        List<RFQ> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT r.*, c.FullName as CustomerName ");
        sql.append("FROM RFQs r ");
        sql.append("LEFT JOIN Customers c ON r.CustomerID = c.CustomerID ");
        sql.append("WHERE r.CustomerID = ? ");

        List<Object> params = new ArrayList<>();
        params.add(customerID);

        // Chỉ lấy các trạng thái liên quan báo giá
        if (status == null || status.isEmpty()) {
            sql.append("AND r.Status IN (?, ?, ?) ");
            params.add(RFQ.STATUS_QUOTED);
            params.add(RFQ.STATUS_QUOTE_REJECTED);
            params.add(RFQ.STATUS_COMPLETED);
        } else {
            sql.append("AND r.Status = ? ");
            params.add(status);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            String kw = "%" + keyword.trim() + "%";
            sql.append("AND (r.RFQCode LIKE ? OR r.CompanyName LIKE ?) ");
            params.add(kw);
            params.add(kw);
        }

        sql.append("ORDER BY r.CreatedDate DESC ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int idx = 1;
            for (Object p : params) {
                if (p instanceof Integer) ps.setInt(idx++, (Integer) p);
                else if (p instanceof String) ps.setString(idx++, (String) p);
            }
            ps.setInt(idx++, (page - 1) * pageSize);
            ps.setInt(idx, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToRFQ(rs));
                }
            }
        } catch (SQLException e) {
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return list;
    }

    /**
     * Đếm số đơn báo giá của customer theo filter
     */
    public int countCustomerQuotations(int customerID, String keyword, String status) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM RFQs r ");
        sql.append("WHERE r.CustomerID = ? ");

        List<Object> params = new ArrayList<>();
        params.add(customerID);

        if (status == null || status.isEmpty()) {
            sql.append("AND r.Status IN (?, ?, ?) ");
            params.add(RFQ.STATUS_QUOTED);
            params.add(RFQ.STATUS_QUOTE_REJECTED);
            params.add(RFQ.STATUS_COMPLETED);
        } else {
            sql.append("AND r.Status = ? ");
            params.add(status);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            String kw = "%" + keyword.trim() + "%";
            sql.append("AND (r.RFQCode LIKE ? OR r.CompanyName LIKE ?) ");
            params.add(kw);
            params.add(kw);
        }

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int idx = 1;
            for (Object p : params) {
                if (p instanceof Integer) ps.setInt(idx++, (Integer) p);
                else if (p instanceof String) ps.setString(idx++, (String) p);
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return 0;
    }

    /**
     * Đếm số RFQ theo status
     */
    public int countRFQsByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM RFQs WHERE Status = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            Logger.getLogger(RFQDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return 0;
    }

    private RFQItem mapResultSetToRFQItem(ResultSet rs) throws SQLException {
        RFQItem item = new RFQItem();
        item.setRfqItemID(rs.getInt("RFQItemID"));
        item.setRfqID(rs.getInt("RFQID"));
        item.setProductID(rs.getInt("ProductID"));
        int variantID = rs.getInt("VariantID");
        item.setVariantID(rs.wasNull() ? null : variantID);
        item.setProductName(rs.getString("ProductName"));
        
        // Get SKU - prefer from RFQItems, fallback to ProductVariants (VSKU)
        String sku = rs.getString("SKU");
        if (sku == null || sku.isEmpty()) {
            if (hasColumn(rs, "VSKU")) {
                sku = rs.getString("VSKU");
            }
        }
        item.setSku(sku);
        
        // Get product image
        if (hasColumn(rs, "ProductImage")) {
            item.setProductImage(rs.getString("ProductImage"));
        }
        
        item.setQuantity(rs.getInt("Quantity"));
        item.setCostPrice(rs.getBigDecimal("CostPrice"));
        item.setProfitMarginPercent(rs.getBigDecimal("ProfitMarginPercent"));
        item.setUnitPrice(rs.getBigDecimal("UnitPrice"));
        item.setSubtotal(rs.getBigDecimal("Subtotal"));
        item.setSpecialRequirements(rs.getString("SpecialRequirements"));
        // Notes column may not exist in older databases
        if (hasColumn(rs, "Notes")) {
            item.setNotes(rs.getString("Notes"));
        }
        return item;
    }
}
