/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.itserviceflow.daos;

import com.itserviceflow.models.ConfigurationItem;
import com.itserviceflow.models.CiRelationship;
import com.itserviceflow.utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Admin
 */
public class CmdbDAO {

    public List<ConfigurationItem> getAllConfigurationItems() {
        return searchConfigurationItems(null, null);
    }

    public List<ConfigurationItem> searchConfigurationItems(String keyword, String status) {
        List<ConfigurationItem> items = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT c.*, u.full_name as owner_name, ct.type_name as ci_type_name "
                + "FROM configuration_item c "
                + "LEFT JOIN user u ON c.owner_id = u.user_id "
                + "LEFT JOIN ci_type ct ON c.ci_type_id = ct.type_id "
                + "WHERE 1=1");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (c.ci_name LIKE ? OR c.ci_code LIKE ?)");
        }
        if (status != null && !status.trim().isEmpty() && !status.equals("ALL")) {
            sql.append(" AND c.status = ?");
        }

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String searchPattern = "%" + keyword.trim() + "%";
                stmt.setString(paramIndex++, searchPattern);
                stmt.setString(paramIndex++, searchPattern);
            }
            if (status != null && !status.trim().isEmpty() && !status.equals("ALL")) {
                stmt.setString(paramIndex++, status);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    items.add(mapRowToCI(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return items;
    }

    public ConfigurationItem getConfigurationItemById(int ciId) {
        String sql = "SELECT c.*, u.full_name as owner_name, ct.type_name as ci_type_name "
                + "FROM configuration_item c "
                + "LEFT JOIN user u ON c.owner_id = u.user_id "
                + "LEFT JOIN ci_type ct ON c.ci_type_id = ct.type_id "
                + "WHERE c.ci_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, ciId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRowToCI(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean createConfigurationItem(ConfigurationItem ci) {
        String sql = "INSERT INTO configuration_item (ci_name, ci_type_id, ci_code, status, location, owner_id, "
                + "manufacturer, model, serial_number, ip_address, description) "
                + "VALUES (?, ?, ?, 'ACTIVE', ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, ci.getCiName());
            stmt.setInt(2, ci.getCiTypeId());
            stmt.setString(3, "CI-" + java.util.UUID.randomUUID().toString().substring(0, 8).toUpperCase());
            stmt.setString(4, ci.getLocation());
            if (ci.getOwnerId() != null) {
                stmt.setInt(5, ci.getOwnerId());
            } else {
                stmt.setNull(5, Types.INTEGER);
            }
            stmt.setString(6, ci.getManufacturer());
            stmt.setString(7, ci.getModel());
            stmt.setString(8, ci.getSerialNumber());
            stmt.setString(9, ci.getIpAddress());
            stmt.setString(10, ci.getDescription());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateConfigurationItem(ConfigurationItem ci) {
        String sql = "UPDATE configuration_item SET ci_name = ?, location = ?, owner_id = ?, "
                + "manufacturer = ?, model = ?, serial_number = ?, ip_address = ?, description = ?, status = ? "
                + "WHERE ci_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, ci.getCiName());
            stmt.setString(2, ci.getLocation());
            if (ci.getOwnerId() != null) {
                stmt.setInt(3, ci.getOwnerId());
            } else {
                stmt.setNull(3, Types.INTEGER);
            }
            stmt.setString(4, ci.getManufacturer());
            stmt.setString(5, ci.getModel());
            stmt.setString(6, ci.getSerialNumber());
            stmt.setString(7, ci.getIpAddress());
            stmt.setString(8, ci.getDescription());
            stmt.setString(9, ci.getStatus());
            stmt.setInt(10, ci.getCiId());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteConfigurationItem(int ciId) {
        String checkSql = "SELECT status, "
                + "(SELECT COUNT(*) FROM ticket WHERE ci_id = ?) as ticket_count, "
                + "(SELECT COUNT(*) FROM change_ci WHERE ci_id = ?) as change_count, "
                + "(SELECT COUNT(*) FROM ci_relationship WHERE parent_ci_id = ? OR child_ci_id = ?) as rel_count "
                + "FROM configuration_item WHERE ci_id = ?";

        String deleteSql = "DELETE FROM configuration_item WHERE ci_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
            checkStmt.setInt(1, ciId);
            checkStmt.setInt(2, ciId);
            checkStmt.setInt(3, ciId);
            checkStmt.setInt(4, ciId);
            checkStmt.setInt(5, ciId);

            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next()) {
                    String status = rs.getString("status");
                    int ticketCount = rs.getInt("ticket_count");
                    int changeCount = rs.getInt("change_count");
                    int relCount = rs.getInt("rel_count");

                    if ("INACTIVE".equals(status) && ticketCount == 0 && changeCount == 0 && relCount == 0) {
                        try (PreparedStatement delStmt = conn.prepareStatement(deleteSql)) {
                            delStmt.setInt(1, ciId);
                            return delStmt.executeUpdate() > 0;
                        }
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean toggleConfigurationItemStatus(int ciId, String currentStatus) {
        String newStatus = "ACTIVE".equals(currentStatus) ? "INACTIVE" : "ACTIVE";
        String sql = "UPDATE configuration_item SET status = ? WHERE ci_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, newStatus);
            stmt.setInt(2, ciId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<CiRelationship> getCiRelationships(int ciId) {
        List<CiRelationship> relationships = new ArrayList<>();
        String sql = "SELECT r.*, p.ci_name as parent_ci_name, p.ci_code as parent_ci_code, "
                + "c.ci_name as child_ci_name, c.ci_code as child_ci_code "
                + "FROM ci_relationship r "
                + "JOIN configuration_item p ON r.parent_ci_id = p.ci_id "
                + "JOIN configuration_item c ON r.child_ci_id = c.ci_id "
                + "WHERE r.parent_ci_id = ? OR r.child_ci_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, ciId);
            stmt.setInt(2, ciId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    CiRelationship rel = new CiRelationship();
                    rel.setRelationshipId(rs.getInt("relationship_id"));
                    rel.setParentCiId(rs.getInt("parent_ci_id"));
                    rel.setChildCiId(rs.getInt("child_ci_id"));
                    rel.setRelationshipType(rs.getString("relationship_type"));
                    rel.setDescription(rs.getString("description"));
                    rel.setParentCiName(rs.getString("parent_ci_name"));
                    rel.setParentCiCode(rs.getString("parent_ci_code"));
                    rel.setChildCiName(rs.getString("child_ci_name"));
                    rel.setChildCiCode(rs.getString("child_ci_code"));
                    relationships.add(rel);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return relationships;
    }

    public boolean addCiRelationship(int parentId, int childId, String relType, String desc) {
        String sql = "INSERT INTO ci_relationship (parent_ci_id, child_ci_id, relationship_type, description) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, parentId);
            stmt.setInt(2, childId);
            stmt.setString(3, relType);
            stmt.setString(4, desc);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteCiRelationship(int relationshipId) {
        String sql = "DELETE FROM ci_relationship WHERE relationship_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, relationshipId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<ConfigurationItem> getImpactedCis(int problemCiId) {
        List<ConfigurationItem> impactedCis = new ArrayList<>();
        String sql = "SELECT c.*, u.full_name as owner_name, ct.type_name as ci_type_name "
                + "FROM configuration_item c "
                + "JOIN ci_relationship r ON c.ci_id = r.child_ci_id "
                + "LEFT JOIN user u ON c.owner_id = u.user_id "
                + "LEFT JOIN ci_type ct ON c.ci_type_id = ct.type_id "
                + "WHERE r.parent_ci_id = ? AND r.relationship_type IN ('DEPENDS_ON', 'HOSTED_BY')";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, problemCiId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    impactedCis.add(mapRowToCI(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return impactedCis;
    }

    private ConfigurationItem mapRowToCI(ResultSet rs) throws SQLException {
        ConfigurationItem ci = new ConfigurationItem();
        ci.setCiId(rs.getInt("ci_id"));
        ci.setCiName(rs.getString("ci_name"));
        ci.setCiTypeId(rs.getInt("ci_type_id"));
        ci.setCiCode(rs.getString("ci_code"));
        ci.setStatus(rs.getString("status"));
        ci.setLocation(rs.getString("location"));
        Object ownerObj = rs.getObject("owner_id");
        if (ownerObj != null) {
            ci.setOwnerId((Integer) ownerObj);
        }
        ci.setManufacturer(rs.getString("manufacturer"));
        ci.setModel(rs.getString("model"));
        ci.setSerialNumber(rs.getString("serial_number"));
        ci.setIpAddress(rs.getString("ip_address"));
        ci.setDescription(rs.getString("description"));
        ci.setUpdatedAt(rs.getTimestamp("updated_at"));

        try {
            ci.setOwnerName(rs.getString("owner_name"));
        } catch (SQLException e) {
            /* Ignore if column not selected */ }

        try {
            ci.setCiTypeName(rs.getString("ci_type_name"));
        } catch (SQLException e) {
            /* Ignore if column not selected */ }

        return ci;
    }

    public List<com.itserviceflow.models.User> getAllUsersForDropdown() {
        List<com.itserviceflow.models.User> users = new ArrayList<>();
        String sql = "SELECT user_id, full_name FROM `user` ORDER BY full_name";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                com.itserviceflow.models.User u = new com.itserviceflow.models.User();
                u.setUserId(rs.getInt("user_id"));
                u.setFullName(rs.getString("full_name"));
                users.add(u);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }

    public List<String[]> getAllCiTypes() {
        List<String[]> types = new ArrayList<>();
        String sql = "SELECT type_id, type_name FROM ci_type ORDER BY type_name";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                types.add(new String[]{String.valueOf(rs.getInt("type_id")), rs.getString("type_name")});
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return types;
    }

    public List<ConfigurationItem> getAllConfigurationItemsForDropdown(int currentCiId) {
        List<ConfigurationItem> list = new ArrayList<>();
        String sql = "SELECT ci_id, ci_name, ci_code FROM configuration_item WHERE ci_id != ? ORDER BY ci_name";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, currentCiId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    ConfigurationItem ci = new ConfigurationItem();
                    ci.setCiId(rs.getInt("ci_id"));
                    ci.setCiName(rs.getString("ci_name"));
                    ci.setCiCode(rs.getString("ci_code"));
                    list.add(ci);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
