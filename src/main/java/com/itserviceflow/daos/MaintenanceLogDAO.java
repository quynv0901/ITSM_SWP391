package com.itserviceflow.daos;

import com.itserviceflow.models.MaintenanceLog;
import com.itserviceflow.utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MaintenanceLogDAO {

    private Connection getConnection() throws SQLException {
        return DBConnection.getConnection();
    }

    // ── Đọc dữ liệu ───────────────────────────────────────────────────────────

    public int countLogs(String keyword, Integer ciId, String type, String status) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM maintenance_log m " +
            "LEFT JOIN configuration_item c ON m.ci_id = c.ci_id " +
            "WHERE m.is_deleted = 0"
        );
        appendFilters(sql, keyword, ciId, type, status);

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bindFilters(ps, keyword, ciId, type, status, 1);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int countLogs(String keyword, Integer ciId, String type) {
        return countLogs(keyword, ciId, type, null);
    }

    public List<MaintenanceLog> getLogsPaged(String keyword, Integer ciId, String type, String status,
                                              int page, int pageSize) {
        List<MaintenanceLog> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT m.*, c.name as ci_name, c.status as ci_status, " +
            "  u1.full_name as performed_by_name, u2.full_name as created_by_name " +
            "FROM maintenance_log m " +
            "LEFT JOIN configuration_item c ON m.ci_id = c.ci_id " +
            "LEFT JOIN `user` u1 ON m.performed_by = u1.user_id " +
            "LEFT JOIN `user` u2 ON m.created_by  = u2.user_id " +
            "WHERE m.is_deleted = 0"
        );
        appendFilters(sql, keyword, ciId, type, status);
        sql.append(" ORDER BY m.maintenance_date DESC, m.log_id DESC LIMIT ? OFFSET ?");

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int next = bindFilters(ps, keyword, ciId, type, status, 1);
            ps.setInt(next++, pageSize);
            ps.setInt(next,   (page - 1) * pageSize);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<MaintenanceLog> getLogsPaged(String keyword, Integer ciId, String type, int page, int pageSize) {
        return getLogsPaged(keyword, ciId, type, null, page, pageSize);
    }

    public MaintenanceLog getLogById(int id) {
        String sql =
            "SELECT m.*, c.name as ci_name, c.status as ci_status, " +
            "  u1.full_name as performed_by_name, u2.full_name as created_by_name " +
            "FROM maintenance_log m " +
            "LEFT JOIN configuration_item c ON m.ci_id = c.ci_id " +
            "LEFT JOIN `user` u1 ON m.performed_by = u1.user_id " +
            "LEFT JOIN `user` u2 ON m.created_by  = u2.user_id " +
            "WHERE m.log_id = ? AND m.is_deleted = 0";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Trả về danh sách CI đang INACTIVE.
     * Dùng để hiện cảnh báo trên trang danh sách.
     */
    public List<String> getInactiveCIsWithoutOpenLog() {
        List<String> names = new ArrayList<>();
        String sql =
            "SELECT c.name FROM configuration_item c " +
            "WHERE c.status = 'INACTIVE' " +
            "AND NOT EXISTS (" +
            "  SELECT 1 FROM maintenance_log m " +
            "  WHERE m.ci_id = c.ci_id " +
            "  AND m.is_deleted = 0 " +
            "  AND m.status IN ('PENDING', 'CONTACTED_VENDOR', 'IN_PROGRESS')" +
            ") ORDER BY c.name";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) names.add(rs.getString("name"));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return names;
    }

    // ── Ghi dữ liệu ───────────────────────────────────────────────────────────

    public boolean createLog(MaintenanceLog log) {
        String sql =
            "INSERT INTO maintenance_log " +
            "(ci_id, maintenance_type, maintenance_date, started_at, completed_at, " +
            " description, performed_by, created_by, status) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, log.getCiId());
            ps.setString(2, log.getMaintenanceType().trim());
            ps.setDate(3,   log.getMaintenanceDate());
            setTimestampOrNull(ps, 4, log.getStartedAt());
            setTimestampOrNull(ps, 5, log.getCompletedAt());
            ps.setString(6, log.getDescription().trim());
            setIntOrNull(ps, 7, log.getPerformedBy());
            setIntOrNull(ps, 8, log.getCreatedBy());
            ps.setString(9, log.getStatus() != null ? log.getStatus() : "PENDING");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateLog(MaintenanceLog log) {
        // Nếu status chuyển sang COMPLETED và chưa có completed_at → tự set
        String sql =
            "UPDATE maintenance_log SET " +
            "  ci_id = ?, maintenance_type = ?, maintenance_date = ?, " +
            "  started_at = ?, completed_at = ?, " +
            "  description = ?, performed_by = ?, status = ? " +
            "WHERE log_id = ? AND is_deleted = 0";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, log.getCiId());
            ps.setString(2, log.getMaintenanceType().trim());
            ps.setDate(3,   log.getMaintenanceDate());
            setTimestampOrNull(ps, 4, log.getStartedAt());
            setTimestampOrNull(ps, 5, log.getCompletedAt());
            ps.setString(6, log.getDescription().trim());
            setIntOrNull(ps, 7, log.getPerformedBy());
            ps.setString(8, log.getStatus());
            ps.setInt(9,    log.getLogId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /** Xóa mềm: đánh dấu is_deleted = 1, status = CANCELLED */
    public boolean softDeleteLog(int id) {
        String sql = "UPDATE maintenance_log SET is_deleted = 1, status = 'CANCELLED' WHERE log_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /** Khôi phục bản ghi đã xóa mềm */
    public boolean restoreLog(int id) {
        String sql = "UPDATE maintenance_log SET is_deleted = 0, status = 'PENDING' WHERE log_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private MaintenanceLog mapRow(ResultSet rs) throws SQLException {
        MaintenanceLog log = new MaintenanceLog();
        log.setLogId(rs.getInt("log_id"));
        log.setCiId(rs.getInt("ci_id"));
        log.setMaintenanceType(rs.getString("maintenance_type"));
        log.setMaintenanceDate(rs.getDate("maintenance_date"));
        log.setStartedAt(rs.getTimestamp("started_at"));
        log.setCompletedAt(rs.getTimestamp("completed_at"));
        log.setDescription(rs.getString("description"));

        int perfBy = rs.getInt("performed_by");
        if (!rs.wasNull()) log.setPerformedBy(perfBy);

        int createdByVal = rs.getInt("created_by");
        if (!rs.wasNull()) log.setCreatedBy(createdByVal);

        log.setStatus(rs.getString("status"));
        log.setIsDeleted(rs.getInt("is_deleted"));
        log.setCreatedAt(rs.getTimestamp("created_at"));
        log.setUpdatedAt(rs.getTimestamp("updated_at"));

        log.setCiName(rs.getString("ci_name"));
        try { log.setCiStatus(rs.getString("ci_status")); } catch (SQLException ignored) {}
        log.setPerformedByName(rs.getString("performed_by_name"));
        try { log.setCreatedByName(rs.getString("created_by_name")); } catch (SQLException ignored) {}
        return log;
    }

    private void appendFilters(StringBuilder sql, String keyword, Integer ciId, String type, String status) {
        if (keyword != null && !keyword.trim().isEmpty())
            sql.append(" AND (c.name LIKE ? OR m.description LIKE ? OR m.maintenance_type LIKE ?)");
        if (ciId != null && ciId > 0)
            sql.append(" AND m.ci_id = ?");
        if (type != null && !type.trim().isEmpty())
            sql.append(" AND m.maintenance_type LIKE ?");
        if (status != null && !status.trim().isEmpty())
            sql.append(" AND m.status = ?");
    }

    private int bindFilters(PreparedStatement ps, String keyword, Integer ciId, String type, String status,
                             int startIdx) throws SQLException {
        int i = startIdx;
        if (keyword != null && !keyword.trim().isEmpty()) {
            String p = "%" + keyword.trim() + "%";
            ps.setString(i++, p);
            ps.setString(i++, p);
            ps.setString(i++, p);
        }
        if (ciId != null && ciId > 0) ps.setInt(i++, ciId);
        if (type != null && !type.trim().isEmpty()) ps.setString(i++, "%" + type.trim() + "%");
        if (status != null && !status.trim().isEmpty()) ps.setString(i++, status.trim());
        return i;
    }

    private void setIntOrNull(PreparedStatement ps, int idx, Integer val) throws SQLException {
        if (val != null && val > 0) ps.setInt(idx, val);
        else ps.setNull(idx, Types.INTEGER);
    }

    private void setTimestampOrNull(PreparedStatement ps, int idx, Timestamp val) throws SQLException {
        if (val != null) ps.setTimestamp(idx, val);
        else ps.setNull(idx, Types.TIMESTAMP);
    }
}
