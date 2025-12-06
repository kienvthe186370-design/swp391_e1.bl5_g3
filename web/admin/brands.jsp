<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản lý Thương hiệu</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <div class="container-fluid mt-4">
        <h2><i class="fas fa-copyright"></i> Quản lý Thương hiệu (Brands)</h2>
        
        <c:if test="${param.msg == 'add_success'}">
            <div class="alert alert-success alert-dismissible fade show">
                <i class="fas fa-check-circle"></i> Thêm thương hiệu thành công!
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${param.msg == 'update_success'}">
            <div class="alert alert-success alert-dismissible fade show">
                <i class="fas fa-check-circle"></i> Cập nhật thương hiệu thành công!
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${param.msg == 'delete_success'}">
            <div class="alert alert-success alert-dismissible fade show">
                <i class="fas fa-check-circle"></i> Xóa thương hiệu thành công!
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        
        <!-- Search and Filter Section -->
        <div class="card mb-3">
            <div class="card-body">
                <form method="get" action="brands" id="filterForm">
                    <div class="row g-3">
                        <div class="col-md-4">
                            <label class="form-label"><i class="fas fa-search"></i> Tìm kiếm</label>
                            <input type="text" name="search" class="form-control" placeholder="Tên thương hiệu, mô tả..." value="${search}">
                        </div>
                        <div class="col-md-2">
                            <label class="form-label"><i class="fas fa-filter"></i> Trạng thái</label>
                            <select name="status" class="form-select">
                                <option value="">Tất cả</option>
                                <option value="active" ${status == 'active' ? 'selected' : ''}>Active</option>
                                <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Inactive</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label"><i class="fas fa-sort"></i> Sắp xếp theo</label>
                            <select name="sortBy" class="form-select">
                                <option value="">Mặc định</option>
                                <option value="BrandName" ${sortBy == 'BrandName' ? 'selected' : ''}>Tên</option>
                                <option value="BrandID" ${sortBy == 'BrandID' ? 'selected' : ''}>ID</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label"><i class="fas fa-arrow-down-up-across-line"></i> Thứ tự</label>
                            <select name="sortOrder" class="form-select">
                                <option value="ASC" ${sortOrder == 'ASC' ? 'selected' : ''}>Tăng dần</option>
                                <option value="DESC" ${sortOrder == 'DESC' ? 'selected' : ''}>Giảm dần</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label"><i class="fas fa-list-ol"></i> Số dòng/trang</label>
                            <select name="pageSize" class="form-select">
                                <option value="5" ${pageSize == 5 ? 'selected' : ''}>5</option>
                                <option value="10" ${pageSize == 10 ? 'selected' : ''}>10</option>
                                <option value="20" ${pageSize == 20 ? 'selected' : ''}>20</option>
                                <option value="50" ${pageSize == 50 ? 'selected' : ''}>50</option>
                            </select>
                        </div>
                    </div>
                    <div class="row mt-3">
                        <div class="col-12">
                            <button type="submit" class="btn btn-primary"><i class="fas fa-search"></i> Tìm kiếm</button>
                            <a href="brands" class="btn btn-secondary"><i class="fas fa-redo"></i> Đặt lại</a>
                            <a href="brands?action=add" class="btn btn-success float-end"><i class="fas fa-plus"></i> Thêm Thương hiệu</a>
                        </div>
                    </div>
                </form>
            </div>
        </div>
        
        <!-- Results Info -->
        <div class="alert alert-info">
            <i class="fas fa-info-circle"></i> Hiển thị <strong>${(currentPage-1)*pageSize + 1}</strong> - <strong>${currentPage*pageSize > totalRecords ? totalRecords : currentPage*pageSize}</strong> 
            trong tổng số <strong>${totalRecords}</strong> bản ghi
        </div>
        
        <!-- Table -->
        <div class="card">
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-bordered table-hover">
                        <thead class="table-dark">
                            <tr>
                                <th width="5%">ID</th>
                                <th width="20%">Tên Thương hiệu</th>
                                <th width="15%">Logo</th>
                                <th width="35%">Mô tả</th>
                                <th width="10%">Trạng thái</th>
                                <th width="15%">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:if test="${empty brands}">
                                <tr>
                                    <td colspan="6" class="text-center text-muted">
                                        <i class="fas fa-inbox fa-3x mb-2"></i>
                                        <p>Không tìm thấy dữ liệu</p>
                                    </td>
                                </tr>
                            </c:if>
                            <c:forEach items="${brands}" var="brand">
                                <tr>
                                    <td>${brand.brandID}</td>
                                    <td><strong>${brand.brandName}</strong></td>
                                    <td>
                                        <c:if test="${not empty brand.logo}">
                                            <img src="${brand.logo}" alt="${brand.brandName}" style="max-height: 40px;">
                                        </c:if>
                                    </td>
                                    <td><small>${brand.description}</small></td>
                                    <td>
                                        <c:if test="${brand.isActive}">
                                            <span class="badge bg-success"><i class="fas fa-check"></i> Active</span>
                                        </c:if>
                                        <c:if test="${!brand.isActive}">
                                            <span class="badge bg-secondary"><i class="fas fa-times"></i> Inactive</span>
                                        </c:if>
                                    </td>
                                    <td>
                                        <a href="brands?action=edit&id=${brand.brandID}" class="btn btn-sm btn-warning" title="Sửa">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <a href="brands?action=delete&id=${brand.brandID}" 
                                           class="btn btn-sm btn-danger" 
                                           onclick="return confirm('Bạn có chắc muốn xóa thương hiệu này?')" title="Xóa">
                                            <i class="fas fa-trash"></i>
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        
        <!-- Pagination -->
        <c:if test="${totalPages > 1}">
            <nav class="mt-3">
                <ul class="pagination justify-content-center">
                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="?page=1&search=${search}&status=${status}&sortBy=${sortBy}&sortOrder=${sortOrder}&pageSize=${pageSize}">
                            <i class="fas fa-angle-double-left"></i>
                        </a>
                    </li>
                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${currentPage-1}&search=${search}&status=${status}&sortBy=${sortBy}&sortOrder=${sortOrder}&pageSize=${pageSize}">
                            <i class="fas fa-angle-left"></i>
                        </a>
                    </li>
                    
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <c:if test="${i >= currentPage - 2 && i <= currentPage + 2}">
                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                <a class="page-link" href="?page=${i}&search=${search}&status=${status}&sortBy=${sortBy}&sortOrder=${sortOrder}&pageSize=${pageSize}">${i}</a>
                            </li>
                        </c:if>
                    </c:forEach>
                    
                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${currentPage+1}&search=${search}&status=${status}&sortBy=${sortBy}&sortOrder=${sortOrder}&pageSize=${pageSize}">
                            <i class="fas fa-angle-right"></i>
                        </a>
                    </li>
                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${totalPages}&search=${search}&status=${status}&sortBy=${sortBy}&sortOrder=${sortOrder}&pageSize=${pageSize}">
                            <i class="fas fa-angle-double-right"></i>
                        </a>
                    </li>
                </ul>
            </nav>
        </c:if>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
