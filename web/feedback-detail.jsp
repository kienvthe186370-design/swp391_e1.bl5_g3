<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    request.setAttribute("pageTitle", "Chi tiết đánh giá");
%>
<jsp:include page="/AdminLTE-3.2.0/includes/admin-header.jsp" />
<jsp:include page="/AdminLTE-3.2.0/includes/admin-sidebar.jsp" />

<style>
    .review-stars { color: #FBBF24; font-size: 24px; }
    .review-stars .empty { color: #D1D5DB; }
    .product-card { display: flex; gap: 20px; padding: 20px; background: #f8f9fa; border-radius: 8px; }
    .product-card img { width: 120px; height: 120px; object-fit: contain; border-radius: 8px; background: #fff; }
    .product-info h5 { margin-bottom: 8px; font-weight: 700; }
    .product-info .brand { color: #2D5A27; font-size: 13px; text-transform: uppercase; margin-bottom: 4px; }
    .review-content-box { background: #fff; border: 1px solid #e9ecef; border-radius: 8px; padding: 20px; margin-top: 20px; }
    .review-title { font-size: 18px; font-weight: 700; margin-bottom: 12px; }
    .review-text { color: #555; line-height: 1.8; white-space: pre-wrap; }
    .reply-box { background: #e8f5e9; border-left: 4px solid #2D5A27; padding: 20px; border-radius: 0 8px 8px 0; margin-top: 20px; }
    .reply-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
    .reply-header .name { font-weight: 700; color: #2D5A27; }
    .reply-header .date { font-size: 13px; color: #888; }
    .status-badge { padding: 6px 16px; border-radius: 20px; font-size: 13px; font-weight: 600; }
    .status-published { background: #d4edda; color: #155724; }
    .status-hidden { background: #f8d7da; color: #721c24; }
</style>

<!-- Content Wrapper -->
<div class="content-wrapper">
    <div class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h1 class="m-0">Chi tiết đánh giá #${review.reviewId}</h1>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/feedbacks">Quản lý đánh giá</a></li>
                        <li class="breadcrumb-item active">Chi tiết</li>
                    </ol>
                </div>
            </div>
        </div>
    </div>

    <section class="content">
        <div class="container-fluid">
            <!-- Alert Messages -->
            <c:if test="${not empty sessionScope.success}">
                <div class="alert alert-success alert-dismissible fade show">
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                    ${sessionScope.success}
                </div>
                <c:remove var="success" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.error}">
                <div class="alert alert-danger alert-dismissible fade show">
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                    ${sessionScope.error}
                </div>
                <c:remove var="error" scope="session"/>
            </c:if>

            <div class="row">
                <!-- Main Content -->
                <div class="col-lg-8">
                    <!-- Product Info -->
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title"><i class="fas fa-box"></i> Thông tin sản phẩm</h3>
                        </div>
                        <div class="card-body">
                            <div class="product-card">
                                <c:choose>
                                    <c:when test="${not empty review.productImage}">
                                        <img src="${pageContext.request.contextPath}${review.productImage}" alt="${review.productName}">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="${pageContext.request.contextPath}/img/product/product-placeholder.jpg" alt="Product">
                                    </c:otherwise>
                                </c:choose>
                                <div class="product-info">
                                    <c:if test="${not empty review.brandName}">
                                        <div class="brand">${review.brandName}</div>
                                    </c:if>
                                    <h5>${review.productName}</h5>
                                    <c:if test="${not empty review.variantSku}">
                                        <div style="font-size: 13px; color: #666; margin: 8px 0;">
                                            <i class="fas fa-tag"></i> Phân loại: <strong>${review.variantSku}</strong>
                                        </div>
                                    </c:if>
                                    <a href="${pageContext.request.contextPath}/product-detail?id=${review.productId}" target="_blank" class="btn btn-sm btn-outline-primary">
                                        <i class="fas fa-external-link-alt"></i> Xem sản phẩm
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Review Content -->
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title"><i class="fas fa-star"></i> Nội dung đánh giá</h3>
                        </div>
                        <div class="card-body">
                            <!-- Rating Stars -->
                            <div class="text-center mb-4">
                                <div class="review-stars mb-2">
                                    <c:forEach begin="1" end="5" var="i">
                                        <i class="fas fa-star ${i <= review.rating ? '' : 'empty'}"></i>
                                    </c:forEach>
                                </div>
                                <span class="badge badge-warning" style="font-size: 16px;">${review.rating}/5 sao</span>
                            </div>

                            <!-- Review Content Box -->
                            <div class="review-content-box">
                                <c:if test="${not empty review.reviewTitle}">
                                    <div class="review-title">${review.reviewTitle}</div>
                                </c:if>
                                <c:choose>
                                    <c:when test="${not empty review.reviewContent}">
                                        <div class="review-text">${review.reviewContent}</div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="text-muted text-center py-3">
                                            <i class="fas fa-comment-slash"></i> Không có nội dung đánh giá
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <!-- Review Images Gallery -->
                            <c:if test="${review.hasImages()}">
                                <div class="mt-4">
                                    <h6><i class="fas fa-images"></i> Hình ảnh đánh giá (${review.images.size()})</h6>
                                    <div class="d-flex flex-wrap gap-2 mt-2" style="gap: 10px;">
                                        <c:forEach var="img" items="${review.images}">
                                            <img src="${pageContext.request.contextPath}${img.mediaUrl}" 
                                                 alt="Review image" 
                                                 style="width: 100px; height: 100px; object-fit: cover; border-radius: 8px; cursor: pointer; border: 1px solid #dee2e6;"
                                                 onclick="openImageModal('${pageContext.request.contextPath}${img.mediaUrl}')"
                                                 data-toggle="tooltip" title="Click để xem ảnh lớn">
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:if>

                            <!-- Reply Section -->
                            <c:choose>
                                <c:when test="${review.hasReply()}">
                                    <div class="reply-box">
                                        <div class="reply-header">
                                            <span class="name">
                                                <i class="fas fa-reply"></i> Phản hồi từ Shop
                                                <c:if test="${not empty review.repliedByName}">
                                                    - ${review.repliedByName}
                                                </c:if>
                                            </span>
                                            <span class="date">
                                                <c:if test="${not empty review.replyDate}">
                                                    ${review.replyDate.toLocalDate()}
                                                </c:if>
                                            </span>
                                        </div>
                                        <div class="reply-content">${review.replyContent}</div>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <!-- Reply Form -->
                                    <div class="mt-4">
                                        <h6><i class="fas fa-reply"></i> Gửi phản hồi</h6>
                                        <form method="post" action="${pageContext.request.contextPath}/feedback-detail">
                                            <input type="hidden" name="action" value="reply">
                                            <input type="hidden" name="reviewId" value="${review.reviewId}">
                                            <div class="form-group">
                                                <textarea name="replyContent" class="form-control" rows="4" 
                                                          placeholder="Nhập nội dung phản hồi..." required></textarea>
                                            </div>
                                            <button type="submit" class="btn btn-primary">
                                                <i class="fas fa-paper-plane"></i> Gửi phản hồi
                                            </button>
                                        </form>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <!-- Sidebar Info -->
                <div class="col-lg-4">
                    <!-- Status & Actions -->
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title"><i class="fas fa-cog"></i> Trạng thái & Thao tác</h3>
                        </div>
                        <div class="card-body">
                            <div class="text-center mb-3">
                                <c:choose>
                                    <c:when test="${review.reviewStatus == 'published'}">
                                        <span class="status-badge status-published">
                                            <i class="fas fa-eye"></i> Đang hiển thị
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status-badge status-hidden">
                                            <i class="fas fa-eye-slash"></i> Đã ẩn
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            
                            <div class="d-grid gap-2">
                                <c:choose>
                                    <c:when test="${review.reviewStatus == 'published'}">
                                        <form method="post" action="${pageContext.request.contextPath}/feedback-detail">
                                            <input type="hidden" name="action" value="toggleStatus">
                                            <input type="hidden" name="reviewId" value="${review.reviewId}">
                                            <input type="hidden" name="newStatus" value="hidden">
                                            <button type="submit" class="btn btn-warning btn-block" 
                                                    onclick="return confirm('Bạn có chắc muốn ẩn đánh giá này?')">
                                                <i class="fas fa-eye-slash"></i> Ẩn đánh giá
                                            </button>
                                        </form>
                                    </c:when>
                                    <c:otherwise>
                                        <form method="post" action="${pageContext.request.contextPath}/feedback-detail">
                                            <input type="hidden" name="action" value="toggleStatus">
                                            <input type="hidden" name="reviewId" value="${review.reviewId}">
                                            <input type="hidden" name="newStatus" value="published">
                                            <button type="submit" class="btn btn-success btn-block">
                                                <i class="fas fa-eye"></i> Hiện đánh giá
                                            </button>
                                        </form>
                                    </c:otherwise>
                                </c:choose>
                                
                                <a href="${pageContext.request.contextPath}/feedbacks" class="btn btn-secondary btn-block">
                                    <i class="fas fa-arrow-left"></i> Quay lại danh sách
                                </a>
                            </div>
                        </div>
                    </div>

                    <!-- Review Info -->
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title"><i class="fas fa-info-circle"></i> Thông tin chi tiết</h3>
                        </div>
                        <div class="card-body p-0">
                            <table class="table table-striped mb-0">
                                <tr>
                                    <td><i class="fas fa-hashtag text-muted"></i> ID</td>
                                    <td><strong>#${review.reviewId}</strong></td>
                                </tr>
                                <tr>
                                    <td><i class="fas fa-user text-muted"></i> Khách hàng</td>
                                    <td><strong>${review.customerName}</strong></td>
                                </tr>
                                <tr>
                                    <td><i class="fas fa-calendar text-muted"></i> Ngày đánh giá</td>
                                    <td>${review.reviewDate.toLocalDate()}</td>
                                </tr>
                                <tr>
                                    <td><i class="fas fa-clock text-muted"></i> Giờ</td>
                                    <td>${review.reviewDate.toLocalTime().toString().substring(0, 5)}</td>
                                </tr>
                                <tr>
                                    <td><i class="fas fa-reply text-muted"></i> Phản hồi</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${review.hasReply()}">
                                                <span class="badge badge-success">Đã phản hồi</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-secondary">Chưa phản hồi</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                                <c:if test="${review.hasReply() && not empty review.replyDate}">
                                    <tr>
                                        <td><i class="fas fa-calendar-check text-muted"></i> Ngày phản hồi</td>
                                        <td>${review.replyDate.toLocalDate()}</td>
                                    </tr>
                                </c:if>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
</div>

<footer class="main-footer">
    <strong>Pickleball Shop Admin</strong>
</footer>
</div>

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

<script src="${pageContext.request.contextPath}/AdminLTE-3.2.0/plugins/jquery/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/AdminLTE-3.2.0/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/AdminLTE-3.2.0/dist/js/adminlte.min.js"></script>
<script>
    function openImageModal(src) {
        document.getElementById('modalImage').src = src;
        $('#imageModal').modal('show');
    }
    
    $(function () {
        $('[data-toggle="tooltip"]').tooltip();
    });
</script>
</body>
</html>
