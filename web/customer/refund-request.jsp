<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:if test="${empty sessionScope.customer}">
    <c:redirect url="/login"/>
</c:if>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Yêu cầu hoàn tiền - Pickleball Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" type="text/css">
</head>
<body>
    <%@include file="../header.jsp" %>
    
    <section class="breadcrumb-option">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="breadcrumb__text">
                        <h4>Yêu cầu hoàn tiền</h4>
                        <div class="breadcrumb__links">
                            <a href="${pageContext.request.contextPath}/Home">Trang chủ</a>
                            <a href="${pageContext.request.contextPath}/customer/orders">Đơn hàng</a>
                            <span>Yêu cầu hoàn tiền</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    
    <section class="spad">
        <div class="container">
            <div class="row mb-4">
                <div class="col-12">
                    <h5>Đơn hàng: <span class="text-danger">${order.orderCode}</span></h5>
                </div>
            </div>

            <form action="${pageContext.request.contextPath}/customer/refund" method="post" enctype="multipart/form-data" id="refundForm">
                <input type="hidden" name="action" value="submit">
                <input type="hidden" name="orderId" value="${order.orderID}">
                
                <div class="row">
                    <div class="col-lg-8">
                        <div class="card mb-4">
                            <div class="card-header bg-light">
                                <h6 class="mb-0"><i class="fa fa-shopping-bag"></i> Chọn sản phẩm cần hoàn</h6>
                            </div>
                            <div class="card-body">
                                <c:forEach var="detail" items="${order.orderDetails}" varStatus="status">
                                    <div class="border rounded p-3 mb-3" id="item-${detail.orderDetailID}">
                                        <div class="row align-items-center">
                                            <div class="col-auto">
                                                <input class="form-check-input item-checkbox" type="checkbox" 
                                                       data-item-id="${detail.orderDetailID}"
                                                       data-price="${detail.finalPrice}"
                                                       data-max="${detail.quantity}"
                                                       onchange="toggleItem('${detail.orderDetailID}')"
                                                       style="width: 20px; height: 20px;">
                                            </div>
                                            <div class="col-auto">
                                                <img src="${pageContext.request.contextPath}/${detail.productImage}" 
                                                     style="width: 70px; height: 70px; object-fit: cover; border-radius: 4px;"
                                                     onerror="this.src='${pageContext.request.contextPath}/img/product/product-placeholder.jpg'">
                                            </div>
                                            <div class="col">
                                                <h6 class="mb-1">${detail.productName}</h6>
                                                <small class="text-muted">SKU: ${detail.sku}</small>
                                                <div class="mt-1">
                                                    <span class="text-danger font-weight-bold">
                                                        <fmt:formatNumber value="${detail.unitPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                                    </span>
                                                    <span class="text-muted">x ${detail.quantity}</span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                                
                                <!-- Hidden inputs sẽ được tạo động bởi JavaScript khi submit -->
                                <div id="selectedItemsContainer"></div>
                            </div>
                        </div>
                        
                        <div class="card mb-4">
                            <div class="card-header bg-light">
                                <h6 class="mb-0"><i class="fa fa-comment"></i> Lý do yêu cầu hoàn tiền</h6>
                            </div>
                            <div class="card-body">
                                <div class="form-group mb-3">
                                    <label><strong>Chọn lý do</strong> <span class="text-danger">*</span></label>
                                    <select class="form-control" id="reasonSelect" onchange="updateReasonText()">
                                        <option value="">-- Chọn lý do --</option>
                                        <option value="Sản phẩm bị lỗi/hư hỏng">Sản phẩm bị lỗi/hư hỏng</option>
                                        <option value="Sản phẩm không đúng mô tả">Sản phẩm không đúng mô tả</option>
                                        <option value="Nhận sai sản phẩm">Nhận sai sản phẩm</option>
                                        <option value="Hư hỏng trong quá trình vận chuyển">Hư hỏng trong quá trình vận chuyển</option>
                                        <option value="Đổi ý không muốn mua nữa">Đổi ý không muốn mua nữa</option>
                                        <option value="other">Lý do khác</option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label><strong>Mô tả chi tiết</strong> <span class="text-danger">*</span></label>
                                    <textarea class="form-control" name="refundReason" id="refundReason" rows="4" 
                                              placeholder="Vui lòng mô tả chi tiết lý do bạn muốn hoàn tiền..." required></textarea>
                                </div>
                            </div>
                        </div>
                        
                        <div class="card mb-4">
                            <div class="card-header bg-light">
                                <h6 class="mb-0"><i class="fa fa-camera"></i> Hình ảnh/Video minh chứng</h6>
                            </div>
                            <div class="card-body">
                                <div class="border border-dashed rounded p-4 text-center" style="cursor: pointer; background: #fafafa;" 
                                     onclick="document.getElementById('mediaFiles').click()" id="uploadArea">
                                    <i class="fa fa-cloud-upload fa-3x text-muted mb-2"></i>
                                    <p class="mb-0">Click để tải lên hình ảnh hoặc video</p>
                                    <small class="text-muted">Hỗ trợ: JPG, JPEG, PNG, GIF, MP4, MOV, AVI (tối đa 10MB/file, tối đa 5 file)</small>
                                </div>
                                <input type="file" id="mediaFiles" name="mediaFiles" multiple 
                                       accept=".jpg,.jpeg,.png,.gif,.mp4,.mov,.avi,image/jpeg,image/png,image/gif,video/mp4,video/quicktime,video/x-msvideo" 
                                       style="display: none;" onchange="validateAndPreviewMedia(this)">
                                <div id="mediaError" class="alert alert-danger mt-2" style="display: none;"></div>
                                <div id="mediaPreview" class="d-flex flex-wrap mt-3" style="gap: 10px;"></div>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-4">
                        <div class="card" style="position: sticky; top: 100px;">
                            <div class="card-body">
                                <h5 class="mb-4"><i class="fa fa-file-text-o"></i> Tóm tắt hoàn tiền</h5>
                                
                                <div class="d-flex justify-content-between mb-2">
                                    <span>Tổng đơn hàng:</span>
                                    <span><fmt:formatNumber value="${order.totalAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</span>
                                </div>
                                
                                <div class="d-flex justify-content-between mb-2">
                                    <span>Sản phẩm đã chọn:</span>
                                    <span id="selectedCount">0</span>
                                </div>
                                
                                <hr>
                                
                                <div class="d-flex justify-content-between mb-3">
                                    <strong>Số tiền hoàn dự kiến:</strong>
                                    <strong class="text-danger" style="font-size: 18px;" id="refundAmount">0₫</strong>
                                </div>
                                
                                <div class="alert alert-info py-2 mb-3">
                                    <small>
                                        <i class="fa fa-info-circle"></i>
                                        Số tiền hoàn thực tế có thể thay đổi sau khi xem xét.
                                    </small>
                                </div>
                                
                                <button type="submit" class="btn btn-danger btn-block" id="submitBtn" disabled>
                                    <i class="fa fa-paper-plane"></i> Gửi yêu cầu hoàn tiền
                                </button>
                                
                                <a href="${pageContext.request.contextPath}/customer/orders?action=detail&id=${order.orderID}" class="btn btn-secondary btn-block mt-2">
                                    <i class="fa fa-arrow-left"></i> Quay lại
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </section>
    
    <%@include file="../footer.jsp"%>
    
    <script src="${pageContext.request.contextPath}/js/jquery-3.3.1.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/bootstrap.min.js"></script>
    <script>
        // Hide preloader
        $(window).on('load', function() {
            $(".loader").fadeOut();
            $("#preloder").delay(200).fadeOut("slow");
        });
        setTimeout(function() {
            $(".loader").fadeOut();
            $("#preloder").fadeOut("slow");
        }, 2000);
        
        function toggleItem(itemId) {
            var checkbox = document.querySelector('input[data-item-id="' + itemId + '"]');
            var itemDiv = document.getElementById('item-' + itemId);
            
            if (checkbox && checkbox.checked) {
                itemDiv.style.borderColor = '#e53637';
                itemDiv.style.background = '#fff5f5';
            } else {
                itemDiv.style.borderColor = '#dee2e6';
                itemDiv.style.background = '#fff';
            }
            updateRefundAmount();
        }
        
        function updateRefundAmount() {
            var total = 0;
            var count = 0;
            var checkboxes = document.querySelectorAll('.item-checkbox:checked');
            checkboxes.forEach(function(checkbox) {
                // data-price là đơn giá (FinalPrice), data-max là số lượng
                var unitPrice = parseFloat(checkbox.dataset.price);
                var qty = parseInt(checkbox.dataset.max);
                total += unitPrice * qty;
                count++;
            });
            document.getElementById('selectedCount').textContent = count;
            document.getElementById('refundAmount').textContent = formatCurrency(total);
            document.getElementById('submitBtn').disabled = count === 0;
        }
        
        function formatCurrency(amount) {
            return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);
        }
        
        function updateReasonText() {
            var select = document.getElementById('reasonSelect');
            var textarea = document.getElementById('refundReason');
            if (select.value && select.value !== 'other') {
                textarea.value = select.value;
            } else if (select.value === 'other') {
                textarea.value = '';
                textarea.focus();
            }
        }
        
        var MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
        var MAX_FILES = 5;
        var ALLOWED_IMAGE_TYPES = ['image/jpeg', 'image/png', 'image/gif', 'image/jpg'];
        var ALLOWED_VIDEO_TYPES = ['video/mp4', 'video/quicktime', 'video/x-msvideo', 'video/avi'];
        var ALLOWED_EXTENSIONS = ['.jpg', '.jpeg', '.png', '.gif', '.mp4', '.mov', '.avi'];
        
        function validateAndPreviewMedia(input) {
            var preview = document.getElementById('mediaPreview');
            var errorDiv = document.getElementById('mediaError');
            preview.innerHTML = '';
            errorDiv.style.display = 'none';
            errorDiv.innerHTML = '';
            
            if (!input.files || input.files.length === 0) return;
            
            var errors = [];
            var validFiles = [];
            
            // Check số lượng file
            if (input.files.length > MAX_FILES) {
                errors.push('Chỉ được tải lên tối đa ' + MAX_FILES + ' file');
            }
            
            Array.from(input.files).forEach(function(file, index) {
                if (index >= MAX_FILES) return;
                
                var fileName = file.name.toLowerCase();
                var fileExt = fileName.substring(fileName.lastIndexOf('.'));
                var isValidType = ALLOWED_IMAGE_TYPES.includes(file.type) || ALLOWED_VIDEO_TYPES.includes(file.type);
                var isValidExt = ALLOWED_EXTENSIONS.includes(fileExt);
                
                // Validate định dạng
                if (!isValidType && !isValidExt) {
                    errors.push('File "' + file.name + '" không đúng định dạng. Chỉ hỗ trợ: JPG, PNG, GIF, MP4, MOV, AVI');
                    return;
                }
                
                // Validate dung lượng
                if (file.size > MAX_FILE_SIZE) {
                    errors.push('File "' + file.name + '" vượt quá 10MB (kích thước: ' + (file.size / 1024 / 1024).toFixed(2) + 'MB)');
                    return;
                }
                
                validFiles.push(file);
            });
            
            // Hiển thị lỗi nếu có
            if (errors.length > 0) {
                errorDiv.innerHTML = '<ul class="mb-0 pl-3">' + errors.map(function(e) { return '<li>' + e + '</li>'; }).join('') + '</ul>';
                errorDiv.style.display = 'block';
            }
            
            // Preview các file hợp lệ
            validFiles.forEach(function(file) {
                var wrapper = document.createElement('div');
                wrapper.style.cssText = 'position:relative;width:100px;height:100px;';
                
                if (file.type.startsWith('image/') || ALLOWED_IMAGE_TYPES.some(function(t) { return file.name.toLowerCase().endsWith(t.split('/')[1]); })) {
                    var reader = new FileReader();
                    reader.onload = function(e) {
                        var img = document.createElement('img');
                        img.src = e.target.result;
                        img.style.cssText = 'width:100px;height:100px;object-fit:cover;border-radius:8px;border:2px solid #e0e0e0;';
                        wrapper.appendChild(img);
                    };
                    reader.readAsDataURL(file);
                } else if (file.type.startsWith('video/')) {
                    var videoWrapper = document.createElement('div');
                    videoWrapper.style.cssText = 'width:100px;height:100px;background:#000;border-radius:8px;display:flex;align-items:center;justify-content:center;position:relative;';
                    videoWrapper.innerHTML = '<i class="fa fa-play-circle" style="color:#fff;font-size:32px;"></i><span style="position:absolute;bottom:5px;left:5px;color:#fff;font-size:10px;background:rgba(0,0,0,0.7);padding:2px 5px;border-radius:3px;">Video</span>';
                    wrapper.appendChild(videoWrapper);
                }
                
                // Nút xóa
                var removeBtn = document.createElement('span');
                removeBtn.innerHTML = '&times;';
                removeBtn.style.cssText = 'position:absolute;top:-5px;right:-5px;background:#dc3545;color:#fff;width:20px;height:20px;border-radius:50%;display:flex;align-items:center;justify-content:center;cursor:pointer;font-size:14px;';
                removeBtn.onclick = function(e) {
                    e.stopPropagation();
                    wrapper.remove();
                };
                wrapper.appendChild(removeBtn);
                
                preview.appendChild(wrapper);
            });
        }
        
        document.getElementById('refundForm').addEventListener('submit', function(e) {
            var checkedItems = document.querySelectorAll('.item-checkbox:checked');
            var reason = document.getElementById('refundReason').value.trim();
            if (checkedItems.length === 0) {
                e.preventDefault();
                alert('Vui lòng chọn ít nhất một sản phẩm cần hoàn');
                return;
            }
            if (!reason) {
                e.preventDefault();
                alert('Vui lòng nhập lý do hoàn tiền');
                return;
            }
            
            // Tạo hidden inputs cho các item được chọn
            var container = document.getElementById('selectedItemsContainer');
            container.innerHTML = '';
            checkedItems.forEach(function(checkbox) {
                var itemId = checkbox.dataset.itemId;
                var qty = checkbox.dataset.max;
                
                var inputId = document.createElement('input');
                inputId.type = 'hidden';
                inputId.name = 'itemIds';
                inputId.value = itemId;
                container.appendChild(inputId);
                
                var inputQty = document.createElement('input');
                inputQty.type = 'hidden';
                inputQty.name = 'quantities';
                inputQty.value = qty;
                container.appendChild(inputQty);
                
                var inputReason = document.createElement('input');
                inputReason.type = 'hidden';
                inputReason.name = 'itemReasons';
                inputReason.value = '';
                container.appendChild(inputReason);
            });
        });
    </script>
</body>
</html>