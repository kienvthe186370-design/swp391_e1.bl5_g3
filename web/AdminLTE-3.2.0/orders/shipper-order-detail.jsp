<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chi tiết đơn hàng | Shipper</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/AdminLTE-3.2.0/plugins/fontawesome-free/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/AdminLTE-3.2.0/dist/css/adminlte.min.css">
    <style>
        .timeline-item { position: relative; padding-left: 40px; padding-bottom: 20px; border-left: 2px solid #dee2e6; }
        .timeline-item:last-child { border-left: none; }
        .timeline-icon { position: absolute; left: -12px; width: 24px; height: 24px; border-radius: 50%; 
                        display: flex; align-items: center; justify-content: center; font-size: 12px; }
        .timeline-icon.picking { background: #ffc107; color: #000; }
        .timeline-icon.picked { background: #17a2b8; color: #fff; }
        .timeline-icon.delivering { background: #007bff; color: #fff; }
        .timeline-icon.delivered { background: #28a745; color: #fff; }
        .timeline-icon.failed { background: #dc3545; color: #fff; }
        .status-btn { min-width: 140px; margin: 5px; }
        .cod-badge { background: #dc3545; color: white; padding: 5px 10px; border-radius: 4px; }
    </style>
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">
    <jsp:include page="../includes/admin-header.jsp"/>
    <jsp:include page="../includes/admin-sidebar.jsp"/>

    <div class="content-wrapper">
        <div class="content-header">
            <div class="container-fluid">
                <div class="row mb-2">
                    <div class="col-sm-6">
                        <h1 class="m-0">Chi tiết đơn hàng #${order.orderCode}</h1>
                    </div>
                    <div class="col-sm-6">
                        <ol class="breadcrumb float-sm-right">
                            <li class="breadcrumb-item">
                                <a href="${pageContext.request.contextPath}/admin/orders?action=shipperOrders">Đơn hàng giao</a>
                            </li>
                            <li class="breadcrumb-item active">Chi tiết</li>
                        </ol>
                    </div>
                </div>
            </div>
        </div>

        <section class="content">
            <div class="container-fluid">
                <!-- Alert messages -->
                <c:if test="${not empty sessionScope.success}">
                    <div class="alert alert-success alert-dismissible">
                        <button type="button" class="close" data-dismiss="alert">&times;</button>
                        ${sessionScope.success}
                    </div>
                    <c:remove var="success" scope="session"/>
                </c:if>
                <c:if test="${not empty sessionScope.error}">
                    <div class="alert alert-danger alert-dismissible">
                        <button type="button" class="close" data-dismiss="alert">&times;</button>
                        ${sessionScope.error}
                    </div>
                    <c:remove var="error" scope="session"/>
                </c:if>

                <div class="row">
                    <!-- Thông tin giao hàng -->
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-primary">
                                <h3 class="card-title"><i class="fas fa-map-marker-alt"></i> Thông tin giao hàng</h3>
                            </div>
                            <div class="card-body">
                                <p><strong>Người nhận:</strong> ${order.address.recipientName}</p>
                                <p><strong>Điện thoại:</strong> 
                                    <a href="tel:${order.address.phone}" class="text-primary">
                                        <i class="fas fa-phone"></i> ${order.address.phone}
                                    </a>
                                </p>
                                <p><strong>Địa chỉ:</strong><br>
                                    ${order.address.street}<br>
                                    ${order.address.ward}, ${order.address.district}<br>
                                    ${order.address.city}
                                </p>
                                <hr>
                                <p><strong>Mã tracking:</strong> ${shipping.trackingCode}</p>
                                <c:if test="${order.paymentMethod == 'COD' && order.paymentStatus != 'Paid'}">
                                    <p><span class="cod-badge"><i class="fas fa-money-bill"></i> Thu COD: 
                                        <fmt:formatNumber value="${order.totalAmount}" type="number"/>đ</span></p>
                                </c:if>
                            </div>
                        </div>
                        
                        <!-- Sản phẩm -->
                        <div class="card">
                            <div class="card-header">
                                <h3 class="card-title"><i class="fas fa-box"></i> Sản phẩm</h3>
                            </div>
                            <div class="card-body p-0">
                                <table class="table table-sm">
                                    <c:forEach var="item" items="${order.orderDetails}">
                                        <tr>
                                            <td>${item.productName}</td>
                                            <td class="text-center">x${item.quantity}</td>
                                        </tr>
                                    </c:forEach>
                                </table>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Cập nhật trạng thái -->
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-success">
                                <h3 class="card-title"><i class="fas fa-sync"></i> Cập nhật trạng thái</h3>
                            </div>
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${currentStatus == 'delivered' || currentStatus == 'returned'}">
                                        <div class="alert alert-info">
                                            <i class="fas fa-check-circle"></i> Đơn hàng đã hoàn thành
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <form method="post" action="${pageContext.request.contextPath}/admin/orders" id="statusForm">
                                            <input type="hidden" name="action" value="updateShippingStatus">
                                            <input type="hidden" name="orderId" value="${order.orderID}">
                                            <input type="hidden" name="newStatus" id="newStatusInput" value="">
                                            
                                            <div class="form-group">
                                                <label>Chọn trạng thái mới:</label>
                                                <div class="btn-group-vertical w-100">
                                                    <c:forEach var="status" items="${nextStatuses}">
                                                        <button type="button" onclick="selectStatus('${status}')"
                                                                class="btn status-btn 
                                                                    <c:choose>
                                                                        <c:when test="${status == 'picked'}">btn-info</c:when>
                                                                        <c:when test="${status == 'delivering'}">btn-primary</c:when>
                                                                        <c:when test="${status == 'delivered'}">btn-success</c:when>
                                                                        <c:when test="${status == 'failed'}">btn-warning</c:when>
                                                                        <c:when test="${status == 'returned'}">btn-danger</c:when>
                                                                        <c:otherwise>btn-secondary</c:otherwise>
                                                                    </c:choose>
                                                                ">
                                                            <c:choose>
                                                                <c:when test="${status == 'picked'}"><i class="fas fa-box-open"></i> Đã lấy hàng</c:when>
                                                                <c:when test="${status == 'delivering'}"><i class="fas fa-truck"></i> Đang giao hàng</c:when>
                                                                <c:when test="${status == 'delivered'}"><i class="fas fa-check-circle"></i> Đã giao thành công</c:when>
                                                                <c:when test="${status == 'failed'}"><i class="fas fa-exclamation-triangle"></i> Giao thất bại</c:when>
                                                                <c:when test="${status == 'returned'}"><i class="fas fa-undo"></i> Hoàn hàng</c:when>
                                                                <c:otherwise>${status}</c:otherwise>
                                                            </c:choose>
                                                        </button>
                                                    </c:forEach>
                                                </div>
                                            </div>
                                            
                                            <!-- Checkbox thu tiền COD - chỉ hiện khi đơn COD chưa thanh toán -->
                                            <c:if test="${order.paymentMethod == 'COD' && order.paymentStatus != 'Paid'}">
                                            <div class="form-group" id="codSection" style="display:none;">
                                                <div class="alert alert-warning">
                                                    <div class="custom-control custom-checkbox">
                                                        <input type="checkbox" class="custom-control-input" id="codCollected" name="codCollected" value="true">
                                                        <label class="custom-control-label" for="codCollected">
                                                            <strong><i class="fas fa-money-bill-wave"></i> Đã thu tiền COD: 
                                                            <fmt:formatNumber value="${order.totalAmount}" type="number"/>đ</strong>
                                                        </label>
                                                    </div>
                                                    <small class="text-muted d-block mt-1">Bắt buộc xác nhận đã thu tiền khi giao thành công đơn COD</small>
                                                </div>
                                            </div>
                                            </c:if>
                                            
                                            <div class="form-group">
                                                <label>Vị trí hiện tại:</label>
                                                <input type="text" name="location" class="form-control" placeholder="VD: Quận 1, TP.HCM">
                                            </div>
                                            
                                            <div class="form-group">
                                                <label>Ghi chú:</label>
                                                <textarea name="notes" class="form-control" rows="2" placeholder="Ghi chú thêm..."></textarea>
                                            </div>
                                        </form>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        
                        <!-- Lịch sử tracking -->
                        <div class="card">
                            <div class="card-header">
                                <h3 class="card-title"><i class="fas fa-history"></i> Lịch sử vận chuyển</h3>
                            </div>
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${empty trackingHistory}">
                                        <p class="text-muted">Chưa có lịch sử</p>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="timeline-container">
                                            <c:forEach var="track" items="${trackingHistory}">
                                                <div class="timeline-item">
                                                    <div class="timeline-icon ${track.statusCode}">
                                                        <i class="fas fa-circle"></i>
                                                    </div>
                                                    <div>
                                                        <strong>${track.statusDescription}</strong><br>
                                                        <small class="text-muted">
                                                            <fmt:formatDate value="${track.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                        </small>
                                                        <c:if test="${not empty track.location}">
                                                            <br><small><i class="fas fa-map-marker-alt"></i> ${track.location}</small>
                                                        </c:if>
                                                        <c:if test="${not empty track.notes}">
                                                            <br><small class="text-info">${track.notes}</small>
                                                        </c:if>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </div>
                
                <a href="${pageContext.request.contextPath}/admin/orders?action=shipperOrders" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Quay lại
                </a>
            </div>
        </section>
    </div>

    <jsp:include page="../includes/admin-footer.jsp"/>
</div>

<script src="${pageContext.request.contextPath}/AdminLTE-3.2.0/plugins/jquery/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/AdminLTE-3.2.0/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/AdminLTE-3.2.0/dist/js/adminlte.min.js"></script>
<script>
var isCOD = <c:choose><c:when test="${order.paymentMethod == 'COD' && order.paymentStatus != 'Paid'}">true</c:when><c:otherwise>false</c:otherwise></c:choose>;

function selectStatus(status) {
    document.getElementById('newStatusInput').value = status;
    
    // Hiện checkbox COD khi chọn "delivered" và đơn là COD
    var codSection = document.getElementById('codSection');
    if (codSection) {
        if (status === 'delivered') {
            codSection.style.display = 'block';
        } else {
            codSection.style.display = 'none';
        }
    }
    
    // Nếu chọn delivered và là đơn COD, kiểm tra checkbox trước khi submit
    if (status === 'delivered' && isCOD) {
        var codCheckbox = document.getElementById('codCollected');
        if (codCheckbox && !codCheckbox.checked) {
            // Hiện section và yêu cầu tick
            if (codSection) codSection.style.display = 'block';
            alert('Vui lòng xác nhận đã thu tiền COD trước khi hoàn thành đơn hàng!');
            return;
        }
    }
    
    // Submit form
    document.getElementById('statusForm').submit();
}
</script>
</body>
</html>
