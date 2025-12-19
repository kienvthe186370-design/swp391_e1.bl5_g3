<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi Tiết Báo Giá ${quotation.quotationCode} - Pickleball Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" type="text/css">
    <style>
        .status-badge { font-size: 1rem; padding: 8px 16px; border-radius: 20px; }
        .status-sent { background: #007bff; color: #fff; }
        .status-customercountered { background: #ffc107; color: #000; }
        .status-sellercountered { background: #17a2b8; color: #fff; }
        .status-accepted { background: #5dade2; color: #fff; } /* Xanh biển - chờ thanh toán */
        .status-paid { background: #28a745; color: #fff; } /* Xanh lá - hoàn thành */
        .status-rejected { background: #dc3545; color: #fff; }
        .status-expired { background: #6c757d; color: #fff; }
        .info-label { font-weight: 600; color: #666; }
        .history-list { list-style: none; padding: 0; margin: 0; }
        .history-item { position: relative; padding: 12px 0 12px 30px; border-bottom: 1px solid #eee; }
        .history-item:last-child { border-bottom: none; }
        .history-item::before { content: ''; width: 12px; height: 12px; background: #007bff; border-radius: 50%; position: absolute; left: 0; top: 16px; }
        .history-item.rejected::before { background: #dc3545; }
        .history-item.accepted::before, .history-item.paid::before { background: #28a745; }
        .history-item.counter::before { background: #ffc107; }

        .price-display { font-size: 1.5rem; font-weight: bold; }
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
                            <a href="${pageContext.request.contextPath}/quotation/list">Báo giá</a>
                            <span>${quotation.quotationCode}</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="spad">
        <div class="container">
            <!-- Alert Messages -->
            <c:if test="${param.success == 'accepted'}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fa fa-check-circle"></i> Bạn đã chấp nhận báo giá. Vui lòng thanh toán để hoàn tất.
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                </div>
            </c:if>
            <c:if test="${param.success == 'countered'}">
                <div class="alert alert-info alert-dismissible fade show" role="alert">
                    <i class="fa fa-comments"></i> Đã gửi đề xuất giá của bạn. Vui lòng chờ Seller phản hồi.
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                </div>
            </c:if>
            <c:if test="${param.success == 'rejected'}">
                <div class="alert alert-warning alert-dismissible fade show" role="alert">
                    <i class="fa fa-info-circle"></i> Bạn đã từ chối báo giá này.
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                </div>
            </c:if>
            <c:if test="${param.error == 'cannot_accept'}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fa fa-exclamation-circle"></i> Không thể chấp nhận báo giá ở trạng thái hiện tại.
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                </div>
            </c:if>

            <c:if test="${param.error == 'expired'}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fa fa-exclamation-circle"></i> Báo giá đã hết hạn.
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                </div>
            </c:if>

            <div class="row">
                <!-- Main Content -->
                <div class="col-lg-8">
                    <!-- Quotation Info -->
                    <div class="card mb-4">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h5 class="mb-0"><i class="fa fa-file-text-o"></i> ${quotation.quotationCode}</h5>
                            <span class="badge status-badge status-${quotation.status.toLowerCase()}">
                                ${quotation.statusDisplayName}
                            </span>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <c:if test="${quotation.rfq != null}">
                                        <p><span class="info-label">RFQ:</span> 
                                            <a href="${pageContext.request.contextPath}/rfq/detail?id=${quotation.rfqID}">${quotation.rfq.rfqCode}</a>
                                        </p>
                                        <p><span class="info-label">Công ty:</span> ${quotation.rfq.companyName}</p>
                                        <p><span class="info-label">Người liên hệ:</span> ${quotation.rfq.contactPerson}</p>
                                        <p><span class="info-label">Điện thoại:</span> ${quotation.rfq.contactPhone}</p>
                                    </c:if>
                                </div>
                                <div class="col-md-6">
                                    <p><span class="info-label">Ngày gửi báo giá:</span> <fmt:formatDate value="${quotation.quotationSentDate}" pattern="dd/MM/yyyy HH:mm"/></p>
                                    <p><span class="info-label">Thanh toán:</span> 
                                        <c:choose>
                                            <c:when test="${quotation.paymentMethod == 'BankTransfer'}">Chuyển khoản (VNPay)</c:when>
                                            <c:otherwise>${quotation.paymentMethod}</c:otherwise>
                                        </c:choose>
                                    </p>

                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Shipping Info -->
                    <c:if test="${not empty quotation.shippingCarrierName}">
                    <div class="card mb-4">
                        <div class="card-header"><h5 class="mb-0"><i class="fa fa-truck"></i> Vận Chuyển</h5></div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <p><span class="info-label">Đơn vị vận chuyển:</span> <strong>${quotation.shippingCarrierName}</strong></p>
                                    <p><span class="info-label">Dịch vụ:</span> ${quotation.shippingServiceName}</p>
                                </div>
                                <div class="col-md-6">
                                    <p><span class="info-label">Phí vận chuyển:</span> 
                                        <span class="text-primary"><fmt:formatNumber value="${quotation.shippingFee}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span>
                                    </p>
                                    <p><span class="info-label">Thời gian giao:</span> 
                                        <span class="badge badge-success">${quotation.estimatedDeliveryDays} ngày</span>
                                    </p>
                                </div>
                            </div>
                            <c:if test="${quotation.rfq != null && not empty quotation.rfq.deliveryAddress}">
                                <p><span class="info-label">Địa chỉ giao:</span> ${quotation.rfq.deliveryAddress}</p>
                            </c:if>
                        </div>
                    </div>
                    </c:if>

                    <!-- Price Negotiation Section -->
                    <c:if test="${quotation.status == 'Sent' || quotation.status == 'SellerCountered'}">
                        <div class="card mb-4 border-primary">
                            <div class="card-header bg-primary text-white">
                                <i class="fa fa-gavel"></i> Xử Lý Báo Giá
                            </div>
                            <div class="card-body">
                                <!-- Current Price -->
                                <div class="text-center mb-4">
                                    <p class="mb-1">Giá báo giá hiện tại:</p>
                                    <h3 class="text-primary price-display">
                                        <c:choose>
                                            <c:when test="${quotation.sellerCounterPrice != null}">
                                                <fmt:formatNumber value="${quotation.sellerCounterPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                            </c:when>
                                            <c:otherwise>
                                                <fmt:formatNumber value="${quotation.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                            </c:otherwise>
                                        </c:choose>
                                    </h3>
                                    <c:if test="${quotation.status == 'SellerCountered' && not empty quotation.sellerCounterNote}">
                                        <p class="text-muted"><i class="fa fa-comment"></i> Ghi chú từ Seller: ${quotation.sellerCounterNote}</p>
                                    </c:if>
                                </div>

                                <!-- Action Buttons -->
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <form action="${pageContext.request.contextPath}/quotation/accept" method="POST">
                                            <input type="hidden" name="quotationId" value="${quotation.quotationID}">
                                            <button type="submit" class="btn btn-success btn-lg w-100" ${quotation.expired ? 'disabled' : ''}>
                                                <i class="fa fa-check"></i> Chấp Nhận Giá Này
                                            </button>
                                        </form>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <button type="button" class="btn btn-outline-danger btn-lg w-100" data-toggle="modal" data-target="#rejectModal">
                                            <i class="fa fa-times"></i> Từ Chối
                                        </button>
                                    </div>
                                </div>


                            </div>
                        </div>
                    </c:if>

                    <!-- Accepted - Payment -->
                    <c:if test="${quotation.status == 'Accepted'}">
                        <div class="card mb-4 border-success">
                            <div class="card-header bg-success text-white">
                                <i class="fa fa-credit-card"></i> Thanh Toán
                            </div>
                            <div class="card-body">
                                <p class="mb-3">Tổng giá trị cần thanh toán: 
                                    <strong class="text-success price-display">
                                        <fmt:formatNumber value="${quotation.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </strong>
                                </p>
                                <form action="${pageContext.request.contextPath}/quotation/payment" method="POST">
                                    <input type="hidden" name="quotationId" value="${quotation.quotationID}">
                                    <button type="submit" class="btn btn-success btn-lg">
                                        <i class="fa fa-credit-card"></i> Thanh Toán Ngay (VNPay)
                                    </button>
                                </form>
                            </div>
                        </div>
                    </c:if>

                    <!-- Paid -->
                    <c:if test="${quotation.status == 'Paid'}">
                        <div class="card mb-4 border-success">
                            <div class="card-header bg-success text-white">
                                <i class="fa fa-check-circle"></i> Đã Thanh Toán Thành Công
                            </div>
                            <div class="card-body">
                                <p class="mb-0"><i class="fa fa-info-circle"></i> Đơn hàng của bạn đã được tạo và đang được xử lý.</p>
                            </div>
                        </div>
                    </c:if>

                    <!-- Rejected -->
                    <c:if test="${quotation.status == 'Rejected'}">
                        <div class="card mb-4 border-danger">
                            <div class="card-header bg-danger text-white">
                                <i class="fa fa-times-circle"></i> Báo Giá Đã Bị Từ Chối
                            </div>
                            <div class="card-body">
                                <c:if test="${not empty quotation.rejectionReason}">
                                    <p><strong>Lý do:</strong> ${quotation.rejectionReason}</p>
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
                                    <c:forEach var="item" items="${quotation.items}">
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
                                        <td class="text-right"><fmt:formatNumber value="${quotation.subtotalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                    </tr>
                                    <tr>
                                        <td colspan="3" class="text-right">Phí vận chuyển:</td>
                                        <td class="text-right"><fmt:formatNumber value="${quotation.shippingFee}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                    </tr>
                                    <tr>
                                        <td colspan="3" class="text-right">Thuế VAT:</td>
                                        <td class="text-right"><fmt:formatNumber value="${quotation.taxAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                    </tr>
                                    <tr class="table-primary">
                                        <td colspan="3" class="text-right"><strong>TỔNG CỘNG:</strong></td>
                                        <td class="text-right"><strong><fmt:formatNumber value="${quotation.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></strong></td>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>
                    </div>

                    <!-- Terms -->
                    <c:if test="${not empty quotation.quotationTerms || not empty quotation.warrantyTerms}">
                    <div class="card mb-4">
                        <div class="card-header"><h5 class="mb-0"><i class="fa fa-file-text"></i> Điều Khoản</h5></div>
                        <div class="card-body">
                            <c:if test="${not empty quotation.warrantyTerms}">
                                <p><span class="info-label">Bảo hành:</span> ${quotation.warrantyTerms}</p>
                            </c:if>
                            <c:if test="${not empty quotation.quotationTerms}">
                                <p><span class="info-label">Điều khoản khác:</span></p>
                                <pre style="white-space: pre-wrap; font-family: inherit;">${quotation.quotationTerms}</pre>
                            </c:if>
                        </div>
                    </div>
                    </c:if>

                    <!-- Back button -->
                    <a href="${pageContext.request.contextPath}/quotation/list" class="btn btn-secondary">
                        <i class="fa fa-arrow-left"></i> Quay lại danh sách
                    </a>
                </div>

                <!-- Sidebar -->
                <div class="col-lg-4">
                    <!-- Lịch sử đã được ẩn theo yêu cầu -->
                </div>
            </div>
        </div>
    </section>

    <!-- Reject Modal -->
    <div class="modal fade" id="rejectModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/quotation/reject" method="POST" onsubmit="return validateRejectForm()">
                    <input type="hidden" name="quotationId" value="${quotation.quotationID}">
                    <div class="modal-header">
                        <h5 class="modal-title">Từ Chối Báo Giá</h5>
                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                    </div>
                    <div class="modal-body">
                        <div class="form-group">
                            <label>Lý do từ chối <span class="text-danger">*</span></label>
                            <textarea class="form-control" name="reason" id="rejectReason" rows="3" maxlength="500" required 
                                      placeholder="Vui lòng cho biết lý do từ chối..."></textarea>
                            <small class="text-muted"><span id="rejectReasonCount">0</span>/500 ký tự</small>
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
    <script src="${pageContext.request.contextPath}/js/main.js"></script>
    <script>
        // Hide preloader immediately when DOM is ready
        $(document).ready(function() {
            $(".loader").fadeOut();
            $("#preloder").delay(100).fadeOut("slow");
        });
        
        // Character count for reject reason
        var rejectReasonEl = document.getElementById('rejectReason');
        if (rejectReasonEl) {
            rejectReasonEl.addEventListener('input', function() {
                // Limit to 500 characters
                if (this.value.length > 500) {
                    this.value = this.value.substring(0, 500);
                }
                document.getElementById('rejectReasonCount').textContent = this.value.length;
            });
            rejectReasonEl.addEventListener('blur', function() {
                this.value = this.value.trim();
                document.getElementById('rejectReasonCount').textContent = this.value.length;
            });
        }
        
        function validateRejectForm() {
            var reasonEl = document.getElementById('rejectReason');
            var reason = reasonEl.value.trim();
            if (!reason) {
                alert('Vui lòng nhập lý do từ chối');
                reasonEl.focus();
                return false;
            }
            if (reason.length < 5) {
                alert('Lý do từ chối phải có ít nhất 5 ký tự');
                reasonEl.focus();
                return false;
            }
            reasonEl.value = reason; // Set trimmed value
            return true;
        }
        
        function validateCounterForm() {
            var priceEl = document.getElementById('counterPrice');
            if (!priceEl) return true;
            
            // Sanitize - only numbers
            var price = priceEl.value.replace(/[^0-9]/g, '');
            priceEl.value = price;
            
            if (!price || parseInt(price) <= 0) {
                alert('Vui lòng nhập giá đề xuất hợp lệ (số dương)');
                priceEl.focus();
                return false;
            }
            
            // Check minimum price
            if (parseInt(price) < 1000) {
                alert('Giá đề xuất phải lớn hơn 1,000₫');
                priceEl.focus();
                return false;
            }
            
            return true;
        }
        
        // Sanitize counter price input - only allow numbers
        $(document).ready(function() {
            var counterPriceInput = document.getElementById('counterPrice');
            if (counterPriceInput) {
                counterPriceInput.addEventListener('input', function() {
                    this.value = this.value.replace(/[^0-9]/g, '');
                });
                counterPriceInput.addEventListener('blur', function() {
                    this.value = this.value.trim();
                });
            }
            
            // Limit note length for counter form
            var noteInput = document.querySelector('input[name="note"]');
            if (noteInput) {
                noteInput.addEventListener('input', function() {
                    if (this.value.length > 100) {
                        this.value = this.value.substring(0, 100);
                    }
                });
                noteInput.addEventListener('blur', function() {
                    this.value = this.value.trim();
                });
            }
        });
    </script>
</body>
</html>
