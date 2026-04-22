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

    public int countLogs(String keyword, Integer ciId, String type) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM maintenance_log m LEFT JOIN configuration_item c ON m.ci_id = c.ci_id WHERE m.status != 'DELETED'");
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (c.name LIKE ? OR m.description LIKE ?)");
        }
        if (ciId != null && ciId > 0) {
            sql.append(" AND m.ci_id = ?");
        }
        if (type != null && !type.trim().isEmpty()) {
            sql.append(" AND m.maintenance_type = ?");
        }

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String searchParam = "%" + keyword.trim() + "%";
                ps.setString(paramIndex++, searchParam);
                ps.setString(paramIndex++, searchParam);
            }
            if (ciId != null && ciId > 0) {
                ps.setInt(paramIndex++, ciId);
            }
            if (type != null && !type.trim().isEmpty()) {
                ps.setString(paramIndex++, type.trim());
            }

            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<MaintenanceLog> getLogsPaged(String keyword, Integer ciId, String type, int page, int pageSize) {
        List<MaintenanceLog> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT m.*, c.name as ci_name, u.full_name as performed_by_name " +
            "FROM maintenance_log m " +
            "LEFT JOIN configuration_item c ON m.ci_id = c.ci_id " +
            "LEFT JOIN `user` u ON m.performed_by = u.user_id " +
            "WHERE m.status != 'DELETED'"
        );

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (c.name LIKE ? OR m.description LIKE ?)");
        }
        if (ciId != null && ciId > 0) {
            sql.append(" AND m.ci_id = ?");
        }
        if (type != null && !type.trim().isEmpty()) {
            sql.append(" AND m.maintenance_type = ?");
        }
        
        sql.append(" ORDER BY m.maintenance_date DESC, m.log_id DESC LIMIT ? OFFSET ?");

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String searchParam = "%" + keyword.trim() + "%";
                ps.setString(paramIndex++, searchParam);
                ps.setString(paramIndex++, searchParam);
            }
            if (ciId != null && ciId > 0) {
                ps.setInt(paramIndex++, ciId);
            }
            if (type != null && !type.trim().isEmpty()) {
                ps.setString(paramIndex++, type.trim());
            }
            ps.setInt(paramIndex++, pageSize);
            ps.setInt(paramIndex, (page - 1) * pageSize);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                MaintenanceLog log = new MaintenanceLog();
                log.setLogId(rs.getInt("log_id"));
                log.setCiId(rs.getInt("ci_id"));
                log.setMaintenanceType(rs.getString("maintenance_type"));
                log.setMaintenanceDate(rs.getDate("maintenance_date"));
                log.setDowntimeMinutes(rs.getInt("downtime_minutes"));
                log.setDescription(rs.getString("description"));
                
                int perfBy = rs.getInt("performed_by");
                if (!rs.wasNull()) log.setPerformedBy(perfBy);
                
                log.setStatus(rs.getString("status"));
                log.setCreatedAt(rs.getTimestamp("created_at"));
                log.setUpdatedAt(rs.getTimestamp("updated_at"));
                
                log.setCiName(rs.getString("ci_name"));
                log.setPerformedByName(rs.getString("performed_by_name"));
                list.add(log);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public MaintenanceLog getLogById(int id) {
        String sql = "SELECT m.*, c.name as ci_name, u.full_name as performed_by_name " +
                     "FROM maintenance_log m " +
                     "LEFT JOIN configuration_item c ON m.ci_id = c.ci_id " +
                     "LEFT JOIN `user` u ON m.performed_by = u.user_id " +
                     "WHERE m.log_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                MaintenanceLog log = new MaintenanceLog();
                log.setLogId(rs.getInt("log_id"));
                log.setCiId(rs.getInt("ci_id"));
                log.setMaintenanceType(rs.getString("maintenance_type"));
                log.setMaintenanceDate(rs.getDate("maintenance_date"));
                log.setDowntimeMinutes(rs.getInt("downtime_minutes"));
                log.setDescription(rs.getString("description"));
                
                int perfBy = rs.getInt("performed_by");
                if (!rs.wasNull()) log.setPerformedBy(perfBy);
                
                log.setStatus(rs.getString("status"));
                log.setCreatedAt(rs.getTimestamp("created_at"));
                log.setUpdatedAt(rs.getTimestamp("updated_at"));
                
                log.setCiName(rs.getString("ci_name"));
                log.setPerformedByName(rs.getString("performed_by_name"));
                return log;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean createLog(MaintenanceLog log) {
        String sql = "INSERT INTO maintenance_log (ci_id, maintenance_type, maintenance_date, downtime_minutes, description, performed_by, status) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, log.getCiId());
            ps.setString(2, log.getMaintenanceType());
            ps.setDate(3, log.getMaintenanceDate());
            ps.setInt(4, log.getDowntimeMinutes());
            ps.setString(5, log.getDescription());
            
            if (log.getPerformedBy() != null) {
                ps.setInt(6, log.getPerformedBy());
            } else {
                ps.setNull(6, Types.INTEGER);
            }
            
            ps.setString(7, log.getStatus() != null ? log.getStatus() : "ACTIVE");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateLog(MaintenanceLog log) {
        String sql = "UPDATE maintenance_log SET ci_id = ?, maintenance_type = ?, maintenance_date = ?, downtime_minutes = ?, description = ?, performed_by = ?, status = ? WHERE log_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, log.getCiId());
            ps.setString(2, log.getMaintenanceType());
            ps.setDate(3, log.getMaintenanceDate());
            ps.setInt(4, log.getDowntimeMinutes());
            ps.setString(5, log.getDescription());
            
            if (log.getPerformedBy() != null) {
                ps.setInt(6, log.getPerformedBy());
            } else {
                ps.setNull(6, Types.INTEGER);
            }
            
            ps.setString(7, log.getStatus());
            ps.setInt(8, log.getLogId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteLog(int id) {
        String sql = "UPDATE maintenance_log SET status = 'DELETED' WHERE log_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
