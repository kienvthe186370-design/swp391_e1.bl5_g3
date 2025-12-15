package controller.admin;

import DAO.StockDAO;
import DAO.CategoryDAO;
import DAO.BrandDAO;
import entity.Category;
import entity.Brand;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Controller xử lý danh sách tồn kho (F_26)
 * URL: /admin/stock
 */
@WebServlet(name = "AdminStockListController", urlPatterns = {"/admin/stock"})
public class AdminStockListController extends HttpServlet {

    private StockDAO stockDAO;
    private CategoryDAO categoryDAO;
    private BrandDAO brandDAO;
    
    private static final int PAGE_SIZE = 5;

    @Override
    public void init() throws ServletException {
        stockDAO = new StockDAO();
        categoryDAO = new CategoryDAO();
        brandDAO = new BrandDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        // Kiểm tra đăng nhập
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employee") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Lấy parameters filter
        String keyword = request.getParameter("keyword");
        String categoryIdStr = request.getParameter("categoryId");
        String brandIdStr = request.getParameter("brandId");
        String stockStatus = request.getParameter("stockStatus");
        String sortBy = request.getParameter("sortBy");
        String pageStr = request.getParameter("page");

        // Parse categoryId
        Integer categoryId = null;
        if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
            try {
                categoryId = Integer.parseInt(categoryIdStr);
            } catch (NumberFormatException e) {
                // ignore
            }
        }

        // Parse brandId
        Integer brandId = null;
        if (brandIdStr != null && !brandIdStr.trim().isEmpty()) {
            try {
                brandId = Integer.parseInt(brandIdStr);
            } catch (NumberFormatException e) {
                // ignore
            }
        }

        // Parse page
        int currentPage = 1;
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try {
                currentPage = Integer.parseInt(pageStr);
                if (currentPage < 1) currentPage = 1;
            } catch (NumberFormatException e) {
                currentPage = 1;
            }
        }

        // Default sortBy
        if (sortBy == null || sortBy.trim().isEmpty()) {
            sortBy = "id";
        }

        // Lấy danh sách tồn kho
        List<Map<String, Object>> stockList = stockDAO.getStockList(
                keyword, categoryId, brandId, stockStatus, sortBy, currentPage, PAGE_SIZE);

        // Lấy tổng số records để phân trang
        int totalRecords = stockDAO.countStockList(keyword, categoryId, brandId, stockStatus);
        int totalPages = (int) Math.ceil((double) totalRecords / PAGE_SIZE);

        // Lấy thống kê
        Map<String, Integer> stats = stockDAO.getStockStats();

        // Lấy danh sách categories và brands cho filter
        List<Category> categories = categoryDAO.getAllCategories();
        List<Brand> brands = brandDAO.getAllBrands();

        // Set attributes
        request.setAttribute("stockList", stockList);
        request.setAttribute("stats", stats);
        request.setAttribute("categories", categories);
        request.setAttribute("brands", brands);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("pageSize", PAGE_SIZE);  // Thêm pageSize cho phân trang
        request.setAttribute("keyword", keyword);
        request.setAttribute("categoryId", categoryId);
        request.setAttribute("brandId", brandId);
        request.setAttribute("stockStatus", stockStatus);
        request.setAttribute("sortBy", sortBy);

        // Set content page for AdminLTE layout
        request.setAttribute("contentPage", "stock-list");
        request.setAttribute("activePage", "stock");
        request.setAttribute("pageTitle", "Quản lý kho");

        // Forward đến AdminLTE index.jsp
        request.getRequestDispatcher("/AdminLTE-3.2.0/index.jsp").forward(request, response);
    }
}