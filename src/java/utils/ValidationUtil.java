package utils;

import java.util.regex.Pattern;
import java.util.regex.Matcher;

public class ValidationUtil {
    
    private static final String EMAIL_PATTERN = 
        "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
    
    private static final Pattern emailPattern = Pattern.compile(EMAIL_PATTERN);
    
    public static boolean isValidEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }
        
        email = email.trim();
        
        if (email.length() > 100) {
            return false;
        }
        
        Matcher matcher = emailPattern.matcher(email);
        return matcher.matches();
    }
    
    public static boolean isEmailFromDomain(String email, String domain) {
        if (!isValidEmail(email)) {
            return false;
        }
        return email.toLowerCase().endsWith("@" + domain.toLowerCase());
    }
    
    public static String getEmailDomain(String email) {
        if (!isValidEmail(email)) {
            return null;
        }
        int atIndex = email.indexOf('@');
        return email.substring(atIndex + 1);
    }
    
    private static final String PHONE_PATTERN = 
        "^(\\+84|0)[0-9]{9,10}$";
    
    private static final Pattern phonePattern = Pattern.compile(PHONE_PATTERN);
    
    public static boolean isValidPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return false;
        }
        
        phone = phone.replaceAll("[\\s-]", "");
        
        Matcher matcher = phonePattern.matcher(phone);
        return matcher.matches();
    }
    
    public static String normalizePhone(String phone) {
        if (phone == null) {
            return null;
        }
        
        phone = phone.replaceAll("[\\s-]", "");
        
        if (phone.startsWith("+84")) {
            phone = "0" + phone.substring(3);
        }
        
        return phone;
    }
    
    public static boolean isValidPassword(String password) {
        if (password == null || password.isEmpty()) {
            return false;
        }
        
        if (password.length() < 6) {
            return false;
        }
        
        if (password.length() > 50) {
            return false;
        }
        
        return true;
    }
    
    public static boolean isStrongPassword(String password) {
        if (password == null || password.length() < 8) {
            return false;
        }
        
        boolean hasUpperCase = false;
        boolean hasLowerCase = false;
        boolean hasDigit = false;
        
        for (char c : password.toCharArray()) {
            if (Character.isUpperCase(c)) hasUpperCase = true;
            if (Character.isLowerCase(c)) hasLowerCase = true;
            if (Character.isDigit(c)) hasDigit = true;
        }
        
        return hasUpperCase && hasLowerCase && hasDigit;
    }
    
    public static String getPasswordError(String password) {
        if (password == null || password.isEmpty()) {
            return "Mật khẩu không được để trống";
        }
        
        if (password.length() < 6) {
            return "Mật khẩu phải có ít nhất 6 ký tự";
        }
        
        if (password.length() > 50) {
            return "Mật khẩu không được quá 50 ký tự";
        }
        
        return null;
    }
    
    public static boolean isValidName(String name) {
        if (name == null || name.trim().isEmpty()) {
            return false;
        }
        
        name = name.trim();
        
        if (name.length() < 2 || name.length() > 100) {
            return false;
        }
        
        String namePattern = "^[\\p{L}\\s]+$";
        return name.matches(namePattern);
    }
    
    public static boolean isEmpty(String str) {
        return str == null || str.trim().isEmpty();
    }
    
    public static boolean isLengthValid(String str, int min, int max) {
        if (str == null) {
            return false;
        }
        int length = str.trim().length();
        return length >= min && length <= max;
    }
}
