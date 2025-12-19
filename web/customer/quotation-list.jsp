<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Báo Giá Của Tôi - Pickleball Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" type="text/css">
    <style>
        .quotation-card { transition: transform 0.2s; margin-bottom: 15px; border-radius: 8px; }
        .quotation-card:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
        .status-badge { font-size: 0.85rem; padding: 6px 12px; border-radius: 20px; }
        .status-sent { background: #007bff; color: #fff; }
        .status-customercountered { background: #ffc107; color: #000; }
        .status-sellercountered { background: #17a2b8; color: #fff; }
        .status-accepted { background: #5dade2; color: #fff; } /* Xanh biển - chờ thanh toán */
        .status-paid { background: #28a745; color: #fff; } /* Xanh lá - hoàn thành */
        .status-rejected { background: #dc3545; color: #fff; }
        .status-expired { background: #6c757d; color: #fff; }
        .stat-card { border-radius: 8px; padding: 15px; text-align: center; }
        .stat-card h3 { margin: 0; font-size: 1.8rem; }
        .stat-card p { margin: 5px 0 0; font-size: 0.9rem; }

    </style>
</head>
<body>
    <%@include file="../header.jsp" %>

    <section class="breadcrumb-option">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="breadcrumb__text">
                        <h4>Báo Giá Của Tôi</h4>
                        <div class="breadcrumb__links">
                            <a href="${pageContext.request.contextPath}/Home">Trang chủ</a>
                            <a href="${pageContext.request.contextPath}/rfq/list">Yêu cầu báo giá</a>
                            <span>Báo giá</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="spad">
        <div class="container">
            <!-- Filter -->
            <div class="card mb-4">
                <div class="card-body">
                    <form class="row g-3" method="GET">
                        <div class="col-md-4">
                            <input type="text" class="form-control" name="keyword" placeholder="Tìm mã báo giá, mã RFQ..." value="${keyword}">
                        </div>
                        <div class="col-md-3">
                            <select class="form-control" name="status">
                                <option value="">Tất cả trạng thái</option>
                                <option value="Sent" ${status == 'Sent' ? 'selected' : ''}>Chờ xử lý</option>
                                <option value="CustomerCountered" ${status == 'CustomerCountered' ? 'selected' : ''}>Đã đề xuất giá</option>
                                <option value="SellerCountered" ${status == 'SellerCountered' ? 'selected' : ''}>Seller đề xuất giá</option>
                                <option value="Accepted" ${status == 'Accepted' ? 'selected' : ''}>Đã chấp nhận</option>
                                <option value="Paid" ${status == 'Paid' ? 'selected' : ''}>Đã thanh toán</option>
                                <option value="Rejected" ${status == 'Rejected' ? 'selected' : ''}>Đã từ chối</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <select class="form-control" name="sortBy">
                                <option value="">Mới nhất</option>
                                <option value="oldest" ${sortBy == 'oldest' ? 'selected' : ''}>Cũ nhất</option>
                                <option value="price_asc" ${sortBy == 'price_asc' ? 'selected' : ''}>Giá tăng dần</option>
                                <option value="price_desc" ${sortBy == 'price_desc' ? 'selected' : ''}>Giá giảm dần</option>
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
                    <p>Bạn chưa có báo giá nào.</p>
                    <a href="${pageContext.request.contextPath}/rfq/list" class="btn btn-primary">Xem Yêu Cầu Báo Giá</a>
                </div>
            </c:if>

            <c:forEach var="q" items="${quotations}">
                <div class="card quotation-card">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-8">
                                <div class="d-flex justify-content-between align-items-start mb-2">
                                    <div>
                                        <h5 class="mb-1">
                                            <a href="${pageContext.request.contextPath}/quotation/detail?id=${q.quotationID}" class="text-decoration-none">
                                                <i class="fa fa-file-text-o"></i> ${q.quotationCode}
                                            </a>
                                        </h5>
                                        <c:if test="${q.rfq != null}">
                                            <p class="text-muted mb-1">
                                                <i class="fa fa-link"></i> RFQ: 
                                                <a href="${pageContext.request.contextPath}/rfq/detail?id=${q.rfqID}">${q.rfq.rfqCode}</a>
                                            </p>
                                            <p class="text-muted mb-1"><i class="fa fa-building"></i> ${q.rfq.companyName}</p>
                                        </c:if>
                                    </div>
                                    <div class="text-right">
                                        <span class="badge status-badge status-${q.status.toLowerCase()}">
                                            ${q.statusDisplayName}
                                        </span>
                                    </div>
                                </div>

                                <c:if test="${q.status == 'Sent'}">
                                    <div class="alert alert-info mb-2 py-2">
                                        <i class="fa fa-clock-o"></i>
                                        <strong>Chờ xử lý:</strong> Vui lòng xem chi tiết để chấp nhận hoặc từ chối báo giá
                                    </div>
                                </c:if>

                                <c:if test="${q.status == 'Accepted'}">
                                    <div class="alert mb-2 py-2" style="background-color: #d6eaf8; border-color: #5dade2; color: #1a5276;">
                                        <i class="fa fa-check-circle"></i>
                                        <strong>Đã chấp nhận:</strong> Vui lòng thanh toán để hoàn tất
                                    </div>
                                </c:if>

                                <div class="text-muted small">
                                    <i class="fa fa-calendar"></i> Ngày gửi: <fmt:formatDate value="${q.quotationSentDate}" pattern="dd/MM/yyyy"/>
                                </div>
                                <c:if test="${not empty q.shippingCarrierName}">
                                    <div class="mt-2 small">
                                        <i class="fa fa-truck"></i> Vận chuyển: ${q.shippingCarrierName} - ${q.shippingServiceName}
                                    </div>
                                </c:if>
                            </div>

                            <div class="col-md-4 d-flex flex-column align-items-end justify-content-center">
                                <c:if test="${q.totalAmount != null}">
                                    <small class="text-muted">Tổng giá trị:</small>
                                    <h4 class="text-primary mb-2">
                                        <fmt:formatNumber value="${q.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </h4>
                                </c:if>

                                <a href="${pageContext.request.contextPath}/quotation/detail?id=${q.quotationID}" class="btn btn-outline-primary btn-sm">
                                    <i class="fa fa-eye"></i> Xem Chi Tiết
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>

            <!-- Pagination -->
            <nav class="mt-4">
                <ul class="pagination justify-content-center">
                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${currentPage - 1}&keyword=${keyword}&status=${status}&sortBy=${sortBy}">«</a>
                    </li>
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <li class="page-item ${currentPage == i ? 'active' : ''}">
                            <a class="page-link" href="?page=${i}&keyword=${keyword}&status=${status}&sortBy=${sortBy}">${i}</a>
                        </li>
                    </c:forEach>
                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${currentPage + 1}&keyword=${keyword}&status=${status}&sortBy=${sortBy}">»</a>
                    </li>
                </ul>
            </nav>
        </div>
    </section>

    <%@include file="../footer.jsp"%>
    <script src="${pageContext.request.contextPath}/js/jquery-3.3.1.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
