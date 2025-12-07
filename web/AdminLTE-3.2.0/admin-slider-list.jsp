<%-- 
    Document   : admin-slider-list
    Created on : Dec 7, 2025, 10:56:59 PM
    Author     : xuand
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="entity.Employee" %>
<%
    Employee employee = (Employee) session.getAttribute("employee");
    if (employee == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String adminName = employee.getFullName();
    String adminEmail = employee.getEmail();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Quản lý Slider - Admin</title>

  <!-- Google Font: Source Sans Pro -->
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
  <!-- Font Awesome -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/fontawesome-free/css/all.min.css">
  <!-- DataTables -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/datatables-bs4/css/dataTables.bootstrap4.min.css">
  <!-- Theme style -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/css/adminlte.min.css">
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">

  <!-- Navbar -->
  <%@ include file="navbar.jsp" %>

  <!-- Sidebar -->
  <%@ include file="sidebar.jsp" %>

  <!-- Content Wrapper -->
  <div class="content-wrapper">
    <!-- Content Header -->
    <section class="content-header">
      <div class="container-fluid">
        <div class="row mb-2">
          <div class="col-sm-6">
            <h1><i class="fas fa-images"></i> Quản lý Slider</h1>
          </div>
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp">Home</a></li>
              <li class="breadcrumb-item active">Slider</li>
            </ol>
          </div>
        </div>
      </div>
    </section>

    <!-- Main content -->
    <section class="content">
      <div class="container-fluid">
        
        <!-- Success/Error Messages -->
        <c:if test="${param.success == 'added'}">
          <div class="alert alert-success alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-check"></i> Thêm slider thành công!
          </div>
        </c:if>
        <c:if test="${param.success == 'updated'}">
          <div class="alert alert-success alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-check"></i> Cập nhật slider thành công!
          </div>
        </c:if>
        <c:if test="${param.success == 'deleted'}">
          <div class="alert alert-success alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-check"></i> Xóa slider thành công!
          </div>
        </c:if>
        <c:if test="${param.error == 'notfound'}">
          <div class="alert alert-danger alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-ban"></i> Không tìm thấy slider!
          </div>
        </c:if>

        <!-- Main Card -->
        <div class="card">
          <div class="card-header">
            <h3 class="card-title">Danh sách Slider</h3>
            <div class="card-tools">
              <a href="<%= request.getContextPath() %>/admin/slider?action=add" class="btn btn-primary btn-sm">
                <i class="fas fa-plus"></i> Thêm Slider Mới
              </a>
            </div>
          </div>
          
          <!-- Card Body -->
          <div class="card-body">
            <!-- Filter Form -->
            <form method="get" action="<%= request.getContextPath() %>/admin/slider" class="mb-3">
              <div class="row">
                <div class="col-md-5">
                  <input type="text" name="search" value="${search}" class="form-control" placeholder="Tìm theo tiêu đề...">
                </div>
                <div class="col-md-3">
                  <select name="status" class="form-control">
                    <option value="">-- Tất cả trạng thái --</option>
                    <option value="active" ${status == 'active' ? 'selected' : ''}>Active</option>
                    <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Inactive</option>
                  </select>
                </div>
                <div class="col-md-2">
                  <button type="submit" class="btn btn-primary btn-block">
                    <i class="fas fa-search"></i> Tìm kiếm
                  </button>
                </div>
                <div class="col-md-2">
                  <a href="<%= request.getContextPath() %>/admin/slider" class="btn btn-secondary btn-block">
                    <i class="fas fa-redo"></i> Reset
                  </a>
                </div>
              </div>
            </form>

            <!-- Table -->
            <table class="table table-bordered table-hover">
              <thead>
                <tr>
                  <th style="width: 60px;">ID</th>
                  <th style="width: 140px;">Hình ảnh</th>
                  <th>Tiêu đề</th>
                  <th>Link URL</th>
                  <th style="width: 80px;">Thứ tự</th>
                  <th style="width: 100px;">Trạng thái</th>
                  <th style="width: 150px;" class="text-center">Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="slider" items="${sliders}">
                  <tr>
                    <td><strong>#${slider.sliderID}</strong></td>
                    <td>
                      <c:choose>
                        <c:when test="${not empty slider.imageURL}">
                          <img src="${slider.imageURL}" alt="${slider.title}" class="img-thumbnail" style="max-width: 120px; max-height: 60px;">
                        </c:when>
                        <c:otherwise>
                          <div class="text-center text-muted">
                            <i class="fas fa-image fa-2x"></i>
                          </div>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td><strong>${slider.title}</strong></td>
                    <td>
                      <c:choose>
                        <c:when test="${not empty slider.linkURL}">
                          <a href="${slider.linkURL}" target="_blank" class="text-primary">
                            <i class="fas fa-external-link-alt"></i> ${slider.linkURL}
                          </a>
                        </c:when>
                        <c:otherwise>
                          <span class="text-muted">Không có link</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td><span class="badge badge-secondary">${slider.displayOrder}</span></td>
                    <td>
                      <c:choose>
                        <c:when test="${slider.status == 'active'}">
                          <span class="badge badge-success">
                            <i class="fas fa-check-circle"></i> Active
                          </span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge badge-danger">
                            <i class="fas fa-times-circle"></i> Inactive
                          </span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td class="text-center">
                      <a href="<%= request.getContextPath() %>/admin/slider?action=edit&id=${slider.sliderID}" 
                         class="btn btn-warning btn-sm" title="Chỉnh sửa">
                        <i class="fas fa-edit"></i>
                      </a>
                      <button type="button" class="btn btn-danger btn-sm" 
                              onclick="confirmDelete(${slider.sliderID}, '${slider.title}')" title="Xóa">
                        <i class="fas fa-trash"></i>
                      </button>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty sliders}">
                  <tr>
                    <td colspan="7" class="text-center">
                      <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                      <p class="text-muted">Không có slider nào.</p>
                    </td>
                  </tr>
                </c:if>
              </tbody>
            </table>

            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
              <div class="mt-3">
                <ul class="pagination justify-content-center">
                  <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                    <a class="page-link" href="?page=${currentPage - 1}&search=${search}&status=${status}">
                      <i class="fas fa-chevron-left"></i>
                    </a>
                  </li>
                  <c:forEach begin="1" end="${totalPages}" var="i">
                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                      <a class="page-link" href="?page=${i}&search=${search}&status=${status}">${i}</a>
                    </li>
                  </c:forEach>
                  <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                    <a class="page-link" href="?page=${currentPage + 1}&search=${search}&status=${status}">
                      <i class="fas fa-chevron-right"></i>
                    </a>
                  </li>
                </ul>
              </div>
            </c:if>
          </div>
        </div>
      </div>
    </section>
  </div>

  <!-- Footer -->
  <footer class="main-footer">
    <strong>Copyright &copy; 2025 <a href="#">Pickleball Shop</a>.</strong> All rights reserved.
  </footer>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header bg-danger">
        <h4 class="modal-title"><i class="fas fa-exclamation-triangle"></i> Xác nhận xóa</h4>
        <button type="button" class="close" data-dismiss="modal">&times;</button>
      </div>
      <div class="modal-body">
        <p>Bạn có chắc chắn muốn xóa slider <strong id="sliderTitle"></strong>?</p>
        <p class="text-danger"><i class="fas fa-info-circle"></i> Hành động này không thể hoàn tác!</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">Hủy</button>
        <a href="#" id="confirmDeleteBtn" class="btn btn-danger">
          <i class="fas fa-trash"></i> Xóa
        </a>
      </div>
    </div>
  </div>
</div>

<!-- jQuery -->
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/jquery/jquery.min.js"></script>
<!-- Bootstrap 4 -->
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<!-- AdminLTE App -->
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/js/adminlte.min.js"></script>

<script>
function confirmDelete(id, title) {
    $('#sliderTitle').text(title);
    $('#confirmDeleteBtn').attr('href', '<%= request.getContextPath() %>/admin/slider?action=delete&id=' + id);
    $('#deleteModal').modal('show');
}

// Auto hide alerts after 3 seconds
setTimeout(function() {
    $('.alert').fadeOut('slow');
}, 3000);
</script>
</body>
</html>
