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
  <title>Quản lý Voucher - Admin</title>

  <!-- Google Font: Source Sans Pro -->
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
  <!-- Font Awesome -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/fontawesome-free/css/all.min.css">
  <!-- DataTables -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/datatables-bs4/css/dataTables.bootstrap4.min.css">
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
            <h1><i class="fas fa-ticket-alt"></i> Quản lý Voucher</h1>
          </div>
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp">Home</a></li>
              <li class="breadcrumb-item active">Voucher</li>
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
            <i class="icon fas fa-check"></i> Thêm voucher thành công!
          </div>
        </c:if>
        <c:if test="${param.success == 'updated'}">
          <div class="alert alert-success alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-check"></i> Cập nhật voucher thành công!
          </div>
        </c:if>
        <c:if test="${param.success == 'deleted'}">
          <div class="alert alert-success alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-check"></i> Xóa voucher thành công!
          </div>
        </c:if>
        <c:if test="${param.success == 'toggled'}">
          <div class="alert alert-success alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-check"></i> Cập nhật trạng thái voucher thành công!
          </div>
        </c:if>
        <c:if test="${param.error == 'notfound'}">
          <div class="alert alert-danger alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-ban"></i> Không tìm thấy voucher!
          </div>
        </c:if>
        <c:if test="${param.error == 'code_exists'}">
          <div class="alert alert-danger alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-ban"></i> Mã voucher đã tồn tại!
          </div>
        </c:if>
        <c:if test="${param.error == 'add_failed' || param.error == 'update_failed' || param.error == 'delete_failed'}">
          <div class="alert alert-danger alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-ban"></i> Có lỗi xảy ra. Vui lòng thử lại!
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
            <form method="get" action="<%= request.getContextPath() %>/admin/voucher">
              <div class="row">
                <div class="col-md-3">
                  <div class="form-group">
                    <label>Tìm kiếm</label>
                    <input type="text" name="search" class="form-control" placeholder="Mã hoặc tên voucher..." value="${search}">
                  </div>
                </div>
                <div class="col-md-2">
                  <div class="form-group">
                    <label>Trạng thái</label>
                    <select name="status" class="form-control">
                      <option value="">Tất cả</option>
                      <option value="active" ${status == 'active' ? 'selected' : ''}>Hoạt động</option>
                      <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Không hoạt động</option>
                    </select>
                  </div>
                </div>
                <div class="col-md-2">
                  <div class="form-group">
                    <label>Loại giảm giá</label>
                    <select name="discountType" class="form-control">
                      <option value="">Tất cả</option>
                      <option value="percentage" ${discountType == 'percentage' ? 'selected' : ''}>Phần trăm</option>
                      <option value="fixed" ${discountType == 'fixed' ? 'selected' : ''}>Số tiền cố định</option>
                    </select>
                  </div>
                </div>
                <div class="col-md-2">
                  <div class="form-group">
                    <label>Số voucher/trang</label>
                    <select name="pageSize" class="form-control">
                      <option value="5" ${pageSize == 5 ? 'selected' : ''}>5</option>
                      <option value="10" ${pageSize == 10 ? 'selected' : ''}>10</option>
                      <option value="20" ${pageSize == 20 ? 'selected' : ''}>20</option>
                    </select>
                  </div>
                </div>
                <div class="col-md-3">
                  <div class="form-group">
                    <label>&nbsp;</label>
                    <button type="submit" class="btn btn-primary btn-block"><i class="fas fa-search"></i> Tìm</button>
                  </div>
                </div>
              </div>
            </form>
          </div>
        </div>

        <!-- Voucher List Card -->
        <div class="card">
          <div class="card-header">
            <h3 class="card-title">Danh sách Voucher (${totalVouchers} voucher)</h3>
            <div class="card-tools">
              <a href="<%= request.getContextPath() %>/admin/voucher?action=add" class="btn btn-success btn-sm">
                <i class="fas fa-plus"></i> Thêm Voucher
              </a>
            </div>
          </div>
          <div class="card-body table-responsive p-0">
            <table class="table table-hover text-nowrap">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Mã Voucher</th>
                  <th>Tên Voucher</th>
                  <th>Loại</th>
                  <th>Giá trị</th>
                  <th>Đơn tối thiểu</th>
                  <th>Đã dùng</th>
                  <th>Thời gian</th>
                  <th>Trạng thái</th>
                  <th>Hành động</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="voucher" items="${vouchers}">
                  <tr>
                    <td>${voucher.voucherID}</td>
                    <td><strong>${voucher.voucherCode}</strong></td>
                    <td>${voucher.voucherName}</td>
                    <td>
                      <c:choose>
                        <c:when test="${voucher.discountType == 'percentage'}">
                          <span class="badge badge-info">Phần trăm</span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge badge-warning">Cố định</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${voucher.discountType == 'percentage'}">
                          <fmt:formatNumber value="${voucher.discountValue}" pattern="#,##0.##"/>%
                        </c:when>
                        <c:otherwise>
                          <fmt:formatNumber value="${voucher.discountValue}" pattern="#,##0"/>₫
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td><fmt:formatNumber value="${voucher.minOrderValue}" pattern="#,##0"/>₫</td>
                    <td>
                      ${voucher.usedCount}
                      <c:if test="${voucher.maxUsage != null}">
                        / ${voucher.maxUsage}
                      </c:if>
                    </td>
                    <td>
                      <small>
                        <fmt:formatDate value="${voucher.startDate}" pattern="dd/MM/yyyy HH:mm"/> -<br>
                        <fmt:formatDate value="${voucher.endDate}" pattern="dd/MM/yyyy HH:mm"/>
                      </small>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${voucher.isActive}">
                          <span class="badge badge-success">Hoạt động</span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge badge-secondary">Tắt</span>
                        </c:otherwise>
                      </c:choose>
                      <c:if test="${voucher.isPrivate}">
                        <br><span class="badge badge-dark mt-1">Riêng tư</span>
                      </c:if>
                    </td>
                    <td>
                      <div class="btn-group">
                        <a href="<%= request.getContextPath() %>/admin/voucher?action=edit&id=${voucher.voucherID}" 
                           class="btn btn-warning btn-sm" title="Chỉnh sửa">
                          <i class="fas fa-edit"></i>
                        </a>
                        <c:choose>
                          <c:when test="${voucher.isActive}">
                            <button type="button" class="btn btn-danger btn-sm" 
                                    onclick="confirmToggleStatus(${voucher.voucherID}, '${voucher.voucherCode}', false)" 
                                    title="Khóa voucher">
                              <i class="fas fa-lock"></i>
                            </button>
                          </c:when>
                          <c:otherwise>
                            <button type="button" class="btn btn-success btn-sm" 
                                    onclick="confirmToggleStatus(${voucher.voucherID}, '${voucher.voucherCode}', true)" 
                                    title="Mở khóa voucher">
                              <i class="fas fa-unlock"></i>
                            </button>
                          </c:otherwise>
                        </c:choose>
                      </div>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty vouchers}">
                  <tr>
                    <td colspan="10" class="text-center">Không có voucher nào.</td>
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
                  <a class="page-link" href="?page=${currentPage - 1}&search=${search}&status=${status}&discountType=${discountType}&pageSize=${pageSize}">«</a>
                </li>
              </c:if>
              
              <c:forEach begin="1" end="${totalPages}" var="i">
                <li class="page-item ${currentPage == i ? 'active' : ''}">
                  <a class="page-link" href="?page=${i}&search=${search}&status=${status}&discountType=${discountType}&pageSize=${pageSize}">${i}</a>
                </li>
              </c:forEach>
              
              <c:if test="${currentPage < totalPages}">
                <li class="page-item">
                  <a class="page-link" href="?page=${currentPage + 1}&search=${search}&status=${status}&discountType=${discountType}&pageSize=${pageSize}">»</a>
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

