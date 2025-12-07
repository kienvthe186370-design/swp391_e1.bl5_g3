package controller;

import DAO.CustomerDAO;
import DAO.EmployeeDAO;
import utils.ValidationUtil;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String phone = request.getParameter("phone");
        
        if (ValidationUtil.isEmpty(fullName) ||
            ValidationUtil.isEmpty(email) ||
            ValidationUtil.isEmpty(password) ||
            ValidationUtil.isEmpty(phone)) {
            
            setErrorAndForward(request, response, 
                "Vui lòng điền đầy đủ thông tin", 
                fullName, email, phone);
            return;
        }
        
        fullName = fullName.trim();
        email = email.trim();
        phone = phone.trim();
        
        if (!ValidationUtil.isValidName(fullName)) {
            setErrorAndForward(request, response, 
                "Tên không hợp lệ. Vui lòng chỉ nhập chữ cái", 
                fullName, email, phone);
            return;
        }
        
        if (!ValidationUtil.isValidEmail(email)) {
            setErrorAndForward(request, response, 
                "Email không đúng định dạng", 
                fullName, email, phone);
            return;
        }
        
        if (!ValidationUtil.isValidPhone(phone)) {
            setErrorAndForward(request, response, 
                "Số điện thoại không hợp lệ", 
                fullName, email, phone);
            return;
        }
        
        phone = ValidationUtil.normalizePhone(phone);
        
        String passwordError = ValidationUtil.getPasswordError(password);
        if (passwordError != null) {
            setErrorAndForward(request, response, 
                passwordError, 
                fullName, email, phone);
            return;
        }
        
        if (!password.equals(confirmPassword)) {
            setErrorAndForward(request, response, 
                "Mật khẩu xác nhận không khớp", 
                fullName, email, phone);
            return;
        }
        
        CustomerDAO customerDAO = new CustomerDAO();
        EmployeeDAO employeeDAO = new EmployeeDAO();
        
        if (customerDAO.isEmailExists(email) || employeeDAO.isEmailExists(email)) {
            setErrorAndForward(request, response, 
                "Email này đã được đăng ký. Vui lòng sử dụng email khác hoặc đăng nhập.", 
                fullName, "", phone);
            return;
        }
        
        boolean success = customerDAO.register(fullName, email, password, phone);
        
        if (success) {
            request.setAttribute("success", 
                "Đăng ký thành công! Vui lòng đăng nhập với email: " + email);
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } else {
            setErrorAndForward(request, response, 
                "Đăng ký thất bại. Vui lòng thử lại sau.", 
                fullName, email, phone);
        }
    }
    
    private void setErrorAndForward(HttpServletRequest request, 
                                    HttpServletResponse response,
                                    String errorMessage,
                                    String fullName,
                                    String email,
                                    String phone) 
            throws ServletException, IOException {
        
        request.setAttribute("error", errorMessage);
        request.setAttribute("fullName", fullName);
        request.setAttribute("email", email);
        request.setAttribute("phone", phone);
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }
}
