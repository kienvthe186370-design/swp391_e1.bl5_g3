<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    // Mode: "create" hoặc "edit"
    String mode = (String) request.getAttribute("formMode");
    if (mode == null) mode = "create";
    
    entity.Employee employee = (entity.Employee) request.getAttribute("employee");
    boolean isEditMode = "edit".equals(mode) && employee != null;
    
    // Set vào request attribute để JSTL có thể truy cập
    request.setAttribute("isEditMode", isEditMode);
%>
<div class="card">
  <div class="card-header">
    <h3 class="card-title">
      <i class="fas fa-<%= isEditMode ? "edit" : "plus" %>"></i> 
      <%= isEditMode ? "Chỉnh sửa Nhân viên" : "Thêm Nhân viên mới" %>
    </h3>
  </div>
  <form method="post" action="<%= request.getContextPath() %>/admin/employees" id="employeeForm">
    <div class="card-body">
      <input type="hidden" name="action" value="<%= isEditMode ? "update" : "create" %>">
      <% if (employee != null) { %>
        <input type="hidden" name="employeeID" value="<%= employee.getEmployeeID() %>">
      <% } %>
      
      <div class="form-group">
        <label for="fullName">Tên Nhân viên <span class="text-danger">*</span></label>
        <input type="text" class="form-control" id="fullName" name="fullName" 
               value="<%= employee != null ? employee.getFullName() : "" %>" required placeholder="Nhập tên nhân viên">
        <small class="form-text text-muted">Chỉ được chứa chữ cái, số và khoảng trắng</small>
      </div>
      
      <div class="form-group">
        <label for="email">Email <span class="text-danger">*</span></label>
        <input type="email" class="form-control" id="email" name="email" 
               value="<%= employee != null ? employee.getEmail() : "" %>" required 
               placeholder="Nhập email">
        <small class="form-text text-muted">Email phải bắt đầu bằng chữ cái (Ví dụ: example@gmail.com)</small>
      </div>
      
      <div class="form-group">
        <label for="phone">Số điện thoại</label>
        <input type="text" class="form-control" id="phone" name="phone" 
               value="<%= employee != null && employee.getPhone() != null ? employee.getPhone() : "" %>" placeholder="Nhập số điện thoại">
        <small class="form-text text-muted">10-11 số, bắt đầu bằng 0 (Ví dụ: 0912345678)</small>
      </div>
      
      <div class="form-group">
        <label for="role">Vai trò <span class="text-danger">*</span></label>
        <select class="form-control" id="role" name="role" required>
          <option value="">-- Chọn vai trò --</option>
          <option value="Marketer" <%= employee != null && "Marketer".equals(employee.getRole()) ? "selected" : "" %>>Marketer</option>
          <option value="SellerManager" <%= employee != null && "SellerManager".equals(employee.getRole()) ? "selected" : "" %>>Seller Manager</option>
          <option value="Seller" <%= employee != null && "Seller".equals(employee.getRole()) ? "selected" : "" %>>Seller</option>
        </select>
      </div>
      
      <% if (isEditMode) { %>
      <div class="form-group">
        <label for="password">Mật khẩu mới</label>
        <input type="password" class="form-control" id="password" name="password" 
               placeholder="Nhập mật khẩu mới (để trống nếu không muốn thay đổi)" minlength="6">
        <small class="form-text text-muted">Để trống nếu không muốn thay đổi mật khẩu</small>
      </div>
      <% } else { %>
      <div class="alert alert-info">
        <i class="fas fa-info-circle"></i> Mật khẩu sẽ được tự động tạo và gửi qua email cho nhân viên. 
        Nhân viên sẽ được yêu cầu đổi mật khẩu khi đăng nhập lần đầu.
      </div>
      <% } %>
      
    </div>
    <div class="card-footer">
      <button type="submit" class="btn btn-primary">
        <i class="fas fa-save"></i> <%= isEditMode ? "Cập nhật" : "Tạo mới" %>
      </button>
      <a href="<%= request.getContextPath() %>/admin/employees" class="btn btn-secondary">
        <i class="fas fa-times"></i> Hủy
      </a>
    </div>
  </form>
</div>

<script>
// Client-side validation
document.getElementById('employeeForm').addEventListener('submit', function(e) {
    var fullName = document.getElementById('fullName').value.trim();
    var email = document.getElementById('email').value.trim();
    var phone = document.getElementById('phone').value.trim();
    var role = document.getElementById('role').value;
    var passwordField = document.getElementById('password');
    var password = passwordField ? passwordField.value : '';
    var isEditMode = document.getElementById('password') !== null;
    
    // Validate họ tên
    var nameRegex = /^[a-zA-ZÀ-ỹ0-9\s]+$/;
    var hasLetter = /[a-zA-ZÀ-ỹ]/;
    if (!nameRegex.test(fullName) || !hasLetter.test(fullName)) {
        e.preventDefault();
        alert('Họ tên không hợp lệ! Chỉ được chứa chữ cái, số và khoảng trắng, phải có ít nhất 1 chữ cái.');
        return false;
    }
    
    // Validate email
    var emailRegex = /^[a-zA-Z][a-zA-Z0-9._-]*@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    if (!emailRegex.test(email)) {
        e.preventDefault();
        alert('Email không hợp lệ! Email phải bắt đầu bằng chữ cái và có định dạng đúng.');
        return false;
    }
    
    // Validate phone nếu có nhập
    if (phone.length > 0) {
        var phoneRegex = /^0[0-9]{9,10}$/;
        if (!phoneRegex.test(phone)) {
            e.preventDefault();
            alert('Số điện thoại không hợp lệ! Phải có 10-11 số và bắt đầu bằng 0.');
            return false;
        }
    }
    
    // Validate role
    if (!role) {
        e.preventDefault();
        alert('Vui lòng chọn vai trò!');
        return false;
    }
    
    // Edit mode: chỉ validate nếu có nhập mật khẩu
    if (isEditMode && password.length > 0) {
        if (password.length < 6) {
            e.preventDefault();
            alert('Mật khẩu phải có ít nhất 6 ký tự!');
            return false;
        }
    }
    
    return true;
});
</script>
