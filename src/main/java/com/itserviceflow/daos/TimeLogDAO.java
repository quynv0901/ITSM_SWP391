package com.itserviceflow.daos;

import com.itserviceflow.models.TimeLog;
import com.itserviceflow.utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * DAO for the time_log table.
 */
public class TimeLogDAO {

    /**
     * Inserts a new time log entry.
     */
    public boolean insertLog(TimeLog log) {
        String sql = "INSERT INTO time_log (ticket_id, user_id, activity_type, time_spent, description) "
                + "VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, log.getTicketId());
            stmt.setInt(2, log.getUserId());
            stmt.setString(3, log.getActivityType());
            stmt.setDouble(4, log.getTimeSpent());
            stmt.setString(5, log.getDescription());

            int rows = stmt.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (keys.next()) {
                        log.setLogId(keys.getInt(1));
                    }
                }
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Returns all time log entries for a given ticket, ordered newest first.
     * Joins with user table to get agent name.
     */
    public List<TimeLog> getLogsByTicketId(int ticketId) {
        List<TimeLog> list = new ArrayList<>();
        String sql = "SELECT tl.*, u.full_name AS agent_name, t.ticket_number "
                + "FROM time_log tl "
                + "JOIN `user` u ON tl.user_id = u.user_id "
                + "JOIN ticket t ON tl.ticket_id = t.ticket_id "
                + "WHERE tl.ticket_id = ? "
                + "ORDER BY tl.logged_at DESC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, ticketId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Returns total hours logged for a ticket.
     */
    public double getTotalTimeByTicket(int ticketId) {
        String sql = "SELECT COALESCE(SUM(time_spent), 0) FROM time_log WHERE ticket_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, ticketId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    /**
     * Returns all time logs for a specific agent (newest first).
     */
    public List<TimeLog> getLogsByUser(int userId) {
        List<TimeLog> list = new ArrayList<>();
        String sql = "SELECT tl.*, u.full_name AS agent_name, t.ticket_number "
                + "FROM time_log tl "
                + "JOIN `user` u ON tl.user_id = u.user_id "
                + "JOIN ticket t ON tl.ticket_id = t.ticket_id "
                + "WHERE tl.user_id = ? "
                + "ORDER BY tl.logged_at DESC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Returns a single time log entry by ID.
     */
    public TimeLog getLogById(int logId) {
        String sql = "SELECT tl.*, u.full_name AS agent_name, t.ticket_number "
                + "FROM time_log tl "
                + "JOIN `user` u ON tl.user_id = u.user_id "
                + "JOIN ticket t ON tl.ticket_id = t.ticket_id "
                + "WHERE tl.log_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, logId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Returns all time logs with optional filters: ticketId, userId, dateFrom,
     * dateTo. Supports pagination.
     */
    public List<TimeLog> getAllLogs(Integer ticketId, Integer userId,
            String dateFrom, String dateTo,
            String activityType,
            int offset, int limit) {
        List<TimeLog> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT tl.*, u.full_name AS agent_name, t.ticket_number "
                + "FROM time_log tl "
                + "JOIN `user` u ON tl.user_id = u.user_id "
                + "JOIN ticket t ON tl.ticket_id = t.ticket_id "
                + "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, ticketId, userId, dateFrom, dateTo, activityType);
        sql.append("ORDER BY tl.logged_at DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            setParams(stmt, params);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Counts all time logs matching the given filters.
     */
    public int countAllLogs(Integer ticketId, Integer userId,
            String dateFrom, String dateTo,
            String activityType) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM time_log tl "
                + "JOIN `user` u ON tl.user_id = u.user_id "
                + "JOIN ticket t ON tl.ticket_id = t.ticket_id "
                + "WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, ticketId, userId, dateFrom, dateTo, activityType);

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            setParams(stmt, params);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Updates an existing time log entry (timeSpent and description only).
     */
    public boolean updateLog(int logId, double timeSpent, String description) {
        String sql = "UPDATE time_log SET time_spent = ?, description = ?, updated_at = CURRENT_TIMESTAMP "
                + "WHERE log_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setDouble(1, timeSpent);
            stmt.setString(2, description);
            stmt.setInt(3, logId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Deletes a time log entry by ID.
     */
    public boolean deleteLog(int logId) {
        String sql = "DELETE FROM time_log WHERE log_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, logId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // -----------------------------------------------------------------------
    // Dashboard / KPI queries
    // -----------------------------------------------------------------------
    /**
     * Returns total ticket counts grouped by status for all ticket types. Map
     * key = status string, value = count.
     */
    public Map<String, Integer> getTicketCountByStatus() {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT status, COUNT(*) AS cnt FROM ticket GROUP BY status ORDER BY cnt DESC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getString("status"), rs.getInt("cnt"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    /**
     * Returns total ticket counts grouped by ticket_type.
     */
    public Map<String, Integer> getTicketCountByType() {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT ticket_type, COUNT(*) AS cnt FROM ticket GROUP BY ticket_type ORDER BY ticket_type";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getString("ticket_type"), rs.getInt("cnt"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    /**
     * Returns total ticket counts grouped by priority.
     */
    public Map<String, Integer> getTicketCountByPriority() {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT priority, COUNT(*) AS cnt FROM ticket GROUP BY priority ORDER BY FIELD(priority,'CRITICAL','HIGH','MEDIUM','LOW')";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getString("priority"), rs.getInt("cnt"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    /**
     * Returns total hours logged per agent (top N agents by time logged). Map
     * key = agent name, value = total hours.
     */
    public Map<String, Double> getTotalHoursPerAgent(int topN) {
        Map<String, Double> map = new LinkedHashMap<>();
        String sql = "SELECT u.full_name, COALESCE(SUM(tl.time_spent), 0) AS total_hours "
                + "FROM time_log tl "
                + "JOIN `user` u ON tl.user_id = u.user_id "
                + "GROUP BY u.user_id, u.full_name "
                + "ORDER BY total_hours DESC "
                + "LIMIT ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, topN);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getString("full_name"), rs.getDouble("total_hours"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    /**
     * Returns summary KPI numbers for the dashboard. Returns array:
     * [totalTickets, openTickets, resolvedTickets, totalHoursLogged,
     * totalLogEntries]
     */
    public double[] getDashboardKpis() {
        double[] kpis = new double[5];
        try (Connection conn = DBConnection.getConnection()) {
            // total tickets
            try (PreparedStatement st = conn.prepareStatement("SELECT COUNT(*) FROM ticket"); ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    kpis[0] = rs.getInt(1);
                }
            }
            // open tickets (not CLOSED/CANCELLED/RESOLVED)
            try (PreparedStatement st = conn.prepareStatement(
                    "SELECT COUNT(*) FROM ticket WHERE status NOT IN ('CLOSED','CANCELLED','RESOLVED')"); ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    kpis[1] = rs.getInt(1);
                }
            }
            // resolved tickets
            try (PreparedStatement st = conn.prepareStatement(
                    "SELECT COUNT(*) FROM ticket WHERE status = 'RESOLVED' OR status = 'CLOSED'"); ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    kpis[2] = rs.getInt(1);
                }
            }
            // total hours logged
            try (PreparedStatement st = conn.prepareStatement("SELECT COALESCE(SUM(time_spent),0) FROM time_log"); ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    kpis[3] = rs.getDouble(1);
                }
            }
            // total log entries
            try (PreparedStatement st = conn.prepareStatement("SELECT COUNT(*) FROM time_log"); ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    kpis[4] = rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return kpis;
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------
    private void appendFilters(StringBuilder sql, List<Object> params,
            Integer ticketId, Integer userId,
            String dateFrom, String dateTo,
            String activityType) {
        if (ticketId != null && ticketId > 0) {
            sql.append("AND tl.ticket_id = ? ");
            params.add(ticketId);
        }
        if (userId != null && userId > 0) {
            sql.append("AND tl.user_id = ? ");
            params.add(userId);
        }
        if (dateFrom != null && !dateFrom.isEmpty()) {
            sql.append("AND DATE(tl.logged_at) >= ? ");
            params.add(dateFrom);
        }
        if (dateTo != null && !dateTo.isEmpty()) {
            sql.append("AND DATE(tl.logged_at) <= ? ");
            params.add(dateTo);
        }
        if (activityType != null && !activityType.isEmpty()) {
            sql.append("AND tl.activity_type = ? ");
            params.add(activityType);
        }
    }

    private void setParams(PreparedStatement stmt, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object p = params.get(i);
            if (p instanceof Integer) {
                stmt.setInt(i + 1, (Integer) p);
            } else if (p instanceof Double) {
                stmt.setDouble(i + 1, (Double) p);
            } else {
                stmt.setString(i + 1, p.toString());
            }
        }
    }

    private TimeLog mapRow(ResultSet rs) throws SQLException {
        TimeLog log = new TimeLog();
        log.setLogId(rs.getInt("log_id"));
        log.setTicketId(rs.getInt("ticket_id"));
        log.setUserId(rs.getInt("user_id"));
        log.setActivityType(rs.getString("activity_type"));
        log.setTimeSpent(rs.getDouble("time_spent"));
        log.setDescription(rs.getString("description"));
        log.setLoggedAt(rs.getTimestamp("logged_at"));
        log.setUpdatedAt(rs.getTimestamp("updated_at"));
        log.setAgentName(rs.getString("agent_name"));
        log.setTicketNumber(rs.getString("ticket_number"));
        return log;
    }
}
