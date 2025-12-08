package controller;

import DAO.ProductDAO;
import java.io.IOException;
import java.math.BigDecimal;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import java.util.Map;

@WebServlet(name = "ShopServlet", urlPatterns = {"/shop"})
public class ShopServlet extends HttpServlet {
    
    private ProductDAO productDAO;
    
    @Override
    public void init() throws ServletException {
        productDAO = new ProductDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Get filter parameters
            String search = request.getParameter("search");
            String categoryIdStr = request.getParameter("categoryId");
            String brandIdStr = request.getParameter("brandId");
            String minPriceStr = request.getParameter("minPrice");
            String maxPriceStr = request.getParameter("maxPrice");
            String sortBy = request.getParameter("sortBy");
            String sortOrder = request.getParameter("sortOrder");
            String pageStr = request.getParameter("page");
            
            // Parse category and brand
            Integer categoryId = (categoryIdStr != null && !categoryIdStr.isEmpty()) 
                                ? Integer.parseInt(categoryIdStr) : null;
            Integer brandId = (brandIdStr != null && !brandIdStr.isEmpty()) 
                            ? Integer.parseInt(brandIdStr) : null;
            
            // Parse price range
            BigDecimal minPrice = null;
            BigDecimal maxPrice = null;
            if (minPriceStr != null && !minPriceStr.isEmpty()) {
                try {
                    minPrice = new BigDecimal(minPriceStr);
                } catch (NumberFormatException e) { }
            }
            if (maxPriceStr != null && !maxPriceStr.isEmpty()) {
                try {
                    maxPrice = new BigDecimal(maxPriceStr);
                } catch (NumberFormatException e) { }
            }
            
            // Default values
            if (sortBy == null || sortBy.isEmpty()) sortBy = "date";
            if (sortOrder == null || sortOrder.isEmpty()) sortOrder = "desc";
            
            int page = 1;
            if (pageStr != null && !pageStr.isEmpty()) {
                try {
                    page = Integer.parseInt(pageStr);
                    if (page < 1) page = 1;
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }
            
            int pageSize = 12;
            
            // Get products with price filter
            List<Map<String, Object>> products = productDAO.getProductsWithPriceFilter(
                search, categoryId, brandId, minPrice, maxPrice, true, sortBy, sortOrder, page, pageSize
            );
            
            // Get total count for pagination
            int totalProducts = productDAO.getTotalProductsWithPriceFilter(
                search, categoryId, brandId, minPrice, maxPrice, true
            );
            int totalPages = (int) Math.ceil((double) totalProducts / pageSize);
            
            // Get categories and brands for filters
            List<Map<String, Object>> categories = productDAO.getCategoriesForFilter();
            List<Map<String, Object>> brands = productDAO.getBrandsForFilter();
            
            // Set attributes
            request.setAttribute("products", products);
            request.setAttribute("categories", categories);
            request.setAttribute("brands", brands);
            request.setAttribute("totalProducts", totalProducts);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", page);
            request.setAttribute("pageSize", pageSize);
            
            // Keep filter values
            request.setAttribute("search", search);
            request.setAttribute("categoryId", categoryId);
            request.setAttribute("brandId", brandId);
            request.setAttribute("minPrice", minPriceStr);
            request.setAttribute("maxPrice", maxPriceStr);
            request.setAttribute("sortBy", sortBy);
            request.setAttribute("sortOrder", sortOrder);
            
            // Forward to JSP
            request.getRequestDispatcher("shop.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
