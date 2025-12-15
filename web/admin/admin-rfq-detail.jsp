<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi Tiết RFQ ${rfq.rfqCode} - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .info-label { font-weight: 600; color: #666; }
        .timeline { border-left: 2px solid #dee2e6; padding-left: 20px; margin-left: 10px; }
        .timeline-item { position: relative; padding-bottom: 15px; }
        .timeline-item::before { content: ''; width: 10px; height: 10px; background: #007bff; border-radius: 50%; position: absolute; left: -25px; top: 5px; }
    </style>
</head>
<body class="bg-light">
    <div class="container-fluid py-4">
        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4><i class="fas fa-file-invoice"></i> Chi Tiết RFQ: ${rfq.rfqCode}</h4>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin">Dashboard</a></li>
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/rfq">RFQ</a></li>
                        <li class="breadcrumb-item active">${rfq.rfqCode}</li>
                    </ol>
                </nav>
            </div>
            <div>
                <span class="badge bg-${rfq.status == 'Completed' ? 'success' : rfq.status == 'Quoted' ? 'primary' : 'warning'} fs-6">
                    ${rfq.statusDisplayName}
                </span>
            </div>
        </div>

        <c:if test="${param.success == 'date_proposed'}">
            <div class="alert alert-success"><i class="fas fa-check"></i> Đã gửi đề xuất ngày giao hàng mới!</div>
        </c:if>
        <c:if test="${param.success == 'quotation_sent'}">
            <div class="alert alert-success"><i class="fas fa-check"></i> Đã gửi báo giá thành công!</div>
        </c:if>

        <div class="row">
            <!-- Main Content -->
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
                                    <c:choose>
                                        <c:when test="${rfq.paymentMethod == 'BankTransfer'}"><span class="badge bg-info">Chuyển khoản ngân hàng</span></c:when>
                                        <c:when test="${rfq.paymentMethod == 'COD'}"><span class="badge bg-warning text-dark">COD + Cọc 50%</span></c:when>
                                        <c:otherwise><span class="badge bg-secondary">${rfq.paymentMethod != null ? rfq.paymentMethod : 'Chưa chọn'}</span></c:otherwise>
                                    </c:choose>
                                </p>
                                <c:if test="${not empty rfq.deliveryInstructions}">
                                    <p><span class="info-label">Yêu cầu đặc biệt:</span> ${rfq.deliveryInstructions}</p>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>

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
                                            <strong>${item.productName}</strong>
                                            <c:if test="${not empty item.sku}"><br><small class="text-muted">SKU: ${item.sku}</small></c:if>
                                        </td>
                                        <td class="text-center">${item.quantity}</td>
                                        <td class="text-right">
                                            <c:if test="${item.costPrice != null}">
                                                <fmt:formatNumber value="${item.costPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                            </c:if>
                                        </td>
                                        <c:if test="${rfq.status == 'Quoted' || rfq.status == 'QuoteAccepted' || rfq.status == 'Completed'}">
                                            <td class="text-center">${item.profitMarginPercent}%</td>
                                            <td class="text-right"><fmt:formatNumber value="${item.unitPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                            <td class="text-right"><fmt:formatNumber value="${item.subtotal}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                        </c:if>
                                    </tr>
                                </c:forEach>
                            </tbody>
                            <c:if test="${rfq.totalAmount != null && rfq.totalAmount > 0}">
                                <tfoot class="table-light">
                                    <tr>
                                        <td colspan="5" class="text-end"><strong>Tạm tính:</strong></td>
                                        <td class="text-right"><fmt:formatNumber value="${rfq.subtotalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                    </tr>
                                    <tr>
                                        <td colspan="5" class="text-end">Phí vận chuyển:</td>
                                        <td class="text-right"><fmt:formatNumber value="${rfq.shippingFee}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                    </tr>
                                    <tr>
                                        <td colspan="5" class="text-end">Thuế:</td>
                                        <td class="text-right"><fmt:formatNumber value="${rfq.taxAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                    </tr>
                                    <tr class="table-primary">
                                        <td colspan="5" class="text-end"><strong>TỔNG CỘNG:</strong></td>
                                        <td class="text-right"><strong><fmt:formatNumber value="${rfq.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></strong></td>
                                    </tr>
                                </tfoot>
                            </c:if>
                        </table>
                    </div>
                </div>

                <!-- Actions -->
                <div class="card mb-4">
                    <div class="card-header"><h5 class="mb-0"><i class="fas fa-cogs"></i> Hành Động</h5></div>
                    <div class="card-body">
                        <c:if test="${rfq.status == 'Pending'}">
                            <form action="${pageContext.request.contextPath}/admin/rfq/assign-to-me" method="POST" class="d-inline">
                                <input type="hidden" name="id" value="${rfq.rfqID}">
                                <button type="submit" class="btn btn-primary"><i class="fas fa-user-check"></i> Nhận Xử Lý</button>
                            </form>
                        </c:if>

                        <c:if test="${rfq.status == 'Reviewing' || rfq.status == 'DateAccepted'}">
                            <button type="button" class="btn btn-warning" data-bs-toggle="modal" data-bs-target="#proposeDateModal">
                                <i class="fas fa-calendar-alt"></i> Đề Xuất Ngày Mới
                            </button>
                            <a href="${pageContext.request.contextPath}/admin/rfq/quotation-form?rfqId=${rfq.rfqID}" class="btn btn-success">
                                <i class="fas fa-file-invoice-dollar"></i> Tạo Báo Giá
                            </a>
                        </c:if>

                        <c:if test="${rfq.status == 'DateProposed'}">
                            <div class="alert alert-info mt-3">
                                <i class="fas fa-hourglass-half"></i> Đang chờ khách hàng phản hồi về ngày giao hàng mới.
                            </div>
                        </c:if>

                        <c:if test="${rfq.status == 'Quoted'}">
                            <div class="alert alert-info mt-3">
                                <i class="fas fa-hourglass-half"></i> Đang chờ khách hàng phản hồi báo giá.
                            </div>
                        </c:if>

                        <a href="${pageContext.request.contextPath}/admin/rfq" class="btn btn-secondary">
                            <i class="fas fa-arrow-left"></i> Quay Lại
                        </a>
                    </div>
                </div>
            </div>

            <!-- Sidebar -->
            <div class="col-lg-4">
                <!-- Notes -->
                <c:if test="${not empty rfq.customerNotes}">
                    <div class="card mb-4">
                        <div class="card-header"><h6 class="mb-0"><i class="fas fa-comment"></i> Ghi Chú Khách Hàng</h6></div>
                        <div class="card-body">${rfq.customerNotes}</div>
                    </div>
                </c:if>

                <!-- Timeline -->
                <div class="card">
                    <div class="card-header"><h6 class="mb-0"><i class="fas fa-history"></i> Lịch Sử</h6></div>
                    <div class="card-body">
                        <div class="timeline">
                            <c:forEach var="h" items="${rfq.history}">
                                <div class="timeline-item">
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

    <!-- Propose Date Modal -->
    <div class="modal fade" id="proposeDateModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/admin/rfq/propose-date" method="POST">
                    <input type="hidden" name="rfqId" value="${rfq.rfqID}">
                    <div class="modal-header">
                        <h5 class="modal-title">Đề Xuất Ngày Giao Hàng Mới</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">Ngày khách yêu cầu</label>
                            <input type="text" class="form-control" value="<fmt:formatDate value="${rfq.requestedDeliveryDate}" pattern="dd/MM/yyyy"/>" disabled>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Ngày đề xuất mới <span class="text-danger">*</span></label>
                            <input type="date" class="form-control" name="proposedDate" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Lý do <span class="text-danger">*</span></label>
                            <textarea class="form-control" name="reason" rows="3" required placeholder="VD: Số lượng lớn, cần thời gian chuẩn bị..."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-warning">Gửi Đề Xuất</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
