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
                    <c:when test="${param.error == 'no_price'}">Sản phẩm chưa có giá bán!</c:when>
                    <c:when test="${param.error == 'no_variants'}">Sản phẩm chưa có phiên bản nào!</c:when>
                    <c:when test="${param.error == 'no_available_variant'}">Sản phẩm hiện tại hết hàng!</c:when>
                    <c:when test="${param.error == 'variant_not_found'}">Không tìm thấy phiên bản sản phẩm!</c:when>
                    <c:when test="${param.error == 'product_inactive'}">Sản phẩm không còn kinh doanh!</c:when>
                    <c:when test="${param.error == 'unavailable_items'}">Giỏ hàng có sản phẩm không còn bán. Vui lòng xóa trước khi thanh toán!</c:when>
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
                    <!-- Check if there are unavailable items or items exceeding stock -->
                    <c:set var="hasUnavailableItems" value="false" />
                    <c:set var="hasExceededStock" value="false" />
                    <c:forEach var="item" items="${cartItems}">
                        <c:if test="${!item.available}">
                            <c:set var="hasUnavailableItems" value="true" />
                        </c:if>
                        <c:if test="${item.available && item.quantity > item.availableStock}">
                            <c:set var="hasExceededStock" value="true" />
                        </c:if>
                    </c:forEach>
                    
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
                                                        
                                                        <!-- Product Unavailable Warning -->
                                                        <c:if test="${!item.available}">
                                                            <div class="alert alert-danger p-2 mt-2" style="font-size: 13px;">
                                                                <i class="fa fa-ban"></i> <strong>Sản phẩm không còn bán</strong><br>
                                                                <small>Vui lòng xóa khỏi giỏ hàng</small>
                                                            </div>
                                                        </c:if>
                                                        
                                                        <!-- Stock Warning (only if product is available) -->
                                                        <c:if test="${item.available}">
                                                            <c:if test="${item.availableStock == 0}">
                                                                <small class="text-danger"><i class="fa fa-exclamation-triangle"></i> Hết hàng</small>
                                                            </c:if>
                                                            <c:if test="${item.availableStock > 0 && item.availableStock < 10}">
                                                                <small class="text-warning"><i class="fa fa-exclamation-circle"></i> Chỉ còn ${item.availableStock} sản phẩm</small>
                                                            </c:if>
                                                            <!-- Quantity exceeds stock warning -->
                                                            <c:if test="${item.quantity > item.availableStock}">
                                                                <div class="alert alert-danger p-2 mt-2 stock-exceeded-warning" style="font-size: 13px;" data-cart-item-id="${item.cartItemID}">
                                                                    <i class="fa fa-exclamation-triangle"></i> <strong>Vượt quá tồn kho!</strong><br>
                                                                    <small>Chỉ còn ${item.availableStock} sản phẩm. Vui lòng giảm số lượng.</small>
                                                                </div>
                                                            </c:if>
                                                        </c:if>
                                                    </div>
                                                </td>
                                                <td class="quantity__item">
                                                    <c:choose>
                                                        <c:when test="${!item.available}">
                                                            <span class="text-muted">-</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="quantity">
                                                                <div class="pro-qty-2">
                                                                    <input type="text" 
                                                                           class="cart-quantity-input"
                                                                           value="${item.quantity}" 
                                                                           data-min="1" 
                                                                           data-max="${item.availableStock}"
                                                                           data-cart-item-id="${item.cartItemID}"
                                                                           pattern="[0-9]*"
                                                                           inputmode="numeric"
                                                                           ${item.availableStock == 0 ? 'disabled' : ''}>
                                                                </div>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="cart__price">
                                                    <c:choose>
                                                        <c:when test="${!item.available}">
                                                            <span class="text-muted" style="text-decoration: line-through;">
                                                                <fmt:formatNumber value="${item.total}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <fmt:formatNumber value="${item.total}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="cart__close">
                                                    <a href="#" onclick="removeCartItem(${item.cartItemID}); return false;" title="${!item.available ? 'Xóa sản phẩm không còn bán' : 'Xóa khỏi giỏ hàng'}">
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
<!--                                <h6>Mã giảm giá</h6>-->
<!--                                <form action="<%= request.getContextPath() %>/cart/apply-voucher" method="post">
                                    <input type="text" name="voucherCode" placeholder="Nhập mã giảm giá" required>
                                    <button type="submit">Áp dụng</button>
                                </form>-->
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
                                
                                <!-- Warning if there are unavailable items -->
                                <c:if test="${hasUnavailableItems}">
                                    <div class="alert alert-danger mb-3" style="font-size: 14px;">
                                        <i class="fa fa-exclamation-triangle"></i> 
                                        <strong>Không thể thanh toán</strong><br>
                                        Vui lòng xóa các sản phẩm không còn bán khỏi giỏ hàng
                                    </div>
                                </c:if>
                                
                                <!-- Warning if there are items exceeding stock -->
                                <c:if test="${!hasUnavailableItems && hasExceededStock}">
                                    <div class="alert alert-danger mb-3 stock-exceeded-checkout-warning" style="font-size: 14px;">
                                        <i class="fa fa-exclamation-triangle"></i> 
                                        <strong>Không thể thanh toán</strong><br>
                                        Có sản phẩm vượt quá số lượng tồn kho. Vui lòng điều chỉnh số lượng.
                                    </div>
                                </c:if>
                                
                                <!-- Checkout button - disabled if there are unavailable items or exceeded stock -->
                                <c:choose>
                                    <c:when test="${hasUnavailableItems || hasExceededStock}">
                                        <a href="#" class="primary-btn checkout-btn-disabled" style="background-color: #ccc; cursor: not-allowed; pointer-events: none;" onclick="return false;">
                                            Thanh toán
                                            <span class="arrow_right"></span>
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="<%= request.getContextPath() %>/checkout" class="primary-btn checkout-btn-enabled">
                                            Thanh toán
                                            <span class="arrow_right"></span>
                                        </a>
                                    </c:otherwise>
                                </c:choose>
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
    <script src="<%= request.getContextPath() %>/js/cart-header.js"></script>
    
    <script>
        // Auto-hide alerts after 5 seconds
        setTimeout(function() {
            $('.alert').fadeOut('slow');
        }, 5000);
    </script>
</body>

</html>
