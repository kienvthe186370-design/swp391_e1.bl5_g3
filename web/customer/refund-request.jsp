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
                                                       name="itemIds" value="${detail.orderDetailID}"
                                                       data-price="${detail.finalPrice / detail.quantity}"
                                                       data-max="${detail.quantity}"
                                                       onchange="toggleItem(${detail.orderDetailID})"
                                                       style="width: 20px; height: 20px;">
                                            </div>
                                            <div class="col-auto">
                                                <img src="${pageContext.request.contextPath}${detail.productImage}" 
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
                                        
                                        <div class="mt-3 pt-3 border-top" id="reason-${detail.orderDetailID}" style="display: none;">
                                            <div class="row">
                                                <div class="col-md-4">
                                                    <label><strong>Số lượng hoàn</strong></label>
                                                    <input type="number" class="form-control qty-input" 
                                                           name="quantities" min="1" max="${detail.quantity}" value="${detail.quantity}"
                                                           data-item="${detail.orderDetailID}"
                                                           onchange="updateRefundAmount()">
                                                </div>
                                                <div class="col-md-8">
                                                    <label><strong>Lý do</strong></label>
                                                    <select class="form-control" name="itemReasons">
                                                        <option value="Sản phẩm bị lỗi">Sản phẩm bị lỗi</option>
                                                        <option value="Không đúng mô tả">Không đúng mô tả</option>
                                                        <option value="Hư hỏng khi vận chuyển">Hư hỏng khi vận chuyển</option>
                                                        <option value="Nhận sai sản phẩm">Nhận sai sản phẩm</option>
                                                        <option value="Khác">Khác</option>
                                                    </select>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
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
                                     onclick="document.getElementById('mediaFiles').click()">
                                    <i class="fa fa-cloud-upload fa-3x text-muted mb-2"></i>
                                    <p class="mb-0">Click để tải lên hình ảnh hoặc video</p>
                                    <small class="text-muted">Hỗ trợ: JPG, PNG, MP4 (tối đa 5MB/file)</small>
                                </div>
                                <input type="file" id="mediaFiles" name="mediaFiles" multiple accept="image/*,video/*" 
                                       style="display: none;" onchange="previewMedia(this)">
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
                                
                                <a href="${pageContext.request.contextPath}/customer/order-detail?id=${order.orderID}" class="btn btn-secondary btn-block mt-2">
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
            var checkbox = document.querySelector('input[value="' + itemId + '"]');
            var reasonDiv = document.getElementById('reason-' + itemId);
            var itemDiv = document.getElementById('item-' + itemId);
            
            if (checkbox.checked) {
                reasonDiv.style.display = 'block';
                itemDiv.style.borderColor = '#e53637';
                itemDiv.style.background = '#fff5f5';
            } else {
                reasonDiv.style.display = 'none';
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
                var price = parseFloat(checkbox.dataset.price);
                var itemId = checkbox.value;
                var qtyInput = document.querySelector('.qty-input[data-item="' + itemId + '"]');
                var qty = qtyInput ? parseInt(qtyInput.value) : parseInt(checkbox.dataset.max);
                total += price * qty;
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
        
        function previewMedia(input) {
            var preview = document.getElementById('mediaPreview');
            preview.innerHTML = '';
            if (input.files) {
                Array.from(input.files).forEach(function(file) {
                    var reader = new FileReader();
                    reader.onload = function(e) {
                        if (file.type.startsWith('image/')) {
                            var img = document.createElement('img');
                            img.src = e.target.result;
                            img.style.cssText = 'width:80px;height:80px;object-fit:cover;border-radius:4px;border:2px solid #e0e0e0;';
                            preview.appendChild(img);
                        }
                    };
                    reader.readAsDataURL(file);
                });
            }
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
        });
    </script>
</body>
</html>