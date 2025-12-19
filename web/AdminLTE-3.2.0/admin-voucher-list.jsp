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
        <c:if test="${param.error == 'invalid_usage_limit'}">
          <div class="alert alert-danger alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-exclamation-triangle"></i> 
            <strong>Lỗi giới hạn sử dụng!</strong> 
            Số lần sử dụng tối đa / khách hàng không được lớn hơn tổng số lần sử dụng của voucher.
          </div>
        </c:if>
        <c:if test="${param.error == 'add_failed' || param.error == 'update_failed' || param.error == 'delete_failed'}">
          <div class="alert alert-danger alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-ban"></i> Có lỗi xảy ra. Vui lòng thử lại!
          </div>
        </c:if>

        <!-- Main Card -->
        <div class="card">
          <div class="card-header">
            <h3 class="card-title">Danh sách Voucher</h3>
            <div class="card-tools">
              <a href="<%= request.getContextPath() %>/admin/voucher?action=add" class="btn btn-primary btn-sm">
                <i class="fas fa-plus"></i> Thêm Voucher Mới
              </a>
            </div>
          </div>
          
          <!-- Card Body -->
          <div class="card-body">
            <!-- Filter Form -->
            <form method="get" action="<%= request.getContextPath() %>/admin/voucher" class="mb-3">
              <div class="row">
                <div class="col-md-3">
                  <input type="text" name="search" value="${search}" class="form-control" placeholder="Tìm theo mã hoặc tên...">
                </div>
                <div class="col-md-2">
                  <select name="status" class="form-control">
                    <option value="">-- Tất cả trạng thái --</option>
                    <option value="active" ${status == 'active' ? 'selected' : ''}>Hoạt động</option>
                    <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Không hoạt động</option>
                  </select>
                </div>
                <div class="col-md-2">
                  <select name="discountType" class="form-control">
                    <option value="">-- Loại giảm --</option>
                    <option value="percentage" ${discountType == 'percentage' ? 'selected' : ''}>Phần trăm</option>
                    <option value="fixed" ${discountType == 'fixed' ? 'selected' : ''}>Cố định</option>
                  </select>
                </div>
                <div class="col-md-2">
                  <select name="pageSize" class="form-control" onchange="this.form.submit()">
                    <option value="5" ${pageSize == 5 ? 'selected' : ''}>5/trang</option>
                    <option value="10" ${pageSize == 10 ? 'selected' : ''}>10/trang</option>
                    <option value="20" ${pageSize == 20 ? 'selected' : ''}>20/trang</option>
                  </select>
                </div>
                <div class="col-md-2">
                  <button type="submit" class="btn btn-primary btn-block">
                    <i class="fas fa-search"></i> Tìm kiếm
                  </button>
                </div>
                <div class="col-md-1">
                  <a href="<%= request.getContextPath() %>/admin/voucher" class="btn btn-secondary btn-block">
                    <i class="fas fa-redo"></i>
                  </a>
                </div>
              </div>
            </form>

            <!-- Table -->
            <table class="table table-bordered table-hover">
              <thead>
                <tr>
                  <th style="width: 50px;">ID</th>
                  <th style="width: 120px;">Mã Voucher</th>
                  <th>Tên Voucher</th>
                  <th style="width: 90px;">Loại</th>
                  <th style="width: 100px;">Giá trị</th>
                  <th style="width: 110px;">Đơn tối thiểu</th>
                  <th style="width: 100px;">Đã dùng</th>
                  <th style="width: 140px;">Thời gian</th>
                  <th style="width: 100px;">Trạng thái</th>
                  <th style="width: 120px;" class="text-center">Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="voucher" items="${vouchers}">
                  <tr>
                    <td><strong>#${voucher.voucherID}</strong></td>
                    <td>
                      <strong style="display: block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="${voucher.voucherCode}">
                        ${voucher.voucherCode}
                      </strong>
                    </td>
                    <td>
                      <span style="display: block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 200px;" title="${voucher.voucherName}">
                        ${voucher.voucherName}
                      </span>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${voucher.discountType == 'percentage'}">
                          <span class="badge badge-info">
                            <i class="fas fa-percent"></i> 
                          </span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge badge-warning">
                            <i class="fas fa-dollar-sign"></i> 
                          </span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${voucher.discountType == 'percentage'}">
                          <strong><fmt:formatNumber value="${voucher.discountValue}" pattern="#,##0.##"/>%</strong>
                        </c:when>
                        <c:otherwise>
                          <strong><fmt:formatNumber value="${voucher.discountValue}" pattern="#,##0"/>₫</strong>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td><fmt:formatNumber value="${voucher.minOrderValue}" pattern="#,##0"/>₫</td>
                    <td>
                      <strong>${voucher.usedCount}</strong>
                      <c:if test="${voucher.maxUsage != null}">
                        / ${voucher.maxUsage}
                      </c:if>
                      <br>
                      <small class="text-muted">
                        <i class="fas fa-user"></i> Max/KH: 
                        <strong>${voucher.maxUsagePerCustomer != null ? voucher.maxUsagePerCustomer : '∞'}</strong>
                      </small>
                    </td>
                    <td>
                      <small>
                        <i class="far fa-calendar-alt"></i> <fmt:formatDate value="${voucher.startDate}" pattern="dd/MM/yyyy"/><br>
                        <i class="far fa-calendar-check"></i> <fmt:formatDate value="${voucher.endDate}" pattern="dd/MM/yyyy"/>
                      </small>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${voucher.isActive}">
                          <span class="badge badge-success">
                            <i class="fas fa-check-circle"></i> Hoạt động
                          </span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge badge-secondary">
                            <i class="fas fa-times-circle"></i> Tắt
                          </span>
                        </c:otherwise>
                      </c:choose>
                      <c:if test="${voucher.isPrivate}">
                        <br><span class="badge badge-dark mt-1"><i class="fas fa-lock"></i> Riêng tư</span>
                      </c:if>
                    </td>
                    <td class="text-center">
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
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty vouchers}">
                  <tr>
                    <td colspan="10" class="text-center">
                      <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                      <p class="text-muted">Không có voucher nào.</p>
                    </td>
                  </tr>
                </c:if>
              </tbody>
            </table>

            <!-- Pagination -->
            <c:if test="${totalVouchers > 0}">
              <div class="row mt-3">
                <div class="col-sm-12 col-md-5">
                  <div class="dataTables_info" role="status" aria-live="polite">
                    Hiển thị <strong>${(currentPage-1)*pageSize + 1}</strong> 
                    đến <strong>${currentPage*pageSize > totalVouchers ? totalVouchers : currentPage*pageSize}</strong> 
                    của <strong>${totalVouchers}</strong> voucher
                  </div>
                </div>
                <div class="col-sm-12 col-md-7">
                  <div class="dataTables_paginate paging_simple_numbers float-right">
                    <ul class="pagination">
                      <li class="paginate_button page-item previous ${currentPage == 1 ? 'disabled' : ''}">
                        <a href="?page=${currentPage - 1}&search=${search}&status=${status}&discountType=${discountType}&pageSize=${pageSize}" 
                           class="page-link">Trước</a>
                      </li>
                      <c:forEach begin="1" end="${totalPages}" var="i">
                        <li class="paginate_button page-item ${currentPage == i ? 'active' : ''}">
                          <a href="?page=${i}&search=${search}&status=${status}&discountType=${discountType}&pageSize=${pageSize}" 
                             class="page-link">${i}</a>
                        </li>
                      </c:forEach>
                      <li class="paginate_button page-item next ${currentPage >= totalPages ? 'disabled' : ''}">
                        <a href="?page=${currentPage + 1}&search=${search}&status=${status}&discountType=${discountType}&pageSize=${pageSize}" 
                           class="page-link">Sau</a>
                      </li>
                    </ul>
                  </div>
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

// Auto hide alerts after 3 seconds
setTimeout(function() {
    $('.alert').fadeOut('slow');
}, 3000);
</script>

</body>
</html>
