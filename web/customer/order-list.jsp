<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="entity.Customer" %>
<%
    Customer customer = (Customer) session.getAttribute("customer");
    if (customer == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đơn hàng của tôi - Pickleball Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" type="text/css">
    <style>
        .order-card { border: 1px solid #e5e5e5; border-radius: 8px; margin-bottom: 20px; }
        .order-card .card-header { background: #f8f9fa; border-bottom: 1px solid #e5e5e5; padding: 15px 20px; }
        .order-card .card-body { padding: 20px; }
        .order-item { display: flex; align-items: center; padding: 10px 0; border-bottom: 1px solid #f0f0f0; }
        .order-item:last-child { border-bottom: none; }
        .order-item img { width: 60px; height: 60px; object-fit: cover; border-radius: 4px; margin-right: 15px; }
        .badge-status { padding: 5px 12px; border-radius: 20px; font-size: 12px; }
        .sidebar-menu { background: #fff; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .sidebar-menu .list-group-item { border: none; padding: 12px 20px; }
        .sidebar-menu .list-group-item.active { background: #ca1515; border-color: #ca1515; }
        .sidebar-menu .list-group-item:hover:not(.active) { background: #f8f9fa; }
        .nav-tabs .nav-link { color: #666; border: none; padding: 10px 20px; }
        .nav-tabs .nav-link.active { color: #ca1515; border-bottom: 2px solid #ca1515; background: transparent; }
    </style>
</head>
<body>
    <jsp:include page="../header.jsp" />
    
    <section class="breadcrumb-option">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="breadcrumb__text">
                        <h4>Đơn hàng của tôi</h4>
                        <div class="breadcrumb__links">
                            <a href="${pageContext.request.contextPath}/Home">Trang chủ</a>
                            <span>Đơn hàng của tôi</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    
    <section class="spad">
        <div class="container">
            <div class="row">
                <!-- Sidebar -->
                <div class="col-lg-3 col-md-4">
                    <div class="sidebar-menu">
                        <div class="list-group list-group-flush">
                            <a href="${pageContext.request.contextPath}/customer/profile" class="list-group-item list-group-item-action">
                                <i class="fa fa-user"></i> Thông tin cá nhân
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/orders" class="list-group-item list-group-item-action active">
                                <i class="fa fa-shopping-bag"></i> Đơn hàng của tôi
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/addresses" class="list-group-item list-group-item-action">
                                <i class="fa fa-map-marker"></i> Sổ địa chỉ
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/wishlist" class="list-group-item list-group-item-action">
                                <i class="fa fa-heart"></i> Yêu thích
                            </a>
                        </div>
                    </div>
                </div>
                
                <!-- Main Content -->
                <div class="col-lg-9 col-md-8">
                    <c:if test="${not empty sessionScope.success}">
                        <div class="alert alert-success alert-dismissible fade show">
                            ${sessionScope.success}
                            <button type="button" class="close" data-dismiss="alert">&times;</button>
                        </div>
                        <c:remove var="success" scope="session"/>
                    </c:if>
                    <c:if test="${not empty sessionScope.error}">
                        <div class="alert alert-danger alert-dismissible fade show">
                            ${sessionScope.error}
                            <button type="button" class="close" data-dismiss="alert">&times;</button>
                        </div>
                        <c:remove var="error" scope="session"/>
                    </c:if>
                    
                    <!-- Filter tabs -->
                    <ul class="nav nav-tabs mb-4">
                        <li class="nav-item">
                            <a class="nav-link ${param.status == null ? 'active' : ''}" href="?">Tất cả</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link ${param.status == 'Pending' ? 'active' : ''}" href="?status=Pending">Chờ xử lý</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link ${param.status == 'Processing' ? 'active' : ''}" href="?status=Processing">Đang xử lý</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link ${param.status == 'Shipping' ? 'active' : ''}" href="?status=Shipping">Đang giao</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link ${param.status == 'Delivered' ? 'active' : ''}" href="?status=Delivered">Đã giao</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link ${param.status == 'Cancelled' ? 'active' : ''}" href="?status=Cancelled">Đã hủy</a>
                        </li>
                    </ul>

                    <!-- Orders list -->
                    <c:forEach var="order" items="${orders}">
                        <div class="order-card">
                            <div class="card-header d-flex justify-content-between align-items-center">
                                <div>
                                    <strong>Đơn hàng: ${order.orderCode}</strong>
                                    <small class="text-muted ml-3">
                                        <fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy HH:mm"/>
                                    </small>
                                </div>
                                <div>
                                    <c:choose>
                                        <c:when test="${order.orderStatus == 'Pending'}">
                                            <span class="badge badge-secondary badge-status">Chờ xử lý</span>
                                        </c:when>
                                        <c:when test="${order.orderStatus == 'Confirmed'}">
                                            <span class="badge badge-info badge-status">Đã xác nhận</span>
                                        </c:when>
                                        <c:when test="${order.orderStatus == 'Processing'}">
                                            <span class="badge badge-primary badge-status">Đang xử lý</span>
                                        </c:when>
                                        <c:when test="${order.orderStatus == 'Shipping'}">
                                            <span class="badge badge-warning badge-status">Đang giao</span>
                                        </c:when>
                                        <c:when test="${order.orderStatus == 'Delivered'}">
                                            <span class="badge badge-success badge-status">Đã giao</span>
                                        </c:when>
                                        <c:when test="${order.orderStatus == 'Completed'}">
                                            <span class="badge badge-success badge-status">Hoàn thành</span>
                                        </c:when>
                                        <c:when test="${order.orderStatus == 'Cancelled'}">
                                            <span class="badge badge-danger badge-status">Đã hủy</span>
                                        </c:when>
                                    </c:choose>
                                </div>
                            </div>
                            <div class="card-body">
                                <!-- Hiển thị 2 sản phẩm đầu tiên -->
                                <c:forEach var="detail" items="${order.orderDetails}" varStatus="loop">
                                    <c:if test="${loop.index < 2}">
                                        <div class="order-item">
                                            <c:if test="${not empty detail.productImage}">
                                                <img src="${pageContext.request.contextPath}/${detail.productImage}" alt="${detail.productName}">
                                            </c:if>
                                            <c:if test="${empty detail.productImage}">
                                                <img src="${pageContext.request.contextPath}/img/product/product-placeholder.jpg" alt="${detail.productName}">
                                            </c:if>
                                            <div class="flex-grow-1">
                                                <strong>${detail.productName}</strong>
                                                <br><small class="text-muted">x${detail.quantity}</small>
                                            </div>
                                            <div class="text-right">
                                                <fmt:formatNumber value="${detail.finalPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                            </div>
                                        </div>
                                    </c:if>
                                </c:forEach>
                                
                                <c:if test="${order.orderDetails.size() > 2}">
                                    <p class="text-muted mt-2 mb-0">
                                        <small>+ ${order.orderDetails.size() - 2} sản phẩm khác</small>
                                    </p>
                                </c:if>
                                
                                <hr>
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <span class="text-muted">Tổng tiền:</span>
                                        <strong class="text-danger ml-2" style="font-size: 18px;">
                                            <fmt:formatNumber value="${order.totalAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                        </strong>
                                    </div>
                                    <div>
                                        <a href="?action=detail&id=${order.orderID}" class="btn btn-outline-primary btn-sm">
                                            Xem chi tiết
                                        </a>
                                        <c:if test="${order.orderStatus == 'Pending'}">
                                            <button class="btn btn-outline-danger btn-sm" 
                                                    onclick="showCancelModal(${order.orderID}, '${order.orderCode}')">
                                                Hủy đơn
                                            </button>
                                        </c:if>
                                        <c:if test="${order.orderStatus == 'Delivered'}">
                                            <form method="post" action="${pageContext.request.contextPath}/customer/orders" style="display:inline;">
                                                <input type="hidden" name="action" value="confirm">
                                                <input type="hidden" name="orderId" value="${order.orderID}">
                                                <button type="submit" class="btn btn-outline-success btn-sm" onclick="return confirm('Xác nhận bạn đã nhận được hàng?')">
                                                    <i class="fa fa-check"></i> Đã nhận hàng
                                                </button>
                                            </form>
                                            <a href="${pageContext.request.contextPath}/customer/refund?action=create&orderId=${order.orderID}" 
                                               class="btn btn-outline-warning btn-sm">
                                                <i class="fa fa-undo"></i> Trả hàng
                                            </a>
                                        </c:if>
                                        <c:if test="${order.orderStatus == 'Completed'}">
                                            <a href="${pageContext.request.contextPath}/order-review?orderId=${order.orderID}" 
                                               class="btn btn-outline-warning btn-sm">
                                                <i class="fa fa-star"></i> Đánh giá
                                            </a>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                    
                    <c:if test="${empty orders}">
                        <div class="text-center py-5">
                            <i class="fa fa-shopping-bag" style="font-size: 64px; color: #ddd;"></i>
                            <h5 class="mt-3 text-muted">Bạn chưa có đơn hàng nào</h5>
                            <a href="${pageContext.request.contextPath}/shop" class="btn btn-primary mt-3">
                                Mua sắm ngay
                            </a>
                        </div>
                    </c:if>
                    
                    <!-- Pagination -->
                    <c:if test="${totalPages > 1}">
                        <nav class="mt-4">
                            <ul class="pagination justify-content-center">
                                <c:if test="${currentPage > 1}">
                                    <li class="page-item">
                                        <a class="page-link" href="?page=${currentPage-1}&status=${param.status}">&laquo;</a>
                                    </li>
                                </c:if>
                                <c:forEach begin="1" end="${totalPages}" var="i">
                                    <li class="page-item ${i == currentPage ? 'active' : ''}">
                                        <a class="page-link" href="?page=${i}&status=${param.status}">${i}</a>
                                    </li>
                                </c:forEach>
                                <c:if test="${currentPage < totalPages}">
                                    <li class="page-item">
                                        <a class="page-link" href="?page=${currentPage+1}&status=${param.status}">&raquo;</a>
                                    </li>
                                </c:if>
                            </ul>
                        </nav>
                    </c:if>
                </div>
            </div>
        </div>
    </section>
    
    <!-- Modal Hủy đơn -->
    <div class="modal fade" id="cancelModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Hủy đơn hàng <span id="cancelOrderCode"></span></h5>
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                </div>
                <form method="post" action="${pageContext.request.contextPath}/customer/orders">
                    <div class="modal-body">
                        <input type="hidden" name="action" value="cancel">
                        <input type="hidden" name="orderId" id="cancelOrderId">
                        <div class="form-group">
                            <label>Lý do hủy đơn:</label>
                            <select name="reason" class="form-control" required>
                                <option value="">-- Chọn lý do --</option>
                                <option value="Đổi ý không muốn mua nữa">Đổi ý không muốn mua nữa</option>
                                <option value="Muốn thay đổi sản phẩm">Muốn thay đổi sản phẩm</option>
                                <option value="Tìm được giá tốt hơn">Tìm được giá tốt hơn</option>
                                <option value="Đặt nhầm sản phẩm">Đặt nhầm sản phẩm</option>
                                <option value="Lý do khác">Lý do khác</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Ghi chú thêm (tùy chọn):</label>
                            <textarea name="note" class="form-control" rows="2"></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Đóng</button>
                        <button type="submit" class="btn btn-danger">Xác nhận hủy</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <jsp:include page="../footer.jsp" />
    
    <script src="${pageContext.request.contextPath}/js/jquery-3.3.1.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/bootstrap.min.js"></script>
    <script>
    function showCancelModal(orderId, orderCode) {
        $('#cancelOrderId').val(orderId);
        $('#cancelOrderCode').text(orderCode);
        $('#cancelModal').modal('show');
    }
    </script>
</body>
</html>
