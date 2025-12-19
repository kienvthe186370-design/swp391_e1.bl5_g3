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
  <title>Chi Tiết RFQ ${rfq.rfqCode} - Admin</title>
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/fontawesome-free/css/all.min.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/css/adminlte.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/css/bootstrap-datepicker.min.css">
  <style>
    .info-label { font-weight: 600; color: #666; }
    .history-list { padding-left: 0; list-style: none; }
    .history-item { position: relative; padding: 10px 0 15px 30px; border-bottom: 1px solid #eee; }
    .history-item:last-child { border-bottom: none; }
    .history-item::before { content: ''; width: 12px; height: 12px; background: #007bff; border-radius: 50%; position: absolute; left: 0; top: 15px; }
    .history-item.rejected::before { background: #dc3545; }
    .history-item.completed::before { background: #28a745; }
    .status-badge { font-size: 0.9rem; padding: 6px 12px; border-radius: 4px; }
    .status-pending { background: #ffc107; color: #000; }
    .status-reviewing { background: #17a2b8; color: #fff; }
    .status-dateproposed { background: #fd7e14; color: #fff; }
    .status-datecountered { background: #e83e8c; color: #fff; }
    .status-dateaccepted { background: #20c997; color: #fff; }
    .status-quotationcreated { background: #007bff; color: #fff; }
    .status-completed { background: #28a745; color: #fff; }
    .status-cancelled { background: #6c757d; color: #fff; }
    .negotiation-box { background: #f8f9fa; border-radius: 8px; padding: 15px; }
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
            <h1><i class="fas fa-file-invoice"></i> Chi Tiết RFQ: ${rfq.rfqCode}</h1>
          </div>
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/admin/dashboard">Dashboard</a></li>
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/admin/rfq">RFQ</a></li>
              <li class="breadcrumb-item active">${rfq.rfqCode}</li>
            </ol>
          </div>
        </div>
      </div>
    </section>

    <section class="content">
      <div class="container-fluid">
        <!-- Success Messages -->
        <c:if test="${param.success == 'date_proposed'}">
          <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check"></i> Đã gửi đề xuất ngày giao hàng mới cho khách hàng!
            <button type="button" class="close" data-dismiss="alert">&times;</button>
          </div>
        </c:if>
        <c:if test="${param.success == 'date_accepted'}">
          <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check"></i> Đã chấp nhận ngày giao do khách hàng đề xuất! Bạn có thể tạo báo giá ngay.
            <button type="button" class="close" data-dismiss="alert">&times;</button>
          </div>
        </c:if>
        <c:if test="${param.success == 'notes_updated'}">
          <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check"></i> Đã cập nhật ghi chú!
            <button type="button" class="close" data-dismiss="alert">&times;</button>
          </div>
        </c:if>

        <div class="row">
          <div class="col-lg-8">
            <!-- Status & Info -->
            <div class="card mb-4">
              <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0"><i class="fas fa-info-circle"></i> Thông Tin RFQ</h5>
                <span class="badge status-badge status-${rfq.status.toLowerCase()}">${rfq.statusDisplayName}</span>
              </div>
              <div class="card-body">
                <div class="row">
                  <div class="col-md-6">
                    <c:if test="${not empty rfq.companyName}">
                      <p><span class="info-label">Công ty:</span> ${rfq.companyName}</p>
                    </c:if>
                    <c:if test="${not empty rfq.taxID}">
                      <p><span class="info-label">Mã số thuế:</span> ${rfq.taxID}</p>
                    </c:if>
                    <p><span class="info-label">Người liên hệ:</span> ${rfq.contactPerson}</p>
                    <p><span class="info-label">Điện thoại:</span> ${rfq.contactPhone}</p>
                    <p><span class="info-label">Email:</span> ${rfq.contactEmail}</p>
                  </div>
                  <div class="col-md-6">
                    <p><span class="info-label">Ngày tạo:</span> <fmt:formatDate value="${rfq.createdDate}" pattern="dd/MM/yyyy HH:mm"/></p>
                    <p><span class="info-label">Ngày yêu cầu giao:</span> <fmt:formatDate value="${rfq.requestedDeliveryDate}" pattern="dd/MM/yyyy"/></p>
                    <c:if test="${rfq.status == 'DateAccepted' || rfq.status == 'QuotationCreated' || rfq.status == 'Completed'}">
                      <p>
                        <span class="info-label text-success"><i class="fas fa-check-circle"></i> Ngày giao (đã thống nhất):</span> 
                        <strong class="text-success"><fmt:formatDate value="${rfq.finalDeliveryDate}" pattern="dd/MM/yyyy"/></strong>
                      </p>
                    </c:if>
                    <p><span class="info-label">Địa chỉ giao:</span> ${rfq.deliveryAddress}</p>
                  </div>
                </div>
              </div>
            </div>

            <!-- Date Negotiation Section -->
            <div class="card mb-4 border-${rfq.status == 'DateProposed' ? 'warning' : (rfq.status == 'DateCountered' ? 'info' : (rfq.status == 'DateAccepted' ? 'success' : 'secondary'))}">
              <div class="card-header bg-light">
                <h5 class="mb-0">
                  <i class="fas fa-calendar-alt"></i> Thương Lượng Ngày Giao
                  <span class="badge badge-secondary float-right">${rfq.dateNegotiationCount}/${rfq.maxDateNegotiationCount} lần</span>
                </h5>
              </div>
              <div class="card-body">
                <div class="negotiation-box mb-3">
                  <div class="row">
                    <div class="col-md-4">
                      <p class="mb-1 text-muted small">Ngày KH yêu cầu:</p>
                      <p class="font-weight-bold"><fmt:formatDate value="${rfq.requestedDeliveryDate}" pattern="dd/MM/yyyy"/></p>
                    </div>
                    <c:if test="${rfq.proposedDeliveryDate != null}">
                      <div class="col-md-4">
                        <p class="mb-1 text-muted small">Ngày bạn đề xuất:</p>
                        <p class="font-weight-bold text-warning"><fmt:formatDate value="${rfq.proposedDeliveryDate}" pattern="dd/MM/yyyy"/></p>
                        <c:if test="${not empty rfq.dateChangeReason}">
                          <small class="text-muted">Lý do: ${rfq.dateChangeReason}</small>
                        </c:if>
                      </div>
                    </c:if>
                    <c:if test="${rfq.customerCounterDate != null}">
                      <div class="col-md-4">
                        <p class="mb-1 text-muted small">Ngày KH đề xuất:</p>
                        <p class="font-weight-bold text-info"><fmt:formatDate value="${rfq.customerCounterDate}" pattern="dd/MM/yyyy"/></p>
                        <c:if test="${not empty rfq.customerCounterDateNote}">
                          <small class="text-muted">Ghi chú: ${rfq.customerCounterDateNote}</small>
                        </c:if>
                      </div>
                    </c:if>
                  </div>
                </div>

                <!-- Status-specific messages -->
                <c:if test="${rfq.status == 'Reviewing'}">
                  <div class="alert alert-info mb-0">
                    <i class="fas fa-info-circle"></i> Bạn có thể đề xuất ngày giao mới hoặc tạo báo giá ngay.
                  </div>
                </c:if>
                <c:if test="${rfq.status == 'DateProposed'}">
                  <div class="alert alert-warning mb-0">
                    <i class="fas fa-hourglass-half"></i> Đang chờ khách hàng phản hồi về ngày giao.
                  </div>
                </c:if>
                <c:if test="${rfq.status == 'DateCountered'}">
                  <div class="alert alert-info mb-0">
                    <i class="fas fa-reply"></i> Khách hàng đề xuất ngày khác. Bạn có thể chấp nhận hoặc đề xuất lại.
                  </div>
                </c:if>
                <c:if test="${rfq.status == 'DateAccepted'}">
                  <div class="alert alert-success mb-0">
                    <i class="fas fa-check-circle"></i> Ngày giao đã được thống nhất: <strong><fmt:formatDate value="${rfq.finalDeliveryDate}" pattern="dd/MM/yyyy"/></strong>. Bạn có thể tạo báo giá.
                  </div>
                </c:if>
              </div>
            </div>

            <!-- Quotation Info (if exists) -->
            <c:if test="${rfq.status == 'QuotationCreated' && not empty rfq.quotation}">
              <div class="card mb-4 border-primary">
                <div class="card-header bg-primary text-white">
                  <h5 class="mb-0"><i class="fas fa-file-invoice-dollar"></i> Báo Giá Đã Tạo</h5>
                </div>
                <div class="card-body">
                  <p><strong>Mã báo giá:</strong> ${rfq.quotation.quotationCode}</p>
                  <p><strong>Tổng tiền:</strong> <span class="text-primary h5"><fmt:formatNumber value="${rfq.quotation.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span></p>
                  <p><strong>Trạng thái:</strong> <span class="badge badge-info">${rfq.quotation.statusDisplayName}</span></p>
                  <a href="<%= request.getContextPath() %>/admin/quotations/detail?id=${rfq.quotation.quotationID}" class="btn btn-primary">
                    <i class="fas fa-eye"></i> Xem Chi Tiết Báo Giá
                  </a>
                </div>
              </div>
            </c:if>

            <!-- Products -->
            <div class="card mb-4">
              <div class="card-header"><h5 class="mb-0"><i class="fas fa-cube"></i> Sản Phẩm Yêu Cầu</h5></div>
              <div class="card-body p-0">
                <table class="table mb-0">
                  <thead class="table-light">
                    <tr>
                      <th>Sản phẩm</th>
                      <th class="text-center">Số lượng sản phẩm</th>
                      <th class="text-center">Số lượng</th>
                      <th class="text-center">Trạng thái</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach var="item" items="${rfq.items}">
                      <c:set var="stock" value="${itemStocks[item.rfqItemID]}"/>
                      <c:if test="${stock == null}"><c:set var="stock" value="0"/></c:if>
                      <c:set var="isShortage" value="${item.quantity > stock}"/>
                      <tr class="${isShortage ? 'table-warning' : ''}">
                        <td>
                          <div class="d-flex align-items-center">
                            <c:if test="${not empty item.productImage}">
                              <img src="${pageContext.request.contextPath}/${item.productImage}" alt="${item.productName}" 
                                   style="width: 50px; height: 50px; object-fit: cover; margin-right: 10px; border-radius: 4px;">
                            </c:if>
                            <div>
                              <strong>${item.productName}</strong>
                              <c:if test="${not empty item.sku}"><br><small class="text-muted">SKU: ${item.sku}</small></c:if>
                            </div>
                          </div>
                        </td>
                        <td class="text-center">
                          <span class="badge ${stock > 0 ? 'badge-secondary' : 'badge-danger'}">${stock}</span>
                        </td>
                        <td class="text-center">${item.quantity}</td>
                        <td class="text-center">
                          <c:choose>
                            <c:when test="${isShortage}">
                              <span class="badge badge-danger"><i class="fas fa-exclamation-triangle"></i> Thiếu ${item.quantity - stock}</span>
                            </c:when>
                            <c:otherwise>
                              <span class="badge badge-success"><i class="fas fa-check"></i> Đủ hàng</span>
                            </c:otherwise>
                          </c:choose>
                        </td>
                      </tr>
                    </c:forEach>
                  </tbody>
                </table>
              </div>
            </div>

            <!-- Stock Warning -->
            <c:if test="${hasShortage && rfq.canCreateQuotation()}">
              <div class="alert alert-warning mb-4">
                <h5><i class="fas fa-exclamation-triangle"></i> Thiếu hàng!</h5>
                <p class="mb-2">Một số sản phẩm trong RFQ này không đủ số lượng. Bạn cần yêu cầu nhập hàng và chờ Admin duyệt trước khi có thể tạo báo giá.</p>
                <c:choose>
                  <c:when test="${hasStockRequest}">
                    <a href="<%= request.getContextPath() %>/admin/stock-requests?action=detail&id=${stockRequestId}" class="btn btn-info btn-sm">
                      <i class="fas fa-eye"></i> Xem yêu cầu nhập hàng
                    </a>
                  </c:when>
                  <c:otherwise>
                    <a href="<%= request.getContextPath() %>/admin/stock-requests?action=create&rfqId=${rfq.rfqID}" class="btn btn-warning btn-sm">
                      <i class="fas fa-boxes"></i> Tạo yêu cầu nhập hàng
                    </a>
                  </c:otherwise>
                </c:choose>
              </div>
            </c:if>

            <!-- Actions -->
            <div class="card mb-4">
              <div class="card-header"><h5 class="mb-0"><i class="fas fa-cogs"></i> Hành Động</h5></div>
              <div class="card-body">
                <c:if test="${rfq.status == 'DateCountered'}">
                  <form action="<%= request.getContextPath() %>/admin/rfq/accept-customer-date" method="POST" style="display: inline;">
                    <input type="hidden" name="rfqId" value="${rfq.rfqID}">
                    <button type="submit" class="btn btn-success mr-2" onclick="return confirm('Chấp nhận ngày do khách hàng đề xuất?')">
                      <i class="fas fa-check"></i> Chấp Nhận Ngày KH Đề Xuất
                    </button>
                  </form>
                </c:if>
                <c:if test="${rfq.canSellerProposeDate()}">
                  <button type="button" class="btn btn-warning mr-2" data-toggle="modal" data-target="#proposeDateModal">
                    <i class="fas fa-calendar-alt"></i> Đề Xuất Ngày Mới
                  </button>
                </c:if>
                <c:if test="${rfq.canCreateQuotation()}">
                  <c:choose>
                    <c:when test="${hasShortage}">
                      <span class="d-inline-block" tabindex="0" data-toggle="tooltip" title="Cần nhập đủ hàng trước khi tạo báo giá">
                        <button type="button" class="btn btn-secondary mr-2" disabled style="pointer-events: none;">
                          <i class="fas fa-file-invoice-dollar"></i> Tạo Báo Giá
                        </button>
                      </span>
                    </c:when>
                    <c:otherwise>
                      <a href="<%= request.getContextPath() %>/admin/quotations/form?rfqId=${rfq.rfqID}" class="btn btn-success mr-2">
                        <i class="fas fa-file-invoice-dollar"></i> Tạo Báo Giá
                      </a>
                    </c:otherwise>
                  </c:choose>
                </c:if>
                <!-- Nút yêu cầu nhập hàng - hiển thị khi có sản phẩm thiếu hàng và chưa có yêu cầu -->
                <c:if test="${hasShortage && !hasStockRequest && (rfq.status == 'Reviewing' || rfq.status == 'DateAccepted')}">
                  <a href="<%= request.getContextPath() %>/admin/stock-requests?action=create&rfqId=${rfq.rfqID}" class="btn btn-warning mr-2">
                    <i class="fas fa-boxes"></i> Yêu cầu nhập hàng
                  </a>
                </c:if>
                <c:if test="${hasStockRequest}">
                  <a href="<%= request.getContextPath() %>/admin/stock-requests?action=detail&id=${stockRequestId}" class="btn btn-info mr-2">
                    <i class="fas fa-boxes"></i> Xem yêu cầu nhập hàng
                  </a>
                </c:if>
                <c:if test="${rfq.status == 'QuotationCreated' && not empty rfq.quotation}">
                  <a href="<%= request.getContextPath() %>/admin/quotations/detail?id=${rfq.quotation.quotationID}" class="btn btn-primary mr-2">
                    <i class="fas fa-eye"></i> Xem Báo Giá
                  </a>
                </c:if>
                <a href="<%= request.getContextPath() %>/admin/rfq" class="btn btn-secondary">
                  <i class="fas fa-arrow-left"></i> Quay Lại
                </a>
              </div>
            </div>
          </div>

          <!-- Sidebar -->
          <div class="col-lg-4">
            <!-- Customer Notes -->
            <c:if test="${not empty rfq.customerNotes}">
              <div class="card mb-4">
                <div class="card-header"><h6 class="mb-0"><i class="fas fa-comment"></i> Ghi Chú Khách Hàng</h6></div>
                <div class="card-body">${rfq.customerNotes}</div>
              </div>
            </c:if>

            <!-- History -->
            <div class="card">
              <div class="card-header"><h6 class="mb-0"><i class="fas fa-history"></i> Lịch Sử</h6></div>
              <div class="card-body" style="max-height: 400px; overflow-y: auto;">
                <div class="history-list">
                  <c:forEach var="h" items="${rfq.history}">
                    <div class="history-item ${h.newStatus == 'Cancelled' ? 'rejected' : ''} ${h.newStatus == 'Completed' ? 'completed' : ''}">
                      <strong>${h.action}</strong>
                      <p class="mb-1 small text-muted">${h.notes}</p>
                      <small class="text-muted">
                        <fmt:formatDate value="${h.changedDate}" pattern="dd/MM/yyyy HH:mm"/>
                        <c:if test="${not empty h.changedByName}"> - ${h.changedByName}</c:if>
                      </small>
                    </div>
                  </c:forEach>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>

  <!-- Propose Date Modal -->
  <div class="modal fade" id="proposeDateModal" tabindex="-1">
    <div class="modal-dialog">
      <div class="modal-content">
        <form action="<%= request.getContextPath() %>/admin/rfq/propose-date" method="POST">
          <input type="hidden" name="rfqId" value="${rfq.rfqID}">
          <div class="modal-header">
            <h5 class="modal-title">Đề Xuất Ngày Giao Hàng</h5>
            <button type="button" class="close" data-dismiss="modal">&times;</button>
          </div>
          <div class="modal-body">
            <div class="mb-3">
              <label class="form-label">Ngày khách yêu cầu</label>
              <input type="text" class="form-control" value="<fmt:formatDate value="${rfq.requestedDeliveryDate}" pattern="dd/MM/yyyy"/>" disabled>
              <input type="hidden" id="requestedDeliveryDateHidden" value="<fmt:formatDate value="${rfq.requestedDeliveryDate}" pattern="yyyy-MM-dd"/>">
            </div>
            <c:if test="${rfq.customerCounterDate != null}">
              <div class="mb-3">
                <label class="form-label">Ngày KH đề xuất</label>
                <input type="text" class="form-control bg-info text-white" value="<fmt:formatDate value="${rfq.customerCounterDate}" pattern="dd/MM/yyyy"/>" disabled>
              </div>
            </c:if>
            <div class="mb-3">
              <label class="form-label">Ngày bạn đề xuất <span class="text-danger">*</span></label>
              <input type="text" class="form-control" name="proposedDate" id="proposedDateInput" placeholder="dd/mm/yyyy" required autocomplete="off">
              <small class="text-muted">Ngày đề xuất phải sau ngày khách yêu cầu</small>
            </div>
            <div class="mb-3">
              <label class="form-label">Lý do</label>
              <textarea class="form-control" name="reason" rows="3" maxlength="500" placeholder="VD: Số lượng lớn, cần thời gian chuẩn bị... (tùy chọn)"></textarea>
            </div>
            <div class="alert alert-info">
              <small><i class="fas fa-info-circle"></i> Còn ${rfq.remainingDateNegotiations} lần thương lượng</small>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
            <button type="submit" class="btn btn-warning">Gửi Đề Xuất</button>
          </div>
        </form>
      </div>
    </div>
  </div>

  <jsp:include page="includes/admin-footer.jsp" />
</div>

<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/jquery/jquery.min.js"></script>
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/js/adminlte.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/js/bootstrap-datepicker.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/locales/bootstrap-datepicker.vi.min.js"></script>
<script>
$(document).ready(function() {
    // Lấy ngày khách yêu cầu và tính ngày tối thiểu (ngày sau đó)
    var requestedDateStr = $('#requestedDeliveryDateHidden').val();
    var minDate = new Date();
    
    if (requestedDateStr) {
        var requestedDate = new Date(requestedDateStr);
        // Ngày đề xuất phải > ngày khách yêu cầu (cộng thêm 1 ngày)
        requestedDate.setDate(requestedDate.getDate() + 1);
        minDate = requestedDate;
    }
    
    $('#proposedDateInput').datepicker({
        format: 'dd/mm/yyyy',
        language: 'vi',
        startDate: minDate,
        autoclose: true,
        todayHighlight: true
    });
});
</script>
</body>
</html>
