<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!-- Content Header (Page header) -->
<div class="content-header">
    <div class="container-fluid">
        <div class="row mb-2">
            <div class="col-sm-6">
                <h1 class="m-0">Quản lý kho</h1>
            </div>
            <div class="col-sm-6">
                <ol class="breadcrumb float-sm-right">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
                    <li class="breadcrumb-item active">Quản lý kho</li>
                </ol>
            </div>
        </div>
    </div>
</div>

<!-- Main content -->
<section class="content">
    <div class="container-fluid">
        <!-- Filter Card -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Bộ lọc</h3>
            </div>
            <div class="card-body">
                <form method="get" action="${pageContext.request.contextPath}/admin/stock">
                    <div class="row">
                        <div class="col-md-3">
                            <div class="form-group">
                                <input type="text" name="keyword" value="${keyword}" class="form-control" placeholder="Tên sản phẩm, SKU...">
                            </div>
                        </div>
                        <div class="col-md-2">
                            <div class="form-group">
                                <select name="categoryId" class="form-control">
                                    <option value="">Tất cả danh mục</option>
                                    <c:forEach var="cat" items="${categories}">
                                        <option value="${cat.categoryID}" ${categoryId == cat.categoryID ? 'selected' : ''}>${cat.categoryName}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-2">
                            <div class="form-group">
                                <select name="brandId" class="form-control">
                                    <option value="">Tất cả thương hiệu</option>
                                    <c:forEach var="brand" items="${brands}">
                                        <option value="${brand.brandID}" ${brandId == brand.brandID ? 'selected' : ''}>${brand.brandName}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-2">
                            <div class="form-group">
                                <select name="stockStatus" class="form-control">
                                    <option value="">Tất cả tình trạng</option>
                                    <option value="in_stock" ${stockStatus == 'in_stock' ? 'selected' : ''}>Còn hàng</option>
                                    <option value="low_stock" ${stockStatus == 'low_stock' ? 'selected' : ''}>Sắp hết</option>
                                    <option value="out_stock" ${stockStatus == 'out_stock' ? 'selected' : ''}>Hết hàng</option>
                                    <option value="not_imported" ${stockStatus == 'not_imported' ? 'selected' : ''}>Chưa nhập</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-2">
                            <div class="form-group">
                                <select name="sortBy" class="form-control">
                                    <option value="id" ${sortBy == 'id' ? 'selected' : ''}>ID</option>
                                    <option value="created_date" ${sortBy == 'created_date' ? 'selected' : ''}>Ngày tạo</option>
                                    <option value="stock" ${sortBy == 'stock' ? 'selected' : ''}>Tồn kho</option>
                                    <option value="cost_price" ${sortBy == 'cost_price' ? 'selected' : ''}>Giá vốn</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-1">
                            <button type="submit" class="btn btn-primary btn-block">
                                <i class="fas fa-search"></i>
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- Stock Table Card -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Danh sách tồn kho</h3>
            </div>
            <div class="card-body table-responsive p-0">
                <table class="table table-hover text-nowrap">
                    <thead>
                        <tr>
                            <th style="width: 50px;">ID</th>
                            <th style="width: 60px;">Ảnh</th>
                            <th>Sản phẩm / SKU</th>
                            <th class="text-center">Tồn kho</th>
                            <th class="text-right">Giá vốn TB</th>
                            <th class="text-right">Giá bán</th>
                            <th class="text-right">Lợi nhuận</th>
                            <th class="text-center">Tình trạng</th>
                            <th class="text-center">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="item" items="${stockList}">
                            <tr>
                                <td>
                                    <strong>#${item.variantId}</strong>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty item.imageUrl}">
                                            <img src="${pageContext.request.contextPath}${item.imageUrl}" alt="${item.productName}" style="width: 50px; height: 50px; object-fit: cover; border-radius: 4px;">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="${pageContext.request.contextPath}/img/product/product-1.jpg" alt="No image" style="width: 50px; height: 50px; object-fit: cover; border-radius: 4px;">
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <strong>${item.productName}</strong><br>
                                    <code class="text-muted">${item.sku}</code>
                                </td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${item.currentStock > 10}">
                                            <span class="text-success font-weight-bold">${item.currentStock}</span>
                                        </c:when>
                                        <c:when test="${item.currentStock > 0}">
                                            <span class="text-warning font-weight-bold">${item.currentStock}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-danger font-weight-bold">${item.currentStock}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-right">
                                    <fmt:formatNumber value="${item.avgCostPrice}" type="number" maxFractionDigits="0"/>₫
                                </td>
                                <td class="text-right">
                                    <span class="text-danger font-weight-bold">
                                        <fmt:formatNumber value="${item.sellingPrice}" type="number" maxFractionDigits="0"/>₫
                                    </span>
                                </td>
                                <td class="text-right">
                                    <span class="text-success">${item.profitPercent}%</span><br>
                                    <small class="text-muted"><fmt:formatNumber value="${item.profitAmount}" type="number" maxFractionDigits="0"/>₫</small>
                                </td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${item.currentStock > 10}">
                                            <span class="badge badge-success">Còn hàng</span>
                                        </c:when>
                                        <c:when test="${item.currentStock > 0}">
                                            <span class="badge badge-warning">Sắp hết</span>
                                        </c:when>
                                        <c:when test="${item.stockStatus == 'out_stock' || item.hasReceipt == true}">
                                            <span class="badge badge-danger">Hết hàng</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-secondary">Chưa nhập</span>
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
                                <td colspan="9" class="text-center py-4">
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
                <div class="card-footer clearfix">
                    <div class="float-left">
                        <span class="text-muted">Hiển thị trang ${currentPage} / ${totalPages} (Tổng: ${totalRecords} bản ghi)</span>
                    </div>
                    <ul class="pagination pagination-sm m-0 float-right">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/admin/stock?page=${currentPage - 1}&keyword=${keyword}&categoryId=${categoryId}&brandId=${brandId}&stockStatus=${stockStatus}&sortBy=${sortBy}">«</a>
                        </li>
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <c:if test="${i >= currentPage - 2 && i <= currentPage + 2}">
                                <li class="page-item ${i == currentPage ? 'active' : ''}">
                                    <a class="page-link" href="${pageContext.request.contextPath}/admin/stock?page=${i}&keyword=${keyword}&categoryId=${categoryId}&brandId=${brandId}&stockStatus=${stockStatus}&sortBy=${sortBy}">${i}</a>
                                </li>
                            </c:if>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/admin/stock?page=${currentPage + 1}&keyword=${keyword}&categoryId=${categoryId}&brandId=${brandId}&stockStatus=${stockStatus}&sortBy=${sortBy}">»</a>
                        </li>
                    </ul>
                </div>
            </c:if>
        </div>
    </div>
</section>
