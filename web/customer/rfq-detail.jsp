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
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/css/bootstrap-datepicker.min.css">
    <style>
        .status-badge { font-size: 1rem; padding: 8px 16px; border-radius: 4px; }
        .bg-pending { background: #ffc107 !important; color: #000 !important; }
        .bg-reviewing { background: #17a2b8 !important; color: #fff !important; }
        .bg-dateproposed { background: #fd7e14 !important; color: #fff !important; }
        .bg-datecountered { background: #e83e8c !important; color: #fff !important; }
        .bg-dateaccepted { background: #20c997 !important; color: #fff !important; }
        .bg-quotationcreated { background: #007bff !important; color: #fff !important; }
        .bg-completed { background: #28a745 !important; color: #fff !important; }
        .bg-cancelled { background: #6c757d !important; color: #fff !important; }
        .history-list { padding-left: 0; margin-left: 0; list-style: none; }
        .history-item { position: relative; padding: 10px 0 15px 30px; border-bottom: 1px solid #eee; }
        .history-item:last-child { border-bottom: none; }
        .history-item::before { content: ''; width: 12px; height: 12px; background: #007bff; border-radius: 50%; position: absolute; left: 0; top: 15px; }
        .history-item.rejected::before { background: #dc3545; }
        .history-item.completed::before { background: #28a745; }
        .info-label { font-weight: 600; color: #666; }
        .negotiation-info { background: #f8f9fa; border-radius: 8px; padding: 15px; }
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
            <!-- Success/Error Messages -->
            <c:if test="${param.success == 'created'}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fa fa-check-circle"></i> Yêu cầu báo giá đã được gửi thành công! Seller sẽ xử lý trong thời gian sớm nhất.
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                </div>
            </c:if>
            <c:if test="${param.success == 'date_accepted'}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fa fa-check-circle"></i> Bạn đã chấp nhận ngày giao hàng. Seller sẽ tạo báo giá cho bạn.
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                </div>
            </c:if>
            <c:if test="${param.success == 'date_countered'}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fa fa-check-circle"></i> Đã gửi đề xuất ngày giao mới cho Seller.
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                </div>
            </c:if>
            <c:if test="${param.success == 'cancelled'}">
                <div class="alert alert-warning alert-dismissible fade show" role="alert">
                    <i class="fa fa-info-circle"></i> Yêu cầu báo giá đã được hủy.
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
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
                                    <c:if test="${not empty rfq.companyName}">
                                        <p><span class="info-label">Công ty:</span> ${rfq.companyName}</p>
                                    </c:if>
                                    <c:if test="${not empty rfq.taxID}">
                                        <p><span class="info-label">Mã số thuế:</span> ${rfq.taxID}</p>
                                    </c:if>
                                    <c:if test="${not empty rfq.businessType}">
                                        <p><span class="info-label">Loại hình:</span> 
                                            <c:choose>
                                                <c:when test="${rfq.businessType == 'Retailer'}">Bán lẻ</c:when>
                                                <c:when test="${rfq.businessType == 'Distributor'}">Nhà phân phối</c:when>
                                                <c:otherwise>${rfq.businessType}</c:otherwise>
                                            </c:choose>
                                        </p>
                                    </c:if>
                                    <p><span class="info-label">Người liên hệ:</span> ${rfq.contactPerson}</p>
                                    <p><span class="info-label">Điện thoại:</span> ${rfq.contactPhone}</p>
                                    <p><span class="info-label">Email:</span> ${rfq.contactEmail}</p>
                                </div>
                                <div class="col-md-6">
                                    <p><span class="info-label">Ngày tạo:</span> <fmt:formatDate value="${rfq.createdDate}" pattern="dd/MM/yyyy HH:mm"/></p>
                                    <p><span class="info-label">Ngày yêu cầu giao:</span> <fmt:formatDate value="${rfq.requestedDeliveryDate}" pattern="dd/MM/yyyy"/></p>
                                    <p><span class="info-label">Địa chỉ giao:</span> ${rfq.deliveryAddress}</p>
                                    <c:if test="${not empty rfq.assignedName}">
                                        <p><span class="info-label">Người xử lý:</span> ${rfq.assignedName}</p>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Date Negotiation Section -->
                    <c:if test="${rfq.status == 'DateProposed' || rfq.status == 'DateCountered' || rfq.status == 'DateAccepted'}">
                        <div class="card mb-4 border-${rfq.status == 'DateProposed' ? 'warning' : (rfq.status == 'DateAccepted' ? 'success' : 'info')}">
                            <div class="card-header bg-${rfq.status == 'DateProposed' ? 'warning text-dark' : (rfq.status == 'DateAccepted' ? 'success text-white' : 'info text-white')}">
                                <i class="fa fa-calendar"></i> Thương Lượng Ngày Giao
                                <span class="badge badge-light float-right">${rfq.dateNegotiationCount}/${rfq.maxDateNegotiationCount} lần</span>
                            </div>
                            <div class="card-body">
                                <div class="negotiation-info mb-3">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <p class="mb-1"><strong>Ngày bạn yêu cầu:</strong></p>
                                            <p class="text-primary"><fmt:formatDate value="${rfq.requestedDeliveryDate}" pattern="dd/MM/yyyy"/></p>
                                        </div>
                                        <c:if test="${rfq.proposedDeliveryDate != null}">
                                            <div class="col-md-6">
                                                <p class="mb-1"><strong>Ngày Seller đề xuất:</strong></p>
                                                <p class="text-warning"><fmt:formatDate value="${rfq.proposedDeliveryDate}" pattern="dd/MM/yyyy"/></p>
                                                <c:if test="${not empty rfq.dateChangeReason}">
                                                    <small class="text-muted">Lý do: ${rfq.dateChangeReason}</small>
                                                </c:if>
                                            </div>
                                        </c:if>
                                    </div>
                                    <c:if test="${rfq.customerCounterDate != null}">
                                        <hr>
                                        <p class="mb-1"><strong>Ngày bạn đề xuất:</strong></p>
                                        <p class="text-info"><fmt:formatDate value="${rfq.customerCounterDate}" pattern="dd/MM/yyyy"/></p>
                                        <c:if test="${not empty rfq.customerCounterDateNote}">
                                            <small class="text-muted">Ghi chú: ${rfq.customerCounterDateNote}</small>
                                        </c:if>
                                    </c:if>
                                </div>

                                <!-- Actions for DateProposed -->
                                <c:if test="${rfq.status == 'DateProposed'}">
                                    <div class="alert alert-warning">
                                        <i class="fa fa-exclamation-triangle"></i> Seller đề xuất ngày giao mới. Vui lòng phản hồi.
                                    </div>
                                    <div class="d-flex flex-wrap gap-2">
                                        <form action="${pageContext.request.contextPath}/rfq/accept-date" method="POST" class="mr-2 mb-2">
                                            <input type="hidden" name="rfqId" value="${rfq.rfqID}">
                                            <button type="submit" class="btn btn-success"><i class="fa fa-check"></i> Chấp Nhận Ngày Này</button>
                                        </form>
                                        <c:if test="${rfq.canCustomerCounterDate()}">
                                            <button type="button" class="btn btn-info mr-2 mb-2" data-toggle="modal" data-target="#counterDateModal">
                                                <i class="fa fa-calendar-plus-o"></i> Đề Xuất Ngày Khác
                                            </button>
                                        </c:if>
                                        <button type="button" class="btn btn-outline-danger mb-2" data-toggle="modal" data-target="#cancelRFQModal">
                                            <i class="fa fa-times"></i> Hủy RFQ
                                        </button>
                                    </div>
                                    <c:if test="${rfq.remainingDateNegotiations == 0}">
                                        <div class="alert alert-danger mt-2">
                                            <i class="fa fa-warning"></i> Đã hết lượt thương lượng. Vui lòng chấp nhận hoặc hủy RFQ.
                                        </div>
                                    </c:if>
                                </c:if>

                                <!-- Info for DateAccepted -->
                                <c:if test="${rfq.status == 'DateAccepted'}">
                                    <div class="alert alert-success">
                                        <i class="fa fa-check-circle"></i> Ngày giao đã được thống nhất: <strong><fmt:formatDate value="${rfq.finalDeliveryDate}" pattern="dd/MM/yyyy"/></strong>
                                        <br><small>Seller sẽ tạo báo giá cho bạn.</small>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </c:if>

                    <!-- Quotation Created Alert -->
                    <c:if test="${rfq.status == 'QuotationCreated' && not empty rfq.quotation}">
                        <div class="card mb-4 border-primary">
                            <div class="card-header bg-primary text-white">
                                <i class="fa fa-file-invoice-dollar"></i> Đã Có Báo Giá
                            </div>
                            <div class="card-body">
                                <p>Seller đã tạo báo giá cho yêu cầu của bạn.</p>
                                <p><strong>Mã báo giá:</strong> ${rfq.quotation.quotationCode}</p>
                                <p><strong>Tổng tiền:</strong> <span class="text-primary h5"><fmt:formatNumber value="${rfq.quotation.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span></p>
                                <a href="${pageContext.request.contextPath}/quotation/detail?id=${rfq.quotation.quotationID}" class="btn btn-primary">
                                    <i class="fa fa-eye"></i> Xem Chi Tiết Báo Giá
                                </a>
                            </div>
                        </div>
                    </c:if>

                    <!-- Products -->
                    <div class="card mb-4">
                        <div class="card-header"><h5 class="mb-0"><i class="fa fa-cube"></i> Sản Phẩm Yêu Cầu</h5></div>
                        <div class="card-body p-0">
                            <table class="table table-striped mb-0">
                                <thead>
                                    <tr>
                                        <th>Sản phẩm</th>
                                        <th class="text-center">Số lượng</th>
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
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Customer Notes -->
                    <c:if test="${not empty rfq.customerNotes}">
                        <div class="card mb-4">
                            <div class="card-header"><h5 class="mb-0"><i class="fa fa-sticky-note"></i> Ghi Chú Của Bạn</h5></div>
                            <div class="card-body">
                                <p class="mb-0">${rfq.customerNotes}</p>
                            </div>
                        </div>
                    </c:if>
                </div>

                <!-- Sidebar -->
                <div class="col-lg-4">
                    <!-- Draft Actions -->
                    <c:if test="${isDraft}">
                        <div class="card mt-3">
                            <div class="card-body">
                                <h5 class="mb-3"><i class="fa fa-paper-plane"></i> Gửi yêu cầu báo giá</h5>
                                
                                <!-- Form gửi yêu cầu -->
                                <form action="${pageContext.request.contextPath}/rfq/submit" method="POST" id="submitRfqForm">
                                    <input type="hidden" name="companyName" value="${rfq.companyName}"/>
                                    <input type="hidden" name="taxID" value="${rfq.taxID}"/>
                                    <input type="hidden" name="businessType" value="${rfq.businessType}"/>
                                    <input type="hidden" name="contactPerson" value="${rfq.contactPerson}"/>
                                    <input type="hidden" name="contactPhone" value="${rfq.contactPhone}"/>
                                    <input type="hidden" name="contactEmail" value="${rfq.contactEmail}"/>
                                    <input type="hidden" name="alternativeContact" value="${rfq.alternativeContact}"/>
                                    <input type="hidden" name="deliveryAddress" value="${rfq.deliveryAddress}"/>
                                    <input type="hidden" name="deliveryStreet" value="${rfq.deliveryStreet}"/>
                                    <input type="hidden" name="deliveryCity" value="${rfq.deliveryCity}"/>
                                    <input type="hidden" name="deliveryCityId" value="${rfq.deliveryCityId}"/>
                                    <input type="hidden" name="deliveryDistrict" value="${rfq.deliveryDistrict}"/>
                                    <input type="hidden" name="deliveryDistrictId" value="${rfq.deliveryDistrictId}"/>
                                    <input type="hidden" name="deliveryWard" value="${rfq.deliveryWard}"/>
                                    <input type="hidden" name="deliveryWardId" value="${rfq.deliveryWardId}"/>
                                    <input type="hidden" name="paymentTermsPreference" value="${rfq.paymentTermsPreference}"/>
                                    <input type="hidden" name="requestedDeliveryDate" value="<fmt:formatDate value='${rfq.requestedDeliveryDate}' pattern='yyyy-MM-dd'/>"/>
                                    <c:forEach var="item" items="${rfq.items}">
                                        <input type="hidden" name="productId" value="${item.productID}"/>
                                        <input type="hidden" name="variantId" value="${item.variantID}"/>
                                        <input type="hidden" name="quantity" value="${item.quantity}"/>
                                    </c:forEach>
                                    <button type="submit" class="btn btn-primary btn-block mb-2">
                                        <i class="fa fa-paper-plane"></i> Gửi Yêu Cầu
                                    </button>
                                </form>
                                
                                <!-- Form chỉnh sửa - quay lại form với dữ liệu đã nhập -->
                                <form action="${pageContext.request.contextPath}/rfq/form" method="POST" id="editRfqForm">
                                    <input type="hidden" name="companyName" value="${rfq.companyName}"/>
                                    <input type="hidden" name="taxID" value="${rfq.taxID}"/>
                                    <input type="hidden" name="businessType" value="${rfq.businessType}"/>
                                    <input type="hidden" name="contactPerson" value="${rfq.contactPerson}"/>
                                    <input type="hidden" name="contactPhone" value="${rfq.contactPhone}"/>
                                    <input type="hidden" name="contactEmail" value="${rfq.contactEmail}"/>
                                    <input type="hidden" name="alternativeContact" value="${rfq.alternativeContact}"/>
                                    <input type="hidden" name="deliveryAddress" value="${rfq.deliveryAddress}"/>
                                    <input type="hidden" name="deliveryStreet" value="${rfq.deliveryStreet}"/>
                                    <input type="hidden" name="deliveryCity" value="${rfq.deliveryCity}"/>
                                    <input type="hidden" name="deliveryCityId" value="${rfq.deliveryCityId}"/>
                                    <input type="hidden" name="deliveryDistrict" value="${rfq.deliveryDistrict}"/>
                                    <input type="hidden" name="deliveryDistrictId" value="${rfq.deliveryDistrictId}"/>
                                    <input type="hidden" name="deliveryWard" value="${rfq.deliveryWard}"/>
                                    <input type="hidden" name="deliveryWardId" value="${rfq.deliveryWardId}"/>
                                    <input type="hidden" name="paymentTermsPreference" value="${rfq.paymentTermsPreference}"/>
                                    <input type="hidden" name="requestedDeliveryDate" value="<fmt:formatDate value='${rfq.requestedDeliveryDate}' pattern='yyyy-MM-dd'/>"/>
                                    <c:forEach var="item" items="${rfq.items}">
                                        <input type="hidden" name="productId" value="${item.productID}"/>
                                        <input type="hidden" name="variantId" value="${item.variantID}"/>
                                        <input type="hidden" name="quantity" value="${item.quantity}"/>
                                    </c:forEach>
                                    <input type="hidden" name="editDraft" value="true"/>
                                    <button type="submit" class="btn btn-outline-secondary btn-block">
                                        <i class="fa fa-edit"></i> Chỉnh Sửa
                                    </button>
                                </form>
                            </div>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </section>

    <!-- Counter Date Modal -->
    <div class="modal fade" id="counterDateModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/rfq/counter-date" method="POST">
                    <input type="hidden" name="rfqId" value="${rfq.rfqID}">
                    <div class="modal-header">
                        <h5 class="modal-title">Đề Xuất Ngày Giao Khác</h5>
                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                    </div>
                    <div class="modal-body">
                        <div class="form-group">
                            <label>Ngày bạn muốn nhận hàng <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="counterDate" id="counterDateInput" required autocomplete="off">
                        </div>
                        <div class="form-group">
                            <label>Ghi chú</label>
                            <textarea class="form-control" name="note" rows="2" maxlength="500" placeholder="Lý do bạn muốn ngày này..."></textarea>
                        </div>
                        <div class="alert alert-info">
                            <small><i class="fa fa-info-circle"></i> Còn ${rfq.remainingDateNegotiations} lần thương lượng</small>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-info">Gửi Đề Xuất</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Cancel RFQ Modal -->
    <div class="modal fade" id="cancelRFQModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/rfq/cancel" method="POST">
                    <input type="hidden" name="rfqId" value="${rfq.rfqID}">
                    <div class="modal-header">
                        <h5 class="modal-title">Hủy Yêu Cầu Báo Giá</h5>
                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                    </div>
                    <div class="modal-body">
                        <p class="text-danger"><i class="fa fa-warning"></i> Bạn có chắc muốn hủy yêu cầu này?</p>
                        <div class="form-group">
                            <label>Lý do hủy <span class="text-danger">*</span></label>
                            <textarea class="form-control" name="reason" rows="3" maxlength="500" required placeholder="Vui lòng cho biết lý do..."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Đóng</button>
                        <button type="submit" class="btn btn-danger">Xác Nhận Hủy</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%@include file="../footer.jsp"%>
    <script src="${pageContext.request.contextPath}/js/jquery-3.3.1.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/main.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/js/bootstrap-datepicker.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/locales/bootstrap-datepicker.vi.min.js"></script>
    <script>
        $(document).ready(function() {
            // Initialize datepicker for counter date
            $('#counterDateInput').datepicker({
                format: 'dd/mm/yyyy',
                language: 'vi',
                autoclose: true,
                startDate: '+1d',
                todayHighlight: true
            });
        });
    </script>
</body>
</html>
