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
    // Set attributes for JSTL
    request.setAttribute("userRole", userRole);
    request.setAttribute("canAssign", canAssign);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="../includes/admin-head.jsp" />
    <title>Quản lý đơn hàng - Pickleball Shop</title>
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
                        <h1 class="m-0">Quản lý đơn hàng</h1>
                    </div>
                    <div class="col-sm-6">
                        <ol class="breadcrumb float-sm-right">
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Trang chủ</a></li>
                            <li class="breadcrumb-item active">Đơn hàng</li>
                        </ol>
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

                <!-- Tabs cho SellerManager -->
                <c:if test="${userRole == 'SellerManager' || userRole == 'Admin'}">
                    <ul class="nav nav-tabs mb-3">
                        <li class="nav-item">
                            <a class="nav-link ${param.tab == null || param.tab == 'all' ? 'active' : ''}" 
                               href="?tab=all">
                                Tất cả <span class="badge badge-primary">${totalOrders}</span>
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link ${param.tab == 'unassigned' ? 'active' : ''}" 
                               href="?tab=unassigned">
                                Chưa phân công 
                                <span class="badge badge-warning">${unassignedCount}</span>
                            </a>
                        </li>
                    </ul>
                </c:if>
                
                <!-- Filter Card -->
                <div class="card card-outline card-primary collapsed-card">
                    <div class="card-header">
                        <h3 class="card-title">
                            <i class="fas fa-filter"></i> Bộ lọc
                        </h3>
                        <div class="card-tools">
                            <button type="button" class="btn btn-tool" data-card-widget="collapse">
                                <i class="fas fa-plus"></i>
                            </button>
                        </div>
                    </div>
                    <div class="card-body">
                        <form method="get" class="row">
                            <input type="hidden" name="tab" value="${param.tab}">
                            <div class="col-md-3">
                                <div class="form-group">
                                    <label>Tìm kiếm</label>
                                    <input type="text" name="search" class="form-control" 
                                           placeholder="Mã đơn, tên KH, SĐT..." value="${param.search}">
                                </div>
                            </div>
                            <div class="col-md-2">
                                <div class="form-group">
                                    <label>Trạng thái</label>
                                    <select name="status" class="form-control">
                                        <option value="">-- Tất cả --</option>
                                        <option value="Pending" ${param.status == 'Pending' ? 'selected' : ''}>Chờ xử lý</option>
                                        <option value="Confirmed" ${param.status == 'Confirmed' ? 'selected' : ''}>Đã xác nhận</option>
                                        <option value="Processing" ${param.status == 'Processing' ? 'selected' : ''}>Đang xử lý</option>
                                        <option value="Shipping" ${param.status == 'Shipping' ? 'selected' : ''}>Đang giao</option>
                                        <option value="Delivered" ${param.status == 'Delivered' ? 'selected' : ''}>Đã giao</option>
                                        <option value="Cancelled" ${param.status == 'Cancelled' ? 'selected' : ''}>Đã hủy</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-2">
                                <div class="form-group">
                                    <label>Thanh toán</label>
                                    <select name="paymentStatus" class="form-control">
                                        <option value="">-- Tất cả --</option>
                                        <option value="Paid" ${param.paymentStatus == 'Paid' ? 'selected' : ''}>Đã thanh toán</option>
                                        <option value="Unpaid" ${param.paymentStatus == 'Unpaid' ? 'selected' : ''}>Chưa thanh toán</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-2">
                                <div class="form-group">
                                    <label>Từ ngày</label>
                                    <input type="date" name="fromDate" class="form-control" value="${param.fromDate}">
                                </div>
                            </div>
                            <div class="col-md-2">
                                <div class="form-group">
                                    <label>Đến ngày</label>
                                    <input type="date" name="toDate" class="form-control" value="${param.toDate}">
                                </div>
                            </div>
                            <div class="col-md-1">
                                <div class="form-group">
                                    <label>&nbsp;</label>
                                    <button type="submit" class="btn btn-primary btn-block">
                                        <i class="fas fa-search"></i>
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Orders Table -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Danh sách đơn hàng</h3>
                    </div>
                    <div class="card-body table-responsive p-0">
                        <table class="table table-hover text-nowrap">
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
                                            <fmt:formatNumber value="${order.totalAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
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
                                                    ${order.assignedSeller.fullName}
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-warning">
                                                        <i class="fas fa-exclamation-triangle"></i> Chưa phân
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <a href="?action=detail&id=${order.orderID}" 
                                               class="btn btn-sm btn-info" title="Xem chi tiết">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            <c:if test="${(userRole == 'SellerManager' || userRole == 'Admin') && order.assignedTo == null}">
                                                <button class="btn btn-sm btn-warning" 
                                                        onclick="showAssignModal(${order.orderID}, '${order.orderCode}')"
                                                        title="Phân công">
                                                    <i class="fas fa-user-plus"></i>
                                                </button>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                                
                                <c:if test="${empty orders}">
                                    <tr>
                                        <td colspan="8" class="text-center text-muted py-4">
                                            <i class="fas fa-inbox fa-3x mb-3"></i>
                                            <p>Không có đơn hàng nào</p>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination -->
                    <div class="card-footer clearfix">
                        <div class="float-left">
                            Hiển thị ${(currentPage-1)*pageSize + 1} - ${currentPage*pageSize > totalOrders ? totalOrders : currentPage*pageSize} 
                            / ${totalOrders} đơn hàng
                        </div>
                        <ul class="pagination pagination-sm m-0 float-right">
                            <c:if test="${currentPage > 1}">
                                <li class="page-item">
                                    <a class="page-link" href="?page=${currentPage-1}&tab=${param.tab}&search=${param.search}&status=${param.status}">
                                        &laquo;
                                    </a>
                                </li>
                            </c:if>
                            
                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <c:if test="${i <= 5 || i > totalPages - 2 || (i >= currentPage - 1 && i <= currentPage + 1)}">
                                    <li class="page-item ${i == currentPage ? 'active' : ''}">
                                        <a class="page-link" href="?page=${i}&tab=${param.tab}&search=${param.search}&status=${param.status}">
                                            ${i}
                                        </a>
                                    </li>
                                </c:if>
                            </c:forEach>
                            
                            <c:if test="${currentPage < totalPages}">
                                <li class="page-item">
                                    <a class="page-link" href="?page=${currentPage+1}&tab=${param.tab}&search=${param.search}&status=${param.status}">
                                        &raquo;
                                    </a>
                                </li>
                            </c:if>
                        </ul>
                    </div>
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
                                    <option value="${seller[0]}">
                                        ${seller[1]} (${seller[4]} đơn đang xử lý)
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="text-center">
                            <button type="button" class="btn btn-success btn-sm" onclick="autoAssign()">
                                <i class="fas fa-magic"></i> Tự động phân cho người ít đơn nhất
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
