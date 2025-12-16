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
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/css/adminlte.min.css">
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

        <!-- Filter Card -->
        <div class="card card-primary card-outline">
          <div class="card-header">
            <h3 class="card-title"><i class="fas fa-filter"></i> Tìm kiếm & Lọc</h3>
          </div>
          <div class="card-body">
            <form method="get" action="<%= request.getContextPath() %>/admin/discount">
              <div class="row">
                <div class="col-md-3">
                  <div class="form-group">
                    <label>Tìm kiếm</label>
                    <input type="text" name="search" class="form-control" placeholder="Tên chiến dịch..." value="${search}">
                  </div>
                </div>
                <div class="col-md-2">
                  <div class="form-group">
                    <label>Trạng thái</label>
                    <select name="status" class="form-control">
                      <option value="">Tất cả</option>
                      <option value="active" ${status == 'active' ? 'selected' : ''}>Đang diễn ra</option>
                      <option value="upcoming" ${status == 'upcoming' ? 'selected' : ''}>Sắp diễn ra</option>
                      <option value="expired" ${status == 'expired' ? 'selected' : ''}>Đã kết thúc</option>
                      <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Tắt</option>
                    </select>
                  </div>
                </div>
                <div class="col-md-2">
                  <div class="form-group">
                    <label>Áp dụng cho</label>
                    <select name="appliedToType" class="form-control">
                      <option value="">Tất cả</option>
                      <option value="all" ${appliedToType == 'all' ? 'selected' : ''}>Toàn bộ</option>
                      <option value="category" ${appliedToType == 'category' ? 'selected' : ''}>Danh mục</option>
                      <option value="product" ${appliedToType == 'product' ? 'selected' : ''}>Sản phẩm</option>
                      <option value="brand" ${appliedToType == 'brand' ? 'selected' : ''}>Thương hiệu</option>
                    </select>
                  </div>
                </div>
                <div class="col-md-2">
                  <div class="form-group">
                    <label>Số/trang</label>
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

        <!-- Campaign List Card -->
        <div class="card">
          <div class="card-header">
            <h3 class="card-title">Danh sách Chiến dịch (${totalCampaigns} chiến dịch)</h3>
            <div class="card-tools">
              <a href="<%= request.getContextPath() %>/admin/discount?action=add" class="btn btn-success btn-sm">
                <i class="fas fa-plus"></i> Thêm Chiến dịch
              </a>
            </div>
          </div>
          <div class="card-body table-responsive p-0">
            <table class="table table-hover text-nowrap">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Tên chiến dịch</th>
                  <th>Loại giảm</th>
                  <th>Giá trị</th>
                  <th>Áp dụng cho</th>
                  <th>Thời gian</th>
                  <th>Trạng thái</th>
                  <th>Hành động</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="campaign" items="${campaigns}">
                  <tr>
                    <td>${campaign.discountID}</td>
                    <td><strong>${campaign.campaignName}</strong></td>
                    <td>
                      <c:choose>
                        <c:when test="${campaign.discountType == 'percentage'}">
                          <span class="badge badge-info">Phần trăm</span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge badge-warning">Cố định</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${campaign.discountType == 'percentage'}">
                          <fmt:formatNumber value="${campaign.discountValue}" pattern="#,##0.##"/>%
                          <c:if test="${campaign.maxDiscountAmount != null}">
                            <br><small class="text-muted">Tối đa: <fmt:formatNumber value="${campaign.maxDiscountAmount}" pattern="#,##0"/>₫</small>
                          </c:if>
                        </c:when>
                        <c:otherwise>
                          <fmt:formatNumber value="${campaign.discountValue}" pattern="#,##0"/>₫
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${campaign.appliedToType == 'all'}">
                          <span class="badge badge-primary">Tất cả</span>
                        </c:when>
                        <c:when test="${campaign.appliedToType == 'category'}">
                          <span class="badge badge-success">Danh mục</span>
                          <c:if test="${not empty campaign.appliedToName}">
                            <br><small>${campaign.appliedToName}</small>
                          </c:if>
                        </c:when>
                        <c:when test="${campaign.appliedToType == 'product'}">
                          <span class="badge badge-info">Sản phẩm</span>
                          <c:if test="${not empty campaign.appliedToName}">
                            <br><small>${campaign.appliedToName}</small>
                          </c:if>
                        </c:when>
                        <c:when test="${campaign.appliedToType == 'brand'}">
                          <span class="badge badge-secondary">Thương hiệu</span>
                          <c:if test="${not empty campaign.appliedToName}">
                            <br><small>${campaign.appliedToName}</small>
                          </c:if>
                        </c:when>
                      </c:choose>
                    </td>
                    <td>
                      <small>
                        ${campaign.startDate.toString().substring(0, 16).replace('T', ' ')}<br>
                        ${campaign.endDate.toString().substring(0, 16).replace('T', ' ')}
                      </small>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${campaign.statusText == 'Đang diễn ra'}">
                          <span class="badge badge-success">${campaign.statusText}</span>
                        </c:when>
                        <c:when test="${campaign.statusText == 'Chưa bắt đầu'}">
                          <span class="badge badge-info">${campaign.statusText}</span>
                        </c:when>
                        <c:when test="${campaign.statusText == 'Đã kết thúc'}">
                          <span class="badge badge-secondary">${campaign.statusText}</span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge badge-danger">${campaign.statusText}</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <div class="btn-group">
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
                      </div>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty campaigns}">
                  <tr>
                    <td colspan="8" class="text-center">Không có chiến dịch nào.</td>
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
                  <a class="page-link" href="?page=${currentPage - 1}&search=${search}&status=${status}&appliedToType=${appliedToType}&pageSize=${pageSize}">«</a>
                </li>
              </c:if>
              
              <c:forEach begin="1" end="${totalPages}" var="i">
                <li class="page-item ${currentPage == i ? 'active' : ''}">
                  <a class="page-link" href="?page=${i}&search=${search}&status=${status}&appliedToType=${appliedToType}&pageSize=${pageSize}">${i}</a>
                </li>
              </c:forEach>
              
              <c:if test="${currentPage < totalPages}">
                <li class="page-item">
                  <a class="page-link" href="?page=${currentPage + 1}&search=${search}&status=${status}&appliedToType=${appliedToType}&pageSize=${pageSize}">»</a>
                </li>
              </c:if>
            </ul>
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
}, 5000);
</script>

</body>
</html>
