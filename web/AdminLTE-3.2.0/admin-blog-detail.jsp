<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="entity.Employee" %>
<%
    Employee employee = (Employee) session.getAttribute("employee");
    if (employee == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    boolean isEdit = request.getAttribute("blog") != null;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><%= isEdit ? "Sửa" : "Thêm" %> Blog - Admin</title>

  <!-- Google Font: Source Sans Pro -->
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
  <!-- Font Awesome -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/fontawesome-free/css/all.min.css">
  <!-- Theme style -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/css/adminlte.min.css">
  <!-- Summernote -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/summernote/summernote-bs4.min.css">
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
            <h1><i class="fas fa-blog"></i> <%= isEdit ? "Sửa" : "Thêm" %> Blog</h1>
          </div>
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp">Home</a></li>
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/admin/blog">Blog</a></li>
              <li class="breadcrumb-item active"><%= isEdit ? "Sửa" : "Thêm" %></li>
            </ol>
          </div>
        </div>
      </div>
    </section>

    <!-- Main content -->
    <section class="content">
      <div class="container-fluid">
        
        <form method="post" action="<%= request.getContextPath() %>/admin/blog" enctype="multipart/form-data">
          <input type="hidden" name="action" value="<%= isEdit ? "update" : "add" %>">
          <c:if test="${blog != null}">
            <input type="hidden" name="id" value="${blog.postId}">
            <input type="hidden" name="currentFeaturedImage" value="${blog.featuredImage}">
          </c:if>
          
          <div class="row">
            <!-- Left Column -->
            <div class="col-md-8">
              <!-- Main Info Card -->
              <div class="card card-primary">
                <div class="card-header">
                  <h3 class="card-title">Thông tin bài viết</h3>
                </div>
                <div class="card-body">
                  <div class="form-group">
                    <label for="title">Tiêu đề <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="title" name="title" 
                           value="${blog != null ? blog.title : ''}" 
                           placeholder="Nhập tiêu đề bài viết" required>
                  </div>
                  
                  <div class="form-group">
                    <label for="slug">Slug (URL thân thiện)</label>
                    <input type="text" class="form-control" id="slug" name="slug" 
                           value="${blog != null ? blog.slug : ''}" 
                           placeholder="vd: bai-viet-moi (tự động tạo nếu để trống)">
                    <small class="form-text text-muted">Để trống để tự động tạo từ tiêu đề</small>
                  </div>
                  
                  <div class="form-group">
                    <label for="summary">Tóm tắt</label>
                    <textarea class="form-control" id="summary" name="summary" rows="3" 
                              placeholder="Nhập tóm tắt ngắn gọn về bài viết">${blog != null ? blog.summary : ''}</textarea>
                  </div>
                  
                  <div class="form-group">
                    <label for="content">Nội dung <span class="text-danger">*</span></label>
                    <textarea class="form-control" id="content" name="content" required>${blog != null ? blog.content : ''}</textarea>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- Right Column -->
            <div class="col-md-4">
              <!-- Publish Card -->
              <div class="card card-success">
                <div class="card-header">
                  <h3 class="card-title">Xuất bản</h3>
                </div>
                <div class="card-body">
                  <div class="form-group">
                    <label for="status">Trạng thái</label>
                    <select class="form-control" id="status" name="status">
                      <option value="draft" ${blog == null || blog.status == 'draft' ? 'selected' : ''}>Nháp</option>
                      <option value="published" ${blog != null && blog.status == 'published' ? 'selected' : ''}>Xuất bản</option>
                    </select>
                  </div>
                  
                  <c:if test="${blog != null && blog.publishedDate != null}">
                    <div class="form-group">
                      <label>Ngày xuất bản</label>
                      <p class="form-control-static">${blog.publishedDate.toString().substring(0, 16).replace('T', ' ')}</p>
                    </div>
                  </c:if>
                  
                  <c:if test="${blog != null}">
                    <div class="form-group">
                      <label>Lượt xem</label>
                      <p class="form-control-static"><span class="badge badge-info">${blog.viewCount}</span></p>
                    </div>
                  </c:if>
                </div>
                <div class="card-footer">
                  <button type="submit" class="btn btn-success btn-block">
                    <i class="fas fa-save"></i> <%= isEdit ? "Cập nhật" : "Lưu" %>
                  </button>
                  <a href="<%= request.getContextPath() %>/admin/blog" class="btn btn-default btn-block">
                    <i class="fas fa-times"></i> Hủy
                  </a>
                </div>
              </div>
              
              <!-- Featured Image Card -->
              <div class="card card-info">
                <div class="card-header">
                  <h3 class="card-title">Ảnh đại diện</h3>
                </div>
                <div class="card-body">
                  <!-- Upload Method Tabs -->
                  <ul class="nav nav-tabs" id="uploadTabs" role="tablist">
                    <li class="nav-item">
                      <a class="nav-link active" id="upload-tab" data-toggle="tab" href="#uploadMethod" role="tab">
                        <i class="fas fa-upload"></i> Upload
                      </a>
                    </li>
                    <li class="nav-item">
                      <a class="nav-link" id="url-tab" data-toggle="tab" href="#urlMethod" role="tab">
                        <i class="fas fa-link"></i> URL
                      </a>
                    </li>
                  </ul>
                  
                  <div class="tab-content border border-top-0 p-3" id="uploadTabContent">
                    <!-- Upload from Computer -->
                    <div class="tab-pane fade show active" id="uploadMethod" role="tabpanel">
                      <div class="custom-file">
                        <input type="file" class="custom-file-input" id="imageFile" name="imageFile" 
                               accept="image/jpeg,image/png,image/jpg,image/gif" onchange="previewUploadedImage(this)">
                        <label class="custom-file-label" for="imageFile">Chọn ảnh...</label>
                      </div>
                      <small class="form-text text-muted">
                        <i class="fas fa-info-circle"></i> JPG, PNG, GIF. Tối đa 5MB. Khuyến nghị: 1200x800px
                      </small>
                    </div>
                    
                    <!-- URL Method -->
                    <div class="tab-pane fade" id="urlMethod" role="tabpanel">
                      <input type="text" class="form-control" id="featuredImage" name="featuredImage" 
                             value="${blog != null ? blog.featuredImage : ''}" 
                             placeholder="img/blog/my-image.jpg">
                      <small class="form-text text-muted">
                        <i class="fas fa-info-circle"></i> Nhập đường dẫn ảnh hoặc URL đầy đủ
                      </small>
                    </div>
                  </div>
                  
                  <!-- Image Preview -->
                  <div class="mt-3 text-center">
                    <c:choose>
                      <c:when test="${blog != null && not empty blog.featuredImage}">
                        <c:set var="previewSrc" value="${blog.featuredImage.startsWith('http://') || blog.featuredImage.startsWith('https://') || blog.featuredImage.startsWith('/') ? blog.featuredImage : pageContext.request.contextPath.concat('/').concat(blog.featuredImage)}" />
                        <img id="imagePreview" class="img-fluid img-thumbnail" src="${previewSrc}" 
                             alt="Preview" style="max-height: 200px; display: block;">
                      </c:when>
                      <c:otherwise>
                        <img id="imagePreview" class="img-fluid img-thumbnail" src="" 
                             alt="Preview" style="max-height: 200px; display: none;">
                      </c:otherwise>
                    </c:choose>
                    <div id="imageInfo" class="text-muted small mt-2" style="display: none;"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </form>

      </div>
    </section>
  </div>

  <!-- Footer -->
  <jsp:include page="includes/admin-footer.jsp" />
</div>

<!-- jQuery -->
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/jquery/jquery.min.js"></script>
<!-- Bootstrap 4 -->
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<!-- AdminLTE App -->
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/js/adminlte.min.js"></script>
<!-- Summernote -->
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/summernote/summernote-bs4.min.js"></script>

<script>
$(function () {
  // Initialize Summernote
  $('#content').summernote({
    height: 300,
    placeholder: 'Nhập nội dung bài viết...',
    toolbar: [
      ['style', ['style']],
      ['font', ['bold', 'underline', 'clear']],
      ['color', ['color']],
      ['para', ['ul', 'ol', 'paragraph']],
      ['table', ['table']],
      ['insert', ['link', 'picture']],
      ['view', ['fullscreen', 'codeview', 'help']]
    ]
  });
  
  // Auto generate slug from title
  $('#title').on('blur', function() {
    var title = $(this).val();
    var slug = $('#slug').val();
    
    if (title && !slug) {
      var generatedSlug = generateSlug(title);
      $('#slug').val(generatedSlug);
    }
  });
  
  // Preview image from URL
  $('#featuredImage').on('change blur', function() {
    previewImageURL(false);
  });
  
  // Load preview on page load if editing
  const featuredImage = $('#featuredImage').val();
  if (featuredImage) {
    previewImageURL(false);
  }
});

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
            label.text('Chọn ảnh...');
            preview.hide();
            imageInfo.hide();
            return;
        }
        
        // Validate file type
        const validTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'];
        if (!validTypes.includes(file.type)) {
            alert('Định dạng file không hợp lệ! Chỉ chấp nhận JPG, PNG, GIF.');
            input.value = '';
            label.text('Chọn ảnh...');
            preview.hide();
            imageInfo.hide();
            return;
        }
        
        // Preview image
        const reader = new FileReader();
        reader.onload = function(e) {
            preview.attr('src', e.target.result);
            preview.show();
            
            // Show file info
            const sizeKB = (file.size / 1024).toFixed(2);
            imageInfo.html('<i class="fas fa-file-image"></i> ' + file.name + ' (' + sizeKB + ' KB)');
            imageInfo.show();
        };
        reader.readAsDataURL(file);
    } else {
        label.text('Chọn ảnh...');
        preview.hide();
        imageInfo.hide();
    }
}

