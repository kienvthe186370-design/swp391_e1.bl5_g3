<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kết Quả Thanh Toán - Pickleball Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" type="text/css">
    <style>
        .result-icon { font-size: 80px; margin-bottom: 20px; }
        .result-icon.success { color: #28a745; }
        .result-icon.error { color: #dc3545; }
        .result-card { max-width: 600px; margin: 0 auto; }
    </style>
</head>
<body>
    <%@include file="../header.jsp" %>

    <section class="breadcrumb-option">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="breadcrumb__text">
                        <h4>Kết Quả Thanh Toán</h4>
                        <div class="breadcrumb__links">
                            <a href="${pageContext.request.contextPath}/Home">Trang chủ</a>
                            <a href="${pageContext.request.contextPath}/rfq/list">Yêu cầu báo giá</a>
                            <span>Kết quả thanh toán</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="spad">
        <div class="container">
            <div class="result-card">
                <c:choose>
                    <c:when test="${success}">
                        <div class="card border-success">
                            <div class="card-body text-center py-5">
                                <div class="result-icon success">
                                    <i class="fa fa-check-circle"></i>
                                </div>
                                <h3 class="text-success mb-3">Thanh Toán Thành Công!</h3>
                                <p class="text-muted mb-4">${message}</p>
                                
                                <div class="bg-light p-4 rounded mb-4">
                                    <table class="table table-borderless mb-0">
                                        <tr>
                                            <td class="text-muted">Mã RFQ:</td>
                                            <td class="text-end"><strong>${rfqCode}</strong></td>
                                        </tr>
                                        <c:if test="${not empty orderID}">
                                        <tr>
                                            <td class="text-muted">Mã đơn hàng:</td>
                                            <td class="text-end">
                                                <a href="${pageContext.request.contextPath}/customer/orders?id=${orderID}" class="text-primary">
                                                    <strong>#${orderID}</strong> <i class="fa fa-external-link"></i>
                                                </a>
                                            </td>
                                        </tr>
                                        </c:if>
                                        <tr>
                                            <td class="text-muted">Số tiền đã thanh toán:</td>
                                            <td class="text-end"><strong class="text-success"><fmt:formatNumber value="${paymentAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></strong></td>
                                        </tr>
                                        <tr>
                                            <td class="text-muted">Mã giao dịch:</td>
                                            <td class="text-end"><strong>${transactionNo}</strong></td>
                                        </tr>
                                        <tr>
                                            <td class="text-muted">Phương thức:</td>
                                            <td class="text-end">Chuyển khoản ngân hàng (VNPay)</td>
                                        </tr>
                                    </table>
                                </div>
                                
                                <div class="d-flex justify-content-center gap-3 mt-4">
                                    <c:if test="${not empty orderID}">
                                    <a href="${pageContext.request.contextPath}/customer/orders?id=${orderID}" class="btn btn-success">
                                        <i class="fa fa-shopping-bag"></i> Xem đơn hàng
                                    </a>
                                    </c:if>
                                    <a href="${pageContext.request.contextPath}/rfq/list" class="btn btn-outline-primary">
                                        <i class="fa fa-list"></i> Danh sách RFQ
                                    </a>
                                    <a href="${pageContext.request.contextPath}/Home" class="btn btn-primary">
                                        <i class="fa fa-home"></i> Về trang chủ
                                    </a>
                                </div>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="card border-danger">
                            <div class="card-body text-center py-5">
                                <div class="result-icon error">
                                    <i class="fa fa-times-circle"></i>
                                </div>
                                <h3 class="text-danger mb-3">Thanh Toán Thất Bại</h3>
                                <p class="text-muted mb-4">${message}</p>
                                
                                <c:if test="${not empty errorCode}">
                                    <p class="text-muted">Mã lỗi: ${errorCode}</p>
                                </c:if>
                                
                                <c:if test="${not empty rfqCode}">
                                    <p class="text-muted">Mã đơn hàng: ${rfqCode}</p>
                                </c:if>
                                
                                <div class="d-flex justify-content-center gap-3 mt-4">
                                    <a href="${pageContext.request.contextPath}/rfq/list" class="btn btn-outline-primary">
                                        <i class="fa fa-list"></i> Danh sách RFQ
                                    </a>
                                    <a href="${pageContext.request.contextPath}/rfq/detail?id=${rfq.rfqID}" class="btn btn-primary">
                                        <i class="fa fa-redo"></i> Thử lại
                                    </a>
                                </div>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </section>

    <%@include file="../footer.jsp"%>

    <script src="${pageContext.request.contextPath}/js/jquery-3.3.1.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/bootstrap.min.js"></script>
</body>
</html>
