<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<style>
    /* Main Image Gallery */
    .product-gallery {
        position: sticky;
        top: 20px;
    }
    
    .main-image-container {
        position: relative;
        background: #f8f9fa;
        border-radius: 12px;
        overflow: hidden;
        margin-bottom: 15px;
    }
    
    .main-image {
        width: 100%;
        height: 400px;
        object-fit: contain;
        cursor: zoom-in;
        transition: transform 0.3s ease;
    }
    
    .main-image:hover {
        transform: scale(1.02);
    }
    
    .thumbnail-list {
        display: flex;
        gap: 10px;
        flex-wrap: wrap;
    }
    
    .thumbnail-item {
        width: 80px;
        height: 80px;
        border-radius: 8px;
        overflow: hidden;
        cursor: pointer;
        border: 2px solid transparent;
        transition: all 0.2s ease;
    }
    
    .thumbnail-item:hover,
    .thumbnail-item.active {
        border-color: #007bff;
        box-shadow: 0 2px 8px rgba(0,123,255,0.3);
    }
    
    .thumbnail-item img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }
    
    .no-image-placeholder {
        width: 100%;
        height: 400px;
        background: linear-gradient(135deg, #f5f7fa 0%, #e4e8eb 100%);
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        border-radius: 12px;
        color: #adb5bd;
    }
    
    .no-image-placeholder i {
        font-size: 64px;
        margin-bottom: 15px;
    }
    
    /* Product Info */
    .product-title {
        font-size: 1.75rem;
        font-weight: 600;
        color: #2d3436;
        margin-bottom: 15px;
        line-height: 1.3;
    }
    
    .product-badges {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        margin-bottom: 20px;
    }
    
    .product-badges .badge {
        font-size: 0.85rem;
        padding: 8px 12px;
        font-weight: 500;
    }
    
    /* Info Sections */
    .info-section {
        background: #f8f9fa;
        border-radius: 10px;
        padding: 20px;
        margin-bottom: 20px;
    }
    
    .info-section-title {
        font-size: 0.9rem;
        font-weight: 600;
        color: #6c757d;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 12px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .info-section-content {
        color: #495057;
        line-height: 1.7;
    }
    
    /* Quick Stats */
    .quick-stats {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 15px;
        margin-bottom: 20px;
    }
    
    .stat-card {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border-radius: 10px;
        padding: 15px;
        text-align: center;
        color: white;
    }
    
    .stat-card.success {
        background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
    }
    
    .stat-card.warning {
        background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
    }
    
    .stat-card .stat-value {
        font-size: 1.5rem;
        font-weight: 700;
        display: block;
    }
    
    .stat-card .stat-label {
        font-size: 0.75rem;
        opacity: 0.9;
        text-transform: uppercase;
    }
    
    /* Variants Table */
    .variants-card {
        border: none;
        box-shadow: 0 2px 12px rgba(0,0,0,0.08);
        border-radius: 12px;
        overflow: hidden;
    }
    
    .variants-card .card-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border: none;
        padding: 15px 20px;
    }
    
    .variants-card .card-header .card-title {
        margin: 0;
        font-weight: 600;
    }
    
    .variant-table {
        margin: 0;
    }
    
    .variant-table thead th {
        background: #f8f9fa;
        border-top: none;
        font-weight: 600;
        font-size: 0.85rem;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        color: #6c757d;
        padding: 12px 15px;
    }
    
    .variant-table tbody td {
        padding: 15px;
        vertical-align: middle;
    }
    
    .variant-table tbody tr:hover {
        background: #f8f9fa;
    }
    
    .sku-badge {
        background: #e9ecef;
        padding: 5px 10px;
        border-radius: 6px;
        font-family: monospace;
        font-weight: 600;
        color: #495057;
    }
    
    .price-main {
        font-weight: 700;
        color: #e74c3c;
        font-size: 1.1rem;
    }
    
    .price-compare {
        text-decoration: line-through;
        color: #adb5bd;
        font-size: 0.9rem;
    }
    
    .stock-badge {
        padding: 5px 12px;
        border-radius: 20px;
        font-weight: 600;
        font-size: 0.85rem;
    }
    
    .stock-ok {
        background: #d4edda;
        color: #155724;
    }
    
    .stock-low {
        background: #fff3cd;
        color: #856404;
    }
    
    .stock-out {
        background: #f8d7da;
        color: #721c24;
    }
    
    /* Metadata */
    .metadata-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 20px;
    }
    
    .metadata-item {
        display: flex;
        align-items: center;
        gap: 12px;
    }
    
    .metadata-icon {
        width: 40px;
        height: 40px;
        background: #e9ecef;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #6c757d;
    }
    
    .metadata-content .label {
        font-size: 0.8rem;
        color: #6c757d;
        margin-bottom: 2px;
    }
    
    .metadata-content .value {
        font-weight: 600;
        color: #2d3436;
    }
    
    /* Action Buttons */
    .action-buttons {
        display: flex;
        gap: 10px;
        flex-wrap: wrap;
    }
    
    .action-buttons .btn {
        padding: 10px 20px;
        border-radius: 8px;
        font-weight: 500;
    }
    
    /* Responsive */
    @media (max-width: 991px) {
        .product-gallery {
            position: relative;
            margin-bottom: 30px;
        }
        
        .main-image {
            height: 300px;
        }
        
        .quick-stats {
            grid-template-columns: repeat(3, 1fr);
        }
        
        .metadata-grid {
            grid-template-columns: 1fr;
        }
    }
    
    @media (max-width: 576px) {
        .quick-stats {
            grid-template-columns: 1fr;
        }
        
        .thumbnail-item {
            width: 60px;
            height: 60px;
        }
    }
