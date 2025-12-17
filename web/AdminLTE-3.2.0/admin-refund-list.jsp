<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% request.setAttribute("pageTitle", "Quản lý hoàn tiền"); %>
<jsp:include page="includes/admin-header.jsp"/>
<jsp:include page="includes/admin-sidebar.jsp"/>

<div class="content-wrapper">
    <div class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h1 class="m-0">Quản lý yêu cầu hoàn tiền</h1>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item active">Hoàn tiền</li>
                    </ol>
                </div>
            </div>
        </div>
    </div>

    <section class="content">
        <div class="container-fluid">
            <c:if test="${not empty success}">
                <div class="alert alert-success alert-dismissible">
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                    ${success}
                </div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-danger alert-dismissible">
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                    ${error}
                </div>
            </c:if>

            <!-- Status Cards -->
            <div class="row">
                <div class="col-lg-3 col-6">
                    <div class="small-box bg-warning">
                        <div class="inner">
                            <h3>${pendingCount}</h3>
                            <p>Đang chờ</p>
                        </div>
                        <div class="icon"><i class="fas fa-clock"></i></div>
                        <a href="${pageContext.request.contextPath}/admin/refunds?status=Pending" class="small-box-footer">
                            Xem chi tiết <i class="fas fa-arrow-circle-right"></i>
                        </a>
                    </div>
                </div>
                <div class="col-lg-3 col-6">
                    <div class="small-box bg-success">
                        <div class="inner">
                            <h3>${approvedCount}</h3>
                            <p>Đã duyệt</p>
                        </div>
                        <div class="icon"><i class="fas fa-check"></i></div>
                        <a href="${pageContext.request.contextPath}/admin/refunds?status=Approved" class="small-box-footer">
                            Xem chi tiết <i class="fas fa-arrow-circle-right"></i>
                        </a>
                    </div>
                </div>
                <div class="col-lg-3 col-6">
                    <div class="small-box bg-danger">
                        <div class="inner">
                            <h3>${rejectedCount}</h3>
                            <p>Từ chối</p>
                        </div>
                        <div class="icon"><i class="fas fa-times"></i></div>
                        <a href="${pageContext.request.contextPath}/admin/refunds?status=Rejected" class="small-box-footer">
                            Xem chi tiết <i class="fas fa-arrow-circle-right"></i>
                        </a>
                    </div>
                </div>
                <div class="col-lg-3 col-6">
                    <div class="small-box bg-info">
                        <div class="inner">
                            <h3>${completedCount}</h3>
                            <p>Hoàn thành</p>
                        </div>
                        <div class="icon"><i class="fas fa-check-double"></i></div>
                        <a href="${pageContext.request.contextPath}/admin/refunds?status=Completed" class="small-box-footer">
                            Xem chi tiết <i class="fas fa-arrow-circle-right"></i>
                        </a>
                    </div>
                </div>
            </div>

            <!-- Filter -->
            <div class="card">
                <div class="card-header">
                    <div class="btn-group">
                        <a href="${pageContext.request.contextPath}/admin/refunds" 
                           class="btn btn-sm ${empty currentStatus ? 'btn-primary' : 'btn-outline-primary'}">
                            Tất cả
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/refunds?status=Pending" 
                           class="btn btn-sm ${currentStatus == 'Pending' ? 'btn-warning' : 'btn-outline-warning'}">
                            Đang chờ
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/refunds?status=Approved" 
                           class="btn btn-sm ${currentStatus == 'Approved' ? 'btn-success' : 'btn-outline-success'}">
                            Đã duyệt
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/refunds?status=Rejected" 
                           class="btn btn-sm ${currentStatus == 'Rejected' ? 'btn-danger' : 'btn-outline-danger'}">
                            Từ chối
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/refunds?status=Completed" 
                           class="btn btn-sm ${currentStatus == 'Completed' ? 'btn-info' : 'btn-outline-info'}">
                            Hoàn thành
                        </a>
                    </div>
                </div>
                <div class="card-body">
                    <table class="table table-bordered table-striped">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Đơn hàng</th>
                                <th>Khách hàng</th>
                                <th>Số tiền</th>
                                <th>Lý do</th>
                                <th>Ngày yêu cầu</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="refund" items="${refundRequests}">
                                <tr>
                                    <td>#${refund.refundRequestID}</td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/admin/order?action=detail&id=${refund.orderID}">
                                            ${refund.order.orderCode}
                                        </a>
                                    </td>
                                    <td>
                                        <strong>${refund.customer.fullName}</strong><br>
                                        <small class="text-muted">${refund.customer.email}</small>
                                    </td>
                                    <td class="text-danger font-weight-bold">
                                        <fmt:formatNumber value="${refund.refundAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </td>
                                    <td>
                                        <span title="${refund.refundReason}">
                                            ${refund.refundReason.length() > 50 ? refund.refundReason.substring(0, 50).concat('...') : refund.refundReason}
                                        </span>
                                    </td>
                                    <td>
                                        <fmt:formatDate value="${refund.requestDate}" pattern="dd/MM/yyyy HH:mm"/>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${refund.refundStatus == 'Pending'}">
                                                <span class="badge badge-warning">Đang chờ</span>
                                            </c:when>
                                            <c:when test="${refund.refundStatus == 'Approved'}">
                                                <span class="badge badge-success">Đã duyệt</span>
                                            </c:when>
                                            <c:when test="${refund.refundStatus == 'Rejected'}">
                                                <span class="badge badge-danger">Từ chối</span>
                                            </c:when>
                                            <c:when test="${refund.refundStatus == 'Completed'}">
                                                <span class="badge badge-info">Hoàn thành</span>
                                            </c:when>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/admin/refund?action=detail&id=${refund.refundRequestID}" 
                                           class="btn btn-sm btn-info" title="Chi tiết">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <c:if test="${refund.refundStatus == 'Pending'}">
                                            <button type="button" class="btn btn-sm btn-success" 
                                                    onclick="showApproveModal(${refund.refundRequestID})" title="Duyệt">
                                                <i class="fas fa-check"></i>
                                            </button>
                                            <button type="button" class="btn btn-sm btn-danger" 
                                                    onclick="showRejectModal(${refund.refundRequestID})" title="Từ chối">
                                                <i class="fas fa-times"></i>
                                            </button>
                                        </c:if>
                                        <c:if test="${refund.refundStatus == 'Approved' && employeeRole == 'SellerManager'}">
                                            <button type="button" class="btn btn-sm btn-primary" 
                                                    onclick="showCompleteModal(${refund.refundRequestID})" title="Hoàn thành">
                                                <i class="fas fa-check-double"></i>
                                            </button>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty refundRequests}">
                                <tr>
                                    <td colspan="8" class="text-center text-muted py-4">
                                        Không có yêu cầu hoàn tiền nào
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
                
                <!-- Pagination -->
                <c:if test="${totalPages > 1}">
                    <div class="card-footer">
                        <nav>
                            <ul class="pagination justify-content-center mb-0">
                                <c:if test="${currentPage > 1}">
                                    <li class="page-item">
                                        <a class="page-link" href="?page=${currentPage - 1}&status=${currentStatus}">
                                            <i class="fas fa-chevron-left"></i>
                                        </a>
                                    </li>
                                </c:if>
                                <c:forEach begin="1" end="${totalPages}" var="i">
                                    <li class="page-item ${i == currentPage ? 'active' : ''}">
                                        <a class="page-link" href="?page=${i}&status=${currentStatus}">${i}</a>
                                    </li>
                                </c:forEach>
                                <c:if test="${currentPage < totalPages}">
                                    <li class="page-item">
                                        <a class="page-link" href="?page=${currentPage + 1}&status=${currentStatus}">
                                            <i class="fas fa-chevron-right"></i>
                                        </a>
                                    </li>
                                </c:if>
                            </ul>
                        </nav>
                    </div>
                </c:if>
            </div>
        </div>
    </section>
