<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tài khoản của tôi - Pickleball Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" type="text/css">
    <style>
        .profile-sidebar { background: #f8f9fa; padding: 20px; border-radius: 8px; }
        .profile-sidebar .nav-link { color: #333; padding: 12px 15px; border-radius: 5px; margin-bottom: 5px; }
        .profile-sidebar .nav-link:hover, .profile-sidebar .nav-link.active { background: #e53637; color: white; }
        .profile-sidebar .nav-link i { width: 20px; }
        .profile-content { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        
        /* Avatar */
        .avatar-wrapper { position: relative; width: 120px; height: 120px; margin: 0 auto 15px; }
        .avatar-img { width: 120px; height: 120px; border-radius: 50%; object-fit: cover; border: 3px solid #e53637; }
        .avatar-placeholder { width: 120px; height: 120px; border-radius: 50%; background: #e1e1e1; display: flex; align-items: center; justify-content: center; border: 3px solid #e53637; }
        .avatar-placeholder i { font-size: 50px; color: #999; }
        .avatar-upload-btn { position: absolute; bottom: 0; right: 0; width: 36px; height: 36px; background: #e53637; border-radius: 50%; display: flex; align-items: center; justify-content: center; cursor: pointer; border: 2px solid white; }
        .avatar-upload-btn i { color: white; font-size: 14px; }
        .avatar-upload-btn:hover { background: #c42b2b; }
        
        /* Address Card */
        .address-card { border: 1px solid #ddd; padding: 15px; margin-bottom: 15px; border-radius: 8px; position: relative; }
        .address-card.default { border-color: #e53637; background: #fff5f5; }
        .address-card .badge-default { position: absolute; top: 10px; right: 10px; background: #e53637; color: white; padding: 3px 8px; border-radius: 3px; font-size: 11px; }
        .address-card .actions { margin-top: 10px; }
        .btn-add-address { border: 2px dashed #ddd; padding: 30px; text-align: center; border-radius: 8px; cursor: pointer; color: #666; }
        .btn-add-address:hover { border-color: #e53637; color: #e53637; }
        
        /* Form */
        .form-group label { font-weight: 600; color: #333; }
        .form-control:focus { border-color: #e53637; box-shadow: 0 0 0 0.2rem rgba(229, 54, 55, 0.15); }
        
        /* Order Card Styles - from order-list.jsp */
        .order-card { border: 1px solid #e5e5e5; border-radius: 8px; margin-bottom: 20px; }
        .order-card .card-header { background: #f8f9fa; border-bottom: 1px solid #e5e5e5; padding: 15px 20px; }
        .order-card .card-body { padding: 20px; }
        .order-item { display: flex; align-items: center; padding: 10px 0; border-bottom: 1px solid #f0f0f0; }
        .order-item:last-child { border-bottom: none; }
        .order-item img { width: 60px; height: 60px; object-fit: cover; border-radius: 4px; margin-right: 15px; }
        .badge-status { padding: 5px 12px; border-radius: 20px; font-size: 12px; }
        .nav-tabs .nav-link { color: #666; border: none; padding: 10px 20px; }
        
        /* Review content - prevent overflow */
        .review-item { overflow: hidden; word-wrap: break-word; overflow-wrap: break-word; }
        .review-item div { word-wrap: break-word; overflow-wrap: break-word; }
        .review-content-text { 
            word-wrap: break-word; 
            overflow-wrap: break-word; 
            white-space: pre-wrap;
            max-width: 100%;
        }
        .nav-tabs .nav-link.active { color: #ca1515; border-bottom: 2px solid #ca1515; background: transparent; }
        
        /* Wishlist Styles - from wishlist.jsp */
        .wishlist-item { border: 1px solid #e5e5e5; border-radius: 8px; margin-bottom: 20px; padding: 20px; transition: all 0.3s; }
        .wishlist-item:hover { box-shadow: 0 5px 15px rgba(0,0,0,0.1); }
        .wishlist-item img { width: 120px; height: 120px; object-fit: cover; border-radius: 8px; }
        .wishlist-item .product-info { flex: 1; padding-left: 20px; }
        .wishlist-item .product-name { font-size: 18px; font-weight: 600; color: #111; margin-bottom: 5px; }
        .wishlist-item .product-name:hover { color: #ca1515; }
        .wishlist-item .brand { color: #999; font-size: 14px; margin-bottom: 10px; }
        .wishlist-item .price { font-size: 20px; font-weight: 700; color: #ca1515; }
        .wishlist-item .price-old { text-decoration: line-through; color: #999; font-size: 14px; margin-right: 10px; }
        .wishlist-item .discount-badge { background: #ca1515; color: #fff; padding: 2px 8px; border-radius: 4px; font-size: 12px; }
        .wishlist-item .stock-status { font-size: 13px; margin-top: 5px; }
        .wishlist-item .actions { display: flex; gap: 10px; margin-top: 15px; }
        .wishlist-item .btn-add-cart { background: #111; color: #fff; border: none; padding: 10px 25px; border-radius: 4px; }
        .wishlist-item .btn-add-cart:hover { background: #ca1515; }
        .wishlist-item .btn-remove { background: transparent; border: 1px solid #ddd; color: #666; padding: 10px 15px; border-radius: 4px; }
        .wishlist-item .btn-remove:hover { border-color: #ca1515; color: #ca1515; }
        .empty-wishlist { text-align: center; padding: 60px 20px; }
        .empty-wishlist i { font-size: 80px; color: #ddd; margin-bottom: 20px; }
    </style>
</head>
<body>
    <%@include file="../header.jsp" %>

    <section class="breadcrumb-option">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="breadcrumb__text">
                        <h4>Tài khoản của tôi</h4>
                        <div class="breadcrumb__links">
                            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
                            <span>Tài khoản</span>
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
                <div class="col-lg-3">
                    <div class="profile-sidebar">
                        <div class="text-center mb-4">
                            <!-- Avatar -->
                            <div class="avatar-wrapper">
                                <c:choose>
                                    <c:when test="${not empty customer.avatar}">
                                        <img src="${pageContext.request.contextPath}/${customer.avatar}" alt="Avatar" class="avatar-img" id="avatarPreview">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="avatar-placeholder" id="avatarPlaceholder">
                                            <i class="fa fa-user"></i>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                                <label class="avatar-upload-btn" for="avatarInput" title="Đổi ảnh đại diện">
                                    <i class="fa fa-camera"></i>
                                </label>
                            </div>
                            <h5 class="mt-2 mb-1">${customer.fullName}</h5>
                            <small class="text-muted">${customer.email}</small>
                        </div>
                        <nav class="nav flex-column">
                            <a class="nav-link ${activeTab == 'profile' || activeTab == null ? 'active' : ''}" href="?tab=profile">
                                <i class="fa fa-user"></i> Thông tin cá nhân
                            </a>
                            <a class="nav-link ${activeTab == 'addresses' ? 'active' : ''}" href="?tab=addresses">
                                <i class="fa fa-map-marker"></i> Địa chỉ giao hàng
                            </a>
                            <a class="nav-link ${activeTab == 'password' ? 'active' : ''}" href="?tab=password">
                                <i class="fa fa-lock"></i> Đổi mật khẩu
                            </a>
                            <a class="nav-link ${activeTab == 'orders' ? 'active' : ''}" href="?tab=orders">
                                <i class="fa fa-list-alt"></i> Đơn hàng của tôi
                            </a>
                            <a class="nav-link ${activeTab == 'reviews' ? 'active' : ''}" href="?tab=reviews">
                                <i class="fa fa-star"></i> Lịch sử đánh giá
                            </a>
                            <a class="nav-link ${activeTab == 'wishlist' ? 'active' : ''}" href="?tab=wishlist">
                                <i class="fa fa-heart"></i> Yêu thích
                            </a>
                            <a class="nav-link" href="${pageContext.request.contextPath}/logout">
                                <i class="fa fa-sign-out"></i> Đăng xuất
                            </a>
                        </nav>
                    </div>
                </div>

                <!-- Content -->
                <div class="col-lg-9">
                    <div class="profile-content">
                        <c:if test="${not empty param.success}">
                            <div class="alert alert-success alert-dismissible fade show">
                                <i class="fa fa-check-circle"></i> ${param.success}
                                <button type="button" class="close" data-dismiss="alert">&times;</button>
                            </div>
                        </c:if>
                        <c:if test="${not empty param.error}">
                            <div class="alert alert-danger alert-dismissible fade show">
                                <i class="fa fa-exclamation-circle"></i> ${param.error}
                                <button type="button" class="close" data-dismiss="alert">&times;</button>
                            </div>
                        </c:if>

                        <c:choose>
                            <c:when test="${activeTab == 'addresses'}">
                            <%-- ADDRESSES TAB --%>
                                <h4 class="mb-4"><i class="fa fa-map-marker text-danger"></i> Địa chỉ giao hàng</h4>
                                
                                <div class="row">
                                    <c:forEach var="addr" items="${addresses}">
                                        <div class="col-md-6">
                                            <div class="address-card ${addr['default'] ? 'default' : ''}" 
                                                 data-id="${addr.addressID}"
                                                 data-name="${addr.recipientName}"
                                                 data-phone="${addr.phone}"
                                                 data-street="${addr.street}"
                                                 data-ward="${addr.ward}"
                                                 data-district="${addr.district}"
                                                 data-city="${addr.city}"
                                                 data-default="${addr['default']}">
                                                <c:if test="${addr['default']}">
                                                    <span class="badge-default">Mặc định</span>
                                                </c:if>
                                                <h6><strong>${addr.recipientName}</strong></h6>
                                                <p class="mb-1"><i class="fa fa-phone"></i> ${addr.phone}</p>
                                                <p class="mb-0 text-muted"><i class="fa fa-home"></i> ${addr.fullAddress}</p>
                                                <div class="actions">
                                                    <button class="btn btn-sm btn-outline-primary" onclick="openEditModal(this)">
                                                        <i class="fa fa-edit"></i> Sửa
                                                    </button>
                                                    <c:if test="${!addr['default']}">
                                                        <button class="btn btn-sm btn-outline-success" onclick="setDefaultAddress('${addr.addressID}')">
                                                            <i class="fa fa-check"></i> Đặt mặc định
                                                        </button>
                                                        <button class="btn btn-sm btn-outline-danger" onclick="deleteAddress('${addr.addressID}')">
                                                            <i class="fa fa-trash"></i>
                                                        </button>
                                                    </c:if>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                    
                                    <div class="col-md-6">
                                        <div class="btn-add-address" data-toggle="modal" data-target="#addAddressModal">
                                            <i class="fa fa-plus fa-2x"></i>
                                            <p class="mt-2 mb-0">Thêm địa chỉ mới</p>
                                        </div>
                                    </div>
                                </div>
                            </c:when>
                            <c:when test="${activeTab == 'password'}">
                            <%-- PASSWORD TAB --%>
                                <h4 class="mb-4"><i class="fa fa-lock text-danger"></i> Đổi mật khẩu</h4>
                                <form action="${pageContext.request.contextPath}/update-profile" method="post">
                                    <input type="hidden" name="action" value="changePassword">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Mật khẩu hiện tại <span class="text-danger">*</span></label>
                                                <input type="password" name="currentPassword" class="form-control" required>
                                            </div>
                                            <div class="form-group">
                                                <label>Mật khẩu mới <span class="text-danger">*</span></label>
                                                <input type="password" name="newPassword" class="form-control" minlength="6" required>
                                                <small class="text-muted">Tối thiểu 6 ký tự</small>
                                            </div>
                                            <div class="form-group">
                                                <label>Xác nhận mật khẩu mới <span class="text-danger">*</span></label>
                                                <input type="password" name="confirmPassword" class="form-control" minlength="6" required>
                                            </div>
                                            <button type="submit" class="btn btn-primary">
                                                <i class="fa fa-save"></i> Đổi mật khẩu
                                            </button>
                                        </div>
                                    </div>
                                </form>
                            </c:when>
                            
                            <c:when test="${activeTab == 'orders'}">
                            <%-- ORDERS TAB - Exact structure from order-list.jsp --%>
                                <h4 class="mb-4"><i class="fa fa-list-alt text-danger"></i> Đơn hàng của tôi</h4>
                                
                                <!-- Status Filter -->
                                <ul class="nav nav-tabs mb-4">
                                    <li class="nav-item">
                                        <a class="nav-link ${empty statusFilter ? 'active' : ''}" href="?tab=orders">Tất cả</a>
                                    </li>
                                    <li class="nav-item">
                                        <a class="nav-link ${statusFilter == 'Pending' ? 'active' : ''}" href="?tab=orders&status=Pending">Chờ xử lý</a>
                                    </li>
                                    <li class="nav-item">
                                        <a class="nav-link ${statusFilter == 'Processing' ? 'active' : ''}" href="?tab=orders&status=Processing">Đang xử lý</a>
                                    </li>
                                    <li class="nav-item">
                                        <a class="nav-link ${statusFilter == 'Shipping' ? 'active' : ''}" href="?tab=orders&status=Shipping">Đang giao</a>
                                    </li>
                                    <li class="nav-item">
                                        <a class="nav-link ${statusFilter == 'Delivered' ? 'active' : ''}" href="?tab=orders&status=Delivered">Đã giao</a>
                                    </li>
                                    <li class="nav-item">
                                        <a class="nav-link ${statusFilter == 'Cancelled' ? 'active' : ''}" href="?tab=orders&status=Cancelled">Đã hủy</a>
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
                                                    <a href="${pageContext.request.contextPath}/customer/orders?action=detail&id=${order.orderID}" class="btn btn-outline-primary btn-sm">
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
                                                    <c:if test="${order.orderStatus == 'Completed' && order.hasPendingReview()}">
                                                        <a href="${pageContext.request.contextPath}/order-review?orderId=${order.orderID}" 
                                                           class="btn btn-outline-warning btn-sm">
                                                            <i class="fa fa-star"></i> Đánh giá
                                                        </a>
                                                    </c:if>
                                                    <c:if test="${order.orderStatus == 'Completed' && order.allReviewed}">
                                                        <span class="btn btn-outline-success btn-sm disabled">
                                                            <i class="fa fa-check"></i> Đã đánh giá
                                                        </span>
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
                            </c:when>
                            
                            <c:when test="${activeTab == 'wishlist'}">
                            <%-- WISHLIST TAB - Exact structure from wishlist.jsp --%>
                                <div class="d-flex justify-content-between align-items-center mb-4">
                                    <h4 class="mb-0"><i class="fa fa-heart text-danger"></i> Sản phẩm yêu thích (${wishlists.size()})</h4>
                                </div>
                                
                                <c:if test="${not empty wishlists}">
                                    <c:forEach var="item" items="${wishlists}">
                                        <div class="wishlist-item d-flex" id="wishlist-item-${item.wishlistID}">
                                            <a href="${pageContext.request.contextPath}/product-detail?id=${item.productID}">
                                                <c:choose>
                                                    <c:when test="${not empty item.productImage}">
                                                        <img src="${pageContext.request.contextPath}/${item.productImage}" alt="${item.productName}">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <img src="${pageContext.request.contextPath}/img/product/default.jpg" alt="${item.productName}">
                                                    </c:otherwise>
                                                </c:choose>
                                            </a>
                                            <div class="product-info">
                                                <a href="${pageContext.request.contextPath}/product-detail?id=${item.productID}" class="product-name">${item.productName}</a>
                                                <c:if test="${not empty item.brandName}">
                                                    <div class="brand">${item.brandName}</div>
                                                </c:if>
                                                <div class="price">
                                                    <c:choose>
                                                        <c:when test="${item.hasPromotion}">
                                                            <span class="price-old"><fmt:formatNumber value="${item.price}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</span>
                                                            <span class="discount-badge">-${item.discountPercent}%</span>
                                                            <br>
                                                            <fmt:formatNumber value="${item.finalPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                                        </c:when>
                                                        <c:when test="${item.price != null}">
                                                            <fmt:formatNumber value="${item.price}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                                        </c:when>
                                                        <c:otherwise>Liên hệ</c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="stock-status">
                                                    <c:choose>
                                                        <c:when test="${item.totalStock > 10}">
                                                            <span class="text-success"><i class="fa fa-check-circle"></i> Còn hàng</span>
                                                        </c:when>
                                                        <c:when test="${item.totalStock > 0}">
                                                            <span class="text-warning"><i class="fa fa-exclamation-circle"></i> Sắp hết hàng</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-danger"><i class="fa fa-times-circle"></i> Hết hàng</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="actions">
                                                    <c:if test="${item.totalStock > 0}">
                                                        <a href="${pageContext.request.contextPath}/product-detail?id=${item.productID}" class="btn btn-add-cart">
                                                            <i class="fa fa-shopping-cart"></i> Xem & Mua
                                                        </a>
                                                    </c:if>
                                                    <button class="btn btn-remove" onclick="removeFromWishlist(${item.wishlistID})">
                                                        <i class="fa fa-trash"></i> Xóa
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:if>
                                
                                <c:if test="${empty wishlists}">
                                    <div class="empty-wishlist">
                                        <i class="fa fa-heart-o"></i>
                                        <h5 class="text-muted">Danh sách yêu thích trống</h5>
                                        <p class="text-muted">Hãy thêm sản phẩm yêu thích để theo dõi và mua sau</p>
                                        <a href="${pageContext.request.contextPath}/shop" class="btn btn-primary mt-3">
                                            Khám phá sản phẩm
                                        </a>
                                    </div>
                                </c:if>
                            </c:when>
                            
                            <c:when test="${activeTab == 'reviews'}">
                            <%-- REVIEWS TAB --%>
                                <div class="d-flex justify-content-between align-items-center mb-4">
                                    <h4 class="mb-0"><i class="fa fa-star text-danger"></i> Lịch sử đánh giá (${totalReviews})</h4>
                                </div>
                                
                                <c:choose>
                                    <c:when test="${empty reviews}">
                                        <div class="text-center py-5">
                                            <i class="fa fa-star-o" style="font-size: 64px; color: #ddd;"></i>
                                            <h5 class="mt-3 text-muted">Bạn chưa có đánh giá nào</h5>
                                            <p class="text-muted">Hãy mua sắm và đánh giá sản phẩm để chia sẻ trải nghiệm của bạn!</p>
                                            <a href="${pageContext.request.contextPath}/shop" class="btn btn-primary mt-3">Mua sắm ngay</a>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="review" items="${reviews}">
                                            <div class="review-item" style="background: #fff; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); padding: 24px; margin-bottom: 20px;">
                                                
                                                <div class="d-flex mb-3 pb-3" style="border-bottom: 1px solid #eee;">
                                                    <c:choose>
                                                        <c:when test="${not empty review.productImage}">
                                                            <img src="${pageContext.request.contextPath}${review.productImage}" alt="${review.productName}" style="width: 80px; height: 80px; object-fit: contain; border-radius: 8px; background: #f9f9f9;">
                                                        </c:when>
                                                        <c:otherwise>
                                                            <img src="${pageContext.request.contextPath}/img/product/product-placeholder.jpg" alt="Product" style="width: 80px; height: 80px; object-fit: contain; border-radius: 8px; background: #f9f9f9;">
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <div style="flex: 1; padding-left: 15px;">
                                                        <c:if test="${not empty review.brandName}">
                                                            <div style="font-size: 12px; color: #2D5A27; text-transform: uppercase;">${review.brandName}</div>
                                                        </c:if>
                                                        <div style="font-weight: 700; color: #333; margin-bottom: 4px;">${review.productName}</div>
                                                        <a href="${pageContext.request.contextPath}/product-detail?id=${review.productId}" class="text-primary" style="font-size: 13px;">Xem sản phẩm →</a>
                                                    </div>
                                                </div>

                                                <div style="color: #FBBF24; font-size: 18px; margin-bottom: 8px;">
                                                    <c:forEach begin="1" end="5" var="i">
                                                        <c:choose>
                                                            <c:when test="${i <= review.rating}">
                                                                <i class="fa fa-star"></i>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <i class="fa fa-star" style="color: #D1D5DB;"></i>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:forEach>
                                                </div>

                                                <c:if test="${not empty review.reviewTitle}">
                                                    <div style="font-weight: 700; font-size: 16px; margin-bottom: 8px;">${review.reviewTitle}</div>
                                                </c:if>

                                                <c:if test="${not empty review.reviewContent}">
                                                    <div class="review-content-text" style="color: #555; line-height: 1.6; margin-bottom: 12px;">${review.reviewContent}</div>
                                                </c:if>

                                                <div style="font-size: 13px; color: #999;">
                                                    <i class="fa fa-clock-o"></i> Đăng ngày: ${review.reviewDate}
                                                </div>

                                                <c:if test="${not empty review.replyContent}">
                                                    <div style="background: #f0f7f0; border-left: 4px solid #2D5A27; padding: 16px; margin-top: 16px; border-radius: 0 8px 8px 0;">
                                                        <div style="font-weight: 700; color: #2D5A27; margin-bottom: 8px; font-size: 14px;">
                                                            <i class="fa fa-reply"></i> Phản hồi từ Shop
                                                        </div>
                                                        <div style="color: #555; font-size: 14px;">${review.replyContent}</div>
                                                    </div>
                                                </c:if>
                                            </div>
                                        </c:forEach>

                                        <!-- Pagination -->
                                        <c:if test="${totalPages > 1}">
                                            <div class="d-flex justify-content-center mt-4">
                                                <nav>
                                                    <ul class="pagination">
                                                        <c:if test="${currentPage > 1}">
                                                            <li class="page-item">
                                                                <a class="page-link" href="?tab=reviews&page=${currentPage - 1}">«</a>
                                                            </li>
                                                        </c:if>
                                                        
                                                        <c:forEach begin="1" end="${totalPages}" var="i">
                                                            <li class="page-item ${i == currentPage ? 'active' : ''}">
                                                                <a class="page-link" href="?tab=reviews&page=${i}">${i}</a>
                                                            </li>
                                                        </c:forEach>
                                                        
                                                        <c:if test="${currentPage < totalPages}">
                                                            <li class="page-item">
                                                                <a class="page-link" href="?tab=reviews&page=${currentPage + 1}">»</a>
                                                            </li>
                                                        </c:if>
                                                    </ul>
                                                </nav>
                                            </div>
                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                            </c:when>
                            
                            <c:otherwise>
                            <%-- PROFILE TAB (default) --%>
                                <h4 class="mb-4"><i class="fa fa-user text-danger"></i> Thông tin cá nhân</h4>
                                <form action="${pageContext.request.contextPath}/update-profile" method="post">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Họ và tên <span class="text-danger">*</span></label>
                                                <input type="text" name="fullName" class="form-control" value="${customer.fullName}" required>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Email</label>
                                                <input type="email" class="form-control" value="${customer.email}" disabled>
                                                <small class="text-muted">Email không thể thay đổi</small>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Số điện thoại</label>
                                                <input type="tel" name="phone" class="form-control" value="${customer.phone}" placeholder="VD: 0912345678">
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Giới tính</label>
                                                <select name="gender" class="form-control">
                                                    <option value="">-- Chọn --</option>
                                                    <option value="Male" ${customer.gender == 'Male' ? 'selected' : ''}>Nam</option>
                                                    <option value="Female" ${customer.gender == 'Female' ? 'selected' : ''}>Nữ</option>
                                                    <option value="Other" ${customer.gender == 'Other' ? 'selected' : ''}>Khác</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Ngày sinh</label>
                                                <input type="date" name="dateOfBirth" class="form-control" 
                                                       value="<fmt:formatDate value='${customer.dateOfBirth}' pattern='yyyy-MM-dd'/>">
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Ngày tham gia</label>
                                                <input type="text" class="form-control" 
                                                       value="<fmt:formatDate value='${customer.createdDate}' pattern='dd/MM/yyyy'/>" disabled>
                                            </div>
                                        </div>
                                    </div>
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fa fa-save"></i> Lưu thay đổi
                                    </button>
                                </form>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Hidden Avatar Upload Form -->
    <form id="avatarForm" action="${pageContext.request.contextPath}/update-profile" method="post" enctype="multipart/form-data" style="display:none;">
        <input type="hidden" name="action" value="updateAvatar">
        <input type="file" name="avatar" id="avatarInput" accept="image/*">
    </form>

    <!-- Add Address Modal -->
    <div class="modal fade" id="addAddressModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fa fa-plus"></i> Thêm địa chỉ mới</h5>
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                </div>
                <form action="${pageContext.request.contextPath}/address" method="post" id="addAddressForm">
                    <input type="hidden" name="action" value="add">
                    <input type="hidden" name="redirect" value="${redirect}">
                    <div class="modal-body">
                        <div class="form-group">
                            <label>Họ tên người nhận <span class="text-danger">*</span></label>
                            <input type="text" name="recipientName" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label>Số điện thoại <span class="text-danger">*</span></label>
                            <input type="tel" name="phone" class="form-control" required>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Tỉnh/Thành phố <span class="text-danger">*</span></label>
                                    <select name="city" id="addCity" class="form-control" required>
                                        <option value="">-- Chọn Tỉnh/TP --</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Quận/Huyện <span class="text-danger">*</span></label>
                                    <select name="district" id="addDistrict" class="form-control" required disabled>
                                        <option value="">-- Chọn Quận/Huyện --</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label>Phường/Xã</label>
                            <input type="text" name="ward" class="form-control" placeholder="VD: Dịch Vọng">
                        </div>
                        <div class="form-group">
                            <label>Địa chỉ cụ thể <span class="text-danger">*</span></label>
                            <input type="text" name="street" class="form-control" placeholder="Số nhà, tên đường..." required>
                        </div>
                        <div class="form-check">
                            <input type="checkbox" name="isDefault" class="form-check-input" id="addIsDefault">
                            <label class="form-check-label" for="addIsDefault">Đặt làm địa chỉ mặc định</label>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-primary"><i class="fa fa-save"></i> Lưu địa chỉ</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Edit Address Modal -->
    <div class="modal fade" id="editAddressModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fa fa-edit"></i> Sửa địa chỉ</h5>
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                </div>
                <form action="${pageContext.request.contextPath}/address" method="post" id="editAddressForm">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="addressId" id="editAddressId">
                    <input type="hidden" name="redirect" value="${redirect}">
                    <div class="modal-body">
                        <div class="form-group">
                            <label>Họ tên người nhận <span class="text-danger">*</span></label>
                            <input type="text" name="recipientName" id="editRecipientName" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label>Số điện thoại <span class="text-danger">*</span></label>
                            <input type="tel" name="phone" id="editPhone" class="form-control" required>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Tỉnh/Thành phố <span class="text-danger">*</span></label>
                                    <select name="city" id="editCity" class="form-control" required>
                                        <option value="">-- Chọn Tỉnh/TP --</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Quận/Huyện <span class="text-danger">*</span></label>
                                    <select name="district" id="editDistrict" class="form-control" required>
                                        <option value="">-- Chọn Quận/Huyện --</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label>Phường/Xã</label>
                            <input type="text" name="ward" id="editWard" class="form-control">
                        </div>
                        <div class="form-group">
                            <label>Địa chỉ cụ thể <span class="text-danger">*</span></label>
                            <input type="text" name="street" id="editStreet" class="form-control" required>
                        </div>
                        <div class="form-check">
                            <input type="checkbox" name="isDefault" class="form-check-input" id="editIsDefault">
                            <label class="form-check-label" for="editIsDefault">Đặt làm địa chỉ mặc định</label>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-primary"><i class="fa fa-save"></i> Cập nhật</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Modal Hủy đơn hàng -->
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

    <%@include file="../footer.jsp"%>

    <script src="${pageContext.request.contextPath}/js/jquery-3.3.1.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/bootstrap.min.js"></script>

    <script>
        var contextPath = '${pageContext.request.contextPath}';
        var redirectUrl = '${redirect}';
        var citiesData = [];
        var districtsCache = {};
        
        $(window).on('load', function() {
            $(".loader").fadeOut();
            $("#preloder").delay(200).fadeOut("slow");
        });
        setTimeout(function() {
            $(".loader").fadeOut();
            $("#preloder").fadeOut("slow");
        }, 2000);
        
        // Avatar upload
        $('#avatarInput').on('change', function() {
            if (this.files && this.files[0]) {
                var file = this.files[0];
                
                // Validate file size (max 5MB)
                if (file.size > 5 * 1024 * 1024) {
                    alert('File ảnh không được vượt quá 5MB');
                    return;
                }
                
                // Preview
                var reader = new FileReader();
                reader.onload = function(e) {
                    if ($('#avatarPreview').length) {
                        $('#avatarPreview').attr('src', e.target.result);
                    } else {
                        $('#avatarPlaceholder').replaceWith('<img src="' + e.target.result + '" alt="Avatar" class="avatar-img" id="avatarPreview">');
                    }
                };
                reader.readAsDataURL(file);
                
                // Submit form
                $('#avatarForm').submit();
            }
        });
        
        // Load cities when page loads
        $(document).ready(function() {
            loadCities();
        });
        
        function loadCities() {
            $.ajax({
                url: contextPath + '/api/goship/cities',
                method: 'GET',
                dataType: 'json',
                timeout: 10000,
                success: function(data) {
                    if (data.success && data.cities) {
                        citiesData = data.cities;
                        var options = '<option value="">-- Chọn Tỉnh/TP --</option>';
                        data.cities.forEach(function(city) {
                            options += '<option value="' + city.name + '" data-id="' + city.id + '">' + city.name + '</option>';
                        });
                        $('#addCity, #editCity').html(options);
                    }
                },
                error: function() {
                    console.log('Failed to load cities from Goship API');
                }
            });
        }
        
        // Load districts when city changes
        $('#addCity').on('change', function() {
            var cityId = $(this).find(':selected').data('id');
            loadDistricts(cityId, '#addDistrict');
        });
        
        $('#editCity').on('change', function() {
            var cityId = $(this).find(':selected').data('id');
            loadDistricts(cityId, '#editDistrict');
        });
        
        function loadDistricts(cityId, targetSelect) {
            if (!cityId) {
                $(targetSelect).html('<option value="">-- Chọn Quận/Huyện --</option>').prop('disabled', true);
                return;
            }
            
            $(targetSelect).html('<option value="">Đang tải...</option>').prop('disabled', true);
            
            // Check cache
            if (districtsCache[cityId]) {
                renderDistricts(districtsCache[cityId], targetSelect);
                return;
            }
            
            $.ajax({
                url: contextPath + '/api/goship/districts',
                method: 'GET',
                data: { cityId: cityId },
                dataType: 'json',
                timeout: 10000,
                success: function(data) {
                    if (data.success && data.districts) {
                        districtsCache[cityId] = data.districts;
                        renderDistricts(data.districts, targetSelect);
                    } else {
                        $(targetSelect).html('<option value="">-- Không có dữ liệu --</option>');
                    }
                },
                error: function() {
                    $(targetSelect).html('<option value="">-- Lỗi tải dữ liệu --</option>');
                }
            });
        }
        
        function renderDistricts(districts, targetSelect) {
            var options = '<option value="">-- Chọn Quận/Huyện --</option>';
            districts.forEach(function(district) {
                options += '<option value="' + district.name + '" data-id="' + district.id + '">' + district.name + '</option>';
            });
            $(targetSelect).html(options).prop('disabled', false);
        }
        
        function setDefaultAddress(addressId) {
            if (confirm('Đặt địa chỉ này làm mặc định?')) {
                var url = contextPath + '/address?action=setDefault&addressId=' + addressId;
                if (redirectUrl) url += '&redirect=' + encodeURIComponent(redirectUrl);
                window.location.href = url;
            }
        }
        
        function deleteAddress(addressId) {
            if (confirm('Bạn có chắc muốn xóa địa chỉ này?')) {
                var url = contextPath + '/address?action=delete&addressId=' + addressId;
                if (redirectUrl) url += '&redirect=' + encodeURIComponent(redirectUrl);
                window.location.href = url;
            }
        }
        
        function openEditModal(btn) {
            var card = $(btn).closest('.address-card');
            var addressId = card.data('id');
            var name = card.data('name');
            var phone = card.data('phone');
            var street = card.data('street');
            var ward = card.data('ward');
            var district = card.data('district');
            var city = card.data('city');
            var isDefault = card.data('default');
            
            $('#editAddressId').val(addressId);
            $('#editRecipientName').val(name);
            $('#editPhone').val(phone);
            $('#editStreet').val(street);
            $('#editWard').val(ward);
            $('#editIsDefault').prop('checked', isDefault === true || isDefault === 'true');
            
            // Set city and load districts
            $('#editCity').val(city);
            var cityId = $('#editCity').find(':selected').data('id');
            
            if (cityId) {
                // Load districts then set value
                if (districtsCache[cityId]) {
                    renderDistricts(districtsCache[cityId], '#editDistrict');
                    $('#editDistrict').val(district);
                } else {
                    $.ajax({
                        url: contextPath + '/api/goship/districts',
                        method: 'GET',
                        data: { cityId: cityId },
                        dataType: 'json',
                        success: function(data) {
                            if (data.success && data.districts) {
                                districtsCache[cityId] = data.districts;
                                renderDistricts(data.districts, '#editDistrict');
                                $('#editDistrict').val(district);
                            }
                        }
                    });
                }
            }
            
            $('#editAddressModal').modal('show');
        }
        
        // Remove from wishlist
        function removeFromWishlist(wishlistId) {
            if (confirm('Bạn có chắc muốn xóa sản phẩm này khỏi danh sách yêu thích?')) {
                $.ajax({
                    url: contextPath + '/wishlist',
                    method: 'POST',
                    data: { action: 'remove', wishlistId: wishlistId },
                    dataType: 'json',
                    success: function(response) {
                        if (response.success) {
                            // Remove item from DOM with animation
                            $('#wishlist-item-' + wishlistId).fadeOut(300, function() {
                                $(this).remove();
                                // Update count
                                var count = $('.wishlist-item').length;
                                $('h4.mb-0').html('<i class="fa fa-heart text-danger"></i> Sản phẩm yêu thích (' + count + ')');
                                if (count === 0) {
                                    location.reload();
                                }
                            });
                        } else {
                            alert(response.message || 'Có lỗi xảy ra');
                        }
                    },
                    error: function() {
                        alert('Có lỗi xảy ra, vui lòng thử lại');
                    }
                });
            }
        }
        
        // Show cancel order modal
        function showCancelModal(orderId, orderCode) {
            $('#cancelOrderId').val(orderId);
            $('#cancelOrderCode').text(orderCode);
            $('#cancelModal').modal('show');
        }
    </script>
</body>
</html>
