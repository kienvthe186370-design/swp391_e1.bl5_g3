package controller;

import DAO.ProductDAO;
import entity.Employee;
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
 * Servlet xử lý xem chi tiết sản phẩm cho Admin/Marketer
 * Read-only view with navigation to edit page
 */
@WebServlet(name = "AdminProductDetailsServlet", urlPatterns = {"/admin/product-details"})
public class AdminProductDetailsServlet extends HttpServlet {
    
    private ProductDAO productDAO;
    
    @Override
    public void init() throws ServletException {
        productDAO = new ProductDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization (Admin hoặc Marketer)
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employee") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Get and validate product ID
        String productIdStr = request.getParameter("id");
        
        if (productIdStr == null || productIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=" + 
                                encodeURL("ID sản phẩm không hợp lệ"));
            return;
        }
        
        try {
            int productId = Integer.parseInt(productIdStr);
            
            // Load product details
            Map<String, Object> product = productDAO.getProductById(productId);
            
            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/admin/products?error=" + 
                                    encodeURL("Không tìm thấy sản phẩm"));
                return;
            }
            
            // Load product images
            List<Map<String, Object>> images = productDAO.getProductImages(productId);
            
            // Load product variants
            List<Map<String, Object>> variants = productDAO.getProductVariants(productId);
            
            // Set attributes for JSP
            request.setAttribute("product", product);
            request.setAttribute("images", images);
            request.setAttribute("variants", variants);
            
            // Set unified layout attributes
            request.setAttribute("contentPage", "product-details");
            request.setAttribute("activePage", "products");
            request.setAttribute("pageTitle", "Chi tiết sản phẩm");
            
            // Forward to unified layout
            request.getRequestDispatcher("/AdminLTE-3.2.0/index.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=" + 
                                encodeURL("ID sản phẩm không hợp lệ"));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/products?error=" + 
                                encodeURL("Lỗi hệ thống: " + e.getMessage()));
        }
    }
    
    /**
     * Encode URL để tránh lỗi với ký tự đặc biệt
     */
    private String encodeURL(String str) {
        try {
            return java.net.URLEncoder.encode(str, "UTF-8");
        } catch (Exception e) {
            return str;
        }
    }
}
