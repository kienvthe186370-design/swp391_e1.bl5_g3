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
      </div>
      
      <div class="form-group">
        <label for="email">Email <span class="text-danger">*</span></label>
        <input type="email" class="form-control" id="email" name="email" 
               value="<%= employee != null ? employee.getEmail() : "" %>" required 
               placeholder="Nhập email">
      </div>
      
      <div class="form-group">
        <label for="phone">Số điện thoại</label>
        <input type="text" class="form-control" id="phone" name="phone" 
               value="<%= employee != null && employee.getPhone() != null ? employee.getPhone() : "" %>" placeholder="Nhập số điện thoại">
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
      
      <div class="form-group">
        <label for="password">Mật khẩu <span class="text-danger">*</span></label>
        <input type="password" class="form-control" id="password" name="password" 
               <%= isEditMode ? "" : "required" %> placeholder="<%= isEditMode ? "Nhập mật khẩu mới (để trống nếu không muốn thay đổi)" : "Nhập mật khẩu" %>" minlength="6">
        <small class="form-text text-muted">
          <%= isEditMode ? "Để trống nếu không muốn thay đổi mật khẩu" : "Mật khẩu tối thiểu 6 ký tự" %>
        </small>
      </div>
      
      <div class="form-group">
        <label for="confirmPassword">Xác nhận Mật khẩu <span class="text-danger">*</span></label>
        <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" 
               <%= isEditMode ? "" : "required" %> placeholder="Nhập lại mật khẩu" minlength="6">
        <small class="form-text text-muted">Xác nhận mật khẩu phải khớp với mật khẩu ở trên</small>
      </div>
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
// Client-side validation: kiểm tra mật khẩu xác nhận
document.getElementById('employeeForm').addEventListener('submit', function(e) {
    var password = document.getElementById('password').value;
    var confirmPassword = document.getElementById('confirmPassword').value;
    
    <c:if test="${!isEditMode}">
    // Create mode: mật khẩu bắt buộc
    if (password.length < 6) {
        e.preventDefault();
        alert('Mật khẩu phải có ít nhất 6 ký tự!');
        return false;
    }
    </c:if>
    
    <c:if test="${isEditMode}">
    // Edit mode: chỉ validate nếu có nhập mật khẩu
    if (password.length > 0) {
        if (password.length < 6) {
            e.preventDefault();
            alert('Mật khẩu phải có ít nhất 6 ký tự!');
            return false;
        }
    }
    </c:if>
    
    // Kiểm tra mật khẩu xác nhận
    if (password.length > 0 && password !== confirmPassword) {
        e.preventDefault();
        alert('Mật khẩu xác nhận không khớp!');
        return false;
    }
});
</script>

