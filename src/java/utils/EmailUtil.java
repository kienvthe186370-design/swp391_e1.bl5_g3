package utils;

import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.mail.*;
import jakarta.mail.internet.*;

public class EmailUtil {

    private static final String FROM_EMAIL = "anhnq2792004@gmail.com";  // Email gmail của mình 
    private static final String APP_PASSWORD = "giqk rubb vthj zemt"; // App Password của google tại đâyyy
    private static final String FROM_NAME = "Pickleball Shop";
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";

    public static boolean sendEmail(String toEmail, String subject, String body) {
        return sendEmail(toEmail, subject, body, false);
    }

    public static boolean sendEmail(String toEmail, String subject, String body, boolean isHtml) {
        Properties props = new Properties();
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        props.put("mail.smtp.ssl.trust", SMTP_HOST);

        Thread.currentThread().setContextClassLoader(EmailUtil.class.getClassLoader());

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM_EMAIL, APP_PASSWORD);
            }
        });

        try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL, FROM_NAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject, "UTF-8");

            if (isHtml) {
                MimeBodyPart mimeBodyPart = new MimeBodyPart();
                mimeBodyPart.setContent(body, "text/html; charset=UTF-8");

                MimeMultipart multipart = new MimeMultipart();
                multipart.addBodyPart(mimeBodyPart);

                message.setContent(multipart);
            } else {
                message.setText(body, "UTF-8");
            }

            Transport.send(message);

            System.out.println("=== EMAIL SENT SUCCESSFULLY ===");
            System.out.println("To: " + toEmail);
            System.out.println("Subject: " + subject);
            System.out.println("===============================");

            return true;
        } catch (Exception e) {
            Logger.getLogger(EmailUtil.class.getName()).log(Level.SEVERE,
                    "Lỗi gửi email đến " + toEmail, e);

            System.out.println("=== EMAIL SEND FAILED ===");
            System.out.println("To: " + toEmail);
            System.out.println("Error: " + e.getMessage());
            System.out.println("=========================");

            return false;
        }
    }

    public static boolean sendVerificationOTP(String toEmail, String otpCode) {
        String subject = "🎾 Kích hoạt tài khoản - Pickleball Shop";

        String htmlBody = buildOTPEmailTemplate(
                "Chào mừng bạn đến với Pickleball Shop!",
                "Cảm ơn bạn đã đăng ký tài khoản. Vui lòng sử dụng mã OTP bên dưới để kích hoạt tài khoản của bạn.",
                otpCode,
                "10 phút",
                "#28a745"
        );

        return sendEmail(toEmail, subject, htmlBody, true);
    }

    public static boolean sendPasswordResetOTP(String toEmail, String otpCode) {
        String subject = "🔐 Đặt lại mật khẩu - Pickleball Shop";

        String htmlBody = buildOTPEmailTemplate(
                "Yêu cầu đặt lại mật khẩu",
                "Bạn đã yêu cầu đặt lại mật khẩu cho tài khoản của mình. Vui lòng sử dụng mã OTP bên dưới.",
                otpCode,
                "5 phút",
                "#dc3545"
        );
        return sendEmail(toEmail, subject, htmlBody, true);
    }

    public static boolean sendPasswordResetEmail(String toEmail, String resetToken) {
        return sendPasswordResetOTP(toEmail, resetToken);
    }

    private static String buildOTPEmailTemplate(String title, String message, String otpCode, String expiry, String accentColor) {
        return "<!DOCTYPE html>"
                + "<html>"
                + "<head>"
                + "<meta charset='UTF-8'>"
                + "<meta name='viewport' content='width=device-width, initial-scale=1.0'>"
                + "</head>"
                + "<body style='margin:0;padding:0;font-family:Arial,sans-serif;background-color:#f4f4f4;'>"
                + "<table width='100%' cellpadding='0' cellspacing='0' style='max-width:600px;margin:0 auto;background-color:#ffffff;'>"
                + "<tr>"
                + "<td style='background-color:" + accentColor + ";padding:30px;text-align:center;'>"
                + "<h1 style='color:#ffffff;margin:0;font-size:24px;'>🎾 Pickleball Shop</h1>"
                + "</td>"
                + "</tr>"
                + "<tr>"
                + "<td style='padding:40px 30px;'>"
                + "<h2 style='color:#333333;margin:0 0 20px 0;font-size:22px;'>" + title + "</h2>"
                + "<p style='color:#666666;font-size:16px;line-height:1.6;margin:0 0 30px 0;'>" + message + "</p>"
                + "<div style='background-color:#f8f9fa;border-radius:10px;padding:30px;text-align:center;margin:0 0 30px 0;'>"
                + "<p style='color:#666666;font-size:14px;margin:0 0 10px 0;'>Mã xác nhận của bạn:</p>"
                + "<div style='font-size:36px;font-weight:bold;color:" + accentColor + ";letter-spacing:8px;font-family:monospace;'>" + otpCode + "</div>"
                + "<p style='color:#999999;font-size:12px;margin:15px 0 0 0;'>Mã này sẽ hết hạn sau " + expiry + "</p>"
                + "</div>"
                + "<p style='color:#999999;font-size:14px;line-height:1.6;margin:0;'>"
                + "⚠️ Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email này."
                + "</p>"
                + "</td>"
                + "</tr>"
                + "<tr>"
                + "<td style='background-color:#f8f9fa;padding:20px 30px;text-align:center;border-top:1px solid #eeeeee;'>"
                + "<p style='color:#999999;font-size:12px;margin:0;'>"
                + "© 2024 Pickleball Shop Vietnam. All rights reserved."
                + "</p>"
                + "</td>"
                + "</tr>"
                + "</table>"
                + "</body>"
                + "</html>";
    }

    public static void main(String[] args) {
        EmailUtil em = new EmailUtil();
    }
}
