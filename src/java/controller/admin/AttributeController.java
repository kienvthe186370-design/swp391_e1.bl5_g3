/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

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
@WebServlet(name="AttributeController", urlPatterns={"/admin/attributes"})
public class AttributeController extends HttpServlet {
   
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
                deleteAttribute(request, response);
                break;
            case "values":
                manageValues(request, response);
                break;
            case "deleteValue":
                deleteValue(request, response);
                break;
            case "categories":
                manageCategories(request, response);
                break;
            case "removeCategory":
                removeCategory(request, response);
                break;
            default:
                listAttributes(request, response);
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
            addAttribute(request, response);
        } else if ("edit".equals(action)) {
            updateAttribute(request, response);
        } else if ("addValue".equals(action)) {
            addValue(request, response);
        } else if ("assignCategory".equals(action)) {
            assignCategory(request, response);
        } else if ("removeCategory".equals(action)) {
            removeCategory(request, response);
        }
    }
    
    private void listAttributes(HttpServletRequest request, HttpServletResponse response)
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
        java.util.List<entity.ProductAttribute> attributes = attributeDAO.getAttributes(search, isActive, sortBy, sortOrder, page, pageSize);
        int totalRecords = attributeDAO.getTotalAttributes(search, isActive);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
        
        // Set attributes
        request.setAttribute("attributes", attributes);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("search", search);
        request.setAttribute("status", statusParam);
        request.setAttribute("sortBy", sortBy);
        request.setAttribute("sortOrder", sortOrder);
        
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-attribute-list.jsp").forward(request, response);
    }
    
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-attribute-detail.jsp").forward(request, response);
    }
    
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        entity.ProductAttribute attr = attributeDAO.getAttributeByID(id);
        request.setAttribute("attribute", attr);
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-attribute-detail.jsp").forward(request, response);
    }
    
    private void addAttribute(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        try {
            String name = request.getParameter("attributeName");
            boolean isActive = "on".equals(request.getParameter("isActive"));
            
            // Validate required fields
            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("error", "Vui lòng nhập tên thuộc tính!");
                forwardToAttributeForm(request, response, null, name, isActive);
                return;
            }
            
            if (name.trim().length() < 2) {
                request.setAttribute("error", "Tên thuộc tính phải có ít nhất 2 ký tự!");
                forwardToAttributeForm(request, response, null, name, isActive);
                return;
            }
            
            // Check duplicate name
            if (attributeDAO.isAttributeNameExists(name.trim(), null)) {
                request.setAttribute("error", "Tên thuộc tính đã tồn tại!");
                forwardToAttributeForm(request, response, null, name, isActive);
                return;
            }
            
            entity.ProductAttribute attr = new entity.ProductAttribute(0, name.trim(), isActive);
            boolean success = attributeDAO.insertAttribute(attr);
            
            if (success) {
                response.sendRedirect("attributes?msg=add_success");
            } else {
                response.sendRedirect("attributes?msg=add_fail");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("attributes?msg=error");
        }
    }
    
    private void updateAttribute(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("attributeID"));
            String name = request.getParameter("attributeName");
            boolean isActive = "on".equals(request.getParameter("isActive"));
            
            // Validate required fields
            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("error", "Vui lòng nhập tên thuộc tính!");
                forwardToAttributeForm(request, response, id, name, isActive);
                return;
            }
            
            if (name.trim().length() < 2) {
                request.setAttribute("error", "Tên thuộc tính phải có ít nhất 2 ký tự!");
                forwardToAttributeForm(request, response, id, name, isActive);
                return;
            }
            
            // Check duplicate name (exclude current attribute)
            if (attributeDAO.isAttributeNameExists(name.trim(), id)) {
                request.setAttribute("error", "Tên thuộc tính đã tồn tại!");
                forwardToAttributeForm(request, response, id, name, isActive);
                return;
            }
            
            entity.ProductAttribute attr = new entity.ProductAttribute(id, name.trim(), isActive);
            boolean success = attributeDAO.updateAttribute(attr);
            
            if (success) {
                response.sendRedirect("attributes?msg=update_success");
            } else {
                response.sendRedirect("attributes?msg=update_fail");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("attributes?msg=error");
        }
    }
    
    private void forwardToAttributeForm(HttpServletRequest request, HttpServletResponse response, 
                                        Integer id, String name, boolean isActive)
    throws ServletException, IOException {
        if (id != null) {
            entity.ProductAttribute attr = new entity.ProductAttribute(id, name, isActive);
            request.setAttribute("attribute", attr);
        } else {
            request.setAttribute("attributeName", name);
            request.setAttribute("isActive", isActive);
        }
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-attribute-detail.jsp").forward(request, response);
    }
    
    private void deleteAttribute(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        boolean success = attributeDAO.deleteAttribute(id);
        
        if (success) {
            response.sendRedirect("attributes?msg=delete_success");
        } else {
            response.sendRedirect("attributes?msg=delete_fail");
        }
    }
    
    private void manageValues(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        int attrId = Integer.parseInt(request.getParameter("id"));
        entity.ProductAttribute attr = attributeDAO.getAttributeByID(attrId);
        request.setAttribute("attribute", attr);
        request.setAttribute("values", attributeDAO.getValuesByAttributeID(attrId));
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-attribute-values.jsp").forward(request, response);
    }
    
    private void addValue(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        try {
            int attrId = Integer.parseInt(request.getParameter("attributeID"));
            String valueName = request.getParameter("valueName");
            boolean isActive = "on".equals(request.getParameter("isActive"));
            
            // Validate required fields
            if (valueName == null || valueName.trim().isEmpty()) {
                request.setAttribute("error", "Vui lòng nhập tên giá trị!");
                forwardToValuesPage(request, response, attrId);
                return;
            }
            
            // Check duplicate value name for this attribute
            if (attributeDAO.isAttributeValueExists(valueName.trim(), attrId, null)) {
                request.setAttribute("error", "Giá trị này đã tồn tại cho thuộc tính này!");
                forwardToValuesPage(request, response, attrId);
                return;
            }
            
            entity.AttributeValue value = new entity.AttributeValue(0, attrId, valueName.trim(), isActive);
            boolean success = attributeDAO.insertAttributeValue(value);
            
            if (success) {
                response.sendRedirect("attributes?action=values&id=" + attrId + "&msg=add_success");
            } else {
                response.sendRedirect("attributes?action=values&id=" + attrId + "&msg=add_fail");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("attributes?msg=error");
        }
    }
    
    private void forwardToValuesPage(HttpServletRequest request, HttpServletResponse response, int attrId)
    throws ServletException, IOException {
        entity.ProductAttribute attr = attributeDAO.getAttributeByID(attrId);
        request.setAttribute("attribute", attr);
        request.setAttribute("values", attributeDAO.getValuesByAttributeID(attrId));
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-attribute-values.jsp").forward(request, response);
    }
    
    private void deleteValue(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        int valueId = Integer.parseInt(request.getParameter("valueId"));
        int attrId = Integer.parseInt(request.getParameter("attrId"));
        boolean success = attributeDAO.deleteAttributeValue(valueId);
        
        if (success) {
            response.sendRedirect("attributes?action=values&id=" + attrId + "&msg=delete_success");
        } else {
            response.sendRedirect("attributes?action=values&id=" + attrId + "&msg=delete_fail");
        }
    }
    
    private void manageCategories(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        int attrId = Integer.parseInt(request.getParameter("id"));
        entity.ProductAttribute attr = attributeDAO.getAttributeByID(attrId);
        
        // Get all categories
        DAO.CategoryDAO categoryDAO = new DAO.CategoryDAO();
        java.util.List<entity.Category> allCategories = categoryDAO.getAllCategories();
        
        // Get categories already assigned to this attribute
        java.util.List<entity.CategoryAttribute> assignedCategories = categoryDAO.getCategoryAttributesByAttribute(attrId);
        
        request.setAttribute("attribute", attr);
        request.setAttribute("allCategories", allCategories);
        request.setAttribute("assignedCategories", assignedCategories);
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-attribute-categories.jsp").forward(request, response);
    }
    
    private void assignCategory(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        try {
            int attributeID = Integer.parseInt(request.getParameter("attributeID"));
            int categoryID = Integer.parseInt(request.getParameter("categoryID"));
            boolean isRequired = "on".equals(request.getParameter("isRequired"));
            int displayOrder = Integer.parseInt(request.getParameter("displayOrder"));
            
            DAO.CategoryDAO categoryDAO = new DAO.CategoryDAO();
            entity.CategoryAttribute ca = new entity.CategoryAttribute(0, categoryID, attributeID, isRequired, displayOrder);
            boolean success = categoryDAO.addCategoryAttribute(ca);
            
            if (success) {
                response.sendRedirect("attributes?action=categories&id=" + attributeID + "&msg=assign_success");
            } else {
                response.sendRedirect("attributes?action=categories&id=" + attributeID + "&msg=assign_fail");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("attributes?msg=error");
        }
    }
    
    private void removeCategory(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        int attributeID = Integer.parseInt(request.getParameter("attributeID"));
        int categoryID = Integer.parseInt(request.getParameter("categoryID"));
        
        DAO.CategoryDAO categoryDAO = new DAO.CategoryDAO();
        boolean success = categoryDAO.removeCategoryAttribute(categoryID, attributeID);
        
        if (success) {
            response.sendRedirect("attributes?action=categories&id=" + attributeID + "&msg=remove_success");
        } else {
            response.sendRedirect("attributes?action=categories&id=" + attributeID + "&msg=remove_fail");
        }
    }

    @Override
    public String getServletInfo() {
        return "Attribute Management Controller";
    }
}
