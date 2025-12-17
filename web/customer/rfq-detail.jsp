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
        .bg-draft { background: #adb5bd !important; color: #fff !important; }
        .bg-quoteexpired { background: #fd7e14 !important; color: #fff !important; }
        .history-list { padding-left: 0; margin-left: 0; list-style: none; }
        .history-item { position: relative; padding: 10px 0 15px 30px; border-bottom: 1px solid #eee; }
        .history-item:last-child { border-bottom: none; }
        .history-item::before { content: ''; width: 12px; height: 12px; background: #007bff; border-radius: 50%; position: absolute; left: 0; top: 15px; }
        .history-item.rejected::before { background: #dc3545; }
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
                <div class="alert alert-success alert-dismissible fade show auto-dismiss" role="alert">
                    <i class="fa fa-check-circle"></i> Yêu cầu báo giá đã được gửi thành công!
                    <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                </div>
            </c:if>

            <div class="row">
                <!-- Main Content -->
                <div class="col-lg-8">
                    <!-- RFQ Info -->
                    <div class="card mb-4">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h5 class="mb-0"><i class="fa fa-file-text"></i>
                                <c:choose>
                                    <c:when test="${not empty rfq.rfqCode}">${rfq.rfqCode}</c:when>
                                    <c:otherwise>Bản nháp yêu cầu báo giá</c:otherwise>
                                </c:choose>
                            </h5>
                            <c:choose>
                                <c:when test="${not empty rfq.status}">
                                    <span class="badge status-badge bg-${rfq.status.toLowerCase()}">
                                        ${rfq.statusDisplayName}
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-secondary">Chưa gửi</span>
                                </c:otherwise>
                            </c:choose>
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
                                    <p><span class="info-label">Email:</span> ${not empty rfq.contactEmail ? rfq.contactEmail : 'N/A'}</p>
                                    <c:if test="${not empty rfq.alternativeContact}">
                                        <p><span class="info-label">Liên hệ dự phòng:</span> ${rfq.alternativeContact}</p>
                                    </c:if>
                                </div>
                                <div class="col-md-6">
                                    <p><span class="info-label">Ngày tạo:</span> <fmt:formatDate value="${rfq.createdDate}" pattern="dd/MM/yyyy HH:mm"/></p>
                                    <p><span class="info-label">Ngày yêu cầu giao:</span> <fmt:formatDate value="${rfq.requestedDeliveryDate}" pattern="dd/MM/yyyy"/></p>
                                    <c:if test="${rfq.proposedDeliveryDate != null}">
                                        <p><span class="info-label">Ngày đề xuất:</span> <fmt:formatDate value="${rfq.proposedDeliveryDate}" pattern="dd/MM/yyyy"/></p>
                                    </c:if>
                                    <p><span class="info-label">Địa chỉ giao:</span> ${rfq.deliveryAddress}</p>
                                    <p><span class="info-label">Hình thức thanh toán:</span> Chuyển khoản ngân hàng (VNPay)</p>
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
                                <p>Phương thức thanh toán: <strong>Chuyển khoản ngân hàng (VNPay)</strong></p>
                                <c:if test="${not empty rfq.warrantyTerms}">
                                    <p>Bảo hành: ${rfq.warrantyTerms}</p>
                                </c:if>
                                <div class="alert alert-info mt-2">
                                    <i class="fa fa-info-circle"></i> Vui lòng vào mục <a href="${pageContext.request.contextPath}/quotation/detail?id=${rfq.rfqID}" class="alert-link"><strong>Đơn Báo Giá</strong></a> để xem chi tiết và thanh toán.
                                </div>
                            </div>
                        </div>
                    </c:if>

                    <c:if test="${rfq.status == 'QuoteExpired'}">
                        <div class="card mb-4 border-warning">
                            <div class="card-header bg-warning text-dark">
                                <i class="fa fa-clock-o"></i> Báo Giá Đã Hết Hạn
                            </div>
                            <div class="card-body">
                                <p class="text-danger mb-2"><i class="fa fa-exclamation-circle"></i> Báo giá này đã hết hạn vào ngày <strong><fmt:formatDate value="${rfq.quotationValidUntil}" pattern="dd/MM/yyyy"/></strong></p>
                                <p class="text-muted">Bạn không thể thanh toán cho báo giá này nữa. Vui lòng liên hệ với chúng tôi để được hỗ trợ hoặc tạo yêu cầu báo giá mới.</p>
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
                                                <div class="d-flex align-items-center">
                                                    <c:if test="${not empty item.productImage}">
                                                        <img src="${pageContext.request.contextPath}/${item.productImage}" alt="${item.productName}" 
                                                             style="width: 50px; height: 50px; object-fit: cover; margin-right: 10px; border-radius: 4px;">
                                                    </c:if>
                                                    <div>
                                                        <strong>${item.productName}</strong>
                                                        <c:if test="${not empty item.sku}"><br><small class="text-muted">SKU: ${item.sku}</small></c:if>
                                                        <c:if test="${not empty item.specialRequirements}"><br><small class="text-info">${item.specialRequirements}</small></c:if>
                                                    </div>
                                                </div>
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
                                    <c:set var="colSpan" value="${(rfq.status == 'Quoted' || rfq.status == 'QuoteAccepted' || rfq.status == 'Completed') ? 3 : 1}" />
                                    <tfoot>
                                        <tr>
                                            <td colspan="${colSpan}" class="text-right"><strong>Tạm tính:</strong></td>
                                            <td class="text-right"><fmt:formatNumber value="${rfq.subtotalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                        </tr>
                                        <tr>
                                            <td colspan="${colSpan}" class="text-right">Phí vận chuyển:</td>
                                            <td class="text-right"><fmt:formatNumber value="${rfq.shippingFee}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                        </tr>
                                        <tr>
                                            <td colspan="${colSpan}" class="text-right">Thuế:</td>
                                            <td class="text-right"><fmt:formatNumber value="${rfq.taxAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                        </tr>
                                        <tr class="table-primary">
                                            <td colspan="${colSpan}" class="text-right"><strong>TỔNG CỘNG:</strong></td>
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

                    <!-- Draft action: gửi đơn yêu cầu báo giá -->
                    <c:if test="${isDraft}">
                        <div class="card mt-3">
                            <div class="card-body">
                                <h5 class="mb-3"><i class="fa fa-paper-plane"></i> Gửi yêu cầu báo giá</h5>
                                
                                <!-- Form chỉnh sửa - quay lại rfq-form với dữ liệu cũ -->
                                <form action="${pageContext.request.contextPath}/rfq/edit-draft" method="POST" id="editDraftForm" class="mb-2">
                                    <input type="hidden" name="companyName" value="${rfq.companyName}"/>
                                    <input type="hidden" name="taxID" value="${rfq.taxID}"/>
                                    <input type="hidden" name="businessType" value="${rfq.businessType}"/>
                                    <input type="hidden" name="contactPerson" value="${rfq.contactPerson}"/>
                                    <input type="hidden" name="contactPhone" value="${rfq.contactPhone}"/>
                                    <input type="hidden" name="contactEmail" value="${rfq.contactEmail}"/>
                                    <input type="hidden" name="alternativeContact" value="${rfq.alternativeContact}"/>
                                    <input type="hidden" name="deliveryAddress" value="${rfq.deliveryAddress}"/>
                                    <input type="hidden" name="deliveryCity" value="${rfq.deliveryCity}"/>
                                    <input type="hidden" name="deliveryCityId" value="${rfq.deliveryCityId}"/>
                                    <input type="hidden" name="deliveryDistrict" value="${rfq.deliveryDistrict}"/>
                                    <input type="hidden" name="deliveryDistrictId" value="${rfq.deliveryDistrictId}"/>
                                    <input type="hidden" name="deliveryWard" value="${rfq.deliveryWard}"/>
                                    <input type="hidden" name="deliveryWardId" value="${rfq.deliveryWardId}"/>
                                    <input type="hidden" name="deliveryStreet" value="${rfq.deliveryStreet}"/>
                                    <input type="hidden" name="deliveryInstructions" value="${rfq.deliveryInstructions}"/>
                                    <input type="hidden" name="customerNotes" value="${rfq.customerNotes}"/>
                                    <input type="hidden" name="preferredPaymentMethod" value="${rfq.paymentMethod}"/>
                                    <input type="hidden" name="requestedDeliveryDate"
                                           value="<fmt:formatDate value='${rfq.requestedDeliveryDate}' pattern='yyyy-MM-dd'/>"/>
                                    <input type="hidden" name="shippingCarrierId" value="${rfq.shippingCarrierId}"/>
                                    <input type="hidden" name="shippingCarrierName" value="${rfq.shippingCarrierName}"/>
                                    <input type="hidden" name="shippingServiceName" value="${rfq.shippingServiceName}"/>
                                    <input type="hidden" name="shippingFee" value="${rfq.shippingFee}"/>
                                    <input type="hidden" name="estimatedDeliveryDays" value="${rfq.estimatedDeliveryDays}"/>
                                    <c:forEach var="item" items="${rfq.items}">
                                        <input type="hidden" name="productId" value="${item.productID}"/>
                                        <input type="hidden" name="variantId" value="${item.variantID}"/>
                                        <input type="hidden" name="quantity" value="${item.quantity}"/>
                                        <input type="hidden" name="specialRequirements" value="${item.specialRequirements}"/>
                                    </c:forEach>
                                    <c:if test="${not empty rfq.rfqID}">
                                        <input type="hidden" name="draftRfqId" value="${rfq.rfqID}"/>
                                    </c:if>
                                    <button type="submit" class="btn btn-outline-secondary btn-block">
                                        <i class="fa fa-edit"></i> Chỉnh sửa
                                    </button>
                                </form>
                                
                                <!-- Form gửi đơn -->
                                <form action="${pageContext.request.contextPath}/rfq/submit" method="POST" id="submitRfqForm">
                                    <input type="hidden" name="companyName" value="${rfq.companyName}"/>
                                    <input type="hidden" name="taxID" value="${rfq.taxID}"/>
                                    <input type="hidden" name="businessType" value="${rfq.businessType}"/>
                                    <input type="hidden" name="contactPerson" value="${rfq.contactPerson}"/>
                                    <input type="hidden" name="contactPhone" value="${rfq.contactPhone}"/>
                                    <input type="hidden" name="contactEmail" value="${rfq.contactEmail}"/>
                                    <input type="hidden" name="alternativeContact" value="${rfq.alternativeContact}"/>
                                    <input type="hidden" name="deliveryAddress" value="${rfq.deliveryAddress}"/>
                                    <input type="hidden" name="deliveryCityId" value="${rfq.deliveryCityId}"/>
                                    <input type="hidden" name="deliveryDistrictId" value="${rfq.deliveryDistrictId}"/>
                                    <input type="hidden" name="deliveryWardId" value="${rfq.deliveryWardId}"/>
                                    <input type="hidden" name="deliveryInstructions" value="${rfq.deliveryInstructions}"/>
                                    <input type="hidden" name="customerNotes" value="${rfq.customerNotes}"/>
                                    <input type="hidden" name="preferredPaymentMethod" value="${rfq.paymentMethod}"/>
                                    <input type="hidden" name="requestedDeliveryDate"
                                           value="<fmt:formatDate value='${rfq.requestedDeliveryDate}' pattern='yyyy-MM-dd'/>"/>
                                    <input type="hidden" name="shippingCarrierId" value="${rfq.shippingCarrierId}"/>
                                    <input type="hidden" name="shippingCarrierName" value="${rfq.shippingCarrierName}"/>
                                    <input type="hidden" name="shippingServiceName" value="${rfq.shippingServiceName}"/>
                                    <input type="hidden" name="shippingFee" value="${rfq.shippingFee}"/>
                                    <input type="hidden" name="estimatedDeliveryDays" value="${rfq.estimatedDeliveryDays}"/>
                                    <c:forEach var="item" items="${rfq.items}">
                                        <input type="hidden" name="productId" value="${item.productID}"/>
                                        <input type="hidden" name="variantId" value="${item.variantID}"/>
                                        <input type="hidden" name="quantity" value="${item.quantity}"/>
                                        <input type="hidden" name="specialRequirements" value="${item.specialRequirements}"/>
                                    </c:forEach>
                                    <c:if test="${not empty rfq.rfqID}">
                                        <input type="hidden" name="draftRfqId" value="${rfq.rfqID}"/>
                                    </c:if>
                                    <button type="submit" class="btn btn-primary btn-block">
                                        <i class="fa fa-paper-plane"></i> Gửi đơn yêu cầu báo giá
                                    </button>
                                </form>
                            </div>
                        </div>
                    </c:if>
                    
                    <!-- Draft status: hiển thị cho đơn đã lưu với status Draft -->
                    <c:if test="${rfq.status == 'Draft' && not isDraft}">
                        <div class="card mt-3">
                            <div class="card-body">
                                <h5 class="mb-3"><i class="fa fa-file-o"></i> Đơn chờ xác nhận</h5>
                                <p class="text-muted small">Đơn này đang ở trạng thái nháp. Bạn có thể chỉnh sửa hoặc gửi đơn.</p>
                                
                                <a href="${pageContext.request.contextPath}/rfq/edit?id=${rfq.rfqID}" class="btn btn-outline-secondary btn-block mb-2">
                                    <i class="fa fa-edit"></i> Chỉnh sửa
                                </a>
                                
                                <form action="${pageContext.request.contextPath}/rfq/submit-draft" method="POST">
                                    <input type="hidden" name="rfqId" value="${rfq.rfqID}"/>
                                    <button type="submit" class="btn btn-primary btn-block">
                                        <i class="fa fa-paper-plane"></i> Gửi đơn yêu cầu báo giá
                                    </button>
                                </form>
                            </div>
                        </div>
                    </c:if>
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
    
    <c:if test="${isDraft}">
    <script>
        var contextPath = '${pageContext.request.contextPath}';
        var draftSaved = false;
        var isSubmitting = false;
        var savedRfqId = null;
        
        // DO NOT auto-save draft immediately - only save when user leaves page
        // This prevents creating duplicate RFQs (one draft + one submitted)
        $(document).ready(function() {
            // Auto-dismiss alerts after 5 seconds
            setTimeout(function() {
                $('.auto-dismiss').fadeOut('slow', function() {
                    $(this).remove();
                });
            }, 5000);
            
            // Intercept all link clicks to show confirmation
            $('a').not('[data-no-confirm]').on('click', function(e) {
                if (!isSubmitting) {
                    var href = $(this).attr('href');
                    // Skip if it's a hash link, javascript, or modal trigger
                    if (!href || href === '#' || href.startsWith('javascript:') || $(this).data('toggle') === 'modal') {
                        return true;
                    }
                    
                    e.preventDefault();
                    if (confirm('Bạn có chắc muốn rời khỏi trang?\n\nThông tin đơn hàng sẽ được lưu dưới dạng nháp trong danh sách yêu cầu báo giá của bạn.')) {
                        isSubmitting = true; // Prevent beforeunload from showing again
                        if (!draftSaved) {
                            saveDraftSync();
                        }
                        window.location.href = href;
                    }
                }
            });
        });
        
        // Mark as submitting when form is submitted
        $('#submitRfqForm').on('submit', function() {
            isSubmitting = true;
        });
        $('#editDraftForm').on('submit', function() {
            isSubmitting = true;
        });
        
        // Warning when leaving page and auto-save draft
        $(window).on('beforeunload', function(e) {
            if (!isSubmitting) {
                // Save draft before leaving
                if (!draftSaved) {
                    saveDraftSync();
                }
                // Show confirmation dialog
                var message = 'Bạn có chắc muốn rời khỏi trang? Thông tin đơn hàng sẽ được lưu dưới dạng nháp.';
                e.returnValue = message;
                return message;
            }
        });
        
        // Also save when visibility changes (tab switch)
        document.addEventListener('visibilitychange', function() {
            if (document.visibilityState === 'hidden' && !isSubmitting && !draftSaved) {
                saveDraftSync();
            }
        });
        
        function saveDraftAsync() {
            var formData = $('#submitRfqForm').serialize();
            $.ajax({
                url: contextPath + '/rfq/save-draft',
                type: 'POST',
                data: formData,
                async: true,
                success: function(response) {
                    draftSaved = true;
                    if (response.rfqId) {
                        savedRfqId = response.rfqId;
                        // Update hidden field with new rfqId
                        if ($('input[name="draftRfqId"]').length === 0) {
                            $('#submitRfqForm').append('<input type="hidden" name="draftRfqId" value="' + response.rfqId + '"/>');
                            $('#editDraftForm').append('<input type="hidden" name="draftRfqId" value="' + response.rfqId + '"/>');
                        }
                    }
                }
            });
        }
        
        function saveDraftSync() {
            var formData = $('#submitRfqForm').serialize();
            // Use sendBeacon for reliable delivery when page is closing
            if (navigator.sendBeacon) {
                var blob = new Blob([formData], {type: 'application/x-www-form-urlencoded'});
                navigator.sendBeacon(contextPath + '/rfq/save-draft', blob);
                draftSaved = true;
            } else {
                // Fallback to sync ajax
                $.ajax({
                    url: contextPath + '/rfq/save-draft',
                    type: 'POST',
                    data: formData,
                    async: false
                });
                draftSaved = true;
            }
        }
    </script>
    </c:if>
</body>
</html>
