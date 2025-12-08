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
  <title>${category != null ? 'Chỉnh sửa' : 'Thêm mới'} Danh mục - Admin</title>

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
            <h1>
              <i class="fas fa-list"></i> 
              ${category != null ? 'Chỉnh sửa Danh mục' : 'Thêm Danh mục Mới'}
            </h1>
          </div>
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp">Home</a></li>
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/admin/categories">Danh mục</a></li>
              <li class="breadcrumb-item active">${category != null ? 'Chỉnh sửa' : 'Thêm mới'}</li>
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
                <h3 class="card-title">Thông tin Danh mục</h3>
              </div>
              
              <form method="post" action="<%= request.getContextPath() %>/admin/categories" id="categoryForm">
                <input type="hidden" name="action" value="${category != null ? 'edit' : 'add'}">
                <c:if test="${category != null}">
                  <input type="hidden" name="categoryID" value="${category.categoryID}">
                </c:if>

                <div class="card-body">
                  <!-- Category Name -->
                  <div class="form-group">
                    <label for="categoryName">Tên Danh mục <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="categoryName" name="categoryName" 
                           value="${category != null ? category.categoryName : ''}" 
                           placeholder="Nhập tên danh mục..." required>
                    <small class="form-text text-muted">Ví dụ: Vợt Pickleball, Bóng Pickleball</small>
                  </div>

                  <!-- Description -->
                  <div class="form-group">
                    <label for="description">Mô tả</label>
                    <textarea class="form-control" id="description" name="description" rows="3" 
                              placeholder="Nhập mô tả danh mục...">${category != null ? category.description : ''}</textarea>
                    <small class="form-text text-muted">Mô tả ngắn gọn về danh mục sản phẩm</small>
                  </div>

                  <!-- Icon -->
                  <div class="form-group">
                    <label for="icon">Icon CSS Class</label>
                    <input type="text" class="form-control" id="icon" name="icon" 
                           value="${category != null ? category.icon : ''}" 
                           placeholder="fas fa-list, icon-paddle...">
                    <small class="form-text text-muted">Class CSS của icon (Font Awesome hoặc custom)</small>
                    <div class="mt-2">
                      <span id="iconPreview" class="${category != null ? category.icon : ''}" style="font-size: 24px;"></span>
                    </div>
                  </div>

                  <!-- Display Order -->
                  <div class="form-group">
                    <label for="displayOrder">Thứ tự hiển thị</label>
                    <input type="number" class="form-control" id="displayOrder" name="displayOrder" 
                           value="${category != null ? category.displayOrder : 0}" 
                           min="0" max="100">
                    <small class="form-text text-muted">Số thứ tự hiển thị (0 = hiển thị đầu tiên)</small>
                  </div>

                  <!-- Is Active -->
                  <div class="form-group">
                    <div class="custom-control custom-switch">
                      <input type="checkbox" class="custom-control-input" id="isActive" name="isActive" 
                             ${category == null || category.isActive ? 'checked' : ''}>
                      <label class="custom-control-label" for="isActive">Kích hoạt danh mục</label>
                    </div>
                    <small class="form-text text-muted">Bật để hiển thị danh mục trên website</small>
                  </div>
                </div>

                <div class="card-footer">
                  <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> ${category != null ? 'Cập nhật' : 'Thêm mới'}
                  </button>
                  <a href="<%= request.getContextPath() %>/admin/categories" class="btn btn-default">
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
                  <li>Tên danh mục phải <strong>duy nhất</strong></li>
                  <li>Mô tả giúp SEO tốt hơn</li>
                  <li>Icon hiển thị trên menu</li>
                  <li>Thứ tự nhỏ hơn hiển thị trước</li>
                </ul>

                <h6 class="mt-3"><i class="fas fa-icons"></i> Icon phổ biến:</h6>
                <ul class="pl-3">
                  <li><i class="fas fa-table-tennis"></i> fas fa-table-tennis</li>
                  <li><i class="fas fa-baseball-ball"></i> fas fa-baseball-ball</li>
                  <li><i class="fas fa-tshirt"></i> fas fa-tshirt</li>
                  <li><i class="fas fa-shopping-bag"></i> fas fa-shopping-bag</li>
                </ul>
              </div>
            </div>

            <!-- Category Info (if editing) -->
            <c:if test="${category != null}">
              <div class="card card-secondary">
                <div class="card-header">
                  <h3 class="card-title"><i class="fas fa-database"></i> Thông tin</h3>
                </div>
                <div class="card-body">
                  <p><strong>ID:</strong> #${category.categoryID}</p>
                  <p><strong>Trạng thái:</strong> 
                    <span class="badge ${category.isActive ? 'badge-success' : 'badge-danger'}">
                      ${category.isActive ? 'Active' : 'Inactive'}
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
// Preview icon when class is entered
$('#icon').on('input', function() {
    const iconClass = $(this).val();
    $('#iconPreview').attr('class', iconClass).css('font-size', '24px');
});

// Form validation
$('#categoryForm').on('submit', function(e) {
    const categoryName = $('#categoryName').val().trim();
    
    if (!categoryName) {
        e.preventDefault();
        alert('Vui lòng nhập tên danh mục!');
        $('#categoryName').focus();
        return false;
    }
    
    if (categoryName.length < 2) {
        e.preventDefault();
        alert('Tên danh mục phải có ít nhất 2 ký tự!');
        $('#categoryName').focus();
        return false;
    }
    
    return true;
});
</script>
