<%-- 
    Document   : blog
    Created on : Dec 4, 2025, 2:19:32 PM
    Author     : xuand
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="description" content="Blog - Tin tức thời trang">
    <meta name="keywords" content="blog, tin tức, thời trang">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Blog - Tin tức</title>

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

    <!-- Breadcrumb Section Begin -->
    <section class="breadcrumb-blog set-bg" data-setbg="img/breadcrumb-bg.jpg">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <h2>Our Blog</h2>
                </div>
            </div>
        </div>
    </section>
    <!-- Breadcrumb Section End -->

    <!-- Blog Section Begin -->
    <section class="blog spad">
        <div class="container">
            <!-- Search Form -->
            <div class="row mb-4">
                <div class="col-lg-12">
                    <form method="get" action="<%= request.getContextPath() %>/blog" class="d-flex justify-content-center">
                        <div class="input-group" style="max-width: 500px;">
                            <input type="text" name="search" class="form-control" 
                                   placeholder="Tìm kiếm bài viết..." value="${search}">
                            <div class="input-group-append">
                                <button class="btn btn-primary" type="submit">
                                    <i class="fa fa-search"></i> Tìm
                                </button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
            
            <div class="row">
                <c:forEach var="blog" items="${blogs}">
                    <div class="col-lg-4 col-md-6 col-sm-6">
                        <div class="blog__item">
                            <div class="blog__item__pic set-bg" 
                                 data-setbg="${not empty blog.featuredImage ? pageContext.request.contextPath.concat('/').concat(blog.featuredImage) : pageContext.request.contextPath.concat('/img/blog/blog-1.jpg')}">
                            </div>
                            <div class="blog__item__text">
                                <span>
                                    <img src="img/icon/calendar.png" alt=""> 
                                    ${blog.publishedDate != null ? blog.publishedDate.toString().substring(0, 10) : 'N/A'}
                                </span>
                                <h5>${blog.title}</h5>
                                <c:if test="${not empty blog.summary}">
                                    <p>
                                        ${blog.summary.length() > 100 ? blog.summary.substring(0, 100).concat('...') : blog.summary}
                                    </p>
                                </c:if>
                                <a href="${pageContext.request.contextPath}/blog-details?id=${blog.postId}">Đọc thêm</a>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                
                <c:if test="${empty blogs}">
                    <div class="col-12 text-center py-5">
                        <i class="fa fa-inbox fa-3x text-muted mb-3"></i>
                        <p class="text-muted">Không tìm thấy bài viết nào.</p>
                        <a href="${pageContext.request.contextPath}/blog" class="btn btn-primary">Xem tất cả</a>
                    </div>
                </c:if>
            </div>
            
            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
                <div class="row mt-5">
                    <div class="col-lg-12">
                        <div class="product__pagination">
                            <c:if test="${currentPage > 1}">
                                <a href="?page=${currentPage - 1}&search=${search}"><i class="fa fa-angle-left"></i></a>
                            </c:if>
                            
                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <a href="?page=${i}&search=${search}" class="${currentPage == i ? 'active' : ''}">${i}</a>
                            </c:forEach>
                            
                            <c:if test="${currentPage < totalPages}">
                                <a href="?page=${currentPage + 1}&search=${search}"><i class="fa fa-angle-right"></i></a>
                            </c:if>
                        </div>
                    </div>
                </div>
            </c:if>
        </div>
    </section>
    <!-- Blog Section End -->

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

</html>