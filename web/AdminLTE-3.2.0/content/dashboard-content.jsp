<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="entity.Employee" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.math.BigDecimal" %>
<%
    Employee employee = (Employee) session.getAttribute("employee");
    String adminName = employee != null ? employee.getFullName() : "Admin";
    String userRole = employee != null ? employee.getRole() : "";
    boolean isAdmin = "Admin".equalsIgnoreCase(userRole);
%>

<!-- Content Header -->
<div class="content-header">
    <div class="container-fluid">
        <div class="row mb-2">
            <div class="col-sm-12">
                <h1 class="m-0">Dashboard</h1>
            </div>
        </div>
    </div>
</div>

<!-- Main content -->
<section class="content">
    <div class="container-fluid">
        
        <!-- Info Boxes -->
        <div class="row">
            <!-- Doanh thu tháng -->
            <div class="col-12 col-sm-6 col-md-3">
                <div class="info-box">
                    <span class="info-box-icon bg-success elevation-1"><i class="fas fa-dollar-sign"></i></span>
                    <div class="info-box-content">
                        <span class="info-box-text">Doanh thu tháng</span>
                        <span class="info-box-number">
                            <fmt:formatNumber value="${monthlyRevenue != null ? monthlyRevenue : 0}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                        </span>
                        <small class="text-muted">Tổng: <fmt:formatNumber value="${totalRevenue != null ? totalRevenue : 0}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ</small>
                    </div>
                </div>
            </div>
            
            <!-- Đơn hàng -->
            <div class="col-12 col-sm-6 col-md-3">
                <div class="info-box">
                    <span class="info-box-icon bg-info elevation-1"><i class="fas fa-shopping-cart"></i></span>
                    <div class="info-box-content">
                        <span class="info-box-text">Đơn hàng</span>
                        <span class="info-box-number">${totalOrders != null ? totalOrders : 0}</span>
                        <small class="text-muted">Hôm nay: ${todayOrders != null ? todayOrders : 0} | Chờ xử lý: <span class="text-warning">${pendingOrders != null ? pendingOrders : 0}</span></small>
                    </div>
                </div>
            </div>
            
            <!-- Khách hàng -->
            <div class="col-12 col-sm-6 col-md-3">
                <div class="info-box">
                    <span class="info-box-icon bg-warning elevation-1"><i class="fas fa-users"></i></span>
                    <div class="info-box-content">
                        <span class="info-box-text">Khách hàng</span>
                        <span class="info-box-number">${totalCustomers != null ? totalCustomers : 0}</span>
                        <small class="text-muted">Mới tháng này: <span class="text-success">+${newCustomers != null ? newCustomers : 0}</span></small>
                    </div>
                </div>
            </div>
            
            <!-- Sản phẩm -->
            <div class="col-12 col-sm-6 col-md-3">
                <div class="info-box">
                    <span class="info-box-icon bg-danger elevation-1"><i class="fas fa-box"></i></span>
                    <div class="info-box-content">
                        <span class="info-box-text">Sản phẩm</span>
                        <span class="info-box-number">${totalProducts != null ? totalProducts : 0}</span>
                        <small class="text-muted">Hết hàng: <span class="text-danger">${outOfStock != null ? outOfStock : 0}</span></small>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Charts Row 1: Doanh thu -->
        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title"><i class="fas fa-chart-bar mr-1"></i> Doanh thu 7 ngày gần nhất</h3>
                    </div>
                    <div class="card-body">
                        <div style="height: 280px;">
                            <canvas id="revenueChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Charts Row 2: Đơn hàng theo trạng thái -->
        <div class="row">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title"><i class="fas fa-chart-pie mr-1"></i> Đơn hàng theo trạng thái</h3>
                    </div>
                    <div class="card-body">
                        <div style="height: 300px;">
                            <canvas id="orderStatusChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Top sản phẩm bán chạy -->
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title"><i class="fas fa-trophy mr-1 text-warning"></i> Top sản phẩm bán chạy</h3>
                    </div>
                    <div class="card-body p-0">
                        <ul class="list-group list-group-flush">
                            <c:forEach var="product" items="${topProducts}" varStatus="loop">
                                <li class="list-group-item d-flex justify-content-between align-items-center">
                                    <span><span class="badge badge-primary mr-2">${loop.index + 1}</span> ${product.name}</span>
                                    <span class="badge badge-success">${product.sold} đã bán</span>
                                </li>
                            </c:forEach>
                            <c:if test="${empty topProducts}">
                                <li class="list-group-item text-center text-muted">Chưa có dữ liệu</li>
                            </c:if>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Tables Row -->
        <div class="row">
            <!-- Đơn hàng mới nhất -->
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title"><i class="fas fa-list mr-1"></i> Đơn hàng mới nhất</h3>
                        <div class="card-tools">
                            <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-tool btn-sm">
                                <i class="fas fa-external-link-alt"></i> Xem tất cả
                            </a>
                        </div>
                    </div>
                    <div class="card-body table-responsive p-0">
                        <table class="table table-hover text-nowrap">
                            <thead>
                                <tr>
                                    <th>Mã đơn</th>
                                    <th>Khách hàng</th>
                                    <th>Tổng tiền</th>
                                    <th>Trạng thái</th>
                                    <th>Ngày đặt</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="order" items="${recentOrders}">
                                    <tr>
                                        <td><a href="${pageContext.request.contextPath}/admin/orders?action=detail&id=${order.orderId}">${order.orderCode}</a></td>
                                        <td>${order.customerName}</td>
                                        <td><fmt:formatNumber value="${order.totalAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${order.status == 'Pending'}"><span class="badge badge-secondary">Chờ xử lý</span></c:when>
                                                <c:when test="${order.status == 'Confirmed'}"><span class="badge badge-info">Đã xác nhận</span></c:when>
                                                <c:when test="${order.status == 'Processing'}"><span class="badge badge-primary">Đang xử lý</span></c:when>
                                                <c:when test="${order.status == 'Shipping'}"><span class="badge badge-warning">Đang giao</span></c:when>
                                                <c:when test="${order.status == 'Delivered'}"><span class="badge badge-success">Đã giao</span></c:when>
                                                <c:when test="${order.status == 'Cancelled'}"><span class="badge badge-danger">Đã hủy</span></c:when>
                                                <c:otherwise><span class="badge badge-secondary">${order.status}</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy HH:mm"/></td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty recentOrders}">
                                    <tr><td colspan="5" class="text-center text-muted">Chưa có đơn hàng</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            
            <!-- Sản phẩm sắp hết hàng -->
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title"><i class="fas fa-exclamation-triangle mr-1 text-danger"></i> Sắp hết hàng</h3>
                    </div>
                    <div class="card-body p-0">
                        <ul class="list-group list-group-flush">
                            <c:forEach var="product" items="${lowStockProducts}">
                                <li class="list-group-item d-flex justify-content-between align-items-center">
                                    <span>${product.name}</span>
                                    <span class="badge badge-danger">Còn ${product.stock}</span>
                                </li>
                            </c:forEach>
                            <c:if test="${empty lowStockProducts}">
                                <li class="list-group-item text-center text-muted">Không có sản phẩm sắp hết</li>
                            </c:if>
                        </ul>
                    </div>
                </div>
            </div>
        </div>

    </div>
