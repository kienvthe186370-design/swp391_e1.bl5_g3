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
    <title>Chi tiết đơn hàng - Pickleball Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" type="text/css">
    <style>
        .order-status-timeline { display: flex; justify-content: space-between; margin: 30px 0; position: relative; }
        .order-status-timeline::before { content: ''; position: absolute; top: 15px; left: 0; right: 0; height: 3px; background: #e5e5e5; z-index: 0; }
        .status-step { text-align: center; position: relative; z-index: 1; flex: 1; }
        .status-step .step-icon { width: 32px; height: 32px; border-radius: 50%; background: #e5e5e5; display: flex; align-items: center; justify-content: center; margin: 0 auto 10px; color: #999; }
        .status-step.active .step-icon { background: #28a745; color: #fff; }
        .status-step.current .step-icon { background: #ffc107; color: #fff; }
        .status-step.cancelled .step-icon { background: #dc3545; color: #fff; }
        .status-step .step-label { font-size: 12px; color: #666; }
        .status-step.active .step-label, .status-step.current .step-label { color: #333; font-weight: 600; }
        .info-card { background: #fff; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); padding: 20px; margin-bottom: 20px; }
        .info-card h5 { border-bottom: 1px solid #e5e5e5; padding-bottom: 10px; margin-bottom: 15px; }
        .product-item { display: flex; align-items: center; padding: 15px 0; border-bottom: 1px solid #f0f0f0; }
        .product-item:last-child { border-bottom: none; }
        .product-item img { width: 80px; height: 80px; object-fit: cover; border-radius: 4px; margin-right: 15px; }
    </style>
</head>
<body>
    <jsp:include page="../header.jsp" />
    
    <section class="breadcrumb-option">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="breadcrumb__text">
                        <h4>Chi tiết đơn hàng</h4>
                        <div class="breadcrumb__links">
                            <a href="${pageContext.request.contextPath}/Home">Trang chủ</a>
                            <a href="${pageContext.request.contextPath}/customer/orders">Đơn hàng</a>
                            <span>${order.orderCode}</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="spad">
        <div class="container">
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
            
            <!-- Order Header -->
            <div class="info-card">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h4 class="mb-1">Đơn hàng: ${order.orderCode}</h4>
                        <small class="text-muted">
                            Đặt ngày: <fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy HH:mm"/>
                        </small>
                    </div>
                    <div>
                        <c:choose>
                            <c:when test="${order.orderStatus == 'Pending'}">
                                <span class="badge badge-secondary" style="font-size: 14px; padding: 8px 16px;">Chờ xử lý</span>
                            </c:when>
                            <c:when test="${order.orderStatus == 'Confirmed'}">
                                <span class="badge badge-info" style="font-size: 14px; padding: 8px 16px;">Đã xác nhận</span>
                            </c:when>
                            <c:when test="${order.orderStatus == 'Processing'}">
                                <span class="badge badge-primary" style="font-size: 14px; padding: 8px 16px;">Đang xử lý</span>
                            </c:when>
                            <c:when test="${order.orderStatus == 'Shipping'}">
                                <span class="badge badge-warning" style="font-size: 14px; padding: 8px 16px;">Đang giao</span>
                            </c:when>
                            <c:when test="${order.orderStatus == 'Delivered'}">
                                <span class="badge badge-success" style="font-size: 14px; padding: 8px 16px;">Đã giao</span>
                            </c:when>
                            <c:when test="${order.orderStatus == 'Completed'}">
                                <span class="badge badge-success" style="font-size: 14px; padding: 8px 16px;">Hoàn thành</span>
                            </c:when>
                            <c:when test="${order.orderStatus == 'Returned'}">
                                <span class="badge badge-info" style="font-size: 14px; padding: 8px 16px;">Đã hoàn tiền</span>
                            </c:when>
                            <c:when test="${order.orderStatus == 'Cancelled'}">
                                <span class="badge badge-danger" style="font-size: 14px; padding: 8px 16px;">Đã hủy</span>
                            </c:when>
                        </c:choose>
                    </div>
                </div>

                <!-- Order Status Timeline -->
                <c:if test="${order.orderStatus != 'Cancelled'}">
                    <c:choose>
                        <c:when test="${not empty refundRequest || order.orderStatus == 'Returned'}">
                            <%-- Timeline cho trường hợp có yêu cầu hoàn tiền --%>
                            <div class="order-status-timeline">
                                <div class="status-step active">
                                    <div class="step-icon"><i class="fa fa-clock-o"></i></div>
                                    <div class="step-label">Chờ xử lý</div>
                                </div>
                                <div class="status-step active">
                                    <div class="step-icon"><i class="fa fa-check"></i></div>
                                    <div class="step-label">Đã xác nhận</div>
                                </div>
                                <div class="status-step active">
                                    <div class="step-icon"><i class="fa fa-cog"></i></div>
                                    <div class="step-label">Đang xử lý</div>
                                </div>
                                <div class="status-step active">
                                    <div class="step-icon"><i class="fa fa-truck"></i></div>
                                    <div class="step-label">Đang giao</div>
                                </div>
                                <div class="status-step active">
                                    <div class="step-icon"><i class="fa fa-home"></i></div>
                                    <div class="step-label">Đã giao</div>
                                </div>
                                <c:choose>
                                    <c:when test="${refundRequest.refundStatus == 'Pending'}">
                                        <div class="status-step current">
                                            <div class="step-icon"><i class="fa fa-hourglass-half"></i></div>
                                            <div class="step-label">Chờ duyệt hoàn tiền</div>
                                        </div>
                                        <div class="status-step">
                                            <div class="step-icon"><i class="fa fa-money"></i></div>
                                            <div class="step-label">Đã hoàn tiền</div>
                                        </div>
                                    </c:when>
                                    <c:when test="${refundRequest.refundStatus == 'Approved'}">
                                        <div class="status-step active">
                                            <div class="step-icon"><i class="fa fa-hourglass-half"></i></div>
                                            <div class="step-label">Đã duyệt hoàn tiền</div>
                                        </div>
                                        <div class="status-step current">
                                            <div class="step-icon"><i class="fa fa-money"></i></div>
                                            <div class="step-label">Đang hoàn tiền</div>
                                        </div>
                                    </c:when>
                                    <c:when test="${refundRequest.refundStatus == 'Completed' || order.orderStatus == 'Returned'}">
                                        <div class="status-step active">
                                            <div class="step-icon"><i class="fa fa-hourglass-half"></i></div>
                                            <div class="step-label">Đã duyệt hoàn tiền</div>
                                        </div>
                                        <div class="status-step active">
                                            <div class="step-icon"><i class="fa fa-money"></i></div>
                                            <div class="step-label">Đã hoàn tiền</div>
                                        </div>
                                    </c:when>
                                    <c:when test="${refundRequest.refundStatus == 'Rejected'}">
                                        <div class="status-step cancelled">
                                            <div class="step-icon"><i class="fa fa-times"></i></div>
                                            <div class="step-label">Từ chối hoàn tiền</div>
                                        </div>
                                    </c:when>
                                </c:choose>
                            </div>
                        </c:when>
                        <%-- Timeline bình thường --%>
                        <c:otherwise>
                            <div class="order-status-timeline">
                                <div class="status-step ${order.orderStatus == 'Pending' ? 'current' : 'active'}">
                                    <div class="step-icon"><i class="fa fa-clock-o"></i></div>
                                    <div class="step-label">Chờ xử lý</div>
                                </div>
                                <div class="status-step ${order.orderStatus == 'Confirmed' ? 'current' : (order.orderStatus == 'Processing' || order.orderStatus == 'Shipping' || order.orderStatus == 'Delivered' || order.orderStatus == 'Completed' ? 'active' : '')}">
                                    <div class="step-icon"><i class="fa fa-check"></i></div>
                                    <div class="step-label">Đã xác nhận</div>
                                </div>
                                <div class="status-step ${order.orderStatus == 'Processing' ? 'current' : (order.orderStatus == 'Shipping' || order.orderStatus == 'Delivered' || order.orderStatus == 'Completed' ? 'active' : '')}">
                                    <div class="step-icon"><i class="fa fa-cog"></i></div>
                                    <div class="step-label">Đang xử lý</div>
                                </div>
                                <div class="status-step ${order.orderStatus == 'Shipping' ? 'current' : (order.orderStatus == 'Delivered' || order.orderStatus == 'Completed' ? 'active' : '')}">
                                    <div class="step-icon"><i class="fa fa-truck"></i></div>
                                    <div class="step-label">Đang giao</div>
                                </div>
                                <div class="status-step ${order.orderStatus == 'Delivered' ? 'current' : (order.orderStatus == 'Completed' ? 'active' : '')}">
                                    <div class="step-icon"><i class="fa fa-home"></i></div>
                                    <div class="step-label">Đã giao</div>
                                </div>
                                <div class="status-step ${order.orderStatus == 'Completed' ? 'active' : ''}">
                                    <div class="step-icon"><i class="fa fa-check-circle"></i></div>
                                    <div class="step-label">Hoàn thành</div>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </c:if>
                
                <c:if test="${order.orderStatus == 'Cancelled'}">
                    <div class="alert alert-danger mt-3">
                        <strong>Đơn hàng đã bị hủy</strong>
                        <c:if test="${not empty order.cancelReason}">
                            <br>Lý do: ${order.cancelReason}
                        </c:if>
                    </div>
                </c:if>
            </div>

            <div class="row">
                <div class="col-lg-8">
                    <!-- Products -->
                    <div class="info-card">
                        <h5><i class="fa fa-shopping-bag"></i> Sản phẩm</h5>
                        <c:forEach var="detail" items="${order.orderDetails}">
                            <div class="product-item">
                                <c:choose>
                                    <c:when test="${not empty detail.productImage}">
                                        <img src="${pageContext.request.contextPath}/${detail.productImage}" alt="${detail.productName}">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="${pageContext.request.contextPath}/img/product/product-placeholder.jpg" alt="${detail.productName}">
                                    </c:otherwise>
                                </c:choose>
                                <div class="flex-grow-1">
                                    <strong>${detail.productName}</strong>
                                    <br><small class="text-muted">SKU: ${detail.sku}</small>
                                    <br><small>Số lượng: ${detail.quantity}</small>
                                </div>
                                <div class="text-right">
                                    <c:if test="${detail.discountAmount != null && detail.discountAmount > 0}">
                                        <small class="text-muted text-decoration-line-through">
                                            <fmt:formatNumber value="${detail.unitPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                        </small>
                                        <br>
                                    </c:if>
                                    <strong class="text-danger">
                                        <fmt:formatNumber value="${detail.finalPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                    </strong>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                    
                    <!-- Order History -->
                    <div class="info-card">
                        <h5><i class="fa fa-history"></i> Lịch sử đơn hàng</h5>
                        <c:forEach var="history" items="${order.statusHistory}">
                            <div class="d-flex mb-3">
                                <div class="mr-3">
                                    <small class="text-muted">
                                        <fmt:formatDate value="${history.changedDate}" pattern="dd/MM/yyyy"/>
                                        <br>
                                        <fmt:formatDate value="${history.changedDate}" pattern="HH:mm"/>
                                    </small>
                                </div>
                                <div>
                                    <strong>
                                        <c:if test="${not empty history.oldStatus}">
                                            ${history.oldStatus} → 
                                        </c:if>
                                        ${history.newStatus}
                                    </strong>
                                    <c:if test="${not empty history.notes}">
                                        <br><small class="text-muted">${history.notes}</small>
                                    </c:if>
                                </div>
                            </div>
                        </c:forEach>
                        <c:if test="${empty order.statusHistory}">
                            <p class="text-muted">Chưa có lịch sử</p>
                        </c:if>
                    </div>
                </div>

                <div class="col-lg-4">
                    <!-- Delivery Info -->
                    <div class="info-card">
                        <h5><i class="fa fa-map-marker"></i> Địa chỉ nhận hàng</h5>
                        <c:if test="${order.address != null}">
                            <p class="mb-1"><strong>${order.address.recipientName}</strong></p>
                            <p class="mb-1">${order.address.phone}</p>
                            <p class="mb-0 text-muted">
                                ${order.address.street}<c:if test="${not empty order.address.ward}">, ${order.address.ward}</c:if><c:if test="${not empty order.address.district}">, ${order.address.district}</c:if><c:if test="${not empty order.address.city}">, ${order.address.city}</c:if>
                            </p>
                        </c:if>
                    </div>
                    
                    <!-- Payment Info -->
                    <div class="info-card">
                        <h5><i class="fa fa-credit-card"></i> Thanh toán</h5>
                        <p class="mb-1">
                            <strong>Phương thức:</strong> ${order.paymentMethod}
                        </p>
                        <p class="mb-0">
                            <strong>Trạng thái:</strong>
                            <span class="badge badge-${order.paymentStatus == 'Paid' ? 'success' : 'warning'}">
                                ${order.paymentStatus == 'Paid' ? 'Đã thanh toán' : 'Chưa thanh toán'}
                            </span>
                        </p>
                    </div>
                    
                    <!-- Order Summary -->
                    <div class="info-card">
                        <h5><i class="fa fa-file-text-o"></i> Tổng đơn hàng</h5>
                        <div class="d-flex justify-content-between mb-2">
                            <span>Tạm tính:</span>
                            <span><fmt:formatNumber value="${order.subtotalAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</span>
                        </div>
                        <c:if test="${order.discountAmount != null && order.discountAmount > 0}">
                            <div class="d-flex justify-content-between mb-2">
                                <span>Giảm giá:</span>
                                <span class="text-success">-<fmt:formatNumber value="${order.discountAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</span>
                            </div>
                        </c:if>
                        <c:if test="${order.voucherDiscount != null && order.voucherDiscount > 0}">
                            <div class="d-flex justify-content-between mb-2">
                                <span>Voucher:</span>
                                <span class="text-success">-<fmt:formatNumber value="${order.voucherDiscount}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</span>
                            </div>
                        </c:if>
                        <div class="d-flex justify-content-between mb-2">
                            <span>Phí vận chuyển:</span>
                            <span><fmt:formatNumber value="${order.shippingFee}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</span>
                        </div>
                        <hr>
                        <div class="d-flex justify-content-between">
                            <strong>Tổng cộng:</strong>
                            <strong class="text-danger" style="font-size: 20px;">
                                <fmt:formatNumber value="${order.totalAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                            </strong>
                        </div>
                    </div>

                    <!-- Shipping Info -->
                    <c:if test="${order.shipping != null && order.shipping.trackingCode != null}">
                        <div class="info-card">
                            <h5><i class="fa fa-truck"></i> Thông tin vận chuyển</h5>
                            <div class="text-center mb-3 p-3" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 8px; color: white;">
                                <small style="opacity: 0.8;">Mã vận đơn</small><br>
                                <span style="font-size: 20px; font-weight: bold; letter-spacing: 2px;">
                                    ${order.shipping.trackingCode}
                                </span>
                            </div>
                            <c:if test="${order.shipping.goshipStatus != null}">
                                <p class="mb-2">
                                    <i class="fa fa-info-circle text-info"></i>
                                    <strong>Trạng thái:</strong> 
                                    <c:choose>
                                        <c:when test="${order.shipping.goshipStatus == 'picking'}">Đang lấy hàng</c:when>
                                        <c:when test="${order.shipping.goshipStatus == 'picked'}">Đã lấy hàng</c:when>
                                        <c:when test="${order.shipping.goshipStatus == 'delivering'}">Đang giao hàng</c:when>
                                        <c:when test="${order.shipping.goshipStatus == 'delivered'}">Giao thành công</c:when>
                                        <c:when test="${order.shipping.goshipStatus == 'delivery_failed'}">Giao thất bại</c:when>
                                        <c:when test="${order.shipping.goshipStatus == 'returning'}">Đang hoàn hàng</c:when>
                                        <c:when test="${order.shipping.goshipStatus == 'returned'}">Đã hoàn hàng</c:when>
                                        <c:otherwise>${order.shipping.goshipStatus}</c:otherwise>
                                    </c:choose>
                                </p>
                            </c:if>
                            <c:if test="${order.shipping.shipper != null}">
                                <p class="mb-2">
                                    <i class="fa fa-motorcycle text-primary"></i>
                                    <strong>Shipper:</strong> ${order.shipping.shipper.fullName}
                                </p>
                            </c:if>
                            <c:if test="${order.shipping.shippedDate != null}">
                                <p class="mb-2">
                                    <i class="fa fa-calendar text-secondary"></i>
                                    <strong>Ngày gửi:</strong> 
                                    <fmt:formatDate value="${order.shipping.shippedDate}" pattern="dd/MM/yyyy HH:mm"/>
                                </p>
                            </c:if>
                            <a href="${pageContext.request.contextPath}/tracking?code=${order.shipping.trackingCode}" 
                               class="btn btn-info btn-block mt-3">
                                <i class="fa fa-search"></i> Theo dõi vận chuyển chi tiết
                            </a>
                        </div>
                    </c:if>
                    
                    <!-- Thông tin hoàn tiền nếu có -->
                    <c:if test="${not empty refundRequest}">
                        <div class="info-card">
                            <h5><i class="fa fa-undo"></i> Yêu cầu hoàn tiền</h5>
                            <p class="mb-2">
                                <strong>Trạng thái:</strong>
                                <c:choose>
                                    <c:when test="${refundRequest.refundStatus == 'Pending'}">
                                        <span class="badge badge-warning">Chờ duyệt</span>
                                    </c:when>
                                    <c:when test="${refundRequest.refundStatus == 'Approved'}">
                                        <span class="badge badge-info">Đã duyệt - Đang hoàn tiền</span>
                                    </c:when>
                                    <c:when test="${refundRequest.refundStatus == 'Completed'}">
                                        <span class="badge badge-success">Đã hoàn tiền thành công</span>
                                    </c:when>
                                    <c:when test="${refundRequest.refundStatus == 'Rejected'}">
                                        <span class="badge badge-danger">Đã từ chối</span>
                                    </c:when>
                                </c:choose>
                            </p>
                            <p class="mb-2">
                                <strong>Số tiền hoàn:</strong> 
                                <span class="text-danger">
                                    <fmt:formatNumber value="${refundRequest.refundAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                </span>
                            </p>
                            <p class="mb-2"><strong>Lý do:</strong> ${refundRequest.refundReason}</p>
                            <c:if test="${not empty refundRequest.adminNotes}">
                                <p class="mb-2"><strong>Ghi chú từ shop:</strong> ${refundRequest.adminNotes}</p>
                            </c:if>
                            <a href="${pageContext.request.contextPath}/customer/refund?action=detail&id=${refundRequest.refundRequestID}" 
                               class="btn btn-outline-info btn-block btn-sm">
                                <i class="fa fa-eye"></i> Xem chi tiết
                            </a>
                        </div>
                    </c:if>

                    <!-- Actions -->
                    
                    <!-- Hủy đơn khi Pending -->
                    <c:if test="${order.orderStatus == 'Pending'}">
                        <button class="btn btn-danger btn-block" onclick="showCancelModal()">
                            <i class="fa fa-times"></i> Hủy đơn hàng
                        </button>
                    </c:if>
                    
                    <!-- Khi đơn hàng Delivered và chưa có refund request: hiện 2 nút -->
                    <c:if test="${order.orderStatus == 'Delivered' && empty refundRequest}">
                        <div class="info-card">
                            <h5><i class="fa fa-check-circle"></i> Xác nhận đơn hàng</h5>
                            <p class="text-muted small">Vui lòng xác nhận bạn đã nhận được hàng hoặc yêu cầu trả hàng/hoàn tiền.</p>
                            <form method="post" action="${pageContext.request.contextPath}/customer/orders" class="mb-2">
                                <input type="hidden" name="action" value="confirm">
                                <input type="hidden" name="orderId" value="${order.orderID}">
                                <button type="submit" class="btn btn-success btn-block" 
                                        onclick="return confirm('Xác nhận bạn đã nhận được hàng?')">
                                    <i class="fa fa-check"></i> Đã nhận được hàng
                                </button>
                            </form>
                            <a href="${pageContext.request.contextPath}/customer/refund?action=create&orderId=${order.orderID}" 
                               class="btn btn-warning btn-block">
                                <i class="fa fa-undo"></i> Trả hàng/Hoàn tiền
                            </a>
                        </div>
                    </c:if>
                    
                    <!-- Khi đơn hàng Completed: chỉ hiện nút đánh giá -->
                    <c:if test="${order.orderStatus == 'Completed'}">
                        <a href="${pageContext.request.contextPath}/order-review?orderId=${order.orderID}" 
                           class="btn btn-success btn-block">
                            <i class="fa fa-star"></i> Đánh giá sản phẩm
                        </a>
                    </c:if>
                    
                    <!-- Khi đang Shipping và chưa có refund: cho phép yêu cầu hoàn tiền -->
                    <c:if test="${order.orderStatus == 'Shipping' && empty refundRequest}">
                        <a href="${pageContext.request.contextPath}/customer/refund?action=create&orderId=${order.orderID}" 
                           class="btn btn-warning btn-block">
                            <i class="fa fa-undo"></i> Yêu cầu hoàn tiền
                        </a>
                    </c:if>
                    
                    <a href="${pageContext.request.contextPath}/customer/orders" class="btn btn-secondary btn-block">
                        <i class="fa fa-arrow-left"></i> Quay lại
                    </a>
                </div>
            </div>
        </div>
    </section>
    
    <!-- Modal Hủy đơn -->
    <c:if test="${order.orderStatus == 'Pending'}">
        <div class="modal fade" id="cancelModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Hủy đơn hàng ${order.orderCode}</h5>
                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                    </div>
                    <form method="post" action="${pageContext.request.contextPath}/customer/orders">
                        <div class="modal-body">
                            <input type="hidden" name="action" value="cancel">
                            <input type="hidden" name="orderId" value="${order.orderID}">
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
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-dismiss="modal">Đóng</button>
                            <button type="submit" class="btn btn-danger">Xác nhận hủy</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </c:if>
    
    <jsp:include page="../footer.jsp" />
    
    <script src="${pageContext.request.contextPath}/js/jquery-3.3.1.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/bootstrap.min.js"></script>
    <script>
    function showCancelModal() {
        $('#cancelModal').modal('show');
    }
    </script>
</body>
</html>
