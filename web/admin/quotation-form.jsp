<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo Báo Giá - ${rfq.rfqCode}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .product-item { background: #f8f9fa; border: 1px solid #dee2e6; border-radius: 8px; padding: 15px; margin-bottom: 15px; }
        .calculated-field { background-color: #e9ecef; font-weight: bold; }
        .summary-box { background: #f8f9fa; border: 2px solid #007bff; border-radius: 8px; padding: 20px; }
        .profit-positive { color: #28a745; }
    </style>
</head>
<body class="bg-light">
    <div class="container-fluid py-4">
        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4><i class="fas fa-file-invoice-dollar"></i> Tạo Báo Giá</h4>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/rfq">RFQ</a></li>
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/rfq/detail?id=${rfq.rfqID}">${rfq.rfqCode}</a></li>
                        <li class="breadcrumb-item active">Tạo Báo Giá</li>
                    </ol>
                </nav>
            </div>
        </div>

        <form action="${pageContext.request.contextPath}/admin/rfq/send-quotation" method="POST" id="quotationForm">
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
                                            <input type="text" class="form-control" name="items[${loop.index}][notes]" placeholder="Ghi chú cho sản phẩm này..." maxlength="200">
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- Shipping Calculation -->
                    <div class="card mb-4">
                        <div class="card-header"><h5 class="mb-0"><i class="fas fa-truck"></i> Tính Phí Vận Chuyển (Goship)</h5></div>
                        <div class="card-body">
                            <div class="row mb-3">
                                <div class="col-md-4">
                                    <label class="form-label">Tổng Cân Nặng</label>
                                    <div class="input-group">
                                        <input type="number" class="form-control" id="totalWeight" value="${totalWeight}" readonly>
                                        <span class="input-group-text">gram</span>
                                    </div>
                                    <small class="text-muted">Tự động tính từ sản phẩm</small>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Địa Chỉ Giao</label>
                                    <input type="text" class="form-control" value="${rfq.deliveryAddress}" readonly>
                                </div>
                                <div class="col-md-4 d-flex align-items-end">
                                    <button type="button" class="btn btn-info w-100" onclick="calculateShipping()">
                                        <i class="fas fa-calculator"></i> Tính Phí Ship
                                    </button>
                                </div>
                            </div>
                            <div id="shippingOptions" class="d-none">
                                <label class="form-label">Chọn Đơn Vị Vận Chuyển</label>
                                <div id="shippingRates" class="row"></div>
                            </div>
                            <div id="shippingLoading" class="text-center d-none">
                                <div class="spinner-border text-primary" role="status"></div>
                                <p>Đang tính phí vận chuyển...</p>
                            </div>
                            <div id="shippingError" class="alert alert-warning d-none"></div>
                        </div>
                    </div>

                    <!-- Cost Summary -->
                    <div class="card mb-4">
                        <div class="card-header"><h5 class="mb-0"><i class="fas fa-money-bill-wave"></i> Chi Phí & Tổng Kết</h5></div>
                        <div class="card-body">
                            <div class="row mb-3">
                                <div class="col-md-4">
                                    <label class="form-label">Phí Vận Chuyển (₫)</label>
                                    <input type="number" class="form-control calculated-field" name="shippingFee" id="shippingFee" value="0" readonly>
                                    <small class="text-muted" id="selectedCarrier">Chọn đơn vị vận chuyển ở trên</small>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Thuế VAT (%)</label>
                                    <div class="input-group">
                                        <input type="number" class="form-control" name="taxPercent" id="taxPercent" value="10" min="0" max="100" onchange="calculateTotal()">
                                        <span class="input-group-text">%</span>
                                    </div>
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
                                <textarea class="form-control" name="warrantyTerms" rows="2">Bảo hành chính hãng 6 tháng cho vợt, 3 tháng cho phụ kiện</textarea>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Điều Khoản Khác</label>
                                <textarea class="form-control" name="additionalTerms" rows="3">1. Hàng không được đổi trả sau khi đã mở seal
2. Thời gian giao hàng có thể thay đổi tùy tình hình thực tế</textarea>
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

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            // Set default valid until date (7 days from now)
            // Calculate all prices
            document.querySelectorAll('.product-item').forEach(function(item, index) {
                calculatePrice(index);
            });
        });

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
            var taxPercent = parseFloat(document.getElementById('taxPercent').value) || 0;
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
        
        // Shipping calculation with Goship - using address parsing API
        var deliveryAddress = '${rfq.deliveryAddress}';
        var deliveryCityId = '${deliveryCityId}';
        var deliveryDistrictId = '${deliveryDistrictId}';
        
        function calculateShipping() {
            var weight = document.getElementById('totalWeight').value || 500;
            
            document.getElementById('shippingLoading').classList.remove('d-none');
            document.getElementById('shippingOptions').classList.add('d-none');
            document.getElementById('shippingError').classList.add('d-none');
            
            // If we have city/district IDs, use them directly
            if (deliveryCityId && deliveryDistrictId) {
                fetchShippingRatesByIds(deliveryCityId, deliveryDistrictId, weight);
            } else if (deliveryAddress) {
                // Use address parsing API
                fetchShippingRatesByAddress(deliveryAddress, weight);
            } else {
                document.getElementById('shippingLoading').classList.add('d-none');
                document.getElementById('shippingError').textContent = 'Không có địa chỉ giao hàng.';
                document.getElementById('shippingError').classList.remove('d-none');
            }
        }
        
        function fetchShippingRatesByIds(toCityId, toDistrictId, weight) {
            fetch('${pageContext.request.contextPath}/api/goship/rates?toCityId=' + toCityId + '&toDistrictId=' + toDistrictId + '&weight=' + weight)
                .then(function(response) { return response.json(); })
                .then(function(data) {
                    document.getElementById('shippingLoading').classList.add('d-none');
                    
                    if (data.success && data.rates && data.rates.length > 0) {
                        displayShippingRates(data.rates);
                    } else {
                        document.getElementById('shippingError').textContent = data.message || 'Không thể lấy phí vận chuyển.';
                        document.getElementById('shippingError').classList.remove('d-none');
                    }
                })
                .catch(function(error) {
                    document.getElementById('shippingLoading').classList.add('d-none');
                    document.getElementById('shippingError').textContent = 'Lỗi kết nối API: ' + error.message;
                    document.getElementById('shippingError').classList.remove('d-none');
                });
        }
        
        function fetchShippingRatesByAddress(address, weight) {
            var url = '${pageContext.request.contextPath}/api/goship/rates-by-address?address=' + encodeURIComponent(address) + '&weight=' + weight;
            
            fetch(url)
                .then(function(response) { return response.json(); })
                .then(function(data) {
                    document.getElementById('shippingLoading').classList.add('d-none');
                    
                    if (data.success && data.rates && data.rates.length > 0) {
                        displayShippingRates(data.rates);
                    } else {
                        document.getElementById('shippingError').textContent = data.message || 'Không thể lấy phí vận chuyển từ địa chỉ.';
                        document.getElementById('shippingError').classList.remove('d-none');
                    }
                })
                .catch(function(error) {
                    document.getElementById('shippingLoading').classList.add('d-none');
                    document.getElementById('shippingError').textContent = 'Lỗi kết nối API: ' + error.message;
                    document.getElementById('shippingError').classList.remove('d-none');
                });
        }
        
        function displayShippingRates(rates) {
            var container = document.getElementById('shippingRates');
            container.innerHTML = '';
            
            rates.forEach(function(rate, index) {
                var col = document.createElement('div');
                col.className = 'col-md-4 mb-2';
                col.innerHTML = 
                    '<div class="card h-100 shipping-rate-card" style="cursor:pointer" onclick="selectShippingRate(' + rate.price + ', \'' + escapeHtml(rate.carrierName) + '\', this)">' +
                        '<div class="card-body text-center p-2">' +
                            (rate.carrierLogo ? '<img src="' + rate.carrierLogo + '" alt="' + escapeHtml(rate.carrierName) + '" style="height:30px" class="mb-2">' : '') +
                            '<h6 class="mb-1">' + escapeHtml(rate.carrierName) + '</h6>' +
                            '<small class="text-muted">' + escapeHtml(rate.serviceName || '') + '</small>' +
                            '<h5 class="text-primary mb-1">' + formatCurrency(rate.price) + '₫</h5>' +
                            '<small class="text-muted">' + escapeHtml(rate.estimatedDelivery || '') + '</small>' +
                        '</div>' +
                    '</div>';
                container.appendChild(col);
            });
            
            document.getElementById('shippingOptions').classList.remove('d-none');
        }
        
        function escapeHtml(text) {
            if (!text) return '';
            var div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }
        
        function selectShippingRate(price, carrierName, element) {
            document.getElementById('shippingFee').value = price;
            document.getElementById('selectedCarrier').textContent = 'Đơn vị: ' + carrierName;
            
            // Highlight selected
            document.querySelectorAll('.shipping-rate-card').forEach(function(card) {
                card.classList.remove('border-primary');
                card.style.border = '';
            });
            element.classList.add('border-primary');
            element.style.border = '2px solid #0d6efd';
            
            // Hide validation error
            document.getElementById('validationError').classList.add('d-none');
            
            calculateTotal();
        }
        
        function validateForm() {
            var errorDiv = document.getElementById('validationError');
            var hasError = false;
            var errorMessages = [];
            
            // Validate profit margins
            document.querySelectorAll('.product-item').forEach(function(item, index) {
                var minMargin = parseFloat(item.dataset.minMargin) || 30;
                var profitInput = item.querySelector('.profit-margin');
                var profitMargin = parseFloat(profitInput.value) || 0;
                var productName = item.querySelector('h6').textContent;
                
                if (profitMargin < minMargin) {
                    hasError = true;
                    profitInput.classList.add('is-invalid');
                    errorMessages.push(productName + ': % lợi nhuận phải >= ' + minMargin + '%');
                } else {
                    profitInput.classList.remove('is-invalid');
                }
            });
            
            // Validate shipping fee
            var shippingFee = parseFloat(document.getElementById('shippingFee').value) || 0;
            if (shippingFee <= 0) {
                hasError = true;
                errorMessages.push('Vui lòng tính phí ship và chọn đơn vị vận chuyển');
            }
            
            if (hasError) {
                errorDiv.innerHTML = errorMessages.join('<br>');
                errorDiv.classList.remove('d-none');
                return false;
            }
            
            errorDiv.classList.add('d-none');
            return true;
        }
    </script>
</body>
</html>
