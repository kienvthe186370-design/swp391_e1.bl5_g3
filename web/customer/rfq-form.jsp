<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gửi Yêu Cầu Báo Giá Bán Buôn - Pickleball Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" type="text/css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/css/bootstrap-datepicker.min.css">
    <style>
        .section-header { background: #f8f9fa; padding: 10px 15px; border-left: 4px solid #e53637; margin-bottom: 20px; }
        .required-field::after { content: " *"; color: red; }
        .product-row { border: 1px solid #dee2e6; padding: 15px; margin-bottom: 10px; border-radius: 5px; background: #f8f9fa; }
        .product-row:hover { background: #e9ecef; }
    </style>
</head>
<body>
    <%@include file="../header.jsp" %>

    <section class="breadcrumb-option">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="breadcrumb__text">
                        <h4>Gửi Yêu Cầu Báo Giá</h4>
                        <div class="breadcrumb__links">
                            <a href="${pageContext.request.contextPath}/Home">Trang chủ</a>
                            <span>Yêu cầu báo giá</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="spad">
        <div class="container">
            <c:if test="${not empty error}">
                <div class="alert alert-danger">${error}</div>
            </c:if>

            <div class="card mb-4">
                <div class="card-body">
                    <h4><i class="fa fa-file-text"></i> Gửi Yêu Cầu Báo Giá Bán Buôn (RFQ)</h4>
                    <p class="text-muted mb-0">Vui lòng điền đầy đủ thông tin. Chúng tôi sẽ gửi báo giá trong 24-48 giờ.</p>
                </div>
            </div>

            <form action="${pageContext.request.contextPath}/rfq/confirm" method="POST" id="rfqForm">
                <c:if test="${not empty draftRfq.rfqID}">
                    <input type="hidden" name="draftRfqId" value="${draftRfq.rfqID}"/>
                </c:if>
                
                <!-- Company Info (optional) -->
                <div class="card mb-4">
                    <div class="card-body">
                        <div class="section-header d-flex justify-content-between align-items-center">
                            <h5 class="mb-0"><i class="fa fa-building"></i> Thông Tin Công Ty (không bắt buộc)</h5>
                            <button type="button" class="btn btn-sm btn-outline-primary" id="toggleCompanyBtn" onclick="toggleCompanySection()">
                                <i class="fa fa-plus"></i> Thêm thông tin công ty
                            </button>
                        </div>
                        <div id="companySection" style="${not empty draftRfq.companyName ? '' : 'display:none;'} margin-top:15px;">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                    <label>Tên Công Ty</label>
                                    <input type="text" class="form-control" name="companyName" value="${draftRfq.companyName}">
                            </div>
                            <div class="col-md-3 mb-3">
                                <label>Mã Số Thuế</label>
                                <input type="text" class="form-control" name="taxID" value="${draftRfq.taxID}">
                            </div>
                            <div class="col-md-3 mb-3">
                                <label>Loại Hình Kinh Doanh</label>
                                <select class="form-control" name="businessType">
                                    <option value="">-- Chọn --</option>
                                    <option value="Retailer" ${draftRfq.businessType == 'Retailer' ? 'selected' : ''}>Bán lẻ</option>
                                    <option value="Distributor" ${draftRfq.businessType == 'Distributor' ? 'selected' : ''}>Nhà phân phối</option>
                                    <option value="Other" ${draftRfq.businessType == 'Other' ? 'selected' : ''}>Khác</option>
                                </select>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Contact Info -->
                <div class="card mb-4">
                    <div class="card-body">
                        <div class="section-header"><h5 class="mb-0"><i class="fa fa-user"></i> Thông Tin Liên Hệ</h5></div>
                        <div class="row">
                            <div class="col-md-4 mb-3">
                                <label class="required-field">Người Liên Hệ</label>
                                <input type="text" class="form-control" name="contactPerson" value="${not empty draftRfq.contactPerson ? draftRfq.contactPerson : customer.fullName}" required>
                            </div>
                            <div class="col-md-4 mb-3">
                                <label class="required-field">Số Điện Thoại</label>
                                <input type="tel" class="form-control" name="contactPhone" value="${not empty draftRfq.contactPhone ? draftRfq.contactPhone : customer.phone}" required>
                            </div>
                            <div class="col-md-4 mb-3">
                                <label class="required-field">Email</label>
                                <input type="email" class="form-control" name="contactEmail" value="${not empty draftRfq.contactEmail ? draftRfq.contactEmail : customer.email}" required>
                            </div>
                            <div class="col-12 mb-3">
                                <label>Liên Hệ Dự Phòng</label>
                                <input type="text" class="form-control" name="alternativeContact" value="${draftRfq.alternativeContact}">
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Delivery Info -->
                <div class="card mb-4">
                    <div class="card-body">
                        <div class="section-header"><h5 class="mb-0"><i class="fa fa-truck"></i> Thông Tin Giao Hàng</h5></div>
                        <div class="row">
                            <div class="col-md-4 mb-3">
                                <label class="required-field">Tỉnh/Thành Phố</label>
                                <select class="form-control" name="deliveryCity" id="deliveryCity" required>
                                    <option value="">-- Đang tải... --</option>
                                </select>
                                <input type="hidden" name="deliveryCityId" id="deliveryCityId" value="${draftRfq.deliveryCityId}">
                            </div>
                            <div class="col-md-4 mb-3">
                                <label class="required-field">Quận/Huyện</label>
                                <select class="form-control" name="deliveryDistrict" id="deliveryDistrict" required disabled>
                                    <option value="">-- Chọn tỉnh/thành trước --</option>
                                </select>
                                <input type="hidden" name="deliveryDistrictId" id="deliveryDistrictId" value="${draftRfq.deliveryDistrictId}">
                            </div>
                            <div class="col-md-4 mb-3">
                                <label class="required-field">Phường/Xã</label>
                                <select class="form-control" name="deliveryWard" id="deliveryWard" required disabled>
                                    <option value="">-- Chọn quận/huyện trước --</option>
                                </select>
                                <input type="hidden" name="deliveryWardId" id="deliveryWardId" value="${draftRfq.deliveryWardId}">
                            </div>
                            <div class="col-md-12 mb-3">
                                <label class="required-field">Địa Chỉ Chi Tiết</label>
                                <input type="text" class="form-control" name="deliveryStreet" id="deliveryStreet" placeholder="Số nhà, tên đường..." value="${draftRfq.deliveryStreet}" required>
                                <input type="hidden" name="deliveryAddress" id="deliveryAddress" value="${draftRfq.deliveryAddress}">
                            </div>
                            <div class="col-12 mb-3">
                                <label>Yêu Cầu Đặc Biệt</label>
                                <textarea class="form-control" name="deliveryInstructions" rows="2">${draftRfq.deliveryInstructions}</textarea>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Products -->
                <div class="card mb-4">
                    <div class="card-body">
                        <div class="section-header d-flex justify-content-between align-items-center">
                            <h5 class="mb-0"><i class="fa fa-cube"></i> Danh Sách Sản Phẩm</h5>
                            <button type="button" class="btn btn-sm btn-outline-primary" onclick="addProductRow()">
                                <i class="fa fa-plus"></i> Thêm Sản Phẩm
                            </button>
                        </div>
                        <div id="productList">
                            <c:choose>
                                <c:when test="${not empty draftRfq.items}">
                                    <c:forEach var="item" items="${draftRfq.items}" varStatus="idx">
                                        <div class="product-row" id="product-${idx.index}">
                                            <div class="row">
                                                <div class="col-md-1 mb-2 d-flex align-items-center justify-content-center">
                                                    <div class="product-image-preview" style="width:60px;height:60px;border:1px solid #ddd;border-radius:4px;display:flex;align-items:center;justify-content:center;background:#f8f9fa;overflow:hidden;">
                                                        <i class="fa fa-image text-muted"></i>
                                                    </div>
                                                </div>
                                                <div class="col-md-4 mb-2">
                                                    <label class="required-field">Sản Phẩm</label>
                                                    <select class="form-control product-select" name="productId" required data-draft-variant="${item.variantID}">
                                                        <option value="">-- Chọn sản phẩm --</option>
                                                        <c:forEach var="p" items="${products}">
                                                            <option value="${p['productID']}" data-image="${p['mainImageUrl']}" ${p['productID'] == item.productID ? 'selected' : ''}>${p['productName']}</option>
                                                        </c:forEach>
                                                    </select>
                                                </div>
                                                <div class="col-md-3 mb-2">
                                                    <label class="required-field">Biến Thể</label>
                                                    <select class="form-control variant-select" name="variantId" required>
                                                        <option value="">-- Chọn biến thể --</option>
                                                    </select>
                                                </div>
                                                <div class="col-md-2 mb-2">
                                                    <label class="required-field">Số Lượng <small class="text-muted font-weight-normal">(min: 20)</small></label>
                                                    <input type="number" class="form-control quantity-input" name="quantity" min="20" value="${item.quantity}" required>
                                                </div>
                                                <div class="col-md-2 mb-2">
                                                    <label>&nbsp;</label>
                                                    <button type="button" class="btn btn-outline-danger w-100 d-block" onclick="removeProductRow(this)">
                                                        <i class="fa fa-trash"></i>
                                                    </button>
                                                </div>
                                                <div class="col-md-1"></div>
                                                <div class="col-md-11 mb-2">
                                                    <label>Yêu Cầu Đặc Biệt</label>
                                                    <input type="text" class="form-control" name="specialRequirements" value="${item.specialRequirements}">
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="product-row" id="product-0">
                                        <div class="row">
                                            <div class="col-md-1 mb-2 d-flex align-items-center justify-content-center">
                                                <div class="product-image-preview" style="width:60px;height:60px;border:1px solid #ddd;border-radius:4px;display:flex;align-items:center;justify-content:center;background:#f8f9fa;">
                                                    <i class="fa fa-image text-muted"></i>
                                                </div>
                                            </div>
                                            <div class="col-md-4 mb-2">
                                                <label class="required-field">Sản Phẩm</label>
                                                <select class="form-control product-select" name="productId" required>
                                                    <option value="">-- Chọn sản phẩm --</option>
                                                    <c:forEach var="p" items="${products}">
                                                        <option value="${p['productID']}" data-image="${p['mainImageUrl']}">${p['productName']}</option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                            <div class="col-md-3 mb-2">
                                                <label class="required-field">Biến Thể</label>
                                                <select class="form-control variant-select" name="variantId" required>
                                                    <option value="">-- Chọn biến thể --</option>
                                                </select>
                                            </div>
                                            <div class="col-md-2 mb-2">
                                                <label class="required-field">Số Lượng <small class="text-muted font-weight-normal">(min: 20)</small></label>
                                                <input type="number" class="form-control quantity-input" name="quantity" min="20" value="20" required>
                                            </div>
                                            <div class="col-md-2 mb-2">
                                                <label>&nbsp;</label>
                                                <button type="button" class="btn btn-outline-danger w-100 d-block" onclick="removeProductRow(this)">
                                                    <i class="fa fa-trash"></i>
                                                </button>
                                            </div>
                                            <div class="col-md-1"></div>
                                            <div class="col-md-11 mb-2">
                                                <label>Yêu Cầu Đặc Biệt</label>
                                                <input type="text" class="form-control" name="specialRequirements">
                                            </div>
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="alert alert-info mt-3">
                            <i class="fa fa-info-circle"></i> Đơn hàng bán buôn yêu cầu số lượng tối thiểu <strong>20 sản phẩm</strong> cho mỗi loại.
                        </div>
                    </div>
                </div>

                <!-- Shipping Method -->
                <div class="card mb-4">
                    <div class="card-body">
                        <div class="section-header"><h5 class="mb-0"><i class="fa fa-truck"></i> Phương Thức Vận Chuyển</h5></div>
                        
                        <div class="row mb-3">
                            <div class="col-12">
                                <button type="button" class="btn btn-info" id="btnCalculateShipping" onclick="calculateShippingRates()">
                                    <i class="fa fa-calculator"></i> Tính Phí Vận Chuyển
                                </button>
                                <small class="text-muted ml-2">Vui lòng chọn địa chỉ giao hàng và sản phẩm trước khi tính phí</small>
                            </div>
                        </div>
                        
                        <div id="shippingRatesContainer" style="display:none;">
                            <div id="shippingRatesLoading" class="text-center py-3" style="display:none;">
                                <i class="fa fa-spinner fa-spin fa-2x"></i>
                                <p class="mt-2">Đang tính phí vận chuyển...</p>
                            </div>
                            <div id="shippingRatesList"></div>
                            <input type="hidden" name="shippingCarrierId" id="shippingCarrierId">
                            <input type="hidden" name="shippingCarrierName" id="shippingCarrierName">
                            <input type="hidden" name="shippingServiceName" id="shippingServiceName">
                            <input type="hidden" name="shippingFee" id="shippingFeeInput">
                            <input type="hidden" name="estimatedDeliveryDays" id="estimatedDeliveryDays">
                        </div>
                        
                        <div id="shippingError" class="alert alert-danger mt-3" style="display:none;">
                            <i class="fa fa-exclamation-triangle"></i> <span id="shippingErrorMsg"></span>
                        </div>
                        
                        <hr class="my-4">
                        
                        <div class="row">
                            <div class="col-md-6">
                                <label class="required-field">Ngày Mong Muốn Nhận Hàng</label>
                                <input type="text" class="form-control" name="requestedDeliveryDate" id="deliveryDate" placeholder="dd/mm/yyyy" required disabled autocomplete="off">
                                <small class="text-muted" id="deliveryDateHint">Vui lòng chọn đơn vị vận chuyển trước</small>
                            </div>
                            <div class="col-md-6">
                                <div id="selectedShippingInfo" style="display:none;">
                                    <label>Thông Tin Vận Chuyển Đã Chọn</label>
                                    <div class="alert alert-success mb-0">
                                        <strong id="selectedCarrierName"></strong><br>
                                        <span id="selectedServiceName"></span><br>
                                        Phí ship: <strong id="selectedShippingFee"></strong><br>
                                        Thời gian giao: <strong id="selectedDeliveryTime"></strong>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Payment & Notes -->
                <div class="card mb-4">
                    <div class="card-body">
                        <div class="section-header"><h5 class="mb-0"><i class="fa fa-credit-card"></i> Thông Tin Thanh Toán & Yêu Cầu Khác</h5></div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="required-field">Hình Thức Thanh Toán</label>
                                <input type="text" class="form-control" value="Chuyển khoản ngân hàng" readonly>
                                <input type="hidden" name="preferredPaymentMethod" value="BankTransfer">
                                <small class="text-muted">Thanh toán qua VNPay sau khi chấp nhận báo giá</small>
                            </div>
                            <div class="col-md-6 mb-3">
                                <!-- Placeholder for alignment -->
                            </div>
                            <div class="col-12 mb-3">
                                <label>Ghi Chú Thêm</label>
                                <textarea class="form-control" name="customerNotes" rows="3" placeholder="Mọi yêu cầu đặc biệt hoặc thông tin bổ sung...">${draftRfq.customerNotes}</textarea>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Submit -->
                <div class="card mb-4">
                    <div class="card-body">
                        <div class="form-check mb-3">
                            <input class="form-check-input" type="checkbox" id="agreeTerms" required>
                            <label class="form-check-label" for="agreeTerms">
                                Tôi đã đọc và đồng ý với <a href="#">Điều khoản bán buôn</a>
                            </label>
                        </div>
                        <div class="d-flex justify-content-end">
                            <a href="${pageContext.request.contextPath}/rfq/list" class="btn btn-secondary mr-2">Hủy</a>
                            <button type="submit" class="btn btn-primary btn-lg">
                                <i class="fa fa-check"></i> Xác Nhận Đơn
                            </button>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </section>


    <%@include file="../footer.jsp"%>

    <script src="${pageContext.request.contextPath}/js/jquery-3.3.1.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/bootstrap.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/js/bootstrap-datepicker.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/locales/bootstrap-datepicker.vi.min.js"></script>
    <script>
        var contextPath = '${pageContext.request.contextPath}';
        
        // Store products data for dynamic rows
        var productsData = [];
        
        $(document).ready(function() {
            // Populate products data from select options
            $('.product-select').first().find('option').each(function() {
                if ($(this).val()) {
                    productsData.push({id: $(this).val(), name: $(this).text(), image: $(this).data('image') || ''});
                }
            });
            
            // Delivery date is disabled by default until shipping method is selected
            $('#deliveryDate').prop('disabled', true);
            
            // Bind change event for product select
            $(document).on('change', '.product-select', function() {
                var productId = $(this).val();
                var variantSelect = $(this).closest('.product-row').find('.variant-select');
                loadVariants(productId, variantSelect);
                
                // Update product image preview
                var imagePreview = $(this).closest('.product-row').find('.product-image-preview');
                var productImage = $(this).find(':selected').data('image');
                if (productImage) {
                    imagePreview.html('<img src="' + contextPath + '/' + productImage + '" style="width:100%;height:100%;object-fit:cover;">');
                } else {
                    imagePreview.html('<i class="fa fa-image text-muted"></i>');
                }
            });
            
            // Load cities
            loadCities();
            
            // Load variants for draft items and update product images
            $('.product-select').each(function() {
                var productId = $(this).val();
                var draftVariantId = $(this).data('draft-variant');
                if (productId) {
                    // Update product image
                    var imagePreview = $(this).closest('.product-row').find('.product-image-preview');
                    var productImage = $(this).find(':selected').data('image');
                    if (productImage) {
                        imagePreview.html('<img src="' + contextPath + '/' + productImage + '" style="width:100%;height:100%;object-fit:cover;">');
                    }
                    
                    // Load variants if draft has variant
                    if (draftVariantId) {
                        var variantSelect = $(this).closest('.product-row').find('.variant-select');
                        loadVariantsWithSelection(productId, variantSelect, draftVariantId);
                    }
                }
            });
            
            // City change event
            $('#deliveryCity').change(function() {
                var cityId = $(this).find(':selected').data('id');
                var cityName = $(this).val();
                $('#deliveryCityId').val(cityId);
                if (cityId) {
                    loadDistricts(cityId, false);
                } else {
                    $('#deliveryDistrict').html('<option value="">-- Chọn tỉnh/thành trước --</option>').prop('disabled', true);
                    $('#deliveryWard').html('<option value="">-- Chọn quận/huyện trước --</option>').prop('disabled', true);
                }
                updateFullAddress();
            });
            
            // District change event
            $('#deliveryDistrict').change(function() {
                var districtId = $(this).find(':selected').data('id');
                $('#deliveryDistrictId').val(districtId);
                if (districtId) {
                    loadWards(districtId, false);
                } else {
                    $('#deliveryWard').html('<option value="">-- Chọn quận/huyện trước --</option>').prop('disabled', true);
                }
                updateFullAddress();
            });
            
            // Ward change event
            $('#deliveryWard').change(function() {
                var wardId = $(this).find(':selected').data('id');
                $('#deliveryWardId').val(wardId);
                updateFullAddress();
            });
            
            // Street change event
            $('#deliveryStreet').on('input', function() {
                updateFullAddress();
            });
        });
        
        // Draft data from server
        var draftCityId = '${draftRfq.deliveryCityId}';
        var draftDistrictId = '${draftRfq.deliveryDistrictId}';
        var draftWardId = '${draftRfq.deliveryWardId}';
        
        function loadCities() {
            $.ajax({
                url: contextPath + '/api/goship/cities',
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    var options = '<option value="">-- Chọn tỉnh/thành phố --</option>';
                    var cities = response.cities || response;
                    if (cities && cities.length > 0) {
                        for (var i = 0; i < cities.length; i++) {
                            options += '<option value="' + cities[i].name + '" data-id="' + cities[i].id + '">' + cities[i].name + '</option>';
                        }
                    }
                    $('#deliveryCity').html(options);
                    
                    // If draft has city, select it and load districts
                    if (draftCityId) {
                        $('#deliveryCity option').each(function() {
                            if ($(this).data('id') == draftCityId) {
                                $(this).prop('selected', true);
                                loadDistricts(draftCityId, true);
                            }
                        });
                    }
                },
                error: function() {
                    $('#deliveryCity').html('<option value="">-- Lỗi tải dữ liệu --</option>');
                }
            });
        }
        
        function loadDistricts(cityId, isFromDraft) {
            $('#deliveryDistrict').html('<option value="">-- Đang tải... --</option>').prop('disabled', true);
            $('#deliveryWard').html('<option value="">-- Chọn quận/huyện trước --</option>').prop('disabled', true);
            
            $.ajax({
                url: contextPath + '/api/goship/districts',
                type: 'GET',
                data: { cityId: cityId },
                dataType: 'json',
                success: function(response) {
                    var options = '<option value="">-- Chọn quận/huyện --</option>';
                    var districts = response.districts || response;
                    if (districts && districts.length > 0) {
                        for (var i = 0; i < districts.length; i++) {
                            options += '<option value="' + districts[i].name + '" data-id="' + districts[i].id + '">' + districts[i].name + '</option>';
                        }
                    }
                    $('#deliveryDistrict').html(options).prop('disabled', false);
                    
                    // If draft has district, select it and load wards
                    if (isFromDraft && draftDistrictId) {
                        $('#deliveryDistrict option').each(function() {
                            if ($(this).data('id') == draftDistrictId) {
                                $(this).prop('selected', true);
                                loadWards(draftDistrictId, true);
                            }
                        });
                    }
                },
                error: function() {
                    $('#deliveryDistrict').html('<option value="">-- Lỗi tải dữ liệu --</option>').prop('disabled', false);
                }
            });
        }
        
        function loadWards(districtId, isFromDraft) {
            $('#deliveryWard').html('<option value="">-- Đang tải... --</option>').prop('disabled', true);
            
            $.ajax({
                url: contextPath + '/api/goship/wards',
                type: 'GET',
                data: { districtId: districtId },
                dataType: 'json',
                success: function(response) {
                    var options = '<option value="">-- Chọn phường/xã --</option>';
                    var wards = response.wards || response;
                    if (wards && wards.length > 0) {
                        for (var i = 0; i < wards.length; i++) {
                            options += '<option value="' + wards[i].name + '" data-id="' + wards[i].id + '">' + wards[i].name + '</option>';
                        }
                    }
                    $('#deliveryWard').html(options).prop('disabled', false);
                    
                    // If draft has ward, select it
                    if (isFromDraft && draftWardId) {
                        $('#deliveryWard option').each(function() {
                            if ($(this).data('id') == draftWardId) {
                                $(this).prop('selected', true);
                            }
                        });
                    }
                },
                error: function() {
                    $('#deliveryWard').html('<option value="">-- Không có dữ liệu --</option>').prop('disabled', false);
                }
            });
        }
        
        function updateFullAddress() {
            var street = $('#deliveryStreet').val() || '';
            var ward = $('#deliveryWard').val() || '';
            var district = $('#deliveryDistrict').val() || '';
            var city = $('#deliveryCity').val() || '';
            
            var parts = [];
            if (street) parts.push(street);
            if (ward) parts.push(ward);
            if (district) parts.push(district);
            if (city) parts.push(city);
            
            $('#deliveryAddress').val(parts.join(', '));
        }
        
        function loadVariants(productId, variantSelect) {
            loadVariantsWithSelection(productId, variantSelect, null);
        }
        
        function loadVariantsWithSelection(productId, variantSelect, selectedVariantId) {
            variantSelect.html('<option value="">-- Đang tải... --</option>');
            
            if (!productId) {
                variantSelect.html('<option value="">-- Chọn sản phẩm trước --</option>');
                return;
            }
            
            $.ajax({
                url: contextPath + '/api/product-variants',
                type: 'GET',
                data: { productId: productId },
                dataType: 'json',
                success: function(variants) {
                    var options = '<option value="">-- Chọn biến thể --</option>';
                    if (variants && variants.length > 0) {
                        for (var i = 0; i < variants.length; i++) {
                            var v = variants[i];
                            if (v.isActive) {
                                var price = v.sellingPrice ? new Intl.NumberFormat('vi-VN').format(v.sellingPrice) + '₫' : '';
                                var stock = v.stock ? ' (Kho: ' + v.stock + ')' : '';
                                var selected = (selectedVariantId && v.variantId == selectedVariantId) ? ' selected' : '';
                                options += '<option value="' + v.variantId + '"' + selected + '>' + v.sku + ' - ' + price + stock + '</option>';
                            }
                        }
                    }
                    variantSelect.html(options);
                },
                error: function() {
                    variantSelect.html('<option value="">-- Không có biến thể --</option>');
                }
            });
        }

        function addProductRow() {
            var productList = $('#productList');
            var count = productList.children().length;
            
            // Build product options from stored data
            var productOptions = '<option value="">-- Chọn sản phẩm --</option>';
            for (var i = 0; i < productsData.length; i++) {
                productOptions += '<option value="' + productsData[i].id + '" data-image="' + (productsData[i].image || '') + '">' + productsData[i].name + '</option>';
            }
            
            var newRow = 
                '<div class="product-row" id="product-' + count + '">' +
                    '<div class="row">' +
                        '<div class="col-md-1 mb-2 d-flex align-items-center justify-content-center">' +
                            '<div class="product-image-preview" style="width:60px;height:60px;border:1px solid #ddd;border-radius:4px;display:flex;align-items:center;justify-content:center;background:#f8f9fa;">' +
                                '<i class="fa fa-image text-muted"></i>' +
                            '</div>' +
                        '</div>' +
                        '<div class="col-md-4 mb-2">' +
                            '<label class="required-field">Sản Phẩm</label>' +
                            '<select class="form-control product-select" name="productId" required>' +
                                productOptions +
                            '</select>' +
                        '</div>' +
                        '<div class="col-md-3 mb-2">' +
                            '<label class="required-field">Biến Thể</label>' +
                            '<select class="form-control variant-select" name="variantId" required>' +
                                '<option value="">-- Chọn biến thể --</option>' +
                            '</select>' +
                        '</div>' +
                        '<div class="col-md-2 mb-2">' +
                            '<label class="required-field">Số Lượng <small class="text-muted font-weight-normal">(min: 20)</small></label>' +
                            '<input type="number" class="form-control quantity-input" name="quantity" min="20" value="20" required>' +
                        '</div>' +
                        '<div class="col-md-2 mb-2">' +
                            '<label>&nbsp;</label>' +
                            '<button type="button" class="btn btn-outline-danger w-100 d-block" onclick="removeProductRow(this)">' +
                                '<i class="fa fa-trash"></i>' +
                            '</button>' +
                        '</div>' +
                        '<div class="col-md-1"></div>' +
                        '<div class="col-md-11 mb-2">' +
                            '<label>Yêu Cầu Đặc Biệt</label>' +
                            '<input type="text" class="form-control" name="specialRequirements">' +
                        '</div>' +
                    '</div>' +
                '</div>';
            productList.append(newRow);
        }

        function removeProductRow(btn) {
            if ($('.product-row').length > 1) {
                $(btn).closest('.product-row').remove();
            } else {
                alert('Phải có ít nhất 1 sản phẩm!');
            }
        }
        
        // ===== Validation helpers =====
        const WHOLESALE_MIN_QTY = 20;
        const MIN_QTY_MSG = 'Số lượng tối thiểu đơn mua buôn là 20.';

        function normalizeQuantity(inputEl) {
            let qty = parseInt($(inputEl).val(), 10) || 0;
            if (qty < WHOLESALE_MIN_QTY) {
                $(inputEl).val(WHOLESALE_MIN_QTY);
                $(inputEl).removeClass('is-invalid');
                alert(MIN_QTY_MSG);
                return false;
            } else {
                $(inputEl).removeClass('is-invalid');
                return true;
            }
        }

        // Validate khi rời ô hoặc đổi giá trị (không chặn khi đang gõ/xóa)
        $(document).on('change blur', '.quantity-input', function() {
            normalizeQuantity(this);
        });
        
        // Validate form before submit
        $('#rfqForm').on('submit', function(e) {
            let ok = true;
            
            // Check minimum quantity for each product
            $('.quantity-input').each(function() {
                if (!normalizeQuantity(this)) ok = false;
            });

            // Require variant selection
            $('.variant-select').each(function() {
                if (!$(this).val()) {
                    ok = false;
                    $(this).addClass('is-invalid');
                } else {
                    $(this).removeClass('is-invalid');
                }
            });
            
            // Check shipping method selected
            if (!$('#shippingCarrierId').val()) {
                ok = false;
                // Check if shipping rates were loaded but none selected
                if ($('#shippingRatesList').find('input[type="radio"]').length > 0) {
                    alert('Vui lòng chọn một đơn vị vận chuyển từ danh sách.');
                } else {
                    alert('Vui lòng bấm "Tính Phí Vận Chuyển" và chọn đơn vị vận chuyển.\n\nNếu địa điểm của bạn không có đơn vị vận chuyển nào nhận, vui lòng chọn địa điểm khác.');
                }
            }
            
            if (!ok) {
                e.preventDefault();
                return false;
            }
            return true;
        });
        
        // Toggle company section (optional info)
        function toggleCompanySection() {
            var section = document.getElementById('companySection');
            var btn = document.getElementById('toggleCompanyBtn');
            var isHidden = section.style.display === 'none' || section.style.display === '';
            if (isHidden) {
                section.style.display = 'block';
                btn.innerHTML = '<i class="fa fa-minus"></i> Ẩn thông tin công ty';
            } else {
                // Clear values when hiding
                section.querySelectorAll('input, select').forEach(function(el){ el.value = ''; });
                section.style.display = 'none';
                btn.innerHTML = '<i class="fa fa-plus"></i> Thêm thông tin công ty';
            }
        }
        
        // ===== Shipping Rate Functions =====
        var selectedShippingRate = null;
        
        function calculateShippingRates() {
            var cityId = $('#deliveryCityId').val();
            var districtId = $('#deliveryDistrictId').val();
            
            if (!cityId || !districtId) {
                alert('Vui lòng chọn Tỉnh/Thành phố và Quận/Huyện trước khi tính phí vận chuyển.');
                return;
            }
            
            // Calculate total weight based on quantity (assume 500g per item)
            var totalQuantity = 0;
            $('.quantity-input').each(function() {
                totalQuantity += parseInt($(this).val()) || 0;
            });
            
            if (totalQuantity === 0) {
                alert('Vui lòng chọn sản phẩm và số lượng trước khi tính phí vận chuyển.');
                return;
            }
            
            var weight = totalQuantity * 500; // 500g per item
            
            $('#shippingRatesContainer').show();
            $('#shippingRatesLoading').show();
            $('#shippingRatesList').html('');
            $('#shippingError').hide();
            
            $.ajax({
                url: contextPath + '/api/goship/rates',
                type: 'GET',
                data: {
                    toCityId: cityId,
                    toDistrictId: districtId,
                    weight: weight,
                    cod: 0
                },
                dataType: 'json',
                success: function(response) {
                    $('#shippingRatesLoading').hide();
                    
                    if (response.success && response.rates && response.rates.length > 0) {
                        renderShippingRates(response.rates);
                        $('#shippingError').hide();
                    } else {
                        $('#shippingError').show();
                        $('#shippingErrorMsg').html('<strong>Địa điểm của bạn không có đơn vị vận chuyển nào nhận.</strong><br>Vui lòng chọn địa điểm khác hoặc liên hệ với chúng tôi để được hỗ trợ.');
                        $('#shippingRatesList').html('');
                    }
                },
                error: function() {
                    $('#shippingRatesLoading').hide();
                    $('#shippingError').show();
                    $('#shippingErrorMsg').text('Lỗi kết nối đến dịch vụ vận chuyển. Vui lòng thử lại sau.');
                }
            });
        }
        
        function renderShippingRates(rates) {
            var html = '<div class="list-group">';
            
            for (var i = 0; i < rates.length; i++) {
                var rate = rates[i];
                var estimatedDays = parseEstimatedDays(rate.estimatedDelivery);
                var priceFormatted = new Intl.NumberFormat('vi-VN').format(rate.price) + '₫';
                
                html += '<label class="list-group-item list-group-item-action d-flex align-items-center" style="cursor:pointer;">';
                html += '<input type="radio" name="shippingRateRadio" class="mr-3" ';
                html += 'data-id="' + rate.id + '" ';
                html += 'data-carrier="' + escapeHtml(rate.carrierName) + '" ';
                html += 'data-service="' + escapeHtml(rate.serviceName) + '" ';
                html += 'data-price="' + rate.price + '" ';
                html += 'data-days="' + estimatedDays + '" ';
                html += 'data-delivery="' + escapeHtml(rate.estimatedDelivery) + '" ';
                html += 'onchange="selectShippingRate(this)">';
                
                if (rate.carrierLogo) {
                    html += '<img src="' + rate.carrierLogo + '" alt="" style="width:50px;height:30px;object-fit:contain;" class="mr-3">';
                }
                
                html += '<div class="flex-grow-1">';
                html += '<strong>' + escapeHtml(rate.carrierName) + '</strong>';
                html += '<br><small class="text-muted">' + escapeHtml(rate.serviceName) + ' - ' + escapeHtml(rate.estimatedDelivery) + '</small>';
                html += '</div>';
                html += '<div class="text-right">';
                html += '<strong class="text-primary">' + priceFormatted + '</strong>';
                html += '</div>';
                html += '</label>';
            }
            
            html += '</div>';
            $('#shippingRatesList').html(html);
        }
        
        function parseEstimatedDays(estimatedDelivery) {
            // Parse "2-3 ngày", "1-2 ngày", "12 giờ", "24 giờ" to get days
            if (!estimatedDelivery) return 3;
            
            var lowerText = estimatedDelivery.toLowerCase();
            var match = lowerText.match(/(\d+)[-–]?(\d+)?/);
            
            if (match) {
                var maxValue = parseInt(match[2] || match[1]) || 3;
                
                // Check if it's hours (giờ) - convert to days (round up)
                if (lowerText.indexOf('giờ') !== -1 || lowerText.indexOf('gio') !== -1 || lowerText.indexOf('hour') !== -1) {
                    return Math.ceil(maxValue / 24) || 1; // At least 1 day
                }
                
                // Otherwise it's days
                return maxValue;
            }
            return 3; // Default 3 days
        }
        
        function selectShippingRate(radio) {
            var $radio = $(radio);
            
            selectedShippingRate = {
                id: $radio.data('id'),
                carrierName: $radio.data('carrier'),
                serviceName: $radio.data('service'),
                price: $radio.data('price'),
                days: $radio.data('days'),
                deliveryTime: $radio.data('delivery')
            };
            
            // Update hidden fields
            $('#shippingCarrierId').val(selectedShippingRate.id);
            $('#shippingCarrierName').val(selectedShippingRate.carrierName);
            $('#shippingServiceName').val(selectedShippingRate.serviceName);
            $('#shippingFeeInput').val(selectedShippingRate.price);
            $('#estimatedDeliveryDays').val(selectedShippingRate.days);
            
            // Show selected info
            $('#selectedShippingInfo').show();
            $('#selectedCarrierName').text(selectedShippingRate.carrierName);
            $('#selectedServiceName').text(selectedShippingRate.serviceName);
            $('#selectedShippingFee').text(new Intl.NumberFormat('vi-VN').format(selectedShippingRate.price) + '₫');
            $('#selectedDeliveryTime').text('Dự kiến giao ' + selectedShippingRate.deliveryTime);
            
            // Enable and set min date for delivery date
            updateDeliveryDateConstraints(selectedShippingRate.days);
        }
        
        function updateDeliveryDateConstraints(deliveryDays) {
            var today = new Date();
            var minDate = new Date();
            minDate.setDate(today.getDate() + deliveryDays);
            
            // Format date as dd/mm/yyyy for display
            var day = String(minDate.getDate()).padStart(2, '0');
            var month = String(minDate.getMonth() + 1).padStart(2, '0');
            var year = minDate.getFullYear();
            var formattedDate = day + '/' + month + '/' + year;
            
            // Destroy existing datepicker if any
            $('#deliveryDate').datepicker('destroy');
            
            // Initialize datepicker with Vietnamese locale and dd/mm/yyyy format
            $('#deliveryDate').datepicker({
                format: 'dd/mm/yyyy',
                language: 'vi',
                startDate: minDate,
                autoclose: true,
                todayHighlight: true
            });
            
            $('#deliveryDate').prop('disabled', false);
            $('#deliveryDate').val(formattedDate); // Set default to earliest possible date
            
            var dayNames = ['Chủ nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
            
            $('#deliveryDateHint').html('Ngày sớm nhất có thể nhận hàng: <strong>' + formattedDate + '</strong> (' + dayNames[minDate.getDay()] + ')');
        }
        
        function escapeHtml(text) {
            if (!text) return '';
            var div = document.createElement('div');
            div.appendChild(document.createTextNode(text));
            return div.innerHTML;
        }
        
        // Reset shipping when address changes
        $('#deliveryCity, #deliveryDistrict').change(function() {
            resetShippingSelection();
        });
        
        function resetShippingSelection() {
            selectedShippingRate = null;
            $('#shippingCarrierId').val('');
            $('#shippingCarrierName').val('');
            $('#shippingServiceName').val('');
            $('#shippingFeeInput').val('');
            $('#estimatedDeliveryDays').val('');
            $('#shippingRatesContainer').hide();
            $('#shippingRatesList').html('');
            $('#selectedShippingInfo').hide();
            $('#deliveryDate').prop('disabled', true).val('');
            $('#deliveryDateHint').text('Vui lòng chọn đơn vị vận chuyển trước');
        }
    </script>
</body>
</html>
