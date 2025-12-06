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
