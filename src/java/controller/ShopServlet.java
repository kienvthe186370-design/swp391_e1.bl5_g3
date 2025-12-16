package controller;

import DAO.ProductDAO;
import DAO.CategoryDAO;
import DAO.DiscountCampaignDAO;
import entity.DiscountCampaign;
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
    private DiscountCampaignDAO discountDAO;
    private CategoryDAO categoryDAO;
    @Override
    public void init() throws ServletException {
        productDAO = new ProductDAO();
        discountDAO = new DiscountCampaignDAO();
        categoryDAO = new CategoryDAO();
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
            
            // Parse parameters
            Integer categoryId = (categoryIdStr != null && !categoryIdStr.isEmpty()) 
                                ? Integer.parseInt(categoryIdStr) : null;
            Integer brandId = (brandIdStr != null && !brandIdStr.isEmpty()) 
                            ? Integer.parseInt(brandIdStr) : null;
            BigDecimal minPrice = (minPriceStr != null && !minPriceStr.isEmpty()) 
                                ? new BigDecimal(minPriceStr) : null;
            BigDecimal maxPrice = (maxPriceStr != null && !maxPriceStr.isEmpty()) 
                                ? new BigDecimal(maxPriceStr) : null;
            
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
            
            int pageSize = 12; // 12 products per page
            
            // Get products with price filter
            List<Map<String, Object>> products = productDAO.getProductsWithPriceFilter(
                search, categoryId, brandId, minPrice, maxPrice, true, sortBy, sortOrder, page, pageSize
            );
            
            // Add promotion info to each product
            for (Map<String, Object> product : products) {
                Integer productId = (Integer) product.get("productID");
                Integer catId = (Integer) product.get("categoryID");
                Integer brId = (Integer) product.get("brandID");
                BigDecimal minPriceProduct = (BigDecimal) product.get("minPrice");
                
                if (productId != null && minPriceProduct != null) {
                    DiscountCampaign bestCampaign = discountDAO.getBestCampaignForProduct(
                        productId, catId, brId, minPriceProduct
                    );
                    
                    if (bestCampaign != null) {
                        BigDecimal discountAmount = discountDAO.calculateDiscount(bestCampaign, minPriceProduct);
                        BigDecimal finalPrice = discountDAO.calculateFinalPrice(bestCampaign, minPriceProduct);
                        
                        product.put("hasPromotion", true);
                        product.put("promotionCampaign", bestCampaign);
                        product.put("discountAmount", discountAmount);
                        product.put("finalPrice", finalPrice);
                        
                        // Calculate discount percentage for display
                        if ("percentage".equals(bestCampaign.getDiscountType())) {
                            product.put("discountPercent", bestCampaign.getDiscountValue().intValue());
                        } else {
                            // For fixed discount, calculate percentage
                            BigDecimal percent = discountAmount.multiply(new BigDecimal("100"))
                                                              .divide(minPriceProduct, 0, BigDecimal.ROUND_HALF_UP);
                            product.put("discountPercent", percent.intValue());
                        }
                    } else {
                        product.put("hasPromotion", false);
                    }
                }
            }
            
            // Get total count for pagination
            int totalProducts = productDAO.getTotalProductsWithPriceFilter(search, categoryId, brandId, minPrice, maxPrice, true);
            int totalPages = (int) Math.ceil((double) totalProducts / pageSize);
            
            // Get categories and brands for filters
            List<Map<String, Object>> categoriesForFilter = productDAO.getCategoriesForFilter();
            List<Map<String, Object>> brands = productDAO.getBrandsForFilter();
            
            // Get categories for header menu dropdown (entity objects)
            List<entity.Category> categories = categoryDAO.getAllCategories();
            
            // Set attributes
            request.setAttribute("products", products);
            request.setAttribute("categories", categories);  // For header menu
            request.setAttribute("categoriesForFilter", categoriesForFilter);  // For sidebar filter
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
