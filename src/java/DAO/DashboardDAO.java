package DAO;

import java.sql.*;
import java.math.BigDecimal;
import java.util.*;

/**
 * DashboardDAO - Lấy dữ liệu thống kê cho Admin Dashboard
 */
public class DashboardDAO extends DBContext {

    /**
     * Lấy tổng doanh thu tháng hiện tại
     */
    public BigDecimal getMonthlyRevenue() {
        String sql = "SELECT ISNULL(SUM(TotalAmount), 0) FROM Orders " +
                     "WHERE OrderStatus = 'Delivered' " +
                     "AND MONTH(OrderDate) = MONTH(GETDATE()) AND YEAR(OrderDate) = YEAR(GETDATE())";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getBigDecimal(1);
            }
        } catch (SQLException e) {
            System.err.println("DashboardDAO.getMonthlyRevenue error: " + e.getMessage());
        }
        return BigDecimal.ZERO;
    }

    /**
     * Lấy tổng doanh thu tất cả thời gian
     */
    public BigDecimal getTotalRevenue() {
        String sql = "SELECT ISNULL(SUM(TotalAmount), 0) FROM Orders WHERE OrderStatus = 'Delivered'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getBigDecimal(1);
            }
        } catch (SQLException e) {
            System.err.println("DashboardDAO.getTotalRevenue error: " + e.getMessage());
        }
        return BigDecimal.ZERO;
    }

    /**
     * Đếm tổng đơn hàng
     */
    public int getTotalOrders() {
        String sql = "SELECT COUNT(*) FROM Orders";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("DashboardDAO.getTotalOrders error: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Đếm đơn hàng mới hôm nay
     */
    public int getTodayOrders() {
        String sql = "SELECT COUNT(*) FROM Orders WHERE CAST(OrderDate AS DATE) = CAST(GETDATE() AS DATE)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("DashboardDAO.getTodayOrders error: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Đếm đơn hàng đang chờ xử lý
     */
    public int getPendingOrders() {
        String sql = "SELECT COUNT(*) FROM Orders WHERE OrderStatus IN ('Pending', 'Confirmed')";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("DashboardDAO.getPendingOrders error: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Đếm tổng khách hàng
     */
    public int getTotalCustomers() {
        String sql = "SELECT COUNT(*) FROM Customers WHERE IsActive = 1";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("DashboardDAO.getTotalCustomers error: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Đếm khách hàng mới tháng này
     */
    public int getNewCustomersThisMonth() {
        String sql = "SELECT COUNT(*) FROM Customers " +
                     "WHERE MONTH(CreatedDate) = MONTH(GETDATE()) AND YEAR(CreatedDate) = YEAR(GETDATE())";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("DashboardDAO.getNewCustomersThisMonth error: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Đếm tổng sản phẩm
     */
    public int getTotalProducts() {
        String sql = "SELECT COUNT(*) FROM Products WHERE IsActive = 1";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("DashboardDAO.getTotalProducts error: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Đếm sản phẩm hết hàng
     */
    public int getOutOfStockProducts() {
        String sql = "SELECT COUNT(DISTINCT p.ProductID) FROM Products p " +
                     "LEFT JOIN ProductVariants pv ON p.ProductID = pv.ProductID AND pv.IsActive = 1 " +
                     "WHERE p.IsActive = 1 " +
                     "GROUP BY p.ProductID " +
                     "HAVING ISNULL(SUM(pv.StockQuantity), 0) = 0";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            int count = 0;
            while (rs.next()) count++;
            return count;
        } catch (SQLException e) {
            System.err.println("DashboardDAO.getOutOfStockProducts error: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Lấy doanh thu 7 ngày gần nhất
     */
    public Map<String, BigDecimal> getDailyRevenueChart() {
        Map<String, BigDecimal> data = new LinkedHashMap<>();
        String sql = "SELECT FORMAT(OrderDate, 'dd/MM') as Day, ISNULL(SUM(TotalAmount), 0) as Revenue " +
                     "FROM Orders WHERE OrderStatus = 'Delivered' " +
                     "AND OrderDate >= DATEADD(DAY, -6, CAST(GETDATE() AS DATE)) " +
                     "GROUP BY FORMAT(OrderDate, 'dd/MM'), CAST(OrderDate AS DATE) " +
                     "ORDER BY CAST(OrderDate AS DATE)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                data.put(rs.getString("Day"), rs.getBigDecimal("Revenue"));
            }
        } catch (SQLException e) {
            System.err.println("DashboardDAO.getDailyRevenueChart error: " + e.getMessage());
        }
        return data;
    }

    /**
     * Lấy số đơn hàng theo trạng thái
     */
    public Map<String, Integer> getOrdersByStatus() {
        Map<String, Integer> data = new LinkedHashMap<>();
        String sql = "SELECT OrderStatus, COUNT(*) as Count FROM Orders GROUP BY OrderStatus";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                data.put(rs.getString("OrderStatus"), rs.getInt("Count"));
            }
        } catch (SQLException e) {
            System.err.println("DashboardDAO.getOrdersByStatus error: " + e.getMessage());
        }
        return data;
    }

    /**
     * Lấy top 5 sản phẩm bán chạy
     */
    public List<Map<String, Object>> getTopSellingProducts(int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT TOP " + limit + " p.ProductName, SUM(od.Quantity) as TotalSold " +
                     "FROM OrderDetails od " +
                     "JOIN ProductVariants pv ON od.VariantID = pv.VariantID " +
                     "JOIN Products p ON pv.ProductID = p.ProductID " +
                     "JOIN Orders o ON od.OrderID = o.OrderID " +
                     "WHERE o.OrderStatus = 'Delivered' " +
                     "GROUP BY p.ProductID, p.ProductName " +
                     "ORDER BY TotalSold DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("name", rs.getString("ProductName"));
                item.put("sold", rs.getInt("TotalSold"));
                list.add(item);
            }
        } catch (SQLException e) {
            System.err.println("DashboardDAO.getTopSellingProducts error: " + e.getMessage());
        }
        return list;
    }

    /**
     * Lấy đơn hàng mới nhất
     */
    public List<Map<String, Object>> getRecentOrders(int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT TOP " + limit + " o.OrderID, o.OrderCode, o.TotalAmount, o.OrderStatus, o.OrderDate, " +
                     "c.FullName as CustomerName " +
                     "FROM Orders o " +
                     "JOIN Customers c ON o.CustomerID = c.CustomerID " +
                     "ORDER BY o.OrderDate DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("orderId", rs.getInt("OrderID"));
                item.put("orderCode", rs.getString("OrderCode"));
                item.put("totalAmount", rs.getBigDecimal("TotalAmount"));
                item.put("status", rs.getString("OrderStatus"));
                item.put("orderDate", rs.getTimestamp("OrderDate"));
                item.put("customerName", rs.getString("CustomerName"));
                list.add(item);
            }
        } catch (SQLException e) {
            System.err.println("DashboardDAO.getRecentOrders error: " + e.getMessage());
        }
        return list;
    }

    /**
     * Lấy sản phẩm sắp hết hàng (stock < 10)
     */
    public List<Map<String, Object>> getLowStockProducts(int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT TOP " + limit + " p.ProductID, p.ProductName, SUM(pv.StockQuantity) as TotalStock " +
                     "FROM Products p " +
                     "JOIN ProductVariants pv ON p.ProductID = pv.ProductID AND pv.IsActive = 1 " +
                     "WHERE p.IsActive = 1 " +
                     "GROUP BY p.ProductID, p.ProductName " +
                     "HAVING SUM(pv.StockQuantity) > 0 AND SUM(pv.StockQuantity) < 10 " +
                     "ORDER BY TotalStock ASC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("productId", rs.getInt("ProductID"));
                item.put("name", rs.getString("ProductName"));
                item.put("stock", rs.getInt("TotalStock"));
                list.add(item);
            }
        } catch (SQLException e) {
            System.err.println("DashboardDAO.getLowStockProducts error: " + e.getMessage());
        }
        return list;
    }
}
