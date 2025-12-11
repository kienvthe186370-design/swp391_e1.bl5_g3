<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<style>
    .product-detail-img {
        width: 100%;
        max-width: 400px;
        height: auto;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    
    .thumbnail-img {
        width: 150px;
        height: 150px;
        object-fit: cover;
        border-radius: 4px;
        cursor: pointer;
        transition: transform 0.2s;
    }
    
    .thumbnail-img:hover {
        transform: scale(1.05);
    }
    
    .placeholder-img {
        width: 100%;
        max-width: 400px;
        height: 300px;
        background-color: #f4f6f9;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 8px;
        color: #adb5bd;
        font-size: 48px;
    }
    
    .info-label {
        font-weight: 600;
        color: #495057;
        margin-bottom: 5px;
    }
    
    .info-value {
        color: #6c757d;
        margin-bottom: 15px;
    }
    
    .variant-table {
        font-size: 14px;
    }
    
    .low-stock {
        color: #fd7e14;
        font-weight: 600;
    }
    
    .out-of-stock {
        color: #dc3545;
        font-weight: 600;
    }
    
    .profit-positive {
        color: #28a745;
        font-weight: 600;
    }
    
    .profit-negative {
        color: #dc3545;
        font-weight: 600;
    }
</style>

<!-- Content Header -->
<section class="content-header">
    <div class="container-fluid">
        <div class="row mb-2">
            <div class="col-sm-6">
                <h1>Chi tiết sản phẩm</h1>
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
        
        <!-- Action Buttons -->
        <div class="row mb-3">
            <div class="col-12">
                <a href="${pageContext.request.contextPath}/admin/products" class="btn btn-default">
                    <i class="fas fa-arrow-left"></i> Quay lại
                </a>
                <a href="${pageContext.request.contextPath}/admin/product-edit?id=${product.productID}" class="btn btn-primary">
                    <i class="fas fa-edit"></i> Chỉnh sửa
                </a>
            </div>
        </div>
        
        <!-- Basic Information Card -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">
                    <i class="fas fa-info-circle"></i> Thông tin cơ bản
                </h3>
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-12">
                        <h3>${product.productName}</h3>
                        <div class="mb-3">
                            <span class="badge badge-info badge-lg mr-2">
                                <i class="fas fa-folder"></i> ${product.categoryName}
                            </span>
                            <c:choose>
                                <c:when test="${not empty product.brandName}">
                                    <span class="badge badge-secondary badge-lg mr-2">
                                        <i class="fas fa-tag"></i> ${product.brandName}
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-secondary badge-lg mr-2">
                                        <i class="fas fa-tag"></i> Không có thương hiệu
                                    </span>
                                </c:otherwise>
                            </c:choose>
                            <c:choose>
                                <c:when test="${product.isActive}">
                                    <span class="badge badge-success badge-lg">
                                        <i class="fas fa-check-circle"></i> Hoạt động
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-danger badge-lg">
                                        <i class="fas fa-times-circle"></i> Ngừng hoạt động
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
                
                <div class="row mt-3">
                    <div class="col-md-6">
                        <div class="info-label">Mô tả:</div>
                        <div class="info-value">
                            <c:choose>
                                <c:when test="${not empty product.description}">
                                    ${fn:replace(product.description, newLineChar, '<br/>')}
                                </c:when>
                                <c:otherwise>
                                    <em class="text-muted">Chưa có mô tả</em>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="info-label">Thông số kỹ thuật:</div>
                        <div class="info-value">
                            <c:choose>
                                <c:when test="${not empty product.specifications}">
                                    ${fn:replace(product.specifications, newLineChar, '<br/>')}
                                </c:when>
                                <c:otherwise>
                                    <em class="text-muted">Chưa có thông số kỹ thuật</em>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Product Images Card -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">
                    <i class="fas fa-images"></i> Hình ảnh sản phẩm
                </h3>
            </div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${empty images}">
                        <div class="text-center">
                            <div class="placeholder-img mx-auto">
                                <i class="fas fa-image"></i>
                            </div>
                            <p class="text-muted mt-3">Chưa có hình ảnh</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="row">
                            <!-- Main Image -->
                            <c:forEach var="img" items="${images}">
                                <c:if test="${img.imageType == 'main'}">
                                    <div class="col-md-12 mb-4">
                                        <div class="text-center">
                                            <img src="${pageContext.request.contextPath}${img.imageURL}" 
                                                 class="product-detail-img" 
                                                 alt="Main Image">
                                            <p class="text-muted mt-2">Ảnh chính</p>
                                        </div>
                                    </div>
                                </c:if>
                            </c:forEach>
                            
                            <!-- Gallery Images (Thumbnails) -->
                            <c:set var="hasGallery" value="false" />
                            <c:forEach var="img" items="${images}">
                                <c:if test="${img.imageType == 'gallery'}">
                                    <c:set var="hasGallery" value="true" />
                                </c:if>
                            </c:forEach>
                            
                            <c:if test="${hasGallery}">
                                <div class="col-md-12">
                                    <h5 class="mb-3">Ảnh phụ:</h5>
                                    <div class="row">
                                        <c:forEach var="img" items="${images}">
                                            <c:if test="${img.imageType == 'gallery'}">
                                                <div class="col-md-3 col-sm-4 col-6 mb-3">
                                                    <img src="${pageContext.request.contextPath}${img.imageURL}" 
                                                         class="thumbnail-img" 
                                                         alt="Gallery Image"
                                                         data-toggle="modal"
                                                         data-target="#imageModal"
                                                         data-image="${pageContext.request.contextPath}${img.imageURL}">
                                                </div>
                                            </c:if>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:if>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
        
        <!-- Product Variants Card -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">
                    <i class="fas fa-boxes"></i> Biến thể sản phẩm
                    <span class="badge badge-info ml-2">${fn:length(variants)} biến thể</span>
                </h3>
            </div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${empty variants}">
                        <div class="text-center py-4">
                            <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                            <p class="text-muted">Chưa có biến thể nào</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover variant-table">
                                <thead>
                                    <tr>
                                        <th>SKU</th>
                                        <th class="text-right">Giá vốn</th>
                                        <th class="text-right">Giá bán</th>
                                        <th class="text-right">Giá so sánh</th>
                                        <th class="text-center">Tồn kho</th>
                                        <th class="text-center">Đã giữ</th>
                                        <th class="text-center">Khả dụng</th>
                                        <th class="text-right">Lợi nhuận</th>
                                        <th class="text-center">Trạng thái</th>
                                        <th class="text-center">Hành động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="variant" items="${variants}">
                                        <tr>
                                            <td><strong>${variant.sku}</strong></td>
                                            <td class="text-right">
                                                <fmt:formatNumber value="${variant.costPrice}" type="number" groupingUsed="true"/>đ
                                            </td>
                                            <td class="text-right">
                                                <fmt:formatNumber value="${variant.sellingPrice}" type="number" groupingUsed="true"/>đ
                                            </td>
                                            <td class="text-right">
                                                <c:choose>
                                                    <c:when test="${not empty variant.compareAtPrice}">
                                                        <fmt:formatNumber value="${variant.compareAtPrice}" type="number" groupingUsed="true"/>đ
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">-</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center">
                                                <c:choose>
                                                    <c:when test="${variant.stock == 0}">
                                                        <span class="out-of-stock">${variant.stock}</span>
                                                    </c:when>
                                                    <c:when test="${variant.stock <= 10}">
                                                        <span class="low-stock">${variant.stock}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        ${variant.stock}
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center">${variant.reservedStock}</td>
                                            <td class="text-center">
                                                <strong>${variant.availableStock}</strong>
                                            </td>
                                            <td class="text-right">
                                                <c:choose>
                                                    <c:when test="${variant.profitMargin >= 0}">
                                                        <span class="profit-positive">
                                                            <fmt:formatNumber value="${variant.profitMargin}" type="number" maxFractionDigits="1"/>%
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="profit-negative">
                                                            <fmt:formatNumber value="${variant.profitMargin}" type="number" maxFractionDigits="1"/>%
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center">
                                                <c:choose>
                                                    <c:when test="${variant.isActive}">
                                                        <span class="badge badge-success">Hoạt động</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-danger">Ngừng</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center">
                                                <a href="${pageContext.request.contextPath}/admin/stock/detail?id=${variant.variantID}" 
                                                   class="btn btn-success btn-sm" title="Nhập kho">
                                                    <i class="fas fa-plus-circle"></i> Nhập
                                                </a>
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
        
        <!-- Metadata Card -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">
                    <i class="fas fa-clock"></i> Thông tin khác
                </h3>
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-6">
                        <div class="info-label">Người tạo:</div>
                        <div class="info-value">
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
                    
                    <div class="col-md-6">
                        <div class="info-label">Ngày tạo:</div>
                        <div class="info-value">
                            <fmt:formatDate value="${product.createdDate}" pattern="dd/MM/yyyy HH:mm" />
                        </div>
                    </div>
                </div>
                
                <div class="row mt-2">
                    <div class="col-md-12">
                        <div class="info-label">Cập nhật lần cuối:</div>
                        <div class="info-value">
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
            </div>
        </div>
        
    </div>
</section>

<!-- Image Modal -->
<div class="modal fade" id="imageModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Xem ảnh</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body text-center">
                <img id="modalImage" src="" style="max-width: 100%; height: auto;">
            </div>
        </div>
    </div>
</div>

<script>
// Image modal
$('#imageModal').on('show.bs.modal', function (event) {
    var button = $(event.relatedTarget);
    var imageUrl = button.data('image');
    var modal = $(this);
    modal.find('#modalImage').attr('src', imageUrl);
});
</script>
