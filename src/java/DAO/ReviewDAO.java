package DAO;

import entity.Review;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.*;

/**
 * DAO cho quản lý Reviews (F_32, F_33).
 */
public class ReviewDAO extends DBContext {

    // ==================== CUSTOMER METHODS ====================

    /**
     * Kiểm tra customer có thể review orderDetail này không
     * Điều kiện: OrderStatus IN ('Delivered', 'Completed') AND IsReviewed=0
     */
    public boolean canReview(int orderDetailId, int customerId) {
        String sql = """
            SELECT 1 FROM OrderDetails od
            JOIN Orders o ON od.OrderID = o.OrderID
            WHERE od.OrderDetailID = ?
              AND o.CustomerID = ?
              AND o.OrderStatus IN ('Delivered', 'Completed')
              AND od.IsReviewed = 0
            """;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderDetailId);
            ps.setInt(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Lấy thông tin sản phẩm từ OrderDetail để hiển thị form review
     */
    public Map<String, Object> getOrderDetailForReview(int orderDetailId, int customerId) {
        String sql = """
            SELECT od.OrderDetailID, pv.ProductID, od.VariantID, od.ProductName, od.SKU,
                   od.Quantity, od.UnitPrice,
                   p.ProductName AS OriginalProductName,
                   b.BrandName,
                   (SELECT TOP 1 ImageURL FROM ProductImages WHERE ProductID = pv.ProductID AND ImageType = 'main') AS ProductImage
            FROM OrderDetails od
            JOIN Orders o ON od.OrderID = o.OrderID
            JOIN ProductVariants pv ON od.VariantID = pv.VariantID
            JOIN Products p ON pv.ProductID = p.ProductID
            LEFT JOIN Brands b ON p.BrandID = b.BrandID
            WHERE od.OrderDetailID = ?
              AND o.CustomerID = ?
              AND o.OrderStatus IN ('Delivered', 'Completed')
              AND od.IsReviewed = 0
            """;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderDetailId);
            ps.setInt(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> data = new HashMap<>();
                    data.put("orderDetailId", rs.getInt("OrderDetailID"));
                    data.put("productId", rs.getInt("ProductID"));
                    data.put("variantId", rs.getObject("VariantID"));
                    data.put("productName", rs.getString("ProductName"));
                    data.put("sku", rs.getString("SKU"));
                    data.put("quantity", rs.getInt("Quantity"));
                    data.put("unitPrice", rs.getBigDecimal("UnitPrice"));
                    data.put("brandName", rs.getString("BrandName"));
                    data.put("productImage", rs.getString("ProductImage"));
                    return data;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Tạo review mới + update IsReviewed=1 (transaction)
     */
    public int createReview(Review review) {
        String insertSql = """
            INSERT INTO Reviews (OrderDetailID, CustomerID, ProductID, Rating, ReviewTitle, ReviewContent, ReviewStatus, ReviewDate)
            VALUES (?, ?, ?, ?, ?, ?, 'published', GETDATE())
            """;
        String updateSql = "UPDATE OrderDetails SET IsReviewed = 1 WHERE OrderDetailID = ?";
        
        Connection con = null;
        try {
            con = getConnection();
            con.setAutoCommit(false);
            
            int reviewId;
            try (PreparedStatement ps = con.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, review.getOrderDetailId());
                ps.setInt(2, review.getCustomerId());
                ps.setInt(3, review.getProductId());
                ps.setInt(4, review.getRating());
                ps.setString(5, review.getReviewTitle());
                ps.setString(6, review.getReviewContent());
                ps.executeUpdate();
                
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        reviewId = rs.getInt(1);
                    } else {
                        throw new SQLException("Failed to get generated review ID");
                    }
                }
            }
            
            try (PreparedStatement ps = con.prepareStatement(updateSql)) {
                ps.setInt(1, review.getOrderDetailId());
                ps.executeUpdate();
            }
            
            con.commit();
            return reviewId;
            
        } catch (SQLException e) {
            if (con != null) {
                try { con.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            return -1;
        } finally {
            if (con != null) {
                try { con.setAutoCommit(true); con.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }

    /**
     * Lấy danh sách reviews của customer
     */
    public List<Review> getReviewsByCustomer(int customerId, int page, int pageSize) {
        List<Review> list = new ArrayList<>();
        String sql = """
            SELECT r.*, p.ProductName, b.BrandName, e.FullName AS RepliedByName,
                   od.SKU AS VariantSKU,
                   (SELECT TOP 1 ImageURL FROM ProductImages WHERE ProductID = r.ProductID AND ImageType = 'main') AS ProductImage
            FROM Reviews r
            JOIN Products p ON r.ProductID = p.ProductID
            LEFT JOIN Brands b ON p.BrandID = b.BrandID
            LEFT JOIN Employees e ON r.RepliedBy = e.EmployeeID
            LEFT JOIN OrderDetails od ON r.OrderDetailID = od.OrderDetailID
            WHERE r.CustomerID = ?
            ORDER BY r.ReviewDate DESC
            OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
            """;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, (page - 1) * pageSize);
            ps.setInt(3, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapReview(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countReviewsByCustomer(int customerId) {
        String sql = "SELECT COUNT(*) FROM Reviews WHERE CustomerID = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ==================== PRODUCT PAGE METHODS ====================

    /**
     * Lấy thống kê reviews của sản phẩm
     */
    public Map<String, Object> getProductReviewStats(int productId) {
        Map<String, Object> stats = new HashMap<>();
        String sql = """
            SELECT 
                COUNT(*) AS TotalReviews,
                ISNULL(AVG(CAST(Rating AS FLOAT)), 0) AS AvgRating,
                SUM(CASE WHEN Rating = 5 THEN 1 ELSE 0 END) AS Count5Star,
                SUM(CASE WHEN Rating = 4 THEN 1 ELSE 0 END) AS Count4Star,
                SUM(CASE WHEN Rating = 3 THEN 1 ELSE 0 END) AS Count3Star,
                SUM(CASE WHEN Rating = 2 THEN 1 ELSE 0 END) AS Count2Star,
                SUM(CASE WHEN Rating = 1 THEN 1 ELSE 0 END) AS Count1Star
            FROM Reviews
            WHERE ProductID = ? AND ReviewStatus = 'published'
            """;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("totalReviews", rs.getInt("TotalReviews"));
                    stats.put("avgRating", Math.round(rs.getDouble("AvgRating") * 10.0) / 10.0);
                    stats.put("count5Star", rs.getInt("Count5Star"));
                    stats.put("count4Star", rs.getInt("Count4Star"));
                    stats.put("count3Star", rs.getInt("Count3Star"));
                    stats.put("count2Star", rs.getInt("Count2Star"));
                    stats.put("count1Star", rs.getInt("Count1Star"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }

    /**
     * Lấy danh sách reviews của sản phẩm (published + hidden của chính customer)
     */
    public List<Review> getProductReviews(int productId, Integer currentCustomerId, Integer filterRating, int page, int pageSize) {
        List<Review> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
            SELECT r.*, c.FullName AS CustomerName, e.FullName AS RepliedByName,
                   od.SKU AS VariantSKU
            FROM Reviews r
            JOIN Customers c ON r.CustomerID = c.CustomerID
            LEFT JOIN Employees e ON r.RepliedBy = e.EmployeeID
            LEFT JOIN OrderDetails od ON r.OrderDetailID = od.OrderDetailID
            WHERE r.ProductID = ?
              AND (r.ReviewStatus = 'published'
            """);
        
        if (currentCustomerId != null) {
            sql.append(" OR r.CustomerID = ?");
        }
        sql.append(")");
        
        if (filterRating != null && filterRating >= 1 && filterRating <= 5) {
            sql.append(" AND r.Rating = ?");
        }
        
        sql.append(" ORDER BY r.ReviewDate DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setInt(idx++, productId);
            if (currentCustomerId != null) {
                ps.setInt(idx++, currentCustomerId);
            }
            if (filterRating != null && filterRating >= 1 && filterRating <= 5) {
                ps.setInt(idx++, filterRating);
            }
            ps.setInt(idx++, (page - 1) * pageSize);
            ps.setInt(idx++, pageSize);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapReviewWithCustomer(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countProductReviews(int productId, Integer currentCustomerId, Integer filterRating) {
        StringBuilder sql = new StringBuilder("""
            SELECT COUNT(*) FROM Reviews r
            WHERE r.ProductID = ?
              AND (r.ReviewStatus = 'published'
            """);
        
        if (currentCustomerId != null) {
            sql.append(" OR r.CustomerID = ?");
        }
        sql.append(")");
        
        if (filterRating != null && filterRating >= 1 && filterRating <= 5) {
            sql.append(" AND r.Rating = ?");
        }
        
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setInt(idx++, productId);
            if (currentCustomerId != null) {
                ps.setInt(idx++, currentCustomerId);
            }
            if (filterRating != null && filterRating >= 1 && filterRating <= 5) {
                ps.setInt(idx++, filterRating);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ==================== MARKETER METHODS ====================

    /**
     * Tìm kiếm reviews với filters
     */
    public List<Review> searchReviews(String status, Integer rating, Integer productId, 
                                       Boolean hasReply, String dateFrom, String dateTo, 
                                       int page, int pageSize) {
        List<Review> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
            SELECT r.*, c.FullName AS CustomerName, p.ProductName, b.BrandName, e.FullName AS RepliedByName,
                   (SELECT TOP 1 ImageURL FROM ProductImages WHERE ProductID = r.ProductID AND ImageType = 'main') AS ProductImage
            FROM Reviews r
            JOIN Customers c ON r.CustomerID = c.CustomerID
            JOIN Products p ON r.ProductID = p.ProductID
            LEFT JOIN Brands b ON p.BrandID = b.BrandID
            LEFT JOIN Employees e ON r.RepliedBy = e.EmployeeID
            WHERE 1=1
            """);
        
        List<Object> params = new ArrayList<>();
        
        if (status != null && !status.isEmpty()) {
            sql.append(" AND r.ReviewStatus = ?");
            params.add(status);
        }
        if (rating != null && rating >= 1 && rating <= 5) {
            sql.append(" AND r.Rating = ?");
            params.add(rating);
        }
        if (productId != null) {
            sql.append(" AND r.ProductID = ?");
            params.add(productId);
        }
        if (hasReply != null) {
            if (hasReply) {
                sql.append(" AND r.ReplyContent IS NOT NULL");
            } else {
                sql.append(" AND r.ReplyContent IS NULL");
            }
        }
        if (dateFrom != null && !dateFrom.isEmpty()) {
            sql.append(" AND r.ReviewDate >= ?");
            params.add(dateFrom);
        }
        if (dateTo != null && !dateTo.isEmpty()) {
            sql.append(" AND r.ReviewDate < DATEADD(day, 1, ?)");
            params.add(dateTo);
        }
        
        sql.append(" ORDER BY r.ReviewDate DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * pageSize);
        params.add(pageSize);
        
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapReviewFull(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countReviews(String status, Integer rating, Integer productId, 
                           Boolean hasReply, String dateFrom, String dateTo) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Reviews r WHERE 1=1");
        List<Object> params = new ArrayList<>();
        
        if (status != null && !status.isEmpty()) {
            sql.append(" AND r.ReviewStatus = ?");
            params.add(status);
        }
        if (rating != null && rating >= 1 && rating <= 5) {
            sql.append(" AND r.Rating = ?");
            params.add(rating);
        }
        if (productId != null) {
            sql.append(" AND r.ProductID = ?");
            params.add(productId);
        }
        if (hasReply != null) {
            if (hasReply) {
                sql.append(" AND r.ReplyContent IS NOT NULL");
            } else {
                sql.append(" AND r.ReplyContent IS NULL");
            }
        }
        if (dateFrom != null && !dateFrom.isEmpty()) {
            sql.append(" AND r.ReviewDate >= ?");
            params.add(dateFrom);
        }
        if (dateTo != null && !dateTo.isEmpty()) {
            sql.append(" AND r.ReviewDate < DATEADD(day, 1, ?)");
            params.add(dateTo);
        }
        
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Lấy chi tiết 1 review
     */
    public Review getReviewById(int reviewId) {
        String sql = """
            SELECT r.*, c.FullName AS CustomerName, p.ProductName, b.BrandName, e.FullName AS RepliedByName,
                   od.SKU AS VariantSKU,
                   (SELECT TOP 1 ImageURL FROM ProductImages WHERE ProductID = r.ProductID AND ImageType = 'main') AS ProductImage
            FROM Reviews r
            JOIN Customers c ON r.CustomerID = c.CustomerID
            JOIN Products p ON r.ProductID = p.ProductID
            LEFT JOIN Brands b ON p.BrandID = b.BrandID
            LEFT JOIN Employees e ON r.RepliedBy = e.EmployeeID
            LEFT JOIN OrderDetails od ON r.OrderDetailID = od.OrderDetailID
            WHERE r.ReviewID = ?
            """;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, reviewId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapReviewFull(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Cập nhật trạng thái review (ẩn/hiện)
     */
    public boolean updateReviewStatus(int reviewId, String status) {
        String sql = "UPDATE Reviews SET ReviewStatus = ? WHERE ReviewID = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, reviewId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Marketer reply review
     */
    public boolean addReply(int reviewId, String replyContent, int employeeId) {
        String sql = "UPDATE Reviews SET ReplyContent = ?, ReplyDate = GETDATE(), RepliedBy = ? WHERE ReviewID = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, replyContent);
            ps.setInt(2, employeeId);
            ps.setInt(3, reviewId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Lấy danh sách products để filter
     */
    public List<Map<String, Object>> getProductsForFilter() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = """
            SELECT DISTINCT p.ProductID, p.ProductName
            FROM Products p
            JOIN Reviews r ON p.ProductID = r.ProductID
            ORDER BY p.ProductName
            """;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("productId", rs.getInt("ProductID"));
                m.put("productName", rs.getString("ProductName"));
                list.add(m);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ==================== HELPER METHODS ====================

    private Review mapReview(ResultSet rs) throws SQLException {
        Review r = new Review();
        r.setReviewId(rs.getInt("ReviewID"));
        r.setOrderDetailId(rs.getInt("OrderDetailID"));
        r.setCustomerId(rs.getInt("CustomerID"));
        r.setProductId(rs.getInt("ProductID"));
        r.setRating(rs.getInt("Rating"));
        r.setReviewTitle(rs.getString("ReviewTitle"));
        r.setReviewContent(rs.getString("ReviewContent"));
        r.setReviewStatus(rs.getString("ReviewStatus"));
        Timestamp rd = rs.getTimestamp("ReviewDate");
        if (rd != null) r.setReviewDate(rd.toLocalDateTime());
        r.setReplyContent(rs.getString("ReplyContent"));
        Timestamp rpd = rs.getTimestamp("ReplyDate");
        if (rpd != null) r.setReplyDate(rpd.toLocalDateTime());
        r.setRepliedBy(rs.getObject("RepliedBy") != null ? rs.getInt("RepliedBy") : null);
        
        // JOIN fields
        try { r.setProductName(rs.getString("ProductName")); } catch (SQLException ignored) {}
        try { r.setBrandName(rs.getString("BrandName")); } catch (SQLException ignored) {}
        try { r.setProductImage(rs.getString("ProductImage")); } catch (SQLException ignored) {}
        try { r.setRepliedByName(rs.getString("RepliedByName")); } catch (SQLException ignored) {}
        try { r.setVariantSku(rs.getString("VariantSKU")); } catch (SQLException ignored) {}
        
        return r;
    }

    private Review mapReviewWithCustomer(ResultSet rs) throws SQLException {
        Review r = mapReview(rs);
        try { r.setCustomerName(rs.getString("CustomerName")); } catch (SQLException ignored) {}
        return r;
    }

    private Review mapReviewFull(ResultSet rs) throws SQLException {
        Review r = mapReviewWithCustomer(rs);
        return r;
    }
}
