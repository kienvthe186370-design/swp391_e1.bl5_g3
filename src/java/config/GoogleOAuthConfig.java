package config;

/**
 * Google OAuth 2.0 Configuration
 * 
 * SETUP: Set environment variables or edit the default values below:
 * - GOOGLE_CLIENT_ID: Your Google OAuth Client ID
 * - GOOGLE_CLIENT_SECRET: Your Google OAuth Client Secret
 */
public class GoogleOAuthConfig {
    
    // Google OAuth Credentials - Read from environment variables or use defaults
    // To set environment variables in Tomcat, add to catalina.properties or setenv.bat/sh
    public static final String CLIENT_ID = getEnvOrDefault("GOOGLE_CLIENT_ID", "");
    public static final String CLIENT_SECRET = getEnvOrDefault("GOOGLE_CLIENT_SECRET", "");
    
    private static String getEnvOrDefault(String envName, String defaultValue) {
        String value = System.getenv(envName);
        if (value != null && !value.isEmpty()) {
            return value;
        }
        // Also try system property
        value = System.getProperty(envName);
        if (value != null && !value.isEmpty()) {
            return value;
        }
        return defaultValue;
    }
    
    // Google OAuth URLs
    public static final String AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth";
    public static final String TOKEN_URL = "https://oauth2.googleapis.com/token";
    public static final String USER_INFO_URL = "https://www.googleapis.com/oauth2/v3/userinfo";
    
    // Scopes
    public static final String SCOPE = "openid email profile";
    
    /**
     * Get redirect URI based on request
     * IMPORTANT: This URI must match exactly with the one registered in Google Cloud Console
     */
    public static String getRedirectUri(jakarta.servlet.http.HttpServletRequest request) {
        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int serverPort = request.getServerPort();
        String contextPath = request.getContextPath();
        
        StringBuilder url = new StringBuilder();
        url.append(scheme).append("://").append(serverName);
        
        if ((scheme.equals("http") && serverPort != 80) || 
            (scheme.equals("https") && serverPort != 443)) {
            url.append(":").append(serverPort);
        }
        
        url.append(contextPath).append("/google-callback");
        
        System.out.println("[GoogleOAuth] Redirect URI: " + url.toString());
        
        return url.toString();
    }
    
    /**
     * Build Google OAuth authorization URL
     */
    public static String getAuthorizationUrl(jakarta.servlet.http.HttpServletRequest request, String state) {
        String redirectUri = getRedirectUri(request);
        
        return AUTH_URL + "?" +
               "client_id=" + CLIENT_ID +
               "&redirect_uri=" + java.net.URLEncoder.encode(redirectUri, java.nio.charset.StandardCharsets.UTF_8) +
               "&response_type=code" +
               "&scope=" + java.net.URLEncoder.encode(SCOPE, java.nio.charset.StandardCharsets.UTF_8) +
               "&state=" + state +
               "&access_type=offline" +
               "&prompt=consent";
    }
}
