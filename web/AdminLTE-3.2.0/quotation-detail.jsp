<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Chi Tiết Báo Giá ${quotation.quotationCode} - Admin</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/fontawesome-free/css/all.min.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/css/adminlte.min.css">
  <style>
    .info-label { font-weight: 600; color: #666; min-width: 140px; display: inline-block; }
    .status-badge { font-size: 1rem; padding: 8px 16px; border-radius: 20px; }
    .history-timeline { position: relative; padding-left: 30px; }
    .history-timeline::before { content: ''; position: absolute; left: 10px; top: 0; bottom: 0; width: 2px; background: #dee2e6; }
    .history-item { position: relative; padding: 10px 0; }
    .history-item::before { content: ''; position: absolute; left: -24px; top: 14px; width: 10px; height: 10px; border-radius: 50%; background: #007bff; }
    .history-item.counter::before { background: #ffc107; }
    .history-item.accepted::before, .history-item.paid::before { background: #28a745; }
    .history-item.rejected::before { background: #dc3545; }
    .price-display { font-size: 1.5rem; font-weight: bold; }
    .negotiation-box { background: #fff3cd; border: 2px solid #ffc107; border-radius: 8px; padding: 20px; }
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
            <h1><i class="fas fa-file-invoice-dollar"></i> Chi Tiết Báo Giá</h1>
          </div>
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/admin/dashboard">Dashboard</a></li>
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/admin/quotations">Báo Giá</a></li>
              <li class="breadcrumb-item active">${quotation.quotationCode}</li>
            </ol>
          </div>
        </div>
      </div>
    </section>

    <section class="content">
      <div class="container-fluid">

        <!-- Alert Messages -->
        <c:if test="${param.success == 'created'}">
          <div class="alert alert-success alert-dismissible fade show">
            <i class="fas fa-check-circle"></i> Báo giá đã được tạo và gửi cho khách hàng.
            <button type="button" class="close" data-dismiss="alert">&times;</button>
          </div>
        </c:if>
        <c:if test="${param.success == 'countered'}">
          <div class="alert alert-info alert-dismissible fade show">
            <i class="fas fa-comments"></i> Đã gửi đề xuất giá mới cho khách hàng.
            <button type="button" class="close" data-dismiss="alert">&times;</button>
          </div>
        </c:if>
        <c:if test="${param.error == 'counter_failed'}">
          <div class="alert alert-danger alert-dismissible fade show">
            <i class="fas fa-exclamation-circle"></i> Không thể gửi đề xuất giá. Vui lòng thử lại.
            <button type="button" class="close" data-dismiss="alert">&times;</button>
          </div>
        </c:if>

        <div class="row">
          <!-- Main Content -->
          <div class="col-lg-8">
            <!-- Quotation Info -->
            <div class="card">
              <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0"><i class="fas fa-file-invoice"></i> ${quotation.quotationCode}</h5>
                <span class="badge badge-${quotation.statusBadgeClass} status-badge">${quotation.statusDisplayName}</span>
              </div>
              <div class="card-body">
                <div class="row">
                  <div class="col-md-6">
                    <c:if test="${quotation.rfq != null}">
                      <p><span class="info-label">RFQ:</span> 
                        <a href="<%= request.getContextPath() %>/admin/rfq/detail?id=${quotation.rfqID}">${quotation.rfq.rfqCode}</a>
                      </p>
                      <p><span class="info-label">Công ty:</span> ${quotation.rfq.companyName}</p>
                      <p><span class="info-label">Người liên hệ:</span> ${quotation.rfq.contactPerson}</p>
                      <p><span class="info-label">Điện thoại:</span> ${quotation.rfq.contactPhone}</p>
                      <p><span class="info-label">Email:</span> ${quotation.rfq.contactEmail}</p>
                    </c:if>
                  </div>
                  <div class="col-md-6">
                    <p><span class="info-label">Ngày tạo:</span> <fmt:formatDate value="${quotation.createdDate}" pattern="dd/MM/yyyy HH:mm"/></p>
                    <p><span class="info-label">Ngày gửi:</span> <fmt:formatDate value="${quotation.quotationSentDate}" pattern="dd/MM/yyyy HH:mm"/></p>
                    <p><span class="info-label">Hiệu lực đến:</span> 
                      <fmt:formatDate value="${quotation.quotationValidUntil}" pattern="dd/MM/yyyy"/>
                      <c:if test="${quotation.expired}"><span class="badge badge-danger ml-2">Hết hạn</span></c:if>
                    </p>
                    <p><span class="info-label">Thanh toán:</span> 
                      <c:choose>
                        <c:when test="${quotation.paymentMethod == 'BankTransfer'}">Chuyển khoản (VNPay)</c:when>
                        <c:otherwise>${quotation.paymentMethod}</c:otherwise>
                      </c:choose>
                    </p>
                    <p><span class="info-label">Thương lượng:</span> 
                      <span class="badge ${quotation.negotiationCount >= quotation.maxNegotiationCount ? 'badge-danger' : 'badge-info'}">
                        ${quotation.negotiationCount}/${quotation.maxNegotiationCount} lần
                      </span>
                    </p>
                  </div>
                </div>
              </div>
            </div>

            <!-- Customer Counter - Need Response -->
            <c:if test="${quotation.status == 'CustomerCountered'}">
              <div class="card border-warning">
                <div class="card-header bg-warning text-dark">
                  <i class="fas fa-exclamation-triangle"></i> Khách Hàng Đề Xuất Giá Mới - Cần Phản Hồi
                </div>
                <div class="card-body">
                  <div class="row mb-3">
                    <div class="col-md-6">
                      <p class="mb-1">Giá báo giá ban đầu:</p>
                      <h4 class="text-muted"><fmt:formatNumber value="${quotation.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></h4>
                    </div>
                    <div class="col-md-6">
                      <p class="mb-1">Giá khách hàng đề xuất:</p>
                      <h4 class="text-warning price-display"><fmt:formatNumber value="${quotation.customerCounterPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></h4>
                    </div>
                  </div>
                  <c:if test="${not empty quotation.customerCounterNote}">
                    <p><i class="fas fa-comment"></i> <strong>Ghi chú từ KH:</strong> ${quotation.customerCounterNote}</p>
                  </c:if>

                  <c:if test="${quotation.canSellerCounter()}">
                    <hr>
                    <div class="negotiation-box">
                      <h6><i class="fas fa-reply"></i> Phản Hồi Đề Xuất (còn ${quotation.remainingNegotiations} lần thương lượng)</h6>
                      <form action="<%= request.getContextPath() %>/admin/quotations/counter" method="POST" onsubmit="return validateCounterForm()">
                        <input type="hidden" name="quotationId" value="${quotation.quotationID}">
                        <div class="row">
                          <div class="col-md-5 mb-3">
                            <label>Giá đề xuất mới (₫) <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" name="counterPrice" id="counterPrice" min="1" required 
                                   value="${quotation.customerCounterPrice}" placeholder="Nhập giá đề xuất">
                          </div>
                          <div class="col-md-5 mb-3">
                            <label>Ghi chú</label>
                            <input type="text" class="form-control" name="note" maxlength="500" placeholder="Lý do đề xuất giá này...">
                          </div>
                          <div class="col-md-2 mb-3 d-flex align-items-end">
                            <button type="submit" class="btn btn-warning w-100">
                              <i class="fas fa-paper-plane"></i> Gửi
                            </button>
                          </div>
                        </div>
                      </form>
                    </div>
                  </c:if>
                  <c:if test="${!quotation.canSellerCounter()}">
                    <div class="alert alert-danger mt-3 mb-0">
                      <i class="fas fa-exclamation-circle"></i> Đã hết số lần thương lượng. Chờ khách hàng quyết định.
                    </div>
                  </c:if>
                </div>
              </div>
            </c:if>

            <!-- Seller Countered - Waiting -->
            <c:if test="${quotation.status == 'SellerCountered'}">
              <div class="card border-info">
                <div class="card-header bg-info text-white">
                  <i class="fas fa-hourglass-half"></i> Chờ Khách Hàng Phản Hồi
                </div>
                <div class="card-body">
                  <p>Bạn đã đề xuất giá: <strong class="text-info price-display">
                    <fmt:formatNumber value="${quotation.sellerCounterPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                  </strong></p>
                  <c:if test="${not empty quotation.sellerCounterNote}">
                    <p><i class="fas fa-comment"></i> Ghi chú: ${quotation.sellerCounterNote}</p>
                  </c:if>
                  <p class="text-muted mb-0">Vui lòng chờ khách hàng xem xét và phản hồi.</p>
                </div>
              </div>
            </c:if>

            <!-- Accepted -->
            <c:if test="${quotation.status == 'Accepted'}">
              <div class="card border-success">
                <div class="card-header bg-success text-white">
                  <i class="fas fa-check-circle"></i> Khách Hàng Đã Chấp Nhận
                </div>
                <div class="card-body">
                  <p class="mb-0">Khách hàng đã chấp nhận báo giá. Chờ thanh toán.</p>
                </div>
              </div>
            </c:if>

            <!-- Paid -->
            <c:if test="${quotation.status == 'Paid'}">
              <div class="card border-success">
                <div class="card-header bg-success text-white">
                  <i class="fas fa-check-double"></i> Đã Thanh Toán
                </div>
                <div class="card-body">
                  <p class="mb-0"><i class="fas fa-info-circle"></i> Đơn hàng đã được tạo và đang chờ xử lý.</p>
                </div>
              </div>
            </c:if>

            <!-- Rejected -->
            <c:if test="${quotation.status == 'Rejected'}">
              <div class="card border-danger">
                <div class="card-header bg-danger text-white">
                  <i class="fas fa-times-circle"></i> Khách Hàng Đã Từ Chối
                </div>
                <div class="card-body">
                  <c:if test="${not empty quotation.rejectionReason}">
                    <p><strong>Lý do:</strong> ${quotation.rejectionReason}</p>
                  </c:if>
                </div>
              </div>
            </c:if>

            <!-- Shipping Info -->
            <c:if test="${not empty quotation.shippingCarrierName}">
            <div class="card">
              <div class="card-header"><h5 class="mb-0"><i class="fas fa-truck"></i> Vận Chuyển</h5></div>
              <div class="card-body">
                <div class="row">
                  <div class="col-md-6">
                    <p><span class="info-label">Đơn vị:</span> <strong>${quotation.shippingCarrierName}</strong></p>
                    <p><span class="info-label">Dịch vụ:</span> ${quotation.shippingServiceName}</p>
                  </div>
                  <div class="col-md-6">
                    <p><span class="info-label">Phí ship:</span> 
                      <span class="text-primary"><fmt:formatNumber value="${quotation.shippingFee}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span>
                    </p>
                    <p><span class="info-label">Thời gian giao:</span> <span class="badge badge-success">${quotation.estimatedDeliveryDays} ngày</span></p>
                  </div>
                </div>
                <c:if test="${quotation.rfq != null && not empty quotation.rfq.deliveryAddress}">
                  <p><span class="info-label">Địa chỉ giao:</span> ${quotation.rfq.deliveryAddress}</p>
                </c:if>
              </div>
            </div>
            </c:if>

            <!-- Products -->
            <div class="card">
              <div class="card-header"><h5 class="mb-0"><i class="fas fa-boxes"></i> Sản Phẩm</h5></div>
              <div class="card-body p-0">
                <table class="table table-striped mb-0">
                  <thead>
                    <tr>
                      <th>Sản phẩm</th>
                      <th class="text-center">SL</th>
                      <th class="text-right">Giá vốn</th>
                      <th class="text-right">Đơn giá</th>
                      <th class="text-right">Thành tiền</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach var="item" items="${quotation.items}">
                      <tr>
                        <td>
                          <strong>${item.productName}</strong>
                          <c:if test="${not empty item.sku}"><br><small class="text-muted">SKU: ${item.sku}</small></c:if>
                        </td>
                        <td class="text-center">${item.quantity}</td>
                        <td class="text-right text-muted"><fmt:formatNumber value="${item.costPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                        <td class="text-right"><fmt:formatNumber value="${item.unitPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                        <td class="text-right"><fmt:formatNumber value="${item.subtotal}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                      </tr>
                    </c:forEach>
                  </tbody>
                  <tfoot>
                    <tr>
                      <td colspan="4" class="text-right"><strong>Tạm tính:</strong></td>
                      <td class="text-right"><fmt:formatNumber value="${quotation.subtotalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                    </tr>
                    <tr>
                      <td colspan="4" class="text-right">Phí vận chuyển:</td>
                      <td class="text-right"><fmt:formatNumber value="${quotation.shippingFee}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                    </tr>
                    <tr>
                      <td colspan="4" class="text-right">Thuế VAT:</td>
                      <td class="text-right"><fmt:formatNumber value="${quotation.taxAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                    </tr>
                    <tr class="table-primary">
                      <td colspan="4" class="text-right"><strong>TỔNG CỘNG:</strong></td>
                      <td class="text-right"><strong><fmt:formatNumber value="${quotation.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></strong></td>
                    </tr>
                  </tfoot>
                </table>
              </div>
            </div>

            <!-- Terms -->
            <c:if test="${not empty quotation.quotationTerms || not empty quotation.warrantyTerms || not empty quotation.sellerNotes}">
            <div class="card">
              <div class="card-header"><h5 class="mb-0"><i class="fas fa-file-contract"></i> Điều Khoản & Ghi Chú</h5></div>
              <div class="card-body">
                <c:if test="${not empty quotation.warrantyTerms}">
                  <p><span class="info-label">Bảo hành:</span> ${quotation.warrantyTerms}</p>
                </c:if>
                <c:if test="${not empty quotation.quotationTerms}">
                  <p><span class="info-label">Điều khoản:</span></p>
                  <pre style="white-space: pre-wrap; font-family: inherit; background: #f8f9fa; padding: 10px; border-radius: 4px;">${quotation.quotationTerms}</pre>
                </c:if>
                <c:if test="${not empty quotation.sellerNotes}">
                  <p><span class="info-label">Ghi chú nội bộ:</span> ${quotation.sellerNotes}</p>
                </c:if>
              </div>
            </div>
            </c:if>

            <!-- Back button -->
            <a href="<%= request.getContextPath() %>/admin/quotations" class="btn btn-secondary mb-4">
              <i class="fas fa-arrow-left"></i> Quay lại danh sách
            </a>
          </div>

          <!-- Sidebar -->
          <div class="col-lg-4">
            <!-- Summary -->
            <div class="card">
              <div class="card-header bg-primary text-white">
                <h5 class="mb-0"><i class="fas fa-calculator"></i> Tổng Kết</h5>
              </div>
              <div class="card-body">
                <table class="table table-sm mb-0">
                  <tr><td>Tổng tiền hàng:</td><td class="text-right"><fmt:formatNumber value="${quotation.subtotalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td></tr>
                  <tr><td>Phí vận chuyển:</td><td class="text-right"><fmt:formatNumber value="${quotation.shippingFee}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td></tr>
                  <tr><td>Thuế VAT:</td><td class="text-right"><fmt:formatNumber value="${quotation.taxAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td></tr>
                  <tr class="table-primary"><td><strong>TỔNG:</strong></td><td class="text-right"><strong><fmt:formatNumber value="${quotation.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></strong></td></tr>
                </table>
                <c:if test="${quotation.customerCounterPrice != null}">
                  <hr>
                  <p class="mb-1 small text-muted">Giá KH đề xuất:</p>
                  <h5 class="text-warning"><fmt:formatNumber value="${quotation.customerCounterPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></h5>
                </c:if>
                <c:if test="${quotation.sellerCounterPrice != null}">
                  <p class="mb-1 small text-muted">Giá Seller đề xuất:</p>
                  <h5 class="text-info"><fmt:formatNumber value="${quotation.sellerCounterPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></h5>
                </c:if>
              </div>
            </div>

            <!-- History -->
            <c:if test="${not empty quotation.history}">
            <div class="card">
              <div class="card-header"><h5 class="mb-0"><i class="fas fa-history"></i> Lịch Sử</h5></div>
              <div class="card-body">
                <div class="history-timeline">
                  <c:forEach var="h" items="${quotation.history}">
                    <div class="history-item ${h.newStatus == 'CustomerCountered' || h.newStatus == 'SellerCountered' ? 'counter' : ''} ${h.newStatus == 'Accepted' || h.newStatus == 'Paid' ? 'accepted' : ''} ${h.newStatus == 'Rejected' ? 'rejected' : ''}">
                      <strong>${h.action}</strong>
                      <c:if test="${not empty h.notes}">
                        <p class="mb-1 small">${h.notes}</p>
                      </c:if>
                      <c:if test="${h.priceChange != null}">
                        <p class="mb-1 small text-primary">
                          Giá: <fmt:formatNumber value="${h.priceChange}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                        </p>
                      </c:if>
                      <small class="text-muted"><fmt:formatDate value="${h.changedDate}" pattern="dd/MM/yyyy HH:mm"/></small>
                    </div>
                  </c:forEach>
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
</div>

<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/jquery/jquery.min.js"></script>
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/js/adminlte.min.js"></script>
<script>
function validateCounterForm() {
    var price = document.getElementById('counterPrice').value;
    if (!price || price <= 0) {
        alert('Vui lòng nhập giá đề xuất hợp lệ');
        return false;
    }
    return true;
}
</script>
</body>
</html>
