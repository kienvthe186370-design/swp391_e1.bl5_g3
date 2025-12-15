<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tài khoản của tôi - Pickleball Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" type="text/css">
    <style>
        .profile-sidebar { background: #f8f9fa; padding: 20px; border-radius: 8px; }
        .profile-sidebar .nav-link { color: #333; padding: 12px 15px; border-radius: 5px; margin-bottom: 5px; }
        .profile-sidebar .nav-link:hover, .profile-sidebar .nav-link.active { background: #e53637; color: white; }
        .profile-sidebar .nav-link i { width: 20px; }
        .profile-content { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        
        /* Avatar */
        .avatar-wrapper { position: relative; width: 120px; height: 120px; margin: 0 auto 15px; }
        .avatar-img { width: 120px; height: 120px; border-radius: 50%; object-fit: cover; border: 3px solid #e53637; }
        .avatar-placeholder { width: 120px; height: 120px; border-radius: 50%; background: #e1e1e1; display: flex; align-items: center; justify-content: center; border: 3px solid #e53637; }
        .avatar-placeholder i { font-size: 50px; color: #999; }
        .avatar-upload-btn { position: absolute; bottom: 0; right: 0; width: 36px; height: 36px; background: #e53637; border-radius: 50%; display: flex; align-items: center; justify-content: center; cursor: pointer; border: 2px solid white; }
        .avatar-upload-btn i { color: white; font-size: 14px; }
        .avatar-upload-btn:hover { background: #c42b2b; }
        
        /* Address Card */
        .address-card { border: 1px solid #ddd; padding: 15px; margin-bottom: 15px; border-radius: 8px; position: relative; }
        .address-card.default { border-color: #e53637; background: #fff5f5; }
        .address-card .badge-default { position: absolute; top: 10px; right: 10px; background: #e53637; color: white; padding: 3px 8px; border-radius: 3px; font-size: 11px; }
        .address-card .actions { margin-top: 10px; }
        .btn-add-address { border: 2px dashed #ddd; padding: 30px; text-align: center; border-radius: 8px; cursor: pointer; color: #666; }
        .btn-add-address:hover { border-color: #e53637; color: #e53637; }
        
        /* Form */
        .form-group label { font-weight: 600; color: #333; }
        .form-control:focus { border-color: #e53637; box-shadow: 0 0 0 0.2rem rgba(229, 54, 55, 0.15); }
    </style>
</head>
<body>
    <%@include file="../header.jsp" %>

    <section class="breadcrumb-option">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="breadcrumb__text">
                        <h4>Tài khoản của tôi</h4>
                        <div class="breadcrumb__links">
                            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
                            <span>Tài khoản</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="spad">
        <div class="container">
            <div class="row">
                <!-- Sidebar -->
                <div class="col-lg-3">
                    <div class="profile-sidebar">
                        <div class="text-center mb-4">
                            <!-- Avatar -->
                            <div class="avatar-wrapper">
                                <c:choose>
                                    <c:when test="${not empty customer.avatar}">
                                        <img src="${pageContext.request.contextPath}/${customer.avatar}" alt="Avatar" class="avatar-img" id="avatarPreview">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="avatar-placeholder" id="avatarPlaceholder">
                                            <i class="fa fa-user"></i>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                                <label class="avatar-upload-btn" for="avatarInput" title="Đổi ảnh đại diện">
                                    <i class="fa fa-camera"></i>
                                </label>
                            </div>
                            <h5 class="mt-2 mb-1">${customer.fullName}</h5>
                            <small class="text-muted">${customer.email}</small>
                        </div>
                        <nav class="nav flex-column">
                            <a class="nav-link ${activeTab == 'profile' || activeTab == null ? 'active' : ''}" href="?tab=profile">
                                <i class="fa fa-user"></i> Thông tin cá nhân
                            </a>
                            <a class="nav-link ${activeTab == 'addresses' ? 'active' : ''}" href="?tab=addresses">
                                <i class="fa fa-map-marker"></i> Địa chỉ giao hàng
                            </a>
                            <a class="nav-link ${activeTab == 'password' ? 'active' : ''}" href="?tab=password">
                                <i class="fa fa-lock"></i> Đổi mật khẩu
                            </a>
                            <a class="nav-link" href="${pageContext.request.contextPath}/customer/orders">
                                <i class="fa fa-list-alt"></i> Đơn hàng của tôi
                            </a>
                            <a class="nav-link" href="${pageContext.request.contextPath}/logout">
                                <i class="fa fa-sign-out"></i> Đăng xuất
                            </a>
                        </nav>
                    </div>
                </div>

                <!-- Content -->
                <div class="col-lg-9">
                    <div class="profile-content">
                        <c:if test="${not empty param.success}">
                            <div class="alert alert-success alert-dismissible fade show">
                                <i class="fa fa-check-circle"></i> ${param.success}
                                <button type="button" class="close" data-dismiss="alert">&times;</button>
                            </div>
                        </c:if>
                        <c:if test="${not empty param.error}">
                            <div class="alert alert-danger alert-dismissible fade show">
                                <i class="fa fa-exclamation-circle"></i> ${param.error}
                                <button type="button" class="close" data-dismiss="alert">&times;</button>
                            </div>
                        </c:if>

                        <c:choose>
                            <c:when test="${activeTab == 'addresses'}">
                            <%-- ADDRESSES TAB --%>
                                <h4 class="mb-4"><i class="fa fa-map-marker text-danger"></i> Địa chỉ giao hàng</h4>
                                
                                <div class="row">
                                    <c:forEach var="addr" items="${addresses}">
                                        <div class="col-md-6">
                                            <div class="address-card ${addr['default'] ? 'default' : ''}" 
                                                 data-id="${addr.addressID}"
                                                 data-name="${addr.recipientName}"
                                                 data-phone="${addr.phone}"
                                                 data-street="${addr.street}"
                                                 data-ward="${addr.ward}"
                                                 data-district="${addr.district}"
                                                 data-city="${addr.city}"
                                                 data-default="${addr['default']}">
                                                <c:if test="${addr['default']}">
                                                    <span class="badge-default">Mặc định</span>
                                                </c:if>
                                                <h6><strong>${addr.recipientName}</strong></h6>
                                                <p class="mb-1"><i class="fa fa-phone"></i> ${addr.phone}</p>
                                                <p class="mb-0 text-muted"><i class="fa fa-home"></i> ${addr.fullAddress}</p>
                                                <div class="actions">
                                                    <button class="btn btn-sm btn-outline-primary" onclick="openEditModal(this)">
                                                        <i class="fa fa-edit"></i> Sửa
                                                    </button>
                                                    <c:if test="${!addr['default']}">
                                                        <button class="btn btn-sm btn-outline-success" onclick="setDefaultAddress('${addr.addressID}')">
                                                            <i class="fa fa-check"></i> Đặt mặc định
                                                        </button>
                                                        <button class="btn btn-sm btn-outline-danger" onclick="deleteAddress('${addr.addressID}')">
                                                            <i class="fa fa-trash"></i>
                                                        </button>
                                                    </c:if>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                    
                                    <div class="col-md-6">
                                        <div class="btn-add-address" data-toggle="modal" data-target="#addAddressModal">
                                            <i class="fa fa-plus fa-2x"></i>
                                            <p class="mt-2 mb-0">Thêm địa chỉ mới</p>
                                        </div>
                                    </div>
                                </div>
                            </c:when>
                            <c:when test="${activeTab == 'password'}">
                            <%-- PASSWORD TAB --%>
                                <h4 class="mb-4"><i class="fa fa-lock text-danger"></i> Đổi mật khẩu</h4>
                                <form action="${pageContext.request.contextPath}/update-profile" method="post">
                                    <input type="hidden" name="action" value="changePassword">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Mật khẩu hiện tại <span class="text-danger">*</span></label>
                                                <input type="password" name="currentPassword" class="form-control" required>
                                            </div>
                                            <div class="form-group">
                                                <label>Mật khẩu mới <span class="text-danger">*</span></label>
                                                <input type="password" name="newPassword" class="form-control" minlength="6" required>
                                                <small class="text-muted">Tối thiểu 6 ký tự</small>
                                            </div>
                                            <div class="form-group">
                                                <label>Xác nhận mật khẩu mới <span class="text-danger">*</span></label>
                                                <input type="password" name="confirmPassword" class="form-control" minlength="6" required>
                                            </div>
                                            <button type="submit" class="btn btn-primary">
                                                <i class="fa fa-save"></i> Đổi mật khẩu
                                            </button>
                                        </div>
                                    </div>
                                </form>
                            </c:when>
                            <c:otherwise>
                            <%-- PROFILE TAB (default) --%>
                                <h4 class="mb-4"><i class="fa fa-user text-danger"></i> Thông tin cá nhân</h4>
                                <form action="${pageContext.request.contextPath}/update-profile" method="post">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Họ và tên <span class="text-danger">*</span></label>
                                                <input type="text" name="fullName" class="form-control" value="${customer.fullName}" required>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Email</label>
                                                <input type="email" class="form-control" value="${customer.email}" disabled>
                                                <small class="text-muted">Email không thể thay đổi</small>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Số điện thoại</label>
                                                <input type="tel" name="phone" class="form-control" value="${customer.phone}" placeholder="VD: 0912345678">
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Giới tính</label>
                                                <select name="gender" class="form-control">
                                                    <option value="">-- Chọn --</option>
                                                    <option value="Male" ${customer.gender == 'Male' ? 'selected' : ''}>Nam</option>
                                                    <option value="Female" ${customer.gender == 'Female' ? 'selected' : ''}>Nữ</option>
                                                    <option value="Other" ${customer.gender == 'Other' ? 'selected' : ''}>Khác</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Ngày sinh</label>
                                                <input type="date" name="dateOfBirth" class="form-control" 
                                                       value="<fmt:formatDate value='${customer.dateOfBirth}' pattern='yyyy-MM-dd'/>">
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Ngày tham gia</label>
                                                <input type="text" class="form-control" 
                                                       value="<fmt:formatDate value='${customer.createdDate}' pattern='dd/MM/yyyy'/>" disabled>
                                            </div>
                                        </div>
                                    </div>
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fa fa-save"></i> Lưu thay đổi
                                    </button>
                                </form>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Hidden Avatar Upload Form -->
    <form id="avatarForm" action="${pageContext.request.contextPath}/update-profile" method="post" enctype="multipart/form-data" style="display:none;">
        <input type="hidden" name="action" value="updateAvatar">
        <input type="file" name="avatar" id="avatarInput" accept="image/*">
    </form>

    <!-- Add Address Modal -->
    <div class="modal fade" id="addAddressModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fa fa-plus"></i> Thêm địa chỉ mới</h5>
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                </div>
                <form action="${pageContext.request.contextPath}/address" method="post" id="addAddressForm">
                    <input type="hidden" name="action" value="add">
                    <input type="hidden" name="redirect" value="${redirect}">
                    <div class="modal-body">
                        <div class="form-group">
                            <label>Họ tên người nhận <span class="text-danger">*</span></label>
                            <input type="text" name="recipientName" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label>Số điện thoại <span class="text-danger">*</span></label>
                            <input type="tel" name="phone" class="form-control" required>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Tỉnh/Thành phố <span class="text-danger">*</span></label>
                                    <select name="city" id="addCity" class="form-control" required>
                                        <option value="">-- Chọn Tỉnh/TP --</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Quận/Huyện <span class="text-danger">*</span></label>
                                    <select name="district" id="addDistrict" class="form-control" required disabled>
                                        <option value="">-- Chọn Quận/Huyện --</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label>Phường/Xã</label>
                            <input type="text" name="ward" class="form-control" placeholder="VD: Dịch Vọng">
                        </div>
                        <div class="form-group">
                            <label>Địa chỉ cụ thể <span class="text-danger">*</span></label>
                            <input type="text" name="street" class="form-control" placeholder="Số nhà, tên đường..." required>
                        </div>
                        <div class="form-check">
                            <input type="checkbox" name="isDefault" class="form-check-input" id="addIsDefault">
                            <label class="form-check-label" for="addIsDefault">Đặt làm địa chỉ mặc định</label>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-primary"><i class="fa fa-save"></i> Lưu địa chỉ</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Edit Address Modal -->
    <div class="modal fade" id="editAddressModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fa fa-edit"></i> Sửa địa chỉ</h5>
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                </div>
                <form action="${pageContext.request.contextPath}/address" method="post" id="editAddressForm">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="addressId" id="editAddressId">
                    <input type="hidden" name="redirect" value="${redirect}">
                    <div class="modal-body">
                        <div class="form-group">
                            <label>Họ tên người nhận <span class="text-danger">*</span></label>
                            <input type="text" name="recipientName" id="editRecipientName" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label>Số điện thoại <span class="text-danger">*</span></label>
                            <input type="tel" name="phone" id="editPhone" class="form-control" required>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Tỉnh/Thành phố <span class="text-danger">*</span></label>
                                    <select name="city" id="editCity" class="form-control" required>
                                        <option value="">-- Chọn Tỉnh/TP --</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Quận/Huyện <span class="text-danger">*</span></label>
                                    <select name="district" id="editDistrict" class="form-control" required>
                                        <option value="">-- Chọn Quận/Huyện --</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label>Phường/Xã</label>
                            <input type="text" name="ward" id="editWard" class="form-control">
                        </div>
                        <div class="form-group">
                            <label>Địa chỉ cụ thể <span class="text-danger">*</span></label>
                            <input type="text" name="street" id="editStreet" class="form-control" required>
                        </div>
                        <div class="form-check">
                            <input type="checkbox" name="isDefault" class="form-check-input" id="editIsDefault">
                            <label class="form-check-label" for="editIsDefault">Đặt làm địa chỉ mặc định</label>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-primary"><i class="fa fa-save"></i> Cập nhật</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%@include file="../footer.jsp"%>

    <script src="${pageContext.request.contextPath}/js/jquery-3.3.1.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/bootstrap.min.js"></script>

    <script>
        var contextPath = '${pageContext.request.contextPath}';
        var redirectUrl = '${redirect}';
        var citiesData = [];
        var districtsCache = {};
        
        $(window).on('load', function() {
            $(".loader").fadeOut();
            $("#preloder").delay(200).fadeOut("slow");
        });
        setTimeout(function() {
            $(".loader").fadeOut();
            $("#preloder").fadeOut("slow");
        }, 2000);
        
        // Avatar upload
        $('#avatarInput').on('change', function() {
            if (this.files && this.files[0]) {
                var file = this.files[0];
                
                // Validate file size (max 5MB)
                if (file.size > 5 * 1024 * 1024) {
                    alert('File ảnh không được vượt quá 5MB');
                    return;
                }
                
                // Preview
                var reader = new FileReader();
                reader.onload = function(e) {
                    if ($('#avatarPreview').length) {
                        $('#avatarPreview').attr('src', e.target.result);
                    } else {
                        $('#avatarPlaceholder').replaceWith('<img src="' + e.target.result + '" alt="Avatar" class="avatar-img" id="avatarPreview">');
                    }
                };
                reader.readAsDataURL(file);
                
                // Submit form
                $('#avatarForm').submit();
            }
        });
        
        // Load cities when page loads
        $(document).ready(function() {
            loadCities();
        });
        
        function loadCities() {
            $.ajax({
                url: contextPath + '/api/goship/cities',
                method: 'GET',
                dataType: 'json',
                timeout: 10000,
                success: function(data) {
                    if (data.success && data.cities) {
                        citiesData = data.cities;
                        var options = '<option value="">-- Chọn Tỉnh/TP --</option>';
                        data.cities.forEach(function(city) {
                            options += '<option value="' + city.name + '" data-id="' + city.id + '">' + city.name + '</option>';
                        });
                        $('#addCity, #editCity').html(options);
                    }
                },
                error: function() {
                    console.log('Failed to load cities from Goship API');
                }
            });
        }
        
        // Load districts when city changes
        $('#addCity').on('change', function() {
            var cityId = $(this).find(':selected').data('id');
            loadDistricts(cityId, '#addDistrict');
        });
        
        $('#editCity').on('change', function() {
            var cityId = $(this).find(':selected').data('id');
            loadDistricts(cityId, '#editDistrict');
        });
        
        function loadDistricts(cityId, targetSelect) {
            if (!cityId) {
                $(targetSelect).html('<option value="">-- Chọn Quận/Huyện --</option>').prop('disabled', true);
                return;
            }
            
            $(targetSelect).html('<option value="">Đang tải...</option>').prop('disabled', true);
            
            // Check cache
            if (districtsCache[cityId]) {
                renderDistricts(districtsCache[cityId], targetSelect);
                return;
            }
            
            $.ajax({
                url: contextPath + '/api/goship/districts',
                method: 'GET',
                data: { cityId: cityId },
                dataType: 'json',
                timeout: 10000,
                success: function(data) {
                    if (data.success && data.districts) {
                        districtsCache[cityId] = data.districts;
                        renderDistricts(data.districts, targetSelect);
                    } else {
                        $(targetSelect).html('<option value="">-- Không có dữ liệu --</option>');
                    }
                },
                error: function() {
                    $(targetSelect).html('<option value="">-- Lỗi tải dữ liệu --</option>');
                }
            });
        }
        
        function renderDistricts(districts, targetSelect) {
            var options = '<option value="">-- Chọn Quận/Huyện --</option>';
            districts.forEach(function(district) {
                options += '<option value="' + district.name + '" data-id="' + district.id + '">' + district.name + '</option>';
            });
            $(targetSelect).html(options).prop('disabled', false);
        }
        
        function setDefaultAddress(addressId) {
            if (confirm('Đặt địa chỉ này làm mặc định?')) {
                var url = contextPath + '/address?action=setDefault&addressId=' + addressId;
                if (redirectUrl) url += '&redirect=' + encodeURIComponent(redirectUrl);
                window.location.href = url;
            }
        }
        
        function deleteAddress(addressId) {
            if (confirm('Bạn có chắc muốn xóa địa chỉ này?')) {
                var url = contextPath + '/address?action=delete&addressId=' + addressId;
                if (redirectUrl) url += '&redirect=' + encodeURIComponent(redirectUrl);
                window.location.href = url;
            }
        }
        
        function openEditModal(btn) {
            var card = $(btn).closest('.address-card');
            var addressId = card.data('id');
            var name = card.data('name');
            var phone = card.data('phone');
            var street = card.data('street');
            var ward = card.data('ward');
            var district = card.data('district');
            var city = card.data('city');
            var isDefault = card.data('default');
            
            $('#editAddressId').val(addressId);
            $('#editRecipientName').val(name);
            $('#editPhone').val(phone);
            $('#editStreet').val(street);
            $('#editWard').val(ward);
            $('#editIsDefault').prop('checked', isDefault === true || isDefault === 'true');
            
            // Set city and load districts
            $('#editCity').val(city);
            var cityId = $('#editCity').find(':selected').data('id');
            
            if (cityId) {
                // Load districts then set value
                if (districtsCache[cityId]) {
                    renderDistricts(districtsCache[cityId], '#editDistrict');
                    $('#editDistrict').val(district);
                } else {
                    $.ajax({
                        url: contextPath + '/api/goship/districts',
                        method: 'GET',
                        data: { cityId: cityId },
                        dataType: 'json',
                        success: function(data) {
                            if (data.success && data.districts) {
                                districtsCache[cityId] = data.districts;
                                renderDistricts(data.districts, '#editDistrict');
                                $('#editDistrict').val(district);
                            }
                        }
                    });
                }
            }
            
            $('#editAddressModal').modal('show');
        }
    </script>
</body>
</html>
