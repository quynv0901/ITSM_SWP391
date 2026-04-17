package com.itserviceflow.daos;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.itserviceflow.models.ConfigurationItem;
import static com.itserviceflow.utils.DBConnection.getConnection;

public class ConfigurationItemDAO {

    public List<ConfigurationItem> getAllConfigurationItems(String keyword, String status) {
        List<ConfigurationItem> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM configuration_item WHERE 1=1");

        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        boolean hasStatus = status != null && !status.trim().isEmpty();

        if (hasKeyword) {
            sql.append(" AND (name LIKE ? OR type LIKE ? OR description LIKE ?)");
        }
        if (hasStatus) {
            sql.append(" AND status = ?");
        }

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            
            if (hasKeyword) {
                String searchParam = "%" + keyword.trim() + "%";
                ps.setString(paramIndex++, searchParam);
                ps.setString(paramIndex++, searchParam);
                ps.setString(paramIndex++, searchParam);
            }
            
            if (hasStatus) {
                ps.setString(paramIndex++, status.trim());
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ConfigurationItem ci = new ConfigurationItem();
                ci.setCiId(rs.getInt("ci_id"));
                ci.setName(rs.getString("name"));
                ci.setType(rs.getString("type"));
                ci.setVersion(rs.getString("version"));
                ci.setDescription(rs.getString("description"));
                ci.setStatus(rs.getString("status"));
                ci.setCreatedAt(rs.getTimestamp("created_at"));
                ci.setUpdatedAt(rs.getTimestamp("updated_at"));
                list.add(ci);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public ConfigurationItem getConfigurationItemById(int id) {
        String sql = "SELECT * FROM configuration_item WHERE ci_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                ConfigurationItem ci = new ConfigurationItem();
                ci.setCiId(rs.getInt("ci_id"));
                ci.setName(rs.getString("name"));
                ci.setType(rs.getString("type"));
                ci.setVersion(rs.getString("version"));
                ci.setDescription(rs.getString("description"));
                ci.setStatus(rs.getString("status"));
                ci.setCreatedAt(rs.getTimestamp("created_at"));
                ci.setUpdatedAt(rs.getTimestamp("updated_at"));
                return ci;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean createConfigurationItem(ConfigurationItem ci) {
        String sql = "INSERT INTO configuration_item (name, type, version, description, status) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ci.getName());
            ps.setString(2, ci.getType());
            ps.setString(3, ci.getVersion());
            ps.setString(4, ci.getDescription());
            ps.setString(5, ci.getStatus() != null ? ci.getStatus() : "ACTIVE");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateConfigurationItem(ConfigurationItem ci) {
        String sql = "UPDATE configuration_item SET name = ?, type = ?, version = ?, description = ?, status = ? WHERE ci_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ci.getName());
            ps.setString(2, ci.getType());
            ps.setString(3, ci.getVersion());
            ps.setString(4, ci.getDescription());
            ps.setString(5, ci.getStatus());
            ps.setInt(6, ci.getCiId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteConfigurationItem(int id) {
        String sql = "DELETE FROM configuration_item WHERE ci_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }   // ← đóng deleteConfigurationItem

    /**
     * Kiểm tra tên CI đã tồn tại chưa (case-insensitive, bỏ qua item đang sửa).
     * @param name      Tên cần kiểm tra
     * @param excludeId ci_id cần bỏ qua (0 khi tạo mới, id thực khi cập nhật)
     */
    public boolean isDuplicateName(String name, int excludeId) {
        String sql = "SELECT COUNT(*) FROM configuration_item "
                + "WHERE LOWER(TRIM(name)) = LOWER(TRIM(?)) "
                + "AND ci_id != ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── Pagination: count total matching rows ────────────────────────────
    public int countConfigurationItems(String keyword, String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM configuration_item WHERE 1=1");
        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        boolean hasStatus  = status  != null && !status.trim().isEmpty();
        if (hasKeyword) sql.append(" AND (name LIKE ? OR type LIKE ? OR description LIKE ?)");
        if (hasStatus)  sql.append(" AND status = ?");
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (hasKeyword) {
                String p = "%" + keyword.trim() + "%";
                ps.setString(idx++, p); ps.setString(idx++, p); ps.setString(idx++, p);
            }
            if (hasStatus) ps.setString(idx, status.trim());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public List<ConfigurationItem> getConfigurationItemsPaged(
            String keyword, String status, int page, int pageSize) {
        List<ConfigurationItem> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM configuration_item WHERE 1=1");
        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        boolean hasStatus  = status  != null && !status.trim().isEmpty();
        if (hasKeyword) sql.append(" AND (name LIKE ? OR type LIKE ? OR description LIKE ?)");
        if (hasStatus)  sql.append(" AND status = ?");
        sql.append(" ORDER BY ci_id ASC LIMIT ? OFFSET ?");
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (hasKeyword) {
                String p = "%" + keyword.trim() + "%";
                ps.setString(idx++, p); ps.setString(idx++, p); ps.setString(idx++, p);
            }
            if (hasStatus) ps.setString(idx++, status.trim());
            ps.setInt(idx++, pageSize);
            ps.setInt(idx,   (page - 1) * pageSize);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ConfigurationItem ci = new ConfigurationItem();
                ci.setCiId(rs.getInt("ci_id"));
                ci.setName(rs.getString("name"));
                ci.setType(rs.getString("type"));
                ci.setVersion(rs.getString("version"));
                ci.setDescription(rs.getString("description"));
                ci.setStatus(rs.getString("status"));
                ci.setCreatedAt(rs.getTimestamp("created_at"));
                ci.setUpdatedAt(rs.getTimestamp("updated_at"));
                list.add(ci);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }
}
