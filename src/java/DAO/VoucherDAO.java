/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DAO;

import entity.Voucher;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
/**
 *
 * @author xuand
 */
public class VoucherDAO extends DBContext {
    
    /**
     * Get all active vouchers
     */
    public List<Voucher> getActiveVouchers() {
        List<Voucher> list = new ArrayList<>();
        String sql = """
            SELECT VoucherID, VoucherCode, VoucherName, Description, DiscountType, 
                   DiscountValue, MinOrderValue, MaxDiscountAmount, MaxUsage, UsedCount,
                   StartDate, EndDate, IsActive, IsPrivate, CreatedBy, CreatedDate
            FROM Vouchers
            WHERE IsActive = 1 AND GETDATE() BETWEEN StartDate AND EndDate
            ORDER BY CreatedDate DESC
        """;
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                list.add(mapResultSetToVoucher(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error in getActiveVouchers: " + e.getMessage());
            e.printStackTrace();
        }
        
        return list;
    }
    
    /**
     * Get all active PUBLIC vouchers (not private) for checkout page
     */
    public List<Voucher> getActivePublicVouchers() {
        List<Voucher> list = new ArrayList<>();
        String sql = """
            SELECT VoucherID, VoucherCode, VoucherName, Description, DiscountType, 
                   DiscountValue, MinOrderValue, MaxDiscountAmount, MaxUsage, UsedCount,
                   StartDate, EndDate, IsActive, IsPrivate, CreatedBy, CreatedDate
            FROM Vouchers
            WHERE IsActive = 1 
              AND IsPrivate = 0 
              AND GETDATE() BETWEEN StartDate AND EndDate
              AND (MaxUsage IS NULL OR UsedCount < MaxUsage)
            ORDER BY DiscountValue DESC
        """;
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                list.add(mapResultSetToVoucher(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error in getActivePublicVouchers: " + e.getMessage());
            e.printStackTrace();
        }
        
        return list;
    }
    
    /**
     * Get all vouchers with pagination, search, filter and sort
     */
    public List<Voucher> getAllVouchers(String search, String status, String discountType, 
                                        String sortBy, String sortOrder, int page, int pageSize) {
        List<Voucher> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT VoucherID, VoucherCode, VoucherName, Description, DiscountType, ");
        sql.append("DiscountValue, MinOrderValue, MaxDiscountAmount, MaxUsage, UsedCount, ");
        sql.append("StartDate, EndDate, IsActive, IsPrivate, CreatedBy, CreatedDate ");
        sql.append("FROM Vouchers WHERE 1=1 ");
        
        // Search by code or name
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (VoucherCode LIKE ? OR VoucherName LIKE ?) ");
        }
        
        // Filter by active status
        if (status != null && !status.trim().isEmpty()) {
            if ("active".equals(status)) {
                sql.append("AND IsActive = 1 ");
            } else if ("inactive".equals(status)) {
                sql.append("AND IsActive = 0 ");
            }
        }
        
        // Filter by discount type
        if (discountType != null && !discountType.trim().isEmpty()) {
            sql.append("AND DiscountType = ? ");
        }
        
        // Sort
        if (sortBy != null && !sortBy.isEmpty()) {
            sql.append("ORDER BY ").append(sortBy);
            if (sortOrder != null && sortOrder.equalsIgnoreCase("DESC")) {
                sql.append(" DESC ");
            } else {
                sql.append(" ASC ");
            }
        } else {
            sql.append("ORDER BY CreatedDate DESC ");
        }
        
        // Pagination
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search.trim() + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            
            if (discountType != null && !discountType.trim().isEmpty()) {
                ps.setString(paramIndex++, discountType);
            }
            
            ps.setInt(paramIndex++, (page - 1) * pageSize);
            ps.setInt(paramIndex++, pageSize);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToVoucher(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error in getAllVouchers: " + e.getMessage());
            e.printStackTrace();
        }
        
        return list;
    }
    
    /**
     * Get total count for pagination
     */
    public int getTotalVouchers(String search, String status, String discountType) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Vouchers WHERE 1=1 ");
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (VoucherCode LIKE ? OR VoucherName LIKE ?) ");
        }
        
