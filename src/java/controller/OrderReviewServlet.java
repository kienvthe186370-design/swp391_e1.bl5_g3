package controller;

import DAO.OrderDAO;
import DAO.ReviewDAO;
import entity.Customer;
import entity.Order;
import entity.OrderDetail;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Servlet hiển thị danh sách sản phẩm cần đánh giá của một đơn hàng
 */
@WebServlet(name = "OrderReviewServlet", urlPatterns = {"/order-review"})
public class OrderReviewServlet extends HttpServlet {

    private OrderDAO orderDAO;
    private ReviewDAO reviewDAO;

    @Override
    public void init() throws ServletException {
        orderDAO = new OrderDAO();
        reviewDAO = new ReviewDAO();
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
        
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr == null || orderIdStr.isEmpty()) {
            session.setAttribute("error", "Thiếu thông tin đơn hàng");
            response.sendRedirect(request.getContextPath() + "/customer/orders");
            return;
        }
        
        try {
            int orderId = Integer.parseInt(orderIdStr);
            Order order = orderDAO.getOrderById(orderId);
            
            // Kiểm tra đơn hàng tồn tại và thuộc về customer này
            if (order == null || order.getCustomerID() != customer.getCustomerID()) {
                session.setAttribute("error", "Không tìm thấy đơn hàng");
                response.sendRedirect(request.getContextPath() + "/customer/orders");
                return;
            }
            
            // Kiểm tra đơn hàng đã giao hoặc hoàn thành chưa
            if (!"Delivered".equals(order.getOrderStatus()) && !"Completed".equals(order.getOrderStatus())) {
                session.setAttribute("error", "Chỉ có thể đánh giá đơn hàng đã giao hoặc hoàn thành");
                response.sendRedirect(request.getContextPath() + "/customer/orders");
                return;
            }
            
            // Lọc ra các sản phẩm chưa đánh giá
            List<OrderDetail> pendingReviews = new ArrayList<>();
            List<OrderDetail> reviewedItems = new ArrayList<>();
            
            System.out.println("=== OrderReviewServlet Debug ===");
            System.out.println("Order ID: " + orderId);
            System.out.println("Order Details count: " + (order.getOrderDetails() != null ? order.getOrderDetails().size() : 0));
            
            if (order.getOrderDetails() != null) {
                for (OrderDetail detail : order.getOrderDetails()) {
                    System.out.println("  - OrderDetailID: " + detail.getOrderDetailID() + ", isReviewed: " + detail.isReviewed());
                    if (!detail.isReviewed()) {
                        pendingReviews.add(detail);
                    } else {
                        reviewedItems.add(detail);
                    }
                }
            }
            System.out.println("Pending reviews: " + pendingReviews.size());
            System.out.println("================================");
            
            // Nếu chỉ có 1 sản phẩm chưa đánh giá, redirect thẳng đến trang đánh giá
            if (pendingReviews.size() == 1) {
                response.sendRedirect(request.getContextPath() + "/review?orderDetailId=" + pendingReviews.get(0).getOrderDetailID());
                return;
            }
            
            // Nếu không còn sản phẩm nào cần đánh giá
            if (pendingReviews.isEmpty()) {
                session.setAttribute("success", "Bạn đã đánh giá tất cả sản phẩm trong đơn hàng này");
                response.sendRedirect(request.getContextPath() + "/my-reviews");
                return;
            }
            
            request.setAttribute("order", order);
            request.setAttribute("pendingReviews", pendingReviews);
            request.setAttribute("reviewedItems", reviewedItems);
            
            request.getRequestDispatcher("/order-review.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Thông tin không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/customer/orders");
        }
    }
}
