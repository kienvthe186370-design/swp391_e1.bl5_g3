package controller;

import config.GoogleOAuthConfig;
import DAO.CustomerDAO;
import entity.Customer;
import service.GoogleOAuthService;
import service.GoogleOAuthService.GoogleUserInfo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Map;

/**
 * Servlet xử lý callback từ Google OAuth
 * Nhận authorization code, đổi lấy access token, lấy user info và đăng nhập
 */
@WebServlet(name = "GoogleCallbackServlet", urlPatterns = {"/google-callback"})
public class GoogleCallbackServlet extends HttpServlet {

    private GoogleOAuthService googleService = new GoogleOAuthService();
    private CustomerDAO customerDAO = new CustomerDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Check for error from Google
        String error = request.getParameter("error");
        if (error != null) {
            System.err.println("[GoogleCallback] Error from Google: " + error);
            response.sendRedirect("login.jsp?error=" + java.net.URLEncoder.encode("Đăng nhập Google thất bại: " + error, "UTF-8"));
            return;
        }
        
        // Get authorization code
        String code = request.getParameter("code");
        String state = request.getParameter("state");
        
        if (code == null || code.isEmpty()) {
            response.sendRedirect("login.jsp?error=" + java.net.URLEncoder.encode("Không nhận được mã xác thực từ Google", "UTF-8"));
            return;
        }
        
        // Verify state to prevent CSRF
        String savedState = (String) session.getAttribute("oauth_state");
        if (savedState == null || !savedState.equals(state)) {
            System.err.println("[GoogleCallback] State mismatch! Expected: " + savedState + ", Got: " + state);
            response.sendRedirect("login.jsp?error=" + java.net.URLEncoder.encode("Phiên đăng nhập không hợp lệ", "UTF-8"));
            return;
        }
        
        // Clear state from session
        session.removeAttribute("oauth_state");
        
        try {
            // Exchange code for access token
            String redirectUri = GoogleOAuthConfig.getRedirectUri(request);
            Map<String, String> tokens = googleService.getAccessToken(code, redirectUri);
            String accessToken = tokens.get("access_token");
            
            System.out.println("[GoogleCallback] Got access token");
            
            // Get user info from Google
            GoogleUserInfo userInfo = googleService.getUserInfo(accessToken);
            
            System.out.println("[GoogleCallback] User: " + userInfo.getEmail());
            
            // Find or create customer
            Customer customer = findOrCreateCustomer(userInfo);
            
            if (customer == null) {
                response.sendRedirect("login.jsp?error=" + java.net.URLEncoder.encode("Không thể tạo tài khoản", "UTF-8"));
                return;
            }
            
            // Check if account is active
            if (!customer.isActive()) {
                response.sendRedirect("login.jsp?error=" + java.net.URLEncoder.encode("Tài khoản đã bị khóa", "UTF-8"));
                return;
            }
            
            // Login successful - set session
            session.setAttribute("customer", customer);
            
            // Update last login
            customerDAO.updateLastLogin(customer.getCustomerID());
            
            System.out.println("[GoogleCallback] Login successful for: " + customer.getEmail());
            
            // Redirect to saved URL or home
            String redirectUrl = (String) session.getAttribute("oauth_redirect");
            session.removeAttribute("oauth_redirect");
            
            if (redirectUrl != null && !redirectUrl.isEmpty()) {
                response.sendRedirect(redirectUrl);
            } else {
                response.sendRedirect("Home");
            }
            
        } catch (Exception e) {
            System.err.println("[GoogleCallback] Error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=" + java.net.URLEncoder.encode("Lỗi đăng nhập: " + e.getMessage(), "UTF-8"));
        }
    }
    
    /**
     * Tìm customer theo Google ID hoặc email, nếu không có thì tạo mới
     */
    private Customer findOrCreateCustomer(GoogleUserInfo userInfo) {
        // 1. Tìm theo Google ID
        Customer customer = customerDAO.findByGoogleId(userInfo.getGoogleId());
        if (customer != null) {
            System.out.println("[GoogleCallback] Found customer by GoogleID");
            return customer;
        }
        
        // 2. Tìm theo email
        customer = customerDAO.getCustomerByEmail(userInfo.getEmail());
        if (customer != null) {
            // Link Google account to existing customer
            System.out.println("[GoogleCallback] Linking Google to existing account: " + userInfo.getEmail());
            customerDAO.linkGoogleAccount(customer.getCustomerID(), userInfo.getGoogleId());
            
            // Update avatar if not set
            if ((customer.getAvatar() == null || customer.getAvatar().isEmpty()) 
                && userInfo.getPicture() != null && !userInfo.getPicture().isEmpty()) {
                customerDAO.updateAvatar(customer.getCustomerID(), userInfo.getPicture());
                customer.setAvatar(userInfo.getPicture());
            }
            
            return customer;
        }
        
        // 3. Tạo customer mới
        System.out.println("[GoogleCallback] Creating new customer for: " + userInfo.getEmail());
        return customerDAO.createGoogleCustomer(
            userInfo.getGoogleId(),
            userInfo.getEmail(),
            userInfo.getName(),
            userInfo.getPicture()
        );
    }
}
