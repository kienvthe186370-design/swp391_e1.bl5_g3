
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
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${slider != null ? 'Chỉnh sửa' : 'Thêm mới'} Slider - Admin</title>

  <!-- Google Font: Source Sans Pro -->
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
  <!-- Font Awesome -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/fontawesome-free/css/all.min.css">
  <!-- Theme style -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/css/adminlte.min.css">
  <style>
    .image-preview {
      max-width: 100%;
      max-height: 300px;
      border: 2px dashed #dee2e6;
      border-radius: 8px;
      padding: 10px;
      display: none;
    }
    .image-preview.show {
      display: block;
    }
  </style>
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
            <h1>
              <i class="fas fa-images"></i> 
              ${slider != null ? 'Chỉnh sửa Slider' : 'Thêm Slider Mới'}
            </h1>
          </div>
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp">Home</a></li>
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/admin/slider">Slider</a></li>
              <li class="breadcrumb-item active">${slider != null ? 'Chỉnh sửa' : 'Thêm mới'}</li>
            </ol>
          </div>
        </div>
      </div>
    </section>

    <!-- Main content -->
    <section class="content">
      <div class="container-fluid">
        <div class="row">
          <!-- Form Column -->
          <div class="col-md-8">
            <div class="card card-primary">
              <div class="card-header">
                <h3 class="card-title">Thông tin Slider</h3>
              </div>
              
              <form method="post" action="<%= request.getContextPath() %>/admin/slider" id="sliderForm">
                <input type="hidden" name="action" value="${slider != null ? 'update' : 'add'}">
                <c:if test="${slider != null}">
                  <input type="hidden" name="id" value="${slider.sliderID}">
                </c:if>

                <div class="card-body">
                  <!-- Title -->
                  <div class="form-group">
                    <label for="title">Tiêu đề Slider <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="title" name="title" 
                           value="${slider != null ? slider.title : ''}" 
                           placeholder="Nhập tiêu đề slider..." required>
                    <small class="form-text text-muted">Tiêu đề mô tả cho slider (tối đa 200 ký tự)</small>
                  </div>

                  <!-- Image URL -->
                  <div class="form-group">
                    <label for="imageURL">URL Hình ảnh <span class="text-danger">*</span></label>
                    <input type="url" class="form-control" id="imageURL" name="imageURL" 
                           value="${slider != null ? slider.imageURL : ''}" 
                           placeholder="https://example.com/image.jpg" 
                           onchange="previewImage()" required>
                    <small class="form-text text-muted">Nhập URL đầy đủ của hình ảnh slider</small>
                    
                    <!-- Image Preview -->
                    <div class="mt-3 text-center">
                      <img id="imagePreview" class="image-preview ${slider != null && slider.imageURL != null ? 'show' : ''}" 
                           src="${slider != null ? slider.imageURL : ''}" alt="Preview">
                    </div>
                  </div>

                  <!-- Link URL -->
                  <div class="form-group">
                    <label for="linkURL">Link URL</label>
                    <input type="url" class="form-control" id="linkURL" name="linkURL" 
                           value="${slider != null ? slider.linkURL : ''}" 
                           placeholder="https://example.com/page">
                    <small class="form-text text-muted">URL trang đích khi click vào slider (có thể để trống)</small>
                  </div>

                  <!-- Display Order -->
                  <div class="form-group">
                    <label for="displayOrder">Thứ tự hiển thị <span class="text-danger">*</span></label>
                    <input type="number" class="form-control" id="displayOrder" name="displayOrder" 
                           value="${slider != null ? slider.displayOrder : 1}" 
                           min="1" max="100" required>
                    <small class="form-text text-muted">Số thứ tự hiển thị (1 = hiển thị đầu tiên)</small>
                  </div>

                  <!-- Status -->
                  <div class="form-group">
                    <label for="status">Trạng thái <span class="text-danger">*</span></label>
                    <select class="form-control" id="status" name="status" required>
                      <option value="active" ${slider == null || slider.status == 'active' ? 'selected' : ''}>
                        Active - Hiển thị
                      </option>
                      <option value="inactive" ${slider != null && slider.status == 'inactive' ? 'selected' : ''}>
                        Inactive - Ẩn
                      </option>
                    </select>
                    <small class="form-text text-muted">Chọn trạng thái hiển thị của slider</small>
                  </div>
                </div>

                <div class="card-footer">
                  <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> ${slider != null ? 'Cập nhật' : 'Thêm mới'}
                  </button>
                  <a href="<%= request.getContextPath() %>/admin/slider" class="btn btn-default">
                    <i class="fas fa-times"></i> Hủy
                  </a>
                </div>
              </form>
            </div>
          </div>

          <!-- Info Column -->
          <div class="col-md-4">
            <!-- Guidelines -->
            <div class="card card-info">
              <div class="card-header">
                <h3 class="card-title"><i class="fas fa-info-circle"></i> Hướng dẫn</h3>
              </div>
              <div class="card-body">
                <h6><i class="fas fa-lightbulb"></i> Lưu ý:</h6>
                <ul class="pl-3">
                  <li>Hình ảnh nên có kích thước <strong>1920x600px</strong></li>
                  <li>Định dạng: <strong>JPG, PNG</strong></li>
                  <li>Dung lượng tối đa: <strong>2MB</strong></li>
                  <li>Thứ tự nhỏ hơn hiển thị trước</li>
                </ul>

                <h6 class="mt-3"><i class="fas fa-exclamation-triangle"></i> Khuyến nghị:</h6>
                <ul class="pl-3">
                  <li>Sử dụng hình ảnh chất lượng cao</li>
                  <li>Nội dung rõ ràng, dễ đọc</li>
                  <li>Tránh quá nhiều text trên ảnh</li>
                  <li>Test trên nhiều thiết bị</li>
                </ul>
              </div>
            </div>

            <!-- Slider Info (if editing) -->
            <c:if test="${slider != null}">
              <div class="card card-secondary">
                <div class="card-header">
                  <h3 class="card-title"><i class="fas fa-database"></i> Thông tin</h3>
                </div>
                <div class="card-body">
                  <p><strong>ID:</strong> #${slider.sliderID}</p>
                  <p><strong>Trạng thái:</strong> 
                    <span class="badge ${slider.status == 'active' ? 'badge-success' : 'badge-danger'}">
                      ${slider.status}
                    </span>
                  </p>
                </div>
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

