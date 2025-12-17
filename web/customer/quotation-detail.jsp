<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi Tiết Báo Giá ${rfq.rfqCode} - Pickleball Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" type="text/css">
    <style>
        .status-badge { font-size: 1rem; padding: 8px 16px; border-radius: 4px; }
        .bg-quoted { background: #ffc107 !important; color: #000 !important; }
        .bg-completed { background: #28a745 !important; color: #fff !important; }
        .bg-quoterejected { background: #dc3545 !important; color: #fff !important; }
        .info-label { font-weight: 600; color: #666; }
        .history-list { padding-left: 0; margin-left: 0; list-style: none; }
        .history-item { position: relative; padding: 10px 0 15px 30px; border-bottom: 1px solid #eee; }
        .history-item:last-child { border-bottom: none; }
        .history-item::before { content: ''; width: 12px; height: 12px; background: #007bff; border-radius: 50%; position: absolute; left: 0; top: 15px; }
        .history-item.rejected::before { background: #dc3545; }
        .history-item.completed::before { background: #28a745; }
    </style>
</head>
<body>
    <%@include file="../header.jsp" %>

    <section class="breadcrumb-option">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="breadcrumb__text">
                        <h4>Chi Tiết Báo Giá</h4>
                        <div class="breadcrumb__links">
                            <a href="${pageContext.request.contextPath}/Home">Trang chủ</a>
                            <a href="${pageContext.request.contextPath}/quotation/list">Đơn Báo Giá</a>
                            <span>${rfq.rfqCode}</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="spad">
        <div class="container">
            <c:if test="${param.success == 'rejected'}">
                <div class="alert alert-info alert-dismissible fade show" role="alert">
                    <i class="fa fa-info-circle"></i> Bạn đã từ chối báo giá này.
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                </div>
            </c:if>

            <div class="row">
                <!-- Main Content -->
                <div class="col-lg-8">
                    <!-- Quotation Info -->
                    <div class="card mb-4">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h5 class="mb-0"><i class="fa fa-file-text-o"></i> ${rfq.rfqCode}</h5>
                            <span class="badge status-badge bg-${rfq.status.toLowerCase()}">
                                <c:choose>
                                    <c:when test="${rfq.status == 'Quoted'}">Chờ chấp nhận</c:when>
                                    <c:when test="${rfq.status == 'Completed'}">Đã thanh toán</c:when>
                                    <c:when test="${rfq.status == 'QuoteRejected'}">Đã từ chối</c:when>
                                    <c:otherwise>${rfq.statusDisplayName}</c:otherwise>
                                </c:choose>
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
                                    <p><span class="info-label">Email:</span> ${rfq.contactEmail}</p>
                                </div>
                                <div class="col-md-6">
                                    <p><span class="info-label">Ngày báo giá:</span> <fmt:formatDate value="${rfq.quotationSentDate}" pattern="dd/MM/yyyy"/></p>
                                    <p><span class="info-label">Hiệu lực đến:</span> <fmt:formatDate value="${rfq.quotationValidUntil}" pattern="dd/MM/yyyy"/></p>
                                    <p><span class="info-label">Ngày giao hàng:</span> <fmt:formatDate value="${rfq.requestedDeliveryDate}" pattern="dd/MM/yyyy"/></p>
                                    <p><span class="info-label">Địa chỉ giao:</span> ${rfq.deliveryAddress}</p>
                                    <p><span class="info-label">Thanh toán:</span> Chuyển khoản ngân hàng (VNPay)</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Shipping Carrier Info -->
                    <c:if test="${not empty rfq.shippingCarrierName}">
                    <div class="card mb-4">
                        <div class="card-header"><h5 class="mb-0"><i class="fa fa-truck"></i> Đơn Vị Vận Chuyển</h5></div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <p><span class="info-label">Đơn vị vận chuyển:</span> <strong>${rfq.shippingCarrierName}</strong></p>
                                    <p><span class="info-label">Dịch vụ:</span> ${rfq.shippingServiceName}</p>
                                </div>
                                <div class="col-md-6">
                                    <p><span class="info-label">Phí vận chuyển (dự kiến):</span> 
                                        <span class="text-primary"><fmt:formatNumber value="${rfq.shippingFee}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span>
                                    </p>
                                    <p><span class="info-label">Thời gian giao hàng:</span> 
                                        <span class="badge badge-success">${rfq.estimatedDeliveryDays} ngày</span>
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                    </c:if>

                    <!-- Action Card for Quoted status -->
                    <c:if test="${rfq.status == 'Quoted'}">
                        <div class="card mb-4 border-primary">
                            <div class="card-header bg-primary text-white">
                                <i class="fa fa-credit-card"></i> Thanh Toán Báo Giá
                            </div>
                            <div class="card-body">
                                <p class="mb-2">Tổng giá trị: <strong class="text-primary" style="font-size: 1.5rem;">
                                    <fmt:formatNumber value="${rfq.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                </strong></p>
                                <p class="text-muted small mb-3">Báo giá có hiệu lực đến: <fmt:formatDate value="${rfq.quotationValidUntil}" pattern="dd/MM/yyyy"/></p>
                                
                                <div class="d-flex">
                                    <form action="${pageContext.request.contextPath}/rfq/payment" method="POST" class="mr-2">
                                        <input type="hidden" name="rfqId" value="${rfq.rfqID}">
                                        <button type="submit" class="btn btn-success btn-lg">
                                            <i class="fa fa-check"></i> Thanh Toán Ngay
                                        </button>
                                    </form>
                                    <button type="button" class="btn btn-outline-danger" data-toggle="modal" data-target="#rejectQuoteModal">
                                        <i class="fa fa-times"></i> Từ Chối
                                    </button>
                                </div>
                            </div>
                        </div>
                    </c:if>

                    <!-- Completed status -->
                    <c:if test="${rfq.status == 'Completed'}">
                        <div class="card mb-4 border-success">
                            <div class="card-header bg-success text-white">
                                <i class="fa fa-check-circle"></i> Đã Thanh Toán Thành Công
                            </div>
                            <div class="card-body">
                                <p class="mb-0"><i class="fa fa-info-circle"></i> Đơn hàng của bạn đã được tạo và đang được xử lý.</p>
                            </div>
                        </div>
                    </c:if>

                    <!-- Rejected status -->
                    <c:if test="${rfq.status == 'QuoteRejected'}">
                        <div class="card mb-4 border-danger">
                            <div class="card-header bg-danger text-white">
                                <i class="fa fa-times-circle"></i> Báo Giá Đã Bị Từ Chối
                            </div>
                            <div class="card-body">
                                <c:if test="${not empty rfq.rejectionReason}">
                                    <p><strong>Lý do:</strong> ${rfq.rejectionReason}</p>
                                </c:if>
                                <a href="${pageContext.request.contextPath}/rfq/form" class="btn btn-primary">
                                    <i class="fa fa-plus"></i> Tạo Yêu Cầu Báo Giá Mới
                                </a>
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
                                        <th class="text-right">Đơn giá</th>
                                        <th class="text-right">Thành tiền</th>
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
                                            <td class="text-right"><fmt:formatNumber value="${item.unitPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                            <td class="text-right"><fmt:formatNumber value="${item.subtotal}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
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
                            </table>
                        </div>
                    </div>

                    <!-- Back button -->
                    <a href="${pageContext.request.contextPath}/quotation/list" class="btn btn-secondary">
                        <i class="fa fa-arrow-left"></i> Quay lại danh sách
                    </a>
                </div>

                <!-- Sidebar -->
                <div class="col-lg-4">
                    <!-- History -->
                    <c:if test="${not empty rfq.history}">
                        <div class="card">
                            <div class="card-header"><h5 class="mb-0"><i class="fa fa-history"></i> Lịch Sử</h5></div>
                            <div class="card-body">
                                <div class="history-list">
                                    <c:forEach var="h" items="${rfq.history}">
                                        <div class="history-item ${h.newStatus == 'QuoteRejected' || h.newStatus == 'DateRejected' || h.newStatus == 'Cancelled' ? 'rejected' : ''} ${h.newStatus == 'Completed' ? 'completed' : ''}">
                                            <strong>${h.action}</strong>
                                            <p class="mb-1 small">${h.notes}</p>
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

    <!-- Reject Quote Modal -->
    <div class="modal fade" id="rejectQuoteModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/quotation/reject" method="POST">
                    <input type="hidden" name="rfqId" value="${rfq.rfqID}">
                    <div class="modal-header">
                        <h5 class="modal-title">Từ Chối Báo Giá</h5>
                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                    </div>
                    <div class="modal-body">
                        <div class="form-group">
                            <label>Lý do từ chối</label>
                            <textarea class="form-control" name="reason" rows="3" required placeholder="Vui lòng cho biết lý do từ chối..."></textarea>
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
