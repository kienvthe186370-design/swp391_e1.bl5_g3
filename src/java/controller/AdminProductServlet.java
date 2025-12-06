package controller;


import DAO.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * Servlet x? lý qu?n lý s?n ph?m cho Admin/Marketer
 * F_12: View Product List (Admin Dashboard - Table layout)
 */
@WebServlet(name = "AdminProductServlet", urlPatterns = {"/admin/products"})
public class AdminProductServlet extends HttpServlet {
    
    private ProductDAO productDAO;
    
    @Override
    public void init() throws ServletException {
        productDAO = new ProductDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization (Admin ho?c Marketer)
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employee") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("delete".equals(action)) {
            handleDelete(request, response);
        } else {
            showProductList(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
    
    /**
     * Hi?n th? danh sách s?n ph?m v?i filter, sort, pagination
     */
    private void showProductList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // L?y parameters t? request
        String search = request.getParameter("search");
        String categoryIdStr = request.getParameter("categoryId");
        String brandIdStr = request.getParameter("brandId");
        String statusStr = request.getParameter("status");
        String sortBy = request.getParameter("sortBy");
        String sortOrder = request.getParameter("sortOrder");
        String pageStr = request.getParameter("page");
        
        // Parse parameters
        Integer categoryId = parseInteger(categoryIdStr);
        Integer brandId = parseInteger(brandIdStr);
        Boolean isActive = parseStatus(statusStr);
        
        // Default sorting
        if (sortBy == null || sortBy.isEmpty()) {
            sortBy = "date";
        }
        if (sortOrder == null || sortOrder.isEmpty()) {
            sortOrder = "desc";
        }
        
        // Pagination
        int page = 1;
        int pageSize = 12; // Hi?n th? 12 s?n ph?m m?i trang
        try {
            if (pageStr != null && !pageStr.isEmpty()) {
                page = Integer.parseInt(pageStr);
                if (page < 1) page = 1;
            }
        } catch (NumberFormatException e) {
            page = 1;
        }
        
        // L?y danh sách s?n ph?m
        List<Map<String, Object>> products = productDAO.getProducts(
            search, categoryId, brandId, isActive, sortBy, sortOrder, page, pageSize
        );
        
        // L?y t?ng s? s?n ph?m ?? tính pagination
        int totalProducts = productDAO.getTotalProducts(search, categoryId, brandId, isActive);
        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);
        
        // L?y categories và brands cho filter dropdown
        List<Map<String, Object>> categories = productDAO.getCategoriesForFilter();
        List<Map<String, Object>> brands = productDAO.getBrandsForFilter();
        
        // Set attributes ?? JSP s? d?ng
        request.setAttribute("products", products);
        request.setAttribute("categories", categories);
        request.setAttribute("brands", brands);
        
        // Pagination info
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("pageSize", pageSize);
        
        // Filter values (?? gi? l?i giá tr? khi filter)
        request.setAttribute("search", search);
        request.setAttribute("categoryId", categoryId);
        request.setAttribute("brandId", brandId);
        request.setAttribute("status", statusStr);
        request.setAttribute("sortBy", sortBy);
        request.setAttribute("sortOrder", sortOrder);
        
        // Success/Error messages
        String message = request.getParameter("message");
        String error = request.getParameter("error");
        if (message != null) {
            request.setAttribute("successMessage", message);
        }
        if (error != null) {
            request.setAttribute("errorMessage", error);
        }
        
        // Set unified layout attributes
        request.setAttribute("contentPage", "products");
        request.setAttribute("activePage", "products");
        request.setAttribute("pageTitle", "Qu?n lý s?n ph?m");
        
        // Forward to unified layout
        request.getRequestDispatcher("/AdminLTE-3.2.0/index.jsp").forward(request, response);
    }
    
    /**
     * X? lý xóa s?n ph?m (soft delete)
     */
    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String productIdStr = request.getParameter("id");
        
        if (productIdStr == null || productIdStr.isEmpty()) {
            response.sendRedirect("products?error=" + encodeURL("ID s?n ph?m không h?p l?"));
            return;
        }
        
        try {
            int productId = Integer.parseInt(productIdStr);
            
            // Th?c hi?n soft delete
            boolean success = productDAO.softDeleteProduct(productId);
            
            if (success) {
                response.sendRedirect("products?message=" + encodeURL("Xóa s?n ph?m thành công"));
            } else {
                response.sendRedirect("products?error=" + encodeURL("Không th? xóa s?n ph?m"));
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect("products?error=" + encodeURL("ID s?n ph?m không h?p l?"));
        }
    }
    
    /**
     * Parse Integer t? String (nullable)
     */
    private Integer parseInteger(String str) {
        if (str == null || str.isEmpty() || "all".equalsIgnoreCase(str)) {
            return null;
        }
        try {
            return Integer.parseInt(str);
        } catch (NumberFormatException e) {
            return null;
        }
    }
    
    /**
     * Parse status t? String (nullable)
     * "active" -> true, "inactive" -> false, "all" -> null
     */
    private Boolean parseStatus(String status) {
        if (status == null || status.isEmpty() || "all".equalsIgnoreCase(status)) {
            return null;
        }
        if ("active".equalsIgnoreCase(status)) {
            return true;
        }
        if ("inactive".equalsIgnoreCase(status)) {
            return false;
        }
        return null;
    }
    
    /**
     * Encode URL ?? tránh l?i v?i ký t? ??c bi?t
     */
    private String encodeURL(String str) {
        try {
            return java.net.URLEncoder.encode(str, "UTF-8");
        } catch (Exception e) {
            return str;
        }
    }
}