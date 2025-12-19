<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Tạo yêu cầu nhập hàng - Pickleball Admin</title>
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
                            <i class="fas fa-plus-circle text-success"></i> Tạo yêu cầu nhập hàng
                        </h1>
                    </div>
                    <div class="col-sm-6">
                        <ol class="breadcrumb float-sm-right">
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/rfq?action=detail&id=${rfq.rfqID}">RFQ ${rfq.rfqCode}</a></li>
                            <li class="breadcrumb-item active">Tạo yêu cầu nhập hàng</li>
                        </ol>
                    </div>
                </div>
            </div>
        </div>

        <section class="content">
            <div class="container-fluid">
                <form action="${pageContext.request.contextPath}/admin/stock-requests" method="post">
                    <input type="hidden" name="action" value="create">
                    <input type="hidden" name="rfqId" value="${rfq.rfqID}">
                    
                    <div class="row">
                        <!-- Left: RFQ Info -->
                        <div class="col-md-4">
                            <div class="card card-primary card-outline">
                                <div class="card-header">
                                    <h3 class="card-title"><i class="fas fa-file-invoice"></i> Thông tin RFQ</h3>
                                </div>
                                <div class="card-body">
                                    <table class="table table-sm table-borderless">
                                        <tr>
                                            <td class="text-muted">Mã RFQ:</td>
                                            <td><strong class="text-primary">${rfq.rfqCode}</strong></td>
                                        </tr>
                                        <tr>
                                            <td class="text-muted">Khách hàng:</td>
                                            <td>${rfq.customerName}</td>
                                        </tr>
                                        <tr>
                                            <td class="text-muted">Công ty:</td>
                                            <td>${rfq.companyName}</td>
                                        </tr>
                                        <tr>
                                            <td class="text-muted">Ngày tạo:</td>
                                            <td><fmt:formatDate value="${rfq.createdDate}" pattern="dd/MM/yyyy"/></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            
                            <!-- Buttons -->
                            <button type="submit" class="btn btn-success btn-lg btn-block">
                                <i class="fas fa-paper-plane"></i> Gửi yêu cầu nhập hàng
                            </button>
                            <a href="${pageContext.request.contextPath}/admin/rfq?action=detail&id=${rfq.rfqID}" 
                               class="btn btn-secondary btn-block">
                                <i class="fas fa-arrow-left"></i> Quay lại RFQ
                            </a>
                        </div>
                        
                        <!-- Right: Shortage Items -->
                        <div class="col-md-8">
                            <div class="card card-danger card-outline">
                                <div class="card-header">
                                    <h3 class="card-title">
                                        <i class="fas fa-exclamation-triangle text-danger"></i> 
                                        Sản phẩm thiếu hàng (${shortageItems.size()} sản phẩm)
                                    </h3>
                                </div>
                                <div class="card-body table-responsive p-0">
                                    <table class="table table-hover">
                                        <thead class="thead-light">
                                            <tr>
                                                <th style="width: 60px">Ảnh</th>
                                                <th>Sản phẩm</th>
                                                <th class="text-center">Tồn kho<br>hiện tại</th>
                                                <th class="text-center">SL yêu cầu<br>trong RFQ</th>
                                                <th class="text-center text-danger">Thiếu</th>
                                                <th class="text-center" style="width: 120px">SL yêu cầu<br>nhập hàng</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="item" items="${shortageItems}" varStatus="status">
                                                <c:set var="currentStock" value="${item.product != null ? item.product.totalStock : 0}"/>
                                                <c:set var="shortage" value="${item.quantity - currentStock}"/>
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
                                                        <input type="hidden" name="productId_${status.index}" value="${item.productID}">
                                                        <input type="hidden" name="variantId_${status.index}" value="${item.variantID}">
                                                        <input type="hidden" name="productName_${status.index}" value="${item.productName}">
                                                        <input type="hidden" name="sku_${status.index}" value="${item.sku}">
                                                        <input type="hidden" name="currentStock_${status.index}" value="${currentStock}">
                                                        <input type="hidden" name="rfqQuantity_${status.index}" value="${item.quantity}">
                                                    </td>
                                                    <td class="text-center">
                                                        <span class="badge badge-secondary">${currentStock}</span>
                                                    </td>
                                                    <td class="text-center">
                                                        <span class="badge badge-info">${item.quantity}</span>
                                                    </td>
                                                    <td class="text-center">
                                                        <span class="badge badge-danger badge-lg">
                                                            <i class="fas fa-arrow-down"></i> ${shortage}
                                                        </span>
                                                    </td>
                                                    <td class="text-center">
                                                        <input type="number" name="requestedQuantity_${status.index}" 
                                                               class="form-control form-control-sm text-center quantity-input"
                                                               value="${shortage}" min="1" required
                                                               data-shortage="${shortage}">
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                    <input type="hidden" name="itemCount" value="${shortageItems.size()}">
                                </div>
                            </div>
                            
                            <div class="alert alert-info">
                                <i class="fas fa-info-circle"></i>
                                <strong>Lưu ý:</strong> Sau khi gửi yêu cầu, Admin sẽ xem xét và nhập hàng. 
                                Khi Admin duyệt, tồn kho sẽ được tự động cập nhật.
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </section>
    </div>
    
    <jsp:include page="includes/admin-footer.jsp"/>
