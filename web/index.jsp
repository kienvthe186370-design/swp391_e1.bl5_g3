<%-- 
    Document   : index
    Created on : Dec 4, 2025, 2:07:45 PM
    Author     : xuand
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.regex.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="zxx">

<head>
    <meta charset="UTF-8">
    <meta name="description" content="Male_Fashion Template">
    <meta name="keywords" content="Male_Fashion, unica, creative, html">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Male-Fashion | Template</title>

    <!-- Google Font -->
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap"
    rel="stylesheet">

    <!-- Css Styles -->
    <link rel="stylesheet" href="css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="css/elegant-icons.css" type="text/css">
    <link rel="stylesheet" href="css/magnific-popup.css" type="text/css">
    <link rel="stylesheet" href="css/nice-select.css" type="text/css">
    <link rel="stylesheet" href="css/owl.carousel.min.css" type="text/css">
    <link rel="stylesheet" href="css/slicknav.min.css" type="text/css">
    <link rel="stylesheet" href="css/style.css" type="text/css">
</head>

<body>
    <%@include file="header.jsp" %>

    <!-- Hero Section Begin -->
    <section class="hero">
    <div class="hero__slider owl-carousel">

        <c:forEach items="${sliders}" var="s">
            <div class="hero__items set-bg" data-setbg="${s.imageURL}">
                <div class="container">
                    <div class="row">
                        <div class="col-xl-5 col-lg-7 col-md-8">
                            <div class="hero__text">

                                <h2>${s.title}</h2>

                                <a href="${s.linkURL}" class="primary-btn">
                                    Xem ngay
                                    <span class="arrow_right"></span>
                                </a>

                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </c:forEach>

    </div>
