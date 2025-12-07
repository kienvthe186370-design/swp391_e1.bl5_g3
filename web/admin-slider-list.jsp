<%-- 
    Document   : admin-slider-list
    Created on : Dec 6, 2025, 5:18:55 PM
    Author     : xuand
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Slider - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .slider-image {
            width: 120px;
            height: 60px;
            object-fit: cover;
            border-radius: 4px;
            border: 1px solid #dee2e6;
        }
        .status-badge {
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 0.85rem;
            font-weight: 500;
        }
        .status-active {
            background-color: #d4edda;
            color: #155724;
        }
        .status-inactive {
            background-color: #f8d7da;
            color: #721c24;
        }
        .table-row:hover {
            background-color: #f8f9fa;
        }
        .action-btn {
            padding: 4px 8px;
            font-size: 0.875rem;
        }
        .alert-custom {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 9999;
            min-width: 300px;
        }
    </style>
</head>
<body>
<div class="container-fluid mt-4">
    <!-- Success/Error Messages -->
    <c:if test="${param.success == 'added'}">
        <div class="alert alert-success alert-dismissible fade show alert-custom" role="alert">
            <i class="fas fa-check-circle"></i> Thêm slider thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${param.success == 'updated'}">
        <div class="alert alert-success alert-dismissible fade show alert-custom" role="alert">
            <i class="fas fa-check-circle"></i> Cập nhật slider thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${param.success == 'deleted'}">
        <div class="alert alert-success alert-dismissible fade show alert-custom" role="alert">
            <i class="fas fa-check-circle"></i> Xóa slider thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${param.error == 'notfound'}">
        <div class="alert alert-danger alert-dismissible fade show alert-custom" role="alert">
            <i class="fas fa-exclamation-circle"></i> Không tìm thấy slider!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="mb-0"><i class="fas fa-images"></i> Quản lý Slider</h2>
        <a href="${pageContext.request.contextPath}/admin/slider?action=add" class="btn btn-primary">
            <i class="fas fa-plus"></i> Thêm Slider Mới
        </a>
    </div>

    <!-- Filter Form -->
    <form class="row g-2 mb-4" method="get" action="${pageContext.request.contextPath}/admin/slider">
        <div class="col-md-5">
            <input type="text" name="search" value="${search}" class="form-control" placeholder="Tìm theo tiêu đề slider...">
        </div>
        <div class="col-md-3">
            <select name="status" class="form-select">
                <option value="">-- Tất cả trạng thái --</option>
                <option value="active" ${status == 'active' ? 'selected' : ''}>Active</option>
                <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Inactive</option>
            </select>
        </div>
        <div class="col-md-2">
            <button type="submit" class="btn btn-primary w-100">
                <i class="fas fa-search"></i> Tìm kiếm
            </button>
        </div>
        <div class="col-md-2">
            <a href="${pageContext.request.contextPath}/admin/slider" class="btn btn-secondary w-100">
                <i class="fas fa-redo"></i> Reset
            </a>
        </div>
    </form>

    <!-- Slider Table -->
    <div class="card">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="table-light">
                    <tr>
                        <th style="width: 60px;">ID</th>
                        <th style="width: 140px;">Hình ảnh</th>
                        <th>Tiêu đề</th>
                        <th>Link URL</th>
                        <th style="width: 100px;">Thứ tự</th>
                        <th style="width: 100px;">Trạng thái</th>
                        <th style="width: 150px;" class="text-center">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="slider" items="${sliders}">
                        <tr class="table-row">
                            <td><strong>#${slider.sliderID}</strong></td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty slider.imageURL}">
                                        <img src="${slider.imageURL}" alt="${slider.title}" class="slider-image">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="slider-image d-flex align-items-center justify-content-center bg-light">
                                            <i class="fas fa-image text-muted"></i>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <strong>${slider.title}</strong>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty slider.linkURL}">
                                        <a href="${slider.linkURL}" target="_blank" class="text-primary text-decoration-none">
                                            <i class="fas fa-external-link-alt"></i> ${slider.linkURL}
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted">Không có link</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <span class="badge bg-secondary">${slider.displayOrder}</span>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${slider.status == 'active'}">
                                        <span class="status-badge status-active">
                                            <i class="fas fa-check-circle"></i> Active
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status-badge status-inactive">
                                            <i class="fas fa-times-circle"></i> Inactive
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center">
                                <a href="${pageContext.request.contextPath}/admin/slider?action=edit&id=${slider.sliderID}" 
                                   class="btn btn-sm btn-warning action-btn me-1" title="Chỉnh sửa">
                                    <i class="fas fa-edit"></i>
                                </a>
                                <button type="button" class="btn btn-sm btn-danger action-btn" 
                                        onclick="confirmDelete(${slider.sliderID}, '${slider.title}')" title="Xóa">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty sliders}">
                        <tr>
                            <td colspan="7" class="text-center py-4">
                                <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                                <p class="text-muted mb-0">Không có slider nào.</p>
                            </td>
                        </tr>
                    </c:if>
                    </tbody>
                </table>
            </div>

            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
                <nav aria-label="Page navigation" class="mt-4">
                    <ul class="pagination justify-content-center">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage - 1}&search=${search}&status=${status}">
                                <i class="fas fa-chevron-left"></i>
                            </a>
                        </li>
                        
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                <a class="page-link" href="?page=${i}&search=${search}&status=${status}">${i}</a>
                            </li>
                        </c:forEach>
                        
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage + 1}&search=${search}&status=${status}">
                                <i class="fas fa-chevron-right"></i>
                            </a>
                        </li>
                    </ul>
                </nav>
            </c:if>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-exclamation-triangle text-danger"></i> Xác nhận xóa</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>Bạn có chắc chắn muốn xóa slider <strong id="sliderTitle"></strong>?</p>
                <p class="text-danger mb-0"><i class="fas fa-info-circle"></i> Hành động này không thể hoàn tác!</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                <a href="#" id="confirmDeleteBtn" class="btn btn-danger">
                    <i class="fas fa-trash"></i> Xóa
                </a>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function confirmDelete(id, title) {
        document.getElementById('sliderTitle').textContent = title;
        document.getElementById('confirmDeleteBtn').href = 
            '${pageContext.request.contextPath}/admin/slider?action=delete&id=' + id;
        new bootstrap.Modal(document.getElementById('deleteModal')).show();
    }
    
    // Auto hide alerts after 3 seconds
    setTimeout(function() {
        var alerts = document.querySelectorAll('.alert-custom');
        alerts.forEach(function(alert) {
            var bsAlert = new bootstrap.Alert(alert);
            bsAlert.close();
        });
    }, 3000);
</script>
</body>
</html>

