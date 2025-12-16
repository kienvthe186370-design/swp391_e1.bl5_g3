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
    boolean isEdit = request.getAttribute("campaign") != null;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><%= isEdit ? "Sửa" : "Thêm" %> Chiến dịch Giảm giá - Admin</title>

  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/fontawesome-free/css/all.min.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/css/adminlte.min.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/tempusdominus-bootstrap-4/css/tempusdominus-bootstrap-4.min.css">
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
            <h1><i class="fas fa-percentage"></i> <%= isEdit ? "Sửa" : "Thêm" %> Chiến dịch Giảm giá</h1>
          </div>
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp">Home</a></li>
              <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/admin/discount">Chiến dịch</a></li>
              <li class="breadcrumb-item active"><%= isEdit ? "Sửa" : "Thêm" %></li>
            </ol>
          </div>
        </div>
      </div>
    </section>

    <section class="content">
      <div class="container-fluid">
        
        <form method="post" action="<%= request.getContextPath() %>/admin/discount">
          <input type="hidden" name="action" value="<%= isEdit ? "update" : "add" %>">
          <c:if test="${campaign != null}">
            <input type="hidden" name="id" value="${campaign.discountID}">
          </c:if>
          
          <div class="row">
            <!-- Left Column -->
            <div class="col-md-8">
              <!-- Campaign Info Card -->
              <div class="card card-primary">
                <div class="card-header">
                  <h3 class="card-title">Thông tin chiến dịch</h3>
                </div>
                <div class="card-body">
                  <div class="form-group">
                    <label for="campaignName">Tên chiến dịch <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="campaignName" name="campaignName" 
                           value="${campaign != null ? campaign.campaignName : ''}" 
                           placeholder="VD: Flash Sale Cuối Tuần" required>
                  </div>
                  
                  <div class="row">
                    <div class="col-md-6">
                      <div class="form-group">
                        <label for="discountType">Loại giảm giá <span class="text-danger">*</span></label>
                        <select class="form-control" id="discountType" name="discountType" required onchange="toggleMaxDiscount()">
                          <option value="percentage" ${campaign == null || campaign.discountType == 'percentage' ? 'selected' : ''}>Phần trăm (%)</option>
                          <option value="fixed" ${campaign != null && campaign.discountType == 'fixed' ? 'selected' : ''}>Số tiền cố định (₫)</option>
                        </select>
                      </div>
                    </div>
                    <div class="col-md-6">
                      <div class="form-group">
                        <label for="discountValue">Giá trị giảm <span class="text-danger">*</span></label>
                        <div class="input-group">
                          <input type="number" class="form-control" id="discountValue" name="discountValue" 
                                 value="${campaign != null ? campaign.discountValue : ''}" 
                                 min="0" step="0.01" placeholder="VD: 20" required>
                          <div class="input-group-append">
                            <span class="input-group-text" id="discountUnit">%</span>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                  
                  <div class="form-group" id="maxDiscountGroup">
                    <label for="maxDiscountAmount">Giảm tối đa (₫)</label>
                    <input type="number" class="form-control" id="maxDiscountAmount" name="maxDiscountAmount" 
                           value="${campaign != null ? campaign.maxDiscountAmount : ''}" 
                           min="0" step="1000" placeholder="VD: 100000">
                    <small class="form-text text-muted">Chỉ áp dụng cho giảm theo phần trăm. Để trống nếu không giới hạn.</small>
                  </div>
                </div>
              </div>
              
              <!-- Apply Scope Card -->
              <div class="card card-info">
                <div class="card-header">
                  <h3 class="card-title">Phạm vi áp dụng</h3>
                </div>
                <div class="card-body">
                  <div class="form-group">
                    <label for="appliedToType">Áp dụng cho <span class="text-danger">*</span></label>
                    <select class="form-control" id="appliedToType" name="appliedToType" required onchange="toggleAppliedToID()">
                      <option value="all" ${campaign == null || campaign.appliedToType == 'all' ? 'selected' : ''}>Tất cả sản phẩm</option>
                      <option value="category" ${campaign != null && campaign.appliedToType == 'category' ? 'selected' : ''}>Danh mục cụ thể</option>
                      <option value="product" ${campaign != null && campaign.appliedToType == 'product' ? 'selected' : ''}>Sản phẩm cụ thể</option>
                      <option value="brand" ${campaign != null && campaign.appliedToType == 'brand' ? 'selected' : ''}>Thương hiệu cụ thể</option>
                    </select>
                  </div>
                  
                  <!-- Category Selection -->
                  <div class="form-group" id="categoryGroup" style="display: none;">
                    <label for="categoryID">Chọn danh mục</label>
                    <select class="form-control" id="categoryID" name="appliedToID">
                      <option value="">-- Chọn danh mục --</option>
                      <c:forEach var="category" items="${categories}">
                        <option value="${category.categoryID}" 
                                ${campaign != null && campaign.appliedToType == 'category' && campaign.appliedToID == category.categoryID ? 'selected' : ''}>
                          ${category.categoryName}
                        </option>
                      </c:forEach>
                    </select>
                  </div>
                  
                  <!-- Product Selection -->
                  <div class="form-group" id="productGroup" style="display: none;">
                    <label for="productID">Chọn sản phẩm</label>
                    <select class="form-control" id="productID" name="appliedToID">
                      <option value="">-- Chọn sản phẩm --</option>
                      <c:forEach var="product" items="${products}">
                        <option value="${product.productID}" 
                                ${campaign != null && campaign.appliedToType == 'product' && campaign.appliedToID == product.productID ? 'selected' : ''}>
                          ${product.productName}
                        </option>
                      </c:forEach>
                    </select>
                  </div>
                  
                  <!-- Brand Selection -->
                  <div class="form-group" id="brandGroup" style="display: none;">
                    <label for="brandID">Chọn thương hiệu</label>
                    <select class="form-control" id="brandID" name="appliedToID">
                      <option value="">-- Chọn thương hiệu --</option>
                      <c:forEach var="brand" items="${brands}">
                        <option value="${brand.brandID}" 
                                ${campaign != null && campaign.appliedToType == 'brand' && campaign.appliedToID == brand.brandID ? 'selected' : ''}>
                          ${brand.brandName}
                        </option>
                      </c:forEach>
                    </select>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- Right Column -->
            <div class="col-md-4">
              <!-- Time Range Card -->
              <div class="card card-warning">
                <div class="card-header">
                  <h3 class="card-title">Thời gian áp dụng</h3>
                </div>
                <div class="card-body">
                  <div class="form-group">
                    <label for="startDate">Ngày bắt đầu <span class="text-danger">*</span></label>
                    <input type="datetime-local" class="form-control" id="startDate" name="startDate" 
                           value="${campaign != null ? campaign.startDate.toString().substring(0, 16) : ''}" required>
                  </div>
                  
                  <div class="form-group">
                    <label for="endDate">Ngày kết thúc <span class="text-danger">*</span></label>
                    <input type="datetime-local" class="form-control" id="endDate" name="endDate" 
                           value="${campaign != null ? campaign.endDate.toString().substring(0, 16) : ''}" required>
                  </div>
                </div>
              </div>
              
              <!-- Status Card -->
              <div class="card card-success">
                <div class="card-header">
                  <h3 class="card-title">Trạng thái</h3>
                </div>
                <div class="card-body">
                  <div class="custom-control custom-switch">
                    <input type="checkbox" class="custom-control-input" id="isActive" name="isActive" 
                           ${campaign == null || campaign.active ? 'checked' : ''}>
                    <label class="custom-control-label" for="isActive">Kích hoạt chiến dịch</label>
                  </div>
                  <small class="form-text text-muted">
                    <i class="fas fa-info-circle"></i> Chiến dịch chỉ áp dụng khi được kích hoạt và trong khoảng thời gian đã đặt.
                  </small>
                </div>
                <div class="card-footer">
                  <button type="submit" class="btn btn-success btn-block">
                    <i class="fas fa-save"></i> <%= isEdit ? "Cập nhật" : "Lưu" %>
                  </button>
                  <a href="<%= request.getContextPath() %>/admin/discount" class="btn btn-default btn-block">
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

  <jsp:include page="includes/admin-footer.jsp" />
