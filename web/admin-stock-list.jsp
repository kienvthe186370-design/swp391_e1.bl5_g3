<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý kho - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .product-image {
            width: 50px;
            height: 50px;
            object-fit: cover;
            border-radius: 4px;
        }
        .product-name {
            font-weight: 600;
            color: #333;
            margin-bottom: 4px;
        }
        .sku-code {
            font-size: 0.75rem;
            color: #6c757d;
            font-family: monospace;
        }
        .category-badge {
            background-color: #17a2b8;
            color: white;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 0.75rem;
        }
        .brand-badge {
            background-color: #6c757d;
            color: white;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 0.75rem;
        }
        .stock-in {
            color: #28a745;
            font-weight: 600;
        }
        .stock-low {
            color: #ffc107;
            font-weight: 600;
        }
        .stock-out {
            color: #dc3545;
            font-weight: 600;
        }
        .price-cost {
            color: #333;
        }
        .price-sell {
            color: #dc3545;
            font-weight: 600;
        }
        .profit-percent {
            color: #28a745;
            font-weight: 500;
        }
        .profit-amount {
            font-size: 0.75rem;
            color: #6c757d;
        }
        .table-row {
            border-bottom: 1px solid #e9ecef;
        }
        .table-row:hover {
            background-color: #f8f9fa;
        }
        .breadcrumb-item a {
            text-decoration: none;
        }
    </style>
