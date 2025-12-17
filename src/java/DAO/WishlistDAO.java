package DAO;

import entity.Wishlist;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * WishlistDAO - Quản lý danh sách yêu thích
 */
public class WishlistDAO extends DBContext {

    /**
     * Lấy danh sách wishlist của customer kèm thông tin sản phẩm
     */
    public List<Wishlist> getWishlistByCustomer(int customerId) {
        List<Wishlist> list = new ArrayList<>();
        String sql = "SELECT w.WishlistID, w.CustomerID, w.ProductID, w.AddedDate, " +
                     "p.ProductName, b.BrandName " +
                     "FROM Wishlists w " +
                     "INNER JOIN Products p ON w.ProductID = p.ProductID " +
                     "LEFT JOIN Brands b ON p.BrandID = b.BrandID " +
                     "WHERE w.CustomerID = ? AND p.IsActive = 1 " +
                     "ORDER BY w.AddedDate DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Wishlist w = new Wishlist();
                w.setWishlistID(rs.getInt("WishlistID"));
                w.setCustomerID(rs.getInt("CustomerID"));
                w.setProductID(rs.getInt("ProductID"));
                w.setAddedDate(rs.getTimestamp("AddedDate"));
                w.setProductName(rs.getString("ProductName"));
                w.setBrandName(rs.getString("BrandName"));
                
                // Load thêm thông tin sản phẩm
                loadProductDetails(w, conn);
                
                list.add(w);
            }
        } catch (SQLException e) {
            System.err.println("WishlistDAO.getWishlistByCustomer error: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }
    
    /**
     * Load thêm thông tin chi tiết sản phẩm (ảnh, giá, tồn kho)
     */
    private void loadProductDetails(Wishlist w, Connection conn) {
        // Load ảnh sản phẩm
        try {
            String imgSql = "SELECT TOP 1 ImageURL FROM ProductImages WHERE ProductID = ? ORDER BY SortOrder ASC";
            try (PreparedStatement ps = conn.prepareStatement(imgSql)) {
                ps.setInt(1, w.getProductID());
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    w.setProductImage(rs.getString("ImageURL"));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error loading product image: " + e.getMessage());
        }
        
        // Load giá và tồn kho - sử dụng SellingPrice và Stock
        try {
            String priceSql = "SELECT MIN(SellingPrice) as MinPrice, SUM(Stock) as TotalStock " +
                              "FROM ProductVariants WHERE ProductID = ? AND IsActive = 1";
            try (PreparedStatement ps = conn.prepareStatement(priceSql)) {
                ps.setInt(1, w.getProductID());
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    w.setPrice(rs.getBigDecimal("MinPrice"));
                    w.setTotalStock(rs.getInt("TotalStock"));
                    w.setFinalPrice(w.getPrice()); // Mặc định giá cuối = giá gốc
                }
            }
        } catch (SQLException e) {
            System.err.println("Error loading product price: " + e.getMessage());
        }
        
        // Load khuyến mãi
        try {
            String promoSql = "SELECT DiscountPercent FROM DiscountCampaigns " +
                              "WHERE ProductID = ? AND IsActive = 1 AND GETDATE() BETWEEN StartDate AND EndDate";
            try (PreparedStatement ps = conn.prepareStatement(promoSql)) {
                ps.setInt(1, w.getProductID());
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    int discount = rs.getInt("DiscountPercent");
                    w.setHasPromotion(true);
                    w.setDiscountPercent(discount);
                    // Tính giá sau khuyến mãi
                    if (w.getPrice() != null) {
                        java.math.BigDecimal discountAmount = w.getPrice()
                            .multiply(java.math.BigDecimal.valueOf(discount))
                            .divide(java.math.BigDecimal.valueOf(100));
                        w.setFinalPrice(w.getPrice().subtract(discountAmount));
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Error loading promotion: " + e.getMessage());
        }
    }

    /**
     * Thêm sản phẩm vào wishlist
     */
    public boolean addToWishlist(int customerId, int productId) {
        String sql = "INSERT INTO Wishlists (CustomerID, ProductID) VALUES (?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("WishlistDAO.addToWishlist error: " + e.getMessage());
            return false;
        }
    }

    /**
     * Xóa sản phẩm khỏi wishlist
     */
    public boolean removeFromWishlist(int customerId, int productId) {
        String sql = "DELETE FROM Wishlists WHERE CustomerID = ? AND ProductID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("WishlistDAO.removeFromWishlist error: " + e.getMessage());
            return false;
        }
    }

    /**
     * Xóa item theo WishlistID
     */
    public boolean removeById(int wishlistId, int customerId) {
        String sql = "DELETE FROM Wishlists WHERE WishlistID = ? AND CustomerID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, wishlistId);
            ps.setInt(2, customerId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("WishlistDAO.removeById error: " + e.getMessage());
            return false;
        }
    }

    /**
     * Kiểm tra sản phẩm có trong wishlist không
     */
    public boolean isInWishlist(int customerId, int productId) {
        String sql = "SELECT 1 FROM Wishlists WHERE CustomerID = ? AND ProductID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, productId);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            System.err.println("WishlistDAO.isInWishlist error: " + e.getMessage());
            return false;
        }
    }

    /**
     * Đếm số sản phẩm trong wishlist
     */
    public int countWishlist(int customerId) {
        String sql = "SELECT COUNT(*) FROM Wishlists WHERE CustomerID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("WishlistDAO.countWishlist error: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Toggle wishlist - thêm nếu chưa có, xóa nếu đã có
     * @return true nếu đã thêm, false nếu đã xóa
     */
    public boolean toggleWishlist(int customerId, int productId) {
        if (isInWishlist(customerId, productId)) {
            removeFromWishlist(customerId, productId);
            return false;
        } else {
            addToWishlist(customerId, productId);
            return true;
        }
    }
}
