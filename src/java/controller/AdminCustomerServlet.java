package controller;

import DAO.CustomerDAO;
import entity.Customer;
import entity.Employee;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "AdminCustomerServlet", urlPatterns = {"/admin/customers"})
public class AdminCustomerServlet extends HttpServlet {
    
    private static final int PAGE_SIZE = 10;
    private CustomerDAO customerDAO = new CustomerDAO();
    
    /**
     * Kiểm tra quyền Admin
     * @param request HTTP request
     * @param response HTTP response
     * @return true nếu là Admin, false nếu không
     * @throws IOException nếu có lỗi khi redirect
     */
    private boolean checkAdminAuth(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        if (employee == null || !"Admin".equalsIgnoreCase(employee.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        return true;
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkAdminAuth(request, response)) {
            return;
        }
        
        HttpSession session = request.getSession();
        
        String action = request.getParameter("action");
        String idParam = request.getParameter("id");
        
        if ("create".equals(action)) {
            // Form tạo mới
            request.setAttribute("formMode", "create");
            request.setAttribute("pageTitle", "Thêm Khách hàng mới");
            request.getRequestDispatcher("/AdminLTE-3.2.0/customers/form.jsp")
                    .forward(request, response);
        } else if ("detail".equals(action) && idParam != null) {
            // Xem chi tiết 
            int customerID = Integer.parseInt(idParam);
            Customer customer = customerDAO.getCustomerById(customerID);
            if (customer == null) {
                session.setAttribute("message", "Không tìm thấy khách hàng!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/customers");
                return;
            }
            request.setAttribute("customer", customer);
            request.setAttribute("pageTitle", "Chi tiết Khách hàng");
            request.getRequestDispatcher("/AdminLTE-3.2.0/customers/detail.jsp")
                    .forward(request, response);
        } else if ("edit".equals(action) && idParam != null) {
            // Form chỉnh sửa
            int customerID = Integer.parseInt(idParam);
            Customer customer = customerDAO.getCustomerById(customerID);
            if (customer == null) {
                session.setAttribute("message", "Không tìm thấy khách hàng!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/customers");
                return;
            }
            request.setAttribute("customer", customer);
            request.setAttribute("formMode", "edit");
            request.setAttribute("pageTitle", "Chỉnh sửa Khách hàng");
            request.getRequestDispatcher("/AdminLTE-3.2.0/customers/form.jsp")
                    .forward(request, response);
        } else {
            // Danh sách khách hàng
            String search = request.getParameter("search");
            String statusParam = request.getParameter("status");
            String emailVerifiedParam = request.getParameter("emailVerified");
            Boolean isActive = null;
            Boolean isEmailVerified = null;
            
            if ("active".equals(statusParam)) {
                isActive = true;
            } else if ("locked".equals(statusParam)) {
                isActive = false;
            }
            
            if ("verified".equals(emailVerifiedParam)) {
                isEmailVerified = true;
            } else if ("unverified".equals(emailVerifiedParam)) {
                isEmailVerified = false;
            }
            
            int page = 1;
            try {
                page = Integer.parseInt(request.getParameter("page"));
            } catch (NumberFormatException e) {
                // Default page 1
            }
            int pageSize = PAGE_SIZE;
            
            // Lấy dữ liệu
            var customers = customerDAO.getAllCustomers(search, isActive, isEmailVerified, page, pageSize);
            int total = customerDAO.getTotalCustomers(search, isActive, isEmailVerified);
            int[] stats = customerDAO.getCustomerStats();
            
            request.setAttribute("customers", customers);
            request.setAttribute("total", total);
            int totalPages = (int) Math.ceil((double) total / pageSize);
            request.setAttribute("totalPages", totalPages > 0 ? totalPages : 1);
            request.setAttribute("currentPage", page);
            request.setAttribute("search", search);
            request.setAttribute("status", statusParam);
            request.setAttribute("emailVerified", emailVerifiedParam);
            request.setAttribute("stats", stats);
            request.setAttribute("pageTitle", "Quản lý Khách hàng");
            
            request.getRequestDispatcher("/AdminLTE-3.2.0/customers/list.jsp")
                    .forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkAdminAuth(request, response)) {
            return;
        }
        
        HttpSession session = request.getSession();
        String action = request.getParameter("action");
        
        if ("create".equals(action)) {
            // Tạo mới khách hàng
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String confirmPassword = request.getParameter("confirmPassword");
            String phone = request.getParameter("phone");
            String emailVerificationStatus = request.getParameter("emailVerificationStatus");
            boolean isEmailVerified = "true".equals(emailVerificationStatus);
            
            // Validation
            if (fullName == null || fullName.trim().isEmpty()) {
                session.setAttribute("message", "Họ tên không được để trống!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/customers?action=create");
                return;
            }
            
            // Validate họ tên: chỉ được chứa chữ cái, số và khoảng trắng, phải có ít nhất 1 chữ cái
            String fullNameTrimmed = fullName.trim();
            if (!fullNameTrimmed.matches("^[a-zA-ZÀ-ỹ0-9\\s]+$") || !fullNameTrimmed.matches(".*[a-zA-ZÀ-ỹ].*")) {
                session.setAttribute("message", "Họ tên không hợp lệ! Họ tên chỉ được chứa chữ cái, số và khoảng trắng, không được có ký tự đặc biệt và phải có ít nhất 1 chữ cái.");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/customers?action=create");
                return;
            }
            
            if (email == null || email.trim().isEmpty()) {
                session.setAttribute("message", "Email không được để trống!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/customers?action=create");
                return;
            }
            
            // Validate format email: chuyển thành chữ thường, phần đầu không được là số, phải có @, đuôi .com hoặc .vn
            String emailTrimmed = email.trim().toLowerCase();
            if (!emailTrimmed.matches("^[a-zA-Z][a-zA-Z0-9._-]*@[a-zA-Z0-9.-]+\\.(com|vn)$")) {
                session.setAttribute("message", "Email không hợp lệ! Email phải bắt đầu bằng chữ cái, có @ và đuôi phải là .com hoặc .vn (Ví dụ: example@gmail.com)");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/customers?action=create");
                return;
            }
            
            // Kiểm tra email đã tồn tại chưa
            if (customerDAO.isEmailExists(emailTrimmed)) {
                session.setAttribute("message", "Email đã tồn tại!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/customers?action=create");
                return;
            }
            
            if (password == null || password.trim().isEmpty() || password.length() < 6) {
                session.setAttribute("message", "Mật khẩu phải có ít nhất 6 ký tự!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/customers?action=create");
                return;
            }
            
            if (!password.equals(confirmPassword)) {
                session.setAttribute("message", "Mật khẩu xác nhận không khớp!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/customers?action=create");
                return;
            }
            
            // Validate số điện thoại: bắt buộc, chỉ chứa số, không có space, không có ký tự đặc biệt
            if (phone == null || phone.trim().isEmpty()) {
                session.setAttribute("message", "Số điện thoại không được để trống!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/customers?action=create");
                return;
            }
            
            String phoneTrimmed = phone.trim();
            if (!phoneTrimmed.matches("^[0-9]+$")) {
                session.setAttribute("message", "Số điện thoại không hợp lệ! Số điện thoại chỉ được chứa số, không được có chữ, khoảng trắng hoặc ký tự đặc biệt.");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/customers?action=create");
                return;
            }
            
            if (!phoneTrimmed.matches("^0[0-9]{9,10}$")) {
                session.setAttribute("message", "Số điện thoại không hợp lệ! Số điện thoại phải có 10-11 số và bắt đầu bằng 0 (Ví dụ: 0912345678)");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/customers?action=create");
                return;
            }
            
            boolean success = customerDAO.createCustomer(fullNameTrimmed, emailTrimmed, password, phoneTrimmed, isEmailVerified);
            
            if (success) {
                session.setAttribute("message", "Tạo khách hàng mới thành công!");
                session.setAttribute("messageType", "success");
                response.sendRedirect(request.getContextPath() + "/admin/customers");
            } else {
                session.setAttribute("message", "Có lỗi xảy ra khi tạo khách hàng!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/customers?action=create");
            }
            
        } else if ("update".equals(action)) {
            // Cập nhật thông tin (không bao gồm mật khẩu - admin không có quyền sửa mật khẩu khách hàng)
            int customerID = Integer.parseInt(request.getParameter("customerID"));
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");
            String emailVerificationStatus = request.getParameter("emailVerificationStatus");
            boolean isEmailVerified = "true".equals(emailVerificationStatus);
            
            // Validation
            if (fullName == null || fullName.trim().isEmpty()) {
                session.setAttribute("message", "Họ tên không được để trống!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/customers?action=edit&id=" + customerID);
                return;
            }
            
            // Validate họ tên: chỉ được chứa chữ cái, số và khoảng trắng, phải có ít nhất 1 chữ cái
            String fullNameTrimmed = fullName.trim();
            // Regex: chỉ cho phép chữ cái (a-zA-ZÀ-ỹ), số (0-9), khoảng trắng, và phải có ít nhất 1 chữ cái
            if (!fullNameTrimmed.matches("^[a-zA-ZÀ-ỹ0-9\\s]+$") || !fullNameTrimmed.matches(".*[a-zA-ZÀ-ỹ].*")) {
                session.setAttribute("message", "Họ tên không hợp lệ! Họ tên chỉ được chứa chữ cái, số và khoảng trắng, không được có ký tự đặc biệt và phải có ít nhất 1 chữ cái.");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/customers?action=edit&id=" + customerID);
                return;
            }
            
            // Validate số điện thoại: bắt buộc, chỉ chứa số, không có space, không có ký tự đặc biệt
            if (phone == null || phone.trim().isEmpty()) {
                session.setAttribute("message", "Số điện thoại không được để trống!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/customers?action=edit&id=" + customerID);
                return;
            }
            
            String phoneTrimmed = phone.trim();
            // Kiểm tra: chỉ chứa số, không có chữ, không có space, không có ký tự đặc biệt
            if (!phoneTrimmed.matches("^[0-9]+$")) {
                session.setAttribute("message", "Số điện thoại không hợp lệ! Số điện thoại chỉ được chứa số, không được có chữ, khoảng trắng hoặc ký tự đặc biệt.");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/customers?action=edit&id=" + customerID);
                return;
            }
            
            // Kiểm tra format số điện thoại VN: 10-11 số, bắt đầu bằng 0
            if (!phoneTrimmed.matches("^0[0-9]{9,10}$")) {
                session.setAttribute("message", "Số điện thoại không hợp lệ! Số điện thoại phải có 10-11 số và bắt đầu bằng 0 (Ví dụ: 0912345678)");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/customers?action=edit&id=" + customerID);
                return;
            }
            
            boolean success = customerDAO.updateCustomer(customerID, fullName.trim(), phoneTrimmed, isEmailVerified);
            
            if (success) {
                session.setAttribute("message", "Cập nhật thông tin khách hàng thành công!");
                session.setAttribute("messageType", "success");
                // Redirect về danh sách khách hàng sau khi cập nhật thành công
                response.sendRedirect(request.getContextPath() + "/admin/customers");
            } else {
                session.setAttribute("message", "Có lỗi xảy ra khi cập nhật!");
                session.setAttribute("messageType", "danger");
                // Nếu lỗi thì quay lại trang edit
                response.sendRedirect(request.getContextPath() + "/admin/customers?action=edit&id=" + customerID);
            }
            
        } else if ("toggleActive".equals(action)) {
            // Khóa/Mở khóa
            int customerID = Integer.parseInt(request.getParameter("customerID"));
            boolean isActive = "true".equals(request.getParameter("isActive"));
            
            boolean success = customerDAO.setCustomerActiveStatus(customerID, !isActive);
            
            if (success) {
                session.setAttribute("message", isActive ? "Đã khóa tài khoản!" : "Đã mở khóa tài khoản!");
                session.setAttribute("messageType", "success");
            } else {
                session.setAttribute("message", "Có lỗi xảy ra!");
                session.setAttribute("messageType", "danger");
            }
            
            response.sendRedirect(request.getContextPath() + "/admin/customers");
        }
    }
}