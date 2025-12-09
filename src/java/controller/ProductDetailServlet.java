package controller;

import DAO.ProductDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import java.util.Map;

@WebServlet(name = "ProductDetailServlet", urlPatterns = {"/product-detail"})
public class ProductDetailServlet extends HttpServlet {
    
    private ProductDAO productDAO;
    
    @Override
    public void init() throws ServletException {
        productDAO = new ProductDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Get product ID
            String productIdStr = request.getParameter("id");
            
            if (productIdStr == null || productIdStr.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/shop");
                return;
            }
            
            int productId = Integer.parseInt(productIdStr);
            
            // Get product details
            Map<String, Object> product = productDAO.getProductById(productId);
            
            // Check if product exists and is active
            if (product == null || !((Boolean) product.get("isActive"))) {
                response.sendRedirect(request.getContextPath() + "/shop");
                return;
            }
            
            // Get product images
            List<Map<String, Object>> images = productDAO.getProductImages(productId);
            
            // Get product variants
            List<Map<String, Object>> variants = productDAO.getProductVariants(productId);
            
            // Get related products (same category, limit 8)
            Integer categoryId = (Integer) product.get("categoryID");
            List<Map<String, Object>> relatedProducts = productDAO.getProducts(
                null, categoryId, null, true, "date", "desc", 1, 8
            );
            
            // Remove current product from related products
            relatedProducts.removeIf(p -> ((Integer) p.get("productID")) == productId);
            
            // Get same category products (limit to 4)
            if (relatedProducts.size() > 4) {
                relatedProducts = relatedProducts.subList(0, 4);
            }
            
            // Set attributes
            request.setAttribute("product", product);
            request.setAttribute("images", images);
            request.setAttribute("variants", variants);
            request.setAttribute("relatedProducts", relatedProducts);
            
            // Forward to JSP
            request.getRequestDispatcher("product-detail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/shop");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/shop");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
