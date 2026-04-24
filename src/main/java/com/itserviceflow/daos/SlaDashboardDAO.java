package com.itserviceflow.daos;

import com.itserviceflow.utils.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SlaDashboardDAO {

    public Map<String, Object> getIncidentSlaSummary(int responseHours) {
        Map<String, Object> summary = new HashMap<>();
        String sql = "SELECT "
                + "SUM(CASE WHEN ticket_type='INCIDENT' AND status='NEW' THEN 1 ELSE 0 END) AS total_new, "
                + "SUM(CASE WHEN ticket_type='INCIDENT' AND status='NEW' "
                + "          AND TIMESTAMPDIFF(HOUR, created_at, NOW()) > ? THEN 1 ELSE 0 END) AS overdue_new, "
                + "SUM(CASE WHEN ticket_type='INCIDENT' AND status NOT IN ('CLOSED','CANCELLED') THEN 1 ELSE 0 END) AS open_incidents "
                + "FROM ticket";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, responseHours);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int totalNew = rs.getInt("total_new");
                    int overdueNew = rs.getInt("overdue_new");
                    int openIncidents = rs.getInt("open_incidents");
                    double overdueRatio = totalNew > 0 ? (overdueNew * 100.0 / totalNew) : 0.0;
                    summary.put("totalNew", totalNew);
                    summary.put("overdueNew", overdueNew);
                    summary.put("openIncidents", openIncidents);
                    summary.put("overdueRatio", overdueRatio);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return summary;
    }

    public List<Map<String, Object>> getOverdueByPriority(int responseHours) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT COALESCE(priority,'N/A') AS priority, COUNT(*) AS cnt "
                + "FROM ticket "
                + "WHERE ticket_type='INCIDENT' "
                + "  AND status='NEW' "
                + "  AND TIMESTAMPDIFF(HOUR, created_at, NOW()) > ? "
                + "GROUP BY priority "
                + "ORDER BY FIELD(priority,'URGENT','CRITICAL','HIGH','MEDIUM','NORMAL','LOW'), cnt DESC";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, responseHours);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("priority", rs.getString("priority"));
                    row.put("count", rs.getInt("cnt"));
                    list.add(row);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Map<String, Object>> getAgentPerformance(int limit) {
        return getAgentPerformance(0, limit);
    }

    public int countAgentPerformance() {
        String sql = "SELECT COUNT(*) AS total "
                + "FROM `user` u "
                + "WHERE u.role_id IN (2, 5) AND COALESCE(u.is_active, 1) = 1";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Map<String, Object>> getAgentPerformance(int offset, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT u.user_id, u.full_name, r.role_name, "
                + "       COALESCE(a.assigned_count, 0) AS assigned_count, "
                + "       COALESCE(a.resolved_count, 0) AS resolved_count, "
                + "       COALESCE(a.on_time_resolved, 0) AS on_time_resolved, "
                + "       COALESCE(a.avg_resolution_hours, 0) AS avg_resolution_hours, "
                + "       COALESCE(t.total_logged_hours, 0) AS total_logged_hours "
                + "FROM `user` u "
                + "JOIN role r ON u.role_id = r.role_id "
                + "LEFT JOIN ( "
                + "    SELECT assigned_to AS user_id, "
                + "           COUNT(*) AS assigned_count, "
                + "           SUM(CASE WHEN status IN ('RESOLVED','CLOSED') THEN 1 ELSE 0 END) AS resolved_count, "
                + "           SUM(CASE WHEN status IN ('RESOLVED','CLOSED') "
                + "                     AND TIMESTAMPDIFF(HOUR, created_at, updated_at) <= "
                + "                         CASE UPPER(COALESCE(priority,'')) "
                + "                           WHEN 'URGENT' THEN 24 "
                + "                           WHEN 'CRITICAL' THEN 24 "
                + "                           WHEN 'HIGH' THEN 120 "
                + "                           WHEN 'MEDIUM' THEN 336 "
                + "                           WHEN 'NORMAL' THEN 336 "
                + "                           WHEN 'LOW' THEN 672 "
                + "                           ELSE 336 END "
                + "                    THEN 1 ELSE 0 END) AS on_time_resolved, "
                + "           AVG(CASE WHEN status IN ('RESOLVED','CLOSED') THEN TIMESTAMPDIFF(HOUR, created_at, updated_at) END) AS avg_resolution_hours "
                + "    FROM ticket "
                + "    WHERE ticket_type = 'INCIDENT' AND assigned_to IS NOT NULL "
                + "    GROUP BY assigned_to "
                + ") a ON a.user_id = u.user_id "
                + "LEFT JOIN ( "
                + "    SELECT user_id, SUM(time_spent) AS total_logged_hours "
                + "    FROM time_log GROUP BY user_id "
                + ") t ON t.user_id = u.user_id "
                + "WHERE u.role_id IN (2, 5) AND COALESCE(u.is_active, 1) = 1 "
                + "ORDER BY on_time_resolved DESC, resolved_count DESC, total_logged_hours DESC "
                + "LIMIT ? OFFSET ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            int safeLimit = Math.max(1, Math.min(limit, 100));
            int safeOffset = Math.max(0, offset);
            ps.setInt(1, safeLimit);
            ps.setInt(2, safeOffset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    int assigned = rs.getInt("assigned_count");
                    int onTimeResolved = rs.getInt("on_time_resolved");
                    double onTimeRate = assigned > 0 ? (onTimeResolved * 100.0 / assigned) : 0.0;
                    row.put("userId", rs.getInt("user_id"));
                    row.put("fullName", rs.getString("full_name"));
                    row.put("roleName", rs.getString("role_name"));
                    row.put("assignedCount", assigned);
                    row.put("resolvedCount", rs.getInt("resolved_count"));
                    row.put("onTimeResolved", onTimeResolved);
                    row.put("onTimeRate", onTimeRate);
                    row.put("avgResolutionHours", rs.getDouble("avg_resolution_hours"));
                    row.put("totalLoggedHours", rs.getDouble("total_logged_hours"));
                    list.add(row);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Map<String, Object>> getOverdueNewIncidents(int responseHours, int limit) {
        return getOverdueNewIncidents(responseHours, 0, limit);
    }

    public int countOverdueNewIncidents(int responseHours) {
        return countOverdueNewIncidents(responseHours, false);
    }

    public int countOverdueNewIncidents(int responseHours, boolean onlyUnassigned) {
        String sql = "SELECT COUNT(*) AS total "
                + "FROM ticket t "
                + "WHERE t.ticket_type='INCIDENT' "
                + "  AND t.status='NEW' "
                + "  AND TIMESTAMPDIFF(HOUR, t.created_at, NOW()) > ? "
                + (onlyUnassigned ? "AND t.assigned_to IS NULL " : "");
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, responseHours);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Map<String, Object>> getOverdueNewIncidents(int responseHours, int offset, int limit) {
        return getOverdueNewIncidents(responseHours, false, offset, limit);
    }

    public List<Map<String, Object>> getOverdueNewIncidents(int responseHours, boolean onlyUnassigned, int offset, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT t.ticket_id, t.ticket_number, t.title, t.priority, t.status, t.assigned_to, "
                + "       TIMESTAMPDIFF(HOUR, t.created_at, NOW()) AS age_hours, "
                + "       u.full_name AS reporter_name, "
                + "       au.full_name AS assignee_name "
                + "FROM ticket t "
                + "LEFT JOIN `user` u ON t.reported_by = u.user_id "
                + "LEFT JOIN `user` au ON t.assigned_to = au.user_id "
                + "WHERE t.ticket_type='INCIDENT' "
                + "  AND t.status='NEW' "
                + "  AND TIMESTAMPDIFF(HOUR, t.created_at, NOW()) > ? "
                + (onlyUnassigned ? "AND t.assigned_to IS NULL " : "")
                + "ORDER BY age_hours DESC "
                + "LIMIT ? OFFSET ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            int safeLimit = Math.max(1, Math.min(limit, 100));
            int safeOffset = Math.max(0, offset);
            ps.setInt(1, responseHours);
            ps.setInt(2, safeLimit);
            ps.setInt(3, safeOffset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("ticketId", rs.getInt("ticket_id"));
                    row.put("ticketNumber", rs.getString("ticket_number"));
                    row.put("title", rs.getString("title"));
                    row.put("priority", rs.getString("priority"));
                    row.put("status", rs.getString("status"));
                    row.put("ageHours", rs.getInt("age_hours"));
                    row.put("reporterName", rs.getString("reporter_name"));
                    row.put("assignedTo", rs.getObject("assigned_to"));
                    row.put("assigneeName", rs.getString("assignee_name"));
                    list.add(row);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Map<String, Object>> getAssignableAgents() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT u.user_id, u.full_name, r.role_name "
                + "FROM `user` u "
                + "JOIN role r ON u.role_id = r.role_id "
                + "WHERE u.role_id IN (2, 5) AND COALESCE(u.is_active, 1) = 1 "
                + "ORDER BY u.full_name ASC";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("userId", rs.getInt("user_id"));
                row.put("fullName", rs.getString("full_name"));
                row.put("roleName", rs.getString("role_name"));
                list.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countFeedback(Integer ratingFilter) {
        String sql = "SELECT COUNT(*) AS total FROM feedback f "
                + "JOIN ticket t ON f.ticket_id = t.ticket_id "
                + "WHERE t.ticket_type = 'INCIDENT' "
                + (ratingFilter != null ? "AND f.rating = ? " : "");
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            if (ratingFilter != null) {
                ps.setInt(1, ratingFilter);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Map<String, Object>> getFeedbackList(Integer ratingFilter, int offset, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT f.feedback_id, f.ticket_id, t.ticket_number, t.title, f.rating, f.feedback_text, "
                + "f.submitted_at, "
                + "u.full_name AS user_name, a.full_name AS agent_name "
                + "FROM feedback f "
                + "JOIN ticket t ON f.ticket_id = t.ticket_id "
                + "JOIN `user` u ON f.user_id = u.user_id "
                + "LEFT JOIN `user` a ON f.agent_id = a.user_id "
                + "WHERE t.ticket_type = 'INCIDENT' "
                + (ratingFilter != null ? "AND f.rating = ? " : "")
                + "ORDER BY f.submitted_at DESC "
                + "LIMIT ? OFFSET ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            if (ratingFilter != null) {
                ps.setInt(idx++, ratingFilter);
            }
            int safeLimit = Math.max(1, Math.min(limit, 100));
            int safeOffset = Math.max(0, offset);
            ps.setInt(idx++, safeLimit);
            ps.setInt(idx, safeOffset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("feedbackId", rs.getInt("feedback_id"));
                    row.put("ticketId", rs.getInt("ticket_id"));
                    row.put("ticketNumber", rs.getString("ticket_number"));
                    row.put("title", rs.getString("title"));
                    row.put("rating", rs.getInt("rating"));
                    row.put("feedbackText", rs.getString("feedback_text"));
                    row.put("submittedAt", rs.getTimestamp("submitted_at"));
                    row.put("userName", rs.getString("user_name"));
                    row.put("agentName", rs.getString("agent_name"));
                    list.add(row);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
