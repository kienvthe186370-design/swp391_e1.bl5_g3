/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import DAO.SliderDAO;
import entity.Slider;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;

/**
 *
 * @author xuand
 */
@WebServlet(name="Home", urlPatterns={"/Home"})
public class HomeServlet extends HttpServlet {
   
    /** 
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet HomeServlet</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet HomeServlet at " + request.getContextPath () + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    } 

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /** 
     * Handles the HTTP <code>GET</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            System.out.println("🏠 HomeServlet: Loading homepage data...");
            
            // 1. Load Sliders
            SliderDAO sliderDAO = new SliderDAO();
            List<Slider> sliders = sliderDAO.getTop5Sliders();
            request.setAttribute("sliders", sliders);
            System.out.println("✅ Loaded " + (sliders != null ? sliders.size() : 0) + " sliders");
            
            // 2. Load Featured Products (12 sản phẩm mới nhất)
            DAO.ProductDAO productDAO = new DAO.ProductDAO();
            List<dto.ProductListDTO> featuredProducts = productDAO.getProducts(
                null, null, null, true, "date", "desc", 1, 12
            );
            request.setAttribute("featuredProducts", featuredProducts);
            System.out.println("✅ Loaded " + (featuredProducts != null ? featuredProducts.size() : 0) + " products");
            
            // 3. Load Categories cho menu
            DAO.CategoryDAO categoryDAO = new DAO.CategoryDAO();
            List<entity.Category> categories = categoryDAO.getAllCategories();
            request.setAttribute("categories", categories);
            System.out.println("✅ Loaded " + (categories != null ? categories.size() : 0) + " categories");
            
            // 4. Load Latest Blogs (3 bài mới nhất)
            try {
                DAO.BlogPostDAO blogDAO = new DAO.BlogPostDAO();
                List<entity.BlogPost> latestBlogs = blogDAO.search(null, "published");
                // Lấy 3 bài đầu
                if (latestBlogs != null && latestBlogs.size() > 3) {
                    latestBlogs = latestBlogs.subList(0, 3);
                }
                request.setAttribute("latestBlogs", latestBlogs);
            } catch (Exception blogEx) {
                System.err.println("⚠️ Warning: Cannot load blogs - " + blogEx.getMessage());
                request.setAttribute("latestBlogs", new java.util.ArrayList<>());
            }
            
            System.out.println("✅ HomeServlet: All data loaded successfully!");
            request.getRequestDispatcher("index.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("❌ Error in HomeServlet: " + e.getMessage());
            e.printStackTrace();
            
            // Set empty lists to prevent JSP errors
            request.setAttribute("sliders", new java.util.ArrayList<>());
            request.setAttribute("featuredProducts", new java.util.ArrayList<>());
            request.setAttribute("categories", new java.util.ArrayList<>());
            request.setAttribute("latestBlogs", new java.util.ArrayList<>());
            
            request.getRequestDispatcher("index.jsp").forward(request, response);
        }
    }

    /** 
     * Handles the HTTP <code>POST</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        processRequest(request, response);
    }

    /** 
     * Returns a short description of the servlet.
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
