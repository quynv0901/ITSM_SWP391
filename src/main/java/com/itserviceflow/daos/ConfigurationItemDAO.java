package com.itserviceflow.daos;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.itserviceflow.models.ConfigurationItem;
import com.itserviceflow.models.CiRelationship;
import static com.itserviceflow.utils.DBConnection.getConnection;

public class ConfigurationItemDAO {

    public List<ConfigurationItem> getAllConfigurationItems(String keyword, String status) {
        List<ConfigurationItem> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM configuration_item WHERE 1=1");

        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        boolean hasStatus = status != null && !status.trim().isEmpty();

        if (hasKeyword) {
            sql.append(" AND (name LIKE ? OR type LIKE ? OR description LIKE ? OR version LIKE ?)");
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

    /**
     * Overload không tham số: lấy toàn bộ CI đang ACTIVE, dùng cho dropdown ở các module khác (Maintenance Log, ...).
     */
    public List<ConfigurationItem> getAllConfigurationItems() {
        return getAllConfigurationItems(null, "ACTIVE");
    }

    public ConfigurationItem getConfigurationItemById(int id) {
        String sql = "SELECT c.*, v.name AS vendor_name FROM configuration_item c LEFT JOIN vendor v ON c.vendor_id = v.vendor_id WHERE c.ci_id = ?";
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
                if (rs.getObject("vendor_id") != null) {
                    ci.setVendorId(rs.getInt("vendor_id"));
                }
                ci.setVendorName(rs.getString("vendor_name"));
                return ci;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean createConfigurationItem(ConfigurationItem ci) {
        String sql = "INSERT INTO configuration_item (name, type, version, description, status, vendor_id) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ci.getName());
            ps.setString(2, ci.getType());
            ps.setString(3, ci.getVersion());
            ps.setString(4, ci.getDescription());
            ps.setString(5, ci.getStatus() != null ? ci.getStatus() : "ACTIVE");
            if (ci.getVendorId() != null && ci.getVendorId() > 0) {
                ps.setInt(6, ci.getVendorId());
            } else {
                ps.setNull(6, Types.INTEGER);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateConfigurationItem(ConfigurationItem ci) {
        String sql = "UPDATE configuration_item SET name = ?, type = ?, version = ?, description = ?, status = ?, vendor_id = ? WHERE ci_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ci.getName());
            ps.setString(2, ci.getType());
            ps.setString(3, ci.getVersion());
            ps.setString(4, ci.getDescription());
            ps.setString(5, ci.getStatus());
            if (ci.getVendorId() != null && ci.getVendorId() > 0) {
                ps.setInt(6, ci.getVendorId());
            } else {
                ps.setNull(6, Types.INTEGER);
            }
            ps.setInt(7, ci.getCiId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Soft Delete (Thu hồi): Không xóa vật lý, giữ lại record lịch sử và đổi trạng thái thành RETIRED.
     */
    public boolean deleteConfigurationItem(int id) {
        String sql = "UPDATE configuration_item SET status = 'RETIRED' WHERE ci_id = ?";
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
        if (hasKeyword) sql.append(" AND (name LIKE ? OR type LIKE ? OR description LIKE ? OR version LIKE ?)");
        if (hasStatus)  sql.append(" AND status = ?");
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (hasKeyword) {
                String p = "%" + keyword.trim() + "%";
                ps.setString(idx++, p); ps.setString(idx++, p); ps.setString(idx++, p); ps.setString(idx++, p);
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
        if (hasKeyword) sql.append(" AND (name LIKE ? OR type LIKE ? OR description LIKE ? OR version LIKE ?)");
        if (hasStatus)  sql.append(" AND status = ?");
        sql.append(" ORDER BY ci_id ASC LIMIT ? OFFSET ?");
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (hasKeyword) {
                String p = "%" + keyword.trim() + "%";
                ps.setString(idx++, p); ps.setString(idx++, p); ps.setString(idx++, p); ps.setString(idx++, p);
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

    public List<ConfigurationItem> getCIsByVendorId(int vendorId) {
        List<ConfigurationItem> list = new ArrayList<>();
        String sql = "SELECT * FROM configuration_item WHERE vendor_id = ? ORDER BY type, name";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, vendorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ConfigurationItem ci = new ConfigurationItem();
                    ci.setCiId(rs.getInt("ci_id"));
                    ci.setName(rs.getString("name"));
                    ci.setType(rs.getString("type"));
                    ci.setVersion(rs.getString("version"));
                    ci.setDescription(rs.getString("description"));
                    ci.setStatus(rs.getString("status"));
                    ci.setVendorId(vendorId);
                    ci.setCreatedAt(rs.getTimestamp("created_at"));
                    ci.setUpdatedAt(rs.getTimestamp("updated_at"));
                    list.add(ci);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean updateCiStatus(int ciId, String status) {
        String sql = "UPDATE configuration_item SET status = ? WHERE ci_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, ciId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────
    //  CI RELATIONSHIP methods
    // ─────────────────────────────────────────────────────────────────

    /** Lấy toàn bộ quan hệ mà CI này tham gia (là cha hoặc con). */
    public List<CiRelationship> getCiRelationships(int ciId) {
        List<CiRelationship> list = new ArrayList<>();
        String sql = "SELECT r.*, "
                + "p.name AS parent_name, p.status AS parent_status, "
                + "c.name AS child_name,  c.status AS child_status "
                + "FROM ci_relationship r "
                + "JOIN configuration_item p ON r.parent_ci_id = p.ci_id "
                + "JOIN configuration_item c ON r.child_ci_id  = c.ci_id "
                + "WHERE r.parent_ci_id = ? OR r.child_ci_id = ? "
                + "ORDER BY r.created_at DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ciId);
            ps.setInt(2, ciId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CiRelationship rel = new CiRelationship();
                    rel.setRelationshipId(rs.getInt("relationship_id"));
                    rel.setParentCiId(rs.getInt("parent_ci_id"));
                    rel.setChildCiId(rs.getInt("child_ci_id"));
                    rel.setRelationshipType(rs.getString("relationship_type"));
                    rel.setDescription(rs.getString("description"));
                    rel.setCreatedAt(rs.getTimestamp("created_at"));
                    rel.setParentCiName(rs.getString("parent_name"));
                    rel.setParentCiStatus(rs.getString("parent_status"));
                    rel.setChildCiName(rs.getString("child_name"));
                    rel.setChildCiStatus(rs.getString("child_status"));
                    list.add(rel);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /** Thêm một quan hệ mới giữa 2 CI. */
    public boolean addCiRelationship(int parentId, int childId, String relType, String desc) {
        String sql = "INSERT INTO ci_relationship (parent_ci_id, child_ci_id, relationship_type, description) "
                + "VALUES (?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, parentId);
            ps.setInt(2, childId);
            ps.setString(3, relType);
            ps.setString(4, desc != null ? desc : "");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /** Xóa một quan hệ theo ID. */
    public boolean deleteCiRelationship(int relationshipId) {
        String sql = "DELETE FROM ci_relationship WHERE relationship_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, relationshipId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /** Kiểm tra quan hệ trùng (cùng parent, child, type). */
    public boolean isDuplicateRelationship(int parentId, int childId, String relType) {
        String sql = "SELECT COUNT(*) FROM ci_relationship "
                + "WHERE parent_ci_id = ? AND child_ci_id = ? AND relationship_type = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, parentId);
            ps.setInt(2, childId);
            ps.setString(3, relType);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    /**
     * Phân tích tác động: trả về các CI bị ảnh hưởng nếu CI này gặp sự cố.
     * Áp dụng cho: DEPENDS_ON, HOSTED_BY, RUNS_ON, PART_OF
     * (CONNECTED_TO không xét vì chỉ là kết nối nền, không phụ thuộc chức năng)
     */
    public List<ConfigurationItem> getImpactedCIs(int ciId) {
        List<ConfigurationItem> list = new ArrayList<>();
        String sql = "SELECT c.* FROM configuration_item c "
                + "JOIN ci_relationship r ON c.ci_id = r.child_ci_id "
                + "WHERE r.parent_ci_id = ? "
                + "AND r.relationship_type IN ('DEPENDS_ON', 'HOSTED_BY', 'RUNS_ON', 'PART_OF')";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ciId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ConfigurationItem ci = new ConfigurationItem();
                    ci.setCiId(rs.getInt("ci_id"));
                    ci.setName(rs.getString("name"));
                    ci.setType(rs.getString("type"));
                    ci.setVersion(rs.getString("version"));
                    ci.setStatus(rs.getString("status"));
                    list.add(ci);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /** Lấy danh sách tất cả CI trừ CI hiện tại, dùng cho dropdown kết nối. */
    public List<ConfigurationItem> getAllForDropdown(int excludeId) {
        List<ConfigurationItem> list = new ArrayList<>();
        String sql = "SELECT ci_id, name, type FROM configuration_item "
                + "WHERE ci_id != ? ORDER BY name";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ConfigurationItem ci = new ConfigurationItem();
                    ci.setCiId(rs.getInt("ci_id"));
                    ci.setName(rs.getString("name"));
                    ci.setType(rs.getString("type"));
                    list.add(ci);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }
}
