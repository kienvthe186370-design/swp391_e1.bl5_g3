<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entity.Employee" %>
<%@ page import="utils.RolePermission" %>
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
    String roleDisplayName = RolePermission.getRoleDisplayName(userRole);
    
    // ===== CHECK IF ADMIN - Admin giữ nguyên menu cũ =====
    boolean isAdmin = "Admin".equalsIgnoreCase(userRole);
    
    // ===== ACTIVE PAGE DETECTION =====
    String currentURI = request.getRequestURI();
    String contextPath = request.getContextPath();
    
    // Dashboard detection
    boolean isDashboard = (currentURI.contains("/admin/dashboard") || 
                          (currentURI.contains("index.jsp") && currentURI.contains("AdminLTE")));
    
    // User Management pages
    boolean isCustomerPage = currentURI.contains("/admin/customer");
    boolean isEmployeePage = currentURI.contains("/admin/employee");
    boolean isSMCustomerPage = currentURI.contains("/seller-manager/customer");
    isCustomerPage = isCustomerPage || isSMCustomerPage;
    
    // Product Management pages
    boolean isProductPage = currentURI.contains("/admin/product");
    boolean isStockPage = currentURI.contains("/admin/stock");
    boolean isCategoryPage = currentURI.contains("/admin/categories");
    boolean isBrandPage = currentURI.contains("/admin/brands");
    boolean isAttributePage = currentURI.contains("/admin/attributes");
    
    // Marketing pages
    boolean isSliderPage = currentURI.contains("/admin/slider");
    boolean isBlogPage = currentURI.contains("/admin/blog");
    boolean isPromotionPage = currentURI.contains("/admin/discount");
    
    // Order pages
    boolean isOrderPage = currentURI.contains("/admin/order");
    
    // RFQ pages
    boolean isRFQPage = currentURI.contains("/admin/rfq");
    
    // Other pages
    boolean isReportsPage = currentURI.contains("/admin/reports");
    boolean isVoucherPage = currentURI.contains("/admin/voucher");
    boolean isSettingsPage = currentURI.contains("/admin/settings");
    
    // Parent menu detection (for expanding submenus)
    boolean isUserManagement = isCustomerPage || isEmployeePage;
    boolean isProductManagement = isProductPage || isStockPage; // Products and Stock pages
    boolean isCatalogManagement = isCategoryPage || isBrandPage || isAttributePage; // Categories, Brands, Attributes
    boolean isMarketing = isSliderPage || isVoucherPage;
    
    
    // ===== ROLE-BASED ACCESS CONTROL FLAGS =====
    // Admin: giữ nguyên tất cả menu như cũ (code của bạn bạn)
    // Các role khác: phân quyền theo yêu cầu mới
    
    // SellerManager permissions
    boolean canAccessCustomerManagement = RolePermission.canManageCustomers(userRole);
    boolean canViewCustomers = RolePermission.canViewCustomers(userRole);
    boolean canAccessOrders = RolePermission.canManageOrders(userRole);
    boolean canAccessReports = RolePermission.canViewSalesReports(userRole);
    boolean canAccessRFQ = RolePermission.canManageRFQ(userRole);
    
    // Marketer permissions
    boolean canAccessProductManagement = RolePermission.canManageProducts(userRole);
    boolean canAccessCatalogManagement = RolePermission.canManageCatalog(userRole);
    boolean canAccessMarketing = RolePermission.canManageMarketing(userRole);
    boolean canAccessVouchers = RolePermission.canManageVouchers(userRole);
    
    // Shipper permissions
    boolean isShipper = RolePermission.isShipper(userRole);
    boolean canViewShipperOrders = RolePermission.canViewShipperOrders(userRole);
    
    // Order assignment permissions (for SellerManager)
    boolean canAssignOrders = RolePermission.canAssignOrders(userRole);
    int unassignedOrderCount = 0;
    if (canAssignOrders) {
        try {
            DAO.OrderDAO orderDAO = new DAO.OrderDAO();
            unassignedOrderCount = orderDAO.countUnassignedOrders();
        } catch (Exception e) {
            // Ignore - OrderDAO may not have this method yet
        }
    }
    
    // Check for access denied message
    String accessDeniedMsg = (String) session.getAttribute("accessDeniedMessage");
    if (accessDeniedMsg != null) {
        session.removeAttribute("accessDeniedMessage");
    }
%>
<aside class="main-sidebar sidebar-dark-primary elevation-4">
  <a href="<%= request.getContextPath() %>/admin/dashboard" class="brand-link">
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
        <small class="text-muted d-block"><%= adminEmail %></small>
        <span class="badge badge-info"><%= roleDisplayName %></span>
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
        
