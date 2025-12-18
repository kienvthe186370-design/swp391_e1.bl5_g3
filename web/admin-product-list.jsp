<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý sản phẩm - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .product-image {
            width: 60px;
            height: 60px;
            object-fit: cover;
            border-radius: 4px;
        }
        .product-name {
            font-weight: 500;
            color: #333;
            margin-bottom: 4px;
        }
        .variant-badge {
            font-size: 0.75rem;
            color: #6c757d;
        }
        .category-badge {
            background-color: #17a2b8;
            color: white;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 0.75rem;
        }
        .brand-badge {
            background-color: #343a40;
            color: white;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 0.75rem;
        }
        .stock-number {
            color: #28a745;
            font-weight: 600;
            font-size: 1rem;
        }
        .reserved-stock {
            font-size: 0.75rem;
            color: #6c757d;
        }
        .price-text {
            color: #007bff;
            font-weight: 500;
        }
        .table-row {
            border-bottom: 1px solid #e9ecef;
        }
        .table-row:hover {
            background-color: #f8f9fa;
        }
    </style>
</head>
<body>
<div class="container-fluid mt-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="mb-0">Danh sách sản phẩm</h2>
    </div>

    <!-- Filter Form -->
    <form class="row g-2 mb-4" method="get" action="${pageContext.request.contextPath}/admin/products">
        <div class="col-md-4">
            <input type="text" name="q" value="${q}" class="form-control" placeholder="Tìm theo tên sản phẩm">
        </div>
        <div class="col-md-2">
            <select name="status" class="form-select">
                <option value="">-- Trạng thái --</option>
                <option value="active" ${status == 'active' ? 'selected' : ''}>Đang bán</option>
                <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Ngừng bán</option>
            </select>
        </div>
        <div class="col-md-2">
            <button type="submit" class="btn btn-primary">Lọc</button>
        </div>
    </form>

    <!-- Product Table -->
    <div class="table-responsive">
        <table class="table table-hover">
            <thead>
            <tr>
                <th style="width: 60px;">ID</th>
                <th style="width: 80px;">Ảnh</th>
                <th>Tên sản phẩm</th>
                <th>Danh mục</th>
                <th>Thương hiệu</th>
                <th>Số lượng</th>
                <th>Giá bán</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="p" items="${products}">
                <tr class="table-row">
                    <td>
                        <strong>#${p.productID}</strong>
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${not empty p.mainImageUrl}">
                                <img src="${p.mainImageUrl}" alt="${p.productName}" class="product-image">
                            </c:when>
                            <c:otherwise>
                                <img src="${pageContext.request.contextPath}/img/product/product-1.jpg" alt="No image" class="product-image">
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <div class="product-name">${p.productName}</div>
                        <div class="variant-badge">
                            📦 ${p.variantCount} biến thể
                        </div>
                    </td>
                    <td>
                        <c:if test="${not empty p.categoryName}">
                            <span class="category-badge">${p.categoryName}</span>
                        </c:if>
                    </td>
                    <td>
                        <c:if test="${not empty p.brandName}">
                            <span class="brand-badge">${p.brandName}</span>
                        </c:if>
                    </td>
                    <td>
                        <div class="stock-number">${p.totalStock}</div>
                        <c:if test="${p.reservedStock > 0}">
                            <div class="reserved-stock">Giữ: ${p.reservedStock}</div>
                        </c:if>
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${p.minPrice != null && p.maxPrice != null}">
                                <c:if test="${p.minPrice.compareTo(p.maxPrice) == 0}">
                                    <span class="price-text">
                                        <fmt:formatNumber value="${p.minPrice}" type="number" maxFractionDigits="0"/>₫
                                    </span>
                                </c:if>
                                <c:if test="${p.minPrice.compareTo(p.maxPrice) != 0}">
                                    <span class="price-text">
                                        <fmt:formatNumber value="${p.minPrice}" type="number" maxFractionDigits="0"/>₫ - 
                                        <fmt:formatNumber value="${p.maxPrice}" type="number" maxFractionDigits="0"/>₫
                                    </span>
                                </c:if>
                            </c:when>
                            <c:otherwise>
                                <span class="text-muted">Chưa có giá</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty products}">
                <tr>
                    <td colspan="7" class="text-center py-4">
                        <p class="text-muted mb-0">Không có sản phẩm nào.</p>
                    </td>
                </tr>
            </c:if>
            </tbody>
        </table>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
