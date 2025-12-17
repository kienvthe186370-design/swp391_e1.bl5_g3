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
    <title>Yêu cầu hoàn tiền - Pickleball Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" type="text/css">
    <style>
        .refund-card { border: 1px solid #e0e0e0; border-radius: 8px; margin-bottom: 15px; background: #fff; transition: box-shadow 0.3s; }
        .refund-card:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
        .status-badge { padding: 5px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; }
        .status-pending { background: #fff3cd; color: #856404; }
        .status-approved { background: #d4edda; color: #155724; }
        .status-rejected { background: #f8d7da; color: #721c24; }
        .status-completed { background: #cce5ff; color: #004085; }
        .empty-state { text-align: center; padding: 60px 20px; color: #6c757d; }
        .empty-state i { font-size: 64px; margin-bottom: 20px; color: #dee2e6; }
    </style>
</head>
<body>
    <%@include file="../header.jsp" %>
    
    <section class="breadcrumb-option">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="breadcrumb__text">
                        <h4>Yêu cầu hoàn tiền</h4>
                        <div class="breadcrumb__links">
                            <a href="${pageContext.request.contextPath}/Home">Trang chủ</a>
                            <a href="${pageContext.request.contextPath}/customer/orders">Đơn hàng</a>
                            <span>Yêu cầu hoàn tiền</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    
    <section class="spad">
        <div class="container">
            <c:if test="${not empty success}">
                <div class="alert alert-success alert-dismissible fade show">
                    ${success}
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                </div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-danger alert-dismissible fade show">
                    ${error}
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                </div>
            </c:if>
            
            <c:choose>
                <c:when test="${empty refundRequests}">
                    <div class="empty-state">
                        <i class="fa fa-undo"></i>
                        <h5>Chưa có yêu cầu hoàn tiền</h5>
                        <p>Bạn chưa gửi yêu cầu hoàn tiền nào.</p>
                        <a href="${pageContext.request.contextPath}/customer/orders" class="btn btn-primary">
                            <i class="fa fa-list"></i> Xem đơn hàng
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="refund" items="${refundRequests}">
                        <div class="refund-card">
                            <div class="card-body p-3">
                                <div class="row align-items-center">
                                    <div class="col-md-6">
                                        <h6 class="mb-1">
                                            Yêu cầu #${refund.refundRequestID}
                                            <c:choose>
                                                <c:when test="${refund.refundStatus == 'Pending'}">
                                                    <span class="status-badge status-pending">Đang chờ</span>
                                                </c:when>
                                                <c:when test="${refund.refundStatus == 'Approved'}">
                                                    <span class="status-badge status-approved">Đã duyệt</span>
                                                </c:when>
                                                <c:when test="${refund.refundStatus == 'Rejected'}">
                                                    <span class="status-badge status-rejected">Từ chối</span>
                                                </c:when>
                                                <c:when test="${refund.refundStatus == 'Completed'}">
                                                    <span class="status-badge status-completed">Hoàn thành</span>
                                                </c:when>
                                            </c:choose>
                                        </h6>
                                        <small class="text-muted">Đơn hàng: <strong>${refund.order.orderCode}</strong></small>
                                        <br>
                                        <small class="text-muted"><fmt:formatDate value="${refund.requestDate}" pattern="dd/MM/yyyy HH:mm"/></small>
                                    </div>
                                    <div class="col-md-3 text-center">
                                        <div class="text-danger font-weight-bold">
                                            <fmt:formatNumber value="${refund.refundAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                        </div>
                                        <small class="text-muted">Số tiền hoàn</small>
                                    </div>
                                    <div class="col-md-3 text-right">
                                        <a href="${pageContext.request.contextPath}/customer/refund?action=detail&id=${refund.refundRequestID}" 
                                           class="btn btn-outline-primary btn-sm">
                                            <i class="fa fa-eye"></i> Chi tiết
                                        </a>
                                    </div>
                                </div>
                                
                                <c:if test="${not empty refund.refundReason}">
                                    <hr class="my-2">
                                    <small class="text-muted"><strong>Lý do:</strong> ${refund.refundReason}</small>
                                </c:if>
                                
                                <c:if test="${refund.refundStatus == 'Rejected' && not empty refund.adminNotes}">
                                    <div class="alert alert-danger mt-2 mb-0 py-2">
                                        <small><strong>Lý do từ chối:</strong> ${refund.adminNotes}</small>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
            
            <div class="mt-4">
                <a href="${pageContext.request.contextPath}/customer/orders" class="btn btn-secondary">
                    <i class="fa fa-arrow-left"></i> Quay lại đơn hàng
                </a>
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