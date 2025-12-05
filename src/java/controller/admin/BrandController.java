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
        request.setAttribute("brands", brandDAO.getAllBrands());
        request.getRequestDispatcher("/admin/brands.jsp").forward(request, response);
    }
    
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        request.getRequestDispatcher("/admin/brand-form.jsp").forward(request, response);
    }
    
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        entity.Brand brand = brandDAO.getBrandByID(id);
        request.setAttribute("brand", brand);
        request.getRequestDispatcher("/admin/brand-form.jsp").forward(request, response);
    }
    
   
}
