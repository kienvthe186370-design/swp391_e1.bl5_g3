package DAO;

import entity.DiscountCampaign;
import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for DiscountCampaigns
 */
public class DiscountCampaignDAO extends DBContext {
    
    /**
     * Get all campaigns with pagination, search and filter
     */
    public List<DiscountCampaign> getAllCampaigns(String search, String status, String appliedToType, 
                                                   int page, int pageSize) {
        List<DiscountCampaign> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT dc.*, e.FullName AS CreatedByName, ");
        sql.append("CASE ");
        sql.append("  WHEN dc.AppliedToType = 'category' THEN c.CategoryName ");
        sql.append("  WHEN dc.AppliedToType = 'product' THEN p.ProductName ");
        sql.append("  WHEN dc.AppliedToType = 'brand' THEN b.BrandName ");
        sql.append("  ELSE NULL ");
        sql.append("END AS AppliedToName ");
        sql.append("FROM DiscountCampaigns dc ");
        sql.append("LEFT JOIN Employees e ON dc.CreatedBy = e.EmployeeID ");
        sql.append("LEFT JOIN Categories c ON dc.AppliedToType = 'category' AND dc.AppliedToID = c.CategoryID ");
        sql.append("LEFT JOIN Products p ON dc.AppliedToType = 'product' AND dc.AppliedToID = p.ProductID ");
        sql.append("LEFT JOIN Brands b ON dc.AppliedToType = 'brand' AND dc.AppliedToID = b.BrandID ");
        sql.append("WHERE 1=1 ");
        
        // Search by campaign name
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND dc.CampaignName LIKE ? ");
        }
        
        // Filter by status
        if (status != null && !status.trim().isEmpty()) {
            if ("active".equals(status)) {
                sql.append("AND dc.IsActive = 1 AND GETDATE() BETWEEN dc.StartDate AND dc.EndDate ");
            } else if ("inactive".equals(status)) {
                sql.append("AND dc.IsActive = 0 ");
            } else if ("upcoming".equals(status)) {
                sql.append("AND dc.IsActive = 1 AND GETDATE() < dc.StartDate ");
            } else if ("expired".equals(status)) {
                sql.append("AND GETDATE() > dc.EndDate ");
            }
        }
        
        // Filter by applied type
        if (appliedToType != null && !appliedToType.trim().isEmpty()) {
            sql.append("AND dc.AppliedToType = ? ");
        }
        
        // Sort by ID descending
        sql.append("ORDER BY dc.DiscountID DESC ");
        
