package controller;

import DAO.EmployeeDAO;
import entity.Employee;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "AdminEmployeeServlet", urlPatterns = {"/admin/employees"})
public class AdminEmployeeServlet extends HttpServlet {
    
    private static final int PAGE_SIZE = 10;
    private EmployeeDAO employeeDAO = new EmployeeDAO();
    
    /**
     * Kiểm tra quyền Admin
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
        
        try {
            if (!checkAdminAuth(request, response)) {
                return;
            }
            
            HttpSession session = request.getSession();
            String action = request.getParameter("action");
            String idParam = request.getParameter("id");
            
            if ("edit".equals(action) && idParam != null) {
                // Form chỉnh sửa
                try {
                    int employeeID = Integer.parseInt(idParam);
                    Employee employee = employeeDAO.getEmployeeById(employeeID);
                    if (employee == null) {
                        session.setAttribute("message", "Không tìm thấy nhân viên!");
                        session.setAttribute("messageType", "danger");
                        response.sendRedirect(request.getContextPath() + "/admin/employees");
                        return;
                    }
                    request.setAttribute("employee", employee);
                    request.setAttribute("formMode", "edit");
                    request.setAttribute("pageTitle", "Chỉnh sửa Nhân viên");
                    request.getRequestDispatcher("/AdminLTE-3.2.0/employees/form.jsp")
                            .forward(request, response);
                } catch (NumberFormatException e) {
                    session.setAttribute("message", "ID nhân viên không hợp lệ!");
                    session.setAttribute("messageType", "danger");
                    response.sendRedirect(request.getContextPath() + "/admin/employees");
                }
            } else if ("create".equals(action)) {
                // Form tạo mới
                request.setAttribute("formMode", "create");
                request.setAttribute("pageTitle", "Thêm Nhân viên mới");
                request.getRequestDispatcher("/AdminLTE-3.2.0/employees/form.jsp")
                        .forward(request, response);
            } else {
                // Danh sách nhân viên
                String search = request.getParameter("search");
                String statusParam = request.getParameter("status");
                String roleParam = request.getParameter("role");
                Boolean isActive = null;
                
                if ("active".equals(statusParam)) {
                    isActive = true;
                } else if ("locked".equals(statusParam)) {
                    isActive = false;
                }
                
                int page = 1;
                try {
                    String pageParam = request.getParameter("page");
                    if (pageParam != null && !pageParam.trim().isEmpty()) {
                        page = Integer.parseInt(pageParam);
                    }
                } catch (NumberFormatException e) {
                    // Default page 1
                }
                int pageSize = PAGE_SIZE;
                
                // Lấy dữ liệu
                var employees = employeeDAO.getAllEmployees(search, isActive, roleParam, page, pageSize);
                int total = employeeDAO.getTotalEmployees(search, isActive, roleParam);
                int[] stats = employeeDAO.getEmployeeStats();
                
                request.setAttribute("employees", employees);
                request.setAttribute("total", total);
                int totalPages = (int) Math.ceil((double) total / pageSize);
                request.setAttribute("totalPages", totalPages > 0 ? totalPages : 1);
                request.setAttribute("currentPage", page);
                request.setAttribute("search", search);
                request.setAttribute("status", statusParam);
                request.setAttribute("role", roleParam);
                request.setAttribute("stats", stats);
                request.setAttribute("pageTitle", "Quản lý Nhân viên");
                
                request.getRequestDispatcher("/AdminLTE-3.2.0/employees/list.jsp")
                        .forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("message", "Có lỗi xảy ra khi tải trang: " + e.getMessage());
            session.setAttribute("messageType", "danger");
            response.sendRedirect(request.getContextPath() + "/AdminLTE-3.2.0/index.jsp");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            if (!checkAdminAuth(request, response)) {
                return;
            }
            
            HttpSession session = request.getSession();
            String action = request.getParameter("action");
        
        if ("create".equals(action)) {
            // Tạo mới nhân viên
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String confirmPassword = request.getParameter("confirmPassword");
            String phone = request.getParameter("phone");
            String role = request.getParameter("role");
            
            // Validation
            if (fullName == null || fullName.trim().isEmpty()) {
                session.setAttribute("message", "Họ tên không được để trống!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/employees?action=create");
                return;
            }
            
            if (email == null || email.trim().isEmpty()) {
                session.setAttribute("message", "Email không được để trống!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/employees?action=create");
                return;
            }
            
            // Validate format email: chuyển thành chữ thường, phần đầu không được là số, phải có @, đuôi .com hoặc .vn
            String emailTrimmed = email.trim().toLowerCase();
            if (!emailTrimmed.matches("^[a-zA-Z][a-zA-Z0-9._-]*@[a-zA-Z0-9.-]+\\.(com|vn)$")) {
                session.setAttribute("message", "Email không hợp lệ! Email phải bắt đầu bằng chữ cái, có @ và đuôi phải là .com hoặc .vn (Ví dụ: example@gmail.com)");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/employees?action=create");
                return;
            }
            
            if (password == null || password.trim().isEmpty() || password.length() < 6) {
                session.setAttribute("message", "Mật khẩu phải có ít nhất 6 ký tự!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/employees?action=create");
                return;
            }
            
            if (!password.equals(confirmPassword)) {
                session.setAttribute("message", "Mật khẩu xác nhận không khớp!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/employees?action=create");
                return;
            }
            
            if (employeeDAO.isEmailExists(emailTrimmed)) {
                session.setAttribute("message", "Email đã tồn tại!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/employees?action=create");
                return;
            }
            
            // Validate số điện thoại
            if (phone != null && !phone.trim().isEmpty()) {
                String phoneTrimmed = phone.trim();
                if (!phoneTrimmed.matches("^[0-9]+$")) {
                    session.setAttribute("message", "Số điện thoại không hợp lệ! Số điện thoại chỉ được chứa số.");
                    session.setAttribute("messageType", "danger");
                    response.sendRedirect(request.getContextPath() + "/admin/employees?action=create");
                    return;
                }
                if (!phoneTrimmed.matches("^0[0-9]{9,10}$")) {
                    session.setAttribute("message", "Số điện thoại không hợp lệ! Số điện thoại phải có 10-11 số và bắt đầu bằng 0 (Ví dụ: 0912345678)");
                    session.setAttribute("messageType", "danger");
                    response.sendRedirect(request.getContextPath() + "/admin/employees?action=create");
                    return;
                }
            }
            
            boolean success = employeeDAO.createEmployee(fullName.trim(), emailTrimmed, password, 
                    phone != null ? phone.trim() : null, role);
            
            if (success) {
                session.setAttribute("message", "Tạo nhân viên mới thành công!");
                session.setAttribute("messageType", "success");
                response.sendRedirect(request.getContextPath() + "/admin/employees");
            } else {
                session.setAttribute("message", "Có lỗi xảy ra khi tạo nhân viên!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/employees?action=create");
            }
            
        } else if ("update".equals(action)) {
            // Cập nhật thông tin nhân viên
            int employeeID = Integer.parseInt(request.getParameter("employeeID"));
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String role = request.getParameter("role");
            String password = request.getParameter("password");
            String confirmPassword = request.getParameter("confirmPassword");
            
            // Lấy trạng thái hiện tại của nhân viên để giữ nguyên (không cho phép sửa trong form)
            Employee currentEmployee = employeeDAO.getEmployeeById(employeeID);
            if (currentEmployee == null) {
                session.setAttribute("message", "Không tìm thấy nhân viên!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/employees");
                return;
            }
            boolean isActive = currentEmployee.isActive(); // Giữ nguyên trạng thái hiện tại
            
            // Validation
            if (fullName == null || fullName.trim().isEmpty()) {
                session.setAttribute("message", "Họ tên không được để trống!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/employees?action=edit&id=" + employeeID);
                return;
            }
            
            // Validate email
            if (email == null || email.trim().isEmpty()) {
                session.setAttribute("message", "Email không được để trống!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/employees?action=edit&id=" + employeeID);
                return;
            }
            
            // Validate format email: chuyển thành chữ thường, phần đầu không được là số, phải có @, đuôi .com hoặc .vn
            String emailTrimmed = email.trim().toLowerCase();
            if (!emailTrimmed.matches("^[a-zA-Z][a-zA-Z0-9._-]*@[a-zA-Z0-9.-]+\\.(com|vn)$")) {
                session.setAttribute("message", "Email không hợp lệ! Email phải bắt đầu bằng chữ cái, có @ và đuôi phải là .com hoặc .vn (Ví dụ: example@gmail.com)");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/employees?action=edit&id=" + employeeID);
                return;
            }
            
            // Kiểm tra email có trùng với nhân viên khác không (không tính chính nhân viên này)
            if (employeeDAO.isEmailExistsForOtherEmployee(emailTrimmed, employeeID)) {
                session.setAttribute("message", "Email đã tồn tại cho nhân viên khác!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/employees?action=edit&id=" + employeeID);
                return;
            }
            
            // Validate họ tên: chỉ được chứa chữ cái, số và khoảng trắng, phải có ít nhất 1 chữ cái
            String fullNameTrimmed = fullName.trim();
            if (!fullNameTrimmed.matches("^[a-zA-ZÀ-ỹ0-9\\s]+$") || !fullNameTrimmed.matches(".*[a-zA-ZÀ-ỹ].*")) {
                session.setAttribute("message", "Họ tên không hợp lệ! Họ tên chỉ được chứa chữ cái, số và khoảng trắng, không được có ký tự đặc biệt và phải có ít nhất 1 chữ cái.");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/employees?action=edit&id=" + employeeID);
                return;
            }
            
            // Validate số điện thoại
            if (phone != null && !phone.trim().isEmpty()) {
                String phoneTrimmed = phone.trim();
                if (!phoneTrimmed.matches("^[0-9]+$")) {
                    session.setAttribute("message", "Số điện thoại không hợp lệ! Số điện thoại chỉ được chứa số.");
                    session.setAttribute("messageType", "danger");
                    response.sendRedirect(request.getContextPath() + "/admin/employees?action=edit&id=" + employeeID);
                    return;
                }
                if (!phoneTrimmed.matches("^0[0-9]{9,10}$")) {
                    session.setAttribute("message", "Số điện thoại không hợp lệ! Số điện thoại phải có 10-11 số và bắt đầu bằng 0 (Ví dụ: 0912345678)");
                    session.setAttribute("messageType", "danger");
                    response.sendRedirect(request.getContextPath() + "/admin/employees?action=edit&id=" + employeeID);
                    return;
                }
            }
            
            // Cập nhật thông tin
            boolean success = employeeDAO.updateEmployee(employeeID, fullName.trim(), emailTrimmed,
                    phone != null ? phone.trim() : null, role, isActive);
            
            // Cập nhật mật khẩu nếu có
            if (password != null && !password.trim().isEmpty()) {
                if (password.length() < 6) {
                    session.setAttribute("message", "Mật khẩu phải có ít nhất 6 ký tự!");
                    session.setAttribute("messageType", "danger");
                    response.sendRedirect(request.getContextPath() + "/admin/employees?action=edit&id=" + employeeID);
                    return;
                }
                if (!password.equals(confirmPassword)) {
                    session.setAttribute("message", "Mật khẩu xác nhận không khớp!");
                    session.setAttribute("messageType", "danger");
                    response.sendRedirect(request.getContextPath() + "/admin/employees?action=edit&id=" + employeeID);
                    return;
                }
                employeeDAO.updatePassword(employeeID, password);
            }
            
            if (success) {
                session.setAttribute("message", "Cập nhật thông tin nhân viên thành công!");
                session.setAttribute("messageType", "success");
                response.sendRedirect(request.getContextPath() + "/admin/employees");
            } else {
                session.setAttribute("message", "Có lỗi xảy ra khi cập nhật!");
                session.setAttribute("messageType", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/employees?action=edit&id=" + employeeID);
            }
            
        } else if ("toggleActive".equals(action)) {
            // Khóa/Mở khóa
            int employeeID = Integer.parseInt(request.getParameter("employeeID"));
            boolean isActive = "true".equals(request.getParameter("isActive"));
            
            boolean success = employeeDAO.setEmployeeActiveStatus(employeeID, !isActive);
            
            if (success) {
                session.setAttribute("message", isActive ? "Đã khóa tài khoản!" : "Đã mở khóa tài khoản!");
                session.setAttribute("messageType", "success");
            } else {
                session.setAttribute("message", "Có lỗi xảy ra!");
                session.setAttribute("messageType", "danger");
            }
            
            response.sendRedirect(request.getContextPath() + "/admin/employees");
        }
        } catch (Exception e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("message", "Có lỗi xảy ra: " + e.getMessage());
            session.setAttribute("messageType", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/employees");
        }
    }
}

