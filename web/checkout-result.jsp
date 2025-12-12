<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kết quả đặt hàng - Pickleball Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="css/style.css" type="text/css">
    <style>
        /* Force hide preloader immediately */
        #preloder, .loader { display: none !important; }
        
        .result-container {
            max-width: 600px;
            margin: 50px auto;
            text-align: center;
            padding: 40px;
            background: #fff;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .result-icon {
            font-size: 80px;
            margin-bottom: 20px;
        }
        .result-icon.success { color: #28a745; }
        .result-icon.failed { color: #dc3545; }
        .order-code {
            font-size: 24px;
            font-weight: bold;
            color: #e53637;
            margin: 20px 0;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 8px;
        }
        .btn-group-custom {
            margin-top: 30px;
        }
        .btn-group-custom .btn {
            margin: 5px;
            padding: 12px 30px;
        }
    </style>
</head>
<body>
    <%@include file="header.jsp" %>

    <section class="spad">
        <div class="container">
            <div class="result-container">
                <c:choose>
                    <c:when test="${param.status == 'success'}">
                        <div class="result-icon success">
                            <i class="fa fa-check-circle"></i>
                        </div>
                        <h2>Đặt hàng thành công!</h2>
                        <p class="text-muted">Cảm ơn bạn đã đặt hàng. Chúng tôi sẽ xử lý đơn hàng sớm nhất.</p>

                        <c:if test="${not empty param.orderCode}">
                            <div class="order-code">
                                Mã đơn hàng: ${param.orderCode}
                            </div>
                        </c:if>
                        
                        <c:if test="${param.method == 'COD'}">
                            <div class="alert alert-info">
                                <i class="fa fa-info-circle"></i>
                                Bạn đã chọn thanh toán khi nhận hàng (COD).
                                Vui lòng chuẩn bị tiền mặt khi nhận hàng.
                            </div>
                        </c:if>
                        
                        <c:if test="${not empty param.message}">
                            <p class="text-success"><i class="fa fa-check"></i> ${param.message}</p>
                        </c:if>
                        
                        <div class="btn-group-custom">
                            <a href="shop" class="btn btn-outline-primary">
                                <i class="fa fa-shopping-bag"></i> Tiếp tục mua sắm
                            </a>
                            <a href="customer/orders.jsp" class="btn btn-primary">
                                <i class="fa fa-list"></i> Xem đơn hàng
                            </a>
                        </div>
                    </c:when>
                    
                    <c:otherwise>
                        <div class="result-icon failed">
                            <i class="fa fa-times-circle"></i>
                        </div>
                        <h2>Thanh toán thất bại</h2>
                        <p class="text-muted">Đơn hàng của bạn chưa được thanh toán thành công.</p>
                        
                        <c:if test="${not empty param.orderCode}">
                            <div class="order-code">
                                Mã đơn hàng: ${param.orderCode}
                            </div>
                        </c:if>
                        
                        <c:if test="${not empty param.message}">
                            <div class="alert alert-danger">
                                <i class="fa fa-exclamation-triangle"></i> ${param.message}
                            </div>
                        </c:if>
                        
                        <div class="btn-group-custom">
                            <a href="checkout" class="btn btn-primary">
                                <i class="fa fa-refresh"></i> Thử lại
                            </a>
                            <a href="shop" class="btn btn-outline-secondary">
                                <i class="fa fa-shopping-bag"></i> Tiếp tục mua sắm
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
    <script src="js/main.js"></script>
    <script>
        // Backup: Hide preloader immediately
        document.addEventListener('DOMContentLoaded', function() {
            var loader = document.querySelector('.loader');
            var preloder = document.getElementById('preloder');
            if (loader) loader.style.display = 'none';
            if (preloder) preloder.style.display = 'none';
        });
    </script>
</body>
</html>
