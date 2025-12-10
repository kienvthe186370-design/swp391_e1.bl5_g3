package controller.admin;

import DAO.CategoryDAO;
import DAO.AttributeDAO;
import entity.CategoryAttribute;
import entity.ProductAttribute;
import entity.AttributeValue;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * API Servlet để lấy thuộc tính theo category
 * Sử dụng cho tính năng Quản lý Biến thể sản phẩm
 * 
 * @author Product Variant Management Feature
 */
@WebServlet(name = "CategoryAttributeApiServlet", urlPatterns = {"/admin/api/category-attributes"})
public class CategoryAttributeApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Set response type là JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String categoryIdStr = request.getParameter("categoryId");
        PrintWriter out = response.getWriter();
        
        // Validate categoryId
        if (categoryIdStr == null || categoryIdStr.isEmpty()) {
            out.print("[]");
            return;
        }
        
        try {
            int categoryId = Integer.parseInt(categoryIdStr);
            
            CategoryDAO categoryDAO = new CategoryDAO();
            AttributeDAO attributeDAO = new AttributeDAO();
            
            // Lấy danh sách attribute của category từ bảng CategoryAttributes
            List<CategoryAttribute> catAttrs = categoryDAO.getCategoryAttributes(categoryId);
            
            // Build JSON response
            StringBuilder json = new StringBuilder("[");
            boolean first = true;
            
            for (CategoryAttribute ca : catAttrs) {
                // Lấy thông tin attribute
                ProductAttribute attr = attributeDAO.getAttributeByID(ca.getAttributeID());
                
                // Bỏ qua nếu attribute không tồn tại hoặc không active
                if (attr == null || !attr.isIsActive()) continue;
                
                // Lấy các giá trị của attribute
                List<AttributeValue> values = attributeDAO.getValuesByAttributeID(attr.getAttributeID());
                
                if (!first) json.append(",");
                first = false;
                
                json.append("{");
                json.append("\"attributeId\":").append(attr.getAttributeID()).append(",");
                json.append("\"attributeName\":\"").append(escapeJson(attr.getAttributeName())).append("\",");
                json.append("\"values\":[");
                
                boolean firstVal = true;
                for (AttributeValue val : values) {
                    // Bỏ qua giá trị không active
                    if (!val.isIsActive()) continue;
                    
                    if (!firstVal) json.append(",");
                    firstVal = false;
                    
                    json.append("{");
                    json.append("\"valueId\":").append(val.getValueID()).append(",");
                    json.append("\"valueName\":\"").append(escapeJson(val.getValueName())).append("\"");
                    json.append("}");
                }
                
                json.append("]}");
            }
            
            json.append("]");
            out.print(json.toString());
            
        } catch (NumberFormatException e) {
            // categoryId không hợp lệ
            out.print("[]");
        }
    }
    
    /**
     * Escape các ký tự đặc biệt trong JSON string
     */
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}
