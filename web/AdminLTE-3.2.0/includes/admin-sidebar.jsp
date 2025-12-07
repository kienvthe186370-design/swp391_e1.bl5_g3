<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entity.Employee" %>
<%
    Employee employee = (Employee) session.getAttribute("employee");
    String userRole = employee.getRole();
    String adminName = employee.getFullName();
    String adminEmail = employee.getEmail();
    
    // Xác định trang hiện tại để highlight menu (navigation tự động)
    String currentURI = request.getRequestURI();
    boolean isDashboard = currentURI.contains("index.jsp") && !currentURI.contains("customer") && !currentURI.contains("product") && !currentURI.contains("order");
    boolean isCustomerPage = currentURI.contains("customer");
    boolean isProductPage = currentURI.contains("product");
    boolean isOrderPage = currentURI.contains("order");
%>
<aside class="main-sidebar sidebar-dark-primary elevation-4">
  <a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp" class="brand-link">
    <img src="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/img/AdminLTELogo.png" alt="AdminLTE Logo" class="brand-image img-circle elevation-3" style="opacity: .8">
    <span class="brand-text font-weight-light">Pickleball Admin</span>
  </a>
  <div class="sidebar">
    <div class="user-panel mt-3 pb-3 mb-3 d-flex">
      <div class="image">
        <img src="<%= request.getContextPath() %>/AdminLTE-3.2.0/dist/img/user2-160x160.jpg" class="img-circle elevation-2" alt="User Image">
      </div>
      <div class="info">
        <a href="#" class="d-block"><%= adminName %></a>
        <small class="text-muted"><%= adminEmail %></small>
      </div>
    </div>
    <nav class="mt-2">
      <ul class="nav nav-pills nav-sidebar flex-column" data-widget="treeview" role="menu" data-accordion="false">
        <!-- Dashboard -->
        <li class="nav-item">
          <a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp" 
             class="nav-link <%= isDashboard ? "active" : "" %>">
            <i class="nav-icon fas fa-tachometer-alt"></i>
            <p>Dashboard</p>
          </a>
        </li>
        
        <!-- Quản lý User - Chỉ Admin mới thấy -->
        <% if ("Admin".equals(userRole)) { %>
        <li class="nav-item <%= isCustomerPage ? "menu-open" : "" %>">
          <a href="#" class="nav-link <%= isCustomerPage ? "active" : "" %>">
            <i class="nav-icon fas fa-users"></i>
            <p>Quản lý User <i class="fas fa-angle-left right"></i></p>
          </a>
          <ul class="nav nav-treeview">
            <li class="nav-item">
              <a href="<%= request.getContextPath() %>/admin/customers" 
                 class="nav-link <%= isCustomerPage ? "active" : "" %>">
                <i class="far fa-circle nav-icon"></i>
                <p>Khách hàng</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="<%= request.getContextPath() %>/admin/employees" class="nav-link">
                <i class="far fa-circle nav-icon"></i>
                <p>Nhân viên</p>
              </a>
            </li>
          </ul>
        </li>
        <% } %>
        
        <!-- Sản phẩm -->
        <li class="nav-item <%= isProductPage ? "menu-open" : "" %>">
          <a href="#" class="nav-link <%= isProductPage ? "active" : "" %>">
            <i class="nav-icon fas fa-cube"></i>
            <p>Sản phẩm <i class="fas fa-angle-left right"></i></p>
          </a>
          <ul class="nav nav-treeview">
            <li class="nav-item">
              <a href="<%= request.getContextPath() %>/admin/products" class="nav-link">
                <i class="far fa-circle nav-icon"></i>
                <p>Danh sách</p>
              </a>
            </li>
          </ul>
        </li>
        
        <!-- Đơn hàng - DÙNG CHUNG cho nhiều role -->
        <li class="nav-item">
          <a href="<%= request.getContextPath() %>/admin/orders" 
             class="nav-link <%= isOrderPage ? "active" : "" %>">
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
  </div>
</aside>

