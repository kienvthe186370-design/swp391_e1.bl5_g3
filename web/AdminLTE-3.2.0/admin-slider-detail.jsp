
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
              
              <form method="post" action="<%= request.getContextPath() %>/admin/slider" id="sliderForm" enctype="multipart/form-data">
                <input type="hidden" name="action" value="${slider != null ? 'update' : 'add'}">
                <c:if test="${slider != null}">
                  <input type="hidden" name="id" value="${slider.sliderID}">
                  <input type="hidden" name="currentImageURL" value="${slider.imageURL}">
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

                  <!-- Image Upload Options -->
                  <div class="form-group">
                    <label>Hình ảnh Slider <span class="text-danger">*</span></label>
                    
                    <!-- Upload Method Tabs -->
                    <ul class="nav nav-tabs" id="uploadTabs" role="tablist">
                      <li class="nav-item">
                        <a class="nav-link active" id="upload-tab" data-toggle="tab" href="#uploadMethod" role="tab">
                          <i class="fas fa-upload"></i> Upload từ máy
                        </a>
                      </li>
                      <li class="nav-item">
                        <a class="nav-link" id="url-tab" data-toggle="tab" href="#urlMethod" role="tab">
                          <i class="fas fa-link"></i> Nhập URL
                        </a>
                      </li>
                    </ul>
                    
                    <div class="tab-content border border-top-0 p-3" id="uploadTabContent">
                      <!-- Upload from Computer -->
                      <div class="tab-pane fade show active" id="uploadMethod" role="tabpanel">
                        <div class="custom-file">
                          <input type="file" class="custom-file-input" id="imageFile" name="imageFile" 
                                 accept="image/jpeg,image/png,image/jpg,image/gif" onchange="previewUploadedImage(this)">
                          <label class="custom-file-label" for="imageFile">Chọn file ảnh...</label>
                        </div>
                        <small class="form-text text-muted">
                          <i class="fas fa-info-circle"></i> Chấp nhận: JPG, PNG, GIF. Tối đa 5MB. Khuyến nghị: 1920x600px
                        </small>
                      </div>
                      
                      <!-- URL Method -->
                      <div class="tab-pane fade" id="urlMethod" role="tabpanel">
                        <input type="text" class="form-control" id="imageURL" name="imageURL" 
                               value="${slider != null ? slider.imageURL : ''}" 
                               placeholder="img/sliders/image.jpg hoặc https://example.com/image.jpg">
                        <small class="form-text text-muted">
                          <i class="fas fa-info-circle"></i> Nhập đường dẫn ảnh (relative path) hoặc URL đầy đủ
                        </small>
                      </div>
                    </div>
                    
                    <!-- Image Preview -->
                    <div class="mt-3 text-center">
                      <c:choose>
                        <c:when test="${slider != null && slider.imageURL != null}">
                          <c:set var="previewSrc" value="${slider.imageURL.startsWith('http://') || slider.imageURL.startsWith('https://') || slider.imageURL.startsWith('/') ? slider.imageURL : pageContext.request.contextPath.concat('/').concat(slider.imageURL)}" />
                          <img id="imagePreview" class="image-preview show" src="${previewSrc}" alt="Preview">
                        </c:when>
                        <c:otherwise>
                          <img id="imagePreview" class="image-preview" src="" alt="Preview">
                        </c:otherwise>
                      </c:choose>
                      <div id="imageInfo" class="text-muted small mt-2" style="display: none;"></div>
                    </div>
                  </div>

                  <!-- Link URL -->
                  <div class="form-group">
                    <label for="linkURL">Link URL</label>
                    <input type="text" class="form-control" id="linkURL" name="linkURL" 
                           value="${slider != null ? slider.linkURL : ''}" 
                           placeholder="/shop hoặc https://example.com/page">
                    <small class="form-text text-muted">Đường dẫn hoặc URL trang đích khi click vào slider (có thể để trống)</small>
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
  <jsp:include page="includes/admin-footer.jsp" />

</div>
<!-- ./wrapper -->

<!-- jQuery -->
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/jquery/jquery.min.js"></script>
<!-- Bootstrap 4 -->
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<!-- AdminLTE App -->
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/js/adminlte.min.js"></script>

