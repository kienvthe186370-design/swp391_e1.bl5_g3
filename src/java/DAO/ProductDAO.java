package DAO;

import entity.Product;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object cho Product
 * DÙNG CHUNG cho cả Homepage và Admin Dashboard
 * Trả về Map<String, Object> thay vì DTO
 */
public class ProductDAO extends DBContext {
    
    /**
     * Lấy danh sách sản phẩm với filter, sort, pagination
     * Trả về List<Map> chứa thông tin sản phẩm + thông tin liên quan
     * 
     * @param search - Tìm kiếm theo tên sản phẩm (nullable)
     * @param categoryId - Filter theo category (nullable)
     * @param brandId - Filter theo brand (nullable)
     * @param isActive - Filter theo status (null = all, true = active, false = inactive)
     * @param sortBy - Sắp xếp theo: "name", "price", "date", "stock"
     * @param sortOrder - "asc" hoặc "desc"
     * @param page - Trang hiện tại (bắt đầu từ 1)
     * @param pageSize - Số item mỗi trang
     * @return List<Map<String, Object>>
     */
    public List<Map<String, Object>> getProducts(String search, Integer categoryId, Integer brandId,
                                                   Boolean isActive, String sortBy, String sortOrder,
                                                   int page, int pageSize) {
        List<Map<String, Object>> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            
            // Build dynamic SQL
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT p.*, ");
            sql.append("c.CategoryName, ");
            sql.append("b.BrandName, ");
            sql.append("(SELECT TOP 1 ImageURL FROM ProductImages WHERE ProductID = p.ProductID AND ImageType = 'main') AS MainImage, ");
            sql.append("(SELECT COUNT(*) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) AS VariantCount, ");
            sql.append("(SELECT MIN(SellingPrice) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) AS MinPrice, ");
            sql.append("(SELECT MAX(SellingPrice) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) AS MaxPrice, ");
            sql.append("(SELECT ISNULL(SUM(Stock), 0) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) AS TotalStock, ");
            sql.append("(SELECT ISNULL(SUM(ReservedStock), 0) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) AS ReservedStock ");
            sql.append("FROM Products p ");
            sql.append("LEFT JOIN Categories c ON p.CategoryID = c.CategoryID ");
            sql.append("LEFT JOIN Brands b ON p.BrandID = b.BrandID ");
            sql.append("WHERE 1=1 ");
            
            // Add filters
            if (search != null && !search.trim().isEmpty()) {
                sql.append("AND p.ProductName LIKE ? ");
            }
            if (categoryId != null) {
                sql.append("AND p.CategoryID = ? ");
            }
            if (brandId != null) {
                sql.append("AND p.BrandID = ? ");
            }
            if (isActive != null) {
                sql.append("AND p.IsActive = ? ");
            }
            
            // Add sorting
            sql.append("ORDER BY ");
            switch (sortBy != null ? sortBy : "date") {
                case "name":
                    sql.append("p.ProductName ");
                    break;
                case "price":
                    sql.append("MinPrice ");
                    break;
                case "stock":
                    sql.append("TotalStock ");
                    break;
                default: // "date"
                    sql.append("p.CreatedDate ");
                    break;
            }
            sql.append("desc".equalsIgnoreCase(sortOrder) ? "DESC " : "ASC ");
            
            // Add pagination
            int offset = (page - 1) * pageSize;
            sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
            
            ps = conn.prepareStatement(sql.toString());
            
            // Set parameters
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + search.trim() + "%");
            }
            if (categoryId != null) {
                ps.setInt(paramIndex++, categoryId);
            }
            if (brandId != null) {
                ps.setInt(paramIndex++, brandId);
            }
            if (isActive != null) {
                ps.setBoolean(paramIndex++, isActive);
            }
            ps.setInt(paramIndex++, offset);
            ps.setInt(paramIndex++, pageSize);
            
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> product = new HashMap<>();
                
                // Product basic info
                product.put("productID", rs.getInt("ProductID"));
                product.put("productName", rs.getString("ProductName"));
                product.put("categoryID", rs.getInt("CategoryID"));
                product.put("brandID", rs.getObject("BrandID"));
                product.put("description", rs.getString("Description"));
                product.put("specifications", rs.getString("Specifications"));
                product.put("isActive", rs.getBoolean("IsActive"));
                product.put("createdBy", rs.getObject("CreatedBy"));
                product.put("createdDate", rs.getTimestamp("CreatedDate"));
                product.put("updatedDate", rs.getTimestamp("UpdatedDate"));
                
                // Additional info
                product.put("categoryName", rs.getString("CategoryName"));
                product.put("brandName", rs.getString("BrandName"));
                product.put("mainImageUrl", rs.getString("MainImage"));
                product.put("variantCount", rs.getInt("VariantCount"));
                product.put("minPrice", rs.getBigDecimal("MinPrice"));
                product.put("maxPrice", rs.getBigDecimal("MaxPrice"));
                product.put("totalStock", rs.getInt("TotalStock"));
                product.put("reservedStock", rs.getInt("ReservedStock"));
                
                // Calculated fields
                int totalStock = rs.getInt("TotalStock");
                int reservedStock = rs.getInt("ReservedStock");
                product.put("availableStock", totalStock - reservedStock);
                
                list.add(product);
            }
            
        } catch (SQLException e) {
            System.err.println("Error in getProducts: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return list;
    }
    
    /**
     * Đếm tổng số sản phẩm (cho pagination)
     */
    public int getTotalProducts(String search, Integer categoryId, Integer brandId, Boolean isActive) {
        int total = 0;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT COUNT(*) FROM Products p WHERE 1=1 ");
            
            if (search != null && !search.trim().isEmpty()) {
                sql.append("AND p.ProductName LIKE ? ");
            }
            if (categoryId != null) {
                sql.append("AND p.CategoryID = ? ");
            }
            if (brandId != null) {
                sql.append("AND p.BrandID = ? ");
            }
            if (isActive != null) {
                sql.append("AND p.IsActive = ? ");
            }
            
            ps = conn.prepareStatement(sql.toString());
            
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + search.trim() + "%");
            }
            if (categoryId != null) {
                ps.setInt(paramIndex++, categoryId);
            }
            if (brandId != null) {
                ps.setInt(paramIndex++, brandId);
            }
            if (isActive != null) {
                ps.setBoolean(paramIndex++, isActive);
            }
            
            rs = ps.executeQuery();
            if (rs.next()) {
                total = rs.getInt(1);
            }
            
        } catch (SQLException e) {
            System.err.println("Error in getTotalProducts: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return total;
    }
    
    /**
     * Soft delete product (set IsActive = 0)
     */
    public boolean softDeleteProduct(int productId) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = getConnection();
            String sql = "UPDATE Products SET IsActive = 0, UpdatedDate = GETDATE() WHERE ProductID = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, productId);
            
            int rows = ps.executeUpdate();
            return rows > 0;
            
        } catch (SQLException e) {
            System.err.println("Error in softDeleteProduct: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Lấy danh sách categories để hiển thị trong filter
     * Trả về List<Map> với keys: "categoryID", "categoryName"
     */
    public List<Map<String, Object>> getCategoriesForFilter() {
        List<Map<String, Object>> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            String sql = "SELECT CategoryID, CategoryName FROM Categories WHERE IsActive = 1 ORDER BY CategoryName";
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> category = new HashMap<>();
                category.put("categoryID", rs.getInt("CategoryID"));
                category.put("categoryName", rs.getString("CategoryName"));
                list.add(category);
            }
            
        } catch (SQLException e) {
            System.err.println("Error in getCategoriesForFilter: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return list;
    }
    
    /**
     * Lấy danh sách brands để hiển thị trong filter
     * Trả về List<Map> với keys: "brandID", "brandName"
     */
    public List<Map<String, Object>> getBrandsForFilter() {
        List<Map<String, Object>> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            String sql = "SELECT BrandID, BrandName FROM Brands WHERE IsActive = 1 ORDER BY BrandName";
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> brand = new HashMap<>();
                brand.put("brandID", rs.getInt("BrandID"));
                brand.put("brandName", rs.getString("BrandName"));
                list.add(brand);
            }
            
        } catch (SQLException e) {
            System.err.println("Error in getBrandsForFilter: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return list;
    }
    
    /**
     * Test DAO
     */
    public static void main(String[] args) {
        ProductDAO dao = new ProductDAO();
        
        System.out.println("=== TEST ProductDAO (WITHOUT DTO) ===\n");
        
        // Test 1: Get all products
        System.out.println("Test 1: Get all active products (page 1, 12 items)");
        List<Map<String, Object>> products = dao.getProducts(null, null, null, true, "date", "desc", 1, 12);
        System.out.println("Found " + products.size() + " products");
        for (Map<String, Object> product : products) {
            System.out.println("ID: " + product.get("productID") + 
                             ", Name: " + product.get("productName") +
                             ", Category: " + product.get("categoryName") +
                             ", Brand: " + product.get("brandName") +
                             ", Variants: " + product.get("variantCount") +
                             ", Stock: " + product.get("totalStock"));
        }
        
        System.out.println("\n---\n");
        
        // Test 2: Get total count
        System.out.println("Test 2: Get total active products");
        int total = dao.getTotalProducts(null, null, null, true);
        System.out.println("Total: " + total);
        
        System.out.println("\n---\n");
        
        // Test 3: Search by name
        System.out.println("Test 3: Search products with 'Joola'");
        List<Map<String, Object>> searchResults = dao.getProducts("Joola", null, null, true, "name", "asc", 1, 10);
        System.out.println("Found " + searchResults.size() + " products");
        for (Map<String, Object> product : searchResults) {
            System.out.println("Name: " + product.get("productName"));
        }
        
        System.out.println("\n---\n");
        
        // Test 4: Get categories
        System.out.println("Test 4: Get categories for filter");
        List<Map<String, Object>> categories = dao.getCategoriesForFilter();
        System.out.println("Found " + categories.size() + " categories");
        for (Map<String, Object> cat : categories) {
            System.out.println("ID: " + cat.get("categoryID") + ", Name: " + cat.get("categoryName"));
        }
        
        System.out.println("\n---\n");
        
        // Test 5: Get brands
        System.out.println("Test 5: Get brands for filter");
        List<Map<String, Object>> brands = dao.getBrandsForFilter();
        System.out.println("Found " + brands.size() + " brands");
        for (Map<String, Object> brand : brands) {
            System.out.println("ID: " + brand.get("brandID") + ", Name: " + brand.get("brandName"));
        }
    }
}