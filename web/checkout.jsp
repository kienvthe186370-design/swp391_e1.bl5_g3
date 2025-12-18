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
        /* Section Cards - Compact Display */
        .checkout-section {
            border: 1px solid #e1e1e1;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
            cursor: pointer;
            transition: all 0.2s;
            background: #fff;
        }
        .checkout-section:hover {
            border-color: #e53637;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }
        .checkout-section .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 8px;
        }
        .checkout-section .section-title {
            font-weight: 600;
            color: #333;
            font-size: 14px;
        }
        .checkout-section .section-action {
            color: #e53637;
            font-size: 13px;
        }
        .checkout-section .section-content {
            color: #666;
            font-size: 14px;
        }
        .checkout-section .section-content strong {
            color: #333;
        }
        .checkout-section.empty {
            border-style: dashed;
            text-align: center;
            color: #999;
        }
        
        /* Modal Styles */
        .checkout-modal .modal-header {
            border-bottom: 1px solid #eee;
            padding: 15px 20px;
        }
        .checkout-modal .modal-title {
            font-weight: 700;
            font-size: 16px;
        }
        .checkout-modal .modal-body {
            padding: 20px;
            max-height: 60vh;
            overflow-y: auto;
        }
        
        /* Address Card in Modal */
        .address-card {
            border: 2px solid #e1e1e1;
            padding: 15px;
            margin-bottom: 10px;
            cursor: pointer;
            border-radius: 8px;
            transition: all 0.2s;
        }
        .address-card.selected {
            border-color: #e53637;
            background: #fff5f5;
        }
        .address-card:hover {
            border-color: #e53637;
        }
        .badge-default {
            background: #e53637;
            color: white;
            font-size: 11px;
            padding: 3px 8px;
            border-radius: 3px;
        }
        
        /* Shipping Option in Modal */
        .shipping-option {
            border: 1px solid #e1e1e1;
            padding: 12px;
            margin-bottom: 8px;
            cursor: pointer;
            border-radius: 6px;
            transition: all 0.2s;
        }
        .shipping-option.selected {
            border-color: #e53637;
            background: #fff5f5;
        }
        .shipping-option:hover {
            border-color: #e53637;
        }
        .shipping-option .carrier-logo {
            height: 24px;
            margin-right: 10px;
            vertical-align: middle;
        }
        
        /* Payment Options */
        .payment-option {
            border: 1px solid #e1e1e1;
            padding: 15px;
            margin-bottom: 10px;
            cursor: pointer;
            border-radius: 8px;
            display: flex;
            align-items: center;
            transition: all 0.2s;
        }
        .payment-option.selected {
            border-color: #e53637;
            background: #fff5f5;
        }
        .payment-option:hover {
            border-color: #e53637;
        }
        .payment-option img {
            height: 30px;
            margin-right: 15px;
        }
        
        /* Voucher Section */
        .voucher-section {
            background: #f9f9f9;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 15px;
        }
        .voucher-input {
            display: flex;
            gap: 10px;
        }
        .voucher-input input {
            flex: 1;
            border: 1px solid #ddd;
            padding: 10px;
            border-radius: 4px;
        }
        .voucher-success {
            color: #28a745;
            font-size: 14px;
            margin-top: 8px;
        }
        .voucher-error {
            color: #dc3545;
            font-size: 14px;
            margin-top: 8px;
        }
        
        /* Order Summary */
        .checkout__order {
            background: #f5f5f5;
            padding: 30px;
            border-radius: 8px;
        }
        .order__title {
            font-weight: 700;
            margin-bottom: 20px;
        }
        .checkout__total__products li {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #e1e1e1;
            font-size: 14px;
        }
        .checkout__total__all li {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
        }
        .checkout__total__all li:last-child {
            font-weight: 700;
            font-size: 18px;
            color: #e53637;
            border-top: 2px solid #e53637;
            margin-top: 10px;
            padding-top: 15px;
        }
        .btn-checkout {
            width: 100%;
            padding: 15px;
            font-size: 16px;
            font-weight: 700;
        }
        
        /* Loading Spinner */
        .loading-spinner {
            text-align: center;
            padding: 30px;
        }
        .loading-spinner i {
            font-size: 24px;
            color: #e53637;
        }
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
                            <c:choose>
                                <c:when test="${buyNowMode}">
                                    <a href="product-detail?id=${buyNowItem.productId}">Sản phẩm</a>
                                </c:when>
                                <c:otherwise>
                                    <a href="cart">Giỏ hàng</a>
                                </c:otherwise>
                            </c:choose>
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
                        <!-- Address Section - Compact -->
                        <div class="checkout-section ${empty addresses ? 'empty' : ''}" onclick="openAddressModal()" id="addressSection">
                            <c:choose>
                                <c:when test="${empty addresses}">
                                    <i class="fa fa-map-marker fa-2x mb-2"></i>
                                    <div>Chưa có địa chỉ giao hàng</div>
                                    <small class="text-muted">Nhấn để thêm địa chỉ</small>
                                </c:when>
                                <c:otherwise>
                                    <div class="section-header">
                                        <span class="section-title"><i class="fa fa-map-marker"></i> Địa chỉ giao hàng</span>
                                        <span class="section-action">Thay đổi <i class="fa fa-chevron-right"></i></span>
                                    </div>
                                    <div class="section-content" id="selectedAddressDisplay">
                                        <c:forEach var="addr" items="${addresses}">
                                            <c:if test="${addr['default']}">
                                                <strong>${addr.recipientName}</strong> | ${addr.phone}
                                                <c:if test="${addr['default']}">
                                                    <span class="badge-default ml-1">Mặc định</span>
                                                </c:if>
                                                <br>
                                                <span class="text-muted"><i class="fa fa-home"></i> ${addr.fullAddress}</span>
                                            </c:if>
                                        </c:forEach>
                                        <!-- Fallback if no default -->
                                        <c:if test="${not empty addresses}">
                                            <c:set var="hasDefault" value="false"/>
                                            <c:forEach var="addr" items="${addresses}">
                                                <c:if test="${addr['default']}"><c:set var="hasDefault" value="true"/></c:if>
                                            </c:forEach>
                                            <c:if test="${not hasDefault}">
                                                <c:set var="firstAddr" value="${addresses[0]}"/>
                                                <strong>${firstAddr.recipientName}</strong> | ${firstAddr.phone}
                                                <br>
                                                <span class="text-muted"><i class="fa fa-home"></i> ${firstAddr.fullAddress}</span>
                                            </c:if>
                                        </c:if>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <input type="hidden" name="addressId" id="selectedAddressId" value="${not empty addresses ? (addresses[0]['default'] ? addresses[0].addressID : addresses[0].addressID) : ''}">

                        <!-- Shipping Section - Compact -->
                        <div class="checkout-section" onclick="openShippingModal()" id="shippingSection">
                            <div class="section-header">
                                <span class="section-title"><i class="fa fa-truck"></i> Phương thức vận chuyển</span>
                                <span class="section-action">Thay đổi <i class="fa fa-chevron-right"></i></span>
                            </div>
                            <div class="section-content" id="selectedShippingDisplay">
                                <c:choose>
                                    <c:when test="${not empty shippingRates}">
                                        <strong>${shippingRates[0].carrierName}</strong> - ${shippingRates[0].serviceName}
                                        <br>
                                        <span class="text-muted"><i class="fa fa-clock-o"></i> ${shippingRates[0].estimatedDelivery}</span>
                                        <span class="text-danger float-right"><fmt:formatNumber value="${shippingRates[0].basePrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted">Chọn địa chỉ để xem phí vận chuyển</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <input type="hidden" name="shippingFee" id="selectedShippingFee" value="${not empty shippingRates ? shippingRates[0].basePrice : 30000}">
                        <input type="hidden" name="carrierId" id="selectedCarrierId" value="${not empty shippingRates ? (not empty shippingRates[0].carrierId ? shippingRates[0].carrierId : shippingRates[0].rateID) : '0'}">
                        <input type="hidden" name="carrierName" id="selectedCarrierName" value="${not empty shippingRates ? shippingRates[0].carrierName : 'Giao Hàng Tiết Kiệm'}">
                        <input type="hidden" name="estimatedDelivery" id="selectedEstimatedDelivery" value="${not empty shippingRates ? shippingRates[0].estimatedDelivery : '2-3 ngày'}">

                        <!-- Payment Method -->
                        <h6 class="checkout__title mt-4"><i class="fa fa-credit-card"></i> Phương thức thanh toán</h6>
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
                            
                            <!-- Cart Items / Buy Now Item -->
                            <div class="checkout__order__products" style="font-weight:600; border-bottom: 2px solid #ddd; padding-bottom: 10px; margin-bottom: 10px;">
                                Sản phẩm <span style="float:right;">Thành tiền</span>
                            </div>
                            <ul class="checkout__total__products" style="list-style: none; padding: 0; margin: 0 0 20px 0;">
                                <c:choose>
                                    <%-- Chế độ Mua ngay --%>
                                    <c:when test="${buyNowMode}">
                                        <li>
                                            <span style="flex:1;">1. ${buyNowItem.productName} 
                                                <c:if test="${not empty buyNowItem.variantName}">
                                                    <small class="text-muted">(${buyNowItem.variantName})</small>
                                                </c:if>
                                                <strong>x${buyNowItem.quantity}</strong>
                                            </span>
                                            <span><fmt:formatNumber value="${buyNowItem.total}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ</span>
                                        </li>
                                    </c:when>
                                    <%-- Chế độ checkout từ giỏ hàng --%>
                                    <c:otherwise>
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
                                    </c:otherwise>
                                </c:choose>
                            </ul>
                            
                            <%-- Hidden field để đánh dấu chế độ mua ngay --%>
                            <c:if test="${buyNowMode}">
                                <input type="hidden" name="buyNowMode" value="true">
                                <input type="hidden" name="buyNowProductId" value="${buyNowItem.productId}">
                                <input type="hidden" name="buyNowVariantId" value="${buyNowItem.variantId}">
                                <input type="hidden" name="buyNowQuantity" value="${buyNowItem.quantity}">
                                <input type="hidden" name="buyNowPrice" value="${buyNowItem.price}">
                            </c:if>

                            <!-- Voucher Section -->
                            <div class="voucher-section">
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <h6 style="margin: 0;"><i class="fa fa-ticket"></i> Mã giảm giá</h6>
                                    <a href="javascript:void(0)" onclick="openVoucherModal()" style="font-size: 13px; color: #e53637;">
                                        Xem voucher <i class="fa fa-chevron-right"></i>
                                    </a>
                                </div>
                                
                                <!-- Selected Voucher Display -->
                                <div id="selectedVoucherDisplay" style="display: none;" class="mb-2">
                                    <div class="d-flex align-items-center justify-content-between p-2" style="background: #e8f5e9; border-radius: 4px; border: 1px solid #4caf50;">
                                        <div>
                                            <i class="fa fa-check-circle text-success"></i>
                                            <strong id="selectedVoucherCode"></strong>
                                            <span id="selectedVoucherDesc" class="text-muted" style="font-size: 12px;"></span>
                                        </div>
                                        <button type="button" class="btn btn-sm btn-link text-danger" onclick="removeVoucher()">
                                            <i class="fa fa-times"></i>
                                        </button>
                                    </div>
                                </div>
                                
                                <!-- Private Voucher Input -->
                                <div id="voucherInputSection">
                                    <div class="voucher-input">
                                        <input type="text" id="voucherCode" name="voucherCode" placeholder="Nhập mã voucher riêng">
                                        <button type="button" class="btn btn-dark" onclick="applyVoucher()" style="padding: 10px 15px; white-space: nowrap;">
                                            Áp dụng
                                        </button>
                                    </div>
                                    <small class="text-muted"><i class="fa fa-lock"></i> Dành cho mã voucher riêng tư</small>
                                </div>
                                <div id="voucherMessage"></div>
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

    <!-- Address Modal -->
    <div class="modal fade checkout-modal" id="addressModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fa fa-map-marker"></i> Chọn địa chỉ giao hàng</h5>
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                </div>
                <div class="modal-body">
                    <c:choose>
                        <c:when test="${empty addresses}">
                            <div class="text-center py-4">
                                <i class="fa fa-map-marker fa-3x text-muted mb-3"></i>
                                <p>Bạn chưa có địa chỉ giao hàng nào</p>
                                <a href="profile?tab=addresses&redirect=checkout" class="btn btn-primary">
                                    <i class="fa fa-plus"></i> Thêm địa chỉ mới
                                </a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="address-list" id="addressList">
                                <c:forEach var="addr" items="${addresses}">
                                    <div class="address-card ${addr['default'] ? 'selected' : ''}" 
                                         data-address-id="${addr.addressID}"
                                         data-city="${addr.city}"
                                         data-district="${addr.district}"
                                         data-name="${addr.recipientName}"
                                         data-phone="${addr.phone}"
                                         data-full-address="${addr.fullAddress}"
                                         data-is-default="${addr['default']}"
                                         onclick="selectAddressInModal(this)">
                                        <div class="d-flex justify-content-between align-items-start">
                                            <div>
                                                <strong>${addr.recipientName}</strong> 
                                                <span class="text-muted">| ${addr.phone}</span>
                                                <c:if test="${addr['default']}">
                                                    <span class="badge-default ml-2">Mặc định</span>
                                                </c:if>
                                            </div>
                                            <i class="fa fa-check-circle text-danger" style="display: ${addr['default'] ? 'inline' : 'none'}; font-size: 20px;"></i>
                                        </div>
                                        <div class="mt-2 text-muted" style="font-size: 14px;">
                                            <i class="fa fa-home"></i> ${addr.fullAddress}
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                            <div class="text-center mt-3">
                                <a href="profile?tab=addresses&redirect=checkout" class="btn btn-outline-primary">
                                    <i class="fa fa-plus"></i> Thêm địa chỉ mới
                                </a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Đóng</button>
                    <button type="button" class="site-btn" onclick="confirmAddressSelection()">Xác nhận</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Shipping Modal -->
    <div class="modal fade checkout-modal" id="shippingModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fa fa-truck"></i> Chọn phương thức vận chuyển</h5>
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                </div>
                <div class="modal-body">
                    <div id="shippingOptionsModal">
                        <div class="loading-spinner">
                            <i class="fa fa-spinner fa-spin"></i>
                            <p class="text-muted mt-2">Đang tải phương thức vận chuyển...</p>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Đóng</button>
                    <button type="button" class="site-btn" onclick="confirmShippingSelection()">Xác nhận</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Voucher Modal -->
    <div class="modal fade checkout-modal" id="voucherModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fa fa-ticket"></i> Chọn Voucher giảm giá</h5>
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                </div>
                <div class="modal-body">
                    <c:choose>
                        <c:when test="${empty publicVouchers}">
                            <div class="text-center py-4">
                                <i class="fa fa-ticket fa-3x text-muted mb-3"></i>
                                <p class="text-muted">Hiện không có voucher công khai nào</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <!-- Debug: Show used up voucher IDs -->
                            <c:if test="${not empty usedUpVoucherIds}">
                                <div style="display:none;">Used up IDs: ${usedUpVoucherIds}</div>
                            </c:if>
                            
                            <div class="voucher-list">
                                <c:forEach var="v" items="${publicVouchers}">
                                    <c:set var="isUsedUp" value="false" />
                                    <c:forEach var="usedId" items="${usedUpVoucherIds}">
                                        <c:if test="${usedId == v.voucherID}">
                                            <c:set var="isUsedUp" value="true" />
                                        </c:if>
                                    </c:forEach>
                                    
                                    <div class="voucher-card ${isUsedUp ? 'used-up' : ''}" 
                                         data-code="${v.voucherCode}" 
                                         data-voucher-id="${v.voucherID}"
                                         data-discount-type="${v.discountType}"
                                         data-discount-value="${v.discountValue}"
                                         data-min-order="${v.minOrderValue}"
                                         data-max-discount="${v.maxDiscountAmount}"
                                         data-name="${v.voucherName}"
                                         data-used-up="${isUsedUp}"
                                         onclick="selectVoucherInModal(this)">
                                        <div class="d-flex">
                                            <div class="voucher-icon">
                                                <c:choose>
                                                    <c:when test="${v.discountType == 'percentage'}">
                                                        <span class="discount-badge">${v.discountValue}%</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="discount-badge"><fmt:formatNumber value="${v.discountValue}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="voucher-info flex-grow-1">
                                                <div class="voucher-code"><strong>${v.voucherCode}</strong></div>
                                                <div class="voucher-name">${v.voucherName}</div>
                                                <div class="voucher-condition">
                                                    <small class="text-muted">
                                                        <i class="fa fa-info-circle"></i>
                                                        Đơn tối thiểu: <fmt:formatNumber value="${v.minOrderValue}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                                        <c:if test="${v.discountType == 'percentage' && v.maxDiscountAmount != null}">
                                                            | Giảm tối đa: <fmt:formatNumber value="${v.maxDiscountAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                                        </c:if>
                                                    </small>
                                                </div>
                                                <div class="voucher-expiry">
                                                    <small class="text-warning">
                                                        <i class="fa fa-clock-o"></i> HSD: <fmt:formatDate value="${v.endDate}" pattern="dd/MM/yyyy"/>
                                                    </small>
                                                </div>
                                                <c:if test="${isUsedUp}">
                                                    <div class="voucher-used-badge">
                                                        <small class="text-danger">
                                                            <i class="fa fa-ban"></i> Đã sử dụng
                                                        </small>
                                                    </div>
                                                </c:if>
                                            </div>
                                            <div class="voucher-select">
                                                <c:choose>
                                                    <c:when test="${isUsedUp}">
                                                        <i class="fa fa-ban text-danger" style="font-size: 24px;"></i>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <i class="fa fa-check-circle text-success" style="font-size: 24px; display: none;"></i>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Đóng</button>
                    <button type="button" class="site-btn" onclick="confirmVoucherSelection()">Áp dụng Voucher</button>
                </div>
            </div>
        </div>
    </div>

    <style>
        /* Voucher Card Styles */
        .voucher-card {
            border: 2px solid #e1e1e1;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 10px;
            cursor: pointer;
            transition: all 0.2s;
            background: #fff;
        }
        .voucher-card:hover {
            border-color: #e53637;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .voucher-card.selected {
            border-color: #28a745;
            background: #f0fff4;
        }
        .voucher-card.disabled {
            opacity: 0.6;
            cursor: not-allowed;
            background: #f5f5f5;
        }
        .voucher-card.used-up {
            opacity: 0.5;
            cursor: not-allowed;
            background: #f9f9f9;
            border-color: #ccc;
        }
        .voucher-card.used-up:hover {
            border-color: #ccc;
            box-shadow: none;
        }
        .voucher-used-badge {
            margin-top: 5px;
        }
        .voucher-icon {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #e53637, #ff6b6b);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 15px;
        }
        .voucher-icon .discount-badge {
            color: white;
            font-weight: 700;
            font-size: 16px;
            text-align: center;
        }
        .voucher-info .voucher-code {
            font-size: 16px;
            color: #e53637;
        }
        .voucher-info .voucher-name {
            font-size: 14px;
            color: #333;
            margin: 3px 0;
        }
        .voucher-select {
            display: flex;
            align-items: center;
            padding-left: 15px;
        }
    </style>

    <%@include file="footer.jsp"%>

    <script src="js/jquery-3.3.1.min.js"></script>
    <script src="js/bootstrap.min.js"></script>

    <script>
        // Hide preloader when page loads
        $(window).on('load', function() {
            $(".loader").fadeOut();
            $("#preloder").delay(200).fadeOut("slow");
        });
        setTimeout(function() {
            $(".loader").fadeOut();
            $("#preloder").fadeOut("slow");
        }, 2000);
        
        var subtotal = parseFloat($('#subtotalValue').val()) || 0;
        var shippingFee = parseFloat($('#selectedShippingFee').val()) || 30000;
        var voucherDiscount = 0;
        
        // Selected data
        var selectedAddress = null;
        var selectedShipping = null;
        var shippingRatesData = [];
        
        // Cache for city/district IDs
        var cityCache = {};
        var districtCache = {};
        
        // Initialize selected address from default
        $(document).ready(function() {
            var $defaultAddr = $('.address-card.selected');
            if ($defaultAddr.length > 0) {
                selectedAddress = {
                    id: $defaultAddr.data('address-id'),
                    name: $defaultAddr.data('name'),
                    phone: $defaultAddr.data('phone'),
                    fullAddress: $defaultAddr.data('full-address'),
                    city: $defaultAddr.data('city'),
                    district: $defaultAddr.data('district'),
                    isDefault: $defaultAddr.data('is-default')
                };
                $('#selectedAddressId').val(selectedAddress.id);
                
                // Load shipping rates for default address
                loadShippingRatesFromGoship(selectedAddress.city, selectedAddress.district);
            }
        });
        
        // Open Address Modal
        function openAddressModal() {
            $('#addressModal').modal('show');
        }
        
        // Select address in modal
        function selectAddressInModal(el) {
            $('#addressList .address-card').removeClass('selected');
            $('#addressList .address-card .fa-check-circle').hide();
            $(el).addClass('selected');
            $(el).find('.fa-check-circle').show();
        }
        
        // Confirm address selection
        function confirmAddressSelection() {
            var $selected = $('#addressList .address-card.selected');
            if ($selected.length === 0) {
                alert('Vui lòng chọn một địa chỉ');
                return;
            }
            
            selectedAddress = {
                id: $selected.data('address-id'),
                name: $selected.data('name'),
                phone: $selected.data('phone'),
                fullAddress: $selected.data('full-address'),
                city: $selected.data('city'),
                district: $selected.data('district'),
                isDefault: $selected.data('is-default')
            };
            
            // Update display
            var html = '<strong>' + selectedAddress.name + '</strong> | ' + selectedAddress.phone;
            if (selectedAddress.isDefault) {
                html += ' <span class="badge-default ml-1">Mặc định</span>';
            }
            html += '<br><span class="text-muted"><i class="fa fa-home"></i> ' + selectedAddress.fullAddress + '</span>';
            
            $('#selectedAddressDisplay').html(html);
            $('#selectedAddressId').val(selectedAddress.id);
            
            // Update section style
            $('#addressSection').removeClass('empty');
            if (!$('#addressSection .section-header').length) {
                $('#addressSection').html(
                    '<div class="section-header">' +
                    '<span class="section-title"><i class="fa fa-map-marker"></i> Địa chỉ giao hàng</span>' +
                    '<span class="section-action">Thay đổi <i class="fa fa-chevron-right"></i></span>' +
                    '</div>' +
                    '<div class="section-content" id="selectedAddressDisplay">' + html + '</div>'
                );
            }
            
            // Enable checkout button
            $('.btn-checkout').prop('disabled', false);
            
            // Close modal and load shipping rates
            $('#addressModal').modal('hide');
            loadShippingRatesFromGoship(selectedAddress.city, selectedAddress.district);
        }
        
        // Open Shipping Modal
        function openShippingModal() {
            if (!selectedAddress) {
                alert('Vui lòng chọn địa chỉ giao hàng trước');
                openAddressModal();
                return;
            }
            
            $('#shippingModal').modal('show');
            
            // If no rates loaded yet, load them
            if (shippingRatesData.length === 0) {
                loadShippingRatesForModal(selectedAddress.city, selectedAddress.district);
            } else {
                renderShippingOptionsInModal(shippingRatesData);
            }
        }
        
        // Load shipping rates from Goship
        function loadShippingRatesFromGoship(cityName, districtName) {
            // Show loading in shipping section
            $('#selectedShippingDisplay').html('<span class="text-muted"><i class="fa fa-spinner fa-spin"></i> Đang tải phí vận chuyển...</span>');
            
            getCityId(cityName, function(cityId) {
                if (!cityId) {
                    useDefaultShippingRates('Không tìm thấy thành phố');
                    return;
                }
                
                getDistrictId(cityId, districtName, function(districtId) {
                    if (!districtId) {
                        useDefaultShippingRates('Không tìm thấy quận/huyện');
                        return;
                    }
                    
                    $.ajax({
                        url: 'api/goship/rates',
                        method: 'GET',
                        data: { toCityId: cityId, toDistrictId: districtId, weight: 500 },
                        dataType: 'json',
                        timeout: 10000,
                        success: function(data) {
                            if (data.success && data.rates && data.rates.length > 0) {
                                shippingRatesData = data.rates;
                                selectFirstShippingRate();
                            } else {
                                useDefaultShippingRates(data.message || 'Không lấy được phí vận chuyển');
                            }
                        },
                        error: function() {
                            useDefaultShippingRates('Lỗi kết nối API');
                        }
                    });
                });
            });
        }
        
        function loadShippingRatesForModal(cityName, districtName) {
            $('#shippingOptionsModal').html('<div class="loading-spinner"><i class="fa fa-spinner fa-spin"></i><p class="text-muted mt-2">Đang tải phương thức vận chuyển...</p></div>');
            
            getCityId(cityName, function(cityId) {
                if (!cityId) {
                    renderDefaultShippingInModal('Không tìm thấy thành phố');
                    return;
                }
                
                getDistrictId(cityId, districtName, function(districtId) {
                    if (!districtId) {
                        renderDefaultShippingInModal('Không tìm thấy quận/huyện');
                        return;
                    }
                    
                    $.ajax({
                        url: 'api/goship/rates',
                        method: 'GET',
                        data: { toCityId: cityId, toDistrictId: districtId, weight: 500 },
                        dataType: 'json',
                        timeout: 10000,
                        success: function(data) {
                            if (data.success && data.rates && data.rates.length > 0) {
                                shippingRatesData = data.rates;
                                renderShippingOptionsInModal(data.rates);
                            } else {
                                renderDefaultShippingInModal(data.message || 'Không lấy được phí vận chuyển');
                            }
                        },
                        error: function() {
                            renderDefaultShippingInModal('Lỗi kết nối API');
                        }
                    });
                });
            });
        }
        
        function getCityId(cityName, callback) {
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
                error: function() { callback(null); }
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
                error: function() { callback(null); }
            });
        }
        
        function selectFirstShippingRate() {
            if (shippingRatesData.length > 0) {
                var rate = shippingRatesData[0];
                selectedShipping = rate;
                shippingFee = rate.price;
                
                $('#selectedShippingFee').val(rate.price);
                $('#selectedCarrierId').val(rate.id);
                $('#selectedCarrierName').val(rate.carrierName);
                $('#selectedEstimatedDelivery').val(rate.estimatedDelivery);
                
                updateShippingDisplay();
                updateTotal();
            }
        }
        
        function useDefaultShippingRates(message) {
            console.log('[Checkout] Using default rates: ' + message);
            shippingRatesData = [
                { id: '1', carrierName: 'Giao Hàng Tiết Kiệm', serviceName: 'Giao Chuẩn', price: 30000, estimatedDelivery: '3-5 ngày' },
                { id: '2', carrierName: 'Giao Hàng Nhanh', serviceName: 'Giao Nhanh', price: 45000, estimatedDelivery: '1-2 ngày' },
                { id: '3', carrierName: 'Viettel Post', serviceName: 'Chuyển phát thường', price: 25000, estimatedDelivery: '3-5 ngày' }
            ];
            selectFirstShippingRate();
        }
        
        function renderShippingOptionsInModal(rates) {
            var html = '';
            rates.forEach(function(rate, index) {
                var selected = (selectedShipping && selectedShipping.id === rate.id) || (!selectedShipping && index === 0);
                html += '<div class="shipping-option ' + (selected ? 'selected' : '') + '" data-index="' + index + '" onclick="selectShippingInModal(this, ' + index + ')">';
                html += '<div class="d-flex justify-content-between align-items-center">';
                html += '<div>';
                if (rate.carrierLogo) {
                    html += '<img src="' + rate.carrierLogo + '" class="carrier-logo" onerror="this.style.display=\'none\'">';
                }
                html += '<strong>' + rate.carrierName + '</strong>';
                html += '<span class="text-muted"> - ' + rate.serviceName + '</span>';
                html += '<br><small class="text-muted"><i class="fa fa-clock-o"></i> ' + rate.estimatedDelivery + '</small>';
                html += '</div>';
                html += '<div class="text-right">';
                html += '<strong class="text-danger">' + formatCurrency(rate.price) + 'đ</strong>';
                html += '<br><i class="fa fa-check-circle text-danger" style="font-size: 18px; display: ' + (selected ? 'inline' : 'none') + ';"></i>';
                html += '</div>';
                html += '</div></div>';
            });
            
            $('#shippingOptionsModal').html(html);
        }
        
        function renderDefaultShippingInModal(message) {
            shippingRatesData = [
                { id: '1', carrierName: 'Giao Hàng Tiết Kiệm', serviceName: 'Giao Chuẩn', price: 30000, estimatedDelivery: '3-5 ngày' },
                { id: '2', carrierName: 'Giao Hàng Nhanh', serviceName: 'Giao Nhanh', price: 45000, estimatedDelivery: '1-2 ngày' },
                { id: '3', carrierName: 'Viettel Post', serviceName: 'Chuyển phát thường', price: 25000, estimatedDelivery: '3-5 ngày' }
            ];
            
            var html = '<div class="alert alert-info mb-3" style="font-size:13px;"><i class="fa fa-info-circle"></i> ' + message + '. Sử dụng giá mặc định.</div>';
            
            shippingRatesData.forEach(function(rate, index) {
                var selected = index === 0;
                html += '<div class="shipping-option ' + (selected ? 'selected' : '') + '" data-index="' + index + '" onclick="selectShippingInModal(this, ' + index + ')">';
                html += '<div class="d-flex justify-content-between align-items-center">';
                html += '<div><strong>' + rate.carrierName + '</strong><span class="text-muted"> - ' + rate.serviceName + '</span>';
                html += '<br><small class="text-muted"><i class="fa fa-clock-o"></i> ' + rate.estimatedDelivery + '</small></div>';
                html += '<div class="text-right">';
                html += '<strong class="text-danger">' + formatCurrency(rate.price) + 'đ</strong>';
                html += '<br><i class="fa fa-check-circle text-danger" style="font-size: 18px; display: ' + (selected ? 'inline' : 'none') + ';"></i>';
                html += '</div>';
                html += '</div></div>';
            });
            
            $('#shippingOptionsModal').html(html);
        }
        
        function selectShippingInModal(el, index) {
            $('#shippingOptionsModal .shipping-option').removeClass('selected');
            $('#shippingOptionsModal .shipping-option .fa-check-circle').hide();
            $(el).addClass('selected');
            $(el).find('.fa-check-circle').show();
        }
        
        function confirmShippingSelection() {
            var $selected = $('#shippingOptionsModal .shipping-option.selected');
            if ($selected.length === 0) {
                alert('Vui lòng chọn phương thức vận chuyển');
                return;
            }
            
            var index = $selected.data('index');
            selectedShipping = shippingRatesData[index];
            shippingFee = selectedShipping.price;
            
            $('#selectedShippingFee').val(selectedShipping.price);
            $('#selectedCarrierId').val(selectedShipping.id);
            $('#selectedCarrierName').val(selectedShipping.carrierName);
            $('#selectedEstimatedDelivery').val(selectedShipping.estimatedDelivery);
            
            updateShippingDisplay();
            updateTotal();
            
            $('#shippingModal').modal('hide');
        }
        
        function updateShippingDisplay() {
            if (selectedShipping) {
                var html = '<strong>' + selectedShipping.carrierName + '</strong> - ' + selectedShipping.serviceName;
                html += '<br><span class="text-muted"><i class="fa fa-clock-o"></i> ' + selectedShipping.estimatedDelivery + '</span>';
                html += '<span class="text-danger float-right">' + formatCurrency(selectedShipping.price) + 'đ</span>';
                $('#selectedShippingDisplay').html(html);
            }
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
        
        // ========== VOUCHER FUNCTIONS ==========
        var selectedVoucher = null;
        
        function openVoucherModal() {
            // Check eligibility for each voucher based on subtotal
            $('.voucher-card').each(function() {
                // Skip if already used up
                if ($(this).hasClass('used-up')) {
                    return;
                }
                
                var minOrder = parseFloat($(this).data('min-order')) || 0;
                if (subtotal < minOrder) {
                    $(this).addClass('disabled');
                    $(this).find('.voucher-condition small').removeClass('text-muted').addClass('text-danger');
                } else {
                    $(this).removeClass('disabled');
                    $(this).find('.voucher-condition small').removeClass('text-danger').addClass('text-muted');
                }
            });
            $('#voucherModal').modal('show');
        }
        
        function selectVoucherInModal(el) {
            // Check if voucher is used up
            if ($(el).data('used-up') === true || $(el).hasClass('used-up')) {
                alert('Bạn đã sử dụng hết lượt áp dụng voucher này');
                return;
            }
            
            if ($(el).hasClass('disabled')) {
                var minOrder = parseFloat($(el).data('min-order')) || 0;
                alert('Đơn hàng chưa đạt giá trị tối thiểu ' + formatCurrency(minOrder) + 'đ để sử dụng voucher này');
                return;
            }
            
            $('.voucher-card').removeClass('selected');
            $('.voucher-card .fa-check-circle').hide();
            $(el).addClass('selected');
            $(el).find('.fa-check-circle').show();
        }
        
        function confirmVoucherSelection() {
            var $selected = $('.voucher-card.selected');
            if ($selected.length === 0) {
                alert('Vui lòng chọn một voucher');
                return;
            }
            
            // Check if voucher is used up (double check)
            if ($selected.data('used-up') === true || $selected.hasClass('used-up')) {
                alert('Bạn đã sử dụng hết lượt áp dụng voucher này');
                return;
            }
            
            var code = $selected.data('code');
            var discountType = $selected.data('discount-type');
            var discountValue = parseFloat($selected.data('discount-value')) || 0;
            var name = $selected.data('name');
            
            // Close modal and show loading
            $('#voucherModal').modal('hide');
            $('#voucherMessage').html('<span class="text-muted"><i class="fa fa-spinner fa-spin"></i> Đang kiểm tra voucher...</span>');
            
            // Validate voucher via API (to check customer usage limit)
            $.ajax({
                url: 'api/voucher',
                method: 'POST',
                data: { voucherCode: code, subtotal: subtotal },
                dataType: 'json',
                success: function(data) {
                    if (data.success) {
                        var discount = parseFloat(data.discount) || 0;
                        
                        // Apply voucher
                        selectedVoucher = { code: code, discount: discount, name: name };
                        voucherDiscount = discount;
                        
                        $('#voucherCode').val(code);
                        $('#voucherDiscount').val(discount);
                        $('#voucherRow').show();
                        $('#voucherDisplay').text('-' + formatCurrency(discount) + 'đ');
                        
                        // Update display
                        var descText = discountType === 'percentage' ? 
                            ('Giảm ' + discountValue + '%') : 
                            ('Giảm ' + formatCurrency(discountValue) + 'đ');
                        
                        $('#selectedVoucherCode').text(code);
                        $('#selectedVoucherDesc').text(' - ' + descText);
                        $('#selectedVoucherDisplay').show();
                        $('#voucherInputSection').hide();
                        $('#voucherMessage').html('<span class="voucher-success"><i class="fa fa-check-circle"></i> ' + data.message + '</span>');
                        
                        updateTotal();
                    } else {
                        // Voucher validation failed
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
        
        function removeVoucher() {
            selectedVoucher = null;
            voucherDiscount = 0;
            
            $('#voucherCode').val('');
            $('#voucherDiscount').val(0);
            $('#voucherRow').hide();
            $('#selectedVoucherDisplay').hide();
            $('#voucherInputSection').show();
            $('#voucherMessage').html('');
            
            // Reset selection in modal
            $('.voucher-card').removeClass('selected');
            $('.voucher-card .fa-check-circle').hide();
            
            updateTotal();
        }
        
        // Form validation
        $('#checkoutForm').on('submit', function(e) {
            if (!$('#selectedAddressId').val()) {
                e.preventDefault();
                alert('Vui lòng chọn địa chỉ giao hàng');
                openAddressModal();
                return false;
            }
            
            $(this).find('button[type="submit"]').prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> Đang xử lý...');
        });
    </script>
</body>
</html>
