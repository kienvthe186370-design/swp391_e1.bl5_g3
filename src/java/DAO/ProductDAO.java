package DAO;

import entity.ProductStatus;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Product data access
 * Last updated: Dec 2024
 */
public class ProductDAO extends DBContext {
    
    public ProductStatus calculateProductStatus(int variantCount, int totalStock) {
        if (variantCount == 0) return ProductStatus.DRAFT;
        if (totalStock == 0) return ProductStatus.OUT_OF_STOCK;
        return ProductStatus.IN_STOCK;
    }
    
    // Get products with filters (backward compatible)
    public List<Map<String, Object>> getProducts(String search, Integer categoryId, Integer brandId,
                                                   Boolean isActive, String sortBy, String sortOrder,
                                                   int page, int pageSize) {
        return getProducts(search, categoryId, brandId, isActive, null, sortBy, sortOrder, page, pageSize);
    }
    
    // Get products with status filter
    public List<Map<String, Object>> getProducts(String search, Integer categoryId, Integer brandId,
                                                   Boolean isActive, String statusFilter, String sortBy, 
                                                   String sortOrder, int page, int pageSize) {
        List<Map<String, Object>> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT p.*, c.CategoryName, b.BrandName, ");
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
            
            if (search != null && !search.trim().isEmpty()) {
                sql.append("AND p.ProductName LIKE ? ");
            }
            if (categoryId != null) sql.append("AND p.CategoryID = ? ");
            if (brandId != null) sql.append("AND p.BrandID = ? ");
            if (isActive != null) sql.append("AND p.IsActive = ? ");
            
            // Status filter
            if (statusFilter != null && !statusFilter.trim().isEmpty() && !"all".equalsIgnoreCase(statusFilter)) {
                if ("draft".equalsIgnoreCase(statusFilter)) {
                    sql.append("AND (SELECT COUNT(*) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) = 0 ");
                } else if ("out_of_stock".equalsIgnoreCase(statusFilter)) {
                    sql.append("AND (SELECT COUNT(*) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) > 0 ");
                    sql.append("AND (SELECT ISNULL(SUM(Stock), 0) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) = 0 ");
                } else if ("in_stock".equalsIgnoreCase(statusFilter)) {
                    sql.append("AND (SELECT COUNT(*) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) > 0 ");
                    sql.append("AND (SELECT ISNULL(SUM(Stock), 0) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) > 0 ");
                }
            }
            
            // Sorting
            sql.append("ORDER BY ");
            switch (sortBy != null ? sortBy : "id") {
                case "name": sql.append("p.ProductName ").append("desc".equalsIgnoreCase(sortOrder) ? "DESC " : "ASC "); break;
                case "price": sql.append("MinPrice ").append("desc".equalsIgnoreCase(sortOrder) ? "DESC " : "ASC "); break;
                case "stock": sql.append("TotalStock ").append("desc".equalsIgnoreCase(sortOrder) ? "DESC " : "ASC "); break;
                case "date": sql.append("p.CreatedDate ").append("desc".equalsIgnoreCase(sortOrder) ? "DESC " : "ASC "); break;
                case "id":
                default: sql.append("p.ProductID ASC "); break;
            }
            
            int offset = (page - 1) * pageSize;
            sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
            
            ps = conn.prepareStatement(sql.toString());
            
            int idx = 1;
            if (search != null && !search.trim().isEmpty()) ps.setString(idx++, "%" + search.trim() + "%");
            if (categoryId != null) ps.setInt(idx++, categoryId);
            if (brandId != null) ps.setInt(idx++, brandId);
            if (isActive != null) ps.setBoolean(idx++, isActive);
            ps.setInt(idx++, offset);
            ps.setInt(idx++, pageSize);
            
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> product = new HashMap<>();
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
                product.put("categoryName", rs.getString("CategoryName"));
                product.put("brandName", rs.getString("BrandName"));
                product.put("mainImageUrl", rs.getString("MainImage"));
                product.put("variantCount", rs.getInt("VariantCount"));
                product.put("minPrice", rs.getBigDecimal("MinPrice"));
                product.put("maxPrice", rs.getBigDecimal("MaxPrice"));
                product.put("totalStock", rs.getInt("TotalStock"));
                product.put("reservedStock", rs.getInt("ReservedStock"));
                
                int totalStock = rs.getInt("TotalStock");
                int reservedStock = rs.getInt("ReservedStock");
                product.put("availableStock", totalStock);
                
                int variantCount = rs.getInt("VariantCount");
                ProductStatus status = calculateProductStatus(variantCount, totalStock);
                product.put("status", status.getCode());
                product.put("statusLabel", status.getAdminLabel());
                
                list.add(product);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(rs, ps, conn);
        }
        
