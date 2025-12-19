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
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="includes/admin-head.jsp" />
    <title>Dashboard - Pickleball Shop Admin</title>
    <style>
        .small-box .icon { font-size: 70px; }
        .info-box-number { font-size: 1.5rem; }
        .chart-container { position: relative; height: 300px; }
    </style>
</head>
<body class="hold-transition sidebar-mini layout-fixed">
<div class="wrapper">
    <jsp:include page="includes/admin-header.jsp" />
    <jsp:include page="includes/admin-sidebar.jsp" />

    <div class="content-wrapper">
        <div class="content-header">
            <div class="container-fluid">
                <div class="row mb-2">
                    <div class="col-sm-6">
                        <h1 class="m-0">Dashboard</h1>
                    </div>
                    <div class="col-sm-6">
                        <ol class="breadcrumb float-sm-right">
                            <li class="breadcrumb-item active">Dashboard</li>
                        </ol>
                    </div>
                </div>
            </div>
        </div>

        <section class="content">
            <div class="container-fluid">
                
                <c:choose>
                    <c:when test="${userRole == 'Admin'}">
                <!-- ==================== ADMIN DASHBOARD ==================== -->
                
                <!-- Bộ lọc thời gian -->
                <div class="card card-outline card-primary mb-3">
                    <div class="card-body py-2">
                        <form method="get" class="form-inline">
                            <div class="btn-group mr-3">
                                <a href="?filter=today" class="btn btn-sm ${filterType == 'today' ? 'btn-primary' : 'btn-outline-primary'}">Hôm nay</a>
                                <a href="?filter=yesterday" class="btn btn-sm ${filterType == 'yesterday' ? 'btn-primary' : 'btn-outline-primary'}">Hôm qua</a>
                                <a href="?filter=week" class="btn btn-sm ${filterType == 'week' ? 'btn-primary' : 'btn-outline-primary'}">Tuần này</a>
                                <a href="?filter=month" class="btn btn-sm ${filterType == 'month' ? 'btn-primary' : 'btn-outline-primary'}">Tháng này</a>
                            </div>
                            <div class="form-group mr-2">
                                <input type="date" name="fromDate" class="form-control form-control-sm" 
                                       value="<fmt:formatDate value='${fromDate}' pattern='yyyy-MM-dd'/>">
                            </div>
                            <span class="mr-2">đến</span>
                            <div class="form-group mr-2">
                                <input type="date" name="toDate" class="form-control form-control-sm"
                                       value="<fmt:formatDate value='${toDate}' pattern='yyyy-MM-dd'/>">
                            </div>
                            <input type="hidden" name="filter" value="custom">
                            <button type="submit" class="btn btn-sm btn-info">
                                <i class="fas fa-filter"></i> Lọc
                            </button>
                        </form>
                    </div>
                </div>

                <!-- Thống kê tổng quan -->
                <div class="row">
                    <div class="col-lg-3 col-6">
                        <div class="small-box bg-info">
                            <div class="inner">
                                <h3><fmt:formatNumber value="${stats.revenue}" type="number" maxFractionDigits="0"/>₫</h3>
                                <p>Doanh thu</p>
                            </div>
                            <div class="icon">
                                <i class="fas fa-dollar-sign"></i>
                            </div>
                            <div class="small-box-footer">&nbsp;</div>
                        </div>
                    </div>
                    <div class="col-lg-3 col-6">
                        <div class="small-box bg-success">
                            <div class="inner">
                                <h3>${stats.totalOrders}</h3>
                                <p>Tổng đơn hàng</p>
                            </div>
                            <div class="icon">
                                <i class="fas fa-shopping-cart"></i>
                            </div>
                            <div class="small-box-footer">&nbsp;</div>
                        </div>
                    </div>
                    <div class="col-lg-3 col-6">
                        <div class="small-box bg-warning">
                            <div class="inner">
                                <h3>${stats.newOrders}</h3>
                                <p>Đơn chờ xử lý</p>
                            </div>
                            <div class="icon">
                                <i class="fas fa-clock"></i>
                            </div>
                            <div class="small-box-footer">&nbsp;</div>
                        </div>
                    </div>
                    <div class="col-lg-3 col-6">
                        <div class="small-box bg-danger">
                            <div class="inner">
                                <h3>${stats.newCustomers}</h3>
                                <p>Khách hàng mới</p>
                            </div>
                            <div class="icon">
                                <i class="fas fa-user-plus"></i>
                            </div>
                            <div class="small-box-footer">&nbsp;</div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <!-- Biểu đồ doanh thu -->
                    <div class="col-md-8">
                        <div class="card">
                            <div class="card-header">
                                <h3 class="card-title"><i class="fas fa-chart-area mr-1"></i> Biểu đồ doanh thu</h3>
                            </div>
                            <div class="card-body">
                                <div class="chart-container">
                                    <canvas id="revenueChart"></canvas>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Thống kê đơn hàng theo trạng thái -->
                    <div class="col-md-4">
                        <div class="card">
                            <div class="card-header">
                                <h3 class="card-title"><i class="fas fa-chart-pie mr-1"></i> Trạng thái đơn hàng</h3>
                            </div>
                            <div class="card-body">
                                <div style="height: 200px; position: relative;">
                                    <canvas id="orderStatusChart"></canvas>
                                </div>
                                <div class="mt-3">
                                    <c:forEach var="entry" items="${stats.ordersByStatus}">
                                        <div class="d-flex justify-content-between mb-1">
                                            <span>
                                                <c:choose>
                                                    <c:when test="${entry.key == 'Pending'}"><span class="badge badge-secondary">Chờ xử lý</span></c:when>
                                                    <c:when test="${entry.key == 'Confirmed'}"><span class="badge badge-info">Đã xác nhận</span></c:when>
                                                    <c:when test="${entry.key == 'Processing'}"><span class="badge badge-primary">Đang xử lý</span></c:when>
                                                    <c:when test="${entry.key == 'Shipping'}"><span class="badge badge-warning">Đang giao</span></c:when>
                                                    <c:when test="${entry.key == 'Delivered'}"><span class="badge badge-success">Đã giao</span></c:when>
                                                    <c:when test="${entry.key == 'Cancelled'}"><span class="badge badge-danger">Đã hủy</span></c:when>
                                                </c:choose>
                                            </span>
                                            <span>${entry.value}</span>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <!-- Top sản phẩm bán chạy -->
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header">
                                <h3 class="card-title"><i class="fas fa-trophy mr-1"></i> Top sản phẩm bán chạy</h3>
                            </div>
                            <div class="card-body p-0">
                                <table class="table table-striped">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Sản phẩm</th>
                                            <th>SL bán</th>
                                            <th>Doanh thu</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="product" items="${topProducts}" varStatus="loop">
                                            <tr>
                                                <td>${loop.index + 1}</td>
                                                <td>${product[0]}</td>
                                                <td>${product[1]}</td>
                                                <td><fmt:formatNumber value="${product[2]}" type="number" maxFractionDigits="0"/>₫</td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty topProducts}">
                                            <tr><td colspan="4" class="text-center text-muted">Chưa có dữ liệu</td></tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Sản phẩm sắp hết hàng -->
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-warning">
                                <h3 class="card-title"><i class="fas fa-exclamation-triangle mr-1"></i> Sản phẩm sắp hết hàng</h3>
                            </div>
                            <div class="card-body p-0">
                                <table class="table table-striped">
                                    <thead>
                                        <tr>
                                            <th>Sản phẩm</th>
                                            <th>Số lượng</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="product" items="${lowStockProducts}">
                                            <tr>
                                                <td>${product.productName}</td>
                                                <td>
                                                    <span class="badge badge-${product.totalStock < 5 ? 'danger' : 'warning'}">
                                                        ${product.totalStock}
                                                    </span>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty lowStockProducts}">
                                            <tr><td colspan="2" class="text-center text-muted">Không có sản phẩm sắp hết</td></tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
                
                    </c:when>
                    <c:otherwise>
                <!-- ==================== WELCOME MESSAGE FOR OTHER ROLES ==================== -->
                <div class="row">
                    <div class="col-12">
                        <div class="callout callout-info">
                            <h5><i class="fas fa-info-circle mr-2"></i>Xin chào, ${employeeName}!</h5>
                            <p class="mb-0">
                                Bạn đang đăng nhập với vai trò: 
                                <strong><%= RolePermission.getRoleDisplayName((String) request.getAttribute("userRole")) %></strong>
                            </p>
                        </div>
                    </div>
                </div>
                
                <div class="row">
                    <div class="col-lg-6">
                        <div class="card">
                            <div class="card-header">
                                <h3 class="card-title"><i class="fas fa-info-circle mr-2"></i>Thông tin tài khoản</h3>
                            </div>
                            <div class="card-body">
                                <table class="table table-borderless">
                                    <tr>
                                        <td width="40%"><strong>Họ tên:</strong></td>
                                        <td>${employeeName}</td>
                                    </tr>
                                    <tr>
                                        <td><strong>Vai trò:</strong></td>
                                        <td>
                                            <span class="badge badge-info">
                                                <%= RolePermission.getRoleDisplayName((String) request.getAttribute("userRole")) %>
                                            </span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><strong>Email:</strong></td>
                                        <td><%= ((Employee) session.getAttribute("employee")).getEmail() %></td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
                    </c:otherwise>
                </c:choose>

            </div>
        </section>
    </div>

    <jsp:include page="includes/admin-footer.jsp" />
