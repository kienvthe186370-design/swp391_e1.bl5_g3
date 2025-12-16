<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    request.setAttribute("pageTitle", "Chi tiết Khách hàng");
%>
<jsp:include page="../includes/admin-header.jsp"/>
<jsp:include page="../includes/admin-sidebar.jsp"/>

<div class="content-wrapper">
  <div class="content-header">
    <div class="container-fluid">
      <div class="row mb-2">
        <div class="col-sm-6">
          <h1 class="m-0"><i class="fas fa-user"></i> Chi tiết Khách hàng</h1>
        </div>
        <div class="col-sm-6">
          <ol class="breadcrumb float-sm-right">
            <li class="breadcrumb-item">
              <a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp">Dashboard</a>
            </li>
            <li class="breadcrumb-item">
              <a href="<%= request.getContextPath() %>/seller-manager/customers">Khách hàng</a>
            </li>
            <li class="breadcrumb-item active">Chi tiết</li>
          </ol>
        </div>
      </div>
    </div>
  </div>

  <section class="content">
    <div class="container-fluid">
      <c:if test="${customer == null}">
        <div class="alert alert-danger">
          Không tìm thấy khách hàng!
        </div>
        <a href="<%= request.getContextPath() %>/seller-manager/customers" class="btn btn-secondary">
          <i class="fas fa-arrow-left"></i> Quay lại
        </a>
      </c:if>
      
      <c:if test="${customer != null}">
        <div class="card">
          <div class="card-header">
            <h3 class="card-title">Thông tin Khách hàng #${customer.customerID}</h3>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-6">
                <table class="table table-bordered">
                  <tr>
                    <th style="width: 200px;">ID</th>
                    <td><strong>#${customer.customerID}</strong></td>
                  </tr>
                  <tr>
                    <th>Họ tên</th>
                    <td>${customer.fullName}</td>
                  </tr>
                  <tr>
                    <th>Email</th>
                    <td>${customer.email}</td>
                  </tr>
                  <tr>
                    <th>Số điện thoại</th>
                    <td>${customer.phone != null ? customer.phone : '-'}</td>
                  </tr>
                  <tr>
                    <th>Xác thực Email</th>
                    <td>
                      <c:choose>
                        <c:when test="${customer.emailVerified}">
                          <span class="badge badge-success">Đã xác thực</span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge badge-warning">Chưa xác thực</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                  </tr>
                  <tr>
                    <th>Trạng thái</th>
                    <td>
                      <c:choose>
                        <c:when test="${customer.active}">
                          <span class="badge badge-success">Đang hoạt động</span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge badge-danger">Đã khóa</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                  </tr>
                  <tr>
                    <th>Ngày tạo</th>
                    <td>
                      <fmt:formatDate value="${customer.createdDate}" pattern="dd/MM/yyyy HH:mm:ss"/>
                    </td>
                  </tr>
                  <tr>
                    <th>Lần đăng nhập cuối</th>
                    <td>
                      <c:choose>
                        <c:when test="${customer.lastLogin != null}">
                          <fmt:formatDate value="${customer.lastLogin}" pattern="dd/MM/yyyy HH:mm:ss"/>
                        </c:when>
                        <c:otherwise>
                          <span class="text-muted">Chưa đăng nhập</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                  </tr>
                </table>
              </div>
              <div class="col-md-6">
                <c:set var="defaultAddress" value="${null}"/>
                <c:forEach var="addr" items="${addresses}">
                  <c:if test="${addr['default']}">
                    <c:set var="defaultAddress" value="${addr}"/>
                  </c:if>
                </c:forEach>
                <div class="card border-success mb-0">
                  <div class="card-header bg-success text-white d-flex justify-content-between align-items-center">
                    <span><i class="fas fa-map-marker-alt mr-1"></i> Địa chỉ giao hàng</span>
                    <button type="button" class="btn btn-sm btn-light" data-toggle="modal" data-target="#addressModal">
                      Xem các địa chỉ khác
                    </button>
                  </div>
                  <div class="card-body">
                    <c:choose>
                      <c:when test="${defaultAddress != null}">
                        <div class="border rounded p-3 mb-0 border-success">
                          <div class="d-flex justify-content-between align-items-center mb-2">
                            <strong>${defaultAddress.recipientName}</strong>
                            <span class="badge badge-primary">Mặc định</span>
                          </div>
                          <div class="text-muted"><i class="fas fa-phone"></i> ${defaultAddress.phone}</div>
                          <div class="mt-1">
                            ${defaultAddress.street}, ${defaultAddress.ward}, ${defaultAddress.district}, ${defaultAddress.city}
                            <c:if test="${not empty defaultAddress.postalCode}">
                              (Mã bưu điện: ${defaultAddress.postalCode})
                            </c:if>
                          </div>
                        </div>
                      </c:when>
                      <c:otherwise>
                        <div class="text-muted">Khách hàng chưa có địa chỉ mặc định</div>
                      </c:otherwise>
                    </c:choose>
                    <c:if test="${empty addresses}">
                      <div class="text-muted mt-2">Khách hàng chưa có địa chỉ nào</div>
                    </c:if>
                  </div>
                </div>
              </div>
            </div>

            <div class="row mt-4">
              <div class="col-12">
                <div class="card">
                  <div class="card-header bg-warning">
                    <h3 class="card-title mb-0"><i class="fas fa-shopping-cart"></i> Lịch sử đơn hàng</h3>
                  </div>
                  <div class="card-body p-0">
                    <c:choose>
                      <c:when test="${not empty orders}">
                        <div class="table-responsive">
                          <table class="table table-striped mb-0">
                            <thead>
                              <tr>
                                <th>Mã đơn</th>
                                <th>Ngày đặt</th>
                                <th>Tổng tiền</th>
                                <th>Thanh toán</th>
                                <th>Trạng thái</th>
                              </tr>
                            </thead>
                            <tbody>
                              <c:forEach var="order" items="${orders}">
                                <tr>
                                  <td>#${order.orderID}</td>
                                  <td><fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy HH:mm"/></td>
                                  <td><fmt:formatNumber value="${order.totalAmount}" type="number" pattern="#,##0"/>đ</td>
                                  <td>
                                    <span class="badge ${'Paid' == order.paymentStatus ? 'badge-success' : 'badge-secondary'}">
                                      ${order.paymentStatus != null ? order.paymentStatus : 'Chưa thanh toán'}
                                    </span>
                                  </td>
                                  <td>
                                    <span class="badge badge-info">${order.orderStatus}</span>
                                  </td>
                                </tr>
                              </c:forEach>
                            </tbody>
                          </table>
                        </div>
                      </c:when>
                      <c:otherwise>
                        <div class="p-3 text-muted">Khách hàng chưa có đơn hàng nào</div>
                      </c:otherwise>
                    </c:choose>
                  </div>
                  <c:if test="${historyTotalPages > 1}">
                    <div class="card-footer">
                      <nav>
                        <ul class="pagination mb-0">
                          <li class="page-item ${historyPage <= 1 ? 'disabled' : ''}">
                            <c:choose>
                              <c:when test="${historyPage <= 1}">
                                <span class="page-link">Trước</span>
                              </c:when>
                              <c:otherwise>
                                <a class="page-link"
                                   href="<%= request.getContextPath() %>/seller-manager/customers?action=detail&id=${customer.customerID}&historyPage=${historyPage - 1}">
                                  Trước
                                </a>
                              </c:otherwise>
                            </c:choose>
                          </li>
                          
                          <c:forEach var="i" begin="1" end="${historyTotalPages}">
                            <li class="page-item ${i == historyPage ? 'active' : ''}">
                              <a class="page-link"
                                 href="<%= request.getContextPath() %>/seller-manager/customers?action=detail&id=${customer.customerID}&historyPage=${i}">
                                ${i}
                              </a>
                            </li>
                          </c:forEach>
                          
                          <li class="page-item ${historyPage >= historyTotalPages ? 'disabled' : ''}">
                            <c:choose>
                              <c:when test="${historyPage >= historyTotalPages}">
                                <span class="page-link">Sau</span>
                              </c:when>
                              <c:otherwise>
                                <a class="page-link"
                                   href="<%= request.getContextPath() %>/seller-manager/customers?action=detail&id=${customer.customerID}&historyPage=${historyPage + 1}">
                                  Sau
                                </a>
                              </c:otherwise>
                            </c:choose>
                          </li>
                        </ul>
                      </nav>
                    </div>
                  </c:if>
                </div>
              </div>
            </div>

            <div class="row">
              <div class="col-12">
                <div class="card">
                  <div class="card-header">
                    <h3 class="card-title mb-0"><i class="fas fa-chart-pie"></i> Thống kê</h3>
                  </div>
                  <div class="card-body">
                    <div class="row text-center">
                      <div class="col-md-2 col-6 mb-3">
                        <div class="h5 mb-0">${orderStats.totalOrders}</div>
                        <small class="text-muted">Tổng đơn</small>
                      </div>
                      <div class="col-md-2 col-6 mb-3">
                        <div class="h5 mb-0">${orderStats.activeOrders}</div>
                        <small class="text-muted">Đang xử lý</small>
                      </div>
                      <div class="col-md-2 col-6 mb-3">
                        <div class="h5 mb-0">${orderStats.completedOrders}</div>
                        <small class="text-muted">Đã hoàn tất</small>
                      </div>
                      <div class="col-md-2 col-6 mb-3">
                        <div class="h5 mb-0">${orderStats.cancelledOrders}</div>
                        <small class="text-muted">Đã hủy</small>
                      </div>
                      <div class="col-md-2 col-6 mb-3">
                        <div class="h5 mb-0">
                          <fmt:formatNumber value="${orderStats.totalSpent}" type="number" pattern="#,##0"/>đ
                        </div>
                        <small class="text-muted">Tổng chi tiêu</small>
                      </div>
                      <div class="col-md-2 col-6 mb-3">
                        <div class="h6 mb-0">
                          <c:choose>
                            <c:when test="${orderStats.lastOrderDate != null}">
                              <fmt:formatDate value="${orderStats.lastOrderDate}" pattern="dd/MM/yyyy HH:mm"/>
                            </c:when>
                            <c:otherwise>
                              <span class="text-muted">-</span>
                            </c:otherwise>
                          </c:choose>
                        </div>
                        <small class="text-muted">Đơn gần nhất</small>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="card-footer">
            <a href="<%= request.getContextPath() %>/seller-manager/customers?action=edit&id=${customer.customerID}" 
               class="btn btn-warning">
              <i class="fas fa-edit"></i> Chỉnh sửa
            </a>
            <a href="<%= request.getContextPath() %>/seller-manager/customers" 
               class="btn btn-secondary">
              <i class="fas fa-arrow-left"></i> Quay lại
            </a>
          </div>
        </div>

        <!-- Modal danh sách địa chỉ -->
        <div class="modal fade" id="addressModal" tabindex="-1" role="dialog" aria-labelledby="addressModalLabel" aria-hidden="true">
          <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
              <div class="modal-header">
                <h5 class="modal-title" id="addressModalLabel">Danh sách địa chỉ</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                  <span aria-hidden="true">&times;</span>
                </button>
              </div>
              <div class="modal-body">
                <c:choose>
                  <c:when test="${not empty addresses}">
                    <div class="list-group">
                      <c:forEach var="addr" items="${addresses}">
                        <div class="list-group-item">
                          <div class="d-flex justify-content-between align-items-center mb-1">
                            <strong>${addr.recipientName}</strong>
                            <c:if test="${addr['default']}">
                              <span class="badge badge-primary">Mặc định</span>
                            </c:if>
                          </div>
                          <div class="text-muted"><i class="fas fa-phone"></i> ${addr.phone}</div>
                          <div>
                            ${addr.street}, ${addr.ward}, ${addr.district}, ${addr.city}
                            <c:if test="${not empty addr.postalCode}">
                              (Mã bưu điện: ${addr.postalCode})
                            </c:if>
                          </div>
                        </div>
                      </c:forEach>
                    </div>
                  </c:when>
                  <c:otherwise>
                    <div class="text-muted">Khách hàng chưa có địa chỉ nào</div>
                  </c:otherwise>
                </c:choose>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Đóng</button>
              </div>
            </div>
          </div>
        </div>
      </c:if>
    </div>
  </section>
</div>

<jsp:include page="../includes/admin-footer.jsp"/>

