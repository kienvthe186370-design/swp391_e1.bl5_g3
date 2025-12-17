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
    <title>Pickleball Shop Vietnam</title>

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

    <!-- Newest Products by Category Section Begin -->
    <section class="categories spad">
        <div class="container">
            <!-- Vợt Mới Nhất -->
            <div class="row mb-5">
                <div class="col-lg-12">
                    <div class="section-title">
                        <span>Sản phẩm mới nhất</span>
                        <h2>Vợt Pickleball Mới Nhất</h2>
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
                                
                                <span class="label" style="background: #28a745;">Mới</span>
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
            
            <!-- Bóng Mới Nhất -->
            <div class="row mb-5 mt-5">
                <div class="col-lg-12">
                    <div class="section-title">
                        <h2>Bóng Pickleball Mới Nhất</h2>
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
                                
                                <span class="label" style="background: #28a745;">Mới</span>
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
            
            <!-- Trang Phục Mới Nhất -->
            <div class="row mb-5 mt-5">
                <div class="col-lg-12">
                    <div class="section-title">
                        <h2>Trang Phục Mới Nhất</h2>
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
                                
                                <span class="label" style="background: #28a745;">Mới</span>
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
    <!-- Newest Products by Category Section End -->

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
                                    <c:set var="logoUrl" value="${brand.logo}" />
                                    <c:choose>
                                        <c:when test="${logoUrl.startsWith('http://') || logoUrl.startsWith('https://')}">
                                            <img src="${brand.logo}" 
                                                 alt="${brand.brandName}" 
                                                 style="max-width: 100%; height: 60px; object-fit: contain; margin-bottom: 10px;"
                                                 onerror="this.onerror=null; this.parentElement.innerHTML='<div style=\'height: 60px; display: flex; align-items: center; justify-content: center; margin-bottom: 10px;\'><i class=\'fa fa-tag\' style=\'font-size: 40px; color: #ddd;\'></i></div>';">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="${pageContext.request.contextPath}${brand.logo}" 
                                                 alt="${brand.brandName}" 
                                                 style="max-width: 100%; height: 60px; object-fit: contain; margin-bottom: 10px;"
                                                 onerror="this.onerror=null; this.parentElement.innerHTML='<div style=\'height: 60px; display: flex; align-items: center; justify-content: center; margin-bottom: 10px;\'><i class=\'fa fa-tag\' style=\'font-size: 40px; color: #ddd;\'></i></div>';">
                                        </c:otherwise>
                                    </c:choose>
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
                            <c:choose>
                                <c:when test="${not empty blog.featuredImage}">
                                    <c:set var="blogImageUrl" value="${blog.featuredImage.startsWith('http://') || blog.featuredImage.startsWith('https://') || blog.featuredImage.startsWith('/') ? blog.featuredImage : pageContext.request.contextPath.concat('/').concat(blog.featuredImage)}" />
                                    <div class="blog__item__pic set-bg" data-setbg="${blogImageUrl}"></div>
                                </c:when>
                                <c:otherwise>
                                    <div class="blog__item__pic set-bg" data-setbg="${pageContext.request.contextPath}/img/blog/blog-1.jpg"></div>
                                </c:otherwise>
                            </c:choose>
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