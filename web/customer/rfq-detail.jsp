<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi Tiết RFQ ${rfq.rfqCode} - Pickleball Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" type="text/css">
    <style>
        .status-badge { font-size: 1rem; padding: 8px 16px; border-radius: 4px; }
        .bg-pending { background: #ffc107 !important; color: #000 !important; }
        .bg-reviewing { background: #17a2b8 !important; color: #fff !important; }
        .bg-dateproposed { background: #fd7e14 !important; color: #fff !important; }
        .bg-dateaccepted { background: #20c997 !important; color: #fff !important; }
        .bg-daterejected { background: #dc3545 !important; color: #fff !important; }
        .bg-quoted { background: #007bff !important; color: #fff !important; }
        .bg-quoteaccepted { background: #6f42c1 !important; color: #fff !important; }
        .bg-quoterejected { background: #dc3545 !important; color: #fff !important; }
        .bg-completed { background: #28a745 !important; color: #fff !important; }
        .bg-cancelled { background: #6c757d !important; color: #fff !important; }
        .history-list { padding-left: 0; margin-left: 0; list-style: none; }
        .history-item { position: relative; padding: 10px 0 15px 30px; border-bottom: 1px solid #eee; }
        .history-item:last-child { border-bottom: none; }
        .history-item::before { content: ''; width: 12px; height: 12px; background: #007bff; border-radius: 50%; position: absolute; left: 0; top: 15px; }
        .history-item.completed::before { background: #28a745; }
        .info-label { font-weight: 600; color: #666; }
    </style>
</head>
<body>
    <%@include file="../header.jsp" %>

    <section class="breadcrumb-option">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="breadcrumb__text">
                        <h4>Chi Tiết Yêu Cầu Báo Giá</h4>
                        <div class="breadcrumb__links">
                            <a href="${pageContext.request.contextPath}/Home">Trang chủ</a>
                            <a href="${pageContext.request.contextPath}/rfq/list">Yêu cầu báo giá</a>
                            <span>${rfq.rfqCode}</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="spad">
        <div class="container">
            <c:if test="${param.success == 'created'}">
                <div class="alert alert-success"><i class="fa fa-check-circle"></i> Yêu cầu báo giá đã được gửi thành công!</div>
            </c:if>

            <div class="row">
                <!-- Main Content -->
                <div class="col-lg-8">
                    <!-- RFQ Info -->
                    <div class="card mb-4">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h5 class="mb-0"><i class="fa fa-file-text"></i> ${rfq.rfqCode}</h5>
                            <span class="badge status-badge bg-${rfq.status.toLowerCase()}">
                                ${rfq.statusDisplayName}
                            </span>
                        </div>
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
                                    <p><span class="info-label">Người liên hệ:</span> ${rfq.contactPerson}</p>
                                    <p><span class="info-label">Điện thoại:</span> ${rfq.contactPhone}</p>
                                </div>
                                <div class="col-md-6">
                                    <p><span class="info-label">Ngày tạo:</span> <fmt:formatDate value="${rfq.createdDate}" pattern="dd/MM/yyyy HH:mm"/></p>
                                    <p><span class="info-label">Ngày yêu cầu giao:</span> <fmt:formatDate value="${rfq.requestedDeliveryDate}" pattern="dd/MM/yyyy"/></p>
                                    <c:if test="${rfq.proposedDeliveryDate != null}">
                                        <p><span class="info-label">Ngày đề xuất:</span> <fmt:formatDate value="${rfq.proposedDeliveryDate}" pattern="dd/MM/yyyy"/></p>
                                    </c:if>
                                    <p><span class="info-label">Địa chỉ giao:</span> ${rfq.deliveryAddress}</p>
                                    <p><span class="info-label">Hình thức thanh toán:</span> 
                                        <c:choose>
                                            <c:when test="${rfq.paymentMethod == 'BankTransfer'}">Chuyển khoản ngân hàng</c:when>
                                            <c:when test="${rfq.paymentMethod == 'COD'}">Thanh toán khi nhận hàng (COD) + Cọc 50%</c:when>
                                            <c:otherwise>${rfq.paymentMethod != null ? rfq.paymentMethod : 'Chưa chọn'}</c:otherwise>
                                        </c:choose>
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Action Required -->
                    <c:if test="${rfq.status == 'DateProposed'}">
                        <div class="card mb-4 border-warning">
                            <div class="card-header bg-warning text-dark">
                                <i class="fa fa-exclamation-triangle"></i> Yêu Cầu Phản Hồi
                            </div>
                            <div class="card-body">
                                <p>Seller đề xuất thay đổi ngày giao hàng:</p>
                                <p><strong>Ngày mới: <fmt:formatDate value="${rfq.proposedDeliveryDate}" pattern="dd/MM/yyyy"/></strong></p>
                                <c:if test="${not empty rfq.dateChangeReason}">
                                    <p>Lý do: ${rfq.dateChangeReason}</p>
                                </c:if>
                                <div class="d-flex gap-2">
                                    <form action="${pageContext.request.contextPath}/rfq/accept-date" method="POST" class="mr-2">
                                        <input type="hidden" name="rfqId" value="${rfq.rfqID}">
                                        <button type="submit" class="btn btn-success"><i class="fa fa-check"></i> Chấp Nhận</button>
                                    </form>
                                    <button type="button" class="btn btn-danger" data-toggle="modal" data-target="#rejectDateModal">
                                        <i class="fa fa-times"></i> Từ Chối
                                    </button>
                                </div>
                            </div>
                        </div>
                    </c:if>

                    <c:if test="${rfq.status == 'Quoted'}">
                        <div class="card mb-4 border-primary">
                            <div class="card-header bg-primary text-white">
                                <i class="fa fa-file-text-o"></i> Báo Giá Đã Nhận
                            </div>
                            <div class="card-body">
                                <p>Báo giá có hiệu lực đến: <strong><fmt:formatDate value="${rfq.quotationValidUntil}" pattern="dd/MM/yyyy"/></strong></p>
                                <p>Phương thức thanh toán: <strong>
                                    <c:choose>
                                        <c:when test="${rfq.paymentMethod == 'BankTransfer'}">Chuyển khoản ngân hàng</c:when>
                                        <c:when test="${rfq.paymentMethod == 'COD'}">Thanh toán khi nhận hàng (COD) + Cọc 50%</c:when>
                                        <c:otherwise>${rfq.paymentMethod}</c:otherwise>
                                    </c:choose>
                                </strong></p>
                                <c:if test="${not empty rfq.warrantyTerms}">
                                    <p>Bảo hành: ${rfq.warrantyTerms}</p>
                                </c:if>
                                <div class="d-flex gap-2">
                                    <form action="${pageContext.request.contextPath}/rfq/payment" method="POST" class="mr-2">
                                        <input type="hidden" name="rfqId" value="${rfq.rfqID}">
                                        <button type="submit" class="btn btn-success btn-lg">
                                            <i class="fa fa-check"></i> Chấp Nhận & Thanh Toán
                                            <c:if test="${rfq.paymentMethod == 'COD'}">
                                                <small>(Cọc 50%)</small>
                                            </c:if>
                                        </button>
                                    </form>
                                    <button type="button" class="btn btn-outline-danger" data-toggle="modal" data-target="#rejectQuoteModal">
                                        <i class="fa fa-times"></i> Từ Chối
                                    </button>
                                </div>
                            </div>
                        </div>
                    </c:if>

                    <!-- Products -->
                    <div class="card mb-4">
                        <div class="card-header"><h5 class="mb-0"><i class="fa fa-cube"></i> Sản Phẩm</h5></div>
                        <div class="card-body p-0">
                            <table class="table table-striped mb-0">
                                <thead>
                                    <tr>
                                        <th>Sản phẩm</th>
                                        <th class="text-center">Số lượng</th>
                                        <c:if test="${rfq.status == 'Quoted' || rfq.status == 'QuoteAccepted' || rfq.status == 'Completed'}">
                                            <th class="text-right">Đơn giá</th>
                                            <th class="text-right">Thành tiền</th>
                                        </c:if>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="item" items="${rfq.items}">
                                        <tr>
                                            <td>
                                                <strong>${item.productName}</strong>
                                                <c:if test="${not empty item.sku}"><br><small class="text-muted">SKU: ${item.sku}</small></c:if>
                                                <c:if test="${not empty item.specialRequirements}"><br><small class="text-info">${item.specialRequirements}</small></c:if>
                                            </td>
                                            <td class="text-center">${item.quantity}</td>
                                            <c:if test="${rfq.status == 'Quoted' || rfq.status == 'QuoteAccepted' || rfq.status == 'Completed'}">
                                                <td class="text-right"><fmt:formatNumber value="${item.unitPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                                <td class="text-right"><fmt:formatNumber value="${item.subtotal}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                            </c:if>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                                <c:if test="${rfq.totalAmount != null && rfq.totalAmount > 0}">
                                    <tfoot>
                                        <tr>
                                            <td colspan="3" class="text-right"><strong>Tạm tính:</strong></td>
                                            <td class="text-right"><fmt:formatNumber value="${rfq.subtotalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                        </tr>
                                        <tr>
                                            <td colspan="3" class="text-right">Phí vận chuyển:</td>
                                            <td class="text-right"><fmt:formatNumber value="${rfq.shippingFee}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                        </tr>
                                        <tr>
                                            <td colspan="3" class="text-right">Thuế:</td>
                                            <td class="text-right"><fmt:formatNumber value="${rfq.taxAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                        </tr>
                                        <tr class="table-primary">
                                            <td colspan="3" class="text-right"><strong>TỔNG CỘNG:</strong></td>
                                            <td class="text-right"><strong><fmt:formatNumber value="${rfq.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></strong></td>
                                        </tr>
                                    </tfoot>
                                </c:if>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Sidebar -->
                <div class="col-lg-4">
                    <!-- Timeline -->
                    <div class="card">
                        <div class="card-header"><h5 class="mb-0"><i class="fa fa-history"></i> Lịch Sử</h5></div>
                        <div class="card-body">
                            <div class="history-list">
                                <c:forEach var="h" items="${rfq.history}">
                                    <div class="history-item ${h.newStatus == 'Completed' ? 'completed' : ''}">
                                        <strong>${h.action}</strong>
                                        <p class="mb-1 small">${h.notes}</p>
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

    <!-- Reject Date Modal -->
    <div class="modal fade" id="rejectDateModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/rfq/reject-date" method="POST">
                    <input type="hidden" name="rfqId" value="${rfq.rfqID}">
                    <div class="modal-header">
                        <h5 class="modal-title">Từ Chối Ngày Giao Mới</h5>
                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                    </div>
                    <div class="modal-body">
                        <p class="text-danger">Lưu ý: Từ chối sẽ hủy yêu cầu báo giá này.</p>
                        <div class="form-group">
                            <label>Lý do từ chối</label>
                            <textarea class="form-control" name="reason" rows="3" required></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-danger">Xác Nhận Từ Chối</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Reject Quote Modal -->
    <div class="modal fade" id="rejectQuoteModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/rfq/reject-quote" method="POST">
                    <input type="hidden" name="rfqId" value="${rfq.rfqID}">
                    <div class="modal-header">
                        <h5 class="modal-title">Từ Chối Báo Giá</h5>
                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                    </div>
                    <div class="modal-body">
                        <div class="form-group">
                            <label>Lý do từ chối</label>
                            <textarea class="form-control" name="reason" rows="3" required></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-danger">Xác Nhận Từ Chối</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%@include file="../footer.jsp"%>
    <script src="${pageContext.request.contextPath}/js/jquery-3.3.1.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/bootstrap.min.js"></script>
</body>
</html>
