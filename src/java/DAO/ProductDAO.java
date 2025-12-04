package DAO;

import entity.ProductListItem;
import entity.ProductVariant;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO phục vụ F07 – màn hình danh sách sản phẩm (admin).
 */
public class ProductDAO {

    private final DBContext db = new DBContext();

    public List<ProductListItem> search(String keyword,
                                        Integer categoryId,
                                        Integer brandId,
                                        Boolean isActive,
                                        int page,
                                        int pageSize) throws SQLException {
        List<ProductListItem> list = new ArrayList<>();
        String sql = """
                SELECT  p.ProductID,
                        p.ProductName,
                        c.CategoryName,
                        b.BrandName,
                        p.IsActive,
                        p.CreatedDate,
                        COUNT(v.VariantID)      AS VariantCount,
                        MIN(v.SellingPrice)     AS MinPrice,
                        MAX(v.SellingPrice)     AS MaxPrice,
                        SUM(ISNULL(v.Stock,0))  AS TotalStock,
                        SUM(ISNULL(v.ReservedStock,0)) AS ReservedStock,
                        (SELECT TOP 1 ImageURL FROM ProductImages 
                         WHERE ProductID = p.ProductID AND ImageType = 'main' 
                         ORDER BY SortOrder) AS MainImageUrl
                FROM    Products p
                LEFT JOIN Categories c      ON p.CategoryID = c.CategoryID
                LEFT JOIN Brands b          ON p.BrandID = b.BrandID
                LEFT JOIN ProductVariants v ON p.ProductID = v.ProductID AND v.IsActive = 1
                WHERE   (? IS NULL OR p.ProductName LIKE '%' + ? + '%')
                  AND   (? IS NULL OR p.CategoryID = ?)
                  AND   (? IS NULL OR p.BrandID = ?)
                  AND   (? IS NULL OR p.IsActive = ?)
                GROUP BY p.ProductID, p.ProductName, c.CategoryName, b.BrandName, p.IsActive, p.CreatedDate
                ORDER BY p.CreatedDate DESC
                OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
                """;

        try (Connection con = db.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            int idx = 1;

            // keyword
            if (keyword == null || keyword.trim().isEmpty()) {
                ps.setObject(idx++, null);
                ps.setObject(idx++, null);
            } else {
                ps.setString(idx++, keyword.trim());
                ps.setString(idx++, keyword.trim());
            }

            // category
            if (categoryId == null) {
                ps.setObject(idx++, null);
                ps.setObject(idx++, null);
            } else {
                ps.setInt(idx++, categoryId);
                ps.setInt(idx++, categoryId);
            }

            // brand
            if (brandId == null) {
                ps.setObject(idx++, null);
                ps.setObject(idx++, null);
            } else {
                ps.setInt(idx++, brandId);
                ps.setInt(idx++, brandId);
            }

            // isActive
            if (isActive == null) {
                ps.setObject(idx++, null);
                ps.setObject(idx++, null);
            } else {
                ps.setBoolean(idx++, isActive);
                ps.setBoolean(idx++, isActive);
            }

            int offset = (page - 1) * pageSize;
            ps.setInt(idx++, offset);
            ps.setInt(idx, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductListItem item = new ProductListItem();
                    item.setProductId(rs.getInt("ProductID"));
                    item.setProductName(rs.getString("ProductName"));
                    item.setCategoryName(rs.getString("CategoryName"));
                    item.setBrandName(rs.getString("BrandName"));
                    item.setActive(rs.getBoolean("IsActive"));
                    Timestamp created = rs.getTimestamp("CreatedDate");
                    if (created != null) {
                        item.setCreatedDate(created.toLocalDateTime());
                    }
                    item.setVariantCount(rs.getInt("VariantCount"));
                    item.setMinPrice(rs.getBigDecimal("MinPrice"));
                    item.setMaxPrice(rs.getBigDecimal("MaxPrice"));
                    item.setTotalStock(rs.getInt("TotalStock"));
                    item.setReservedStock(rs.getInt("ReservedStock"));
                    String imgUrl = rs.getString("MainImageUrl");
                    item.setImageUrl(imgUrl != null ? imgUrl : "");
                    list.add(item);
                }
            }
        }
        return list;
    }

    public List<ProductVariant> getVariantsByProductId(int productId) throws SQLException {
        List<ProductVariant> list = new ArrayList<>();
        String sql = """
                SELECT VariantID, ProductID, SKU, CostPrice, SellingPrice,
                       Stock, ReorderLevel, IsActive, CreatedDate, UpdatedDate
                FROM ProductVariants
                WHERE ProductID = ?
                ORDER BY VariantID
                """;
        try (Connection con = db.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductVariant v = new ProductVariant();
                    v.setVariantId(rs.getInt("VariantID"));
                    v.setProductId(rs.getInt("ProductID"));
                    v.setSku(rs.getString("SKU"));
                    v.setCostPrice(rs.getBigDecimal("CostPrice"));
                    v.setSellingPrice(rs.getBigDecimal("SellingPrice"));
                    v.setStock((Integer) rs.getObject("Stock"));
                    v.setReorderLevel((Integer) rs.getObject("ReorderLevel"));
                    v.setActive(rs.getBoolean("IsActive"));
                    Timestamp c = rs.getTimestamp("CreatedDate");
                    if (c != null) {
                        v.setCreatedDate(c.toLocalDateTime());
                    }
                    Timestamp u = rs.getTimestamp("UpdatedDate");
                    if (u != null) {
                        v.setUpdatedDate(u.toLocalDateTime());
                    }
                    list.add(v);
                }
            }
        }
        return list;
    }

    public void updateVariantBasicInfo(ProductVariant v) throws SQLException {
        String sql = """
                UPDATE ProductVariants
                SET SellingPrice = ?, Stock = ?, IsActive = ?, UpdatedDate = ?
                WHERE VariantID = ?
                """;
        try (Connection con = db.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setBigDecimal(1, v.getSellingPrice());
            if (v.getStock() == null) {
                ps.setObject(2, null);
            } else {
                ps.setInt(2, v.getStock());
            }
            ps.setBoolean(3, v.isActive());
            ps.setTimestamp(4, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(5, v.getVariantId());
            ps.executeUpdate();
        }
    }
}



