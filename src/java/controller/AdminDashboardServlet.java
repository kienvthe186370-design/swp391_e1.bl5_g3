package controller;

import DAO.ProductDAO;
import entity.Employee;
import java.io.IOException;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        productDAO = new ProductDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");

        if (employee != null) {

            Map<String, Integer> statusCounts = productDAO.getProductStatusCounts();
            request.setAttribute("statusCounts", statusCounts);
            request.setAttribute("contentPage", "dashboard");
            request.setAttribute("activePage", "dashboard");
            request.setAttribute("pageTitle", "Dashboard");
            request.getRequestDispatcher("/AdminLTE-3.2.0/index.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/login");
        }
    }
}