</div>

<jsp:include page="includes/admin-scripts.jsp" />
<c:if test="${userRole == 'Admin'}">
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Dữ liệu biểu đồ từ server
    var chartLabels = ${chartLabels};
    var chartRevenue = ${chartRevenue};
    var chartOrders = ${chartOrders};

    // Biểu đồ doanh thu
    var revenueCtx = document.getElementById('revenueChart');
    if (revenueCtx) {
        new Chart(revenueCtx, {
            type: 'line',
            data: {
                labels: chartLabels,
                datasets: [{
                    label: 'Doanh thu (₫)',
                    data: chartRevenue,
                    borderColor: 'rgb(75, 192, 192)',
                    backgroundColor: 'rgba(75, 192, 192, 0.2)',
                    tension: 0.3,
                    fill: true,
                    yAxisID: 'y'
                }, {
                    label: 'Số đơn',
                    data: chartOrders,
                    borderColor: 'rgb(255, 99, 132)',
                    backgroundColor: 'rgba(255, 99, 132, 0.2)',
                    tension: 0.3,
                    yAxisID: 'y1'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: {
                    mode: 'index',
                    intersect: false,
                },
                scales: {
                    y: {
                        type: 'linear',
                        display: true,
                        position: 'left',
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) {
                                return value.toLocaleString('vi-VN') + '₫';
                            }
                        }
                    },
                    y1: {
                        type: 'linear',
                        display: true,
                        position: 'right',
                        beginAtZero: true,
                        grid: {
                            drawOnChartArea: false,
                        }
                    }
                }
            }
        });
    }

    // Biểu đồ trạng thái đơn hàng
    var statusCtx = document.getElementById('orderStatusChart');
    if (statusCtx) {
        var statusData = [
            parseInt('${stats.ordersByStatus["Pending"]}') || 0,
            parseInt('${stats.ordersByStatus["Confirmed"]}') || 0,
            parseInt('${stats.ordersByStatus["Processing"]}') || 0,
            parseInt('${stats.ordersByStatus["Shipping"]}') || 0,
            parseInt('${stats.ordersByStatus["Delivered"]}') || 0,
            parseInt('${stats.ordersByStatus["Cancelled"]}') || 0
        ];
        
        new Chart(statusCtx, {
            type: 'doughnut',
            data: {
                labels: ['Chờ xử lý', 'Đã xác nhận', 'Đang xử lý', 'Đang giao', 'Đã giao', 'Đã hủy'],
                datasets: [{
                    data: statusData,
                    backgroundColor: [
                        '#6c757d',
                        '#17a2b8',
                        '#007bff',
                        '#ffc107',
                        '#28a745',
                        '#dc3545'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                plugins: {
                    legend: {
                        display: false
                    }
                }
            }
        });
    }
});
</script>
</c:if>
</body>
</html>
