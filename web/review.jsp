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
    <title>Đánh giá sản phẩm - Pickleball Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" type="text/css">
    <style>
        :root {
            --primary: #2D5A27;
            --primary-hover: #1E3D1A;
            --accent: #E85A4F;
            --star-color: #FBBF24;
            --star-empty: #D1D5DB;
        }
        .review-card { background: #fff; border-radius: 16px; box-shadow: 0 4px 12px rgba(0,0,0,0.08); overflow: hidden; max-width: 800px; margin: 0 auto; }
        .review-header { background: linear-gradient(135deg, var(--primary) 0%, #3D7A37 100%); color: white; padding: 28px 32px; }
        .review-header h1 { font-size: 24px; font-weight: 800; margin-bottom: 8px; }
        .review-header p { opacity: 0.9; font-size: 15px; margin: 0; }
        .product-info { display: flex; gap: 20px; padding: 24px 32px; border-bottom: 1px solid #E5E7EB; background: #F9FAFB; }
        .product-image { width: 100px; height: 100px; border-radius: 10px; background: #fff; border: 1px solid #E5E7EB; display: flex; align-items: center; justify-content: center; flex-shrink: 0; overflow: hidden; }
        .product-image img { max-width: 80%; max-height: 80%; object-fit: contain; }
        .product-details { flex: 1; }
        .product-brand { font-size: 12px; text-transform: uppercase; color: var(--primary); font-weight: 700; letter-spacing: 0.5px; margin-bottom: 4px; }
        .product-name { font-size: 18px; font-weight: 700; color: #1A1A1A; margin-bottom: 8px; line-height: 1.3; }
        .product-variant { font-size: 14px; color: #6B7280; }
        .product-variant span { background: #fff; padding: 4px 10px; border-radius: 4px; border: 1px solid #E5E7EB; margin-right: 8px; }
        .review-form { padding: 32px; }
        .form-section { margin-bottom: 32px; }
        .form-label { display: block; font-size: 15px; font-weight: 700; color: #1A1A1A; margin-bottom: 12px; }
        .form-label .required { color: var(--accent); margin-left: 4px; }
        .form-label .optional { color: #6B7280; font-weight: 400; font-size: 13px; margin-left: 8px; }
        .rating-container { display: flex; align-items: center; gap: 24px; }
        .star-rating { display: flex; flex-direction: row-reverse; justify-content: flex-end; gap: 8px; }
        .star-rating input { display: none; }
        .star-rating label { font-size: 36px; color: var(--star-empty); cursor: pointer; transition: all 0.15s ease; }
        .star-rating label:hover, .star-rating label:hover ~ label, .star-rating input:checked + label, .star-rating input:checked + label ~ label { color: var(--star-color); }
        .rating-text { font-size: 15px; color: #6B7280; font-weight: 600; min-width: 120px; }
        .rating-text.active { color: var(--primary); }
        .form-input { width: 100%; padding: 14px 16px; border: 2px solid #E5E7EB; border-radius: 6px; font-size: 15px; font-family: inherit; transition: border-color 0.2s, box-shadow 0.2s; background: #fff; }
        .form-input:focus { outline: none; border-color: var(--primary); box-shadow: 0 0 0 3px rgba(45, 90, 39, 0.1); }
        textarea.form-input { min-height: 140px; resize: vertical; }
        .char-count { text-align: right; font-size: 13px; color: #6B7280; margin-top: 8px; }
        .upload-container { display: flex; gap: 16px; flex-wrap: wrap; }
        .upload-box { width: 120px; height: 120px; border: 2px dashed #E5E7EB; border-radius: 10px; display: flex; flex-direction: column; align-items: center; justify-content: center; cursor: pointer; transition: all 0.2s; background: #F9FAFB; }
        .upload-box:hover { border-color: var(--primary); background: rgba(45, 90, 39, 0.03); }
        .upload-box i { font-size: 28px; color: #6B7280; margin-bottom: 8px; }
        .upload-box span { font-size: 12px; color: #6B7280; text-align: center; line-height: 1.3; }
        .upload-box:hover i, .upload-box:hover span { color: var(--primary); }
        .preview-item { width: 120px; height: 120px; border-radius: 10px; position: relative; overflow: hidden; border: 2px solid #E5E7EB; display: none; }
        .preview-item img { width: 100%; height: 100%; object-fit: cover; }
        .preview-item .remove-btn { position: absolute; top: 6px; right: 6px; width: 24px; height: 24px; background: rgba(0, 0, 0, 0.6); color: white; border: none; border-radius: 50%; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 12px; }
        .preview-item .remove-btn:hover { background: var(--accent); }
        .upload-hint { width: 100%; margin-top: 12px; font-size: 13px; color: #6B7280; }
        .submit-section { display: flex; gap: 16px; padding-top: 24px; border-top: 1px solid #E5E7EB; margin-top: 32px; }
        .btn-review { padding: 14px 32px; border-radius: 6px; font-size: 15px; font-weight: 700; cursor: pointer; transition: all 0.2s; display: inline-flex; align-items: center; justify-content: center; gap: 8px; text-decoration: none; }
        .btn-primary-review { background: var(--primary); color: white; border: none; flex: 1; max-width: 250px; }
        .btn-primary-review:hover { background: var(--primary-hover); transform: translateY(-1px); color: white; }
        .btn-secondary-review { background: #fff; color: #6B7280; border: 2px solid #E5E7EB; }
        .btn-secondary-review:hover { border-color: #6B7280; color: #1A1A1A; text-decoration: none; }
        .guidelines { background: #FEF0EF; border-radius: 10px; padding: 20px 24px; margin-top: 24px; }
        .guidelines h3 { font-size: 14px; font-weight: 700; color: var(--accent); margin-bottom: 12px; }
        .guidelines ul { list-style: none; font-size: 13px; color: #1A1A1A; padding: 0; margin: 0; }
        .guidelines li { padding: 4px 0; padding-left: 20px; position: relative; }
        .guidelines li::before { content: "✓"; position: absolute; left: 0; color: var(--primary); font-weight: 700; }
        @media (max-width: 640px) {
            .review-header, .review-form, .product-info { padding: 20px; }
            .product-info { flex-direction: column; align-items: center; text-align: center; }
            .star-rating label { font-size: 32px; }
            .rating-container { flex-direction: column; align-items: flex-start; gap: 12px; }
            .upload-box, .preview-item { width: 100px; height: 100px; }
            .submit-section { flex-direction: column; }
            .btn-primary-review { max-width: 100%; }
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
                        <h4>Đánh giá sản phẩm</h4>
                        <div class="breadcrumb__links">
                            <a href="${pageContext.request.contextPath}/Home">Trang chủ</a>
                            <a href="${pageContext.request.contextPath}/customer/orders">Đơn hàng của tôi</a>
                            <span>Đánh giá sản phẩm</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="spad">
        <div class="container">
            <c:if test="${not empty sessionScope.error}">
                <div class="alert alert-danger alert-dismissible fade show" style="max-width: 800px; margin: 0 auto 20px;">
                    ${sessionScope.error}
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                </div>
                <c:remove var="error" scope="session"/>
            </c:if>

            <div class="review-card">
                <div class="review-header">
                    <h1><i class="fa fa-star" style="margin-right: 10px;"></i>Đánh giá sản phẩm</h1>
                    <p>Chia sẻ trải nghiệm của bạn để giúp người mua khác đưa ra quyết định tốt hơn</p>
                </div>

                <div class="product-info">
                    <div class="product-image">
                        <c:choose>
                            <c:when test="${not empty orderDetail.productImage}">
                                <img src="${pageContext.request.contextPath}${orderDetail.productImage}" alt="${orderDetail.productName}">
                            </c:when>
                            <c:otherwise>
                                <img src="${pageContext.request.contextPath}/img/product/product-placeholder.jpg" alt="Product">
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="product-details">
                        <c:if test="${not empty orderDetail.brandName}">
                            <div class="product-brand">${orderDetail.brandName}</div>
                        </c:if>
                        <h2 class="product-name">${orderDetail.productName}</h2>
                        <div class="product-variant">
                            <span>SKU: ${orderDetail.sku}</span>
                        </div>
                    </div>
                </div>

                <form class="review-form" method="post" action="${pageContext.request.contextPath}/review" enctype="multipart/form-data">
                    <input type="hidden" name="orderDetailId" value="${orderDetail.orderDetailId}">
                    <input type="hidden" name="productId" value="${orderDetail.productId}">

                    <!-- Rating -->
                    <div class="form-section">
                        <label class="form-label">
                            Đánh giá của bạn
                            <span class="required">*</span>
                        </label>
                        <div class="rating-container">
                            <div class="star-rating">
                                <input type="radio" name="rating" value="5" id="star5" required>
                                <label for="star5" title="Tuyệt vời"><i class="fa fa-star"></i></label>
                                <input type="radio" name="rating" value="4" id="star4">
                                <label for="star4" title="Tốt"><i class="fa fa-star"></i></label>
                                <input type="radio" name="rating" value="3" id="star3">
                                <label for="star3" title="Bình thường"><i class="fa fa-star"></i></label>
                                <input type="radio" name="rating" value="2" id="star2">
                                <label for="star2" title="Không hài lòng"><i class="fa fa-star"></i></label>
                                <input type="radio" name="rating" value="1" id="star1">
                                <label for="star1" title="Rất tệ"><i class="fa fa-star"></i></label>
                            </div>
                            <span class="rating-text" id="ratingText">Chọn số sao</span>
                        </div>
                    </div>

                    <!-- Title -->
                    <div class="form-section">
                        <label class="form-label">
                            Tiêu đề đánh giá
                            <span class="optional">(Không bắt buộc)</span>
                        </label>
                        <input type="text" name="reviewTitle" class="form-input" placeholder="Ví dụ: Sản phẩm chất lượng, đóng gói cẩn thận" maxlength="100" id="titleInput">
                        <div class="char-count"><span id="titleCount">0</span>/100 ký tự</div>
                    </div>

                    <!-- Content -->
                    <div class="form-section">
                        <label class="form-label">
                            Nội dung đánh giá
                            <span class="optional">(Không bắt buộc)</span>
                        </label>
                        <textarea name="reviewContent" class="form-input" placeholder="Chia sẻ chi tiết trải nghiệm của bạn về sản phẩm: chất lượng, độ bền, cảm giác khi sử dụng..." maxlength="1000" id="contentInput"></textarea>
                        <div class="char-count"><span id="contentCount">0</span>/1000 ký tự</div>
                    </div>

                    <!-- Images Upload -->
                    <div class="form-section">
                        <label class="form-label">
                            Hình ảnh sản phẩm
                            <span class="optional">(Tối đa 5 ảnh, mỗi ảnh không quá 2MB)</span>
                        </label>
                        <div class="upload-container" id="uploadContainer">
                            <div class="upload-box" id="uploadBox" onclick="document.getElementById('imageInput').click()">
                                <i class="fa fa-camera"></i>
                                <span>Thêm ảnh</span>
                            </div>
                        </div>
                        <input type="file" id="imageInput" name="reviewImages" multiple accept="image/jpeg,image/png,image/gif" style="display: none;">
                        <div class="upload-hint">
                            <i class="fa fa-info-circle"></i> Chấp nhận định dạng: JPG, PNG, GIF. Tối đa 5 ảnh.
                        </div>
                    </div>

                    <!-- Guidelines -->
                    <div class="guidelines">
                        <h3><i class="fa fa-lightbulb-o"></i> Hướng dẫn viết đánh giá</h3>
                        <ul>
                            <li>Mô tả trải nghiệm thực tế khi sử dụng sản phẩm</li>
                            <li>Đề cập đến chất lượng, độ bền và tính năng nổi bật</li>
                            <li>Thêm hình ảnh thực tế để đánh giá hữu ích hơn</li>
                            <li>Tránh sử dụng ngôn ngữ không phù hợp</li>
                        </ul>
                    </div>

                    <!-- Submit -->
                    <div class="submit-section">
                        <a href="${pageContext.request.contextPath}/customer/orders" class="btn-review btn-secondary-review">
                            <i class="fa fa-arrow-left"></i>
                            Quay lại
                        </a>
                        <button type="submit" class="btn-review btn-primary-review">
                            <i class="fa fa-paper-plane"></i>
                            Gửi đánh giá
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </section>

    <jsp:include page="footer.jsp" />

    <script src="${pageContext.request.contextPath}/js/jquery-3.3.1.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/bootstrap.min.js"></script>
    <script>
        // Star rating interaction
        const ratingInputs = document.querySelectorAll('.star-rating input');
        const ratingText = document.getElementById('ratingText');
        const ratingLabels = {
            1: 'Rất tệ 😞',
            2: 'Không hài lòng 😕',
            3: 'Bình thường 😐',
            4: 'Tốt 😊',
            5: 'Tuyệt vời 🤩'
        };

        ratingInputs.forEach(input => {
            input.addEventListener('change', function() {
                ratingText.textContent = ratingLabels[this.value];
                ratingText.classList.add('active');
            });
        });

        // ========== TEXT VALIDATION ==========
        var TITLE_MAX_LENGTH = 100;
        var CONTENT_MAX_LENGTH = 1000;
        
        // Update character count with color change
        function updateCharCount(input, countEl, maxLength) {
            var length = input.value.length;
            countEl.textContent = length;
            
            var parent = countEl.parentElement;
            if (length > maxLength) {
                parent.style.color = '#E85A4F';
            } else {
                parent.style.color = '#6B7280';
            }
        }
        
        // Show field error
        function showFieldError(input, message) {
            input.style.borderColor = '#E85A4F';
            var errorDiv = input.parentElement.querySelector('.field-error');
            if (!errorDiv) {
                errorDiv = document.createElement('div');
                errorDiv.className = 'field-error';
                errorDiv.style.color = '#E85A4F';
                errorDiv.style.fontSize = '13px';
                errorDiv.style.marginTop = '4px';
                input.parentElement.insertBefore(errorDiv, input.nextSibling);
            }
            errorDiv.textContent = message;
        }
        
        // Clear field error
        function clearFieldError(input) {
            input.style.borderColor = '#E5E7EB';
            var errorDiv = input.parentElement.querySelector('.field-error');
            if (errorDiv) errorDiv.remove();
        }
        
        // Validate text field
        function validateTextField(input, maxLength, fieldName) {
            var value = input.value.trim();
            input.value = value; // Auto trim
            
            clearFieldError(input);
            
            if (value.length > maxLength) {
                showFieldError(input, fieldName + ' không được vượt quá ' + maxLength + ' ký tự (hiện tại: ' + value.length + ')');
                return false;
            }
            
            return true;
        }
        
        // Title input events
        var titleInput = document.getElementById('titleInput');
        var titleCount = document.getElementById('titleCount');
        
        titleInput.addEventListener('input', function() {
            updateCharCount(this, titleCount, TITLE_MAX_LENGTH);
            clearFieldError(this);
        });
        
        titleInput.addEventListener('blur', function() {
            this.value = this.value.trim();
            updateCharCount(this, titleCount, TITLE_MAX_LENGTH);
            validateTextField(this, TITLE_MAX_LENGTH, 'Tiêu đề');
        });
        
        // Content input events
        var contentInput = document.getElementById('contentInput');
        var contentCount = document.getElementById('contentCount');
        
        contentInput.addEventListener('input', function() {
            updateCharCount(this, contentCount, CONTENT_MAX_LENGTH);
            clearFieldError(this);
        });
        
        contentInput.addEventListener('blur', function() {
            this.value = this.value.trim();
            updateCharCount(this, contentCount, CONTENT_MAX_LENGTH);
            validateTextField(this, CONTENT_MAX_LENGTH, 'Nội dung đánh giá');
        });
        
        // Form submit validation
        document.querySelector('.review-form').addEventListener('submit', function(e) {
            var isValid = true;
            
            // Trim all text fields
            titleInput.value = titleInput.value.trim();
            contentInput.value = contentInput.value.trim();
            
            // Validate title
            if (!validateTextField(titleInput, TITLE_MAX_LENGTH, 'Tiêu đề')) {
                isValid = false;
            }
            
            // Validate content
            if (!validateTextField(contentInput, CONTENT_MAX_LENGTH, 'Nội dung đánh giá')) {
                isValid = false;
            }
            
            if (!isValid) {
                e.preventDefault();
                alert('Vui lòng kiểm tra lại thông tin đánh giá');
                return false;
            }
        });

        // Image upload preview
        const imageInput = document.getElementById('imageInput');
        const uploadContainer = document.getElementById('uploadContainer');
        const uploadBox = document.getElementById('uploadBox');
        const MAX_IMAGES = 5;
        const MAX_SIZE = 2 * 1024 * 1024; // 2MB
        let selectedFiles = [];

        imageInput.addEventListener('change', function(e) {
            const files = Array.from(e.target.files);
            
            files.forEach(file => {
                if (selectedFiles.length >= MAX_IMAGES) {
                    alert('Chỉ được upload tối đa ' + MAX_IMAGES + ' ảnh');
                    return;
                }
                if (file.size > MAX_SIZE) {
                    alert('File ' + file.name + ' vượt quá 2MB');
                    return;
                }
                if (!file.type.match(/image\/(jpeg|png|gif)/)) {
                    alert('File ' + file.name + ' không đúng định dạng');
                    return;
                }
                selectedFiles.push(file);
                addPreview(file, selectedFiles.length - 1);
            });
            
            updateUploadBox();
            updateFileInput();
        });

        function addPreview(file, index) {
            const reader = new FileReader();
            reader.onload = function(e) {
                const preview = document.createElement('div');
                preview.className = 'preview-item';
                preview.style.display = 'block';
                preview.dataset.index = index;
                preview.innerHTML = `
                    <img src="${e.target.result}" alt="Preview">
                    <button type="button" class="remove-btn" onclick="removeImage(${index})">
                        <i class="fa fa-times"></i>
                    </button>
                `;
                uploadContainer.insertBefore(preview, uploadBox);
            };
            reader.readAsDataURL(file);
        }

        function removeImage(index) {
            selectedFiles.splice(index, 1);
            refreshPreviews();
            updateUploadBox();
            updateFileInput();
        }

        function refreshPreviews() {
            const previews = uploadContainer.querySelectorAll('.preview-item');
            previews.forEach(p => p.remove());
            selectedFiles.forEach((file, idx) => addPreview(file, idx));
        }

        function updateUploadBox() {
            uploadBox.style.display = selectedFiles.length >= MAX_IMAGES ? 'none' : 'flex';
        }

        function updateFileInput() {
            const dt = new DataTransfer();
            selectedFiles.forEach(file => dt.items.add(file));
            imageInput.files = dt.files;
        }
    </script>
</body>
</html>
