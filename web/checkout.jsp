<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh toán - Pickleball Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="css/elegant-icons.css" type="text/css">
    <link rel="stylesheet" href="css/style.css" type="text/css">
    <style>
        .address-card { border: 2px solid #e1e1e1; padding: 15px; margin-bottom: 10px; cursor: pointer; border-radius: 8px; transition: all 0.2s; }
        .address-card.selected { border-color: #e53637; background: #fff5f5; }
        .address-card:hover { border-color: #e53637; }
        .shipping-option { border: 1px solid #e1e1e1; padding: 12px; margin-bottom: 8px; cursor: pointer; border-radius: 6px; transition: all 0.2s; }
        .shipping-option.selected { border-color: #e53637; background: #fff5f5; }
        .shipping-option:hover { border-color: #e53637; }
        .shipping-option .carrier-logo { height: 24px; margin-right: 10px; vertical-align: middle; }
        .payment-option { border: 1px solid #e1e1e1; padding: 15px; margin-bottom: 10px; cursor: pointer; border-radius: 8px; display: flex; align-items: center; transition: all 0.2s; }
        .payment-option.selected { border-color: #e53637; background: #fff5f5; }
        .payment-option:hover { border-color: #e53637; }
        .payment-option img { height: 30px; margin-right: 15px; }
        .voucher-section { background: #f9f9f9; padding: 15px; border-radius: 8px; margin-bottom: 15px; }
        .voucher-input { display: flex; gap: 10px; }
        .voucher-input input { flex: 1; border: 1px solid #ddd; padding: 10px; border-radius: 4px; }
        .voucher-success { color: #28a745; font-size: 14px; margin-top: 8px; }
        .voucher-error { color: #dc3545; font-size: 14px; margin-top: 8px; }
        .checkout__order { background: #f5f5f5; padding: 30px; border-radius: 8px; }
        .order__title { font-weight: 700; margin-bottom: 20px; }
        .checkout__total__products li { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #e1e1e1; font-size: 14px; }
        .checkout__total__all li { display: flex; justify-content: space-between; padding: 12px 0; }
        .checkout__total__all li:last-child { font-weight: 700; font-size: 18px; color: #e53637; border-top: 2px solid #e53637; margin-top: 10px; padding-top: 15px; }
        .btn-checkout { width: 100%; padding: 15px; font-size: 16px; font-weight: 700; }
        .badge-default { background: #e53637; color: white; font-size: 11px; padding: 3px 8px; border-radius: 3px; }
    </style>
</head>
<body>
    <%@include file="header.jsp" %>

    <section class="breadcrumb-option">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="breadcrumb__text">
                        <h4>Thanh toán</h4>
                        <div class="breadcrumb__links">
                            <a href="home">Trang chủ</a>
                            <a href="cart">Giỏ hàng</a>
                            <span>Thanh toán</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="checkout spad">
        <div class="container">
            <c:if test="${not empty error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fa fa-exclamation-circle"></i> ${error}
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                </div>
            </c:if>
            
            <form action="checkout" method="post" id="checkoutForm">
                <div class="row">
                    <div class="col-lg-8">
                        <!-- Shipping Address -->
                        <h6 class="checkout__title">
                            <i class="fa fa-map-marker"></i> Địa chỉ giao hàng
                            <a href="profile?tab=addresses&redirect=checkout" class="btn btn-sm btn-outline-primary float-right" style="font-size: 12px;">
                                <i class="fa fa-plus"></i> Thêm địa chỉ
                            </a>
                        </h6>
                        <c:choose>
                            <c:when test="${empty addresses}">
                                <div class="alert alert-warning">
                                    <i class="fa fa-exclamation-triangle"></i> 
                                    <strong>Bạn chưa có địa chỉ giao hàng!</strong><br>
                                    Vui lòng thêm địa chỉ để chúng tôi có thể tính phí vận chuyển và giao hàng cho bạn.
                                    <br><br>
                                    <a href="profile?tab=addresses&redirect=checkout" class="btn btn-primary">
                                        <i class="fa fa-plus"></i> Thêm địa chỉ ngay
                                    </a>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="address-list mb-4">
                                    <c:forEach var="addr" items="${addresses}">
                                        <div class="address-card ${addr['default'] ? 'selected' : ''}" 
                                             data-address-id="${addr.addressID}"
                                             data-city="${addr.city}"
                                             data-district="${addr.district}"
                                             onclick="selectAddress(this)">
                                            <input type="radio" name="addressId" value="${addr.addressID}" 
                                                   ${addr['default'] ? 'checked' : ''} style="display:none;">
                                            <div class="d-flex justify-content-between align-items-start">
                                                <div>
                                                    <strong>${addr.recipientName}</strong> 
                                                    <span class="text-muted">| ${addr.phone}</span>
                                                    <c:if test="${addr['default']}">
                                                        <span class="badge-default ml-2">Mặc định</span>
                                                    </c:if>
                                                </div>
                                            </div>
                                            <div class="mt-2 text-muted" style="font-size: 14px;">
                                                <i class="fa fa-home"></i> ${addr.fullAddress}
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <!-- Shipping Method -->
                        <h6 class="checkout__title"><i class="fa fa-truck"></i> Phương thức vận chuyển</h6>
                        <div class="shipping-options mb-4" id="shippingOptions">
                            <c:choose>
                                <c:when test="${not empty shippingRates}">
                                    <c:forEach var="rate" items="${shippingRates}" varStatus="status">
                                        <div class="shipping-option ${status.first ? 'selected' : ''}" 
                                             data-price="${rate.basePrice}" 
                                             data-rate-id="${not empty rate.carrierId ? rate.carrierId : rate.rateID}"
                                             onclick="selectShipping(this)">
                                            <input type="radio" name="shippingFee" value="${rate.basePrice}" 
                                                   ${status.first ? 'checked' : ''} style="display:none;">
                                            <input type="hidden" class="carrier-id" value="${not empty rate.carrierId ? rate.carrierId : rate.rateID}">
                                            <div class="d-flex justify-content-between align-items-center">
                                                <div>
                                                    <c:if test="${not empty rate.carrierLogo}">
                                                        <img src="${rate.carrierLogo}" alt="${rate.carrierShortName}" class="carrier-logo">
                                                    </c:if>
                                                    <strong>${not empty rate.carrierName ? rate.carrierName : (not empty rate.carrier ? rate.carrier.carrierName : 'Vận chuyển')}</strong>
                                                    <span class="text-muted">- ${rate.serviceName}</span>
                                                    <br><small class="text-muted"><i class="fa fa-clock-o"></i> ${rate.estimatedDelivery}</small>
                                                </div>
                                                <strong class="text-danger">
                                                    <fmt:formatNumber value="${rate.basePrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                                </strong>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="shipping-option selected" data-price="30000" data-rate-id="0" onclick="selectShipping(this)">
                                        <input type="radio" name="shippingFee" value="30000" checked style="display:none;">
                                        <input type="hidden" class="carrier-id" value="0">
                                        <div class="d-flex justify-content-between align-items-center">
                                            <div>
                                                <strong>Giao hàng tiêu chuẩn</strong>
                                                <br><small class="text-muted"><i class="fa fa-clock-o"></i> 2-3 ngày</small>
                                            </div>
                                            <strong class="text-danger">30,000đ</strong>
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <input type="hidden" name="carrierId" id="selectedCarrierId" value="${not empty shippingRates ? (not empty shippingRates[0].carrierId ? shippingRates[0].carrierId : shippingRates[0].rateID) : '0'}">
                        <input type="hidden" name="carrierName" id="selectedCarrierName" value="${not empty shippingRates ? shippingRates[0].carrierName : 'Giao Hàng Tiết Kiệm'}">
                        <input type="hidden" name="estimatedDelivery" id="selectedEstimatedDelivery" value="${not empty shippingRates ? shippingRates[0].estimatedDelivery : '2-3 ngày'}">

                        <!-- Payment Method -->
                        <h6 class="checkout__title"><i class="fa fa-credit-card"></i> Phương thức thanh toán</h6>
                        <div class="payment-options mb-4">
                            <div class="payment-option selected" onclick="selectPayment(this, 'COD')">
                                <input type="radio" name="paymentMethod" value="COD" checked style="display:none;">
                                <i class="fa fa-money fa-2x mr-3" style="color:#28a745;"></i>
                                <div>
                                    <strong>Thanh toán khi nhận hàng (COD)</strong>
                                    <br><small class="text-muted">Thanh toán bằng tiền mặt khi nhận hàng</small>
                                </div>
                            </div>
                            <div class="payment-option" onclick="selectPayment(this, 'VNPay')">
                                <input type="radio" name="paymentMethod" value="VNPay" style="display:none;">
                                <img src="https://vnpay.vn/s1/statics.vnpay.vn/2023/9/06ncktiwd6dc1694418196384.png" alt="VNPay">
                                <div>
                                    <strong>VNPay</strong>
                                    <br><small class="text-muted">Thanh toán qua VNPay (ATM/Visa/MasterCard/QR)</small>
                                </div>
                            </div>
                        </div>

                        <!-- Notes -->
                        <h6 class="checkout__title"><i class="fa fa-pencil"></i> Ghi chú đơn hàng</h6>
                        <div class="checkout__input mb-4">
                            <textarea name="notes" class="form-control" rows="3" 
                                placeholder="Ghi chú về đơn hàng, ví dụ: thời gian hay chỉ dẫn địa điểm giao hàng chi tiết hơn."></textarea>
                        </div>
                    </div>

                    <div class="col-lg-4">
                        <div class="checkout__order">
                            <h4 class="order__title"><i class="fa fa-shopping-bag"></i> Đơn hàng của bạn</h4>
                            
                            <!-- Cart Items -->
                            <div class="checkout__order__products" style="font-weight:600; border-bottom: 2px solid #ddd; padding-bottom: 10px; margin-bottom: 10px;">
                                Sản phẩm <span style="float:right;">Thành tiền</span>
                            </div>
                            <ul class="checkout__total__products" style="list-style: none; padding: 0; margin: 0 0 20px 0;">
                                <c:forEach var="item" items="${cartItems}" varStatus="status">
                                    <li>
                                        <span style="flex:1;">${status.count}. ${item.productName} 
                                            <c:if test="${not empty item.variantName}">
                                                <small class="text-muted">(${item.variantName})</small>
                                            </c:if>
                                            <strong>x${item.quantity}</strong>
                                        </span>
                                        <span><fmt:formatNumber value="${item.total}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ</span>
                                    </li>
                                </c:forEach>
                            </ul>

                            <!-- Voucher -->
                            <div class="voucher-section">
                                <h6 style="margin-bottom: 10px;"><i class="fa fa-ticket"></i> Mã giảm giá</h6>
                                <div class="voucher-input">
                                    <input type="text" id="voucherCode" name="voucherCode" placeholder="Nhập mã voucher">
                                    <button type="button" class="site-btn" onclick="applyVoucher()" style="padding: 10px 20px;">Áp dụng</button>
                                </div>
                                <div id="voucherMessage"></div>
                                
                                <!-- Available vouchers hint -->
                                <c:if test="${not empty vouchers}">
                                    <div class="mt-2">
                                        <small class="text-muted">Mã có sẵn: </small>
                                        <c:forEach var="v" items="${vouchers}" varStatus="vs">
                                            <c:if test="${vs.index < 3}">
                                                <span class="badge badge-secondary" style="cursor:pointer; margin: 2px;" 
                                                      onclick="$('#voucherCode').val('${v.voucherCode}');">${v.voucherCode}</span>
                                            </c:if>
                                        </c:forEach>
                                    </div>
                                </c:if>
                            </div>

                            <!-- Totals -->
                            <ul class="checkout__total__all" style="list-style: none; padding: 0; margin: 0;">
                                <li>
                                    Tạm tính 
                                    <span id="subtotalDisplay">
                                        <fmt:formatNumber value="${subtotal}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                    </span>
                                </li>
                                <li>
                                    Phí vận chuyển 
                                    <span id="shippingDisplay">
                                        <c:choose>
                                            <c:when test="${not empty shippingRates}">
                                                <fmt:formatNumber value="${shippingRates[0].basePrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                            </c:when>
                                            <c:otherwise>30,000đ</c:otherwise>
                                        </c:choose>
                                    </span>
                                </li>
                                <li id="voucherRow" style="display:none; color: #28a745;">
                                    Giảm giá voucher 
                                    <span id="voucherDisplay">-0đ</span>
                                </li>
                                <li>
                                    Tổng cộng 
                                    <span id="totalDisplay">
                                        <c:choose>
                                            <c:when test="${not empty shippingRates}">
                                                <fmt:formatNumber value="${subtotal + shippingRates[0].basePrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                            </c:when>
                                            <c:otherwise>
                                                <fmt:formatNumber value="${subtotal + 30000}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                </li>
                            </ul>

                            <input type="hidden" id="subtotalValue" value="${subtotal}">
                            <input type="hidden" id="voucherDiscount" name="voucherDiscount" value="0">
                            
                            <button type="submit" class="site-btn btn-checkout" ${empty addresses ? 'disabled' : ''}>
                                <i class="fa fa-check-circle"></i> ĐẶT HÀNG
                            </button>
                            
                            <c:if test="${empty addresses}">
                                <p class="text-danger text-center mt-2" style="font-size: 13px;">
                                    <i class="fa fa-exclamation-triangle"></i> Vui lòng thêm địa chỉ giao hàng để đặt hàng
                                </p>
                            </c:if>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </section>

    <%@include file="footer.jsp"%>

    <script src="js/jquery-3.3.1.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <script>
        // Hide preloader when page loads
        $(window).on('load', function() {
            $(".loader").fadeOut();
            $("#preloder").delay(200).fadeOut("slow");
        });
        // Fallback: hide preloader after 2 seconds anyway
        setTimeout(function() {
            $(".loader").fadeOut();
            $("#preloder").fadeOut("slow");
        }, 2000);
        
        var subtotal = parseFloat($('#subtotalValue').val()) || 0;
        var shippingFee = parseFloat($('input[name="shippingFee"]:checked').val()) || 30000;
        var voucherDiscount = 0;

        function selectAddress(el) {
            $('.address-card').removeClass('selected');
            $(el).addClass('selected');
            $(el).find('input[type="radio"]').prop('checked', true);
            
            // Load shipping rates from Goship API for selected address
            var city = $(el).data('city');
            var district = $(el).data('district');
            loadShippingRatesFromGoship(city, district);
        }
        
        // Cache for city/district IDs
        var cityCache = {};
        var districtCache = {};
        
        function loadShippingRatesFromGoship(cityName, districtName) {
            var $shippingOptions = $('#shippingOptions');
            $shippingOptions.html('<div class="text-center p-3"><i class="fa fa-spinner fa-spin fa-2x"></i><br><small class="text-muted">Đang lấy phí vận chuyển từ Goship...</small></div>');
            
            // First get city ID
            getCityId(cityName, function(cityId) {
                if (!cityId) {
                    showDefaultShippingRates('Không tìm thấy thành phố: ' + cityName);
                    return;
                }
                
                // Then get district ID
                getDistrictId(cityId, districtName, function(districtId) {
                    if (!districtId) {
                        showDefaultShippingRates('Không tìm thấy quận/huyện: ' + districtName);
                        return;
                    }
                    
                    // Finally get shipping rates
                    $.ajax({
                        url: 'api/goship/rates',
                        method: 'GET',
                        data: { 
                            toCityId: cityId, 
                            toDistrictId: districtId,
                            weight: 500
                        },
                        dataType: 'json',
                        timeout: 10000,
                        success: function(data) {
                            if (data.success && data.rates && data.rates.length > 0) {
                                renderShippingRates(data.rates);
                            } else {
                                showDefaultShippingRates(data.message || 'Không lấy được phí vận chuyển');
                            }
                        },
                        error: function() {
                            showDefaultShippingRates('Lỗi kết nối Goship API');
                        }
                    });
                });
            });
        }
        
        function getCityId(cityName, callback) {
            // Check cache
            if (cityCache[cityName]) {
                callback(cityCache[cityName]);
                return;
            }
            
            $.ajax({
                url: 'api/goship/cities',
                method: 'GET',
                dataType: 'json',
                timeout: 5000,
                success: function(data) {
                    if (data.success && data.cities) {
                        for (var i = 0; i < data.cities.length; i++) {
                            var city = data.cities[i];
                            var name = city.name.toLowerCase();
                            if (name.indexOf(cityName.toLowerCase()) >= 0 || 
                                cityName.toLowerCase().indexOf(name) >= 0) {
                                cityCache[cityName] = city.id;
                                callback(city.id);
                                return;
                            }
                        }
                    }
                    callback(null);
                },
                error: function() {
                    callback(null);
                }
            });
        }
        
        function getDistrictId(cityId, districtName, callback) {
            var cacheKey = cityId + '_' + districtName;
            if (districtCache[cacheKey]) {
                callback(districtCache[cacheKey]);
                return;
            }
            
            $.ajax({
                url: 'api/goship/districts',
                method: 'GET',
                data: { cityId: cityId },
                dataType: 'json',
                timeout: 5000,
                success: function(data) {
                    if (data.success && data.districts) {
                        for (var i = 0; i < data.districts.length; i++) {
                            var district = data.districts[i];
                            var name = district.name.toLowerCase();
                            if (name.indexOf(districtName.toLowerCase()) >= 0 || 
                                districtName.toLowerCase().indexOf(name) >= 0) {
                                districtCache[cacheKey] = district.id;
                                callback(district.id);
                                return;
                            }
                        }
                    }
                    callback(null);
                },
                error: function() {
                    callback(null);
                }
            });
        }
        
        function renderShippingRates(rates) {
            var html = '';
            rates.forEach(function(rate, index) {
                var selected = index === 0 ? 'selected' : '';
                var checked = index === 0 ? 'checked' : '';
                html += '<div class="shipping-option ' + selected + '" data-price="' + rate.price + '" data-rate-id="' + rate.id + '" onclick="selectShipping(this)">';
                html += '<input type="radio" name="shippingFee" value="' + rate.price + '" ' + checked + ' style="display:none;">';
                html += '<input type="hidden" class="carrier-id" value="' + rate.id + '">';
                html += '<div class="d-flex justify-content-between align-items-center">';
                html += '<div>';
                if (rate.carrierLogo) {
                    html += '<img src="' + rate.carrierLogo + '" class="carrier-logo" onerror="this.style.display=\'none\'">';
                }
                html += '<strong>' + rate.carrierName + '</strong>';
                html += '<span class="text-muted"> - ' + rate.serviceName + '</span>';
                html += '<br><small class="text-muted"><i class="fa fa-clock-o"></i> ' + rate.estimatedDelivery + '</small>';
                html += '</div>';
                html += '<strong class="text-danger">' + formatCurrency(rate.price) + 'đ</strong>';
                html += '</div></div>';
            });
            
            $('#shippingOptions').html(html);
            
            // Update shipping fee with first rate
            if (rates.length > 0) {
                shippingFee = rates[0].price;
                $('#selectedCarrierId').val(rates[0].id);
                $('#selectedCarrierName').val(rates[0].carrierName);
                $('#selectedEstimatedDelivery').val(rates[0].estimatedDelivery);
                updateTotal();
            }
        }
        
        function showDefaultShippingRates(message) {
            console.log('[Checkout] Using default rates: ' + message);
            var html = '';
            html += '<div class="alert alert-info mb-2" style="font-size:12px;"><i class="fa fa-info-circle"></i> ' + message + '. Sử dụng giá mặc định.</div>';
            
            var defaultRates = [
                { id: '1', carrierName: 'Giao Hàng Tiết Kiệm', serviceName: 'Giao Chuẩn', price: 30000, estimatedDelivery: '3-5 ngày' },
                { id: '2', carrierName: 'Giao Hàng Nhanh', serviceName: 'Giao Nhanh', price: 45000, estimatedDelivery: '1-2 ngày' },
                { id: '3', carrierName: 'Viettel Post', serviceName: 'Chuyển phát thường', price: 25000, estimatedDelivery: '3-5 ngày' }
            ];
            
            defaultRates.forEach(function(rate, index) {
                var selected = index === 0 ? 'selected' : '';
                var checked = index === 0 ? 'checked' : '';
                html += '<div class="shipping-option ' + selected + '" data-price="' + rate.price + '" data-rate-id="' + rate.id + '" onclick="selectShipping(this)">';
                html += '<input type="radio" name="shippingFee" value="' + rate.price + '" ' + checked + ' style="display:none;">';
                html += '<input type="hidden" class="carrier-id" value="' + rate.id + '">';
                html += '<div class="d-flex justify-content-between align-items-center">';
                html += '<div><strong>' + rate.carrierName + '</strong><span class="text-muted"> - ' + rate.serviceName + '</span>';
                html += '<br><small class="text-muted"><i class="fa fa-clock-o"></i> ' + rate.estimatedDelivery + '</small></div>';
                html += '<strong class="text-danger">' + formatCurrency(rate.price) + 'đ</strong>';
                html += '</div></div>';
            });
            
            $('#shippingOptions').html(html);
            shippingFee = 30000;
            $('#selectedCarrierId').val('1');
            updateTotal();
        }
        
        // Auto-load shipping rates for default address on page load
        $(document).ready(function() {
            var $selectedAddress = $('.address-card.selected');
            if ($selectedAddress.length > 0) {
                var city = $selectedAddress.data('city');
                var district = $selectedAddress.data('district');
                if (city && district) {
                    loadShippingRatesFromGoship(city, district);
                }
            }
        });

        function selectShipping(el) {
            $('.shipping-option').removeClass('selected');
            $(el).addClass('selected');
            $(el).find('input[type="radio"]').prop('checked', true);
            shippingFee = parseFloat($(el).data('price')) || 30000;
            
            // Update carrier ID, name, and estimated delivery
            var carrierId = $(el).find('.carrier-id').val();
            var carrierName = $(el).find('strong').first().text();
            var estimatedDelivery = $(el).find('small').text().replace(/.*\s/, ''); // Get delivery time
            
            $('#selectedCarrierId').val(carrierId);
            $('#selectedCarrierName').val(carrierName);
            $('#selectedEstimatedDelivery').val(estimatedDelivery);
            
            updateTotal();
        }

        function selectPayment(el, method) {
            $('.payment-option').removeClass('selected');
            $(el).addClass('selected');
            $(el).find('input[type="radio"]').prop('checked', true);
        }

        function applyVoucher() {
            var code = $('#voucherCode').val().trim();
            if (!code) {
                $('#voucherMessage').html('<span class="voucher-error"><i class="fa fa-times-circle"></i> Vui lòng nhập mã voucher</span>');
                return;
            }
            
            // Show loading
            $('#voucherMessage').html('<span class="text-muted"><i class="fa fa-spinner fa-spin"></i> Đang kiểm tra...</span>');
            
            $.ajax({
                url: 'api/voucher',
                method: 'POST',
                data: { voucherCode: code, subtotal: subtotal },
                dataType: 'json',
                success: function(data) {
                    if (data.success) {
                        voucherDiscount = parseFloat(data.discount) || 0;
                        $('#voucherDiscount').val(voucherDiscount);
                        $('#voucherRow').show();
                        $('#voucherDisplay').text('-' + formatCurrency(voucherDiscount) + 'đ');
                        $('#voucherMessage').html('<span class="voucher-success"><i class="fa fa-check-circle"></i> ' + data.message + '</span>');
                        updateTotal();
                    } else {
                        voucherDiscount = 0;
                        $('#voucherDiscount').val(0);
                        $('#voucherRow').hide();
                        $('#voucherMessage').html('<span class="voucher-error"><i class="fa fa-times-circle"></i> ' + data.message + '</span>');
                        updateTotal();
                    }
                },
                error: function() {
                    $('#voucherMessage').html('<span class="voucher-error"><i class="fa fa-times-circle"></i> Lỗi kết nối, vui lòng thử lại</span>');
                }
            });
        }

        function updateTotal() {
            var total = subtotal + shippingFee - voucherDiscount;
            if (total < 0) total = 0;
            $('#shippingDisplay').text(formatCurrency(shippingFee) + 'đ');
            $('#totalDisplay').text(formatCurrency(total) + 'đ');
        }

        function formatCurrency(num) {
            return Math.round(num).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        }
        
        // Form validation
        $('#checkoutForm').on('submit', function(e) {
            if (!$('input[name="addressId"]:checked').val()) {
                e.preventDefault();
                alert('Vui lòng chọn địa chỉ giao hàng');
                return false;
            }
            
            // Show loading on button
            $(this).find('button[type="submit"]').prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> Đang xử lý...');
        });
    </script>
</body>
</html>
