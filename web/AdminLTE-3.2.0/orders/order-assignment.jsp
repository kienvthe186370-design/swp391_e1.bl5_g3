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
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Giám sát Seller | Admin</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/AdminLTE-3.2.0/plugins/fontawesome-free/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/AdminLTE-3.2.0/dist/css/adminlte.min.css">
    <style>
        .seller-card { transition: all 0.3s; }
        .seller-card:hover { transform: translateY(-2px); box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
    </style>
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">
    <jsp:include page="../includes/admin-header.jsp" />
    <jsp:include page="../includes/admin-sidebar.jsp" />

    <div class="content-wrapper">
        <div class="content-header">
            <div class="container-fluid">
                <div class="row mb-2">
                    <div class="col-sm-6">
                        <h1 class="m-0"><i class="fas fa-user-tie"></i> Giám sát Seller</h1>
                    </div>
                    <div class="col-sm-6">
                        <ol class="breadcrumb float-sm-right">
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/orders">Đơn hàng</a></li>
                            <li class="breadcrumb-item active">Giám sát Seller</li>
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
                                <c:choose>
                                    <c:when test="${empty sellers}">
                                        <div class="p-4 text-center text-muted">
                                            <i class="fas fa-user-slash fa-3x mb-3"></i>
                                            <p>Chưa có seller nào</p>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="seller" items="${sellers}">
                                            <div class="seller-card p-3 border-bottom">
                                                <div class="d-flex justify-content-between align-items-center">
                                                    <div>
                                                        <i class="fas fa-user-circle fa-2x text-info mr-2"></i>
                                                        <strong>${seller[1]}</strong>
                                                        <br>
                                                        <small class="text-muted ml-4">
                                                            <i class="fas fa-envelope"></i> ${seller[2]}
                                                        </small>
                                                    </div>
                                                    <div class="text-right">
                                                        <span class="badge badge-${seller[4] > 5 ? 'danger' : (seller[4] > 2 ? 'warning' : 'success')} badge-pill" style="font-size:16px">
                                                            ${seller[4]}
                                                        </span>
                                                        <br><small class="text-muted">đơn đang xử lý</small>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <!-- Đơn hàng chưa phân công (nếu có) -->
                    <div class="col-md-8">
                        <div class="card">
                            <div class="card-header bg-primary">
                                <h3 class="card-title text-white">
                                    <i class="fas fa-clipboard-list"></i> Đơn hàng chưa phân công
                                    <c:if test="${not empty unassignedOrders}">
                                        <span class="badge badge-warning ml-2">${unassignedOrders.size()}</span>
                                    </c:if>
                                </h3>
                            </div>
                            <div class="card-body p-0">
                                <c:choose>
                                    <c:when test="${empty unassignedOrders}">
                                        <div class="p-4 text-center text-muted">
                                            <i class="fas fa-check-circle fa-3x mb-3 text-success"></i>
                                            <p>Tất cả đơn hàng đã được phân công tự động!</p>
                                            <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-primary">
                                                <i class="fas fa-list"></i> Xem danh sách đơn hàng
                                            </a>
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
                                                    <c:forEach var="order" items="${unassignedOrders}">
                                                        <tr>
                                                            <td>
                                                                <a href="${pageContext.request.contextPath}/admin/orders?action=detail&id=${order.orderID}">
                                                                    <strong>${order.orderCode}</strong>
                                                                </a>
                                                            </td>
                                                            <td>
                                                                ${order.customer.fullName}<br>
                                                                <small class="text-muted">${order.customer.phone}</small>
                                                            </td>
                                                            <td>
                                                                <fmt:formatNumber value="${order.totalAmount}" type="number"/>đ
                                                            </td>
                                                            <td>
                                                                <span class="badge badge-warning">${order.orderStatus}</span>
                                                            </td>
                                                            <td>
                                                                <button type="button" class="btn btn-success btn-sm" 
                                                                        data-toggle="modal" 
                                                                        data-target="#assignModal${order.orderID}"
                                                                        title="Phân công Seller">
                                                                    <i class="fas fa-user-plus"></i> Phân công
                                                                </button>
                                                                
                                                                <!-- Modal phân công seller -->
                                                                <div class="modal fade" id="assignModal${order.orderID}" tabindex="-1">
                                                                    <div class="modal-dialog modal-sm">
                                                                        <div class="modal-content">
                                                                            <div class="modal-header bg-success">
                                                                                <h5 class="modal-title text-white">Phân công Seller</h5>
                                                                                <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
                                                                            </div>
                                                                            <form method="post" action="${pageContext.request.contextPath}/admin/orders">
                                                                                <div class="modal-body">
                                                                                    <input type="hidden" name="action" value="assign">
                                                                                    <input type="hidden" name="orderId" value="${order.orderID}">
                                                                                    <p><strong>Đơn:</strong> ${order.orderCode}</p>
                                                                                    <div class="form-group">
                                                                                        <label>Chọn Seller:</label>
                                                                                        <select name="sellerId" class="form-control" required>
                                                                                            <c:forEach var="seller" items="${sellers}">
                                                                                                <option value="${seller[0]}">
                                                                                                    ${seller[1]} (${seller[4]} đơn)
                                                                                                </option>
                                                                                            </c:forEach>
                                                                                        </select>
                                                                                    </div>
                                                                                </div>
                                                                                <div class="modal-footer">
                                                                                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                                                                                    <button type="submit" class="btn btn-success">Phân công</button>
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