</section>
    <!-- Hero Section End -->

    <!-- Top Selling Products by Category Section Begin -->
    <section class="categories spad">
        <div class="container">
            <!-- Top Vợt Bán Chạy -->
            <div class="row mb-5">
                <div class="col-lg-12">
                    <div class="section-title">
                        <span>Sản phẩm bán chạy</span>
                        <h2>Top Vợt Pickleball</h2>
                    </div>
                </div>
            </div>
            <div class="row">
                <c:forEach var="product" items="${topRackets}">
                    <div class="col-lg-3 col-md-6 col-sm-6">
                        <div class="product__item">
                            <div class="product__item__pic set-bg" data-setbg="${not empty product.mainImageUrl ? pageContext.request.contextPath.concat(product.mainImageUrl) : pageContext.request.contextPath.concat('/img/product/default.jpg')}" 
                                 style="cursor: pointer;" 
                                 onclick="window.location.href='${pageContext.request.contextPath}/product-detail?id=${product.productID}'">
                                
                                <c:if test="${product.totalSold > 0}">
                                    <span class="label" style="background: #e53637;">Bán chạy</span>
                                </c:if>
                                
                                <ul class="product__hover">
                                    <li><a href="#" title="Thêm vào yêu thích" onclick="event.stopPropagation(); return false;"><img src="${pageContext.request.contextPath}/img/icon/heart.png" alt=""></a></li>
                                    <li><a href="${pageContext.request.contextPath}/product-detail?id=${product.productID}" title="Xem chi tiết" onclick="event.stopPropagation();"><img src="${pageContext.request.contextPath}/img/icon/search.png" alt=""></a></li>
                                </ul>
                            </div>
                            <div class="product__item__text">
                                <c:if test="${not empty product.brandName}">
                                    <div class="product__brand" style="margin-bottom: 8px;">
                                        <small style="color: #888; font-size: 12px;">
                                            <i class="fa fa-tag"></i> ${product.brandName}
                                        </small>
                                    </div>
                                </c:if>
                                
                                <h6><a href="${pageContext.request.contextPath}/product-detail?id=${product.productID}">${product.productName}</a></h6>
                                
                                <c:choose>
                                    <c:when test="${product.minPrice != null && product.maxPrice != null}">
                                        <c:choose>
                                            <c:when test="${product.minPrice.compareTo(product.maxPrice) == 0}">
                                                <h5><fmt:formatNumber value="${product.minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</h5>
                                            </c:when>
                                            <c:otherwise>
                                                <h5><fmt:formatNumber value="${product.minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫ - <fmt:formatNumber value="${product.maxPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</h5>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:when>
                                    <c:otherwise>
                                        <h5>Liên hệ</h5>
                                    </c:otherwise>
                                </c:choose>
                                
                                <c:if test="${product.totalSold > 0}">
                                    <small style="color: #666; font-size: 12px;">
                                        <i class="fa fa-shopping-cart"></i> Đã bán: ${product.totalSold}
                                    </small>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                
                <c:if test="${empty topRackets}">
                    <div class="col-12 text-center py-3">
                        <p class="text-muted">Chưa có sản phẩm nào.</p>
                    </div>
                </c:if>
            </div>
            
            <!-- Top Bóng Bán Chạy -->
            <div class="row mb-5 mt-5">
                <div class="col-lg-12">
                    <div class="section-title">
                        <h2>Top Bóng Pickleball</h2>
                    </div>
                </div>
            </div>
            <div class="row">
                <c:forEach var="product" items="${topBalls}">
                    <div class="col-lg-3 col-md-6 col-sm-6">
                        <div class="product__item">
                            <div class="product__item__pic set-bg" data-setbg="${not empty product.mainImageUrl ? pageContext.request.contextPath.concat(product.mainImageUrl) : pageContext.request.contextPath.concat('/img/product/default.jpg')}" 
                                 style="cursor: pointer;" 
                                 onclick="window.location.href='${pageContext.request.contextPath}/product-detail?id=${product.productID}'">
                                
                                <c:if test="${product.totalSold > 0}">
                                    <span class="label" style="background: #e53637;">Bán chạy</span>
                                </c:if>
                                
                                <ul class="product__hover">
                                    <li><a href="#" title="Thêm vào yêu thích" onclick="event.stopPropagation(); return false;"><img src="${pageContext.request.contextPath}/img/icon/heart.png" alt=""></a></li>
                                    <li><a href="${pageContext.request.contextPath}/product-detail?id=${product.productID}" title="Xem chi tiết" onclick="event.stopPropagation();"><img src="${pageContext.request.contextPath}/img/icon/search.png" alt=""></a></li>
                                </ul>
                            </div>
                            <div class="product__item__text">
                                <c:if test="${not empty product.brandName}">
                                    <div class="product__brand" style="margin-bottom: 8px;">
                                        <small style="color: #888; font-size: 12px;">
                                            <i class="fa fa-tag"></i> ${product.brandName}
                                        </small>
                                    </div>
                                </c:if>
                                
                                <h6><a href="${pageContext.request.contextPath}/product-detail?id=${product.productID}">${product.productName}</a></h6>
                                
                                <c:choose>
                                    <c:when test="${product.minPrice != null && product.maxPrice != null}">
                                        <c:choose>
                                            <c:when test="${product.minPrice.compareTo(product.maxPrice) == 0}">
                                                <h5><fmt:formatNumber value="${product.minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</h5>
                                            </c:when>
                                            <c:otherwise>
                                                <h5><fmt:formatNumber value="${product.minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫ - <fmt:formatNumber value="${product.maxPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</h5>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:when>
                                    <c:otherwise>
                                        <h5>Liên hệ</h5>
                                    </c:otherwise>
                                </c:choose>
                                
                                <c:if test="${product.totalSold > 0}">
                                    <small style="color: #666; font-size: 12px;">
                                        <i class="fa fa-shopping-cart"></i> Đã bán: ${product.totalSold}
                                    </small>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                
                <c:if test="${empty topBalls}">
                    <div class="col-12 text-center py-3">
                        <p class="text-muted">Chưa có sản phẩm nào.</p>
                    </div>
                </c:if>
            </div>
            
            <!-- Top Trang Phục Bán Chạy -->
            <div class="row mb-5 mt-5">
                <div class="col-lg-12">
                    <div class="section-title">
                        <h2>Top Trang Phục</h2>
                    </div>
                </div>
            </div>
            <div class="row">
                <c:forEach var="product" items="${topClothing}">
                    <div class="col-lg-3 col-md-6 col-sm-6">
                        <div class="product__item">
                            <div class="product__item__pic set-bg" data-setbg="${not empty product.mainImageUrl ? pageContext.request.contextPath.concat(product.mainImageUrl) : pageContext.request.contextPath.concat('/img/product/default.jpg')}" 
                                 style="cursor: pointer;" 
                                 onclick="window.location.href='${pageContext.request.contextPath}/product-detail?id=${product.productID}'">
                                
                                <c:if test="${product.totalSold > 0}">
                                    <span class="label" style="background: #e53637;">Bán chạy</span>
                                </c:if>
                                
                                <ul class="product__hover">
                                    <li><a href="#" title="Thêm vào yêu thích" onclick="event.stopPropagation(); return false;"><img src="${pageContext.request.contextPath}/img/icon/heart.png" alt=""></a></li>
                                    <li><a href="${pageContext.request.contextPath}/product-detail?id=${product.productID}" title="Xem chi tiết" onclick="event.stopPropagation();"><img src="${pageContext.request.contextPath}/img/icon/search.png" alt=""></a></li>
                                </ul>
                            </div>
                            <div class="product__item__text">
                                <c:if test="${not empty product.brandName}">
                                    <div class="product__brand" style="margin-bottom: 8px;">
                                        <small style="color: #888; font-size: 12px;">
                                            <i class="fa fa-tag"></i> ${product.brandName}
                                        </small>
                                    </div>
                                </c:if>
                                
                                <h6><a href="${pageContext.request.contextPath}/product-detail?id=${product.productID}">${product.productName}</a></h6>
                                
                                <c:choose>
                                    <c:when test="${product.minPrice != null && product.maxPrice != null}">
                                        <c:choose>
                                            <c:when test="${product.minPrice.compareTo(product.maxPrice) == 0}">
                                                <h5><fmt:formatNumber value="${product.minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</h5>
                                            </c:when>
                                            <c:otherwise>
                                                <h5><fmt:formatNumber value="${product.minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫ - <fmt:formatNumber value="${product.maxPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</h5>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:when>
                                    <c:otherwise>
                                        <h5>Liên hệ</h5>
                                    </c:otherwise>
                                </c:choose>
                                
                                <c:if test="${product.totalSold > 0}">
                                    <small style="color: #666; font-size: 12px;">
                                        <i class="fa fa-shopping-cart"></i> Đã bán: ${product.totalSold}
                                    </small>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                
                <c:if test="${empty topClothing}">
                    <div class="col-12 text-center py-3">
                        <p class="text-muted">Chưa có sản phẩm nào.</p>
                    </div>
                </c:if>
            </div>
        </div>
    </section>
    <!-- Top Selling Products by Category Section End -->

    <!-- Brands Section Begin -->
    <section class="brands spad" style="background: #f3f2ee;">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="section-title">
                        <span>Thương hiệu</span>
                        <h2>Các Thương Hiệu Nổi Tiếng</h2>
                    </div>
                </div>
            </div>
            <div class="row">
                <c:forEach var="brand" items="${brands}">
                    <div class="col-lg-2 col-md-3 col-sm-4 col-6 mb-4">
                        <a href="${pageContext.request.contextPath}/shop?brandId=${brand.brandID}" 
                           class="brand__item" 
                           style="display: block; text-align: center; padding: 20px; background: white; border-radius: 8px; transition: all 0.3s; text-decoration: none;">
                            <c:choose>
                                <c:when test="${not empty brand.logo}">
                                    <img src="${pageContext.request.contextPath}${brand.logo}" 
                                         alt="${brand.brandName}" 
                                         style="max-width: 100%; height: 60px; object-fit: contain; margin-bottom: 10px;">
                                </c:when>
                                <c:otherwise>
                                    <div style="height: 60px; display: flex; align-items: center; justify-content: center; margin-bottom: 10px;">
                                        <i class="fa fa-tag" style="font-size: 40px; color: #ddd;"></i>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                            <h6 style="margin: 0; color: #333; font-size: 14px; font-weight: 600;">${brand.brandName}</h6>
                        </a>
                    </div>
                </c:forEach>
                
                <c:if test="${empty brands}">
                    <div class="col-12 text-center py-5">
                        <p class="text-muted">Chưa có thương hiệu nào.</p>
                    </div>
                </c:if>
            </div>
        </div>
    </section>
    <!-- Brands Section End -->

    <!-- Product Section Begin -->
    <section class="product spad">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <ul class="filter__controls">
                        <li class="active" data-filter="*">Best Sellers</li>
                        <li data-filter=".new-arrivals">New Arrivals</li>
                        <li data-filter=".hot-sales">Hot Sales</li>
                    </ul>
                    
                    
                    
                    
                    
                    
                </div>
            </div>
            <div class="row product__filter">
                <div class="col-lg-3 col-md-6 col-sm-6 col-md-6 col-sm-6 mix new-arrivals">
                    <div class="product__item">
                        <div class="product__item__pic set-bg" data-setbg="img/product/product-1.jpg">
                            <span class="label">New</span>
                            <ul class="product__hover">
                                <li><a href="#"><img src="img/icon/heart.png" alt=""></a></li>
                                <li><a href="#"><img src="img/icon/compare.png" alt=""> <span>Compare</span></a></li>
                                <li><a href="#"><img src="img/icon/search.png" alt=""></a></li>
                            </ul>
                        </div>
                        <div class="product__item__text">
                            <h6>Piqué Biker Jacket</h6>
                            <a href="#" class="add-cart">+ Add To Cart</a>
                            <div class="rating">
                                <i class="fa fa-star-o"></i>
                                <i class="fa fa-star-o"></i>
                                <i class="fa fa-star-o"></i>
                                <i class="fa fa-star-o"></i>
                                <i class="fa fa-star-o"></i>
                            </div>
                            <h5>$67.24</h5>
                            <div class="product__color__select">
                                <label for="pc-1">
                                    <input type="radio" id="pc-1">
                                </label>
                                <label class="active black" for="pc-2">
                                    <input type="radio" id="pc-2">
                                </label>
                                <label class="grey" for="pc-3">
                                    <input type="radio" id="pc-3">
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 col-sm-6 col-md-6 col-sm-6 mix hot-sales">
                    <div class="product__item">
                        <div class="product__item__pic set-bg" data-setbg="img/product/product-2.jpg">
                            <ul class="product__hover">
                                <li><a href="#"><img src="img/icon/heart.png" alt=""></a></li>
                                <li><a href="#"><img src="img/icon/compare.png" alt=""> <span>Compare</span></a></li>
                                <li><a href="#"><img src="img/icon/search.png" alt=""></a></li>
                            </ul>
                        </div>
                        <div class="product__item__text">
                            <h6>Piqué Biker Jacket</h6>
                            <a href="#" class="add-cart">+ Add To Cart</a>
                            <div class="rating">
                                <i class="fa fa-star-o"></i>
                                <i class="fa fa-star-o"></i>
                                <i class="fa fa-star-o"></i>
                                <i class="fa fa-star-o"></i>
                                <i class="fa fa-star-o"></i>
                            </div>
                            <h5>$67.24</h5>
                            <div class="product__color__select">
                                <label for="pc-4">
                                    <input type="radio" id="pc-4">
                                </label>
                                <label class="active black" for="pc-5">
                                    <input type="radio" id="pc-5">
                                </label>
                                <label class="grey" for="pc-6">
                                    <input type="radio" id="pc-6">
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 col-sm-6 col-md-6 col-sm-6 mix new-arrivals">
                    <div class="product__item sale">
                        <div class="product__item__pic set-bg" data-setbg="img/product/product-3.jpg">
                            <span class="label">Sale</span>
                            <ul class="product__hover">
                                <li><a href="#"><img src="img/icon/heart.png" alt=""></a></li>
                                <li><a href="#"><img src="img/icon/compare.png" alt=""> <span>Compare</span></a></li>
                                <li><a href="#"><img src="img/icon/search.png" alt=""></a></li>
                            </ul>
                        </div>
                        <div class="product__item__text">
                            <h6>Multi-pocket Chest Bag</h6>
                            <a href="#" class="add-cart">+ Add To Cart</a>
                            <div class="rating">
                                <i class="fa fa-star"></i>
                                <i class="fa fa-star"></i>
                                <i class="fa fa-star"></i>
                                <i class="fa fa-star"></i>
                                <i class="fa fa-star-o"></i>
                            </div>
                            <h5>$43.48</h5>
                            <div class="product__color__select">
                                <label for="pc-7">
                                    <input type="radio" id="pc-7">
                                </label>
                                <label class="active black" for="pc-8">
                                    <input type="radio" id="pc-8">
                                </label>
                                <label class="grey" for="pc-9">
                                    <input type="radio" id="pc-9">
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 col-sm-6 col-md-6 col-sm-6 mix hot-sales">
                    <div class="product__item">
                        <div class="product__item__pic set-bg" data-setbg="img/product/product-4.jpg">
                            <ul class="product__hover">
                                <li><a href="#"><img src="img/icon/heart.png" alt=""></a></li>
                                <li><a href="#"><img src="img/icon/compare.png" alt=""> <span>Compare</span></a></li>
                                <li><a href="#"><img src="img/icon/search.png" alt=""></a></li>
                            </ul>
                        </div>
                        <div class="product__item__text">
                            <h6>Diagonal Textured Cap</h6>
                            <a href="#" class="add-cart">+ Add To Cart</a>
                            <div class="rating">
                                <i class="fa fa-star-o"></i>
                                <i class="fa fa-star-o"></i>
                                <i class="fa fa-star-o"></i>
                                <i class="fa fa-star-o"></i>
                                <i class="fa fa-star-o"></i>
                            </div>
                            <h5>$60.9</h5>
                            <div class="product__color__select">
                                <label for="pc-10">
                                    <input type="radio" id="pc-10">
                                </label>
                                <label class="active black" for="pc-11">
                                    <input type="radio" id="pc-11">
                                </label>
                                <label class="grey" for="pc-12">
                                    <input type="radio" id="pc-12">
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 col-sm-6 col-md-6 col-sm-6 mix new-arrivals">
                    <div class="product__item">
                        <div class="product__item__pic set-bg" data-setbg="img/product/product-5.jpg">
                            <ul class="product__hover">
                                <li><a href="#"><img src="img/icon/heart.png" alt=""></a></li>
                                <li><a href="#"><img src="img/icon/compare.png" alt=""> <span>Compare</span></a></li>
                                <li><a href="#"><img src="img/icon/search.png" alt=""></a></li>
                            </ul>
                        </div>
                        <div class="product__item__text">
                            <h6>Lether Backpack</h6>
                            <a href="#" class="add-cart">+ Add To Cart</a>
                            <div class="rating">
                                <i class="fa fa-star-o"></i>
                                <i class="fa fa-star-o"></i>
                                <i class="fa fa-star-o"></i>
                                <i class="fa fa-star-o"></i>
                                <i class="fa fa-star-o"></i>
                            </div>
                            <h5>$31.37</h5>
                            <div class="product__color__select">
                                <label for="pc-13">
                                    <input type="radio" id="pc-13">
                                </label>
                                <label class="active black" for="pc-14">
                                    <input type="radio" id="pc-14">
                                </label>
                                <label class="grey" for="pc-15">
                                    <input type="radio" id="pc-15">
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 col-sm-6 col-md-6 col-sm-6 mix hot-sales">
                    <div class="product__item sale">
                        <div class="product__item__pic set-bg" data-setbg="img/product/product-6.jpg">
                            <span class="label">Sale</span>
                            <ul class="product__hover">
                                <li><a href="#"><img src="img/icon/heart.png" alt=""></a></li>
                                <li><a href="#"><img src="img/icon/compare.png" alt=""> <span>Compare</span></a></li>
                                <li><a href="#"><img src="img/icon/search.png" alt=""></a></li>
                            </ul>
                        </div>
                        <div class="product__item__text">
                            <h6>Ankle Boots</h6>
                            <a href="#" class="add-cart">+ Add To Cart</a>
                            <div class="rating">
                                <i class="fa fa-star"></i>
                                <i class="fa fa-star"></i>
                                <i class="fa fa-star"></i>
                                <i class="fa fa-star"></i>
                                <i class="fa fa-star-o"></i>
                            </div>
                            <h5>$98.49</h5>
                            <div class="product__color__select">
                                <label for="pc-16">
                                    <input type="radio" id="pc-16">
                                </label>
                                <label class="active black" for="pc-17">
                                    <input type="radio" id="pc-17">
                                </label>
                                <label class="grey" for="pc-18">
                                    <input type="radio" id="pc-18">
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 col-sm-6 col-md-6 col-sm-6 mix new-arrivals">
                    <div class="product__item">
                        <div class="product__item__pic set-bg" data-setbg="img/product/product-7.jpg">
                            <ul class="product__hover">
                                <li><a href="#"><img src="img/icon/heart.png" alt=""></a></li>
                                <li><a href="#"><img src="img/icon/compare.png" alt=""> <span>Compare</span></a></li>
                                <li><a href="#"><img src="img/icon/search.png" alt=""></a></li>
                            </ul>
                        </div>
                        <div class="product__item__text">
                            <h6>T-shirt Contrast Pocket</h6>
                            <a href="#" class="add-cart">+ Add To Cart</a>
                            <div class="rating">
                                <i class="fa fa-star-o"></i>
                                <i class="fa fa-star-o"></i>
                                <i class="fa fa-star-o"></i>
                                <i class="fa fa-star-o"></i>
                                <i class="fa fa-star-o"></i>
                            </div>
                            <h5>$49.66</h5>
                            <div class="product__color__select">
                                <label for="pc-19">
                                    <input type="radio" id="pc-19">
                                </label>
                                <label class="active black" for="pc-20">
                                    <input type="radio" id="pc-20">
                                </label>
                                <label class="grey" for="pc-21">
                                    <input type="radio" id="pc-21">
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 col-sm-6 col-md-6 col-sm-6 mix hot-sales">
                    <div class="product__item">
                        <div class="product__item__pic set-bg" data-setbg="img/product/product-8.jpg">
                            <ul class="product__hover">
                                <li><a href="#"><img src="img/icon/heart.png" alt=""></a></li>
                                <li><a href="#"><img src="img/icon/compare.png" alt=""> <span>Compare</span></a></li>
                                <li><a href="#"><img src="img/icon/search.png" alt=""></a></li>
                            </ul>
                        </div>
                        <div class="product__item__text">
                            <h6>Basic Flowing Scarf</h6>
                            <a href="#" class="add-cart">+ Add To Cart</a>
                            <div class="rating">
                                <i class="fa fa-star-o"></i>
                                <i class="fa fa-star-o"></i>
                                <i class="fa fa-star-o"></i>
                                <i class="fa fa-star-o"></i>
                                <i class="fa fa-star-o"></i>
                            </div>
                            <h5>$26.28</h5>
                            <div class="product__color__select">
                                <label for="pc-22">
                                    <input type="radio" id="pc-22">
                                </label>
                                <label class="active black" for="pc-23">
                                    <input type="radio" id="pc-23">
                                </label>
                                <label class="grey" for="pc-24">
                                    <input type="radio" id="pc-24">
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row">
                <!-- Loop through featured products from database -->
                <c:forEach var="product" items="${featuredProducts}">
                    <div class="col-lg-3 col-md-6 col-sm-6">
                        <div class="product__item">
                            <div class="product__item__pic set-bg" data-setbg="${not empty product.mainImageUrl ? pageContext.request.contextPath.concat(product.mainImageUrl) : pageContext.request.contextPath.concat('/img/product/default.jpg')}" 
                                 style="cursor: pointer;" 
                                 onclick="window.location.href='${pageContext.request.contextPath}/product-detail?id=${product.productID}'">
                                <!-- Show "New" badge if product created within last 30 days -->
                                <c:if test="${not empty product.createdDate}">
                                    <jsp:useBean id="now" class="java.util.Date"/>
                                    <c:set var="daysDiff" value="${(now.time - product.createdDate.time) / (1000 * 60 * 60 * 24)}"/>
                                    <c:if test="${daysDiff <= 30}">
                                        <span class="label">New</span>
                                    </c:if>
                                </c:if>
                                
                                <!-- Show "Out of Stock" badge if no stock -->
                                <c:if test="${product.totalStock == 0}">
                                    <span class="label" style="background: #dc3545;">Hết hàng</span>
                                </c:if>
                                
                                <ul class="product__hover">
                                    <li><a href="#" title="Thêm vào yêu thích" onclick="event.stopPropagation(); return false;"><img src="${pageContext.request.contextPath}/img/icon/heart.png" alt=""></a></li>
                                    <li><a href="${pageContext.request.contextPath}/product-detail?id=${product.productID}" title="Xem chi tiết" onclick="event.stopPropagation();"><img src="${pageContext.request.contextPath}/img/icon/search.png" alt=""></a></li>
                                </ul>
                            </div>
                            <div class="product__item__text">
                                <!-- Show brand if available -->
                                <c:if test="${not empty product.brandName}">
                                    <div class="product__brand" style="margin-bottom: 8px;">
                                        <small style="color: #888; font-size: 12px;">
                                            <i class="fa fa-tag"></i> ${product.brandName}
                                        </small>
                                    </div>
                                </c:if>
                                
                                <h6><a href="${pageContext.request.contextPath}/product-detail?id=${product.productID}">${product.productName}</a></h6>
                                
                                <!-- Price display -->
                                <c:choose>
                                    <c:when test="${product.minPrice != null && product.maxPrice != null}">
                                        <c:choose>
                                            <c:when test="${product.minPrice.compareTo(product.maxPrice) == 0}">
                                                <h5><fmt:formatNumber value="${product.minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</h5>
                                            </c:when>
                                            <c:otherwise>
                                                <h5><fmt:formatNumber value="${product.minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫ - <fmt:formatNumber value="${product.maxPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</h5>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:when>
                                    <c:otherwise>
                                        <h5>Liên hệ</h5>
                                    </c:otherwise>
                                </c:choose>
                                
                                <!-- Add to cart button - disabled if out of stock -->
                                <c:choose>
                                    <c:when test="${product.totalStock > 0}">
                                        <a href="${pageContext.request.contextPath}/cart/add?id=${product.productID}" class="add-cart">+ Thêm vào giỏ</a>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="#" class="add-cart" style="background: #ccc; cursor: not-allowed;" onclick="return false;">Hết hàng</a>
                                    </c:otherwise>
                                </c:choose>
                                
                                <!-- Category and stock info -->
                                <div style="margin-top: 8px;">
                                    <c:if test="${not empty product.categoryName}">
                                        <small style="color: #666; font-size: 12px;">
                                            <i class="fa fa-folder-o"></i> ${product.categoryName}
                                        </small>
                                    </c:if>
                                    <c:if test="${product.totalStock > 0 && product.totalStock <= 10}">
                                        <small style="color: #ff6b6b; font-size: 12px; margin-left: 10px;">
                                            <i class="fa fa-exclamation-circle"></i> Chỉ còn ${product.totalStock} sản phẩm
                                        </small>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                
                <!-- Show message if no products -->
                <c:if test="${empty featuredProducts}">
                    <div class="col-12 text-center py-5">
                        <p class="text-muted">Chưa có sản phẩm nào.</p>
                    </div>
                </c:if>
            </div>
            
            <!-- View All Products Button -->
            <div class="row mt-4">
                <div class="col-12 text-center">
                    <a href="${pageContext.request.contextPath}/shop" class="primary-btn">
                        Xem tất cả sản phẩm
                        <span class="arrow_right"></span>
                    </a>
                </div>
            </div>
        </div>
    </section>
    <!-- Product Section End -->

    

    <!-- Latest Blog Section Begin -->
    <section class="latest spad">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="section-title">
                        <span>Tin tức mới nhất</span>
                        <h2>Blog & Hướng dẫn</h2>
                    </div>
                </div>
            </div>
            <div class="row">
                <!-- Loop through latest blogs from database -->
                <c:forEach var="blog" items="${latestBlogs}">
                    <div class="col-lg-4 col-md-6 col-sm-6">
                        <div class="blog__item">
                            <div class="blog__item__pic set-bg" data-setbg="${not empty blog.featuredImage ? blog.featuredImage : pageContext.request.contextPath.concat('/img/blog/default.jpg')}"></div>
                            <div class="blog__item__text">
                                <span>
                                    <img src="${pageContext.request.contextPath}/img/icon/calendar.png" alt=""> 
                                    ${blog.publishedDate != null ? blog.publishedDate.toString().substring(0, 10) : 'N/A'}
                                </span>
                                <h5>${blog.title}</h5>
                                <c:if test="${not empty blog.summary}">
                                    <p>
                                        <c:choose>
                                            <c:when test="${blog.summary.length() > 100}">
                                                ${blog.summary.substring(0, 100)}...
                                            </c:when>
                                            <c:otherwise>
                                                ${blog.summary}
                                            </c:otherwise>
                                        </c:choose>
                                    </p>
                                </c:if>
                                <a href="${pageContext.request.contextPath}/blog-details?id=${blog.postId}">Đọc thêm</a>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                
                <!-- Show message if no blogs -->
                <c:if test="${empty latestBlogs}">
                    <div class="col-12 text-center py-5">
                        <p class="text-muted">Chưa có bài viết nào.</p>
                    </div>
                </c:if>
            </div>
            
            <!-- View All Blogs Button -->
            <c:if test="${not empty latestBlogs}">
                <div class="row mt-4">
                    <div class="col-12 text-center">
                        <a href="${pageContext.request.contextPath}/blog" class="primary-btn">
                            Xem tất cả bài viết
                            <span class="arrow_right"></span>
                        </a>
                    </div>
                </div>
            </c:if>
        </div>
    </section>
    <!-- Latest Blog Section End -->

    <%@include  file="footer.jsp"%>

    

    <style>
        .brand__item:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .brand__item h6 {
            transition: color 0.3s;
        }
        
        .brand__item:hover h6 {
            color: #e53637 !important;
        }
    </style>

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
</body>
<script>
    $(document).ready(function(){
        $(".hero__slider").owlCarousel({
            items: 1,
            loop: true,
            nav: true,
            dots: true,
            autoplay: true,
            autoplayTimeout: 5000,
            animateOut: 'fadeOut',
            animateIn: 'fadeIn',
            navText: ["<span class='arrow_left'></span>","<span class='arrow_right'></span>"]
        });
    });
</script>

</html>