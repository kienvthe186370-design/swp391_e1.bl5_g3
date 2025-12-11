<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!-- Mini Cart Dropdown -->
<div class="cart-mini-dropdown" style="display: none;">
    <div class="cart-mini-header">
        <h6>Giỏ hàng của bạn</h6>
        <span class="cart-mini-count">${cartCount != null ? cartCount : 0} sản phẩm</span>
    </div>
    
    <div class="cart-mini-body">
        <c:choose>
            <c:when test="${empty cartItems}">
                <div class="cart-mini-empty">
                    <i class="fa fa-shopping-cart"></i>
                    <p>Giỏ hàng trống</p>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="item" items="${cartItems}" begin="0" end="2">
                    <div class="cart-mini-item">
                        <div class="cart-mini-item-image">
                            <img src="<%= request.getContextPath() %>${not empty item.productImage ? item.productImage : '/img/product/default.jpg'}" 
                                 alt="${item.productName}">
                        </div>
                        <div class="cart-mini-item-info">
                            <h6>${item.productName}</h6>
                            <p class="cart-mini-item-price">
                                ${item.quantity} x <fmt:formatNumber value="${item.price}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                            </p>
                        </div>
                        <div class="cart-mini-item-remove">
                            <a href="#" onclick="removeCartItem(${item.cartItemID}); return false;">
                                <i class="fa fa-close"></i>
                            </a>
                        </div>
                    </div>
                </c:forEach>
                
                <c:if test="${cartItems.size() > 3}">
                    <div class="cart-mini-more">
                        <small>Và ${cartItems.size() - 3} sản phẩm khác...</small>
                    </div>
                </c:if>
            </c:otherwise>
        </c:choose>
    </div>
    
    <c:if test="${not empty cartItems}">
        <div class="cart-mini-footer">
            <div class="cart-mini-total">
                <span>Tổng cộng:</span>
                <span class="cart-mini-total-amount">
                    <fmt:formatNumber value="${cartTotal != null ? cartTotal : 0}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                </span>
            </div>
            <div class="cart-mini-actions">
                <a href="<%= request.getContextPath() %>/cart" class="btn btn-secondary btn-sm btn-block">
                    Xem giỏ hàng
                </a>
                <a href="<%= request.getContextPath() %>/checkout" class="btn btn-primary btn-sm btn-block">
                    Thanh toán
                </a>
            </div>
        </div>
    </c:if>
</div>

<style>
.cart-mini-dropdown {
    position: absolute;
    top: 100%;
    right: 0;
    width: 350px;
    background: white;
    border: 1px solid #ddd;
    border-radius: 5px;
    box-shadow: 0 5px 15px rgba(0,0,0,0.1);
    z-index: 1000;
    margin-top: 10px;
}

.cart-mini-header {
    padding: 15px;
    border-bottom: 1px solid #eee;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.cart-mini-header h6 {
    margin: 0;
    font-size: 16px;
    font-weight: 600;
}

.cart-mini-count {
    font-size: 12px;
    color: #666;
}

.cart-mini-body {
    max-height: 300px;
    overflow-y: auto;
    padding: 10px;
}

.cart-mini-empty {
    text-align: center;
    padding: 40px 20px;
    color: #999;
}

.cart-mini-empty i {
    font-size: 40px;
    margin-bottom: 10px;
}

.cart-mini-item {
    display: flex;
    padding: 10px;
    border-bottom: 1px solid #f5f5f5;
    align-items: center;
}

.cart-mini-item:last-child {
    border-bottom: none;
}

.cart-mini-item-image {
    width: 60px;
    height: 60px;
    margin-right: 10px;
    flex-shrink: 0;
}

.cart-mini-item-image img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    border-radius: 3px;
}

.cart-mini-item-info {
    flex: 1;
}

.cart-mini-item-info h6 {
    font-size: 14px;
    margin: 0 0 5px 0;
    font-weight: 500;
    line-height: 1.3;
}

.cart-mini-item-price {
    font-size: 13px;
    color: #666;
    margin: 0;
}

.cart-mini-item-remove {
    margin-left: 10px;
}

.cart-mini-item-remove a {
    color: #999;
    font-size: 16px;
}

.cart-mini-item-remove a:hover {
    color: #e53637;
}

.cart-mini-more {
    text-align: center;
    padding: 10px;
    color: #666;
}

.cart-mini-footer {
    padding: 15px;
    border-top: 1px solid #eee;
}

.cart-mini-total {
    display: flex;
    justify-content: space-between;
    margin-bottom: 15px;
    font-weight: 600;
}

.cart-mini-total-amount {
    color: #e53637;
}

.cart-mini-actions a {
    margin-bottom: 5px;
}

.cart-mini-actions a:last-child {
    margin-bottom: 0;
}

/* Show dropdown on hover */
.header__nav__option > a:hover + .cart-mini-dropdown,
.cart-mini-dropdown:hover {
    display: block !important;
}
</style>
