package com.itserviceflow.utils;

import com.itserviceflow.models.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

public class AuthUtils {

    // Roles from database.sql
    public static final int ROLE_END_USER = 1;
    public static final int ROLE_SUPPORT_AGENT = 2;
    public static final int ROLE_MANAGER = 3;
    public static final int ROLE_GENERAL_MANAGER = 4;
    public static final int ROLE_TECHNICAL_EXPERT = 5;
    public static final int ROLE_SYSTEM_ENGINEER = 6;
    public static final int ROLE_CAB_MEMBER = 7;
    public static final int ROLE_ASSET_MANAGER = 8;
    public static final int ROLE_IT_DIRECTOR = 9;
    public static final int ROLE_ADMIN = 10;

    /**
     * Checks if the user is logged in. If not, redirects to login page.
     * 
     * @return true if logged in, false otherwise.
     */
    public static boolean isLoggedIn(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return false;
        }
        return true;
    }

    /**
     * Gets the current logged-in user.
     */
    public static User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            return (User) session.getAttribute("user");
        }
        return null;
    }

    /**
     * Checks if the user has any of the specified roles. If not, redirects to an
     * error/forbidden page or login.
     *
     * @return true if authorized, false otherwise.
     */
    public static boolean hasRole(HttpServletRequest request, HttpServletResponse response, int... allowedRoles)
            throws IOException {
        if (!isLoggedIn(request, response)) {
            return false;
        }

        User user = getCurrentUser(request);
        if (user != null && user.getRoleId() != null) {
            int userRole = user.getRoleId();
            // Admin always has access
            if (userRole == ROLE_ADMIN) {
                return true;
            }

            for (int role : allowedRoles) {
                if (userRole == role) {
                    return true;
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/auth?action=forbid");
        return false;
    }
}
