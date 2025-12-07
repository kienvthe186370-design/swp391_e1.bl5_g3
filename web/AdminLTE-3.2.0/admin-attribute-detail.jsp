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
  <title>${attribute != null ? 'Chỉnh sửa' : 'Thêm mới'} Thuộc tính - Admin</title>

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
              <i class="fas fa-tags"></i> 
              ${attribute != null ? 'Chỉnh sửa Thuộc tính' : 'Thêm Thuộc tính Mới'}
            </h1>
          </div>
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp">Home</a></li>
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/admin/attributes">Thuộc tính</a></li>
              <li class="breadcrumb-item active">${attribute != null ? 'Chỉnh sửa' : 'Thêm mới'}</li>
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
                <h3 class="card-title">Thông tin Thuộc tính</h3>
              </div>
              
              <form method="post" action="<%= request.getContextPath() %>/admin/attributes" id="attributeForm">
                <input type="hidden" name="action" value="${attribute != null ? 'edit' : 'add'}">
                <c:if test="${attribute != null}">
                  <input type="hidden" name="attributeID" value="${attribute.attributeID}">
                </c:if>

                <div class="card-body">
                  <!-- Attribute Name -->
                  <div class="form-group">
                    <label for="attributeName">Tên Thuộc tính <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="attributeName" name="attributeName" 
                           value="${attribute != null ? attribute.attributeName : ''}" 
                           placeholder="Nhập tên thuộc tính..." required>
                    <small class="form-text text-muted">Ví dụ: Màu sắc, Trọng lượng, Size tay cầm, Độ dày lõi</small>
                  </div>

                  <!-- Is Active -->
                  <div class="form-group">
                    <div class="custom-control custom-switch">
                      <input type="checkbox" class="custom-control-input" id="isActive" name="isActive" 
                             ${attribute == null || attribute.isActive ? 'checked' : ''}>
                      <label class="custom-control-label" for="isActive">Kích hoạt thuộc tính</label>
                    </div>
                    <small class="form-text text-muted">Bật để sử dụng thuộc tính này cho sản phẩm</small>
                  </div>

                  <!-- Info Alert -->
                  <div class="alert alert-info">
                    <h5><i class="icon fas fa-info"></i> Lưu ý!</h5>
                    Sau khi tạo thuộc tính, bạn cần thêm <strong>giá trị</strong> cho thuộc tính này.
                    <br>Ví dụ: Thuộc tính "Màu sắc" có các giá trị: Đỏ, Xanh, Đen...
                  </div>
                </div>

                <div class="card-footer">
                  <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> ${attribute != null ? 'Cập nhật' : 'Thêm mới'}
                  </button>
                  <c:if test="${attribute != null}">
                    <a href="<%= request.getContextPath() %>/admin/attributes?action=values&id=${attribute.attributeID}" class="btn btn-info">
                      <i class="fas fa-list"></i> Quản lý Giá trị
                    </a>
                  </c:if>
                  <a href="<%= request.getContextPath() %>/admin/attributes" class="btn btn-default">
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
                <h6><i class="fas fa-lightbulb"></i> Thuộc tính là gì?</h6>
                <p>Thuộc tính là đặc điểm của sản phẩm giúp phân biệt các biến thể (variants).</p>

                <h6 class="mt-3"><i class="fas fa-list"></i> Ví dụ:</h6>
                <ul class="pl-3">
                  <li><strong>Màu sắc:</strong> Đỏ, Xanh, Đen</li>
                  <li><strong>Trọng lượng:</strong> 220g, 230g</li>
                  <li><strong>Size:</strong> S, M, L, XL</li>
                  <li><strong>Độ dày:</strong> 14mm, 16mm</li>
                </ul>

                <h6 class="mt-3"><i class="fas fa-exclamation-triangle"></i> Lưu ý:</h6>
                <ul class="pl-3">
                  <li>Tên thuộc tính phải <strong>duy nhất</strong></li>
                  <li>Sau khi tạo, thêm giá trị cho thuộc tính</li>
                  <li>Gán thuộc tính cho danh mục sản phẩm</li>
                </ul>
              </div>
            </div>

            <!-- Attribute Info (if editing) -->
            <c:if test="${attribute != null}">
              <div class="card card-secondary">
                <div class="card-header">
                  <h3 class="card-title"><i class="fas fa-database"></i> Thông tin</h3>
                </div>
                <div class="card-body">
                  <p><strong>ID:</strong> #${attribute.attributeID}</p>
                  <p><strong>Trạng thái:</strong> 
                    <span class="badge ${attribute.isActive ? 'badge-success' : 'badge-danger'}">
                      ${attribute.isActive ? 'Active' : 'Inactive'}
                    </span>
                  </p>
                  <hr>
                  <a href="<%= request.getContextPath() %>/admin/attributes?action=values&id=${attribute.attributeID}" 
                     class="btn btn-info btn-block">
                    <i class="fas fa-list"></i> Quản lý Giá trị
                  </a>
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
// Form validation
$('#attributeForm').on('submit', function(e) {
    const attributeName = $('#attributeName').val().trim();
    
    if (!attributeName) {
        e.preventDefault();
        alert('Vui lòng nhập tên thuộc tính!');
        $('#attributeName').focus();
        return false;
    }
    
    if (attributeName.length < 2) {
        e.preventDefault();
        alert('Tên thuộc tính phải có ít nhất 2 ký tự!');
        $('#attributeName').focus();
        return false;
    }
    
    return true;
});
</script>
</body>
</html>