</div>

<!-- jQuery -->
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/jquery/jquery.min.js"></script>
<!-- Bootstrap 4 -->
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<!-- AdminLTE App -->
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/js/adminlte.min.js"></script>

<script>
function confirmToggleStatus(id, voucherCode, isActivating) {
    if (!isActivating) {
        $('#modalHeader').removeClass('bg-success').addClass('bg-danger');
        $('#modalTitle').text('Xác nhận khóa voucher');
        $('#modalMessage').html('Bạn có chắc chắn muốn <strong>khóa</strong> voucher <strong>' + voucherCode + '</strong>?<br><small class="text-muted">Voucher sẽ không thể sử dụng.</small>');
        $('#confirmToggleBtn').removeClass('btn-success').addClass('btn-danger');
        $('#modalIcon').removeClass('fa-unlock').addClass('fa-lock');
        $('#modalBtnText').text('Khóa');
    } else {
        $('#modalHeader').removeClass('bg-danger').addClass('bg-success');
        $('#modalTitle').text('Xác nhận mở khóa voucher');
        $('#modalMessage').html('Bạn có chắc chắn muốn <strong>mở khóa</strong> voucher <strong>' + voucherCode + '</strong>?<br><small class="text-muted">Voucher sẽ có thể sử dụng trở lại.</small>');
        $('#confirmToggleBtn').removeClass('btn-danger').addClass('btn-success');
        $('#modalIcon').removeClass('fa-lock').addClass('fa-unlock');
        $('#modalBtnText').text('Mở khóa');
    }
    $('#confirmToggleBtn').attr('href', '<%= request.getContextPath() %>/admin/voucher?action=toggleStatus&id=' + id);
    $('#toggleStatusModal').modal('show');
}

// Auto hide alerts after 5 seconds
setTimeout(function() {
    $('.alert').fadeOut('slow');
}, 5000);
</script>

</body>
</html>
