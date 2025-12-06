package controller;

import entity.Employee;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        
        if (employee != null && "Admin".equalsIgnoreCase(employee.getRole())) {
            // Set attributes for unified layout
            request.setAttribute("contentPage", "dashboard");
            request.setAttribute("activePage", "dashboard");
            request.setAttribute("pageTitle", "Dashboard");
            
            // Forward to unified AdminLTE layout
            request.getRequestDispatcher("/AdminLTE-3.2.0/index.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/login");
        }
    }
}
