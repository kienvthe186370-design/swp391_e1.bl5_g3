<%-- 
    Document   : navbar
    Created on : Dec 7, 2025, 10:59:11 PM
    Author     : xuand
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!-- Navbar -->
<nav class="main-header navbar navbar-expand navbar-white navbar-light">
  <!-- Left navbar links -->
  <ul class="navbar-nav">
    <li class="nav-item">
      <a class="nav-link" data-widget="pushmenu" href="#" role="button"><i class="fas fa-bars"></i></a>
    </li>
    <li class="nav-item d-none d-sm-inline-block">
      <a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp" class="nav-link">Home</a>
    </li>
  </ul>

  <!-- Right navbar links -->
  <ul class="navbar-nav ml-auto">
    <!-- User Info -->
    <li class="nav-item">
      <span class="nav-link">
        <i class="fas fa-user"></i> <%= session.getAttribute("employee") != null ? ((entity.Employee)session.getAttribute("employee")).getFullName() : "Admin" %>
      </span>
    </li>
    <!-- Logout -->
    <li class="nav-item">
      <a class="nav-link" href="<%= request.getContextPath() %>/logout">
        <i class="fas fa-sign-out-alt"></i> Đăng xuất
      </a>
    </li>
  </ul>
</nav>
