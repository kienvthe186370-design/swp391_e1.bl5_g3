<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% request.setAttribute("pageTitle", "Chi tiết hoàn tiền"); %>
<jsp:include page="includes/admin-header.jsp"/>
<jsp:include page="includes/admin-sidebar.jsp"/>

<style>
    .media-gallery img, .media-gallery video {
        width: 120px;
        height: 120px;
        object-fit: cover;
        border-radius: 8px;
        cursor: pointer;
        margin: 5px;
    }
    .product-img {
        width: 60px;
        height: 60px;
        object-fit: cover;
        border-radius: 4px;
    }
</style>

<div class="content-wrapper">
    <div class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h1 class="m-0">Chi tiết yêu cầu hoàn tiền #${refundRequest.refundRequestID}</h1>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/refunds">Hoàn tiền</a></li>
                        <li class="breadcrumb-item active">#${refundRequest.refundRequestID}</li>
                    </ol>
                </div>
            </div>
        </div>
    </div>

    <section class="content">
        <div class="container-fluid">
            <c:if test="${not empty error}">
                <div class="alert alert-danger alert-dismissible">
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                    ${error}
                </div>
            </c:if>
            <c:if test="${not empty success}">
                <div class="alert alert-success alert-dismissible">
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                    ${success}
                </div>
            </c:if>
            
            <c:if test="${empty refundRequest}">
                <div class="alert alert-warning">
                    <i class="fas fa-exclamation-triangle"></i> Không tìm thấy yêu cầu hoàn tiền.
                    <a href="${pageContext.request.contextPath}/admin/refunds" class="btn btn-sm btn-secondary ml-2">Quay lại</a>
                </div>
            </c:if>
            
            <c:if test="${not empty refundRequest}">
            <div class="row">
                <div class="col-lg-8">
                    <!-- Thông tin yêu cầu -->
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">Thông tin yêu cầu</h3>
                            <div class="card-tools">
                                <c:choose>
                                    <c:when test="${refundRequest.refundStatus == 'Pending'}">
                                        <span class="badge badge-warning badge-lg">Đang chờ xử lý</span>
                                    </c:when>
                                    <c:when test="${refundRequest.refundStatus == 'Approved'}">
                                        <span class="badge badge-success badge-lg">Đã duyệt</span>
                                    </c:when>
                                    <c:when test="${refundRequest.refundStatus == 'Rejected'}">
                                        <span class="badge badge-danger badge-lg">Từ chối</span>
                                    </c:when>
                                    <c:when test="${refundRequest.refundStatus == 'Completed'}">
                                        <span class="badge badge-info badge-lg">Hoàn thành</span>
                                    </c:when>
                                </c:choose>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <dl>
                                        <dt>Đơn hàng</dt>
                                        <dd>
                                            <a href="${pageContext.request.contextPath}/admin/order?action=detail&id=${refundRequest.orderID}">
                                                ${refundRequest.order.orderCode}
                                            </a>
                                        </dd>
                                        
                                        <dt>Ngày yêu cầu</dt>
                                        <dd><fmt:formatDate value="${refundRequest.requestDate}" pattern="dd/MM/yyyy HH:mm"/></dd>
                                        
                                        <dt>Số tiền hoàn</dt>
                                        <dd class="text-danger font-weight-bold" style="font-size: 1.2em;">
                                            <fmt:formatNumber value="${refundRequest.refundAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                        </dd>
                                    </dl>
                                </div>
                                <div class="col-md-6">
                                    <dl>
                                        <dt>Khách hàng</dt>
                                        <dd>
                                            <strong>${refundRequest.customer.fullName}</strong><br>
                                            <small>${refundRequest.customer.email}</small>
                                        </dd>
                                        
                                        <c:if test="${not empty refundRequest.processedDate}">
                                            <dt>Ngày xử lý</dt>
                                            <dd><fmt:formatDate value="${refundRequest.processedDate}" pattern="dd/MM/yyyy HH:mm"/></dd>
                                        </c:if>
                                        
                                        <c:if test="${not empty refundRequest.processor}">
                                            <dt>Người xử lý</dt>
                                            <dd>${refundRequest.processor.fullName}</dd>
                                        </c:if>
                                    </dl>
                                </div>
                            </div>
                            
                            <hr>
                            
                            <h6>Lý do hoàn tiền</h6>
                            <p class="bg-light p-3 rounded">${refundRequest.refundReason}</p>
                            
                            <c:if test="${not empty refundRequest.adminNotes}">
                                <h6>Ghi chú xử lý</h6>
                                <div class="alert ${refundRequest.refundStatus == 'Rejected' ? 'alert-danger' : 'alert-info'}">
                                    ${refundRequest.adminNotes}
                                </div>
                            </c:if>
                        </div>
                    </div>
                    
                    <!-- Sản phẩm hoàn -->
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">Sản phẩm yêu cầu hoàn</h3>
                        </div>
                        <div class="card-body p-0">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>Sản phẩm</th>
                                        <th>SKU</th>
                                        <th>Đơn giá</th>
                                        <th>SL hoàn</th>
                                        <th>Lý do</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="item" items="${refundRequest.refundItems}">
                                        <tr>
                                            <td>
                                                <div class="d-flex align-items-center">
                                                    <img src="${pageContext.request.contextPath}${item.orderDetail.productImage}" 
                                                         class="product-img mr-2" alt=""
                                                         onerror="this.src='${pageContext.request.contextPath}/img/no-image.png'">
                                                    <span>${item.orderDetail.productName}</span>
                                                </div>
                                            </td>
                                            <td>${item.orderDetail.sku}</td>
                                            <td>
                                                <fmt:formatNumber value="${item.orderDetail.unitPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                            </td>
                                            <td>${item.quantity}</td>
                                            <td>${item.itemReason}</td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty refundRequest.refundItems}">
                                        <tr>
                                            <td colspan="5" class="text-center text-muted">Không có sản phẩm</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    
                    <!-- Hình ảnh minh chứng -->
                    <c:if test="${not empty refundRequest.refundMedia}">
                        <div class="card">
                            <div class="card-header">
                                <h3 class="card-title">Hình ảnh/Video minh chứng</h3>
                            </div>
                            <div class="card-body">
                                <div class="media-gallery">
                                    <c:forEach var="media" items="${refundRequest.refundMedia}">
                                        <c:choose>
                                            <c:when test="${media.mediaType == 'image'}">
                                                <img src="${pageContext.request.contextPath}${media.mediaURL}" 
                                                     alt="Minh chứng" onclick="openMedia('${pageContext.request.contextPath}${media.mediaURL}', 'image')">
                                            </c:when>
                                            <c:otherwise>
                                                <video onclick="openMedia('${pageContext.request.contextPath}${media.mediaURL}', 'video')">
                                                    <source src="${pageContext.request.contextPath}${media.mediaURL}">
                                                </video>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:forEach>
                                </div>
                            </div>
                        </div>
                    </c:if>
                </div>
                
                <div class="col-lg-4">
                    <!-- Thông tin đơn hàng -->
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">Thông tin đơn hàng</h3>
                        </div>
                        <div class="card-body">
                            <dl>
                                <dt>Mã đơn</dt>
                                <dd>${refundRequest.order.orderCode}</dd>
                                
                                <dt>Trạng thái đơn</dt>
                                <dd>
                                    <c:choose>
                                        <c:when test="${refundRequest.order.orderStatus == 'Delivered'}">
                                            <span class="badge badge-success">Đã giao</span>
                                        </c:when>
                                        <c:when test="${refundRequest.order.orderStatus == 'Shipping'}">
                                            <span class="badge badge-info">Đang giao</span>
                                        </c:when>
                                        <c:when test="${refundRequest.order.orderStatus == 'Returned'}">
                                            <span class="badge badge-secondary">Đã hoàn</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-secondary">${refundRequest.order.orderStatus}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </dd>
                                
                                <dt>Tổng đơn hàng</dt>
                                <dd>
                                    <fmt:formatNumber value="${refundRequest.order.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                </dd>
                                
                                <dt>Phương thức thanh toán</dt>
                                <dd>${refundRequest.order.paymentMethod}</dd>
                                
                                <dt>Trạng thái thanh toán</dt>
                                <dd>
                                    <c:choose>
                                        <c:when test="${refundRequest.order.paymentStatus == 'Paid'}">
                                            <span class="badge badge-success">Đã thanh toán</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-warning">${refundRequest.order.paymentStatus}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </dd>
                            </dl>
                        </div>
                    </div>
                    
                    <!-- Actions -->
                    <c:if test="${refundRequest.refundStatus == 'Pending'}">
                        <div class="card">
                            <div class="card-header">
                                <h3 class="card-title">Xử lý yêu cầu</h3>
                            </div>
                            <div class="card-body">
                                <form action="${pageContext.request.contextPath}/admin/refund" method="post" id="processForm">
                                    <input type="hidden" name="refundId" value="${refundRequest.refundRequestID}">
                                    <input type="hidden" name="action" id="processAction">
                                    
                                    <div class="form-group">
                                        <label>Ghi chú</label>
                                        <textarea class="form-control" name="adminNotes" rows="3" id="adminNotes"
                                                  placeholder="Nhập ghi chú..."></textarea>
                                    </div>
                                    
                                    <div class="btn-group w-100">
                                        <button type="button" class="btn btn-success" onclick="processRefund('approve')">
                                            <i class="fas fa-check"></i> Duyệt
                                        </button>
                                        <button type="button" class="btn btn-danger" onclick="processRefund('reject')">
                                            <i class="fas fa-times"></i> Từ chối
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </c:if>
                    
                    <c:if test="${refundRequest.refundStatus == 'Approved' && employeeRole == 'SellerManager'}">
                        <div class="card">
                            <div class="card-header">
                                <h3 class="card-title">Hoàn thành hoàn tiền</h3>
                            </div>
                            <div class="card-body">
                                <p>Sau khi đã chuyển tiền cho khách hàng, nhấn nút bên dưới để hoàn tất.</p>
                                <form action="${pageContext.request.contextPath}/admin/refund" method="post">
                                    <input type="hidden" name="action" value="complete">
                                    <input type="hidden" name="refundId" value="${refundRequest.refundRequestID}">
                                    <button type="submit" class="btn btn-primary btn-block">
                                        <i class="fas fa-check-double"></i> Xác nhận hoàn thành
                                    </button>
                                </form>
                            </div>
                        </div>
                    </c:if>
                    
                    <a href="${pageContext.request.contextPath}/admin/refunds" class="btn btn-secondary btn-block">
                        <i class="fas fa-arrow-left"></i> Quay lại danh sách
                    </a>
                </div>
            </div>
            </c:if>
        </div>
    </section>
