package com.itserviceflow.filter;

import com.itserviceflow.models.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebFilter("/*")
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);
        String path = req.getRequestURI().substring(req.getContextPath().length());

        // Bypass for static resources and auth pages
        if (isPublicPath(req, path)) {
            chain.doFilter(request, response);
            return;
        }

        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            res.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        if (path.startsWith("/admin/") && (user.getRoleId() == null || user.getRoleId() != 10)) {
            res.sendRedirect(req.getContextPath() + "/auth?action=forbid");
            return;
        }

        if (path.startsWith("/support-agent/") && (user.getRoleId() == null
                || (user.getRoleId() != 10 && user.getRoleId() != 2
                && user.getRoleId() != 3 && user.getRoleId() != 4))) {
            res.sendRedirect(req.getContextPath() + "/auth?action=forbid");
            return;
        }
        chain.doFilter(request, response);
    }

    private boolean isPublicPath(HttpServletRequest req, String path) {
        // Static resources
        if (path.startsWith("/assets/")
                || path.startsWith("/css/")
                || path.startsWith("/js/")
                || path.startsWith("/img/")) {
            return true;
        }

        // Auth servlet: /auth?action=login | forgotPassword | resetPassword
        if (path.equals("/auth")) {
            String action = req.getParameter("action");
            return action == null
                    || action.equals("login")
                    || action.equals("forgotPassword")
                    || action.equals("resetPassword");
        }

        return false;
    }
}