</head>
<body>
<div class="container-fluid mt-4">
    <!-- Header & Breadcrumb -->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
            <h2 class="mb-1">Quản lý kho</h2>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-0">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
                    <li class="breadcrumb-item active" aria-current="page">Quản lý kho</li>
                </ol>
            </nav>
        </div>
    </div>

    <!-- Filter Form -->
    <form class="row g-2 mb-4" method="get" action="${pageContext.request.contextPath}/admin/stock">
        <div class="col-md-3">
            <input type="text" name="keyword" value="${keyword}" class="form-control" placeholder="Tên sản phẩm, SKU...">
        </div>
        <div class="col-md-2">
            <select name="categoryId" class="form-select">
                <option value="">Tất cả danh mục</option>
                <c:forEach var="cat" items="${categories}">
                    <option value="${cat.categoryID}" ${categoryId == cat.categoryID ? 'selected' : ''}>${cat.categoryName}</option>
                </c:forEach>
            </select>
        </div>
        <div class="col-md-2">
            <select name="brandId" class="form-select">
                <option value="">Tất cả thương hiệu</option>
                <c:forEach var="brand" items="${brands}">
                    <option value="${brand.brandID}" ${brandId == brand.brandID ? 'selected' : ''}>${brand.brandName}</option>
                </c:forEach>
            </select>
        </div>
        <div class="col-md-2">
            <select name="stockStatus" class="form-select">
                <option value="">Tất cả tình trạng</option>
                <option value="in_stock" ${stockStatus == 'in_stock' ? 'selected' : ''}>Còn hàng</option>
                <option value="low_stock" ${stockStatus == 'low_stock' ? 'selected' : ''}>Sắp hết</option>
                <option value="out_stock" ${stockStatus == 'out_stock' ? 'selected' : ''}>Hết hàng</option>
                <option value="not_imported" ${stockStatus == 'not_imported' ? 'selected' : ''}>Chưa nhập</option>
            </select>
        </div>
        <div class="col-md-2">
            <select name="sortBy" class="form-select">
                <option value="created_date" ${sortBy == 'created_date' ? 'selected' : ''}>Ngày tạo</option>
                <option value="stock" ${sortBy == 'stock' ? 'selected' : ''}>Tồn kho</option>
                <option value="cost_price" ${sortBy == 'cost_price' ? 'selected' : ''}>Giá vốn</option>
            </select>
        </div>
        <div class="col-md-1">
            <button type="submit" class="btn btn-primary w-100">
                <i class="fas fa-search"></i> Tìm
            </button>
        </div>
    </form>

    <!-- Stock Table -->
    <div class="table-responsive">
        <table class="table table-hover">
            <thead class="table-light">
            <tr>
                <th style="width: 60px;">Ảnh</th>
                <th>Sản phẩm / SKU</th>
                <th>Danh mục</th>
                <th>Thương hiệu</th>
                <th class="text-center">Tồn kho</th>
                <th class="text-end">Giá vốn TB</th>
                <th class="text-end">Giá bán</th>
                <th class="text-end">Lợi nhuận</th>
                <th class="text-center">Tình trạng</th>
                <th class="text-center">Thao tác</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="item" items="${stockList}">
                <tr class="table-row">
                    <td>
                        <c:choose>
                            <c:when test="${not empty item.imageUrl}">
                                <img src="${item.imageUrl}" alt="${item.productName}" class="product-image">
                            </c:when>
                            <c:otherwise>
                                <img src="${pageContext.request.contextPath}/img/product/product-1.jpg" alt="No image" class="product-image">
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <div class="product-name">${item.productName}</div>
                        <code class="sku-code">${item.sku}</code>
                    </td>
                    <td>
                        <c:if test="${not empty item.categoryName}">
                            <span class="category-badge">${item.categoryName}</span>
                        </c:if>
                    </td>
                    <td>
                        <c:if test="${not empty item.brandName}">
                            <span class="brand-badge">${item.brandName}</span>
                        </c:if>
                    </td>
                    <td class="text-center">
                        <c:choose>
                            <c:when test="${item.currentStock > 10}">
                                <span class="stock-in">${item.currentStock}</span>
                            </c:when>
                            <c:when test="${item.currentStock > 0}">
                                <span class="stock-low">${item.currentStock}</span>
                            </c:when>
                            <c:otherwise>
                                <span class="stock-out">${item.currentStock}</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td class="text-end">
                        <span class="price-cost">
                            <fmt:formatNumber value="${item.avgCostPrice}" type="number" maxFractionDigits="0"/>₫
                        </span>
                    </td>
                    <td class="text-end">
                        <span class="price-sell">
                            <fmt:formatNumber value="${item.sellingPrice}" type="number" maxFractionDigits="0"/>₫
                        </span>
                    </td>
                    <td class="text-end">
                        <div class="profit-percent">${item.profitPercent}%</div>
                        <div class="profit-amount">
                            <fmt:formatNumber value="${item.profitAmount}" type="number" maxFractionDigits="0"/>₫
                        </div>
                    </td>
                    <td class="text-center">
                        <c:choose>
                            <c:when test="${item.currentStock > 10}">
                                <span class="badge bg-success">Còn hàng</span>
                            </c:when>
                            <c:when test="${item.currentStock > 0}">
                                <span class="badge bg-warning text-dark">Sắp hết</span>
                            </c:when>
                            <c:when test="${item.stockStatus == 'out_stock' || item.hasReceipt == true}">
                                <span class="badge bg-danger">Hết hàng</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-secondary">Chưa nhập</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td class="text-center">
                        <a href="${pageContext.request.contextPath}/admin/stock/detail?id=${item.variantId}" 
                           class="btn btn-success btn-sm" title="Nhập kho">
                            <i class="fas fa-plus"></i> Nhập kho
                        </a>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty stockList}">
                <tr>
                    <td colspan="10" class="text-center py-4">
                        <i class="fas fa-box-open fa-3x text-muted mb-3"></i>
                        <p class="text-muted mb-0">Không có dữ liệu tồn kho.</p>
                    </td>
                </tr>
            </c:if>
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <c:if test="${totalPages > 1}">
        <div class="d-flex justify-content-between align-items-center mt-4">
            <div class="text-muted">
                Hiển thị trang ${currentPage} / ${totalPages} (Tổng: ${totalRecords} bản ghi)
            </div>
            <nav aria-label="Page navigation">
                <ul class="pagination mb-0">
                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="${pageContext.request.contextPath}/admin/stock?page=${currentPage - 1}&keyword=${keyword}&categoryId=${categoryId}&brandId=${brandId}&stockStatus=${stockStatus}&sortBy=${sortBy}">
                            <i class="fas fa-chevron-left"></i>
                        </a>
                    </li>
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <c:if test="${i >= currentPage - 2 && i <= currentPage + 2}">
                            <li class="page-item ${i == currentPage ? 'active' : ''}">
                                <a class="page-link" href="${pageContext.request.contextPath}/admin/stock?page=${i}&keyword=${keyword}&categoryId=${categoryId}&brandId=${brandId}&stockStatus=${stockStatus}&sortBy=${sortBy}">${i}</a>
                            </li>
                        </c:if>
                    </c:forEach>
                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="${pageContext.request.contextPath}/admin/stock?page=${currentPage + 1}&keyword=${keyword}&categoryId=${categoryId}&brandId=${brandId}&stockStatus=${stockStatus}&sortBy=${sortBy}">
                            <i class="fas fa-chevron-right"></i>
                        </a>
                    </li>
                </ul>
            </nav>
        </div>
    </c:if>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
