<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Yêu cầu nhập hàng - Pickleball Admin</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/AdminLTE-3.2.0/plugins/fontawesome-free/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/AdminLTE-3.2.0/dist/css/adminlte.min.css">
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">
    <jsp:include page="includes/admin-header.jsp"/>
    <jsp:include page="includes/admin-sidebar.jsp"/>
    
    <div class="content-wrapper">
        <div class="content-header">
            <div class="container-fluid">
                <div class="row mb-2">
                    <div class="col-sm-6">
                        <h1 class="m-0">
                            <i class="fas fa-boxes text-primary"></i> Yêu cầu nhập hàng
                        </h1>
                    </div>
                    <div class="col-sm-6">
                        <ol class="breadcrumb float-sm-right">
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item active">Yêu cầu nhập hàng</li>
                        </ol>
                    </div>
                </div>
            </div>
        </div>

        <section class="content">
            <div class="container-fluid">
                <!-- Statistics - Đặt lên đầu trang -->
                <div class="row">
                    <div class="col-md-6">
                        <div class="info-box bg-warning">
                            <span class="info-box-icon"><i class="fas fa-clock"></i></span>
                            <div class="info-box-content">
                                <span class="info-box-text">Chờ duyệt</span>
                                <span class="info-box-number">${pendingCount}</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="info-box bg-success">
                            <span class="info-box-icon"><i class="fas fa-check"></i></span>
                            <div class="info-box-content">
                                <span class="info-box-text">Đã nhập hàng</span>
                                <span class="info-box-number">${completedCount}</span>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Alerts -->
                <c:if test="${param.success == 'created'}">
                    <div class="alert alert-success alert-dismissible fade show">
                        <i class="fas fa-check-circle"></i> Đã tạo yêu cầu nhập hàng thành công!
                        <button type="button" class="close" data-dismiss="alert">&times;</button>
                    </div>
                </c:if>
                <c:if test="${param.success == 'approved'}">
                    <div class="alert alert-success alert-dismissible fade show">
                        <i class="fas fa-check-circle"></i> Đã duyệt và nhập hàng thành công!
                        <button type="button" class="close" data-dismiss="alert">&times;</button>
                    </div>
                </c:if>
                <c:if test="${not empty param.error}">
                    <div class="alert alert-danger alert-dismissible fade show">
                        <i class="fas fa-exclamation-circle"></i> ${param.error}
                        <button type="button" class="close" data-dismiss="alert">&times;</button>
                    </div>
                </c:if>

                <!-- Filter Card -->
                <div class="card card-outline card-primary">
                    <div class="card-header">
                        <h3 class="card-title"><i class="fas fa-filter"></i> Bộ lọc</h3>
                        <div class="card-tools">
                            <button type="button" class="btn btn-tool" data-card-widget="collapse">
                                <i class="fas fa-minus"></i>
                            </button>
                        </div>
                    </div>
                    <div class="card-body">
                        <form method="get" action="${pageContext.request.contextPath}/admin/stock-requests">
                            <div class="row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>Tìm kiếm</label>
                                        <input type="text" name="keyword" class="form-control" 
                                               placeholder="Mã yêu cầu, mã RFQ..." value="${keyword}">
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="form-group">
                                        <label>Trạng thái</label>
                                        <select name="status" class="form-control">
                                            <option value="">-- Tất cả --</option>
                                            <option value="Pending" ${status == 'Pending' ? 'selected' : ''}>Chờ duyệt</option>
                                            <option value="Completed" ${status == 'Completed' ? 'selected' : ''}>Đã nhập hàng</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-3 d-flex align-items-end">
                                    <div class="form-group">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fas fa-search"></i> Tìm kiếm
                                        </button>
                                        <a href="${pageContext.request.contextPath}/admin/stock-requests" class="btn btn-secondary">
                                            <i class="fas fa-redo"></i> Reset
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Data Table -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">
                            <i class="fas fa-list"></i> Danh sách yêu cầu 
                            <span class="badge badge-secondary">${totalRequests}</span>
                        </h3>
                    </div>
                    <div class="card-body table-responsive p-0">
                        <table class="table table-hover table-striped">
                            <thead class="thead-light">
                                <tr>
                                    <th>Mã yêu cầu</th>
                                    <th>Mã RFQ</th>
                                    <c:if test="${isAdmin}">
                                        <th>Người tạo</th>
                                    </c:if>
                                    <th>Ngày tạo</th>
                                    <th>Trạng thái</th>
                                    <th class="text-center">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="req" items="${stockRequests}">
                                    <tr>
                                        <td>
                                            <strong class="text-primary">${req.requestCode}</strong>
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/admin/rfq?action=detail&id=${req.rfqID}" 
                                               class="text-info" target="_blank">
                                                ${req.rfqCode} <i class="fas fa-external-link-alt fa-xs"></i>
                                            </a>
                                        </td>
                                        <c:if test="${isAdmin}">
                                            <td>${req.requestedByName}</td>
                                        </c:if>
                                        <td>
                                            <fmt:formatDate value="${req.createdDate}" pattern="dd/MM/yyyy HH:mm"/>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${req.status == 'Pending'}">
                                                    <span class="badge badge-warning">
                                                        <i class="fas fa-clock"></i> Chờ duyệt
                                                    </span>
                                                </c:when>
                                                <c:when test="${req.status == 'Completed'}">
                                                    <span class="badge badge-success">
                                                        <i class="fas fa-check"></i> Đã nhập hàng
                                                    </span>
                                                </c:when>
                                            </c:choose>
                                        </td>
                                        <td class="text-center">
                                            <a href="${pageContext.request.contextPath}/admin/stock-requests?action=detail&id=${req.stockRequestID}" 
                                               class="btn btn-sm btn-info">
                                                <i class="fas fa-eye"></i> Xem
                                            </a>
                                            <c:if test="${isAdmin && req.status == 'Pending'}">
                                                <a href="${pageContext.request.contextPath}/admin/stock-requests?action=detail&id=${req.stockRequestID}" 
                                                   class="btn btn-sm btn-success">
                                                    <i class="fas fa-check"></i> Duyệt
                                                </a>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty stockRequests}">
                                    <tr>
                                        <td colspan="${isAdmin ? 6 : 5}" class="text-center text-muted py-4">
                                            <i class="fas fa-inbox fa-3x mb-3"></i>
                                            <p>Không có yêu cầu nhập hàng nào</p>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                    
                    <!-- Pagination -->
                    <div class="card-footer clearfix">
                        <div class="float-left">
                            <c:choose>
                                <c:when test="${totalRequests > 0}">
                                    <c:set var="startRecord" value="${(currentPage - 1) * pageSize + 1}" />
                                    <c:set var="endRecord" value="${currentPage * pageSize > totalRequests ? totalRequests : currentPage * pageSize}" />
                                    Hiển thị <strong>${startRecord}</strong> đến <strong>${endRecord}</strong> của <strong>${totalRequests}</strong> bản ghi
                                </c:when>
                                <c:otherwise>
                                    Hiển thị <strong>0</strong> bản ghi
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <ul class="pagination pagination-sm m-0 float-right">
                            <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage - 1}&keyword=${keyword}&status=${status}">Trước</a>
                            </li>
                            <c:forEach begin="1" end="${totalPages > 0 ? totalPages : 1}" var="i">
                                <li class="page-item ${i == currentPage ? 'active' : ''}">
                                    <a class="page-link" href="?page=${i}&keyword=${keyword}&status=${status}">${i}</a>
                                </li>
                            </c:forEach>
                            <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage + 1}&keyword=${keyword}&status=${status}">Sau</a>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </section>
    </div>
    
    <jsp:include page="includes/admin-footer.jsp"/>
