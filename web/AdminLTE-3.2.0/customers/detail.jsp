<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    request.setAttribute("pageTitle", "Chi tiết Khách hàng");
%>
<jsp:include page="../includes/admin-header.jsp"/>
<jsp:include page="../includes/admin-sidebar.jsp"/>

<div class="content-wrapper">
  <div class="content-header">
    <div class="container-fluid">
      <div class="row mb-2">
        <div class="col-sm-6">
          <h1 class="m-0"><i class="fas fa-user"></i> Chi tiết Khách hàng</h1>
        </div>
        <div class="col-sm-6">
          <ol class="breadcrumb float-sm-right">
            <li class="breadcrumb-item">
              <a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp">Dashboard</a>
            </li>
            <li class="breadcrumb-item">
              <a href="<%= request.getContextPath() %>/admin/customers">Khách hàng</a>
            </li>
            <li class="breadcrumb-item active">Chi tiết</li>
          </ol>
        </div>
      </div>
    </div>
  </div>

  <section class="content">
    <div class="container-fluid">
      <c:if test="${customer == null}">
        <div class="alert alert-danger">
          Không tìm thấy khách hàng!
        </div>
        <a href="<%= request.getContextPath() %>/admin/customers" class="btn btn-secondary">
          <i class="fas fa-arrow-left"></i> Quay lại
        </a>
      </c:if>
      
      <c:if test="${customer != null}">
        <div class="card">
          <div class="card-header">
            <h3 class="card-title">Thông tin Khách hàng #${customer.customerID}</h3>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-6">
                <table class="table table-bordered">
                  <tr>
                    <th style="width: 200px;">ID</th>
                    <td><strong>#${customer.customerID}</strong></td>
                  </tr>
                  <tr>
                    <th>Họ tên</th>
                    <td>${customer.fullName}</td>
                  </tr>
                  <tr>
                    <th>Email</th>
                    <td>${customer.email}</td>
                  </tr>
                  <tr>
                    <th>Số điện thoại</th>
                    <td>${customer.phone != null ? customer.phone : '-'}</td>
                  </tr>
                  <tr>
                    <th>Xác thực Email</th>
                    <td>
                      <c:choose>
                        <c:when test="${customer.emailVerified}">
                          <span class="badge badge-success">Đã xác thực</span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge badge-warning">Chưa xác thực</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                  </tr>
                  <tr>
                    <th>Trạng thái</th>
                    <td>
                      <c:choose>
                        <c:when test="${customer.active}">
                          <span class="badge badge-success">Đang hoạt động</span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge badge-danger">Đã khóa</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                  </tr>
                  <tr>
                    <th>Ngày tạo</th>
                    <td>
                      <fmt:formatDate value="${customer.createdDate}" pattern="dd/MM/yyyy HH:mm:ss"/>
                    </td>
                  </tr>
                  <tr>
                    <th>Lần đăng nhập cuối</th>
                    <td>
                      <c:choose>
                        <c:when test="${customer.lastLogin != null}">
                          <fmt:formatDate value="${customer.lastLogin}" pattern="dd/MM/yyyy HH:mm:ss"/>
                        </c:when>
                        <c:otherwise>
                          <span class="text-muted">Chưa đăng nhập</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                  </tr>
                </table>
              </div>
            </div>
          </div>
          <div class="card-footer">
            <a href="<%= request.getContextPath() %>/admin/customers?action=edit&id=${customer.customerID}" 
               class="btn btn-warning">
              <i class="fas fa-edit"></i> Chỉnh sửa
            </a>
            <a href="<%= request.getContextPath() %>/admin/customers" 
               class="btn btn-secondary">
              <i class="fas fa-arrow-left"></i> Quay lại
            </a>
          </div>
        </div>
      </c:if>
    </div>
  </section>
</div>

<jsp:include page="../includes/admin-footer.jsp"/>

