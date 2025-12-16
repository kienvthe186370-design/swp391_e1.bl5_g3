package controller;

import DAO.BlogPostDAO;
import entity.BlogPost;
import entity.Employee;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.SQLException;
import java.util.List;
import java.util.UUID;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

/**
 * Controller for Admin Blog Management (CRUD)
 */
@WebServlet(name = "AdminBlogController", urlPatterns = {"/admin/blog"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 5,        // 5MB
    maxRequestSize = 1024 * 1024 * 10     // 10MB
)
public class AdminBlogController extends HttpServlet {

    private BlogPostDAO blogDAO;

    @Override
    public void init() throws ServletException {
        blogDAO = new BlogPostDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if (action == null) {
            action = "list";
        }
        
        try {
            switch (action) {
                case "list":
                    showBlogList(request, response);
                    break;
                case "add":
                    showAddForm(request, response);
                    break;
                case "edit":
                    showEditForm(request, response);
                    break;
                case "delete":
                    deleteBlog(request, response);
                    break;
                case "toggleStatus":
                    toggleBlogStatus(request, response);
                    break;
                default:
                    showBlogList(request, response);
                    break;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        try {
            if ("add".equals(action)) {
                addBlog(request, response);
            } else if ("update".equals(action)) {
                updateBlog(request, response);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/blog?error=database");
        }
    }

    /**
     * Show blog list with search, filter and pagination
     */
    private void showBlogList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        String search = request.getParameter("search");
        String status = request.getParameter("status");
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
                if (pageSize != 5 && pageSize != 10 && pageSize != 20) {
                    pageSize = 10;
                }
            } catch (NumberFormatException e) {
                pageSize = 10;
            }
        }
        
        // Get all blogs matching search and status
        List<BlogPost> allBlogs = blogDAO.search(search, status);
        
        // Calculate pagination
        int totalBlogs = allBlogs.size();
        int totalPages = (int) Math.ceil((double) totalBlogs / pageSize);
        
        // Get blogs for current page
        int fromIndex = (page - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalBlogs);
        List<BlogPost> blogs = allBlogs.subList(fromIndex, toIndex);
        
        request.setAttribute("blogs", blogs);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalBlogs", totalBlogs);
        request.setAttribute("search", search);
        request.setAttribute("status", status);
        
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-blog-list.jsp").forward(request, response);
    }

    /**
     * Show add blog form
     */
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-blog-detail.jsp").forward(request, response);
    }

    /**
     * Show edit blog form
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        String idStr = request.getParameter("id");
        
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/blog?error=invalid");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            BlogPost blog = blogDAO.findById(id);
            
            if (blog != null) {
                request.setAttribute("blog", blog);
                request.getRequestDispatcher("/AdminLTE-3.2.0/admin-blog-detail.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/blog?error=notfound");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/blog?error=invalid");
        }
    }

    /**
     * Add new blog
     */
    private void addBlog(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        
        if (employee == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String title = request.getParameter("title");
        String slug = request.getParameter("slug");
        String content = request.getParameter("content");
        String featuredImage = request.getParameter("featuredImage");
        String summary = request.getParameter("summary");
        String status = request.getParameter("status");
        
        // Handle file upload
        Part filePart = request.getPart("imageFile");
        if (filePart != null && filePart.getSize() > 0) {
            featuredImage = handleFileUpload(filePart, request, "blog");
        }
        
        // Validate required fields
        if (title == null || title.trim().isEmpty() || 
            content == null || content.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/blog?action=add&error=missing");
            return;
        }
        
        // Generate slug if empty
        if (slug == null || slug.trim().isEmpty()) {
            slug = generateSlug(title);
        }
        
        BlogPost blog = new BlogPost();
        blog.setTitle(title.trim());
        blog.setSlug(slug.trim());
        blog.setContent(content);
        blog.setFeaturedImage(featuredImage);
        blog.setSummary(summary);
        blog.setStatus(status != null ? status : "draft");
        blog.setAuthorId(employee.getEmployeeID());
        
        blogDAO.insert(blog);
        
        response.sendRedirect(request.getContextPath() + "/admin/blog?success=added");
    }

    /**
     * Update blog
     */
    private void updateBlog(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        String idStr = request.getParameter("id");
        
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/blog?error=invalid");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            BlogPost blog = blogDAO.findById(id);
            
            if (blog == null) {
                response.sendRedirect(request.getContextPath() + "/admin/blog?error=notfound");
                return;
            }
            
            String title = request.getParameter("title");
            String slug = request.getParameter("slug");
            String content = request.getParameter("content");
            String featuredImage = request.getParameter("featuredImage");
            String currentFeaturedImage = request.getParameter("currentFeaturedImage");
            String summary = request.getParameter("summary");
            String status = request.getParameter("status");
            
            // Handle file upload
            Part filePart = request.getPart("imageFile");
            if (filePart != null && filePart.getSize() > 0) {
                featuredImage = handleFileUpload(filePart, request, "blog");
            } else if (featuredImage == null || featuredImage.trim().isEmpty()) {
                // Keep current image if no new image provided
                featuredImage = currentFeaturedImage;
            }
            
            // Validate required fields
            if (title == null || title.trim().isEmpty() || 
                content == null || content.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/blog?action=edit&id=" + id + "&error=missing");
                return;
            }
            
            // Generate slug if empty
            if (slug == null || slug.trim().isEmpty()) {
                slug = generateSlug(title);
            }
            
            blog.setTitle(title.trim());
            blog.setSlug(slug.trim());
            blog.setContent(content);
            blog.setFeaturedImage(featuredImage);
            blog.setSummary(summary);
            blog.setStatus(status != null ? status : "draft");
            
            blogDAO.update(blog);
            
            response.sendRedirect(request.getContextPath() + "/admin/blog?success=updated");
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/blog?error=invalid");
        }
    }

    /**
     * Delete blog (soft delete by changing status to draft)
     */
    private void deleteBlog(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        String idStr = request.getParameter("id");
        
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/blog?error=invalid");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            BlogPost blog = blogDAO.findById(id);
            
            if (blog != null) {
                blog.setStatus("draft");
                blogDAO.update(blog);
                response.sendRedirect(request.getContextPath() + "/admin/blog?success=deleted");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/blog?error=notfound");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/blog?error=invalid");
        }
    }

    /**
     * Toggle blog status between draft and published
     */
    private void toggleBlogStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        String idStr = request.getParameter("id");
        
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/blog?error=invalid");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            BlogPost blog = blogDAO.findById(id);
            
            if (blog != null) {
                String newStatus = "published".equals(blog.getStatus()) ? "draft" : "published";
                blog.setStatus(newStatus);
                blogDAO.update(blog);
                response.sendRedirect(request.getContextPath() + "/admin/blog?success=toggled");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/blog?error=notfound");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/blog?error=invalid");
        }
    }

    /**
     * Generate SEO-friendly slug from title
     */
    private String generateSlug(String title) {
        return title.toLowerCase()
                .replaceAll("[àáạảãâầấậẩẫăằắặẳẵ]", "a")
                .replaceAll("[èéẹẻẽêềếệểễ]", "e")
                .replaceAll("[ìíịỉĩ]", "i")
                .replaceAll("[òóọỏõôồốộổỗơờớợởỡ]", "o")
                .replaceAll("[ùúụủũưừứựửữ]", "u")
                .replaceAll("[ỳýỵỷỹ]", "y")
                .replaceAll("[đ]", "d")
                .replaceAll("[^a-z0-9\\s-]", "")
                .replaceAll("\\s+", "-")
                .replaceAll("-+", "-")
                .replaceAll("^-|-$", "");
    }

    /**
     * Handle file upload and return the saved file path
     */
    private String handleFileUpload(Part filePart, HttpServletRequest request, String folder) throws IOException {
        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }
        
        // Get filename
        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        
        // Validate file extension
        String fileExtension = "";
        int dotIndex = fileName.lastIndexOf('.');
        if (dotIndex > 0) {
            fileExtension = fileName.substring(dotIndex);
        }
        
        String[] allowedExtensions = {".jpg", ".jpeg", ".png", ".gif"};
        boolean validExtension = false;
        for (String ext : allowedExtensions) {
            if (fileExtension.equalsIgnoreCase(ext)) {
                validExtension = true;
                break;
            }
        }
        
        if (!validExtension) {
            throw new IOException("Invalid file type. Only JPG, PNG, GIF allowed.");
        }
        
        // Generate unique filename
        String uniqueFileName = folder + "_" + UUID.randomUUID().toString() + fileExtension;
        
        // Get upload directory path
        String uploadPath = request.getServletContext().getRealPath("") + File.separator + "img" + File.separator + folder;
        
        // Create directory if not exists
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
        
        // Save file
        Path filePath = Paths.get(uploadPath, uniqueFileName);
        Files.copy(filePart.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
        
        // Return relative path
        return "img/" + folder + "/" + uniqueFileName;
    }

    @Override
    public String getServletInfo() {
        return "Admin Blog Management Controller";
    }
}
