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

@WebServlet(name = "SellerManagerCustomerServlet", urlPatterns = {"/seller-manager/customers"})
public class SellerManagerCustomerServlet extends HttpServlet {
    
    private static final int PAGE_SIZE = 5;
    private final CustomerDAO customerDAO = new CustomerDAO();
    
    /**
     * Kiểm tra quyền SellerManager
     */
    private boolean checkSellerManagerAuth(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        if (employee == null || !"SellerManager".equalsIgnoreCase(employee.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        return true;
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkSellerManagerAuth(request, response)) {
            return;
        }
        
        HttpSession session = request.getSession();
        
        String action = request.getParameter("action");
        String idParam = request.getParameter("id");
        String baseUrl = request.getContextPath() + "/seller-manager/customers";
        request.setAttribute("baseUrl", baseUrl);
        
        if ("create".equals(action)) {
            request.setAttribute("formMode", "create");
            request.setAttribute("pageTitle", "Thêm Khách hàng mới");
            request.getRequestDispatcher("/AdminLTE-3.2.0/customers/form.jsp")
                    .forward(request, response);
        } else if ("detail".equals(action) && idParam != null) {
            int customerID = Integer.parseInt(idParam);
            Customer customer = customerDAO.getCustomerById(customerID);
            if (customer == null) {
                session.setAttribute("message", "Không tìm thấy khách hàng!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(baseUrl);
                return;
            }
            request.setAttribute("customer", customer);
            request.setAttribute("pageTitle", "Chi tiết Khách hàng");
            request.getRequestDispatcher("/AdminLTE-3.2.0/customers/detail.jsp")
                    .forward(request, response);
        } else if ("edit".equals(action) && idParam != null) {
            int customerID = Integer.parseInt(idParam);
            Customer customer = customerDAO.getCustomerById(customerID);
            if (customer == null) {
                session.setAttribute("message", "Không tìm thấy khách hàng!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(baseUrl);
                return;
            }
            request.setAttribute("customer", customer);
            request.setAttribute("formMode", "edit");
            request.setAttribute("pageTitle", "Chỉnh sửa Khách hàng");
            request.getRequestDispatcher("/AdminLTE-3.2.0/customers/form.jsp")
                    .forward(request, response);
        } else {
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
                // giữ page = 1
            }
            int pageSize = PAGE_SIZE;
            
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
            request.setAttribute("pageSize", pageSize);
            
            request.getRequestDispatcher("/AdminLTE-3.2.0/customers/list.jsp")
                    .forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkSellerManagerAuth(request, response)) {
            return;
        }
        
        HttpSession session = request.getSession();
        String action = request.getParameter("action");
        String baseUrl = request.getContextPath() + "/seller-manager/customers";
        request.setAttribute("baseUrl", baseUrl);
        
        if ("create".equals(action)) {
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String phone = request.getParameter("phone");
            String emailVerificationStatus = request.getParameter("emailVerificationStatus");
            boolean isEmailVerified = "true".equals(emailVerificationStatus);
            Customer tempCustomer = new Customer();
            tempCustomer.setFullName(fullName);
            tempCustomer.setEmail(email);
            tempCustomer.setPhone(phone);
            tempCustomer.setEmailVerified(isEmailVerified);
            
            if (fullName == null || fullName.trim().isEmpty()) {
                request.setAttribute("message", "Họ tên không được để trống!");
                request.setAttribute("messageType", "danger");
                request.setAttribute("customer", tempCustomer);
                request.setAttribute("formMode", "create");
                request.setAttribute("pageTitle", "Thêm Khách hàng mới");
                request.getRequestDispatcher("/AdminLTE-3.2.0/customers/form.jsp").forward(request, response);
                return;
            }
            
            String fullNameTrimmed = fullName.trim();
            if (!fullNameTrimmed.matches("^[a-zA-ZÀ-ỹ0-9\\s]+$") || !fullNameTrimmed.matches(".*[a-zA-ZÀ-ỹ].*")) {
                request.setAttribute("message", "Họ tên không hợp lệ! Họ tên chỉ được chứa chữ cái, số và khoảng trắng, không được có ký tự đặc biệt và phải có ít nhất 1 chữ cái.");
                request.setAttribute("messageType", "danger");
                request.setAttribute("customer", tempCustomer);
                request.setAttribute("formMode", "create");
                request.setAttribute("pageTitle", "Thêm Khách hàng mới");
                request.getRequestDispatcher("/AdminLTE-3.2.0/customers/form.jsp").forward(request, response);
                return;
            }
            
            if (email == null || email.trim().isEmpty()) {
                request.setAttribute("message", "Email không được để trống!");
                request.setAttribute("messageType", "danger");
                request.setAttribute("customer", tempCustomer);
                request.setAttribute("formMode", "create");
                request.setAttribute("pageTitle", "Thêm Khách hàng mới");
                request.getRequestDispatcher("/AdminLTE-3.2.0/customers/form.jsp").forward(request, response);
                return;
            }
            
            String emailTrimmed = email.trim().toLowerCase();
            if (!emailTrimmed.matches("^[a-zA-Z][a-zA-Z0-9._-]*@[a-zA-Z0-9.-]+\\.(com|vn)$")) {
                request.setAttribute("message", "Email không hợp lệ! Email phải bắt đầu bằng chữ cái, có @ và đuôi phải là .com hoặc .vn (Ví dụ: example@gmail.com)");
                request.setAttribute("messageType", "danger");
                request.setAttribute("customer", tempCustomer);
                request.setAttribute("formMode", "create");
                request.setAttribute("pageTitle", "Thêm Khách hàng mới");
                request.getRequestDispatcher("/AdminLTE-3.2.0/customers/form.jsp").forward(request, response);
                return;
            }
            
            if (customerDAO.isEmailExists(emailTrimmed)) {
                request.setAttribute("message", "Email đã tồn tại!");
                request.setAttribute("messageType", "danger");
                request.setAttribute("customer", tempCustomer);
                request.setAttribute("formMode", "create");
                request.setAttribute("pageTitle", "Thêm Khách hàng mới");
                request.getRequestDispatcher("/AdminLTE-3.2.0/customers/form.jsp").forward(request, response);
                return;
            }
            
            if (password == null || password.trim().isEmpty() || password.length() < 6) {
                request.setAttribute("message", "Mật khẩu phải có ít nhất 6 ký tự!");
                request.setAttribute("messageType", "danger");
                request.setAttribute("customer", tempCustomer);
                request.setAttribute("formMode", "create");
                request.setAttribute("pageTitle", "Thêm Khách hàng mới");
                request.getRequestDispatcher("/AdminLTE-3.2.0/customers/form.jsp").forward(request, response);
                return;
            }
            
            if (phone == null || phone.trim().isEmpty()) {
                request.setAttribute("message", "Số điện thoại không được để trống!");
                request.setAttribute("messageType", "danger");
                request.setAttribute("customer", tempCustomer);
                request.setAttribute("formMode", "create");
                request.setAttribute("pageTitle", "Thêm Khách hàng mới");
                request.getRequestDispatcher("/AdminLTE-3.2.0/customers/form.jsp").forward(request, response);
                return;
            }
            
            String phoneTrimmed = phone.trim();
            if (!phoneTrimmed.matches("^[0-9]+$")) {
                request.setAttribute("message", "Số điện thoại không hợp lệ! Số điện thoại chỉ được chứa số, không được có chữ, khoảng trắng hoặc ký tự đặc biệt.");
                request.setAttribute("messageType", "danger");
                request.setAttribute("customer", tempCustomer);
                request.setAttribute("formMode", "create");
                request.setAttribute("pageTitle", "Thêm Khách hàng mới");
                request.getRequestDispatcher("/AdminLTE-3.2.0/customers/form.jsp").forward(request, response);
                return;
            }
            
            if (!phoneTrimmed.matches("^0[0-9]{9,10}$")) {
                request.setAttribute("message", "Số điện thoại không hợp lệ! Số điện thoại phải có 10-11 số và bắt đầu bằng 0 (Ví dụ: 0912345678)");
                request.setAttribute("messageType", "danger");
                request.setAttribute("customer", tempCustomer);
                request.setAttribute("formMode", "create");
                request.setAttribute("pageTitle", "Thêm Khách hàng mới");
                request.getRequestDispatcher("/AdminLTE-3.2.0/customers/form.jsp").forward(request, response);
                return;
            }
            
            boolean success = customerDAO.createCustomer(fullNameTrimmed, emailTrimmed, password, phoneTrimmed, isEmailVerified);
            
            if (success) {
                session.setAttribute("message", "Tạo khách hàng mới thành công!");
                session.setAttribute("messageType", "success");
                response.sendRedirect(baseUrl);
            } else {
                session.setAttribute("message", "Có lỗi xảy ra khi tạo khách hàng!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(baseUrl + "?action=create");
            }
            
        } else if ("update".equals(action)) {
            int customerID = Integer.parseInt(request.getParameter("customerID"));
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");
            String emailVerificationStatus = request.getParameter("emailVerificationStatus");
            boolean isEmailVerified = "true".equals(emailVerificationStatus);
            Customer existing = customerDAO.getCustomerById(customerID);
            if (existing == null) {
                session.setAttribute("message", "Không tìm thấy khách hàng!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(baseUrl);
                return;
            }
            existing.setFullName(fullName);
            existing.setPhone(phone);
            existing.setEmailVerified(isEmailVerified);
            
            if (fullName == null || fullName.trim().isEmpty()) {
                request.setAttribute("message", "Họ tên không được để trống!");
                request.setAttribute("messageType", "danger");
                request.setAttribute("customer", existing);
                request.setAttribute("formMode", "edit");
                request.setAttribute("pageTitle", "Chỉnh sửa Khách hàng");
                request.getRequestDispatcher("/AdminLTE-3.2.0/customers/form.jsp").forward(request, response);
                return;
            }
            
            String fullNameTrimmed = fullName.trim();
            if (!fullNameTrimmed.matches("^[a-zA-ZÀ-ỹ0-9\\s]+$") || !fullNameTrimmed.matches(".*[a-zA-ZÀ-ỹ].*")) {
                request.setAttribute("message", "Họ tên không hợp lệ! Họ tên chỉ được chứa chữ cái, số và khoảng trắng, không được có ký tự đặc biệt và phải có ít nhất 1 chữ cái.");
                request.setAttribute("messageType", "danger");
                request.setAttribute("customer", existing);
                request.setAttribute("formMode", "edit");
                request.setAttribute("pageTitle", "Chỉnh sửa Khách hàng");
                request.getRequestDispatcher("/AdminLTE-3.2.0/customers/form.jsp").forward(request, response);
                return;
            }
            
            if (phone == null || phone.trim().isEmpty()) {
                request.setAttribute("message", "Số điện thoại không được để trống!");
                request.setAttribute("messageType", "danger");
                request.setAttribute("customer", existing);
                request.setAttribute("formMode", "edit");
                request.setAttribute("pageTitle", "Chỉnh sửa Khách hàng");
                request.getRequestDispatcher("/AdminLTE-3.2.0/customers/form.jsp").forward(request, response);
                return;
            }
            
            String phoneTrimmed = phone.trim();
            if (!phoneTrimmed.matches("^[0-9]+$")) {
                request.setAttribute("message", "Số điện thoại không hợp lệ! Số điện thoại chỉ được chứa số, không được có chữ, khoảng trắng hoặc ký tự đặc biệt.");
                request.setAttribute("messageType", "danger");
                request.setAttribute("customer", existing);
                request.setAttribute("formMode", "edit");
                request.setAttribute("pageTitle", "Chỉnh sửa Khách hàng");
                request.getRequestDispatcher("/AdminLTE-3.2.0/customers/form.jsp").forward(request, response);
                return;
            }
            
            if (!phoneTrimmed.matches("^0[0-9]{9,10}$")) {
                request.setAttribute("message", "Số điện thoại không hợp lệ! Số điện thoại phải có 10-11 số và bắt đầu bằng 0 (Ví dụ: 0912345678)");
                request.setAttribute("messageType", "danger");
                request.setAttribute("customer", existing);
                request.setAttribute("formMode", "edit");
                request.setAttribute("pageTitle", "Chỉnh sửa Khách hàng");
                request.getRequestDispatcher("/AdminLTE-3.2.0/customers/form.jsp").forward(request, response);
                return;
            }
            
            boolean success = customerDAO.updateCustomer(customerID, fullName.trim(), phoneTrimmed, isEmailVerified);
            
            if (success) {
                session.setAttribute("message", "Cập nhật thông tin khách hàng thành công!");
                session.setAttribute("messageType", "success");
                response.sendRedirect(baseUrl);
            } else {
                session.setAttribute("message", "Có lỗi xảy ra khi cập nhật!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(baseUrl + "?action=edit&id=" + customerID);
            }
            
        } else if ("toggleActive".equals(action)) {
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
            
            response.sendRedirect(baseUrl);
        }
    }
}

