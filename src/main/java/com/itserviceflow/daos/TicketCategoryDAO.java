package com.itserviceflow.daos;

import com.itserviceflow.models.TicketCategory;
import com.itserviceflow.utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Full CRUD + list/search/filter DAO for the ticket_category table.
 */
public class TicketCategoryDAO {

    // ── READ ──────────────────────────────────────────────────────────────
    /**
     * Returns all categories (for dropdowns / admin list). Joins parent name,
     * child count, and ticket count.
     */
    public List<TicketCategory> getAllCategories() {
        return query(null, null, null, 0, Integer.MAX_VALUE);
    }

    /**
     * Returns only active categories (used in ticket forms).
     */
    public List<TicketCategory> getActiveCategories() {
        return query(null, null, true, 0, Integer.MAX_VALUE);
    }

    /**
     * Paginated, filterable list.
     *
     * @param search optional name/code search
     * @param categoryType optional type filter
     * @param activeOnly null = all, true = active only, false = inactive only
     * @param offset pagination offset
     * @param limit page size
     */
    public List<TicketCategory> query(String search, String categoryType,
            Boolean activeOnly, int offset, int limit) {
        List<TicketCategory> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT tc.*, "
                + "  p.category_name AS parent_category_name, "
                + "  (SELECT COUNT(*) FROM ticket_category c2 WHERE c2.parent_category_id = tc.category_id) AS child_count, "
                + "  (SELECT COUNT(*) FROM ticket t WHERE t.category_id = tc.category_id) AS ticket_count "
                + "FROM ticket_category tc "
                + "LEFT JOIN ticket_category p ON tc.parent_category_id = p.category_id "
                + "WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();

        if (search != null && !search.isBlank()) {
            sql.append("AND (tc.category_name LIKE ? OR tc.category_code LIKE ? OR tc.description LIKE ?) ");
            String like = "%" + search.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }
        if (categoryType != null && !categoryType.isBlank()) {
            sql.append("AND tc.category_type = ? ");
            params.add(categoryType);
        }
        if (activeOnly != null) {
            sql.append("AND tc.is_active = ? ");
            params.add(activeOnly ? 1 : 0);
        }
    // Sort by newest first using updated_at (created_at not present in schema).
    sql.append("ORDER BY tc.updated_at DESC ");
        if (limit < Integer.MAX_VALUE) {
            sql.append("LIMIT ? OFFSET ?");
            params.add(limit);
            params.add(offset);
        }

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
     * Total count matching the same filters (for pagination).
     */
    public int count(String search, String categoryType, Boolean activeOnly) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM ticket_category tc WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();
        if (search != null && !search.isBlank()) {
            sql.append("AND (tc.category_name LIKE ? OR tc.category_code LIKE ? OR tc.description LIKE ?) ");
            String like = "%" + search.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }
        if (categoryType != null && !categoryType.isBlank()) {
            sql.append("AND tc.category_type = ? ");
            params.add(categoryType);
        }
        if (activeOnly != null) {
            sql.append("AND tc.is_active = ? ");
            params.add(activeOnly ? 1 : 0);
        }
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
     * Fetch single category by id (with joined fields).
     */
    public TicketCategory findById(int id) {
        String sql
                = "SELECT tc.*, "
                + "  p.category_name AS parent_category_name, "
                + "  (SELECT COUNT(*) FROM ticket_category c2 WHERE c2.parent_category_id = tc.category_id) AS child_count, "
                + "  (SELECT COUNT(*) FROM ticket t WHERE t.category_id = tc.category_id) AS ticket_count "
                + "FROM ticket_category tc "
                + "LEFT JOIN ticket_category p ON tc.parent_category_id = p.category_id "
                + "WHERE tc.category_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
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

    // ── WRITE ─────────────────────────────────────────────────────────────
    /**
     * Inserts a new category. Returns generated ID or -1 on failure.
     */
    public int insert(TicketCategory cat) {
        String sql = "INSERT INTO ticket_category "
                + "(category_name, category_code, category_type, description, parent_category_id, difficulty_level, is_active) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, cat.getCategoryName());
            stmt.setString(2, cat.getCategoryCode());
            stmt.setString(3, cat.getCategoryType());
            stmt.setString(4, cat.getDescription());
            if (cat.getParentCategoryId() != null && cat.getParentCategoryId() > 0) {
                stmt.setInt(5, cat.getParentCategoryId());
            } else {
                stmt.setNull(5, Types.INTEGER);
            }
            stmt.setString(6, cat.getDifficultyLevel());
            stmt.setBoolean(7, cat.isActive());
            int rows = stmt.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (keys.next()) {
                        return keys.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Updates all mutable fields for an existing category.
     */
    public boolean update(TicketCategory cat) {
        String sql = "UPDATE ticket_category SET "
                + "category_name = ?, category_code = ?, category_type = ?, "
                + "description = ?, parent_category_id = ?, difficulty_level = ?, "
                + "is_active = ?, updated_at = CURRENT_TIMESTAMP "
                + "WHERE category_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, cat.getCategoryName());
            stmt.setString(2, cat.getCategoryCode());
            stmt.setString(3, cat.getCategoryType());
            stmt.setString(4, cat.getDescription());
            if (cat.getParentCategoryId() != null && cat.getParentCategoryId() > 0) {
                stmt.setInt(5, cat.getParentCategoryId());
            } else {
                stmt.setNull(5, Types.INTEGER);
            }
            stmt.setString(6, cat.getDifficultyLevel());
            stmt.setBoolean(7, cat.isActive());
            stmt.setInt(8, cat.getCategoryId());
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Deletes a category ONLY if: - No tickets currently reference it - It has
     * no sub-categories Returns "ok", "has_tickets", "has_children", or
     * "error".
     */
    public String safeDelete(int id) {
        TicketCategory cat = findById(id);
        if (cat == null) {
            return "error";
        }
        if (cat.getTicketCount() > 0) {
            return "has_tickets";
        }
        if (cat.getChildCount() > 0) {
            return "has_children";
        }

        String sql = "DELETE FROM ticket_category WHERE category_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0 ? "ok" : "error";
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "error";
    }

    /**
     * Bulk delete — silently skips any category that has tickets or children.
     */
    public int bulkSafeDelete(List<Integer> ids) {
        int deleted = 0;
        for (int id : ids) {
            if ("ok".equals(safeDelete(id))) {
                deleted++;
            }
        }
        return deleted;
    }

    /**
     * Toggles active status. Returns new status (true = active).
     */
    public boolean toggleActive(int id, boolean active) {
        String sql = "UPDATE ticket_category SET is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE category_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setBoolean(1, active);
            stmt.setInt(2, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Bulk toggle active/inactive for a list of IDs.
     */
    public int bulkToggle(List<Integer> ids, boolean active) {
        int count = 0;
        for (int id : ids) {
            if (toggleActive(id, active)) {
                count++;
            }
        }
        return count;
    }

    /**
     * Find category by code (case-insensitive). Returns null if not found.
     */
    public TicketCategory findByCode(String code) {
        if (code == null || code.isBlank()) return null;
        String sql = "SELECT tc.* FROM ticket_category tc WHERE LOWER(tc.category_code) = LOWER(?) LIMIT 1";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, code.trim());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Returns all sub-categories of a given parent ID.
     */
    public List<TicketCategory> getChildren(int parentId) {
        List<TicketCategory> list = new ArrayList<>();
    String sql
        = "SELECT tc.*, "
        + "  p.category_name AS parent_category_name, "
        + "  (SELECT COUNT(*) FROM ticket_category c2 WHERE c2.parent_category_id = tc.category_id) AS child_count, "
        + "  (SELECT COUNT(*) FROM ticket t WHERE t.category_id = tc.category_id) AS ticket_count "
        + "FROM ticket_category tc "
        + "LEFT JOIN ticket_category p ON tc.parent_category_id = p.category_id "
        + "WHERE tc.parent_category_id = ? "
        + "ORDER BY tc.updated_at DESC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, parentId);
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

    // ── Helpers ───────────────────────────────────────────────────────────
    private TicketCategory mapRow(ResultSet rs) throws SQLException {
        TicketCategory cat = new TicketCategory();
        cat.setCategoryId(rs.getInt("category_id"));
        cat.setCategoryName(rs.getString("category_name"));
        cat.setCategoryCode(rs.getString("category_code"));
        cat.setCategoryType(rs.getString("category_type"));
        cat.setDescription(rs.getString("description"));
        cat.setParentCategoryId((Integer) rs.getObject("parent_category_id"));
        // difficulty_level may not always be in the result set
        try {
            cat.setDifficultyLevel(rs.getString("difficulty_level"));
        } catch (Exception ignored) {
        }
        cat.setActive(rs.getBoolean("is_active"));
        cat.setUpdatedAt(rs.getTimestamp("updated_at"));
        // joined / derived
        try {
            cat.setParentCategoryName(rs.getString("parent_category_name"));
        } catch (Exception ignored) {
        }
        try {
            cat.setChildCount(rs.getInt("child_count"));
        } catch (Exception ignored) {
        }
        try {
            cat.setTicketCount(rs.getInt("ticket_count"));
        } catch (Exception ignored) {
        }
        return cat;
    }

    private void setParams(PreparedStatement stmt, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object p = params.get(i);
            if (p instanceof Integer) {
                stmt.setInt(i + 1, (Integer) p);
            } else if (p instanceof Boolean) {
                stmt.setBoolean(i + 1, (Boolean) p);
            } else {
                stmt.setString(i + 1, p.toString());
            }
        }
    }
}
