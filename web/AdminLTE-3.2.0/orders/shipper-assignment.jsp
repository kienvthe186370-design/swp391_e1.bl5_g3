<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Giám sát Shipper | Admin</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/AdminLTE-3.2.0/plugins/fontawesome-free/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/AdminLTE-3.2.0/dist/css/adminlte.min.css">
    <style>
        .shipper-card { transition: all 0.3s; }
        .shipper-card:hover { transform: translateY(-2px); box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        .status-dot { width: 10px; height: 10px; border-radius: 50%; display: inline-block; margin-right: 5px; }
        .status-picking { background: #ffc107; }
        .status-delivering { background: #17a2b8; }
        .status-delivered { background: #28a745; }
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
                        <h1 class="m-0"><i class="fas fa-motorcycle"></i> Giám sát Shipper</h1>
                    </div>
                    <div class="col-sm-6">
                        <ol class="breadcrumb float-sm-right">
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/orders">Đơn hàng</a></li>
                            <li class="breadcrumb-item active">Giám sát Shipper</li>
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

                <!-- Thông báo tự động phân công -->
                <div class="alert alert-info">
                    <i class="fas fa-info-circle"></i> 
                    <strong>Phân công tự động:</strong> Hệ thống tự động phân công shipper khi đơn hàng chuyển sang trạng thái "Đang giao". 
                    Bạn có thể thay đổi phân công nếu cần.
                </div>

                <div class="row">
                    <!-- Danh sách Shipper -->
                    <div class="col-md-4">
                        <div class="card">
                            <div class="card-header bg-info">
                                <h3 class="card-title">
                                    <i class="fas fa-users"></i> Danh sách Shipper
                                </h3>
                            </div>
                            <div class="card-body p-0">
                                <c:choose>
                                    <c:when test="${empty shippers}">
                                        <div class="p-4 text-center text-muted">
                                            <i class="fas fa-user-slash fa-3x mb-3"></i>
                                            <p>Chưa có shipper nào</p>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="shipper" items="${shippers}">
                                            <div class="shipper-card p-3 border-bottom">
                                                <div class="d-flex justify-content-between align-items-center">
                                                    <div>
                                                        <i class="fas fa-user-circle fa-2x text-info mr-2"></i>
                                                        <strong>${shipper[1]}</strong>
                                                        <br>
                                                        <small class="text-muted ml-4">
                                                            <i class="fas fa-phone"></i> ${shipper[2]}
                                                        </small>
                                                    </div>
                                                    <div class="text-right">
                                                        <span class="badge badge-${shipper[3] > 5 ? 'danger' : (shipper[3] > 2 ? 'warning' : 'success')} badge-pill" style="font-size:16px">
                                                            ${shipper[3]}
                                                        </span>
                                                        <br><small class="text-muted">đơn đang giao</small>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <!-- Đơn hàng đang giao -->
                    <div class="col-md-8">
                        <div class="card">
                            <div class="card-header bg-primary">
                                <h3 class="card-title">
                                    <i class="fas fa-truck"></i> Đơn hàng đang vận chuyển
                                    <span class="badge badge-light ml-2">${assignedShippings.size()}</span>
                                </h3>
                            </div>
                            <div class="card-body p-0">
                                <c:choose>
                                    <c:when test="${empty assignedShippings}">
                                        <div class="p-4 text-center text-muted">
                                            <i class="fas fa-box-open fa-3x mb-3"></i>
                                            <p>Chưa có đơn hàng nào đang vận chuyển</p>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="table-responsive">
                                            <table class="table table-hover mb-0">
                                                <thead class="thead-light">
                                                    <tr>
                                                        <th>Mã đơn</th>
                                                        <th>Khách hàng</th>
                                                        <th>Shipper</th>
                                                        <th>Trạng thái</th>
                                                        <th>Thao tác</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="shipping" items="${assignedShippings}">
                                                        <tr>
                                                            <td>
                                                                <strong>${shipping.orderCode}</strong><br>
                                                                <small class="text-muted">
                                                                    <fmt:formatNumber value="${shipping.totalAmount}" type="number"/>đ
                                                                </small>
                                                            </td>
                                                            <td>
                                                                ${shipping.address.recipientName}<br>
                                                                <small class="text-muted">${shipping.address.district}, ${shipping.address.city}</small>
                                                            </td>
                                                            <td>
                                                                <i class="fas fa-user text-info"></i>
                                                                <strong>${shipping.shipperName}</strong>
                                                            </td>
                                                            <td>
                                                                <span class="status-dot 
                                                                    <c:choose>
                                                                        <c:when test="${shipping.goshipStatus == 'delivering'}">status-delivering</c:when>
                                                                        <c:when test="${shipping.goshipStatus == 'delivered'}">status-delivered</c:when>
                                                                        <c:otherwise>status-picking</c:otherwise>
                                                                    </c:choose>
                                                                "></span>
                                                                <c:choose>
                                                                    <c:when test="${shipping.goshipStatus == 'picking'}">Đang lấy hàng</c:when>
                                                                    <c:when test="${shipping.goshipStatus == 'picked'}">Đã lấy hàng</c:when>
                                                                    <c:when test="${shipping.goshipStatus == 'delivering'}">Đang giao</c:when>
                                                                    <c:when test="${shipping.goshipStatus == 'delivered'}">Đã giao</c:when>
                                                                    <c:otherwise>Chờ xử lý</c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td>
                                                                <button type="button" class="btn btn-warning btn-sm" 
                                                                        data-toggle="modal" 
                                                                        data-target="#reassignModal${shipping.shippingID}"
                                                                        title="Thay đổi shipper">
                                                                    <i class="fas fa-exchange-alt"></i>
                                                                </button>
                                                                
                                                                <!-- Modal thay đổi shipper -->
                                                                <div class="modal fade" id="reassignModal${shipping.shippingID}" tabindex="-1">
                                                                    <div class="modal-dialog modal-sm">
                                                                        <div class="modal-content">
                                                                            <div class="modal-header bg-warning">
                                                                                <h5 class="modal-title">Thay đổi Shipper</h5>
                                                                                <button type="button" class="close" data-dismiss="modal">&times;</button>
                                                                            </div>
                                                                            <form method="post" action="${pageContext.request.contextPath}/admin/orders">
                                                                                <div class="modal-body">
                                                                                    <input type="hidden" name="action" value="reassignShipper">
                                                                                    <input type="hidden" name="shippingId" value="${shipping.shippingID}">
                                                                                    <p><strong>Đơn:</strong> ${shipping.orderCode}</p>
                                                                                    <p><strong>Shipper hiện tại:</strong> ${shipping.shipperName}</p>
                                                                                    <div class="form-group">
                                                                                        <label>Chọn shipper mới:</label>
                                                                                        <select name="shipperId" class="form-control" required>
                                                                                            <c:forEach var="shipper" items="${shippers}">
                                                                                                <option value="${shipper[0]}" ${shipper[0] == shipping.shipperID ? 'selected' : ''}>
                                                                                                    ${shipper[1]} (${shipper[3]} đơn)
                                                                                                </option>
                                                                                            </c:forEach>
                                                                                        </select>
                                                                                    </div>
                                                                                </div>
                                                                                <div class="modal-footer">
                                                                                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                                                                                    <button type="submit" class="btn btn-warning">Thay đổi</button>
                                                                                </div>
                                                                            </form>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </div>

    <jsp:include page="../includes/admin-footer.jsp"/>
</div>

<script src="${pageContext.request.contextPath}/AdminLTE-3.2.0/plugins/jquery/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/AdminLTE-3.2.0/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/AdminLTE-3.2.0/dist/js/adminlte.min.js"></script>
</body>
</html>
