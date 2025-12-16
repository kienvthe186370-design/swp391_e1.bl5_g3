<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="description" content="${blog != null ? blog.summary : 'Chi tiết bài viết'}">
    <meta name="keywords" content="blog, tin tức, thời trang">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>${blog != null ? blog.title : 'Chi tiết bài viết'}</title>

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

    <!-- Blog Details Hero Begin -->
    <c:if test="${blog != null}">
        <section class="blog-hero spad">
            <div class="container">
                <div class="row d-flex justify-content-center">
                    <div class="col-lg-9 text-center">
                        <div class="blog__hero__text">
                            <h2>${blog.title}</h2>
                            <ul>
                                <li>Bởi ${blog.authorName}</li>
                                <li>${blog.publishedDate != null ? blog.publishedDate.toString().substring(0, 10) : 'N/A'}</li>
                                <li><i class="fa fa-eye"></i> ${blog.viewCount} lượt xem</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </c:if>
    <!-- Blog Details Hero End -->

    <!-- Blog Details Section Begin -->
    <c:choose>
        <c:when test="${blog != null}">
            <section class="blog-details spad">
                <div class="container">
                    <div class="row d-flex justify-content-center">
                        <c:if test="${not empty blog.featuredImage}">
                            <div class="col-lg-12">
                                <div class="blog__details__pic">
                                    <c:set var="blogDetailImageUrl" value="${blog.featuredImage.startsWith('http://') || blog.featuredImage.startsWith('https://') || blog.featuredImage.startsWith('/') ? blog.featuredImage : pageContext.request.contextPath.concat('/').concat(blog.featuredImage)}" />
                                    <img src="${blogDetailImageUrl}" alt="${blog.title}" style="width: 100%; height: auto;">
                                </div>
                            </div>
                        </c:if>
                        <div class="col-lg-8">
                            <div class="blog__details__content">
                                <div class="blog__details__share">
                                    <span>Chia sẻ</span>
                                    <ul>
                                        <li><a href="https://www.facebook.com/sharer/sharer.php?u=${pageContext.request.requestURL}" target="_blank"><i class="fa fa-facebook"></i></a></li>
                                        <li><a href="https://twitter.com/intent/tweet?url=${pageContext.request.requestURL}" target="_blank" class="twitter"><i class="fa fa-twitter"></i></a></li>
                                        <li><a href="#" class="linkedin"><i class="fa fa-linkedin"></i></a></li>
                                    </ul>
                                </div>
                                <div class="blog__details__text">
                                    ${blog.content}
                                </div>
                                <div class="blog__details__option">
                                    <div class="row">
                                        <div class="col-lg-12 col-md-12">
                                            <div class="blog__details__author">
                                                <div class="blog__details__author__text">
                                                    <h5>Tác giả: ${blog.authorName}</h5>
                                                    <p>Ngày xuất bản: ${blog.publishedDate != null ? blog.publishedDate.toString().substring(0, 10) : 'N/A'}</p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                
                                <!-- Related Blogs -->
                                <c:if test="${not empty relatedBlogs}">
                                    <div class="blog__details__related mt-5">
                                        <h4>Bài viết liên quan</h4>
                                        <div class="row">
                                            <c:forEach var="related" items="${relatedBlogs}">
                                                <div class="col-lg-4 col-md-4 col-sm-6">
                                                    <div class="blog__item">
                                                        <div class="blog__item__pic set-bg" 
                                                             data-setbg="${not empty related.featuredImage ? pageContext.request.contextPath.concat('/').concat(related.featuredImage) : pageContext.request.contextPath.concat('/img/blog/blog-1.jpg')}">
                                                        </div>
                                                        <div class="blog__item__text">
                                                            <span>
                                                                <img src="${pageContext.request.contextPath}/img/icon/calendar.png" alt=""> 
                                                                ${related.publishedDate != null ? related.publishedDate.toString().substring(0, 10) : 'N/A'}
                                                            </span>
                                                            <h5>${related.title}</h5>
                                                            <a href="${pageContext.request.contextPath}/blog-details?id=${related.postId}">Đọc thêm</a>
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </div>
                                </c:if>
                                
                                <div class="text-center mt-4">
                                    <a href="${pageContext.request.contextPath}/blog" class="primary-btn">
                                        <i class="fa fa-arrow-left"></i> Quay lại danh sách
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </c:when>
        <c:otherwise>
            <section class="blog-details spad">
                <div class="container">
                    <div class="row">
                        <div class="col-lg-12 text-center">
                            <h3>Không tìm thấy bài viết</h3>
                            <p class="text-muted">Bài viết không tồn tại hoặc đã bị xóa.</p>
                            <a href="${pageContext.request.contextPath}/blog" class="primary-btn mt-3">
                                <i class="fa fa-arrow-left"></i> Quay lại danh sách
                            </a>
                        </div>
                    </div>
                </div>
            </section>
        </c:otherwise>
    </c:choose>
    <!-- Blog Details Section End -->

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
