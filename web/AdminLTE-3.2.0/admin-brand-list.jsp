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
  <title>Quản lý Thương hiệu - Admin</title>

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
  <jsp:include page="includes/admin-header.jsp" />

  <!-- Sidebar - Using unified sidebar component -->
  <jsp:include page="includes/admin-sidebar.jsp" />

  <!-- Content Wrapper -->
  <div class="content-wrapper">
    <!-- Content Header -->
    <section class="content-header">
      <div class="container-fluid">
        <div class="row mb-2">
          <div class="col-sm-6">
            <h1><i class="fas fa-copyright"></i> Quản lý Thương hiệu</h1>
          </div>
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp">Home</a></li>
              <li class="breadcrumb-item active">Thương hiệu</li>
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
            <i class="icon fas fa-check"></i> Thêm thương hiệu thành công!
          </div>
        </c:if>
        <c:if test="${param.msg == 'update_success'}">
          <div class="alert alert-success alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-check"></i> Cập nhật thương hiệu thành công!
          </div>
        </c:if>
        <c:if test="${param.msg == 'delete_success'}">
          <div class="alert alert-success alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-check"></i> Xóa thương hiệu thành công!
          </div>
        </c:if>

        <!-- Main Card -->
        <div class="card">
          <div class="card-header">
            <h3 class="card-title">Danh sách Thương hiệu</h3>
            <div class="card-tools">
              <a href="<%= request.getContextPath() %>/admin/brands?action=add" class="btn btn-primary btn-sm">
                <i class="fas fa-plus"></i> Thêm Thương hiệu Mới
              </a>
            </div>
          </div>
          
          <!-- Card Body -->
          <div class="card-body">
            <!-- Filter Form -->
            <form method="get" action="<%= request.getContextPath() %>/admin/brands" class="mb-3">
              <div class="row">
                <div class="col-md-4">
                  <input type="text" name="search" value="${search}" class="form-control" placeholder="Tìm theo tên thương hiệu...">
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
                    <option value="BrandName" ${sortBy == 'BrandName' ? 'selected' : ''}>Tên</option>
                    <option value="BrandID" ${sortBy == 'BrandID' ? 'selected' : ''}>ID</option>
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
                  <th style="width: 60px;">ID</th>
                  <th>Tên Thương hiệu</th>
                  <th style="width: 140px;">Logo</th>
                  <th>Mô tả</th>
                  <th style="width: 100px;">Trạng thái</th>
                  <th style="width: 150px;" class="text-center">Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="brand" items="${brands}">
                  <tr>
                    <td><strong>#${brand.brandID}</strong></td>
                    <td><strong>${brand.brandName}</strong></td>
                    <td>
                      <c:choose>
                        <c:when test="${not empty brand.logo}">
                          <img src="${brand.logo}" alt="${brand.brandName}" class="img-thumbnail" style="max-width: 120px; max-height: 60px;">
                        </c:when>
                        <c:otherwise>
                          <div class="text-center text-muted">
                            <i class="fas fa-image fa-2x"></i>
                          </div>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td><small>${brand.description}</small></td>
                    <td>
                      <c:choose>
                        <c:when test="${brand.isActive}">
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
                      <a href="<%= request.getContextPath() %>/admin/brands?action=edit&id=${brand.brandID}" 
                         class="btn btn-warning btn-sm" title="Chỉnh sửa">
                        <i class="fas fa-edit"></i>
                      </a>
                      <button type="button" class="btn btn-danger btn-sm" 
                              onclick="confirmDelete(${brand.brandID}, '${brand.brandName}')" title="Xóa">
                        <i class="fas fa-trash"></i>
                      </button>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty brands}">
                  <tr>
                    <td colspan="6" class="text-center">
                      <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                      <p class="text-muted">Không có thương hiệu nào.</p>
                    </td>
                  </tr>
                </c:if>
              </tbody>
            </table>

            <!-- Pagination -->
            <c:if test="${totalRecords > 0}">
              <div class="row mt-3">
                <div class="col-sm-12 col-md-5">
                  <div class="dataTables_info" role="status" aria-live="polite">
                    Hiển thị <strong>${(currentPage-1)*pageSize + 1}</strong> 
                    đến <strong>${currentPage*pageSize > totalRecords ? totalRecords : currentPage*pageSize}</strong> 
                    của <strong>${totalRecords}</strong> bản ghi
                  </div>
                </div>
                <div class="col-sm-12 col-md-7">
                  <c:if test="${totalRecords > 0}">
                    <div class="dataTables_paginate paging_simple_numbers float-right">
                      <ul class="pagination">
                      <li class="paginate_button page-item previous ${currentPage == 1 ? 'disabled' : ''}">
                        <a href="?page=${currentPage - 1}&search=${search}&status=${status}&sortBy=${sortBy}&sortOrder=${sortOrder}&pageSize=${pageSize}" 
                           class="page-link">Trước</a>
                      </li>
                      
                      <c:choose>
                        <c:when test="${totalPages <= 7}">
                          <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="paginate_button page-item ${currentPage == i ? 'active' : ''}">
                              <a href="?page=${i}&search=${search}&status=${status}&sortBy=${sortBy}&sortOrder=${sortOrder}&pageSize=${pageSize}" 
                                 class="page-link">${i}</a>
                            </li>
                          </c:forEach>
                        </c:when>
                        <c:otherwise>
                          <c:if test="${currentPage > 3}">
                            <li class="paginate_button page-item">
                              <a href="?page=1&search=${search}&status=${status}&sortBy=${sortBy}&sortOrder=${sortOrder}&pageSize=${pageSize}" 
                                 class="page-link">1</a>
                            </li>
                            <c:if test="${currentPage > 4}">
                              <li class="paginate_button page-item disabled"><span class="page-link">...</span></li>
                            </c:if>
                          </c:if>
                          
                          <c:forEach begin="1" end="${totalPages}" var="i">
                            <c:if test="${i >= currentPage - 2 && i <= currentPage + 2}">
                              <li class="paginate_button page-item ${currentPage == i ? 'active' : ''}">
                                <a href="?page=${i}&search=${search}&status=${status}&sortBy=${sortBy}&sortOrder=${sortOrder}&pageSize=${pageSize}" 
                                   class="page-link">${i}</a>
                              </li>
                            </c:if>
                          </c:forEach>
                          
                          <c:if test="${currentPage < totalPages - 2}">
                            <c:if test="${currentPage < totalPages - 3}">
                              <li class="paginate_button page-item disabled"><span class="page-link">...</span></li>
                            </c:if>
                            <li class="paginate_button page-item">
                              <a href="?page=${totalPages}&search=${search}&status=${status}&sortBy=${sortBy}&sortOrder=${sortOrder}&pageSize=${pageSize}" 
                                 class="page-link">${totalPages}</a>
                            </li>
                          </c:if>
                        </c:otherwise>
                      </c:choose>
                      
                      <li class="paginate_button page-item next ${currentPage >= totalPages ? 'disabled' : ''}">
                        <a href="?page=${currentPage + 1}&search=${search}&status=${status}&sortBy=${sortBy}&sortOrder=${sortOrder}&pageSize=${pageSize}" 
                           class="page-link">Sau</a>
                      </li>
                    </ul>
                  </div>
                  </c:if>
                </div>
              </div>
            </c:if>
          </div>
        </div>
      </div>
    </section>
  </div>

  <!-- Footer -->
  <jsp:include page="includes/admin-footer.jsp" />

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header bg-danger">
        <h4 class="modal-title"><i class="fas fa-exclamation-triangle"></i> Xác nhận xóa</h4>
        <button type="button" class="close" data-dismiss="modal">&times;</button>
      </div>
      <div class="modal-body">
        <p>Bạn có chắc chắn muốn xóa thương hiệu <strong id="brandName"></strong>?</p>
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

<script>
function confirmDelete(id, name) {
    $('#brandName').text(name);
    $('#confirmDeleteBtn').attr('href', '<%= request.getContextPath() %>/admin/brands?action=delete&id=' + id);
    $('#deleteModal').modal('show');
}

// Auto hide alerts after 3 seconds
setTimeout(function() {
    $('.alert').fadeOut('slow');
}, 3000);
</script>
