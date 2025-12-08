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
    <style>
        /* Hide hover effect that shows product name */
        .product__item .product__hover {
            display: none !important;
            visibility: hidden !important;
            opacity: 0 !important;
        }
        .product__item:hover .product__hover {
            display: none !important;
            visibility: hidden !important;
            opacity: 0 !important;
        }
        .product__item:hover .product__item__pic:before,
        .product__item:hover .product__item__pic:after {
            display: none !important;
            opacity: 0 !important;
            background: transparent !important;
        }
        .product__item__pic:before,
        .product__item__pic:after {
            display: none !important;
        }
        /* Product name styling - FORCE VISIBLE */
        .product__item__text h6 {
            display: block !important;
            visibility: visible !important;
            opacity: 1 !important;
            margin-bottom: 8px !important;
            min-height: 40px;
            position: relative !important;
        }
        .product__item:hover .product__item__text h6 {
            display: block !important;
            visibility: visible !important;
            opacity: 1 !important;
        }
        .product__item__text h6 a {
            color: #111 !important;
            font-size: 14px !important;
            line-height: 1.4;
            font-weight: 600;
            display: inline !important;
            visibility: visible !important;
            opacity: 1 !important;
        }
        .product__item__text h6 a:hover {
            color: #ca1515 !important;
        }
        /* Price styling */
        .product-price {
            color: #ca1515 !important;
            font-weight: 600 !important;
            font-size: 14px !important;
            margin-bottom: 5px !important;
        }
    </style>
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
                        <div class="product__item" style="cursor: pointer;" onclick="window.location.href='${pageContext.request.contextPath}/product-detail?id=${product.productID}'">
                            <div class="product__item__pic set-bg" data-setbg="${not empty product.mainImageUrl ? pageContext.request.contextPath.concat(product.mainImageUrl) : pageContext.request.contextPath.concat('/img/product/default.jpg')}">
                                <!-- Show "New" badge if product created within last 30 days -->
                                <c:if test="${not empty product.createdDate}">
                                    <jsp:useBean id="now" class="java.util.Date"/>
                                    <c:set var="daysDiff" value="${(now.time - product.createdDate.time) / (1000 * 60 * 60 * 24)}"/>
                                    <c:if test="${daysDiff <= 30}">
                                        <span class="label">New</span>
                                    </c:if>
                                </c:if>
                                
                                <!-- Show status badge based on variant/stock -->
                                <c:choose>
                                    <c:when test="${product.variantCount == 0}">
                                        <span class="label" style="background: #17a2b8;">Coming Soon</span>
                                    </c:when>
                                    <c:when test="${product.totalStock == 0}">
                                        <span class="label" style="background: #dc3545;">Hết hàng</span>
                                    </c:when>
                                </c:choose>
                            </div>
                            <div class="product__item__text">
                                <h6 style="margin-bottom: 8px; min-height: 40px;"><a href="${pageContext.request.contextPath}/product-detail?id=${product.productID}" onclick="event.stopPropagation();">${product.productName}</a></h6>
                                
                                <!-- Price display -->
                                <c:choose>
                                    <c:when test="${product.minPrice != null && product.maxPrice != null}">
                                        <c:choose>
                                            <c:when test="${product.minPrice.compareTo(product.maxPrice) == 0}">
                                                <p class="product-price" style="color: #ca1515; font-weight: 600; font-size: 14px; margin-bottom: 5px;"><fmt:formatNumber value="${product.minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</p>
                                            </c:when>
                                            <c:otherwise>
                                                <p class="product-price" style="color: #ca1515; font-weight: 600; font-size: 14px; margin-bottom: 5px;"><fmt:formatNumber value="${product.minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫ - <fmt:formatNumber value="${product.maxPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</p>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:when>
                                    <c:otherwise>
                                        <p class="product-price" style="color: #ca1515; font-weight: 600; font-size: 14px; margin-bottom: 5px;">Liên hệ</p>
                                    </c:otherwise>
                                </c:choose>
                                
                                <!-- Brand info -->
                                <c:if test="${not empty product.brandName}">
                                    <small style="color: #999; font-size: 11px;">${product.brandName}</small>
                                </c:if>
                                
                                <!-- Stock warning -->
                                <c:if test="${product.totalStock > 0 && product.totalStock <= 10}">
                                    <div style="margin-top: 5px;">
                                        <small style="color: #ff6b6b; font-size: 11px;">
                                            <i class="fa fa-exclamation-circle"></i> Còn ${product.totalStock} sp
                                        </small>
                                    </div>
                                </c:if>
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