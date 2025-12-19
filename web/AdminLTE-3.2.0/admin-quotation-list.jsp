<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Quản Lý Báo Giá - Admin</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/fontawesome-free/css/all.min.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/css/adminlte.min.css">
  <style>
    .status-badge { font-size: 0.85rem; padding: 5px 10px; border-radius: 15px; }
    /* Fix cho nút action */
    .btn i { pointer-events: none; }
    .btn-action { display: inline-block; margin: 2px; }
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
            <h1><i class="fas fa-file-invoice-dollar"></i> Quản Lý Báo Giá</h1>
          </div>
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/admin/dashboard">Dashboard</a></li>
              <li class="breadcrumb-item active">Báo Giá</li>
            </ol>
          </div>
        </div>
      </div>
    </section>

    <section class="content">
      <div class="container-fluid">
        <!-- Stats -->
        <div class="row mb-3">
          <div class="col-lg-3 col-6">
            <div class="small-box bg-primary">
              <div class="inner"><h3>${sentCount}</h3><p>Đã gửi</p></div>
              <div class="icon"><i class="fas fa-paper-plane"></i></div>
            </div>
          </div>
          <div class="col-lg-3 col-6">
            <div class="small-box bg-warning">
              <div class="inner"><h3>${acceptedCount}</h3><p>Đã chấp nhận</p></div>
              <div class="icon"><i class="fas fa-handshake"></i></div>
            </div>
          </div>
          <div class="col-lg-3 col-6">
            <div class="small-box bg-success">
              <div class="inner"><h3>${paidCount}</h3><p>Đã thanh toán</p></div>
              <div class="icon"><i class="fas fa-check-circle"></i></div>
            </div>
          </div>
          <div class="col-lg-3 col-6">
            <div class="small-box bg-danger">
              <div class="inner"><h3>${rejectedCount}</h3><p>Từ chối</p></div>
              <div class="icon"><i class="fas fa-times-circle"></i></div>
            </div>
          </div>
        </div>

        <div class="card">
          <div class="card-header">
            <h5 class="mb-0"><i class="fas fa-list"></i> Danh sách báo giá</h5>
          </div>
          <div class="card-body">
            <!-- Filters -->
            <form class="row g-3 align-items-end mb-3" method="GET" action="<%= request.getContextPath() %>/admin/quotations">
              <div class="col-md-4">
                <input type="text" class="form-control" name="keyword" placeholder="Tìm theo mã báo giá, mã RFQ..." value="${keyword}">
              </div>
              <div class="col-md-3">
                <select class="form-control" name="status">
                  <option value="">Tất cả trạng thái</option>
                  <option value="Sent" ${status == 'Sent' ? 'selected' : ''}>Đã gửi</option>
                  <option value="Accepted" ${status == 'Accepted' ? 'selected' : ''}>Đã chấp nhận</option>
                  <option value="Paid" ${status == 'Paid' ? 'selected' : ''}>Đã thanh toán</option>
                  <option value="Rejected" ${status == 'Rejected' ? 'selected' : ''}>Từ chối</option>
                </select>
              </div>

              <div class="col-md-2">
                <button type="submit" class="btn btn-primary w-100"><i class="fas fa-search"></i> Tìm</button>
              </div>
            </form>

            <div class="table-responsive">
              <table class="table table-hover mb-0">
                <thead class="table-light">
                  <tr>
                    <th>Mã Báo Giá</th>
                    <th>RFQ</th>
                    <th>Khách hàng</th>
                    <th>Ngày gửi</th>
                    <th>Giá trị</th>
                    <th>Trạng thái</th>
                    <th>Hành động</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="q" items="${quotations}">
                    <tr>
                      <td>
                        <a href="<%= request.getContextPath() %>/admin/quotations/detail?id=${q.quotationID}">
                          <strong>${q.quotationCode}</strong>
                        </a>
                      </td>
                      <td>
                        <c:if test="${q.rfq != null}">
                          <a href="<%= request.getContextPath() %>/admin/rfq/detail?id=${q.rfqID}">${q.rfq.rfqCode}</a>
                        </c:if>
                      </td>
                      <td>
                        <c:if test="${q.rfq != null}">
                          ${q.rfq.contactPerson}<br>
                          <small class="text-muted">${q.rfq.companyName}</small>
                        </c:if>
                      </td>
                      <td><fmt:formatDate value="${q.quotationSentDate}" pattern="dd/MM/yyyy"/></td>
                      <td>
                        <strong class="text-primary">
                          <fmt:formatNumber value="${q.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                        </strong>
                      </td>
                      <td>
                        <span class="badge badge-${q.statusBadgeClass}">${q.statusDisplayName}</span>
                      </td>
                      <td class="text-nowrap">
                        <a href="<%= request.getContextPath() %>/admin/quotations?action=detail&id=${q.quotationID}" 
                           class="btn btn-sm btn-outline-info mr-1" title="Xem chi tiết">
                          <i class="fas fa-eye"></i>
                        </a>
                        <c:if test="${q.status == 'CustomerCountered'}">
                          <a href="<%= request.getContextPath() %>/admin/quotations?action=detail&id=${q.quotationID}" 
                             class="btn btn-sm btn-warning" title="Cần phản hồi">
                            <i class="fas fa-reply"></i>
                          </a>
                        </c:if>
                      </td>
                    </tr>
                  </c:forEach>
                  <c:if test="${empty quotations}">
                    <tr>
                      <td colspan="7" class="text-center py-4 text-muted">Chưa có báo giá nào</td>
                    </tr>
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
                    <c:url var="prevUrl" value="/admin/quotations">
                      <c:param name="page" value="${currentPage - 1}"/>
                      <c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if>
                      <c:if test="${not empty status}"><c:param name="status" value="${status}"/></c:if>
                    </c:url>
                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                      <a class="page-link" href="${prevUrl}">Trước</a>
                    </li>
                    <c:forEach begin="1" end="${totalPages > 0 ? totalPages : 1}" var="i">
                      <c:url var="pageUrl" value="/admin/quotations">
                        <c:param name="page" value="${i}"/>
                        <c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if>
                        <c:if test="${not empty status}"><c:param name="status" value="${status}"/></c:if>
                      </c:url>
                      <li class="page-item ${currentPage == i ? 'active' : ''}">
                        <a class="page-link" href="${pageUrl}">${i}</a>
                      </li>
                    </c:forEach>
                    <c:url var="nextUrl" value="/admin/quotations">
                      <c:param name="page" value="${currentPage + 1}"/>
                      <c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if>
                      <c:if test="${not empty status}"><c:param name="status" value="${status}"/></c:if>
                    </c:url>
                    <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                      <a class="page-link" href="${nextUrl}">Sau</a>
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
