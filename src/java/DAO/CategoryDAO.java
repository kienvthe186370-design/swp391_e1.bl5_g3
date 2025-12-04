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
    
}
    