<script>
// Preview uploaded image from file input
function previewUploadedImage(input) {
    const preview = $('#imagePreview');
    const imageInfo = $('#imageInfo');
    const label = $(input).next('.custom-file-label');
    
    if (input.files && input.files[0]) {
        const file = input.files[0];
        
        // Update label
        label.text(file.name);
        
        // Validate file size (5MB)
        if (file.size > 5 * 1024 * 1024) {
            alert('File quá lớn! Vui lòng chọn file nhỏ hơn 5MB.');
            input.value = '';
            label.text('Chọn file ảnh...');
            preview.removeClass('show');
            imageInfo.hide();
            return;
        }
        
        // Validate file type
        const validTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'];
        if (!validTypes.includes(file.type)) {
            alert('Định dạng file không hợp lệ! Chỉ chấp nhận JPG, PNG, GIF.');
            input.value = '';
            label.text('Chọn file ảnh...');
            preview.removeClass('show');
            imageInfo.hide();
            return;
        }
        
        // Preview image
        const reader = new FileReader();
        reader.onload = function(e) {
            preview.attr('src', e.target.result);
            preview.addClass('show');
            
            // Show file info
            const sizeKB = (file.size / 1024).toFixed(2);
            imageInfo.html('<i class="fas fa-file-image"></i> ' + file.name + ' (' + sizeKB + ' KB)');
            imageInfo.show();
        };
        reader.readAsDataURL(file);
    } else {
        label.text('Chọn file ảnh...');
        preview.removeClass('show');
        imageInfo.hide();
    }
}

// Preview image when URL is entered
function previewImageURL(showAlert = true) {
    const imageURL = $('#imageURL').val();
    const preview = $('#imagePreview');
    const imageInfo = $('#imageInfo');
    
    if (imageURL) {
        // Remove old error handler
        preview.off('error');
        preview.off('load');
        
        // Build correct image path
        let imageSrc = imageURL;
        // If it's a relative path (not starting with http:// or https:// or /), prepend context path
        if (!imageURL.startsWith('http://') && !imageURL.startsWith('https://') && !imageURL.startsWith('/')) {
            imageSrc = '<%= request.getContextPath() %>/' + imageURL;
        }
        
        preview.attr('src', imageSrc);
        preview.addClass('show');
        imageInfo.html('<i class="fas fa-link"></i> Đang tải ảnh...');
        imageInfo.show();
        
        // Handle image load error
        preview.on('error', function() {
            preview.removeClass('show');
            if (showAlert) {
                alert('Không thể tải hình ảnh. Vui lòng kiểm tra lại URL: ' + imageURL);
                imageInfo.html('<i class="fas fa-exclamation-triangle text-danger"></i> Không thể tải hình ảnh');
            } else {
                // Just show a warning message without alert
                imageInfo.html('<i class="fas fa-exclamation-triangle text-warning"></i> Không thể tải hình ảnh từ URL này');
            }
            imageInfo.show();
        });
        
        // Handle successful load
        preview.on('load', function() {
            preview.addClass('show');
            imageInfo.html('<i class="fas fa-check-circle text-success"></i> Hình ảnh đã tải thành công');
            imageInfo.show();
        });
    } else {
        preview.removeClass('show');
        imageInfo.hide();
    }
}

// Form validation
$('#sliderForm').on('submit', function(e) {
    const title = $('#title').val().trim();
    const displayOrder = $('#displayOrder').val();
    const imageFile = $('#imageFile')[0].files[0];
    const imageURL = $('#imageURL').val().trim();
    const currentImageURL = $('input[name="currentImageURL"]').val();
    
    if (!title) {
        e.preventDefault();
        alert('Vui lòng nhập tiêu đề slider!');
        $('#title').focus();
        return false;
    }
    
    // Check if image is provided (file upload or URL or existing image)
    if (!imageFile && !imageURL && !currentImageURL) {
        e.preventDefault();
        alert('Vui lòng chọn hình ảnh hoặc nhập URL!');
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

// Load preview on page load if editing (don't show alert)
$(document).ready(function() {
    const imageURL = $('#imageURL').val();
    if (imageURL) {
        previewImageURL(false); // Pass false to not show alert on page load
    }
    
    // Show alert only when user manually changes URL
    $('#imageURL').on('change', function() {
        previewImageURL(true); // Pass true to show alert when user changes
    });
});
</script>

</body>
</html>