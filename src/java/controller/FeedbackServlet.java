package controller;

import DAO.ReviewDAO;
import entity.Employee;
import entity.Review;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "FeedbackServlet", urlPatterns = {"/feedbacks"})
public class FeedbackServlet extends HttpServlet {

    private ReviewDAO reviewDAO;
    private static final int PAGE_SIZE = 10;

    @Override
    public void init() throws ServletException {
        reviewDAO = new ReviewDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        
        // Kiểm tra quyền Marketer hoặc Admin
        if (employee == null || 
            (!"Marketer".equalsIgnoreCase(employee.getRole()) && !"Admin".equalsIgnoreCase(employee.getRole()))) {
            response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
            return;
        }
        
        // Lấy filter params
        String status = request.getParameter("status");
        String ratingStr = request.getParameter("rating");
        String productIdStr = request.getParameter("productId");
        String hasReplyStr = request.getParameter("hasReply");
        String dateFrom = request.getParameter("dateFrom");
        String dateTo = request.getParameter("dateTo");
        String pageStr = request.getParameter("page");
        
        Integer rating = null;
        if (ratingStr != null && !ratingStr.isEmpty()) {
            try { rating = Integer.parseInt(ratingStr); } catch (NumberFormatException ignored) {}
        }
        
        Integer productId = null;
        if (productIdStr != null && !productIdStr.isEmpty()) {
            try { productId = Integer.parseInt(productIdStr); } catch (NumberFormatException ignored) {}
        }
        
        Boolean hasReply = null;
        if ("yes".equals(hasReplyStr)) hasReply = true;
        else if ("no".equals(hasReplyStr)) hasReply = false;
        
        int page = 1;
        if (pageStr != null) {
            try { page = Integer.parseInt(pageStr); if (page < 1) page = 1; } catch (NumberFormatException ignored) {}
        }
        
        // Lấy danh sách reviews
        List<Review> reviews = reviewDAO.searchReviews(status, rating, productId, hasReply, dateFrom, dateTo, page, PAGE_SIZE);
        int totalReviews = reviewDAO.countReviews(status, rating, productId, hasReply, dateFrom, dateTo);
        int totalPages = (int) Math.ceil((double) totalReviews / PAGE_SIZE);
        
        // Lấy danh sách products để filter
        List<Map<String, Object>> products = reviewDAO.getProductsForFilter();
        
        request.setAttribute("reviews", reviews);
        request.setAttribute("totalReviews", totalReviews);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("products", products);
        
        // Giữ lại filter values
        request.setAttribute("filterStatus", status);
        request.setAttribute("filterRating", rating);
        request.setAttribute("filterProductId", productId);
        request.setAttribute("filterHasReply", hasReplyStr);
        request.setAttribute("filterDateFrom", dateFrom);
        request.setAttribute("filterDateTo", dateTo);
        
        request.getRequestDispatcher("/feedback-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        
        // Kiểm tra quyền Marketer hoặc Admin
        if (employee == null || 
            (!"Marketer".equalsIgnoreCase(employee.getRole()) && !"Admin".equalsIgnoreCase(employee.getRole()))) {
            response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        String reviewIdStr = request.getParameter("reviewId");
        
        if (reviewIdStr == null || reviewIdStr.isEmpty()) {
            session.setAttribute("error", "Thiếu thông tin đánh giá");
            response.sendRedirect(request.getContextPath() + "/feedbacks");
            return;
        }
        
        try {
            int reviewId = Integer.parseInt(reviewIdStr);
            
            if ("toggleStatus".equals(action)) {
                String newStatus = request.getParameter("newStatus");
                if (reviewDAO.updateReviewStatus(reviewId, newStatus)) {
                    session.setAttribute("success", "Đã cập nhật trạng thái đánh giá");
                } else {
                    session.setAttribute("error", "Cập nhật thất bại");
                }
            } else if ("reply".equals(action)) {
                String replyContent = request.getParameter("replyContent");
                if (replyContent == null || replyContent.trim().isEmpty()) {
                    session.setAttribute("error", "Vui lòng nhập nội dung phản hồi");
                } else {
                    if (reviewDAO.addReply(reviewId, replyContent.trim(), employee.getEmployeeID())) {
                        session.setAttribute("success", "Đã gửi phản hồi thành công");
                    } else {
                        session.setAttribute("error", "Gửi phản hồi thất bại");
                    }
                }
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Thông tin không hợp lệ");
        }
        
        // Redirect về trang list với các filter hiện tại
        String queryString = request.getParameter("returnQuery");
        if (queryString != null && !queryString.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/feedbacks?" + queryString);
        } else {
            response.sendRedirect(request.getContextPath() + "/feedbacks");
        }
    }
}
