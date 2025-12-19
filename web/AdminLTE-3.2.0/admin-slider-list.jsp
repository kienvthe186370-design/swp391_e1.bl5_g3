
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
        <c:if test="${param.success == 'toggled'}">
          <div class="alert alert-success alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-check"></i> Cập nhật trạng thái slider thành công!
          </div>
        </c:if>
        <c:if test="${param.error == 'notfound'}">
          <div class="alert alert-danger alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-ban"></i> Không tìm thấy slider!
          </div>
        </c:if>
        <c:if test="${param.error == 'toggle_failed'}">
          <div class="alert alert-danger alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-ban"></i> Không thể cập nhật trạng thái slider!
          </div>
        </c:if>
        <c:if test="${param.error == 'no_image'}">
          <div class="alert alert-danger alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-ban"></i> Vui lòng chọn hình ảnh hoặc nhập URL!
          </div>
        </c:if>
        <c:if test="${param.error == 'add_failed'}">
          <div class="alert alert-danger alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-ban"></i> Không thể thêm slider! Vui lòng thử lại.
          </div>
        </c:if>
        <c:if test="${param.error == 'update_failed'}">
          <div class="alert alert-danger alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-ban"></i> Không thể cập nhật slider! Vui lòng thử lại.
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
                <div class="col-md-3">
                  <input type="text" name="search" value="${search}" class="form-control" placeholder="Tìm theo tiêu đề...">
                </div>
                <div class="col-md-2">
                  <select name="status" class="form-control">
                    <option value="">-- Tất cả trạng thái --</option>
                    <option value="active" ${status == 'active' ? 'selected' : ''}>Active</option>
                    <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Inactive</option>
                  </select>
                </div>
                <div class="col-md-2">
                  <select name="sortBy" class="form-control">
                    <option value="">Sắp xếp theo</option>
                    <option value="SliderID" ${sortBy == 'SliderID' ? 'selected' : ''}>ID</option>
                    <option value="Title" ${sortBy == 'Title' ? 'selected' : ''}>Tiêu đề</option>
                    <option value="DisplayOrder" ${sortBy == 'DisplayOrder' ? 'selected' : ''}>Thứ tự</option>
                    <option value="Status" ${sortBy == 'Status' ? 'selected' : ''}>Trạng thái</option>
                  </select>
                </div>
                <div class="col-md-2">
                  <select name="pageSize" class="form-control" onchange="this.form.submit()">
                    <option value="5" ${pageSize == 5 ? 'selected' : ''}>5/trang</option>
                    <option value="10" ${pageSize == 10 ? 'selected' : ''}>10/trang</option>
                    <option value="20" ${pageSize == 20 ? 'selected' : ''}>20/trang</option>
                  </select>
                </div>
                <div class="col-md-2">
                  <button type="submit" class="btn btn-primary btn-block">
                    <i class="fas fa-search"></i> Tìm kiếm
                  </button>
                </div>
                <div class="col-md-1">
                  <a href="<%= request.getContextPath() %>/admin/slider" class="btn btn-secondary btn-block">
                    <i class="fas fa-redo"></i>
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
                          <img src="${pageContext.request.contextPath}/${slider.imageURL}" 
                               alt="${slider.title}" 
                               class="img-thumbnail" 
                               style="max-width: 120px; max-height: 60px; cursor: pointer;"
                               onclick="showImageModal('${pageContext.request.contextPath}/${slider.imageURL}', '${slider.title}')">
                        </c:when>
                        <c:otherwise>
                          <div class="text-center text-muted">
                            <i class="fas fa-image fa-2x"></i>
                          </div>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <strong style="display: block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 500px;" title="${slider.title}">
                        ${slider.title}
                      </strong>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${not empty slider.linkURL}">
                          <a href="${slider.linkURL}" target="_blank" class="text-primary" style="display: block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 200px;" title="${slider.linkURL}">
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
                      <c:choose>
                        <c:when test="${slider.status == 'active'}">
                          <button type="button" class="btn btn-danger btn-sm" 
                                  onclick="confirmToggleStatus(${slider.sliderID}, '${slider.title}', 'inactive')" 
                                  title="Khóa slider">
                            <i class="fas fa-lock"></i>
                          </button>
                        </c:when>
                        <c:otherwise>
                          <button type="button" class="btn btn-success btn-sm" 
                                  onclick="confirmToggleStatus(${slider.sliderID}, '${slider.title}', 'active')" 
                                  title="Mở khóa slider">
                            <i class="fas fa-unlock"></i>
                          </button>
                        </c:otherwise>
                      </c:choose>
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
            <c:if test="${totalSliders > 0}">
              <div class="row mt-3">
                <div class="col-sm-12 col-md-5">
                  <div class="dataTables_info" role="status" aria-live="polite">
                    Hiển thị <strong>${(currentPage-1)*pageSize + 1}</strong> 
                    đến <strong>${currentPage*pageSize > totalSliders ? totalSliders : currentPage*pageSize}</strong> 
                    của <strong>${totalSliders}</strong> slider
                  </div>
                </div>
                <div class="col-sm-12 col-md-7">
                  <div class="dataTables_paginate paging_simple_numbers float-right">
                    <ul class="pagination">
                      <li class="paginate_button page-item previous ${currentPage == 1 ? 'disabled' : ''}">
                        <a href="?page=${currentPage - 1}&search=${search}&status=${status}&sortBy=${sortBy}&pageSize=${pageSize}" 
                           class="page-link">Trước</a>
                      </li>
                      <c:forEach begin="1" end="${totalPages}" var="i">
                        <li class="paginate_button page-item ${currentPage == i ? 'active' : ''}">
                          <a href="?page=${i}&search=${search}&status=${status}&sortBy=${sortBy}&pageSize=${pageSize}" 
                             class="page-link">${i}</a>
                        </li>
                      </c:forEach>
                      <li class="paginate_button page-item next ${currentPage >= totalPages ? 'disabled' : ''}">
                        <a href="?page=${currentPage + 1}&search=${search}&status=${status}&sortBy=${sortBy}&pageSize=${pageSize}" 
                           class="page-link">Sau</a>
                      </li>
                    </ul>
                  </div>
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

