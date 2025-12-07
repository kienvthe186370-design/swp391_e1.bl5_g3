<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản lý Giá trị - ${attribute.attributeName}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <h2>Quản lý Giá trị - ${attribute.attributeName}</h2>
        
        <c:if test="${param.msg == 'add_success'}">
            <div class="alert alert-success">Thêm giá trị thành công!</div>
        </c:if>
        <c:if test="${param.msg == 'delete_success'}">
            <div class="alert alert-success">Xóa giá trị thành công!</div>
        </c:if>
        
        <div class="card mb-3">
            <div class="card-body">
                <h5>Thêm Giá trị mới</h5>
                <form method="post" action="attributes" class="row g-3">
                    <input type="hidden" name="action" value="addValue">
                    <input type="hidden" name="attributeID" value="${attribute.attributeID}">
                    
                    <div class="col-md-6">
                        <input type="text" name="valueName" class="form-control" 
                               placeholder="Tên giá trị (VD: Đỏ, XL, 220g)" required>
                    </div>
                    <div class="col-md-3">
                        <div class="form-check">
                            <input type="checkbox" name="isActive" class="form-check-input" checked>
                            <label class="form-check-label">Kích hoạt</label>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <button type="submit" class="btn btn-primary">Thêm</button>
                    </div>
                </form>
            </div>
        </div>
        
        <table class="table table-bordered table-striped">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Tên Giá trị</th>
                    <th>Trạng thái</th>
                    <th>Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${values}" var="val">
                    <tr>
                        <td>${val.valueID}</td>
                        <td>${val.valueName}</td>
                        <td>
                            <c:if test="${val.isActive}">
                                <span class="badge bg-success">Active</span>
                            </c:if>
                            <c:if test="${!val.isActive}">
                                <span class="badge bg-secondary">Inactive</span>
                            </c:if>
                        </td>
                        <td>
                            <a href="attributes?action=deleteValue&valueId=${val.valueID}&attrId=${attribute.attributeID}" 
                               class="btn btn-sm btn-danger" 
                               onclick="return confirm('Bạn có chắc muốn xóa?')">Xóa</a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
        
        <a href="attributes" class="btn btn-secondary">Quay lại</a>
    </div>
</body>
</html>
