package controller;

import DAO.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * API Servlet để kiểm tra trùng lặp sản phẩm/biến thể realtime
 */
@WebServlet(name = "ProductDuplicateCheckServlet", urlPatterns = {"/admin/api/check-duplicate"})
public class ProductDuplicateCheckServlet extends HttpServlet {
    
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
        
        String type = request.getParameter("type");
        PrintWriter out = response.getWriter();
        
        try {
            if ("product-name".equals(type)) {
                checkProductName(request, out);
            } else if ("sku".equals(type)) {
                checkSku(request, out);
            } else if ("variant".equals(type)) {
                checkVariant(request, out);
            } else {
                out.print("{\"error\": \"Invalid type parameter\"}");
            }
        } catch (Exception e) {
            out.print("{\"error\": \"" + escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    private void checkProductName(HttpServletRequest request, PrintWriter out) {
        String productName = request.getParameter("name");
        String excludeIdStr = request.getParameter("excludeId");
        Integer excludeId = null;
        
        if (excludeIdStr != null && !excludeIdStr.isEmpty()) {
            try {
                excludeId = Integer.parseInt(excludeIdStr);
            } catch (NumberFormatException e) {
                // ignore
            }
        }
        
        if (productName == null || productName.trim().isEmpty()) {
            out.print("{\"duplicate\": false}");
            return;
        }
        
        Map<String, Object> duplicate = productDAO.findDuplicateProductByName(productName.trim(), excludeId);
        
        if (duplicate != null) {
            out.print("{\"duplicate\": true, " +
                     "\"productId\": " + duplicate.get("productId") + ", " +
                     "\"productName\": \"" + escapeJson((String) duplicate.get("productName")) + "\", " +
                     "\"isActive\": " + duplicate.get("isActive") + "}");
        } else {
            out.print("{\"duplicate\": false}");
        }
    }
    
    private void checkSku(HttpServletRequest request, PrintWriter out) {
        String sku = request.getParameter("sku");
        String excludeIdStr = request.getParameter("excludeVariantId");
        Integer excludeId = null;
        
        if (excludeIdStr != null && !excludeIdStr.isEmpty()) {
            try {
                excludeId = Integer.parseInt(excludeIdStr);
            } catch (NumberFormatException e) {
                // ignore
            }
        }
        
        if (sku == null || sku.trim().isEmpty()) {
            out.print("{\"duplicate\": false}");
            return;
        }
        
        Map<String, Object> duplicate = productDAO.findVariantBySku(sku.trim(), excludeId);
        
        if (duplicate != null) {
            out.print("{\"duplicate\": true, " +
                     "\"variantId\": " + duplicate.get("variantId") + ", " +
                     "\"productId\": " + duplicate.get("productId") + ", " +
                     "\"sku\": \"" + escapeJson((String) duplicate.get("sku")) + "\", " +
                     "\"productName\": \"" + escapeJson((String) duplicate.get("productName")) + "\"}");
        } else {
            out.print("{\"duplicate\": false}");
        }
    }
    
    private void checkVariant(HttpServletRequest request, PrintWriter out) {
        String productIdStr = request.getParameter("productId");
        String valueIdsStr = request.getParameter("valueIds");
        String excludeIdStr = request.getParameter("excludeVariantId");
        
        if (productIdStr == null || productIdStr.isEmpty() || 
            valueIdsStr == null || valueIdsStr.isEmpty()) {
            out.print("{\"duplicate\": false}");
            return;
        }
        
        try {
            int productId = Integer.parseInt(productIdStr);
            Integer excludeId = null;
            
            if (excludeIdStr != null && !excludeIdStr.isEmpty()) {
                excludeId = Integer.parseInt(excludeIdStr);
            }
            
            List<Integer> valueIds = Arrays.stream(valueIdsStr.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .map(Integer::parseInt)
                .collect(Collectors.toList());
            
            if (valueIds.isEmpty()) {
                out.print("{\"duplicate\": false}");
                return;
            }
            
            Map<String, Object> duplicate = productDAO.findDuplicateVariant(productId, valueIds, excludeId);
            
            if (duplicate != null) {
                StringBuilder json = new StringBuilder();
                json.append("{\"duplicate\": true, ");
                json.append("\"variantId\": ").append(duplicate.get("variantId")).append(", ");
                json.append("\"sku\": \"").append(escapeJson((String) duplicate.get("sku"))).append("\", ");
                json.append("\"isActive\": ").append(duplicate.get("isActive"));
                
                // Thêm thông tin attributes nếu có
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> attrs = (List<Map<String, Object>>) duplicate.get("attributes");
                if (attrs != null && !attrs.isEmpty()) {
                    json.append(", \"attributes\": [");
                    for (int i = 0; i < attrs.size(); i++) {
                        if (i > 0) json.append(", ");
                        Map<String, Object> attr = attrs.get(i);
                        json.append("{\"attributeName\": \"").append(escapeJson((String) attr.get("attributeName"))).append("\", ");
                        json.append("\"valueName\": \"").append(escapeJson((String) attr.get("valueName"))).append("\"}");
                    }
                    json.append("]");
                }
                
                json.append("}");
                out.print(json.toString());
            } else {
                out.print("{\"duplicate\": false}");
            }
        } catch (NumberFormatException e) {
            out.print("{\"error\": \"Invalid parameter format\"}");
        }
    }
    
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}
