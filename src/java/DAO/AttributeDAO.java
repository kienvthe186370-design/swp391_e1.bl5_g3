package DAO;

import entity.ProductAttribute;
import entity.AttributeValue;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AttributeDAO extends DBContext {
    
    // Get all attributes
    public List<ProductAttribute> getAllAttributes() {
        List<ProductAttribute> list = new ArrayList<>();
        String sql = "SELECT * FROM ProductAttributes ORDER BY AttributeName";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ProductAttribute attr = new ProductAttribute(
                    rs.getInt("AttributeID"),
                    rs.getString("AttributeName"),
                    rs.getBoolean("IsActive")
                );
                list.add(attr);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // Get attribute by ID
    public ProductAttribute getAttributeByID(int id) {
        String sql = "SELECT * FROM ProductAttributes WHERE AttributeID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new ProductAttribute(
                    rs.getInt("AttributeID"),
                    rs.getString("AttributeName"),
                    rs.getBoolean("IsActive")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Insert new attribute
    public boolean insertAttribute(ProductAttribute attr) {
        String sql = "INSERT INTO ProductAttributes (AttributeName, IsActive) VALUES (?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, attr.getAttributeName());
            ps.setBoolean(2, attr.isIsActive());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Update attribute
    public boolean updateAttribute(ProductAttribute attr) {
        String sql = "UPDATE ProductAttributes SET AttributeName = ?, IsActive = ? WHERE AttributeID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, attr.getAttributeName());
            ps.setBoolean(2, attr.isIsActive());
            ps.setInt(3, attr.getAttributeID());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Delete attribute
    public boolean deleteAttribute(int id) {
        String sql = "DELETE FROM ProductAttributes WHERE AttributeID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    public List<AttributeValue> getValuesByAttributeID(int attributeID) {
        List<AttributeValue> list = new ArrayList<>();
        String sql = "SELECT * FROM AttributeValues WHERE AttributeID = ? ORDER BY ValueName";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, attributeID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                AttributeValue val = new AttributeValue(
                    rs.getInt("ValueID"),
                    rs.getInt("AttributeID"),
                    rs.getString("ValueName"),
                    rs.getBoolean("IsActive")
                );
                list.add(val);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // Insert attribute value
    public boolean insertAttributeValue(AttributeValue value) {
        String sql = "INSERT INTO AttributeValues (AttributeID, ValueName, IsActive) VALUES (?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, value.getAttributeID());
            ps.setString(2, value.getValueName());
            ps.setBoolean(3, value.isIsActive());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Update attribute value
    public boolean updateAttributeValue(AttributeValue value) {
        String sql = "UPDATE AttributeValues SET ValueName = ?, IsActive = ? WHERE ValueID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, value.getValueName());
            ps.setBoolean(2, value.isIsActive());
            ps.setInt(3, value.getValueID());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Delete attribute value
    public boolean deleteAttributeValue(int valueID) {
        String sql = "DELETE FROM AttributeValues WHERE ValueID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, valueID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}