</section>

<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Revenue Chart Data
    var revenueLabels = [];
    var revenueData = [];
    <c:forEach var="entry" items="${revenueChart}">
        revenueLabels.push('${entry.key}');
        revenueData.push(${entry.value});
    </c:forEach>
    
    // Revenue Bar Chart
    if (document.getElementById('revenueChart')) {
        new Chart(document.getElementById('revenueChart'), {
            type: 'bar',
            data: {
                labels: revenueLabels.length > 0 ? revenueLabels : ['Chưa có dữ liệu'],
                datasets: [{
                    label: 'Doanh thu (VNĐ)',
                    data: revenueData.length > 0 ? revenueData : [0],
                    backgroundColor: '#28a745',
                    borderColor: '#1e7e34',
                    borderWidth: 1,
                    borderRadius: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) {
                                if (value >= 1000000) {
                                    return (value / 1000000).toFixed(1) + 'M';
                                } else if (value >= 1000) {
                                    return (value / 1000).toFixed(0) + 'K';
                                }
                                return value;
                            }
                        }
                    }
                }
            }
        });
    }
    
    // Order Status Chart Data
    var statusLabels = [];
    var statusData = [];
    var statusColors = {
        'Pending': '#6c757d',
        'Confirmed': '#17a2b8',
        'Processing': '#007bff',
        'Shipping': '#ffc107',
        'Delivered': '#28a745',
        'Cancelled': '#dc3545'
    };
    var statusNames = {
        'Pending': 'Chờ xử lý',
        'Confirmed': 'Đã xác nhận',
        'Processing': 'Đang xử lý',
        'Shipping': 'Đang giao',
        'Delivered': 'Đã giao',
        'Cancelled': 'Đã hủy'
    };
    var bgColors = [];
    
    <c:forEach var="entry" items="${ordersByStatus}">
        statusLabels.push(statusNames['${entry.key}'] || '${entry.key}');
        statusData.push(${entry.value});
        bgColors.push(statusColors['${entry.key}'] || '#6c757d');
    </c:forEach>
    
    // Order Status Doughnut Chart
    if (document.getElementById('orderStatusChart')) {
        new Chart(document.getElementById('orderStatusChart'), {
            type: 'doughnut',
            data: {
                labels: statusLabels.length > 0 ? statusLabels : ['Chưa có đơn hàng'],
                datasets: [{
                    data: statusData.length > 0 ? statusData : [1],
                    backgroundColor: bgColors.length > 0 ? bgColors : ['#e9ecef'],
                    borderWidth: 2,
                    borderColor: '#fff'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            padding: 15,
                            usePointStyle: true,
                            font: { size: 11 }
                        }
                    }
                },
                cutout: '50%'
            }
        });
    }
});
</script>
