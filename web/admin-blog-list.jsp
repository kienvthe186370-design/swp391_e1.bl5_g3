<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Blog</title>
    <link rel="stylesheet" href="css/bootstrap.min.css"/>
    <link rel="stylesheet" href="css/style.css"/>
</head>
<body>
<div class="container mt-4">
    <h2>Quản lý bài viết Blog</h2>

    <form class="row g-2 mb-3" method="get" action="${pageContext.request.contextPath}/admin/blogs">
        <div class="col-md-4">
            <input type="text" name="q" value="${q}" class="form-control" placeholder="Tìm theo tiêu đề">
        </div>
        <div class="col-md-3">
            <select name="status" class="form-control">
                <option value="">-- Tất cả trạng thái --</option>
                <option value="draft" ${status == 'draft' ? 'selected' : ''}>Nháp</option>
                <option value="published" ${status == 'published' ? 'selected' : ''}>Đã xuất bản</option>
                <option value="archived" ${status == 'archived' ? 'selected' : ''}>Lưu trữ</option>
            </select>
        </div>
        <div class="col-md-2">
            <button type="submit" class="btn btn-primary">Lọc</button>
        </div>
    </form>

    <table class="table table-bordered table-striped">
        <thead>
        <tr>
            <th>ID</th>
            <th>Tiêu đề</th>
            <th>Slug</th>
            <th>Tác giả</th>
            <th>Trạng thái</th>
            <th>Ngày xuất bản</th>
            <th>Lượt xem</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="p" items="${posts}">
            <tr>
                <td>${p.postId}</td>
                <td>${p.title}</td>
                <td>${p.slug}</td>
                <td>${p.authorName}</td>
                <td>${p.status}</td>
                <td>
                    <c:if test="${p.publishedDate != null}">
                        ${p.publishedDate}
                    </c:if>
                </td>
                <td>${p.viewCount}</td>
            </tr>
        </c:forEach>
        <c:if test="${empty posts}">
            <tr>
                <td colspan="7" class="text-center">Chưa có bài viết nào.</td>
            </tr>
        </c:if>
        </tbody>
    </table>
</div>
</body>
</html>



