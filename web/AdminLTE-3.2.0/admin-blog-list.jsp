<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
  <title>Quản lý Blog - Admin</title>

  <!-- Google Font: Source Sans Pro -->
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
  <!-- Font Awesome -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/fontawesome-free/css/all.min.css">
  <!-- DataTables -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/datatables-bs4/css/dataTables.bootstrap4.min.css">
  <!-- Theme style -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/css/adminlte.min.css">
  <style>
    .text-truncate-2 {
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
      text-overflow: ellipsis;
      max-width: 100%;
    }
  </style>
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">

  <!-- Navbar -->
  <jsp:include page="includes/admin-header.jsp" />

  <!-- Sidebar -->
  <jsp:include page="includes/admin-sidebar.jsp" />

  <!-- Content Wrapper -->
  <div class="content-wrapper">
    <!-- Content Header -->
    <section class="content-header">
      <div class="container-fluid">
        <div class="row mb-2">
          <div class="col-sm-6">
            <h1><i class="fas fa-blog"></i> Quản lý Blog</h1>
          </div>
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp">Home</a></li>
              <li class="breadcrumb-item active">Blog</li>
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
            <i class="icon fas fa-check"></i> Thêm bài viết thành công!
          </div>
        </c:if>
        <c:if test="${param.success == 'updated'}">
          <div class="alert alert-success alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-check"></i> Cập nhật bài viết thành công!
          </div>
        </c:if>
        <c:if test="${param.success == 'deleted'}">
          <div class="alert alert-success alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-check"></i> Chuyển bài viết về nháp thành công!
          </div>
        </c:if>
        <c:if test="${param.success == 'toggled'}">
          <div class="alert alert-success alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-check"></i> Cập nhật trạng thái bài viết thành công!
          </div>
        </c:if>
        <c:if test="${param.error == 'notfound'}">
          <div class="alert alert-danger alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-ban"></i> Không tìm thấy bài viết!
          </div>
        </c:if>

        <!-- Main Card -->
        <div class="card">
          <div class="card-header">
            <h3 class="card-title">Danh sách Blog</h3>
            <div class="card-tools">
              <a href="<%= request.getContextPath() %>/admin/blog?action=add" class="btn btn-primary btn-sm">
                <i class="fas fa-plus"></i> Thêm Bài Viết Mới
              </a>
            </div>
          </div>
          
          <!-- Card Body -->
          <div class="card-body">
            <!-- Filter Form -->
            <form method="get" action="<%= request.getContextPath() %>/admin/blog" class="mb-3">
              <div class="row">
                <div class="col-md-3">
                  <input type="text" name="search" value="${search}" class="form-control" placeholder="Tìm theo tiêu đề...">
                </div>
                <div class="col-md-2">
                  <select name="status" class="form-control">
                    <option value="">-- Tất cả trạng thái --</option>
                    <option value="published" ${status == 'published' ? 'selected' : ''}>Đã xuất bản</option>
                    <option value="draft" ${status == 'draft' ? 'selected' : ''}>Nháp</option>
                  </select>
                </div>
                <div class="col-md-2">
                  <select name="sortBy" class="form-control">
                    <option value="">Sắp xếp theo</option>
                    <option value="PostID" ${sortBy == 'PostID' ? 'selected' : ''}>ID</option>
                    <option value="Title" ${sortBy == 'Title' ? 'selected' : ''}>Tiêu đề</option>
                    <option value="PublishedDate" ${sortBy == 'PublishedDate' ? 'selected' : ''}>Ngày xuất bản</option>
                    <option value="ViewCount" ${sortBy == 'ViewCount' ? 'selected' : ''}>Lượt xem</option>
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
                  <a href="<%= request.getContextPath() %>/admin/blog" class="btn btn-secondary btn-block">
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
                  <th style="width: 140px;">Ảnh</th>
                  <th>Tiêu đề</th>
                  <th style="width: 150px;">Tác giả</th>
                  <th style="width: 80px;">Lượt xem</th>
                  <th style="width: 140px;">Ngày xuất bản</th>
                  <th style="width: 100px;">Trạng thái</th>
                  <th style="width: 120px;" class="text-center">Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="blog" items="${blogs}">
                  <tr>
                    <td><strong>#${blog.postId}</strong></td>
                    <td>
                      <c:choose>
                        <c:when test="${not empty blog.featuredImage}">
                          <c:set var="blogImageUrl" value="${blog.featuredImage.startsWith('http://') || blog.featuredImage.startsWith('https://') || blog.featuredImage.startsWith('/') ? blog.featuredImage : pageContext.request.contextPath.concat('/').concat(blog.featuredImage)}" />
                          <img src="${blogImageUrl}" 
                               alt="${blog.title}" 
                               class="img-thumbnail" 
                               style="max-width: 120px; max-height: 60px; cursor: pointer;"
                               onclick="showImageModal('${blogImageUrl}', '${blog.title}')">
                        </c:when>
                        <c:otherwise>
                          <div class="text-center text-muted">
                            <i class="fas fa-image fa-2x"></i>
                          </div>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <strong style="display: block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 400px;" title="${blog.title}">${blog.title}</strong>
                      <c:if test="${not empty blog.summary}">
                        <small class="text-muted text-truncate-2" title="${blog.summary}">
                          ${blog.summary}
                        </small>
                      </c:if>
                    </td>
                    <td style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="${blog.authorName}">${blog.authorName}</td>
                    <td><span class="badge badge-info">${blog.viewCount}</span></td>
                    <td>
                      <c:choose>
                        <c:when test="${blog.publishedDate != null}">
                          <small>${blog.publishedDate.toString().substring(0, 16).replace('T', ' ')}</small>
                        </c:when>
                        <c:otherwise>
                          <span class="text-muted">Chưa xuất bản</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${blog.status == 'published'}">
                          <span class="badge badge-success">
                            <i class="fas fa-check-circle"></i> Đã xuất bản
                          </span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge badge-secondary">
                            <i class="fas fa-file"></i> Nháp
                          </span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td class="text-center">
                      <a href="<%= request.getContextPath() %>/admin/blog?action=edit&id=${blog.postId}" 
                         class="btn btn-warning btn-sm" title="Chỉnh sửa">
                        <i class="fas fa-edit"></i>
                      </a>
                      <c:choose>
                        <c:when test="${blog.status == 'published'}">
                          <button type="button" class="btn btn-secondary btn-sm" 
                                  onclick="confirmToggleStatus(${blog.postId}, '${blog.title}', false)" 
                                  title="Chuyển về nháp">
                            <i class="fas fa-eye-slash"></i>
                          </button>
                        </c:when>
                        <c:otherwise>
                          <button type="button" class="btn btn-success btn-sm" 
                                  onclick="confirmToggleStatus(${blog.postId}, '${blog.title}', true)" 
                                  title="Xuất bản">
                            <i class="fas fa-eye"></i>
                          </button>
                        </c:otherwise>
                      </c:choose>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty blogs}">
                  <tr>
                    <td colspan="8" class="text-center">
                      <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                      <p class="text-muted">Không có bài viết nào.</p>
                    </td>
                  </tr>
                </c:if>
              </tbody>
            </table>

            <!-- Pagination -->
            <c:if test="${totalBlogs > 0}">
              <div class="row mt-3">
                <div class="col-sm-12 col-md-5">
                  <div class="dataTables_info" role="status" aria-live="polite">
                    Hiển thị <strong>${(currentPage-1)*pageSize + 1}</strong> 
                    đến <strong>${currentPage*pageSize > totalBlogs ? totalBlogs : currentPage*pageSize}</strong> 
                    của <strong>${totalBlogs}</strong> bài viết
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
        <h5 class="modal-title" id="imageModalTitle">Xem ảnh đại diện</h5>
        <button type="button" class="close" data-dismiss="modal">&times;</button>
      </div>
      <div class="modal-body text-center">
        <img id="imageModalImg" src="" alt="Blog Image" class="img-fluid" style="max-height: 500px;">
      </div>
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
function confirmToggleStatus(id, title, isPublishing) {
    if (isPublishing) {
        $('#modalHeader').removeClass('bg-secondary').addClass('bg-success');
        $('#modalTitle').text('Xác nhận xuất bản');
        $('#modalMessage').html('Bạn có chắc chắn muốn <strong>xuất bản</strong> bài viết <strong>' + title + '</strong>?<br><small class="text-muted">Bài viết sẽ hiển thị công khai.</small>');
        $('#confirmToggleBtn').removeClass('btn-secondary').addClass('btn-success');
        $('#modalIcon').removeClass('fa-eye-slash').addClass('fa-eye');
        $('#modalBtnText').text('Xuất bản');
    } else {
        $('#modalHeader').removeClass('bg-success').addClass('bg-secondary');
        $('#modalTitle').text('Xác nhận chuyển về nháp');
        $('#modalMessage').html('Bạn có chắc chắn muốn <strong>chuyển về nháp</strong> bài viết <strong>' + title + '</strong>?<br><small class="text-muted">Bài viết sẽ không hiển thị công khai.</small>');
        $('#confirmToggleBtn').removeClass('btn-success').addClass('btn-secondary');
        $('#modalIcon').removeClass('fa-eye').addClass('fa-eye-slash');
        $('#modalBtnText').text('Chuyển về nháp');
    }
    $('#confirmToggleBtn').attr('href', '<%= request.getContextPath() %>/admin/blog?action=toggleStatus&id=' + id);
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

</body>
</html>
