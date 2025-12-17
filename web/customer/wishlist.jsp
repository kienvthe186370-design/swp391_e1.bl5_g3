<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="entity.Customer" %>
<%
    Customer customer = (Customer) session.getAttribute("customer");
    if (customer == null) {
        response.sendRedirect(request.getContextPath() + "/login?redirect=wishlist");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh sách yêu thích - Pickleball Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" type="text/css">
    <style>
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
        .sidebar-menu { background: #fff; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .sidebar-menu .list-group-item { border: none; padding: 12px 20px; }
        .sidebar-menu .list-group-item.active { background: #ca1515; border-color: #ca1515; }
        .sidebar-menu .list-group-item:hover:not(.active) { background: #f8f9fa; }
        .empty-wishlist { text-align: center; padding: 60px 20px; }
        .empty-wishlist i { font-size: 80px; color: #ddd; margin-bottom: 20px; }
    </style>
</head>
<body>
    <jsp:include page="../header.jsp" />
    
    <section class="breadcrumb-option">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="breadcrumb__text">
                        <h4>Danh sách yêu thích</h4>
                        <div class="breadcrumb__links">
                            <a href="${pageContext.request.contextPath}/Home">Trang chủ</a>
                            <span>Yêu thích</span>
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
                            <a href="${pageContext.request.contextPath}/customer/orders" class="list-group-item list-group-item-action">
                                <i class="fa fa-shopping-bag"></i> Đơn hàng của tôi
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/addresses" class="list-group-item list-group-item-action">
                                <i class="fa fa-map-marker"></i> Sổ địa chỉ
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/wishlist" class="list-group-item list-group-item-action active">
                                <i class="fa fa-heart"></i> Yêu thích
                            </a>
                        </div>
                    </div>
                </div>
                
                <!-- Main Content -->
                <div class="col-lg-9 col-md-8">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h5 class="mb-0">Sản phẩm yêu thích (${wishlist.size()})</h5>
                    </div>
                    
                    <c:if test="${not empty wishlist}">
                        <c:forEach var="item" items="${wishlist}">
                            <div class="wishlist-item d-flex" id="wishlist-item-${item.wishlistID}">
                                <a href="${pageContext.request.contextPath}/product-detail?id=${item.productID}">
                                    <c:choose>
                                        <c:when test="${not empty item.productImage}">
                                            <img src="${pageContext.request.contextPath}${item.productImage}" alt="${item.productName}">
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
                    
                    <c:if test="${empty wishlist}">
                        <div class="empty-wishlist">
                            <i class="fa fa-heart-o"></i>
                            <h5 class="text-muted">Danh sách yêu thích trống</h5>
                            <p class="text-muted">Hãy thêm sản phẩm yêu thích để theo dõi và mua sau</p>
                            <a href="${pageContext.request.contextPath}/shop" class="btn btn-primary mt-3">
                                Khám phá sản phẩm
                            </a>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </section>
    
    <jsp:include page="../footer.jsp" />
    
    <script src="${pageContext.request.contextPath}/js/jquery-3.3.1.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/bootstrap.min.js"></script>
    <script>
    function removeFromWishlist(wishlistId) {
        if (!confirm('Bạn có chắc muốn xóa sản phẩm này khỏi danh sách yêu thích?')) return;
        
        $.ajax({
            url: '${pageContext.request.contextPath}/wishlist',
            type: 'POST',
            data: { action: 'remove', wishlistId: wishlistId },
            dataType: 'json',
            success: function(res) {
                if (res.success) {
                    $('#wishlist-item-' + wishlistId).fadeOut(300, function() {
                        $(this).remove();
                        // Cập nhật số lượng
                        var count = $('.wishlist-item').length;
                        $('h5.mb-0').text('Sản phẩm yêu thích (' + count + ')');
                        if (count === 0) {
                            location.reload();
                        }
                    });
                } else {
                    alert(res.message || 'Có lỗi xảy ra');
                }
            },
            error: function() {
                alert('Có lỗi xảy ra, vui lòng thử lại');
            }
        });
    }
    </script>
</body>
</html>
