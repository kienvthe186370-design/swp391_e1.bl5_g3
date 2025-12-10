package controller;

/**
 * AdminCustomerServlet đã được chuyển logic sang SellerManagerCustomerServlet.
 * Admin hiện không quản lý khách hàng nữa để tránh xung đột quyền và route.
 * Nếu cần tham khảo logic cũ, vui lòng xem SellerManagerCustomerServlet.java.
 * 
 * Servlet này giữ lại file để tránh xóa file trong dự án nhóm,
 * nhưng không còn xử lý request nào.
 */
public class AdminCustomerServlet {
    // No-op: all customer handling moved to SellerManagerCustomerServlet.
}