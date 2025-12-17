package controller;

import entity.Customer;
import entity.CustomerAddress;
import entity.Order;
import entity.Review;
import entity.Wishlist;
import DAO.CustomerAddressDAO;
import DAO.OrderDAO;
import DAO.ReviewDAO;
import DAO.WishlistDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
public class ProfileServlet extends HttpServlet {

    private CustomerAddressDAO addressDAO = new CustomerAddressDAO();
    private OrderDAO orderDAO = new OrderDAO();
    private WishlistDAO wishlistDAO = new WishlistDAO();
    private ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        
        // Check login
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?redirect=profile");
            return;
        }
        
        // Get active tab
        String tab = request.getParameter("tab");
        if (tab == null) tab = "profile";
        request.setAttribute("activeTab", tab);
        request.setAttribute("customer", customer);
        
        // Load data based on active tab
        switch (tab) {
            case "addresses":
                List<CustomerAddress> addresses = addressDAO.getAddressesByCustomerId(customer.getCustomerID());
                request.setAttribute("addresses", addresses);
                break;
                
            case "orders":
                String statusFilter = request.getParameter("status");
                List<Order> orders;
                if (statusFilter != null && !statusFilter.isEmpty()) {
                    orders = orderDAO.getOrdersByCustomerAndStatus(customer.getCustomerID(), statusFilter);
                } else {
                    orders = orderDAO.getOrdersByCustomerId(customer.getCustomerID());
                }
                request.setAttribute("orders", orders);
                request.setAttribute("statusFilter", statusFilter);
                break;
                
            case "wishlist":
                List<Wishlist> wishlists = wishlistDAO.getWishlistByCustomer(customer.getCustomerID());
                request.setAttribute("wishlists", wishlists);
                break;
                
            case "reviews":
                int page = 1;
                try {
                    String pageParam = request.getParameter("page");
                    if (pageParam != null) page = Integer.parseInt(pageParam);
                } catch (NumberFormatException e) { }
                int pageSize = 10;
                List<Review> reviews = reviewDAO.getReviewsByCustomer(customer.getCustomerID(), page, pageSize);
                int totalReviews = reviewDAO.countReviewsByCustomer(customer.getCustomerID());
                int totalPages = (int) Math.ceil((double) totalReviews / pageSize);
                request.setAttribute("reviews", reviews);
                request.setAttribute("totalReviews", totalReviews);
                request.setAttribute("currentPage", page);
                request.setAttribute("totalPages", totalPages);
                break;
                
            default:
                // Profile tab - no extra data needed
                break;
        }
        
        // Pass redirect parameter to JSP for address form
        String redirect = request.getParameter("redirect");
        if (redirect != null && !redirect.isEmpty()) {
            request.setAttribute("redirect", redirect);
        }
        
        // Forward to profile page
        request.getRequestDispatcher("/customer/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
