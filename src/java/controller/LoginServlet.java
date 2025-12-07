package controller;

import DAO.CustomerDAO;
import DAO.EmployeeDAO;
import entity.Customer;
import entity.Employee;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Nếu đã đăng nhập, redirect về trang tương ứng
        HttpSession session = request.getSession(false);
        if (session != null) {
            if (session.getAttribute("customer") != null) {
                response.sendRedirect("customer/home");
                return;
            } else if (session.getAttribute("employee") != null) {
                Employee emp = (Employee) session.getAttribute("employee");
                response.sendRedirect(getRedirectUrlByRole(emp.getRole()));
                return;
            }
        }
        
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String userType = request.getParameter("userType"); // "customer" or "employee"
        
        if (email == null || email.trim().isEmpty() || 
            password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ email và mật khẩu");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }
        
        HttpSession session = request.getSession();
        
        // Mặc định thử đăng nhập Customer trước
        if (userType == null || userType.equals("customer")) {
            CustomerDAO customerDAO = new CustomerDAO();
            Customer customer = customerDAO.login(email, password);
            
            if (customer != null) {
                session.setAttribute("customer", customer);
                session.setAttribute("userID", customer.getCustomerID());
                session.setAttribute("userName", customer.getFullName());
                session.setAttribute("userType", "customer");
                
                response.sendRedirect("customer/home");
                return;
            }
        }
        
        // Nếu không phải customer, thử đăng nhập Employee
        EmployeeDAO employeeDAO = new EmployeeDAO();
        Employee employee = employeeDAO.login(email, password);
        
        if (employee != null) {
            session.setAttribute("employee", employee);
            session.setAttribute("userID", employee.getEmployeeID());
            session.setAttribute("userName", employee.getFullName());
            session.setAttribute("userRole", employee.getRole());
            session.setAttribute("userType", "employee");
            
            // Redirect dựa trên role
            String redirectUrl = getRedirectUrlByRole(employee.getRole());
            response.sendRedirect(redirectUrl);
        } else {
            request.setAttribute("error", "Email hoặc mật khẩu không đúng");
            request.setAttribute("email", email);
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
    
    private String getRedirectUrlByRole(String role) {
        switch (role.toLowerCase()) {
            case "admin":
                return "admin/dashboard";
            case "seller":
                return "seller/dashboard";
            case "sellermanager":
                return "seller-manager/dashboard";
            case "marketer":
                return "marketer/dashboard";
            case "staff":
                return "staff/dashboard";
            default:
                return "index.html";
        }
    }
}
