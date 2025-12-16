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
  <!-- Theme style -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/css/adminlte.min.css">
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

        <!-- Filter and Search Card -->
        <div class="card card-primary card-outline">
          <div class="card-header">
            <h3 class="card-title"><i class="fas fa-filter"></i> Tìm kiếm & Lọc</h3>
            <div class="card-tools">
              <button type="button" class="btn btn-tool" data-card-widget="collapse">
                <i class="fas fa-minus"></i>
              </button>
            </div>
          </div>
          <div class="card-body">
            <form method="get" action="<%= request.getContextPath() %>/admin/blog">
              <div class="row">
                <div class="col-md-4">
                  <div class="form-group">
                    <label>Tìm kiếm</label>
                    <input type="text" name="search" class="form-control" placeholder="Tiêu đề bài viết..." value="${search}">
                  </div>
                </div>
                <div class="col-md-2">
                  <div class="form-group">
                    <label>Trạng thái</label>
                    <select name="status" class="form-control">
                      <option value="">Tất cả</option>
                      <option value="published" ${status == 'published' ? 'selected' : ''}>Đã xuất bản</option>
                      <option value="draft" ${status == 'draft' ? 'selected' : ''}>Nháp</option>
                    </select>
                  </div>
                </div>
                <div class="col-md-2">
                  <div class="form-group">
                    <label>Số bài/trang</label>
                    <select name="pageSize" class="form-control">
                      <option value="5" ${pageSize == 5 ? 'selected' : ''}>5</option>
                      <option value="10" ${pageSize == 10 ? 'selected' : ''}>10</option>
                      <option value="20" ${pageSize == 20 ? 'selected' : ''}>20</option>
                    </select>
                  </div>
                </div>
                <div class="col-md-4">
                  <div class="form-group">
                    <label>&nbsp;</label>
                    <button type="submit" class="btn btn-primary btn-block"><i class="fas fa-search"></i> Tìm</button>
                  </div>
                </div>
              </div>
            </form>
          </div>
        </div>

        <!-- Blog List Card -->
        <div class="card">
          <div class="card-header">
            <h3 class="card-title">Danh sách Blog (${totalBlogs} bài viết)</h3>
            <div class="card-tools">
              <a href="<%= request.getContextPath() %>/admin/blog?action=add" class="btn btn-success btn-sm">
                <i class="fas fa-plus"></i> Thêm Bài Viết
              </a>
            </div>
          </div>
          <div class="card-body table-responsive p-0">
            <table class="table table-hover text-nowrap">
              <thead>
                <tr>
                  <th>ID</th>
                  <th style="width: 100px;">Ảnh</th>
                  <th>Tiêu đề</th>
                  <th>Tác giả</th>
                  <th>Lượt xem</th>
                  <th>Ngày xuất bản</th>
                  <th>Trạng thái</th>
                  <th>Hành động</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="blog" items="${blogs}">
                  <tr>
                    <td>${blog.postId}</td>
                    <td>
                      <c:choose>
                        <c:when test="${not empty blog.featuredImage}">
                          <c:set var="blogImageUrl" value="${blog.featuredImage.startsWith('http://') || blog.featuredImage.startsWith('https://') || blog.featuredImage.startsWith('/') ? blog.featuredImage : pageContext.request.contextPath.concat('/').concat(blog.featuredImage)}" />
                          <img src="${blogImageUrl}" 
                               alt="${blog.title}" 
                               class="img-thumbnail" 
                               style="max-width: 80px; max-height: 60px; object-fit: cover; cursor: pointer;"
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
                      <strong>${blog.title}</strong>
                      <c:if test="${not empty blog.summary}">
                        <br><small class="text-muted">
                          ${blog.summary.length() > 80 ? blog.summary.substring(0, 80).concat('...') : blog.summary}
                        </small>
                      </c:if>
                    </td>
                    <td>${blog.authorName}</td>
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
                          <span class="badge badge-success">Đã xuất bản</span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge badge-secondary">Nháp</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <div class="btn-group">
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
                      </div>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty blogs}">
                  <tr>
                    <td colspan="8" class="text-center">Không có bài viết nào.</td>
                  </tr>
                </c:if>
              </tbody>
            </table>
          </div>
          
          <!-- Pagination -->
          <div class="card-footer clearfix">
            <ul class="pagination pagination-sm m-0 float-right">
              <c:if test="${currentPage > 1}">
                <li class="page-item">
                  <a class="page-link" href="?page=${currentPage - 1}&search=${search}&status=${status}&pageSize=${pageSize}">«</a>
                </li>
              </c:if>
              
              <c:forEach begin="1" end="${totalPages}" var="i">
                <li class="page-item ${currentPage == i ? 'active' : ''}">
                  <a class="page-link" href="?page=${i}&search=${search}&status=${status}&pageSize=${pageSize}">${i}</a>
                </li>
              </c:forEach>
              
              <c:if test="${currentPage < totalPages}">
                <li class="page-item">
                  <a class="page-link" href="?page=${currentPage + 1}&search=${search}&status=${status}&pageSize=${pageSize}">»</a>
                </li>
              </c:if>
            </ul>
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

// Auto hide alerts after 5 seconds
setTimeout(function() {
    $('.alert').fadeOut('slow');
}, 5000);
</script>

</body>
</html>
