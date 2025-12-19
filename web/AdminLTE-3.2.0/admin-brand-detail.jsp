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
                  <!-- Thông báo lỗi -->
                  <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible">
                      <button type="button" class="close" data-dismiss="alert">&times;</button>
                      <i class="fas fa-exclamation-triangle"></i> ${error}
                    </div>
                  </c:if>
                  
                  <!-- Brand Name -->
                  <div class="form-group">
                    <label for="brandName">Tên Thương hiệu <span class="text-danger">*</span></label>
                    <input type="text" class="form-control ${not empty error ? 'is-invalid' : ''}" id="brandName" name="brandName" 
                           value="${brand != null ? brand.brandName : (brandName != null ? brandName : '')}" 
                           placeholder="Nhập tên thương hiệu..." required>
                    <small class="form-text text-muted">Ví dụ: Joola, Selkirk, Franklin</small>
                  </div>

                  <!-- Brandfetch Auto Logo -->
                  <div class="form-group">
                    <label for="brandDomain">Tự động lấy Logo từ Brandfetch</label>
                    <div class="input-group">
                      <input type="text" class="form-control" id="brandDomain" 
                             placeholder="Nhập domain thương hiệu (vd: joola.com, selkirk.com)">
                      <div class="input-group-append">
                        <button type="button" class="btn btn-info" onclick="fetchBrandLogo()">
                          <i class="fas fa-magic"></i> Lấy Logo
                        </button>
                      </div>
                    </div>
                    <small class="form-text text-muted">
                      <i class="fas fa-lightbulb text-warning"></i> Nhập domain website của thương hiệu để tự động lấy logo
                    </small>
                  </div>

                  <!-- Logo URL -->
                  <div class="form-group">
                    <label for="logo">URL Logo</label>
                    <input type="url" class="form-control" id="logo" name="logo" 
                           value="${brand != null ? brand.logo : ''}" 
                           placeholder="https://example.com/logo.png" 
                           onchange="previewLogo()">
                    <small class="form-text text-muted">Nhập URL đầy đủ hoặc sử dụng Brandfetch ở trên</small>
                    
                    <!-- Logo Preview -->
                    <div class="mt-3 text-center">
                      <img id="logoPreview" class="logo-preview ${brand != null && brand.logo != null ? 'show' : ''}" 
                           src="${brand != null ? brand.logo : ''}" alt="Logo Preview"
                           onerror="this.classList.remove('show')">
                      <p id="logoSource" class="text-muted small mt-2" style="display:none;"></p>
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
                <h6><i class="fas fa-magic text-info"></i> Brandfetch CDN:</h6>
                <ul class="pl-3">
                  <li>Nhập domain thương hiệu (vd: <code>joola.com</code>)</li>
                  <li>Click "Lấy Logo" để tự động lấy</li>
                  <li>Logo được lấy từ Brandfetch CDN</li>
                  <li>Miễn phí và chất lượng cao</li>
                </ul>

                <h6 class="mt-3"><i class="fas fa-lightbulb text-warning"></i> Lưu ý:</h6>
                <ul class="pl-3">
                  <li>Tên thương hiệu phải <strong>duy nhất</strong></li>
                  <li>Có thể nhập URL logo thủ công</li>
                  <li>Mô tả giúp khách hàng hiểu rõ hơn</li>
                </ul>

                <h6 class="mt-3"><i class="fas fa-globe text-success"></i> Domain phổ biến:</h6>
                <ul class="pl-3 small">
                  <li><code>joola.com</code> - Joola</li>
                  <li><code>selkirk.com</code> - Selkirk</li>
                  <li><code>head.com</code> - Head</li>
                  <li><code>wilson.com</code> - Wilson</li>
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
  <jsp:include page="includes/admin-footer.jsp" />

<script>
// Brandfetch CDN - Lấy logo tự động từ domain
function fetchBrandLogo() {
    let domain = $('#brandDomain').val().trim();
    
    if (!domain) {
        alert('Vui lòng nhập domain thương hiệu!');
        $('#brandDomain').focus();
        return;
    }
    
    // Clean domain - remove http/https and trailing slashes
    domain = domain.replace(/^(https?:\/\/)?(www\.)?/, '').replace(/\/.*$/, '');
    
    // Brandfetch CDN URL formats
    const logoFormats = [
        'https://cdn.brandfetch.io/' + domain + '/w/400/h/400/logo',
        'https://cdn.brandfetch.io/' + domain + '/w/200/h/200/icon',
        'https://cdn.brandfetch.io/' + domain + '/fallback/transparent/logo'
    ];
    
    // Try the main logo format first
    const logoUrl = logoFormats[0];
    
    // Test if image loads
    const testImg = new Image();
    testImg.onload = function() {
        $('#logo').val(logoUrl);
        $('#logoPreview').attr('src', logoUrl).addClass('show');
        $('#logoSource').text('Logo từ Brandfetch CDN: ' + domain).show();
        
        // Auto-fill brand name if empty
        if (!$('#brandName').val().trim()) {
            // Capitalize first letter of domain name
            const brandName = domain.split('.')[0];
            const capitalizedName = brandName.charAt(0).toUpperCase() + brandName.slice(1);
            $('#brandName').val(capitalizedName);
        }
    };
    testImg.onerror = function() {
        // Try icon format
        const iconUrl = logoFormats[1];
        const testIcon = new Image();
        testIcon.onload = function() {
            $('#logo').val(iconUrl);
            $('#logoPreview').attr('src', iconUrl).addClass('show');
            $('#logoSource').text('Icon từ Brandfetch CDN: ' + domain).show();
        };
        testIcon.onerror = function() {
            alert('Không tìm thấy logo cho domain: ' + domain + '\nHãy thử nhập URL logo thủ công.');
        };
        testIcon.src = iconUrl;
    };
    testImg.src = logoUrl;
}

// Preview logo when URL is entered
function previewLogo() {
    const logoURL = $('#logo').val();
    const preview = $('#logoPreview');
    
    if (logoURL) {
        preview.attr('src', logoURL);
        preview.addClass('show');
        $('#logoSource').hide();
    } else {
        preview.removeClass('show');
        $('#logoSource').hide();
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
    
    // Enter key on domain input triggers fetch
    $('#brandDomain').on('keypress', function(e) {
        if (e.which === 13) {
            e.preventDefault();
            fetchBrandLogo();
        }
    });
});
</script>
