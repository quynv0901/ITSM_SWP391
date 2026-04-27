package com.itserviceflow.utils;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Properties;

public class EmailService {

    private final String username = "vietnbhe176247@fpt.edu.vn";
    private final String password = "wvyuodtqrwtjckzp";

    public void sendEmail(String to, String subject, String body) {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(username));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject);
            message.setText(body);

            Transport.send(message);
            System.out.println("Email sent successfully to " + to);
        } catch (MessagingException e) {
            e.printStackTrace();
        }
    }

    public void sendNewAccountEmail(String toEmail, String fullName, String username, String rawPassword) {
        String subject = "Tài khoản của bạn đã được tạo";
        String body = "Chào " + fullName + ",\n\n"
                + "Tài khoản của bạn đã được tạo thành công.\n\n"
                + "Thông tin đăng nhập:\n"
                + "  - Họ tên     : " + fullName + "\n"
                + "  - Email      : " + toEmail + "\n"
                + "  - Tên đăng nhập: " + username + "\n"
                + "  - Mật khẩu  : " + rawPassword + "\n\n"
                + "Vui lòng đổi mật khẩu sau khi đăng nhập lần đầu.\n\n"
                + "Trân trọng,\nIT Service Flow";
        sendEmail(toEmail, subject, body);
    }

    public void sendUpdateAccountEmail(String toEmail, String fullName,
            String oldFullName, String oldEmail,
            String newFullName, String newEmail,
            String oldRole, String newRole,
            String oldDept, String newDept) {
        StringBuilder changes = new StringBuilder();

        if (!oldFullName.equals(newFullName)) {
            changes.append("  - Họ tên   : ").append(oldFullName).append(" → ").append(newFullName).append("\n");
        }
        if (!oldEmail.equals(newEmail)) {
            changes.append("  - Email    : ").append(oldEmail).append(" → ").append(newEmail).append("\n");
        }
        if (oldRole != null && !oldRole.equals(newRole)) {
            changes.append("  - Vai trò  : ").append(oldRole).append(" → ").append(newRole).append("\n");
        }

        String od = oldDept != null ? oldDept : "N/A";
        String nd = newDept != null ? newDept : "N/A";
        if (!od.equals(nd)) {
            changes.append("  - Phòng ban: ").append(od).append(" → ").append(nd).append("\n");
        }

        String subject = "Thông tin tài khoản của bạn đã được cập nhật";
        String body = "Chào " + fullName + ",\n\n"
                + "Thông tin tài khoản của bạn vừa được cập nhật:\n\n"
                + (changes.length() > 0 ? changes.toString() : "  Không có thay đổi.\n")
                + "\nNếu bạn không yêu cầu thay đổi này, vui lòng liên hệ quản trị viên.\n\n"
                + "Trân trọng,\nIT Service Flow";
        sendEmail(toEmail, subject, body);
    }
}