<!-- jQuery -->
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/jquery/jquery.min.js"></script>
<!-- Bootstrap 4 -->
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<!-- AdminLTE App -->
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/js/adminlte.min.js"></script>

<script>
// Preview image when URL is entered
function previewImage() {
    const imageURL = $('#imageURL').val();
    const preview = $('#imagePreview');
    
    if (imageURL) {
        preview.attr('src', imageURL);
        preview.addClass('show');
        
        // Handle image load error
        preview.on('error', function() {
            preview.removeClass('show');
            alert('Không thể tải hình ảnh. Vui lòng kiểm tra lại URL.');
        });
    } else {
        preview.removeClass('show');
    }
}

// Form validation
$('#sliderForm').on('submit', function(e) {
    const title = $('#title').val().trim();
    const imageURL = $('#imageURL').val().trim();
    const displayOrder = $('#displayOrder').val();
    
    if (!title) {
        e.preventDefault();
        alert('Vui lòng nhập tiêu đề slider!');
        $('#title').focus();
        return false;
    }
    
    if (!imageURL) {
        e.preventDefault();
        alert('Vui lòng nhập URL hình ảnh!');
        $('#imageURL').focus();
        return false;
    }
    
    if (displayOrder < 1 || displayOrder > 100) {
        e.preventDefault();
        alert('Thứ tự hiển thị phải từ 1 đến 100!');
        $('#displayOrder').focus();
        return false;
    }
    
    return true;
});

// Load preview on page load if editing
$(document).ready(function() {
    const imageURL = $('#imageURL').val();
    if (imageURL) {
        previewImage();
    }
});
</script>
</body>
</html>
