<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<style>
    .required-field::after {
        content: " *";
        color: #dc3545;
        font-weight: bold;
    }
    
    .form-error {
        color: #dc3545;
        font-size: 0.875rem;
        margin-top: 0.25rem;
    }
    
    .is-invalid {
        border-color: #dc3545;
    }
    
    .custom-file-label::after {
        content: "Chọn file";
    }
    
    .image-upload-hint {
        font-size: 0.875rem;
        color: #6c757d;
        margin-top: 0.25rem;
    }
    
    .existing-image {
        position: relative;
        display: inline-block;
        margin-right: 10px;
        margin-bottom: 10px;
    }
    
    .existing-image img {
        width: 150px;
        height: 150px;
        object-fit: cover;
        border-radius: 4px;
        border: 2px solid #ddd;
    }
    
    .existing-image .remove-existing-img {
        position: absolute;
        top: 5px;
        right: 5px;
        background: #dc3545;
        color: white;
        border: none;
        border-radius: 50%;
        width: 25px;
        height: 25px;
        cursor: pointer;
    }
</style>

<!-- Content Header -->
<section class="content-header">
    <div class="container-fluid">
        <div class="row mb-2">
            <div class="col-sm-6">
                <h1>Chỉnh sửa sản phẩm</h1>
            </div>
            <div class="col-sm-6">
                <ol class="breadcrumb float-sm-right">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/products">Sản phẩm</a></li>
                    <li class="breadcrumb-item active">Chỉnh sửa</li>
                </ol>
            </div>
        </div>
    </div>
</section>

