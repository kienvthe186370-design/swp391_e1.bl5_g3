<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    // Mode: "create" hoặc "edit"
    String mode = (String) request.getAttribute("formMode");
    if (mode == null) mode = "create";
    
    String pageTitle = "create".equals(mode) ? "Thêm Khách hàng mới" : "Chỉnh sửa Khách hàng";
    request.setAttribute("pageTitle", pageTitle);
    
    // Get message from session
    String message = (String) session.getAttribute("message");
    String messageType = (String) session.getAttribute("messageType");
    session.removeAttribute("message");
    session.removeAttribute("messageType");
    
    // Set vào request attribute để JSTL có thể truy cập
    if (message != null) {
        request.setAttribute("message", message);
        request.setAttribute("messageType", messageType);
    }
%>
<jsp:include page="../includes/admin-header.jsp"/>
<jsp:include page="../includes/admin-sidebar.jsp"/>

<div class="content-wrapper">
  <div class="content-header">
    <div class="container-fluid">
      <div class="row mb-2">
        <div class="col-sm-6">
          <h1 class="m-0">
            <i class="fas fa-<%= "create".equals(mode) ? "plus" : "edit" %>"></i> 
            <%= pageTitle %>
          </h1>
        </div>
        <div class="col-sm-6">
          <ol class="breadcrumb float-sm-right">
            <li class="breadcrumb-item">
              <a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp">Dashboard</a>
            </li>
            <li class="breadcrumb-item">
              <a href="<%= request.getContextPath() %>/admin/customers">Khách hàng</a>
            </li>
            <li class="breadcrumb-item active"><%= "create".equals(mode) ? "Thêm mới" : "Chỉnh sửa" %></li>
          </ol>
        </div>
      </div>
    </div>
  </div>

  <section class="content">
    <div class="container-fluid">
      <!-- Alert Message -->
      <c:if test="${not empty message}">
        <div class="alert alert-${messageType} alert-dismissible fade show" role="alert">
          ${message}
          <button type="button" class="close" data-dismiss="alert" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
      </c:if>

      <!-- Sử dụng form CHUNG -->
      <jsp:include page="../shared/form-customer.jsp"/>
    </div>
  </section>
</div>

<jsp:include page="../includes/admin-footer.jsp"/>

