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
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/css/bootstrap-datepicker.min.css">
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
                                <div class="product-item" data-index="${loop.index}" data-cost="${item.costPrice != null ? item.costPrice : 0}" data-quantity="${item.quantity}" data-min-margin="${item.minProfitMargin != null ? item.minProfitMargin : 30}">
                                    <div class="row align-items-center mb-3">
                                        <div class="col-md-8">
                                            <h6 class="mb-1">${item.productName}</h6>
                                            <small class="text-muted">SKU: ${item.sku != null ? item.sku : 'N/A'} | Yêu cầu: <strong>${item.quantity}</strong> cái</small>
                                        </div>
                                        <div class="col-md-4 text-end">
                                            <span class="badge bg-info">Giá vốn: <fmt:formatNumber value="${item.costPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span>
                                            <span class="badge bg-warning text-dark">Min: ${item.minProfitMargin != null ? item.minProfitMargin : 30}%</span>
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
                                                <input type="number" class="form-control profit-margin" name="items[${loop.index}][profitMargin]" 
                                                       value="${item.minProfitMargin != null ? item.minProfitMargin : 30}" min="${item.minProfitMargin != null ? item.minProfitMargin : 30}" step="0.01" required onchange="validateAndCalculatePrice(${loop.index})">
                                                <span class="input-group-text">%</span>
                                            </div>
                                            <small class="text-muted">Tối thiểu: ${item.minProfitMargin != null ? item.minProfitMargin : 30}%</small>
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
                                            <input type="text" class="form-control" name="items[${loop.index}][notes]" placeholder="Ghi chú cho sản phẩm này...">
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- Shipping Info (Readonly - Customer đã chọn) -->
                    <div class="card mb-4">
                        <div class="card-header bg-light"><h5 class="mb-0"><i class="fas fa-truck"></i> Thông Tin Vận Chuyển (Khách Hàng Đã Chọn)</h5></div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${not empty rfq.shippingCarrierName}">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label class="form-label">Đơn Vị Vận Chuyển</label>
                                                <input type="text" class="form-control calculated-field" value="${rfq.shippingCarrierName}" readonly>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">Dịch Vụ</label>
                                                <input type="text" class="form-control calculated-field" value="${rfq.shippingServiceName}" readonly>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label class="form-label">Phí Vận Chuyển (Dự Kiến)</label>
                                                <div class="input-group">
                                                    <input type="text" class="form-control calculated-field text-success font-weight-bold" 
                                                           value="<fmt:formatNumber value="${rfq.shippingFee}" maxFractionDigits="0"/>" readonly>
                                                    <span class="input-group-text">₫</span>
                                                </div>
                                                <input type="hidden" name="shippingFee" id="shippingFee" value="${rfq.shippingFee != null ? rfq.shippingFee : 0}">
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">Thời Gian Giao Dự Kiến</label>
                                                <input type="text" class="form-control calculated-field" value="${rfq.estimatedDeliveryDays} ngày" readonly>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="alert alert-info mb-0">
                                        <i class="fas fa-info-circle"></i> Thông tin vận chuyển đã được khách hàng chọn khi tạo RFQ.
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="alert alert-warning mb-0">
                                        <i class="fas fa-exclamation-triangle"></i> Khách hàng chưa chọn đơn vị vận chuyển.
                                    </div>
                                    <input type="hidden" name="shippingFee" id="shippingFee" value="0">
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <!-- Cost Summary -->
                    <div class="card mb-4">
                        <div class="card-header"><h5 class="mb-0"><i class="fas fa-money-bill-wave"></i> Chi Phí & Tổng Kết</h5></div>
                        <div class="card-body">
                            <div class="row mb-3">
                                <div class="col-md-4">
                                    <label class="form-label">Phí Vận Chuyển (₫)</label>
                                    <input type="text" class="form-control calculated-field" 
                                           value="<fmt:formatNumber value="${rfq.shippingFee != null ? rfq.shippingFee : 0}" maxFractionDigits="0"/>" readonly>
                                    <small class="text-muted">Phí do khách hàng đã chọn</small>
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
                                <div class="col-md-6">
                                    <label class="form-label">Báo Giá Có Hiệu Lực Đến <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" name="quotationValidUntil" id="validUntil" required placeholder="dd/mm/yyyy">
                                    <small class="text-muted" id="minDateHint"></small>
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
    </section>
  </div>

  <jsp:include page="includes/admin-footer.jsp" />