        if (status != null && !status.trim().isEmpty()) {
            if ("active".equals(status)) {
                sql.append("AND IsActive = 1 ");
            } else if ("inactive".equals(status)) {
                sql.append("AND IsActive = 0 ");
            }
        }
        
        if (discountType != null && !discountType.trim().isEmpty()) {
            sql.append("AND DiscountType = ? ");
        }
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search.trim() + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            
            if (discountType != null && !discountType.trim().isEmpty()) {
                ps.setString(paramIndex++, discountType);
            }
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("Error in getTotalVouchers: " + e.getMessage());
            e.printStackTrace();
        }
        
        return 0;
    }
    
    /**
     * Get voucher by ID
     */
    public Voucher getVoucherById(int id) {
        String sql = """
            SELECT VoucherID, VoucherCode, VoucherName, Description, DiscountType, 
                   DiscountValue, MinOrderValue, MaxDiscountAmount, MaxUsage, UsedCount,
                   StartDate, EndDate, IsActive, IsPrivate, CreatedBy, CreatedDate
            FROM Vouchers
            WHERE VoucherID = ?
        """;
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToVoucher(rs);
            }
        } catch (SQLException e) {
            System.err.println("Error in getVoucherById: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Get voucher by code
     */
    public Voucher getVoucherByCode(String code) {
        String sql = """
            SELECT VoucherID, VoucherCode, VoucherName, Description, DiscountType, 
                   DiscountValue, MinOrderValue, MaxDiscountAmount, MaxUsage, UsedCount,
                   StartDate, EndDate, IsActive, IsPrivate, CreatedBy, CreatedDate
            FROM Vouchers
            WHERE VoucherCode = ?
        """;
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, code);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToVoucher(rs);
            }
        } catch (SQLException e) {
            System.err.println("Error in getVoucherByCode: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Insert new voucher
     */
    public boolean insertVoucher(Voucher voucher) {
        String sql = """
            INSERT INTO Vouchers (VoucherCode, VoucherName, Description, DiscountType, 
                                  DiscountValue, MinOrderValue, MaxDiscountAmount, MaxUsage, 
                                  UsedCount, StartDate, EndDate, IsActive, IsPrivate, 
                                  CreatedBy, CreatedDate)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?, ?, ?, ?, GETDATE())
        """;
        
        System.out.println("=== INSERT VOUCHER DAO START ===");
        System.out.println("SQL: " + sql);
        System.out.println("Voucher: " + voucher.toString());
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            System.out.println("Connection obtained: " + (conn != null));
            
            ps.setString(1, voucher.getVoucherCode());
            ps.setString(2, voucher.getVoucherName());
            ps.setString(3, voucher.getDescription());
            ps.setString(4, voucher.getDiscountType());
            ps.setBigDecimal(5, voucher.getDiscountValue());
            ps.setBigDecimal(6, voucher.getMinOrderValue());
            
            if (voucher.getMaxDiscountAmount() != null) {
                ps.setBigDecimal(7, voucher.getMaxDiscountAmount());
            } else {
                ps.setNull(7, Types.DECIMAL);
            }
            
            if (voucher.getMaxUsage() != null) {
                ps.setInt(8, voucher.getMaxUsage());
            } else {
                ps.setNull(8, Types.INTEGER);
            }
            
            ps.setTimestamp(9, voucher.getStartDate());
            ps.setTimestamp(10, voucher.getEndDate());
            ps.setBoolean(11, voucher.isIsActive());
            ps.setBoolean(12, voucher.isIsPrivate());
            
            if (voucher.getCreatedBy() != null) {
                ps.setInt(13, voucher.getCreatedBy());
            } else {
                ps.setNull(13, Types.INTEGER);
            }
            
            System.out.println("Executing INSERT...");
            int rowsAffected = ps.executeUpdate();
            System.out.println("✅ Inserted voucher: " + voucher.getVoucherCode() + " - Rows affected: " + rowsAffected);
            System.out.println("=== INSERT VOUCHER DAO END ===");
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ SQL Error in insertVoucher:");
            System.err.println("   Error Code: " + e.getErrorCode());
            System.err.println("   SQL State: " + e.getSQLState());
            System.err.println("   Message: " + e.getMessage());
            e.printStackTrace();
            System.out.println("=== INSERT VOUCHER DAO END (ERROR) ===");
            return false;
        }
    }
    
    /**
     * Update voucher
     */
    public boolean updateVoucher(Voucher voucher) {
        String sql = """
            UPDATE Vouchers 
            SET VoucherCode = ?, VoucherName = ?, Description = ?, DiscountType = ?,
                DiscountValue = ?, MinOrderValue = ?, MaxDiscountAmount = ?, MaxUsage = ?,
                StartDate = ?, EndDate = ?, IsActive = ?, IsPrivate = ?
            WHERE VoucherID = ?
        """;
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, voucher.getVoucherCode());
            ps.setString(2, voucher.getVoucherName());
            ps.setString(3, voucher.getDescription());
            ps.setString(4, voucher.getDiscountType());
            ps.setBigDecimal(5, voucher.getDiscountValue());
            ps.setBigDecimal(6, voucher.getMinOrderValue());
            
            if (voucher.getMaxDiscountAmount() != null) {
                ps.setBigDecimal(7, voucher.getMaxDiscountAmount());
            } else {
                ps.setNull(7, Types.DECIMAL);
            }
            
            if (voucher.getMaxUsage() != null) {
                ps.setInt(8, voucher.getMaxUsage());
            } else {
                ps.setNull(8, Types.INTEGER);
            }
            
            ps.setTimestamp(9, voucher.getStartDate());
            ps.setTimestamp(10, voucher.getEndDate());
            ps.setBoolean(11, voucher.isIsActive());
            ps.setBoolean(12, voucher.isIsPrivate());
            ps.setInt(13, voucher.getVoucherID());
            
            int rowsAffected = ps.executeUpdate();
            System.out.println("✅ Updated voucher ID: " + voucher.getVoucherID() + " - Rows affected: " + rowsAffected);
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Error in updateVoucher: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Delete voucher
     */
    public boolean deleteVoucher(int id) {
        String sql = "DELETE FROM Vouchers WHERE VoucherID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            int rowsAffected = ps.executeUpdate();
            System.out.println("✅ Deleted voucher ID: " + id + " - Rows affected: " + rowsAffected);
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Error in deleteVoucher: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Toggle voucher active status
     */
    public boolean toggleVoucherStatus(int id) {
        String sql = "UPDATE Vouchers SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END WHERE VoucherID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            int rowsAffected = ps.executeUpdate();
            System.out.println("✅ Toggled voucher status ID: " + id + " - Rows affected: " + rowsAffected);
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Error in toggleVoucherStatus: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Increment used count when voucher is applied
     */
    public boolean incrementUsedCount(int voucherId) {
        String sql = "UPDATE Vouchers SET UsedCount = UsedCount + 1 WHERE VoucherID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, voucherId);
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Error in incrementUsedCount: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Check if voucher code already exists
     */
    public boolean isVoucherCodeExists(String code, Integer excludeId) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Vouchers WHERE VoucherCode = ?");
        if (excludeId != null) {
            sql.append(" AND VoucherID != ?");
        }
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            ps.setString(1, code);
            if (excludeId != null) {
                ps.setInt(2, excludeId);
            }
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("Error in isVoucherCodeExists: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Check if voucher is valid for use
     * @param voucher The voucher to check
     * @return true if voucher can be used, false otherwise
     */
    public boolean isVoucherValid(Voucher voucher) {
        if (voucher == null) {
            return false;
        }
        
        // Check if active
        if (!voucher.isIsActive()) {
            System.out.println("❌ Voucher is not active");
            return false;
        }
        
        // Check date range
        Timestamp now = new Timestamp(System.currentTimeMillis());
        if (now.before(voucher.getStartDate())) {
            System.out.println("❌ Voucher has not started yet");
            return false;
        }
        if (now.after(voucher.getEndDate())) {
            System.out.println("❌ Voucher has expired");
            return false;
        }
        
        // Check usage limit
        if (voucher.getMaxUsage() != null && voucher.getUsedCount() >= voucher.getMaxUsage()) {
            System.out.println("❌ Voucher usage limit reached");
            return false;
        }
        
        return true;
    }
    
    /**
     * Check if voucher can be applied to an order
     * @param voucherCode The voucher code
     * @param orderAmount The order amount
     * @return Voucher object if valid, null otherwise
     */
    public Voucher validateVoucherForOrder(String voucherCode, BigDecimal orderAmount) {
        Voucher voucher = getVoucherByCode(voucherCode);
        
        if (voucher == null) {
            System.out.println("❌ Voucher not found: " + voucherCode);
            return null;
        }
        
        // Check if voucher is valid
        if (!isVoucherValid(voucher)) {
            return null;
        }
        
        // Check minimum order value
        if (orderAmount.compareTo(voucher.getMinOrderValue()) < 0) {
            System.out.println("❌ Order amount is below minimum: " + voucher.getMinOrderValue());
            return null;
        }
        
        System.out.println("✅ Voucher is valid for order");
        return voucher;
    }
    
    /**
     * Calculate discount amount for an order
     * @param voucher The voucher to apply
     * @param orderAmount The order amount
     * @return Discount amount
     */
    public BigDecimal calculateDiscount(Voucher voucher, BigDecimal orderAmount) {
        if (voucher == null || orderAmount == null) {
            return BigDecimal.ZERO;
        }
        
        BigDecimal discount = BigDecimal.ZERO;
        
        if ("percentage".equals(voucher.getDiscountType())) {
            // Percentage discount
            discount = orderAmount.multiply(voucher.getDiscountValue())
                                  .divide(new BigDecimal("100"));
            
            // Apply max discount limit if exists
            if (voucher.getMaxDiscountAmount() != null && 
                discount.compareTo(voucher.getMaxDiscountAmount()) > 0) {
                discount = voucher.getMaxDiscountAmount();
            }
        } else if ("fixed".equals(voucher.getDiscountType())) {
            // Fixed amount discount
            discount = voucher.getDiscountValue();
            
            // Discount cannot exceed order amount
            if (discount.compareTo(orderAmount) > 0) {
                discount = orderAmount;
            }
        }
        
        return discount;
    }
    
    /**
     * Map ResultSet to Voucher object
     */
    private Voucher mapResultSetToVoucher(ResultSet rs) throws SQLException {
        Voucher voucher = new Voucher();
        voucher.setVoucherID(rs.getInt("VoucherID"));
        voucher.setVoucherCode(rs.getString("VoucherCode"));
        voucher.setVoucherName(rs.getString("VoucherName"));
        voucher.setDescription(rs.getString("Description"));
        voucher.setDiscountType(rs.getString("DiscountType"));
        voucher.setDiscountValue(rs.getBigDecimal("DiscountValue"));
        voucher.setMinOrderValue(rs.getBigDecimal("MinOrderValue"));
        voucher.setMaxDiscountAmount(rs.getBigDecimal("MaxDiscountAmount"));
        
        Integer maxUsage = (Integer) rs.getObject("MaxUsage");
        voucher.setMaxUsage(maxUsage);
        
        voucher.setUsedCount(rs.getInt("UsedCount"));
        voucher.setStartDate(rs.getTimestamp("StartDate"));
        voucher.setEndDate(rs.getTimestamp("EndDate"));
        voucher.setIsActive(rs.getBoolean("IsActive"));
        voucher.setIsPrivate(rs.getBoolean("IsPrivate"));
        
        Integer createdBy = (Integer) rs.getObject("CreatedBy");
        voucher.setCreatedBy(createdBy);
        
        voucher.setCreatedDate(rs.getTimestamp("CreatedDate"));
        
        return voucher;
    }
}

