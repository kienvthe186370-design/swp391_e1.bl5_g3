package controller;

import DAO.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * API endpoint to get product variants
 */
@WebServlet(name = "ProductVariantAPI", urlPatterns = {"/api/product-variants"})
public class ProductVariantAPI extends HttpServlet {

    private ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        
        try {
            String productIdStr = request.getParameter("productId");
            if (productIdStr == null || productIdStr.isEmpty()) {
                out.print("{\"error\": \"productId is required\"}");
                return;
            }
            
            int productId = Integer.parseInt(productIdStr);
            List<Map<String, Object>> variants = productDAO.getProductVariants(productId);
            
            JSONArray jsonArray = new JSONArray();
            for (Map<String, Object> variant : variants) {
                JSONObject obj = new JSONObject();
                obj.put("variantId", variant.get("variantID"));
                obj.put("sku", variant.get("sku") != null ? variant.get("sku") : "");
                obj.put("sellingPrice", variant.get("sellingPrice"));
                obj.put("stock", variant.get("availableStock"));
                obj.put("isActive", variant.get("isActive") != null ? variant.get("isActive") : false);
                jsonArray.put(obj);
            }
            
            out.print(jsonArray.toString());
            
        } catch (NumberFormatException e) {
            out.print("{\"error\": \"Invalid productId\"}");
        } catch (Exception e) {
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }
}
