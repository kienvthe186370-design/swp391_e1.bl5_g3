package utils;

// import java.util.Properties;
// import jakarta.mail.*;
// import jakarta.mail.internet.*;

/**
 * EmailUtil - Tiện ích gửi email
 * 
 * LƯU Ý: Để sử dụng chức năng gửi email, cần thêm thư viện Jakarta Mail:
 * 1. Download jakarta.mail-2.0.1.jar và jakarta.activation-api-2.1.0.jar
 * 2. Thêm vào thư mục lib/ của project
 * 3. Uncomment code bên dưới
 * 
 * Hiện tại: Chức năng gửi email đã được tắt, mã token sẽ được lưu trong database
 */
public class EmailUtil {
    
    private static final String FROM_EMAIL = "your-email@gmail.com";
    private static final String PASSWORD = "your-app-password";
    
    /**
     * Gửi email đơn giản
     * @param toEmail Email người nhận
     * @param subject Tiêu đề email
     * @param body Nội dung email
     * @return true nếu gửi thành công
     */
    public static boolean sendEmail(String toEmail, String subject, String body) {
        // TODO: Uncomment code bên dưới khi đã thêm thư viện Jakarta Mail
        
        /*
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        
        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM_EMAIL, PASSWORD);
            }
        });
        
        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setText(body);
            
            Transport.send(message);
            return true;
        } catch (MessagingException e) {
            e.printStackTrace();
            return false;
        }
        */
        
        // Tạm thời return false - mã token sẽ được lấy từ database
        System.out.println("=== EMAIL SIMULATION ===");
        System.out.println("To: " + toEmail);
        System.out.println("Subject: " + subject);
        System.out.println("Body: " + body);
        System.out.println("========================");
        
        return false; // Trả về false để không gửi email thật
    }
    
    /**
     * Gửi email đặt lại mật khẩu
     * @param toEmail Email người nhận
     * @param resetToken Mã token reset password
     * @return true nếu gửi thành công
     */
    public static boolean sendPasswordResetEmail(String toEmail, String resetToken) {
        String subject = "Đặt lại mật khẩu - Pickleball Shop";
        String body = "Xin chào,\n\n"
                + "Bạn đã yêu cầu đặt lại mật khẩu. Vui lòng sử dụng mã sau:\n\n"
                + "Mã xác nhận: " + resetToken + "\n\n"
                + "Mã này sẽ hết hạn sau 30 phút.\n\n"
                + "Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.\n\n"
                + "Trân trọng,\nPickleball Shop Team";
        
        return sendEmail(toEmail, subject, body);
    }
}
