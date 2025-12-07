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
  <title>${brand != null ? 'Chỉnh sửa' : 'Thêm mới'} Thương hiệu - Admin</title>

  <!-- Google Font: Source Sans Pro -->
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
  <!-- Font Awesome -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/fontawesome-free/css/all.min.css">
  <!-- Theme style -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/css/adminlte.min.css">
  <style>
    .logo-preview {
      max-width: 100%;
      max-height: 200px;
      border: 2px dashed #dee2e6;
      border-radius: 8px;
      padding: 10px;
      display: none;
    }
    .logo-preview.show {
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
              <i class="fas fa-copyright"></i> 
              ${brand != null ? 'Chỉnh sửa Thương hiệu' : 'Thêm Thương hiệu Mới'}
            </h1>
          </div>
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp">Home</a></li>
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/admin/brands">Thương hiệu</a></li>
              <li class="breadcrumb-item active">${brand != null ? 'Chỉnh sửa' : 'Thêm mới'}</li>
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
                <h3 class="card-title">Thông tin Thương hiệu</h3>
              </div>
              
              <form method="post" action="<%= request.getContextPath() %>/admin/brands" id="brandForm">
                <input type="hidden" name="action" value="${brand != null ? 'edit' : 'add'}">
                <c:if test="${brand != null}">
                  <input type="hidden" name="brandID" value="${brand.brandID}">
                </c:if>

                <div class="card-body">
                  <!-- Brand Name -->
                  <div class="form-group">
                    <label for="brandName">Tên Thương hiệu <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="brandName" name="brandName" 
                           value="${brand != null ? brand.brandName : ''}" 
                           placeholder="Nhập tên thương hiệu..." required>
                    <small class="form-text text-muted">Ví dụ: Joola, Selkirk, Franklin</small>
                  </div>

                  <!-- Logo URL -->
                  <div class="form-group">
                    <label for="logo">URL Logo</label>
                    <input type="url" class="form-control" id="logo" name="logo" 
                           value="${brand != null ? brand.logo : ''}" 
                           placeholder="https://example.com/logo.png" 
                           onchange="previewLogo()">
                    <small class="form-text text-muted">Nhập URL đầy đủ của logo thương hiệu</small>
                    
                    <!-- Logo Preview -->
                    <div class="mt-3 text-center">
                      <img id="logoPreview" class="logo-preview ${brand != null && brand.logo != null ? 'show' : ''}" 
                           src="${brand != null ? brand.logo : ''}" alt="Logo Preview">
                    </div>
                  </div>

                  <!-- Description -->
                  <div class="form-group">
                    <label for="description">Mô tả</label>
                    <textarea class="form-control" id="description" name="description" rows="4" 
                              placeholder="Nhập mô tả về thương hiệu...">${brand != null ? brand.description : ''}</textarea>
                    <small class="form-text text-muted">Mô tả chi tiết về thương hiệu, lịch sử, đặc điểm</small>
                  </div>

                  <!-- Is Active -->
                  <div class="form-group">
                    <div class="custom-control custom-switch">
                      <input type="checkbox" class="custom-control-input" id="isActive" name="isActive" 
                             ${brand == null || brand.isActive ? 'checked' : ''}>
                      <label class="custom-control-label" for="isActive">Kích hoạt thương hiệu</label>
                    </div>
                    <small class="form-text text-muted">Bật để hiển thị thương hiệu trên website</small>
                  </div>
                </div>

                <div class="card-footer">
                  <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> ${brand != null ? 'Cập nhật' : 'Thêm mới'}
                  </button>
                  <a href="<%= request.getContextPath() %>/admin/brands" class="btn btn-default">
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
                  <li>Tên thương hiệu phải <strong>duy nhất</strong></li>
                  <li>Logo nên có nền trong suốt (PNG)</li>
                  <li>Kích thước logo: <strong>200x100px</strong></li>
                  <li>Mô tả giúp khách hàng hiểu rõ hơn</li>
                </ul>

                <h6 class="mt-3"><i class="fas fa-exclamation-triangle"></i> Khuyến nghị:</h6>
                <ul class="pl-3">
                  <li>Sử dụng logo chính thức</li>
                  <li>Định dạng: PNG hoặc SVG</li>
                  <li>Dung lượng tối đa: 500KB</li>
                  <li>Nền trắng hoặc trong suốt</li>
                </ul>
              </div>
            </div>

            <!-- Brand Info (if editing) -->
            <c:if test="${brand != null}">
              <div class="card card-secondary">
                <div class="card-header">
                  <h3 class="card-title"><i class="fas fa-database"></i> Thông tin</h3>
                </div>
                <div class="card-body">
                  <p><strong>ID:</strong> #${brand.brandID}</p>
                  <p><strong>Trạng thái:</strong> 
                    <span class="badge ${brand.isActive ? 'badge-success' : 'badge-danger'}">
                      ${brand.isActive ? 'Active' : 'Inactive'}
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
// Preview logo when URL is entered
function previewLogo() {
    const logoURL = $('#logo').val();
    const preview = $('#logoPreview');
    
    if (logoURL) {
        preview.attr('src', logoURL);
        preview.addClass('show');
        
        // Handle image load error
        preview.on('error', function() {
            preview.removeClass('show');
            alert('Không thể tải logo. Vui lòng kiểm tra lại URL.');
        });
    } else {
        preview.removeClass('show');
    }
}

// Form validation
$('#brandForm').on('submit', function(e) {
    const brandName = $('#brandName').val().trim();
    
    if (!brandName) {
        e.preventDefault();
        alert('Vui lòng nhập tên thương hiệu!');
        $('#brandName').focus();
        return false;
    }
    
    if (brandName.length < 2) {
        e.preventDefault();
        alert('Tên thương hiệu phải có ít nhất 2 ký tự!');
        $('#brandName').focus();
        return false;
    }
    
    return true;
});

// Load preview on page load if editing
$(document).ready(function() {
    const logoURL = $('#logo').val();
    if (logoURL) {
        previewLogo();
    }
});
</script>
</body>
</html>
