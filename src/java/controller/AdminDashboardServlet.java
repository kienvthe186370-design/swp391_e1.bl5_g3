package controller;

import DAO.DashboardDAO;
import entity.Employee;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.text.SimpleDateFormat;
import java.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {
    
    private DashboardDAO dashboardDAO;
    
    @Override
    public void init() throws ServletException {
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
        request.setAttribute("userRole", role);
        request.setAttribute("employeeName", employee.getFullName());
        
        // Nếu không phải Admin, chỉ hiển thị welcome message
        if (!"Admin".equals(role)) {
            request.getRequestDispatcher("/AdminLTE-3.2.0/dashboard.jsp").forward(request, response);
            return;
        }
        
        // Xử lý filter ngày (chỉ cho Admin)
        String filterType = request.getParameter("filter");
        String fromDateStr = request.getParameter("fromDate");
        String toDateStr = request.getParameter("toDate");
        
        Date fromDate, toDate;
        Calendar cal = Calendar.getInstance();
        
        if (filterType == null) filterType = "today";
        
        switch (filterType) {
            case "yesterday":
                cal.add(Calendar.DAY_OF_MONTH, -1);
                fromDate = new Date(cal.getTimeInMillis());
                toDate = new Date(cal.getTimeInMillis());
                break;
            case "week":
                cal.set(Calendar.DAY_OF_WEEK, cal.getFirstDayOfWeek());
                fromDate = new Date(cal.getTimeInMillis());
                toDate = new Date(System.currentTimeMillis());
                break;
            case "month":
                cal.set(Calendar.DAY_OF_MONTH, 1);
                fromDate = new Date(cal.getTimeInMillis());
                toDate = new Date(System.currentTimeMillis());
                break;
            case "custom":
                try {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                    if (fromDateStr != null && toDateStr != null) {
                        fromDate = new Date(sdf.parse(fromDateStr).getTime());
                        toDate = new Date(sdf.parse(toDateStr).getTime());
                    } else {
                        fromDate = new Date(System.currentTimeMillis());
                        toDate = new Date(System.currentTimeMillis());
                    }
                } catch (Exception e) {
                    fromDate = new Date(System.currentTimeMillis());
                    toDate = new Date(System.currentTimeMillis());
                }
                break;
            case "today":
            default:
                fromDate = new Date(System.currentTimeMillis());
                toDate = new Date(System.currentTimeMillis());
                break;
        }
        
        // Lấy dữ liệu thống kê
        Map<String, Object> stats = dashboardDAO.getDashboardStats(fromDate, toDate);
        List<Object[]> revenueByDay = dashboardDAO.getRevenueByDay(fromDate, toDate);
        List<Object[]> topProducts = dashboardDAO.getTopSellingProducts(fromDate, toDate, 10);
        List<Map<String, Object>> recentOrders = dashboardDAO.getRecentOrders(10);
        List<Map<String, Object>> lowStockProducts = dashboardDAO.getLowStockProducts(10, 10);
        
        // Chuẩn bị dữ liệu cho biểu đồ
        StringBuilder chartLabels = new StringBuilder("[");
        StringBuilder chartRevenue = new StringBuilder("[");
        StringBuilder chartOrders = new StringBuilder("[");
        SimpleDateFormat chartDateFormat = new SimpleDateFormat("dd/MM");
        
        if (revenueByDay.isEmpty()) {
            // Nếu không có dữ liệu, hiển thị ngày hiện tại với giá trị 0
            chartLabels.append("\"").append(chartDateFormat.format(fromDate)).append("\"");
            chartRevenue.append("0");
            chartOrders.append("0");
        } else {
            for (int i = 0; i < revenueByDay.size(); i++) {
                Object[] row = revenueByDay.get(i);
                if (i > 0) {
                    chartLabels.append(",");
                    chartRevenue.append(",");
                    chartOrders.append(",");
                }
                chartLabels.append("\"").append(chartDateFormat.format((Date) row[0])).append("\"");
                chartRevenue.append(((BigDecimal) row[1]).longValue());
                chartOrders.append(row[2]);
            }
        }
        chartLabels.append("]");
        chartRevenue.append("]");
        chartOrders.append("]");
        
        // Set attributes
        request.setAttribute("stats", stats);
        request.setAttribute("revenueByDay", revenueByDay);
        request.setAttribute("topProducts", topProducts);
        request.setAttribute("recentOrders", recentOrders);
        request.setAttribute("lowStockProducts", lowStockProducts);
        request.setAttribute("chartLabels", chartLabels.toString());
        request.setAttribute("chartRevenue", chartRevenue.toString());
        request.setAttribute("chartOrders", chartOrders.toString());
        request.setAttribute("filterType", filterType);
        request.setAttribute("fromDate", fromDate);
        request.setAttribute("toDate", toDate);
        
        request.getRequestDispatcher("/AdminLTE-3.2.0/dashboard.jsp").forward(request, response);
    }
}
