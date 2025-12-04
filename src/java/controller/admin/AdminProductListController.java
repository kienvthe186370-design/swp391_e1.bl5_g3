package controller.admin;

import DAO.ProductDAO;
import entity.ProductListItem;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Servlet cho màn hình danh sách sản phẩm (F07).
 */
@WebServlet(name = "AdminProductListController", urlPatterns = {"/admin/products"})
public class AdminProductListController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("q");
        String categoryStr = request.getParameter("categoryId");
        String brandStr = request.getParameter("brandId");
        String statusStr = request.getParameter("status");
        String pageStr = request.getParameter("page");

        Integer categoryId = parseNullableInt(categoryStr);
        Integer brandId = parseNullableInt(brandStr);
        Boolean isActive = null;
        if ("active".equalsIgnoreCase(statusStr)) {
            isActive = true;
        } else if ("inactive".equalsIgnoreCase(statusStr)) {
            isActive = false;
        }
        int page = 1;
        int pageSize = 20;
        try {
            if (pageStr != null) {
                page = Integer.parseInt(pageStr);
                if (page < 1) {
                    page = 1;
                }
            }
        } catch (NumberFormatException ignore) {
            page = 1;
        }

        ProductDAO dao = new ProductDAO();
        try {
            List<ProductListItem> products = dao.search(keyword, categoryId, brandId, isActive, page, pageSize);
            request.setAttribute("products", products);
            request.setAttribute("q", keyword);
            request.setAttribute("categoryId", categoryId);
            request.setAttribute("brandId", brandId);
            request.setAttribute("status", statusStr);
            request.setAttribute("page", page);
        } catch (SQLException e) {
            throw new ServletException(e);
        }

        request.getRequestDispatcher("/admin-product-list.jsp").forward(request, response);
    }

    private Integer parseNullableInt(String raw) {
        if (raw == null || raw.isBlank()) {
            return null;
        }
        try {
            return Integer.parseInt(raw.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}

