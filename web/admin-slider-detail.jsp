<%-- 
    Document   : admin-slider-detail
    Created on : Dec 6, 2025, 5:25:30 PM
    Author     : xuand
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${slider != null ? 'Chỉnh sửa' : 'Thêm mới'} Slider - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .form-section {
            background: white;
            border-radius: 8px;
            padding: 24px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .image-preview {
            max-width: 100%;
            max-height: 300px;
            border-radius: 8px;
            border: 2px dashed #dee2e6;
            padding: 10px;
            display: none;
        }
        .image-preview.show {
            display: block;
        }
        .preview-container {
            text-align: center;
            margin-top: 15px;
        }
        .required-field::after {
            content: " *";
            color: red;
        }
    </style>
</head>
<body class="bg-light">
<div class="container mt-4 mb-5">
    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="mb-0">
            <i class="fas fa-images"></i> 
            ${slider != null ? 'Chỉnh sửa Slider' : 'Thêm Slider Mới'}
        </h2>
        <a href="${pageContext.request.contextPath}/admin/slider" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Quay lại
        </a>
    </div>

    <!-- Form -->
    <div class="row">
        <div class="col-lg-8">
            <div class="form-section">
                <form method="post" action="${pageContext.request.contextPath}/admin/slider" id="sliderForm">
                    <input type="hidden" name="action" value="${slider != null ? 'update' : 'add'}">
                    <c:if test="${slider != null}">
                        <input type="hidden" name="id" value="${slider.sliderID}">
                    </c:if>

                    <!-- Title -->
                    <div class="mb-3">
                        <label for="title" class="form-label required-field">Tiêu đề Slider</label>
                        <input type="text" class="form-control" id="title" name="title" 
                               value="${slider != null ? slider.title : ''}" 
                               placeholder="Nhập tiêu đề slider..." required>
                        <div class="form-text">Tiêu đề mô tả cho slider (tối đa 200 ký tự)</div>
                    </div>

                    <!-- Image URL -->
                    <div class="mb-3">
                        <label for="imageURL" class="form-label required-field">URL Hình ảnh</label>
                        <input type="url" class="form-control" id="imageURL" name="imageURL" 
                               value="${slider != null ? slider.imageURL : ''}" 
                               placeholder="https://example.com/image.jpg" 
                               onchange="previewImage()" required>
                        <div class="form-text">Nhập URL đầy đủ của hình ảnh slider</div>
                        
                        <!-- Image Preview -->
                        <div class="preview-container">
                            <img id="imagePreview" class="image-preview ${slider != null && slider.imageURL != null ? 'show' : ''}" 
                                 src="${slider != null ? slider.imageURL : ''}" alt="Preview">
                        </div>
                    </div>

                    <!-- Link URL -->
                    <div class="mb-3">
                        <label for="linkURL" class="form-label">Link URL</label>
                        <input type="url" class="form-control" id="linkURL" name="linkURL" 
                               value="${slider != null ? slider.linkURL : ''}" 
                               placeholder="https://example.com/page">
                        <div class="form-text">URL trang đích khi click vào slider (có thể để trống)</div>
                    </div>

                    <!-- Display Order -->
                    <div class="mb-3">
                        <label for="displayOrder" class="form-label required-field">Thứ tự hiển thị</label>
                        <input type="number" class="form-control" id="displayOrder" name="displayOrder" 
                               value="${slider != null ? slider.displayOrder : 1}" 
                               min="1" max="100" required>
                        <div class="form-text">Số thứ tự hiển thị (1 = hiển thị đầu tiên)</div>
                    </div>

                    <!-- Status -->
                    <div class="mb-4">
                        <label for="status" class="form-label required-field">Trạng thái</label>
                        <select class="form-select" id="status" name="status" required>
                            <option value="active" ${slider == null || slider.status == 'active' ? 'selected' : ''}>
                                Active - Hiển thị
                            </option>
                            <option value="inactive" ${slider != null && slider.status == 'inactive' ? 'selected' : ''}>
                                Inactive - Ẩn
                            </option>
                        </select>
                        <div class="form-text">Chọn trạng thái hiển thị của slider</div>
                    </div>

                    <!-- Buttons -->
                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> ${slider != null ? 'Cập nhật' : 'Thêm mới'}
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/slider" class="btn btn-secondary">
                            <i class="fas fa-times"></i> Hủy
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <!-- Info Panel -->
        <div class="col-lg-4">
            <div class="form-section">
                <h5 class="mb-3"><i class="fas fa-info-circle text-info"></i> Hướng dẫn</h5>
                
                <div class="alert alert-info">
                    <h6><i class="fas fa-lightbulb"></i> Lưu ý:</h6>
                    <ul class="mb-0 ps-3">
                        <li>Hình ảnh nên có kích thước <strong>1920x600px</strong> để hiển thị tốt nhất</li>
                        <li>Định dạng khuyến nghị: <strong>JPG, PNG</strong></li>
                        <li>Dung lượng tối đa: <strong>2MB</strong></li>
                        <li>Thứ tự hiển thị: số nhỏ hơn sẽ hiển thị trước</li>
                    </ul>
                </div>

                <div class="alert alert-warning">
                    <h6><i class="fas fa-exclamation-triangle"></i> Khuyến nghị:</h6>
                    <ul class="mb-0 ps-3">
                        <li>Sử dụng hình ảnh chất lượng cao</li>
                        <li>Nội dung rõ ràng, dễ đọc</li>
                        <li>Tránh quá nhiều text trên ảnh</li>
                        <li>Test trên nhiều thiết bị</li>
                    </ul>
                </div>

                <c:if test="${slider != null}">
                    <div class="alert alert-secondary">
                        <h6><i class="fas fa-database"></i> Thông tin:</h6>
                        <p class="mb-1"><strong>ID:</strong> #${slider.sliderID}</p>
                        <p class="mb-0"><strong>Trạng thái:</strong> 
                            <span class="badge ${slider.status == 'active' ? 'bg-success' : 'bg-danger'}">
                                ${slider.status}
                            </span>
                        </p>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Preview image when URL is entered
    function previewImage() {
        const imageURL = document.getElementById('imageURL').value;
        const preview = document.getElementById('imagePreview');
        
        if (imageURL) {
            preview.src = imageURL;
            preview.classList.add('show');
            
            // Handle image load error
            preview.onerror = function() {
                preview.classList.remove('show');
                alert('Không thể tải hình ảnh. Vui lòng kiểm tra lại URL.');
            };
        } else {
            preview.classList.remove('show');
        }
    }

    // Form validation
    document.getElementById('sliderForm').addEventListener('submit', function(e) {
        const title = document.getElementById('title').value.trim();
        const imageURL = document.getElementById('imageURL').value.trim();
        const displayOrder = document.getElementById('displayOrder').value;
        
        if (!title) {
            e.preventDefault();
            alert('Vui lòng nhập tiêu đề slider!');
            document.getElementById('title').focus();
            return false;
        }
        
        if (!imageURL) {
            e.preventDefault();
            alert('Vui lòng nhập URL hình ảnh!');
            document.getElementById('imageURL').focus();
            return false;
        }
        
        if (displayOrder < 1 || displayOrder > 100) {
            e.preventDefault();
            alert('Thứ tự hiển thị phải từ 1 đến 100!');
            document.getElementById('displayOrder').focus();
            return false;
        }
        
        return true;
    });

    // Load preview on page load if editing
    window.addEventListener('load', function() {
        const imageURL = document.getElementById('imageURL').value;
        if (imageURL) {
            previewImage();
        }
    });
</script>
</body>
</html>

