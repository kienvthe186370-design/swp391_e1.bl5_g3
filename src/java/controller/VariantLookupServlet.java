package controller;

import DAO.ProductDAO;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;

/**
 * API để tìm variant theo tổ hợp thuộc tính đã chọn
 */
@WebServlet(name = "VariantLookupServlet", urlPatterns = {"/api/variant-lookup"})
public class VariantLookupServlet extends HttpServlet {
    
    private ProductDAO productDAO;
    
    @Override
    public void init() throws ServletException {
        productDAO = new ProductDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        JSONObject result = new JSONObject();
        
        try {
            String productIdStr = request.getParameter("productId");
            String valueIdsStr = request.getParameter("valueIds");
            
            if (productIdStr == null || productIdStr.isEmpty()) {
                result.put("success", false);
                result.put("message", "Thiếu productId");
                out.print(result.toString());
                return;
            }
            
            int productId = Integer.parseInt(productIdStr);
            
            // Parse valueIds (comma-separated)
            List<Integer> valueIds = new ArrayList<>();
            if (valueIdsStr != null && !valueIdsStr.isEmpty()) {
                String[] ids = valueIdsStr.split(",");
                for (String id : ids) {
                    try {
                        valueIds.add(Integer.parseInt(id.trim()));
                    } catch (NumberFormatException e) {
                        // Skip invalid ids
                    }
                }
            }
            
            if (valueIds.isEmpty()) {
                result.put("success", false);
                result.put("message", "Vui lòng chọn đầy đủ thuộc tính");
                out.print(result.toString());
                return;
            }
            
            // Find variant by attributes
            Map<String, Object> variant = productDAO.findVariantByAttributes(productId, valueIds);
            
            if (variant != null) {
                result.put("success", true);
                
                JSONObject variantJson = new JSONObject();
                variantJson.put("variantId", variant.get("variantId"));
                variantJson.put("sku", variant.get("sku"));
                
                BigDecimal sellingPrice = (BigDecimal) variant.get("sellingPrice");
                variantJson.put("sellingPrice", sellingPrice != null ? sellingPrice.doubleValue() : 0);
                
                BigDecimal compareAtPrice = (BigDecimal) variant.get("compareAtPrice");
                variantJson.put("compareAtPrice", compareAtPrice != null ? compareAtPrice.doubleValue() : 0);
                
                variantJson.put("stock", variant.get("stock"));
                variantJson.put("availableStock", variant.get("availableStock"));
                
                result.put("variant", variantJson);
            } else {
                result.put("success", false);
                result.put("message", "Không tìm thấy phiên bản với tổ hợp này");
            }
            
        } catch (NumberFormatException e) {
            result.put("success", false);
            result.put("message", "Tham số không hợp lệ");
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "Có lỗi xảy ra");
        }
        
        out.print(result.toString());
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
