<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    // Mode: "create" hoặc "edit"
    String mode = (String) request.getAttribute("formMode");
    if (mode == null) mode = "create";
    
    entity.Customer customer = (entity.Customer) request.getAttribute("customer");
    boolean isEditMode = "edit".equals(mode) && customer != null;
    
    // Set vào request attribute để JSTL có thể truy cập
    request.setAttribute("isEditMode", isEditMode);
%>
<div class="card">
  <div class="card-header">
    <h3 class="card-title">
      <i class="fas fa-<%= isEditMode ? "edit" : "plus" %>"></i> 
      <%= isEditMode ? "Chỉnh sửa Khách hàng" : "Thêm Khách hàng mới" %>
    </h3>
  </div>
  <form method="post" action="<%= request.getContextPath() %>/seller-manager/customers" id="customerForm">
    <div class="card-body">
      <input type="hidden" name="action" value="<%= isEditMode ? "update" : "create" %>">
      <% if (customer != null) { %>
        <input type="hidden" name="customerID" value="<%= customer.getCustomerID() %>">
      <% } %>
      
      <div class="form-group">
        <label for="fullName">Họ tên <span class="text-danger">*</span></label>
        <input type="text" class="form-control" id="fullName" name="fullName" 
               value="<%= customer != null ? customer.getFullName() : "" %>" required placeholder="Nhập họ tên">
      </div>
      
      <div class="form-group">
        <label for="email">Email <span class="text-danger">*</span></label>
        <input type="email" class="form-control" id="email" name="email" 
               value="<%= customer != null ? customer.getEmail() : "" %>" 
               <%= isEditMode ? "readonly" : "required" %> placeholder="Nhập email">
        <% if (isEditMode) { %>
          <small class="form-text text-muted">Email không thể thay đổi</small>
        <% } %>
      </div>
      
      <% if (!isEditMode) { %>
      <div class="form-group">
        <label for="password">Mật khẩu <span class="text-danger">*</span></label>
        <input type="password" class="form-control" id="password" name="password" 
               required placeholder="Nhập mật khẩu" minlength="6">
        <small class="form-text text-muted">Mật khẩu tối thiểu 6 ký tự</small>
      </div>
      <% } %>
      
      <div class="form-group">
        <label for="phone">Số điện thoại <span class="text-danger">*</span></label>
        <input type="text" class="form-control" id="phone" name="phone" 
               value="<%= customer != null && customer.getPhone() != null ? customer.getPhone() : "" %>" 
               required placeholder="Nhập số điện thoại">
      </div>
      
     
      
    </div>
    <div class="card-footer">
      <button type="submit" class="btn btn-primary">
        <i class="fas fa-save"></i> <%= isEditMode ? "Cập nhật" : "Tạo mới" %>
      </button>
      <a href="<%= request.getContextPath() %>/seller-manager/customers" class="btn btn-secondary">
        <i class="fas fa-times"></i> Hủy
      </a>
    </div>
  </form>
</div>

<script>
// Client-side validation: kiểm tra độ dài mật khẩu (chỉ cho create mode)
<c:if test="${!isEditMode}">
document.getElementById('customerForm').addEventListener('submit', function(e) {
    var password = document.getElementById('password').value;
    if (password.length < 6) {
        e.preventDefault();
        alert('Mật khẩu phải có ít nhất 6 ký tự!');
        return false;
    }
});
</c:if>
</script>

