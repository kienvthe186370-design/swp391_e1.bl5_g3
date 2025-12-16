package controller;

import config.GoogleOAuthConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.UUID;

/**
 * Servlet khởi tạo luồng đăng nhập Google
 * Redirect user đến Google OAuth consent screen
 */
@WebServlet(name = "GoogleLoginServlet", urlPatterns = {"/google-login"})
public class GoogleLoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Generate state token để chống CSRF
        String state = UUID.randomUUID().toString();
        request.getSession().setAttribute("oauth_state", state);
        
        // Lưu redirect URL nếu có
        String redirect = request.getParameter("redirect");
        if (redirect != null && !redirect.isEmpty()) {
            request.getSession().setAttribute("oauth_redirect", redirect);
        }
        
        // Build authorization URL và redirect
        String authUrl = GoogleOAuthConfig.getAuthorizationUrl(request, state);
        
        System.out.println("[GoogleLogin] Redirecting to: " + authUrl);
        response.sendRedirect(authUrl);
    }
}