// Preview image when URL is entered
function previewImageURL(showAlert = true) {
    const imageURL = $('#featuredImage').val();
    const preview = $('#imagePreview');
    const imageInfo = $('#imageInfo');
    
    if (imageURL) {
        // Remove old error handler
        preview.off('error');
        preview.off('load');
        
        // Build correct image path
        let imageSrc = imageURL;
        if (!imageURL.startsWith('http://') && !imageURL.startsWith('https://') && !imageURL.startsWith('/')) {
            imageSrc = '<%= request.getContextPath() %>/' + imageURL;
        }
        
        preview.attr('src', imageSrc);
        preview.show();
        imageInfo.html('<i class="fas fa-link"></i> Đang tải ảnh...');
        imageInfo.show();
        
        // Handle image load error
        preview.on('error', function() {
            preview.hide();
            if (showAlert) {
                alert('Không thể tải hình ảnh. Vui lòng kiểm tra lại URL: ' + imageURL);
                imageInfo.html('<i class="fas fa-exclamation-triangle text-danger"></i> Không thể tải hình ảnh');
            } else {
                imageInfo.html('<i class="fas fa-exclamation-triangle text-warning"></i> Không thể tải hình ảnh từ URL này');
            }
            imageInfo.show();
        });
        
        // Handle successful load
        preview.on('load', function() {
            preview.show();
            imageInfo.html('<i class="fas fa-check-circle text-success"></i> Hình ảnh đã tải thành công');
            imageInfo.show();
        });
    } else {
        preview.hide();
        imageInfo.hide();
    }
}

function generateSlug(text) {
  return text.toLowerCase()
    .replace(/[àáạảãâầấậẩẫăằắặẳẵ]/g, 'a')
    .replace(/[èéẹẻẽêềếệểễ]/g, 'e')
    .replace(/[ìíịỉĩ]/g, 'i')
    .replace(/[òóọỏõôồốộổỗơờớợởỡ]/g, 'o')
    .replace(/[ùúụủũưừứựửữ]/g, 'u')
    .replace(/[ỳýỵỷỹ]/g, 'y')
    .replace(/đ/g, 'd')
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '');
}
</script>

</body>
</html>
