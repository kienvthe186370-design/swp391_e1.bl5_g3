<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<style>
    /* Compact table rows to fit viewport without scrollbar */
    .table td, .table th {
        padding: 0.5rem 0.75rem;
        vertical-align: middle;
    }
    
    .product-img {
        width: 40px;
        height: 40px;
        object-fit: cover;
        border-radius: 4px;
    }
    
    .product-img-placeholder {
        width: 40px;
        height: 40px;
        background-color: #f4f6f9;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 4px;
        color: #adb5bd;
        font-size: 12px;
    }
    
    .badge-custom {
        padding: 3px 6px;
        font-size: 11px;
        border-radius: 3px;
    }
    
    .product-name {
        font-weight: 500;
        color: #495057;
        margin-bottom: 1px;
        font-size: 13px;
    }
    
    .product-variants-info {
        font-size: 11px;
        color: #6c757d;
    }
    
    .btn-action {
        padding: 2px 6px;
        font-size: 12px;
    }
    
    .price-text {
        font-weight: 600;
        color: #007bff;
        font-size: 13px;
    }
    
    .stock-info {
        font-size: 12px;
    }
    
    .stock-reserved {
        color: #6c757d;
        font-size: 11px;
    }
    
    /* Draft product highlighting */
    tr.product-draft {
        background-color: #FFF9E6 !important;
    }
    
    tr.product-draft:hover {
        background-color: #FFF3CD !important;
    }
    
    /* Compact filter section */
    .card-body .form-group {
        margin-bottom: 0.5rem;
    }
    
    .card-body .form-group label {
        margin-bottom: 0.25rem;
        font-size: 12px;
    }
    
    .card-body .form-control {
        padding: 0.25rem 0.5rem;
        font-size: 13px;
        height: auto;
    }
    
    /* Compact content header */
    .content-header {
        padding: 0.5rem 0.5rem;
    }
    
    .content-header h1 {
        font-size: 1.5rem;
    }
    
    /* Compact card header */
    .card-header {
        padding: 0.5rem 1rem;
    }
    
    .card-header .card-title {
        font-size: 1rem;
    }
    
    /* Reduce card body padding */
    .card > .card-body {
        padding: 0.75rem;
    }
</style>

<!-- Content Header -->
<section class="content-header">
    <div class="container-fluid">
        <div class="row mb-2">
            <div class="col-sm-6">
                <h1>Quản lý sản phẩm</h1>
            </div>
            <div class="col-sm-6">
                <ol class="breadcrumb float-sm-right">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
                    <li class="breadcrumb-item active">Sản phẩm</li>
                </ol>
            </div>
        </div>
    </div>
</section>

