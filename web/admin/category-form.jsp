<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${category == null ? 'Thêm' : 'Sửa'} Danh mục</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <h2>${category == null ? 'Thêm' : 'Sửa'} Danh mục</h2>
        
        <form method="post" action="categories">
            <input type="hidden" name="action" value="${category == null ? 'add' : 'edit'}">
            <c:if test="${category != null}">
                <input type="hidden" name="categoryID" value="${category.categoryID}">
            </c:if>
            
            <div class="mb-3">
                <label class="form-label">Tên Danh mục *</label>
                <input type="text" name="categoryName" class="form-control" 
                       value="${category.categoryName}" required>
            </div>
            
            <div class="mb-3">
                <label class="form-label">Mô tả</label>
                <textarea name="description" class="form-control" rows="3">${category.description}</textarea>
            </div>
            
            <div class="mb-3">
                <label class="form-label">Icon</label>
                <input type="text" name="icon" class="form-control" 
                       value="${category.icon}">
            </div>
            
            <div class="mb-3">
                <label class="form-label">Thứ tự hiển thị</label>
                <input type="number" name="displayOrder" class="form-control" 
                       value="${category.displayOrder != null ? category.displayOrder : 0}" required>
            </div>
            
            <div class="mb-3 form-check">
                <input type="checkbox" name="isActive" class="form-check-input" 
                       ${category == null || category.isActive ? 'checked' : ''}>
                <label class="form-check-label">Kích hoạt</label>
            </div>
            
            <button type="submit" class="btn btn-primary">Lưu</button>
            <a href="categories" class="btn btn-secondary">Hủy</a>
        </form>
    </div>
</body>
</html>
