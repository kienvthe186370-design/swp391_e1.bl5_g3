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
        
        // Redirect to profile page with reviews tab
        String page = request.getParameter("page");
        String redirectUrl = request.getContextPath() + "/profile?tab=reviews";
        if (page != null && !page.isEmpty()) {
            redirectUrl += "&page=" + page;
        }
        response.sendRedirect(redirectUrl);
    }
}
