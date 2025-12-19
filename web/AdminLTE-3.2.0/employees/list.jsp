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
              <div class="col-md-2">
                <select name="status" class="form-control">
                  <option value="">Tất cả trạng thái</option>
                  <option value="active" ${status == 'active' ? 'selected' : ''}>Đang hoạt động</option>
                  <option value="locked" ${status == 'locked' ? 'selected' : ''}>Đã khóa</option>
                </select>
              </div>
              <div class="col-md-3">
                <select name="role" class="form-control">
                  <option value="">Tất cả vai trò</option>
                  <option value="Marketer" ${role == 'Marketer' ? 'selected' : ''}>Marketer</option>
                  <option value="SellerManager" ${role == 'SellerManager' ? 'selected' : ''}>Seller Manager</option>
                  <option value="Seller" ${role == 'Seller' ? 'selected' : ''}>Seller</option>
                  <option value="Shipper" ${role == 'Shipper' ? 'selected' : ''}>Shipper</option>
                </select>
              </div>
              <div class="col-md-2">
                <button type="submit" class="btn btn-primary">
                  <i class="fas fa-search"></i> Tìm kiếm
                </button>
              </div>
            </div>
            <c:if test="${not empty role}">
              <input type="hidden" name="role" value="${role}">
            </c:if>
          </form>

          <!-- Employee Table -->
          <div class="table-responsive">
            <table class="table table-bordered table-hover">
              <thead>
                <tr>
                  <th>Mã nhân viên</th>
                  <th>Tên</th>
                  <th>Email</th>
                  <th>Số điện thoại</th>
                  <th>Vai trò</th>
                  <th>Trạng thái</th>
                  <th>Ngày vào công ty</th>
                  <th>Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="employee" items="${employees}">
                  <tr>
                    <td><strong>NV-${employee.employeeID}</strong></td>
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
          <%
            int empPageSizeVal = 5; // đồng bộ với AdminEmployeeServlet
          %>
          <c:set var="pageSize" value="<%= empPageSizeVal %>"/>
          <c:set var="startIndex" value="${total > 0 ? ((currentPage - 1) * pageSize + 1) : 0}"/>
          <c:if test="${startIndex > total}">
            <c:set var="startIndex" value="${total}"/>
          </c:if>
          <c:set var="endIndex" value="${currentPage * pageSize}"/>
          <c:if test="${endIndex > total}">
            <c:set var="endIndex" value="${total}"/>
          </c:if>
          <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-between">
            <div class="mb-2 mb-md-0">
              Hiển thị <strong>${startIndex}</strong> đến <strong>${endIndex}</strong> của <strong>${total}</strong> bản ghi
            </div>
            <nav>
              <ul class="pagination mb-0">
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
    </div>
  </section>
</div>

<jsp:include page="../includes/admin-footer.jsp"/>