<!-- Main content -->
<section class="content">
    <div class="container-fluid">
        
        <!-- Error Messages -->
        <c:if test="${not empty errors.general}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-triangle"></i> ${errors.general}
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
        </c:if>
        
        <!-- Success Message -->
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle"></i> ${successMessage}
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/admin/product-edit" 
              enctype="multipart/form-data" id="productEditForm">
            
            <!-- Hidden Product ID -->
            <input type="hidden" name="productId" value="${product.productID}">
            
            <div class="row">
                <!-- Left Column - Basic Information -->
                <div class="col-md-8">
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">
                                <i class="fas fa-info-circle"></i> Thông tin cơ bản
                            </h3>
                        </div>
                        <div class="card-body">
                            
                            <!-- Product Name -->
                            <div class="form-group">
                                <label for="productName" class="required-field">Tên sản phẩm</label>
                                <input type="text" 
                                       class="form-control ${not empty errors.productName ? 'is-invalid' : ''}" 
                                       id="productName" 
                                       name="productName" 
                                       placeholder="Nhập tên sản phẩm"
                                       value="${product.productName}"
                                       aria-required="true"
                                       aria-describedby="${not empty errors.productName ? 'productNameError' : ''}">
                                <c:if test="${not empty errors.productName}">
                                    <div class="form-error" id="productNameError" role="alert">
                                        ${errors.productName}
                                    </div>
                                </c:if>
                            </div>
                            
                            <!-- Description -->
                            <div class="form-group">
                                <label for="description">Mô tả sản phẩm</label>
                                <textarea class="form-control" 
                                          id="description" 
                                          name="description" 
                                          rows="4"
                                          placeholder="Nhập mô tả chi tiết về sản phẩm">${product.description}</textarea>
                            </div>
                            
                            <!-- Specifications -->
                            <div class="form-group">
                                <label for="specifications">Thông số kỹ thuật</label>
                                <textarea class="form-control" 
                                          id="specifications" 
                                          name="specifications" 
                                          rows="4"
                                          placeholder="Nhập thông số kỹ thuật của sản phẩm">${product.specifications}</textarea>
                            </div>
                            
                        </div>
                    </div>
                    
                    <!-- Images Section -->
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">
                                <i class="fas fa-images"></i> Hình ảnh sản phẩm
                            </h3>
                        </div>
                        <div class="card-body">
                            
                            <!-- Existing Images -->
                            <c:if test="${not empty images}">
                                <div class="form-group">
                                    <label>Ảnh hiện tại:</label>
                                    <div id="existingImages">
                                        <c:forEach var="img" items="${images}">
                                            <div class="existing-image" data-image-id="${img.imageID}">
                                                <img src="${pageContext.request.contextPath}${img.imageURL}" alt="Product Image">
                                                <button type="button" class="remove-existing-img" 
                                                        onclick="removeExistingImage(${img.imageID})">
                                                    <i class="fas fa-times"></i>
                                                </button>
                                                <input type="hidden" name="keepImageIds" value="${img.imageID}">
                                                <c:if test="${img.imageType == 'main'}">
                                                    <div class="badge badge-primary">Ảnh chính</div>
                                                </c:if>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:if>
                            
                            <!-- Main Image -->
                            <div class="form-group">
                                <label for="mainImage">Ảnh chính mới (nếu muốn thay đổi)</label>
                                <div class="custom-file">
                                    <input type="file" 
                                           class="custom-file-input ${not empty errors.mainImage ? 'is-invalid' : ''}" 
                                           id="mainImage" 
                                           name="mainImage"
                                           accept=".jpg,.jpeg,.png,.gif"
                                           aria-describedby="${not empty errors.mainImage ? 'mainImageError' : ''}">
                                    <label class="custom-file-label" for="mainImage">Chọn ảnh chính mới</label>
                                </div>
                                <div class="image-upload-hint">
                                    Chấp nhận: JPG, PNG, GIF. Kích thước tối đa: 2MB
                                </div>
                                <!-- Preview Main Image -->
                                <div id="mainImagePreview" class="mt-3" style="display: none;">
                                    <img id="mainImagePreviewImg" src="" alt="Preview" 
                                         style="max-width: 100%; max-height: 300px; border: 1px solid #ddd; border-radius: 4px; padding: 5px;">
                                    <button type="button" class="btn btn-sm btn-danger mt-2" id="removeMainImage">
                                        <i class="fas fa-times"></i> Xóa ảnh
                                    </button>
                                </div>
                                <c:if test="${not empty errors.mainImage}">
                                    <div class="form-error" id="mainImageError" role="alert">
                                        ${errors.mainImage}
                                    </div>
                                </c:if>
                            </div>
                            
                            <!-- Thumbnail Images -->
                            <div class="form-group">
                                <label for="thumbnailImages">Ảnh phụ mới (Thumbnails)</label>
                                <div class="custom-file">
                                    <input type="file" 
                                           class="custom-file-input ${not empty errors.thumbnailImages ? 'is-invalid' : ''}" 
                                           id="thumbnailImages" 
                                           name="thumbnailImages"
                                           accept=".jpg,.jpeg,.png,.gif"
                                           multiple
                                           aria-describedby="${not empty errors.thumbnailImages ? 'thumbnailImagesError' : ''}">
                                    <label class="custom-file-label" for="thumbnailImages">Chọn ảnh phụ mới</label>
                                </div>
                                <div class="image-upload-hint">
                                    Chấp nhận: JPG, PNG, GIF. Tối đa 4 ảnh. Tổng kích thước tối đa: 2MB
                                </div>
                                <!-- Preview Thumbnails -->
                                <div id="thumbnailsPreview" class="mt-3 row" style="display: none;"></div>
                                <c:if test="${not empty errors.thumbnailImages}">
                                    <div class="form-error" id="thumbnailImagesError" role="alert">
                                        ${errors.thumbnailImages}
                                    </div>
                                </c:if>
                            </div>
                            
                        </div>
                    </div>
                </div>
                
                <!-- Right Column - Category & Brand -->
                <div class="col-md-4">
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">
                                <i class="fas fa-tags"></i> Phân loại
                            </h3>
                        </div>
                        <div class="card-body">
                            
                            <!-- Category -->
                            <div class="form-group">
                                <label for="categoryId" class="required-field">Danh mục</label>
                                <select class="form-control ${not empty errors.categoryId ? 'is-invalid' : ''}" 
                                        id="categoryId" 
                                        name="categoryId"
                                        aria-required="true"
                                        aria-describedby="${not empty errors.categoryId ? 'categoryIdError' : ''}">
                                    <option value="0">-- Chọn danh mục --</option>
                                    <c:forEach var="cat" items="${categories}">
                                        <option value="${cat.categoryID}" 
                                                ${product.categoryID == cat.categoryID ? 'selected' : ''}>
                                            ${cat.categoryName}
                                        </option>
                                    </c:forEach>
                                </select>
                                <c:if test="${not empty errors.categoryId}">
                                    <div class="form-error" id="categoryIdError" role="alert">
                                        ${errors.categoryId}
                                    </div>
                                </c:if>
                            </div>
                            
                            <!-- Brand -->
                            <div class="form-group">
                                <label for="brandId">Thương hiệu</label>
                                <select class="form-control" 
                                        id="brandId" 
                                        name="brandId">
                                    <option value="0">-- Chọn thương hiệu --</option>
                                    <c:forEach var="brand" items="${brands}">
                                        <option value="${brand.brandID}" 
                                                ${product.brandID == brand.brandID ? 'selected' : ''}>
                                            ${brand.brandName}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                            
                            <!-- Active Status -->
                            <div class="form-group">
                                <div class="custom-control custom-switch">
                                    <input type="checkbox" 
                                           class="custom-control-input" 
                                           id="isActive" 
                                           name="isActive" 
                                           value="true"
                                           ${product.isActive ? 'checked' : ''}>
                                    <label class="custom-control-label" for="isActive">
                                        Sản phẩm hoạt động
                                    </label>
                                </div>
                            </div>
                            
                        </div>
                    </div>
                    
                    <!-- Action Buttons -->
                    <div class="card">
                        <div class="card-body">
                            <button type="submit" class="btn btn-primary btn-block">
                                <i class="fas fa-save"></i> Cập nhật sản phẩm
                            </button>
                            <a href="${pageContext.request.contextPath}/admin/product-details?id=${product.productID}" 
                               class="btn btn-secondary btn-block">
                                <i class="fas fa-times"></i> Hủy
                            </a>
                        </div>
                    </div>
                    
                    <!-- Help Card -->
                    <div class="card card-info">
                        <div class="card-header">
                            <h3 class="card-title">
                                <i class="fas fa-question-circle"></i> Hướng dẫn
                            </h3>
                        </div>
                        <div class="card-body">
                            <p class="mb-2"><small>
                                <strong>Trường bắt buộc:</strong> Các trường có dấu 
                                <span class="text-danger">*</span> là bắt buộc phải nhập.
                            </small></p>
                            <p class="mb-2"><small>
                                <strong>Hình ảnh:</strong> Bạn có thể giữ ảnh cũ hoặc upload ảnh mới. 
                                Click nút X để xóa ảnh cũ.
                            </small></p>
                            <p class="mb-0"><small>
                                <strong>Trạng thái:</strong> Tắt "Sản phẩm hoạt động" để ẩn sản phẩm 
                                khỏi trang web.
                            </small></p>
                        </div>
                    </div>
                </div>
            </div>
            
        </form>
        
    </div>
