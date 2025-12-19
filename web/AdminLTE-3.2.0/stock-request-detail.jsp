<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chi tiết yêu cầu nhập hàng - ${stockRequest.requestCode}</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/AdminLTE-3.2.0/plugins/fontawesome-free/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/AdminLTE-3.2.0/dist/css/adminlte.min.css">
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">
    <jsp:include page="includes/admin-header.jsp"/>
    <jsp:include page="includes/admin-sidebar.jsp"/>
    
    <div class="content-wrapper">
        <div class="content-header">
            <div class="container-fluid">
                <div class="row mb-2">
                    <div class="col-sm-6">
                        <h1 class="m-0">
                            <i class="fas fa-boxes text-primary"></i> 
                            Yêu cầu nhập hàng: <strong>${stockRequest.requestCode}</strong>
                        </h1>
                    </div>
                    <div class="col-sm-6">
                        <ol class="breadcrumb float-sm-right">
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/stock-requests">Yêu cầu nhập hàng</a></li>
                            <li class="breadcrumb-item active">${stockRequest.requestCode}</li>
                        </ol>
                    </div>
                </div>
            </div>
        </div>

        <section class="content">
            <div class="container-fluid">
                <!-- Alerts -->
                <c:if test="${param.success == 'approved'}">
                    <div class="alert alert-success alert-dismissible fade show">
                        <i class="fas fa-check-circle"></i> Đã duyệt và nhập hàng thành công! Tồn kho đã được cập nhật.
                        <button type="button" class="close" data-dismiss="alert">&times;</button>
                    </div>
                </c:if>
                <c:if test="${not empty param.error}">
                    <div class="alert alert-danger alert-dismissible fade show">
                        <i class="fas fa-exclamation-circle"></i> ${param.error}
                        <button type="button" class="close" data-dismiss="alert">&times;</button>
                    </div>
                </c:if>

                <div class="row">
                    <!-- Left Column: Request Info -->
                    <div class="col-md-4">
                        <div class="card card-primary card-outline">
                            <div class="card-header">
                                <h3 class="card-title"><i class="fas fa-info-circle"></i> Thông tin yêu cầu</h3>
                            </div>
                            <div class="card-body">
                                <table class="table table-sm table-borderless">
                                    <tr>
                                        <td class="text-muted">Mã yêu cầu:</td>
                                        <td><strong class="text-primary">${stockRequest.requestCode}</strong></td>
                                    </tr>
                                    <tr>
                                        <td class="text-muted">Mã RFQ:</td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/admin/rfq?action=detail&id=${stockRequest.rfqID}" 
                                               class="text-info" target="_blank">
                                                ${stockRequest.rfqCode} <i class="fas fa-external-link-alt fa-xs"></i>
                                            </a>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="text-muted">Trạng thái:</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${stockRequest.status == 'Pending'}">
                                                    <span class="badge badge-warning badge-lg">
                                                        <i class="fas fa-clock"></i> Chờ duyệt
                                                    </span>
                                                </c:when>
                                                <c:when test="${stockRequest.status == 'Completed'}">
                                                    <span class="badge badge-success badge-lg">
                                                        <i class="fas fa-check"></i> Đã nhập hàng
                                                    </span>
                                                </c:when>
                                            </c:choose>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="text-muted">Người tạo:</td>
                                        <td>${stockRequest.requestedByName}</td>
                                    </tr>
                                    <tr>
                                        <td class="text-muted">Ngày tạo:</td>
                                        <td><fmt:formatDate value="${stockRequest.createdDate}" pattern="dd/MM/yyyy HH:mm"/></td>
                                    </tr>
                                    <c:if test="${stockRequest.status == 'Completed'}">
                                        <tr>
                                            <td class="text-muted">Người duyệt:</td>
                                            <td>${stockRequest.completedByName}</td>
                                        </tr>
                                        <tr>
                                            <td class="text-muted">Ngày duyệt:</td>
                                            <td><fmt:formatDate value="${stockRequest.completedDate}" pattern="dd/MM/yyyy HH:mm"/></td>
                                        </tr>
                                    </c:if>
                                </table>
                                
                                <c:if test="${not empty stockRequest.notes}">
                                    <hr>
                                    <h6><i class="fas fa-sticky-note"></i> Ghi chú của Seller:</h6>
                                    <p class="text-muted">${stockRequest.notes}</p>
                                </c:if>
                                
                                <c:if test="${not empty stockRequest.adminNotes}">
                                    <hr>
                                    <h6><i class="fas fa-user-shield"></i> Ghi chú của Admin:</h6>
                                    <p class="text-muted">${stockRequest.adminNotes}</p>
                                </c:if>
                            </div>
                        </div>
                        
                        <!-- Back Button -->
                        <a href="${pageContext.request.contextPath}/admin/stock-requests" class="btn btn-secondary btn-block">
                            <i class="fas fa-arrow-left"></i> Quay lại danh sách
                        </a>
                    </div>

                    <!-- Right Column: Items & Approve Form -->
                    <div class="col-md-8">
                        <c:choose>
                            <c:when test="${isAdmin && stockRequest.status == 'Pending'}">
                                <!-- Admin Approve Form -->
                                <form action="${pageContext.request.contextPath}/admin/stock-requests/approve" method="post">
                                    <input type="hidden" name="requestId" value="${stockRequest.stockRequestID}">
                                    
                                    <div class="card card-success card-outline">
                                        <div class="card-header">
                                            <h3 class="card-title">
                                                <i class="fas fa-list"></i> Danh sách sản phẩm cần nhập
                                            </h3>
                                        </div>
                                        <div class="card-body table-responsive p-0">
                                            <table class="table table-hover">
                                                <thead class="thead-light">
                                                    <tr>
                                                        <th style="width: 60px">Ảnh</th>
                                                        <th>Sản phẩm</th>
                                                        <th class="text-center">Tồn kho<br><small>(lúc tạo)</small></th>
                                                        <th class="text-center">SL trong RFQ</th>
                                                        <th class="text-center">SL Seller<br>yêu cầu</th>
                                                        <th class="text-center" style="width: 120px">SL duyệt</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="item" items="${stockRequest.items}">
                                                        <tr>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${not empty item.productImage}">
                                                                        <img src="${pageContext.request.contextPath}/${item.productImage}" alt="" 
                                                                             class="img-thumbnail" style="width: 50px; height: 50px; object-fit: cover;">
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <div class="bg-secondary text-white d-flex align-items-center justify-content-center" 
                                                                             style="width: 50px; height: 50px;">
                                                                            <i class="fas fa-image"></i>
                                                                        </div>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td>
                                                                <strong>${item.productName}</strong>
                                                                <c:if test="${not empty item.sku}">
                                                                    <br><small class="text-muted">SKU: ${item.sku}</small>
                                                                </c:if>
                                                            </td>
                                                            <td class="text-center">
                                                                <span class="badge badge-secondary">${item.currentStock}</span>
                                                            </td>
                                                            <td class="text-center">
                                                                <span class="badge badge-info">${item.rfqQuantity}</span>
                                                            </td>
                                                            <td class="text-center">
                                                                <span class="badge badge-warning">${item.originalRequestedQuantity}</span>
                                                            </td>
                                                            <td class="text-center">
                                                                <input type="number" 
                                                                       name="approvedQuantity_${item.stockRequestItemID}" 
                                                                       class="form-control form-control-sm text-center approved-quantity"
                                                                       value="${item.requestedQuantity}" 
                                                                       min="1" max="10000" required
                                                                       onchange="validateApprovedQuantity(this)"
                                                                       onkeyup="validateApprovedQuantity(this)">
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                    
                                    <!-- Admin Notes & Submit -->
                                    <div class="card card-warning">
                                        <div class="card-header">
                                            <h3 class="card-title"><i class="fas fa-check-circle"></i> Duyệt yêu cầu</h3>
                                        </div>
                                        <div class="card-body">
                                            <div class="form-group">
                                                <label>Ghi chú của Admin (tùy chọn):</label>
                                                <textarea name="adminNotes" class="form-control" rows="2" 
                                                          placeholder="Nhập ghi chú nếu cần..."></textarea>
                                            </div>
                                            <div class="alert alert-info">
                                                <i class="fas fa-info-circle"></i>
                                                Khi duyệt, hệ thống sẽ <strong>tự động cộng số lượng</strong> vào tồn kho của từng sản phẩm.
                                            </div>
                                        </div>
                                        <div class="card-footer">
                                            <button type="submit" class="btn btn-success btn-lg">
                                                <i class="fas fa-check"></i> Duyệt & Nhập hàng
                                            </button>
                                        </div>
                                    </div>
                                </form>
                            </c:when>
                            <c:otherwise>
                                <!-- View Only (Seller or Completed) -->
                                <div class="card card-info card-outline">
                                    <div class="card-header">
                                        <h3 class="card-title">
                                            <i class="fas fa-list"></i> Danh sách sản phẩm
                                        </h3>
                                    </div>
                                    <div class="card-body table-responsive p-0">
                                        <table class="table table-hover">
                                            <thead class="thead-light">
                                                <tr>
                                                    <th style="width: 60px">Ảnh</th>
                                                    <th>Sản phẩm</th>
                                                    <th class="text-center">Tồn kho<br><small>(lúc tạo)</small></th>
                                                    <th class="text-center">SL trong RFQ</th>
                                                    <th class="text-center">SL yêu cầu</th>
                                                    <c:if test="${stockRequest.status == 'Completed'}">
                                                        <th class="text-center">SL đã nhập</th>
                                                    </c:if>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="item" items="${stockRequest.items}">
                                                    <tr>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${not empty item.productImage}">
                                                                    <img src="${pageContext.request.contextPath}/${item.productImage}" alt="" 
                                                                         class="img-thumbnail" style="width: 50px; height: 50px; object-fit: cover;">
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <div class="bg-secondary text-white d-flex align-items-center justify-content-center" 
                                                                         style="width: 50px; height: 50px;">
                                                                        <i class="fas fa-image"></i>
                                                                    </div>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <strong>${item.productName}</strong>
                                                            <c:if test="${not empty item.sku}">
                                                                <br><small class="text-muted">SKU: ${item.sku}</small>
                                                            </c:if>
                                                        </td>
                                                        <td class="text-center">
                                                            <span class="badge badge-secondary">${item.currentStock}</span>
                                                        </td>
                                                        <td class="text-center">
                                                            <span class="badge badge-info">${item.rfqQuantity}</span>
                                                        </td>
                                                        <td class="text-center">
                                                            <span class="badge badge-warning">${item.originalRequestedQuantity}</span>
                                                        </td>
                                                        <c:if test="${stockRequest.status == 'Completed'}">
                                                            <td class="text-center">
                                                                <span class="badge badge-success">
                                                                    ${item.approvedQuantity != null ? item.approvedQuantity : item.requestedQuantity}
                                                                </span>
                                                                <c:if test="${item.approvedQuantity != null && item.approvedQuantity != item.originalRequestedQuantity}">
                                                                    <br><small class="text-muted">(đã điều chỉnh)</small>
                                                                </c:if>
                                                            </td>
                                                        </c:if>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                                
                                <c:if test="${stockRequest.status == 'Completed'}">
                                    <div class="alert alert-success">
                                        <i class="fas fa-check-circle"></i>
                                        <strong>Đã nhập hàng thành công!</strong> Tồn kho đã được cập nhật vào 
                                        <fmt:formatDate value="${stockRequest.completedDate}" pattern="dd/MM/yyyy HH:mm"/>
                                    </div>
                                </c:if>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </section>
    </div>
    
    <jsp:include page="includes/admin-footer.jsp"/>
    
