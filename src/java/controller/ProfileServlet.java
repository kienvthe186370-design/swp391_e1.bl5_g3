package controller;

import entity.Customer;
import entity.CustomerAddress;
import DAO.CustomerAddressDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
public class ProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        
        // Check login
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?redirect=profile");
            return;
        }
        
        // Get addresses
        CustomerAddressDAO addressDAO = new CustomerAddressDAO();
        List<CustomerAddress> addresses = addressDAO.getAddressesByCustomerId(customer.getCustomerID());
        request.setAttribute("addresses", addresses);
        request.setAttribute("customer", customer);
        
        // Get active tab
        String tab = request.getParameter("tab");
        if (tab == null) tab = "profile";
        request.setAttribute("activeTab", tab);
        
        // Pass redirect parameter to JSP for address form
        String redirect = request.getParameter("redirect");
        if (redirect != null && !redirect.isEmpty()) {
            request.setAttribute("redirect", redirect);
        }
        
        // Forward to profile page
        request.getRequestDispatcher("/customer/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
