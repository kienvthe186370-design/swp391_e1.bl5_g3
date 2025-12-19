package DAO;

import entity.Category;
import entity.CategoryAttribute;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO extends DBContext {
    
    // Get all categories
    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT * FROM Categories ORDER BY DisplayOrder, CategoryName";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Category cat = new Category(
                    rs.getInt("CategoryID"),
                    rs.getString("CategoryName"),
                    rs.getString("Description"),
                    rs.getString("Icon"),
                    rs.getInt("DisplayOrder"),
                    rs.getBoolean("IsActive")
                );
                list.add(cat);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // Get categories with search, filter, sort and paging
    public List<Category> getCategories(String search, Boolean isActive, String sortBy, String sortOrder, int page, int pageSize) {
        List<Category> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM Categories WHERE 1=1");
        
        // Search
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (CategoryName LIKE ? OR Description LIKE ?)");
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
            sql.append(" ORDER BY DisplayOrder, CategoryName");
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
                Category cat = new Category(
                    rs.getInt("CategoryID"),
                    rs.getString("CategoryName"),
                    rs.getString("Description"),
                    rs.getString("Icon"),
                    rs.getInt("DisplayOrder"),
                    rs.getBoolean("IsActive")
                );
                list.add(cat);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // Get total count for pagination
    public int getTotalCategories(String search, Boolean isActive) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Categories WHERE 1=1");
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (CategoryName LIKE ? OR Description LIKE ?)");
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
    public Category getCategoryByID(int id) {
        String sql = "SELECT * FROM Categories WHERE CategoryID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new Category(
                    rs.getInt("CategoryID"),
                    rs.getString("CategoryName"),
                    rs.getString("Description"),
                    rs.getString("Icon"),
                    rs.getInt("DisplayOrder"),
                    rs.getBoolean("IsActive")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
     public boolean insertCategory(Category cat) {
        String sql = "INSERT INTO Categories (CategoryName, Description, Icon, DisplayOrder, IsActive) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cat.getCategoryName());
            ps.setString(2, cat.getDescription());
            ps.setString(3, cat.getIcon());
            ps.setInt(4, cat.getDisplayOrder());
            ps.setBoolean(5, cat.isIsActive());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
     public boolean updateCategory(Category cat) {
        String sql = "UPDATE Categories SET CategoryName = ?, Description = ?, Icon = ?, DisplayOrder = ?, IsActive = ? WHERE CategoryID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cat.getCategoryName());
            ps.setString(2, cat.getDescription());
            ps.setString(3, cat.getIcon());
            ps.setInt(4, cat.getDisplayOrder());
            ps.setBoolean(5, cat.isIsActive());
            ps.setInt(6, cat.getCategoryID());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Delete category
    public boolean deleteCategory(int id) {
        String sql = "DELETE FROM Categories WHERE CategoryID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    public List<CategoryAttribute> getCategoryAttributes(int categoryID) {
        List<CategoryAttribute> list = new ArrayList<>();
        String sql = "SELECT * FROM CategoryAttributes WHERE CategoryID = ? ORDER BY DisplayOrder";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                CategoryAttribute ca = new CategoryAttribute(
                    rs.getInt("CategoryAttributeID"),
                    rs.getInt("CategoryID"),
                    rs.getInt("AttributeID"),
                    rs.getBoolean("IsRequired"),
                    rs.getInt("DisplayOrder")
                );
                list.add(ca);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
     public boolean addCategoryAttribute(CategoryAttribute ca) {
        String sql = "INSERT INTO CategoryAttributes (CategoryID, AttributeID, IsRequired, DisplayOrder) VALUES (?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ca.getCategoryID());
            ps.setInt(2, ca.getAttributeID());
            ps.setBoolean(3, ca.isIsRequired());
            ps.setInt(4, ca.getDisplayOrder());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Remove attribute from category
    public boolean removeCategoryAttribute(int categoryID, int attributeID) {
        String sql = "DELETE FROM CategoryAttributes WHERE CategoryID = ? AND AttributeID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryID);
            ps.setInt(2, attributeID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Get category attributes by attribute ID
    public List<CategoryAttribute> getCategoryAttributesByAttribute(int attributeID) {
        List<CategoryAttribute> list = new ArrayList<>();
        String sql = "SELECT * FROM CategoryAttributes WHERE AttributeID = ? ORDER BY DisplayOrder";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, attributeID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                CategoryAttribute ca = new CategoryAttribute(
                    rs.getInt("CategoryAttributeID"),
                    rs.getInt("CategoryID"),
                    rs.getInt("AttributeID"),
                    rs.getBoolean("IsRequired"),
                    rs.getInt("DisplayOrder")
                );
                list.add(ca);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    
    public boolean isCategoryNameExists(String categoryName, Integer excludeId) {
        String sql = "SELECT COUNT(*) FROM Categories WHERE CategoryName = ?";
        if (excludeId != null) {
            sql += " AND CategoryID != ?";
        }
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, categoryName);
            if (excludeId != null) {
                ps.setInt(2, excludeId);
            }
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
