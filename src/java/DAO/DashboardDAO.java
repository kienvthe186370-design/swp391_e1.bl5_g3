package DAO;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * DAO cho Dashboard thống kê
 */
public class DashboardDAO extends DBContext {

    /**
     * Đếm tổng số khách hàng
     */
    public int getTotalCustomers() {
        String sql = "SELECT COUNT(*) FROM Customers WHERE IsActive = 1";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Đếm khách hàng mới trong khoảng thời gian
     */
    public int getNewCustomers(Date fromDate, Date toDate) {
        String sql = "SELECT COUNT(*) FROM Customers WHERE IsActive = 1 " +
                     "AND CAST(CreatedDate AS DATE) BETWEEN ? AND ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, fromDate);
            ps.setDate(2, toDate);
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
     * Đếm tổng số sản phẩm đang bán
     */
    public int getTotalProducts() {
        String sql = "SELECT COUNT(*) FROM Products WHERE IsActive = 1";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }


    /**
     * Đếm đơn hàng mới (Pending) trong khoảng thời gian
     */
    public int getNewOrders(Date fromDate, Date toDate) {
        String sql = "SELECT COUNT(*) FROM Orders WHERE OrderStatus = 'Pending' " +
                     "AND CAST(OrderDate AS DATE) BETWEEN ? AND ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, fromDate);
            ps.setDate(2, toDate);
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
     * Tổng doanh thu (đơn Delivered) trong khoảng thời gian
     */
    public BigDecimal getRevenue(Date fromDate, Date toDate) {
        String sql = "SELECT ISNULL(SUM(TotalAmount), 0) FROM Orders " +
                     "WHERE OrderStatus = 'Delivered' AND CAST(OrderDate AS DATE) BETWEEN ? AND ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, fromDate);
            ps.setDate(2, toDate);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getBigDecimal(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }

    /**
     * Tổng lợi nhuận trong khoảng thời gian
     * Dùng cột TotalProfit từ bảng Orders
     */
    public BigDecimal getProfit(Date fromDate, Date toDate) {
        String sql = "SELECT ISNULL(SUM(TotalProfit), 0) FROM Orders " +
                     "WHERE OrderStatus = 'Delivered' AND CAST(OrderDate AS DATE) BETWEEN ? AND ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, fromDate);
            ps.setDate(2, toDate);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getBigDecimal(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }

    /**
     * Tổng số đơn hàng trong khoảng thời gian
     */
    public int getTotalOrders(Date fromDate, Date toDate) {
        String sql = "SELECT COUNT(*) FROM Orders WHERE CAST(OrderDate AS DATE) BETWEEN ? AND ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, fromDate);
            ps.setDate(2, toDate);
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
     * Thống kê đơn hàng theo trạng thái trong khoảng thời gian
     */
    public Map<String, Integer> getOrderCountByStatus(Date fromDate, Date toDate) {
        Map<String, Integer> result = new LinkedHashMap<>();
        result.put("Pending", 0);
        result.put("Confirmed", 0);
        result.put("Processing", 0);
        result.put("Shipping", 0);
        result.put("Delivered", 0);
        result.put("Cancelled", 0);

        String sql = "SELECT OrderStatus, COUNT(*) as cnt FROM Orders WHERE CAST(OrderDate AS DATE) BETWEEN ? AND ? GROUP BY OrderStatus";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, fromDate);
            ps.setDate(2, toDate);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                result.put(rs.getString("OrderStatus"), rs.getInt("cnt"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }


    /**
     * Doanh thu theo ngày trong khoảng thời gian
     * Trả về List<Object[]> với [date, revenue, orderCount]
     */
    public List<Object[]> getRevenueByDay(Date fromDate, Date toDate) {
        List<Object[]> result = new ArrayList<>();
        String sql = "SELECT CAST(OrderDate AS DATE) as OrderDay, " +
                     "ISNULL(SUM(CASE WHEN OrderStatus = 'Delivered' THEN TotalAmount ELSE 0 END), 0) as Revenue, " +
                     "COUNT(*) as OrderCount " +
                     "FROM Orders WHERE CAST(OrderDate AS DATE) BETWEEN ? AND ? " +
                     "GROUP BY CAST(OrderDate AS DATE) ORDER BY OrderDay";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, fromDate);
            ps.setDate(2, toDate);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                result.add(new Object[]{
                    rs.getDate("OrderDay"),
                    rs.getBigDecimal("Revenue"),
                    rs.getInt("OrderCount")
                });
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    /**
     * Top sản phẩm bán chạy trong khoảng thời gian
     * Trả về List<Object[]> với [productName, quantitySold, revenue]
     */
    public List<Object[]> getTopSellingProducts(Date fromDate, Date toDate, int limit) {
        List<Object[]> result = new ArrayList<>();
        String sql = "SELECT TOP (?) p.ProductName, SUM(od.Quantity) as QtySold, SUM(od.FinalPrice) as Revenue " +
                     "FROM OrderDetails od " +
                     "JOIN Orders o ON od.OrderID = o.OrderID " +
                     "JOIN ProductVariants pv ON od.VariantID = pv.VariantID " +
                     "JOIN Products p ON pv.ProductID = p.ProductID " +
                     "WHERE o.OrderStatus = 'Delivered' AND CAST(o.OrderDate AS DATE) BETWEEN ? AND ? " +
                     "GROUP BY p.ProductID, p.ProductName " +
                     "ORDER BY QtySold DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setDate(2, fromDate);
            ps.setDate(3, toDate);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                result.add(new Object[]{
                    rs.getString("ProductName"),
                    rs.getInt("QtySold"),
                    rs.getBigDecimal("Revenue")
                });
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    /**
     * Đơn hàng gần đây
     */
    public List<Map<String, Object>> getRecentOrders(int limit) {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT TOP (?) o.OrderID, o.OrderCode, o.TotalAmount, o.OrderStatus, o.OrderDate, " +
                     "c.FullName as CustomerName " +
                     "FROM Orders o " +
                     "LEFT JOIN Customers c ON o.CustomerID = c.CustomerID " +
                     "ORDER BY o.OrderDate DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> order = new HashMap<>();
                order.put("orderID", rs.getInt("OrderID"));
                order.put("orderCode", rs.getString("OrderCode"));
                order.put("totalAmount", rs.getBigDecimal("TotalAmount"));
                order.put("orderStatus", rs.getString("OrderStatus"));
                order.put("orderDate", rs.getTimestamp("OrderDate"));
                order.put("customerName", rs.getString("CustomerName"));
                result.add(order);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }


    /**
     * Sản phẩm sắp hết hàng (stock < threshold)
     */
    public List<Map<String, Object>> getLowStockProducts(int threshold, int limit) {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT TOP (?) p.ProductID, p.ProductName, " +
                     "(SELECT ISNULL(SUM(Stock), 0) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) as TotalStock " +
                     "FROM Products p WHERE p.IsActive = 1 " +
                     "AND (SELECT ISNULL(SUM(Stock), 0) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) > 0 " +
                     "AND (SELECT ISNULL(SUM(Stock), 0) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) < ? " +
                     "ORDER BY TotalStock ASC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setInt(2, threshold);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> product = new HashMap<>();
                product.put("productID", rs.getInt("ProductID"));
                product.put("productName", rs.getString("ProductName"));
                product.put("totalStock", rs.getInt("TotalStock"));
                result.add(product);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    /**
     * Thống kê tổng hợp cho dashboard
     */
    public Map<String, Object> getDashboardStats(Date fromDate, Date toDate) {
        Map<String, Object> stats = new HashMap<>();
        
        stats.put("totalCustomers", getTotalCustomers());
        stats.put("newCustomers", getNewCustomers(fromDate, toDate));
        stats.put("totalProducts", getTotalProducts());
        stats.put("newOrders", getNewOrders(fromDate, toDate));
        stats.put("totalOrders", getTotalOrders(fromDate, toDate));
        stats.put("revenue", getRevenue(fromDate, toDate));
        stats.put("profit", getProfit(fromDate, toDate));
        stats.put("ordersByStatus", getOrderCountByStatus(fromDate, toDate));
        
        return stats;
    }
}
