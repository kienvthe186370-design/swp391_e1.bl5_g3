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
        .shipper-card { transition: all 0.2s; cursor: pointer; border-left: 3px solid transparent; }
        .shipper-card:hover { background: #f8f9fa; }
        .shipper-card.selected { background: #e3f2fd; border-left-color: #007bff; }
        .status-dot { width: 8px; height: 8px; border-radius: 50%; display: inline-block; margin-right: 5px; }
        .status-picking { background: #ffc107; }
        .status-delivering { background: #17a2b8; }
        .status-delivered { background: #28a745; }
        .nav-tabs .nav-link { padding: 8px 12px; font-size: 13px; }
        .nav-tabs .nav-link.active { font-weight: bold; }
        .shipper-list { max-height: 500px; overflow-y: auto; }
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

                <!-- Stats Row -->
                <div class="row">
                    <div class="col-lg-3 col-6">
                        <div class="small-box bg-info">
                            <div class="inner">
                                <h3>${totalShippers}</h3>
                                <p>Tổng Shipper</p>
                            </div>
                            <div class="icon"><i class="fas fa-users"></i></div>
                        </div>
                    </div>
                    <div class="col-lg-3 col-6">
                        <div class="small-box bg-success">
                            <div class="inner">
                                <h3>${activeShippers}</h3>
                                <p>Đang giao hàng</p>
                            </div>
                            <div class="icon"><i class="fas fa-truck"></i></div>
                        </div>
                    </div>
                    <div class="col-lg-3 col-6">
                        <div class="small-box bg-secondary">
                            <div class="inner">
                                <h3>${idleShippers}</h3>
                                <p>Rảnh</p>
                            </div>
                            <div class="icon"><i class="fas fa-coffee"></i></div>
                        </div>
                    </div>
                    <div class="col-lg-3 col-6">
                        <div class="small-box bg-warning">
                            <div class="inner">
                                <h3>${totalShippingOrders}</h3>
                                <p>Đơn đang vận chuyển</p>
                            </div>
                            <div class="icon"><i class="fas fa-box"></i></div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <!-- Cột trái: Danh sách Shipper -->
                    <div class="col-md-4">
                        <div class="card">
                            <div class="card-header p-0">
                                <ul class="nav nav-tabs">
                                    <li class="nav-item">
                                        <a class="nav-link ${shipperTab == 'active' ? 'active' : ''}" 
                                           href="?action=shipperAssignment&shipperTab=active">
                                            <i class="fas fa-truck"></i> Đang giao 
                                            <span class="badge badge-success">${activeShipperCount}</span>
                                        </a>
                                    </li>
                                    <li class="nav-item">
                                        <a class="nav-link ${shipperTab == 'all' ? 'active' : ''}" 
                                           href="?action=shipperAssignment&shipperTab=all">
                                            <i class="fas fa-list"></i> Tất cả 
                                            <span class="badge badge-secondary">${allShipperCount}</span>
                                        </a>
                                    </li>
                                </ul>
                            </div>
                            <div class="card-body p-0 shipper-list">
                                <c:choose>
                                    <c:when test="${empty shippers}">
                                        <div class="p-4 text-center text-muted">
                                            <i class="fas fa-user-slash fa-3x mb-3"></i>
                                            <p>Không có shipper nào</p>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="shipper" items="${shippers}">
                                            <a href="?action=shipperAssignment&shipperTab=${shipperTab}&shipperId=${shipper[0]}" 
                                               class="shipper-card d-block p-3 border-bottom text-dark ${shipper[0] == selectedShipperId ? 'selected' : ''}">
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
                                                        <c:choose>
                                                            <c:when test="${shipper[3] > 0}">
                                                                <span class="badge badge-${shipper[3] > 5 ? 'danger' : (shipper[3] > 2 ? 'warning' : 'success')} badge-pill" style="font-size:16px">
                                                                    ${shipper[3]}
                                                                </span>
                                                                <br><small class="text-muted">đang giao</small>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge badge-secondary badge-pill" style="font-size:16px">0</span>
                                                                <br><small class="text-muted">rảnh</small>
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <br><small class="text-success"><i class="fas fa-check"></i> ${shipper[4]} đã giao</small>
                                                    </div>
                                                </div>
                                            </a>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <!-- Cột phải: Đơn hàng của Shipper -->
                    <div class="col-md-8">
                        <div class="card">
                            <div class="card-header">
                                <c:if test="${selectedShipperId != null}">
                                    <c:forEach var="s" items="${shippers}">
                                        <c:if test="${s[0] == selectedShipperId}">
                                            <h3 class="card-title">
                                                <i class="fas fa-user text-info"></i> 
                                                <strong>${s[1]}</strong> - 
                                                <i class="fas fa-phone"></i> ${s[2]}
                                            </h3>
                                        </c:if>
                                    </c:forEach>
                                </c:if>
                            </div>
                            <div class="card-header p-0 border-top">
                                <ul class="nav nav-tabs">
                                    <li class="nav-item">
                                        <a class="nav-link ${orderTab == 'active' ? 'active' : ''}" 
                                           href="?action=shipperAssignment&shipperTab=${shipperTab}&shipperId=${selectedShipperId}&orderTab=active">
                                            <i class="fas fa-truck"></i> Đang giao 
                                            <span class="badge badge-warning">${activeCount}</span>
                                        </a>
                                    </li>
                                    <li class="nav-item">
                                        <a class="nav-link ${orderTab == 'delivered' ? 'active' : ''}" 
                                           href="?action=shipperAssignment&shipperTab=${shipperTab}&shipperId=${selectedShipperId}&orderTab=delivered">
                                            <i class="fas fa-check-circle"></i> Đã giao 
                                            <span class="badge badge-success">${deliveredCount}</span>
                                        </a>
                                    </li>
                                    <li class="nav-item">
                                        <a class="nav-link ${orderTab == 'all' ? 'active' : ''}" 
                                           href="?action=shipperAssignment&shipperTab=${shipperTab}&shipperId=${selectedShipperId}&orderTab=all">
                                            <i class="fas fa-list"></i> Tất cả 
                                            <span class="badge badge-secondary">${allOrderCount}</span>
                                        </a>
                                    </li>
                                </ul>
                            </div>
                            <div class="card-body p-0">
                                <c:choose>
                                    <c:when test="${selectedShipperId == null}">
                                        <div class="p-4 text-center text-muted">
                                            <i class="fas fa-hand-pointer fa-3x mb-3"></i>
                                            <p>Chọn một shipper để xem đơn hàng</p>
                                        </div>
                                    </c:when>
                                    <c:when test="${empty shipperOrders}">
                                        <div class="p-4 text-center text-muted">
                                            <i class="fas fa-box-open fa-3x mb-3"></i>
                                            <p>Không có đơn hàng nào</p>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="table-responsive">
                                            <table class="table table-hover mb-0">
                                                <thead class="thead-light">
                                                    <tr>
                                                        <th>Mã đơn</th>
                                                        <th>Khách hàng</th>
                                                        <th>Tổng tiền</th>
                                                        <th>Trạng thái</th>
                                                        <th>Thao tác</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="shipping" items="${shipperOrders}">
                                                        <tr>
                                                            <td>
                                                                <strong>${shipping.orderCode}</strong>
                                                            </td>
                                                            <td>
                                                                ${shipping.address.recipientName}<br>
                                                                <small class="text-muted">${shipping.address.district}, ${shipping.address.city}</small>
                                                            </td>
                                                            <td>
                                                                <strong class="text-danger">
                                                                    <fmt:formatNumber value="${shipping.totalAmount}" type="number"/>đ
                                                                </strong>
                                                                <br><small>${shipping.paymentMethod}</small>
                                                            </td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${shipping.orderStatus == 'Delivered'}">
                                                                        <span class="badge badge-success">Đã giao</span>
                                                                    </c:when>
                                                                    <c:otherwise>
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
                                                                            <c:otherwise>Chờ xử lý</c:otherwise>
                                                                        </c:choose>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td>
                                                                <c:if test="${shipping.orderStatus == 'Shipping'}">
                                                                    <button type="button" class="btn btn-warning btn-sm" 
                                                                            onclick="showReassignModal(${shipping.shippingID}, '${shipping.orderCode}')"
                                                                            title="Thay đổi shipper">
                                                                        <i class="fas fa-exchange-alt"></i>
                                                                    </button>
                                                                </c:if>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <!-- Pagination -->
                            <c:if test="${totalPages > 1}">
                                <div class="card-footer clearfix">
                                    <ul class="pagination pagination-sm m-0 float-right">
                                        <c:if test="${currentPage > 1}">
                                            <li class="page-item">
                                                <a class="page-link" href="?action=shipperAssignment&shipperTab=${shipperTab}&shipperId=${selectedShipperId}&orderTab=${orderTab}&page=${currentPage - 1}">
                                                    <i class="fas fa-chevron-left"></i>
                                                </a>
                                            </li>
                                        </c:if>
                                        <c:forEach begin="1" end="${totalPages}" var="i">
                                            <li class="page-item ${i == currentPage ? 'active' : ''}">
                                                <a class="page-link" href="?action=shipperAssignment&shipperTab=${shipperTab}&shipperId=${selectedShipperId}&orderTab=${orderTab}&page=${i}">${i}</a>
                                            </li>
                                        </c:forEach>
                                        <c:if test="${currentPage < totalPages}">
                                            <li class="page-item">
                                                <a class="page-link" href="?action=shipperAssignment&shipperTab=${shipperTab}&shipperId=${selectedShipperId}&orderTab=${orderTab}&page=${currentPage + 1}">
                                                    <i class="fas fa-chevron-right"></i>
                                                </a>
                                            </li>
                                        </c:if>
                                    </ul>
                                    <div class="float-left text-muted">
                                        Trang ${currentPage} / ${totalPages} (${totalOrders} đơn)
                                    </div>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </div>

    <!-- Modal Thay đổi Shipper -->
    <div class="modal fade" id="reassignModal" tabindex="-1">
        <div class="modal-dialog modal-sm">
            <div class="modal-content">
                <div class="modal-header bg-warning">
                    <h5 class="modal-title">Thay đổi Shipper</h5>
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                </div>
                <form method="post" action="${pageContext.request.contextPath}/admin/orders">
                    <div class="modal-body">
                        <input type="hidden" name="action" value="reassignShipper">
                        <input type="hidden" name="shippingId" id="reassignShippingId">
                        <p><strong>Đơn:</strong> <span id="reassignOrderCode"></span></p>
                        <div class="form-group">
                            <label>Chọn shipper mới:</label>
                            <select name="shipperId" class="form-control" required>
                                <c:forEach var="shipper" items="${allShippers}">
                                    <option value="${shipper[0]}">${shipper[1]} (${shipper[3]} đơn)</option>
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

    <jsp:include page="../includes/admin-footer.jsp"/>
</div>

<script src="${pageContext.request.contextPath}/AdminLTE-3.2.0/plugins/jquery/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/AdminLTE-3.2.0/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/AdminLTE-3.2.0/dist/js/adminlte.min.js"></script>
<script>
function showReassignModal(shippingId, orderCode) {
    $('#reassignShippingId').val(shippingId);
    $('#reassignOrderCode').text(orderCode);
    $('#reassignModal').modal('show');
}
</script>
</body>
</html>
