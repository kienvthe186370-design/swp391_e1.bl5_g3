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

  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/fontawesome-free/css/all.min.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/css/adminlte.min.css">
  <style>
    .status-badge { font-size: 0.8rem; padding: 4px 10px; border-radius: 4px; }
    .status-pending { background: #ffc107; color: #000; }
    .status-reviewing { background: #17a2b8; color: #fff; }
    .status-dateproposed { background: #fd7e14; color: #fff; }
    .status-datecountered { background: #e83e8c; color: #fff; }
    .status-dateaccepted { background: #20c997; color: #fff; }
    .status-quotationcreated { background: #007bff; color: #fff; }
    .status-completed { background: #28a745; color: #fff; }
    .status-cancelled { background: #6c757d; color: #fff; }
    .negotiation-badge { font-size: 0.7rem; }
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
            <h1><i class="fas fa-file-invoice"></i> Quản Lý Yêu Cầu Báo Giá (RFQ)</h1>
          </div>
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/admin/dashboard">Dashboard</a></li>
              <li class="breadcrumb-item active">RFQ</li>
            </ol>
          </div>
        </div>
      </div>
    </section>

    <section class="content">
      <div class="container-fluid">

        <!-- Statistics Cards - 5 cards đều nhau trên 1 dòng -->
        <div class="row" style="display: flex; flex-wrap: wrap;">
          <div class="col" style="flex: 1; min-width: 150px;">
            <div class="small-box bg-warning">
              <div class="inner">
                <h3>${pendingCount}</h3>
                <p>Chờ Xử Lý</p>
              </div>
              <div class="icon"><i class="fas fa-clock"></i></div>
            </div>
          </div>
          <div class="col" style="flex: 1; min-width: 150px;">
            <div class="small-box bg-info">
              <div class="inner">
                <h3>${reviewingCount}</h3>
                <p>Đang Xem Xét</p>
              </div>
              <div class="icon"><i class="fas fa-search"></i></div>
            </div>
          </div>
          <div class="col" style="flex: 1; min-width: 150px;">
            <div class="small-box bg-orange">
              <div class="inner">
                <h3>${negotiatingCount}</h3>
                <p>Thương Lượng Ngày</p>
              </div>
              <div class="icon"><i class="fas fa-calendar-alt"></i></div>
            </div>
          </div>
          <div class="col" style="flex: 1; min-width: 150px;">
            <div class="small-box bg-primary">
              <div class="inner">
                <h3>${quotationCreatedCount}</h3>
                <p>Đã Tạo Báo Giá</p>
              </div>
              <div class="icon"><i class="fas fa-file-invoice-dollar"></i></div>
            </div>
          </div>
          <div class="col" style="flex: 1; min-width: 150px;">
            <div class="small-box bg-success">
              <div class="inner">
                <h3>${completedCount}</h3>
                <p>Hoàn Thành</p>
              </div>
              <div class="icon"><i class="fas fa-check-circle"></i></div>
            </div>
          </div>
        </div>

        <!-- RFQ List -->
        <div class="card">
          <div class="card-header">
            <h5 class="mb-0"><i class="fas fa-list"></i> Danh Sách RFQ Được Phân Công</h5>
          </div>
          
          <!-- Filter -->
          <div class="card-body border-bottom">
            <form class="row g-3 align-items-end" method="GET">
              <div class="col-md-5">
                <input type="text" class="form-control" name="keyword" placeholder="Tìm theo mã RFQ, công ty, khách hàng..." value="${keyword}">
              </div>
              <div class="col-md-5">
                <select class="form-control" name="status">
                  <option value="">Tất cả trạng thái</option>
                  <option value="Pending" ${status == 'Pending' ? 'selected' : ''}>Chờ xử lý</option>
                  <option value="Reviewing" ${status == 'Reviewing' ? 'selected' : ''}>Đang xem xét</option>
                  <option value="DateProposed" ${status == 'DateProposed' ? 'selected' : ''}>Đề xuất ngày</option>
                  <option value="DateCountered" ${status == 'DateCountered' ? 'selected' : ''}>KH đề xuất ngày</option>
                  <option value="DateAccepted" ${status == 'DateAccepted' ? 'selected' : ''}>Đã chấp nhận ngày</option>
                  <option value="QuotationCreated" ${status == 'QuotationCreated' ? 'selected' : ''}>Đã tạo báo giá</option>
                  <option value="Completed" ${status == 'Completed' ? 'selected' : ''}>Hoàn thành</option>
                  <option value="Cancelled" ${status == 'Cancelled' ? 'selected' : ''}>Đã hủy</option>
                </select>
              </div>
              <div class="col-md-2">
                <button type="submit" class="btn btn-primary w-100"><i class="fas fa-search"></i> Tìm</button>
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
                    <th>Ngày Giao</th>
                    <th>Thương Lượng</th>
                    <th>Trạng Thái</th>
                    <th>Hành Động</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="rfq" items="${rfqs}">
                    <tr class="${rfq.status == 'DateCountered' ? 'table-warning' : ''}">
                      <td>
                        <a href="<%= request.getContextPath() %>/admin/rfq/detail?id=${rfq.rfqID}">
                          <strong>${rfq.rfqCode}</strong>
                        </a>
                      </td>
                      <td>
                        ${rfq.contactPerson}<br>
                        <small class="text-muted">${rfq.contactPhone}</small>
                      </td>
                      <td>${not empty rfq.companyName ? rfq.companyName : '-'}</td>
                      <td><fmt:formatDate value="${rfq.createdDate}" pattern="dd/MM/yyyy"/></td>
                      <td>
                        <small class="text-muted">Yêu cầu:</small> <fmt:formatDate value="${rfq.requestedDeliveryDate}" pattern="dd/MM/yyyy"/>
                        <c:if test="${rfq.proposedDeliveryDate != null}">
                          <br><small class="text-warning">Đề xuất:</small> <fmt:formatDate value="${rfq.proposedDeliveryDate}" pattern="dd/MM/yyyy"/>
                        </c:if>
                        <c:if test="${rfq.customerCounterDate != null}">
                          <br><small class="text-info">KH đề xuất:</small> <fmt:formatDate value="${rfq.customerCounterDate}" pattern="dd/MM/yyyy"/>
                        </c:if>
                      </td>
                      <td class="text-center">
                        <c:if test="${rfq.dateNegotiationCount > 0}">
                          <span class="badge badge-secondary negotiation-badge">
                            ${rfq.dateNegotiationCount}/${rfq.maxDateNegotiationCount}
                          </span>
                        </c:if>
                        <c:if test="${rfq.dateNegotiationCount == 0}">
                          <span class="text-muted">-</span>
                        </c:if>
                      </td>
                      <td>
                        <span class="badge status-badge status-${rfq.status.toLowerCase()}">
                          ${rfq.statusDisplayName}
                        </span>
                      </td>
                      <td>
                        <div class="btn-group btn-group-sm">
                          <a href="<%= request.getContextPath() %>/admin/rfq/detail?id=${rfq.rfqID}" class="btn btn-outline-info" title="Xem chi tiết">
                            <i class="fas fa-eye"></i>
                          </a>
                          <c:if test="${rfq.canCreateQuotation()}">
                            <a href="<%= request.getContextPath() %>/admin/quotations/form?rfqId=${rfq.rfqID}" class="btn btn-outline-success" title="Tạo báo giá">
                              <i class="fas fa-file-invoice-dollar"></i>
                            </a>
                          </c:if>
                        </div>
                      </td>
                    </tr>
                  </c:forEach>
                  <c:if test="${empty rfqs}">
                    <tr><td colspan="8" class="text-center py-4 text-muted">Không có RFQ nào được phân công cho bạn</td></tr>
                  </c:if>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Pagination -->
          <div class="card-footer">
            <div class="row">
              <div class="col-sm-6 text-muted" style="padding-top: 8px;">
                <c:choose>
                  <c:when test="${totalCount > 0}">
                    <c:set var="startRecord" value="${(currentPage - 1) * pageSize + 1}" />
                    <c:set var="endRecord" value="${currentPage * pageSize > totalCount ? totalCount : currentPage * pageSize}" />
                    Hiển thị <strong>${startRecord}</strong> đến <strong>${endRecord}</strong> của <strong>${totalCount}</strong> bản ghi
                  </c:when>
                  <c:otherwise>
                    Hiển thị <strong>0</strong> bản ghi
                  </c:otherwise>
                </c:choose>
              </div>
              <div class="col-sm-6 text-right">
                <nav style="display: inline-block;">
                  <ul class="pagination pagination-sm mb-0">
                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                      <a class="page-link" href="?page=${currentPage - 1}&keyword=${keyword}&status=${status}">Trước</a>
                    </li>
                    <c:forEach begin="1" end="${totalPages > 0 ? totalPages : 1}" var="i">
                      <li class="page-item ${currentPage == i ? 'active' : ''}">
                        <a class="page-link" href="?page=${i}&keyword=${keyword}&status=${status}">${i}</a>
                      </li>
                    </c:forEach>
                    <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                      <a class="page-link" href="?page=${currentPage + 1}&keyword=${keyword}&status=${status}">Sau</a>
                    </li>
                  </ul>
                </nav>
              </div>
            </div>
          </div>
        </div>

      </div>
    </section>
  </div>

  <jsp:include page="includes/admin-footer.jsp" />

</div>

<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/jquery/jquery.min.js"></script>
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/js/adminlte.min.js"></script>
</body>
</html>
