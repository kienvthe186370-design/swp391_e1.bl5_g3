package controller;

import DAO.CustomerDAO;
import entity.Customer;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Date;
import java.util.UUID;

@WebServlet(name = "UpdateProfileServlet", urlPatterns = {"/update-profile"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1 MB
    maxFileSize = 1024 * 1024 * 5,         // 5 MB
    maxRequestSize = 1024 * 1024 * 10      // 10 MB
)
public class UpdateProfileServlet extends HttpServlet {

    private CustomerDAO customerDAO = new CustomerDAO();
    private static final String UPLOAD_DIR = "uploads/avatars";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        
        if (customer == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("updateAvatar".equals(action)) {
            handleAvatarUpload(request, response, customer);
        } else if ("changePassword".equals(action)) {
            handleChangePassword(request, response, customer);
        } else {
            handleUpdateProfile(request, response, customer);
        }
    }
    
    private void handleUpdateProfile(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws IOException {
        
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String gender = request.getParameter("gender");
        String dobStr = request.getParameter("dateOfBirth");
        
        // Validate fullName
        if (fullName == null || fullName.trim().isEmpty()) {
            response.sendRedirect("profile?tab=profile&error=" + java.net.URLEncoder.encode("Vui lòng nhập họ tên!", "UTF-8"));
            return;
        }
        
        if (fullName.trim().length() < 2) {
            response.sendRedirect("profile?tab=profile&error=" + java.net.URLEncoder.encode("Họ tên phải có ít nhất 2 ký tự!", "UTF-8"));
            return;
        }
        
        if (fullName.trim().length() > 100) {
            response.sendRedirect("profile?tab=profile&error=" + java.net.URLEncoder.encode("Họ tên không được quá 100 ký tự!", "UTF-8"));
            return;
        }
        
        // Validate phone
        if (phone != null && !phone.trim().isEmpty()) {
            String phoneRegex = "^(0|\\+84)[0-9]{9,10}$";
            if (!phone.trim().matches(phoneRegex)) {
                response.sendRedirect("profile?tab=profile&error=" + java.net.URLEncoder.encode("Số điện thoại không hợp lệ! (VD: 0912345678)", "UTF-8"));
                return;
            }
        }
        
        // Validate gender
        if (gender != null && !gender.isEmpty()) {
            if (!gender.equals("Male") && !gender.equals("Female") && !gender.equals("Other")) {
                response.sendRedirect("profile?tab=profile&error=" + java.net.URLEncoder.encode("Giới tính không hợp lệ!", "UTF-8"));
                return;
            }
        }
        
        Date dateOfBirth = null;
        if (dobStr != null && !dobStr.trim().isEmpty()) {
            try {
                dateOfBirth = Date.valueOf(dobStr);
                // Validate date of birth is not in the future
                if (dateOfBirth.after(new Date(System.currentTimeMillis()))) {
                    response.sendRedirect("profile?tab=profile&error=" + java.net.URLEncoder.encode("Ngày sinh không thể là ngày trong tương lai!", "UTF-8"));
                    return;
                }
            } catch (IllegalArgumentException e) {
                response.sendRedirect("profile?tab=profile&error=" + java.net.URLEncoder.encode("Định dạng ngày sinh không hợp lệ!", "UTF-8"));
                return;
            }
        }
        
        boolean success = customerDAO.updateProfile(
            customer.getCustomerID(),
            fullName.trim(),
            phone != null ? phone.trim() : null,
            gender,
            dateOfBirth
        );
        
        if (success) {
            // Update session
            customer.setFullName(fullName.trim());
            customer.setPhone(phone != null ? phone.trim() : null);
            customer.setGender(gender);
            customer.setDateOfBirth(dateOfBirth);
            request.getSession().setAttribute("customer", customer);
            
            response.sendRedirect("profile?tab=profile&success=" + java.net.URLEncoder.encode("Cập nhật thông tin thành công!", "UTF-8"));
        } else {
            response.sendRedirect("profile?tab=profile&error=" + java.net.URLEncoder.encode("Cập nhật thất bại. Vui lòng thử lại.", "UTF-8"));
        }
    }
    
    private void handleAvatarUpload(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws IOException, ServletException {
        
        Part filePart = request.getPart("avatar");
        
        if (filePart == null || filePart.getSize() == 0) {
            response.sendRedirect("profile?tab=profile&error=" + java.net.URLEncoder.encode("Vui lòng chọn file ảnh.", "UTF-8"));
            return;
        }
        
        String fileName = getFileName(filePart);
        String contentType = filePart.getContentType();
        
        // Validate file type
        if (!contentType.startsWith("image/")) {
            response.sendRedirect("profile?tab=profile&error=" + java.net.URLEncoder.encode("Chỉ chấp nhận file ảnh.", "UTF-8"));
            return;
        }
        
        // Generate unique filename
        String extension = fileName.substring(fileName.lastIndexOf("."));
        String newFileName = "avatar_" + customer.getCustomerID() + "_" + UUID.randomUUID().toString().substring(0, 8) + extension;
        
        // Create upload directory
        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
        Path uploadDir = Paths.get(uploadPath);
        if (!Files.exists(uploadDir)) {
            Files.createDirectories(uploadDir);
        }
        
        // Delete old avatar if exists
        if (customer.getAvatar() != null && !customer.getAvatar().isEmpty()) {
            String oldAvatarPath = getServletContext().getRealPath("") + File.separator + customer.getAvatar();
            File oldFile = new File(oldAvatarPath);
            if (oldFile.exists()) {
                oldFile.delete();
            }
        }
        
        // Save new file
        String filePath = uploadPath + File.separator + newFileName;
        filePart.write(filePath);
        
        // Update database
        String avatarUrl = UPLOAD_DIR + "/" + newFileName;
        boolean success = customerDAO.updateAvatar(customer.getCustomerID(), avatarUrl);
        
        if (success) {
            customer.setAvatar(avatarUrl);
            request.getSession().setAttribute("customer", customer);
            response.sendRedirect("profile?tab=profile&success=" + java.net.URLEncoder.encode("Cập nhật ảnh đại diện thành công!", "UTF-8"));
        } else {
            response.sendRedirect("profile?tab=profile&error=" + java.net.URLEncoder.encode("Cập nhật ảnh thất bại.", "UTF-8"));
        }
    }
    
    private void handleChangePassword(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws IOException {
        
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        
        // Validate
        if (newPassword == null || newPassword.length() < 6) {
            response.sendRedirect("profile?tab=password&error=" + java.net.URLEncoder.encode("Mật khẩu mới phải có ít nhất 6 ký tự.", "UTF-8"));
            return;
        }
        
        if (!newPassword.equals(confirmPassword)) {
            response.sendRedirect("profile?tab=password&error=" + java.net.URLEncoder.encode("Mật khẩu xác nhận không khớp.", "UTF-8"));
            return;
        }
        
        // Verify current password
        if (!utils.PasswordUtil.verifyPassword(currentPassword, customer.getPasswordHash())) {
            response.sendRedirect("profile?tab=password&error=" + java.net.URLEncoder.encode("Mật khẩu hiện tại không đúng.", "UTF-8"));
            return;
        }
        
        // Update password
        boolean success = customerDAO.updatePassword(customer.getCustomerID(), newPassword);
        
        if (success) {
            // Update session with new password hash
            customer.setPasswordHash(utils.PasswordUtil.hashPassword(newPassword));
            request.getSession().setAttribute("customer", customer);
            response.sendRedirect("profile?tab=password&success=" + java.net.URLEncoder.encode("Đổi mật khẩu thành công!", "UTF-8"));
        } else {
            response.sendRedirect("profile?tab=password&error=" + java.net.URLEncoder.encode("Đổi mật khẩu thất bại.", "UTF-8"));
        }
    }
    
    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        for (String token : contentDisposition.split(";")) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "unknown";
    }
}
