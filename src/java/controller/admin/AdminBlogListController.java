package controller.admin;

import DAO.BlogPostDAO;
import entity.BlogPost;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Servlet quản lý danh sách blog/feedback (phần Blog – F21).
 */
@WebServlet(name = "AdminBlogListController", urlPatterns = {"/admin/blogs"})
public class AdminBlogListController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("q");
        String status = request.getParameter("status");

        BlogPostDAO dao = new BlogPostDAO();
        try {
            List<BlogPost> posts = dao.search(keyword, status);
            request.setAttribute("posts", posts);
            request.setAttribute("q", keyword);
            request.setAttribute("status", status);
        } catch (SQLException e) {
            throw new ServletException(e);
        }

        request.getRequestDispatcher("/admin-blog-list.jsp").forward(request, response);
    }
}

