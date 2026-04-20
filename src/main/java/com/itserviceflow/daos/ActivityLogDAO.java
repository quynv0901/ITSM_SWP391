package com.itserviceflow.daos;

import com.itserviceflow.models.ActivityLog;
import com.itserviceflow.utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for the activity_log table.
 * Note: In the current database schema, this functionality is handled by the time_log table.
 * This DAO provides a dedicated interface for activity logging operations.
 */
public class ActivityLogDAO {

    /**
     * Logs an activity entry.
     * Uses the time_log table structure with activity_type and description.
     */
    public boolean logActivity(int ticketId, int userId, String activityType, String reason) {
        // Calculate time spent based on activity type (similar to TimeLogService)
        double timeSpent = calculateTimeSpentForActivity(activityType);
        
        // Build description with reason
        String description = buildActivityDescription(ticketId, activityType, timeSpent, reason);

        String sql = "INSERT INTO time_log (ticket_id, user_id, activity_type, time_spent, description) "
                + "VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, ticketId);
            stmt.setInt(2, userId);
            stmt.setString(3, activityType);
            stmt.setDouble(4, timeSpent);
            stmt.setString(5, description);

            int rows = stmt.executeUpdate();
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Gets the latest cancellation reason for a ticket from activity logs.
     */
    public String getCancelReason(int ticketId) {
        // In some flows (approve cancellation request), we log the agent-entered reason
        // under CANCEL_APPROVED while auto-log for CANCELLED may be disabled.
        // Prefer CANCELLED; fall back to CANCEL_APPROVED so end-user still sees the message.
        String reason = getLatestReasonByActivityType(ticketId, "CANCELLED");
        if (reason == null || reason.trim().isEmpty()) {
            reason = getLatestReasonByActivityType(ticketId, "CANCEL_APPROVED");
        }
        return reason;
    }

    public String getLatestReasonByActivityType(int ticketId, String activityType) {
        if (activityType == null || activityType.trim().isEmpty()) {
            return null;
        }
        String sql = "SELECT description FROM time_log "
                + "WHERE ticket_id = ? AND activity_type = ? "
                + "ORDER BY logged_at DESC LIMIT 1";
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, ticketId);
            stmt.setString(2, activityType);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    String description = rs.getString("description");
                    // Extract reason from description
                    if (description != null && description.contains("Reason:")) {
                        int startIndex = description.indexOf("Reason:") + 7;
                        String reason = description.substring(startIndex).trim();
                        // Remove any trailing text after the reason
                        if (reason.contains("|")) {
                            reason = reason.substring(0, reason.indexOf("|")).trim();
                        }
                        return reason;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Gets all activity logs for a ticket.
     */
    public List<ActivityLog> getActivityLogs(int ticketId) {
        List<ActivityLog> list = new ArrayList<>();
        String sql = "SELECT tl.*, u.full_name AS agent_name, t.ticket_number "
                + "FROM time_log tl "
                + "JOIN `user` u ON tl.user_id = u.user_id "
                + "JOIN ticket t ON tl.ticket_id = t.ticket_id "
                + "WHERE tl.ticket_id = ? "
                + "ORDER BY tl.logged_at DESC";
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, ticketId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    ActivityLog log = new ActivityLog();
                    log.setLogId(rs.getInt("log_id"));
                    log.setTicketId(rs.getInt("ticket_id"));
                    log.setUserId(rs.getInt("user_id"));
                    log.setActivityType(rs.getString("activity_type"));
                    log.setTimeSpent(rs.getDouble("time_spent"));
                    log.setDescription(rs.getString("description"));
                    log.setLoggedAt(rs.getTimestamp("logged_at"));
                    log.setAgentName(rs.getString("agent_name"));
                    log.setTicketNumber(rs.getString("ticket_number"));
                    list.add(log);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Helper methods for time calculation and description building
    private double calculateTimeSpentForActivity(String activityType) {
        // Simple time calculation for cancellation activity
        // This could be expanded to match the full TimeLogService logic
        switch (activityType.toUpperCase()) {
            case "CANCELLED":
                return 0.25; // 15 minutes for cancellation
            default:
                return 1.0;
        }
    }

    private String buildActivityDescription(int ticketId, String activityType, double timeSpent, String reason) {
        return String.format(
                "Auto-logged: [%s] on ticket #%d | Time: %.2f h | Reason: %s",
                activityType,
                ticketId,
                timeSpent,
                reason != null ? reason : "No reason provided"
        );
    }
}