<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${attribute == null ? 'Thêm' : 'Sửa'} Thuộc tính</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <h2>${attribute == null ? 'Thêm' : 'Sửa'} Thuộc tính</h2>
        
        <form method="post" action="attributes">
            <input type="hidden" name="action" value="${attribute == null ? 'add' : 'edit'}">
            <c:if test="${attribute != null}">
                <input type="hidden" name="attributeID" value="${attribute.attributeID}">
            </c:if>
            
            <div class="mb-3">
                <label class="form-label">Tên Thuộc tính *</label>
                <input type="text" name="attributeName" class="form-control" 
                       value="${attribute.attributeName}" required>
                <small class="text-muted">Ví dụ: Màu sắc, Kích thước, Trọng lượng</small>
            </div>
            
            <div class="mb-3 form-check">
                <input type="checkbox" name="isActive" class="form-check-input" 
                       ${attribute == null || attribute.isActive ? 'checked' : ''}>
                <label class="form-check-label">Kích hoạt</label>
            </div>
            
            <button type="submit" class="btn btn-primary">Lưu</button>
            <a href="attributes" class="btn btn-secondary">Hủy</a>
        </form>
    </div>
</body>
</html>
