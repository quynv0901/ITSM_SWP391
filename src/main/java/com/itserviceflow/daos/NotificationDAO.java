package com.itserviceflow.daos;

import com.itserviceflow.models.Notification;
import com.itserviceflow.utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {

    public boolean createNotification(Notification n) throws SQLException {
        String sql = """
            INSERT INTO notification (user_id, notification_type, title, message, related_ticket_id, related_article_id, is_seen)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, n.getUserId());
            ps.setString(2, n.getNotificationType());
            ps.setString(3, n.getTitle());
            ps.setString(4, n.getMessage());
            
            if (n.getRelatedTicketId() != null) {
                ps.setInt(5, n.getRelatedTicketId());
            } else {
                ps.setNull(5, Types.INTEGER);
            }
            
            if (n.getRelatedArticleId() != null) {
                ps.setInt(6, n.getRelatedArticleId());
            } else {
                ps.setNull(6, Types.INTEGER);
            }
            
            ps.setBoolean(7, n.isSeen());
            return ps.executeUpdate() > 0;
        }
    }

    public List<Notification> getUnreadNotifications(int userId, int limit) throws SQLException {
        List<Notification> list = new ArrayList<>();
        String sql = """
            SELECT notification_id, user_id, notification_type, title, message, related_ticket_id, related_article_id, is_seen, created_at
            FROM notification
            WHERE user_id = ? AND is_seen = 0
            ORDER BY created_at DESC
        """;
        if (limit > 0) {
            sql += " LIMIT " + limit;
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public int countUnreadNotifications(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM notification WHERE user_id = ? AND is_seen = 0";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public boolean markAsSeen(int notificationId, int userId) throws SQLException {
        String sql = "UPDATE notification SET is_seen = 1 WHERE notification_id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean markAllAsSeen(int userId) throws SQLException {
        String sql = "UPDATE notification SET is_seen = 1 WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        }
    }

    private Notification mapRow(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setNotificationId(rs.getInt("notification_id"));
        n.setUserId(rs.getInt("user_id"));
        n.setNotificationType(rs.getString("notification_type"));
        n.setTitle(rs.getString("title"));
        n.setMessage(rs.getString("message"));
        
        int tId = rs.getInt("related_ticket_id");
        n.setRelatedTicketId(rs.wasNull() ? null : tId);
        
        int aId = rs.getInt("related_article_id");
        n.setRelatedArticleId(rs.wasNull() ? null : aId);
        
        n.setSeen(rs.getBoolean("is_seen"));
        n.setCreatedAt(rs.getTimestamp("created_at"));
        return n;
    }
}