</style>

<!-- Content Header -->
<section class="content-header">
    <div class="container-fluid">
        <div class="row mb-2">
            <div class="col-sm-6">
                <h1><i class="fas fa-box-open mr-2"></i>Chi tiết sản phẩm</h1>
            </div>
            <div class="col-sm-6">
                <ol class="breadcrumb float-sm-right">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/products">Sản phẩm</a></li>
                    <li class="breadcrumb-item active">Chi tiết</li>
                </ol>
            </div>
        </div>
    </div>
</section>

<!-- Main content -->
<section class="content">
    <div class="container-fluid">
        
        <!-- Main Product Section -->
        <div class="card">
            <div class="card-body">
                <div class="row">
                    <!-- Left Column - Images -->
                    <div class="col-lg-5">
                        <div class="product-gallery">
                            <c:choose>
                                <c:when test="${empty images}">
                                    <div class="no-image-placeholder">
                                        <i class="fas fa-image"></i>
                                        <span>Chưa có hình ảnh</span>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <!-- Main Image -->
                                    <div class="main-image-container">
                                        <c:forEach var="img" items="${images}" varStatus="status">
                                            <c:if test="${img.imageType == 'main' || status.first}">
                                                <img id="mainProductImage" 
                                                     src="${pageContext.request.contextPath}${img.imageURL}" 
                                                     class="main-image" 
                                                     alt="${product.productName}"
                                                     data-toggle="modal"
                                                     data-target="#imageModal">
                                            </c:if>
                                        </c:forEach>
                                    </div>
                                    
                                    <!-- Thumbnails -->
                                    <div class="thumbnail-list">
                                        <c:forEach var="img" items="${images}" varStatus="status">
                                            <div class="thumbnail-item ${status.first ? 'active' : ''}" 
                                                 onclick="changeMainImage('${pageContext.request.contextPath}${img.imageURL}', this)">
                                                <img src="${pageContext.request.contextPath}${img.imageURL}" alt="Thumbnail">
                                            </div>
                                        </c:forEach>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    
                    <!-- Right Column - Product Info -->
                    <div class="col-lg-7">
                        <!-- Product Title & Badges -->
                        <h1 class="product-title">${product.productName}</h1>
                        
                        <div class="product-badges">
                            <span class="badge badge-info">
                                <i class="fas fa-folder mr-1"></i>${product.categoryName}
                            </span>
                            <c:if test="${not empty product.brandName}">
                                <span class="badge badge-secondary">
                                    <i class="fas fa-tag mr-1"></i>${product.brandName}
                                </span>
                            </c:if>
                            <c:choose>
                                <c:when test="${product.isActive}">
                                    <span class="badge badge-success">
                                        <i class="fas fa-check-circle mr-1"></i>Đang hoạt động
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-danger">
                                        <i class="fas fa-times-circle mr-1"></i>Ngừng hoạt động
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        
                        <!-- Quick Stats -->
                        <div class="quick-stats">
                            <div class="stat-card">
                                <span class="stat-value">${fn:length(variants)}</span>
                                <span class="stat-label">Biến thể</span>
                            </div>
                            <div class="stat-card success">
                                <span class="stat-value">
                                    <c:set var="totalStock" value="0" />
                                    <c:forEach var="v" items="${variants}">
                                        <c:set var="totalStock" value="${totalStock + v.stock}" />
                                    </c:forEach>
                                    ${totalStock}
                                </span>
                                <span class="stat-label">Tồn kho</span>
                            </div>
                            <div class="stat-card warning">
                                <span class="stat-value">${fn:length(images)}</span>
                                <span class="stat-label">Hình ảnh</span>
                            </div>
                        </div>
                        
                        <!-- Description -->
                        <c:if test="${not empty product.description}">
                            <div class="info-section">
                                <div class="info-section-title">
                                    <i class="fas fa-align-left"></i> Mô tả sản phẩm
                                </div>
                                <div class="info-section-content">
                                    ${fn:replace(product.description, newLineChar, '<br/>')}
                                </div>
                            </div>
                        </c:if>
                        
                        <!-- Specifications -->
                        <c:if test="${not empty product.specifications}">
                            <div class="info-section">
                                <div class="info-section-title">
                                    <i class="fas fa-list-ul"></i> Thông số kỹ thuật
                                </div>
                                <div class="info-section-content">
                                    ${fn:replace(product.specifications, newLineChar, '<br/>')}
                                </div>
                            </div>
                        </c:if>
                        
                        <!-- Action Buttons -->
                        <div class="action-buttons mt-4">
                            <a href="${pageContext.request.contextPath}/admin/products" class="btn btn-outline-secondary">
                                <i class="fas fa-arrow-left mr-1"></i> Quay lại
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/product-edit?id=${product.productID}" class="btn btn-primary">
                                <i class="fas fa-edit mr-1"></i> Chỉnh sửa
                            </a>
                            <button type="button" class="btn btn-outline-danger" onclick="confirmDelete(${product.productID})">
                                <i class="fas fa-trash mr-1"></i> Xóa
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Variants Section -->
        <div class="card variants-card">
            <div class="card-header">
                <h3 class="card-title">
                    <i class="fas fa-boxes mr-2"></i>Biến thể sản phẩm
                    <span class="badge badge-light ml-2">${fn:length(variants)}</span>
                </h3>
            </div>
            <div class="card-body p-0">
                <c:choose>
                    <c:when test="${empty variants}">
                        <div class="text-center py-5">
                            <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                            <p class="text-muted mb-0">Chưa có biến thể nào</p>
                            <a href="${pageContext.request.contextPath}/admin/product-edit?id=${product.productID}" 
                               class="btn btn-primary btn-sm mt-3">
                                <i class="fas fa-plus mr-1"></i> Thêm biến thể
                            </a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="table variant-table mb-0">
                                <thead>
                                    <tr>
                                        <th>SKU</th>
                                        <th class="text-right">Giá bán</th>
                                        <th class="text-right">Giá so sánh</th>
                                        <th class="text-center">Tồn kho</th>
                                        <th class="text-center">Khả dụng</th>
                                        <th class="text-right">Lợi nhuận</th>
                                        <th class="text-center">Trạng thái</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="variant" items="${variants}">
                                        <tr>
                                            <td>
                                                <span class="sku-badge">${variant.sku}</span>
                                            </td>
                                            <td class="text-right">
                                                <span class="price-main">
                                                    <fmt:formatNumber value="${variant.sellingPrice}" type="number" groupingUsed="true"/>đ
                                                </span>
                                            </td>
                                            <td class="text-right">
                                                <c:choose>
                                                    <c:when test="${not empty variant.compareAtPrice && variant.compareAtPrice > 0}">
                                                        <span class="price-compare">
                                                            <fmt:formatNumber value="${variant.compareAtPrice}" type="number" groupingUsed="true"/>đ
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">-</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center">
                                                <c:choose>
                                                    <c:when test="${variant.stock == 0}">
                                                        <span class="stock-badge stock-out">${variant.stock}</span>
                                                    </c:when>
                                                    <c:when test="${variant.stock <= 10}">
                                                        <span class="stock-badge stock-low">${variant.stock}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="stock-badge stock-ok">${variant.stock}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center">
                                                <strong>${variant.availableStock}</strong>
                                            </td>
                                            <td class="text-right">
                                                <c:choose>
                                                    <c:when test="${variant.profitMargin >= 0}">
                                                        <span class="text-success font-weight-bold">
                                                            +<fmt:formatNumber value="${variant.profitMargin}" type="number" maxFractionDigits="1"/>%
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-danger font-weight-bold">
                                                            <fmt:formatNumber value="${variant.profitMargin}" type="number" maxFractionDigits="1"/>%
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center">
                                                <c:choose>
                                                    <c:when test="${variant.isActive}">
                                                        <span class="badge badge-success">
                                                            <i class="fas fa-check"></i>
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-danger">
                                                            <i class="fas fa-times"></i>
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
        
        <!-- Metadata Section -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">
                    <i class="fas fa-info-circle mr-2"></i>Thông tin bổ sung
                </h3>
            </div>
            <div class="card-body">
                <div class="metadata-grid">
                    <div class="metadata-item">
                        <div class="metadata-icon">
                            <i class="fas fa-user"></i>
                        </div>
                        <div class="metadata-content">
                            <div class="label">Người tạo</div>
                            <div class="value">
                                <c:choose>
                                    <c:when test="${not empty product.createdByName}">
                                        ${product.createdByName}
                                    </c:when>
                                    <c:otherwise>
                                        <em class="text-muted">Không rõ</em>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                    
                    <div class="metadata-item">
                        <div class="metadata-icon">
                            <i class="fas fa-calendar-plus"></i>
                        </div>
                        <div class="metadata-content">
                            <div class="label">Ngày tạo</div>
                            <div class="value">
                                <fmt:formatDate value="${product.createdDate}" pattern="dd/MM/yyyy HH:mm" />
                            </div>
                        </div>
                    </div>
                    
                    <div class="metadata-item">
                        <div class="metadata-icon">
                            <i class="fas fa-calendar-check"></i>
                        </div>
                        <div class="metadata-content">
                            <div class="label">Cập nhật lần cuối</div>
                            <div class="value">
                                <c:choose>
                                    <c:when test="${not empty product.updatedDate}">
                                        <fmt:formatDate value="${product.updatedDate}" pattern="dd/MM/yyyy HH:mm" />
                                    </c:when>
                                    <c:otherwise>
                                        <em class="text-muted">Chưa cập nhật</em>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                    
                    <div class="metadata-item">
                        <div class="metadata-icon">
                            <i class="fas fa-hashtag"></i>
                        </div>
                        <div class="metadata-content">
                            <div class="label">Mã sản phẩm</div>
                            <div class="value">#${product.productID}</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
    </div>
