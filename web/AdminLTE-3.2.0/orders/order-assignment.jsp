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
    if (!RolePermission.canAssignOrders(userRole)) {
        response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="../includes/admin-head.jsp" />
    <title>Phân công đơn hàng - Pickleball Shop</title>
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
                        <h1 class="m-0">Phân công đơn hàng</h1>
                    </div>
                    <div class="col-sm-6">
                        <ol class="breadcrumb float-sm-right">
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/orders">Đơn hàng</a></li>
                            <li class="breadcrumb-item active">Phân công</li>
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
                
                <div class="row">
                    <!-- Danh sách Seller -->
                    <div class="col-md-4">
                        <div class="card">
                            <div class="card-header bg-info">
                                <h3 class="card-title text-white"><i class="fas fa-users"></i> Danh sách Seller</h3>
                            </div>
                            <div class="card-body p-0">
                                <table class="table table-striped">
                                    <thead>
                                        <tr>
                                            <th>Nhân viên</th>
                                            <th class="text-center">Đơn đang xử lý</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="seller" items="${sellers}">
                                            <tr>
                                                <td>
                                                    <strong>${seller[1]}</strong>
                                                    <br><small class="text-muted">${seller[2]}</small>
                                                </td>
                                                <td class="text-center">
                                                    <span class="badge badge-${seller[4] > 5 ? 'danger' : (seller[4] > 2 ? 'warning' : 'success')}">
                                                        ${seller[4]}
                                                    </span>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Đơn chưa phân công -->
                    <div class="col-md-8">
                        <div class="card">
                            <div class="card-header bg-warning">
                                <h3 class="card-title"><i class="fas fa-exclamation-triangle"></i> Đơn hàng chưa phân công (${unassignedOrders.size()})</h3>
                            </div>
                            <div class="card-body p-0">
                                <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>Mã đơn</th>
                                            <th>Khách hàng</th>
                                            <th>Tổng tiền</th>
                                            <th>Ngày đặt</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="order" items="${unassignedOrders}">
                                            <tr>
                                                <td>
                                                    <a href="${pageContext.request.contextPath}/admin/orders?action=detail&id=${order.orderID}">
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
                                                    <fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy HH:mm"/>
                                                </td>
                                                <td>
                                                    <div class="btn-group">
                                                        <button class="btn btn-sm btn-primary" 
                                                                onclick="showAssignModal(${order.orderID}, '${order.orderCode}')">
                                                            <i class="fas fa-user-plus"></i> Phân công
                                                        </button>
                                                        <form method="post" action="${pageContext.request.contextPath}/admin/orders" style="display: inline;">
                                                            <input type="hidden" name="action" value="assignAuto">
                                                            <input type="hidden" name="orderId" value="${order.orderID}">
                                                            <button type="submit" class="btn btn-sm btn-success" title="Tự động phân công">
                                                                <i class="fas fa-magic"></i>
                                                            </button>
                                                        </form>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        
                                        <c:if test="${empty unassignedOrders}">
                                            <tr>
                                                <td colspan="5" class="text-center text-success py-4">
                                                    <i class="fas fa-check-circle fa-3x mb-3"></i>
                                                    <p>Tất cả đơn hàng đã được phân công!</p>
                                                </td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                            <c:if test="${not empty unassignedOrders}">
                                <div class="card-footer">
                                    <form method="post" action="${pageContext.request.contextPath}/admin/orders" 
                                          onsubmit="return confirm('Tự động phân công tất cả đơn hàng?');">
                                        <input type="hidden" name="action" value="assignAllAuto">
                                        <button type="submit" class="btn btn-success">
                                            <i class="fas fa-magic"></i> Tự động phân công tất cả
                                        </button>
                                    </form>
                                </div>
                            </c:if>
                        </div>
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
</script>
</body>
</html>
