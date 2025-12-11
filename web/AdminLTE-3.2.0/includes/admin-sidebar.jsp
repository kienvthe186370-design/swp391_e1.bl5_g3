<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entity.Employee" %>
<%
    // ===== ROLE DETECTION AND NULL SAFETY =====
    Employee employee = (Employee) session.getAttribute("employee");
    
    // Null safety check - redirect to login if no employee in session
    if (employee == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    // Get user role with default fallback to "Staff" (most restrictive)
    String userRole = employee.getRole();
    if (userRole == null || userRole.trim().isEmpty()) {
        userRole = "Staff";
    }
    
    String adminName = employee.getFullName();
    String adminEmail = employee.getEmail();
    
    // ===== ACTIVE PAGE DETECTION =====
    // Xác định trang hiện tại để highlight menu (navigation tự động)
    String currentURI = request.getRequestURI();
    String contextPath = request.getContextPath();
    
    // Dashboard detection
    boolean isDashboard = (currentURI.contains("/admin/dashboard") || 
                          (currentURI.contains("index.jsp") && currentURI.contains("AdminLTE")));
    
    // User Management pages
    boolean isCustomerPage = currentURI.contains("/admin/customer");
    boolean isEmployeePage = currentURI.contains("/admin/employee");
    
    // Product Management pages
    boolean isProductPage = currentURI.contains("/admin/product");
    boolean isStockPage = currentURI.contains("/admin/stock");
    boolean isCategoryPage = currentURI.contains("/admin/categories");
    boolean isBrandPage = currentURI.contains("/admin/brands");
    boolean isAttributePage = currentURI.contains("/admin/attributes");
    
    // Marketing pages
    boolean isSliderPage = currentURI.contains("/admin/slider");
    
    // Order pages
    boolean isOrderPage = currentURI.contains("/admin/order");
    
    // Parent menu detection (for expanding submenus)
    boolean isUserManagement = isCustomerPage || isEmployeePage;
    boolean isProductManagement = isProductPage || isStockPage; // Products and Stock pages
    boolean isCatalogManagement = isCategoryPage || isBrandPage || isAttributePage; // Categories, Brands, Attributes
    boolean isMarketing = isSliderPage;
    
    // ===== ROLE-BASED ACCESS CONTROL FLAGS =====
    // Determine which menu sections are visible based on user role
    boolean canAccessUserManagement = "Admin".equals(userRole);
    boolean canAccessProductManagement = "Admin".equals(userRole) || "Marketer".equals(userRole);
    boolean canAccessCatalogManagement = "Admin".equals(userRole) || "Marketer".equals(userRole);
    boolean canAccessMarketing = "Admin".equals(userRole) || "Marketer".equals(userRole);
    boolean canAccessOrders = !"Staff".equals(userRole); // All roles except Staff
    boolean canAccessVouchers = "Admin".equals(userRole) || "Marketer".equals(userRole);
    boolean canAccessReports = "Admin".equals(userRole);
    boolean canAccessSettings = "Admin".equals(userRole);
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
        <!-- Dashboard - Visible to all roles -->
        <li class="nav-item">
          <a href="<%= contextPath %>/admin/dashboard" 
             class="nav-link <%= isDashboard ? "active" : "" %>">
            <i class="nav-icon fas fa-tachometer-alt"></i>
            <p>Dashboard</p>
          </a>
        </li>
        
        <!-- User Management - Admin only -->
        <% if (canAccessUserManagement) { %>
        <li class="nav-item <%= isUserManagement ? "menu-open" : "" %>">
          <a href="#" class="nav-link <%= isUserManagement ? "active" : "" %>">
            <i class="nav-icon fas fa-users"></i>
            <p>
              Quản lý User
              <i class="fas fa-angle-left right"></i>
            </p>
          </a>
          <ul class="nav nav-treeview">
            <li class="nav-item">
              <a href="<%= contextPath %>/admin/customers" 
                 class="nav-link <%= isCustomerPage ? "active" : "" %>">
                <i class="far fa-circle nav-icon"></i>
                <p>Khách hàng</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="<%= contextPath %>/admin/employees" 
                 class="nav-link <%= isEmployeePage ? "active" : "" %>">
                <i class="far fa-circle nav-icon"></i>
                <p>Nhân viên</p>
              </a>
            </li>
          </ul>
        </li>
        <% } %>
        
        <!-- Product Management - Admin and Marketer -->
        <% if (canAccessProductManagement) { %>
        <li class="nav-item <%= isProductManagement ? "menu-open" : "" %>">
          <a href="#" class="nav-link <%= isProductManagement ? "active" : "" %>">
            <i class="nav-icon fas fa-cube"></i>
            <p>
              Quản lý Sản phẩm
              <i class="fas fa-angle-left right"></i>
            </p>
          </a>
          <ul class="nav nav-treeview">
            <li class="nav-item">
              <a href="<%= contextPath %>/admin/products" 
                 class="nav-link <%= isProductPage ? "active" : "" %>">
                <i class="far fa-circle nav-icon"></i>
                <p>Sản phẩm</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="<%= contextPath %>/admin/stock" 
                 class="nav-link <%= isStockPage ? "active" : "" %>">
                <i class="far fa-circle nav-icon"></i>
                <p>Quản lý tồn kho</p>
              </a>
            </li>
          </ul>
        </li>
        <% } %>
        
        <!-- Catalog Management - Admin and Marketer -->
        <% if (canAccessCatalogManagement) { %>
        <li class="nav-item <%= isCatalogManagement ? "menu-open" : "" %>">
          <a href="#" class="nav-link <%= isCatalogManagement ? "active" : "" %>">
            <i class="nav-icon fas fa-tags"></i>
            <p>
              Quản lý Danh mục
              <i class="fas fa-angle-left right"></i>
            </p>
          </a>
          <ul class="nav nav-treeview">
            <li class="nav-item">
              <a href="<%= contextPath %>/admin/categories" 
                 class="nav-link <%= isCategoryPage ? "active" : "" %>">
                <i class="far fa-circle nav-icon"></i>
                <p>Danh mục</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="<%= contextPath %>/admin/brands" 
                 class="nav-link <%= isBrandPage ? "active" : "" %>">
                <i class="far fa-circle nav-icon"></i>
                <p>Thương hiệu</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="<%= contextPath %>/admin/attributes" 
                 class="nav-link <%= isAttributePage ? "active" : "" %>">
                <i class="far fa-circle nav-icon"></i>
                <p>Thuộc tính</p>
              </a>
            </li>
          </ul>
        </li>
        <% } %>
        
        <!-- Marketing - Admin and Marketer -->
        <% if (canAccessMarketing) { %>
        <li class="nav-item <%= isMarketing ? "menu-open" : "" %>">
          <a href="#" class="nav-link <%= isMarketing ? "active" : "" %>">
            <i class="nav-icon fas fa-bullhorn"></i>
            <p>
              Marketing
              <i class="fas fa-angle-left right"></i>
            </p>
          </a>
          <ul class="nav nav-treeview">
            <li class="nav-item">
              <a href="<%= contextPath %>/admin/slider" 
                 class="nav-link <%= isSliderPage ? "active" : "" %>">
                <i class="far fa-circle nav-icon"></i>
                <p>Sliders</p>
              </a>
            </li>
          </ul>
        </li>
        <% } %>
        
        <!-- Orders - All roles except Staff -->
        <% if (canAccessOrders) { %>
        <li class="nav-item">
          <a href="<%= contextPath %>/admin/orders" 
             class="nav-link <%= isOrderPage ? "active" : "" %>">
            <i class="nav-icon fas fa-shopping-cart"></i>
            <p>Đơn hàng</p>
          </a>
        </li>
        <% } %>
        
        <!-- Vouchers - Placeholder (Admin, Marketer) -->
        <% if (canAccessVouchers) { %>
        <li class="nav-item">
          <a href="#" class="nav-link">
            <i class="nav-icon fas fa-ticket-alt"></i>
            <p>Voucher</p>
          </a>
        </li>
        <% } %>
        
        <!-- Reports - Placeholder (Admin only) -->
        <% if (canAccessReports) { %>
        <li class="nav-item">
          <a href="#" class="nav-link">
            <i class="nav-icon fas fa-chart-bar"></i>
            <p>Báo cáo</p>
          </a>
        </li>
        <% } %>
        
        <!-- Settings - Placeholder (Admin only) -->
        <% if (canAccessSettings) { %>
        <li class="nav-item">
          <a href="#" class="nav-link">
            <i class="nav-icon fas fa-cog"></i>
            <p>Cài đặt</p>
          </a>
        </li>
        <% } %>
      </ul>
    </nav>
  </div>
</aside>

