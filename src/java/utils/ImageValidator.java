package utils;

import jakarta.servlet.http.Part;
import java.util.Arrays;
import java.util.List;

/**
 * ImageValidator - Utility class để validate ảnh upload phía server
 * 
 * Sử dụng:
 * Part imagePart = request.getPart("productImage");
 * ImageValidator.ValidationResult result = ImageValidator.validate(imagePart);
 * if (!result.isValid()) {
 *     // Handle error: result.getError()
 * }
 * 
 * @author Auto-generated from spec
 * @version 1.0
 */
public class ImageValidator {
    
    // Định dạng cho phép
    private static final List<String> ALLOWED_EXTENSIONS = Arrays.asList("jpg", "jpeg", "png", "gif");
    private static final List<String> ALLOWED_MIME_TYPES = Arrays.asList("image/jpeg", "image/png", "image/gif");
    
    // Kích thước tối đa (2MB)
    private static final long MAX_SIZE = 2 * 1024 * 1024;
    
    /**
     * Validate file ảnh từ Part (Servlet 3.0+)
     * @param part - Part object từ request.getPart()
     * @return ValidationResult
     */
    public static ValidationResult validate(Part part) {
        // Kiểm tra part có tồn tại và có dữ liệu không
        if (part == null || part.getSize() == 0) {
            return new ValidationResult(false, "Vui lòng chọn file ảnh.");
        }
        
        // Lấy tên file
        String fileName = getFileName(part);
        if (fileName == null || fileName.isEmpty()) {
            return new ValidationResult(false, "Vui lòng chọn file ảnh.");
        }
        
        // Kiểm tra MIME type
        String contentType = part.getContentType();
        if (contentType == null || !ALLOWED_MIME_TYPES.contains(contentType.toLowerCase())) {
            return new ValidationResult(false, "Định dạng không hợp lệ. Chỉ chấp nhận: JPG, PNG, GIF");
        }
        
        // Kiểm tra extension
        String extension = getFileExtension(fileName);
        if (!ALLOWED_EXTENSIONS.contains(extension.toLowerCase())) {
            return new ValidationResult(false, "Định dạng không hợp lệ. Chỉ chấp nhận: JPG, PNG, GIF");
        }
        
        // Kiểm tra MIME type và extension có khớp nhau không (bảo mật)
        if (!isMimeTypeMatchExtension(contentType, extension)) {
            return new ValidationResult(false, "Định dạng file không khớp. Vui lòng chọn file ảnh hợp lệ.");
        }
        
        // Kiểm tra kích thước
        if (part.getSize() > MAX_SIZE) {
            double sizeMB = part.getSize() / (1024.0 * 1024.0);
            return new ValidationResult(false, 
                String.format("Kích thước file (%.2fMB) vượt quá giới hạn 2MB.", sizeMB));
        }
        
        return new ValidationResult(true, null);
    }
    
    /**
     * Validate file ảnh với custom max size
     * @param part - Part object từ request.getPart()
     * @param maxSizeBytes - Kích thước tối đa (bytes)
     * @return ValidationResult
     */
    public static ValidationResult validate(Part part, long maxSizeBytes) {
        // Kiểm tra part có tồn tại và có dữ liệu không
        if (part == null || part.getSize() == 0) {
            return new ValidationResult(false, "Vui lòng chọn file ảnh.");
        }
        
        // Lấy tên file
        String fileName = getFileName(part);
        if (fileName == null || fileName.isEmpty()) {
            return new ValidationResult(false, "Vui lòng chọn file ảnh.");
        }
        
        // Kiểm tra MIME type
        String contentType = part.getContentType();
        if (contentType == null || !ALLOWED_MIME_TYPES.contains(contentType.toLowerCase())) {
            return new ValidationResult(false, "Định dạng không hợp lệ. Chỉ chấp nhận: JPG, PNG, GIF");
        }
        
        // Kiểm tra extension
        String extension = getFileExtension(fileName);
        if (!ALLOWED_EXTENSIONS.contains(extension.toLowerCase())) {
            return new ValidationResult(false, "Định dạng không hợp lệ. Chỉ chấp nhận: JPG, PNG, GIF");
        }
        
        // Kiểm tra MIME type và extension có khớp nhau không (bảo mật)
        if (!isMimeTypeMatchExtension(contentType, extension)) {
            return new ValidationResult(false, "Định dạng file không khớp. Vui lòng chọn file ảnh hợp lệ.");
        }
        
        // Kiểm tra kích thước
        if (part.getSize() > maxSizeBytes) {
            double sizeMB = part.getSize() / (1024.0 * 1024.0);
            double maxSizeMB = maxSizeBytes / (1024.0 * 1024.0);
            return new ValidationResult(false, 
                String.format("Kích thước file (%.2fMB) vượt quá giới hạn %.0fMB.", sizeMB, maxSizeMB));
        }
        
        return new ValidationResult(true, null);
    }
    
    /**
     * Kiểm tra MIME type có khớp với extension không
     */
    private static boolean isMimeTypeMatchExtension(String mimeType, String extension) {
        if (mimeType == null || extension == null) {
            return false;
        }
        
        mimeType = mimeType.toLowerCase();
        extension = extension.toLowerCase();
        
        // JPEG
        if (mimeType.equals("image/jpeg")) {
            return extension.equals("jpg") || extension.equals("jpeg");
        }
        // PNG
        if (mimeType.equals("image/png")) {
            return extension.equals("png");
        }
        // GIF
        if (mimeType.equals("image/gif")) {
            return extension.equals("gif");
        }
        
        return false;
    }
    
    /**
     * Lấy tên file từ Part
     */
    public static String getFileName(Part part) {
        if (part == null) {
            return "";
        }
        
        String contentDisposition = part.getHeader("content-disposition");
        if (contentDisposition == null) {
            return "";
        }
        
        for (String token : contentDisposition.split(";")) {
            if (token.trim().startsWith("filename")) {
                String fileName = token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
                // Handle path in filename (some browsers send full path)
                int lastSlash = Math.max(fileName.lastIndexOf('/'), fileName.lastIndexOf('\\'));
                if (lastSlash >= 0) {
                    fileName = fileName.substring(lastSlash + 1);
                }
                return fileName;
            }
        }
        return "";
    }
    
    /**
     * Lấy extension từ tên file
     */
    public static String getFileExtension(String fileName) {
        if (fileName == null || fileName.isEmpty()) {
            return "";
        }
        
        int lastDot = fileName.lastIndexOf('.');
        if (lastDot > 0 && lastDot < fileName.length() - 1) {
            return fileName.substring(lastDot + 1);
        }
        return "";
    }
    
    /**
     * Kiểm tra file có phải là ảnh hợp lệ không (quick check)
     */
    public static boolean isValidImage(Part part) {
        return validate(part).isValid();
    }
    
    /**
     * Inner class để trả về kết quả validation
     */
    public static class ValidationResult {
        private final boolean valid;
        private final String error;
        
        public ValidationResult(boolean valid, String error) {
            this.valid = valid;
            this.error = error;
        }
        
        public boolean isValid() { 
            return valid; 
        }
        
        public String getError() { 
            return error; 
        }
        
        @Override
        public String toString() {
            return "ValidationResult{valid=" + valid + ", error='" + error + "'}";
        }
    }
}
