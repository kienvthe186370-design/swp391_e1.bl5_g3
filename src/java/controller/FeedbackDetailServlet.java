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

@WebServlet(name = "FeedbackDetailServlet", urlPatterns = {"/feedback-detail"})
public class FeedbackDetailServlet extends HttpServlet {

    private ReviewDAO reviewDAO;

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
        
        String reviewIdStr = request.getParameter("id");
        if (reviewIdStr == null || reviewIdStr.isEmpty()) {
            session.setAttribute("error", "Thiếu thông tin đánh giá");
            response.sendRedirect(request.getContextPath() + "/feedbacks");
            return;
        }
        
        try {
            int reviewId = Integer.parseInt(reviewIdStr);
            Review review = reviewDAO.getReviewById(reviewId);
            
            if (review == null) {
                session.setAttribute("error", "Không tìm thấy đánh giá");
                response.sendRedirect(request.getContextPath() + "/feedbacks");
                return;
            }
            
            // Populate images for review
            review.setImages(reviewDAO.getReviewImages(reviewId));
            
            request.setAttribute("review", review);
            request.getRequestDispatcher("/feedback-detail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID đánh giá không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/feedbacks");
        }
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
            
            response.sendRedirect(request.getContextPath() + "/feedback-detail?id=" + reviewId);
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Thông tin không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/feedbacks");
        }
    }
}
