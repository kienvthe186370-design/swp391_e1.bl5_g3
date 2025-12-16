<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Yêu Cầu Báo Giá - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .stat-card { border-radius: 8px; padding: 20px; color: white; }
        .stat-card.warning { background: linear-gradient(135deg, #ffc107, #d39e00); color: #333; }
        .stat-card.info { background: linear-gradient(135deg, #17a2b8, #117a8b); }
        .stat-card.primary { background: linear-gradient(135deg, #007bff, #0056b3); }
        .stat-card.success { background: linear-gradient(135deg, #28a745, #1e7e34); }
        .stat-card .stat-icon { font-size: 2.5rem; opacity: 0.7; }
        .stat-card .stat-number { font-size: 1.75rem; font-weight: 700; }
        .stat-card .stat-label { font-size: 0.875rem; opacity: 0.9; }
        .priority-high { border-left: 4px solid #dc3545; }
        .priority-normal { border-left: 4px solid #007bff; }
        .status-badge { font-size: 0.8rem; padding: 4px 10px; }
    </style>
</head>
<body class="bg-light">
    <div class="container-fluid py-4">
        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4><i class="fas fa-file-invoice"></i> Quản Lý Yêu Cầu Báo Giá (RFQ)</h4>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin">Dashboard</a></li>
                        <li class="breadcrumb-item active">RFQ Management</li>
                    </ol>
                </nav>
            </div>
        </div>

        <!-- Statistics Cards -->
        <div class="row mb-4">
            <div class="col-lg-3 col-6 mb-3">
                <div class="stat-card warning">
                    <div class="d-flex justify-content-between">
                        <div>
                            <div class="stat-number">${pendingCount}</div>
                            <div class="stat-label">Chờ Xử Lý</div>
                        </div>
                        <div class="stat-icon"><i class="fas fa-clock"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 col-6 mb-3">
                <div class="stat-card info">
                    <div class="d-flex justify-content-between">
                        <div>
                            <div class="stat-number">${processingCount}</div>
                            <div class="stat-label">Đang Xử Lý</div>
                        </div>
                        <div class="stat-icon"><i class="fas fa-spinner"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 col-6 mb-3">
                <div class="stat-card primary">
                    <div class="d-flex justify-content-between">
                        <div>
                            <div class="stat-number">${quotedCount}</div>
                            <div class="stat-label">Đã Báo Giá</div>
                        </div>
                        <div class="stat-icon"><i class="fas fa-file-invoice-dollar"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 col-6 mb-3">
                <div class="stat-card success">
                    <div class="d-flex justify-content-between">
                        <div>
                            <div class="stat-number">${completedCount}</div>
                            <div class="stat-label">Hoàn Thành</div>
                        </div>
                        <div class="stat-icon"><i class="fas fa-check-circle"></i></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Filter -->
        <div class="card mb-4">
            <div class="card-body">
                <form class="row g-3" method="GET">
                    <div class="col-md-3">
                        <input type="text" class="form-control" name="keyword" placeholder="Mã RFQ, công ty, khách hàng..." value="${keyword}">
                    </div>
                    <div class="col-md-2">
                        <select class="form-select" name="status">
                            <option value="">Tất cả trạng thái</option>
                            <option value="Pending" ${status == 'Pending' ? 'selected' : ''}>Chờ xử lý</option>
                            <option value="DateProposed" ${status == 'DateProposed' ? 'selected' : ''}>Đề xuất ngày</option>
                            <option value="Quoted" ${status == 'Quoted' ? 'selected' : ''}>Đã báo giá</option>
                            <option value="Completed" ${status == 'Completed' ? 'selected' : ''}>Hoàn thành</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <select class="form-select" name="assignedTo">
                            <option value="">Tất cả</option>
                            <option value="me" ${assignedTo == 'me' ? 'selected' : ''}>Của tôi</option>
                            <option value="unassigned" ${assignedTo == 'unassigned' ? 'selected' : ''}>Chưa phân công</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <button type="submit" class="btn btn-primary w-100"><i class="fas fa-search"></i> Tìm</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- RFQ List -->
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0">Danh Sách Yêu Cầu Báo Giá</h5>
                <span class="badge bg-info">${totalCount} kết quả</span>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Mã RFQ</th>
                                <th>Khách Hàng</th>
                                <th>Công Ty</th>
                                <th>Ngày Tạo</th>
                                <th>Ngày Yêu Cầu</th>
                                <th>Giá Trị</th>
                                <th>Trạng Thái</th>
                                <th>Hành Động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="rfq" items="${rfqs}">
                                <tr class="${rfq.status == 'Pending' ? 'priority-high' : 'priority-normal'}">
                                    <td>
                                        <a href="${pageContext.request.contextPath}/admin/rfq/detail?id=${rfq.rfqID}">
                                            <strong>${rfq.rfqCode}</strong>
                                        </a>
                                    </td>
                                    <td>
                                        ${rfq.contactPerson}<br>
                                        <small class="text-muted">${rfq.contactPhone}</small>
                                    </td>
                                    <td>${rfq.companyName}</td>
                                    <td><fmt:formatDate value="${rfq.createdDate}" pattern="dd/MM/yyyy"/></td>
                                    <td>
                                        <fmt:formatDate value="${rfq.requestedDeliveryDate}" pattern="dd/MM/yyyy"/>
                                        <c:if test="${rfq.proposedDeliveryDate != null}">
                                            <br><small class="text-primary">→ <fmt:formatDate value="${rfq.proposedDeliveryDate}" pattern="dd/MM/yyyy"/></small>
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${rfq.totalAmount != null && rfq.totalAmount > 0}">
                                                <strong class="text-primary"><fmt:formatNumber value="${rfq.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></strong>
                                            </c:when>
                                            <c:otherwise><span class="text-muted">Chưa báo giá</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span class="badge status-badge bg-${rfq.status == 'Completed' ? 'success' : rfq.status == 'Quoted' ? 'primary' : rfq.status == 'Pending' ? 'warning' : 'info'}">
                                            ${rfq.statusDisplayName}
                                        </span>
                                    </td>
                                    <td>
                                        <div class="btn-group btn-group-sm">
                                            <a href="${pageContext.request.contextPath}/admin/rfq/detail?id=${rfq.rfqID}" class="btn btn-outline-info" title="Xem">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty rfqs}">
                                <tr><td colspan="8" class="text-center py-4 text-muted">Không có dữ liệu</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
                <div class="card-footer">
                    <nav>
                        <ul class="pagination pagination-sm mb-0 justify-content-end">
                            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage - 1}&keyword=${keyword}&status=${status}&assignedTo=${assignedTo}">«</a>
                            </li>
                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <li class="page-item ${currentPage == i ? 'active' : ''}">
                                    <a class="page-link" href="?page=${i}&keyword=${keyword}&status=${status}&assignedTo=${assignedTo}">${i}</a>
                                </li>
                            </c:forEach>
                            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage + 1}&keyword=${keyword}&status=${status}&assignedTo=${assignedTo}">»</a>
                            </li>
                        </ul>
                    </nav>
                </div>
            </c:if>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
