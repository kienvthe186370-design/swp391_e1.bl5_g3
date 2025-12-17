<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="entity.Customer" %>
<%
    Customer customer = (Customer) session.getAttribute("customer");
    if (customer == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đánh giá của tôi - Pickleball Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" type="text/css">
    <style>
        .review-item { background: #fff; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); padding: 24px; margin-bottom: 20px; }
        .review-item.hidden-review { opacity: 0.6; border: 2px dashed #dc3545; }
        .review-product { display: flex; gap: 16px; margin-bottom: 16px; padding-bottom: 16px; border-bottom: 1px solid #eee; }
        .review-product img { width: 80px; height: 80px; object-fit: contain; border-radius: 8px; background: #f9f9f9; }
        .review-product-info { flex: 1; }
        .review-product-name { font-weight: 700; color: #333; margin-bottom: 4px; }
        .review-product-brand { font-size: 12px; color: #2D5A27; text-transform: uppercase; }
        .review-stars { color: #FBBF24; font-size: 18px; margin-bottom: 8px; }
        .review-stars .empty { color: #D1D5DB; }
        .review-title { font-weight: 700; font-size: 16px; margin-bottom: 8px; }
        .review-content { color: #555; line-height: 1.6; margin-bottom: 12px; }
        .review-date { font-size: 13px; color: #999; }
        .review-reply { background: #f0f7f0; border-left: 4px solid #2D5A27; padding: 16px; margin-top: 16px; border-radius: 0 8px 8px 0; }
        .review-reply-header { font-weight: 700; color: #2D5A27; margin-bottom: 8px; font-size: 14px; }
        .review-reply-content { color: #555; font-size: 14px; }
        .badge-hidden { background: #dc3545; color: #fff; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: 600; }
        .empty-state { text-align: center; padding: 60px 20px; }
        .empty-state i { font-size: 64px; color: #ddd; margin-bottom: 20px; }
        .empty-state h3 { color: #666; margin-bottom: 10px; }
        .empty-state p { color: #999; }
        .pagination-wrapper { display: flex; justify-content: center; margin-top: 30px; }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />

    <section class="breadcrumb-option">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="breadcrumb__text">
                        <h4>Đánh giá của tôi</h4>
                        <div class="breadcrumb__links">
                            <a href="${pageContext.request.contextPath}/Home">Trang chủ</a>
                            <span>Đánh giá của tôi</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="spad">
        <div class="container">
            <c:if test="${not empty sessionScope.success}">
                <div class="alert alert-success alert-dismissible fade show">
                    ${sessionScope.success}
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                </div>
                <c:remove var="success" scope="session"/>
            </c:if>

            <div class="row">
                <div class="col-lg-12">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h5 class="mb-0">Tổng cộng: ${totalReviews} đánh giá</h5>
                    </div>

                    <c:choose>
                        <c:when test="${empty reviews}">
                            <div class="empty-state">
                                <i class="fa fa-star-o"></i>
                                <h3>Bạn chưa có đánh giá nào</h3>
                                <p>Hãy mua sắm và đánh giá sản phẩm để chia sẻ trải nghiệm của bạn!</p>
                                <a href="${pageContext.request.contextPath}/shop" class="btn btn-primary mt-3">Mua sắm ngay</a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="review" items="${reviews}">
                                <div class="review-item ${review.hidden ? 'hidden-review' : ''}">
                                    <c:if test="${review.hidden}">
                                        <div class="mb-2">
                                            <span class="badge-hidden"><i class="fa fa-eye-slash"></i> Đã bị ẩn</span>
                                        </div>
                                    </c:if>
                                    
                                    <div class="review-product">
                                        <c:choose>
                                            <c:when test="${not empty review.productImage}">
                                                <img src="${pageContext.request.contextPath}${review.productImage}" alt="${review.productName}">
                                            </c:when>
                                            <c:otherwise>
                                                <img src="${pageContext.request.contextPath}/img/product/product-placeholder.jpg" alt="Product">
                                            </c:otherwise>
                                        </c:choose>
                                        <div class="review-product-info">
                                            <c:if test="${not empty review.brandName}">
                                                <div class="review-product-brand">${review.brandName}</div>
                                            </c:if>
                                            <div class="review-product-name">${review.productName}</div>
                                            <c:if test="${not empty review.variantSku}">
                                                <div style="font-size: 12px; color: #888; margin-top: 2px;">
                                                    <i class="fa fa-tag"></i> Phân loại: ${review.variantSku}
                                                </div>
                                            </c:if>
                                            <a href="${pageContext.request.contextPath}/product-detail?id=${review.productId}" class="text-primary" style="font-size: 13px;">Xem sản phẩm →</a>
                                        </div>
                                    </div>

                                    <div class="review-stars">
                                        <c:forEach begin="1" end="5" var="i">
                                            <i class="fa fa-star ${i <= review.rating ? '' : 'empty'}"></i>
                                        </c:forEach>
                                    </div>

                                    <c:if test="${not empty review.reviewTitle}">
                                        <div class="review-title">${review.reviewTitle}</div>
                                    </c:if>

                                    <c:if test="${not empty review.reviewContent}">
                                        <div class="review-content">${review.reviewContent}</div>
                                    </c:if>



                                    <div class="review-date">
                                        <i class="fa fa-clock-o"></i>
                                        Đăng ngày: ${review.reviewDate.toLocalDate().toString()}
                                    </div>

                                    <c:if test="${review.hasReply()}">
                                        <div class="review-reply">
                                            <div class="review-reply-header">
                                                <i class="fa fa-reply"></i> Phản hồi từ Shop
                                                <c:if test="${not empty review.repliedByName}">
                                                    - ${review.repliedByName}
                                                </c:if>
                                            </div>
                                            <div class="review-reply-content">${review.replyContent}</div>
                                        </div>
                                    </c:if>
                                </div>
                            </c:forEach>

                            <!-- Pagination -->
                            <c:if test="${totalPages > 1}">
                                <div class="pagination-wrapper">
                                    <nav>
                                        <ul class="pagination">
                                            <c:if test="${currentPage > 1}">
                                                <li class="page-item">
                                                    <a class="page-link" href="${pageContext.request.contextPath}/my-reviews?page=${currentPage - 1}">«</a>
                                                </li>
                                            </c:if>
                                            
                                            <c:forEach begin="1" end="${totalPages}" var="i">
                                                <li class="page-item ${i == currentPage ? 'active' : ''}">
                                                    <a class="page-link" href="${pageContext.request.contextPath}/my-reviews?page=${i}">${i}</a>
                                                </li>
                                            </c:forEach>
                                            
                                            <c:if test="${currentPage < totalPages}">
                                                <li class="page-item">
                                                    <a class="page-link" href="${pageContext.request.contextPath}/my-reviews?page=${currentPage + 1}">»</a>
                                                </li>
                                            </c:if>
                                        </ul>
                                    </nav>
                                </div>
                            </c:if>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </section>

    <!-- Image Modal -->
    <div class="modal fade" id="imageModal" tabindex="-1">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content" style="background: transparent; border: none;">
                <div class="modal-body text-center p-0">
                    <img id="modalImage" src="" style="max-width: 100%; max-height: 80vh; border-radius: 8px;">
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="footer.jsp" />

    <script src="${pageContext.request.contextPath}/js/jquery-3.3.1.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/bootstrap.min.js"></script>
    <script>
        function openImageModal(src) {
            document.getElementById('modalImage').src = src;
            $('#imageModal').modal('show');
        }
    </script>
</body>
</html>
