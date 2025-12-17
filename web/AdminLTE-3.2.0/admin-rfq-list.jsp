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
  <title>Quản Lý Yêu Cầu Báo Giá (RFQ) - Admin</title>

  <!-- Google Font: Source Sans Pro -->
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
  <!-- Font Awesome -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/fontawesome-free/css/all.min.css">
  <!-- Theme style -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/css/adminlte.min.css">
  <style>
    .status-badge { font-size: 0.8rem; padding: 4px 10px; border-radius: 4px; }
    .status-pending { background: #ffc107; color: #000; }
    .status-reviewing { background: #17a2b8; color: #fff; }
    .status-dateproposed { background: #fd7e14; color: #fff; }
    .status-dateaccepted { background: #20c997; color: #fff; }
    .status-daterejected { background: #dc3545; color: #fff; }
    .status-quoted { background: #007bff; color: #fff; }
    .status-quoteaccepted { background: #6f42c1; color: #fff; }
    .status-quoterejected { background: #dc3545; color: #fff; }
    .status-completed { background: #28a745; color: #fff; }
    .status-cancelled { background: #dc3545; color: #fff; }
  </style>
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
            <h1><i class="fas fa-file-invoice"></i> Quản Lý Yêu Cầu Báo Giá (RFQ)</h1>
          </div>
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/admin/dashboard">Dashboard</a></li>
              <li class="breadcrumb-item active">RFQ Management</li>
            </ol>
          </div>
        </div>
      </div>
    </section>

    <!-- Main content -->
    <section class="content">
      <div class="container-fluid">

        <!-- Statistics Cards - AdminLTE Small Box Style -->
        <div class="row">
          <div class="col-lg-3 col-6">
            <div class="small-box bg-warning">
              <div class="inner">
                <h3>${pendingCount}</h3>
                <p>Chờ Xử Lý</p>
              </div>
              <div class="icon">
                <i class="fas fa-clock"></i>
              </div>
            </div>
          </div>
          <div class="col-lg-3 col-6">
            <div class="small-box bg-info">
              <div class="inner">
                <h3>${processingCount}</h3>
                <p>Đang Xử Lý</p>
              </div>
              <div class="icon">
                <i class="fas fa-spinner"></i>
              </div>
            </div>
          </div>
          <div class="col-lg-3 col-6">
            <div class="small-box bg-primary">
              <div class="inner">
                <h3>${quotedCount}</h3>
                <p>Đã Báo Giá</p>
              </div>
              <div class="icon">
                <i class="fas fa-file-invoice-dollar"></i>
              </div>
            </div>
          </div>
          <div class="col-lg-3 col-6">
            <div class="small-box bg-danger">
              <div class="inner">
                <h3>${cancelledCount}</h3>
                <p>Đã Hủy</p>
              </div>
              <div class="icon">
                <i class="fas fa-times-circle"></i>
              </div>
            </div>
          </div>
        </div>

        <!-- RFQ List -->
        <div class="card">
          <div class="card-header">
            <h5 class="mb-0"><i class="fas fa-list"></i> Danh Sách Yêu Cầu Báo Giá</h5>
          </div>
          
          <!-- Filter inside card -->
          <div class="card-body border-bottom">
            <form class="row g-3 align-items-end" method="GET" action="<%= request.getContextPath() %>/admin/rfq">
              <div class="col-md-5">
                <input type="text" class="form-control" name="keyword" placeholder="Tìm theo mã RFQ, công ty, khách hàng..." value="${keyword}">
              </div>
              <div class="col-md-5">
                <select class="form-control" name="status">
                  <option value="">Tất cả trạng thái</option>
                  <option value="Pending" ${status == 'Pending' ? 'selected' : ''}>Chờ xử lý</option>
                  <option value="DateProposed" ${status == 'DateProposed' ? 'selected' : ''}>Đề xuất ngày</option>
                  <option value="DateAccepted" ${status == 'DateAccepted' ? 'selected' : ''}>Đã chấp nhận ngày</option>
                  <option value="Cancelled" ${status == 'Cancelled' ? 'selected' : ''}>Đã hủy</option>
                  <option value="Quoted" ${status == 'Quoted' ? 'selected' : ''}>Đã tạo báo giá</option>
                </select>
              </div>

              <div class="col-md-2">
                <button type="submit" class="btn btn-primary w-100"><i class="fas fa-search"></i> Tìm kiếm</button>
              </div>
            </form>
          </div>
          <div class="card-body p-0">
            <div class="table-responsive">
              <table class="table table-hover mb-0">
                <thead class="table-light">
                  <tr>
                    <th>Mã RFQ</th>
                    <th>Khách Hàng</th>
                    <th>Công Ty</th>
                    <th>Ngày Tạo</th>
                    <th>Ngày Yêu Cầu</th>
                    <th>Giá Trị</th>
                    <th>Trạng Thái</th>
                    <th>Hành Động</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="rfq" items="${rfqs}">
                    <tr>
                      <td>
                        <a href="<%= request.getContextPath() %>/admin/rfq/detail?id=${rfq.rfqID}">
                          <strong>${rfq.rfqCode}</strong>
                        </a>
                      </td>
                      <td>
                        ${rfq.contactPerson}<br>
                        <small class="text-muted">${rfq.contactPhone}</small>
                      </td>
                      <td>${rfq.companyName}</td>
                      <td><fmt:formatDate value="${rfq.createdDate}" pattern="dd/MM/yyyy"/></td>
                      <td>
                        <fmt:formatDate value="${rfq.requestedDeliveryDate}" pattern="dd/MM/yyyy"/>
                        <c:if test="${rfq.proposedDeliveryDate != null}">
                          <br><small class="text-primary">→ <fmt:formatDate value="${rfq.proposedDeliveryDate}" pattern="dd/MM/yyyy"/></small>
                        </c:if>
                      </td>
                      <td>
                        <c:choose>
                          <c:when test="${rfq.totalAmount != null && rfq.totalAmount > 0}">
                            <strong class="text-primary"><fmt:formatNumber value="${rfq.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></strong>
                          </c:when>
                          <c:otherwise><span class="text-muted">Chưa báo giá</span></c:otherwise>
                        </c:choose>
                      </td>
                      <td>
                        <span class="badge status-badge status-${rfq.status.toLowerCase()}">
                          ${rfq.statusDisplayName}
                        </span>
                      </td>
                      <td>
                        <div class="btn-group btn-group-sm">
                          <a href="<%= request.getContextPath() %>/admin/rfq/detail?id=${rfq.rfqID}" class="btn btn-outline-info" title="Xem">
                            <i class="fas fa-eye"></i>
                          </a>
                        </div>
                      </td>
                    </tr>
                  </c:forEach>
                  <c:if test="${empty rfqs}">
                    <tr><td colspan="8" class="text-center py-4 text-muted">Không có dữ liệu</td></tr>
                  </c:if>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Pagination -->
          <div class="card-footer d-flex justify-content-between align-items-center">
            <div class="text-muted">
              Hiển thị trang ${currentPage} / ${totalPages > 0 ? totalPages : 1} (Tổng: ${totalCount} bản ghi)
            </div>
            <c:if test="${totalPages > 1}">
              <nav>
                <ul class="pagination pagination-sm mb-0">
                  <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                    <a class="page-link" href="?page=${currentPage - 1}&keyword=${keyword}&status=${status}">«</a>
                  </li>
                  <c:forEach begin="1" end="${totalPages}" var="i">
                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                      <a class="page-link" href="?page=${i}&keyword=${keyword}&status=${status}">${i}</a>
                    </li>
                  </c:forEach>
                  <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                    <a class="page-link" href="?page=${currentPage + 1}&keyword=${keyword}&status=${status}">»</a>
                  </li>
                </ul>
              </nav>
            </c:if>
          </div>
        </div>

      </div>
    </section>
  </div>

  <!-- Footer -->
  <jsp:include page="includes/admin-footer.jsp" />

</div>

<!-- jQuery -->
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/jquery/jquery.min.js"></script>
<!-- Bootstrap 4 -->
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<!-- AdminLTE App -->
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/js/adminlte.min.js"></script>
</body>
</html>
