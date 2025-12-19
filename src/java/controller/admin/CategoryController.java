package controller.admin;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 *
 * @author Admin
 */
@WebServlet(name="CategoryController", urlPatterns={"/admin/categories"})
public class CategoryController extends HttpServlet {
   
    private DAO.CategoryDAO categoryDAO = new DAO.CategoryDAO();
    private DAO.AttributeDAO attributeDAO = new DAO.AttributeDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        if (action == null) action = "list";
        
        switch (action) {
            case "add":
                showAddForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteCategory(request, response);
                break;
            default:
                listCategories(request, response);
                break;
        }
    } 

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        
        if ("add".equals(action)) {
            addCategory(request, response);
        } else if ("edit".equals(action)) {
            updateCategory(request, response);
        }
    }
    
    private void listCategories(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        // Get search, filter, sort parameters
        String search = request.getParameter("search");
        String statusParam = request.getParameter("status");
        String sortBy = request.getParameter("sortBy");
        String sortOrder = request.getParameter("sortOrder");
        
        // Get page parameters
        int page = 1;
        int pageSize = 5;
        try {
            if (request.getParameter("page") != null) {
                page = Integer.parseInt(request.getParameter("page"));
            }
            if (request.getParameter("pageSize") != null) {
                pageSize = Integer.parseInt(request.getParameter("pageSize"));
            }
        } catch (NumberFormatException e) {
            page = 1;
            pageSize = 5;
        }
        
        // Parse status filter
        Boolean isActive = null;
        if (statusParam != null && !statusParam.isEmpty()) {
            isActive = "active".equals(statusParam);
        }
        
        // Get data with filters
        java.util.List<entity.Category> categories = categoryDAO.getCategories(search, isActive, sortBy, sortOrder, page, pageSize);
        int totalRecords = categoryDAO.getTotalCategories(search, isActive);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
        
        // Set attributes
        request.setAttribute("categories", categories);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("search", search);
        request.setAttribute("status", statusParam);
        request.setAttribute("sortBy", sortBy);
        request.setAttribute("sortOrder", sortOrder);
        
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-category-list.jsp").forward(request, response);
    }
    
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        request.setAttribute("attributes", attributeDAO.getAllAttributes());
       request.getRequestDispatcher("/AdminLTE-3.2.0/admin-category-detail.jsp").forward(request, response);
    }
    
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        entity.Category category = categoryDAO.getCategoryByID(id);
        request.setAttribute("category", category);
        request.setAttribute("attributes", attributeDAO.getAllAttributes());
        request.setAttribute("categoryAttributes", categoryDAO.getCategoryAttributes(id));
      request.getRequestDispatcher("/AdminLTE-3.2.0/admin-category-detail.jsp").forward(request, response);
    }
    private void addCategory(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        try {
            String name = request.getParameter("categoryName");
            String desc = request.getParameter("description");
            String icon = request.getParameter("icon");
            
            String displayOrderStr = request.getParameter("displayOrder");
            int displayOrder = (displayOrderStr != null && !displayOrderStr.isEmpty()) 
                              ? Integer.parseInt(displayOrderStr) : 0;
            
            boolean isActive = "on".equals(request.getParameter("isActive"));
            
            // Kiểm tra trùng tên danh mục
            if (categoryDAO.isCategoryNameExists(name, null)) {
                request.setAttribute("error", "Tên danh mục đã tồn tại!");
                request.setAttribute("categoryName", name);
                request.setAttribute("description", desc);
                request.setAttribute("icon", icon);
                request.setAttribute("displayOrder", displayOrder);
                request.setAttribute("isActive", isActive);
                request.setAttribute("attributes", attributeDAO.getAllAttributes());
                request.getRequestDispatcher("/AdminLTE-3.2.0/admin-category-detail.jsp").forward(request, response);
                return;
            }
            
            entity.Category category = new entity.Category(0, name, desc, icon, displayOrder, isActive);
            boolean success = categoryDAO.insertCategory(category);
            
            if (success) {
                response.sendRedirect("categories?msg=add_success");
            } else {
                response.sendRedirect("categories?msg=add_fail");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("categories?msg=error");
        }
    }
    private void updateCategory(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("categoryID"));
            String name = request.getParameter("categoryName");
            String desc = request.getParameter("description");
            String icon = request.getParameter("icon");
            
            String displayOrderStr = request.getParameter("displayOrder");
            int displayOrder = (displayOrderStr != null && !displayOrderStr.isEmpty()) 
                              ? Integer.parseInt(displayOrderStr) : 0;
            
            boolean isActive = "on".equals(request.getParameter("isActive"));
            
            // Kiểm tra trùng tên danh mục (loại trừ chính nó)
            if (categoryDAO.isCategoryNameExists(name, id)) {
                entity.Category category = new entity.Category(id, name, desc, icon, displayOrder, isActive);
                request.setAttribute("error", "Tên danh mục đã tồn tại!");
                request.setAttribute("category", category);
                request.setAttribute("attributes", attributeDAO.getAllAttributes());
                request.setAttribute("categoryAttributes", categoryDAO.getCategoryAttributes(id));
                request.getRequestDispatcher("/AdminLTE-3.2.0/admin-category-detail.jsp").forward(request, response);
                return;
            }
            
            entity.Category category = new entity.Category(id, name, desc, icon, displayOrder, isActive);
            boolean success = categoryDAO.updateCategory(category);
            
            if (success) {
                response.sendRedirect("categories?msg=update_success");
            } else {
                response.sendRedirect("categories?msg=update_fail");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("categories?msg=error");
        }
    }
    
    private void deleteCategory(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        boolean success = categoryDAO.deleteCategory(id);
        
        if (success) {
            response.sendRedirect("categories?msg=delete_success");
        } else {
            response.sendRedirect("categories?msg=delete_fail");
        }
    }

    @Override
    public String getServletInfo() {
        return "Category Management Controller";
    }
}
