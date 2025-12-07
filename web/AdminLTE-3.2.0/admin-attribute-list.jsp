<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="entity.Employee" %>
<%
    Employee employee = (Employee) session.getAttribute("employee");
    if (employee == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Quản lý Thuộc tính - Admin</title>

  <!-- Google Font: Source Sans Pro -->
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
  <!-- Font Awesome -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/fontawesome-free/css/all.min.css">
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
            <h1><i class="fas fa-tags"></i> Quản lý Thuộc tính</h1>
          </div>
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp">Home</a></li>
              <li class="breadcrumb-item active">Thuộc tính</li>
            </ol>
          </div>
        </div>
      </div>
    </section>

    <!-- Main content -->
    <section class="content">
      <div class="container-fluid">
        
        <!-- Success/Error Messages -->
        <c:if test="${param.msg == 'add_success'}">
          <div class="alert alert-success alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-check"></i> Thêm thuộc tính thành công!
          </div>
        </c:if>
        <c:if test="${param.msg == 'update_success'}">
          <div class="alert alert-success alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-check"></i> Cập nhật thuộc tính thành công!
          </div>
        </c:if>
        <c:if test="${param.msg == 'delete_success'}">
          <div class="alert alert-success alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-check"></i> Xóa thuộc tính thành công!
          </div>
        </c:if>

        <!-- Main Card -->
        <div class="card">
          <div class="card-header">
            <h3 class="card-title">Danh sách Thuộc tính</h3>
            <div class="card-tools">
              <a href="<%= request.getContextPath() %>/admin/attributes?action=add" class="btn btn-primary btn-sm">
                <i class="fas fa-plus"></i> Thêm Thuộc tính Mới
              </a>
            </div>
          </div>
          
          <!-- Card Body -->
          <div class="card-body">
            <!-- Filter Form -->
            <form method="get" action="<%= request.getContextPath() %>/admin/attributes" class="mb-3">
              <div class="row">
                <div class="col-md-4">
                  <input type="text" name="search" value="${search}" class="form-control" placeholder="Tìm theo tên thuộc tính...">
                </div>
                <div class="col-md-2">
                  <select name="status" class="form-control">
                    <option value="">-- Tất cả --</option>
                    <option value="active" ${status == 'active' ? 'selected' : ''}>Active</option>
                    <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Inactive</option>
                  </select>
                </div>
                <div class="col-md-2">
                  <select name="sortBy" class="form-control">
                    <option value="">Sắp xếp</option>
                    <option value="AttributeName" ${sortBy == 'AttributeName' ? 'selected' : ''}>Tên</option>
                    <option value="AttributeID" ${sortBy == 'AttributeID' ? 'selected' : ''}>ID</option>
                  </select>
                </div>
                <div class="col-md-2">
                  <select name="pageSize" class="form-control" onchange="this.form.submit()">
                    <option value="10" ${pageSize == 10 ? 'selected' : ''}>10/trang</option>
                    <option value="20" ${pageSize == 20 ? 'selected' : ''}>20/trang</option>
                    <option value="50" ${pageSize == 50 ? 'selected' : ''}>50/trang</option>
                  </select>
                </div>
                <div class="col-md-2">
                  <button type="submit" class="btn btn-primary btn-block">
                    <i class="fas fa-search"></i> Tìm
                  </button>
                </div>
              </div>
            </form>

            <!-- Table -->
            <table class="table table-bordered table-hover">
              <thead>
                <tr>
                  <th style="width: 80px;">ID</th>
                  <th>Tên Thuộc tính</th>
                  <th style="width: 120px;">Trạng thái</th>
                  <th style="width: 250px;" class="text-center">Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="attr" items="${attributes}">
                  <tr>
                    <td><strong>#${attr.attributeID}</strong></td>
                    <td><strong>${attr.attributeName}</strong></td>
                    <td>
                      <c:choose>
                        <c:when test="${attr.isActive}">
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
                      <a href="<%= request.getContextPath() %>/admin/attributes?action=values&id=${attr.attributeID}" 
                         class="btn btn-info btn-sm" title="Quản lý giá trị">
                        <i class="fas fa-list"></i> Giá trị
                      </a>
                      <a href="<%= request.getContextPath() %>/admin/attributes?action=edit&id=${attr.attributeID}" 
                         class="btn btn-warning btn-sm" title="Chỉnh sửa">
                        <i class="fas fa-edit"></i>
                      </a>
                      <button type="button" class="btn btn-danger btn-sm" 
                              onclick="confirmDelete(${attr.attributeID}, '${attr.attributeName}')" title="Xóa">
                        <i class="fas fa-trash"></i>
                      </button>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty attributes}">
                  <tr>
                    <td colspan="4" class="text-center">
                      <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                      <p class="text-muted">Không có thuộc tính nào.</p>
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
                    <a class="page-link" href="?page=${currentPage - 1}&search=${search}&status=${status}&sortBy=${sortBy}&pageSize=${pageSize}">
                      <i class="fas fa-chevron-left"></i>
                    </a>
                  </li>
                  <c:forEach begin="1" end="${totalPages}" var="i">
                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                      <a class="page-link" href="?page=${i}&search=${search}&status=${status}&sortBy=${sortBy}&pageSize=${pageSize}">${i}</a>
                    </li>
                  </c:forEach>
                  <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                    <a class="page-link" href="?page=${currentPage + 1}&search=${search}&status=${status}&sortBy=${sortBy}&pageSize=${pageSize}">
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
        <p>Bạn có chắc chắn muốn xóa thuộc tính <strong id="attributeName"></strong>?</p>
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
function confirmDelete(id, name) {
    $('#attributeName').text(name);
    $('#confirmDeleteBtn').attr('href', '<%= request.getContextPath() %>/admin/attributes?action=delete&id=' + id);
    $('#deleteModal').modal('show');
}

// Auto hide alerts after 3 seconds
setTimeout(function() {
    $('.alert').fadeOut('slow');
}, 3000);
</script>
</body>
</html>
