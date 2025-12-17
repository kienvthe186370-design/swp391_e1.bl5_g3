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
import java.util.List;

@WebServlet(name = "MyReviewsServlet", urlPatterns = {"/my-reviews"})
public class MyReviewsServlet extends HttpServlet {

    private ReviewDAO reviewDAO;
    private static final int PAGE_SIZE = 7;

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
        
        int page = 1;
        String pageStr = request.getParameter("page");
        if (pageStr != null) {
            try {
                page = Integer.parseInt(pageStr);
                if (page < 1) page = 1;
            } catch (NumberFormatException ignored) {}
        }
        
        // Lấy danh sách reviews
        List<Review> reviews = reviewDAO.getReviewsByCustomer(customer.getCustomerID(), page, PAGE_SIZE);
        int totalReviews = reviewDAO.countReviewsByCustomer(customer.getCustomerID());
        int totalPages = (int) Math.ceil((double) totalReviews / PAGE_SIZE);
        
        request.setAttribute("reviews", reviews);
        request.setAttribute("totalReviews", totalReviews);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        
        request.getRequestDispatcher("/my-reviews.jsp").forward(request, response);
    }
}
