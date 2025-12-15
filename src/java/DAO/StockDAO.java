package DAO;

import entity.StockReceipt;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Stock Data Access Object
 * Quản lý nhập kho sản phẩm
 */
public class StockDAO extends DBContext {

    /**
     * Lấy thông tin chi tiết stock của một variant
     */
    public Map<String, Object> getStockDetail(int variantId) {
        Map<String, Object> result = new HashMap<>();
        
        String sql = "SELECT pv.VariantID, pv.SKU, pv.SellingPrice, pv.CostPrice, pv.Stock, " +
                     "pv.ProfitMarginTarget, " +
                     "p.ProductID, p.ProductName, " +
                     "(SELECT TOP 1 ImageURL FROM ProductImages WHERE ProductID = p.ProductID AND ImageType = 'main') AS MainImage " +
                     "FROM ProductVariants pv " +
                     "JOIN Products p ON pv.ProductID = p.ProductID " +
                     "WHERE pv.VariantID = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, variantId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                result.put("variantId", rs.getInt("VariantID"));
                result.put("sku", rs.getString("SKU"));
                result.put("sellingPrice", rs.getBigDecimal("SellingPrice"));
                result.put("costPrice", rs.getBigDecimal("CostPrice"));
                result.put("stock", rs.getInt("Stock"));
                result.put("productId", rs.getInt("ProductID"));
                result.put("productName", rs.getString("ProductName"));
                result.put("mainImage", rs.getString("MainImage"));
                result.put("variantName", rs.getString("SKU")); // Dùng SKU thay cho VariantName
                
                // Lấy ProfitMarginTarget (default 30 nếu null)
                BigDecimal profitMarginTarget = rs.getBigDecimal("ProfitMarginTarget");
                if (profitMarginTarget == null) {
                    profitMarginTarget = new BigDecimal("30");
                }
                result.put("profitMarginTarget", profitMarginTarget);
                
                // Lấy tồn kho từ ProductVariants.Stock (đã có sẵn)
                int currentStock = rs.getInt("Stock");
                result.put("currentStock", currentStock);
                
                // Tính giá vốn trung bình từ StockReceipts (nếu có)
                BigDecimal avgCostPrice = calculateAvgCostPrice(variantId);
                // Nếu chưa có phiếu nhập, dùng CostPrice hiện tại
                if (avgCostPrice.compareTo(BigDecimal.ZERO) == 0) {
                    avgCostPrice = rs.getBigDecimal("CostPrice");
                    if (avgCostPrice == null) avgCostPrice = BigDecimal.ZERO;
                }
                result.put("avgCostPrice", avgCostPrice);
                
                // Lấy tổng tiền và tổng SL đã nhập (để JS tính preview)
                Map<String, Object> receiptSummary = getReceiptSummaryInternal(variantId);
                result.put("totalCost", receiptSummary.get("totalAmount"));
                result.put("totalReceived", receiptSummary.get("totalQuantity"));
                
                // Tính lợi nhuận
                BigDecimal sellingPrice = rs.getBigDecimal("SellingPrice");
                if (sellingPrice != null && avgCostPrice != null && avgCostPrice.compareTo(BigDecimal.ZERO) > 0) {
                    BigDecimal profitAmount = sellingPrice.subtract(avgCostPrice);
                    BigDecimal profitPercent = profitAmount.multiply(new BigDecimal("100"))
                            .divide(avgCostPrice, 2, RoundingMode.HALF_UP);
                    result.put("profitAmount", profitAmount);
                    result.put("profitPercent", profitPercent);
                } else {
                    result.put("profitAmount", BigDecimal.ZERO);
                    result.put("profitPercent", BigDecimal.ZERO);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }
    
    /**
     * Internal method để lấy receipt summary (dùng trong getStockDetail)
     */
    private Map<String, Object> getReceiptSummaryInternal(int variantId) {
        Map<String, Object> summary = new HashMap<>();
        summary.put("totalQuantity", 0);
        summary.put("totalAmount", BigDecimal.ZERO);
        
        String sql = "SELECT ISNULL(SUM(Quantity), 0) AS TotalQuantity, " +
                     "ISNULL(SUM(Quantity * UnitCost), 0) AS TotalAmount " +
                     "FROM StockReceipts WHERE VariantID = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, variantId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                summary.put("totalQuantity", rs.getInt("TotalQuantity"));
                summary.put("totalAmount", rs.getBigDecimal("TotalAmount"));
            }
        } catch (SQLException e) {
            System.out.println("Error getting receipt summary: " + e.getMessage());
        }
        return summary;
    }

    /**
     * Tính giá vốn trung bình từ bảng StockReceipts
     */
    private BigDecimal calculateAvgCostPrice(int variantId) {
        String sql = "SELECT SUM(Quantity * UnitCost) AS TotalCost, SUM(Quantity) AS TotalQty " +
                     "FROM StockReceipts WHERE VariantID = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, variantId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                BigDecimal totalCost = rs.getBigDecimal("TotalCost");
                int totalQty = rs.getInt("TotalQty");
                
                if (totalCost != null && totalQty > 0) {
                    return totalCost.divide(new BigDecimal(totalQty), 0, RoundingMode.HALF_UP);
                }
            }
        } catch (SQLException e) {
            // Bảng StockReceipts có thể chưa tồn tại
            System.out.println("StockReceipts table may not exist: " + e.getMessage());
        }
        return BigDecimal.ZERO;
    }

    /**
     * Lấy lịch sử nhập kho của một variant
     */
    public List<Map<String, Object>> getReceiptHistory(int variantId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT sr.ReceiptID, sr.Quantity, sr.UnitCost, sr.ReceiptDate, sr.CreatedBy, " +
                     "e.FullName AS CreatedByName " +
                     "FROM StockReceipts sr " +
                     "LEFT JOIN Employees e ON sr.CreatedBy = e.EmployeeID " +
                     "WHERE sr.VariantID = ? " +
                     "ORDER BY sr.ReceiptDate DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, variantId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, Object> receipt = new HashMap<>();
                receipt.put("receiptId", rs.getInt("ReceiptID"));
                receipt.put("quantity", rs.getInt("Quantity"));
                receipt.put("unitCost", rs.getBigDecimal("UnitCost"));
                receipt.put("receiptDate", rs.getTimestamp("ReceiptDate"));
                receipt.put("createdBy", rs.getObject("CreatedBy"));
                receipt.put("createdByName", rs.getString("CreatedByName"));
                
                // Tính thành tiền
                int qty = rs.getInt("Quantity");
                BigDecimal unitCost = rs.getBigDecimal("UnitCost");
                if (unitCost != null) {
                    receipt.put("totalCost", unitCost.multiply(new BigDecimal(qty)));
                }
                
                list.add(receipt);
            }
        } catch (SQLException e) {
            System.out.println("Error getting receipt history: " + e.getMessage());
        }
        return list;
    }

    /**
     * Thêm phiếu nhập kho mới
     */
    public boolean insertReceipt(StockReceipt receipt) {
        String sql = "INSERT INTO StockReceipts (VariantID, Quantity, UnitCost, ReceiptDate, CreatedBy) " +
                     "VALUES (?, ?, ?, GETDATE(), ?)";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, receipt.getVariantId());
            ps.setInt(2, receipt.getQuantity());
            ps.setBigDecimal(3, receipt.getUnitCost());
            if (receipt.getCreatedBy() != null) {
                ps.setInt(4, receipt.getCreatedBy());
            } else {
                ps.setNull(4, Types.INTEGER);
            }
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Tính lại và cập nhật Stock, CostPrice, SellingPrice trong ProductVariants
     * SellingPrice = CostPrice × (1 + ProfitMarginTarget / 100)
     */
    public void recalculateStock(int variantId) {
        String sql = "UPDATE ProductVariants SET " +
                     "Stock = ISNULL((SELECT SUM(Quantity) FROM StockReceipts WHERE VariantID = ?), Stock) " +
                     "- ISNULL((SELECT SUM(od.Quantity) FROM OrderDetails od " +
                     "JOIN Orders o ON od.OrderID = o.OrderID " +
                     "WHERE od.VariantID = ? AND o.OrderStatus = 'Delivered'), 0), " +
                     "CostPrice = ISNULL((SELECT SUM(Quantity * UnitCost) / NULLIF(SUM(Quantity), 0) " +
                     "FROM StockReceipts WHERE VariantID = ?), CostPrice), " +
                     "SellingPrice = ISNULL((SELECT SUM(Quantity * UnitCost) / NULLIF(SUM(Quantity), 0) " +
                     "FROM StockReceipts WHERE VariantID = ?), CostPrice) * (1 + ISNULL(ProfitMarginTarget, 30) / 100.0), " +
                     "UpdatedDate = GETDATE() " +
                     "WHERE VariantID = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, variantId);
            ps.setInt(2, variantId);
            ps.setInt(3, variantId);
            ps.setInt(4, variantId);
            ps.setInt(5, variantId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    /**
     * Cập nhật % lợi nhuận mong muốn và tính lại giá bán
     */
    public boolean updateProfitMarginTarget(int variantId, BigDecimal profitMarginTarget) {
        String sql = "UPDATE ProductVariants SET ProfitMarginTarget = ?, UpdatedDate = GETDATE() " +
                     "WHERE VariantID = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, profitMarginTarget);
            ps.setInt(2, variantId);
            int updated = ps.executeUpdate();
            
            if (updated > 0) {
                // Tính lại SellingPrice với ProfitMarginTarget mới
                recalculateStock(variantId);
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy tổng số lượng và tổng tiền đã nhập của một variant
     */
    public Map<String, Object> getReceiptSummary(int variantId) {
        Map<String, Object> summary = new HashMap<>();
        summary.put("totalQuantity", 0);
        summary.put("totalAmount", BigDecimal.ZERO);
        
        String sql = "SELECT ISNULL(SUM(Quantity), 0) AS TotalQuantity, " +
                     "ISNULL(SUM(Quantity * UnitCost), 0) AS TotalAmount " +
                     "FROM StockReceipts WHERE VariantID = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, variantId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                summary.put("totalQuantity", rs.getInt("TotalQuantity"));
                summary.put("totalAmount", rs.getBigDecimal("TotalAmount"));
            }
        } catch (SQLException e) {
            System.out.println("Error getting receipt summary: " + e.getMessage());
        }
        return summary;
    }

    /**
     * Lấy danh sách tồn kho với filter và phân trang (F_26)
     */
    public List<Map<String, Object>> getStockList(String keyword, Integer categoryId, Integer brandId, 
            String stockStatus, String sortBy, int page, int pageSize) {
        List<Map<String, Object>> list = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT pv.VariantID, pv.SKU, pv.SellingPrice, pv.CostPrice, pv.Stock, ");
        sql.append("p.ProductID, p.ProductName, c.CategoryName, b.BrandName, ");
        sql.append("(SELECT TOP 1 ImageURL FROM ProductImages WHERE ProductID = p.ProductID AND ImageType = 'main') AS ImageUrl, ");
        sql.append("(SELECT COUNT(*) FROM StockReceipts WHERE VariantID = pv.VariantID) AS ReceiptCount ");
        sql.append("FROM ProductVariants pv ");
        sql.append("JOIN Products p ON pv.ProductID = p.ProductID ");
        sql.append("LEFT JOIN Categories c ON p.CategoryID = c.CategoryID ");
        sql.append("LEFT JOIN Brands b ON p.BrandID = b.BrandID ");
        sql.append("WHERE 1=1 ");
        
        // Keyword filter
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (p.ProductName LIKE ? OR pv.SKU LIKE ?) ");
        }
        
        // Category filter
        if (categoryId != null) {
            sql.append("AND p.CategoryID = ? ");
        }
        
        // Brand filter
        if (brandId != null) {
            sql.append("AND p.BrandID = ? ");
        }
        
        // Stock status filter
        if (stockStatus != null && !stockStatus.trim().isEmpty()) {
            switch (stockStatus) {
                case "in_stock":
                    sql.append("AND pv.Stock > 10 ");
                    break;
                case "low_stock":
                    sql.append("AND pv.Stock > 0 AND pv.Stock <= 10 ");
                    break;
                case "out_stock":
                    sql.append("AND pv.Stock = 0 AND (SELECT COUNT(*) FROM StockReceipts WHERE VariantID = pv.VariantID) > 0 ");
                    break;
                case "not_imported":
                    sql.append("AND pv.Stock = 0 AND (SELECT COUNT(*) FROM StockReceipts WHERE VariantID = pv.VariantID) = 0 ");
                    break;
            }
        }
        
        // Sort
        switch (sortBy != null ? sortBy : "id") {
            case "stock":
                sql.append("ORDER BY pv.Stock DESC ");
                break;
            case "cost_price":
                sql.append("ORDER BY pv.CostPrice DESC ");
                break;
            case "created_date":
                sql.append("ORDER BY pv.CreatedDate DESC ");
                break;
            case "id":
            default:
                sql.append("ORDER BY pv.VariantID ASC ");
        }
        
        // Paging
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            
            if (keyword != null && !keyword.trim().isEmpty()) {
                String searchPattern = "%" + keyword + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            
            if (categoryId != null) {
                ps.setInt(paramIndex++, categoryId);
            }
            
            if (brandId != null) {
                ps.setInt(paramIndex++, brandId);
            }
            
            ps.setInt(paramIndex++, (page - 1) * pageSize);
            ps.setInt(paramIndex++, pageSize);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                int variantId = rs.getInt("VariantID");
                int currentStock = rs.getInt("Stock");
                int receiptCount = rs.getInt("ReceiptCount");
                BigDecimal sellingPrice = rs.getBigDecimal("SellingPrice");
                BigDecimal costPrice = rs.getBigDecimal("CostPrice");
                
                item.put("variantId", variantId);
                item.put("sku", rs.getString("SKU"));
                item.put("productName", rs.getString("ProductName"));
                item.put("categoryName", rs.getString("CategoryName"));
                item.put("brandName", rs.getString("BrandName"));
                item.put("imageUrl", rs.getString("ImageUrl"));
                item.put("currentStock", currentStock);
                item.put("sellingPrice", sellingPrice);
                item.put("hasReceipt", receiptCount > 0);
                
                // Tính giá vốn trung bình
                BigDecimal avgCostPrice = calculateAvgCostPrice(variantId);
                if (avgCostPrice.compareTo(BigDecimal.ZERO) == 0 && costPrice != null) {
                    avgCostPrice = costPrice;
                }
                item.put("avgCostPrice", avgCostPrice);
                
                // Tính lợi nhuận
                if (sellingPrice != null && avgCostPrice != null && avgCostPrice.compareTo(BigDecimal.ZERO) > 0) {
                    BigDecimal profitAmount = sellingPrice.subtract(avgCostPrice);
                    BigDecimal profitPercent = profitAmount.multiply(new BigDecimal("100"))
                            .divide(avgCostPrice, 1, RoundingMode.HALF_UP);
                    item.put("profitAmount", profitAmount);
                    item.put("profitPercent", profitPercent);
                } else {
                    item.put("profitAmount", BigDecimal.ZERO);
                    item.put("profitPercent", BigDecimal.ZERO);
                }
                
                // Xác định tình trạng kho
                String status;
                if (currentStock > 10) {
                    status = "in_stock";
                } else if (currentStock > 0) {
                    status = "low_stock";
                } else if (receiptCount > 0) {
                    status = "out_stock";
                } else {
                    status = "not_imported";
                }
                item.put("stockStatus", status);
                
                list.add(item);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Đếm tổng số records cho phân trang
     */
    public int countStockList(String keyword, Integer categoryId, Integer brandId, String stockStatus) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM ProductVariants pv ");
        sql.append("JOIN Products p ON pv.ProductID = p.ProductID ");
        sql.append("WHERE 1=1 ");
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (p.ProductName LIKE ? OR pv.SKU LIKE ?) ");
        }
        
        if (categoryId != null) {
            sql.append("AND p.CategoryID = ? ");
        }
        
        if (brandId != null) {
            sql.append("AND p.BrandID = ? ");
        }
        
        if (stockStatus != null && !stockStatus.trim().isEmpty()) {
            switch (stockStatus) {
                case "in_stock":
                    sql.append("AND pv.Stock > 10 ");
                    break;
                case "low_stock":
                    sql.append("AND pv.Stock > 0 AND pv.Stock <= 10 ");
                    break;
                case "out_stock":
                    sql.append("AND pv.Stock = 0 AND (SELECT COUNT(*) FROM StockReceipts WHERE VariantID = pv.VariantID) > 0 ");
                    break;
                case "not_imported":
                    sql.append("AND pv.Stock = 0 AND (SELECT COUNT(*) FROM StockReceipts WHERE VariantID = pv.VariantID) = 0 ");
                    break;
            }
        }
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            
            if (keyword != null && !keyword.trim().isEmpty()) {
                String searchPattern = "%" + keyword + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            
            if (categoryId != null) {
                ps.setInt(paramIndex++, categoryId);
            }
            
            if (brandId != null) {
                ps.setInt(paramIndex++, brandId);
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

    /**
     * Lấy thống kê tồn kho cho stat cards
     */
    public Map<String, Integer> getStockStats() {
        Map<String, Integer> stats = new HashMap<>();
        stats.put("totalVariants", 0);
        stats.put("inStockCount", 0);
        stats.put("lowStockCount", 0);
        stats.put("outStockCount", 0);
        
        String sql = "SELECT " +
                     "COUNT(*) AS TotalVariants, " +
                     "SUM(CASE WHEN Stock > 10 THEN 1 ELSE 0 END) AS InStockCount, " +
                     "SUM(CASE WHEN Stock > 0 AND Stock <= 10 THEN 1 ELSE 0 END) AS LowStockCount, " +
                     "SUM(CASE WHEN Stock = 0 THEN 1 ELSE 0 END) AS OutStockCount " +
                     "FROM ProductVariants";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                stats.put("totalVariants", rs.getInt("TotalVariants"));
                stats.put("inStockCount", rs.getInt("InStockCount"));
                stats.put("lowStockCount", rs.getInt("LowStockCount"));
                stats.put("outStockCount", rs.getInt("OutStockCount"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }
}
