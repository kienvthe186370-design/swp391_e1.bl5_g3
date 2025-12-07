<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String contextPath = request.getContextPath();
%>
  <footer class="main-footer">
    <strong>Copyright &copy; 2025 <a href="#">Pickleball Shop</a>.</strong>
    All rights reserved.
    <div class="float-right d-none d-sm-inline-block">
      <b>Version</b> 1.0.0
    </div>
  </footer>
</div>

<!-- Scripts CHUNG - Tất cả trang admin dùng chung -->
<script src="<%= contextPath %>/AdminLTE-3.2.0/plugins/jquery/jquery.min.js"></script>
<script src="<%= contextPath %>/AdminLTE-3.2.0/plugins/jquery-ui/jquery-ui.min.js"></script>
<script>$.widget.bridge('uibutton', $.ui.button)</script>
<script src="<%= contextPath %>/AdminLTE-3.2.0/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="<%= contextPath %>/AdminLTE-3.2.0/plugins/chart.js/Chart.min.js"></script>
<script src="<%= contextPath %>/AdminLTE-3.2.0/plugins/sparklines/sparkline.js"></script>
<script src="<%= contextPath %>/AdminLTE-3.2.0/plugins/jqvmap/jquery.vmap.min.js"></script>
<script src="<%= contextPath %>/AdminLTE-3.2.0/plugins/jqvmap/maps/jquery.vmap.usa.js"></script>
<script src="<%= contextPath %>/AdminLTE-3.2.0/plugins/jquery-knob/jquery.knob.min.js"></script>
<script src="<%= contextPath %>/AdminLTE-3.2.0/plugins/moment/moment.min.js"></script>
<script src="<%= contextPath %>/AdminLTE-3.2.0/plugins/daterangepicker/daterangepicker.js"></script>
<script src="<%= contextPath %>/AdminLTE-3.2.0/plugins/tempusdominus-bootstrap-4/js/tempusdominus-bootstrap-4.min.js"></script>
<script src="<%= contextPath %>/AdminLTE-3.2.0/plugins/summernote/summernote-bs4.min.js"></script>
<script src="<%= contextPath %>/AdminLTE-3.2.0/plugins/overlayScrollbars/js/jquery.overlayScrollbars.min.js"></script>
<script src="<%= contextPath %>/AdminLTE-3.2.0/dist/js/adminlte.js"></script>
</body>
</html>

