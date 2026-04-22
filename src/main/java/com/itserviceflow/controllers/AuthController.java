package com.itserviceflow.controllers;

import com.itserviceflow.daos.UserDAO;
import com.itserviceflow.models.User;
import com.itserviceflow.utils.EmailService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.UUID;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet(name = "AuthController", urlPatterns = {"/auth", "/profile"})
public class AuthController extends HttpServlet {

    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/profile".equals(path)) {
            profileView(request, response);
            return;
        }

        String action = request.getParameter("action");
        action = (action == null) ? "login" : action;

        switch (action) {
            case "login":
                loginView(request, response);
                break;
            case "logout":
                logout(request, response);
                break;
            case "forgotPassword":
                forgotPasswordView(request, response);
                break;
            case "resetPassword":
                resetPasswordView(request, response);
                break;
            case "forbid":
                forbidView(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/auth?action=login");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        String action = request.getParameter("action");
        action = (action == null) ? "login" : action;

        if ("/profile".equals(path)) {
            switch (action) {
                case "updateProfile":
                    updateProfile(request, response);
                    break;
                case "changePassword":
                    changePassword(request, response);
                    break;
                default:
                    profileView(request, response);
            }
            return;
        }

        switch (action) {
            case "login":
                login(request, response);
                break;
            case "forgotPassword":
                forgotPassword(request, response);
                break;
            case "resetPassword":
                resetPassword(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/auth?action=login");
        }
    }

    // ===================== VIEW HANDLERS =====================
    private void loginView(HttpServletRequest request, HttpServletResponse response) {
        try {
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
        } catch (Exception e) {
            System.out.println("loginView error: " + e);
        }
    }

    private void forgotPasswordView(HttpServletRequest request, HttpServletResponse response) {
        try {
            request.getRequestDispatcher("/auth/forgot_password.jsp").forward(request, response);
        } catch (Exception e) {
            System.out.println("forgotPasswordView error: " + e);
        }
    }

    private void resetPasswordView(HttpServletRequest request, HttpServletResponse response) {
        try {
            String token = request.getParameter("token");
            if (token == null || token.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/auth?action=login");
                return;
            }
            User user = userDAO.findByResetToken(token);
            if (user == null) {
                request.setAttribute("error", "Mã xác thực không hợp lệ hoặc đã hết hạn!");
            } else {
                request.setAttribute("token", token);
            }
            request.getRequestDispatcher("/auth/reset_password.jsp").forward(request, response);
        } catch (Exception e) {
            System.out.println("resetPasswordView error: " + e);
        }
    }

    private void forbidView(HttpServletRequest request, HttpServletResponse response) {
        try {
            request.getRequestDispatcher("/auth/forbid.jsp").forward(request, response);
        } catch (Exception e) {
            System.out.println("forbidView error: " + e);
        }
    }

    private void profileView(HttpServletRequest request, HttpServletResponse response) {
        try {
            User sessionUser = (User) request.getSession().getAttribute("user");
            User currentUser = userDAO.findById(sessionUser.getUserId());
            request.setAttribute("currentUser", currentUser);
            request.getRequestDispatcher("/user/profile.jsp").forward(request, response);
        } catch (Exception e) {
            System.out.println("profileView error: " + e);
        }
    }

    // ===================== ACTION HANDLERS =====================
    private void login(HttpServletRequest request, HttpServletResponse response) {
        try {
            String username = request.getParameter("username");
            String password = request.getParameter("password");

            if (username == null || password == null || username.isEmpty() || password.isEmpty()) {
                request.setAttribute("error", "Vui lòng nhập đầy đủ thông tin!");
                request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
                return;
            }

            User user = userDAO.login(username, password);
            if (user != null) {
                HttpSession session = request.getSession();
                session.setAttribute("user", user);
                session.setAttribute("dalogin", user);

                if (user.getRoleId() != null && user.getRoleId() == 10) {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                } else {
                    response.sendRedirect(request.getContextPath() + "/home");
                }
            } else {
                request.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không đúng!");
                request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
            }
        } catch (Exception e) {
            System.out.println("login error: " + e);
        }
    }

    private void logout(HttpServletRequest request, HttpServletResponse response) {
        try {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/auth?action=login&logout=success");
        } catch (Exception e) {
            System.out.println("logout error: " + e);
        }
    }

    private void forgotPassword(HttpServletRequest request, HttpServletResponse response) {
        try {
            String email = request.getParameter("email");

            if (email == null || email.isEmpty()) {
                request.setAttribute("error", "Vui lòng nhập email!");
                request.getRequestDispatcher("/auth/forgot_password.jsp").forward(request, response);
                return;
            }

            User user = userDAO.findByEmail(email);
            if (user != null) {
                String token = UUID.randomUUID().toString();
                LocalDateTime expiry = LocalDateTime.now().plusHours(1);
                userDAO.updateResetToken(email, token, expiry);

                String resetLink = request.getScheme() + "://" + request.getServerName()
                        + ":" + request.getServerPort()
                        + request.getContextPath()
                        + "/auth?action=resetPassword&token=" + token;

                EmailService emailService = new EmailService();
                emailService.sendEmail(email, "Reset Password - ITServiceFlow",
                        "Xin chào, vui lòng nhấn vào link sau để đặt lại mật khẩu: " + resetLink);

                request.setAttribute("message", "Yêu cầu đã được gửi. Vui lòng kiểm tra email của bạn.");
            } else {
                request.setAttribute("error", "Email không tồn tại trong hệ thống!");
            }

            request.getRequestDispatcher("/auth/forgot_password.jsp").forward(request, response);
        } catch (Exception e) {
            System.out.println("forgotPassword error: " + e);
        }
    }

    private void resetPassword(HttpServletRequest request, HttpServletResponse response) {
        try {
            String token = request.getParameter("token");
            String newPass = request.getParameter("password");
            String confirmPass = request.getParameter("confirm_password");

            // ✅ Validate độ dài mật khẩu
            if (newPass == null || newPass.length() < 8) {
                request.setAttribute("error", "Mật khẩu phải có ít nhất 8 ký tự!");
                request.setAttribute("token", token);
                request.getRequestDispatcher("/auth/reset_password.jsp").forward(request, response);
                return;
            }

            if (!newPass.equals(confirmPass)) {
                request.setAttribute("error", "Mật khẩu không khớp!");
                request.setAttribute("token", token);
                request.getRequestDispatcher("/auth/reset_password.jsp").forward(request, response);
                return;
            }

            User user = userDAO.findByResetToken(token);
            if (user != null) {
                userDAO.updatePassword(user.getUserId(), newPass);
                response.sendRedirect(request.getContextPath() + "/auth?action=login&reset=success");
            } else {
                request.setAttribute("error", "Mã xác thực không hợp lệ hoặc đã hết hạn!");
                request.getRequestDispatcher("/auth/reset_password.jsp").forward(request, response);
            }
        } catch (Exception e) {
            System.out.println("resetPassword error: " + e);
        }
    }

    private void updateProfile(HttpServletRequest request, HttpServletResponse response) {
        try {
            User sessionUser = (User) request.getSession().getAttribute("user");
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");

            User u = new User();
            u.setUserId(sessionUser.getUserId());
            u.setFullName(fullName);
            u.setPhone(phone);

            if (userDAO.updateProfile(u)) {
                sessionUser.setFullName(fullName);
                sessionUser.setPhone(phone);
                request.setAttribute("message", "Cập nhật thông tin thành công!");
            } else {
                request.setAttribute("error", "Cập nhật thất bại!");
            }
            profileView(request, response);
        } catch (Exception e) {
            System.out.println("updateProfile error: " + e);
        }
    }

    private void changePassword(HttpServletRequest request, HttpServletResponse response) {
        try {
            User sessionUser = (User) request.getSession().getAttribute("user");
            String currentPass = request.getParameter("currentPassword");
            String newPass = request.getParameter("newPassword");
            String confirmPass = request.getParameter("confirmPassword");

            if (newPass == null || !newPass.equals(confirmPass)) {
                request.setAttribute("error", "Mật khẩu xác nhận không khớp!");
                profileView(request, response);
                return;
            }

            User userFromDb = userDAO.findById(sessionUser.getUserId());
            if (BCrypt.checkpw(currentPass, userFromDb.getPasswordHash())) {
                userDAO.updatePassword(sessionUser.getUserId(), newPass);
                request.setAttribute("message", "Đổi mật khẩu thành công!");
            } else {
                request.setAttribute("error", "Mật khẩu hiện tại không đúng!");
            }
            profileView(request, response);
        } catch (Exception e) {
            System.out.println("changePassword error: " + e);
        }
    }

    @Override
    public String getServletInfo() {
        return "AuthController - Handles login, logout, forgot/reset password, profile";
    }
}