<script>
// Chặn nhập ký tự không phải số
document.querySelectorAll('.approved-quantity').forEach(function(input) {
    input.addEventListener('keypress', function(e) {
        // Chỉ cho phép số (0-9)
        if (!/[0-9]/.test(e.key)) {
            e.preventDefault();
            alert('Chỉ được nhập số!');
        }
    });
    
    input.addEventListener('paste', function(e) {
        var pasteData = (e.clipboardData || window.clipboardData).getData('text');
        if (!/^\d+$/.test(pasteData)) {
            e.preventDefault();
            alert('Chỉ được nhập số!');
        }
    });
});

function validateApprovedQuantity(input) {
    var rawValue = input.value.toString().trim();
    
    // Nếu rỗng, không làm gì (sẽ validate khi submit)
    if (rawValue === '') {
        input.classList.add('is-invalid');
        return;
    }
    
    // Kiểm tra chỉ chứa số
    if (!/^\d+$/.test(rawValue)) {
        alert('Chỉ được nhập số!');
        input.value = '';
        input.classList.add('is-invalid');
        return;
    }
    
    var value = parseInt(rawValue);
    
    // Không cho phép giá trị < 1
    if (value < 1) {
        alert('Số lượng phải lớn hơn 0!');
        input.value = '';
        input.classList.add('is-invalid');
        return;
    }
    
    // Giới hạn tối đa 10000
    if (value > 10000) {
        alert('Số lượng tối đa là 10,000!');
        input.value = 10000;
    }
    
    input.classList.remove('is-invalid');
}