        return list;
    }
    
    public int getTotalProducts(String search, Integer categoryId, Integer brandId, Boolean isActive) {
        return getTotalProducts(search, categoryId, brandId, isActive, null);
    }
    
    public int getTotalProducts(String search, Integer categoryId, Integer brandId, Boolean isActive, String statusFilter) {
        int total = 0;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Products p WHERE 1=1 ");
            
            if (search != null && !search.trim().isEmpty()) sql.append("AND p.ProductName LIKE ? ");
            if (categoryId != null) sql.append("AND p.CategoryID = ? ");
            if (brandId != null) sql.append("AND p.BrandID = ? ");
            if (isActive != null) sql.append("AND p.IsActive = ? ");
            
            if (statusFilter != null && !statusFilter.trim().isEmpty() && !"all".equalsIgnoreCase(statusFilter)) {
                if ("draft".equalsIgnoreCase(statusFilter)) {
                    sql.append("AND (SELECT COUNT(*) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) = 0 ");
                } else if ("out_of_stock".equalsIgnoreCase(statusFilter)) {
                    sql.append("AND (SELECT COUNT(*) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) > 0 ");
                    sql.append("AND (SELECT ISNULL(SUM(Stock), 0) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) = 0 ");
                } else if ("in_stock".equalsIgnoreCase(statusFilter)) {
                    sql.append("AND (SELECT COUNT(*) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) > 0 ");
                    sql.append("AND (SELECT ISNULL(SUM(Stock), 0) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) > 0 ");
                }
            }
            
            ps = conn.prepareStatement(sql.toString());
            
            int idx = 1;
            if (search != null && !search.trim().isEmpty()) ps.setString(idx++, "%" + search.trim() + "%");
            if (categoryId != null) ps.setInt(idx++, categoryId);
            if (brandId != null) ps.setInt(idx++, brandId);
            if (isActive != null) ps.setBoolean(idx++, isActive);
            
            rs = ps.executeQuery();
            if (rs.next()) total = rs.getInt(1);
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(rs, ps, conn);
        }
        
        return total;
    }

    
    // Get products with price filter (for shop page)
    public List<Map<String, Object>> getProductsWithPriceFilter(String search, Integer categoryId, Integer brandId,
                                                                  BigDecimal minPrice, BigDecimal maxPrice,
                                                                  Boolean isActive, String sortBy, String sortOrder,
                                                                  int page, int pageSize) {
        List<Map<String, Object>> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT p.*, c.CategoryName, b.BrandName, ");
            sql.append("(SELECT TOP 1 ImageURL FROM ProductImages WHERE ProductID = p.ProductID AND ImageType = 'main') AS MainImage, ");
            sql.append("(SELECT COUNT(*) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) AS VariantCount, ");
            sql.append("(SELECT MIN(SellingPrice) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) AS MinPrice, ");
            sql.append("(SELECT MAX(SellingPrice) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) AS MaxPrice, ");
            sql.append("(SELECT ISNULL(SUM(Stock), 0) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) AS TotalStock, ");
            sql.append("(SELECT ISNULL(SUM(ReservedStock), 0) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) AS ReservedStock ");
            sql.append("FROM Products p ");
            sql.append("LEFT JOIN Categories c ON p.CategoryID = c.CategoryID ");
            sql.append("LEFT JOIN Brands b ON p.BrandID = b.BrandID WHERE 1=1 ");
            
            if (search != null && !search.trim().isEmpty()) sql.append("AND p.ProductName LIKE ? ");
            if (categoryId != null) sql.append("AND p.CategoryID = ? ");
            if (brandId != null) sql.append("AND p.BrandID = ? ");
            if (isActive != null) sql.append("AND p.IsActive = ? ");
            if (minPrice != null) sql.append("AND (SELECT MIN(SellingPrice) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) >= ? ");
            if (maxPrice != null) sql.append("AND (SELECT MIN(SellingPrice) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) <= ? ");
            
            sql.append("ORDER BY ");
            switch (sortBy != null ? sortBy : "id") {
                case "name": sql.append("p.ProductName ").append("desc".equalsIgnoreCase(sortOrder) ? "DESC " : "ASC "); break;
                case "price": sql.append("MinPrice ").append("desc".equalsIgnoreCase(sortOrder) ? "DESC " : "ASC "); break;
                case "stock": sql.append("TotalStock ").append("desc".equalsIgnoreCase(sortOrder) ? "DESC " : "ASC "); break;
                case "date": sql.append("p.CreatedDate ").append("desc".equalsIgnoreCase(sortOrder) ? "DESC " : "ASC "); break;
                case "id":
                default: sql.append("p.ProductID ASC "); break;
            }
            
            int offset = (page - 1) * pageSize;
            sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
            
            ps = conn.prepareStatement(sql.toString());
            
            int idx = 1;
            if (search != null && !search.trim().isEmpty()) ps.setString(idx++, "%" + search.trim() + "%");
            if (categoryId != null) ps.setInt(idx++, categoryId);
            if (brandId != null) ps.setInt(idx++, brandId);
            if (isActive != null) ps.setBoolean(idx++, isActive);
            if (minPrice != null) ps.setBigDecimal(idx++, minPrice);
            if (maxPrice != null) ps.setBigDecimal(idx++, maxPrice);
            ps.setInt(idx++, offset);
            ps.setInt(idx++, pageSize);
            
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> product = new HashMap<>();
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
                product.put("categoryName", rs.getString("CategoryName"));
                product.put("brandName", rs.getString("BrandName"));
                product.put("mainImageUrl", rs.getString("MainImage"));
                product.put("variantCount", rs.getInt("VariantCount"));
                product.put("minPrice", rs.getBigDecimal("MinPrice"));
                product.put("maxPrice", rs.getBigDecimal("MaxPrice"));
                product.put("totalStock", rs.getInt("TotalStock"));
                product.put("reservedStock", rs.getInt("ReservedStock"));
                
                int totalStock = rs.getInt("TotalStock");
                int reservedStock = rs.getInt("ReservedStock");
                product.put("availableStock", totalStock);
                
                int variantCount = rs.getInt("VariantCount");
                ProductStatus status = calculateProductStatus(variantCount, totalStock);
                product.put("status", status.getCode());
                product.put("statusLabel", status.getAdminLabel());
                
                list.add(product);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(rs, ps, conn);
        }
        
        return list;
    }
    
    public int getTotalProductsWithPriceFilter(String search, Integer categoryId, Integer brandId,
                                                BigDecimal minPrice, BigDecimal maxPrice, Boolean isActive) {
        int total = 0;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Products p WHERE 1=1 ");
            
            if (search != null && !search.trim().isEmpty()) sql.append("AND p.ProductName LIKE ? ");
            if (categoryId != null) sql.append("AND p.CategoryID = ? ");
            if (brandId != null) sql.append("AND p.BrandID = ? ");
            if (isActive != null) sql.append("AND p.IsActive = ? ");
            if (minPrice != null) sql.append("AND (SELECT MIN(SellingPrice) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) >= ? ");
            if (maxPrice != null) sql.append("AND (SELECT MIN(SellingPrice) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) <= ? ");
            
            ps = conn.prepareStatement(sql.toString());
            
            int idx = 1;
            if (search != null && !search.trim().isEmpty()) ps.setString(idx++, "%" + search.trim() + "%");
            if (categoryId != null) ps.setInt(idx++, categoryId);
            if (brandId != null) ps.setInt(idx++, brandId);
            if (isActive != null) ps.setBoolean(idx++, isActive);
            if (minPrice != null) ps.setBigDecimal(idx++, minPrice);
            if (maxPrice != null) ps.setBigDecimal(idx++, maxPrice);
            
            rs = ps.executeQuery();
            if (rs.next()) total = rs.getInt(1);
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(rs, ps, conn);
        }
        
        return total;
    }
    
    public Map<String, Integer> getProductStatusCounts() {
        Map<String, Integer> counts = new HashMap<>();
        counts.put("draft", 0);
        counts.put("in_stock", 0);
        counts.put("out_of_stock", 0);
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            String sql = "SELECT " +
                "SUM(CASE WHEN VariantCount = 0 THEN 1 ELSE 0 END) AS DraftCount, " +
                "SUM(CASE WHEN VariantCount > 0 AND TotalStock = 0 THEN 1 ELSE 0 END) AS OutOfStockCount, " +
                "SUM(CASE WHEN VariantCount > 0 AND TotalStock > 0 THEN 1 ELSE 0 END) AS InStockCount " +
                "FROM (SELECT p.ProductID, " +
                "(SELECT COUNT(*) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) AS VariantCount, " +
                "(SELECT ISNULL(SUM(Stock), 0) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) AS TotalStock " +
                "FROM Products p WHERE p.IsActive = 1) AS ProductStats";
            
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                counts.put("draft", rs.getInt("DraftCount"));
                counts.put("out_of_stock", rs.getInt("OutOfStockCount"));
                counts.put("in_stock", rs.getInt("InStockCount"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(rs, ps, conn);
        }
        
        return counts;
    }
    
    public boolean softDeleteProduct(int productId) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = getConnection();
            ps = conn.prepareStatement("UPDATE Products SET IsActive = 0, UpdatedDate = GETDATE() WHERE ProductID = ?");
            ps.setInt(1, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources(null, ps, conn);
        }
    }
    
    public boolean toggleProductStatus(int productId, boolean isActive) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = getConnection();
            ps = conn.prepareStatement("UPDATE Products SET IsActive = ?, UpdatedDate = GETDATE() WHERE ProductID = ?");
            ps.setBoolean(1, isActive);
            ps.setInt(2, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources(null, ps, conn);
        }
    }
    
    public List<Map<String, Object>> getCategoriesForFilter() {
        List<Map<String, Object>> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            ps = conn.prepareStatement("SELECT CategoryID, CategoryName FROM Categories WHERE IsActive = 1 ORDER BY CategoryName");
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> cat = new HashMap<>();
                cat.put("categoryID", rs.getInt("CategoryID"));
                cat.put("categoryName", rs.getString("CategoryName"));
                list.add(cat);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(rs, ps, conn);
        }
        
        return list;
    }
    
    public List<Map<String, Object>> getBrandsForFilter() {
        List<Map<String, Object>> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            ps = conn.prepareStatement("SELECT BrandID, BrandName FROM Brands WHERE IsActive = 1 ORDER BY BrandName");
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> brand = new HashMap<>();
                brand.put("brandID", rs.getInt("BrandID"));
                brand.put("brandName", rs.getString("BrandName"));
                list.add(brand);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(rs, ps, conn);
        }
        
        return list;
    }

    
    public int insertProduct(String productName, int categoryId, Integer brandId,
                            String description, String specifications, int createdBy) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            String sql = "INSERT INTO Products (ProductName, CategoryID, BrandID, Description, " +
                        "Specifications, IsActive, CreatedBy, CreatedDate, UpdatedDate) " +
                        "VALUES (?, ?, ?, ?, ?, 1, ?, GETDATE(), GETDATE())";
            
            ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
            ps.setString(1, productName);
            ps.setInt(2, categoryId);
            if (brandId != null) ps.setInt(3, brandId);
            else ps.setNull(3, java.sql.Types.INTEGER);
            ps.setString(4, description);
            ps.setString(5, specifications);
            ps.setInt(6, createdBy);
            
            int rows = ps.executeUpdate();
            if (rows > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) return rs.getInt(1);
            }
            return -1;
        } catch (SQLException e) {
            e.printStackTrace();
            return -1;
        } finally {
            closeResources(rs, ps, conn);
        }
    }
    
    public boolean insertProductImage(int productId, String imageUrl, String imageType, int sortOrder) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = getConnection();
            ps = conn.prepareStatement("INSERT INTO ProductImages (ProductID, ImageURL, ImageType, SortOrder) VALUES (?, ?, ?, ?)");
            ps.setInt(1, productId);
            ps.setString(2, imageUrl);
            ps.setString(3, imageType);
            ps.setInt(4, sortOrder);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources(null, ps, conn);
        }
    }
    
    public Map<String, Object> getProductById(int productId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            String sql = "SELECT p.*, c.CategoryName, b.BrandName, e.FullName AS CreatedByName, " +
                        "(SELECT COUNT(*) FROM ProductImages WHERE ProductID = p.ProductID) AS ImageCount, " +
                        "(SELECT COUNT(*) FROM ProductVariants WHERE ProductID = p.ProductID) AS VariantCount, " +
                        "(SELECT ISNULL(SUM(Stock), 0) FROM ProductVariants WHERE ProductID = p.ProductID) AS TotalStock, " +
                        "(SELECT MIN(SellingPrice) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) AS MinPrice, " +
                        "(SELECT MAX(SellingPrice) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) AS MaxPrice " +
                        "FROM Products p " +
                        "LEFT JOIN Categories c ON p.CategoryID = c.CategoryID " +
                        "LEFT JOIN Brands b ON p.BrandID = b.BrandID " +
                        "LEFT JOIN Employees e ON p.CreatedBy = e.EmployeeID " +
                        "WHERE p.ProductID = ?";
            
            ps = conn.prepareStatement(sql);
            ps.setInt(1, productId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                Map<String, Object> product = new HashMap<>();
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
                product.put("categoryName", rs.getString("CategoryName"));
                product.put("brandName", rs.getString("BrandName"));
                product.put("createdByName", rs.getString("CreatedByName"));
                product.put("imageCount", rs.getInt("ImageCount"));
                product.put("variantCount", rs.getInt("VariantCount"));
                product.put("totalStock", rs.getInt("TotalStock"));
                product.put("minPrice", rs.getBigDecimal("MinPrice"));
                product.put("maxPrice", rs.getBigDecimal("MaxPrice"));
                
                int variantCount = rs.getInt("VariantCount");
                int totalStock = rs.getInt("TotalStock");
                ProductStatus status = calculateProductStatus(variantCount, totalStock);
                product.put("status", status.getCode());
                product.put("statusLabel", status.getAdminLabel());
                
                return product;
            }
            return null;
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        } finally {
            closeResources(rs, ps, conn);
        }
    }
    
    public List<Map<String, Object>> getProductImages(int productId) {
        List<Map<String, Object>> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            ps = conn.prepareStatement("SELECT ImageID, ProductID, ImageURL, ImageType, SortOrder FROM ProductImages WHERE ProductID = ? ORDER BY SortOrder");
            ps.setInt(1, productId);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> img = new HashMap<>();
                img.put("imageID", rs.getInt("ImageID"));
                img.put("productID", rs.getInt("ProductID"));
                img.put("imageURL", rs.getString("ImageURL"));
                img.put("imageType", rs.getString("ImageType"));
                img.put("sortOrder", rs.getInt("SortOrder"));
                list.add(img);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(rs, ps, conn);
        }
        
        return list;
    }
    
    public List<Map<String, Object>> getProductVariants(int productId) {
        List<Map<String, Object>> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            ps = conn.prepareStatement("SELECT VariantID, ProductID, SKU, CostPrice, SellingPrice, " +
                        "ProfitMargin, ProfitAmount, Stock, ReservedStock, ReorderLevel, IsActive, CreatedDate, UpdatedDate " +
                        "FROM ProductVariants WHERE ProductID = ? ORDER BY CreatedDate DESC");
            ps.setInt(1, productId);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> v = new HashMap<>();
                v.put("variantID", rs.getInt("VariantID"));
                v.put("productID", rs.getInt("ProductID"));
                v.put("sku", rs.getString("SKU"));
                v.put("costPrice", rs.getBigDecimal("CostPrice"));
                v.put("sellingPrice", rs.getBigDecimal("SellingPrice"));
                v.put("profitMargin", rs.getBigDecimal("ProfitMargin"));
                v.put("profitAmount", rs.getBigDecimal("ProfitAmount"));
                v.put("stock", rs.getInt("Stock"));
                v.put("reservedStock", rs.getInt("ReservedStock"));
                v.put("reorderLevel", rs.getObject("ReorderLevel"));
                v.put("isActive", rs.getBoolean("IsActive"));
                v.put("createdDate", rs.getTimestamp("CreatedDate"));
                v.put("updatedDate", rs.getTimestamp("UpdatedDate"));
                
                list.add(v);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(rs, ps, conn);
        }
        
        return list;
    }
    
    public boolean updateProduct(int productId, String productName, int categoryId, Integer brandId,
                                 String description, String specifications, boolean isActive) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = getConnection();
            ps = conn.prepareStatement("UPDATE Products SET ProductName = ?, CategoryID = ?, BrandID = ?, " +
                        "Description = ?, Specifications = ?, IsActive = ?, UpdatedDate = GETDATE() WHERE ProductID = ?");
            ps.setString(1, productName);
            ps.setInt(2, categoryId);
            if (brandId != null) ps.setInt(3, brandId);
            else ps.setNull(3, java.sql.Types.INTEGER);
            ps.setString(4, description);
            ps.setString(5, specifications);
            ps.setBoolean(6, isActive);
            ps.setInt(7, productId);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources(null, ps, conn);
        }
    }
    
    public boolean deleteProductImage(int imageId) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = getConnection();
            ps = conn.prepareStatement("DELETE FROM ProductImages WHERE ImageID = ?");
            ps.setInt(1, imageId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources(null, ps, conn);
        }
    }
    
    // ========== VARIANT MANAGEMENT METHODS ==========
    
    /**
     * Insert variant mới và trả về variantId
     * Sử dụng cho tính năng Quản lý Biến thể sản phẩm
     */
    public int insertVariant(int productId, String sku, BigDecimal sellingPrice, int stock) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            String sql = "INSERT INTO ProductVariants (ProductID, SKU, CostPrice, SellingPrice, Stock, IsActive, CreatedDate, UpdatedDate) " +
                        "VALUES (?, ?, 0, ?, ?, 1, GETDATE(), GETDATE())";
            
            ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
            ps.setInt(1, productId);
            ps.setString(2, sku);
            ps.setBigDecimal(3, sellingPrice);
            ps.setInt(4, stock);
            
            int rows = ps.executeUpdate();
            if (rows > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
            return -1;
        } catch (SQLException e) {
            e.printStackTrace();
            return -1;
        } finally {
            closeResources(rs, ps, conn);
        }
    }
    
    /**
     * Insert liên kết variant-attribute vào bảng VariantAttributes
     * Sử dụng cho tính năng Quản lý Biến thể sản phẩm
     */
    public boolean insertVariantAttribute(int variantId, int valueId) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = getConnection();
            String sql = "INSERT INTO VariantAttributes (VariantID, ValueID) VALUES (?, ?)";
            
            ps = conn.prepareStatement(sql);
            ps.setInt(1, variantId);
            ps.setInt(2, valueId);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources(null, ps, conn);
        }
    }
    
    /**
     * Delete a product variant
     */
    public boolean deleteProductVariant(int variantId) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = getConnection();
            // First delete variant attributes
            ps = conn.prepareStatement("DELETE FROM VariantAttributes WHERE VariantID = ?");
            ps.setInt(1, variantId);
            ps.executeUpdate();
            ps.close();
            
            // Then delete the variant
            ps = conn.prepareStatement("DELETE FROM ProductVariants WHERE VariantID = ?");
            ps.setInt(1, variantId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources(null, ps, conn);
        }
    }
    
    /**
     * Update an existing product variant
     */
    public boolean updateProductVariant(int variantId, String sku, BigDecimal costPrice, BigDecimal sellingPrice, boolean isActive) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = getConnection();
            String sql = "UPDATE ProductVariants SET SKU = ?, CostPrice = ?, SellingPrice = ?, IsActive = ?, UpdatedDate = GETDATE() WHERE VariantID = ?";
            
            ps = conn.prepareStatement(sql);
            ps.setString(1, sku);
            ps.setBigDecimal(2, costPrice);
            ps.setBigDecimal(3, sellingPrice);
            ps.setBoolean(4, isActive);
            ps.setInt(5, variantId);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources(null, ps, conn);
        }
    }
    
    /**
     * Update only SKU and active status of a product variant (price managed via stock import)
     */
    public boolean updateVariantSkuAndStatus(int variantId, String sku, boolean isActive) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = getConnection();
            String sql = "UPDATE ProductVariants SET SKU = ?, IsActive = ?, UpdatedDate = GETDATE() WHERE VariantID = ?";
            
            ps = conn.prepareStatement(sql);
            ps.setString(1, sku);
            ps.setBoolean(2, isActive);
            ps.setInt(3, variantId);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources(null, ps, conn);
        }
    }
    
    /**
     * Insert a new product variant and return the generated ID
     */
    public int insertProductVariant(int productId, String sku, BigDecimal sellingPrice, int stock) {
        return insertVariant(productId, sku, sellingPrice, stock);
    }
    
    /**
     * Insert variant-attribute value link
     */
    public boolean insertVariantAttributeValue(int variantId, int valueId) {
        return insertVariantAttribute(variantId, valueId);
    }
    
    // Helper method to close resources
    
    
    
    
    
    private void closeResources(ResultSet rs, PreparedStatement ps, Connection conn) {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
        public List<Map<String, Object>> getTopSellingProductsByCategory(int categoryId, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT TOP (?) p.*, ");
            sql.append("c.CategoryName, ");
            sql.append("b.BrandName, ");
            sql.append("(SELECT TOP 1 ImageURL FROM ProductImages WHERE ProductID = p.ProductID AND ImageType = 'main') AS MainImage, ");
            sql.append("(SELECT MIN(SellingPrice) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) AS MinPrice, ");
            sql.append("(SELECT MAX(SellingPrice) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) AS MaxPrice, ");
            sql.append("(SELECT ISNULL(SUM(Stock), 0) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) AS TotalStock, ");
            sql.append("ISNULL((SELECT SUM(od.Quantity) FROM OrderDetails od ");
            sql.append("INNER JOIN Orders o ON od.OrderID = o.OrderID ");
            sql.append("WHERE od.ProductID = p.ProductID AND o.Status IN ('completed', 'shipped', 'delivered')), 0) AS TotalSold ");
            sql.append("FROM Products p ");
            sql.append("LEFT JOIN Categories c ON p.CategoryID = c.CategoryID ");
            sql.append("LEFT JOIN Brands b ON p.BrandID = b.BrandID ");
            sql.append("WHERE p.IsActive = 1 AND p.CategoryID = ? ");
            sql.append("ORDER BY TotalSold DESC, p.CreatedDate DESC");
            
            ps = conn.prepareStatement(sql.toString());
            ps.setInt(1, limit);
            ps.setInt(2, categoryId);
            
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> product = new HashMap<>();
                product.put("productID", rs.getInt("ProductID"));
                product.put("productName", rs.getString("ProductName"));
                product.put("categoryID", rs.getInt("CategoryID"));
                product.put("brandID", rs.getObject("BrandID"));
                product.put("categoryName", rs.getString("CategoryName"));
                product.put("brandName", rs.getString("BrandName"));
                product.put("mainImageUrl", rs.getString("MainImage"));
                product.put("minPrice", rs.getBigDecimal("MinPrice"));
                product.put("maxPrice", rs.getBigDecimal("MaxPrice"));
                product.put("totalStock", rs.getInt("TotalStock"));
                product.put("totalSold", rs.getInt("TotalSold"));
                product.put("createdDate", rs.getTimestamp("CreatedDate"));
                list.add(product);
            }
            
        } catch (SQLException e) {
            System.err.println("Error in getTopSellingProductsByCategory: " + e.getMessage());
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
     * Get newest products by category
     * @param categoryId Category ID
     * @param limit Number of products to return
     * @return List of newest products
     */
    public List<Map<String, Object>> getNewestProductsByCategory(int categoryId, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT TOP (?) p.*, ");
            sql.append("c.CategoryName, ");
            sql.append("b.BrandName, ");
            sql.append("(SELECT TOP 1 ImageURL FROM ProductImages WHERE ProductID = p.ProductID AND ImageType = 'main') AS MainImage, ");
            sql.append("(SELECT MIN(SellingPrice) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) AS MinPrice, ");
            sql.append("(SELECT MAX(SellingPrice) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) AS MaxPrice, ");
            sql.append("(SELECT ISNULL(SUM(Stock), 0) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) AS TotalStock ");
            sql.append("FROM Products p ");
            sql.append("LEFT JOIN Categories c ON p.CategoryID = c.CategoryID ");
            sql.append("LEFT JOIN Brands b ON p.BrandID = b.BrandID ");
            sql.append("WHERE p.IsActive = 1 AND p.CategoryID = ? ");
            sql.append("ORDER BY p.CreatedDate DESC");
            
            ps = conn.prepareStatement(sql.toString());
            ps.setInt(1, limit);
            ps.setInt(2, categoryId);
            
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> product = new HashMap<>();
                product.put("productID", rs.getInt("ProductID"));
                product.put("productName", rs.getString("ProductName"));
                product.put("categoryID", rs.getInt("CategoryID"));
                product.put("brandID", rs.getObject("BrandID"));
                product.put("categoryName", rs.getString("CategoryName"));
                product.put("brandName", rs.getString("BrandName"));
                product.put("mainImageUrl", rs.getString("MainImage"));
                product.put("minPrice", rs.getBigDecimal("MinPrice"));
                product.put("maxPrice", rs.getBigDecimal("MaxPrice"));
                product.put("totalStock", rs.getInt("TotalStock"));
                product.put("createdDate", rs.getTimestamp("CreatedDate"));
                list.add(product);
            }
            
        } catch (SQLException e) {
            System.err.println("Error in getNewestProductsByCategory: " + e.getMessage());
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
     * Lấy danh sách thuộc tính và giá trị của sản phẩm theo nhóm
     * Ví dụ: {Màu sắc: [Trắng, Đen], Size: [S, M, L]}
     */
    public List<Map<String, Object>> getProductAttributeGroups(int productId) {
        List<Map<String, Object>> result = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            // Lấy tất cả thuộc tính và giá trị của các variant thuộc sản phẩm này
            String sql = "SELECT DISTINCT pa.AttributeID, pa.AttributeName, av.ValueID, av.ValueName " +
                        "FROM ProductVariants pv " +
                        "JOIN VariantAttributes va ON pv.VariantID = va.VariantID " +
                        "JOIN AttributeValues av ON va.ValueID = av.ValueID " +
                        "JOIN ProductAttributes pa ON av.AttributeID = pa.AttributeID " +
                        "WHERE pv.ProductID = ? AND pv.IsActive = 1 " +
                        "ORDER BY pa.AttributeID, av.ValueName";
            
            ps = conn.prepareStatement(sql);
            ps.setInt(1, productId);
            rs = ps.executeQuery();
            
            // Group by attribute
            Map<Integer, Map<String, Object>> attrMap = new HashMap<>();
            
            while (rs.next()) {
                int attrId = rs.getInt("AttributeID");
                String attrName = rs.getString("AttributeName");
                int valueId = rs.getInt("ValueID");
                String valueName = rs.getString("ValueName");
                
                if (!attrMap.containsKey(attrId)) {
                    Map<String, Object> attr = new HashMap<>();
                    attr.put("attributeId", attrId);
                    attr.put("attributeName", attrName);
                    attr.put("values", new ArrayList<Map<String, Object>>());
                    attrMap.put(attrId, attr);
                }
                
                Map<String, Object> value = new HashMap<>();
                value.put("valueId", valueId);
                value.put("valueName", valueName);
                ((List<Map<String, Object>>) attrMap.get(attrId).get("values")).add(value);
            }
            
            result.addAll(attrMap.values());
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(rs, ps, conn);
        }
        
        return result;
    }
    
    /**
     * Tìm variant theo tổ hợp các giá trị thuộc tính đã chọn
     * @param productId ID sản phẩm
     * @param selectedValueIds Danh sách các ValueID đã chọn
     * @return Thông tin variant nếu tìm thấy, null nếu không
     */
    public Map<String, Object> findVariantByAttributes(int productId, List<Integer> selectedValueIds) {
        if (selectedValueIds == null || selectedValueIds.isEmpty()) {
            return null;
        }
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            
            // Tìm variant có đúng tất cả các giá trị thuộc tính đã chọn
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT pv.VariantID, pv.SKU, pv.SellingPrice, pv.CompareAtPrice, pv.Stock, pv.ReservedStock ");
            sql.append("FROM ProductVariants pv ");
            sql.append("WHERE pv.ProductID = ? AND pv.IsActive = 1 ");
            sql.append("AND (SELECT COUNT(*) FROM VariantAttributes va WHERE va.VariantID = pv.VariantID) = ? ");
            sql.append("AND ? = (SELECT COUNT(*) FROM VariantAttributes va WHERE va.VariantID = pv.VariantID AND va.ValueID IN (");
            
            // Build IN clause
            for (int i = 0; i < selectedValueIds.size(); i++) {
                if (i > 0) sql.append(",");
                sql.append("?");
            }
            sql.append("))");
            
            ps = conn.prepareStatement(sql.toString());
            int paramIndex = 1;
            ps.setInt(paramIndex++, productId);
            ps.setInt(paramIndex++, selectedValueIds.size());
            ps.setInt(paramIndex++, selectedValueIds.size());
            
            for (Integer valueId : selectedValueIds) {
                ps.setInt(paramIndex++, valueId);
            }
            
            rs = ps.executeQuery();
            
            if (rs.next()) {
                Map<String, Object> variant = new HashMap<>();
                variant.put("variantId", rs.getInt("VariantID"));
                variant.put("sku", rs.getString("SKU"));
                variant.put("sellingPrice", rs.getBigDecimal("SellingPrice"));
                variant.put("compareAtPrice", rs.getBigDecimal("CompareAtPrice"));
                variant.put("stock", rs.getInt("Stock"));
                variant.put("reservedStock", rs.getInt("ReservedStock"));
                variant.put("availableStock", rs.getInt("Stock") - rs.getInt("ReservedStock"));
                return variant;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(rs, ps, conn);
        }
        
        return null;
    }
    
    /**
     * Lấy thông tin thuộc tính của một variant cụ thể
     */
    public List<Map<String, Object>> getVariantAttributeValues(int variantId) {
        List<Map<String, Object>> result = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            String sql = "SELECT pa.AttributeID, pa.AttributeName, av.ValueID, av.ValueName " +
                        "FROM VariantAttributes va " +
                        "JOIN AttributeValues av ON va.ValueID = av.ValueID " +
                        "JOIN ProductAttributes pa ON av.AttributeID = pa.AttributeID " +
                        "WHERE va.VariantID = ? " +
                        "ORDER BY pa.AttributeID";
            
            ps = conn.prepareStatement(sql);
            ps.setInt(1, variantId);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> attr = new HashMap<>();
                attr.put("attributeId", rs.getInt("AttributeID"));
                attr.put("attributeName", rs.getString("AttributeName"));
                attr.put("valueId", rs.getInt("ValueID"));
                attr.put("valueName", rs.getString("ValueName"));
                result.add(attr);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(rs, ps, conn);
        }
        
        return result;
    }
    
    /**
     * Get all products (simple list for dropdown)
     */
    public List<Map<String, Object>> getAllProducts() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT ProductID, ProductName FROM Products WHERE IsActive = 1 ORDER BY ProductName";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> product = new HashMap<>();
                product.put("productID", rs.getInt("ProductID"));
                product.put("productName", rs.getString("ProductName"));
                list.add(product);
            }
        } catch (SQLException e) {
            System.err.println("Error in getAllProducts: " + e.getMessage());
            e.printStackTrace();
        }
        
        return list;
    }
}
