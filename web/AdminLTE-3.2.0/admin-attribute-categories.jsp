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
  <title>Gán Danh mục cho Thuộc tính - Admin</title>

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
            <h1><i class="fas fa-link"></i> Gán Danh mục: ${attribute.attributeName}</h1>
          </div>
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp">Home</a></li>
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/admin/attributes">Thuộc tính</a></li>
              <li class="breadcrumb-item active">Gán Danh mục</li>
            </ol>
          </div>
        </div>
      </div>
    </section>

    <!-- Main content -->
    <section class="content">
      <div class="container-fluid">
        
        <!-- Success/Error Messages -->
        <c:if test="${param.msg == 'assign_success'}">
          <div class="alert alert-success alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-check"></i> Gán danh mục thành công!
          </div>
        </c:if>
        <c:if test="${param.msg == 'remove_success'}">
          <div class="alert alert-success alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-check"></i> Xóa danh mục thành công!
          </div>
        </c:if>

        <div class="row">
          <!-- Assigned Categories -->
          <div class="col-md-6">
            <div class="card card-success">
              <div class="card-header">
                <h3 class="card-title">Danh mục đã gán</h3>
              </div>
              
              <div class="card-body">
                <table class="table table-bordered table-hover">
                  <thead>
                    <tr>
                      <th>Tên Danh mục</th>
                      <th width="100px">Bắt buộc</th>
                      <th width="100px" class="text-center">Thao tác</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach var="ca" items="${assignedCategories}">
                      <c:forEach var="cat" items="${allCategories}">
                        <c:if test="${cat.categoryID == ca.categoryID}">
                          <tr>
                            <td><strong>${cat.categoryName}</strong></td>
                            <td>
                              <c:choose>
                                <c:when test="${ca.isRequired}">
                                  <span class="badge badge-danger">Bắt buộc</span>
                                </c:when>
                                <c:otherwise>
                                  <span class="badge badge-secondary">Tùy chọn</span>
                                </c:otherwise>
                              </c:choose>
                            </td>
                            <td class="text-center">
                              <button type="button" class="btn btn-danger btn-sm" 
                                      onclick="confirmRemove(${ca.categoryID}, '${cat.categoryName}')" title="Xóa">
                                <i class="fas fa-times"></i>
                              </button>
                            </td>
                          </tr>
                        </c:if>
                      </c:forEach>
                    </c:forEach>
                    <c:if test="${empty assignedCategories}">
                      <tr>
                        <td colspan="3" class="text-center text-muted">
                          <i class="fas fa-inbox fa-2x mb-2"></i>
                          <p>Chưa gán danh mục nào</p>
                        </td>
                      </tr>
                    </c:if>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <!-- Available Categories -->
          <div class="col-md-6">
            <div class="card card-primary">
              <div class="card-header">
                <h3 class="card-title">Gán Danh mục Mới</h3>
              </div>
              
              <form method="post" action="<%= request.getContextPath() %>/admin/attributes">
                <input type="hidden" name="action" value="assignCategory">
                <input type="hidden" name="attributeID" value="${attribute.attributeID}">
                
                <div class="card-body">
                  <div class="form-group">
                    <label for="categoryID">Chọn Danh mục <span class="text-danger">*</span></label>
                    <select class="form-control" id="categoryID" name="categoryID" required>
                      <option value="">-- Chọn danh mục --</option>
                      <c:forEach var="cat" items="${allCategories}">
                        <c:set var="isAssigned" value="false" />
                        <c:forEach var="ca" items="${assignedCategories}">
                          <c:if test="${ca.categoryID == cat.categoryID}">
                            <c:set var="isAssigned" value="true" />
                          </c:if>
                        </c:forEach>
                        <c:if test="${!isAssigned}">
                          <option value="${cat.categoryID}">${cat.categoryName}</option>
                        </c:if>
                      </c:forEach>
                    </select>
                  </div>

                  <div class="form-group">
                    <div class="custom-control custom-checkbox">
                      <input type="checkbox" class="custom-control-input" id="isRequired" name="isRequired">
                      <label class="custom-control-label" for="isRequired">
                        <strong>Thuộc tính bắt buộc</strong>
                      </label>
                    </div>
                    <div class="alert alert-info mt-2 mb-0">
                      <small>
                        <i class="fas fa-info-circle"></i> <strong>Ý nghĩa:</strong><br>
                        • <strong>Tích:</strong> Khi tạo sản phẩm thuộc danh mục này, <strong>BẮT BUỘC</strong> phải chọn giá trị cho thuộc tính<br>
                        • <strong>Không tích:</strong> Thuộc tính là <strong>TÙY CHỌN</strong>, có thể bỏ qua<br><br>
                        <strong>Ví dụ:</strong> Nếu gán "Màu sắc" (Bắt buộc) cho "Vợt Pickleball" 
                        → Khi tạo sản phẩm vợt, phải chọn màu (Đỏ, Xanh, Đen...)
                      </small>
                    </div>
                  </div>

                  <div class="form-group">
                    <label for="displayOrder">Thứ tự hiển thị</label>
                    <input type="number" class="form-control" id="displayOrder" name="displayOrder" value="0" min="0">
                  </div>
                </div>

                <div class="card-footer">
                  <button type="submit" class="btn btn-primary">
                    <i class="fas fa-link"></i> Gán Danh mục
                  </button>
                  <a href="<%= request.getContextPath() %>/admin/attributes" class="btn btn-default">
                    <i class="fas fa-arrow-left"></i> Quay lại
                  </a>
                </div>
              </form>
            </div>

            <!-- Info Card -->
            <div class="card card-warning">
              <div class="card-header">
                <h3 class="card-title"><i class="fas fa-lightbulb"></i> Giải thích "Bắt buộc"</h3>
              </div>
              <div class="card-body">
                <h6><i class="fas fa-check-circle text-success"></i> Thuộc tính BẮT BUỘC:</h6>
                <ul class="pl-3">
                  <li>Khi tạo sản phẩm, <strong>PHẢI</strong> chọn giá trị</li>
                  <li>Không thể bỏ qua hoặc để trống</li>
                  <li>Dùng cho thuộc tính quan trọng</li>
                </ul>
                
                <h6 class="mt-3"><i class="fas fa-circle text-secondary"></i> Thuộc tính TÙY CHỌN:</h6>
                <ul class="pl-3">
                  <li>Khi tạo sản phẩm, <strong>CÓ THỂ</strong> chọn hoặc bỏ qua</li>
                  <li>Không bắt buộc phải điền</li>
                  <li>Dùng cho thuộc tính phụ</li>
                </ul>
                
                <hr>
                
                <h6><i class="fas fa-example"></i> Ví dụ thực tế:</h6>
                <div class="bg-light p-2 rounded">
                  <small>
                    <strong>Danh mục:</strong> Vợt Pickleball<br>
                    <strong>Thuộc tính:</strong> Màu sắc (Bắt buộc ✓)<br>
                    <strong>Thuộc tính:</strong> Độ dày lõi (Bắt buộc ✓)<br>
                    <strong>Thuộc tính:</strong> Phụ kiện đi kèm (Tùy chọn)<br><br>
                    
                    → Khi tạo sản phẩm vợt:<br>
                    • Phải chọn màu sắc (Đỏ/Xanh/Đen)<br>
                    • Phải chọn độ dày (14mm/16mm)<br>
                    • Có thể bỏ qua phụ kiện đi kèm
                  </small>
                </div>
              </div>
            </div>
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

<!-- Remove Confirmation Modal -->
<div class="modal fade" id="removeModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header bg-danger">
        <h4 class="modal-title"><i class="fas fa-exclamation-triangle"></i> Xác nhận xóa</h4>
        <button type="button" class="close" data-dismiss="modal">&times;</button>
      </div>
      <div class="modal-body">
        <p>Bạn có chắc chắn muốn xóa danh mục <strong id="categoryName"></strong>?</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">Hủy</button>
        <a href="#" id="confirmRemoveBtn" class="btn btn-danger">
          <i class="fas fa-times"></i> Xóa
        </a>
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
function confirmRemove(categoryId, categoryName) {
    $('#categoryName').text(categoryName);
    $('#confirmRemoveBtn').attr('href', '<%= request.getContextPath() %>/admin/attributes?action=removeCategory&attributeID=${attribute.attributeID}&categoryID=' + categoryId);
    $('#removeModal').modal('show');
}

// Auto hide alerts after 3 seconds
setTimeout(function() {
    $('.alert').fadeOut('slow');
}, 3000);
</script>
</body>
</html>
