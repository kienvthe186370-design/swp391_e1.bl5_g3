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



    <!-- Product Section Begin -->
    <section class="product spad">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="section-title">
                        <span>Sản phẩm nổi bật</span>
                        <h2>Vợt & Phụ kiện Pickleball</h2>
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