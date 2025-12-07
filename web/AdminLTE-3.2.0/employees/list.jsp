<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    request.setAttribute("pageTitle", "Quản lý Nhân viên");
    
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
          <h1 class="m-0"><i class="fas fa-user-tie"></i> Quản lý Nhân viên</h1>
        </div>
        <div class="col-sm-6">
          <ol class="breadcrumb float-sm-right">
            <li class="breadcrumb-item">
              <a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp">Dashboard</a>
            </li>
            <li class="breadcrumb-item active">Nhân viên</li>
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
              <i class="fas fa-user-tie"></i>
            </div>
            <a href="<%= request.getContextPath() %>/admin/employees" class="small-box-footer">
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
            <a href="<%= request.getContextPath() %>/admin/employees?status=active" class="small-box-footer">
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
            <a href="<%= request.getContextPath() %>/admin/employees?status=locked" class="small-box-footer">
              Chi tiết <i class="fas fa-arrow-circle-right"></i>
            </a>
          </div>
        </div>
      </div>

      <!-- Employee List Card -->
      <div class="card">
        <div class="card-header">
          <h3 class="card-title"><i class="fas fa-list"></i> 
            <c:choose>
              <c:when test="${status == 'active'}">Nhân viên Đang hoạt động</c:when>
              <c:when test="${status == 'locked'}">Nhân viên Đã khóa</c:when>
              <c:otherwise>Tất cả nhân viên</c:otherwise>
            </c:choose>
          </h3>
          <div class="card-tools">
            <div class="btn-group mr-2">
              <a href="<%= request.getContextPath() %>/admin/employees?status=active" 
                 class="btn btn-sm btn-success ${status == 'active' ? 'active' : ''}">
                <i class="fas fa-user-check"></i> Đang hoạt động
              </a>
              <a href="<%= request.getContextPath() %>/admin/employees?status=locked" 
                 class="btn btn-sm btn-warning ${status == 'locked' ? 'active' : ''}">
                <i class="fas fa-user-lock"></i> Đã khóa
              </a>
              <a href="<%= request.getContextPath() %>/admin/employees" 
                 class="btn btn-sm btn-secondary ${status == null ? 'active' : ''}">
                <i class="fas fa-list"></i> Tất cả
              </a>
            </div>
            <a href="<%= request.getContextPath() %>/admin/employees?action=create" class="btn btn-primary btn-sm">
              <i class="fas fa-plus"></i> Thêm Nhân viên
            </a>
          </div>
        </div>
        <div class="card-body">
          <!-- Search Form -->
          <form method="get" action="<%= request.getContextPath() %>/admin/employees" class="mb-3">
            <div class="row">
              <div class="col-md-3">
                <input type="text" name="search" value="${search}" class="form-control" 
                       placeholder="Tìm theo tên, email, số điện thoại...">
              </div>
              <div class="col-md-3">
                <select name="role" class="form-control" onchange="this.form.submit()">
                  <option value="">Tất cả vai trò</option>
                  <option value="Marketer" ${role == 'Marketer' ? 'selected' : ''}>Marketer</option>
                  <option value="SellerManager" ${role == 'SellerManager' ? 'selected' : ''}>Seller Manager</option>
                  <option value="Seller" ${role == 'Seller' ? 'selected' : ''}>Seller</option>
                </select>
              </div>
              <div class="col-md-2">
                <button type="submit" class="btn btn-primary">
                  <i class="fas fa-search"></i> Tìm kiếm
                </button>
              </div>
            </div>
            <c:if test="${not empty status}">
              <input type="hidden" name="status" value="${status}">
            </c:if>
            <c:if test="${not empty role}">
              <input type="hidden" name="role" value="${role}">
            </c:if>
          </form>

          <!-- Employee Table -->
          <div class="table-responsive">
            <table class="table table-bordered table-hover">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Tên</th>
                  <th>Email</th>
                  <th>Số điện thoại</th>
                  <th>Vai trò</th>
                  <th>Trạng thái</th>
                  <th>Ngày tạo</th>
                  <th>Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="employee" items="${employees}">
                  <tr>
                    <td><strong>#${employee.employeeID}</strong></td>
                    <td>${employee.fullName}</td>
                    <td>${employee.email}</td>
                    <td>${employee.phone != null ? employee.phone : '-'}</td>
                    <td>
                      <c:choose>
                        <c:when test="${employee.role == 'Admin'}">
                          <span class="badge badge-danger">Admin</span>
                        </c:when>
                        <c:when test="${employee.role == 'Marketer'}">
                          <span class="badge badge-info">Marketer</span>
                        </c:when>
                        <c:when test="${employee.role == 'SellerManager'}">
                          <span class="badge badge-primary">Seller Manager</span>
                        </c:when>
                        <c:when test="${employee.role == 'Seller'}">
                          <span class="badge badge-success">Seller</span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge badge-secondary">${employee.role}</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${employee.active}">
                          <span class="badge badge-success">Đang hoạt động</span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge badge-danger">Đã khóa</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <fmt:formatDate value="${employee.createdDate}" pattern="dd/MM/yyyy HH:mm"/>
                    </td>
                    <td>
                      <a href="<%= request.getContextPath() %>/admin/employees?action=edit&id=${employee.employeeID}" 
                         class="btn btn-sm btn-warning" title="Chỉnh sửa">
                        <i class="fas fa-edit"></i>
                      </a>
                      <form method="post" action="<%= request.getContextPath() %>/admin/employees" 
                            style="display:inline;" 
                            onsubmit="return confirm('Bạn có chắc muốn ${employee.active ? 'khóa' : 'mở khóa'} tài khoản này?');">
                        <input type="hidden" name="action" value="toggleActive">
                        <input type="hidden" name="employeeID" value="${employee.employeeID}">
                        <input type="hidden" name="isActive" value="${employee.active}">
                        <button type="submit" class="btn btn-sm ${employee.active ? 'btn-danger' : 'btn-success'}" 
                                title="${employee.active ? 'Khóa' : 'Mở khóa'}">
                          <i class="fas fa-${employee.active ? 'lock' : 'unlock'}"></i>
                        </button>
                      </form>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty employees}">
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
          <nav>
            <ul class="pagination justify-content-center">
              <!-- Nút Trước -->
              <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                <c:choose>
                  <c:when test="${currentPage == 1}">
                    <span class="page-link">Trước</span>
                  </c:when>
                  <c:otherwise>
                    <a class="page-link" 
                       href="<%= request.getContextPath() %>/admin/employees?page=${currentPage - 1}&status=${status}&role=${role}&search=${search}">
                      Trước
                    </a>
                  </c:otherwise>
                </c:choose>
              </li>
              
              <!-- Số trang -->
              <c:forEach var="i" begin="1" end="${totalPages > 0 ? totalPages : 1}">
                <li class="page-item ${i == currentPage ? 'active' : ''}">
                  <a class="page-link" 
                     href="<%= request.getContextPath() %>/admin/employees?page=${i}&status=${status}&role=${role}&search=${search}">
                    ${i}
                  </a>
                </li>
              </c:forEach>
              
              <!-- Nút Sau -->
              <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                <c:choose>
                  <c:when test="${currentPage >= totalPages}">
                    <span class="page-link">Sau</span>
                  </c:when>
                  <c:otherwise>
                    <a class="page-link" 
                       href="<%= request.getContextPath() %>/admin/employees?page=${currentPage + 1}&status=${status}&role=${role}&search=${search}">
                      Sau
                    </a>
                  </c:otherwise>
                </c:choose>
              </li>
            </ul>
          </nav>
        </div>
      </div>
    </div>
  </section>
</div>

<jsp:include page="../includes/admin-footer.jsp"/>


