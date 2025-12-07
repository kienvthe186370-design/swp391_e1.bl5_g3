package controller;

import entity.Employee;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "SellerDashboardServlet", urlPatterns = {"/seller/dashboard"})
public class SellerDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        
        if (employee != null && "Seller".equalsIgnoreCase(employee.getRole())) {
            request.setAttribute("employee", employee);
            request.getRequestDispatcher("/seller/dashboard.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/login");
        }
    }
}