        // Pagination
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            
            if (search != null && !search.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + search.trim() + "%");
            }
            
            if (appliedToType != null && !appliedToType.trim().isEmpty()) {
                ps.setString(paramIndex++, appliedToType);
            }
            
            ps.setInt(paramIndex++, (page - 1) * pageSize);
            ps.setInt(paramIndex++, pageSize);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToCampaign(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error in getAllCampaigns: " + e.getMessage());
            e.printStackTrace();
        }
        
        return list;
    }
    
    /**
     * Get total count for pagination
     */
    public int getTotalCampaigns(String search, String status, String appliedToType) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM DiscountCampaigns WHERE 1=1 ");
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND CampaignName LIKE ? ");
        }
        
        if (status != null && !status.trim().isEmpty()) {
            if ("active".equals(status)) {
                sql.append("AND IsActive = 1 AND GETDATE() BETWEEN StartDate AND EndDate ");
            } else if ("inactive".equals(status)) {
                sql.append("AND IsActive = 0 ");
            } else if ("upcoming".equals(status)) {
                sql.append("AND IsActive = 1 AND GETDATE() < StartDate ");
            } else if ("expired".equals(status)) {
                sql.append("AND GETDATE() > EndDate ");
            }
        }
        
        if (appliedToType != null && !appliedToType.trim().isEmpty()) {
            sql.append("AND AppliedToType = ? ");
        }
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            
            if (search != null && !search.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + search.trim() + "%");
            }
            
            if (appliedToType != null && !appliedToType.trim().isEmpty()) {
                ps.setString(paramIndex++, appliedToType);
            }
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("Error in getTotalCampaigns: " + e.getMessage());
            e.printStackTrace();
        }
        
        return 0;
    }
    
    /**
     * Get campaign by ID
     */
    public DiscountCampaign getCampaignById(int id) {
        String sql = "SELECT dc.*, e.FullName AS CreatedByName FROM DiscountCampaigns dc " +
                     "LEFT JOIN Employees e ON dc.CreatedBy = e.EmployeeID " +
                     "WHERE dc.DiscountID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToCampaign(rs);
            }
        } catch (SQLException e) {
            System.err.println("Error in getCampaignById: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Insert new campaign
     */
    public boolean insertCampaign(DiscountCampaign campaign) {
        String sql = "INSERT INTO DiscountCampaigns (CampaignName, DiscountType, DiscountValue, " +
                     "MaxDiscountAmount, AppliedToType, AppliedToID, StartDate, EndDate, " +
                     "IsActive, CreatedBy, CreatedDate) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, campaign.getCampaignName());
            ps.setString(2, campaign.getDiscountType());
            ps.setBigDecimal(3, campaign.getDiscountValue());
            
            if (campaign.getMaxDiscountAmount() != null) {
                ps.setBigDecimal(4, campaign.getMaxDiscountAmount());
            } else {
                ps.setNull(4, Types.DECIMAL);
            }
            
            ps.setString(5, campaign.getAppliedToType());
            
            if (campaign.getAppliedToID() != null) {
                ps.setInt(6, campaign.getAppliedToID());
            } else {
                ps.setNull(6, Types.INTEGER);
            }
            
            ps.setTimestamp(7, Timestamp.valueOf(campaign.getStartDate()));
            ps.setTimestamp(8, Timestamp.valueOf(campaign.getEndDate()));
            ps.setBoolean(9, campaign.isActive());
            
            if (campaign.getCreatedBy() != null) {
                ps.setInt(10, campaign.getCreatedBy());
            } else {
                ps.setNull(10, Types.INTEGER);
            }
            
            int rowsAffected = ps.executeUpdate();
            System.out.println("✅ Inserted campaign: " + campaign.getCampaignName());
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Error in insertCampaign: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Update campaign
     */
    public boolean updateCampaign(DiscountCampaign campaign) {
        String sql = "UPDATE DiscountCampaigns SET CampaignName = ?, DiscountType = ?, " +
                     "DiscountValue = ?, MaxDiscountAmount = ?, AppliedToType = ?, " +
                     "AppliedToID = ?, StartDate = ?, EndDate = ?, IsActive = ? " +
                     "WHERE DiscountID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, campaign.getCampaignName());
            ps.setString(2, campaign.getDiscountType());
            ps.setBigDecimal(3, campaign.getDiscountValue());
            
            if (campaign.getMaxDiscountAmount() != null) {
                ps.setBigDecimal(4, campaign.getMaxDiscountAmount());
            } else {
                ps.setNull(4, Types.DECIMAL);
            }
            
            ps.setString(5, campaign.getAppliedToType());
            
            if (campaign.getAppliedToID() != null) {
                ps.setInt(6, campaign.getAppliedToID());
            } else {
                ps.setNull(6, Types.INTEGER);
            }
            
            ps.setTimestamp(7, Timestamp.valueOf(campaign.getStartDate()));
            ps.setTimestamp(8, Timestamp.valueOf(campaign.getEndDate()));
            ps.setBoolean(9, campaign.isActive());
            ps.setInt(10, campaign.getDiscountID());
            
            int rowsAffected = ps.executeUpdate();
            System.out.println("✅ Updated campaign ID: " + campaign.getDiscountID());
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Error in updateCampaign: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Toggle campaign status
     */
    public boolean toggleCampaignStatus(int id) {
        String sql = "UPDATE DiscountCampaigns SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END " +
                     "WHERE DiscountID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            int rowsAffected = ps.executeUpdate();
            System.out.println("✅ Toggled campaign status ID: " + id);
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Error in toggleCampaignStatus: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Get active campaigns for a product
     */
    public List<DiscountCampaign> getActiveCampaignsForProduct(int productID, Integer categoryID, Integer brandID) {
        List<DiscountCampaign> list = new ArrayList<>();
        String sql = "SELECT * FROM DiscountCampaigns " +
                     "WHERE IsActive = 1 AND GETDATE() BETWEEN StartDate AND EndDate " +
                     "AND (AppliedToType = 'all' " +
                     "     OR (AppliedToType = 'product' AND AppliedToID = ?) " +
                     "     OR (AppliedToType = 'category' AND AppliedToID = ?) " +
                     "     OR (AppliedToType = 'brand' AND AppliedToID = ?)) " +
                     "ORDER BY DiscountValue DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, productID);
            ps.setObject(2, categoryID);
            ps.setObject(3, brandID);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToCampaign(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error in getActiveCampaignsForProduct: " + e.getMessage());
            e.printStackTrace();
        }
        
        return list;
    }
    
    /**
     * Calculate discount amount
     */
    public BigDecimal calculateDiscount(DiscountCampaign campaign, BigDecimal originalPrice) {
        if (campaign == null || originalPrice == null) {
            return BigDecimal.ZERO;
        }
        
        BigDecimal discount = BigDecimal.ZERO;
        
        if ("percentage".equals(campaign.getDiscountType())) {
            discount = originalPrice.multiply(campaign.getDiscountValue())
                                   .divide(new BigDecimal("100"));
            
            if (campaign.getMaxDiscountAmount() != null && 
                discount.compareTo(campaign.getMaxDiscountAmount()) > 0) {
                discount = campaign.getMaxDiscountAmount();
            }
        } else if ("fixed".equals(campaign.getDiscountType())) {
            discount = campaign.getDiscountValue();
            
            if (discount.compareTo(originalPrice) > 0) {
                discount = originalPrice;
            }
        }
        
        return discount;
    }
    
    /**
     * Map ResultSet to DiscountCampaign object
     */
    private DiscountCampaign mapResultSetToCampaign(ResultSet rs) throws SQLException {
        DiscountCampaign campaign = new DiscountCampaign();
        campaign.setDiscountID(rs.getInt("DiscountID"));
        campaign.setCampaignName(rs.getString("CampaignName"));
        campaign.setDiscountType(rs.getString("DiscountType"));
        campaign.setDiscountValue(rs.getBigDecimal("DiscountValue"));
        campaign.setMaxDiscountAmount(rs.getBigDecimal("MaxDiscountAmount"));
        campaign.setAppliedToType(rs.getString("AppliedToType"));
        
        Integer appliedToID = (Integer) rs.getObject("AppliedToID");
        campaign.setAppliedToID(appliedToID);
        
        Timestamp startDate = rs.getTimestamp("StartDate");
        if (startDate != null) {
            campaign.setStartDate(startDate.toLocalDateTime());
        }
        
        Timestamp endDate = rs.getTimestamp("EndDate");
        if (endDate != null) {
            campaign.setEndDate(endDate.toLocalDateTime());
        }
        
        campaign.setActive(rs.getBoolean("IsActive"));
        
        Integer createdBy = (Integer) rs.getObject("CreatedBy");
        campaign.setCreatedBy(createdBy);
        
        Timestamp createdDate = rs.getTimestamp("CreatedDate");
        if (createdDate != null) {
            campaign.setCreatedDate(createdDate.toLocalDateTime());
        }
        
        try {
            campaign.setCreatedByName(rs.getString("CreatedByName"));
        } catch (SQLException ignore) {
        }
        
        try {
            campaign.setAppliedToName(rs.getString("AppliedToName"));
        } catch (SQLException ignore) {
        }
        
        return campaign;
    }
}
