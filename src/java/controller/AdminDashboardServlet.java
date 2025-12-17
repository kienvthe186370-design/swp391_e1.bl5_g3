package controller;

import DAO.DashboardDAO;
import DAO.ProductDAO;
import entity.Employee;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {
    
    private ProductDAO productDAO;
    private DashboardDAO dashboardDAO;
    
    @Override
    public void init() throws ServletException {
        productDAO = new ProductDAO();
        dashboardDAO = new DashboardDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        
        if (employee == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String role = employee.getRole();
        
        // Chỉ Admin mới xem được dashboard thống kê tổng quan
        // Các role khác redirect đến trang chức năng của họ
        if (!"Admin".equalsIgnoreCase(role)) {
            // Redirect theo role
            if ("Shipper".equalsIgnoreCase(role)) {
                response.sendRedirect(request.getContextPath() + "/admin/orders?action=shipperOrders");
            } else if ("SellerManager".equalsIgnoreCase(role) || "Seller".equalsIgnoreCase(role)) {
                response.sendRedirect(request.getContextPath() + "/admin/orders");
            } else if ("Marketer".equalsIgnoreCase(role)) {
                response.sendRedirect(request.getContextPath() + "/admin/products");
            } else {
                response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
            }
            return;
        }
        
        // ===== ADMIN DASHBOARD =====
        // Get product status counts for dashboard widgets
        Map<String, Integer> statusCounts = productDAO.getProductStatusCounts();
        request.setAttribute("statusCounts", statusCounts);
            
            // ===== DASHBOARD STATISTICS =====
            // Revenue
            BigDecimal monthlyRevenue = dashboardDAO.getMonthlyRevenue();
            BigDecimal totalRevenue = dashboardDAO.getTotalRevenue();
            request.setAttribute("monthlyRevenue", monthlyRevenue);
            request.setAttribute("totalRevenue", totalRevenue);
            
            // Orders
            int totalOrders = dashboardDAO.getTotalOrders();
            int todayOrders = dashboardDAO.getTodayOrders();
            int pendingOrders = dashboardDAO.getPendingOrders();
            request.setAttribute("totalOrders", totalOrders);
            request.setAttribute("todayOrders", todayOrders);
            request.setAttribute("pendingOrders", pendingOrders);
            
            // Customers
            int totalCustomers = dashboardDAO.getTotalCustomers();
            int newCustomers = dashboardDAO.getNewCustomersThisMonth();
            request.setAttribute("totalCustomers", totalCustomers);
            request.setAttribute("newCustomers", newCustomers);
            
            // Products
            int totalProducts = dashboardDAO.getTotalProducts();
            int outOfStock = dashboardDAO.getOutOfStockProducts();
            request.setAttribute("totalProducts", totalProducts);
            request.setAttribute("outOfStock", outOfStock);
            
            // Charts data
            Map<String, BigDecimal> revenueChart = dashboardDAO.getDailyRevenueChart();
            Map<String, Integer> ordersByStatus = dashboardDAO.getOrdersByStatus();
            List<Map<String, Object>> topProducts = dashboardDAO.getTopSellingProducts(5);
            request.setAttribute("revenueChart", revenueChart);
            request.setAttribute("ordersByStatus", ordersByStatus);
            request.setAttribute("topProducts", topProducts);
            
            // Tables data
            List<Map<String, Object>> recentOrders = dashboardDAO.getRecentOrders(5);
            List<Map<String, Object>> lowStockProducts = dashboardDAO.getLowStockProducts(5);
            request.setAttribute("recentOrders", recentOrders);
            request.setAttribute("lowStockProducts", lowStockProducts);
            
            // Set attributes for unified layout
            request.setAttribute("contentPage", "dashboard");
            request.setAttribute("activePage", "dashboard");
            request.setAttribute("pageTitle", "Dashboard");
            
        // Forward to unified AdminLTE layout
        request.getRequestDispatcher("/AdminLTE-3.2.0/index.jsp").forward(request, response);
    }
}
