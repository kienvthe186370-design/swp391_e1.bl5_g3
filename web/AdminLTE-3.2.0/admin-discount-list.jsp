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
  <title>Quản lý Chiến dịch Giảm giá - Admin</title>

  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/fontawesome-free/css/all.min.css">
  <!-- DataTables -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/datatables-bs4/css/dataTables.bootstrap4.min.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/css/adminlte.min.css">
  <style>
    .text-truncate-1 {
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
      max-width: 100%;
    }
  </style>
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">

  <jsp:include page="includes/admin-header.jsp" />
  <jsp:include page="includes/admin-sidebar.jsp" />

  <div class="content-wrapper">
    <section class="content-header">
      <div class="container-fluid">
        <div class="row mb-2">
          <div class="col-sm-6">
            <h1><i class="fas fa-percentage"></i> Quản lý Chiến dịch Giảm giá</h1>
          </div>
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp">Home</a></li>
              <li class="breadcrumb-item active">Chiến dịch</li>
            </ol>
          </div>
        </div>
      </div>
    </section>

    <section class="content">
      <div class="container-fluid">
        
        <!-- Success/Error Messages -->
        <c:if test="${param.success == 'added'}">
          <div class="alert alert-success alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-check"></i> Thêm chiến dịch thành công!
          </div>
        </c:if>
        <c:if test="${param.success == 'updated'}">
          <div class="alert alert-success alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-check"></i> Cập nhật chiến dịch thành công!
          </div>
        </c:if>
        <c:if test="${param.success == 'toggled'}">
          <div class="alert alert-success alert-dismissible fade show">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="icon fas fa-check"></i> Cập nhật trạng thái thành công!
          </div>
        </c:if>

        <!-- Main Card -->
        <div class="card">
          <div class="card-header">
            <h3 class="card-title">Danh sách Chiến dịch Giảm giá</h3>
            <div class="card-tools">
              <a href="<%= request.getContextPath() %>/admin/discount?action=add" class="btn btn-primary btn-sm">
                <i class="fas fa-plus"></i> Thêm Chiến dịch Mới
              </a>
            </div>
          </div>
          
          <!-- Card Body -->
          <div class="card-body">
            <!-- Filter Form -->
            <form method="get" action="<%= request.getContextPath() %>/admin/discount" class="mb-3">
              <div class="row">
                <div class="col-md-2">
                  <input type="text" name="search" value="${search}" class="form-control" placeholder="Tìm theo tên...">
                </div>
                <div class="col-md-2">
                  <select name="status" class="form-control">
                    <option value="">-- Trạng thái --</option>
                    <option value="active" ${status == 'active' ? 'selected' : ''}>Đang diễn ra</option>
                    <option value="upcoming" ${status == 'upcoming' ? 'selected' : ''}>Sắp diễn ra</option>
                    <option value="expired" ${status == 'expired' ? 'selected' : ''}>Đã kết thúc</option>
                    <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Tắt</option>
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
                  <select name="appliedToType" class="form-control">
                    <option value="">-- Áp dụng cho --</option>
                    <option value="all" ${appliedToType == 'all' ? 'selected' : ''}>Toàn bộ</option>
                    <option value="category" ${appliedToType == 'category' ? 'selected' : ''}>Danh mục</option>
                    <option value="product" ${appliedToType == 'product' ? 'selected' : ''}>Sản phẩm</option>
                    <option value="brand" ${appliedToType == 'brand' ? 'selected' : ''}>Thương hiệu</option>
                  </select>
                </div>
                <div class="col-md-1">
                  <select name="pageSize" class="form-control" onchange="this.form.submit()">
                    <option value="5" ${pageSize == 5 ? 'selected' : ''}>5</option>
                    <option value="10" ${pageSize == 10 ? 'selected' : ''}>10</option>
                    <option value="20" ${pageSize == 20 ? 'selected' : ''}>20</option>
                  </select>
                </div>
                <div class="col-md-2">
                  <button type="submit" class="btn btn-primary btn-block">
                    <i class="fas fa-search"></i> Tìm kiếm
                  </button>
                </div>
                <div class="col-md-1">
                  <a href="<%= request.getContextPath() %>/admin/discount" class="btn btn-secondary btn-block">
                    <i class="fas fa-redo"></i>
                  </a>
                </div>
              </div>
            </form>

            <!-- Table -->
            <table class="table table-bordered table-hover">
              <thead>
                <tr>
                  <th style="width: 60px;">ID</th>
                  <th>Tên chiến dịch</th>
                  <th style="width: 100px;">Loại giảm</th>
                  <th style="width: 120px;">Giá trị</th>
                  <th style="width: 150px;">Áp dụng cho</th>
                  <th style="width: 140px;">Thời gian</th>
                  <th style="width: 110px;">Trạng thái</th>
                  <th style="width: 120px;" class="text-center">Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="campaign" items="${campaigns}">
                  <tr>
                    <td><strong>#${campaign.discountID}</strong></td>
                    <td>
                      <strong class="text-truncate-1" style="display: block; max-width: 250px;" title="${campaign.campaignName}">${campaign.campaignName}</strong>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${campaign.discountType == 'percentage'}">
                          <span class="badge badge-info">
                            <i class="fas fa-percent"></i> Phần trăm
                          </span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge badge-warning">
                            <i class="fas fa-dollar-sign"></i> Cố định
                          </span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${campaign.discountType == 'percentage'}">
                          <strong><fmt:formatNumber value="${campaign.discountValue}" pattern="#,##0.##"/>%</strong>
                          <c:if test="${campaign.maxDiscountAmount != null}">
                            <br><small class="text-muted">Max: <fmt:formatNumber value="${campaign.maxDiscountAmount}" pattern="#,##0"/>₫</small>
                          </c:if>
                        </c:when>
                        <c:otherwise>
                          <strong><fmt:formatNumber value="${campaign.discountValue}" pattern="#,##0"/>₫</strong>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${campaign.appliedToType == 'all'}">
                          <span class="badge badge-primary">
                            <i class="fas fa-globe"></i> Tất cả
                          </span>
                        </c:when>
                        <c:when test="${campaign.appliedToType == 'category'}">
                          <span class="badge badge-success">
                            <i class="fas fa-folder"></i> Danh mục
                          </span>
                          <c:if test="${not empty campaign.appliedToName}">
                            <br><small class="text-truncate-1" style="display: block; max-width: 130px;" title="${campaign.appliedToName}">${campaign.appliedToName}</small>
                          </c:if>
                        </c:when>
                        <c:when test="${campaign.appliedToType == 'product'}">
                          <span class="badge badge-info">
                            <i class="fas fa-box"></i> Sản phẩm
                          </span>
                          <c:if test="${not empty campaign.appliedToName}">
                            <br><small class="text-truncate-1" style="display: block; max-width: 130px;" title="${campaign.appliedToName}">${campaign.appliedToName}</small>
                          </c:if>
                        </c:when>
                        <c:when test="${campaign.appliedToType == 'brand'}">
                          <span class="badge badge-secondary">
                            <i class="fas fa-tag"></i> Thương hiệu
                          </span>
                          <c:if test="${not empty campaign.appliedToName}">
                            <br><small class="text-truncate-1" style="display: block; max-width: 130px;" title="${campaign.appliedToName}">${campaign.appliedToName}</small>
                          </c:if>
                        </c:when>
                      </c:choose>
                    </td>
                    <td>
                      <small>
                        <i class="far fa-calendar-alt"></i> ${campaign.startDate.toString().substring(0, 10)}<br>
                        <i class="far fa-calendar-check"></i> ${campaign.endDate.toString().substring(0, 10)}
                      </small>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${campaign.statusText == 'Đang diễn ra'}">
                          <span class="badge badge-success">
                            <i class="fas fa-check-circle"></i> Đang diễn ra
                          </span>
                        </c:when>
                        <c:when test="${campaign.statusText == 'Chưa bắt đầu'}">
                          <span class="badge badge-info">
                            <i class="fas fa-clock"></i> Chưa bắt đầu
                          </span>
                        </c:when>
                        <c:when test="${campaign.statusText == 'Đã kết thúc'}">
                          <span class="badge badge-secondary">
                            <i class="fas fa-ban"></i> Đã kết thúc
                          </span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge badge-danger">
                            <i class="fas fa-times-circle"></i> ${campaign.statusText}
                          </span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td class="text-center">
                      <a href="<%= request.getContextPath() %>/admin/discount?action=edit&id=${campaign.discountID}" 
                         class="btn btn-warning btn-sm" title="Chỉnh sửa">
                        <i class="fas fa-edit"></i>
                      </a>
                      <c:choose>
                        <c:when test="${campaign.active}">
                          <button type="button" class="btn btn-danger btn-sm" 
                                  onclick="confirmToggleStatus(${campaign.discountID}, '${campaign.campaignName}', false)" 
                                  title="Tắt chiến dịch">
                            <i class="fas fa-power-off"></i>
                          </button>
                        </c:when>
                        <c:otherwise>
                          <button type="button" class="btn btn-success btn-sm" 
                                  onclick="confirmToggleStatus(${campaign.discountID}, '${campaign.campaignName}', true)" 
                                  title="Bật chiến dịch">
                            <i class="fas fa-check"></i>
                          </button>
                        </c:otherwise>
                      </c:choose>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty campaigns}">
                  <tr>
                    <td colspan="8" class="text-center">
                      <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                      <p class="text-muted">Không có chiến dịch nào.</p>
                    </td>
                  </tr>
                </c:if>
              </tbody>
            </table>

            <!-- Pagination -->
            <c:if test="${totalCampaigns > 0}">
              <div class="row mt-3">
                <div class="col-sm-12 col-md-5">
                  <div class="dataTables_info" role="status" aria-live="polite">
                    Hiển thị <strong>${(currentPage-1)*pageSize + 1}</strong> 
                    đến <strong>${currentPage*pageSize > totalCampaigns ? totalCampaigns : currentPage*pageSize}</strong> 
                    của <strong>${totalCampaigns}</strong> chiến dịch
                  </div>
                </div>
                <div class="col-sm-12 col-md-7">
                  <div class="dataTables_paginate paging_simple_numbers float-right">
                    <ul class="pagination">
                      <li class="paginate_button page-item previous ${currentPage == 1 ? 'disabled' : ''}">
                        <a href="?page=${currentPage - 1}&search=${search}&status=${status}&appliedToType=${appliedToType}&pageSize=${pageSize}" 
                           class="page-link">Trước</a>
                      </li>
                      <c:forEach begin="1" end="${totalPages}" var="i">
                        <li class="paginate_button page-item ${currentPage == i ? 'active' : ''}">
                          <a href="?page=${i}&search=${search}&status=${status}&appliedToType=${appliedToType}&pageSize=${pageSize}" 
                             class="page-link">${i}</a>
                        </li>
                      </c:forEach>
                      <li class="paginate_button page-item next ${currentPage >= totalPages ? 'disabled' : ''}">
                        <a href="?page=${currentPage + 1}&search=${search}&status=${status}&appliedToType=${appliedToType}&pageSize=${pageSize}" 
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

  <jsp:include page="includes/admin-footer.jsp" />