<% if (isAdmin) { %>
        <!-- ==================== ADMIN - GIỮ NGUYÊN MENU CŨ ==================== -->
        
        <!-- User Management - Admin only -->
        <li class="nav-item <%= isEmployeePage ? "menu-open" : "" %>">
          <a href="#" class="nav-link <%= isEmployeePage ? "active" : "" %>">
            <i class="nav-icon fas fa-users"></i>
            <p>
              Quản lý User
              <i class="fas fa-angle-left right"></i>
            </p>
          </a>
          <ul class="nav nav-treeview">
            <li class="nav-item">
              <a href="<%= contextPath %>/admin/employees" 
                 class="nav-link <%= isEmployeePage ? "active" : "" %>">
                <i class="far fa-circle nav-icon"></i>
                <p>Nhân viên</p>
              </a>
            </li>
          </ul>
        </li>
        
        <!-- Product Management - Admin -->
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
        
        <!-- Catalog Management - Admin -->
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
        
        <!-- Marketing - Admin -->
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
          <ul class="nav nav-treeview">
            <li class="nav-item">
              <a href="<%= contextPath %>/admin/blog" 
                 class="nav-link <%= isBlogPage ? "active" : "" %>">
                <i class="far fa-circle nav-icon"></i>
                <p>Blog</p>
              </a>
            </li>
          </ul>
          <ul class="nav nav-treeview">
            <li class="nav-item">
              <a href="<%= contextPath %>/admin/discount" 
                 class="nav-link <%= isPromotionPage ? "active" : "" %>">
                <i class="far fa-circle nav-icon"></i>
                <p>Promotion</p>
              </a>
            </li>
          </ul>
        </li>
        
        <!-- Orders - Admin (chỉ xem, không xử lý) -->
        <li class="nav-item">
          <a href="<%= contextPath %>/admin/orders" 
             class="nav-link <%= isOrderPage ? "active" : "" %>">
            <i class="nav-icon fas fa-shopping-cart"></i>
            <p>Đơn hàng</p>
          </a>
        </li>
        
        <!-- Admin không xử lý Refund - Refund do Seller/SellerManager xử lý -->
        
        <!-- Vouchers - Admin -->
        <li class="nav-item">
          <a href="<%= contextPath %>/admin/voucher" 
             class="nav-link <%= isVoucherPage ? "active" : "" %>">
            <i class="nav-icon fas fa-ticket-alt"></i>
            <p>Voucher</p>
          </a>
        </li>
        
        <!-- Reports - Admin -->
        <li class="nav-item">
          <a href="<%= contextPath %>/admin/reports" 
             class="nav-link <%= isReportsPage ? "active" : "" %>">
            <i class="nav-icon fas fa-chart-bar"></i>
            <p>Báo cáo</p>
          </a>
        </li>
        
        <!-- Quản lý đánh giá - Admin -->
        <li class="nav-item">
          <a href="<%= contextPath %>/feedbacks" 
             class="nav-link <%= currentURI.contains("/feedbacks") ? "active" : "" %>">
            <i class="nav-icon fas fa-comments"></i>
            <p>Quản lý đánh giá</p>
          </a>
        </li>
        
        <!-- Settings - Admin -->
        <li class="nav-item">
          <a href="<%= contextPath %>/admin/settings" 
             class="nav-link <%= isSettingsPage ? "active" : "" %>">
            <i class="nav-icon fas fa-cog"></i>
            <p>Cài đặt</p>
          </a>
        </li>
        
<% } else { %>
        <!-- ==================== OTHER ROLES - PHÂN QUYỀN MỚI ==================== -->
        
        <!-- ===== SELLER MANAGER SECTION ===== -->
        <!-- Quản lý Khách hàng - SellerManager (CRUD) hoặc Seller (View only) -->
        <% if (canViewCustomers) { %>
        <li class="nav-item">
          <a href="<%= contextPath %>/seller-manager/customers" 
             class="nav-link <%= isSMCustomerPage ? "active" : "" %>">
            <i class="nav-icon fas fa-users"></i>
            <p>Quản lý khách hàng<% if (!canAccessCustomerManagement) { %> <small>(Xem)</small><% } %></p>
          </a>
        </li>
        <% } %>
        
        <!-- Quản lý Đơn hàng - SellerManager và Seller -->
        <% if (canAccessOrders) { %>
        <li class="nav-item menu-is-opening menu-open">
          <a href="#" class="nav-link">
            <i class="nav-icon fas fa-shopping-cart"></i>
            <p>
              Quản lý đơn hàng
              <i class="right fas fa-angle-left"></i>
              <% if (unassignedOrderCount > 0 && canAssignOrders) { %>
                <span class="badge badge-warning right"><%= unassignedOrderCount %></span>
              <% } %>
            </p>
          </a>
          <ul class="nav nav-treeview" style="display: block;">
            <li class="nav-item">
              <a href="<%= contextPath %>/admin/orders" class="nav-link">
                <i class="far fa-circle nav-icon"></i>
                <p>Danh sách đơn hàng</p>
              </a>
            </li>
            <% if (canAssignOrders) { %>
            <li class="nav-item">
              <a href="<%= contextPath %>/admin/orders?action=assignment" class="nav-link">
                <i class="far fa-circle nav-icon"></i>
                <p>Giám sát Seller
                  <% if (unassignedOrderCount > 0) { %>
                    <span class="badge badge-warning right"><%= unassignedOrderCount %></span>
                  <% } %>
                </p>
              </a>
            </li>
            <li class="nav-item">
              <a href="<%= contextPath %>/admin/orders?action=shipperAssignment" class="nav-link">
                <i class="far fa-circle nav-icon"></i>
                <p>Giám sát Shipper</p>
              </a>
            </li>
            <% } %>
            <!-- Hoàn tiền - Hiển thị cho cả Seller và SellerManager -->
            <li class="nav-item">
              <a href="<%= contextPath %>/admin/refunds" class="nav-link <%= currentURI.contains("/admin/refund") ? "active" : "" %>">
                <i class="far fa-circle nav-icon"></i>
                <p><i class="fas fa-undo-alt text-warning"></i> Hoàn tiền</p>
              </a>
            </li>
          </ul>
        </li>
        <% } %>
        
        <!-- RFQ Management - Chỉ SellerManager -->
        <% if (canAccessRFQ) { %>
        <li class="nav-item">
          <a href="<%= contextPath %>/admin/rfq" 
             class="nav-link <%= isRFQPage ? "active" : "" %>">
            <i class="nav-icon fas fa-file-invoice"></i>
            <p>Yêu cầu báo giá (RFQ)</p>
          </a>
        </li>
        <% } %>
        
        <!-- Báo cáo doanh số - Chỉ SellerManager -->
        <% if (canAccessReports) { %>
        <li class="nav-item">
          <a href="<%= contextPath %>/admin/reports" 
             class="nav-link <%= isReportsPage ? "active" : "" %>">
            <i class="nav-icon fas fa-chart-bar"></i>
            <p>Báo cáo doanh số</p>
          </a>
        </li>
        <% } %>
        
        <!-- ===== MARKETER SECTION ===== -->
        <!-- Quản lý Sản phẩm - Chỉ Marketer -->
        <% if (canAccessProductManagement) { %>
        <li class="nav-item">
          <a href="<%= contextPath %>/admin/products" 
             class="nav-link <%= isProductPage ? "active" : "" %>">
            <i class="nav-icon fas fa-cube"></i>
            <p>Quản lý Sản phẩm</p>
          </a>
        </li>
        <% } %>
        
        <!-- Quản lý Danh mục - Chỉ Marketer -->
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
        
        <!-- Marketing - Chỉ Marketer -->
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
                <ul class="nav nav-treeview">
            <li class="nav-item">
              <a href="<%= contextPath %>/admin/blog" 
                 class="nav-link <%= isBlogPage ? "active" : "" %>">
                <i class="far fa-circle nav-icon"></i>
                <p>Blog</p>
              </a>
            </li>
          </ul>
                <ul class="nav nav-treeview">
            <li class="nav-item">
              <a href="<%= contextPath %>/admin/discount" 
                 class="nav-link <%= isPromotionPage ? "active" : "" %>">
                <i class="far fa-circle nav-icon"></i>
                <p>Promotion</p>
              </a>
            </li>
          </ul>
        </li>
        <% } %>
        
        <!-- Voucher - Chỉ Marketer -->
        <% if (canAccessVouchers) { %>
        <li class="nav-item">
          <a href="<%= contextPath %>/admin/voucher" 
             class="nav-link <%= isVoucherPage ? "active" : "" %>">
            <i class="nav-icon fas fa-ticket-alt"></i>
            <p>Voucher</p>
          </a>
        </li>
        <% } %>
        
        <!-- Quản lý đánh giá - Chỉ Marketer -->
        <% if (canAccessMarketing) { %>
        <li class="nav-item">
          <a href="<%= contextPath %>/feedbacks" 
             class="nav-link <%= currentURI.contains("/feedbacks") ? "active" : "" %>">
            <i class="nav-icon fas fa-comments"></i>
            <p>Quản lý đánh giá</p>
          </a>
        </li>
        <% } %>
        
        <!-- ===== SHIPPER SECTION ===== -->
        <% if (isShipper) { %>
        <li class="nav-item">
          <a href="<%= contextPath %>/admin/orders?action=shipperOrders" 
             class="nav-link <%= isOrderPage ? "active" : "" %>">
            <i class="nav-icon fas fa-motorcycle"></i>
            <p>Đơn hàng giao</p>
          </a>
        </li>
        <% } %>
        
<% } %>
        
      </ul>
    </nav>
  </div>
</aside>