</div>

<!-- Approve Modal -->
<div class="modal fade" id="approveModal">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/admin/refund" method="post">
                <input type="hidden" name="action" value="approve">
                <input type="hidden" name="refundId" id="approveRefundId">
                <div class="modal-header">
                    <h5 class="modal-title">Duyệt yêu cầu hoàn tiền</h5>
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                </div>
                <div class="modal-body">
                    <p>Bạn có chắc chắn muốn duyệt yêu cầu hoàn tiền này?</p>
                    <div class="form-group">
                        <label>Ghi chú (tùy chọn)</label>
                        <textarea class="form-control" name="adminNotes" rows="3" 
                                  placeholder="Nhập ghi chú cho khách hàng..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-success">Duyệt</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Reject Modal -->
<div class="modal fade" id="rejectModal">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/admin/refund" method="post">
                <input type="hidden" name="action" value="reject">
                <input type="hidden" name="refundId" id="rejectRefundId">
                <div class="modal-header">
                    <h5 class="modal-title">Từ chối yêu cầu hoàn tiền</h5>
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                </div>
                <div class="modal-body">
                    <div class="form-group">
                        <label>Lý do từ chối <span class="text-danger">*</span></label>
                        <textarea class="form-control" name="adminNotes" rows="3" required
                                  placeholder="Nhập lý do từ chối..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-danger">Từ chối</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Complete Modal -->
<div class="modal fade" id="completeModal">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/admin/refund" method="post">
                <input type="hidden" name="action" value="complete">
                <input type="hidden" name="refundId" id="completeRefundId">
                <div class="modal-header">
                    <h5 class="modal-title">Xác nhận hoàn tiền</h5>
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                </div>
                <div class="modal-body">
                    <p>Xác nhận đã hoàn tiền cho khách hàng?</p>
                    <div class="alert alert-info">
                        <i class="fas fa-info-circle"></i>
                        Hành động này sẽ đánh dấu yêu cầu hoàn tiền là hoàn thành và cập nhật trạng thái đơn hàng.
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary">Xác nhận hoàn thành</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    function showApproveModal(refundId) {
        document.getElementById('approveRefundId').value = refundId;
        $('#approveModal').modal('show');
    }
    
    function showRejectModal(refundId) {
        document.getElementById('rejectRefundId').value = refundId;
        $('#rejectModal').modal('show');
    }
    
    function showCompleteModal(refundId) {
        document.getElementById('completeRefundId').value = refundId;
        $('#completeModal').modal('show');
    }
</script>

<jsp:include page="includes/admin-footer.jsp"/>