</div>

<!-- Media Modal -->
<div class="modal fade" id="mediaModal">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-body p-0">
                <img id="modalImage" src="" class="img-fluid w-100" style="display: none;">
                <video id="modalVideo" controls class="w-100" style="display: none;">
                    <source src="" type="video/mp4">
                </video>
            </div>
        </div>
    </div>
</div>

<script>
    function processRefund(action) {
        var notes = document.getElementById('adminNotes').value;
        
        if (action === 'reject' && !notes.trim()) {
            alert('Vui lòng nhập lý do từ chối');
            return;
        }
        
        var confirmMsg = action === 'approve' 
            ? 'Bạn có chắc chắn muốn duyệt yêu cầu hoàn tiền này?' 
            : 'Bạn có chắc chắn muốn từ chối yêu cầu hoàn tiền này?';
        
        if (confirm(confirmMsg)) {
            document.getElementById('processAction').value = action;
            document.getElementById('processForm').submit();
        }
    }
    
    function openMedia(url, type) {
        var img = document.getElementById('modalImage');
        var video = document.getElementById('modalVideo');
        
        if (type === 'image') {
            img.src = url;
            img.style.display = 'block';
            video.style.display = 'none';
        } else {
            video.querySelector('source').src = url;
            video.load();
            video.style.display = 'block';
            img.style.display = 'none';
        }
        
        $('#mediaModal').modal('show');
    }
</script>

<jsp:include page="includes/admin-footer.jsp"/>
