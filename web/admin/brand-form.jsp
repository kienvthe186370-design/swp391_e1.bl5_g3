<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${brand == null ? 'Thêm' : 'Sửa'} Thương hiệu</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <h2>${brand == null ? 'Thêm' : 'Sửa'} Thương hiệu</h2>
        
        <form method="post" action="brands">
            <input type="hidden" name="action" value="${brand == null ? 'add' : 'edit'}">
            <c:if test="${brand != null}">
                <input type="hidden" name="brandID" value="${brand.brandID}">
            </c:if>
            
            <div class="mb-3">
                <label class="form-label">Tên Thương hiệu *</label>
                <input type="text" name="brandName" class="form-control" 
                       value="${brand.brandName}" required>
            </div>
            
            <div class="mb-3">
                <label class="form-label">Logo URL</label>
                <input type="text" name="logo" class="form-control" 
                       value="${brand.logo}">
            </div>
            
            <div class="mb-3">
                <label class="form-label">Mô tả</label>
                <textarea name="description" class="form-control" rows="3">${brand.description}</textarea>
            </div>
            
            <div class="mb-3 form-check">
                <input type="checkbox" name="isActive" class="form-check-input" 
                       ${brand == null || brand.isActive ? 'checked' : ''}>
                <label class="form-check-label">Kích hoạt</label>
            </div>
            
            <button type="submit" class="btn btn-primary">Lưu</button>
            <a href="brands" class="btn btn-secondary">Hủy</a>
        </form>
    </div>
</body>
</html>
