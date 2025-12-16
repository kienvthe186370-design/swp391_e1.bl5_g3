package service;

import config.GoogleOAuthConfig;
import org.json.JSONObject;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

/**
 * Service để xử lý Google OAuth 2.0
 */
public class GoogleOAuthService {
    
    /**
     * Đổi authorization code lấy access token
     */
    public Map<String, String> getAccessToken(String code, String redirectUri) throws Exception {
        URL url = new URL(GoogleOAuthConfig.TOKEN_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        conn.setDoOutput(true);
        
        String params = "code=" + java.net.URLEncoder.encode(code, "UTF-8") +
                       "&client_id=" + GoogleOAuthConfig.CLIENT_ID +
                       "&client_secret=" + GoogleOAuthConfig.CLIENT_SECRET +
                       "&redirect_uri=" + java.net.URLEncoder.encode(redirectUri, "UTF-8") +
                       "&grant_type=authorization_code";
        
        try (OutputStream os = conn.getOutputStream()) {
            os.write(params.getBytes(StandardCharsets.UTF_8));
        }
        
        int responseCode = conn.getResponseCode();
        System.out.println("[GoogleOAuth] Token response code: " + responseCode);
        
        if (responseCode != 200) {
            BufferedReader errorReader = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
            StringBuilder errorResponse = new StringBuilder();
            String line;
            while ((line = errorReader.readLine()) != null) {
                errorResponse.append(line);
            }
            System.err.println("[GoogleOAuth] Token error: " + errorResponse.toString());
            throw new Exception("Failed to get access token: " + errorResponse.toString());
        }
        
        BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        StringBuilder response = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            response.append(line);
        }
        
        JSONObject json = new JSONObject(response.toString());
        Map<String, String> tokens = new HashMap<>();
        tokens.put("access_token", json.getString("access_token"));
        if (json.has("refresh_token")) {
            tokens.put("refresh_token", json.getString("refresh_token"));
        }
        tokens.put("token_type", json.getString("token_type"));
        tokens.put("expires_in", String.valueOf(json.getInt("expires_in")));
        
        return tokens;
    }
    
    /**
     * Lấy thông tin user từ Google
     */
    public GoogleUserInfo getUserInfo(String accessToken) throws Exception {
        URL url = new URL(GoogleOAuthConfig.USER_INFO_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Authorization", "Bearer " + accessToken);
        
        int responseCode = conn.getResponseCode();
        System.out.println("[GoogleOAuth] UserInfo response code: " + responseCode);
        
        if (responseCode != 200) {
            throw new Exception("Failed to get user info");
        }
        
        BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        StringBuilder response = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            response.append(line);
        }
        
        JSONObject json = new JSONObject(response.toString());
        
        GoogleUserInfo userInfo = new GoogleUserInfo();
        userInfo.setGoogleId(json.getString("sub"));
        userInfo.setEmail(json.getString("email"));
        userInfo.setEmailVerified(json.optBoolean("email_verified", false));
        userInfo.setName(json.optString("name", ""));
        userInfo.setGivenName(json.optString("given_name", ""));
        userInfo.setFamilyName(json.optString("family_name", ""));
        userInfo.setPicture(json.optString("picture", ""));
        
        System.out.println("[GoogleOAuth] User info: " + userInfo);
        
        return userInfo;
    }
    
    /**
     * Inner class chứa thông tin user từ Google
     */
    public static class GoogleUserInfo {
        private String googleId;
        private String email;
        private boolean emailVerified;
        private String name;
        private String givenName;
        private String familyName;
        private String picture;
        
        // Getters and Setters
        public String getGoogleId() { return googleId; }
        public void setGoogleId(String googleId) { this.googleId = googleId; }
        
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        
        public boolean isEmailVerified() { return emailVerified; }
        public void setEmailVerified(boolean emailVerified) { this.emailVerified = emailVerified; }
        
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        
        public String getGivenName() { return givenName; }
        public void setGivenName(String givenName) { this.givenName = givenName; }
        
        public String getFamilyName() { return familyName; }
        public void setFamilyName(String familyName) { this.familyName = familyName; }
        
        public String getPicture() { return picture; }
        public void setPicture(String picture) { this.picture = picture; }
        
        @Override
        public String toString() {
            return "GoogleUserInfo{googleId='" + googleId + "', email='" + email + "', name='" + name + "'}";
        }
    }
}