<!-- Main content -->
<section class="content">
    <div class="container-fluid">
        
        <!-- Success/Error Messages -->
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle"></i> ${successMessage}
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
        </c:if>
        
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-triangle"></i> ${errorMessage}
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
        </c:if>

        <div class="card">
            <div class="card-header">
                <div class="row align-items-center">
                    <div class="col-md-8">
                        <h3 class="card-title">
                            <i class="fas fa-list"></i> Danh sách sản phẩm
                            <span class="badge badge-info ml-2">${totalProducts} sản phẩm</span>
                        </h3>
                    </div>
                    <div class="col-md-4 text-right">
                        <a href="${pageContext.request.contextPath}/admin/product-add" class="btn btn-primary">
                            <i class="fas fa-plus"></i> Thêm sản phẩm
                        </a>
                    </div>
                </div>
            </div>
            
            <!-- Filter Section -->
            <div class="card-body">
                <form method="get" action="${pageContext.request.contextPath}/admin/products" class="mb-3">
                    <div class="row">
                        <!-- Search -->
                        <div class="col-md-3">
                            <div class="form-group">
                                <label>Tìm kiếm</label>
                                <input type="text" name="search" class="form-control" 
                                       placeholder="Tên sản phẩm..." value="${search}">
                            </div>
                        </div>
                        
                        <!-- Category Filter -->
                        <div class="col-md-2">
                            <div class="form-group">
                                <label>Danh mục</label>
                                <select name="categoryId" class="form-control">
                                    <option value="">Tất cả</option>
                                    <c:forEach var="cat" items="${categories}">
                                        <option value="${cat.categoryID}" ${categoryId == cat.categoryID ? 'selected' : ''}>
                                            ${cat.categoryName}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        
                        <!-- Brand Filter -->
                        <div class="col-md-2">
                            <div class="form-group">
                                <label>Thương hiệu</label>
                                <select name="brandId" class="form-control">
                                    <option value="">Tất cả</option>
                                    <c:forEach var="brand" items="${brands}">
                                        <option value="${brand.brandID}" ${brandId == brand.brandID ? 'selected' : ''}>
                                            ${brand.brandName}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        
                        <!-- Product Status Filter -->
                        <div class="col-md-2">
                            <div class="form-group">
                                <label>Tình trạng</label>
                                <select name="statusFilter" class="form-control">
                                    <option value="">Tất cả 
                                        <c:if test="${not empty statusCounts}">
                                            (${statusCounts.draft + statusCounts.in_stock + statusCounts.out_of_stock})
                                        </c:if>
                                    </option>
                                    <option value="draft" ${statusFilter == 'draft' ? 'selected' : ''}>
                                        Nháp
                                        <c:if test="${not empty statusCounts}"> (${statusCounts.draft})</c:if>
                                    </option>
                                    <option value="in_stock" ${statusFilter == 'in_stock' ? 'selected' : ''}>
                                        Còn hàng
                                        <c:if test="${not empty statusCounts}"> (${statusCounts.in_stock})</c:if>
                                    </option>
                                    <option value="out_of_stock" ${statusFilter == 'out_of_stock' ? 'selected' : ''}>
                                        Hết hàng
                                        <c:if test="${not empty statusCounts}"> (${statusCounts.out_of_stock})</c:if>
                                    </option>
                                </select>
                            </div>
                        </div>
                        
                        <!-- Active Status Filter -->
                        <div class="col-md-2">
                            <div class="form-group">
                                <label>Trạng thái</label>
                                <select name="status" class="form-control">
                                    <option value="">Tất cả</option>
                                    <option value="active" ${status == 'active' ? 'selected' : ''}>Hoạt động</option>
                                    <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Không hoạt động</option>
                                </select>
                            </div>
                        </div>
                        
                        <!-- Sort -->
                        <div class="col-md-2">
                            <div class="form-group">
                                <label>Sắp xếp</label>
                                <select name="sortBy" class="form-control">
                                    <option value="date" ${sortBy == 'date' ? 'selected' : ''}>Ngày tạo</option>
                                    <option value="name" ${sortBy == 'name' ? 'selected' : ''}>Tên sản phẩm</option>
                                    <option value="price" ${sortBy == 'price' ? 'selected' : ''}>Giá</option>
                                    <option value="stock" ${sortBy == 'stock' ? 'selected' : ''}>Tồn kho</option>
                                </select>
                            </div>
                        </div>
                        
                        <!-- Action Buttons -->
                        <div class="col-md-1">
                            <div class="form-group">
                                <label>&nbsp;</label>
                                <button type="submit" class="btn btn-info btn-block">
                                    <i class="fas fa-search"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </form>
                
                <!-- Products Table -->
                <div class="table-responsive">
                    <table class="table table-bordered table-hover">
                        <thead>
                            <tr>
                                <th style="width: 60px;">ID</th>
                                <th style="width: 80px;">Ảnh</th>
                                <th>Tên sản phẩm</th>
                                <th style="width: 150px;">Danh mục</th>
                                <th style="width: 120px;">Thương hiệu</th>
                                <th style="width: 100px;">Tồn kho</th>
                                <th style="width: 130px;">Giá bán</th>
                                <th style="width: 120px;">Tình trạng</th>
                                <th style="width: 100px;">Trạng thái</th>
                                <th style="width: 150px;">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty products}">
                                    <tr>
                                        <td colspan="10" class="text-center py-4"></td>
                                            <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                                            <p class="text-muted">Không có sản phẩm nào</p>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="item" items="${products}">
                                        <tr class="${item.status == 'draft' ? 'product-draft' : ''}">
                                            <!-- ID -->
                                            <td class="text-center">#${item.productID}</td>
                                            
                                            <!-- Image -->
                                            <td class="text-center">
                                                <c:choose>
                                                    <c:when test="${not empty item.mainImageUrl}">
                                                        <img src="${pageContext.request.contextPath}${item.mainImageUrl}" 
                                                             class="product-img" alt="${item.productName}">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="product-img-placeholder">
                                                            <i class="fas fa-image"></i>
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            
                                            <!-- Product Name -->
                                            <td>
                                                <div class="product-name">${item.productName}</div>
                                                <div class="product-variants-info">
                                                    <i class="fas fa-boxes"></i> ${item.variantCount} biến thể
                                                </div>
                                            </td>
                                            
                                            <!-- Category -->
                                            <td>
                                                <span class="badge badge-info badge-custom">
                                                    ${item.categoryName}
                                                </span>
                                            </td>
                                            
                                            <!-- Brand -->
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty item.brandName}">
                                                        <span class="badge badge-secondary badge-custom">
                                                            ${item.brandName}
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">-</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            
                                            <!-- Stock -->
                                            <td class="text-center">
                                                <div class="stock-info">
                                                    <c:choose>
                                                        <c:when test="${item.status == 'draft'}">
                                                            <span class="badge badge-secondary">
                                                                <i class="fas fa-minus"></i> Chưa nhập
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${item.totalStock == 0}">
                                                            <span class="badge badge-danger">Hết hàng</span>
                                                        </c:when>
                                                        <c:when test="${item.totalStock <= 10}">
                                                            <span class="badge badge-warning">
                                                                <i class="fas fa-exclamation-triangle"></i> ${item.totalStock}
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge badge-success">${item.totalStock}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <c:if test="${item.reservedStock > 0}">
                                                    <div class="stock-reserved">Giữ: ${item.reservedStock}</div>
                                                </c:if>
                                            </td>
                                            
                                            <!-- Price -->
                                            <td class="text-right">
                                                <c:choose>
                                                    <c:when test="${item.minPrice != null && item.maxPrice != null}">
                                                        <c:choose>
                                                            <c:when test="${item.minPrice == item.maxPrice}">
                                                                <div class="price-text">
                                                                    <fmt:formatNumber value="${item.minPrice}" type="number" groupingUsed="true"/>đ
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="price-text">
                                                                    <fmt:formatNumber value="${item.minPrice}" type="number" groupingUsed="true"/>đ
                                                                    - 
                                                                    <fmt:formatNumber value="${item.maxPrice}" type="number" groupingUsed="true"/>đ
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">Chưa có giá</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            
                                            <!-- Tình trạng (Product Status) -->
                                            <td class="text-center">
                                                <c:choose>
                                                    <c:when test="${item.status == 'draft'}">
                                                        <span class="badge badge-primary badge-custom" 
                                                              data-toggle="tooltip" 
                                                              title="Sản phẩm cần bổ sung variant và giá bán">
                                                            <i class="fas fa-edit"></i> Nháp
                                                        </span>
                                                    </c:when>
                                                    <c:when test="${item.status == 'out_of_stock'}">
                                                        <span class="badge badge-danger badge-custom">
                                                            <i class="fas fa-times-circle"></i> Hết hàng
                                                        </span>
                                                    </c:when>
                                                    <c:when test="${item.status == 'in_stock'}">
                                                        <span class="badge badge-success badge-custom">
                                                            <i class="fas fa-check-circle"></i> Còn hàng
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-secondary badge-custom">
                                                            <i class="fas fa-question-circle"></i> N/A
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            
                                            <!-- Status (Active/Inactive) -->
                                            <td class="text-center">
                                                <c:choose>
                                                    <c:when test="${item.isActive}">
                                                        <span class="badge badge-success badge-custom">
                                                            <i class="fas fa-check-circle"></i> Hoạt động
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-secondary badge-custom">
                                                            <i class="fas fa-ban"></i> Dừng
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            
                                            <!-- Actions -->
                                            <td class="text-center">
                                                <a href="${pageContext.request.contextPath}/admin/product-details?id=${item.productID}" 
                                                   class="btn btn-info btn-sm btn-action" title="Xem chi tiết">
                                                    <i class="fas fa-eye"></i>
                                                </a>
                                                <a href="${pageContext.request.contextPath}/admin/product-edit?id=${item.productID}" 
                                                   class="btn btn-primary btn-sm btn-action" title="Chỉnh sửa">
                                                    <i class="fas fa-edit"></i>
                                                </a>
                                                <c:choose>
                                                    <c:when test="${item.isActive}">
                                                        <button type="button" class="btn btn-warning btn-sm btn-action" 
                                                                data-product-id="${item.productID}"
                                                                data-product-name="<c:out value='${item.productName}'/>"
                                                                data-is-active="true"
                                                                onclick="toggleProductStatus(this)" 
                                                                title="Dừng hoạt động">
                                                            <i class="fas fa-lock"></i>
                                                        </button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button type="button" class="btn btn-success btn-sm btn-action" 
                                                                data-product-id="${item.productID}"
                                                                data-product-name="<c:out value='${item.productName}'/>"
                                                                data-is-active="false"
                                                                onclick="toggleProductStatus(this)" 
                                                                title="Kích hoạt">
                                                            <i class="fas fa-unlock"></i>
                                                        </button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td></i>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
                
                <!-- Pagination -->
                <c:if test="${totalPages > 1}">
                    <div class="row mt-3">
                        <div class="col-md-6">
                            <p class="text-muted">
                                Hiển thị ${(currentPage - 1) * pageSize + 1} - 
                                ${currentPage * pageSize > totalProducts ? totalProducts : currentPage * pageSize} 
                                trong tổng số ${totalProducts} sản phẩm
                            </p>
                        </div>
                        <div class="col-md-6">
                            <nav aria-label="Page navigation">
                                <ul class="pagination justify-content-end mb-0">
                                    <!-- Previous -->
                                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                        <a class="page-link" href="?page=${currentPage - 1}&search=${search}&categoryId=${categoryId}&brandId=${brandId}&status=${status}&statusFilter=${statusFilter}&sortBy=${sortBy}&sortOrder=${sortOrder}">
                                            <i class="fas fa-chevron-left"></i>
                                        </a>
                                    </li>
                                    
                                    <!-- Page Numbers -->
                                    <c:forEach begin="1" end="${totalPages}" var="i">
                                        <c:if test="${i == 1 || i == totalPages || (i >= currentPage - 2 && i <= currentPage + 2)}">
                                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                                <a class="page-link" href="?page=${i}&search=${search}&categoryId=${categoryId}&brandId=${brandId}&status=${status}&statusFilter=${statusFilter}&sortBy=${sortBy}&sortOrder=${sortOrder}">
                                                    ${i}
                                                </a>
                                            </li>
                                        </c:if>
                                        <c:if test="${i == 2 && currentPage > 4}">
                                            <li class="page-item disabled"><span class="page-link">...</span></li>
                                        </c:if>
                                        <c:if test="${i == totalPages - 1 && currentPage < totalPages - 3}">
                                            <li class="page-item disabled"><span class="page-link">...</span></li>
                                        </c:if>
                                    </c:forEach>
                                    
                                    <!-- Next -->
                                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                        <a class="page-link" href="?page=${currentPage + 1}&search=${search}&categoryId=${categoryId}&brandId=${brandId}&status=${status}&statusFilter=${statusFilter}&sortBy=${sortBy}&sortOrder=${sortOrder}">
                                            <i class="fas fa-chevron-right"></i>
                                        </a>
                                    </li>
                                </ul>
                            </nav>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
</section>

<script>
function toggleProductStatus(button) {
    var productId = button.getAttribute('data-product-id');
    var productName = button.getAttribute('data-product-name');
    var isActive = button.getAttribute('data-is-active') === 'true';
    
    var action = isActive ? 'dừng hoạt động' : 'kích hoạt';
    var confirmMessage = 'Bạn có chắc muốn ' + action + ' sản phẩm "' + productName + '" không?';
    
    if (confirm(confirmMessage)) {
        var newStatus = isActive ? 'inactive' : 'active';
        window.location.href = '${pageContext.request.contextPath}/admin/products?action=toggle-status&id=' + productId + '&status=' + newStatus;
    }
}

// Auto dismiss alerts after 5 seconds
$(document).ready(function() {
    setTimeout(function() {
        $('.alert').fadeOut('slow');
    }, 5000);
    
    // Initialize tooltips
    $('[data-toggle="tooltip"]').tooltip();
});
</script>
