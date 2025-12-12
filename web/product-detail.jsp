<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>${product.productName} - Pickleball Shop</title>

    <!-- Google Font -->
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">

    <!-- Css Styles -->
    <link rel="stylesheet" href="css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="css/elegant-icons.css" type="text/css">
    <link rel="stylesheet" href="css/magnific-popup.css" type="text/css">
    <link rel="stylesheet" href="css/nice-select.css" type="text/css">
    <link rel="stylesheet" href="css/owl.carousel.min.css" type="text/css">
    <link rel="stylesheet" href="css/slicknav.min.css" type="text/css">
    <link rel="stylesheet" href="css/style.css" type="text/css">
    
    <style>
        * {
            box-sizing: border-box;
        }
        
        .breadcrumb-option {
            background: linear-gradient(135deg, #ca1515 0%, #a01010 100%);
            padding: 20px 0;
            box-shadow: 0 2px 10px rgba(202, 21, 21, 0.1);
        }
        
        .breadcrumb-option .breadcrumb__text h4 {
            color: white;
            margin: 0;
            font-size: 24px;
            font-weight: 700;
        }
        
        .breadcrumb-option .breadcrumb__links {
            margin-top: 8px;
        }
        
        .breadcrumb-option .breadcrumb__links a,
        .breadcrumb-option .breadcrumb__links span {
            color: rgba(255, 255, 255, 0.9);
            font-size: 14px;
            transition: all 0.3s;
        }
        
        .breadcrumb-option .breadcrumb__links a:hover {
            color: white;
            text-decoration: underline;
        }
        
        .product-detail {
            padding: 60px 0;
            background: #f8f9fa;
        }
        
        .product__details__pic {
            background: white;
            border-radius: 16px;
            padding: 30px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
            position: sticky;
            top: 100px;
        }
        
        .product__details__pic__item {
            position: relative;
            overflow: hidden;
            border-radius: 12px;
            background: #f8f9fa;
        }
        
        .product__details__pic__item img {
            width: 100%;
            border-radius: 12px;
            transition: transform 0.5s ease;
        }
        
        .product__details__pic__item:hover img {
            transform: scale(1.05);
        }
        
        .product__details__pic__slider {
            margin-top: 20px;
            display: flex;
            gap: 10px;
        }
        
        .product__details__pic__slider .col-3 {
            padding: 0 5px;
        }
        
        .product__details__pic__slider img {
            width: 100%;
            height: 90px;
            object-fit: cover;
            border: 3px solid #e1e1e1;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
            background: #f8f9fa;
        }
        
        .product__details__pic__slider img:hover {
            border-color: #ca1515;
            transform: translateY(-3px);
            box-shadow: 0 4px 12px rgba(202, 21, 21, 0.2);
        }
        
        .product__details__pic__slider img.active {
            border-color: #ca1515;
            box-shadow: 0 0 0 2px rgba(202, 21, 21, 0.2);
        }
        
        .product__details__text {
            background: white;
            padding: 40px;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
        }
        
        .product__details__text h3 {
            font-size: 32px;
            font-weight: 800;
            margin-bottom: 15px;
            color: #1a1a1a;
            line-height: 1.3;
        }
        
        .product__details__text .product__brand {
            display: inline-block;
            background: linear-gradient(135deg, #ca1515 0%, #a01010 100%);
            color: white;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            padding: 6px 16px;
            border-radius: 20px;
            margin-bottom: 15px;
            font-weight: 600;
        }
        
        .product__details__text .product__status {
            font-size: 14px;
            color: #666;
            margin-bottom: 25px;
            padding: 12px 0;
            border-bottom: 1px solid #e1e1e1;
        }
        
        .product__details__text .product__status span {
            color: #28a745;
            font-weight: 700;
            background: #d4edda;
            padding: 4px 12px;
            border-radius: 6px;
        }
        
        .product__details__price {
            margin-bottom: 20px;
        }
        
        .product__details__price .price-display {
            margin-bottom: 10px;
        }
        
        .product__details__price .current-price {
            font-size: 36px;
            font-weight: 800;
            color: #1a1a1a;
            display: block;
        }
        
        .product__details__price .contact-price {
            font-size: 36px;
            font-weight: 800;
            color: #1a1a1a;
        }
        
        .product__details__price .price-discount {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .product__details__price .old-price {
            font-size: 20px;
            color: #999;
            text-decoration: line-through;
            font-weight: 500;
        }
        
        .product__details__price .discount-badge {
            display: inline-block;
            background: transparent;
            color: #dc2626;
            padding: 0;
            border-radius: 0;
            font-size: 20px;
            font-weight: 700;
            box-shadow: none;
        }
        
        .product__details__quantity {
            margin: 30px 0 15px 0;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .pro-qty {
            width: 160px;
            height: 55px;
            border: 2px solid #d1d5db;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 15px;
            background: white;
            transition: all 0.3s;
        }
        
        .pro-qty:hover {
            border-color: #9ca3af;
        }
        
        .pro-qty input {
            width: 60px;
            border: none;
            text-align: center;
            font-size: 20px;
            font-weight: 700;
            color: #1a1a1a;
        }
        
        .pro-qty .qtybtn {
            cursor: pointer;
            font-size: 24px;
            color: #6b7280;
            font-weight: 400;
            width: 30px;
            height: 30px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s;
            user-select: none;
        }
        
        .pro-qty .qtybtn:hover {
            color: #1a1a1a;
        }
        
        .pro-qty .qtybtn:active {
            transform: scale(0.9);
        }
        
        /* Hide any extra elements added by JS */
        .pro-qty .qtybtn ins,
        .pro-qty .qtybtn fm,
        .pro-qty .qtybtn span:not(.qtybtn) {
            display: none !important;
        }
        
        /* Hide Font Awesome icons added by template JS */
        .pro-qty .fa-angle-up,
        .pro-qty .fa-angle-down,
        .pro-qty .dec,
        .pro-qty .inc {
            display: none !important;
        }
        
        /* Ensure only text content shows */
        .pro-qty .qtybtn::before,
        .pro-qty .qtybtn::after {
            display: none !important;
        }
        
        .primary-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            padding: 16px 40px;
            background: linear-gradient(135deg, #ca1515 0%, #a01010 100%);
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 700;
            font-size: 15px;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            box-shadow: 0 2px 8px rgba(202, 21, 21, 0.2);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .primary-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(202, 21, 21, 0.3);
            color: white;
        }
        
        .primary-btn:active {
            transform: translateY(0);
        }
        
        .primary-btn.outline {
            background: white;
            color: #d91f4e;
            border: 2px solid #d91f4e;
            box-shadow: none;
            flex: 1;
            height: 55px;
        }
        
        .primary-btn.outline:hover {
            background: #fef2f2;
            color: #d91f4e;
            border-color: #d91f4e;
        }
        
        .primary-btn.buy-now-btn {
            width: 100%;
            height: 55px;
            background: linear-gradient(135deg, #d91f4e 0%, #c2185b 100%);
            margin-top: 0;
            font-size: 16px;
        }
        
        .primary-btn.buy-now-btn:hover {
            background: linear-gradient(135deg, #c2185b 0%, #ad1457 100%);
        }
        
        .product__details__features {
            margin-top: 35px;
            padding: 25px;
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border-radius: 12px;
            border: 1px solid #e1e1e1;
        }
        
        .product__details__features ul {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        
        .product__details__features ul li {
            padding: 15px 0;
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
            display: flex;
            align-items: center;
            font-size: 15px;
            color: #333;
        }
        
        .product__details__features ul li:last-child {
            border-bottom: none;
            padding-bottom: 0;
        }
        
        .product__details__features ul li i {
            color: #ca1515;
            margin-right: 15px;
            font-size: 22px;
            width: 30px;
            text-align: center;
        }
        
        .product__details__tab {
            margin-top: 60px;
            background: white;
            border-radius: 16px;
            padding: 30px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
        }
        
        .product__details__tab .nav-tabs {
            border-bottom: 2px solid #e1e1e1;
            margin-bottom: 30px;
        }
        
        .product__details__tab .nav-tabs .nav-link {
            border: none;
            color: #666;
            font-weight: 600;
            padding: 15px 30px;
            border-bottom: 3px solid transparent;
            transition: all 0.3s;
            font-size: 15px;
        }
        
        .product__details__tab .nav-tabs .nav-link:hover {
            color: #ca1515;
        }
        
        .product__details__tab .nav-tabs .nav-link.active {
            color: #ca1515;
            border-bottom-color: #ca1515;
            background: transparent;
        }
        
        .product__details__tab .tab-content {
            padding: 0;
            line-height: 1.8;
            color: #555;
        }
        
        .product__details__tab__content h5 {
            color: #1a1a1a;
            font-weight: 700;
            margin-bottom: 20px;
        }
        
        .product__details__tab__content ul {
            padding-left: 20px;
        }
        
        .product__details__tab__content ul li {
            margin-bottom: 10px;
            color: #555;
        }
        
        .related-products {
            margin-top: 60px;
            padding: 40px;
            background: white;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
        }
        
        .related-products h3 {
            font-size: 28px;
            font-weight: 800;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 3px solid #ca1515;
            color: #1a1a1a;
            position: relative;
        }
        
        .related-products h3:after {
            content: '';
            position: absolute;
            bottom: -3px;
            left: 0;
            width: 80px;
            height: 3px;
            background: #ca1515;
        }
        
        .variant-selector {
            margin: 25px 0;
        }
        
        .variant-selector label {
            display: block;
            font-weight: 700;
            margin-bottom: 12px;
            color: #1a1a1a;
            font-size: 15px;
        }
        
        .variant-selector select {
            width: 100%;
            padding: 14px 18px;
            border: 2px solid #e1e1e1;
            border-radius: 10px;
            font-size: 15px;
            transition: all 0.3s;
            background: white;
            cursor: pointer;
        }
        
        .variant-selector select:hover,
        .variant-selector select:focus {
            border-color: #ca1515;
            outline: none;
        }
        
        /* Enhanced product cards in related section */
        .related-products .product__item {
            transition: all 0.3s;
            border-radius: 12px;
            overflow: hidden;
            background: white;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
        }
        
        .related-products .product__item:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
        }
        
        .related-products .product__item__pic {
            border-radius: 12px 12px 0 0;
        }
        
        .related-products .product__item__text {
            padding: 15px;
        }
        
        .related-products .product__brand__tag {
            margin-bottom: 8px;
        }
        
        .related-products .product__brand__tag small {
            color: #999;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .related-products .product__name {
            margin-bottom: 12px;
            min-height: 40px;
        }
        
        .related-products .product__name a {
            font-size: 14px;
            font-weight: 600;
            color: #1a1a1a;
            text-decoration: none;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            line-height: 1.4;
            transition: color 0.3s;
        }
        
        .related-products .product__name a:hover {
            color: #ca1515;
        }
        
        .related-products .product__item__text h5 {
            font-size: 18px;
            font-weight: 700;
            color: #ca1515;
            margin: 0;
        }
        
        @media (max-width: 991px) {
            .product__details__pic {
                position: relative;
                top: 0;
                margin-bottom: 30px;
            }
            
            .product__details__text {
                padding: 30px 20px;
            }
            
            .product__details__text h3 {
                font-size: 26px;
            }
            
            .product__details__price {
                font-size: 32px;
            }
        }
    </style>
</head>

<body>
    <%@include file="header.jsp" %>

    <!-- Breadcrumb Section Begin -->
    <section class="breadcrumb-option">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="breadcrumb__text">
                        <h4>${product.productName}</h4>
                        <div class="breadcrumb__links">
                            <a href="${pageContext.request.contextPath}/">Trang chủ</a>
                            <span>/</span>
                            <a href="${pageContext.request.contextPath}/shop">Vợt Pickleball</a>
                            <span>/</span>
                            <span>${product.productName}</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!-- Breadcrumb Section End -->

    <!-- Product Details Section Begin -->
    <section class="product-detail">
        <div class="container">
            <div class="row">
                <!-- Product Images -->
                <div class="col-lg-6">
                    <div class="product__details__pic">
                        <div class="product__details__pic__item">
                            <c:choose>
                                <c:when test="${not empty images && images.size() > 0}">
                                    <img id="mainImage" src="${pageContext.request.contextPath}${images[0].imageURL}" alt="${product.productName}">
                                </c:when>
                                <c:otherwise>
                                    <img id="mainImage" src="${pageContext.request.contextPath}/img/product/default.jpg" alt="${product.productName}">
                                </c:otherwise>
                            </c:choose>
                        </div>
                        
                        <!-- Thumbnail Images -->
                        <c:if test="${not empty images && images.size() > 1}">
                            <div class="product__details__pic__slider">
                                <div class="row">
                                    <c:forEach var="img" items="${images}" varStatus="status">
                                        <div class="col-3">
                                            <img src="${pageContext.request.contextPath}${img.imageURL}" 
                                                 alt="${product.productName}"
                                                 class="${status.index == 0 ? 'active' : ''}"
                                                 onclick="changeMainImage('${pageContext.request.contextPath}${img.imageURL}', this)">
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </c:if>
                    </div>
                </div>

                <!-- Product Info -->
                <div class="col-lg-6">
                    <div class="product__details__text">
                        <!-- Brand -->
                        <c:if test="${not empty product.brandName}">
                            <span class="product__brand">Thương hiệu: ${product.brandName}</span>
                        </c:if>
                        
                        <!-- Product Name -->
                        <h3>${product.productName}</h3>
                        
                        <!-- Status -->
                        <div class="product__status">
                            Mã sản phẩm: <span>Đang cập nhật</span>
                        </div>
                        
                        <!-- Price -->
                        <div class="product__details__price">
                            <c:choose>
                                <c:when test="${not empty variants && variants.size() > 0}">
                                    <c:set var="minPrice" value="${variants[0].sellingPrice}"/>
                                    <c:set var="maxPrice" value="${variants[0].sellingPrice}"/>
                                    <c:set var="hasComparePrice" value="false"/>
                                    <c:set var="comparePrice" value="0"/>
                                    
                                    <c:forEach var="variant" items="${variants}">
                                        <c:if test="${variant.sellingPrice < minPrice}">
                                            <c:set var="minPrice" value="${variant.sellingPrice}"/>
                                        </c:if>
                                        <c:if test="${variant.sellingPrice > maxPrice}">
                                            <c:set var="maxPrice" value="${variant.sellingPrice}"/>
                                        </c:if>
                                        <c:if test="${not empty variant.compareAtPrice && variant.compareAtPrice > variant.sellingPrice}">
                                            <c:set var="hasComparePrice" value="true"/>
                                            <c:set var="comparePrice" value="${variant.compareAtPrice}"/>
                                        </c:if>
                                    </c:forEach>
                                    
                                    <c:choose>
                                        <c:when test="${minPrice != null && minPrice > 0}">
                                            <div class="price-display">
                                                <span class="current-price">
                                                    <c:choose>
                                                        <c:when test="${minPrice == maxPrice}">
                                                            <fmt:formatNumber value="${minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                                        </c:when>
                                                        <c:otherwise>
                                                            <fmt:formatNumber value="${minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫ - 
                                                            <fmt:formatNumber value="${maxPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                                        </c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </div>
                                            
                                            <!-- Show old price and discount if exists -->
                                            <c:if test="${hasComparePrice}">
                                                <div class="price-discount">
                                                    <span class="old-price">
                                                        <fmt:formatNumber value="${comparePrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                                    </span>
                                                    <c:set var="discountPercent" value="${((comparePrice - minPrice) / comparePrice) * 100}"/>
                                                    <span class="discount-badge">-<fmt:formatNumber value="${discountPercent}" maxFractionDigits="0"/>%</span>
                                                </div>
                                            </c:if>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="contact-price">Liên hệ</span>
                                        </c:otherwise>
                                    </c:choose>
                                </c:when>
                                <c:otherwise>
                                    <span class="contact-price">Liên hệ</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        
                        <!-- Variant Selector -->
                        <c:if test="${not empty variants && variants.size() > 1}">
                            <div class="variant-selector">
                                <label>Chọn phiên bản:</label>
                                <select id="variantSelect" onchange="updateVariantInfo()">
                                    <c:forEach var="variant" items="${variants}" varStatus="status">
                                        <option value="${variant.variantID}" 
                                                data-price="${variant.sellingPrice}"
                                                data-compare-price="${variant.compareAtPrice}"
                                                data-stock="${variant.stock}"
                                                data-sku="${variant.sku}">
                                            ${variant.sku} - <fmt:formatNumber value="${variant.sellingPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                            <c:if test="${variant.stock <= 0}"> (Hết hàng)</c:if>
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                        </c:if>
                        
                        <!-- Quantity and Add to Cart -->
                        <div class="product__details__quantity">
                            <div class="pro-qty">
                                <span class="qtybtn" onclick="decreaseQty()">-</span>
                                <input type="text" id="quantity" value="1" readonly>
                                <span class="qtybtn" onclick="increaseQty()">+</span>
                            </div>
                            <button class="primary-btn outline" onclick="addToCart()">
                                BỎ VÀO GIỎ HÀNG
                            </button>
                        </div>
                        
                        <button class="primary-btn buy-now-btn" onclick="buyNow()">
                            MUA NGAY
                        </button>
                        
                        <!-- Features -->
                        <div class="product__details__features">
                            <ul>
                                <li>
                                    <i class="fa fa-truck"></i>
                                    <span>Giao hàng toàn quốc</span>
                                </li>
                                <li>
                                    <i class="fa fa-check-circle"></i>
                                    <span>Tích điểm tất cả sản phẩm</span>
                                </li>
                                <li>
                                    <i class="fa fa-percent"></i>
                                    <span>Giảm 5% khi thanh toán online</span>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Product Tabs -->
            <div class="product__details__tab">
                <ul class="nav nav-tabs" role="tablist">
                    <li class="nav-item">
                        <a class="nav-link active" data-toggle="tab" href="#tabs-1" role="tab">Mô tả sản phẩm</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" data-toggle="tab" href="#tabs-2" role="tab">Chính sách giao hàng</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" data-toggle="tab" href="#tabs-3" role="tab">Chính sách đổi trả</a>
                    </li>
                </ul>
                <div class="tab-content">
                    <div class="tab-pane fade show active" id="tabs-1" role="tabpanel">
                        <div class="product__details__tab__content">
                            <c:choose>
                                <c:when test="${not empty product.description}">
                                    <div>${product.description}</div>
                                </c:when>
                                <c:otherwise>
                                    <p>Thông tin chi tiết về sản phẩm đang được cập nhật.</p>
                                </c:otherwise>
                            </c:choose>
                            
                            <c:if test="${not empty product.specifications}">
                                <h5 style="margin-top: 30px; font-weight: 700;">Thông số kỹ thuật:</h5>
                                <div>${product.specifications}</div>
                            </c:if>
                        </div>
                    </div>
                    <div class="tab-pane fade" id="tabs-2" role="tabpanel">
                        <div class="product__details__tab__content">
                            <h5>Chính sách giao hàng</h5>
                            <ul>
                                <li>Giao hàng toàn quốc, nhận hàng trong vòng 2-5 ngày</li>
                                <li>Miễn phí vận chuyển cho đơn hàng từ 500.000đ</li>
                                <li>Kiểm tra hàng trước khi thanh toán</li>
                                <li>Hỗ trợ đổi trả trong vòng 7 ngày nếu sản phẩm lỗi</li>
                            </ul>
                        </div>
                    </div>
                    <div class="tab-pane fade" id="tabs-3" role="tabpanel">
                        <div class="product__details__tab__content">
                            <h5>Chính sách đổi trả</h5>
                            <ul>
                                <li>Đổi trả trong vòng 7 ngày kể từ ngày nhận hàng</li>
                                <li>Sản phẩm còn nguyên tem mác, chưa qua sử dụng</li>
                                <li>Có hóa đơn mua hàng</li>
                                <li>Liên hệ hotline: 0988369892 để được hỗ trợ</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Related Products -->
            <c:if test="${not empty relatedProducts}">
                <div class="related-products">
                    <h3>Sản phẩm cùng phân khúc</h3>
                    <div class="row">
                        <c:forEach var="relProduct" items="${relatedProducts}">
                            <div class="col-lg-3 col-md-6 col-sm-6">
                                <div class="product__item">
                                    <div class="product__item__pic set-bg" data-setbg="${not empty relProduct.mainImageUrl ? pageContext.request.contextPath.concat(relProduct.mainImageUrl) : pageContext.request.contextPath.concat('/img/product/default.jpg')}">
                                        <c:if test="${not empty relProduct.createdDate}">
                                            <jsp:useBean id="now2" class="java.util.Date"/>
                                            <c:set var="daysDiff2" value="${(now2.time - relProduct.createdDate.time) / (1000 * 60 * 60 * 24)}"/>
                                            <c:if test="${daysDiff2 <= 30}">
                                                <span class="label">New</span>
                                            </c:if>
                                        </c:if>
                                        <ul class="product__hover">
                                            <li><a href="#"><img src="${pageContext.request.contextPath}/img/icon/heart.png" alt=""></a></li>
                                            <li><a href="${pageContext.request.contextPath}/product-detail?id=${relProduct.productID}"><img src="${pageContext.request.contextPath}/img/icon/search.png" alt=""></a></li>
                                        </ul>
                                    </div>
                                    <div class="product__item__text">
                                        <c:if test="${not empty relProduct.brandName}">
                                            <div class="product__brand__tag">
                                                <small>${relProduct.brandName}</small>
                                            </div>
                                        </c:if>
                                        <h6 class="product__name">
                                            <a href="${pageContext.request.contextPath}/product-detail?id=${relProduct.productID}" title="${relProduct.productName}">
                                                ${relProduct.productName}
                                            </a>
                                        </h6>
                                        <c:choose>
                                            <c:when test="${relProduct.minPrice != null && relProduct.maxPrice != null}">
                                                <c:choose>
                                                    <c:when test="${relProduct.minPrice.compareTo(relProduct.maxPrice) == 0}">
                                                        <h5><fmt:formatNumber value="${relProduct.minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</h5>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <h5><fmt:formatNumber value="${relProduct.minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫ - <fmt:formatNumber value="${relProduct.maxPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</h5>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:when>
                                            <c:otherwise>
                                                <h5>Liên hệ</h5>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </c:if>
            
            <!-- Same Category Products -->
            <div class="related-products">
                <h3>Sản phẩm cùng loại</h3>
                <div class="row">
                    <c:forEach var="sameProduct" items="${relatedProducts}" begin="0" end="3">
                        <div class="col-lg-3 col-md-6 col-sm-6">
                            <div class="product__item">
                                <div class="product__item__pic set-bg" data-setbg="${not empty sameProduct.mainImageUrl ? pageContext.request.contextPath.concat(sameProduct.mainImageUrl) : pageContext.request.contextPath.concat('/img/product/default.jpg')}">
                                    <ul class="product__hover">
                                        <li><a href="#"><img src="${pageContext.request.contextPath}/img/icon/heart.png" alt=""></a></li>
                                        <li><a href="${pageContext.request.contextPath}/product-detail?id=${sameProduct.productID}"><img src="${pageContext.request.contextPath}/img/icon/search.png" alt=""></a></li>
                                    </ul>
                                </div>
                                <div class="product__item__text">
                                    <c:if test="${not empty sameProduct.brandName}">
                                        <div class="product__brand__tag">
                                            <small>${sameProduct.brandName}</small>
                                        </div>
                                    </c:if>
                                    <h6 class="product__name">
                                        <a href="${pageContext.request.contextPath}/product-detail?id=${sameProduct.productID}" title="${sameProduct.productName}">
                                            ${sameProduct.productName}
                                        </a>
                                    </h6>
                                    <c:choose>
                                        <c:when test="${sameProduct.minPrice != null && sameProduct.maxPrice != null}">
                                            <h5><fmt:formatNumber value="${sameProduct.minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</h5>
                                        </c:when>
                                        <c:otherwise>
                                            <h5>Liên hệ</h5>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </div>
    </section>
    <!-- Product Details Section End -->

    <%@include file="footer.jsp" %>

    <!-- Js Plugins -->
    <script src="js/jquery-3.3.1.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <script src="js/jquery.nice-select.min.js"></script>
    <script src="js/jquery.nicescroll.min.js"></script>
    <script src="js/jquery.magnific-popup.min.js"></script>
    <script src="js/jquery.countdown.min.js"></script>
    <script src="js/jquery.slicknav.js"></script>
    <script src="js/mixitup.min.js"></script>
    <script src="js/owl.carousel.min.js"></script>
    <script src="js/main.js"></script>
    
    <script>
        // Change main image when clicking thumbnail
        function changeMainImage(imageUrl, element) {
            document.getElementById('mainImage').src = imageUrl;
            
            // Remove active class from all thumbnails
            document.querySelectorAll('.product__details__pic__slider img').forEach(img => {
                img.classList.remove('active');
            });
            
            // Add active class to clicked thumbnail
            element.classList.add('active');
        }
        
        // Quantity controls
        function increaseQty() {
            const qtyInput = document.getElementById('quantity');
            let currentQty = parseInt(qtyInput.value);
            qtyInput.value = currentQty + 1;
        }
        
        function decreaseQty() {
            const qtyInput = document.getElementById('quantity');
            let currentQty = parseInt(qtyInput.value);
            if (currentQty > 1) {
                qtyInput.value = currentQty - 1;
            }
        }
        
        // Update variant info when selecting different variant
        function updateVariantInfo() {
            const select = document.getElementById('variantSelect');
            const selectedOption = select.options[select.selectedIndex];
            
            const price = selectedOption.getAttribute('data-price');
            const comparePrice = selectedOption.getAttribute('data-compare-price');
            const stock = selectedOption.getAttribute('data-stock');
            
            // Update price display (you can add more logic here)
            console.log('Selected variant:', {price, comparePrice, stock});
        }
        
        // Add to cart
        function addToCart() {
            const quantity = document.getElementById('quantity').value;
            const productId = ${product.productID};
            
            // Get selected variant if exists
            const variantSelect = document.getElementById('variantSelect');
            const variantId = variantSelect ? variantSelect.value : null;
            
            // TODO: Implement add to cart logic
            alert('Thêm ' + quantity + ' sản phẩm vào giỏ hàng');
            
            // Redirect to cart or show notification
            // window.location.href = '${pageContext.request.contextPath}/cart';
        }
        
        // Buy now
        function buyNow() {
            addToCart();
            window.location.href = '${pageContext.request.contextPath}/checkout';
        }
    </script>
</body>
</html>
