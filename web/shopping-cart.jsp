<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="description" content="Shopping Cart - Pickleball Shop">
    <meta name="keywords" content="Pickleball, shopping cart, giỏ hàng">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Giỏ Hàng - Pickleball Shop</title>

    <!-- Google Font -->
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">

    <!-- CSS Styles -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/elegant-icons.css" type="text/css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/magnific-popup.css" type="text/css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/nice-select.css" type="text/css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/owl.carousel.min.css" type="text/css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/slicknav.min.css" type="text/css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css" type="text/css">
</head>

<body>
    <%@include file="header.jsp" %>

    <!-- Breadcrumb Section Begin -->
    <section class="breadcrumb-option">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="breadcrumb__text">
                        <h4>Giỏ Hàng</h4>
                        <div class="breadcrumb__links">
                            <a href="<%= request.getContextPath() %>/Home">Trang chủ</a>
                            <a href="<%= request.getContextPath() %>/shop">Sản phẩm</a>
                            <span>Giỏ hàng</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!-- Breadcrumb Section End -->

    <!-- Success/Error Messages -->
    <c:if test="${param.success == 'added'}">
        <div class="container mt-3">
            <div class="alert alert-success alert-dismissible fade show">
                <button type="button" class="close" data-dismiss="alert">&times;</button>
                <i class="fa fa-check-circle"></i> Đã thêm sản phẩm vào giỏ hàng!
            </div>
        </div>
    </c:if>
    <c:if test="${param.success == 'removed'}">
        <div class="container mt-3">
            <div class="alert alert-success alert-dismissible fade show">
                <button type="button" class="close" data-dismiss="alert">&times;</button>
                <i class="fa fa-check-circle"></i> Đã xóa sản phẩm khỏi giỏ hàng!
            </div>
        </div>
    </c:if>
    <c:if test="${param.success == 'cleared'}">
        <div class="container mt-3">
            <div class="alert alert-success alert-dismissible fade show">
                <button type="button" class="close" data-dismiss="alert">&times;</button>
                <i class="fa fa-check-circle"></i> Đã xóa toàn bộ giỏ hàng!
            </div>
        </div>
    </c:if>
    <c:if test="${param.error != null}">
        <div class="container mt-3">
            <div class="alert alert-danger alert-dismissible fade show">
                <button type="button" class="close" data-dismiss="alert">&times;</button>
                <i class="fa fa-exclamation-circle"></i> 
                <c:choose>
                    <c:when test="${param.error == 'insufficient_stock'}">Sản phẩm không đủ số lượng trong kho!</c:when>
                    <c:when test="${param.error == 'product_not_found'}">Không tìm thấy sản phẩm!</c:when>
                    <c:when test="${param.error == 'invalid_quantity'}">Số lượng không hợp lệ!</c:when>
                    <c:otherwise>Có lỗi xảy ra. Vui lòng thử lại!</c:otherwise>
                </c:choose>
            </div>
        </div>
    </c:if>

    <!-- Shopping Cart Section Begin -->
    <section class="shopping-cart spad">
        <div class="container">
            <c:choose>
                <c:when test="${empty cartItems}">
                    <!-- Empty Cart State -->
                    <div class="row">
                        <div class="col-lg-12">
                            <div class="text-center py-5">
                                <i class="fa fa-shopping-cart" style="font-size: 80px; color: #ddd;"></i>
                                <h3 class="mt-4">Giỏ hàng trống</h3>
                                <p class="text-muted">Bạn chưa có sản phẩm nào trong giỏ hàng</p>
                                <a href="<%= request.getContextPath() %>/shop" class="primary-btn mt-3">
                                    Tiếp tục mua sắm
                                    <span class="arrow_right"></span>
                                </a>
                            </div>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <!-- Cart with Items -->
                    <div class="row">
                        <div class="col-lg-8">
                            <div class="shopping__cart__table">
                                <table>
                                    <thead>
                                        <tr>
                                            <th>Sản phẩm</th>
                                            <th>Số lượng</th>
                                            <th>Tổng</th>
                                            <th></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="item" items="${cartItems}">
                                            <tr>
                                                <td class="product__cart__item">
                                                    <div class="product__cart__item__pic">
                                                        <img src="<%= request.getContextPath() %>${not empty item.productImage ? item.productImage : '/img/product/default.jpg'}" 
                                                             alt="${item.productName}"
                                                             style="width: 90px; height: 90px; object-fit: cover;">
                                                    </div>
                                                    <div class="product__cart__item__text">
                                                        <h6>
                                                            <a href="<%= request.getContextPath() %>/product-detail?id=${item.productID}">
                                                                ${item.productName}
                                                            </a>
                                                        </h6>
                                                        <c:if test="${not empty item.variantSKU}">
                                                            <small class="text-muted">SKU: ${item.variantSKU}</small><br>
                                                        </c:if>
                                                        <c:if test="${not empty item.brandName}">
                                                            <small class="text-muted"><i class="fa fa-tag"></i> ${item.brandName}</small><br>
                                                        </c:if>
                                                        <h5><fmt:formatNumber value="${item.price}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</h5>
                                                        
                                                        <!-- Stock Warning -->
                                                        <c:if test="${item.availableStock == 0}">
                                                            <small class="text-danger"><i class="fa fa-exclamation-triangle"></i> Hết hàng</small>
                                                        </c:if>
                                                        <c:if test="${item.availableStock > 0 && item.availableStock < 10}">
                                                            <small class="text-warning"><i class="fa fa-exclamation-circle"></i> Chỉ còn ${item.availableStock} sản phẩm</small>
                                                        </c:if>
                                                    </div>
                                                </td>
                                                <td class="quantity__item">
                                                    <div class="quantity">
                                                        <div class="pro-qty-2">
                                                            <input type="number" 
                                                                   class="cart-quantity-input"
                                                                   value="${item.quantity}" 
                                                                   min="1" 
                                                                   max="${item.availableStock}"
                                                                   data-cart-item-id="${item.cartItemID}"
                                                                   ${item.availableStock == 0 ? 'disabled' : ''}>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td class="cart__price">
                                                    <fmt:formatNumber value="${item.total}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                                </td>
                                                <td class="cart__close">
                                                    <a href="#" onclick="removeCartItem(${item.cartItemID}); return false;">
                                                        <i class="fa fa-close"></i>
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                            <div class="row">
                                <div class="col-lg-6 col-md-6 col-sm-6">
                                    <div class="continue__btn">
                                        <a href="<%= request.getContextPath() %>/shop">Tiếp tục mua sắm</a>
                                    </div>
                                </div>
                                <div class="col-lg-6 col-md-6 col-sm-6">
                                    <div class="continue__btn update__btn">
                                        <a href="#" onclick="clearCart(); return false;">
                                            <i class="fa fa-trash"></i> Xóa giỏ hàng
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <!-- Discount Code -->
                            <div class="cart__discount">
                                <h6>Mã giảm giá</h6>
                                <form action="<%= request.getContextPath() %>/cart/apply-voucher" method="post">
                                    <input type="text" name="voucherCode" placeholder="Nhập mã giảm giá" required>
                                    <button type="submit">Áp dụng</button>
                                </form>
                            </div>
                            
                            <!-- Cart Total -->
                            <div class="cart__total">
                                <h6>Tổng giỏ hàng</h6>
                                <ul>
                                    <li>Tạm tính 
                                        <span class="cart-subtotal">
                                            <fmt:formatNumber value="${subtotal}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                        </span>
                                    </li>
                                    <c:if test="${discount != null && discount > 0}">
                                        <li>Giảm giá 
                                            <span class="text-danger">
                                                -<fmt:formatNumber value="${discount}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                            </span>
                                        </li>
                                    </c:if>
                                    <li>Tổng cộng 
                                        <span>
                                            <fmt:formatNumber value="${total}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                        </span>
                                    </li>
                                </ul>
                                <a href="<%= request.getContextPath() %>/checkout" class="primary-btn">
                                    Thanh toán
                                    <span class="arrow_right"></span>
                                </a>
                            </div>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </section>
    <!-- Shopping Cart Section End -->

    <%@include file="footer.jsp"%>

    <!-- JS Plugins -->
    <script src="<%= request.getContextPath() %>/js/jquery-3.3.1.min.js"></script>
    <script src="<%= request.getContextPath() %>/js/bootstrap.min.js"></script>
    <script src="<%= request.getContextPath() %>/js/jquery.nice-select.min.js"></script>
    <script src="<%= request.getContextPath() %>/js/jquery.nicescroll.min.js"></script>
    <script src="<%= request.getContextPath() %>/js/jquery.magnific-popup.min.js"></script>
    <script src="<%= request.getContextPath() %>/js/jquery.countdown.min.js"></script>
    <script src="<%= request.getContextPath() %>/js/jquery.slicknav.js"></script>
    <script src="<%= request.getContextPath() %>/js/mixitup.min.js"></script>
    <script src="<%= request.getContextPath() %>/js/owl.carousel.min.js"></script>
    <script src="<%= request.getContextPath() %>/js/main.js"></script>
    
    <!-- Cart JavaScript -->
    <script src="<%= request.getContextPath() %>/js/cart.js"></script>
    
    <script>
        // Auto-hide alerts after 5 seconds
        setTimeout(function() {
            $('.alert').fadeOut('slow');
        }, 5000);
    </script>
</body>

</html>
