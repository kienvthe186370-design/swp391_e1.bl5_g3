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
        request.setAttribute("categories", categoryDAO.getAllCategories());
        request.getRequestDispatcher("/admin/categories.jsp").forward(request, response);
    }
    
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        request.setAttribute("attributes", attributeDAO.getAllAttributes());
        request.getRequestDispatcher("/admin/category-form.jsp").forward(request, response);
    }
    
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        entity.Category category = categoryDAO.getCategoryByID(id);
        request.setAttribute("category", category);
        request.setAttribute("attributes", attributeDAO.getAllAttributes());
        request.setAttribute("categoryAttributes", categoryDAO.getCategoryAttributes(id));
        request.getRequestDispatcher("/admin/category-form.jsp").forward(request, response);
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
}
