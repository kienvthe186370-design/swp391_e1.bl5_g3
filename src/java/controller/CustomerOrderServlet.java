package controller;

import DAO.OrderDAO;
import entity.*;
import utils.OrderStatusValidator;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "CustomerOrderServlet", urlPatterns = {"/customer/orders"})
public class CustomerOrderServlet extends HttpServlet {
    
    private OrderDAO orderDAO;
    
    @Override
    public void init() throws ServletException {
        orderDAO = new OrderDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) action = "list";
        
        switch (action) {
            case "list":
                listCustomerOrders(request, response, customer);
                break;
            case "detail":
                viewOrderDetail(request, response, customer);
                break;
            case "track":
                trackOrder(request, response, customer);
                break;
            default:
                listCustomerOrders(request, response, customer);
        }
    }
    
    private void listCustomerOrders(HttpServletRequest request, HttpServletResponse response,
                                   Customer customer) throws ServletException, IOException {
        
        int page = getPageParam(request);
        int pageSize = 10;
        
        // Filter by status if provided
        OrderFilter filter = new OrderFilter();
        filter.setCustomerId(customer.getCustomerID());
        
        String status = request.getParameter("status");
        if (status != null && !status.trim().isEmpty()) {
            filter.setOrderStatus(status);
        }
        
        List<Order> orders = orderDAO.getOrders(filter, page, pageSize);
        int totalOrders = orderDAO.countOrders(filter);
        int totalPages = (int) Math.ceil((double) totalOrders / pageSize);
        
        // Load order details for each order (for preview)
        for (Order order : orders) {
            Order fullOrder = orderDAO.getOrderById(order.getOrderID());
            if (fullOrder != null) {
                order.setOrderDetails(fullOrder.getOrderDetails());
            }
        }
        
        request.setAttribute("orders", orders);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        
        request.getRequestDispatcher("/customer/order-list.jsp")
               .forward(request, response);
    }
    
    private void viewOrderDetail(HttpServletRequest request, HttpServletResponse response,
                                Customer customer) throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/orders");
            return;
        }
        
        try {
            int orderId = Integer.parseInt(idParam);
            Order order = orderDAO.getOrderById(orderId);
            
            if (order == null) {
                request.getSession().setAttribute("error", "Không tìm thấy đơn hàng");
                response.sendRedirect(request.getContextPath() + "/customer/orders");
                return;
            }
            
            // Validate: đơn phải thuộc customer này
            if (order.getCustomerID() != customer.getCustomerID()) {
                response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
                return;
            }
            
            // Check if can cancel
            boolean canCancel = "Pending".equals(order.getOrderStatus());
            
            request.setAttribute("order", order);
            request.setAttribute("canCancel", canCancel);
            
            request.getRequestDispatcher("/customer/order-detail.jsp")
                   .forward(request, response);
                   
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/orders");
        }
    }
    
    private void trackOrder(HttpServletRequest request, HttpServletResponse response,
                           Customer customer) throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/orders");
            return;
        }
        
        try {
            int orderId = Integer.parseInt(idParam);
            Order order = orderDAO.getOrderById(orderId);
            
            if (order == null || order.getCustomerID() != customer.getCustomerID()) {
                response.sendRedirect(request.getContextPath() + "/customer/orders");
                return;
            }
            
            request.setAttribute("order", order);
            
            request.getRequestDispatcher("/customer/order-tracking.jsp")
                   .forward(request, response);
                   
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/orders");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("cancel".equals(action)) {
            cancelOrder(request, response, customer);
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/orders");
        }
    }
    
    private void cancelOrder(HttpServletRequest request, HttpServletResponse response,
                            Customer customer) throws IOException {
        
        String orderIdParam = request.getParameter("orderId");
        String reason = request.getParameter("reason");
        
        if (orderIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/customer/orders");
            return;
        }
        
        try {
            int orderId = Integer.parseInt(orderIdParam);
            Order order = orderDAO.getOrderById(orderId);
            
            // Validate: đơn phải thuộc customer này và status = Pending
            if (order == null || order.getCustomerID() != customer.getCustomerID()) {
                request.getSession().setAttribute("error", "Bạn không có quyền hủy đơn này");
                response.sendRedirect(request.getContextPath() + "/customer/orders");
                return;
            }
            
            if (!"Pending".equals(order.getOrderStatus())) {
                request.getSession().setAttribute("error", "Chỉ có thể hủy đơn hàng đang chờ xử lý");
                response.sendRedirect(request.getContextPath() + "/customer/orders?action=detail&id=" + orderId);
                return;
            }
            
            // Hủy đơn - changedById = null vì customer hủy
            String note = "Khách hàng hủy: " + (reason != null ? reason : "Không có lý do");
            boolean success = orderDAO.updateOrderStatus(orderId, "Cancelled", null, note);
            
            if (success) {
                request.getSession().setAttribute("success", "Đã hủy đơn hàng thành công");
            } else {
                request.getSession().setAttribute("error", "Hủy đơn hàng thất bại");
            }
            
            response.sendRedirect(request.getContextPath() + "/customer/orders?action=detail&id=" + orderId);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/orders");
        }
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
}
