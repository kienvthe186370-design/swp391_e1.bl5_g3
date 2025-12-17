<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="entity.Employee" %>
<%@ page import="utils.RolePermission" %>
<%
    Employee employee = (Employee) session.getAttribute("employee");
    if (employee == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String userRole = employee.getRole();
    boolean canAssign = RolePermission.canAssignOrders(userRole);
    request.setAttribute("userRole", userRole);
    request.setAttribute("canAssign", canAssign);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="../includes/admin-head.jsp" />
    <title>Quản lý đơn hàng - Pickleball Shop</title>
    <style>
        .nav-tabs .nav-link { padding: 8px 12px; font-size: 13px; }
        .nav-tabs .nav-link.active { font-weight: bold; }
        .stats-box { text-align: center; padding: 15px; border-radius: 5px; margin-bottom: 15px; }
        .stats-box h3 { margin: 0; font-size: 28px; }
        .stats-box p { margin: 5px 0 0; font-size: 12px; }
        .filter-form { background: #f8f9fa; padding: 15px; border-radius: 5px; margin-bottom: 15px; }
    </style>
</head>
<body class="hold-transition sidebar-mini layout-fixed">
<div class="wrapper">
    <jsp:include page="../includes/admin-header.jsp" />
    <jsp:include page="../includes/admin-sidebar.jsp" />

    <div class="content-wrapper">
        <div class="content-header">
            <div class="container-fluid">
                <div class="row mb-2">
                    <div class="col-sm-6">
                        <h1 class="m-0"><i class="fas fa-shopping-cart"></i> Quản lý đơn hàng</h1>
                    </div>
                </div>
            </div>
        </div>

        <section class="content">
            <div class="container-fluid">
                
                <!-- Thông báo -->
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
                    <div class="col-lg-2 col-md-4 col-6">
                        <div class="small-box bg-secondary">
                            <div class="inner">
                                <h3>${pendingCount}</h3>
                                <p>Chờ xử lý</p>
                            </div>
                            <div class="icon"><i class="fas fa-clock"></i></div>
                            <a href="?tab=pending" class="small-box-footer">Xem <i class="fas fa-arrow-circle-right"></i></a>
                        </div>
                    </div>
                    <div class="col-lg-2 col-md-4 col-6">
                        <div class="small-box bg-info">
                            <div class="inner">
                                <h3>${confirmedCount}</h3>
                                <p>Đã xác nhận</p>
                            </div>
                            <div class="icon"><i class="fas fa-check"></i></div>
                            <a href="?tab=confirmed" class="small-box-footer">Xem <i class="fas fa-arrow-circle-right"></i></a>
                        </div>
                    </div>
                    <div class="col-lg-2 col-md-4 col-6">
                        <div class="small-box bg-primary">
                            <div class="inner">
                                <h3>${processingCount}</h3>
                                <p>Đang xử lý</p>
                            </div>
                            <div class="icon"><i class="fas fa-cog"></i></div>
                            <a href="?tab=processing" class="small-box-footer">Xem <i class="fas fa-arrow-circle-right"></i></a>
                        </div>
                    </div>
                    <div class="col-lg-2 col-md-4 col-6">
                        <div class="small-box bg-warning">
                            <div class="inner">
                                <h3>${shippingCount}</h3>
                                <p>Đang giao</p>
                            </div>
                            <div class="icon"><i class="fas fa-truck"></i></div>
                            <a href="?tab=shipping" class="small-box-footer">Xem <i class="fas fa-arrow-circle-right"></i></a>
                        </div>
                    </div>
                    <div class="col-lg-2 col-md-4 col-6">
                        <div class="small-box bg-success">
                            <div class="inner">
                                <h3>${deliveredCount}</h3>
                                <p>Đã giao</p>
                            </div>
                            <div class="icon"><i class="fas fa-check-circle"></i></div>
                            <a href="?tab=delivered" class="small-box-footer">Xem <i class="fas fa-arrow-circle-right"></i></a>
                        </div>
                    </div>
                    <div class="col-lg-2 col-md-4 col-6">
                        <div class="small-box bg-danger">
                            <div class="inner">
                                <h3>${cancelledCount}</h3>
                                <p>Đã hủy</p>
                            </div>
                            <div class="icon"><i class="fas fa-times-circle"></i></div>
                            <a href="?tab=cancelled" class="small-box-footer">Xem <i class="fas fa-arrow-circle-right"></i></a>
                        </div>
                    </div>
                </div>

                <!-- Orders Card -->
                <div class="card">
                    <div class="card-header p-0">
                        <!-- Tabs -->
                        <ul class="nav nav-tabs" id="orderTabs">
                            <li class="nav-item">
                                <a class="nav-link ${currentTab == 'all' ? 'active' : ''}" href="?tab=all">
                                    <i class="fas fa-list"></i> Tất cả <span class="badge badge-secondary">${allCount}</span>
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link ${currentTab == 'pending' ? 'active' : ''}" href="?tab=pending">
                                    <i class="fas fa-clock"></i> Chờ xử lý <span class="badge badge-secondary">${pendingCount}</span>
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link ${currentTab == 'confirmed' ? 'active' : ''}" href="?tab=confirmed">
                                    <i class="fas fa-check"></i> Đã xác nhận <span class="badge badge-info">${confirmedCount}</span>
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link ${currentTab == 'processing' ? 'active' : ''}" href="?tab=processing">
                                    <i class="fas fa-cog"></i> Đang xử lý <span class="badge badge-primary">${processingCount}</span>
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link ${currentTab == 'shipping' ? 'active' : ''}" href="?tab=shipping">
                                    <i class="fas fa-truck"></i> Đang giao <span class="badge badge-warning">${shippingCount}</span>
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link ${currentTab == 'delivered' ? 'active' : ''}" href="?tab=delivered">
                                    <i class="fas fa-check-circle"></i> Đã giao <span class="badge badge-success">${deliveredCount}</span>
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link ${currentTab == 'cancelled' ? 'active' : ''}" href="?tab=cancelled">
                                    <i class="fas fa-times"></i> Đã hủy <span class="badge badge-danger">${cancelledCount}</span>
                                </a>
                            </li>
                            <c:if test="${userRole == 'SellerManager' || userRole == 'Admin'}">
                                <li class="nav-item">
                                    <a class="nav-link ${currentTab == 'unassigned' ? 'active' : ''}" href="?tab=unassigned">
                                        <i class="fas fa-user-slash"></i> Chưa phân <span class="badge badge-warning">${unassignedCount}</span>
                                    </a>
                                </li>
                            </c:if>
                        </ul>
                    </div>
                    
                    <div class="card-body">
                        <!-- Toggle Filter Button -->
                        <div class="mb-2">
                            <button type="button" class="btn btn-outline-secondary btn-sm" id="toggleFilterBtn">
                                <i class="fas fa-filter"></i> <span id="filterBtnText">Hiện bộ lọc</span>
                            </button>
                            <c:if test="${not empty param.search || not empty param.fromDate || not empty param.toDate || not empty param.paymentStatus}">
                                <span class="badge badge-info ml-2">Đang lọc</span>
                            </c:if>
                        </div>
                        
                        <!-- Filter Form -->
                        <form method="get" class="filter-form" id="filterForm" 
                              style="display: ${not empty param.search || not empty param.fromDate || not empty param.toDate || not empty param.paymentStatus ? 'block' : 'none'};">
                            <input type="hidden" name="tab" value="${currentTab}">
                            <div class="row">
                                <div class="col-md-4">
                                    <div class="form-group mb-0">
                                        <label><i class="fas fa-search"></i> Tìm kiếm</label>
                                        <input type="text" name="search" class="form-control" 
                                               placeholder="Mã đơn, tên KH, SĐT..." value="${param.search}">
                                    </div>
                                </div>
                                <div class="col-md-2">
                                    <div class="form-group mb-0">
                                        <label>Thanh toán</label>
                                        <select name="paymentStatus" class="form-control">
                                            <option value="">-- Tất cả --</option>
                                            <option value="Paid" ${param.paymentStatus == 'Paid' ? 'selected' : ''}>Đã TT</option>
                                            <option value="Unpaid" ${param.paymentStatus == 'Unpaid' ? 'selected' : ''}>Chưa TT</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-2">
                                    <div class="form-group mb-0">
                                        <label>Từ ngày</label>
                                        <input type="date" name="fromDate" class="form-control" value="${param.fromDate}">
                                    </div>
                                </div>
                                <div class="col-md-2">
                                    <div class="form-group mb-0">
                                        <label>Đến ngày</label>
                                        <input type="date" name="toDate" class="form-control" value="${param.toDate}">
                                    </div>
                                </div>
                                <div class="col-md-2">
                                    <div class="form-group mb-0">
                                        <label>&nbsp;</label>
                                        <div>
                                            <button type="submit" class="btn btn-primary"><i class="fas fa-filter"></i> Lọc</button>
                                            <a href="?tab=${currentTab}" class="btn btn-secondary"><i class="fas fa-redo"></i></a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </form>
                        
                        <!-- Results info -->
                        <div class="mb-2 text-muted">
                            <small>Hiển thị ${orders.size()} / ${totalOrders} đơn hàng</small>
                        </div>

                        <!-- Orders Table -->
                        <c:choose>
                            <c:when test="${empty orders}">
                                <div class="p-4 text-center text-muted">
                                    <i class="fas fa-inbox fa-3x mb-3"></i>
                                    <p>Không có đơn hàng nào</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead>
                                            <tr>
                                                <th>Mã đơn</th>
                                                <th>Khách hàng</th>
                                                <th>Tổng tiền</th>
                                                <th>Thanh toán</th>
                                                <th>Trạng thái</th>
                                                <th>Ngày đặt</th>
                                                <th>Người xử lý</th>
                                                <th>Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="order" items="${orders}">
                                                <tr>
                                                    <td>
                                                        <a href="?action=detail&id=${order.orderID}">
                                                            <strong>${order.orderCode}</strong>
                                                        </a>
                                                    </td>
                                                    <td>
                                                        ${order.customer.fullName}
                                                        <br><small class="text-muted">${order.customer.phone}</small>
                                                    </td>
                                                    <td>
                                                        <strong class="text-danger">
                                                            <fmt:formatNumber value="${order.totalAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                                        </strong>
                                                    </td>
                                                    <td>
                                                        <span class="badge badge-${order.paymentStatus == 'Paid' ? 'success' : 'warning'}">
                                                            ${order.paymentStatus == 'Paid' ? 'Đã TT' : 'Chưa TT'}
                                                        </span>
                                                        <br><small>${order.paymentMethod}</small>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${order.orderStatus == 'Pending'}">
                                                                <span class="badge badge-secondary">Chờ xử lý</span>
                                                            </c:when>
                                                            <c:when test="${order.orderStatus == 'Confirmed'}">
                                                                <span class="badge badge-info">Đã xác nhận</span>
                                                            </c:when>
                                                            <c:when test="${order.orderStatus == 'Processing'}">
                                                                <span class="badge badge-primary">Đang xử lý</span>
                                                            </c:when>
                                                            <c:when test="${order.orderStatus == 'Shipping'}">
                                                                <span class="badge badge-warning">Đang giao</span>
                                                            </c:when>
                                                            <c:when test="${order.orderStatus == 'Delivered'}">
                                                                <span class="badge badge-success">Đã giao</span>
                                                            </c:when>
                                                            <c:when test="${order.orderStatus == 'Cancelled'}">
                                                                <span class="badge badge-danger">Đã hủy</span>
                                                            </c:when>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy"/>
                                                        <br><small><fmt:formatDate value="${order.orderDate}" pattern="HH:mm"/></small>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${order.assignedSeller != null}">
                                                                <small>${order.assignedSeller.fullName}</small>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-warning"><i class="fas fa-exclamation-triangle"></i></span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <a href="?action=detail&id=${order.orderID}" class="btn btn-sm btn-info" title="Chi tiết">
                                                            <i class="fas fa-eye"></i>
                                                        </a>
                                                        <c:if test="${(userRole == 'SellerManager' || userRole == 'Admin') && order.assignedTo == null}">
                                                            <button class="btn btn-sm btn-warning" onclick="showAssignModal(${order.orderID}, '${order.orderCode}')" title="Phân công">
                                                                <i class="fas fa-user-plus"></i>
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
                                        <a class="page-link" href="?tab=${currentTab}&page=${currentPage - 1}${not empty param.search ? '&search='.concat(param.search) : ''}${not empty param.fromDate ? '&fromDate='.concat(param.fromDate) : ''}${not empty param.toDate ? '&toDate='.concat(param.toDate) : ''}${not empty param.paymentStatus ? '&paymentStatus='.concat(param.paymentStatus) : ''}">
                                            <i class="fas fa-chevron-left"></i>
                                        </a>
                                    </li>
                                </c:if>
                                
                                <c:forEach begin="1" end="${totalPages}" var="i">
                                    <c:if test="${i == 1 || i == totalPages || (i >= currentPage - 2 && i <= currentPage + 2)}">
                                        <li class="page-item ${i == currentPage ? 'active' : ''}">
                                            <a class="page-link" href="?tab=${currentTab}&page=${i}${not empty param.search ? '&search='.concat(param.search) : ''}${not empty param.fromDate ? '&fromDate='.concat(param.fromDate) : ''}${not empty param.toDate ? '&toDate='.concat(param.toDate) : ''}${not empty param.paymentStatus ? '&paymentStatus='.concat(param.paymentStatus) : ''}">${i}</a>
                                        </li>
                                    </c:if>
                                    <c:if test="${(i == 2 && currentPage > 4) || (i == totalPages - 1 && currentPage < totalPages - 3)}">
                                        <li class="page-item disabled"><span class="page-link">...</span></li>
                                    </c:if>
                                </c:forEach>
                                
                                <c:if test="${currentPage < totalPages}">
                                    <li class="page-item">
                                        <a class="page-link" href="?tab=${currentTab}&page=${currentPage + 1}${not empty param.search ? '&search='.concat(param.search) : ''}${not empty param.fromDate ? '&fromDate='.concat(param.fromDate) : ''}${not empty param.toDate ? '&toDate='.concat(param.toDate) : ''}${not empty param.paymentStatus ? '&paymentStatus='.concat(param.paymentStatus) : ''}">
                                            <i class="fas fa-chevron-right"></i>
                                        </a>
                                    </li>
                                </c:if>
                            </ul>
                            <div class="float-left text-muted">
                                Trang ${currentPage} / ${totalPages}
                            </div>
                        </div>
                    </c:if>
                </div>
                
            </div>
        </section>
    </div>

    <!-- Modal Phân công -->
    <div class="modal fade" id="assignModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Phân công đơn hàng <span id="assignOrderCode"></span></h5>
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                </div>
                <form method="post" action="${pageContext.request.contextPath}/admin/orders">
                    <div class="modal-body">
                        <input type="hidden" name="action" value="assign">
                        <input type="hidden" name="orderId" id="assignOrderId">
                        <div class="form-group">
                            <label>Chọn nhân viên xử lý:</label>
                            <select name="sellerId" class="form-control" required>
                                <option value="">-- Chọn Seller --</option>
                                <c:forEach var="seller" items="${sellers}">
                                    <option value="${seller[0]}">${seller[1]} (${seller[4]} đơn)</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="text-center">
                            <button type="button" class="btn btn-success btn-sm" onclick="autoAssign()">
                                <i class="fas fa-magic"></i> Tự động phân
                            </button>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-primary">Phân công</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <jsp:include page="../includes/admin-footer.jsp" />
</div>

<jsp:include page="../includes/admin-scripts.jsp" />
<script>
$(document).ready(function() {
    // Toggle filter form
    $('#toggleFilterBtn').click(function() {
        $('#filterForm').slideToggle(200);
        var isVisible = $('#filterForm').is(':visible');
        $('#filterBtnText').text(isVisible ? 'Ẩn bộ lọc' : 'Hiện bộ lọc');
    });
    if ($('#filterForm').is(':visible')) {
        $('#filterBtnText').text('Ẩn bộ lọc');
    }
});

function showAssignModal(orderId, orderCode) {
    $('#assignOrderId').val(orderId);
    $('#assignOrderCode').text(orderCode);
    $('#assignModal').modal('show');
}

function autoAssign() {
    var orderId = $('#assignOrderId').val();
    if (confirm('Tự động phân công đơn này cho seller ít đơn nhất?')) {
        var form = $('<form method="post" action="${pageContext.request.contextPath}/admin/orders">' +
            '<input type="hidden" name="action" value="assignAuto">' +
            '<input type="hidden" name="orderId" value="' + orderId + '">' +
            '</form>');
        $('body').append(form);
        form.submit();
    }
}
</script>
</body>
</html>
