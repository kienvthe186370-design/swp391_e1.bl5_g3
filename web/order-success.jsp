<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt hàng thành công - Pickleball Shop</title>
    
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="css/style.css" type="text/css">
    
    <style>
        .success-container {
            max-width: 600px;
            margin: 50px auto;
            text-align: center;
            padding: 40px;
        }
        .success-icon {
            width: 100px;
            height: 100px;
            background: #28a745;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 30px;
        }
        .success-icon i {
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
            <div class="success-container">
                <div class="success-icon">
                    <i class="fa fa-check"></i>
                </div>
                
                <h2 class="text-success mb-3">Đặt hàng thành công!</h2>
                
                <c:if test="${not empty paymentSuccess}">
                    <div class="alert alert-success">${paymentSuccess}</div>
                </c:if>
                
                <p class="text-muted">
                    Cảm ơn bạn đã đặt hàng. Chúng tôi sẽ xử lý đơn hàng của bạn trong thời gian sớm nhất.
                </p>
                
                <c:if test="${not empty orderSuccess}">
                    <div class="order-info">
                        <div class="order-info-row">
                            <span>Mã đơn hàng:</span>
                            <strong class="text-primary">${orderSuccess.orderCode}</strong>
                        </div>
                        <div class="order-info-row">
                            <span>Ngày đặt:</span>
                            <span><fmt:formatDate value="${orderSuccess.orderDate}" pattern="dd/MM/yyyy HH:mm"/></span>
                        </div>
                        <div class="order-info-row">
                            <span>Phương thức thanh toán:</span>
                            <span>
                                <c:choose>
                                    <c:when test="${orderSuccess.paymentMethod == 'COD'}">Thanh toán khi nhận hàng</c:when>
                                    <c:when test="${orderSuccess.paymentMethod == 'VNPay'}">VNPay</c:when>
                                    <c:otherwise>${orderSuccess.paymentMethod}</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <div class="order-info-row">
                            <span>Trạng thái thanh toán:</span>
                            <span>
                                <c:choose>
                                    <c:when test="${orderSuccess.paymentStatus == 'Paid'}">
                                        <span class="badge badge-success">Đã thanh toán</span>
                                    </c:when>
                                    <c:when test="${orderSuccess.paymentStatus == 'Unpaid'}">
                                        <span class="badge badge-warning">Chưa thanh toán</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-secondary">${orderSuccess.paymentStatus}</span>
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <div class="order-info-row">
                            <span>Tổng tiền:</span>
                            <strong class="text-primary">
                                <fmt:formatNumber value="${orderSuccess.totalAmount}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ
                            </strong>
                        </div>
                    </div>
                </c:if>
                
                <div class="mt-4">
                    <a href="customer/orders.jsp" class="btn btn-primary mr-2">
                        <i class="fa fa-list"></i> Xem đơn hàng
                    </a>
                    <a href="shop" class="btn btn-outline-primary">
                        <i class="fa fa-shopping-bag"></i> Tiếp tục mua sắm
                    </a>
                </div>
            </div>
        </div>
    </section>

    <%@include file="footer.jsp"%>

    <script src="js/jquery-3.3.1.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
</body>
</html>
