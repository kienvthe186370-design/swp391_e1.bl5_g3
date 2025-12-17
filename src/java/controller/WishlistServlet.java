package controller;

import DAO.WishlistDAO;
import entity.Customer;
import entity.Wishlist;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * WishlistServlet - Xử lý các request liên quan đến wishlist
 */
@WebServlet(name = "WishlistServlet", urlPatterns = {"/wishlist", "/customer/wishlist"})
public class WishlistServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Customer customer = (Customer) request.getSession().getAttribute("customer");
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login?redirect=wishlist");
            return;
        }

        String action = request.getParameter("action");
        
        if ("check".equals(action)) {
            // AJAX: Kiểm tra sản phẩm có trong wishlist không
            checkWishlist(request, response, customer);
        } else if ("count".equals(action)) {
            // AJAX: Đếm số sản phẩm trong wishlist
            countWishlist(request, response, customer);
        } else {
            // Hiển thị trang wishlist
            showWishlist(request, response, customer);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Customer customer = (Customer) request.getSession().getAttribute("customer");
        if (customer == null) {
            // AJAX request
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"message\":\"Vui lòng đăng nhập\",\"login\":true}");
            return;
        }

        String action = request.getParameter("action");
        
        switch (action != null ? action : "") {
            case "add" -> addToWishlist(request, response, customer);
            case "remove" -> removeFromWishlist(request, response, customer);
            case "toggle" -> toggleWishlist(request, response, customer);
            default -> response.sendRedirect(request.getContextPath() + "/wishlist");
        }
    }

    private void showWishlist(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        System.out.println("WishlistServlet: showWishlist for customer ID = " + customer.getCustomerID() + ", name = " + customer.getFullName());
        WishlistDAO dao = new WishlistDAO();
        List<Wishlist> wishlist = dao.getWishlistByCustomer(customer.getCustomerID());
        System.out.println("WishlistServlet: Found " + wishlist.size() + " items");
        request.setAttribute("wishlist", wishlist);
        request.getRequestDispatcher("/customer/wishlist.jsp").forward(request, response);
    }

    private void addToWishlist(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            int productId = Integer.parseInt(request.getParameter("productId"));
            WishlistDAO dao = new WishlistDAO();
            
            if (dao.isInWishlist(customer.getCustomerID(), productId)) {
                out.write("{\"success\":false,\"message\":\"Sản phẩm đã có trong danh sách yêu thích\"}");
            } else {
                boolean result = dao.addToWishlist(customer.getCustomerID(), productId);
                int count = dao.countWishlist(customer.getCustomerID());
                if (result) {
                    out.write("{\"success\":true,\"message\":\"Đã thêm vào danh sách yêu thích\",\"count\":" + count + "}");
                } else {
                    out.write("{\"success\":false,\"message\":\"Không thể thêm sản phẩm\"}");
                }
            }
        } catch (NumberFormatException e) {
            out.write("{\"success\":false,\"message\":\"ID sản phẩm không hợp lệ\"}");
        }
    }

    private void removeFromWishlist(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            String wishlistIdStr = request.getParameter("wishlistId");
            String productIdStr = request.getParameter("productId");
            WishlistDAO dao = new WishlistDAO();
            boolean result;
            
            if (wishlistIdStr != null && !wishlistIdStr.isEmpty()) {
                int wishlistId = Integer.parseInt(wishlistIdStr);
                result = dao.removeById(wishlistId, customer.getCustomerID());
            } else if (productIdStr != null && !productIdStr.isEmpty()) {
                int productId = Integer.parseInt(productIdStr);
                result = dao.removeFromWishlist(customer.getCustomerID(), productId);
            } else {
                out.write("{\"success\":false,\"message\":\"Thiếu thông tin\"}");
                return;
            }
            
            int count = dao.countWishlist(customer.getCustomerID());
            if (result) {
                out.write("{\"success\":true,\"message\":\"Đã xóa khỏi danh sách yêu thích\",\"count\":" + count + "}");
            } else {
                out.write("{\"success\":false,\"message\":\"Không thể xóa sản phẩm\"}");
            }
        } catch (NumberFormatException e) {
            out.write("{\"success\":false,\"message\":\"ID không hợp lệ\"}");
        }
    }

    private void toggleWishlist(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            int productId = Integer.parseInt(request.getParameter("productId"));
            WishlistDAO dao = new WishlistDAO();
            boolean added = dao.toggleWishlist(customer.getCustomerID(), productId);
            int count = dao.countWishlist(customer.getCustomerID());
            
            if (added) {
                out.write("{\"success\":true,\"added\":true,\"message\":\"Đã thêm vào yêu thích\",\"count\":" + count + "}");
            } else {
                out.write("{\"success\":true,\"added\":false,\"message\":\"Đã xóa khỏi yêu thích\",\"count\":" + count + "}");
            }
        } catch (NumberFormatException e) {
            out.write("{\"success\":false,\"message\":\"ID sản phẩm không hợp lệ\"}");
        }
    }

    private void checkWishlist(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            int productId = Integer.parseInt(request.getParameter("productId"));
            WishlistDAO dao = new WishlistDAO();
            boolean inWishlist = dao.isInWishlist(customer.getCustomerID(), productId);
            out.write("{\"inWishlist\":" + inWishlist + "}");
        } catch (NumberFormatException e) {
            out.write("{\"inWishlist\":false}");
        }
    }

    private void countWishlist(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        WishlistDAO dao = new WishlistDAO();
        int count = dao.countWishlist(customer.getCustomerID());
        response.getWriter().write("{\"count\":" + count + "}");
    }
}
