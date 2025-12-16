<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Theo dõi vận chuyển - Pickleball Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" type="text/css">
    <style>
        .info-card { background: #fff; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); padding: 20px; margin-bottom: 20px; }
        .info-card h5 { border-bottom: 1px solid #e5e5e5; padding-bottom: 10px; margin-bottom: 15px; font-size: 16px; }
        .tracking-header { text-align: center; padding: 30px 20px; background: #f8f9fa; border-radius: 8px; margin-bottom: 20px; }
        .tracking-code { font-size: 24px; font-weight: 700; color: #333; letter-spacing: 1px; margin-bottom: 15px; }
        .info-row { display: flex; padding: 10px 0; border-bottom: 1px solid #f0f0f0; }
        .info-row:last-child { border-bottom: none; }
        .info-label { width: 140px; color: #666; font-size: 14px; }
        .info-value { flex: 1; font-weight: 500; color: #333; }
        
        .timeline { position: relative; padding-left: 25px; }
        .timeline::before { content: ''; position: absolute; left: 6px; top: 5px; bottom: 5px; width: 2px; background: #e5e5e5; }
        .timeline-item { position: relative; padding-bottom: 20px; }
        .timeline-item:last-child { padding-bottom: 0; }
        .timeline-item::before { 
            content: ''; position: absolute; left: -22px; top: 5px; 
            width: 10px; height: 10px; border-radius: 50%; 
            background: #e5e5e5; border: 2px solid #fff;
        }
        .timeline-item:first-child::before { background: #28a745; width: 12px; height: 12px; left: -23px; top: 4px; }
        .timeline-item.delivered::before { background: #28a745; }
        .timeline-status { font-weight: 600; color: #333; margin-bottom: 3px; }
        .timeline-time { font-size: 13px; color: #999; }
        .timeline-location { font-size: 13px; color: #666; margin-top: 5px; }
        
        .shipper-info { background: #f8f9fa; padding: 15px; border-radius: 6px; margin-bottom: 20px; }
        .shipper-info i { color: #28a745; margin-right: 10px; }
    </style>
</head>
<body>
    <jsp:include page="../header.jsp" />
    
    <section class="breadcrumb-option">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="breadcrumb__text">
                        <h4>Theo dõi vận chuyển</h4>
                        <div class="breadcrumb__links">
                            <a href="${pageContext.request.contextPath}/Home">Trang chủ</a>
                            <a href="${pageContext.request.contextPath}/customer/orders">Đơn hàng</a>
                            <span>Theo dõi</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    
    <section class="spad">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <c:choose>
                        <c:when test="${tracking != null && tracking.success}">
                            <!-- Tracking Header -->
                            <div class="tracking-header">
                                <div class="tracking-code">${tracking.trackingCode}</div>
                                <c:choose>
                                    <c:when test="${tracking.status == 'delivered'}">
                                        <span class="badge badge-success" style="font-size:14px;padding:8px 20px;">
                                            <i class="fa fa-check"></i> Giao thành công
                                        </span>
                                    </c:when>
                                    <c:when test="${tracking.status == 'delivering'}">
                                        <span class="badge badge-warning" style="font-size:14px;padding:8px 20px;">
                                            <i class="fa fa-truck"></i> Đang giao hàng
                                        </span>
                                    </c:when>
                                    <c:when test="${tracking.status == 'picked'}">
                                        <span class="badge badge-info" style="font-size:14px;padding:8px 20px;">
                                            <i class="fa fa-box"></i> Đã lấy hàng
                                        </span>
                                    </c:when>
                                    <c:when test="${tracking.status == 'failed' || tracking.status == 'returned'}">
                                        <span class="badge badge-danger" style="font-size:14px;padding:8px 20px;">
                                            <i class="fa fa-times"></i> ${tracking.statusText}
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-secondary" style="font-size:14px;padding:8px 20px;">
                                            <i class="fa fa-clock-o"></i> Chờ lấy hàng
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <!-- Shipper Info -->
                            <c:if test="${not empty tracking.shipperName}">
                                <div class="shipper-info">
                                    <i class="fa fa-motorcycle"></i>
                                    <strong>Nhân viên giao hàng:</strong> ${tracking.shipperName}
                                    <c:if test="${not empty tracking.shipperPhone}">
                                        - <a href="tel:${tracking.shipperPhone}">${tracking.shipperPhone}</a>
                                    </c:if>
                                </div>
                            </c:if>
                            
                            <div class="row">
                                <!-- Thông tin người nhận -->
                                <div class="col-md-6">
                                    <div class="info-card">
                                        <h5><i class="fa fa-user"></i> Người nhận</h5>
                                        <div class="info-row">
                                            <span class="info-label">Họ tên</span>
                                            <span class="info-value">${tracking.recipientName}</span>
                                        </div>
                                        <div class="info-row">
                                            <span class="info-label">Điện thoại</span>
                                            <span class="info-value">${tracking.recipientPhone}</span>
                                        </div>
                                        <div class="info-row">
                                            <span class="info-label">Địa chỉ</span>
                                            <span class="info-value">${tracking.recipientAddress}</span>
                                        </div>
                                    </div>
                                </div>
                                
                                <!-- Thông tin đơn hàng -->
                                <c:if test="${order != null}">
                                    <div class="col-md-6">
                                        <div class="info-card">
                                            <h5><i class="fa fa-shopping-bag"></i> Đơn hàng</h5>
                                            <div class="info-row">
                                                <span class="info-label">Mã đơn</span>
                                                <span class="info-value">${order.orderCode}</span>
                                            </div>
                                            <div class="info-row">
                                                <span class="info-label">Tổng tiền</span>
                                                <span class="info-value" style="color:#e53637">
                                                    <fmt:formatNumber value="${order.totalAmount}" type="number"/>₫
                                                </span>
                                            </div>
                                            <div class="info-row">
                                                <span class="info-label">Thanh toán</span>
                                                <span class="info-value">
                                                    <c:choose>
                                                        <c:when test="${order.paymentStatus == 'Paid'}">
                                                            <span class="text-success">Đã thanh toán</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-warning">COD - Thu khi giao</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                </c:if>
                            </div>
                            
                            <!-- Lịch sử vận chuyển -->
                            <div class="info-card">
                                <h5><i class="fa fa-history"></i> Lịch sử vận chuyển</h5>
                                <c:choose>
                                    <c:when test="${not empty tracking.trackingEvents}">
                                        <div class="timeline">
                                            <c:forEach var="event" items="${tracking.trackingEvents}">
                                                <div class="timeline-item ${event.statusCode == 'delivered' ? 'delivered' : ''}">
                                                    <div class="timeline-status">${event.statusDescription}</div>
                                                    <div class="timeline-time">
                                                        <i class="fa fa-clock-o"></i>
                                                        <fmt:formatDate value="${event.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                    </div>
                                                    <c:if test="${not empty event.location}">
                                                        <div class="timeline-location">
                                                            <i class="fa fa-map-marker"></i> ${event.location}
                                                        </div>
                                                    </c:if>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <p class="text-muted text-center py-3">
                                            <i class="fa fa-clock-o"></i> Đang chờ shipper cập nhật trạng thái
                                        </p>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            
                            <!-- Buttons -->
                            <div class="text-center">
                                <c:if test="${order != null}">
                                    <a href="${pageContext.request.contextPath}/customer/orders?action=detail&id=${order.orderID}" 
                                       class="btn btn-outline-dark mr-2">
                                        <i class="fa fa-eye"></i> Xem đơn hàng
                                    </a>
                                </c:if>
                                <a href="${pageContext.request.contextPath}/customer/orders" class="btn btn-dark">
                                    <i class="fa fa-arrow-left"></i> Quay lại
                                </a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <!-- Error State -->
                            <div class="info-card text-center py-5">
                                <i class="fa fa-exclamation-circle fa-3x text-muted mb-3"></i>
                                <h5>Không tìm thấy thông tin vận chuyển</h5>
                                <p class="text-muted">
                                    <c:choose>
                                        <c:when test="${not empty error}">${error}</c:when>
                                        <c:otherwise>Vui lòng kiểm tra lại hoặc liên hệ hỗ trợ.</c:otherwise>
                                    </c:choose>
                                </p>
                                <a href="${pageContext.request.contextPath}/customer/orders" class="btn btn-dark mt-3">
                                    <i class="fa fa-arrow-left"></i> Quay lại đơn hàng
                                </a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </section>
    
    <jsp:include page="../footer.jsp" />
    
    <script src="${pageContext.request.contextPath}/js/jquery-3.3.1.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/bootstrap.min.js"></script>
</body>
</html>
