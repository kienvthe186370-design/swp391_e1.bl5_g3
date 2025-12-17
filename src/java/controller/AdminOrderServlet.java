package controller;

import DAO.OrderDAO;
import DAO.ShippingDAO;
import DAO.ShippingTrackingDAO;
import entity.*;
import utils.OrderStatusValidator;
import utils.RolePermission;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Map;

@WebServlet(name = "AdminOrderServlet", urlPatterns = {"/admin/orders"})
public class AdminOrderServlet extends HttpServlet {
    
    private OrderDAO orderDAO;
    private ShippingDAO shippingDAO;
    private ShippingTrackingDAO trackingDAO;
    
    @Override
    public void init() throws ServletException {
        orderDAO = new OrderDAO();
        shippingDAO = new ShippingDAO();
        trackingDAO = new ShippingTrackingDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        
        if (employee == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String role = employee.getRole();
        
        // Admin có full quyền, SellerManager, Seller và Shipper được truy cập
        if (!RolePermission.ADMIN.equalsIgnoreCase(role) && 
            !RolePermission.canManageOrders(role) && !RolePermission.isShipper(role)) {
            response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) {
            // Shipper mặc định vào trang đơn hàng của mình
            action = RolePermission.isShipper(role) ? "shipperOrders" : "list";
        }
        
        switch (action) {
            case "list":
                if (RolePermission.isShipper(role)) {
                    // Shipper không được xem list chung
                    listShipperOrders(request, response, employee);
                } else {
                    listOrders(request, response, employee);
                }
                break;
            case "shipperOrders":
                // Trang đơn hàng của Shipper
                if (RolePermission.isShipper(role)) {
                    listShipperOrders(request, response, employee);
                } else {
                    response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
                }
                break;
            case "shipperDetail":
                // Chi tiết đơn hàng cho Shipper
                if (RolePermission.isShipper(role)) {
                    viewShipperOrderDetail(request, response, employee);
                } else {
                    response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
                }
                break;
            case "detail":
                viewOrderDetail(request, response, employee);
                break;
            case "assignment":
                // Chỉ SellerManager mới vào được
                if (RolePermission.canAssignOrders(role)) {
                    showAssignmentPage(request, response);
                } else {
                    response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
                }
                break;
            case "shipperAssignment":
                // Phân công shipper
                if (RolePermission.canAssignShipper(role)) {
                    showShipperAssignmentPage(request, response);
                } else {
                    response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
                }
                break;
            default:
                if (RolePermission.isShipper(role)) {
                    listShipperOrders(request, response, employee);
                } else {
                    listOrders(request, response, employee);
                }
        }
    }
    
    private void listOrders(HttpServletRequest request, HttpServletResponse response, 
                           Employee employee) throws ServletException, IOException {
        
        String role = employee.getRole();
        OrderFilter filter = buildFilterFromRequest(request);
        
        // Seller chỉ thấy đơn được phân công cho mình
        Integer assignedToFilter = null;
        if ("Seller".equalsIgnoreCase(role)) {
            assignedToFilter = employee.getEmployeeID();
            filter.setAssignedTo(assignedToFilter);
        }
        
        // Tab filter theo trạng thái
        String tab = request.getParameter("tab");
        if (tab == null || tab.isEmpty()) {
            tab = "all";
        }
        
        // Áp dụng tab filter
        if ("pending".equals(tab)) {
            filter.setOrderStatus("Pending");
        } else if ("confirmed".equals(tab)) {
            filter.setOrderStatus("Confirmed");
        } else if ("processing".equals(tab)) {
            filter.setOrderStatus("Processing");
        } else if ("shipping".equals(tab)) {
            filter.setOrderStatus("Shipping");
        } else if ("delivered".equals(tab)) {
            filter.setOrderStatus("Delivered");
        } else if ("cancelled".equals(tab)) {
            filter.setOrderStatus("Cancelled");
        } else if ("unassigned".equals(tab)) {
            filter.setUnassignedOnly(true);
        }
        // "all" không filter status
        
        int page = getPageParam(request);
        int pageSize = 5; // Giảm xuống 5 đơn/trang
        
        List<Order> orders = orderDAO.getOrders(filter, page, pageSize);
        int totalOrders = orderDAO.countOrders(filter);
        int totalPages = (int) Math.ceil((double) totalOrders / pageSize);
        
        // Thống kê động theo filter (search, date) nhưng không theo tab
        OrderFilter statsFilter = buildFilterFromRequest(request);
        if (assignedToFilter != null) {
            statsFilter.setAssignedTo(assignedToFilter);
        }
        
        // Đếm theo từng trạng thái
        statsFilter.setOrderStatus("Pending");
        int pendingCount = orderDAO.countOrders(statsFilter);
        
        statsFilter.setOrderStatus("Confirmed");
        int confirmedCount = orderDAO.countOrders(statsFilter);
        
        statsFilter.setOrderStatus("Processing");
        int processingCount = orderDAO.countOrders(statsFilter);
        
        statsFilter.setOrderStatus("Shipping");
        int shippingCount = orderDAO.countOrders(statsFilter);
        
        statsFilter.setOrderStatus("Delivered");
        int deliveredCount = orderDAO.countOrders(statsFilter);
        
        statsFilter.setOrderStatus("Cancelled");
        int cancelledCount = orderDAO.countOrders(statsFilter);
        
        statsFilter.setOrderStatus(null);
        int allCount = orderDAO.countOrders(statsFilter);
        
        int unassignedCount = orderDAO.countUnassignedOrders();
        
        // Lấy danh sách seller cho modal phân công
        if (RolePermission.canAssignOrders(role)) {
            List<Object[]> sellers = orderDAO.getSellersWithActiveOrderCount();
            request.setAttribute("sellers", sellers);
        }
        
        request.setAttribute("orders", orders);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("currentTab", tab);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("confirmedCount", confirmedCount);
        request.setAttribute("processingCount", processingCount);
        request.setAttribute("shippingCount", shippingCount);
        request.setAttribute("deliveredCount", deliveredCount);
        request.setAttribute("cancelledCount", cancelledCount);
        request.setAttribute("allCount", allCount);
        request.setAttribute("unassignedCount", unassignedCount);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("userRole", role);
        request.setAttribute("filter", filter);
        
        // Set page attributes for layout
        request.setAttribute("pageTitle", "Quản lý đơn hàng");
        request.setAttribute("contentPage", "order-list");
        
        request.getRequestDispatcher("/AdminLTE-3.2.0/orders/order-list.jsp")
               .forward(request, response);
    }
    
    private void viewOrderDetail(HttpServletRequest request, HttpServletResponse response,
                                Employee employee) throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        System.out.println("[AdminOrder] viewOrderDetail - id param: " + idParam);
        
        if (idParam == null || idParam.isEmpty()) {
            request.getSession().setAttribute("error", "Thiếu ID đơn hàng");
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }
        
        try {
            int orderId = Integer.parseInt(idParam);
            
            if (orderId <= 0) {
                request.getSession().setAttribute("error", "ID đơn hàng không hợp lệ: " + orderId);
                response.sendRedirect(request.getContextPath() + "/admin/orders");
                return;
            }
            
            System.out.println("[AdminOrder] Loading order ID: " + orderId);
            Order order = orderDAO.getOrderById(orderId);
            System.out.println("[AdminOrder] Order loaded: " + (order != null ? order.getOrderCode() : "NULL"));
            
            if (order == null) {
                request.getSession().setAttribute("error", "Không tìm thấy đơn hàng");
                response.sendRedirect(request.getContextPath() + "/admin/orders");
                return;
            }
            
            String role = employee.getRole();
            
            // Seller chỉ xem được đơn được phân công cho mình
            if ("Seller".equalsIgnoreCase(role) && 
                (order.getAssignedTo() == null || order.getAssignedTo() != employee.getEmployeeID())) {
                response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
                return;
            }
            
            // Lấy available status transitions
            Map<String, String> availableStatuses = OrderStatusValidator.getAvailableTransitions(
                order.getOrderStatus(), role);
            
            // Lấy danh sách seller cho reassign
            if (RolePermission.canAssignOrders(role)) {
                List<Object[]> sellers = orderDAO.getSellersWithActiveOrderCount();
                request.setAttribute("sellers", sellers);
            }
            
            request.setAttribute("order", order);
            request.setAttribute("availableStatuses", availableStatuses);
            request.setAttribute("userRole", role);
            request.setAttribute("canUpdateStatus", RolePermission.canUpdateOrderStatus(role));
            request.setAttribute("canAssign", RolePermission.canAssignOrders(role));
            
            request.setAttribute("pageTitle", "Chi tiết đơn hàng " + order.getOrderCode());
            
            System.out.println("[AdminOrder] Forwarding to order-detail.jsp");
            request.getRequestDispatcher("/AdminLTE-3.2.0/orders/order-detail.jsp")
                   .forward(request, response);
                   
        } catch (NumberFormatException e) {
            System.err.println("[AdminOrder] NumberFormatException: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/orders");
        } catch (Exception e) {
            System.err.println("[AdminOrder] Exception in viewOrderDetail: " + e.getMessage());
            e.printStackTrace();
            request.getSession().setAttribute("error", "Lỗi khi tải chi tiết đơn hàng: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/orders");
        }
    }
    
