<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="entity.Customer" %>
<%
    Customer customer = (Customer) session.getAttribute("customer");
    if (customer == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đánh giá đơn hàng - Pickleball Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" type="text/css">
    <style>
        .review-select-card {
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.08);
            overflow: hidden;
            max-width: 800px;
            margin: 0 auto;
        }
        .review-select-header {
            background: linear-gradient(135deg, #2D5A27 0%, #3D7A37 100%);
            color: white;
            padding: 24px 28px;
        }
        .review-select-header h1 {
            font-size: 22px;
            font-weight: 700;
            margin: 0 0 8px;
        }
        .review-select-header p {
            opacity: 0.9;
            font-size: 14px;
            margin: 0;
        }
        .product-review-item {
            display: flex;
            align-items: center;
            padding: 20px 28px;
            border-bottom: 1px solid #eee;
            transition: background 0.2s;
        }
        .product-review-item:hover {
            background: #f9f9f9;
        }
        .product-review-item:last-child {
            border-bottom: none;
        }
        .product-review-item img {
            width: 80px;
            height: 80px;
            object-fit: contain;
            border-radius: 8px;
            background: #f5f5f5;
            margin-right: 16px;
        }
        .product-review-info {
            flex: 1;
        }
        .product-review-info h4 {
            font-size: 16px;
            font-weight: 600;
            margin: 0 0 6px;
            color: #333;
        }
        .product-review-info .sku {
            font-size: 13px;
            color: #888;
            margin-bottom: 4px;
        }
        .product-review-info .qty {
            font-size: 13px;
            color: #666;
        }
        .btn-review-product {
            background: #2D5A27;
            color: white;
            padding: 10px 20px;
            border-radius: 6px;
            text-decoration: none;
            font-weight: 600;
            font-size: 14px;
            transition: all 0.2s;
        }
        .btn-review-product:hover {
            background: #1E3D1A;
            color: white;
            text-decoration: none;
        }
        .reviewed-badge {
            background: #28a745;
            color: white;
            padding: 8px 16px;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 600;
        }
        .section-title {
            padding: 16px 28px 8px;
            font-size: 14px;
            font-weight: 700;
            color: #666;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            background: #f9f9f9;
        }
        .reviewed-item {
            opacity: 0.6;
        }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />

    <section class="breadcrumb-option">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="breadcrumb__text">
                        <h4>Đánh giá đơn hàng</h4>
                        <div class="breadcrumb__links">
                            <a href="${pageContext.request.contextPath}/Home">Trang chủ</a>
                            <a href="${pageContext.request.contextPath}/customer/orders">Đơn hàng của tôi</a>
                            <span>Đánh giá đơn hàng ${order.orderCode}</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="spad">
        <div class="container">
            <div class="review-select-card">
                <div class="review-select-header">
                    <h1><i class="fa fa-star" style="margin-right: 10px;"></i>Đánh giá đơn hàng ${order.orderCode}</h1>
                    <p>Chọn sản phẩm bạn muốn đánh giá</p>
                </div>

                <!-- Sản phẩm chưa đánh giá -->
                <c:if test="${not empty pendingReviews}">
                    <div class="section-title">
                        <i class="fa fa-clock-o"></i> Chờ đánh giá (${pendingReviews.size()})
                    </div>
                    <c:forEach var="detail" items="${pendingReviews}">
                        <div class="product-review-item">
                            <c:choose>
                                <c:when test="${not empty detail.productImage}">
                                    <img src="${pageContext.request.contextPath}/${detail.productImage}" alt="${detail.productName}">
                                </c:when>
                                <c:otherwise>
                                    <img src="${pageContext.request.contextPath}/img/product/product-placeholder.jpg" alt="${detail.productName}">
                                </c:otherwise>
                            </c:choose>
                            <div class="product-review-info">
                                <h4>${detail.productName}</h4>
                                <div class="sku">SKU: ${detail.sku}</div>
                                <div class="qty">Số lượng: ${detail.quantity}</div>
                            </div>
                            <a href="${pageContext.request.contextPath}/review?orderDetailId=${detail.orderDetailID}" class="btn-review-product">
                                <i class="fa fa-star"></i> Đánh giá ngay
                            </a>
                        </div>
                    </c:forEach>
                </c:if>

                <!-- Sản phẩm đã đánh giá -->
                <c:if test="${not empty reviewedItems}">
                    <div class="section-title">
                        <i class="fa fa-check-circle"></i> Đã đánh giá (${reviewedItems.size()})
                    </div>
                    <c:forEach var="detail" items="${reviewedItems}">
                        <div class="product-review-item reviewed-item">
                            <c:choose>
                                <c:when test="${not empty detail.productImage}">
                                    <img src="${pageContext.request.contextPath}/${detail.productImage}" alt="${detail.productName}">
                                </c:when>
                                <c:otherwise>
                                    <img src="${pageContext.request.contextPath}/img/product/product-placeholder.jpg" alt="${detail.productName}">
                                </c:otherwise>
                            </c:choose>
                            <div class="product-review-info">
                                <h4>${detail.productName}</h4>
                                <div class="sku">SKU: ${detail.sku}</div>
                                <div class="qty">Số lượng: ${detail.quantity}</div>
                            </div>
                            <span class="reviewed-badge">
                                <i class="fa fa-check"></i> Đã đánh giá
                            </span>
                        </div>
                    </c:forEach>
                </c:if>

                <div style="padding: 20px 28px; text-align: center; border-top: 1px solid #eee;">
                    <a href="${pageContext.request.contextPath}/customer/orders" class="btn btn-secondary">
                        <i class="fa fa-arrow-left"></i> Quay lại đơn hàng
                    </a>
                    <a href="${pageContext.request.contextPath}/my-reviews" class="btn btn-outline-primary ml-2">
                        <i class="fa fa-list"></i> Xem đánh giá của tôi
                    </a>
                </div>
            </div>
        </div>
    </section>

    <jsp:include page="footer.jsp" />

    <script src="${pageContext.request.contextPath}/js/jquery-3.3.1.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/bootstrap.min.js"></script>
</body>
</html>
