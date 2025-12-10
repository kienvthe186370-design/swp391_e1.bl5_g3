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
            switch (sortBy != null ? sortBy : "date") {
                case "name": sql.append("p.ProductName "); break;
                case "price": sql.append("MinPrice "); break;
                case "stock": sql.append("TotalStock "); break;
                default: sql.append("p.CreatedDate "); break;
            }
            sql.append("desc".equalsIgnoreCase(sortOrder) ? "DESC " : "ASC ");
            
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
                product.put("availableStock", totalStock - reservedStock);
                
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
            switch (sortBy != null ? sortBy : "date") {
                case "name": sql.append("p.ProductName "); break;
                case "price": sql.append("MinPrice "); break;
                case "stock": sql.append("TotalStock "); break;
                default: sql.append("p.CreatedDate "); break;
            }
            sql.append("desc".equalsIgnoreCase(sortOrder) ? "DESC " : "ASC ");
            
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
                product.put("availableStock", totalStock - reservedStock);
                
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
                        "(SELECT ISNULL(SUM(Stock), 0) FROM ProductVariants WHERE ProductID = p.ProductID) AS TotalStock " +
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
            ps = conn.prepareStatement("SELECT VariantID, ProductID, SKU, CostPrice, SellingPrice, CompareAtPrice, " +
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
                v.put("compareAtPrice", rs.getBigDecimal("CompareAtPrice"));
                v.put("profitMargin", rs.getBigDecimal("ProfitMargin"));
                v.put("profitAmount", rs.getBigDecimal("ProfitAmount"));
                v.put("stock", rs.getInt("Stock"));
                v.put("reservedStock", rs.getInt("ReservedStock"));
                v.put("reorderLevel", rs.getObject("ReorderLevel"));
                v.put("isActive", rs.getBoolean("IsActive"));
                v.put("createdDate", rs.getTimestamp("CreatedDate"));
                v.put("updatedDate", rs.getTimestamp("UpdatedDate"));
                
                int stock = rs.getInt("Stock");
                int reserved = rs.getInt("ReservedStock");
                v.put("availableStock", stock - reserved);
                
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
}
