<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entity.Employee" %>
<%@ page import="utils.RolePermission" %>
<%
    // ... (Giữ nguyên phần import và check session ở đầu như file cũ) ...
    Employee employee = (Employee) session.getAttribute("employee");
    if (employee == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String userRole = employee.getRole();
    if (userRole == null || userRole.trim().isEmpty()) userRole = "Staff";
    
    String adminName = employee.getFullName();
    String adminEmail = employee.getEmail();
    String roleDisplayName = RolePermission.getRoleDisplayName(userRole);
    boolean isAdmin = "Admin".equalsIgnoreCase(userRole);
    
    String currentURI = request.getRequestURI();
    String contextPath = request.getContextPath();
    
    // Active Flags
    boolean isDashboard = (currentURI.contains("/admin/dashboard") || (currentURI.contains("index.jsp") && currentURI.contains("AdminLTE")));
    boolean isEmployeePage = currentURI.contains("/admin/employee");
    
    boolean isProductPage = currentURI.contains("/admin/product");
    boolean isStockPage = currentURI.contains("/admin/stock");
    boolean isStockRequestPage = currentURI.contains("/admin/stock-request");
    
    boolean isCategoryPage = currentURI.contains("/admin/categories");
    boolean isBrandPage = currentURI.contains("/admin/brands");
    boolean isAttributePage = currentURI.contains("/admin/attributes");
    
    boolean isProductManagement = isProductPage || isStockPage;
    boolean isCatalogManagement = isCategoryPage || isBrandPage || isAttributePage;
    
    // Permission Flags for OTHER roles (Seller/Manager/Marketer)
    boolean canAccessCustomerManagement = RolePermission.canManageCustomers(userRole);
    boolean canAccessOrders = RolePermission.canManageOrders(userRole);
    boolean canAccessReports = RolePermission.canViewSalesReports(userRole);
    boolean canAccessRFQ = RolePermission.canManageRFQ(userRole);
    boolean canAccessMarketing = RolePermission.canManageMarketing(userRole);
    boolean canAccessVouchers = RolePermission.canManageVouchers(userRole);
    boolean isShipper = RolePermission.isShipper(userRole);
    boolean isSeller = RolePermission.isSeller(userRole);
    boolean canAssignOrders = RolePermission.canAssignOrders(userRole);
    
    // Counters
    int unassignedOrderCount = 0;
    if (canAssignOrders) {
        try {
            DAO.OrderDAO orderDAO = new DAO.OrderDAO();
            unassignedOrderCount = orderDAO.countUnassignedOrders();
        } catch (Exception e) {}
    }
    
    int totalRFQNeedAction = 0;
    if (canAccessRFQ) {
        try {
            DAO.RFQDAONew rfqDAO = new DAO.RFQDAONew();
            if (isSeller) {
                int[] stats = rfqDAO.getRFQStatistics(employee.getEmployeeID());
                totalRFQNeedAction = stats[1] + stats[2];
            } else {
                int[] stats = rfqDAO.getRFQStatistics(null);
                totalRFQNeedAction = stats[0] + stats[1] + stats[2];
            }
        } catch (Exception e) {}
    }
    
    boolean canAccessStockRequests = RolePermission.canManageStockRequests(userRole);
    int pendingStockRequestCount = 0;
    if (canAccessStockRequests) {
        try {
            DAO.StockRequestDAO stockRequestDAO = new DAO.StockRequestDAO();
            if (isAdmin) {
                pendingStockRequestCount = stockRequestDAO.countPendingRequests();
            }
        } catch (Exception e) {}
    }

    if (session.getAttribute("accessDeniedMessage") != null) {
        session.removeAttribute("accessDeniedMessage");
    }
%>

<aside class="main-sidebar sidebar-dark-primary elevation-4">
    <a href="<%= contextPath %>/admin/dashboard" class="brand-link">
        <img src="<%= contextPath %>/AdminLTE-3.2.0/dist/img/AdminLTELogo.png" alt="AdminLTE Logo" class="brand-image img-circle elevation-3" style="opacity: .8">
        <span class="brand-text font-weight-light">Pickleball Admin</span>
    </a>

    <div class="sidebar">
        <div class="user-panel mt-3 pb-3 mb-3 d-flex">
            <div class="image">
                <img src="<%= contextPath %>/AdminLTE-3.2.0/dist/img/user2-160x160.jpg" class="img-circle elevation-2" alt="User Image">
            </div>
            <div class="info">
                <a href="#" class="d-block"><%= adminName %></a>
                <small class="text-muted d-block"><%= adminEmail %></small>
                <span class="badge badge-info"><%= roleDisplayName %></span>
            </div>
        </div>

        <nav class="mt-2">
            <ul class="nav nav-pills nav-sidebar flex-column" data-widget="treeview" role="menu" data-accordion="false">

                <li class="nav-item">
                    <a href="<%= contextPath %>/admin/dashboard" class="nav-link <%= isDashboard ? "active" : "" %>">
                        <i class="nav-icon fas fa-tachometer-alt"></i>
                        <p>Dashboard</p>
                    </a>
                </li>

                <% if (isAdmin) { %>
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
                            <a href="<%= contextPath %>/admin/employees" class="nav-link <%= isEmployeePage ? "active" : "" %>">
                                <i class="far fa-circle nav-icon"></i>
                                <p>Nhân viên</p>
                            </a>
                        </li>
                    </ul>
                </li>

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
                            <a href="<%= contextPath %>/admin/products" class="nav-link <%= isProductPage ? "active" : "" %>">
                                <i class="far fa-circle nav-icon"></i>
                                <p>Sản phẩm</p>
                            </a>
                        </li>
                        <li class="nav-item">
                            <a href="<%= contextPath %>/admin/stock" class="nav-link <%= isStockPage ? "active" : "" %>">
                                <i class="far fa-circle nav-icon"></i>
                                <p>Quản lý tồn kho</p>
                            </a>
                        </li>
                    </ul>
                </li>

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
                            <a href="<%= contextPath %>/admin/categories" class="nav-link <%= isCategoryPage ? "active" : "" %>">
                                <i class="far fa-circle nav-icon"></i>
                                <p>Danh mục</p>
                            </a>
                        </li>
                        <li class="nav-item">
                            <a href="<%= contextPath %>/admin/brands" class="nav-link <%= isBrandPage ? "active" : "" %>">
                                <i class="far fa-circle nav-icon"></i>
                                <p>Thương hiệu</p>
                            </a>
                        </li>
                        <li class="nav-item">
                            <a href="<%= contextPath %>/admin/attributes" class="nav-link <%= isAttributePage ? "active" : "" %>">
                                <i class="far fa-circle nav-icon"></i>
                                <p>Thuộc tính</p>
                            </a>
                        </li>
                    </ul>
                </li>

                <li class="nav-item">
                    <a href="<%= contextPath %>/admin/stock-requests" class="nav-link <%= isStockRequestPage ? "active" : "" %>">
                        <i class="nav-icon fas fa-boxes"></i>
                        <p>
                            Yêu cầu nhập hàng
                            <% if (pendingStockRequestCount > 0) { %>
                            <span class="badge badge-warning right"><%= pendingStockRequestCount %></span>
                            <% } %>
                        </p>
                    </a>
                </li>

                <li class="nav-item">
                    <a href="<%= contextPath %>/admin/settings" class="nav-link <%= currentURI.contains("/admin/settings") ? "active" : "" %>">
                        <i class="nav-icon fas fa-cog"></i>
                        <p>Cài đặt</p>
                    </a>
                </li>

                <% } else { %>
                <%-- CHÚ Ý: ĐỂ TIẾT KIỆM DÒNG, TÔI ĐÃ RÚT GỌN PHẦN NÀY VÌ NÓ KHÔNG ĐỔI. 
                     BẠN HÃY COPY NGUYÊN KHỐI <% } else { %> TỪ BẢN CODE TRƯỚC VÀO ĐÂY --%>

                <%-- Dưới đây là ví dụ Seller Manager để đảm bảo tính liên tục --%>
                <% if (canAccessCustomerManagement) { %>
                <li class="nav-item">
                    <a href="<%= contextPath %>/seller-manager/customers" class="nav-link">
                        <i class="nav-icon fas fa-users"></i>
                        <p>Quản lý khách hàng</p>
                    </a>
                </li>
                <% } %>

                <% if (canAccessOrders) { %>
                <li class="nav-item menu-is-opening menu-open">
                    <a href="#" class="nav-link">
                        <i class="nav-icon fas fa-shopping-cart"></i>
                        <p>Quản lý đơn hàng <i class="right fas fa-angle-left"></i></p>
                    </a>
                    <ul class="nav nav-treeview">
                        <li class="nav-item">
                            <a href="<%= contextPath %>/admin/orders" class="nav-link"><i class="far fa-circle nav-icon"></i><p>Danh sách đơn hàng</p></a>
                        </li>
                        <% if (canAssignOrders) { %>
                        <li class="nav-item">
                            <a href="<%= contextPath %>/admin/orders?action=assignment" class="nav-link"><i class="far fa-circle nav-icon"></i><p>Giám sát Seller</p></a>
                        </li>
                        <li class="nav-item">
                            <a href="<%= contextPath %>/admin/orders?action=shipperAssignment" class="nav-link"><i class="far fa-circle nav-icon"></i><p>Giám sát Shipper</p></a>
                        </li>
                        <% } %>
                        <li class="nav-item">
                            <a href="<%= contextPath %>/admin/refunds" class="nav-link"><i class="far fa-circle nav-icon"></i><p>Hoàn tiền</p></a>
                        </li>
                    </ul>
                </li>
                <% } %>

                <% if (canAccessRFQ && isSeller) { %>
                <li class="nav-item"><a href="<%= contextPath %>/admin/rfq" class="nav-link"><i class="nav-icon fas fa-file-invoice"></i><p>RFQ</p></a></li>
                <li class="nav-item"><a href="<%= contextPath %>/admin/quotations" class="nav-link"><i class="nav-icon fas fa-file-invoice-dollar"></i><p>Đơn Báo Giá</p></a></li>
                <li class="nav-item"><a href="<%= contextPath %>/admin/stock-requests" class="nav-link"><i class="nav-icon fas fa-boxes"></i><p>Yêu cầu nhập hàng</p></a></li>
                            <% } %>

                <% if (canAccessMarketing) { %>
                <li class="nav-item">
                    <a href="#" class="nav-link"><i class="nav-icon fas fa-bullhorn"></i><p>Marketing <i class="fas fa-angle-left right"></i></p></a>
                    <ul class="nav nav-treeview">
                        <li class="nav-item"><a href="<%= contextPath %>/admin/slider" class="nav-link"><i class="far fa-circle nav-icon"></i><p>Sliders</p></a></li>
                        <li class="nav-item"><a href="<%= contextPath %>/admin/blog" class="nav-link"><i class="far fa-circle nav-icon"></i><p>Blog</p></a></li>
                        <li class="nav-item"><a href="<%= contextPath %>/admin/discount" class="nav-link"><i class="far fa-circle nav-icon"></i><p>Promotion</p></a></li>
                    </ul>
                </li>
                <li class="nav-item"><a href="<%= contextPath %>/feedbacks" class="nav-link"><i class="nav-icon fas fa-comments"></i><p>Quản lý đánh giá</p></a></li>
                            <% } %>

                <% if (canAccessVouchers) { %>
                <li class="nav-item"><a href="<%= contextPath %>/admin/voucher" class="nav-link"><i class="nav-icon fas fa-ticket-alt"></i><p>Voucher</p></a></li>
                            <% } %>

                <% if (canAccessReports) { %>
                <li class="nav-item"><a href="<%= contextPath %>/admin/reports" class="nav-link"><i class="nav-icon fas fa-chart-bar"></i><p>Báo cáo doanh số</p></a></li>
                            <% } %>

                <%-- SHIPPER MENU --%>
                <% if (isShipper) { %>
                <li class="nav-item">
                    <a href="<%= contextPath %>/admin/orders?action=shipperOrders" class="nav-link">
                        <i class="nav-icon fas fa-truck"></i>
                        <p>Đơn hàng giao</p>
                    </a>
                </li>
                <% } %>
                <% } %>  <%-- Đóng else (không phải Admin) --%>
            </ul>
        </nav>
    </div>
</aside>
