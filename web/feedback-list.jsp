<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    request.setAttribute("pageTitle", "Quản lý đánh giá");
%>
<jsp:include page="/AdminLTE-3.2.0/includes/admin-header.jsp" />
<jsp:include page="/AdminLTE-3.2.0/includes/admin-sidebar.jsp" />

<style>
    .review-stars { color: #FBBF24; }
    .review-stars .empty { color: #D1D5DB; }
    .review-content-cell { max-width: 300px; }
    .review-content-preview { display: -webkit-box; -webkit-line-clamp: 2; line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
    .product-cell { display: flex; align-items: center; gap: 10px; }
    .product-cell img { width: 50px; height: 50px; object-fit: contain; border-radius: 4px; background: #f9f9f9; }
    .filter-form .form-group { margin-bottom: 10px; }
    .reply-badge { background: #28a745; color: #fff; padding: 2px 8px; border-radius: 4px; font-size: 11px; }
    .no-reply-badge { background: #6c757d; color: #fff; padding: 2px 8px; border-radius: 4px; font-size: 11px; }
</style>

<!-- Content Wrapper -->
<div class="content-wrapper">
    <div class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h1 class="m-0">Quản lý đánh giá</h1>
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

            <!-- Filter Card -->
            <div class="card card-outline card-primary">
                <div class="card-header">
                    <h3 class="card-title"><i class="fas fa-filter"></i> Bộ lọc</h3>
                    <div class="card-tools">
                        <button type="button" class="btn btn-tool" data-card-widget="collapse">
                            <i class="fas fa-minus"></i>
                        </button>
                    </div>
                </div>
                <div class="card-body">
                    <form method="get" action="${pageContext.request.contextPath}/feedbacks" class="filter-form">
                        <div class="row">
                            <div class="col-md-2">
                                <div class="form-group">
                                    <label>Trạng thái</label>
                                    <select name="status" class="form-control form-control-sm">
                                        <option value="">-- Tất cả --</option>
                                        <option value="published" ${filterStatus == 'published' ? 'selected' : ''}>Hiển thị</option>
                                        <option value="hidden" ${filterStatus == 'hidden' ? 'selected' : ''}>Đã ẩn</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-2">
                                <div class="form-group">
                                    <label>Số sao</label>
                                    <select name="rating" class="form-control form-control-sm">
                                        <option value="">-- Tất cả --</option>
                                        <c:forEach begin="1" end="5" var="i">
                                            <option value="${i}" ${filterRating == i ? 'selected' : ''}>${i} sao</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="form-group">
                                    <label>Sản phẩm</label>
                                    <select name="productId" class="form-control form-control-sm">
                                        <option value="">-- Tất cả --</option>
                                        <c:forEach var="p" items="${products}">
                                            <option value="${p.productId}" ${filterProductId == p.productId ? 'selected' : ''}>${p.productName}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-2">
                                <div class="form-group">
                                    <label>Phản hồi</label>
                                    <select name="hasReply" class="form-control form-control-sm">
                                        <option value="">-- Tất cả --</option>
                                        <option value="yes" ${filterHasReply == 'yes' ? 'selected' : ''}>Đã phản hồi</option>
                                        <option value="no" ${filterHasReply == 'no' ? 'selected' : ''}>Chưa phản hồi</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="form-group">
                                    <label>Ngày đánh giá</label>
                                    <div class="input-group input-group-sm">
                                        <input type="date" name="dateFrom" class="form-control" value="${filterDateFrom}" placeholder="Từ">
                                        <input type="date" name="dateTo" class="form-control" value="${filterDateTo}" placeholder="Đến">
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-12">
                                <button type="submit" class="btn btn-primary btn-sm"><i class="fas fa-search"></i> Lọc</button>
                                <a href="${pageContext.request.contextPath}/feedbacks" class="btn btn-secondary btn-sm"><i class="fas fa-redo"></i> Reset</a>
                            </div>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Reviews Table -->
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">Danh sách đánh giá (${totalReviews})</h3>
                </div>
                <div class="card-body table-responsive p-0">
                    <table class="table table-hover text-nowrap">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Sản phẩm</th>
                                <th>Khách hàng</th>
                                <th>Đánh giá</th>
                                <th>Nội dung</th>
                                <th>Trạng thái</th>
                                <th>Ngày</th>
                                <th>Reply</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="review" items="${reviews}">
                                <tr>
                                    <td>${review.reviewId}</td>
                                    <td>
                                        <div class="product-cell">
                                            <c:choose>
                                                <c:when test="${not empty review.productImage}">
                                                    <img src="${pageContext.request.contextPath}${review.productImage}" alt="">
                                                </c:when>
                                                <c:otherwise>
                                                    <img src="${pageContext.request.contextPath}/img/product/product-placeholder.jpg" alt="">
                                                </c:otherwise>
                                            </c:choose>
                                            <div>
                                                <div style="font-weight: 600; max-width: 150px; overflow: hidden; text-overflow: ellipsis;">${review.productName}</div>
                                                <small class="text-muted">${review.brandName}</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td>${review.customerName}</td>
                                    <td>
                                        <div class="review-stars">
                                            <c:forEach begin="1" end="5" var="i">
                                                <i class="fas fa-star ${i <= review.rating ? '' : 'empty'}"></i>
                                            </c:forEach>
                                        </div>
                                    </td>
                                    <td class="review-content-cell">
                                        <c:if test="${not empty review.reviewTitle}">
                                            <strong>${review.reviewTitle}</strong><br>
                                        </c:if>
                                        <div class="review-content-preview">${review.reviewContent}</div>
                                        <c:if test="${review.hasImages()}">
                                            <span class="badge badge-info mt-1"><i class="fas fa-image"></i> ${review.images.size()} ảnh</span>
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${review.reviewStatus == 'published'}">
                                                <span class="badge badge-success">Hiển thị</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-danger">Đã ẩn</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <small>${review.reviewDate.toLocalDate()}</small>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${review.hasReply()}">
                                                <span class="reply-badge"><i class="fas fa-check"></i> Đã reply</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="no-reply-badge">Chưa reply</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="btn-group">
                                            <!-- Toggle Status -->
                                            <c:choose>
                                                <c:when test="${review.reviewStatus == 'published'}">
                                                    <form method="post" action="${pageContext.request.contextPath}/feedbacks" style="display:inline;">
                                                        <input type="hidden" name="action" value="toggleStatus">
                                                        <input type="hidden" name="reviewId" value="${review.reviewId}">
                                                        <input type="hidden" name="newStatus" value="hidden">
                                                        <input type="hidden" name="returnQuery" value="${pageContext.request.queryString}">
                                                        <button type="submit" class="btn btn-warning btn-sm" title="Ẩn">
                                                            <i class="fas fa-eye-slash"></i>
                                                        </button>
                                                    </form>
                                                </c:when>
                                                <c:otherwise>
                                                    <form method="post" action="${pageContext.request.contextPath}/feedbacks" style="display:inline;">
                                                        <input type="hidden" name="action" value="toggleStatus">
                                                        <input type="hidden" name="reviewId" value="${review.reviewId}">
                                                        <input type="hidden" name="newStatus" value="published">
                                                        <input type="hidden" name="returnQuery" value="${pageContext.request.queryString}">
                                                        <button type="submit" class="btn btn-success btn-sm" title="Hiện">
                                                            <i class="fas fa-eye"></i>
                                                        </button>
                                                    </form>
                                                </c:otherwise>
                                            </c:choose>
                                            
                                            <!-- Reply Button -->
                                            <c:if test="${!review.hasReply()}">
                                                <button type="button" class="btn btn-info btn-sm" title="Phản hồi" 
                                                        data-review-id="${review.reviewId}"
                                                        data-customer-name="${review.customerName}"
                                                        data-review-content="${review.reviewContent}"
                                                        onclick="openReplyModalFromBtn(this)">
                                                    <i class="fas fa-reply"></i>
                                                </button>
                                            </c:if>
                                            
                                            <!-- View Detail -->
                                            <a href="${pageContext.request.contextPath}/feedback-detail?id=${review.reviewId}" 
                                               class="btn btn-secondary btn-sm" title="Chi tiết">
                                                <i class="fas fa-info-circle"></i>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty reviews}">
                                <tr>
                                    <td colspan="9" class="text-center py-4">
                                        <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                                        <p class="text-muted">Không có đánh giá nào</p>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination -->
                <c:if test="${totalPages > 1}">
                    <div class="card-footer clearfix">
                        <ul class="pagination pagination-sm m-0 float-right">
                            <c:if test="${currentPage > 1}">
                                <li class="page-item">
                                    <a class="page-link" href="${pageContext.request.contextPath}/feedbacks?page=${currentPage - 1}&status=${filterStatus}&rating=${filterRating}&productId=${filterProductId}&hasReply=${filterHasReply}&dateFrom=${filterDateFrom}&dateTo=${filterDateTo}">«</a>
                                </li>
                            </c:if>
                            
                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <c:if test="${i >= currentPage - 2 && i <= currentPage + 2}">
                                    <li class="page-item ${i == currentPage ? 'active' : ''}">
                                        <a class="page-link" href="${pageContext.request.contextPath}/feedbacks?page=${i}&status=${filterStatus}&rating=${filterRating}&productId=${filterProductId}&hasReply=${filterHasReply}&dateFrom=${filterDateFrom}&dateTo=${filterDateTo}">${i}</a>
                                    </li>
                                </c:if>
                            </c:forEach>
                            
                            <c:if test="${currentPage < totalPages}">
                                <li class="page-item">
                                    <a class="page-link" href="${pageContext.request.contextPath}/feedbacks?page=${currentPage + 1}&status=${filterStatus}&rating=${filterRating}&productId=${filterProductId}&hasReply=${filterHasReply}&dateFrom=${filterDateFrom}&dateTo=${filterDateTo}">»</a>
                                </li>
                            </c:if>
                        </ul>
                    </div>
                </c:if>
            </div>
        </div>
    </section>
</div>

<footer class="main-footer">
    <strong>Pickleball Shop Admin</strong>
</footer>
</div>

<!-- Reply Modal -->
<div class="modal fade" id="replyModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-reply"></i> Phản hồi đánh giá</h5>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/feedbacks">
                <div class="modal-body">
                    <input type="hidden" name="action" value="reply">
                    <input type="hidden" name="reviewId" id="replyReviewId">
                    <input type="hidden" name="returnQuery" value="${pageContext.request.queryString}">
                    
                    <div class="form-group">
                        <label>Khách hàng:</label>
                        <p id="replyCustomerName" class="font-weight-bold"></p>
                    </div>
                    <div class="form-group">
                        <label>Nội dung đánh giá:</label>
                        <p id="replyReviewContent" class="text-muted" style="font-style: italic;"></p>
                    </div>
                    <div class="form-group">
                        <label>Nội dung phản hồi <span class="text-danger">*</span></label>
                        <textarea name="replyContent" class="form-control" rows="4" required placeholder="Nhập nội dung phản hồi..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-paper-plane"></i> Gửi phản hồi</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/AdminLTE-3.2.0/plugins/jquery/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/AdminLTE-3.2.0/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/AdminLTE-3.2.0/dist/js/adminlte.min.js"></script>
<script>
    function openReplyModalFromBtn(btn) {
        var reviewId = btn.getAttribute('data-review-id');
        var customerName = btn.getAttribute('data-customer-name');
        var reviewContent = btn.getAttribute('data-review-content');
        document.getElementById('replyReviewId').value = reviewId;
        document.getElementById('replyCustomerName').textContent = customerName;
        document.getElementById('replyReviewContent').textContent = reviewContent || '(Không có nội dung)';
        $('#replyModal').modal('show');
    }
</script>
</body>
</html>