</div>

    <script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/jquery/jquery.min.js"></script>
    <script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
    <script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/js/adminlte.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/js/bootstrap-datepicker.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/locales/bootstrap-datepicker.vi.min.js"></script>
    <script>
        // Global variables for date validation
        var minValidDate;
        var baseDateStr;
        
        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            // Lấy ngày yêu cầu giao hoặc ngày đề xuất (nếu có)
            <c:choose>
                <c:when test="${rfq.proposedDeliveryDate != null && rfq.status == 'DateAccepted'}">
                    var baseDate = new Date('<fmt:formatDate value="${rfq.proposedDeliveryDate}" pattern="yyyy-MM-dd"/>');
                    baseDateStr = '<fmt:formatDate value="${rfq.proposedDeliveryDate}" pattern="dd/MM/yyyy"/>';
                </c:when>
                <c:otherwise>
                    var baseDate = new Date('<fmt:formatDate value="${rfq.requestedDeliveryDate}" pattern="yyyy-MM-dd"/>');
                    baseDateStr = '<fmt:formatDate value="${rfq.requestedDeliveryDate}" pattern="dd/MM/yyyy"/>';
                </c:otherwise>
            </c:choose>
            
            // Min date = ngày sau baseDate (ngày yêu cầu/đề xuất + 1)
            minValidDate = new Date(baseDate);
            minValidDate.setDate(minValidDate.getDate() + 1);
            
            // Default date = 7 ngày sau minDate
            var defaultDate = new Date(minValidDate);
            defaultDate.setDate(defaultDate.getDate() + 7);
            
            // Show hint
            var minDateFormatted = ('0' + minValidDate.getDate()).slice(-2) + '/' + ('0' + (minValidDate.getMonth() + 1)).slice(-2) + '/' + minValidDate.getFullYear();
            document.getElementById('minDateHint').innerHTML = 'Tối thiểu sau 1 ngày so với ngày giao hàng (' + baseDateStr + '). Tối thiểu: ' + minDateFormatted;
            
            // Init Bootstrap Datepicker
            $('#validUntil').datepicker({
                format: 'dd/mm/yyyy',
                language: 'vi',
                autoclose: true,
                todayHighlight: true,
                startDate: minValidDate
            }).datepicker('setDate', defaultDate);
            
            // Calculate all prices
            document.querySelectorAll('.product-item').forEach(function(item, index) {
                calculatePrice(index);
            });
        });

        function validateAndCalculatePrice(index) {
            var item = document.querySelector('.product-item[data-index="' + index + '"]');
            var minMargin = parseFloat(item.dataset.minMargin) || 30;
            var profitInput = item.querySelector('.profit-margin');
            var profitMargin = parseFloat(profitInput.value) || 0;
            
            // Validate min profit margin
            if (profitMargin < minMargin) {
                profitInput.value = minMargin;
                profitInput.classList.add('is-invalid');
                alert('% Lợi nhuận không được thấp hơn ngưỡng tối thiểu ' + minMargin + '% đã thiết lập trong quản lý kho!');
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
            
            // Validate valid until date
            var validUntilInput = document.getElementById('validUntil');
            var validUntilStr = validUntilInput.value;
            if (validUntilStr) {
                var parts = validUntilStr.split('/');
                if (parts.length === 3) {
                    var validUntilDate = new Date(parts[2], parts[1] - 1, parts[0]);
                    if (validUntilDate <= minValidDate) {
                        hasError = true;
                        validUntilInput.classList.add('is-invalid');
                        errorMessages.push('Ngày báo giá có hiệu lực phải sau ngày giao hàng (' + baseDateStr + ') tối thiểu 1 ngày');
                    } else {
                        validUntilInput.classList.remove('is-invalid');
                    }
                }
            } else {
                hasError = true;
                validUntilInput.classList.add('is-invalid');
                errorMessages.push('Vui lòng chọn ngày báo giá có hiệu lực');
            }
            
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