</div>

<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/jquery/jquery.min.js"></script>
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/js/adminlte.min.js"></script>

<script>
$(function() {
  // Initialize on page load
  toggleMaxDiscount();
  toggleAppliedToID();
  
  // Set minimum date to today for new campaigns
  <% if (!isEdit) { %>
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');
  const hours = String(now.getHours()).padStart(2, '0');
  const minutes = String(now.getMinutes()).padStart(2, '0');
  const minDateTime = year + '-' + month + '-' + day + 'T' + hours + ':' + minutes;
  $('#startDate').attr('min', minDateTime);
  $('#endDate').attr('min', minDateTime);
  <% } %>
  
  // Validate end date is after start date
  $('#startDate, #endDate').on('change', function() {
    const startDate = $('#startDate').val();
    const endDate = $('#endDate').val();
    
    if (startDate && endDate && endDate <= startDate) {
      alert('Ngày kết thúc phải sau ngày bắt đầu!');
      $('#endDate').val('');
    }
  });
});

// Toggle max discount field based on discount type
function toggleMaxDiscount() {
  const discountType = $('#discountType').val();
  const maxDiscountGroup = $('#maxDiscountGroup');
  const discountUnit = $('#discountUnit');
  
  if (discountType === 'percentage') {
    maxDiscountGroup.show();
    discountUnit.text('%');
    $('#discountValue').attr('max', '100');
  } else {
    maxDiscountGroup.hide();
    discountUnit.text('₫');
    $('#discountValue').removeAttr('max');
  }
}

// Toggle applied to ID field based on applied to type
function toggleAppliedToID() {
  const appliedToType = $('#appliedToType').val();
  
  // Hide all groups
  $('#categoryGroup, #productGroup, #brandGroup').hide();
  $('#categoryID, #productID, #brandID').removeAttr('required');
  
  // Show relevant group
  if (appliedToType === 'category') {
    $('#categoryGroup').show();
    $('#categoryID').attr('required', 'required');
  } else if (appliedToType === 'product') {
    $('#productGroup').show();
    $('#productID').attr('required', 'required');
  } else if (appliedToType === 'brand') {
    $('#brandGroup').show();
    $('#brandID').attr('required', 'required');
  }
}
</script>

</body>
</html>
