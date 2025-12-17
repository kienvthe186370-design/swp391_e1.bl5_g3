<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:if test="${empty sessionScope.customer}">
    <c:redirect url="/login"/>
</c:if>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết yêu cầu hoàn tiền - Pickleball Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" type="text/css">
    <style>
        .status-badge { padding: 8px 16px; border-radius: 20px; font-size: 14px; font-weight: 600; }
        .status-pending { background: #fff3cd; color: #856404; }
        .status-approved { background: #d4edda; color: #155724; }
        .status-rejected { background: #f8d7da; color: #721c24; }
        .status-completed { background: #cce5ff; color: #004085; }
        .info-card { background: #fff; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); padding: 20px; margin-bottom: 20px; }
        .info-card h5 { border-bottom: 1px solid #e5e5e5; padding-bottom: 10px; margin-bottom: 15px; }
        .refund-item { display: flex; align-items: center; padding: 15px 0; border-bottom: 1px solid #f0f0f0; }
        .refund-item:last-child { border-bottom: none; }
        .refund-item img { width: 70px; height: 70px; object-fit: cover; border-radius: 4px; margin-right: 15px; }
        .media-gallery img { width: 100px; height: 100px; object-fit: cover; border-radius: 8px; cursor: pointer; margin: 5px; }
        .timeline { position: relative; padding-left: 30px; }
        .timeline::before { content: ''; position: absolute; left: 10px; top: 0; bottom: 0; width: 2px; background: #dee2e6; }
        .timeline-item { position: relative; padding-bottom: 20px; }
        .timeline-item::before { content: ''; position: absolute; left: -24px; top: 5px; width: 12px; height: 12px; border-radius: 50%; background: #007bff; border: 2px solid #fff; }
    </style>
</head>
<body>
    <%@include file="../header.jsp" %>
    
    <section class="breadcrumb-option">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="breadcrumb__text">
                        <h4>Chi tiết yêu cầu hoàn tiền</h4>
                        <div class="breadcrumb__links">
                            <a href="${pageContext.request.contextPath}/Home">Trang chủ</a>
                            <a href="${pageContext.request.contextPath}/customer/refund">Yêu cầu hoàn tiền</a>
                            <span>#${refundRequest.refundRequestID}</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    
    <section class="spad">
        <div class="container">
            <div class="row">
                <div class="col-lg-8">
                    <div class="info-card">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h5 class="mb-0 border-0 pb-0">Yêu cầu hoàn tiền #${refundRequest.refundRequestID}</h5>
                            <c:choose>
                                <c:when test="${refundRequest.refundStatus == 'Pending'}">
                                    <span class="status-badge status-pending">Đang chờ xử lý</span>
                                </c:when>
                                <c:when test="${refundRequest.refundStatus == 'Approved'}">
                                    <span class="status-badge status-approved">Đã duyệt</span>
                                </c:when>
                                <c:when test="${refundRequest.refundStatus == 'Rejected'}">
                                    <span class="status-badge status-rejected">Từ chối</span>
                                </c:when>
                                <c:when test="${refundRequest.refundStatus == 'Completed'}">
                                    <span class="status-badge status-completed">Hoàn thành</span>
                                </c:when>
                            </c:choose>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <small class="text-muted">Đơn hàng</small>
                                <p class="mb-0 font-weight-bold">
                                    <a href="${pageContext.request.contextPath}/customer/order-detail?id=${refundRequest.orderID}">
                                        ${refundRequest.order.orderCode}
                                    </a>
                                </p>
                            </div>
                            <div class="col-md-6">
                                <small class="text-muted">Ngày yêu cầu</small>
                                <p class="mb-0"><fmt:formatDate value="${refundRequest.requestDate}" pattern="dd/MM/yyyy HH:mm"/></p>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <small class="text-muted">Lý do hoàn tiền</small>
                            <p class="mb-0">${refundRequest.refundReason}</p>
                        </div>
                        
                        <c:if test="${not empty refundRequest.adminNotes}">
                            <div class="alert ${refundRequest.refundStatus == 'Rejected' ? 'alert-danger' : 'alert-info'} mb-0">
                                <strong>Phản hồi từ shop:</strong><br>${refundRequest.adminNotes}
                            </div>
                        </c:if>
                    </div>
                    
                    <div class="info-card">
                        <h5><i class="fa fa-shopping-bag"></i> Sản phẩm yêu cầu hoàn</h5>
                        <c:forEach var="item" items="${refundRequest.refundItems}">
                            <div class="refund-item">
                                <img src="${pageContext.request.contextPath}${item.orderDetail.productImage}" 
                                     onerror="this.src='${pageContext.request.contextPath}/img/product/product-placeholder.jpg'">
                                <div class="flex-grow-1">
                                    <h6 class="mb-1">${item.orderDetail.productName}</h6>
                                    <small class="text-muted">SKU: ${item.orderDetail.sku}</small>
                                    <div class="mt-1">
                                        <span class="text-danger font-weight-bold">
                                            <fmt:formatNumber value="${item.orderDetail.unitPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                        </span>
                                        <span class="text-muted">x ${item.quantity}</span>
                                    </div>
                                    <c:if test="${not empty item.itemReason}">
                                        <small class="text-muted d-block mt-1"><i class="fa fa-comment"></i> ${item.itemReason}</small>
                                    </c:if>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                    
                    <c:if test="${not empty refundRequest.refundMedia}">
                        <div class="info-card">
                            <h5><i class="fa fa-camera"></i> Hình ảnh minh chứng</h5>
                            <div class="media-gallery">
                                <c:forEach var="media" items="${refundRequest.refundMedia}">
                                    <img src="${pageContext.request.contextPath}${media.mediaURL}" onclick="window.open(this.src)">
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>
                </div>
                
                <div class="col-lg-4">
                    <div class="info-card">
                        <h5><i class="fa fa-file-text-o"></i> Tóm tắt</h5>
                        <div class="d-flex justify-content-between mb-2">
                            <span>Số tiền hoàn:</span>
                            <strong class="text-danger">
                                <fmt:formatNumber value="${refundRequest.refundAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                            </strong>
                        </div>
                        
                        <c:if test="${refundRequest.refundStatus == 'Approved'}">
                            <div class="alert alert-success py-2 mt-3">
                                <small><i class="fa fa-check-circle"></i> Yêu cầu đã được duyệt. Tiền sẽ được hoàn trong 3-5 ngày làm việc.</small>
                            </div>
                        </c:if>
                        
                        <c:if test="${refundRequest.refundStatus == 'Completed'}">
                            <div class="alert alert-info py-2 mt-3">
                                <small><i class="fa fa-check-circle"></i> Hoàn tiền đã hoàn tất vào ngày <fmt:formatDate value="${refundRequest.processedDate}" pattern="dd/MM/yyyy"/></small>
                            </div>
                        </c:if>
                    </div>
                    
                    <div class="info-card">
                        <h5><i class="fa fa-history"></i> Lịch sử xử lý</h5>
                        <div class="timeline">
                            <div class="timeline-item">
                                <strong>Gửi yêu cầu</strong>
                                <p class="text-muted mb-0"><small><fmt:formatDate value="${refundRequest.requestDate}" pattern="dd/MM/yyyy HH:mm"/></small></p>
                            </div>
                            <c:if test="${refundRequest.refundStatus != 'Pending'}">
                                <div class="timeline-item">
                                    <strong>
                                        <c:choose>
                                            <c:when test="${refundRequest.refundStatus == 'Approved' || refundRequest.refundStatus == 'Completed'}">Đã duyệt</c:when>
                                            <c:when test="${refundRequest.refundStatus == 'Rejected'}">Từ chối</c:when>
                                        </c:choose>
                                    </strong>
                                    <c:if test="${not empty refundRequest.processedDate}">
                                        <p class="text-muted mb-0"><small><fmt:formatDate value="${refundRequest.processedDate}" pattern="dd/MM/yyyy HH:mm"/></small></p>
                                    </c:if>
                                </div>
                            </c:if>
                            <c:if test="${refundRequest.refundStatus == 'Completed'}">
                                <div class="timeline-item">
                                    <strong>Hoàn tiền hoàn tất</strong>
                                    <p class="text-muted mb-0"><small><fmt:formatDate value="${refundRequest.processedDate}" pattern="dd/MM/yyyy HH:mm"/></small></p>
                                </div>
                            </c:if>
                        </div>
                    </div>
                    
                    <a href="${pageContext.request.contextPath}/customer/refund" class="btn btn-secondary btn-block">
                        <i class="fa fa-arrow-left"></i> Quay lại danh sách
                    </a>
                </div>
            </div>
        </div>
    </section>
    
    <%@include file="../footer.jsp"%>
    <script src="${pageContext.request.contextPath}/js/jquery-3.3.1.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/bootstrap.min.js"></script>
    <script>
        $(window).on('load', function() {
            $(".loader").fadeOut();
            $("#preloder").delay(200).fadeOut("slow");
        });
        setTimeout(function() {
            $(".loader").fadeOut();
            $("#preloder").fadeOut("slow");
        }, 2000);
    </script>
</body>
</html>