<!-- Toggle Status Modal -->
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

<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/jquery/jquery.min.js"></script>
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/js/adminlte.min.js"></script>

<script>
function confirmToggleStatus(id, name, isActivating) {
    if (isActivating) {
        $('#modalHeader').removeClass('bg-danger').addClass('bg-success');
        $('#modalTitle').text('Xác nhận bật chiến dịch');
        $('#modalMessage').html('Bạn có chắc chắn muốn <strong>bật</strong> chiến dịch <strong>' + name + '</strong>?');
        $('#confirmToggleBtn').removeClass('btn-danger').addClass('btn-success');
        $('#modalIcon').removeClass('fa-power-off').addClass('fa-check');
        $('#modalBtnText').text('Bật');
    } else {
        $('#modalHeader').removeClass('bg-success').addClass('bg-danger');
        $('#modalTitle').text('Xác nhận tắt chiến dịch');
        $('#modalMessage').html('Bạn có chắc chắn muốn <strong>tắt</strong> chiến dịch <strong>' + name + '</strong>?');
        $('#confirmToggleBtn').removeClass('btn-success').addClass('btn-danger');
        $('#modalIcon').removeClass('fa-check').addClass('fa-power-off');
        $('#modalBtnText').text('Tắt');
    }
    $('#confirmToggleBtn').attr('href', '<%= request.getContextPath() %>/admin/discount?action=toggleStatus&id=' + id);
    $('#toggleStatusModal').modal('show');
}

setTimeout(function() {
    $('.alert').fadeOut('slow');
}, 3000);
</script>

</body>
</html>
