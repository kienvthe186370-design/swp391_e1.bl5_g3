<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Đơn Báo Giá - Admin</title>

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
            <h1><i class="fas fa-file-invoice-dollar"></i> Đơn Báo Giá</h1>
          </div>
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/admin/dashboard">Dashboard</a></li>
              <li class="breadcrumb-item active">Đơn Báo Giá</li>
            </ol>
          </div>
        </div>
      </div>
    </section>

    <section class="content">
      <div class="container-fluid">

        <!-- Stats -->
        <div class="row mb-3">
          <div class="col-lg-4 col-12">
            <div class="small-box bg-warning">
              <div class="inner">
                <h3>${pendingCount}</h3>
                <p>Chờ chấp nhận</p>
              </div>
              <div class="icon">
                <i class="fas fa-hourglass-half"></i>
              </div>
            </div>
          </div>
          <div class="col-lg-4 col-12">
            <div class="small-box bg-success">
              <div class="inner">
                <h3>${paidCount}</h3>
                <p>Đã thanh toán</p>
              </div>
              <div class="icon">
                <i class="fas fa-check-circle"></i>
              </div>
            </div>
          </div>
          <div class="col-lg-4 col-12">
            <div class="small-box bg-danger">
              <div class="inner">
                <h3>${rejectedCount}</h3>
                <p>Từ chối báo giá</p>
              </div>
              <div class="icon">
                <i class="fas fa-times-circle"></i>
              </div>
            </div>
          </div>
        </div>

        <div class="card">
          <div class="card-header">
            <h5 class="mb-0"><i class="fas fa-list"></i> Danh sách đơn báo giá</h5>
          </div>
          <div class="card-body">
            <!-- Filters -->
            <form class="row g-3 align-items-end mb-3" method="GET" action="<%= request.getContextPath() %>/admin/quotations">
              <div class="col-md-5">
                <input type="text" class="form-control" name="keyword" placeholder="Tìm theo mã RFQ, công ty, khách hàng..." value="${keyword}">
              </div>
              <div class="col-md-4">
                <select class="form-control" name="status">
                  <option value="">Tất cả trạng thái</option>
                  <option value="Quoted" ${status == 'Quoted' ? 'selected' : ''}>Chờ chấp nhận</option>
                  <option value="QuoteAccepted" ${status == 'QuoteAccepted' ? 'selected' : ''}>Đã thanh toán</option>
                  <option value="QuoteRejected" ${status == 'QuoteRejected' ? 'selected' : ''}>Từ chối báo giá</option>
                </select>
              </div>
              <div class="col-md-3">
                <button type="submit" class="btn btn-primary w-100"><i class="fas fa-search"></i> Tìm kiếm</button>
              </div>
            </form>

            <div class="table-responsive">
              <table class="table table-hover mb-0">
                <thead class="table-light">
                  <tr>
                    <th>Mã RFQ</th>
                    <th>Khách hàng</th>
                    <th>Công ty</th>
                    <th>Ngày gửi báo giá</th>
                    <th>Giá trị báo giá</th>
                    <th>Trạng thái</th>
                    <th>Hành động</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="rfq" items="${quotations}">
                    <tr>
                      <td>
                        <a href="<%= request.getContextPath() %>/admin/quotations/detail?id=${rfq.rfqID}">
                          <strong>${rfq.rfqCode}</strong>
                        </a>
                      </td>
                      <td>
                        ${rfq.contactPerson}<br>
                        <small class="text-muted">${rfq.contactPhone}</small>
                      </td>
                      <td>${rfq.companyName}</td>
                      <td><fmt:formatDate value="${rfq.quotationSentDate}" pattern="dd/MM/yyyy"/></td>
                      <td>
                        <c:choose>
                          <c:when test="${rfq.totalAmount != null && rfq.totalAmount > 0}">
                            <strong class="text-primary">
                              <fmt:formatNumber value="${rfq.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                            </strong>
                          </c:when>
                          <c:otherwise><span class="text-muted">Chưa có</span></c:otherwise>
                        </c:choose>
                      </td>
                      <td>
                        <c:choose>
                          <c:when test="${rfq.status == 'Quoted'}">
                            <span class="badge badge-warning text-dark">Chờ chấp nhận</span>
                          </c:when>
                          <c:when test="${rfq.status == 'QuoteAccepted'}">
                            <span class="badge badge-success">Đã thanh toán</span>
                          </c:when>
                          <c:when test="${rfq.status == 'QuoteRejected'}">
                            <span class="badge badge-danger">Từ chối báo giá</span>
                          </c:when>
                          <c:otherwise>
                            <span class="badge badge-secondary">${rfq.statusDisplayName}</span>
                          </c:otherwise>
                        </c:choose>
                      </td>
                      <td>
                        <a href="<%= request.getContextPath() %>/admin/quotations/detail?id=${rfq.rfqID}" class="btn btn-sm btn-outline-info">
                          <i class="fas fa-eye"></i> Xem báo giá
                        </a>
                      </td>
                    </tr>
                  </c:forEach>
                  <c:if test="${empty quotations}">
                    <tr>
                      <td colspan="7" class="text-center py-4 text-muted">Chưa có đơn báo giá nào</td>
                    </tr>
                  </c:if>
                </tbody>
              </table>
            </div>
          </div>

          <c:if test="${totalCount > 0}">
            <div class="card-footer">
              <div class="d-flex flex-column flex-sm-row align-items-center justify-content-between w-100 flex-wrap">
                <div class="text-muted small mb-2 mb-sm-0" style="font-size:1.15em;">
                Hiển thị trang ${currentPage} / ${totalPages} (Tổng: ${totalCount} bản ghi)
                </div>
                <ul class="pagination pagination-sm mb-0 ms-sm-auto">
                <c:url var="prevUrl" value="/admin/quotations">
                  <c:param name="page" value="${currentPage - 1}"/>
                  <c:if test="${not empty keyword}">
                    <c:param name="keyword" value="${keyword}"/>
                  </c:if>
                  <c:if test="${not empty status}">
                    <c:param name="status" value="${status}"/>
                  </c:if>
                </c:url>
                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                  <a class="page-link" href="${prevUrl}">«</a>
                </li>
                <c:forEach begin="1" end="${totalPages}" var="i">
                  <c:url var="pageUrl" value="/admin/quotations">
                    <c:param name="page" value="${i}"/>
                    <c:if test="${not empty keyword}">
                      <c:param name="keyword" value="${keyword}"/>
                    </c:if>
                    <c:if test="${not empty status}">
                      <c:param name="status" value="${status}"/>
                    </c:if>
                  </c:url>
                  <li class="page-item ${currentPage == i ? 'active' : ''}">
                    <a class="page-link" href="${pageUrl}">${i}</a>
                  </li>
                </c:forEach>
                <c:url var="nextUrl" value="/admin/quotations">
                  <c:param name="page" value="${currentPage + 1}"/>
                  <c:if test="${not empty keyword}">
                    <c:param name="keyword" value="${keyword}"/>
                  </c:if>
                  <c:if test="${not empty status}">
                    <c:param name="status" value="${status}"/>
                  </c:if>
                </c:url>
                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                  <a class="page-link" href="${nextUrl}">»</a>
                </li>
              </ul>
            </div>
          </c:if>
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
