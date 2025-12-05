<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản lý Danh mục</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <h2>Quản lý Danh mục (Categories)</h2>
        
        <c:if test="${param.msg == 'add_success'}">
            <div class="alert alert-success">Thêm danh mục thành công!</div>
        </c:if>
        <c:if test="${param.msg == 'update_success'}">
            <div class="alert alert-success">Cập nhật danh mục thành công!</div>
        </c:if>
        <c:if test="${param.msg == 'delete_success'}">
            <div class="alert alert-success">Xóa danh mục thành công!</div>
        </c:if>
        
        <div class="mb-3">
            <a href="categories?action=add" class="btn btn-primary">+ Thêm Danh mục</a>
        </div>
        
        <table class="table table-bordered table-striped">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Tên Danh mục</th>
                    <th>Icon</th>
                    <th>Thứ tự</th>
                    <th>Trạng thái</th>
                    <th>Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${categories}" var="cat">
                    <tr>
                        <td>${cat.categoryID}</td>
                        <td>${cat.categoryName}</td>
                        <td>${cat.icon}</td>
                        <td>${cat.displayOrder}</td>
                        <td>
                            <c:if test="${cat.isActive}">
                                <span class="badge bg-success">Active</span>
                            </c:if>
                            <c:if test="${!cat.isActive}">
                                <span class="badge bg-secondary">Inactive</span>
                            </c:if>
                        </td>
                        <td>
                            <a href="categories?action=edit&id=${cat.categoryID}" class="btn btn-sm btn-warning">Sửa</a>
                            <a href="categories?action=delete&id=${cat.categoryID}" 
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
