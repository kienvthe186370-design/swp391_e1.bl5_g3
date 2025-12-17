<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đơn Báo Giá Của Tôi - Pickleball Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" type="text/css">
    <style>
        .quotation-card { transition: transform 0.2s; margin-bottom: 15px; }
        .quotation-card:hover { transform: translateY(-2px); box-shadow: 0 4px 8px rgba(0,0,0,0.1); }
        .status-badge { font-size: 0.85rem; padding: 5px 12px; }
        .status-quoted { background: #ffc107; color: #000; }
        .status-completed { background: #28a745; color: #fff; }
        .status-quoterejected { background: #dc3545; color: #fff; }
        .payment-method { font-size: 0.8rem; padding: 3px 8px; border-radius: 4px; }
        .payment-bank { background: #e3f2fd; color: #1565c0; }
    </style>
</head>
<body>
    <%@include file="../header.jsp" %>

    <section class="breadcrumb-option">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="breadcrumb__text">
                        <h4>Đơn Báo Giá Của Tôi</h4>
                        <div class="breadcrumb__links">
                            <a href="${pageContext.request.contextPath}/Home">Trang chủ</a>
                            <span>Đơn Báo Giá</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="spad">
        <div class="container">
            <div class="mb-4">
                <h4><i class="fa fa-file-text-o"></i> Đơn Báo Giá Của Tôi</h4>
            </div>

            <!-- Filter -->
            <div class="card mb-4">
                <div class="card-body">
                    <form class="row g-3" method="GET">
                        <div class="col-md-5">
                            <input type="text" class="form-control" name="keyword" placeholder="Tìm mã RFQ, công ty..." value="${keyword}">
                        </div>
                        <div class="col-md-5">
                            <select class="form-control" name="status">
                                <option value="">Tất cả trạng thái</option>
                                <option value="Quoted" ${status == 'Quoted' ? 'selected' : ''}>Chờ chấp nhận</option>
                                <option value="Completed" ${status == 'Completed' ? 'selected' : ''}>Đã thanh toán</option>
                                <option value="QuoteRejected" ${status == 'QuoteRejected' ? 'selected' : ''}>Đã từ chối</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <button type="submit" class="btn btn-primary w-100"><i class="fa fa-search"></i> Tìm</button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Quotation List -->
            <c:if test="${empty quotations}">
                <div class="alert alert-info text-center">
                    <i class="fa fa-info-circle fa-2x mb-2"></i>
                    <p>Bạn chưa có đơn báo giá nào.</p>
                    <a href="${pageContext.request.contextPath}/rfq/form" class="btn btn-primary">Tạo Yêu Cầu Báo Giá</a>
                </div>
            </c:if>

            <c:forEach var="q" items="${quotations}">
                <div class="card quotation-card ${q.status == 'Quoted' ? 'border-warning' : ''} ${q.status == 'Completed' ? 'border-success' : ''} ${q.status == 'QuoteRejected' ? 'border-danger' : ''}">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-8">
                                <div class="d-flex justify-content-between align-items-start mb-2">
                                    <div>
                                        <h5 class="mb-1">
                                            <a href="${pageContext.request.contextPath}/quotation/detail?id=${q.rfqID}" class="text-decoration-none">
                                                ${q.rfqCode}
                                            </a>
                                        </h5>
                                        <p class="text-muted mb-1"><i class="fa fa-building"></i> ${q.companyName}</p>
                                        <p class="text-muted mb-2">
                                            <i class="fa fa-user"></i> ${q.contactPerson}
                                            <span class="mx-2">|</span>
                                            <i class="fa fa-envelope"></i> ${q.contactEmail}
                                        </p>
                                    </div>
                                    <span class="badge status-badge status-${q.status.toLowerCase()}">
                                        <c:choose>
                                            <c:when test="${q.status == 'Quoted'}">Chờ chấp nhận</c:when>
                                            <c:when test="${q.status == 'Completed'}">Đã thanh toán</c:when>
                                            <c:when test="${q.status == 'QuoteRejected'}">Đã từ chối</c:when>
                                            <c:otherwise>${q.statusDisplayName}</c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>

                                <c:if test="${q.status == 'Quoted'}">
                                    <div class="alert alert-warning mb-2 py-2">
                                        <i class="fa fa-clock-o"></i>
                                        <strong>Chờ chấp nhận:</strong> Báo giá có hiệu lực đến 
                                        <strong><fmt:formatDate value="${q.quotationValidUntil}" pattern="dd/MM/yyyy"/></strong>
                                    </div>
                                </c:if>

                                <div class="row text-muted small">
                                    <div class="col-6">
                                        <i class="fa fa-calendar"></i> Ngày báo giá: <fmt:formatDate value="${q.quotationSentDate}" pattern="dd/MM/yyyy"/>
                                    </div>
                                    <div class="col-6">
                                        <i class="fa fa-truck"></i> Giao hàng: <fmt:formatDate value="${q.requestedDeliveryDate}" pattern="dd/MM/yyyy"/>
                                    </div>
                                </div>
                                <div class="mt-2">
                                    <i class="fa fa-credit-card"></i> Thanh toán: 
                                    <span class="payment-method payment-bank">Chuyển khoản ngân hàng (VNPay)</span>
                                </div>
                            </div>

                            <div class="col-md-4 d-flex flex-column align-items-end justify-content-center">
                                <c:if test="${q.totalAmount != null && q.totalAmount > 0}">
                                    <small class="text-muted">Tổng giá trị:</small>
                                    <h4 class="text-primary mb-2"><fmt:formatNumber value="${q.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></h4>
                                </c:if>

                                <a href="${pageContext.request.contextPath}/quotation/detail?id=${q.rfqID}" class="btn btn-outline-primary btn-sm">
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
                            <a class="page-link" href="?page=${currentPage - 1}&keyword=${keyword}&status=${status}">«</a>
                        </li>
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                <a class="page-link" href="?page=${i}&keyword=${keyword}&status=${status}">${i}</a>
                            </li>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage + 1}&keyword=${keyword}&status=${status}">»</a>
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
