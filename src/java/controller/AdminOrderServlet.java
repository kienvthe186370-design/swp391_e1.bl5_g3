package controller;

import DAO.OrderDAO;
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
    
    @Override
    public void init() throws ServletException {
        orderDAO = new OrderDAO();
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
        
        // Chỉ SellerManager và Seller mới được truy cập
        if (!RolePermission.canManageOrders(role)) {
            response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) action = "list";
        
        switch (action) {
            case "list":
                listOrders(request, response, employee);
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
            default:
                listOrders(request, response, employee);
        }
    }
    
    private void listOrders(HttpServletRequest request, HttpServletResponse response, 
                           Employee employee) throws ServletException, IOException {
        
        String role = employee.getRole();
        OrderFilter filter = buildFilterFromRequest(request);
        
        // Seller chỉ thấy đơn được phân công cho mình
        if ("Seller".equalsIgnoreCase(role)) {
            filter.setAssignedTo(employee.getEmployeeID());
        }
        
        // SellerManager thấy tất cả
        // Tab: all, unassigned, assigned
        String tab = request.getParameter("tab");
        if ("unassigned".equals(tab)) {
            filter.setUnassignedOnly(true);
        }
        
        int page = getPageParam(request);
        int pageSize = getPageSizeParam(request);
        
        List<Order> orders = orderDAO.getOrders(filter, page, pageSize);
        int totalOrders = orderDAO.countOrders(filter);
        int unassignedCount = orderDAO.countUnassignedOrders();
        int totalPages = (int) Math.ceil((double) totalOrders / pageSize);
        
        // Lấy danh sách seller cho modal phân công
        if (RolePermission.canAssignOrders(role)) {
            List<Object[]> sellers = orderDAO.getSellersWithActiveOrderCount();
            request.setAttribute("sellers", sellers);
        }
        
        request.setAttribute("orders", orders);
        request.setAttribute("totalOrders", totalOrders);
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
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }
        
        try {
            int orderId = Integer.parseInt(idParam);
            Order order = orderDAO.getOrderById(orderId);
            
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
            
            request.getRequestDispatcher("/AdminLTE-3.2.0/orders/order-detail.jsp")
                   .forward(request, response);
                   
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/orders");
        }
    }
    
    private void showAssignmentPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lấy đơn chưa phân công
        List<Order> unassignedOrders = orderDAO.getUnassignedOrders();
        List<Object[]> sellers = orderDAO.getSellersWithActiveOrderCount();
        
        request.setAttribute("unassignedOrders", unassignedOrders);
        request.setAttribute("sellers", sellers);
        request.setAttribute("pageTitle", "Phân công đơn hàng");
        
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
            default:
                response.sendRedirect(request.getContextPath() + "/admin/orders");
        }
    }
    
    private void updateOrderStatus(HttpServletRequest request, HttpServletResponse response,
                                  Employee employee) throws IOException {
        
        String orderIdParam = request.getParameter("orderId");
        String newStatus = request.getParameter("newStatus");
        String note = request.getParameter("note");
        
        if (orderIdParam == null || newStatus == null) {
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }
        
        try {
            int orderId = Integer.parseInt(orderIdParam);
            Order order = orderDAO.getOrderById(orderId);
            
            if (order == null) {
                request.getSession().setAttribute("error", "Không tìm thấy đơn hàng");
                response.sendRedirect(request.getContextPath() + "/admin/orders");
                return;
            }
            
            // Validate transition
            String role = employee.getRole();
            if (!OrderStatusValidator.canTransition(order.getOrderStatus(), newStatus, role, false)) {
                request.getSession().setAttribute("error", "Không thể chuyển sang trạng thái này");
                response.sendRedirect(request.getContextPath() + "/admin/orders?action=detail&id=" + orderId);
                return;
            }
            
            boolean success = orderDAO.updateOrderStatus(orderId, newStatus, employee.getEmployeeID(), note);
            
            if (success) {
                String successMsg = "Cập nhật trạng thái thành công";
                
                // Nếu chuyển sang Shipping, tự động tạo vận đơn Goship với carrier đã chọn từ checkout
                if ("Shipping".equals(newStatus)) {
                    try {
                        // Lấy shipping info để lấy carrier ID đã chọn từ checkout
                        DAO.ShippingDAO shippingDAO = new DAO.ShippingDAO();
                        entity.Shipping shipping = shippingDAO.getShippingByOrderId(orderId);
                        
                        String carrierId = null;
                        if (shipping != null && shipping.getGoshipCarrierId() != null) {
                            carrierId = shipping.getGoshipCarrierId();
                        }
                        
                        if (carrierId != null && !carrierId.isEmpty()) {
                            service.GoshipService goshipService = new service.GoshipService();
                            service.GoshipService.GoshipShipmentResult shipmentResult = 
                                goshipService.createShipment(order, carrierId);
                            
                            if (shipmentResult.isSuccess()) {
                                // Cập nhật thông tin vận đơn vào database
                                orderDAO.updateOrderGoshipInfo(orderId, 
                                    shipmentResult.getGoshipOrderCode(), 
                                    shipmentResult.getTrackingCode());
                                successMsg += ". Đã tạo vận đơn Goship: " + shipmentResult.getTrackingCode();
                            } else {
                                successMsg += ". Lưu ý: " + shipmentResult.getMessage();
                            }
                        } else {
                            successMsg += ". (Không có Goship carrier ID - vận đơn không được tạo tự động)";
                        }
                    } catch (Exception e) {
                        successMsg += ". Lưu ý: Lỗi khi tạo vận đơn Goship";
                        e.printStackTrace();
                    }
                }
                
                request.getSession().setAttribute("success", successMsg);
            } else {
                request.getSession().setAttribute("error", "Cập nhật trạng thái thất bại");
            }
            
            response.sendRedirect(request.getContextPath() + "/admin/orders?action=detail&id=" + orderId);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/orders");
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
}
