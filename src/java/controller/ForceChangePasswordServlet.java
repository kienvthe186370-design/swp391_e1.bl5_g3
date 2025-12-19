package controller;

import DAO.CustomerDAO;
import DAO.EmployeeDAO;
import entity.Customer;
import entity.Employee;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "ForceChangePasswordServlet", urlPatterns = {"/force-change-password"})
public class ForceChangePasswordServlet extends HttpServlet {

    private final EmployeeDAO employeeDAO = new EmployeeDAO();
    private final CustomerDAO customerDAO = new CustomerDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        // Kiểm tra xem có pending password change không
        if (session == null || session.getAttribute("pendingPasswordChange") == null) {
            response.sendRedirect("login");
            return;
        }
        
        request.getRequestDispatcher("force-change-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        // Kiểm tra xem có pending password change không
        if (session == null || session.getAttribute("pendingPasswordChange") == null) {
            response.sendRedirect("login");
            return;
        }
        
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        String userType = (String) session.getAttribute("pendingUserType");
        
        // Validation
        if (newPassword == null || newPassword.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập mật khẩu mới!");
            request.getRequestDispatcher("force-change-password.jsp").forward(request, response);
            return;
        }
        
        if (newPassword.length() < 6) {
            request.setAttribute("error", "Mật khẩu phải có ít nhất 6 ký tự!");
            request.getRequestDispatcher("force-change-password.jsp").forward(request, response);
            return;
        }
        
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp!");
            request.getRequestDispatcher("force-change-password.jsp").forward(request, response);
            return;
        }
        
        boolean success = false;
        
        if ("employee".equals(userType)) {
            Integer employeeID = (Integer) session.getAttribute("pendingEmployeeID");
            if (employeeID != null) {
                success = employeeDAO.updatePasswordAndClearMustChange(employeeID, newPassword);
                
                if (success) {
                    // Lấy thông tin employee và đăng nhập
                    Employee employee = employeeDAO.getEmployeeById(employeeID);
                    if (employee != null) {
                        // Xóa các session pending
                        session.removeAttribute("pendingPasswordChange");
                        session.removeAttribute("pendingEmployeeID");
                        session.removeAttribute("pendingUserType");
                        
                        // Đăng nhập
                        session.setAttribute("employee", employee);
                        session.setAttribute("userID", employee.getEmployeeID());
                        session.setAttribute("userName", employee.getFullName());
                        session.setAttribute("userRole", employee.getRole());
                        session.setAttribute("userType", "employee");
                        
                        response.sendRedirect("admin/dashboard");
                        return;
                    }
                }
            }
        } else if ("customer".equals(userType)) {
            Integer customerID = (Integer) session.getAttribute("pendingCustomerID");
            if (customerID != null) {
                success = customerDAO.updatePasswordAndClearMustChange(customerID, newPassword);
                
                if (success) {
                    // Lấy thông tin customer và đăng nhập
                    Customer customer = customerDAO.getCustomerById(customerID);
                    if (customer != null) {
                        // Xóa các session pending
                        session.removeAttribute("pendingPasswordChange");
                        session.removeAttribute("pendingCustomerID");
                        session.removeAttribute("pendingUserType");
                        
                        // Đăng nhập
                        session.setAttribute("customer", customer);
                        session.setAttribute("userID", customer.getCustomerID());
                        session.setAttribute("userName", customer.getFullName());
                        session.setAttribute("userType", "customer");
                        
                        // Load cart
                        try {
                            DAO.CartDAO cartDAO = new DAO.CartDAO();
                            entity.Cart cart = cartDAO.getOrCreateCart(customer.getCustomerID());
                            if (cart != null) {
                                session.setAttribute("cartCount", cart.getTotalItems());
                                session.setAttribute("cartTotal", cart.getSubtotal());
                            } else {
                                session.setAttribute("cartCount", 0);
                                session.setAttribute("cartTotal", java.math.BigDecimal.ZERO);
                            }
                        } catch (Exception e) {
                            session.setAttribute("cartCount", 0);
                            session.setAttribute("cartTotal", java.math.BigDecimal.ZERO);
                        }
                        
                        response.sendRedirect("customer/home");
                        return;
                    }
                }
            }
        }
        
        // Nếu có lỗi
        request.setAttribute("error", "Có lỗi xảy ra khi đổi mật khẩu. Vui lòng thử lại!");
        request.getRequestDispatcher("force-change-password.jsp").forward(request, response);
    }
}
