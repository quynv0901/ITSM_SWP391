package com.itserviceflow.controllers;

import com.google.gson.Gson;
import com.itserviceflow.daos.NotificationDAO;
import com.itserviceflow.models.Notification;
import com.itserviceflow.models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/notifications")
public class NotificationServlet extends HttpServlet {

    private final NotificationDAO notificationDAO = new NotificationDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing action");
            return;
        }

        User currentUser = (User) request.getSession().getAttribute("user");
        if (currentUser == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
            return;
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try (PrintWriter out = response.getWriter()) {
            if ("api-get-unread".equals(action)) {
                int limit = 5;
                String limitParam = request.getParameter("limit");
                if (limitParam != null) {
                    try { limit = Integer.parseInt(limitParam); } catch (NumberFormatException ignored) {}
                }
                
                List<Notification> unreadList = notificationDAO.getUnreadNotifications(currentUser.getUserId(), limit);
                int count = notificationDAO.countUnreadNotifications(currentUser.getUserId());
                
                Map<String, Object> result = new HashMap<>();
                result.put("count", count);
                result.put("notifications", unreadList);
                
                out.print(gson.toJson(result));
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
            }
        } catch (SQLException e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing action");
            return;
        }

        User currentUser = (User) request.getSession().getAttribute("user");
        if (currentUser == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
            return;
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try (PrintWriter out = response.getWriter()) {
            Map<String, Object> result = new HashMap<>();
            if ("api-mark-seen".equals(action)) {
                String idParam = request.getParameter("id");
                if ("all".equals(idParam)) {
                    boolean success = notificationDAO.markAllAsSeen(currentUser.getUserId());
                    result.put("success", success);
                } else {
                    int notificationId = Integer.parseInt(idParam);
                    boolean success = notificationDAO.markAsSeen(notificationId, currentUser.getUserId());
                    result.put("success", success);
                }
                out.print(gson.toJson(result));
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
            }
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error marking notification");
        }
    }
}
