<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kết quả thanh toán - Pickleball Shop</title>
    
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="css/style.css" type="text/css">
    
    <style>
        .result-container {
            max-width: 600px;
            margin: 50px auto;
            text-align: center;
            padding: 40px;
        }
        .result-icon {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 30px;
        }
        .result-icon.error {
            background: #dc3545;
        }
        .result-icon.warning {
            background: #ffc107;
        }
        .result-icon i {
            font-size: 50px;
            color: white;
        }
        .order-info {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            margin: 30px 0;
            text-align: left;
        }
        .order-info-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #dee2e6;
        }
        .order-info-row:last-child {
            border-bottom: none;
        }
    </style>
</head>
<body>
    <%@include file="header.jsp" %>

    <section class="spad">
        <div class="container">
            <div class="result-container">
                <c:choose>
                    <c:when test="${param.status == 'failed'}">
                        <div class="result-icon error">
                            <i class="fa fa-times"></i>
                        </div>
                        <h2 class="text-danger mb-3">Thanh toán thất bại!</h2>
                        
                        <c:if test="${not empty paymentError}">
                            <div class="alert alert-danger">${paymentError}</div>
                        </c:if>
                        
                        <p class="text-muted">
                            Rất tiếc, giao dịch thanh toán của bạn không thành công. 
                            Vui lòng thử lại hoặc chọn phương thức thanh toán khác.
                        </p>
                        
                        <c:if test="${not empty failedOrder}">
                            <div class="order-info">
                                <div class="order-info-row">
                                    <span>Mã đơn hàng:</span>
                                    <strong>${failedOrder.orderCode}</strong>
                                </div>
                                <div class="order-info-row">
                                    <span>Tổng tiền:</span>
                                    <strong>
                                        <fmt:formatNumber value="${failedOrder.totalAmount}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ
                                    </strong>
                                </div>
                            </div>
                            
                            <div class="mt-4">
                                <a href="checkout?retry=${failedOrder.orderID}" class="btn btn-primary mr-2">
                                    <i class="fa fa-refresh"></i> Thử lại thanh toán
                                </a>
                                <a href="customer/orders.jsp" class="btn btn-outline-secondary">
                                    <i class="fa fa-list"></i> Xem đơn hàng
                                </a>
                            </div>
                        </c:if>
                    </c:when>
                    
                    <c:otherwise>
                        <div class="result-icon warning">
                            <i class="fa fa-exclamation"></i>
                        </div>
                        <h2 class="text-warning mb-3">Có lỗi xảy ra</h2>
                        
                        <c:if test="${not empty paymentError}">
                            <div class="alert alert-warning">${paymentError}</div>
                        </c:if>
                        
                        <p class="text-muted">
                            Đã có lỗi xảy ra trong quá trình xử lý. 
                            Vui lòng liên hệ với chúng tôi nếu bạn cần hỗ trợ.
                        </p>
                        
                        <div class="mt-4">
                            <a href="home" class="btn btn-primary mr-2">
                                <i class="fa fa-home"></i> Về trang chủ
                            </a>
                            <a href="contact.jsp" class="btn btn-outline-secondary">
                                <i class="fa fa-phone"></i> Liên hệ hỗ trợ
                            </a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </section>

    <%@include file="footer.jsp"%>

    <script src="js/jquery-3.3.1.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
</body>
</html>
