<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Yêu Cầu Báo Giá Của Tôi - Pickleball Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" type="text/css">
    <style>
        .rfq-card { transition: transform 0.2s; margin-bottom: 15px; }
        .rfq-card:hover { transform: translateY(-2px); box-shadow: 0 4px 8px rgba(0,0,0,0.1); }
        .status-badge { font-size: 0.85rem; padding: 5px 12px; }
        .status-pending { background: #ffc107; color: #000; }
        .status-reviewing { background: #17a2b8; color: #fff; }
        .status-dateproposed { background: #fd7e14; color: #fff; }
        .status-dateaccepted { background: #20c997; color: #fff; }
        .status-daterejected { background: #dc3545; color: #fff; }
        .status-quoted { background: #007bff; color: #fff; }
        .status-quoteaccepted { background: #6f42c1; color: #fff; }
        .status-quoterejected { background: #dc3545; color: #fff; }
        .status-completed { background: #28a745; color: #fff; }
        .status-cancelled { background: #6c757d; color: #fff; }
        .payment-method { font-size: 0.8rem; padding: 3px 8px; border-radius: 4px; }
        .payment-bank { background: #e3f2fd; color: #1565c0; }
        .payment-cod { background: #fff3e0; color: #e65100; }
    </style>
</head>
<body>
    <%@include file="../header.jsp" %>

    <section class="breadcrumb-option">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="breadcrumb__text">
                        <h4>Yêu Cầu Báo Giá Của Tôi</h4>
                        <div class="breadcrumb__links">
                            <a href="${pageContext.request.contextPath}/Home">Trang chủ</a>
                            <span>Yêu cầu báo giá</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="spad">
        <div class="container">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h4><i class="fa fa-file-text"></i> Yêu Cầu Báo Giá Của Tôi</h4>
                <a href="${pageContext.request.contextPath}/rfq/form" class="btn btn-primary">
                    <i class="fa fa-plus"></i> Tạo Yêu Cầu Mới
                </a>
            </div>

            <!-- Filter -->
            <div class="card mb-4">
                <div class="card-body">
                    <form class="row g-3" method="GET">
                        <div class="col-md-4">
                            <input type="text" class="form-control" name="keyword" placeholder="Tìm mã RFQ, công ty..." value="${keyword}">
                        </div>
                        <div class="col-md-3">
                            <select class="form-control" name="status">
                                <option value="">Tất cả trạng thái</option>
                                <option value="Pending" ${status == 'Pending' ? 'selected' : ''}>Chờ xử lý</option>
                                <option value="Reviewing" ${status == 'Reviewing' ? 'selected' : ''}>Đang xem xét</option>
                                <option value="DateProposed" ${status == 'DateProposed' ? 'selected' : ''}>Đề xuất ngày mới</option>
                                <option value="Quoted" ${status == 'Quoted' ? 'selected' : ''}>Đã báo giá</option>
                                <option value="Completed" ${status == 'Completed' ? 'selected' : ''}>Hoàn thành</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <select class="form-control" name="paymentMethod">
                                <option value="">Tất cả thanh toán</option>
                                <option value="BankTransfer" ${paymentMethod == 'BankTransfer' ? 'selected' : ''}>Chuyển khoản</option>
                                <option value="COD" ${paymentMethod == 'COD' ? 'selected' : ''}>COD + Cọc 50%</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <button type="submit" class="btn btn-primary w-100"><i class="fa fa-search"></i> Tìm</button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- RFQ List -->
            <c:if test="${empty rfqs}">
                <div class="alert alert-info text-center">
                    <i class="fa fa-info-circle fa-2x mb-2"></i>
                    <p>Bạn chưa có yêu cầu báo giá nào.</p>
                    <a href="${pageContext.request.contextPath}/rfq/form" class="btn btn-primary">Tạo Yêu Cầu Đầu Tiên</a>
                </div>
            </c:if>

            <c:forEach var="rfq" items="${rfqs}">
                <div class="card rfq-card ${rfq.status == 'DateProposed' ? 'border-warning' : ''} ${rfq.status == 'Quoted' ? 'border-primary' : ''}">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-8">
                                <div class="d-flex justify-content-between align-items-start mb-2">
                                    <div>
                                        <h5 class="mb-1">
                                            <a href="${pageContext.request.contextPath}/rfq/detail?id=${rfq.rfqID}" class="text-decoration-none">
                                                ${rfq.rfqCode}
                                            </a>
                                        </h5>
                                        <p class="text-muted mb-2"><i class="fa fa-building"></i> ${rfq.companyName}</p>
                                    </div>
                                    <span class="badge status-badge status-${rfq.status.toLowerCase()}">${rfq.statusDisplayName}</span>
                                </div>

                                <c:if test="${rfq.status == 'DateProposed'}">
                                    <div class="alert alert-warning mb-2 py-2">
                                        <i class="fa fa-exclamation-triangle"></i>
                                        <strong>Yêu cầu phản hồi:</strong> Seller đề xuất ngày giao mới: 
                                        <strong><fmt:formatDate value="${rfq.proposedDeliveryDate}" pattern="dd/MM/yyyy"/></strong>
                                        <c:if test="${not empty rfq.dateChangeReason}">
                                            <br><small>Lý do: ${rfq.dateChangeReason}</small>
                                        </c:if>
                                    </div>
                                </c:if>

                                <div class="row text-muted small">
                                    <div class="col-6">
                                        <i class="fa fa-calendar"></i> Gửi: <fmt:formatDate value="${rfq.createdDate}" pattern="dd/MM/yyyy HH:mm"/>
                                    </div>
                                    <div class="col-6">
                                        <i class="fa fa-truck"></i> Mong muốn: <fmt:formatDate value="${rfq.requestedDeliveryDate}" pattern="dd/MM/yyyy"/>
                                    </div>
                                </div>
                                <c:if test="${not empty rfq.paymentMethod}">
                                    <div class="mt-2">
                                        <i class="fa fa-credit-card"></i> Thanh toán: 
                                        <span class="payment-method ${rfq.paymentMethod == 'BankTransfer' ? 'payment-bank' : 'payment-cod'}">
                                            <c:choose>
                                                <c:when test="${rfq.paymentMethod == 'BankTransfer'}">Chuyển khoản ngân hàng</c:when>
                                                <c:when test="${rfq.paymentMethod == 'COD'}">COD + Cọc 50%</c:when>
                                                <c:otherwise>${rfq.paymentMethod}</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>
                                </c:if>
                            </div>

                            <div class="col-md-4 d-flex flex-column align-items-end justify-content-center">
                                <c:if test="${rfq.totalAmount != null && rfq.totalAmount > 0}">
                                    <small class="text-muted">Tổng báo giá:</small>
                                    <h4 class="text-primary mb-2"><fmt:formatNumber value="${rfq.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></h4>
                                </c:if>

                                <a href="${pageContext.request.contextPath}/rfq/detail?id=${rfq.rfqID}" class="btn btn-outline-primary btn-sm">
                                    <i class="fa fa-eye"></i> Xem Chi Tiết
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>

            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
                <nav class="mt-4">
                    <ul class="pagination justify-content-center">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage - 1}&keyword=${keyword}&status=${status}&paymentMethod=${paymentMethod}">«</a>
                        </li>
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                <a class="page-link" href="?page=${i}&keyword=${keyword}&status=${status}&paymentMethod=${paymentMethod}">${i}</a>
                            </li>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage + 1}&keyword=${keyword}&status=${status}&paymentMethod=${paymentMethod}">»</a>
                        </li>
                    </ul>
                </nav>
            </c:if>
        </div>
    </section>

    <%@include file="../footer.jsp"%>
    <script src="${pageContext.request.contextPath}/js/jquery-3.3.1.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/bootstrap.min.js"></script>
</body>
</html>
