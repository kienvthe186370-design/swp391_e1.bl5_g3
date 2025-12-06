<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    request.setAttribute("pageTitle", "Quản lý Khách hàng");
    
    // Get message from session
    String message = (String) session.getAttribute("message");
    String messageType = (String) session.getAttribute("messageType");
    session.removeAttribute("message");
    session.removeAttribute("messageType");
%>
<!-- Import header, sidebar, footer CHUNG -->
<jsp:include page="../includes/admin-header.jsp"/>
<jsp:include page="../includes/admin-sidebar.jsp"/>

<div class="content-wrapper">
  <div class="content-header">
    <div class="container-fluid">
      <div class="row mb-2">
        <div class="col-sm-6">
          <h1 class="m-0"><i class="fas fa-users"></i> Quản lý Khách hàng</h1>
        </div>
        <div class="col-sm-6">
          <ol class="breadcrumb float-sm-right">
            <li class="breadcrumb-item">
              <a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp">Dashboard</a>
            </li>
            <li class="breadcrumb-item active">Khách hàng</li>
          </ol>
        </div>
      </div>
    </div>
  </div>

  <section class="content">
    <div class="container-fluid">
      <!-- Alert Message -->
      <c:if test="${not empty message}">
        <div class="alert alert-${messageType} alert-dismissible fade show" role="alert">
          ${message}
          <button type="button" class="close" data-dismiss="alert" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
      </c:if>

      <!-- Statistics Cards -->
      <div class="row">
        <div class="col-lg-4 col-6">
          <div class="small-box bg-info">
            <div class="inner">
              <h3>${stats[0]}</h3>
              <p>Tổng tài khoản</p>
            </div>
            <div class="icon">
              <i class="fas fa-users"></i>
            </div>
            <a href="<%= request.getContextPath() %>/admin/customers" class="small-box-footer">
              Xem tất cả <i class="fas fa-arrow-circle-right"></i>
            </a>
          </div>
        </div>
        <div class="col-lg-4 col-6">
          <div class="small-box bg-success">
            <div class="inner">
              <h3>${stats[1]}</h3>
              <p>Đang hoạt động</p>
            </div>
            <div class="icon">
              <i class="fas fa-user-check"></i>
            </div>
            <a href="<%= request.getContextPath() %>/admin/customers?status=active" class="small-box-footer">
              Chi tiết <i class="fas fa-arrow-circle-right"></i>
            </a>
          </div>
        </div>
        <div class="col-lg-4 col-6">
          <div class="small-box bg-warning">
            <div class="inner">
              <h3>${stats[2]}</h3>
              <p>Đã khóa</p>
            </div>
            <div class="icon">
              <i class="fas fa-user-lock"></i>
            </div>
            <a href="<%= request.getContextPath() %>/admin/customers?status=locked" class="small-box-footer">
              Chi tiết <i class="fas fa-arrow-circle-right"></i>
            </a>
          </div>
        </div>
      </div>

      <!-- Customer List Card -->
      <div class="card">
        <div class="card-header">
          <h3 class="card-title"><i class="fas fa-list"></i> 
            <c:choose>
              <c:when test="${status == 'active'}">Khách hàng Đang hoạt động</c:when>
              <c:when test="${status == 'locked'}">Khách hàng Đã khóa</c:when>
              <c:otherwise>Tất cả khách hàng</c:otherwise>
            </c:choose>
          </h3>
          <div class="card-tools">
            <div class="btn-group">
              <a href="<%= request.getContextPath() %>/admin/customers?status=active" 
                 class="btn btn-sm btn-success ${status == 'active' ? 'active' : ''}">
                <i class="fas fa-user-check"></i> Đang hoạt động
              </a>
              <a href="<%= request.getContextPath() %>/admin/customers?status=locked" 
                 class="btn btn-sm btn-warning ${status == 'locked' ? 'active' : ''}">
                <i class="fas fa-user-lock"></i> Đã khóa
              </a>
              <a href="<%= request.getContextPath() %>/admin/customers" 
                 class="btn btn-sm btn-secondary ${status == null ? 'active' : ''}">
                <i class="fas fa-list"></i> Tất cả
              </a>
            </div>
          </div>
        </div>
        <div class="card-body">
          <!-- Search Form -->
          <form method="get" action="<%= request.getContextPath() %>/admin/customers" class="mb-3">
            <div class="row">
              <div class="col-md-4">
                <input type="text" name="search" value="${search}" class="form-control" 
                       placeholder="Tìm theo tên, email, số điện thoại...">
                <c:if test="${not empty status}">
                  <input type="hidden" name="status" value="${status}">
                </c:if>
              </div>
              <div class="col-md-2">
                <button type="submit" class="btn btn-primary">
                  <i class="fas fa-search"></i> Tìm kiếm
                </button>
              </div>
            </div>
          </form>

          <!-- Customer Table -->
          <div class="table-responsive">
            <table class="table table-bordered table-hover">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Họ tên</th>
                  <th>Email</th>
                  <th>Số điện thoại</th>
                  <th>Xác thực Email</th>
                  <th>Trạng thái</th>
                  <th>Ngày tạo</th>
                  <th>Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="customer" items="${customers}">
                  <tr>
                    <td><strong>#${customer.customerID}</strong></td>
                    <td>${customer.fullName}</td>
                    <td>${customer.email}</td>
                    <td>${customer.phone != null ? customer.phone : '-'}</td>
                    <td>
                      <c:choose>
                        <c:when test="${customer.emailVerified}">
                          <span class="badge badge-success">Đã xác thực</span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge badge-warning">Chưa</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
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
                    <td>
                      <fmt:formatDate value="${customer.createdDate}" pattern="dd/MM/yyyy HH:mm"/>
                    </td>
                    <td>
                      <a href="<%= request.getContextPath() %>/admin/customers?action=detail&id=${customer.customerID}" 
                         class="btn btn-sm btn-info" title="Xem chi tiết">
                        <i class="fas fa-eye"></i>
                      </a>
                      <a href="<%= request.getContextPath() %>/admin/customers?action=edit&id=${customer.customerID}" 
                         class="btn btn-sm btn-warning" title="Chỉnh sửa">
                        <i class="fas fa-edit"></i>
                      </a>
                      <form method="post" action="<%= request.getContextPath() %>/admin/customers" 
                            style="display:inline;" 
                            onsubmit="return confirm('Bạn có chắc muốn ${customer.active ? 'khóa' : 'mở khóa'} tài khoản này?');">
                        <input type="hidden" name="action" value="toggleActive">
                        <input type="hidden" name="customerID" value="${customer.customerID}">
                        <input type="hidden" name="isActive" value="${customer.active}">
                        <button type="submit" class="btn btn-sm ${customer.active ? 'btn-danger' : 'btn-success'}" 
                                title="${customer.active ? 'Khóa' : 'Mở khóa'}">
                          <i class="fas fa-${customer.active ? 'lock' : 'unlock'}"></i>
                        </button>
                      </form>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty customers}">
                  <tr>
                    <td colspan="8" class="text-center py-4">
                      <p class="text-muted mb-0">Không có dữ liệu</p>
                    </td>
                  </tr>
                </c:if>
              </tbody>
            </table>
          </div>

          <!-- Pagination -->
          <c:if test="${totalPages > 1}">
            <nav>
              <ul class="pagination justify-content-center">
                <c:forEach var="i" begin="1" end="${totalPages}">
                  <li class="page-item ${i == currentPage ? 'active' : ''}">
                    <a class="page-link" 
                       href="<%= request.getContextPath() %>/admin/customers?page=${i}&status=${status}&search=${search}">
                      ${i}
                    </a>
                  </li>
                </c:forEach>
              </ul>
            </nav>
          </c:if>
        </div>
      </div>
    </div>
  </section>
</div>

<jsp:include page="../includes/admin-footer.jsp"/>

