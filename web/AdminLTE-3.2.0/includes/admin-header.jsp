<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entity.Employee" %>
<%
    Employee employee = (Employee) session.getAttribute("employee");
    String adminName = (employee != null) ? employee.getFullName() : "Admin";
%>
<!-- Navbar -->
<nav class="main-header navbar navbar-expand navbar-white navbar-light">
  <!-- Left navbar links -->
  <ul class="navbar-nav">
    <li class="nav-item">
      <a class="nav-link" data-widget="pushmenu" href="#" role="button"><i class="fas fa-bars"></i></a>
    </li>
    <li class="nav-item d-none d-sm-inline-block">
      <a href="<%= request.getContextPath() %>/admin/dashboard" class="nav-link">Home</a>
    </li>
  </ul>

  <!-- Right navbar links -->
  <ul class="navbar-nav ml-auto">
    <!-- User Info -->
    <li class="nav-item">
      <span class="nav-link">
        <i class="fas fa-user"></i> <%= adminName %>
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
<!-- /.navbar -->
