package DAO;

import entity.Brand;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BrandDAO extends DBContext {
    
    // Get all brands
    public List<Brand> getAllBrands() {
        List<Brand> list = new ArrayList<>();
        String sql = "SELECT * FROM Brands ORDER BY BrandName";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Brand brand = new Brand(
                    rs.getInt("BrandID"),
                    rs.getString("BrandName"),
                    rs.getString("Logo"),
                    rs.getString("Description"),
                    rs.getBoolean("IsActive")
                );
                list.add(brand);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // Get brands with search, filter, sort and paging
    public List<Brand> getBrands(String search, Boolean isActive, String sortBy, String sortOrder, int page, int pageSize) {
        List<Brand> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM Brands WHERE 1=1");
        
        // Search
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (BrandName LIKE ? OR Description LIKE ?)");
        }
        
        // Filter by status
        if (isActive != null) {
            sql.append(" AND IsActive = ?");
        }
        
        // Sort
        if (sortBy != null && !sortBy.isEmpty()) {
            sql.append(" ORDER BY ").append(sortBy);
            if (sortOrder != null && sortOrder.equalsIgnoreCase("DESC")) {
                sql.append(" DESC");
            } else {
                sql.append(" ASC");
            }
        } else {
            sql.append(" ORDER BY BrandName");
        }
        
        // Paging
        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            
            // Set search parameters
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            
            // Set filter parameters
            if (isActive != null) {
                ps.setBoolean(paramIndex++, isActive);
            }
            
            // Set paging parameters
            ps.setInt(paramIndex++, (page - 1) * pageSize);
            ps.setInt(paramIndex++, pageSize);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Brand brand = new Brand(
                    rs.getInt("BrandID"),
                    rs.getString("BrandName"),
                    rs.getString("Logo"),
                    rs.getString("Description"),
                    rs.getBoolean("IsActive")
                );
                list.add(brand);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // Get total count for pagination
    public int getTotalBrands(String search, Boolean isActive) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Brands WHERE 1=1");
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (BrandName LIKE ? OR Description LIKE ?)");
        }
        
        if (isActive != null) {
            sql.append(" AND IsActive = ?");
        }
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            
            if (isActive != null) {
                ps.setBoolean(paramIndex++, isActive);
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
    
    // Get brand by ID
    public Brand getBrandByID(int id) {
        String sql = "SELECT * FROM Brands WHERE BrandID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new Brand(
                    rs.getInt("BrandID"),
                    rs.getString("BrandName"),
                    rs.getString("Logo"),
                    rs.getString("Description"),
                    rs.getBoolean("IsActive")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Insert new brand
    public boolean insertBrand(Brand brand) {
        String sql = "INSERT INTO Brands (BrandName, Logo, Description, IsActive) VALUES (?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, brand.getBrandName());
            ps.setString(2, brand.getLogo());
            ps.setString(3, brand.getDescription());
            ps.setBoolean(4, brand.isIsActive());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Update brand
    public boolean updateBrand(Brand brand) {
        String sql = "UPDATE Brands SET BrandName = ?, Logo = ?, Description = ?, IsActive = ? WHERE BrandID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, brand.getBrandName());
            ps.setString(2, brand.getLogo());
            ps.setString(3, brand.getDescription());
            ps.setBoolean(4, brand.isIsActive());
            ps.setInt(5, brand.getBrandID());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Delete brand
    public boolean deleteBrand(int id) {
        String sql = "DELETE FROM Brands WHERE BrandID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
