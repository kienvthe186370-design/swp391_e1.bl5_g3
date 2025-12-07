<%-- 
    Document   : sidebar
    Created on : Dec 7, 2025, 10:59:45 PM
    Author     : xuand
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entity.Employee" %>
<%
    Employee emp = (Employee) session.getAttribute("employee");
    String empName = emp != null ? emp.getFullName() : "Admin";
    String empEmail = emp != null ? emp.getEmail() : "";
%>
<!-- Main Sidebar Container -->
<aside class="main-sidebar sidebar-dark-primary elevation-4">
  <!-- Brand Logo -->
  <a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp" class="brand-link">
    <img src="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/img/AdminLTELogo.png" alt="AdminLTE Logo" class="brand-image img-circle elevation-3" style="opacity: .8">
    <span class="brand-text font-weight-light">Pickleball Admin</span>
  </a>

  <!-- Sidebar -->
  <div class="sidebar">
    <!-- Sidebar user panel -->
    <div class="user-panel mt-3 pb-3 mb-3 d-flex">
      <div class="image">
        <img src="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/img/user2-160x160.jpg" class="img-circle elevation-2" alt="User Image">
      </div>
      <div class="info">
        <a href="#" class="d-block"><%= empName %></a>
        <small class="text-muted"><%= empEmail %></small>
      </div>
    </div>

    <!-- Sidebar Menu -->
    <nav class="mt-2">
      <ul class="nav nav-pills nav-sidebar flex-column" data-widget="treeview" role="menu" data-accordion="false">
        <!-- Dashboard -->
        <li class="nav-item">
          <a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp" class="nav-link">
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
          </ul>
        </li>

        <!-- Orders -->
        <li class="nav-item">
          <a href="#" class="nav-link">
            <i class="nav-icon fas fa-shopping-cart"></i>
            <p>Đơn hàng</p>
          </a>
        </li>

        <!-- Categories, Brands, Attributes -->
        <li class="nav-item">
          <a href="#" class="nav-link">
            <i class="nav-icon fas fa-database"></i>
            <p>
              Quản lý Dữ liệu
              <i class="fas fa-angle-left right"></i>
            </p>
          </a>
          <ul class="nav nav-treeview">
            <li class="nav-item">
              <a href="<%= request.getContextPath() %>/admin/categories" class="nav-link">
                <i class="far fa-circle nav-icon"></i>
                <p>Danh mục</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="<%= request.getContextPath() %>/admin/brands" class="nav-link">
                <i class="far fa-circle nav-icon"></i>
                <p>Thương hiệu</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="<%= request.getContextPath() %>/admin/attributes" class="nav-link">
                <i class="far fa-circle nav-icon"></i>
                <p>Thuộc tính</p>
              </a>
            </li>
          </ul>
        </li>

        <!-- Slider -->
        <li class="nav-item">
          <a href="<%= request.getContextPath() %>/admin/slider" class="nav-link">
            <i class="nav-icon fas fa-images"></i>
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
      </ul>
    </nav>
  </div>
</aside>
