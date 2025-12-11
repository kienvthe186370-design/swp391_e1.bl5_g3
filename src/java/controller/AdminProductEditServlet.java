package controller;

import DAO.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@WebServlet(name = "AdminProductEditServlet", urlPatterns = {"/admin/product-edit"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 1024 * 1024 * 2,
    maxRequestSize = 1024 * 1024 * 10
)
public class AdminProductEditServlet extends HttpServlet {
    
    private static final String UPLOAD_DIR = "/img/product/uploads";
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
            List<Map<String, Object>> categories = productDAO.getCategoriesForFilter();
            List<Map<String, Object>> brands = productDAO.getBrandsForFilter();
            List<Map<String, Object>> variants = productDAO.getProductVariants(productId);
            
            request.setAttribute("product", product);
            request.setAttribute("images", images);
            request.setAttribute("categories", categories);
            request.setAttribute("brands", brands);
            request.setAttribute("variants", variants);
            
            request.setAttribute("contentPage", "product-edit");
            request.setAttribute("activePage", "products");
            request.setAttribute("pageTitle", "Chỉnh sửa sản phẩm");
            
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
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employee") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        request.setCharacterEncoding("UTF-8");
        
        String productIdStr = request.getParameter("productId");
        if (productIdStr == null || productIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=" + 
                                encodeURL("ID sản phẩm không hợp lệ"));
            return;
        }
        
        int productId = Integer.parseInt(productIdStr);
        Map<String, String> errors = validateInput(request);
        
        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            doGet(request, response);
            return;
        }
        
        String productName = request.getParameter("productName").trim();
        String description = request.getParameter("description");
        String specifications = request.getParameter("specifications");
        int categoryId = Integer.parseInt(request.getParameter("categoryId"));
        String brandIdStr = request.getParameter("brandId");
        Integer brandId = (brandIdStr != null && !brandIdStr.isEmpty() && !"0".equals(brandIdStr)) 
                          ? Integer.parseInt(brandIdStr) : null;
        boolean isActive = "true".equals(request.getParameter("isActive"));
        
        try {
            boolean updated = productDAO.updateProduct(productId, productName, categoryId, brandId,
                                                      description, specifications, isActive);
            if (!updated) {
                request.setAttribute("errors", Map.of("general", "Không thể cập nhật sản phẩm"));
                doGet(request, response);
                return;
            }
            
            // Handle image deletions
            String[] deleteImageIds = request.getParameterValues("deleteImageIds");
            if (deleteImageIds != null) {
                for (String imgId : deleteImageIds) {
                    productDAO.deleteProductImage(Integer.parseInt(imgId));
                }
            }
            
            // Handle new uploads
            String uploadDir = getServletContext().getRealPath(UPLOAD_DIR);
            File uploadDirFile = new File(uploadDir);
            if (!uploadDirFile.exists()) uploadDirFile.mkdirs();
            
            List<Map<String, Object>> currentImages = productDAO.getProductImages(productId);
            int maxOrder = 0;
            for (Map<String, Object> img : currentImages) {
                int order = (Integer) img.get("sortOrder");
                if (order > maxOrder) maxOrder = order;
            }
            
            Part mainImagePart = request.getPart("mainImage");
            if (mainImagePart != null && mainImagePart.getSize() > 0) {
                String imageUrl = saveImage(mainImagePart, uploadDir);
                if (imageUrl != null) {
                    productDAO.insertProductImage(productId, imageUrl, "main", 0);
                }
            }
            
            int sortOrder = maxOrder + 1;
            for (Part part : request.getParts()) {
                if ("thumbnailImages".equals(part.getName()) && part.getSize() > 0) {
                    String imageUrl = saveImage(part, uploadDir);
                    if (imageUrl != null) {
                        productDAO.insertProductImage(productId, imageUrl, "gallery", sortOrder++);
                    }
                }
            }
            
            // Handle variant deletions
            String[] deleteVariantIds = request.getParameterValues("deleteVariantIds");
            if (deleteVariantIds != null) {
                for (String variantId : deleteVariantIds) {
                    productDAO.deleteProductVariant(Integer.parseInt(variantId));
                }
            }
            
            // Handle existing variant updates
            String existingCountStr = request.getParameter("existingVariantCount");
            if (existingCountStr != null && !existingCountStr.isEmpty()) {
                int existingCount = Integer.parseInt(existingCountStr);
                for (int i = 0; i < existingCount; i++) {
                    String variantIdStr = request.getParameter("existingVariantId_" + i);
                    if (variantIdStr == null || variantIdStr.isEmpty()) continue;
                    
                    int variantId = Integer.parseInt(variantIdStr);
                    String sku = request.getParameter("existingVariantSku_" + i);
                    String costPriceStr = request.getParameter("existingVariantCostPrice_" + i);
                    String priceStr = request.getParameter("existingVariantPrice_" + i);
                    boolean variantActive = "true".equals(request.getParameter("existingVariantActive_" + i));
                    
                    if (sku != null && !sku.isEmpty() && priceStr != null && !priceStr.isEmpty()) {
                        java.math.BigDecimal costPrice = (costPriceStr != null && !costPriceStr.isEmpty()) 
                            ? new java.math.BigDecimal(costPriceStr) : java.math.BigDecimal.ZERO;
                        java.math.BigDecimal sellingPrice = new java.math.BigDecimal(priceStr);
                        productDAO.updateProductVariant(variantId, sku, costPrice, sellingPrice, variantActive);
                    }
                }
            }
            
            // Handle new variants
            int newVariantIndex = 0;
            while (true) {
                String valueIds = request.getParameter("newVariant_values_" + newVariantIndex);
                if (valueIds == null) break;
                
                String sku = request.getParameter("newVariant_sku_" + newVariantIndex);
                String priceStr = request.getParameter("newVariant_price_" + newVariantIndex);
                String stockStr = request.getParameter("newVariant_stock_" + newVariantIndex);
                
                if (sku != null && !sku.isEmpty() && priceStr != null && !priceStr.isEmpty()) {
                    java.math.BigDecimal sellingPrice = new java.math.BigDecimal(priceStr);
                    int stock = (stockStr != null && !stockStr.isEmpty()) ? Integer.parseInt(stockStr) : 0;
                    
                    // Create new variant
                    int newVariantId = productDAO.insertProductVariant(productId, sku, sellingPrice, stock);
                    
                    // Link variant to attribute values
                    if (newVariantId > 0 && !valueIds.isEmpty()) {
                        String[] valueIdArray = valueIds.split(",");
                        for (String valueId : valueIdArray) {
                            productDAO.insertVariantAttributeValue(newVariantId, Integer.parseInt(valueId.trim()));
                        }
                    }
                }
                newVariantIndex++;
            }
            
            response.sendRedirect(request.getContextPath() + "/admin/product-details?id=" + productId + 
                                "&message=" + encodeURL("Cập nhật sản phẩm thành công"));
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errors", Map.of("general", "Lỗi hệ thống: " + e.getMessage()));
            doGet(request, response);
        }
    }
    
    private Map<String, String> validateInput(HttpServletRequest request) {
        Map<String, String> errors = new HashMap<>();
        
        String productName = request.getParameter("productName");
        if (productName == null || productName.trim().isEmpty()) {
            errors.put("productName", "Tên sản phẩm không được để trống");
        }
        
        String categoryIdStr = request.getParameter("categoryId");
        if (categoryIdStr == null || categoryIdStr.isEmpty() || "0".equals(categoryIdStr)) {
            errors.put("categoryId", "Vui lòng chọn danh mục");
        }
        
        return errors;
    }
    
    private String saveImage(Part filePart, String uploadDir) throws IOException {
        if (filePart == null || filePart.getSize() == 0) return null;
        
        String originalName = getFileName(filePart);
        String ext = "";
        int idx = originalName.lastIndexOf('.');
        if (idx > 0) ext = originalName.substring(idx);
        
        String uniqueName = System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 8) + ext;
        
        // Save to build/web
        String buildPath = uploadDir + File.separator + uniqueName;
        try (InputStream input = filePart.getInputStream()) {
            Files.copy(input, Paths.get(buildPath), StandardCopyOption.REPLACE_EXISTING);
        }
        
        // Also save to web/ source
        try {
            String webRoot = getServletContext().getRealPath("/");
            String sourcePath = webRoot.replace("build\\web", "web") + UPLOAD_DIR.substring(1);
            File sourceDir = new File(sourcePath);
            if (!sourceDir.exists()) sourceDir.mkdirs();
            
            try (InputStream input = filePart.getInputStream()) {
                Files.copy(input, Paths.get(sourcePath + File.separator + uniqueName), StandardCopyOption.REPLACE_EXISTING);
            }
        } catch (Exception e) {
            // ignore if can't save to source
        }
        
        return UPLOAD_DIR + "/" + uniqueName;
    }
    
    private String getFileName(Part part) {
        String header = part.getHeader("content-disposition");
        for (String token : header.split(";")) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return "";
    }
    
    private String encodeURL(String str) {
        try {
            return java.net.URLEncoder.encode(str, "UTF-8");
        } catch (Exception e) {
            return str;
        }
    }
}
