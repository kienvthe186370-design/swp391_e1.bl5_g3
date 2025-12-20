<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!-- Content Header (Page header) -->
<div class="content-header">
    <div class="container-fluid">
        <div class="row mb-2">
            <div class="col-sm-6">
                <h1 class="m-0">Quản lý sản phẩm</h1>
            </div>
            <div class="col-sm-6">
                <ol class="breadcrumb float-sm-right">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
                    <li class="breadcrumb-item active">Sản phẩm</li>
                </ol>
            </div>
        </div>
    </div>
</div>

<!-- Main content -->
<section class="content">
    <div class="container-fluid">
        <!-- Success/Error Messages -->
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle"></i> ${successMessage}
                <button type="button" class="close" data-dismiss="alert">&times;</button>
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-triangle"></i> ${errorMessage}
                <button type="button" class="close" data-dismiss="alert">&times;</button>
            </div>
        </c:if>

        <!-- Filter Card -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Bộ lọc</h3>
                <div class="card-tools">
                    <a href="${pageContext.request.contextPath}/admin/product-add" class="btn btn-primary btn-sm">
                        <i class="fas fa-plus"></i> Thêm sản phẩm
                    </a>
                </div>
            </div>
            <div class="card-body">
                <form method="get" action="${pageContext.request.contextPath}/admin/products">
                    <div class="row">
                        <div class="col">
                            <input type="text" name="search" value="${search}" class="form-control" placeholder="Tên sản phẩm...">
                        </div>
                        <div class="col">
                            <select name="categoryId" class="form-control">
                                <option value="">Danh mục</option>
                                <c:forEach var="cat" items="${categories}">
                                    <option value="${cat.categoryID}" ${categoryId == cat.categoryID ? 'selected' : ''}>${cat.categoryName}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col">
                            <select name="brandId" class="form-control">
                                <option value="">Thương hiệu</option>
                                <c:forEach var="brand" items="${brands}">
                                    <option value="${brand.brandID}" ${brandId == brand.brandID ? 'selected' : ''}>${brand.brandName}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col">
                            <select name="statusFilter" class="form-control">
                                <option value="">Tình trạng</option>
                                <option value="draft" ${statusFilter == 'draft' ? 'selected' : ''}>Nháp</option>
                                <option value="in_stock" ${statusFilter == 'in_stock' ? 'selected' : ''}>Còn hàng</option>
                                <option value="out_of_stock" ${statusFilter == 'out_of_stock' ? 'selected' : ''}>Hết hàng</option>
                            </select>
                        </div>
                        <div class="col">
                            <select name="status" class="form-control">
                                <option value="">Trạng thái</option>
                                <option value="active" ${status == 'active' ? 'selected' : ''}>Hoạt động</option>
                                <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Dừng</option>
                            </select>
                        </div>
                        <div class="col">
                            <select name="sortBy" class="form-control">
                                <option value="id" ${sortBy == 'id' ? 'selected' : ''}>Sắp xếp: ID</option>
                                <option value="date" ${sortBy == 'date' ? 'selected' : ''}>Ngày tạo</option>
                                <option value="name" ${sortBy == 'name' ? 'selected' : ''}>Tên</option>
                                <option value="price" ${sortBy == 'price' ? 'selected' : ''}>Giá</option>
                                <option value="stock" ${sortBy == 'stock' ? 'selected' : ''}>Số lượng</option>
                            </select>
                        </div>
                        <div class="col-auto">
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-search"></i>
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- Products Table Card -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Danh sách sản phẩm <span class="badge badge-info">${totalProducts}</span></h3>
            </div>
            <div class="card-body table-responsive p-0">
                <table class="table table-hover text-nowrap">
                    <thead>
                        <tr>
                            <th style="width: 50px;">ID</th>
                            <th style="width: 60px;">Ảnh</th>
                            <th>Tên sản phẩm</th>
                            <th>Danh mục</th>
                            <th>Thương hiệu</th>
                            <th class="text-center">Số lượng</th>
                            <th class="text-center">Đã giữ</th>
                            <th class="text-right">Giá nhập TB</th>
                            <th class="text-center">Tình trạng</th>
                            <th class="text-center">Trạng thái</th>
                            <th class="text-center">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="item" items="${products}">
                            <tr class="${item.status == 'draft' ? 'table-warning' : ''}">
                                <td><strong>#${item.productID}</strong></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty item.mainImageUrl}">
                                            <img src="${pageContext.request.contextPath}${item.mainImageUrl}" alt="${item.productName}" style="width: 50px; height: 50px; object-fit: cover; border-radius: 4px;">
                                        </c:when>
                                        <c:otherwise>
                                            <div style="width: 50px; height: 50px; background: #f4f6f9; display: flex; align-items: center; justify-content: center; border-radius: 4px;">
                                                <i class="fas fa-image text-muted"></i>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <strong>${item.productName}</strong><br>
                                    <small class="text-muted"><i class="fas fa-boxes"></i> ${item.variantCount} biến thể</small>
                                </td>
                                <td><span class="badge badge-info">${item.categoryName}</span></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty item.brandName}">
                                            <span class="badge badge-secondary">${item.brandName}</span>
                                        </c:when>
                                        <c:otherwise><span class="text-muted">-</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${item.status == 'draft'}">
                                            <span class="badge badge-secondary">Chưa nhập</span>
                                        </c:when>
                                        <c:when test="${item.totalStock == 0}">
                                            <span class="badge badge-danger">0</span>
                                        </c:when>
                                        <c:when test="${item.totalStock <= 10}">
                                            <span class="badge badge-warning">${item.totalStock}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-success">${item.totalStock}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${item.status == 'draft'}">
                                            <span class="text-muted">-</span>
                                        </c:when>
                                        <c:when test="${item.reservedStock == 0}">
                                            <span class="badge badge-light">0</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-info">${item.reservedStock}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-right">
                                    <c:choose>
                                        <c:when test="${item.avgCostPrice != null}">
                                            <span class="text-primary font-weight-bold">
                                                <fmt:formatNumber value="${item.avgCostPrice}" type="number" maxFractionDigits="0"/>₫
                                            </span>
                                        </c:when>
                                        <c:otherwise><span class="text-muted">Chưa có giá</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${item.status == 'draft'}">
                                            <span class="badge badge-primary">Nháp</span>
                                        </c:when>
                                        <c:when test="${item.status == 'out_of_stock'}">
                                            <span class="badge badge-danger">Hết hàng</span>
                                        </c:when>
                                        <c:when test="${item.status == 'in_stock'}">
                                            <span class="badge badge-success">Còn hàng</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-secondary">N/A</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${item.isActive}">
                                            <span class="badge badge-success">Hoạt động</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-secondary">Dừng</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center">
                                    <a href="${pageContext.request.contextPath}/admin/product-details?id=${item.productID}" class="btn btn-info btn-sm" title="Xem">
                                        <i class="fas fa-eye"></i>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/admin/product-edit?id=${item.productID}" class="btn btn-primary btn-sm" title="Sửa">
                                        <i class="fas fa-edit"></i>
                                    </a>
                                    <c:choose>
                                        <c:when test="${item.isActive}">
                                            <button type="button" class="btn btn-warning btn-sm" data-id="${item.productID}" data-name="${item.productName}" data-active="true" onclick="toggleStatus(this)" title="Dừng">
                                                <i class="fas fa-lock"></i>
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button type="button" class="btn btn-success btn-sm" data-id="${item.productID}" data-name="${item.productName}" data-active="false" onclick="toggleStatus(this)" title="Kích hoạt">
                                                <i class="fas fa-unlock"></i>
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty products}">
                            <tr>
                                <td colspan="11" class="text-center py-4">
                                    <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                                    <p class="text-muted mb-0">Không có sản phẩm nào.</p>
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
                        <span class="text-muted">Hiển thị trang ${currentPage} / ${totalPages} (Tổng: ${totalProducts} sản phẩm)</span>
                    </div>
                    <ul class="pagination pagination-sm m-0 float-right">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/admin/products?page=${currentPage - 1}&search=${search}&categoryId=${categoryId}&brandId=${brandId}&statusFilter=${statusFilter}&status=${status}&sortBy=${sortBy}">«</a>
                        </li>
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <c:if test="${i >= currentPage - 2 && i <= currentPage + 2}">
                                <li class="page-item ${i == currentPage ? 'active' : ''}">
                                    <a class="page-link" href="${pageContext.request.contextPath}/admin/products?page=${i}&search=${search}&categoryId=${categoryId}&brandId=${brandId}&statusFilter=${statusFilter}&status=${status}&sortBy=${sortBy}">${i}</a>
                                </li>
                            </c:if>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/admin/products?page=${currentPage + 1}&search=${search}&categoryId=${categoryId}&brandId=${brandId}&statusFilter=${statusFilter}&status=${status}&sortBy=${sortBy}">»</a>
                        </li>
                    </ul>
                </div>
            </c:if>
        </div>
    </div>
</section>

<script>
function toggleStatus(btn) {
    var productId = btn.getAttribute('data-id');
    var productName = btn.getAttribute('data-name');
    var isActive = btn.getAttribute('data-active') === 'true';
    var action = isActive ? 'dừng hoạt động' : 'kích hoạt';
    if (confirm('Bạn có chắc muốn ' + action + ' sản phẩm "' + productName + '"?')) {
        var newStatus = isActive ? 'inactive' : 'active';
        window.location.href = '${pageContext.request.contextPath}/admin/products?action=toggle-status&id=' + productId + '&status=' + newStatus;
    }
}
</script>
