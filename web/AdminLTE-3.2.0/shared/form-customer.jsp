<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    // Chỉ hỗ trợ edit mode
    entity.Customer customer = (entity.Customer) request.getAttribute("customer");
    if (customer == null) {
        response.sendRedirect(request.getContextPath() + "/admin/customers");
        return;
    }
    
    // Set vào request attribute để JSTL có thể truy cập
    request.setAttribute("isEditMode", true);
%>
<div class="card">
  <div class="card-header">
    <h3 class="card-title">
      <i class="fas fa-edit"></i> Chỉnh sửa Khách hàng
    </h3>
  </div>
  <form method="post" action="<%= request.getContextPath() %>/admin/customers" id="customerForm">
    <div class="card-body">
      <input type="hidden" name="action" value="update">
      <input type="hidden" name="customerID" value="${customer.customerID}">
      
      <div class="form-group">
        <label for="fullName">Họ tên <span class="text-danger">*</span></label>
        <input type="text" class="form-control" id="fullName" name="fullName" 
               value="${customer.fullName}" required placeholder="Nhập họ tên">
      </div>
      
      <div class="form-group">
        <label for="email">Email <span class="text-danger">*</span></label>
        <input type="email" class="form-control" id="email" name="email" 
               value="${customer.email}" readonly placeholder="Nhập email">
        <small class="form-text text-muted">Email không thể thay đổi</small>
      </div>
      
      <div class="form-group">
        <label for="phone">Số điện thoại</label>
        <input type="text" class="form-control" id="phone" name="phone" 
               value="${customer.phone}" placeholder="Nhập số điện thoại">
      </div>
      
      <div class="form-group">
        <label for="emailVerificationStatus">Trạng thái xác thực Email</label>
        <select class="form-control" id="emailVerificationStatus" name="emailVerificationStatus">
          <option value="true" ${customer.emailVerified ? 'selected' : ''}>Đã xác thực</option>
          <option value="false" ${!customer.emailVerified ? 'selected' : ''}>Chưa xác thực</option>
        </select>
      </div>
      
    </div>
    <div class="card-footer">
      <button type="submit" class="btn btn-primary">
        <i class="fas fa-save"></i> Cập nhật
      </button>
      <a href="<%= request.getContextPath() %>/admin/customers" class="btn btn-secondary">
        <i class="fas fa-times"></i> Hủy
      </a>
    </div>
  </form>
</div>