    private void showAssignmentPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lấy đơn chưa phân công (nếu có - thường sẽ trống vì đã tự động phân công)
        List<Order> unassignedOrders = orderDAO.getUnassignedOrders();
        List<Object[]> sellers = orderDAO.getSellersWithActiveOrderCount();
        
        request.setAttribute("unassignedOrders", unassignedOrders);
        request.setAttribute("sellers", sellers);
        request.setAttribute("pageTitle", "Giám sát Seller");
        
        request.getRequestDispatcher("/AdminLTE-3.2.0/orders/order-assignment.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        
        if (employee == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getParameter("action");
        
        switch (action) {
            case "updateStatus":
                updateOrderStatus(request, response, employee);
                break;
            case "assign":
                assignOrder(request, response, employee);
                break;
            case "assignAuto":
                autoAssignOrder(request, response, employee);
                break;
            case "reassign":
                reassignOrder(request, response, employee);
                break;
            case "updateNote":
                updateInternalNote(request, response);
                break;
            case "assignShipper":
                assignShipperToOrder(request, response, employee);
                break;
            case "autoAssignShipper":
                autoAssignShipperToOrder(request, response, employee);
                break;
            case "autoAssignAllShippers":
                autoAssignAllShippers(request, response, employee);
                break;
            case "reassignShipper":
                reassignShipperToOrder(request, response, employee);
                break;
            case "updateShippingStatus":
                updateShippingStatus(request, response, employee);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/orders");
        }
    }
    
    private void updateOrderStatus(HttpServletRequest request, HttpServletResponse response,
                                  Employee employee) throws IOException {
        
        String orderIdParam = request.getParameter("orderId");
        String newStatus = request.getParameter("newStatus");
        String note = request.getParameter("note");
        
        System.out.println("[AdminOrder] updateOrderStatus - orderId: " + orderIdParam + ", newStatus: " + newStatus + ", note: " + note);
        System.out.println("[AdminOrder] Employee: " + employee.getFullName() + " (ID: " + employee.getEmployeeID() + ", Role: " + employee.getRole() + ")");
        
        if (orderIdParam == null || orderIdParam.isEmpty()) {
            request.getSession().setAttribute("error", "Thiếu ID đơn hàng");
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }
        
        if (newStatus == null || newStatus.isEmpty()) {
            request.getSession().setAttribute("error", "Vui lòng chọn trạng thái mới");
            response.sendRedirect(request.getContextPath() + "/admin/orders?action=detail&id=" + orderIdParam);
            return;
        }
        
        int orderId = 0;
        try {
            orderId = Integer.parseInt(orderIdParam);
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("error", "ID đơn hàng không hợp lệ: " + orderIdParam);
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }
        
        if (orderId <= 0) {
            request.getSession().setAttribute("error", "ID đơn hàng không hợp lệ: " + orderId);
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }
        
        try {
            Order order = orderDAO.getOrderById(orderId);
            System.out.println("[AdminOrder] Order found: " + (order != null ? order.getOrderCode() + " - Status: " + order.getOrderStatus() : "NULL"));
            
            if (order == null) {
                request.getSession().setAttribute("error", "Không tìm thấy đơn hàng ID: " + orderId);
                response.sendRedirect(request.getContextPath() + "/admin/orders");
                return;
            }
            
            // Validate transition
            String role = employee.getRole();
            boolean canTransition = OrderStatusValidator.canTransition(order.getOrderStatus(), newStatus, role, false);
            System.out.println("[AdminOrder] canTransition from '" + order.getOrderStatus() + "' to '" + newStatus + "' for role '" + role + "': " + canTransition);
            
            if (!canTransition) {
                request.getSession().setAttribute("error", "Không thể chuyển từ '" + order.getOrderStatus() + "' sang '" + newStatus + "'");
                response.sendRedirect(request.getContextPath() + "/admin/orders?action=detail&id=" + orderId);
                return;
            }
            
            System.out.println("[AdminOrder] Calling orderDAO.updateOrderStatus...");
            boolean success = orderDAO.updateOrderStatus(orderId, newStatus, employee.getEmployeeID(), note);
            System.out.println("[AdminOrder] updateOrderStatus result: " + success);
            
            if (success) {
                request.getSession().setAttribute("success", "Cập nhật trạng thái thành công: " + newStatus);
            } else {
                request.getSession().setAttribute("error", "Cập nhật trạng thái thất bại - Kiểm tra log server");
            }
            
            // Redirect về trang detail
            response.sendRedirect(request.getContextPath() + "/admin/orders?action=detail&id=" + orderId);
            
        } catch (Exception e) {
            System.err.println("[AdminOrder] Error updating status: " + e.getMessage());
            e.printStackTrace();
            request.getSession().setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/orders?action=detail&id=" + orderId);
        }
    }
    
    private void assignOrder(HttpServletRequest request, HttpServletResponse response,
                            Employee employee) throws IOException {
        
        if (!RolePermission.canAssignOrders(employee.getRole())) {
            response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
            return;
        }
        
        String orderIdParam = request.getParameter("orderId");
        String sellerIdParam = request.getParameter("sellerId");
        
        if (orderIdParam == null || sellerIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }
        
        try {
            int orderId = Integer.parseInt(orderIdParam);
            int sellerId = Integer.parseInt(sellerIdParam);
            
            boolean success = orderDAO.assignOrderToSeller(orderId, sellerId, employee.getEmployeeID());
            
            if (success) {
                request.getSession().setAttribute("success", "Phân công đơn hàng thành công");
            } else {
                request.getSession().setAttribute("error", "Phân công đơn hàng thất bại");
            }
            
            // Redirect back to where we came from
            String referer = request.getHeader("Referer");
            if (referer != null && referer.contains("assignment")) {
                response.sendRedirect(request.getContextPath() + "/admin/orders?action=assignment");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/orders?action=detail&id=" + orderId);
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/orders");
        }
    }
    
    private void autoAssignOrder(HttpServletRequest request, HttpServletResponse response,
                                Employee employee) throws IOException {
        
        if (!RolePermission.canAssignOrders(employee.getRole())) {
            response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
            return;
        }
        
        String orderIdParam = request.getParameter("orderId");
        
        if (orderIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }
        
        try {
            int orderId = Integer.parseInt(orderIdParam);
            
            // Lấy seller có ít đơn nhất
            Employee seller = orderDAO.getSellerWithLeastActiveOrders();
            
            if (seller == null) {
                request.getSession().setAttribute("error", "Không có seller nào khả dụng");
                response.sendRedirect(request.getContextPath() + "/admin/orders?action=assignment");
                return;
            }
            
            boolean success = orderDAO.assignOrderToSeller(orderId, seller.getEmployeeID(), employee.getEmployeeID());
            
            if (success) {
                request.getSession().setAttribute("success", 
                    "Đã phân công đơn hàng cho " + seller.getFullName());
            } else {
                request.getSession().setAttribute("error", "Phân công đơn hàng thất bại");
            }
            
            response.sendRedirect(request.getContextPath() + "/admin/orders?action=assignment");
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/orders");
        }
    }
    
    private void reassignOrder(HttpServletRequest request, HttpServletResponse response,
                              Employee employee) throws IOException {
        // Same as assign
        assignOrder(request, response, employee);
    }
    
    private void updateInternalNote(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        String orderIdParam = request.getParameter("orderId");
        String note = request.getParameter("note");
        
        if (orderIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }
        
        try {
            int orderId = Integer.parseInt(orderIdParam);
            orderDAO.updateInternalNote(orderId, note);
            
            request.getSession().setAttribute("success", "Cập nhật ghi chú thành công");
            response.sendRedirect(request.getContextPath() + "/admin/orders?action=detail&id=" + orderId);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/orders");
        }
    }
    
    // ==================== HELPER METHODS ====================
    
    private OrderFilter buildFilterFromRequest(HttpServletRequest request) {
        OrderFilter filter = new OrderFilter();
        
        String search = request.getParameter("search");
        if (search != null && !search.trim().isEmpty()) {
            filter.setSearchKeyword(search.trim());
        }
        
        String status = request.getParameter("status");
        if (status != null && !status.trim().isEmpty()) {
            filter.setOrderStatus(status);
        }
        
        String paymentStatus = request.getParameter("paymentStatus");
        if (paymentStatus != null && !paymentStatus.trim().isEmpty()) {
            filter.setPaymentStatus(paymentStatus);
        }
        
        String fromDateStr = request.getParameter("fromDate");
        String toDateStr = request.getParameter("toDate");
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        
        try {
            if (fromDateStr != null && !fromDateStr.isEmpty()) {
                filter.setFromDate(sdf.parse(fromDateStr));
            }
            if (toDateStr != null && !toDateStr.isEmpty()) {
                filter.setToDate(sdf.parse(toDateStr));
            }
        } catch (ParseException e) {
            // Ignore invalid dates
        }
        
        String sortBy = request.getParameter("sortBy");
        if (sortBy != null && !sortBy.isEmpty()) {
            filter.setSortBy(sortBy);
        }
        
        String sortOrder = request.getParameter("sortOrder");
        if (sortOrder != null && !sortOrder.isEmpty()) {
            filter.setSortOrder(sortOrder);
        }
        
        return filter;
    }
    
    private int getPageParam(HttpServletRequest request) {
        String pageStr = request.getParameter("page");
        if (pageStr != null) {
            try {
                int page = Integer.parseInt(pageStr);
                return page > 0 ? page : 1;
            } catch (NumberFormatException e) {
                return 1;
            }
        }
        return 1;
    }
    
    private int getPageSizeParam(HttpServletRequest request) {
        String sizeStr = request.getParameter("pageSize");
        if (sizeStr != null) {
            try {
                int size = Integer.parseInt(sizeStr);
                return (size > 0 && size <= 100) ? size : 10;
            } catch (NumberFormatException e) {
                return 10;
            }
        }
        return 10;
    }
    
    // ==================== SHIPPER ASSIGNMENT ====================
    
    /**
     * Hiển thị trang giám sát shipper
     */
    private void showShipperAssignmentPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lấy đơn đã phân shipper (đang vận chuyển)
        List<Shipping> assignedShippings = shippingDAO.getAssignedShippings();
        
        // Lấy danh sách shipper với số đơn đang giao
        List<Object[]> shippers = orderDAO.getShippersWithActiveOrderCount();
        
        request.setAttribute("assignedShippings", assignedShippings);
        request.setAttribute("shippers", shippers);
        request.setAttribute("pageTitle", "Giám sát Shipper");
        
        request.getRequestDispatcher("/AdminLTE-3.2.0/orders/shipper-assignment.jsp")
               .forward(request, response);
    }
    
    /**
     * Phân công shipper cho đơn hàng
     */
    private void assignShipperToOrder(HttpServletRequest request, HttpServletResponse response,
                                     Employee employee) throws IOException {
        
        if (!RolePermission.canAssignShipper(employee.getRole())) {
            response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
            return;
        }
        
        String shippingIdParam = request.getParameter("shippingId");
        String shipperIdParam = request.getParameter("shipperId");
        
        if (shippingIdParam == null || shipperIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/admin/orders?action=shipperAssignment");
            return;
        }
        
        try {
            int shippingId = Integer.parseInt(shippingIdParam);
            int shipperId = Integer.parseInt(shipperIdParam);
            
            // Tạo tracking code
            String trackingCode = "SIM" + System.currentTimeMillis();
            
            // Phân công shipper
            boolean success = shippingDAO.assignShipper(shippingId, shipperId, trackingCode);
            
            if (success) {
                // Tạo tracking record đầu tiên
                ShippingTracking tracking = new ShippingTracking();
                tracking.setShippingID(shippingId);
                tracking.setStatusCode(ShippingTracking.STATUS_PICKING);
                tracking.setStatusDescription("Đơn hàng đã được xác nhận, đang chờ lấy hàng");
                tracking.setLocation("Pickleball Shop");
                tracking.setUpdatedBy(shipperId);
                trackingDAO.createTracking(tracking);
                
                // Cập nhật goship status
                shippingDAO.updateGoshipStatus(shippingId, ShippingTracking.STATUS_PICKING);
                
                request.getSession().setAttribute("success", "Phân công shipper thành công");
            } else {
                request.getSession().setAttribute("error", "Phân công shipper thất bại");
            }
            
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("error", "Dữ liệu không hợp lệ");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/orders?action=shipperAssignment");
    }
    
    /**
     * Thay đổi shipper cho đơn hàng đã phân công
     */
    private void reassignShipperToOrder(HttpServletRequest request, HttpServletResponse response,
                                       Employee employee) throws IOException {
        
        if (!RolePermission.canAssignShipper(employee.getRole())) {
            response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
            return;
        }
        
        String shippingIdParam = request.getParameter("shippingId");
        String shipperIdParam = request.getParameter("shipperId");
        
        if (shippingIdParam == null || shipperIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/admin/orders?action=shipperAssignment");
            return;
        }
        
        try {
            int shippingId = Integer.parseInt(shippingIdParam);
            int newShipperId = Integer.parseInt(shipperIdParam);
            
            // Cập nhật shipper mới
            boolean success = shippingDAO.updateShipperAssignment(shippingId, newShipperId);
            
            if (success) {
                request.getSession().setAttribute("success", "Đã thay đổi shipper thành công");
            } else {
                request.getSession().setAttribute("error", "Thay đổi shipper thất bại");
            }
            
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("error", "Dữ liệu không hợp lệ");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/orders?action=shipperAssignment");
    }
    
    /**
     * Tự động phân công shipper (chọn shipper ít đơn nhất)
     */
    private void autoAssignShipperToOrder(HttpServletRequest request, HttpServletResponse response,
                                         Employee employee) throws IOException {
        
        if (!RolePermission.canAssignShipper(employee.getRole())) {
            response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
            return;
        }
        
        String shippingIdParam = request.getParameter("shippingId");
        
        if (shippingIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/admin/orders?action=shipperAssignment");
            return;
        }
        
        try {
            int shippingId = Integer.parseInt(shippingIdParam);
            
            // Lấy shipper có ít đơn nhất
            Employee shipper = orderDAO.getShipperWithLeastActiveOrders();
            
            if (shipper == null) {
                request.getSession().setAttribute("error", "Không có shipper nào khả dụng");
                response.sendRedirect(request.getContextPath() + "/admin/orders?action=shipperAssignment");
                return;
            }
            
            // Tạo tracking code
            String trackingCode = "SIM" + System.currentTimeMillis();
            
            // Phân công shipper
            boolean success = shippingDAO.assignShipper(shippingId, shipper.getEmployeeID(), trackingCode);
            
            if (success) {
                // Tạo tracking record đầu tiên
                ShippingTracking tracking = new ShippingTracking();
                tracking.setShippingID(shippingId);
                tracking.setStatusCode(ShippingTracking.STATUS_PICKING);
                tracking.setStatusDescription("Đơn hàng đã được xác nhận, đang chờ lấy hàng");
                tracking.setLocation("Pickleball Shop");
                tracking.setUpdatedBy(shipper.getEmployeeID());
                trackingDAO.createTracking(tracking);
                
                // Cập nhật goship status
                shippingDAO.updateGoshipStatus(shippingId, ShippingTracking.STATUS_PICKING);
                
                request.getSession().setAttribute("success", 
                    "Đã phân công đơn cho shipper: " + shipper.getFullName());
            } else {
                request.getSession().setAttribute("error", "Phân công shipper thất bại");
            }
            
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("error", "Dữ liệu không hợp lệ");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/orders?action=shipperAssignment");
    }
    
    /**
     * Tự động phân công TẤT CẢ đơn hàng cho các shipper (round-robin theo số đơn ít nhất)
     */
    private void autoAssignAllShippers(HttpServletRequest request, HttpServletResponse response,
                                       Employee employee) throws IOException {
        
        if (!RolePermission.canAssignShipper(employee.getRole())) {
            response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
            return;
        }
        
        try {
            // Lấy tất cả đơn chưa phân shipper
            List<Shipping> unassignedShippings = shippingDAO.getUnassignedShippings();
            
            if (unassignedShippings.isEmpty()) {
                request.getSession().setAttribute("success", "Không có đơn hàng nào cần phân công");
                response.sendRedirect(request.getContextPath() + "/admin/orders?action=shipperAssignment");
                return;
            }
            
            int successCount = 0;
            int failCount = 0;
            
            for (Shipping shipping : unassignedShippings) {
                // Lấy shipper có ít đơn nhất (refresh mỗi lần để cân bằng)
                Employee shipper = orderDAO.getShipperWithLeastActiveOrders();
                
                if (shipper == null) {
                    failCount++;
                    continue;
                }
                
                // Tạo tracking code
                String trackingCode = "SIM" + System.currentTimeMillis() + shipping.getShippingID();
                
                // Phân công shipper
                boolean success = shippingDAO.assignShipper(shipping.getShippingID(), shipper.getEmployeeID(), trackingCode);
                
                if (success) {
                    // Tạo tracking record đầu tiên
                    ShippingTracking tracking = new ShippingTracking();
                    tracking.setShippingID(shipping.getShippingID());
                    tracking.setStatusCode(ShippingTracking.STATUS_PICKING);
                    tracking.setStatusDescription("Đơn hàng đã được xác nhận, đang chờ lấy hàng");
                    tracking.setLocation("Pickleball Shop");
                    tracking.setUpdatedBy(shipper.getEmployeeID());
                    trackingDAO.createTracking(tracking);
                    
                    // Cập nhật goship status
                    shippingDAO.updateGoshipStatus(shipping.getShippingID(), ShippingTracking.STATUS_PICKING);
                    
                    successCount++;
                } else {
                    failCount++;
                }
            }
            
            if (failCount == 0) {
                request.getSession().setAttribute("success", 
                    "Đã tự động phân công thành công " + successCount + " đơn hàng!");
            } else {
                request.getSession().setAttribute("success", 
                    "Đã phân công " + successCount + " đơn, " + failCount + " đơn thất bại");
            }
            
        } catch (Exception e) {
            System.err.println("[AdminOrder] Auto assign all error: " + e.getMessage());
            e.printStackTrace();
            request.getSession().setAttribute("error", "Lỗi: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/orders?action=shipperAssignment");
    }
    
    // ==================== SHIPPER ORDER MANAGEMENT ====================
    
    /**
     * Hiển thị danh sách đơn hàng của Shipper
     */
    private void listShipperOrders(HttpServletRequest request, HttpServletResponse response,
                                   Employee shipper) throws ServletException, IOException {
        
        // Lấy filter parameters
        String tab = request.getParameter("tab"); // pending, delivered, all
        String search = request.getParameter("search");
        String fromDateStr = request.getParameter("fromDate");
        String toDateStr = request.getParameter("toDate");
        int page = getPageParam(request);
        int pageSize = 5;
        
        // Default tab là "pending" (cần giao)
        if (tab == null || tab.isEmpty()) {
            tab = "pending";
        }
        
        // Parse dates
        java.util.Date fromDate = null;
        java.util.Date toDate = null;
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        try {
            if (fromDateStr != null && !fromDateStr.isEmpty()) {
                fromDate = sdf.parse(fromDateStr);
            }
            if (toDateStr != null && !toDateStr.isEmpty()) {
                toDate = sdf.parse(toDateStr);
            }
        } catch (ParseException e) {
            // Ignore
        }
        
        // Lấy đơn hàng theo filter
        List<Order> orders = orderDAO.getShipperOrdersFiltered(
            shipper.getEmployeeID(), tab, search, fromDate, toDate, page, pageSize);
        
        // Đếm tổng để phân trang
        int totalOrders = orderDAO.countShipperOrdersFiltered(
            shipper.getEmployeeID(), tab, search, fromDate, toDate);
        int totalPages = (int) Math.ceil((double) totalOrders / pageSize);
        
        // Thống kê động theo filter
        int pendingCount = orderDAO.countShipperOrdersFiltered(
            shipper.getEmployeeID(), "pending", search, fromDate, toDate);
        int deliveredCount = orderDAO.countShipperOrdersFiltered(
            shipper.getEmployeeID(), "delivered", search, fromDate, toDate);
        int allCount = orderDAO.countShipperOrdersFiltered(
            shipper.getEmployeeID(), "all", search, fromDate, toDate);
        
        // Đếm giao hôm nay (không theo filter)
        int deliveredToday = shippingDAO.countDeliveredTodayByShipper(shipper.getEmployeeID());
        
        request.setAttribute("orders", orders);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("deliveredCount", deliveredCount);
        request.setAttribute("allCount", allCount);
        request.setAttribute("deliveredToday", deliveredToday);
        request.setAttribute("currentTab", tab);
        request.setAttribute("search", search);
        request.setAttribute("fromDate", fromDateStr);
        request.setAttribute("toDate", toDateStr);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("shipper", shipper);
        request.setAttribute("pageTitle", "Đơn hàng giao");
        
        request.getRequestDispatcher("/AdminLTE-3.2.0/orders/shipper-order-list.jsp")
               .forward(request, response);
    }
    
    /**
     * Xem chi tiết đơn hàng cho Shipper
     */
    private void viewShipperOrderDetail(HttpServletRequest request, HttpServletResponse response,
                                       Employee shipper) throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/orders?action=shipperOrders");
            return;
        }
        
        try {
            int orderId = Integer.parseInt(idParam);
            Order order = orderDAO.getOrderById(orderId);
            
            if (order == null) {
                request.getSession().setAttribute("error", "Không tìm thấy đơn hàng");
                response.sendRedirect(request.getContextPath() + "/admin/orders?action=shipperOrders");
                return;
            }
            
            // Kiểm tra đơn có được phân cho shipper này không
            Shipping shipping = order.getShipping();
            if (shipping == null || shipping.getShipperID() == null || 
                shipping.getShipperID() != shipper.getEmployeeID()) {
                request.getSession().setAttribute("error", "Bạn không có quyền xem đơn hàng này");
                response.sendRedirect(request.getContextPath() + "/admin/orders?action=shipperOrders");
                return;
            }
            
            // Lấy lịch sử tracking
            List<ShippingTracking> trackingHistory = trackingDAO.getTrackingHistory(shipping.getShippingID());
            
            // Lấy trạng thái hiện tại và các trạng thái tiếp theo hợp lệ
            String currentStatus = trackingHistory.isEmpty() ? null : trackingHistory.get(0).getStatusCode();
            String[] nextStatuses = ShippingTracking.getNextValidStatuses(currentStatus);
            
            request.setAttribute("order", order);
            request.setAttribute("shipping", shipping);
            request.setAttribute("trackingHistory", trackingHistory);
            request.setAttribute("currentStatus", currentStatus);
            request.setAttribute("nextStatuses", nextStatuses);
            request.setAttribute("pageTitle", "Chi tiết đơn hàng #" + order.getOrderCode());
            
            request.getRequestDispatcher("/AdminLTE-3.2.0/orders/shipper-order-detail.jsp")
                   .forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/orders?action=shipperOrders");
        }
    }
    
    /**
     * Cập nhật trạng thái vận chuyển (cho Shipper)
     */
    private void updateShippingStatus(HttpServletRequest request, HttpServletResponse response,
                                     Employee shipper) throws IOException {
        
        if (!RolePermission.isShipper(shipper.getRole())) {
            response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
            return;
        }
        
        String orderIdParam = request.getParameter("orderId");
        String newStatus = request.getParameter("newStatus");
        String notes = request.getParameter("notes");
        String location = request.getParameter("location");
        
        if (orderIdParam == null || newStatus == null) {
            response.sendRedirect(request.getContextPath() + "/admin/orders?action=shipperOrders");
            return;
        }
        
        int orderId = Integer.parseInt(orderIdParam);
        
        try {
            Order order = orderDAO.getOrderById(orderId);
            if (order == null || order.getShipping() == null) {
                request.getSession().setAttribute("error", "Không tìm thấy đơn hàng");
                response.sendRedirect(request.getContextPath() + "/admin/orders?action=shipperOrders");
                return;
            }
            
            Shipping shipping = order.getShipping();
            
            // Kiểm tra quyền
            if (shipping.getShipperID() == null || shipping.getShipperID() != shipper.getEmployeeID()) {
                request.getSession().setAttribute("error", "Bạn không có quyền cập nhật đơn hàng này");
                response.sendRedirect(request.getContextPath() + "/admin/orders?action=shipperOrders");
                return;
            }
            
            // Validate status transition
            ShippingTracking latestTracking = trackingDAO.getLatestTracking(shipping.getShippingID());
            String currentStatus = latestTracking != null ? latestTracking.getStatusCode() : null;
            String[] validNextStatuses = ShippingTracking.getNextValidStatuses(currentStatus);
            
            boolean isValidTransition = false;
            for (String valid : validNextStatuses) {
                if (valid.equals(newStatus)) {
                    isValidTransition = true;
                    break;
                }
            }
            
            if (!isValidTransition) {
                request.getSession().setAttribute("error", "Trạng thái không hợp lệ");
                response.sendRedirect(request.getContextPath() + "/admin/orders?action=shipperDetail&id=" + orderId);
                return;
            }
            
            // Validate COD collection - bắt buộc xác nhận thu tiền khi giao thành công đơn COD
            String codCollected = request.getParameter("codCollected");
            if (ShippingTracking.STATUS_DELIVERED.equals(newStatus) 
                && "COD".equals(order.getPaymentMethod()) 
                && !"Paid".equals(order.getPaymentStatus())
                && !"true".equals(codCollected)) {
                request.getSession().setAttribute("error", "Vui lòng xác nhận đã thu tiền COD trước khi hoàn thành đơn hàng!");
                response.sendRedirect(request.getContextPath() + "/admin/orders?action=shipperDetail&id=" + orderId);
                return;
            }
            
            // Tạo tracking record mới
            ShippingTracking tracking = new ShippingTracking();
            tracking.setShippingID(shipping.getShippingID());
            tracking.setStatusCode(newStatus);
            tracking.setStatusDescription(ShippingTracking.getVietnameseName(newStatus));
            tracking.setLocation(location);
            tracking.setNotes(notes);
            tracking.setUpdatedBy(shipper.getEmployeeID());
            
            int trackingId = trackingDAO.createTracking(tracking);
            
            if (trackingId > 0) {
                // Cập nhật GoshipStatus trong Shipping
                shippingDAO.updateGoshipStatus(shipping.getShippingID(), newStatus);
                
                // Cập nhật Order status nếu cần
                if (ShippingTracking.STATUS_DELIVERED.equals(newStatus)) {
                    orderDAO.updateOrderStatus(orderId, "Delivered", shipper.getEmployeeID(), 
                        "Shipper xác nhận đã giao hàng thành công");
                    shippingDAO.updateDeliveredDate(shipping.getShippingID());
                    
                    // Xử lý thu tiền COD (codCollected đã được lấy ở trên)
                    if ("true".equals(codCollected) && "COD".equals(order.getPaymentMethod())) {
                        orderDAO.updatePaymentStatus(orderId, "Paid");
                        System.out.println("[AdminOrder] COD collected for order " + orderId);
                    }
                } else if (ShippingTracking.STATUS_RETURNED.equals(newStatus)) {
                    orderDAO.updateOrderStatus(orderId, "Cancelled", shipper.getEmployeeID(), 
                        "Đơn hàng đã hoàn về shop");
                }
                
                request.getSession().setAttribute("success", 
                    "Cập nhật trạng thái thành công: " + ShippingTracking.getVietnameseName(newStatus));
            } else {
                request.getSession().setAttribute("error", "Cập nhật trạng thái thất bại");
            }
            
        } catch (Exception e) {
            System.err.println("[AdminOrder] Shipper update error: " + e.getMessage());
            e.printStackTrace();
            request.getSession().setAttribute("error", "Lỗi: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/orders?action=shipperDetail&id=" + orderId);
    }
}
