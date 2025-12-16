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

            <form action="${pageContext.request.contextPath}/rfq/submit" method="POST" id="rfqForm">
                <!-- Company Info -->
                <div class="card mb-4">
                    <div class="card-body">
                        <div class="section-header"><h5 class="mb-0"><i class="fa fa-building"></i> Thông Tin Công Ty</h5></div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="required-field">Tên Công Ty</label>
                                <input type="text" class="form-control" name="companyName" required>
                            </div>
                            <div class="col-md-3 mb-3">
                                <label>Mã Số Thuế</label>
                                <input type="text" class="form-control" name="taxID">
                            </div>
                            <div class="col-md-3 mb-3">
                                <label>Loại Hình Kinh Doanh</label>
                                <select class="form-control" name="businessType">
                                    <option value="">-- Chọn --</option>
                                    <option value="Retailer">Bán lẻ</option>
                                    <option value="Distributor">Nhà phân phối</option>
                                    <option value="Other">Khác</option>
                                </select>
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
                                <input type="text" class="form-control" name="contactPerson" value="${customer.fullName}" required>
                            </div>
                            <div class="col-md-4 mb-3">
                                <label class="required-field">Số Điện Thoại</label>
                                <input type="tel" class="form-control" name="contactPhone" value="${customer.phone}" required>
                            </div>
                            <div class="col-md-4 mb-3">
                                <label>Email</label>
                                <input type="email" class="form-control" name="contactEmail" value="${customer.email}">
                            </div>
                            <div class="col-12 mb-3">
                                <label>Liên Hệ Dự Phòng</label>
                                <input type="text" class="form-control" name="alternativeContact">
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
                                <input type="hidden" name="deliveryCityId" id="deliveryCityId">
                            </div>
                            <div class="col-md-4 mb-3">
                                <label class="required-field">Quận/Huyện</label>
                                <select class="form-control" name="deliveryDistrict" id="deliveryDistrict" required disabled>
                                    <option value="">-- Chọn tỉnh/thành trước --</option>
                                </select>
                                <input type="hidden" name="deliveryDistrictId" id="deliveryDistrictId">
                            </div>
                            <div class="col-md-4 mb-3">
                                <label class="required-field">Ngày Mong Muốn Nhận Hàng</label>
                                <input type="date" class="form-control" name="requestedDeliveryDate" id="deliveryDate" required>
                            </div>
                            <div class="col-md-8 mb-3">
                                <label class="required-field">Địa Chỉ Chi Tiết</label>
                                <input type="text" class="form-control" name="deliveryStreet" id="deliveryStreet" placeholder="Số nhà, tên đường, phường/xã..." required>
                                <input type="hidden" name="deliveryAddress" id="deliveryAddress">
                            </div>
                            <div class="col-md-4 mb-3">
                                <label>Phường/Xã</label>
                                <select class="form-control" name="deliveryWard" id="deliveryWard">
                                    <option value="">-- Chọn quận/huyện trước --</option>
                                </select>
                                <input type="hidden" name="deliveryWardId" id="deliveryWardId">
                            </div>
                            <div class="col-12 mb-3">
                                <label>Yêu Cầu Đặc Biệt</label>
                                <textarea class="form-control" name="deliveryInstructions" rows="2"></textarea>
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
                            <div class="product-row" id="product-0">
                                <div class="row">
                                    <div class="col-md-5 mb-2">
                                        <label class="required-field">Sản Phẩm</label>
                                        <select class="form-control product-select" name="productId" required>
                                            <option value="">-- Chọn sản phẩm --</option>
                                            <c:forEach var="p" items="${products}">
                                                <option value="${p['productID']}">${p['productName']}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="col-md-3 mb-2">
                                        <label>Biến Thể</label>
                                        <select class="form-control variant-select" name="variantId">
                                            <option value="">-- Tất cả --</option>
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
                                    <div class="col-12 mb-2">
                                        <label>Yêu Cầu Đặc Biệt</label>
                                        <input type="text" class="form-control" name="specialRequirements">
                                    </div>
                                </div>
                            </div>
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
                                <label class="required-field">Hình Thức Thanh Toán Mong Muốn</label>
                                <select class="form-control" name="preferredPaymentMethod" required>
                                    <option value="">-- Chọn --</option>
                                    <option value="BankTransfer">Chuyển khoản ngân hàng</option>
                                    <option value="COD">Thanh toán khi nhận hàng (COD) + Cọc 50%</option>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <!-- Placeholder for alignment -->
                            </div>
                            <div class="col-12 mb-3">
                                <label>Ghi Chú Thêm</label>
                                <textarea class="form-control" name="customerNotes" rows="3" placeholder="Mọi yêu cầu đặc biệt hoặc thông tin bổ sung..."></textarea>
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
                                <i class="fa fa-paper-plane"></i> Gửi Yêu Cầu Báo Giá
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
    <script>
        var contextPath = '${pageContext.request.contextPath}';
        
        // Store products data for dynamic rows
        var productsData = [];
        
        $(document).ready(function() {
            // Populate products data from select options
            $('.product-select').first().find('option').each(function() {
                if ($(this).val()) {
                    productsData.push({id: $(this).val(), name: $(this).text()});
                }
            });
            
            // Set min date to tomorrow
            var tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            $('#deliveryDate').attr('min', tomorrow.toISOString().split('T')[0]);
            
            // Bind change event for product select
            $(document).on('change', '.product-select', function() {
                var productId = $(this).val();
                var variantSelect = $(this).closest('.product-row').find('.variant-select');
                loadVariants(productId, variantSelect);
            });
            
            // Load cities
            loadCities();
            
            // City change event
            $('#deliveryCity').change(function() {
                var cityId = $(this).find(':selected').data('id');
                var cityName = $(this).val();
                $('#deliveryCityId').val(cityId);
                if (cityId) {
                    loadDistricts(cityId);
                } else {
                    $('#deliveryDistrict').html('<option value="">-- Chọn tỉnh/thành trước --</option>').prop('disabled', true);
                    $('#deliveryWard').html('<option value="">-- Chọn quận/huyện trước --</option>');
                }
                updateFullAddress();
            });
            
            // District change event
            $('#deliveryDistrict').change(function() {
                var districtId = $(this).find(':selected').data('id');
                $('#deliveryDistrictId').val(districtId);
                if (districtId) {
                    loadWards(districtId);
                } else {
                    $('#deliveryWard').html('<option value="">-- Chọn quận/huyện trước --</option>');
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
                },
                error: function() {
                    $('#deliveryCity').html('<option value="">-- Lỗi tải dữ liệu --</option>');
                }
            });
        }
        
        function loadDistricts(cityId) {
            $('#deliveryDistrict').html('<option value="">-- Đang tải... --</option>').prop('disabled', true);
            $('#deliveryWard').html('<option value="">-- Chọn quận/huyện trước --</option>');
            
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
                },
                error: function() {
                    $('#deliveryDistrict').html('<option value="">-- Lỗi tải dữ liệu --</option>').prop('disabled', false);
                }
            });
        }
        
        function loadWards(districtId) {
            $('#deliveryWard').html('<option value="">-- Đang tải... --</option>');
            
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
                    $('#deliveryWard').html(options);
                },
                error: function() {
                    $('#deliveryWard').html('<option value="">-- Không có dữ liệu --</option>');
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
            variantSelect.html('<option value="">-- Đang tải... --</option>');
            
            if (!productId) {
                variantSelect.html('<option value="">-- Tất cả --</option>');
                return;
            }
            
            $.ajax({
                url: contextPath + '/api/product-variants',
                type: 'GET',
                data: { productId: productId },
                dataType: 'json',
                success: function(variants) {
                    var options = '<option value="">-- Tất cả --</option>';
                    if (variants && variants.length > 0) {
                        for (var i = 0; i < variants.length; i++) {
                            var v = variants[i];
                            if (v.isActive) {
                                var price = v.sellingPrice ? new Intl.NumberFormat('vi-VN').format(v.sellingPrice) + '₫' : '';
                                var stock = v.stock ? ' (Kho: ' + v.stock + ')' : '';
                                options += '<option value="' + v.variantId + '">' + v.sku + ' - ' + price + stock + '</option>';
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
                productOptions += '<option value="' + productsData[i].id + '">' + productsData[i].name + '</option>';
            }
            
            var newRow = 
                '<div class="product-row" id="product-' + count + '">' +
                    '<div class="row">' +
                        '<div class="col-md-5 mb-2">' +
                            '<label class="required-field">Sản Phẩm</label>' +
                            '<select class="form-control product-select" name="productId" required>' +
                                productOptions +
                            '</select>' +
                        '</div>' +
                        '<div class="col-md-3 mb-2">' +
                            '<label>Biến Thể</label>' +
                            '<select class="form-control variant-select" name="variantId">' +
                                '<option value="">-- Tất cả --</option>' +
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
                        '<div class="col-12 mb-2">' +
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
        
        // Validate form before submit
        $('#rfqForm').on('submit', function(e) {
            var isValid = true;
            var errorMessages = [];
            
            // Check minimum quantity for each product
            $('.quantity-input').each(function(index) {
                var qty = parseInt($(this).val()) || 0;
                if (qty < 20) {
                    isValid = false;
                    var productName = $(this).closest('.product-row').find('.product-select option:selected').text();
                    errorMessages.push('Sản phẩm "' + productName + '" phải có số lượng tối thiểu 20.');
                    $(this).addClass('is-invalid');
                } else {
                    $(this).removeClass('is-invalid');
                }
            });
            
            if (!isValid) {
                e.preventDefault();
                alert('Lỗi:\n' + errorMessages.join('\n'));
                return false;
            }
            
            return true;
        });
        
        // Real-time validation on quantity change
        $(document).on('change input', '.quantity-input', function() {
            var qty = parseInt($(this).val()) || 0;
            if (qty < 20) {
                $(this).addClass('is-invalid');
            } else {
                $(this).removeClass('is-invalid');
            }
        });
    </script>
</body>
</html>
