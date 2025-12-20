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
@WebServlet(name="BrandController", urlPatterns={"/admin/brands"})
public class BrandController extends HttpServlet {
   
    private DAO.BrandDAO brandDAO = new DAO.BrandDAO();
    
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
                deleteBrand(request, response);
                break;
            default:
                listBrands(request, response);
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
            addBrand(request, response);
        } else if ("edit".equals(action)) {
            updateBrand(request, response);
        }
    }
    
    private void listBrands(HttpServletRequest request, HttpServletResponse response)
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
        java.util.List<entity.Brand> brands = brandDAO.getBrands(search, isActive, sortBy, sortOrder, page, pageSize);
        int totalRecords = brandDAO.getTotalBrands(search, isActive);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
        
        // Set attributes
        request.setAttribute("brands", brands);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("search", search);
        request.setAttribute("status", statusParam);
        request.setAttribute("sortBy", sortBy);
        request.setAttribute("sortOrder", sortOrder);
        
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-brand-list.jsp").forward(request, response);
    }
    
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-brand-detail.jsp").forward(request, response);
    }
    
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        entity.Brand brand = brandDAO.getBrandByID(id);
        request.setAttribute("brand", brand);
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-brand-detail.jsp").forward(request, response);
    }
    
    private void addBrand(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        try {
            String name = request.getParameter("brandName");
            String logo = request.getParameter("logo");
            String desc = request.getParameter("description");
            boolean isActive = "on".equals(request.getParameter("isActive"));
            
            // Validate required fields
            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("error", "Vui lòng nhập tên thương hiệu!");
                forwardToForm(request, response, null, name, logo, desc, isActive);
                return;
            }
            
            if (name.trim().length() < 2) {
                request.setAttribute("error", "Tên thương hiệu phải có ít nhất 2 ký tự!");
                forwardToForm(request, response, null, name, logo, desc, isActive);
                return;
            }
            
            // Check duplicate name
            if (brandDAO.isBrandNameExists(name.trim(), null)) {
                request.setAttribute("error", "Tên thương hiệu đã tồn tại!");
                forwardToForm(request, response, null, name, logo, desc, isActive);
                return;
            }
            
            entity.Brand brand = new entity.Brand(0, name.trim(), logo, desc, isActive);
            boolean success = brandDAO.insertBrand(brand);
            
            if (success) {
                response.sendRedirect("brands?msg=add_success");
            } else {
                response.sendRedirect("brands?msg=add_fail");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("brands?msg=error");
        }
    }
    
    private void updateBrand(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("brandID"));
            String name = request.getParameter("brandName");
            String logo = request.getParameter("logo");
            String desc = request.getParameter("description");
            boolean isActive = "on".equals(request.getParameter("isActive"));
            
            // Validate required fields
            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("error", "Vui lòng nhập tên thương hiệu!");
                forwardToForm(request, response, id, name, logo, desc, isActive);
                return;
            }
            
            if (name.trim().length() < 2) {
                request.setAttribute("error", "Tên thương hiệu phải có ít nhất 2 ký tự!");
                forwardToForm(request, response, id, name, logo, desc, isActive);
                return;
            }
            
            // Check duplicate name (exclude current brand)
            if (brandDAO.isBrandNameExists(name.trim(), id)) {
                request.setAttribute("error", "Tên thương hiệu đã tồn tại!");
                forwardToForm(request, response, id, name, logo, desc, isActive);
                return;
            }
            
            entity.Brand brand = new entity.Brand(id, name.trim(), logo, desc, isActive);
            boolean success = brandDAO.updateBrand(brand);
            
            if (success) {
                response.sendRedirect("brands?msg=update_success");
            } else {
                response.sendRedirect("brands?msg=update_fail");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("brands?msg=error");
        }
    }
    
    private void forwardToForm(HttpServletRequest request, HttpServletResponse response, 
                               Integer id, String name, String logo, String desc, boolean isActive)
    throws ServletException, IOException {
        if (id != null) {
            entity.Brand brand = new entity.Brand(id, name, logo, desc, isActive);
            request.setAttribute("brand", brand);
        } else {
            request.setAttribute("brandName", name);
            request.setAttribute("logo", logo);
            request.setAttribute("description", desc);
            request.setAttribute("isActive", isActive);
        }
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-brand-detail.jsp").forward(request, response);
    }
    
    private void deleteBrand(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        boolean success = brandDAO.deleteBrand(id);
        
        if (success) {
            response.sendRedirect("brands?msg=delete_success");
        } else {
            response.sendRedirect("brands?msg=delete_fail");
        }
    }

    @Override
    public String getServletInfo() {
        return "Brand Management Controller";
    }
}