<!-- Toggle Status Confirmation Modal -->
<div class="modal fade" id="toggleStatusModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header" id="modalHeader">
        <h4 class="modal-title"><i class="fas fa-exclamation-triangle"></i> <span id="modalTitle"></span></h4>
        <button type="button" class="close" data-dismiss="modal">&times;</button>
      </div>
      <div class="modal-body">
        <p id="modalMessage"></p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">Hủy</button>
        <a href="#" id="confirmToggleBtn" class="btn">
          <i id="modalIcon"></i> <span id="modalBtnText"></span>
        </a>
      </div>
    </div>
  </div>
</div>

<!-- Image Preview Modal -->
<div class="modal fade" id="imageModal">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="imageModalTitle">Xem ảnh Slider</h5>
        <button type="button" class="close" data-dismiss="modal">&times;</button>
      </div>
      <div class="modal-body text-center">
        <img id="imageModalImg" src="" alt="Slider Image" class="img-fluid" style="max-height: 500px;">
      </div>
    </div>
  </div>
</div>

<script>
function confirmToggleStatus(id, title, newStatus) {
    if (newStatus === 'inactive') {
        $('#modalHeader').removeClass('bg-success').addClass('bg-danger');
        $('#modalTitle').text('Xác nhận khóa slider');
        $('#modalMessage').html('Bạn có chắc chắn muốn <strong>khóa</strong> slider <strong>' + title + '</strong>?<br><small class="text-muted">Slider sẽ không hiển thị trên trang chủ.</small>');
        $('#confirmToggleBtn').removeClass('btn-success').addClass('btn-danger');
        $('#modalIcon').removeClass('fa-unlock').addClass('fa-lock');
        $('#modalBtnText').text('Khóa');
    } else {
        $('#modalHeader').removeClass('bg-danger').addClass('bg-success');
        $('#modalTitle').text('Xác nhận mở khóa slider');
        $('#modalMessage').html('Bạn có chắc chắn muốn <strong>mở khóa</strong> slider <strong>' + title + '</strong>?<br><small class="text-muted">Slider sẽ hiển thị trên trang chủ.</small>');
        $('#confirmToggleBtn').removeClass('btn-danger').addClass('btn-success');
        $('#modalIcon').removeClass('fa-lock').addClass('fa-unlock');
        $('#modalBtnText').text('Mở khóa');
    }
    $('#confirmToggleBtn').attr('href', '<%= request.getContextPath() %>/admin/slider?action=toggleStatus&id=' + id);
    $('#toggleStatusModal').modal('show');
}

function showImageModal(imageSrc, title) {
    $('#imageModalImg').attr('src', imageSrc);
    $('#imageModalTitle').text(title);
    $('#imageModal').modal('show');
}

// Auto hide alerts after 3 seconds
setTimeout(function() {
    $('.alert').fadeOut('slow');
}, 3000);
</script>
