<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo Báo Giá - ${rfq.rfqCode}</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/fontawesome-free/css/all.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/css/adminlte.min.css">
    <style>
        .product-item { background: #f8f9fa; border: 1px solid #dee2e6; border-radius: 8px; padding: 15px; margin-bottom: 15px; }
        .calculated-field { background-color: #e9ecef; font-weight: bold; }
        .summary-box { background: #f8f9fa; border: 2px solid #007bff; border-radius: 8px; padding: 20px; }
        .profit-positive { color: #28a745; }
    </style>
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">
    <jsp:include page="includes/admin-header.jsp" />
    <jsp:include page="includes/admin-sidebar.jsp" />

    <div class="content-wrapper">
        <section class="content-header">
            <div class="container-fluid">
                <div class="row mb-2">
                    <div class="col-sm-6">
                        <h1><i class="fas fa-file-invoice-dollar"></i> Tạo Báo Giá</h1>
                    </div>
                    <div class="col-sm-6">
                        <ol class="breadcrumb float-sm-right">
                            <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/admin/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/admin/rfq">RFQ</a></li>
                            <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/admin/rfq/detail?id=${rfq.rfqID}">${rfq.rfqCode}</a></li>
                            <li class="breadcrumb-item active">Tạo Báo Giá</li>
                        </ol>
                    </div>
                </div>
            </div>
        </section>

        <section class="content">
            <div class="container-fluid py-4">

        <form action="${pageContext.request.contextPath}/admin/quotations/create" method="POST" id="quotationForm">
            <input type="hidden" name="rfqId" value="${rfq.rfqID}">

            <div class="row">
                <div class="col-lg-8">
                    <!-- RFQ Info -->
                    <div class="card mb-4">
                        <div class="card-header"><h5 class="mb-0"><i class="fas fa-info-circle"></i> Thông Tin RFQ</h5></div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <p><strong>Mã RFQ:</strong> ${rfq.rfqCode}</p>
                                    <p><strong>Khách hàng:</strong> ${rfq.contactPerson} (${rfq.contactPhone})</p>
                                    <p><strong>Công ty:</strong> ${rfq.companyName}</p>
                                </div>
                                <div class="col-md-6">
                                    <p><strong>Ngày tạo:</strong> <fmt:formatDate value="${rfq.createdDate}" pattern="dd/MM/yyyy"/></p>
                                    <p><strong>Ngày yêu cầu giao:</strong> <fmt:formatDate value="${rfq.requestedDeliveryDate}" pattern="dd/MM/yyyy"/></p>
                                    <c:if test="${rfq.proposedDeliveryDate != null && rfq.status == 'DateAccepted'}">
                                        <p><strong>Ngày giao hàng mới (đã khách chấp nhận):</strong>
                                            <fmt:formatDate value="${rfq.proposedDeliveryDate}" pattern="dd/MM/yyyy"/>
                                        </p>
                                    </c:if>
                                    <p><strong>Địa chỉ:</strong> ${rfq.deliveryAddress}</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Products Pricing -->
                    <div class="card mb-4">
                        <div class="card-header"><h5 class="mb-0"><i class="fas fa-calculator"></i> Định Giá Sản Phẩm</h5></div>
                        <div class="card-body">
                            <c:forEach var="item" items="${rfq.items}" varStatus="loop">
                                <div class="product-item" data-index="${loop.index}" data-cost="${item.costPrice != null ? item.costPrice : 0}" data-quantity="${item.quantity}" data-max-margin="${item.minProfitMargin != null ? item.minProfitMargin : 30}">
                                    <div class="row align-items-center mb-3">
                                        <div class="col-auto">
                                            <c:choose>
                                                <c:when test="${not empty item.productImage}">
                                                    <img src="${pageContext.request.contextPath}/${item.productImage}" alt="${item.productName}" 
                                                         style="width:70px;height:70px;object-fit:cover;border-radius:8px;border:1px solid #dee2e6;">
                                                </c:when>
                                                <c:otherwise>
                                                    <div style="width:70px;height:70px;background:#f8f9fa;border-radius:8px;border:1px solid #dee2e6;display:flex;align-items:center;justify-content:center;">
                                                        <i class="fas fa-image text-muted fa-2x"></i>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="col">
                                            <h6 class="mb-1">${item.productName}</h6>
                                            <small class="text-muted">SKU: ${item.sku != null ? item.sku : 'N/A'} | Yêu cầu: <strong>${item.quantity}</strong> cái</small>
                                        </div>
                                        <div class="col-auto text-end">
                                            <span class="badge bg-info">Giá vốn: <fmt:formatNumber value="${item.costPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span>
                                            <span class="badge bg-danger">Max: ${item.minProfitMargin != null ? item.minProfitMargin : 30}%</span>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-3">
                                            <label class="form-label">Số Lượng</label>
                                            <input type="number" class="form-control" value="${item.quantity}" readonly>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label">Giá Vốn (₫)</label>
                                            <input type="text" class="form-control calculated-field" value="<fmt:formatNumber value="${item.costPrice}" maxFractionDigits="0"/>" readonly>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label">% Lợi Nhuận <span class="text-danger">*</span></label>
                                            <div class="input-group">
                                                <input type="text" class="form-control profit-margin" name="items[${loop.index}][profitMargin]" 
                                                       value="0" maxlength="5" required 
                                                       oninput="sanitizeProfitInput(this); calculatePrice(${loop.index})" 
                                                       onblur="validateProfitOnBlur(${loop.index})">
                                                <span class="input-group-text">%</span>
                                            </div>
                                            <small class="text-muted">Tối đa: ${item.minProfitMargin != null ? item.minProfitMargin : 30}% (giá bán lẻ)</small>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label">Đơn Giá (₫)</label>
                                            <input type="text" class="form-control calculated-field unit-price" id="unitPrice-${loop.index}" readonly>
                                        </div>
                                    </div>
                                    <div class="row mt-2">
                                        <div class="col-12">
                                            <div class="d-flex justify-content-between align-items-center p-2 bg-white rounded">
                                                <span><strong>Thành tiền:</strong></span>
                                                <h5 class="mb-0 text-success subtotal" id="subtotal-${loop.index}">0₫</h5>
                                            </div>
                                        </div>
                                        <div class="col-12 mt-2">
                                            <input type="text" class="form-control" name="items[${loop.index}][notes]" placeholder="Ghi chú cho sản phẩm này..." maxlength="100">
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- Shipping Info - Seller chọn đơn vị vận chuyển -->
                    <div class="card mb-4">
                        <div class="card-header"><h5 class="mb-0"><i class="fas fa-truck"></i> Chọn Đơn Vị Vận Chuyển</h5></div>
                        <div class="card-body">
                            <div class="row mb-3">
                                <div class="col-md-8">
                                    <p class="mb-1"><i class="fas fa-map-marker-alt text-muted"></i> <strong>Địa chỉ giao hàng:</strong> ${rfq.deliveryAddress}</p>
                                    <p class="mb-0"><i class="fas fa-calendar text-muted"></i> <strong>Ngày khách yêu cầu nhận:</strong> <fmt:formatDate value="${rfq.requestedDeliveryDate}" pattern="dd/MM/yyyy"/></p>
                                </div>
                                <div class="col-md-4 text-right">
                                    <button type="button" class="btn btn-info" id="btnCalculateShipping" onclick="calculateShippingRates()">
                                        <i class="fas fa-calculator"></i> Tính Phí Vận Chuyển
                                    </button>
                                </div>
                            </div>
                            
                            <div id="shippingRatesContainer" style="display:none;">
                                <div id="shippingRatesLoading" class="text-center py-3" style="display:none;">
                                    <i class="fas fa-spinner fa-spin fa-2x"></i>
                                    <p class="mt-2">Đang tính phí vận chuyển...</p>
                                </div>
                                <div id="shippingRatesList"></div>
                            </div>
                            
                            <div id="shippingError" class="alert alert-danger mt-3" style="display:none;">
                                <i class="fas fa-exclamation-triangle"></i> <span id="shippingErrorMsg"></span>
                            </div>
                            
                            <div id="selectedShippingInfo" class="mt-3" style="display:none;">
                                <div class="alert alert-success">
                                    <h6 class="mb-2"><i class="fas fa-check-circle"></i> Đơn Vị Vận Chuyển Đã Chọn</h6>
                                    <div class="row">
                                        <div class="col-md-6">
                                            <strong>Đơn vị:</strong> <span id="selectedCarrierName"></span><br>
                                            <strong>Dịch vụ:</strong> <span id="selectedServiceName"></span>
                                        </div>
                                        <div class="col-md-6">
                                            <strong>Phí ship:</strong> <span id="selectedShippingFee" class="text-primary"></span><br>
                                            <strong>Thời gian giao:</strong> <span id="selectedDeliveryTime"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <input type="hidden" name="shippingCarrierId" id="shippingCarrierId">
                            <input type="hidden" name="shippingCarrierName" id="shippingCarrierNameInput">
                            <input type="hidden" name="shippingServiceName" id="shippingServiceNameInput">
                            <input type="hidden" name="shippingFee" id="shippingFee" value="0">
                            <input type="hidden" name="estimatedDeliveryDays" id="estimatedDeliveryDays">
                        </div>
                    </div>

                    <!-- Cost Summary -->
                    <div class="card mb-4">
                        <div class="card-header"><h5 class="mb-0"><i class="fas fa-money-bill-wave"></i> Chi Phí & Tổng Kết</h5></div>
                        <div class="card-body">
                            <div class="row mb-3">
                                <div class="col-md-4">
                                    <label class="form-label">Phí Vận Chuyển (₫)</label>
                                    <input type="text" class="form-control calculated-field" id="shippingFeeDisplay" value="0" readonly>
                                    <small class="text-muted">Chọn đơn vị vận chuyển ở trên</small>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Thuế VAT (%)</label>
                                    <div class="input-group">
                                        <input type="text" class="form-control calculated-field" value="10" readonly>
                                        <span class="input-group-text">%</span>
                                    </div>
                                    <input type="hidden" name="taxPercent" id="taxPercent" value="10">
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Thuế VAT (₫)</label>
                                    <input type="text" class="form-control calculated-field" id="taxAmount" readonly>
                                </div>
                            </div>
                            <div class="summary-box">
                                <div class="row text-center">
                                    <div class="col-md-4">
                                        <h6 class="text-muted">Tổng Giá Vốn</h6>
                                        <h4 id="totalCost">0₫</h4>
                                    </div>
                                    <div class="col-md-4">
                                        <h6 class="text-muted">Tổng Tiền Hàng</h6>
                                        <h4 class="text-primary" id="subtotalAmount">0₫</h4>
                                    </div>
                                    <div class="col-md-4">
                                        <h6 class="text-muted">TỔNG CỘNG</h6>
                                        <h3 class="text-success" id="grandTotal">0₫</h3>
                                    </div>
                                </div>
                                <hr>
                                <div class="text-center">
                                    <h6 class="text-muted">Tổng Lợi Nhuận Dự Kiến</h6>
                                    <h3 class="text-success" id="totalProfit">0₫</h3>
                                    <p class="mb-0">Margin: <strong class="profit-positive" id="profitMargin">0%</strong></p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Payment Terms -->
                    <div class="card mb-4">
                        <div class="card-header"><h5 class="mb-0"><i class="fas fa-credit-card"></i> Điều Khoản Thanh Toán</h5></div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <label class="form-label">Phương Thức Thanh Toán</label>
                                    <input type="text" class="form-control calculated-field" value="Chuyển khoản ngân hàng (VNPay)" readonly>
                                    <input type="hidden" name="paymentMethod" value="BankTransfer">
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Terms -->
                    <div class="card mb-4">
                        <div class="card-header"><h5 class="mb-0"><i class="fas fa-file-contract"></i> Điều Khoản</h5></div>
                        <div class="card-body">
                            <div class="mb-3">
                                <label class="form-label">Điều Khoản Bảo Hành</label>
                                <textarea class="form-control" name="warrantyTerms" id="warrantyTerms" rows="2" maxlength="300">Bảo hành chính hãng 6 tháng cho vợt, 3 tháng cho phụ kiện</textarea>
                                <small class="text-muted"><span id="warrantyTermsCount">0</span>/300 ký tự</small>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Điều Khoản Khác</label>
                                <textarea class="form-control" name="additionalTerms" id="additionalTerms" rows="3" maxlength="500">1. Hàng không được đổi trả sau khi đã mở seal
2. Thời gian giao hàng có thể thay đổi tùy tình hình thực tế</textarea>
                                <small class="text-muted"><span id="additionalTermsCount">0</span>/500 ký tự</small>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Sidebar Actions -->
                <div class="col-lg-4">
                    <div class="card sticky-top" style="top: 20px;">
                        <div class="card-body">
                            <h5 class="mb-3">Tổng Kết Báo Giá</h5>
                            <table class="table table-sm">
                                <tr><td>Tổng tiền hàng:</td><td class="text-end" id="sideSubtotal">0₫</td></tr>
                                <tr><td>Phí vận chuyển:</td><td class="text-end" id="sideShipping">0₫</td></tr>
                                <tr><td>Thuế VAT:</td><td class="text-end" id="sideTax">0₫</td></tr>
                                <tr class="table-primary"><td><strong>TỔNG CỘNG:</strong></td><td class="text-end"><strong id="sideTotal">0₫</strong></td></tr>
                            </table>
                            <hr>
                            <div class="d-grid gap-2">
                                <button type="submit" class="btn btn-success btn-lg" onclick="return validateForm()">
                                    <i class="fas fa-paper-plane"></i> Gửi Báo Giá
                                </button>
                                <a href="${pageContext.request.contextPath}/admin/rfq/detail?id=${rfq.rfqID}" class="btn btn-secondary">
                                    <i class="fas fa-times"></i> Hủy
                                </a>
                            </div>
                            <div id="validationError" class="alert alert-danger mt-2 d-none"></div>
                        </div>
                    </div>
                </div>
            </div>
        </form>
      </div>
    </section>
  </div>

  <jsp:include page="includes/admin-footer.jsp" />
</div>

    <script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/jquery/jquery.min.js"></script>
    <script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
    <script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/js/adminlte.min.js"></script>
    <script>
        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            // Calculate all prices
            document.querySelectorAll('.product-item').forEach(function(item, index) {
                calculatePrice(index);
            });
            
            // Initialize character counts for textareas
            updateCharCount('warrantyTerms', 'warrantyTermsCount', 300);
            updateCharCount('additionalTerms', 'additionalTermsCount', 500);
            
            // Bind character count events
            var warrantyEl = document.getElementById('warrantyTerms');
            if (warrantyEl) {
                warrantyEl.addEventListener('input', function() {
                    updateCharCount('warrantyTerms', 'warrantyTermsCount', 300);
                });
            }
            
            var additionalEl = document.getElementById('additionalTerms');
            if (additionalEl) {
                additionalEl.addEventListener('input', function() {
                    updateCharCount('additionalTerms', 'additionalTermsCount', 500);
                });
            }
            
            // Limit product notes length
            document.querySelectorAll('input[name*="[notes]"]').forEach(function(input) {
                input.addEventListener('input', function() {
                    if (this.value.length > 100) {
                        this.value = this.value.substring(0, 100);
                    }
                });
            });
        });
        
        // Character count helper
        function updateCharCount(inputId, countId, maxLen) {
            var input = document.getElementById(inputId);
            var count = document.getElementById(countId);
            if (input && count) {
                count.textContent = input.value.length;
            }
        }

        // Sanitize profit input - chỉ cho phép số và dấu chấm thập phân
        function sanitizeProfitInput(input) {
            var value = input.value;
            // Xóa dấu cách
            value = value.replace(/\s/g, '');
            // Chỉ giữ số và dấu chấm
            value = value.replace(/[^0-9.]/g, '');
            // Chỉ cho phép 1 dấu chấm
            var parts = value.split('.');
            if (parts.length > 2) {
                value = parts[0] + '.' + parts.slice(1).join('');
            }
            input.value = value;
        }
        
        // Validate khi blur (rời khỏi input)
        function validateProfitOnBlur(index) {
            var item = document.querySelector('.product-item[data-index="' + index + '"]');
            var maxMargin = parseFloat(item.dataset.maxMargin) || 30;
            var profitInput = item.querySelector('.profit-margin');
            
            // Trim và xử lý
            var value = profitInput.value.trim();
            
            // Nếu để trống hoặc chỉ có dấu chấm -> set về 0
            if (value === '' || value === '.') {
                profitInput.value = '0';
                value = '0';
            }
            
            // Xử lý số 0 ở đầu (ví dụ: 05 -> 5, nhưng 0.5 giữ nguyên)
            if (value.length > 1 && value[0] === '0' && value[1] !== '.') {
                value = parseFloat(value).toString();
                profitInput.value = value;
            }
            
            var profitMargin = parseFloat(value) || 0;
            
            // Validate max profit margin
            if (profitMargin < 0 || isNaN(profitMargin)) {
                profitInput.value = 0;
                profitInput.classList.add('is-invalid');
                alert('% Lợi nhuận không hợp lệ!');
                setTimeout(function() { profitInput.classList.remove('is-invalid'); }, 2000);
            } else if (profitMargin > maxMargin) {
                profitInput.value = maxMargin;
                profitInput.classList.add('is-invalid');
                alert('% Lợi nhuận không được vượt quá ' + maxMargin + '% (giá bán lẻ)!');
                setTimeout(function() { profitInput.classList.remove('is-invalid'); }, 2000);
            } else {
                profitInput.classList.remove('is-invalid');
            }
            
            calculatePrice(index);
        }
        
        function calculatePrice(index) {
            var item = document.querySelector('.product-item[data-index="' + index + '"]');
            var costPrice = parseFloat(item.dataset.cost) || 0;
            var quantity = parseInt(item.dataset.quantity) || 0;
            var profitMargin = parseFloat(item.querySelector('.profit-margin').value) || 0;
            
            var unitPrice = costPrice * (1 + profitMargin / 100);
            var subtotal = unitPrice * quantity;
            
            document.getElementById('unitPrice-' + index).value = formatCurrency(unitPrice);
            document.getElementById('subtotal-' + index).textContent = formatCurrency(subtotal) + '₫';
            
            calculateTotal();
        }

        function calculateTotal() {
            var subtotalAmount = 0;
            var totalCost = 0;
            
            document.querySelectorAll('.product-item').forEach(function(item) {
                var costPrice = parseFloat(item.dataset.cost) || 0;
                var quantity = parseInt(item.dataset.quantity) || 0;
                var profitMargin = parseFloat(item.querySelector('.profit-margin').value) || 0;
                var unitPrice = costPrice * (1 + profitMargin / 100);
                
                subtotalAmount += unitPrice * quantity;
                totalCost += costPrice * quantity;
            });
            
            var shippingFee = parseFloat(document.getElementById('shippingFee').value) || 0;
            var taxPercent = 10; // Fixed at 10%
            var taxAmount = subtotalAmount * (taxPercent / 100);
            var grandTotal = subtotalAmount + shippingFee + taxAmount;
            var totalProfit = subtotalAmount - totalCost;
            var profitMargin = totalCost > 0 ? (totalProfit / totalCost * 100).toFixed(2) : 0;
            
            document.getElementById('totalCost').textContent = formatCurrency(totalCost) + '₫';
            document.getElementById('subtotalAmount').textContent = formatCurrency(subtotalAmount) + '₫';
            document.getElementById('taxAmount').value = formatCurrency(taxAmount);
            document.getElementById('grandTotal').textContent = formatCurrency(grandTotal) + '₫';
            document.getElementById('totalProfit').textContent = formatCurrency(totalProfit) + '₫';
            document.getElementById('profitMargin').textContent = profitMargin + '%';
            
            // Update sidebar
            document.getElementById('sideSubtotal').textContent = formatCurrency(subtotalAmount) + '₫';
            document.getElementById('sideShipping').textContent = formatCurrency(shippingFee) + '₫';
            document.getElementById('sideTax').textContent = formatCurrency(taxAmount) + '₫';
            document.getElementById('sideTotal').textContent = formatCurrency(grandTotal) + '₫';
        }

        function formatCurrency(value) {
            return Math.round(value).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        }
        
        function validateForm() {
            var errorDiv = document.getElementById('validationError');
            var hasError = false;
            var errorMessages = [];
            
            // Validate profit margins (không được vượt quá ngưỡng bán lẻ)
            document.querySelectorAll('.product-item').forEach(function(item, index) {
                var maxMargin = parseFloat(item.dataset.maxMargin) || 30;
                var profitInput = item.querySelector('.profit-margin');
                var profitMargin = parseFloat(profitInput.value) || 0;
                var productName = item.querySelector('h6').textContent;
                
                if (profitMargin < 0) {
                    hasError = true;
                    profitInput.classList.add('is-invalid');
                    errorMessages.push(productName + ': % lợi nhuận không được âm');
                } else if (profitMargin > maxMargin) {
                    hasError = true;
                    profitInput.classList.add('is-invalid');
                    errorMessages.push(productName + ': % lợi nhuận không được vượt quá ' + maxMargin + '% (giá bán lẻ)');
                } else {
                    profitInput.classList.remove('is-invalid');
                }
            });
            
            // Validate shipping method selected
            if (!document.getElementById('shippingCarrierId').value) {
                hasError = true;
                errorMessages.push('Vui lòng chọn đơn vị vận chuyển');
            }
            
            if (hasError) {
                errorDiv.innerHTML = errorMessages.join('<br>');
                errorDiv.classList.remove('d-none');
                return false;
            }
            
            errorDiv.classList.add('d-none');
            return true;
        }
        
        // ===== Shipping Rate Functions =====
        var contextPath = '<%= request.getContextPath() %>';
        var deliveryCityId = '${rfq.deliveryCityId}';
        var deliveryDistrictId = '${rfq.deliveryDistrictId}';
        
        function calculateShippingRates() {
            if (!deliveryCityId || !deliveryDistrictId) {
                alert('Không có thông tin địa chỉ giao hàng từ RFQ.');
                return;
            }
            
            // Calculate total weight based on quantity (assume 500g per item)
            var totalQuantity = 0;
            document.querySelectorAll('.product-item').forEach(function(item) {
                totalQuantity += parseInt(item.dataset.quantity) || 0;
            });
            
            if (totalQuantity === 0) {
                alert('Không có sản phẩm trong RFQ.');
                return;
            }
            
            var weight = totalQuantity * 500; // 500g per item
            
            document.getElementById('shippingRatesContainer').style.display = 'block';
            document.getElementById('shippingRatesLoading').style.display = 'block';
            document.getElementById('shippingRatesList').innerHTML = '';
            document.getElementById('shippingError').style.display = 'none';
            
            $.ajax({
                url: contextPath + '/api/goship/rates',
                type: 'GET',
                data: {
                    toCityId: deliveryCityId,
                    toDistrictId: deliveryDistrictId,
                    weight: weight,
                    cod: 0
                },
                dataType: 'json',
                success: function(response) {
                    document.getElementById('shippingRatesLoading').style.display = 'none';
                    
                    if (response.success && response.rates && response.rates.length > 0) {
                        renderShippingRates(response.rates);
                        document.getElementById('shippingError').style.display = 'none';
                    } else {
                        document.getElementById('shippingError').style.display = 'block';
                        document.getElementById('shippingErrorMsg').innerHTML = '<strong>Không có đơn vị vận chuyển nào nhận địa điểm này.</strong><br>Vui lòng liên hệ khách hàng để thay đổi địa chỉ giao hàng.';
                        document.getElementById('shippingRatesList').innerHTML = '';
                    }
                },
                error: function() {
                    document.getElementById('shippingRatesLoading').style.display = 'none';
                    document.getElementById('shippingError').style.display = 'block';
                    document.getElementById('shippingErrorMsg').textContent = 'Lỗi kết nối đến dịch vụ vận chuyển. Vui lòng thử lại sau.';
                }
            });
        }
        
        function renderShippingRates(rates) {
            var html = '<div class="list-group">';
            
            for (var i = 0; i < rates.length; i++) {
                var rate = rates[i];
                var estimatedDays = parseEstimatedDays(rate.estimatedDelivery);
                var priceFormatted = formatCurrency(rate.price) + '₫';
                
                html += '<label class="list-group-item list-group-item-action d-flex align-items-center" style="cursor:pointer;">';
                html += '<input type="radio" name="shippingRateRadio" class="me-3" ';
                html += 'data-id="' + rate.id + '" ';
                html += 'data-carrier="' + escapeHtml(rate.carrierName) + '" ';
                html += 'data-service="' + escapeHtml(rate.serviceName) + '" ';
                html += 'data-price="' + rate.price + '" ';
                html += 'data-days="' + estimatedDays + '" ';
                html += 'data-delivery="' + escapeHtml(rate.estimatedDelivery) + '" ';
                html += 'onchange="selectShippingRate(this)">';
                
                if (rate.carrierLogo) {
                    html += '<img src="' + rate.carrierLogo + '" alt="" style="width:50px;height:30px;object-fit:contain;" class="me-3">';
                }
                
                html += '<div class="flex-grow-1">';
                html += '<strong>' + escapeHtml(rate.carrierName) + '</strong>';
                html += '<br><small class="text-muted">' + escapeHtml(rate.serviceName) + ' - ' + escapeHtml(rate.estimatedDelivery) + '</small>';
                html += '</div>';
                html += '<div class="text-end">';
                html += '<strong class="text-primary">' + priceFormatted + '</strong>';
                html += '</div>';
                html += '</label>';
            }
            
            html += '</div>';
            document.getElementById('shippingRatesList').innerHTML = html;
        }
        
        function parseEstimatedDays(estimatedDelivery) {
            if (!estimatedDelivery) return 3;
            
            var lowerText = estimatedDelivery.toLowerCase();
            var match = lowerText.match(/(\d+)[-–]?(\d+)?/);
            
            if (match) {
                var maxValue = parseInt(match[2] || match[1]) || 3;
                if (lowerText.indexOf('giờ') !== -1 || lowerText.indexOf('hour') !== -1) {
                    return Math.ceil(maxValue / 24) || 1;
                }
                return maxValue;
            }
            return 3;
        }
        
        function selectShippingRate(radio) {
            var id = radio.getAttribute('data-id');
            var carrierName = radio.getAttribute('data-carrier');
            var serviceName = radio.getAttribute('data-service');
            var price = parseFloat(radio.getAttribute('data-price')) || 0;
            var days = radio.getAttribute('data-days');
            var deliveryTime = radio.getAttribute('data-delivery');
            
            // Update hidden fields
            document.getElementById('shippingCarrierId').value = id;
            document.getElementById('shippingCarrierNameInput').value = carrierName;
            document.getElementById('shippingServiceNameInput').value = serviceName;
            document.getElementById('shippingFee').value = price;
            document.getElementById('estimatedDeliveryDays').value = days;
            
            // Update display
            document.getElementById('shippingFeeDisplay').value = formatCurrency(price);
            
            // Show selected info
            document.getElementById('selectedShippingInfo').style.display = 'block';
            document.getElementById('selectedCarrierName').textContent = carrierName;
            document.getElementById('selectedServiceName').textContent = serviceName;
            document.getElementById('selectedShippingFee').textContent = formatCurrency(price) + '₫';
            document.getElementById('selectedDeliveryTime').textContent = deliveryTime;
            
            // Recalculate total
            calculateTotal();
        }
        
        function escapeHtml(text) {
            if (!text) return '';
            var div = document.createElement('div');
            div.appendChild(document.createTextNode(text));
            return div.innerHTML;
        }
    </script>
</body>
</html>
