<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="entity.Employee" %>
<%
    Employee employee = (Employee) session.getAttribute("employee");
    if (employee == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    boolean isEdit = request.getAttribute("voucher") != null;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><%= isEdit ? "Sửa" : "Thêm" %> Voucher - Admin</title>

  <!-- Google Font: Source Sans Pro -->
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
  <!-- Font Awesome -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/fontawesome-free/css/all.min.css">
  <!-- Theme style -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/css/adminlte.min.css">
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">

  <!-- Navbar -->
  <jsp:include page="includes/admin-header.jsp" />

  <!-- Sidebar -->
  <jsp:include page="includes/admin-sidebar.jsp" />

  <!-- Content Wrapper -->
  <div class="content-wrapper">
    <!-- Content Header -->
    <section class="content-header">
      <div class="container-fluid">
        <div class="row mb-2">
          <div class="col-sm-6">
            <h1><i class="fas fa-ticket-alt"></i> <%= isEdit ? "Sửa" : "Thêm" %> Voucher</h1>
          </div>
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp">Home</a></li>
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/admin/voucher">Voucher</a></li>
              <li class="breadcrumb-item active"><%= isEdit ? "Sửa" : "Thêm" %></li>
            </ol>
          </div>
        </div>
      </div>
    </section>

    <!-- Main content -->
    <section class="content">
      <div class="container-fluid">
        
        <form method="post" action="<%= request.getContextPath() %>/admin/voucher" id="voucherForm">
          <input type="hidden" name="action" value="<%= isEdit ? "update" : "add" %>">
          <c:if test="${voucher != null}">
            <input type="hidden" name="id" value="${voucher.voucherID}">
          </c:if>
          
          <div class="row">
            <!-- Left Column -->
            <div class="col-md-6">
              
              <!-- Basic Information -->
              <div class="card card-primary">
                <div class="card-header">
                  <h3 class="card-title">Thông tin cơ bản</h3>
                </div>
                <div class="card-body">
                  
                  <div class="form-group">
                    <label for="voucherCode">Mã Voucher <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="voucherCode" name="voucherCode" 
                           value="${voucher.voucherCode}" required maxlength="50"
                           placeholder="VD: SUMMER2024, FREESHIP50">
                    <small class="form-text text-muted">Mã voucher sẽ tự động chuyển thành chữ IN HOA</small>
                  </div>
                  
                  <div class="form-group">
                    <label for="voucherName">Tên Voucher <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="voucherName" name="voucherName" 
                           value="${voucher.voucherName}" required maxlength="200"
                           placeholder="VD: Giảm giá mùa hè 2024">
                  </div>
                  
                  <div class="form-group">
                    <label for="description">Mô tả</label>
                    <textarea class="form-control" id="description" name="description" rows="3"
                              placeholder="Mô tả chi tiết về voucher...">${voucher.description}</textarea>
                  </div>
                  
                </div>
              </div>
              
              <!-- Discount Settings -->
              <div class="card card-info">
                <div class="card-header">
                  <h3 class="card-title">Cài đặt giảm giá</h3>
                </div>
                <div class="card-body">
                  
                  <div class="form-group">
                    <label for="discountType">Loại giảm giá <span class="text-danger">*</span></label>
                    <select class="form-control" id="discountType" name="discountType" required>
                      <option value="percentage" ${voucher.discountType == 'percentage' ? 'selected' : ''}>Phần trăm (%)</option>
                      <option value="fixed" ${voucher.discountType == 'fixed' ? 'selected' : ''}>Số tiền cố định (₫)</option>
                    </select>
                  </div>
                  
                  <div class="form-group">
                    <label for="discountValue">Giá trị giảm <span class="text-danger">*</span></label>
                    <div class="input-group">
                      <input type="number" class="form-control" id="discountValue" name="discountValue" 
                             value="${voucher.discountValue}" required min="0" step="0.01"
                             placeholder="VD: 10 hoặc 50000">
                      <div class="input-group-append">
                        <span class="input-group-text" id="discountUnit">%</span>
                      </div>
                    </div>
                    <small class="form-text text-muted">
                      Nếu chọn phần trăm: nhập 10 = giảm 10%<br>
                      Nếu chọn cố định: nhập 50000 = giảm 50,000₫
                    </small>
                  </div>
                  
                  <div class="form-group">
                    <label for="minOrderValue">Giá trị đơn hàng tối thiểu <span class="text-danger">*</span></label>
                    <div class="input-group">
                      <input type="number" class="form-control" id="minOrderValue" name="minOrderValue" 
                             value="${voucher.minOrderValue}" required min="0" step="1000"
                             placeholder="VD: 100000">
                      <div class="input-group-append">
                        <span class="input-group-text">₫</span>
                      </div>
                    </div>
                    <small class="form-text text-muted">Đơn hàng phải đạt giá trị này mới áp dụng được voucher</small>
                  </div>
                  
                  <div class="form-group">
                    <label for="maxDiscountAmount">Giảm tối đa (chỉ cho loại %)</label>
                    <div class="input-group">
                      <input type="number" class="form-control" id="maxDiscountAmount" name="maxDiscountAmount" 
                             value="${voucher.maxDiscountAmount}" min="0" step="1000"
                             placeholder="VD: 100000">
                      <div class="input-group-append">
                        <span class="input-group-text">₫</span>
                      </div>
                    </div>
                    <small class="form-text text-muted">Để trống nếu không giới hạn</small>
                  </div>
                  
                </div>
              </div>
              
            </div>
            
            <!-- Right Column -->
            <div class="col-md-6">
              
              <!-- Usage Settings -->
              <div class="card card-warning">
                <div class="card-header">
                  <h3 class="card-title">Cài đặt sử dụng</h3>
                </div>
                <div class="card-body">
                  
                  <div class="form-group">
                    <label for="maxUsage">Số lần sử dụng tối đa (tổng)</label>
                    <input type="number" class="form-control" id="maxUsage" name="maxUsage" 
                           value="${voucher.maxUsage}" min="1" step="1"
                           placeholder="VD: 100">
                    <small class="form-text text-muted">Tổng số lần voucher có thể được sử dụng bởi tất cả khách hàng. Để trống nếu không giới hạn</small>
                  </div>
                  
                  <div class="form-group">
                    <label for="maxUsagePerCustomer">
                      Số lần sử dụng tối đa / khách hàng 
                      <span class="text-danger">*</span>
                    </label>
                    <input type="number" class="form-control" id="maxUsagePerCustomer" name="maxUsagePerCustomer" 
                           value="${voucher.maxUsagePerCustomer != null ? voucher.maxUsagePerCustomer : 1}" 
                           min="1" step="1" required
                           placeholder="VD: 1">
                    <small class="form-text text-muted">
                      <i class="fas fa-info-circle text-info"></i> 
                      Mỗi khách hàng chỉ được sử dụng voucher này tối đa bao nhiêu lần. 
                      <strong>Mặc định: 1 lần</strong>
                    </small>
                    <small class="form-text text-warning">
                      <i class="fas fa-exclamation-triangle"></i> 
                      <strong>Lưu ý:</strong> Giá trị này phải ≤ "Số lần sử dụng tối đa (tổng)" nếu có giới hạn tổng.
                    </small>
                  </div>
                  
                  <c:if test="${voucher != null}">
                    <div class="form-group">
                      <label>Đã sử dụng (tổng)</label>
                      <input type="text" class="form-control" value="${voucher.usedCount}" readonly>
                    </div>
                  </c:if>
                  
                  <div class="form-group">
                    <label for="startDate">Ngày bắt đầu <span class="text-danger">*</span></label>
                    <input type="datetime-local" class="form-control" id="startDate" name="startDate" required
                           value="<fmt:formatDate value='${voucher.startDate}' pattern='yyyy-MM-dd\'T\'HH:mm'/>">
                  </div>
                  
                  <div class="form-group">
                    <label for="endDate">Ngày kết thúc <span class="text-danger">*</span></label>
                    <input type="datetime-local" class="form-control" id="endDate" name="endDate" required
                           value="<fmt:formatDate value='${voucher.endDate}' pattern='yyyy-MM-dd\'T\'HH:mm'/>">
                  </div>
                  
                </div>
              </div>
              
              <!-- Status Settings -->
              <div class="card card-success">
                <div class="card-header">
                  <h3 class="card-title">Trạng thái</h3>
                </div>
                <div class="card-body">
                  
                  <div class="form-group">
                    <div class="custom-control custom-switch">
                      <input type="checkbox" class="custom-control-input" id="isActive" name="isActive" 
                             ${voucher == null || voucher.isActive ? 'checked' : ''}>
                      <label class="custom-control-label" for="isActive">Kích hoạt voucher</label>
                    </div>
                    <small class="form-text text-muted">Chỉ voucher được kích hoạt mới có thể sử dụng</small>
                  </div>
                  
                  <div class="form-group">
                    <div class="custom-control custom-switch">
                      <input type="checkbox" class="custom-control-input" id="isPrivate" name="isPrivate" 
                             ${voucher.isPrivate ? 'checked' : ''}>
                      <label class="custom-control-label" for="isPrivate">Voucher riêng tư</label>
                    </div>
                    <small class="form-text text-muted">Voucher riêng tư chỉ dành cho khách hàng được chỉ định</small>
                  </div>
                  
                </div>
              </div>
              
              <!-- Action Buttons -->
              <div class="card">
                <div class="card-body">
                  <button type="submit" class="btn btn-primary btn-lg btn-block">
                    <i class="fas fa-save"></i> <%= isEdit ? "Cập nhật" : "Thêm mới" %>
                  </button>
                  <a href="<%= request.getContextPath() %>/admin/voucher" class="btn btn-secondary btn-lg btn-block">
                    <i class="fas fa-times"></i> Hủy
                  </a>
                </div>
              </div>
              
            </div>
          </div>
          
        </form>
        
      </div>
    </section>
  </div>

  <!-- Footer -->
  <jsp:include page="includes/admin-footer.jsp" />
</div>

<!-- jQuery -->
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/jquery/jquery.min.js"></script>
<!-- Bootstrap 4 -->
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<!-- AdminLTE App -->
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/js/adminlte.min.js"></script>

<script>
  $(document).ready(function() {
    
    // Update discount unit based on discount type
    $('#discountType').change(function() {
      var type = $(this).val();
      if (type === 'percentage') {
        $('#discountUnit').text('%');
        $('#discountValue').attr('max', '100');
        $('#maxDiscountAmount').prop('disabled', false);
      } else {
        $('#discountUnit').text('₫');
        $('#discountValue').removeAttr('max');
        $('#maxDiscountAmount').prop('disabled', true).val('');
      }
    });
    
    // Trigger on page load
    $('#discountType').trigger('change');
    
    // Form validation
    $('#voucherForm').submit(function(e) {
      var startDate = new Date($('#startDate').val());
      var endDate = new Date($('#endDate').val());
      
      if (endDate <= startDate) {
        alert('Ngày kết thúc phải sau ngày bắt đầu!');
        e.preventDefault();
        return false;
      }
      
      var discountType = $('#discountType').val();
      var discountValue = parseFloat($('#discountValue').val());
      
      if (discountType === 'percentage' && discountValue > 100) {
        alert('Giá trị giảm phần trăm không được vượt quá 100%!');
        e.preventDefault();
        return false;
      }
      
      // Validate MaxUsagePerCustomer <= MaxUsage
      var maxUsage = $('#maxUsage').val();
      var maxUsagePerCustomer = parseInt($('#maxUsagePerCustomer').val());
      
      if (maxUsage && maxUsage.trim() !== '') {
        var maxUsageInt = parseInt(maxUsage);
        if (maxUsagePerCustomer > maxUsageInt) {
          alert('Số lần sử dụng tối đa / khách hàng (' + maxUsagePerCustomer + ') không được lớn hơn tổng số lần sử dụng (' + maxUsageInt + ')!');
          e.preventDefault();
          return false;
        }
      }
      
      return true;
    });
    
    // Auto uppercase voucher code
    $('#voucherCode').on('input', function() {
      $(this).val($(this).val().toUpperCase());
    });
    
  });
</script>

</body>
</html>
