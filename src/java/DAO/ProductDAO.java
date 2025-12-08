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
     * Lấy danh sách sản phẩm với filter khoảng giá
     */
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
            sql.append("LEFT JOIN Brands b ON p.BrandID = b.BrandID ");
            sql.append("WHERE 1=1 ");
            
            if (search != null && !search.trim().isEmpty()) sql.append("AND p.ProductName LIKE ? ");
            if (categoryId != null) sql.append("AND p.CategoryID = ? ");
            if (brandId != null) sql.append("AND p.BrandID = ? ");
            if (isActive != null) sql.append("AND p.IsActive = ? ");
            if (minPrice != null || maxPrice != null) {
                sql.append("AND p.ProductID IN (SELECT ProductID FROM ProductVariants WHERE IsActive = 1 ");
                if (minPrice != null) sql.append("AND SellingPrice >= ? ");
                if (maxPrice != null) sql.append("AND SellingPrice <= ? ");
                sql.append(") ");
            }
            
            sql.append("ORDER BY ");
            switch (sortBy != null ? sortBy : "date") {
                case "name": sql.append("p.ProductName "); break;
                case "price": sql.append("MinPrice "); break;
                case "stock": sql.append("TotalStock "); break;
                default: sql.append("p.CreatedDate "); break;
            }
            sql.append("desc".equalsIgnoreCase(sortOrder) ? "DESC " : "ASC ");
            sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
            
            ps = conn.prepareStatement(sql.toString());
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) ps.setString(paramIndex++, "%" + search.trim() + "%");
            if (categoryId != null) ps.setInt(paramIndex++, categoryId);
            if (brandId != null) ps.setInt(paramIndex++, brandId);
            if (isActive != null) ps.setBoolean(paramIndex++, isActive);
            if (minPrice != null) ps.setBigDecimal(paramIndex++, minPrice);
            if (maxPrice != null) ps.setBigDecimal(paramIndex++, maxPrice);
            ps.setInt(paramIndex++, (page - 1) * pageSize);
            ps.setInt(paramIndex++, pageSize);
            
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
                product.put("availableStock", rs.getInt("TotalStock") - rs.getInt("ReservedStock"));
                list.add(product);
            }
        } catch (SQLException e) {
            System.err.println("Error in getProductsWithPriceFilter: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
        return list;
    }
    
    /**
     * Đếm tổng số sản phẩm với filter khoảng giá
     */
    public int getTotalProductsWithPriceFilter(String search, Integer categoryId, Integer brandId,
                                               BigDecimal minPrice, BigDecimal maxPrice, Boolean isActive) {
        int total = 0;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT COUNT(*) FROM Products p WHERE 1=1 ");
            
            if (search != null && !search.trim().isEmpty()) sql.append("AND p.ProductName LIKE ? ");
            if (categoryId != null) sql.append("AND p.CategoryID = ? ");
            if (brandId != null) sql.append("AND p.BrandID = ? ");
            if (isActive != null) sql.append("AND p.IsActive = ? ");
            if (minPrice != null || maxPrice != null) {
                sql.append("AND p.ProductID IN (SELECT ProductID FROM ProductVariants WHERE IsActive = 1 ");
                if (minPrice != null) sql.append("AND SellingPrice >= ? ");
                if (maxPrice != null) sql.append("AND SellingPrice <= ? ");
                sql.append(") ");
            }
            
            ps = conn.prepareStatement(sql.toString());
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) ps.setString(paramIndex++, "%" + search.trim() + "%");
            if (categoryId != null) ps.setInt(paramIndex++, categoryId);
            if (brandId != null) ps.setInt(paramIndex++, brandId);
            if (isActive != null) ps.setBoolean(paramIndex++, isActive);
            if (minPrice != null) ps.setBigDecimal(paramIndex++, minPrice);
            if (maxPrice != null) ps.setBigDecimal(paramIndex++, maxPrice);
            
            rs = ps.executeQuery();
            if (rs.next()) total = rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("Error in getTotalProductsWithPriceFilter: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
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
     * Insert new product into database
     * @param productName - Product name (required)
     * @param categoryId - Category ID (required)
     * @param brandId - Brand ID (nullable)
     * @param description - Product description (nullable)
     * @param specifications - Product specifications (nullable)
     * @param createdBy - Employee ID who created the product
     * @return Product ID of newly created product, or -1 if failed
     */
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
            
            if (brandId != null) {
                ps.setInt(3, brandId);
            } else {
                ps.setNull(3, java.sql.Types.INTEGER);
            }
            
            ps.setString(4, description);
            ps.setString(5, specifications);
            ps.setInt(6, createdBy);
            
            int affectedRows = ps.executeUpdate();
            
            if (affectedRows > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
            
            return -1;
            
        } catch (SQLException e) {
            System.err.println("Error in insertProduct: " + e.getMessage());
            e.printStackTrace();
            return -1;
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Insert product image into database
     * @param productId - Product ID
     * @param imageUrl - Relative URL to image file
     * @param imageType - "main" or "thumbnail"
     * @param sortOrder - Sort order for images (0 for main image, 1,2,3... for thumbnails)
     * @return true if successful, false otherwise
     */
    public boolean insertProductImage(int productId, String imageUrl, 
                                     String imageType, int sortOrder) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = getConnection();
            
            // Database uses SortOrder, not DisplayOrder
            String sql = "INSERT INTO ProductImages (ProductID, ImageURL, ImageType, SortOrder) " +
                        "VALUES (?, ?, ?, ?)";
            
            ps = conn.prepareStatement(sql);
            ps.setInt(1, productId);
            ps.setString(2, imageUrl);
            ps.setString(3, imageType);
            ps.setInt(4, sortOrder);
            
            int rows = ps.executeUpdate();
            System.out.println("Inserted ProductImage: ProductID=" + productId + ", ImageURL=" + imageUrl + ", Type=" + imageType + ", SortOrder=" + sortOrder + ", Rows=" + rows);
            return rows > 0;
            
        } catch (SQLException e) {
            System.err.println("Error in insertProductImage: " + e.getMessage());
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
     * Insert product with images in a single transaction
     * This ensures atomicity - either all inserts succeed or all fail
     * 
     * @param productName - Product name (required)
     * @param categoryId - Category ID (required)
     * @param brandId - Brand ID (nullable)
     * @param description - Product description (nullable)
     * @param specifications - Product specifications (nullable)
     * @param createdBy - Employee ID who created the product
     * @param mainImageUrl - Main image URL (nullable)
     * @param thumbnailUrls - List of thumbnail URLs (nullable)
     * @return Product ID of newly created product, or -1 if failed
     */
    public int insertProductWithImages(String productName, int categoryId, Integer brandId,
                                      String description, String specifications, int createdBy,
                                      String mainImageUrl, List<String> thumbnailUrls) {
        Connection conn = null;
        PreparedStatement psProduct = null;
        PreparedStatement psImage = null;
        ResultSet rs = null;
        int productId = -1;
        
        try {
            conn = getConnection();
            // Start transaction
            conn.setAutoCommit(false);
            
            // Insert product
            String sqlProduct = "INSERT INTO Products (ProductName, CategoryID, BrandID, Description, " +
                               "Specifications, IsActive, CreatedBy, CreatedDate, UpdatedDate) " +
                               "VALUES (?, ?, ?, ?, ?, 1, ?, GETDATE(), GETDATE())";
            
            psProduct = conn.prepareStatement(sqlProduct, PreparedStatement.RETURN_GENERATED_KEYS);
            psProduct.setString(1, productName);
            psProduct.setInt(2, categoryId);
            
            if (brandId != null) {
                psProduct.setInt(3, brandId);
            } else {
                psProduct.setNull(3, java.sql.Types.INTEGER);
            }
            
            psProduct.setString(4, description);
            psProduct.setString(5, specifications);
            psProduct.setInt(6, createdBy);
            
            int affectedRows = psProduct.executeUpdate();
            
            if (affectedRows == 0) {
                conn.rollback();
                return -1;
            }
            
            // Get generated product ID
            rs = psProduct.getGeneratedKeys();
            if (rs.next()) {
                productId = rs.getInt(1);
            } else {
                conn.rollback();
                return -1;
            }
            
            // Insert images if provided
            // Database uses SortOrder, not DisplayOrder
            String sqlImage = "INSERT INTO ProductImages (ProductID, ImageURL, ImageType, SortOrder) " +
                             "VALUES (?, ?, ?, ?)";
            psImage = conn.prepareStatement(sqlImage);
            
            // Insert main image
            if (mainImageUrl != null && !mainImageUrl.trim().isEmpty()) {
                psImage.setInt(1, productId);
                psImage.setString(2, mainImageUrl);
                psImage.setString(3, "main");
                psImage.setInt(4, 0);
                psImage.executeUpdate();
            }
            
            // Insert thumbnails
            if (thumbnailUrls != null && !thumbnailUrls.isEmpty()) {
                for (int i = 0; i < thumbnailUrls.size(); i++) {
                    String thumbnailUrl = thumbnailUrls.get(i);
                    if (thumbnailUrl != null && !thumbnailUrl.trim().isEmpty()) {
                        psImage.setInt(1, productId);
                        psImage.setString(2, thumbnailUrl);
                        psImage.setString(3, "thumbnail");
                        psImage.setInt(4, i + 1);
                        psImage.executeUpdate();
                    }
                }
            }
            
            // Commit transaction
            conn.commit();
            return productId;
            
        } catch (SQLException e) {
            System.err.println("Error in insertProductWithImages: " + e.getMessage());
            e.printStackTrace();
            
            // Rollback on error
            if (conn != null) {
                try {
                    conn.rollback();
                    System.err.println("Transaction rolled back");
                } catch (SQLException ex) {
                    System.err.println("Error rolling back transaction: " + ex.getMessage());
                    ex.printStackTrace();
                }
            }
            return -1;
        } finally {
            try {
                if (rs != null) rs.close();
                if (psProduct != null) psProduct.close();
                if (psImage != null) psImage.close();
                if (conn != null) {
                    conn.setAutoCommit(true); // Reset auto-commit
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Get complete product details by ID
     * @param productId - Product ID
     * @return Map with all product fields + category name + brand name + creator name, or null if not found
     */
    public Map<String, Object> getProductById(int productId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            
            String sql = "SELECT p.*, " +
                        "c.CategoryName, " +
                        "b.BrandName, " +
                        "e.FullName AS CreatedByName, " +
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
                
                // Joined fields
                product.put("categoryName", rs.getString("CategoryName"));
                product.put("brandName", rs.getString("BrandName"));
                product.put("createdByName", rs.getString("CreatedByName"));
                
                // Aggregated fields
                product.put("imageCount", rs.getInt("ImageCount"));
                product.put("variantCount", rs.getInt("VariantCount"));
                product.put("totalStock", rs.getInt("TotalStock"));
                
                return product;
            }
            
            return null; // Product not found
            
        } catch (SQLException e) {
            System.err.println("Error in getProductById: " + e.getMessage());
            e.printStackTrace();
            return null;
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Get all images for a product
     * @param productId - Product ID
     * @return List of Maps with ImageID, ImageURL, ImageType, SortOrder
     */
    public List<Map<String, Object>> getProductImages(int productId) {
        List<Map<String, Object>> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            
            String sql = "SELECT ImageID, ProductID, ImageURL, ImageType, SortOrder " +
                        "FROM ProductImages " +
                        "WHERE ProductID = ? " +
                        "ORDER BY SortOrder ASC";
            
            ps = conn.prepareStatement(sql);
            ps.setInt(1, productId);
            
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> image = new HashMap<>();
                image.put("imageID", rs.getInt("ImageID"));
                image.put("productID", rs.getInt("ProductID"));
                image.put("imageURL", rs.getString("ImageURL"));
                image.put("imageType", rs.getString("ImageType"));
                image.put("sortOrder", rs.getInt("SortOrder"));
                list.add(image);
            }
            
        } catch (SQLException e) {
            System.err.println("Error in getProductImages: " + e.getMessage());
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
     * Get all variants for a product
     * @param productId - Product ID
     * @return List of Maps with variant details
     */
    public List<Map<String, Object>> getProductVariants(int productId) {
        List<Map<String, Object>> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            
            String sql = "SELECT VariantID, ProductID, SKU, CostPrice, SellingPrice, CompareAtPrice, " +
                        "ProfitMargin, ProfitAmount, Stock, ReservedStock, ReorderLevel, IsActive, " +
                        "CreatedDate, UpdatedDate " +
                        "FROM ProductVariants " +
                        "WHERE ProductID = ? " +
                        "ORDER BY CreatedDate DESC";
            
            ps = conn.prepareStatement(sql);
            ps.setInt(1, productId);
            
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> variant = new HashMap<>();
                variant.put("variantID", rs.getInt("VariantID"));
                variant.put("productID", rs.getInt("ProductID"));
                variant.put("sku", rs.getString("SKU"));
                variant.put("costPrice", rs.getBigDecimal("CostPrice"));
                variant.put("sellingPrice", rs.getBigDecimal("SellingPrice"));
                variant.put("compareAtPrice", rs.getBigDecimal("CompareAtPrice"));
                variant.put("profitMargin", rs.getBigDecimal("ProfitMargin"));
                variant.put("profitAmount", rs.getBigDecimal("ProfitAmount"));
                variant.put("stock", rs.getInt("Stock"));
                variant.put("reservedStock", rs.getInt("ReservedStock"));
                variant.put("reorderLevel", rs.getObject("ReorderLevel"));
                variant.put("isActive", rs.getBoolean("IsActive"));
                variant.put("createdDate", rs.getTimestamp("CreatedDate"));
                variant.put("updatedDate", rs.getTimestamp("UpdatedDate"));
                
                // Calculated fields
                int stock = rs.getInt("Stock");
                int reservedStock = rs.getInt("ReservedStock");
                variant.put("availableStock", stock - reservedStock);
                
                list.add(variant);
            }
            
        } catch (SQLException e) {
            System.err.println("Error in getProductVariants: " + e.getMessage());
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
     * Update product basic information
     * @param productId - Product ID
     * @param productName - Product name
     * @param categoryId - Category ID
     * @param brandId - Brand ID (nullable)
     * @param description - Description (nullable)
     * @param specifications - Specifications (nullable)
     * @param isActive - Active status
     * @return true if successful, false otherwise
     */
    public boolean updateProduct(int productId, String productName, int categoryId, Integer brandId,
                                 String description, String specifications, boolean isActive) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = getConnection();
            
            String sql = "UPDATE Products SET ProductName = ?, CategoryID = ?, BrandID = ?, " +
                        "Description = ?, Specifications = ?, IsActive = ?, UpdatedDate = GETDATE() " +
                        "WHERE ProductID = ?";
            
            ps = conn.prepareStatement(sql);
            ps.setString(1, productName);
            ps.setInt(2, categoryId);
            
            if (brandId != null) {
                ps.setInt(3, brandId);
            } else {
                ps.setNull(3, java.sql.Types.INTEGER);
            }
            
            ps.setString(4, description);
            ps.setString(5, specifications);
            ps.setBoolean(6, isActive);
            ps.setInt(7, productId);
            
            int rows = ps.executeUpdate();
            return rows > 0;
            
        } catch (SQLException e) {
            System.err.println("Error in updateProduct: " + e.getMessage());
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
     * Delete product image
     * @param imageId - Image ID
     * @return true if successful, false otherwise
     */
    public boolean deleteProductImage(int imageId) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = getConnection();
            
            String sql = "DELETE FROM ProductImages WHERE ImageID = ?";
            
            ps = conn.prepareStatement(sql);
            ps.setInt(1, imageId);
            
            int rows = ps.executeUpdate();
            return rows > 0;
            
        } catch (SQLException e) {
            System.err.println("Error in deleteProductImage: " + e.getMessage());
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
     * Get employee name by ID
     * @param employeeId - Employee ID
     * @return Employee full name, or "Unknown" if not found
     */
    public String getEmployeeName(int employeeId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            
            String sql = "SELECT FullName FROM Employees WHERE EmployeeID = ?";
            
            ps = conn.prepareStatement(sql);
            ps.setInt(1, employeeId);
            
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getString("FullName");
            }
            
            return "Unknown";
            
        } catch (SQLException e) {
            System.err.println("Error in getEmployeeName: " + e.getMessage());
            e.printStackTrace();
            return "Unknown";
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    // Main method for testing
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