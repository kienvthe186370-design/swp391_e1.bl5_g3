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

@WebServlet(name = "AdminProductServlet", urlPatterns = {"/admin/products", "/admin/product-add"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 1024 * 1024 * 2,
    maxRequestSize = 1024 * 1024 * 10
)
public class AdminProductServlet extends HttpServlet {
    
    private static final String UPLOAD_DIR = "/img/product/uploads";
    private static final long MAX_SIZE = 2 * 1024 * 1024;
    private static final String[] ALLOWED_EXT = {".jpg", ".jpeg", ".png", ".gif"};
    
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
        
        String path = request.getServletPath();
        
        if ("/admin/product-add".equals(path)) {
            showAddForm(request, response);
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
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employee") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String path = request.getServletPath();
        if ("/admin/product-add".equals(path)) {
            handleCreate(request, response);
        } else {
            doGet(request, response);
        }
    }
    
    private void showProductList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String search = request.getParameter("search");
        String categoryIdStr = request.getParameter("categoryId");
        String brandIdStr = request.getParameter("brandId");
        String statusStr = request.getParameter("status");
        String statusFilter = request.getParameter("statusFilter");
        String sortBy = request.getParameter("sortBy");
        String sortOrder = request.getParameter("sortOrder");
        String pageStr = request.getParameter("page");
        
        Integer categoryId = parseInteger(categoryIdStr);
        Integer brandId = parseInteger(brandIdStr);
        Boolean isActive = parseStatus(statusStr);
        
        if (sortBy == null || sortBy.isEmpty()) sortBy = "date";
        if (sortOrder == null || sortOrder.isEmpty()) sortOrder = "desc";
        
        int page = 1;
        int pageSize = 6;
        try {
            if (pageStr != null && !pageStr.isEmpty()) {
                page = Integer.parseInt(pageStr);
                if (page < 1) page = 1;
            }
        } catch (NumberFormatException e) {
            page = 1;
        }
        
        List<Map<String, Object>> products = productDAO.getProducts(
            search, categoryId, brandId, isActive, statusFilter, sortBy, sortOrder, page, pageSize
        );
        
        int totalProducts = productDAO.getTotalProducts(search, categoryId, brandId, isActive, statusFilter);
        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);
        
        Map<String, Integer> statusCounts = productDAO.getProductStatusCounts();
        List<Map<String, Object>> categories = productDAO.getCategoriesForFilter();
        List<Map<String, Object>> brands = productDAO.getBrandsForFilter();
        
        request.setAttribute("products", products);
        request.setAttribute("categories", categories);
        request.setAttribute("brands", brands);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("search", search);
        request.setAttribute("categoryId", categoryId);
        request.setAttribute("brandId", brandId);
        request.setAttribute("status", statusStr);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("statusCounts", statusCounts);
        request.setAttribute("sortBy", sortBy);
        request.setAttribute("sortOrder", sortOrder);
        
        String message = request.getParameter("message");
        String error = request.getParameter("error");
        if (message != null) request.setAttribute("successMessage", message);
        if (error != null) request.setAttribute("errorMessage", error);
        
        request.setAttribute("contentPage", "products");
        request.setAttribute("activePage", "products");
        request.setAttribute("pageTitle", "Quản lý sản phẩm");
        
        request.getRequestDispatcher("/AdminLTE-3.2.0/index.jsp").forward(request, response);
    }
    
    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String productIdStr = request.getParameter("id");
        if (productIdStr == null || productIdStr.isEmpty()) {
            response.sendRedirect("products?error=" + encodeURL("ID sản phẩm không hợp lệ"));
            return;
        }
        
        try {
            int productId = Integer.parseInt(productIdStr);
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
            boolean success = productDAO.toggleProductStatus(productId, newStatus);
            
            if (success) {
                String msg = newStatus ? "Kích hoạt sản phẩm thành công" : "Dừng hoạt động sản phẩm thành công";
                response.sendRedirect("products?message=" + encodeURL(msg));
            } else {
                response.sendRedirect("products?error=" + encodeURL("Không thể cập nhật trạng thái sản phẩm"));
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("products?error=" + encodeURL("ID sản phẩm không hợp lệ"));
        }
    }
    
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<Map<String, Object>> categories = productDAO.getCategoriesForFilter();
        List<Map<String, Object>> brands = productDAO.getBrandsForFilter();
        
        request.setAttribute("categories", categories);
        request.setAttribute("brands", brands);
        request.setAttribute("contentPage", "product-add");
        request.setAttribute("activePage", "products");
        request.setAttribute("pageTitle", "Thêm sản phẩm mới");
        
        request.getRequestDispatcher("/AdminLTE-3.2.0/index.jsp").forward(request, response);
    }
    
    private void handleCreate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        Map<String, String> errors = validateInput(request);
        
        Part mainImagePart = null;
        List<Part> thumbnailParts = new ArrayList<>();
        
        try {
            mainImagePart = request.getPart("mainImage");
            for (Part part : request.getParts()) {
                if ("thumbnailImages".equals(part.getName()) && part.getSize() > 0) {
                    thumbnailParts.add(part);
                }
            }
            Map<String, String> fileErrors = validateImages(mainImagePart, thumbnailParts);
            errors.putAll(fileErrors);
        } catch (Exception e) {
            errors.put("general", "Lỗi khi xử lý file upload: " + e.getMessage());
        }
        
        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("productName", request.getParameter("productName"));
            request.setAttribute("description", request.getParameter("description"));
            request.setAttribute("specifications", request.getParameter("specifications"));
            request.setAttribute("categoryId", request.getParameter("categoryId"));
            request.setAttribute("brandId", request.getParameter("brandId"));
            showAddForm(request, response);
            return;
        }
        
        String productName = request.getParameter("productName").trim();
        String description = request.getParameter("description");
        String specifications = request.getParameter("specifications");
        int categoryId = Integer.parseInt(request.getParameter("categoryId"));
        String brandIdStr = request.getParameter("brandId");
        Integer brandId = (brandIdStr != null && !brandIdStr.isEmpty() && !"0".equals(brandIdStr)) 
                          ? Integer.parseInt(brandIdStr) : null;
        
        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        int createdBy = employee.getEmployeeID();
        
        try {
            int productId = productDAO.insertProduct(productName, categoryId, brandId, 
                                                     description, specifications, createdBy);
            
            if (productId <= 0) {
                request.setAttribute("errors", Map.of("general", "Không thể lưu sản phẩm. Vui lòng thử lại."));
                request.setAttribute("productName", productName);
                request.setAttribute("description", description);
                request.setAttribute("specifications", specifications);
                request.setAttribute("categoryId", categoryId);
                request.setAttribute("brandId", brandId);
                showAddForm(request, response);
                return;
            }
            
            String uploadDir = getServletContext().getRealPath(UPLOAD_DIR);
            // System.out.println("Upload dir: " + uploadDir);
            
            File uploadDirFile = new File(uploadDir);
            if (!uploadDirFile.exists()) {
                uploadDirFile.mkdirs();
            }
            
            if (mainImagePart != null && mainImagePart.getSize() > 0) {
                String imageUrl = saveImage(mainImagePart, uploadDir);
                if (imageUrl != null) {
                    productDAO.insertProductImage(productId, imageUrl, "main", 0);
                }
            }
            
            int displayOrder = 1;
            for (Part thumbnailPart : thumbnailParts) {
                String imageUrl = saveImage(thumbnailPart, uploadDir);
                if (imageUrl != null) {
                    productDAO.insertProductImage(productId, imageUrl, "gallery", displayOrder++);
                }
            }
            
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
            showAddForm(request, response);
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
        } else {
            try {
                int catId = Integer.parseInt(categoryIdStr);
                if (catId <= 0) errors.put("categoryId", "Vui lòng chọn danh mục");
            } catch (NumberFormatException e) {
                errors.put("categoryId", "Danh mục không hợp lệ");
            }
        }
        
        return errors;
    }
    
    private Map<String, String> validateImages(Part mainImage, List<Part> thumbnails) {
        Map<String, String> errors = new HashMap<>();
        
        if (mainImage != null && mainImage.getSize() > 0) {
            String filename = getFileName(mainImage);
            boolean validExt = false;
            for (String ext : ALLOWED_EXT) {
                if (filename.toLowerCase().endsWith(ext)) {
                    validExt = true;
                    break;
                }
            }
            if (!validExt) errors.put("mainImage", "Chỉ chấp nhận file JPG, PNG, GIF");
            if (mainImage.getSize() > MAX_SIZE) errors.put("mainImage", "Kích thước file không được vượt quá 2MB");
        }
        
        if (thumbnails != null && !thumbnails.isEmpty()) {
            long totalSize = 0;
            for (Part thumb : thumbnails) {
                if (thumb.getSize() > 0) {
                    String filename = getFileName(thumb);
                    boolean validExt = false;
                    for (String ext : ALLOWED_EXT) {
                        if (filename.toLowerCase().endsWith(ext)) {
                            validExt = true;
                            break;
                        }
                    }
                    if (!validExt) {
                        errors.put("thumbnailImages", "Chỉ chấp nhận file JPG, PNG, GIF");
                        break;
                    }
                    totalSize += thumb.getSize();
                }
            }
            if (totalSize > MAX_SIZE) {
                errors.put("thumbnailImages", "Tổng kích thước ảnh thumbnail không được vượt quá 2MB");
            }
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
        
        String buildPath = uploadDir + File.separator + uniqueName;
        try (InputStream input = filePart.getInputStream()) {
            Files.copy(input, Paths.get(buildPath), StandardCopyOption.REPLACE_EXISTING);
        }
        
        // Also save to web/ source folder
        try {
            String webRoot = getServletContext().getRealPath("/");
            String sourcePath = webRoot.replace("build\\web", "web") + UPLOAD_DIR.substring(1);
            File sourceDir = new File(sourcePath);
            if (!sourceDir.exists()) sourceDir.mkdirs();
            
            try (InputStream input = filePart.getInputStream()) {
                Files.copy(input, Paths.get(sourcePath + File.separator + uniqueName), StandardCopyOption.REPLACE_EXISTING);
            }
        } catch (Exception e) {
            // ignore
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
    
    private Integer parseInteger(String str) {
        if (str == null || str.isEmpty() || "all".equalsIgnoreCase(str)) return null;
        try {
            return Integer.parseInt(str);
        } catch (NumberFormatException e) {
            return null;
        }
    }
    
    private Boolean parseStatus(String status) {
        if (status == null || status.isEmpty() || "all".equalsIgnoreCase(status)) return null;
        if ("active".equalsIgnoreCase(status)) return true;
        if ("inactive".equalsIgnoreCase(status)) return false;
        return null;
    }
    
    private String encodeURL(String str) {
        try {
            return java.net.URLEncoder.encode(str, "UTF-8");
        } catch (Exception e) {
            return str;
        }
    }
}
