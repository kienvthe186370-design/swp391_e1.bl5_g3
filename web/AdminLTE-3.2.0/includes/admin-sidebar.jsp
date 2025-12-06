<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entity.Employee" %>
<%
    Employee employee = (Employee) session.getAttribute("employee");
    String adminName = (employee != null) ? employee.getFullName() : "Admin";
    String adminEmail = (employee != null) ? employee.getEmail() : "";
    
    String activePage = (String) request.getAttribute("activePage");
    if (activePage == null) activePage = "dashboard";
%>
<!-- Main Sidebar Container -->
<aside class="main-sidebar sidebar-dark-primary elevation-4">
  <!-- Brand Logo -->
  <a href="<%= request.getContextPath() %>/admin/dashboard" class="brand-link">
    <img src="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/img/AdminLTELogo.png" alt="AdminLTE Logo" class="brand-image img-circle elevation-3" style="opacity: .8">
    <span class="brand-text font-weight-light">Pickleball Admin</span>
  </a>

  <!-- Sidebar -->
  <div class="sidebar">
    <!-- Sidebar user panel (optional) -->
    <div class="user-panel mt-3 pb-3 mb-3 d-flex">
      <div class="image">
        <img src="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/img/user2-160x160.jpg" class="img-circle elevation-2" alt="User Image">
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
          <a href="<%= request.getContextPath() %>/admin/dashboard" class="nav-link <%= activePage.equals("dashboard") ? "active" : "" %>">
            <i class="nav-icon fas fa-tachometer-alt"></i>
            <p>Dashboard</p>
          </a>
        </li>
        
        <!-- Users Management -->
        <li class="nav-item <%= activePage.startsWith("user") ? "menu-open" : "" %>">
          <a href="#" class="nav-link <%= activePage.startsWith("user") ? "active" : "" %>">
            <i class="nav-icon fas fa-users"></i>
            <p>
              Quản lý User
              <i class="fas fa-angle-left right"></i>
            </p>
          </a>
          <ul class="nav nav-treeview">
            <li class="nav-item">
              <a href="<%= request.getContextPath() %>/admin/customers" class="nav-link <%= activePage.equals("customers") ? "active" : "" %>">
                <i class="far fa-circle nav-icon"></i>
                <p>Khách hàng</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="<%= request.getContextPath() %>/admin/employees" class="nav-link <%= activePage.equals("employees") ? "active" : "" %>">
                <i class="far fa-circle nav-icon"></i>
                <p>Nhân viên</p>
              </a>
            </li>
          </ul>
        </li>

        <!-- Products -->
        <li class="nav-item <%= activePage.startsWith("product") ? "menu-open" : "" %>">
          <a href="#" class="nav-link <%= activePage.startsWith("product") ? "active" : "" %>">
            <i class="nav-icon fas fa-cube"></i>
            <p>
              Sản phẩm
              <i class="fas fa-angle-left right"></i>
            </p>
          </a>
          <ul class="nav nav-treeview">
            <li class="nav-item">
              <a href="<%= request.getContextPath() %>/admin/products" class="nav-link <%= activePage.equals("products") ? "active" : "" %>">
                <i class="far fa-circle nav-icon"></i>
                <p>Danh sách</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="<%= request.getContextPath() %>/admin/product-add" class="nav-link <%= activePage.equals("product-add") ? "active" : "" %>">
                <i class="far fa-circle nav-icon"></i>
                <p>Thêm mới</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="<%= request.getContextPath() %>/admin/categories" class="nav-link <%= activePage.equals("categories") ? "active" : "" %>">
                <i class="far fa-circle nav-icon"></i>
                <p>Danh mục</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="<%= request.getContextPath() %>/admin/brands" class="nav-link <%= activePage.equals("brands") ? "active" : "" %>">
                <i class="far fa-circle nav-icon"></i>
                <p>Thương hiệu</p>
              </a>
            </li>
          </ul>
        </li>

        <!-- Orders -->
        <li class="nav-item">
          <a href="<%= request.getContextPath() %>/admin/orders" class="nav-link <%= activePage.equals("orders") ? "active" : "" %>">
            <i class="nav-icon fas fa-shopping-cart"></i>
            <p>Đơn hàng</p>
          </a>
        </li>

        <!-- Vouchers -->
        <li class="nav-item">
          <a href="<%= request.getContextPath() %>/admin/vouchers" class="nav-link <%= activePage.equals("vouchers") ? "active" : "" %>">
            <i class="nav-icon fas fa-ticket-alt"></i>
            <p>Voucher</p>
          </a>
        </li>

        <!-- Blogs -->
        <li class="nav-item">
          <a href="<%= request.getContextPath() %>/admin/blogs" class="nav-link <%= activePage.equals("blogs") ? "active" : "" %>">
            <i class="nav-icon fas fa-blog"></i>
            <p>Blogs</p>
          </a>
        </li>

        <!-- Reports -->
        <li class="nav-item">
          <a href="<%= request.getContextPath() %>/admin/reports" class="nav-link <%= activePage.equals("reports") ? "active" : "" %>">
            <i class="nav-icon fas fa-chart-bar"></i>
            <p>Báo cáo</p>
          </a>
        </li>

        <!-- Settings -->
        <li class="nav-item">
          <a href="<%= request.getContextPath() %>/admin/settings" class="nav-link <%= activePage.equals("settings") ? "active" : "" %>">
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