</section>

<!-- Image Modal -->
<div class="modal fade" id="imageModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-xl modal-dialog-centered" role="document">
        <div class="modal-content" style="background: transparent; border: none;">
            <div class="modal-body text-center p-0">
                <button type="button" class="close text-white" data-dismiss="modal" 
                        style="position: absolute; right: -30px; top: -30px; font-size: 2rem; opacity: 1;">
                    <span>&times;</span>
                </button>
                <img id="modalImage" src="" style="max-width: 100%; max-height: 90vh; border-radius: 8px;">
            </div>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title"><i class="fas fa-exclamation-triangle mr-2"></i>Xác nhận xóa</h5>
                <button type="button" class="close text-white" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>Bạn có chắc chắn muốn xóa sản phẩm <strong>${product.productName}</strong>?</p>
                <p class="text-danger mb-0"><small>Hành động này không thể hoàn tác!</small></p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                <a id="deleteLink" href="#" class="btn btn-danger">
                    <i class="fas fa-trash mr-1"></i> Xóa
                </a>
            </div>
        </div>
    </div>
</div>

<script>
// Change main image when clicking thumbnail
function changeMainImage(imageUrl, element) {
    document.getElementById('mainProductImage').src = imageUrl;
    
    // Update active state
    document.querySelectorAll('.thumbnail-item').forEach(function(item) {
        item.classList.remove('active');
    });
    element.classList.add('active');
}

// Image modal
$('#imageModal').on('show.bs.modal', function (event) {
    var mainImage = document.getElementById('mainProductImage');
    if (mainImage) {
        $('#modalImage').attr('src', mainImage.src);
    }
});

// Delete confirmation
function confirmDelete(productId) {
    $('#deleteLink').attr('href', '${pageContext.request.contextPath}/admin/product-delete?id=' + productId);
    $('#deleteModal').modal('show');
}
</script>
