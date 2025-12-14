<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="entity.Employee" %>
<%@ page import="utils.RolePermission" %>
<%
    Employee employee = (Employee) session.getAttribute("employee");
    if (employee == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String userRole = employee.getRole();
    boolean canAssign = RolePermission.canAssignOrders(userRole);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="../includes/admin-head.jsp" />
    <title>Chi tiết đơn hàng - Pickleball Shop</title>
</head>
<body class="hold-transition sidebar-mini layout-fixed">
<div class="wrapper">
    <jsp:include page="../includes/admin-header.jsp" />
    <jsp:include page="../includes/admin-sidebar.jsp" />

    <div class="content-wrapper">
        <div class="content-header">
            <div class="container-fluid">
                <div class="row mb-2">
                    <div class="col-sm-6">
                        <h1 class="m-0">Chi tiết đơn hàng ${order.orderCode}</h1>
                    </div>
                    <div class="col-sm-6">
                        <ol class="breadcrumb float-sm-right">
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/orders">Đơn hàng</a></li>
                            <li class="breadcrumb-item active">${order.orderCode}</li>
                        </ol>
                    </div>
                </div>
            </div>
        </div>

        <section class="content">
            <div class="container-fluid">
                
                <!-- Thông báo -->
                <c:if test="${not empty sessionScope.success}">
                    <div class="alert alert-success alert-dismissible">
                        <button type="button" class="close" data-dismiss="alert">&times;</button>
                        ${sessionScope.success}
                    </div>
                    <c:remove var="success" scope="session"/>
                </c:if>
                <c:if test="${not empty sessionScope.error}">
                    <div class="alert alert-danger alert-dismissible">
                        <button type="button" class="close" data-dismiss="alert">&times;</button>
                        ${sessionScope.error}
                    </div>
                    <c:remove var="error" scope="session"/>
                </c:if>
                
                <div class="row">
                    <!-- Cột trái: Thông tin đơn hàng -->
                    <div class="col-md-8">
                        
                        <!-- Thông tin khách hàng & giao hàng -->
                        <div class="card">
                            <div class="card-header">
                                <h3 class="card-title"><i class="fas fa-user"></i> Thông tin khách hàng</h3>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-6">
                                        <p><strong>Họ tên:</strong> ${order.customer.fullName}</p>
                                        <p><strong>Email:</strong> ${order.customer.email}</p>
                                        <p><strong>SĐT:</strong> ${order.customer.phone}</p>
                                    </div>
                                    <div class="col-md-6">
                                        <c:if test="${order.address != null}">
                                            <p><strong>Người nhận:</strong> ${order.address.recipientName}</p>
                                            <p><strong>SĐT nhận:</strong> ${order.address.phone}</p>
                                            <p><strong>Địa chỉ:</strong> ${order.address.street}, ${order.address.ward}, ${order.address.district}, ${order.address.city}</p>
                                        </c:if>
                                    </div>
                                </div>
                                <c:if test="${not empty order.notes}">
                                    <hr>
                                    <p><strong>Ghi chú của khách:</strong> ${order.notes}</p>
                                </c:if>
                            </div>
                        </div>

                        <!-- Danh sách sản phẩm -->
                        <div class="card">
                            <div class="card-header">
                                <h3 class="card-title"><i class="fas fa-box"></i> Sản phẩm</h3>
                            </div>
                            <div class="card-body p-0">
                                <table class="table">
                                    <thead>
                                        <tr>
                                            <th style="width: 50%">Sản phẩm</th>
                                            <th>Đơn giá</th>
                                            <th>SL</th>
                                            <th>Thành tiền</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="detail" items="${order.orderDetails}">
                                            <tr>
                                                <td>
                                                    <div class="d-flex align-items-center">
                                                        <c:if test="${not empty detail.productImage}">
                                                            <img src="${pageContext.request.contextPath}/${detail.productImage}" 
                                                                 alt="${detail.productName}" 
                                                                 style="width: 50px; height: 50px; object-fit: cover; margin-right: 10px;">
                                                        </c:if>
                                                        <div>
                                                            <strong>${detail.productName}</strong>
                                                            <br><small class="text-muted">SKU: ${detail.sku}</small>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td><fmt:formatNumber value="${detail.unitPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</td>
                                                <td>${detail.quantity}</td>
                                                <td><fmt:formatNumber value="${detail.finalPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                    <tfoot>
                                        <tr>
                                            <td colspan="3" class="text-right">Tạm tính:</td>
                                            <td><fmt:formatNumber value="${order.subtotalAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</td>
                                        </tr>
                                        <c:if test="${order.discountAmount != null && order.discountAmount > 0}">
                                            <tr>
                                                <td colspan="3" class="text-right">Giảm giá:</td>
                                                <td>-<fmt:formatNumber value="${order.discountAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</td>
                                            </tr>
                                        </c:if>
                                        <c:if test="${order.voucherDiscount != null && order.voucherDiscount > 0}">
                                            <tr>
                                                <td colspan="3" class="text-right">Voucher:</td>
                                                <td>-<fmt:formatNumber value="${order.voucherDiscount}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</td>
                                            </tr>
                                        </c:if>
                                        <tr>
                                            <td colspan="3" class="text-right">Phí vận chuyển:</td>
                                            <td><fmt:formatNumber value="${order.shippingFee}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</td>
                                        </tr>
                                        <tr class="font-weight-bold">
                                            <td colspan="3" class="text-right">Tổng cộng:</td>
                                            <td class="text-danger">
                                                <fmt:formatNumber value="${order.totalAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                            </td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>
                        </div>

                        <!-- Lịch sử trạng thái -->
                        <div class="card">
                            <div class="card-header">
                                <h3 class="card-title"><i class="fas fa-history"></i> Lịch sử trạng thái</h3>
                            </div>
                            <div class="card-body">
                                <div class="timeline">
                                    <c:forEach var="history" items="${order.statusHistory}">
                                        <div>
                                            <i class="fas fa-clock bg-blue"></i>
                                            <div class="timeline-item">
                                                <span class="time">
                                                    <i class="fas fa-clock"></i> 
                                                    <fmt:formatDate value="${history.changedDate}" pattern="dd/MM/yyyy HH:mm"/>
                                                </span>
                                                <h3 class="timeline-header">
                                                    <c:if test="${not empty history.oldStatus}">
                                                        ${history.oldStatus} → 
                                                    </c:if>
                                                    <strong>${history.newStatus}</strong>
                                                </h3>
                                                <div class="timeline-body">
                                                    <c:choose>
                                                        <c:when test="${history.changedByEmployee != null}">
                                                            Bởi: ${history.changedByEmployee.fullName}
                                                        </c:when>
                                                        <c:otherwise>
                                                            Bởi: Khách hàng
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <c:if test="${not empty history.notes}">
                                                        <br>Ghi chú: ${history.notes}
                                                    </c:if>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                    <c:if test="${empty order.statusHistory}">
                                        <p class="text-muted">Chưa có lịch sử trạng thái</p>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                        
                    </div>
                    
                    <!-- Cột phải: Actions -->
                    <div class="col-md-4">
                        
                        <!-- Trạng thái hiện tại -->
                        <div class="card">
                            <div class="card-header bg-primary">
                                <h3 class="card-title text-white">Trạng thái đơn hàng</h3>
                            </div>
                            <div class="card-body text-center">
                                <h3>
                                    <c:choose>
                                        <c:when test="${order.orderStatus == 'Pending'}">
                                            <span class="badge badge-secondary" style="font-size: 1.2em;">Chờ xử lý</span>
                                        </c:when>
                                        <c:when test="${order.orderStatus == 'Confirmed'}">
                                            <span class="badge badge-info" style="font-size: 1.2em;">Đã xác nhận</span>
                                        </c:when>
                                        <c:when test="${order.orderStatus == 'Processing'}">
                                            <span class="badge badge-primary" style="font-size: 1.2em;">Đang xử lý</span>
                                        </c:when>
                                        <c:when test="${order.orderStatus == 'Shipping'}">
                                            <span class="badge badge-warning" style="font-size: 1.2em;">Đang giao</span>
                                        </c:when>
                                        <c:when test="${order.orderStatus == 'Delivered'}">
                                            <span class="badge badge-success" style="font-size: 1.2em;">Đã giao</span>
                                        </c:when>
                                        <c:when test="${order.orderStatus == 'Cancelled'}">
                                            <span class="badge badge-danger" style="font-size: 1.2em;">Đã hủy</span>
                                        </c:when>
                                    </c:choose>
                                </h3>
                                <hr>
                                <p><strong>Thanh toán:</strong> ${order.paymentMethod}</p>
                                <p>
                                    <span class="badge badge-${order.paymentStatus == 'Paid' ? 'success' : 'warning'}">
                                        ${order.paymentStatus == 'Paid' ? 'Đã thanh toán' : 'Chưa thanh toán'}
                                    </span>
                                </p>
                                <c:if test="${not empty order.cancelReason}">
                                    <hr>
                                    <p class="text-danger"><strong>Lý do hủy:</strong> ${order.cancelReason}</p>
                                </c:if>
                            </div>
                        </div>

                        <!-- Cập nhật trạng thái -->
                        <c:if test="${canUpdateStatus && order.orderStatus != 'Delivered' && order.orderStatus != 'Cancelled'}">
                            <div class="card">
                                <div class="card-header">
                                    <h3 class="card-title">Cập nhật trạng thái</h3>
                                </div>
                                <div class="card-body">
                                    <form method="post" action="${pageContext.request.contextPath}/admin/orders" id="updateStatusForm">
                                        <input type="hidden" name="action" value="updateStatus">
                                        <input type="hidden" name="orderId" value="${order.orderID}">
                                        <div class="form-group">
                                            <select name="newStatus" class="form-control" required id="newStatusSelect">
                                                <option value="">-- Chọn trạng thái --</option>
                                                <c:forEach var="status" items="${availableStatuses}">
                                                    <option value="${status.key}">${status.value}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        
                                        <!-- Hiển thị đơn vị vận chuyển đã chọn từ checkout -->
                                        <c:if test="${order.shipping != null && order.shipping.carrierName != null}">
                                        <div class="alert alert-info mb-2">
                                            <i class="fas fa-truck"></i> <strong>Đơn vị vận chuyển:</strong> ${order.shipping.carrierName}
                                            <br><small>Dự kiến: ${order.shipping.estimatedDelivery}</small>
                                        </div>
                                        </c:if>
                                        
                                        <div class="form-group">
                                            <textarea name="note" class="form-control" rows="2" 
                                                      placeholder="Ghi chú (tùy chọn)"></textarea>
                                        </div>
                                        <button type="submit" class="btn btn-primary btn-block">
                                            <i class="fas fa-save"></i> Cập nhật
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </c:if>
                        
                        <!-- Phân công (SellerManager/Admin) -->
                        <c:if test="${canAssign}">
                            <div class="card">
                                <div class="card-header">
                                    <h3 class="card-title">Phân công xử lý</h3>
                                </div>
                                <div class="card-body">
                                    <c:choose>
                                        <c:when test="${order.assignedSeller != null}">
                                            <p>Đang xử lý bởi: <strong>${order.assignedSeller.fullName}</strong></p>
                                            <button class="btn btn-warning btn-block" data-toggle="modal" data-target="#reassignModal">
                                                <i class="fas fa-exchange-alt"></i> Chuyển người khác
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <form method="post" action="${pageContext.request.contextPath}/admin/orders">
                                                <input type="hidden" name="action" value="assign">
                                                <input type="hidden" name="orderId" value="${order.orderID}">
                                                <div class="form-group">
                                                    <select name="sellerId" class="form-control" required>
                                                        <option value="">-- Chọn Seller --</option>
                                                        <c:forEach var="seller" items="${sellers}">
                                                            <option value="${seller[0]}">
                                                                ${seller[1]} (${seller[4]} đơn)
                                                            </option>
                                                        </c:forEach>
                                                    </select>
                                                </div>
                                                <button type="submit" class="btn btn-primary btn-block">
                                                    <i class="fas fa-user-plus"></i> Phân công
                                                </button>
                                            </form>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </c:if>
                        
                        <!-- Thông tin vận chuyển -->
                        <c:if test="${order.shipping != null && order.shipping.trackingCode != null}">
                            <div class="card">
                                <div class="card-header bg-info">
                                    <h3 class="card-title text-white">Thông tin vận chuyển</h3>
                                </div>
                                <div class="card-body">
                                    <p><strong>Mã vận đơn:</strong> ${order.shipping.trackingCode}</p>
                                    <c:if test="${order.shipping.estimatedDelivery != null}">
                                        <p><strong>Dự kiến giao:</strong> 
                                            <fmt:formatDate value="${order.shipping.estimatedDelivery}" pattern="dd/MM/yyyy"/>
                                        </p>
                                    </c:if>
                                    <c:if test="${order.shipping.goshipOrderCode != null}">
                                        <a href="https://goship.io/tracking/${order.shipping.trackingCode}" 
                                           target="_blank" class="btn btn-info btn-block">
                                            <i class="fas fa-truck"></i> Theo dõi đơn hàng
                                        </a>
                                    </c:if>
                                </div>
                            </div>
                        </c:if>
                        
                        <!-- Ghi chú nội bộ -->
                        <div class="card">
                            <div class="card-header">
                                <h3 class="card-title">Ghi chú nội bộ</h3>
                            </div>
                            <div class="card-body">
                                <form method="post" action="${pageContext.request.contextPath}/admin/orders">
                                    <input type="hidden" name="action" value="updateNote">
                                    <input type="hidden" name="orderId" value="${order.orderID}">
                                    <div class="form-group">
                                        <textarea name="note" class="form-control" rows="3" 
                                                  placeholder="Ghi chú nội bộ...">${order.notes}</textarea>
                                    </div>
                                    <button type="submit" class="btn btn-secondary btn-block">
                                        <i class="fas fa-save"></i> Lưu ghi chú
                                    </button>
                                </form>
                            </div>
                        </div>
                        
                        <!-- Nút quay lại -->
                        <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-secondary btn-block">
                            <i class="fas fa-arrow-left"></i> Quay lại danh sách
                        </a>
                        
                    </div>
                </div>
            </div>
        </section>
    </div>

    <!-- Modal Reassign -->
    <c:if test="${canAssign && order.assignedSeller != null}">
        <div class="modal fade" id="reassignModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Chuyển đơn hàng cho người khác</h5>
                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                    </div>
                    <form method="post" action="${pageContext.request.contextPath}/admin/orders">
                        <div class="modal-body">
                            <input type="hidden" name="action" value="reassign">
                            <input type="hidden" name="orderId" value="${order.orderID}">
                            <p>Đơn hàng đang được xử lý bởi: <strong>${order.assignedSeller.fullName}</strong></p>
                            <div class="form-group">
                                <label>Chọn nhân viên mới:</label>
                                <select name="sellerId" class="form-control" required>
                                    <option value="">-- Chọn Seller --</option>
                                    <c:forEach var="seller" items="${sellers}">
                                        <c:if test="${seller[0] != order.assignedTo}">
                                            <option value="${seller[0]}">
                                                ${seller[1]} (${seller[4]} đơn đang xử lý)
                                            </option>
                                        </c:if>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                            <button type="submit" class="btn btn-warning">Chuyển đơn</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </c:if>

    <jsp:include page="../includes/admin-footer.jsp" />
</div>

<jsp:include page="../includes/admin-scripts.jsp" />

<script>
// Không cần chọn carrier nữa vì đã lưu từ checkout
</script>
</body>
</html>
