package controller;

import DAO.CustomerDAO;
import DAO.EmployeeDAO;
import entity.Customer;
import entity.Employee;
import entity.OTPCode;
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
        String userType = request.getParameter("userType");

        if (email == null || email.trim().isEmpty()
                || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ email và mật khẩu");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession();
        if (userType == null || userType.equals("customer")) {
            CustomerDAO customerDAO = new CustomerDAO();
            
            // Kiểm tra tài khoản khách hàng bị khóa trước
            if (customerDAO.isAccountLocked(email)) {
                request.setAttribute("error", "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ quản trị viên.");
                request.setAttribute("email", email);
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }
            
            Customer customer = customerDAO.login(email, password);

            if (customer != null) {
                // Đây để kiểm tra email đã được xác thực chưa
                if (!customer.isEmailVerified()) {
                    // Tạo OTP mới và gửi email
                    OTPService otpService = new OTPService();
                    otpService.createAndSendOTP(email, OTPCode.TYPE_VERIFY_EMAIL);
                    // Lưu email vào session để verify
                    session.setAttribute("pendingEmail", email);
                    session.setAttribute("otpType", OTPCode.TYPE_VERIFY_EMAIL);
                    // Redirect đến trang verify OTP
                    response.sendRedirect("verify-otp");
                    return;
                }
                
                // Kiểm tra nếu cần đổi mật khẩu lần đầu
                if (customer.isMustChangePassword()) {
                    session.setAttribute("pendingPasswordChange", true);
                    session.setAttribute("pendingCustomerID", customer.getCustomerID());
                    session.setAttribute("pendingUserType", "customer");
                    response.sendRedirect("force-change-password");
                    return;
                }
                
                session.setAttribute("customer", customer);
                session.setAttribute("userID", customer.getCustomerID());
                session.setAttribute("userName", customer.getFullName());
                session.setAttribute("userType", "customer");
                
                // Load cart count for header display
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
                    System.err.println("⚠️ Error loading cart on login: " + e.getMessage());
                    session.setAttribute("cartCount", 0);
                    session.setAttribute("cartTotal", java.math.BigDecimal.ZERO);
                }

                response.sendRedirect("customer/home");
                return;
            }
        }

        EmployeeDAO employeeDAO = new EmployeeDAO();
        
        // Kiểm tra tài khoản bị khóa trước
        if (employeeDAO.isAccountLocked(email)) {
            request.setAttribute("error", "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ quản trị viên.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }
        
        Employee employee = employeeDAO.login(email, password);

        if (employee != null) {
            // Kiểm tra nếu cần đổi mật khẩu lần đầu
            if (employee.isMustChangePassword()) {
                session.setAttribute("pendingPasswordChange", true);
                session.setAttribute("pendingEmployeeID", employee.getEmployeeID());
                session.setAttribute("pendingUserType", "employee");
                response.sendRedirect("force-change-password");
                return;
            }
            
            session.setAttribute("employee", employee);
            session.setAttribute("userID", employee.getEmployeeID());
            session.setAttribute("userName", employee.getFullName());
            session.setAttribute("userRole", employee.getRole());
            session.setAttribute("userType", "employee");
            String redirectUrl = getRedirectUrlByRole(employee.getRole());
            response.sendRedirect(redirectUrl);
        } else {
            request.setAttribute("error", "Email hoặc mật khẩu không đúng");
            request.setAttribute("email", email);
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    private String getRedirectUrlByRole(String role) {
        // Tất cả employee đều vào admin/dashboard, phân quyền theo sidebar
        return "admin/dashboard";
    }
}
