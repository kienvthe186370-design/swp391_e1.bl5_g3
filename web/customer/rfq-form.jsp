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
                                    <input type="text" class="form-control" name="companyName" value="${draftRfq.companyName}" maxlength="100">
                            </div>
                            <div class="col-md-3 mb-3">
                                <label>Mã Số Thuế</label>
                                <input type="text" class="form-control" name="taxID" value="${draftRfq.taxID}" maxlength="20">
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
                                <input type="text" class="form-control" name="contactPerson" id="contactPerson" value="${not empty draftRfq.contactPerson ? draftRfq.contactPerson : customer.fullName}" required maxlength="50">
                                <small class="text-danger d-none" id="contactPersonError"></small>
                            </div>
                            <div class="col-md-4 mb-3">
                                <label class="required-field">Số Điện Thoại</label>
                                <input type="tel" class="form-control" name="contactPhone" id="contactPhone" value="${not empty draftRfq.contactPhone ? draftRfq.contactPhone : customer.phone}" required maxlength="15">
                                <small class="text-danger d-none" id="contactPhoneError"></small>
                            </div>
                            <div class="col-md-4 mb-3">
                                <label class="required-field">Email</label>
                                <input type="email" class="form-control" name="contactEmail" id="contactEmail" value="${not empty draftRfq.contactEmail ? draftRfq.contactEmail : customer.email}" required maxlength="50">
                                <small class="text-danger d-none" id="contactEmailError"></small>
                            </div>
                            <div class="col-12 mb-3">
                                <label>Liên Hệ Dự Phòng</label>
                                <input type="text" class="form-control" name="alternativeContact" value="${draftRfq.alternativeContact}" maxlength="100">
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
                            <div class="col-md-8 mb-3">
                                <label class="required-field">Địa Chỉ Chi Tiết</label>
                                <input type="text" class="form-control" name="deliveryStreet" id="deliveryStreet" placeholder="Số nhà, tên đường..." value="${draftRfq.deliveryStreet}" required maxlength="200">
                                <input type="hidden" name="deliveryAddress" id="deliveryAddress" value="${draftRfq.deliveryAddress}">
                            </div>
                            <div class="col-md-4 mb-3">
                                <label class="required-field">Ngày Mong Muốn Nhận Hàng</label>
                                <input type="text" class="form-control" name="requestedDeliveryDate" id="deliveryDate" placeholder="dd/mm/yyyy" required autocomplete="off">
                                <small class="text-muted">Chọn ngày bạn muốn nhận hàng</small>
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
    <script src="${pageContext.request.contextPath}/js/main.js"></script>
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
            
            // Initialize delivery date picker
            initDeliveryDatePicker();
            
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
                                var selected = (selectedVariantId && v.variantId == selectedVariantId) ? ' selected' : '';
                                options += '<option value="' + v.variantId + '"' + selected + '>' + v.sku + '</option>';
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
        
        // ===== Validation Functions =====
        // Validate người liên hệ: không được toàn số hoặc ký tự đặc biệt
        function validateContactPerson(value) {
            if (!value || value.trim() === '') return { valid: false, message: 'Vui lòng nhập tên người liên hệ' };
            var trimmed = value.trim();
            // Không được toàn số
            if (/^\d+$/.test(trimmed)) return { valid: false, message: 'Tên không được chỉ chứa số' };
            // Không được toàn ký tự đặc biệt
            if (/^[^a-zA-ZÀ-ỹ\s]+$/.test(trimmed)) return { valid: false, message: 'Tên không hợp lệ' };
            // Phải có ít nhất 1 chữ cái
            if (!/[a-zA-ZÀ-ỹ]/.test(trimmed)) return { valid: false, message: 'Tên phải chứa ít nhất một chữ cái' };
            return { valid: true };
        }
        
        // Validate số điện thoại Việt Nam
        function validateVietnamesePhone(value) {
            if (!value || value.trim() === '') return { valid: false, message: 'Vui lòng nhập số điện thoại' };
            var phone = value.trim().replace(/\s/g, '');
            // Số điện thoại VN: 10 số, bắt đầu bằng số 0
            var vnPhoneRegex = /^0\d{9}$/;
            if (!vnPhoneRegex.test(phone)) return { valid: false, message: 'Số điện thoại phải có 10 số và bắt đầu bằng số 0' };
            return { valid: true };
        }
        
        // Validate email
        function validateEmail(value) {
            if (!value || value.trim() === '') return { valid: false, message: 'Vui lòng nhập email' };
            var email = value.trim();
            var emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            if (!emailRegex.test(email)) return { valid: false, message: 'Email không hợp lệ' };
            return { valid: true };
        }
        
        // Show/hide error message
        function showFieldError(fieldId, errorId, result) {
            var field = $('#' + fieldId);
            var error = $('#' + errorId);
            if (!result.valid) {
                field.addClass('is-invalid');
                error.text(result.message).removeClass('d-none');
                return false;
            } else {
                field.removeClass('is-invalid');
                error.addClass('d-none');
                return true;
            }
        }
        
        // Real-time validation on blur
        $('#contactPerson').on('blur', function() {
            showFieldError('contactPerson', 'contactPersonError', validateContactPerson($(this).val()));
        });
        $('#contactPhone').on('blur', function() {
            showFieldError('contactPhone', 'contactPhoneError', validateVietnamesePhone($(this).val()));
        });
        $('#contactEmail').on('blur', function() {
            showFieldError('contactEmail', 'contactEmailError', validateEmail($(this).val()));
        });
        
        // Prevent non-numeric input in quantity fields
        $(document).on('keypress', '.quantity-input', function(e) {
            if (e.which < 48 || e.which > 57) {
                e.preventDefault();
            }
        });
        $(document).on('paste', '.quantity-input', function(e) {
            var pastedData = e.originalEvent.clipboardData.getData('text');
            if (!/^\d+$/.test(pastedData)) {
                e.preventDefault();
            }
        });
        
        // Validate form before submit
        $('#rfqForm').on('submit', function(e) {
            let ok = true;
            var errorMessages = [];
            
            // Validate contact person
            var contactResult = validateContactPerson($('#contactPerson').val());
            if (!showFieldError('contactPerson', 'contactPersonError', contactResult)) {
                ok = false;
                errorMessages.push(contactResult.message);
            }
            
            // Validate phone
            var phoneResult = validateVietnamesePhone($('#contactPhone').val());
            if (!showFieldError('contactPhone', 'contactPhoneError', phoneResult)) {
                ok = false;
                errorMessages.push(phoneResult.message);
            }
            
            // Validate email
            var emailResult = validateEmail($('#contactEmail').val());
            if (!showFieldError('contactEmail', 'contactEmailError', emailResult)) {
                ok = false;
                errorMessages.push(emailResult.message);
            }
            
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
            
            // Check delivery address (city, district, ward)
            if (!$('#deliveryCity').val()) {
                ok = false;
                $('#deliveryCity').addClass('is-invalid');
                errorMessages.push('Vui lòng chọn Tỉnh/Thành phố');
            } else {
                $('#deliveryCity').removeClass('is-invalid');
            }
            
            if (!$('#deliveryDistrict').val()) {
                ok = false;
                $('#deliveryDistrict').addClass('is-invalid');
                errorMessages.push('Vui lòng chọn Quận/Huyện');
            } else {
                $('#deliveryDistrict').removeClass('is-invalid');
            }
            
            if (!$('#deliveryWard').val()) {
                ok = false;
                $('#deliveryWard').addClass('is-invalid');
                errorMessages.push('Vui lòng chọn Phường/Xã');
            } else {
                $('#deliveryWard').removeClass('is-invalid');
            }
            
            // Check delivery street
            if (!$('#deliveryStreet').val() || $('#deliveryStreet').val().trim() === '') {
                ok = false;
                $('#deliveryStreet').addClass('is-invalid');
                errorMessages.push('Vui lòng nhập địa chỉ chi tiết');
            } else {
                $('#deliveryStreet').removeClass('is-invalid');
            }
            
            // Check delivery date
            if (!$('#deliveryDate').val()) {
                ok = false;
                $('#deliveryDate').addClass('is-invalid');
                errorMessages.push('Vui lòng chọn ngày mong muốn nhận hàng');
            } else {
                $('#deliveryDate').removeClass('is-invalid');
            }
            
            if (!ok) {
                e.preventDefault();
                if (errorMessages.length > 0) {
                    alert('Vui lòng kiểm tra lại thông tin:\n- ' + errorMessages.join('\n- '));
                }
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
        
        // ===== Delivery Date Functions =====
        // Draft delivery date from server
        var draftDeliveryDate = '<fmt:formatDate value="${draftRfq.requestedDeliveryDate}" pattern="dd/MM/yyyy"/>';
        
        function initDeliveryDatePicker() {
            var tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1); // Minimum tomorrow
            
            // Initialize datepicker with Vietnamese locale and dd/mm/yyyy format
            $('#deliveryDate').datepicker({
                format: 'dd/mm/yyyy',
                language: 'vi',
                startDate: tomorrow,
                autoclose: true,
                todayHighlight: true
            });
            
            // Set draft delivery date if exists (already formatted as dd/MM/yyyy)
            if (draftDeliveryDate && draftDeliveryDate.trim() !== '') {
                $('#deliveryDate').datepicker('setDate', draftDeliveryDate.trim());
            }
        }
    </script>
</body>
</html>
