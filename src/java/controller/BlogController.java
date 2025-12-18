package controller;

import DAO.BlogPostDAO;
import entity.BlogPost;
import entity.Employee;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Controller for Blog Management (Customer-facing)
 */
@WebServlet(name = "BlogController", urlPatterns = {"/blog", "/blog-details"})
public class BlogController extends HttpServlet {

    private BlogPostDAO blogDAO;

    @Override
    public void init() throws ServletException {
        blogDAO = new BlogPostDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String path = request.getServletPath();
        
        try {
            if ("/blog".equals(path)) {
                showBlogList(request, response);
            } else if ("/blog-details".equals(path)) {
                showBlogDetails(request, response);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        }
    }

    /**
     * Show blog list with search and pagination
     */
    private void showBlogList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        String search = request.getParameter("search");
        String pageStr = request.getParameter("page");
        
        int page = 1;
        int pageSize = 9; // 9 blogs per page (3x3 grid)
        
        if (pageStr != null) {
            try {
                page = Integer.parseInt(pageStr);
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        
        // Get only published blogs for customers
        List<BlogPost> allBlogs = blogDAO.search(search, "published");
        
        // Calculate pagination
        int totalBlogs = allBlogs.size();
        int totalPages = (int) Math.ceil((double) totalBlogs / pageSize);
        
        // Get blogs for current page
        int fromIndex = (page - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalBlogs);
        List<BlogPost> blogs = allBlogs.subList(fromIndex, toIndex);
        
        request.setAttribute("blogs", blogs);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalBlogs", totalBlogs);
        request.setAttribute("search", search);
        
        request.getRequestDispatcher("/blog.jsp").forward(request, response);
    }

    /**
     * Show blog details
     */
    private void showBlogDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        String idStr = request.getParameter("id");
        
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/blog");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            BlogPost blog = blogDAO.findById(id);
            
            if (blog == null || !"published".equals(blog.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/blog?error=notfound");
                return;
            }
            
            // Increment view count (with session tracking to prevent spam)
            HttpSession session = request.getSession();
            String viewedBlogsKey = "viewedBlogs";
            @SuppressWarnings("unchecked")
            java.util.Set<Integer> viewedBlogs = (java.util.Set<Integer>) session.getAttribute(viewedBlogsKey);
            
            if (viewedBlogs == null) {
                viewedBlogs = new java.util.HashSet<>();
                session.setAttribute(viewedBlogsKey, viewedBlogs);
            }
            
            // Only increment if user hasn't viewed this blog in current session
            if (!viewedBlogs.contains(id)) {
                blogDAO.incrementViewCount(id);
                viewedBlogs.add(id);
                // Reload blog to get updated view count
                blog = blogDAO.findById(id);
                System.out.println("📊 Blog view count incremented: " + blog.getTitle() + " (Views: " + blog.getViewCount() + ")");
            }
            
            // Get related blogs (same status, different ID)
            List<BlogPost> relatedBlogs = blogDAO.search(null, "published");
            relatedBlogs.removeIf(b -> b.getPostId() == id);
            if (relatedBlogs.size() > 3) {
                relatedBlogs = relatedBlogs.subList(0, 3);
            }
            
            request.setAttribute("blog", blog);
            request.setAttribute("relatedBlogs", relatedBlogs);
            
            request.getRequestDispatcher("/blog-details.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/blog");
        }
    }

    @Override
    public String getServletInfo() {
        return "Blog Controller for customer-facing blog pages";
    }
}
