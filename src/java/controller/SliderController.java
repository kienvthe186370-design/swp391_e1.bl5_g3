/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import DAO.SliderDAO;
import entity.Slider;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;

/**
 *
 * @author xuand
 */
@WebServlet(name="SliderController", urlPatterns={"/admin/slider"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1,  // 1 MB
    maxFileSize = 1024 * 1024 * 5,        // 5 MB
    maxRequestSize = 1024 * 1024 * 10     // 10 MB
)
public class SliderController extends HttpServlet {
    
    private SliderDAO sliderDAO;
    private static final String UPLOAD_DIR = "img/sliders";
    
    // Thư mục upload ngoài project (không bị mất khi rebuild)
    // Windows: C:/pickleball-uploads/sliders
    // Linux/Mac: /var/pickleball-uploads/sliders
    private static final String EXTERNAL_UPLOAD_PATH = "C:/pickleball-uploads/sliders";
    
    @Override
    public void init() throws ServletException {
        sliderDAO = new SliderDAO();
    }
   
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if (action == null) {
            action = "list";
        }
        
        switch (action) {
            case "list":
                showSliderList(request, response);
                break;
            case "add":
                showAddForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteSlider(request, response);
                break;
            case "toggleStatus":
                toggleSliderStatus(request, response);
                break;
            default:
                showSliderList(request, response);
                break;
        }
    } 

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        if ("add".equals(action)) {
            addSlider(request, response);
        } else if ("update".equals(action)) {
            updateSlider(request, response);
        }
    }
    
    // Show slider list with pagination, search, filter and sort
    private void showSliderList(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        String search = request.getParameter("search");
        String status = request.getParameter("status");
        String sortBy = request.getParameter("sortBy");
        String sortOrder = request.getParameter("sortOrder");
        String pageStr = request.getParameter("page");
        String pageSizeStr = request.getParameter("pageSize");
        
        int page = 1;
        int pageSize = 10;
        
        if (pageStr != null) {
            try {
                page = Integer.parseInt(pageStr);
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        
        if (pageSizeStr != null) {
            try {
                pageSize = Integer.parseInt(pageSizeStr);
            } catch (NumberFormatException e) {
                pageSize = 10;
            }
        }
        
        List<Slider> sliders = sliderDAO.getAllSliders(search, status, sortBy, sortOrder, page, pageSize);
        int totalSliders = sliderDAO.getTotalSliders(search, status);
        int totalPages = (int) Math.ceil((double) totalSliders / pageSize);
        
        request.setAttribute("sliders", sliders);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalSliders", totalSliders);
        request.setAttribute("search", search);
        request.setAttribute("status", status);
        request.setAttribute("sortBy", sortBy);
        request.setAttribute("sortOrder", sortOrder);
        
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-slider-list.jsp").forward(request, response);
    }
    
    // Show add slider form
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-slider-detail.jsp").forward(request, response);
    }
    
    // Show edit slider form
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Slider slider = sliderDAO.getSliderById(id);
        
        if (slider != null) {
            request.setAttribute("slider", slider);
            request.getRequestDispatcher("/AdminLTE-3.2.0/admin-slider-detail.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/slider?error=notfound");
        }
    }
    
    // Add new slider
    private void addSlider(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        try {
            String title = request.getParameter("title");
            String linkURL = request.getParameter("linkURL");
            int displayOrder = Integer.parseInt(request.getParameter("displayOrder"));
            String status = request.getParameter("status");
            
            // Handle image upload or URL
            String imageURL = handleImageUpload(request);
            
            if (imageURL == null || imageURL.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/slider?error=no_image");
                return;
            }
            
            Slider slider = new Slider();
            slider.setTitle(title);
            slider.setImageURL(imageURL);
            slider.setLinkURL(linkURL);
            slider.setDisplayOrder(displayOrder);
            slider.setStatus(status);
            
            sliderDAO.insertSlider(slider);
            
            response.sendRedirect(request.getContextPath() + "/admin/slider?success=added");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/slider?error=add_failed");
        }
    }
    
    // Update slider
    private void updateSlider(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String title = request.getParameter("title");
            String linkURL = request.getParameter("linkURL");
            int displayOrder = Integer.parseInt(request.getParameter("displayOrder"));
            String status = request.getParameter("status");
            String currentImageURL = request.getParameter("currentImageURL");
            
            // Handle image upload or URL (keep current if no new image)
            String imageURL = handleImageUpload(request);
            if (imageURL == null || imageURL.isEmpty()) {
                imageURL = currentImageURL; // Keep existing image
            }
            
            Slider slider = new Slider();
            slider.setSliderID(id);
            slider.setTitle(title);
            slider.setImageURL(imageURL);
            slider.setLinkURL(linkURL);
            slider.setDisplayOrder(displayOrder);
            slider.setStatus(status);
            
            sliderDAO.updateSlider(slider);
            
            response.sendRedirect(request.getContextPath() + "/admin/slider?success=updated");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/slider?error=update_failed");
        }
    }
    
    // Delete slider
    private void deleteSlider(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        sliderDAO.deleteSlider(id);
        
        response.sendRedirect(request.getContextPath() + "/admin/slider?success=deleted");
    }
    
    // Toggle slider status (active <-> inactive)
    private void toggleSliderStatus(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        boolean success = sliderDAO.toggleSliderStatus(id);
        
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/slider?success=toggled");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/slider?error=toggle_failed");
        }
    }

    /**
     * Handle image upload from file or URL
     * Returns the image path to save in database
     */
    private String handleImageUpload(HttpServletRequest request) throws ServletException, IOException {
        // Check if user uploaded a file
        Part filePart = request.getPart("imageFile");
        
        if (filePart != null && filePart.getSize() > 0) {
            // User uploaded a file - save it to server
            return saveUploadedFile(filePart, request);
        } else {
            // User provided URL - return the URL
            String imageURL = request.getParameter("imageURL");
            return (imageURL != null && !imageURL.trim().isEmpty()) ? imageURL : null;
        }
    }
    
    /**
     * Save uploaded file to server
     * Returns the relative path to save in database
     */
    private String saveUploadedFile(Part filePart, HttpServletRequest request) throws IOException {
        // Get original filename
        String fileName = getFileName(filePart);
        
        // Validate file extension
        String fileExtension = getFileExtension(fileName);
        if (!isValidImageExtension(fileExtension)) {
            throw new IOException("Invalid file type. Only JPG, PNG, GIF allowed.");
        }
        
        // Generate unique filename to avoid conflicts
        String uniqueFileName = generateUniqueFileName(fileExtension);
        
        // Get absolute path to web/img/sliders folder (primary location)
        String applicationPath = request.getServletContext().getRealPath("");
        String uploadPath = applicationPath + File.separator + UPLOAD_DIR;
        
        // Create directory if not exists
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
        
        // Save file to deploy folder
        String filePath = uploadPath + File.separator + uniqueFileName;
        try {
            Files.copy(filePart.getInputStream(), 
                      Paths.get(filePath), 
                      StandardCopyOption.REPLACE_EXISTING);
            System.out.println("✅ File uploaded successfully: " + filePath);
        } catch (IOException e) {
            System.err.println("❌ Error uploading file: " + e.getMessage());
            throw e;
        }
        
        // Try to also save to external folder (optional - won't fail if not exists)
        try {
            File externalDir = new File(EXTERNAL_UPLOAD_PATH);
            if (!externalDir.exists()) {
                externalDir.mkdirs();
            }
            String externalFilePath = EXTERNAL_UPLOAD_PATH + File.separator + uniqueFileName;
            Files.copy(Paths.get(filePath), 
                      Paths.get(externalFilePath), 
                      StandardCopyOption.REPLACE_EXISTING);
            System.out.println("✅ File also saved to external: " + externalFilePath);
        } catch (Exception e) {
            System.out.println("⚠️ Could not save to external folder (optional): " + e.getMessage());
        }
        
        // Try to also save to project source folder (optional)
        try {
            String deployPath = request.getServletContext().getRealPath("");
            String projectSourcePath = getProjectSourcePath(request);
            
            System.out.println("🔍 DEBUG Upload - Deploy path: " + deployPath);
            System.out.println("🔍 DEBUG Upload - Source path: " + projectSourcePath);
            
            File sourceDir = new File(projectSourcePath + File.separator + UPLOAD_DIR);
            System.out.println("🔍 DEBUG Upload - Source dir: " + sourceDir.getAbsolutePath());
            System.out.println("🔍 DEBUG Upload - Source dir exists: " + sourceDir.exists());
            System.out.println("🔍 DEBUG Upload - Source dir can write: " + sourceDir.canWrite());
            
            if (!sourceDir.exists()) {
                boolean created = sourceDir.mkdirs();
                System.out.println("🔍 DEBUG Upload - Created source dir: " + created);
            }
            
            String sourceFilePath = projectSourcePath + File.separator + UPLOAD_DIR + File.separator + uniqueFileName;
            System.out.println("🔍 DEBUG Upload - Source file path: " + sourceFilePath);
            
            Files.copy(Paths.get(filePath), 
                      Paths.get(sourceFilePath), 
                      StandardCopyOption.REPLACE_EXISTING);
            System.out.println("✅ File also saved to source: " + sourceFilePath);
        } catch (Exception e) {
            System.out.println("⚠️ Could not save to source folder (optional): " + e.getMessage());
            System.out.println("⚠️ Full error:");
            e.printStackTrace();
        }
        
        // Return relative path for database (e.g., "img/sliders/abc123.jpg")
        return UPLOAD_DIR + "/" + uniqueFileName;
    }
    
    /**
     * Get project source path (web folder in source code)
     */
    private String getProjectSourcePath(HttpServletRequest request) {
        String deployPath = request.getServletContext().getRealPath("");
        // Từ: C:\...\build\web
        // Lấy: C:\...\web
        if (deployPath.contains("build" + File.separator + "web")) {
            return deployPath.replace("build" + File.separator + "web", "web");
        }
        // Nếu deploy trên Tomcat: C:\...\webapps\app-name
        // Cần config đường dẫn project thủ công
        return deployPath;
    }
    
    /**
     * Extract filename from Part header
     */
    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        String[] tokens = contentDisposition.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return "unknown";
    }
    
    /**
     * Get file extension from filename
     */
    private String getFileExtension(String fileName) {
        int lastDotIndex = fileName.lastIndexOf('.');
        if (lastDotIndex > 0) {
            return fileName.substring(lastDotIndex + 1).toLowerCase();
        }
        return "";
    }
    
    /**
     * Validate image file extension
     */
    private boolean isValidImageExtension(String extension) {
        return extension.equals("jpg") || extension.equals("jpeg") || 
               extension.equals("png") || extension.equals("gif");
    }
    
    /**
     * Generate unique filename using UUID
     */
    private String generateUniqueFileName(String extension) {
        return "slider_" + UUID.randomUUID().toString() + "." + extension;
    }

    @Override
    public String getServletInfo() {
        return "Slider Management Controller";
    }
}
