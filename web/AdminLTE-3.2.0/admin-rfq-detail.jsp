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
  <style>
    .info-label { font-weight: 600; color: #666; }
    .history-list { padding-left: 0; margin-left: 0; list-style: none; }
    .history-item { position: relative; padding: 10px 0 15px 30px; border-bottom: 1px solid #eee; }
    .history-item:last-child { border-bottom: none; }
    .history-item::before { content: ''; width: 12px; height: 12px; background: #007bff; border-radius: 50%; position: absolute; left: 0; top: 15px; }
    .history-item.rejected::before { background: #dc3545; }
    .history-item.completed::before { background: #28a745; }
    .status-badge { font-size: 0.9rem; padding: 6px 12px; border-radius: 4px; }
    .status-pending { background: #ffc107; color: #000; }
    .status-reviewing { background: #17a2b8; color: #fff; }
    .status-dateproposed { background: #fd7e14; color: #fff; }
    .status-dateaccepted { background: #20c997; color: #fff; }
    .status-daterejected { background: #dc3545; color: #fff; }
    .status-quoted { background: #ffc107; color: #000; }
    .status-quoteaccepted { background: #6f42c1; color: #fff; }
    .status-quoterejected { background: #dc3545; color: #fff; }
    .status-completed { background: #28a745; color: #fff; }
    .status-cancelled { background: #6c757d; color: #fff; }
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
        <c:if test="${param.success == 'date_proposed'}">
          <div class="alert alert-success alert-dismissible fade show auto-dismiss" role="alert">
            <i class="fas fa-check"></i> Đã gửi đề xuất ngày giao hàng mới!
            <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
          </div>
        </c:if>
        <c:if test="${param.success == 'quotation_sent'}">
          <div class="alert alert-success alert-dismissible fade show auto-dismiss" role="alert">
            <i class="fas fa-check"></i> Đã gửi báo giá thành công!
            <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
          </div>
        </c:if>

        <div class="row">
          <div class="col-lg-8">
            <!-- Customer Info -->
            <div class="card mb-4">
              <div class="card-header"><h5 class="mb-0"><i class="fas fa-user"></i> Thông Tin Khách Hàng</h5></div>
              <div class="card-body">
                <div class="row">
                  <div class="col-md-6">
                    <p><span class="info-label">Công ty:</span> ${rfq.companyName}</p>
                    <p><span class="info-label">Mã số thuế:</span> ${rfq.taxID != null ? rfq.taxID : 'N/A'}</p>
                    <p><span class="info-label">Loại hình:</span> 
                      <c:choose>
                        <c:when test="${rfq.businessType == 'Retailer'}">Bán lẻ</c:when>
                        <c:when test="${rfq.businessType == 'Distributor'}">Nhà phân phối</c:when>
                        <c:when test="${rfq.businessType == 'Other'}">Khác</c:when>
                        <c:otherwise>${rfq.businessType != null ? rfq.businessType : 'N/A'}</c:otherwise>
                      </c:choose>
                    </p>
                  </div>
                  <div class="col-md-6">
                    <p><span class="info-label">Người liên hệ:</span> ${rfq.contactPerson}</p>
                    <p><span class="info-label">Điện thoại:</span> ${rfq.contactPhone}</p>
                    <p><span class="info-label">Email:</span> ${rfq.contactEmail}</p>
                  </div>
                </div>
              </div>
            </div>

            <!-- Delivery Info -->
            <div class="card mb-4">
              <div class="card-header"><h5 class="mb-0"><i class="fas fa-truck"></i> Thông Tin Giao Hàng & Thanh Toán</h5></div>
              <div class="card-body">
                <div class="row">
                  <div class="col-md-6">
                    <p><span class="info-label">Địa chỉ:</span> ${rfq.deliveryAddress}</p>
                    <p><span class="info-label">Ngày yêu cầu:</span> <fmt:formatDate value="${rfq.requestedDeliveryDate}" pattern="dd/MM/yyyy"/></p>
                    <c:if test="${rfq.proposedDeliveryDate != null}">
                      <p><span class="info-label">Ngày đề xuất:</span> <fmt:formatDate value="${rfq.proposedDeliveryDate}" pattern="dd/MM/yyyy"/></p>
                    </c:if>
                  </div>
                  <div class="col-md-6">
                    <p><span class="info-label">Hình thức thanh toán:</span> 
                      <span class="badge bg-info">Chuyển khoản ngân hàng (VNPay)</span>
                    </p>
                    <c:if test="${not empty rfq.deliveryInstructions}">
                      <p><span class="info-label">Yêu cầu đặc biệt:</span> ${rfq.deliveryInstructions}</p>
                    </c:if>
                  </div>
                </div>
              </div>
            </div>

            <!-- Shipping Carrier Info -->
            <c:if test="${not empty rfq.shippingCarrierName}">
            <div class="card mb-4">
              <div class="card-header bg-light"><h5 class="mb-0"><i class="fas fa-shipping-fast"></i> Đơn Vị Vận Chuyển</h5></div>
              <div class="card-body">
                <div class="row">
                  <div class="col-md-6">
                    <p><span class="info-label">Đơn vị vận chuyển:</span> <strong>${rfq.shippingCarrierName}</strong></p>
                    <p><span class="info-label">Dịch vụ:</span> ${rfq.shippingServiceName}</p>
                  </div>
                  <div class="col-md-6">
                    <p><span class="info-label">Phí vận chuyển (dự kiến):</span> 
                      <span class="text-primary font-weight-bold"><fmt:formatNumber value="${rfq.shippingFee}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span>
                    </p>
                    <p><span class="info-label">Thời gian giao hàng:</span> 
                      <span class="badge bg-success">${rfq.estimatedDeliveryDays} ngày</span>
                    </p>
                  </div>
                </div>
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
                      <th class="text-center">Số lượng</th>
                      <th class="text-right">Giá vốn</th>
                      <c:if test="${rfq.status == 'Quoted' || rfq.status == 'QuoteAccepted' || rfq.status == 'Completed'}">
                        <th class="text-center">Margin %</th>
                        <th class="text-right">Đơn giá</th>
                        <th class="text-right">Thành tiền</th>
                      </c:if>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach var="item" items="${rfq.items}">
                      <tr>
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
                        <td class="text-center">${item.quantity}</td>
                        <td class="text-right"><c:if test="${item.costPrice != null}"><fmt:formatNumber value="${item.costPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></c:if></td>
                        <c:if test="${rfq.status == 'Quoted' || rfq.status == 'QuoteAccepted' || rfq.status == 'Completed'}">
                          <td class="text-center">${item.profitMarginPercent}%</td>
                          <td class="text-right"><fmt:formatNumber value="${item.unitPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                          <td class="text-right"><fmt:formatNumber value="${item.subtotal}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                        </c:if>
                      </tr>
                    </c:forEach>
                  </tbody>
                  <c:if test="${rfq.totalAmount != null && rfq.totalAmount > 0}">
                    <c:set var="colSpan" value="${(rfq.status == 'Quoted' || rfq.status == 'QuoteAccepted' || rfq.status == 'Completed') ? 4 : 1}" />
                    <tfoot class="table-light">
                      <tr><td colspan="${colSpan}"></td><td class="text-right"><strong>Tạm tính:</strong></td><td class="text-right"><fmt:formatNumber value="${rfq.subtotalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td></tr>
                      <tr><td colspan="${colSpan}"></td><td class="text-right">Phí vận chuyển:</td><td class="text-right"><fmt:formatNumber value="${rfq.shippingFee}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td></tr>
                      <tr><td colspan="${colSpan}"></td><td class="text-right">Thuế:</td><td class="text-right"><fmt:formatNumber value="${rfq.taxAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td></tr>
                      <tr class="table-primary"><td colspan="${colSpan}"></td><td class="text-right"><strong>TỔNG CỘNG:</strong></td><td class="text-right"><strong><fmt:formatNumber value="${rfq.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></strong></td></tr>
                    </tfoot>
                  </c:if>
                </table>
              </div>
            </div>

            <!-- Actions -->
            <div class="card mb-4">
              <div class="card-header"><h5 class="mb-0"><i class="fas fa-cogs"></i> Hành Động</h5></div>
              <div class="card-body">
                <c:if test="${rfq.status == 'Pending' || rfq.status == 'DateAccepted'}">
                  <button type="button" class="btn btn-warning" data-toggle="modal" data-target="#proposeDateModal"><i class="fas fa-calendar-alt"></i> Đề Xuất Ngày Mới</button>
                  <a href="<%= request.getContextPath() %>/admin/rfq/quotation-form?rfqId=${rfq.rfqID}" class="btn btn-success"><i class="fas fa-file-invoice-dollar"></i> Tạo Báo Giá</a>
                </c:if>
                <c:if test="${rfq.status == 'DateProposed'}"><div class="alert alert-info mt-3"><i class="fas fa-hourglass-half"></i> Đang chờ khách hàng phản hồi về ngày giao hàng mới.</div></c:if>
                <c:if test="${rfq.status == 'Quoted'}"><div class="alert alert-warning mt-3"><i class="fas fa-hourglass-half"></i> Chờ khách hàng chấp nhận báo giá.</div></c:if>
                <c:if test="${rfq.status == 'Completed'}"><div class="alert alert-success mt-3"><i class="fas fa-check-circle"></i> Đơn hàng đã hoàn thành.</div></c:if>
                <c:choose>
                  <c:when test="${fromQuotation}">
                    <a href="<%= request.getContextPath() %>/admin/quotations" class="btn btn-secondary"><i class="fas fa-arrow-left"></i> Quay Lại</a>
                  </c:when>
                  <c:otherwise>
                    <a href="<%= request.getContextPath() %>/admin/rfq" class="btn btn-secondary"><i class="fas fa-arrow-left"></i> Quay Lại</a>
                  </c:otherwise>
                </c:choose>
              </div>
            </div>
          </div>

          <!-- Sidebar -->
          <div class="col-lg-4">
            <div class="mb-3">
              <span class="badge status-badge status-${rfq.status.toLowerCase()}" style="font-size: 1rem; padding: 10px 20px;">
                <c:choose>
                  <c:when test="${rfq.status == 'Quoted'}">Chờ chấp nhận</c:when>
                  <c:when test="${rfq.status == 'Completed'}">Đã thanh toán</c:when>
                  <c:when test="${rfq.status == 'QuoteRejected'}">Từ chối báo giá</c:when>
                  <c:otherwise>${rfq.statusDisplayName}</c:otherwise>
                </c:choose>
              </span>
            </div>
            <c:if test="${not empty rfq.customerNotes}">
              <div class="card mb-4">
                <div class="card-header"><h6 class="mb-0"><i class="fas fa-comment"></i> Ghi Chú Khách Hàng</h6></div>
                <div class="card-body">${rfq.customerNotes}</div>
              </div>
            </c:if>
            <div class="card">
              <div class="card-header"><h6 class="mb-0"><i class="fas fa-history"></i> Lịch Sử</h6></div>
              <div class="card-body">
                <div class="history-list">
                  <c:forEach var="h" items="${rfq.history}">
                    <div class="history-item ${h.newStatus == 'QuoteRejected' || h.newStatus == 'DateRejected' || h.newStatus == 'Cancelled' ? 'rejected' : ''} ${h.newStatus == 'Completed' ? 'completed' : ''}">
                      <strong>${h.action}</strong>
                      <p class="mb-1 small text-muted">${h.notes}</p>
                      <small class="text-muted"><fmt:formatDate value="${h.changedDate}" pattern="dd/MM/yyyy HH:mm"/></small>
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
        <form action="<%= request.getContextPath() %>/admin/rfq/propose-date" method="POST" id="proposeDateForm">
          <input type="hidden" name="rfqId" value="${rfq.rfqID}">
          <div class="modal-header">
            <h5 class="modal-title">Đề Xuất Ngày Giao Hàng Mới</h5>
            <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
          </div>
          <div class="modal-body">
            <div class="mb-3">
              <label class="form-label">Ngày khách yêu cầu</label>
              <input type="text" class="form-control" id="customerRequestedDate" value="<fmt:formatDate value="${rfq.requestedDeliveryDate}" pattern="dd/MM/yyyy"/>" disabled>
            </div>
            <div class="mb-3">
              <label class="form-label">Ngày đề xuất mới <span class="text-danger">*</span></label>
              <input type="text" class="form-control" name="proposedDate" id="proposedDateInput" placeholder="dd/mm/yyyy" required autocomplete="off">
              <small class="text-muted">Ngày đề xuất phải sau ngày khách yêu cầu</small>
            </div>
            <div class="mb-3">
              <label class="form-label">Lý do <span class="text-danger">*</span></label>
              <textarea class="form-control" name="reason" rows="3" required placeholder="VD: Số lượng lớn, cần thời gian chuẩn bị..."></textarea>
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

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/css/bootstrap-datepicker.min.css">
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/jquery/jquery.min.js"></script>
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/js/adminlte.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/js/bootstrap-datepicker.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/locales/bootstrap-datepicker.vi.min.js"></script>
<script>
$(document).ready(function() {
    // Auto-dismiss alerts after 5 seconds
    setTimeout(function() {
        $('.auto-dismiss').fadeOut('slow', function() {
            $(this).remove();
        });
    }, 5000);
    
    // Parse customer requested date (dd/MM/yyyy format)
    var customerDateStr = $('#customerRequestedDate').val();
    var parts = customerDateStr.split('/');
    var customerDate = new Date(parts[2], parts[1] - 1, parts[0]);
    
    // Min date is the day after customer requested date
    var minDate = new Date(customerDate);
    minDate.setDate(minDate.getDate() + 1);
    
    // Initialize datepicker
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
