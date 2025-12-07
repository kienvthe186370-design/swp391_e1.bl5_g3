<%-- 
    Document   : index
    Created on : Dec 5, 2025, 3:37:35 PM
    Author     : ASUS
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entity.Employee" %>
<%
    // Check if user is logged in and is Admin
    Employee employee = (Employee) session.getAttribute("employee");
    if (employee == null || !"Admin".equalsIgnoreCase(employee.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    // Get admin info
    String adminName = employee.getFullName() != null ? employee.getFullName() : "Admin";
    String adminEmail = employee.getEmail() != null ? employee.getEmail() : "";
    
    // Determine which content to load
    String contentPage = (String) request.getAttribute("contentPage");
    if (contentPage == null) {
        contentPage = "dashboard"; // default
    }
    
    String activePage = (String) request.getAttribute("activePage");
    if (activePage == null) {
        activePage = "dashboard";
    }
    
    String pageTitle = (String) request.getAttribute("pageTitle");
    if (pageTitle == null) {
        pageTitle = "Dashboard";
    }
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="includes/admin-head.jsp" />
<body class="hold-transition sidebar-mini layout-fixed">
<div class="wrapper">

  <!-- Preloader -->
  <div class="preloader flex-column justify-content-center align-items-center">
    <img class="animation__shake" src="dist/img/AdminLTELogo.png" alt="AdminLTELogo" height="60" width="60">
  </div>

  <!-- Navbar -->
  <jsp:include page="includes/admin-header.jsp" />
  <!-- /.navbar -->

  <!-- Main Sidebar Container -->
  <aside class="main-sidebar sidebar-dark-primary elevation-4">
    <!-- Brand Logo -->
    <a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp" class="brand-link">
      <img src="dist/img/AdminLTELogo.png" alt="AdminLTE Logo" class="brand-image img-circle elevation-3" style="opacity: .8">
      <span class="brand-text font-weight-light">Pickleball Admin</span>
    </a>

    <!-- Sidebar -->
    <div class="sidebar">
      <!-- Sidebar user panel (optional) -->
      <div class="user-panel mt-3 pb-3 mb-3 d-flex">
        <div class="image">
          <img src="dist/img/user2-160x160.jpg" class="img-circle elevation-2" alt="User Image">
        </div>
        <div class="info">
          <a href="#" class="d-block"><%= adminName %></a>
          <small class="text-muted"><%= adminEmail %></small>
        </div>
      </div>

      <!-- Sidebar Menu -->
      <nav class="mt-2">
        <ul class="nav nav-pills nav-sidebar flex-column" data-widget="treeview" role="menu" data-accordion="false">
          <!-- Dashboard -->
          <li class="nav-item">
            <a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp" class="nav-link active">
              <i class="nav-icon fas fa-tachometer-alt"></i>
              <p>Dashboard</p>
            </a>
          </li>
          
          <!-- Users Management -->
          <li class="nav-item">
            <a href="#" class="nav-link">
              <i class="nav-icon fas fa-users"></i>
              <p>
                Quản lý User
                <i class="fas fa-angle-left right"></i>
              </p>
            </a>
            <ul class="nav nav-treeview">
              <li class="nav-item">
                <a href="#" class="nav-link">
                  <i class="far fa-circle nav-icon"></i>
                  <p>Khách hàng</p>
                </a>
              </li>
              <li class="nav-item">
                <a href="#" class="nav-link">
                  <i class="far fa-circle nav-icon"></i>
                  <p>Nhân viên</p>
                </a>
              </li>
            </ul>
          </li>

          <!-- Products -->
          <li class="nav-item">
            <a href="#" class="nav-link">
              <i class="nav-icon fas fa-cube"></i>
              <p>
                Sản phẩm
                <i class="fas fa-angle-left right"></i>
              </p>
            </a>
            <ul class="nav nav-treeview">
              <li class="nav-item">
                <a href="#" class="nav-link">
                  <i class="far fa-circle nav-icon"></i>
                  <p>Danh sách</p>
                </a>
              </li>
              <li class="nav-item">
                <a href="#" class="nav-link">
                  <i class="far fa-circle nav-icon"></i>
                  <p>Thêm mới</p>
                </a>
              </li>
              <li class="nav-item">
                <a href="#" class="nav-link">
                  <i class="far fa-circle nav-icon"></i>
                  <p>Danh mục</p>
                </a>
              </li>
              <li class="nav-item">
                <a href="#" class="nav-link">
                  <i class="far fa-circle nav-icon"></i>
                  <p>Thương hiệu</p>
                </a>
              </li>
            </ul>
          </li>

          <!-- Orders -->
          <li class="nav-item">
            <a href="#" class="nav-link">
              <i class="nav-icon fas fa-shopping-cart"></i>
              <p>Đơn hàng</p>
            </a>
          </li>

          <!-- Vouchers -->
          <li class="nav-item">
            <a href="#" class="nav-link">
              <i class="nav-icon fas fa-ticket-alt"></i>
              <p>Voucher</p>
            </a>
          </li>
          
          <!-- Slider -->
          <li class="nav-item">
            <a href="<%= request.getContextPath() %>/admin/slider" class="nav-link">

              <i class="nav-icon fas fa-fw fa-images "></i>
              <p>Slider</p>
            </a>
          </li>

          <!-- Reports -->
          <li class="nav-item">
            <a href="#" class="nav-link">
              <i class="nav-icon fas fa-chart-bar"></i>
              <p>Báo cáo</p>
            </a>
          </li>

          <!-- Settings -->
          <li class="nav-item">
            <a href="#" class="nav-link">
              <i class="nav-icon fas fa-cog"></i>
              <p>Cài đặt</p>
            </a>
          </li>
        </ul>
      </nav>
      <!-- /.sidebar-menu -->
    </div>
    <!-- /.sidebar -->
  </aside>
  <jsp:include page="includes/admin-sidebar.jsp" />

  <!-- Content Wrapper. Contains page content -->
  <div class="content-wrapper">
    <%
        // Dynamically include content based on contentPage parameter
        if ("products".equals(contentPage)) {
    %>
        <jsp:include page="content/products-content.jsp" />
    <%
        } else if ("product-add".equals(contentPage)) {
    %>
        <jsp:include page="content/product-add-content.jsp" />
    <%
        } else if ("product-details".equals(contentPage)) {
    %>
        <jsp:include page="content/product-details-content.jsp" />
    <%
        } else if ("product-edit".equals(contentPage)) {
    %>
        <jsp:include page="content/product-edit-content.jsp" />
    <%
        } else {
            // Default dashboard content
    %>
        <jsp:include page="content/dashboard-content.jsp" />
    <%
        }
    %>
  </div>
  <!-- /.content-wrapper -->
  
  <jsp:include page="includes/admin-footer.jsp" />

  <!-- Control Sidebar -->
  <aside class="control-sidebar control-sidebar-dark">
    <!-- Control sidebar content goes here -->
  </aside>
  <!-- /.control-sidebar -->
</div>
<!-- ./wrapper -->

<jsp:include page="includes/admin-scripts.jsp" />
</body>
</html>
