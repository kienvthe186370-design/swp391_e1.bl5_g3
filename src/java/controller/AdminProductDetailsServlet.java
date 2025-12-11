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
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employee") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String productIdStr = request.getParameter("id");
        if (productIdStr == null || productIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=" + 
                                encodeURL("ID sản phẩm không hợp lệ"));
            return;
        }
        
        try {
            int productId = Integer.parseInt(productIdStr);
            
            Map<String, Object> product = productDAO.getProductById(productId);
            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/admin/products?error=" + 
                                    encodeURL("Không tìm thấy sản phẩm"));
                return;
            }
            
            List<Map<String, Object>> images = productDAO.getProductImages(productId);
            List<Map<String, Object>> variants = productDAO.getProductVariants(productId);
            
            request.setAttribute("product", product);
            request.setAttribute("images", images);
            request.setAttribute("variants", variants);
            
            request.setAttribute("contentPage", "product-details");
            request.setAttribute("activePage", "products");
            request.setAttribute("pageTitle", "Chi tiết sản phẩm");
            
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
    
    private String encodeURL(String str) {
        try {
            return java.net.URLEncoder.encode(str, "UTF-8");
        } catch (Exception e) {
            return str;
        }
    }
}