</section>

<script>
// Remove existing image
function removeExistingImage(imageId) {
    if (confirm('Bạn có chắc muốn xóa ảnh này?')) {
        var imageDiv = document.querySelector('.existing-image[data-image-id="' + imageId + '"]');
        if (imageDiv) {
            // Remove the hidden input so this image won't be kept
            var hiddenInput = imageDiv.querySelector('input[name="keepImageIds"]');
            if (hiddenInput) {
                hiddenInput.remove();
            }
            // Hide the image div
            imageDiv.style.display = 'none';
            
            // Add to delete list
            var form = document.getElementById('productEditForm');
            var deleteInput = document.createElement('input');
            deleteInput.type = 'hidden';
            deleteInput.name = 'deleteImageIds';
            deleteInput.value = imageId;
            form.appendChild(deleteInput);
        }
    }
}

// Same JavaScript as product-add for file previews
document.addEventListener('DOMContentLoaded', function() {
    console.log('Product Edit Form Script Loaded');
    
    // Handle main image file input with preview
    var mainImageInput = document.getElementById('mainImage');
    if (mainImageInput) {
        mainImageInput.addEventListener('change', function() {
            console.log('Main image changed');
            var fileName = this.value.split('\\').pop();
            var label = this.nextElementSibling;
            if (label) {
                label.textContent = fileName || 'Chọn ảnh chính mới';
            }
            
            // Show preview
            var file = this.files[0];
            if (file) {
                console.log('File selected:', file.name, file.size);
                var reader = new FileReader();
                reader.onload = function(e) {
                    var previewImg = document.getElementById('mainImagePreviewImg');
                    var previewDiv = document.getElementById('mainImagePreview');
                    if (previewImg && previewDiv) {
                        previewImg.src = e.target.result;
                        previewDiv.style.display = 'block';
                    }
                };
                reader.readAsDataURL(file);
            }
        });
    }
    
    // Remove main image
    var removeMainBtn = document.getElementById('removeMainImage');
    if (removeMainBtn) {
        removeMainBtn.addEventListener('click', function() {
            var mainImageInput = document.getElementById('mainImage');
            var label = mainImageInput.nextElementSibling;
            var previewDiv = document.getElementById('mainImagePreview');
            
            mainImageInput.value = '';
            if (label) label.textContent = 'Chọn ảnh chính mới';
            if (previewDiv) previewDiv.style.display = 'none';
        });
    }
    
    // Handle thumbnail images file input with preview
    var thumbnailInput = document.getElementById('thumbnailImages');
    var thumbnailFiles = []; // Store files array
    
    if (thumbnailInput) {
        thumbnailInput.addEventListener('change', function() {
            console.log('Thumbnails changed');
            
            // Store files in our array
            thumbnailFiles = Array.from(this.files);
            
            // Check max 4 images limit
            if (thumbnailFiles.length > 4) {
                alert('Bạn chỉ có thể chọn tối đa 4 ảnh phụ!');
                thumbnailFiles = thumbnailFiles.slice(0, 4);
                
                // Update file input with only first 4 files
                var dt = new DataTransfer();
                thumbnailFiles.forEach(function(f) {
                    dt.items.add(f);
                });
                this.files = dt.files;
            }
            
            var fileCount = thumbnailFiles.length;
            var label = this.nextElementSibling;
            if (label) {
                label.textContent = fileCount > 0 ? fileCount + ' file đã chọn' : 'Chọn ảnh phụ mới';
            }
            
            // Show previews
            var previewContainer = document.getElementById('thumbnailsPreview');
            if (previewContainer) {
                previewContainer.innerHTML = '';
                
                if (thumbnailFiles.length > 0) {
                    previewContainer.style.display = 'flex';
                    
                    thumbnailFiles.forEach(function(file, index) {
                        var reader = new FileReader();
                        reader.onload = function(e) {
                            var col = document.createElement('div');
                            col.className = 'col-md-3 col-sm-4 col-6 mb-3';
                            col.setAttribute('data-file-index', index);
                            
                            var imgContainer = document.createElement('div');
                            imgContainer.style.position = 'relative';
                            
                            var img = document.createElement('img');
                            img.src = e.target.result;
                            img.className = 'img-thumbnail';
                            img.style.width = '100%';
                            img.style.height = '150px';
                            img.style.objectFit = 'cover';
                            
                            var removeBtn = document.createElement('button');
                            removeBtn.type = 'button';
                            removeBtn.className = 'btn btn-sm btn-danger';
                            removeBtn.style.position = 'absolute';
                            removeBtn.style.top = '5px';
                            removeBtn.style.right = '5px';
                            removeBtn.setAttribute('data-index', index);
                            removeBtn.innerHTML = '<i class="fas fa-times"></i>';
                            
                            removeBtn.addEventListener('click', function() {
                                var fileIndex = parseInt(this.getAttribute('data-index'));
                                
                                // Remove from files array
                                thumbnailFiles.splice(fileIndex, 1);
                                
                                // Update file input with remaining files
                                var dt = new DataTransfer();
                                thumbnailFiles.forEach(function(f) {
                                    dt.items.add(f);
                                });
                                thumbnailInput.files = dt.files;
                                
                                // Update label
                                if (label) {
                                    label.textContent = thumbnailFiles.length > 0 ? thumbnailFiles.length + ' file đã chọn' : 'Chọn ảnh phụ mới';
                                }
                                
                                // Remove preview
                                col.remove();
                                
                                // Re-render all previews with updated indices
                                renderThumbnailPreviews();
                                
                                if (thumbnailFiles.length === 0) {
                                    previewContainer.style.display = 'none';
                                }
                            });
                            
                            imgContainer.appendChild(img);
                            imgContainer.appendChild(removeBtn);
                            col.appendChild(imgContainer);
                            previewContainer.appendChild(col);
                        };
                        reader.readAsDataURL(file);
                    });
                } else {
                    previewContainer.style.display = 'none';
                }
            }
        });
    }
    
    // Function to re-render thumbnail previews with correct indices
    function renderThumbnailPreviews() {
        var previewContainer = document.getElementById('thumbnailsPreview');
        var label = thumbnailInput.nextElementSibling;
        
        if (!previewContainer) return;
        
        previewContainer.innerHTML = '';
        
        if (thumbnailFiles.length > 0) {
            previewContainer.style.display = 'flex';
            
            thumbnailFiles.forEach(function(file, index) {
                var reader = new FileReader();
                reader.onload = function(e) {
                    var col = document.createElement('div');
                    col.className = 'col-md-3 col-sm-4 col-6 mb-3';
                    col.setAttribute('data-file-index', index);
                    
                    var imgContainer = document.createElement('div');
                    imgContainer.style.position = 'relative';
                    
                    var img = document.createElement('img');
                    img.src = e.target.result;
                    img.className = 'img-thumbnail';
                    img.style.width = '100%';
                    img.style.height = '150px';
                    img.style.objectFit = 'cover';
                    
                    var removeBtn = document.createElement('button');
                    removeBtn.type = 'button';
                    removeBtn.className = 'btn btn-sm btn-danger';
                    removeBtn.style.position = 'absolute';
                    removeBtn.style.top = '5px';
                    removeBtn.style.right = '5px';
                    removeBtn.setAttribute('data-index', index);
                    removeBtn.innerHTML = '<i class="fas fa-times"></i>';
                    
                    removeBtn.addEventListener('click', function() {
                        var fileIndex = parseInt(this.getAttribute('data-index'));
                        
                        // Remove from files array
                        thumbnailFiles.splice(fileIndex, 1);
                        
                        // Update file input with remaining files
                        var dt = new DataTransfer();
                        thumbnailFiles.forEach(function(f) {
                            dt.items.add(f);
                        });
                        thumbnailInput.files = dt.files;
                        
                        // Update label
                        if (label) {
                            label.textContent = thumbnailFiles.length > 0 ? thumbnailFiles.length + ' file đã chọn' : 'Chọn ảnh phụ mới';
                        }
                        
                        // Re-render all previews
                        renderThumbnailPreviews();
                        
                        if (thumbnailFiles.length === 0) {
                            previewContainer.style.display = 'none';
                        }
                    });
                    
                    imgContainer.appendChild(img);
                    imgContainer.appendChild(removeBtn);
                    col.appendChild(imgContainer);
                    previewContainer.appendChild(col);
                };
                reader.readAsDataURL(file);
            });
        } else {
            previewContainer.style.display = 'none';
        }
    }
    
    // Auto dismiss alerts after 5 seconds
    setTimeout(function() {
        var alerts = document.querySelectorAll('.alert');
        alerts.forEach(function(alert) {
            alert.style.transition = 'opacity 0.5s';
            alert.style.opacity = '0';
            setTimeout(function() {
                alert.style.display = 'none';
            }, 500);
        });
    }, 5000);
    
    // Form validation before submit
    var form = document.getElementById('productEditForm');
    if (form) {
        form.addEventListener('submit', function(e) {
            var isValid = true;
            var errorMessage = '';
            
            // Check product name
            var productName = document.getElementById('productName').value.trim();
            if (productName === '') {
                isValid = false;
                errorMessage += '- Tên sản phẩm không được để trống\n';
            }
            
            // Check category
            var categoryId = document.getElementById('categoryId').value;
            if (categoryId === '0' || categoryId === '') {
                isValid = false;
                errorMessage += '- Vui lòng chọn danh mục\n';
            }
            
            // Check thumbnails count
            var thumbnailFiles = document.getElementById('thumbnailImages').files;
            if (thumbnailFiles.length > 4) {
                isValid = false;
                errorMessage += '- Chỉ được chọn tối đa 4 ảnh phụ\n';
            }
            
            if (!isValid) {
                e.preventDefault();
                alert('Vui lòng kiểm tra lại:\n\n' + errorMessage);
                return false;
            }
            
            // Show loading
            var submitBtn = this.querySelector('button[type="submit"]');
            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Đang cập nhật...';
            }
        });
    }
    
    console.log('All event listeners attached');
});
</script>

