<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản lý Thương hiệu</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <h2>Quản lý Thương hiệu (Brands)</h2>
        
        <c:if test="${param.msg == 'add_success'}">
            <div class="alert alert-success">Thêm thương hiệu thành công!</div>
        </c:if>
        <c:if test="${param.msg == 'update_success'}">
            <div class="alert alert-success">Cập nhật thương hiệu thành công!</div>
        </c:if>
        <c:if test="${param.msg == 'delete_success'}">
            <div class="alert alert-success">Xóa thương hiệu thành công!</div>
        </c:if>
        
        <div class="mb-3">
            <a href="brands?action=add" class="btn btn-primary">+ Thêm Thương hiệu</a>
        </div>
        
        <table class="table table-bordered table-striped">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Tên Thương hiệu</th>
                    <th>Logo</th>
                    <th>Mô tả</th>
                    <th>Trạng thái</th>
                    <th>Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${brands}" var="brand">
                    <tr>
                        <td>${brand.brandID}</td>
                        <td>${brand.brandName}</td>
                        <td>${brand.logo}</td>
                        <td>${brand.description}</td>
                        <td>
                            <c:if test="${brand.isActive}">
                                <span class="badge bg-success">Active</span>
                            </c:if>
                            <c:if test="${!brand.isActive}">
                                <span class="badge bg-secondary">Inactive</span>
                            </c:if>
                        </td>
                        <td>
                            <a href="brands?action=edit&id=${brand.brandID}" class="btn btn-sm btn-warning">Sửa</a>
                            <a href="brands?action=delete&id=${brand.brandID}" 
                               class="btn btn-sm btn-danger" 
                               onclick="return confirm('Bạn có chắc muốn xóa?')">Xóa</a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</body>
</html>
