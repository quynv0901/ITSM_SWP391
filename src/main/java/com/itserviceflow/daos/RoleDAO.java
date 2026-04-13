package com.itserviceflow.daos;

import com.itserviceflow.models.Role;
import com.itserviceflow.utils.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO providing simple role lookups.
 */
public class RoleDAO {

    public List<Role> listAll() {
        List<Role> list = new ArrayList<>();
        String sql = "SELECT * FROM role WHERE status = 'ACTIVE'";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement st = conn.prepareStatement(sql); ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Retrieve a role by its id.
     */
    public Role getRoleById(int id) {
        String sql = "SELECT role_id, role_name, description, permission, status FROM role WHERE role_id = ?";
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

    /**
     * Convenience: return the role name for a given id, or null if not found.
     */
    public String getRoleNameById(int id) {
        Role r = getRoleById(id);
        return r == null ? null : r.getRoleName();
    }

    private Role mapRow(ResultSet rs) throws Exception {
        Role r = new Role();
        r.setRoleId(rs.getInt("role_id"));
        r.setRoleName(rs.getString("role_name"));
        r.setDescription(rs.getString("description"));
        r.setPermission(rs.getString("permission"));
        r.setStatus(rs.getString("status"));
        return r;
    }
}
