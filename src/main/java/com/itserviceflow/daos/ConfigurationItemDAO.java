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
    }
}