// Validate trước khi submit form approve
var approveForm = document.querySelector('form[action*="approve"]');
if (approveForm) {
    approveForm.addEventListener('submit', function(e) {
        var inputs = document.querySelectorAll('.approved-quantity');
        var valid = true;
        var errorMsg = '';
        
        inputs.forEach(function(input) {
            var rawValue = input.value.toString().trim();
            
            // Kiểm tra rỗng
            if (rawValue === '') {
                valid = false;
                errorMsg = 'Số lượng không được để trống!';
                input.classList.add('is-invalid');
                return;
            }
            
            // Kiểm tra chỉ chứa số
            if (!/^\d+$/.test(rawValue)) {
                valid = false;
                errorMsg = 'Chỉ được nhập số!';
                input.classList.add('is-invalid');
                return;
            }
            
            var value = parseInt(rawValue);
            if (value < 1) {
                valid = false;
                errorMsg = 'Số lượng phải lớn hơn 0!';
                input.classList.add('is-invalid');
            } else if (value > 10000) {
                valid = false;
                errorMsg = 'Số lượng tối đa là 10,000!';
                input.classList.add('is-invalid');
            } else {
                input.classList.remove('is-invalid');
            }
        });
        
        if (!valid) {
            e.preventDefault();
            alert(errorMsg);
        }
    });
}
</script>
