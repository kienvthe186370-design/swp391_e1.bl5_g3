package controller;

import DAO.ProductDAO;
import entity.Employee;
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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Servlet xử lý chỉnh sửa sản phẩm cho Admin/Marketer
 */
@WebServlet(name = "AdminProductEditServlet", urlPatterns = {"/admin/product-edit"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1,  // 1 MB
    maxFileSize = 1024 * 1024 * 2,        // 2 MB
    maxRequestSize = 1024 * 1024 * 10     // 10 MB
)
public class AdminProductEditServlet extends HttpServlet {
    
    // Upload configuration constants
    private static final String UPLOAD_DIRECTORY = "/img/product/uploads";
    private static final long MAX_FILE_SIZE = 2 * 1024 * 1024; // 2MB
    private static final String[] ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".gif"};
    
    private ProductDAO productDAO;
    
    @Override
    public void init() throws ServletException {
        productDAO = new ProductDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization
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
            
            // Load categories and brands for dropdowns
            List<Map<String, Object>> categories = productDAO.getCategoriesForFilter();
            List<Map<String, Object>> brands = productDAO.getBrandsForFilter();
            
            // Set attributes for JSP
            request.setAttribute("product", product);
            request.setAttribute("images", images);
            request.setAttribute("categories", categories);
            request.setAttribute("brands", brands);
            
            // Set unified layout attributes
            request.setAttribute("contentPage", "product-edit");
            request.setAttribute("activePage", "products");
            request.setAttribute("pageTitle", "Chỉnh sửa sản phẩm");
            
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
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employee") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Set UTF-8 encoding
        request.setCharacterEncoding("UTF-8");
        
        // Get product ID
        String productIdStr = request.getParameter("productId");
        if (productIdStr == null || productIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=" + 
                                encodeURL("ID sản phẩm không hợp lệ"));
            return;
        }
        
        int productId = Integer.parseInt(productIdStr);
        
        // Validate input data
        Map<String, String> errors = validateProductInput(request);
        
        if (!errors.isEmpty()) {
            // Reload form with errors
            request.setAttribute("errors", errors);
            doGet(request, response);
            return;
        }
        
        // Get form data
        String productName = request.getParameter("productName").trim();
        String description = request.getParameter("description");
        String specifications = request.getParameter("specifications");
        int categoryId = Integer.parseInt(request.getParameter("categoryId"));
        String brandIdStr = request.getParameter("brandId");
        Integer brandId = (brandIdStr != null && !brandIdStr.isEmpty() && !"0".equals(brandIdStr)) 
                          ? Integer.parseInt(brandIdStr) : null;
        boolean isActive = "true".equals(request.getParameter("isActive"));
        
        try {
            // Update product in database
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
                for (String imageIdStr : deleteImageIds) {
                    int imageId = Integer.parseInt(imageIdStr);
                    productDAO.deleteProductImage(imageId);
                }
            }
            
            // Handle new image uploads
            String uploadDir = getServletContext().getRealPath(UPLOAD_DIRECTORY);
            File uploadDirFile = new File(uploadDir);
            if (!uploadDirFile.exists()) {
                uploadDirFile.mkdirs();
            }
            
            // Get current max sort order
            List<Map<String, Object>> currentImages = productDAO.getProductImages(productId);
            int maxSortOrder = 0;
            for (Map<String, Object> img : currentImages) {
                int sortOrder = (Integer) img.get("sortOrder");
                if (sortOrder > maxSortOrder) {
                    maxSortOrder = sortOrder;
                }
            }
            
            // Save new main image
            Part mainImagePart = request.getPart("mainImage");
            if (mainImagePart != null && mainImagePart.getSize() > 0) {
                String imageUrl = saveImageFile(mainImagePart, uploadDir);
                if (imageUrl != null) {
                    productDAO.insertProductImage(productId, imageUrl, "main", 0);
                }
            }
            
            // Save new thumbnail images (gallery type for homepage/details display)
            int sortOrder = maxSortOrder + 1;
            for (Part part : request.getParts()) {
                if ("thumbnailImages".equals(part.getName()) && part.getSize() > 0) {
                    String imageUrl = saveImageFile(part, uploadDir);
                    if (imageUrl != null) {
                        productDAO.insertProductImage(productId, imageUrl, "gallery", sortOrder++);
                    }
                }
            }
            
            // Redirect to product details with success message
            response.sendRedirect(request.getContextPath() + "/admin/product-details?id=" + productId + 
                                "&message=" + encodeURL("Cập nhật sản phẩm thành công"));
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errors", Map.of("general", "Lỗi hệ thống: " + e.getMessage()));
            doGet(request, response);
        }
    }
    
    /**
     * Validate product input data
     */
    private Map<String, String> validateProductInput(HttpServletRequest request) {
        Map<String, String> errors = new HashMap<>();
        
        // Validate product name
        String productName = request.getParameter("productName");
        if (productName == null || productName.trim().isEmpty()) {
            errors.put("productName", "Tên sản phẩm không được để trống");
        }
        
        // Validate category
        String categoryIdStr = request.getParameter("categoryId");
        if (categoryIdStr == null || categoryIdStr.isEmpty() || "0".equals(categoryIdStr)) {
            errors.put("categoryId", "Vui lòng chọn danh mục");
        }
        
        return errors;
    }
    
    /**
     * Save uploaded image file to file system
     * Saves to BOTH build/web/ (runtime) AND web/ (source)
     */
    private String saveImageFile(Part filePart, String uploadDir) throws IOException {
        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }
        
        String originalFilename = getSubmittedFileName(filePart);
        String uniqueFilename = generateUniqueFilename(originalFilename);
        
        // Save to build/web/ (runtime)
        String buildFilePath = uploadDir + File.separator + uniqueFilename;
        try (InputStream input = filePart.getInputStream()) {
            Files.copy(input, Paths.get(buildFilePath), StandardCopyOption.REPLACE_EXISTING);
        }
        
        // Save to web/ (source)
        try {
            String webRoot = getServletContext().getRealPath("/");
            String sourceWebPath = webRoot.replace("build\\web", "web");
            String sourceUploadDir = sourceWebPath + UPLOAD_DIRECTORY.substring(1);
            
            File sourceDir = new File(sourceUploadDir);
            if (!sourceDir.exists()) {
                sourceDir.mkdirs();
            }
            
            String sourceFilePath = sourceUploadDir + File.separator + uniqueFilename;
            try (InputStream input = filePart.getInputStream()) {
                Files.copy(input, Paths.get(sourceFilePath), StandardCopyOption.REPLACE_EXISTING);
            }
        } catch (Exception e) {
            System.err.println("Warning: Could not save to source web/ directory: " + e.getMessage());
        }
        
        return UPLOAD_DIRECTORY + "/" + uniqueFilename;
    }
    
    /**
     * Generate unique filename for uploaded image
     */
    private String generateUniqueFilename(String originalFilename) {
        String timestamp = String.valueOf(System.currentTimeMillis());
        String randomString = UUID.randomUUID().toString().substring(0, 8);
        
        String extension = "";
        int dotIndex = originalFilename.lastIndexOf('.');
        if (dotIndex > 0) {
            extension = originalFilename.substring(dotIndex);
        }
        
        return timestamp + "_" + randomString + extension;
    }
    
    /**
     * Get submitted filename from Part
     */
    private String getSubmittedFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        String[] tokens = contentDisposition.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return "";
    }
    
    /**
     * Encode URL
     */
    private String encodeURL(String str) {
        try {
            return java.net.URLEncoder.encode(str, "UTF-8");
        } catch (Exception e) {
            return str;
        }
    }
}
