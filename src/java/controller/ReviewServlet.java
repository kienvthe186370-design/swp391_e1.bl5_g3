package controller;

import DAO.ReviewDAO;
import entity.Customer;
import entity.Review;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Map;

@WebServlet(name = "ReviewServlet", urlPatterns = {"/review"})
public class ReviewServlet extends HttpServlet {

    private ReviewDAO reviewDAO;

    @Override
    public void init() throws ServletException {
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
        
        String orderDetailIdStr = request.getParameter("orderDetailId");
        if (orderDetailIdStr == null || orderDetailIdStr.isEmpty()) {
            session.setAttribute("error", "Thiếu thông tin đơn hàng");
            response.sendRedirect(request.getContextPath() + "/customer/orders");
            return;
        }
        
        try {
            int orderDetailId = Integer.parseInt(orderDetailIdStr);
            
            if (!reviewDAO.canReview(orderDetailId, customer.getCustomerID())) {
                session.setAttribute("error", "Bạn không thể đánh giá sản phẩm này");
                response.sendRedirect(request.getContextPath() + "/customer/orders");
                return;
            }
            
            Map<String, Object> orderDetail = reviewDAO.getOrderDetailForReview(orderDetailId, customer.getCustomerID());
            
            if (orderDetail == null) {
                session.setAttribute("error", "Không tìm thấy thông tin sản phẩm");
                response.sendRedirect(request.getContextPath() + "/customer/orders");
                return;
            }
            
            request.setAttribute("orderDetail", orderDetail);
            request.getRequestDispatcher("/review.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Thông tin không hợp lệ");
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
        
        int orderDetailId = 0;
        try {
            orderDetailId = Integer.parseInt(request.getParameter("orderDetailId"));
            int productId = Integer.parseInt(request.getParameter("productId"));
            int rating = Integer.parseInt(request.getParameter("rating"));
            String reviewTitle = request.getParameter("reviewTitle");
            String reviewContent = request.getParameter("reviewContent");
            
            // Validate rating
            if (rating < 1 || rating > 5) {
                session.setAttribute("error", "Vui lòng chọn số sao đánh giá (1-5)");
                response.sendRedirect(request.getContextPath() + "/review?orderDetailId=" + orderDetailId);
                return;
            }
            
            // Kiểm tra quyền review
            if (!reviewDAO.canReview(orderDetailId, customer.getCustomerID())) {
                session.setAttribute("error", "Bạn không thể đánh giá sản phẩm này");
                response.sendRedirect(request.getContextPath() + "/customer/orders");
                return;
            }
            
            // Tạo review
            Review review = new Review();
            review.setOrderDetailId(orderDetailId);
            review.setCustomerId(customer.getCustomerID());
            review.setProductId(productId);
            review.setRating(rating);
            review.setReviewTitle(reviewTitle != null ? reviewTitle.trim() : null);
            review.setReviewContent(reviewContent != null ? reviewContent.trim() : null);
            
            int reviewId = reviewDAO.createReview(review);
            
            if (reviewId > 0) {
                session.setAttribute("success", "Đánh giá của bạn đã được gửi thành công!");
                response.sendRedirect(request.getContextPath() + "/my-reviews");
            } else {
                session.setAttribute("error", "Có lỗi xảy ra, vui lòng thử lại");
                response.sendRedirect(request.getContextPath() + "/review?orderDetailId=" + orderDetailId);
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Thông tin không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/customer/orders");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/review?orderDetailId=" + orderDetailId);
        }
    }
}
