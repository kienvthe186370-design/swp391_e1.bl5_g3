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
  <title>Quản lý Giá trị Thuộc tính - Admin</title>

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
            <h1><i class="fas fa-list-ul"></i> Giá trị: ${attribute.attributeName}</h1>
          </div>
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp">Home</a></li>
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/admin/attributes">Thuộc tính</a></li>
              <li class="breadcrumb-item active">Giá trị</li>
            </ol>
          </div>
        </div>
      </div>
    </section>

    <!-- Main content -->
    <section class="content">
      <div class="container-fluid">
        
        <!-- Success/Error Messages -->
        <c:if test="${param.msg == 'add_success'}">
          <div class="alert alert-success alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-check"></i> Thêm giá trị thành công!
          </div>
        </c:if>
        <c:if test="${param.msg == 'delete_success'}">
          <div class="alert alert-success alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-check"></i> Xóa giá trị thành công!
          </div>
        </c:if>

        <div class="row">
          <!-- Add Value Form -->
          <div class="col-md-4">
            <div class="card card-primary">
              <div class="card-header">
                <h3 class="card-title">Thêm Giá trị Mới</h3>
              </div>
              
              <form method="post" action="<%= request.getContextPath() %>/admin/attributes" id="valueForm">
                <input type="hidden" name="action" value="addValue">
                <input type="hidden" name="attributeID" value="${attribute.attributeID}">

                <div class="card-body">
                  <!-- Value Name -->
                  <div class="form-group">
                    <label for="valueName">Tên Giá trị <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="valueName" name="valueName" 
                           placeholder="Nhập giá trị..." required>
                    <small class="form-text text-muted">
                      Ví dụ: 
                      <c:choose>
                        <c:when test="${attribute.attributeName == 'Màu sắc'}">Đỏ, Xanh, Đen</c:when>
                        <c:when test="${attribute.attributeName == 'Trọng lượng'}">220g, 230g</c:when>
                        <c:otherwise>S, M, L, XL</c:otherwise>
                      </c:choose>
                    </small>
                  </div>

                  <!-- Is Active -->
                  <div class="form-group">
                    <div class="custom-control custom-switch">
                      <input type="checkbox" class="custom-control-input" id="isActive" name="isActive" checked>
                      <label class="custom-control-label" for="isActive">Kích hoạt</label>
                    </div>
                  </div>
                </div>

                <div class="card-footer">
                  <button type="submit" class="btn btn-primary btn-block">
                    <i class="fas fa-plus"></i> Thêm Giá trị
                  </button>
                  <a href="<%= request.getContextPath() %>/admin/attributes" class="btn btn-default btn-block">
                    <i class="fas fa-arrow-left"></i> Quay lại
                  </a>
                </div>
              </form>
            </div>

            <!-- Info Card -->
            <div class="card card-info">
              <div class="card-header">
                <h3 class="card-title"><i class="fas fa-info-circle"></i> Thông tin</h3>
              </div>
              <div class="card-body">
                <p><strong>Thuộc tính:</strong> ${attribute.attributeName}</p>
                <p><strong>ID:</strong> #${attribute.attributeID}</p>
                <p><strong>Trạng thái:</strong> 
                  <span class="badge ${attribute.isActive ? 'badge-success' : 'badge-danger'}">
                    ${attribute.isActive ? 'Active' : 'Inactive'}
                  </span>
                </p>
                <hr>
                <p class="text-muted"><small>Tổng số giá trị: <strong>${values.size()}</strong></small></p>
              </div>
            </div>
          </div>

          <!-- Values List -->
          <div class="col-md-8">
            <div class="card">
              <div class="card-header">
                <h3 class="card-title">Danh sách Giá trị</h3>
              </div>
              
              <div class="card-body">
                <table class="table table-bordered table-hover">
                  <thead>
                    <tr>
                      <th style="width: 80px;">ID</th>
                      <th>Tên Giá trị</th>
                      <th style="width: 120px;">Trạng thái</th>
                      <th style="width: 100px;" class="text-center">Thao tác</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach var="val" items="${values}">
                      <tr>
                        <td><strong>#${val.valueID}</strong></td>
                        <td><strong>${val.valueName}</strong></td>
                        <td>
                          <c:choose>
                            <c:when test="${val.isActive}">
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
                          <button type="button" class="btn btn-danger btn-sm" 
                                  onclick="confirmDelete(${val.valueID}, '${val.valueName}')" title="Xóa">
                            <i class="fas fa-trash"></i>
                          </button>
                        </td>
                      </tr>
                    </c:forEach>
                    <c:if test="${empty values}">
                      <tr>
                        <td colspan="4" class="text-center">
                          <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                          <p class="text-muted">Chưa có giá trị nào. Hãy thêm giá trị mới!</p>
                        </td>
                      </tr>
                    </c:if>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>

  <!-- Footer -->
  <jsp:include page="includes/admin-footer.jsp" />

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header bg-danger">
        <h4 class="modal-title"><i class="fas fa-exclamation-triangle"></i> Xác nhận xóa</h4>
        <button type="button" class="close" data-dismiss="modal">&times;</button>
      </div>
      <div class="modal-body">
        <p>Bạn có chắc chắn muốn xóa giá trị <strong id="valueName"></strong>?</p>
        <p class="text-danger"><i class="fas fa-info-circle"></i> Hành động này không thể hoàn tác!</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">Hủy</button>
        <a href="#" id="confirmDeleteBtn" class="btn btn-danger">
          <i class="fas fa-trash"></i> Xóa
        </a>
      </div>
    </div>
  </div>
</div>

<script>
function confirmDelete(valueId, valueName) {
    $('#valueName').text(valueName);
    $('#confirmDeleteBtn').attr('href', '<%= request.getContextPath() %>/admin/attributes?action=deleteValue&valueId=' + valueId + '&attrId=${attribute.attributeID}');
    $('#deleteModal').modal('show');
}

// Form validation
$('#valueForm').on('submit', function(e) {
    const valueName = $('#valueName').val().trim();
    
    if (!valueName) {
        e.preventDefault();
        alert('Vui lòng nhập tên giá trị!');
        $('#valueName').focus();
        return false;
    }
    
    return true;
});

// Auto hide alerts after 3 seconds
setTimeout(function() {
    $('.alert').fadeOut('slow');
}, 3000);
</script>
