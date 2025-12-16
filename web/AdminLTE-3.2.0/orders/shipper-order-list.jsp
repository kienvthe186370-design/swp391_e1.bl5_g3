<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đơn hàng giao | Shipper</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/AdminLTE-3.2.0/plugins/fontawesome-free/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/AdminLTE-3.2.0/dist/css/adminlte.min.css">
    <style>
        .status-badge { padding: 5px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; }
        .status-picking { background: #fff3cd; color: #856404; }
        .status-picked { background: #cce5ff; color: #004085; }
        .status-delivering { background: #d1ecf1; color: #0c5460; }
        .status-delivered { background: #d4edda; color: #155724; }
        .status-failed { background: #f8d7da; color: #721c24; }
        .cod-badge { background: #dc3545; color: white; padding: 3px 8px; border-radius: 4px; font-size: 11px; }
    </style>
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">
    <jsp:include page="../includes/admin-header.jsp"/>
    <jsp:include page="../includes/admin-sidebar.jsp"/>

    <div class="content-wrapper">
        <div class="content-header">
            <div class="container-fluid">
                <div class="row mb-2">
                    <div class="col-sm-6">
                        <h1 class="m-0"><i class="fas fa-motorcycle"></i> Đơn hàng giao</h1>
                    </div>
                </div>
            </div>
        </div>

        <section class="content">
            <div class="container-fluid">
                <!-- Alert messages -->
                <c:if test="${not empty sessionScope.success}">
                    <div class="alert alert-success alert-dismissible">
                        <button type="button" class="close" data-dismiss="alert">&times;</button>
                        ${sessionScope.success}
                    </div>
                    <c:remove var="success" scope="session"/>
                </c:if>
                <c:if test="${not empty sessionScope.error}">
                    <div class="alert alert-danger alert-dismissible">
                        <button type="button" class="close" data-dismiss="alert">&times;</button>
                        ${sessionScope.error}
                    </div>
                    <c:remove var="error" scope="session"/>
                </c:if>

                <!-- Stats -->
                <div class="row">
                    <div class="col-lg-4 col-6">
                        <div class="small-box bg-warning">
                            <div class="inner">
                                <h3>${pendingCount}</h3>
                                <p>Đơn cần giao</p>
                            </div>
                            <div class="icon"><i class="fas fa-box"></i></div>
                        </div>
                    </div>
                    <div class="col-lg-4 col-6">
                        <div class="small-box bg-success">
                            <div class="inner">
                                <h3>${deliveredToday}</h3>
                                <p>Đã giao hôm nay</p>
                            </div>
                            <div class="icon"><i class="fas fa-check-circle"></i></div>
                        </div>
                    </div>
                    <div class="col-lg-4 col-6">
                        <div class="small-box bg-info">
                            <div class="inner">
                                <h3>${orders.size()}</h3>
                                <p>Tổng đơn được phân</p>
                            </div>
                            <div class="icon"><i class="fas fa-list"></i></div>
                        </div>
                    </div>
                </div>

                <!-- Order List -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title"><i class="fas fa-clipboard-list"></i> Danh sách đơn hàng</h3>
                    </div>
                    <div class="card-body p-0">
                        <c:choose>
                            <c:when test="${empty orders}">
                                <div class="p-4 text-center text-muted">
                                    <i class="fas fa-inbox fa-3x mb-3"></i>
                                    <p>Chưa có đơn hàng nào được phân công cho bạn.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>Mã đơn</th>
                                            <th>Khách hàng</th>
                                            <th>Địa chỉ</th>
                                            <th>Tổng tiền</th>
                                            <th>Trạng thái</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="order" items="${orders}">
                                            <tr>
                                                <td>
                                                    <strong>${order.orderCode}</strong><br>
                                                    <small class="text-muted">
                                                        <fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy HH:mm"/>
                                                    </small>
                                                </td>
                                                <td>
                                                    <strong>${order.customer.fullName}</strong><br>
                                                    <small><i class="fas fa-phone"></i> ${order.address.phone}</small>
                                                </td>
                                                <td>
                                                    <small>${order.address.street}, ${order.address.ward}<br>
                                                    ${order.address.district}, ${order.address.city}</small>
                                                </td>
                                                <td>
                                                    <c:if test="${order.paymentMethod == 'COD' && order.paymentStatus != 'Paid'}">
                                                        <span class="cod-badge">COD</span><br>
                                                    </c:if>
                                                    <strong class="text-danger">
                                                        <fmt:formatNumber value="${order.totalAmount}" type="number"/>đ
                                                    </strong>
                                                </td>
                                                <td>
                                                    <span class="status-badge 
                                                        <c:choose>
                                                            <c:when test="${order.shipping.goshipStatus == 'picking'}">status-picking</c:when>
                                                            <c:when test="${order.shipping.goshipStatus == 'picked'}">status-picked</c:when>
                                                            <c:when test="${order.shipping.goshipStatus == 'delivering'}">status-delivering</c:when>
                                                            <c:when test="${order.shipping.goshipStatus == 'delivered'}">status-delivered</c:when>
                                                            <c:otherwise>status-picking</c:otherwise>
                                                        </c:choose>
                                                    ">
                                                        <c:choose>
                                                            <c:when test="${order.shipping.goshipStatus == 'picking'}">Đang lấy hàng</c:when>
                                                            <c:when test="${order.shipping.goshipStatus == 'picked'}">Đã lấy hàng</c:when>
                                                            <c:when test="${order.shipping.goshipStatus == 'delivering'}">Đang giao</c:when>
                                                            <c:when test="${order.shipping.goshipStatus == 'delivered'}">Đã giao</c:when>
                                                            <c:otherwise>Chờ lấy hàng</c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </td>
                                                <td>
                                                    <a href="${pageContext.request.contextPath}/admin/orders?action=shipperDetail&id=${order.orderID}" 
                                                       class="btn btn-primary btn-sm">
                                                        <i class="fas fa-eye"></i> Chi tiết
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </section>
    </div>

    <jsp:include page="../includes/admin-footer.jsp"/>
</div>

<script src="${pageContext.request.contextPath}/AdminLTE-3.2.0/plugins/jquery/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/AdminLTE-3.2.0/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/AdminLTE-3.2.0/dist/js/adminlte.min.js"></script>
</body>
</html>
