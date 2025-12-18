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
        .result-icon { font-size: 5rem; margin-bottom: 20px; }
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
                            <a href="${pageContext.request.contextPath}/quotation/list">Báo giá</a>
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
                                <i class="fa fa-check-circle result-icon success"></i>
                                <h2 class="text-success mb-3">Thanh Toán Thành Công!</h2>
                                <p class="lead">${message}</p>
                                
                                <div class="bg-light p-4 rounded my-4">
                                    <c:if test="${quotation != null}">
                                        <p class="mb-2"><strong>Mã báo giá:</strong> ${quotation.quotationCode}</p>
                                    </c:if>
                                    <c:if test="${rfq != null}">
                                        <p class="mb-2"><strong>Mã RFQ:</strong> ${rfq.rfqCode}</p>
                                    </c:if>
                                    <c:if test="${orderID != null && orderID > 0}">
                                        <p class="mb-2"><strong>Mã đơn hàng:</strong> #${orderID}</p>
                                    </c:if>
                                    <c:if test="${paymentAmount != null}">
                                        <p class="mb-2"><strong>Số tiền:</strong> 
                                            <span class="text-success">
                                                <fmt:formatNumber value="${paymentAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                            </span>
                                        </p>
                                    </c:if>
                                    <c:if test="${transactionNo != null}">
                                        <p class="mb-0"><strong>Mã giao dịch:</strong> ${transactionNo}</p>
                                    </c:if>
                                </div>
                                
                                <div class="d-flex justify-content-center gap-3">
                                    <c:if test="${orderID != null && orderID > 0}">
                                        <a href="${pageContext.request.contextPath}/customer/orders?action=detail&id=${orderID}" class="btn btn-success btn-lg mr-2">
                                            <i class="fa fa-eye"></i> Xem Đơn Hàng
                                        </a>
                                    </c:if>
                                    <a href="${pageContext.request.contextPath}/quotation/list" class="btn btn-outline-primary btn-lg">
                                        <i class="fa fa-list"></i> Danh Sách Báo Giá
                                    </a>
                                </div>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="card border-danger">
                            <div class="card-body text-center py-5">
                                <i class="fa fa-times-circle result-icon error"></i>
                                <h2 class="text-danger mb-3">Thanh Toán Thất Bại</h2>
                                <p class="lead">${message}</p>
                                
                                <c:if test="${errorCode != null}">
                                    <p class="text-muted">Mã lỗi: ${errorCode}</p>
                                </c:if>
                                
                                <c:if test="${quotationCode != null}">
                                    <p>Mã báo giá: <strong>${quotationCode}</strong></p>
                                </c:if>
                                
                                <div class="mt-4">
                                    <a href="${pageContext.request.contextPath}/quotation/list" class="btn btn-primary btn-lg mr-2">
                                        <i class="fa fa-arrow-left"></i> Quay Lại
                                    </a>
                                    <a href="${pageContext.request.contextPath}/contact" class="btn btn-outline-secondary btn-lg">
                                        <i class="fa fa-phone"></i> Liên Hệ Hỗ Trợ
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
    <script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
