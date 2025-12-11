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
 * Servlet xử lý quản lý sản phẩm cho Admin/Marketer
 * F_12: View Product List (Admin Dashboard - Table layout)
 */
@WebServlet(name = "AdminProductServlet", urlPatterns = {"/admin/products", "/admin/product-add"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1,  // 1 MB
    maxFileSize = 1024 * 1024 * 2,        // 2 MB
    maxRequestSize = 1024 * 1024 * 10     // 10 MB
)
public class AdminProductServlet extends HttpServlet {
    
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
        
        // Check authorization (Admin hoặc Marketer)
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employee") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String path = request.getServletPath();
        
        if ("/admin/product-add".equals(path)) {
            showProductAddForm(request, response);
        } else {
            String action = request.getParameter("action");
            
            if ("delete".equals(action)) {
                handleDelete(request, response);
            } else if ("toggle-status".equals(action)) {
                handleToggleStatus(request, response);
            } else {
                showProductList(request, response);
            }
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
        
        String path = request.getServletPath();
        
        if ("/admin/product-add".equals(path)) {
            handleProductCreate(request, response);
        } else {
            doGet(request, response);
        }
    }
    
    /**
     * Hiển thị danh sách sản phẩm với filter, sort, pagination
     */
    private void showProductList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lấy parameters từ request
        String search = request.getParameter("search");
        String categoryIdStr = request.getParameter("categoryId");
        String brandIdStr = request.getParameter("brandId");
        String statusStr = request.getParameter("status");
        String statusFilter = request.getParameter("statusFilter");
        String sortBy = request.getParameter("sortBy");
        String sortOrder = request.getParameter("sortOrder");
        String pageStr = request.getParameter("page");
        
        // Parse parameters
        Integer categoryId = parseInteger(categoryIdStr);
        Integer brandId = parseInteger(brandIdStr);
        Boolean isActive = parseStatus(statusStr);
        
        // Default sorting
        if (sortBy == null || sortBy.isEmpty()) {
            sortBy = "date";
        }
        if (sortOrder == null || sortOrder.isEmpty()) {
            sortOrder = "desc";
        }
        
        // Pagination
        int page = 1;
        int pageSize = 6; // Hiển thị 6 sản phẩm mỗi trang để vừa viewport, tránh thanh cuộn dọc
        try {
            if (pageStr != null && !pageStr.isEmpty()) {
                page = Integer.parseInt(pageStr);
                if (page < 1) page = 1;
            }
        } catch (NumberFormatException e) {
            page = 1;
        }
        
        // Lấy danh sách sản phẩm (with status filter)
        List<Map<String, Object>> products = productDAO.getProducts(
            search, categoryId, brandId, isActive, statusFilter, sortBy, sortOrder, page, pageSize
        );
        
        // Lấy tổng số sản phẩm để tính pagination (with status filter)
        int totalProducts = productDAO.getTotalProducts(search, categoryId, brandId, isActive, statusFilter);
        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);
        
        // Lấy status counts cho dashboard/filter
        Map<String, Integer> statusCounts = productDAO.getProductStatusCounts();
        
        // Lấy categories và brands cho filter dropdown
        List<Map<String, Object>> categories = productDAO.getCategoriesForFilter();
        List<Map<String, Object>> brands = productDAO.getBrandsForFilter();
        
        // Set attributes để JSP sử dụng
        request.setAttribute("products", products);
        request.setAttribute("categories", categories);
        request.setAttribute("brands", brands);
        
        // Pagination info
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("pageSize", pageSize);
        
        // Filter values (để giữ lại giá trị khi filter)
        request.setAttribute("search", search);
        request.setAttribute("categoryId", categoryId);
        request.setAttribute("brandId", brandId);
        request.setAttribute("status", statusStr);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("statusCounts", statusCounts);
        request.setAttribute("sortBy", sortBy);
        request.setAttribute("sortOrder", sortOrder);
        
        // Success/Error messages
        String message = request.getParameter("message");
        String error = request.getParameter("error");
        if (message != null) {
            request.setAttribute("successMessage", message);
        }
        if (error != null) {
            request.setAttribute("errorMessage", error);
        }
        
        // Set unified layout attributes
        request.setAttribute("contentPage", "products");
        request.setAttribute("activePage", "products");
        request.setAttribute("pageTitle", "Quản lý sản phẩm");
        
        // Forward to unified layout
        request.getRequestDispatcher("/AdminLTE-3.2.0/index.jsp").forward(request, response);
    }
    
    /**
     * Xử lý xóa sản phẩm (soft delete)
     */
    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String productIdStr = request.getParameter("id");
        
        if (productIdStr == null || productIdStr.isEmpty()) {
            response.sendRedirect("products?error=" + encodeURL("ID sản phẩm không hợp lệ"));
            return;
        }
        
        try {
            int productId = Integer.parseInt(productIdStr);
            
            // Thực hiện soft delete
            boolean success = productDAO.softDeleteProduct(productId);
            
            if (success) {
                response.sendRedirect("products?message=" + encodeURL("Xóa sản phẩm thành công"));
            } else {
                response.sendRedirect("products?error=" + encodeURL("Không thể xóa sản phẩm"));
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect("products?error=" + encodeURL("ID sản phẩm không hợp lệ"));
        }
    }
    
    /**
     * Xử lý toggle trạng thái sản phẩm (active/inactive)
     */
    private void handleToggleStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String productIdStr = request.getParameter("id");
        String statusStr = request.getParameter("status");
        
        if (productIdStr == null || productIdStr.isEmpty()) {
            response.sendRedirect("products?error=" + encodeURL("ID sản phẩm không hợp lệ"));
            return;
        }
        
        if (statusStr == null || statusStr.isEmpty()) {
            response.sendRedirect("products?error=" + encodeURL("Trạng thái không hợp lệ"));
            return;
        }
        
        try {
            int productId = Integer.parseInt(productIdStr);
            boolean newStatus = "active".equalsIgnoreCase(statusStr);
            
            // Thực hiện toggle status
            boolean success = productDAO.toggleProductStatus(productId, newStatus);
            
            if (success) {
                String message = newStatus ? "Kích hoạt sản phẩm thành công" : "Dừng hoạt động sản phẩm thành công";
                response.sendRedirect("products?message=" + encodeURL(message));
            } else {
                response.sendRedirect("products?error=" + encodeURL("Không thể cập nhật trạng thái sản phẩm"));
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect("products?error=" + encodeURL("ID sản phẩm không hợp lệ"));
        }
    }
    
    /**
     * Parse Integer từ String (nullable)
     */
    private Integer parseInteger(String str) {
        if (str == null || str.isEmpty() || "all".equalsIgnoreCase(str)) {
            return null;
        }
        try {
            return Integer.parseInt(str);
        } catch (NumberFormatException e) {
            return null;
        }
    }
    
    /**
     * Parse status từ String (nullable)
     * "active" -> true, "inactive" -> false, "all" -> null
     */
    private Boolean parseStatus(String status) {
        if (status == null || status.isEmpty() || "all".equalsIgnoreCase(status)) {
            return null;
        }
        if ("active".equalsIgnoreCase(status)) {
            return true;
        }
        if ("inactive".equalsIgnoreCase(status)) {
            return false;
        }
        return null;
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
    
    /**
     * Hiển thị form thêm sản phẩm mới
     */
    private void showProductAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lấy categories và brands cho dropdown
        List<Map<String, Object>> categories = productDAO.getCategoriesForFilter();
        List<Map<String, Object>> brands = productDAO.getBrandsForFilter();
        
        // Set attributes
        request.setAttribute("categories", categories);
        request.setAttribute("brands", brands);
        
        // Set unified layout attributes
        request.setAttribute("contentPage", "product-add");
        request.setAttribute("activePage", "products");
        request.setAttribute("pageTitle", "Thêm sản phẩm mới");
        
        // Forward to unified layout
        request.getRequestDispatcher("/AdminLTE-3.2.0/index.jsp").forward(request, response);
    }
    
    /**
     * Xử lý tạo sản phẩm mới
     */
    private void handleProductCreate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Set UTF-8 encoding
        request.setCharacterEncoding("UTF-8");
        
        // Validate input data
        Map<String, String> errors = validateProductInput(request);
        
        // Get uploaded files
        Part mainImagePart = null;
        List<Part> thumbnailParts = new ArrayList<>();
        
        try {
            mainImagePart = request.getPart("mainImage");
            
            // Get all thumbnail parts
            for (Part part : request.getParts()) {
                if ("thumbnailImages".equals(part.getName()) && part.getSize() > 0) {
                    thumbnailParts.add(part);
                }
            }
            
            // Validate image files
            Map<String, String> fileErrors = validateImageFiles(mainImagePart, thumbnailParts);
            errors.putAll(fileErrors);
            
        } catch (Exception e) {
            errors.put("general", "Lỗi khi xử lý file upload: " + e.getMessage());
        }
        
        // If validation fails, show form again with errors
        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("productName", request.getParameter("productName"));
            request.setAttribute("description", request.getParameter("description"));
            request.setAttribute("specifications", request.getParameter("specifications"));
            request.setAttribute("categoryId", request.getParameter("categoryId"));
            request.setAttribute("brandId", request.getParameter("brandId"));
            
            showProductAddForm(request, response);
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
        
        // Get employee ID from session
        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        int createdBy = employee.getEmployeeID();
        
        try {
            // Insert product into database
            int productId = productDAO.insertProduct(productName, categoryId, brandId, 
                                                     description, specifications, createdBy);
            
            if (productId <= 0) {
                request.setAttribute("errors", Map.of("general", "Không thể lưu sản phẩm. Vui lòng thử lại."));
                request.setAttribute("productName", productName);
                request.setAttribute("description", description);
                request.setAttribute("specifications", specifications);
                request.setAttribute("categoryId", categoryId);
                request.setAttribute("brandId", brandId);
                showProductAddForm(request, response);
                return;
            }
            
            // Save uploaded images
            String uploadDir = getServletContext().getRealPath(UPLOAD_DIRECTORY);
            
            // Debug: Log đường dẫn upload
            System.out.println("=== DEBUG UPLOAD ===");
            System.out.println("Upload Directory: " + uploadDir);
            System.out.println("UPLOAD_DIRECTORY constant: " + UPLOAD_DIRECTORY);
            
            File uploadDirFile = new File(uploadDir);
            if (!uploadDirFile.exists()) {
                boolean created = uploadDirFile.mkdirs();
                System.out.println("Created upload directory: " + created);
                System.out.println("Directory path: " + uploadDirFile.getAbsolutePath());
                if (!created) {
                    throw new IOException("Không thể tạo thư mục upload: " + uploadDir);
                }
            } else {
                System.out.println("Upload directory already exists: " + uploadDirFile.getAbsolutePath());
            }
            
            // Save main image
            if (mainImagePart != null && mainImagePart.getSize() > 0) {
                System.out.println("Saving main image: " + getSubmittedFileName(mainImagePart));
                String imageUrl = saveImageFile(mainImagePart, uploadDir);
                System.out.println("Main image saved to: " + imageUrl);
                if (imageUrl != null) {
                    boolean inserted = productDAO.insertProductImage(productId, imageUrl, "main", 0);
                    System.out.println("Main image inserted to DB: " + inserted);
                }
            } else {
                System.out.println("No main image uploaded");
            }
            
            // Save thumbnail images (gallery type for homepage/details display)
            int displayOrder = 1;
            System.out.println("Number of thumbnails: " + thumbnailParts.size());
            for (Part thumbnailPart : thumbnailParts) {
                System.out.println("Saving thumbnail " + displayOrder + ": " + getSubmittedFileName(thumbnailPart));
                String imageUrl = saveImageFile(thumbnailPart, uploadDir);
                System.out.println("Thumbnail saved to: " + imageUrl);
                if (imageUrl != null) {
                    boolean inserted = productDAO.insertProductImage(productId, imageUrl, "gallery", displayOrder++);
                    System.out.println("Thumbnail inserted to DB: " + inserted);
                }
            }
            
            System.out.println("=== PRODUCT CREATED SUCCESSFULLY ===");
            System.out.println("Product ID: " + productId);
            System.out.println("Product Name: " + productName);
            
            // Redirect to product list with success message
            response.sendRedirect(request.getContextPath() + "/admin/products?message=" + 
                                encodeURL("Thêm sản phẩm thành công"));
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errors", Map.of("general", "Lỗi hệ thống: " + e.getMessage()));
            request.setAttribute("productName", productName);
            request.setAttribute("description", description);
            request.setAttribute("specifications", specifications);
            request.setAttribute("categoryId", categoryId);
            request.setAttribute("brandId", brandId);
            showProductAddForm(request, response);
        }
    }
    
    /**
     * Validate product input data
     * @return Map of field names to error messages
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
        } else {
            try {
                int categoryId = Integer.parseInt(categoryIdStr);
                if (categoryId <= 0) {
                    errors.put("categoryId", "Vui lòng chọn danh mục");
                }
            } catch (NumberFormatException e) {
                errors.put("categoryId", "Danh mục không hợp lệ");
            }
        }
        
        // Brand is optional, no validation needed
        
        return errors;
    }
    
    /**
     * Validate uploaded image files
     * @return Map of field names to error messages
     */
    private Map<String, String> validateImageFiles(Part mainImage, List<Part> thumbnails) {
        Map<String, String> errors = new HashMap<>();
        
        // Validate main image
        if (mainImage != null && mainImage.getSize() > 0) {
            String filename = getSubmittedFileName(mainImage);
            
            // Check format
            boolean validFormat = false;
            for (String ext : ALLOWED_EXTENSIONS) {
                if (filename.toLowerCase().endsWith(ext)) {
                    validFormat = true;
                    break;
                }
            }
            if (!validFormat) {
                errors.put("mainImage", "Chỉ chấp nhận file JPG, PNG, GIF");
            }
            
            // Check size
            if (mainImage.getSize() > MAX_FILE_SIZE) {
                errors.put("mainImage", "Kích thước file không được vượt quá 2MB");
            }
        }
        
        // Validate thumbnails
        if (thumbnails != null && !thumbnails.isEmpty()) {
            long totalSize = 0;
            
            for (Part thumbnail : thumbnails) {
                if (thumbnail.getSize() > 0) {
                    String filename = getSubmittedFileName(thumbnail);
                    
                    // Check format
                    boolean validFormat = false;
                    for (String ext : ALLOWED_EXTENSIONS) {
                        if (filename.toLowerCase().endsWith(ext)) {
                            validFormat = true;
                            break;
                        }
                    }
                    if (!validFormat) {
                        errors.put("thumbnailImages", "Chỉ chấp nhận file JPG, PNG, GIF");
                        break;
                    }
                    
                    totalSize += thumbnail.getSize();
                }
            }
            
            // Check total size
            if (totalSize > MAX_FILE_SIZE) {
                errors.put("thumbnailImages", "Tổng kích thước ảnh thumbnail không được vượt quá 2MB");
            }
        }
        
        return errors;
    }
    
    /**
     * Save uploaded image file to file system
     * Saves to BOTH build/web/ (runtime) AND web/ (source)
     * @return Relative URL to the saved image, or null if failed
     */
    private String saveImageFile(Part filePart, String uploadDir) throws IOException {
        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }
        
        String originalFilename = getSubmittedFileName(filePart);
        String uniqueFilename = generateUniqueFilename(originalFilename);
        
        // Save to build/web/ (runtime - Tomcat uses this)
        String buildFilePath = uploadDir + File.separator + uniqueFilename;
        try (InputStream input = filePart.getInputStream()) {
            Files.copy(input, Paths.get(buildFilePath), StandardCopyOption.REPLACE_EXISTING);
            System.out.println("Saved to build/web: " + buildFilePath);
        }
        
        // Also save to web/ (source - so you can see it in project)
        try {
            String webRoot = getServletContext().getRealPath("/");
            String sourceWebPath = webRoot.replace("build\\web", "web");
            String sourceUploadDir = sourceWebPath + UPLOAD_DIRECTORY.substring(1); // Remove leading /
            
            File sourceDir = new File(sourceUploadDir);
            if (!sourceDir.exists()) {
                sourceDir.mkdirs();
                System.out.println("Created source directory: " + sourceUploadDir);
            }
            
            String sourceFilePath = sourceUploadDir + File.separator + uniqueFilename;
            try (InputStream input = filePart.getInputStream()) {
                Files.copy(input, Paths.get(sourceFilePath), StandardCopyOption.REPLACE_EXISTING);
                System.out.println("Saved to web/: " + sourceFilePath);
            }
        } catch (Exception e) {
            System.err.println("Warning: Could not save to source web/ directory: " + e.getMessage());
            // Don't fail if we can't save to source, build/web is enough for runtime
        }
        
        // Return relative URL
        return UPLOAD_DIRECTORY + "/" + uniqueFilename;
    }
    
    /**
     * Generate unique filename for uploaded image
     */
    private String generateUniqueFilename(String originalFilename) {
        String timestamp = String.valueOf(System.currentTimeMillis());
        String randomString = UUID.randomUUID().toString().substring(0, 8);
        
        // Get file extension
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
}