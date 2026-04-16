package com.itserviceflow.daos;

import com.itserviceflow.models.Workflow;
import com.itserviceflow.utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for the `workflow` table. Provides CRUD + enable/disable
 * operations.
 */
public class WorkflowDAO {

    // ---------------------------------------------------------------
    // READ: List all workflows (with creator name)
    // ---------------------------------------------------------------
    public List<Workflow> getAllWorkflows() throws SQLException {
        List<Workflow> list = new ArrayList<>();
        String sql = """
                SELECT w.workflow_id, w.workflow_name, w.description, w.status,
                       w.workflow_config, w.created_by, w.updated_at,
                       u.full_name AS created_by_name
                FROM workflow w
                LEFT JOIN `user` u ON w.created_by = u.user_id
                ORDER BY w.updated_at DESC
                """;
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    // ---------------------------------------------------------------
    // READ: List all ACTIVE workflows (used by WorkflowService engine)
    // ---------------------------------------------------------------
    public List<Workflow> getActiveWorkflows() throws SQLException {
        return getWorkflowsByStatus("ACTIVE");
    }

    // ---------------------------------------------------------------
    // READ: List workflows filtered by status
    // ---------------------------------------------------------------
    public List<Workflow> getWorkflowsByStatus(String status) throws SQLException {
        List<Workflow> list = new ArrayList<>();
        String sql = """
                SELECT w.workflow_id, w.workflow_name, w.description, w.status,
                       w.workflow_config, w.created_by, w.updated_at,
                       u.full_name AS created_by_name
                FROM workflow w
                LEFT JOIN `user` u ON w.created_by = u.user_id
                WHERE w.status = ?
                ORDER BY w.updated_at DESC
                """;
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    // ---------------------------------------------------------------
    // READ: Get single workflow by ID
    // ---------------------------------------------------------------
    public Workflow getWorkflowById(int id) throws SQLException {
        String sql = """
                SELECT w.workflow_id, w.workflow_name, w.description, w.status,
                       w.workflow_config, w.created_by, w.updated_at,
                       u.full_name AS created_by_name
                FROM workflow w
                LEFT JOIN `user` u ON w.created_by = u.user_id
                WHERE w.workflow_id = ?
                """;
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    // ---------------------------------------------------------------
    // CREATE
    // ---------------------------------------------------------------
    public boolean createWorkflow(Workflow w) throws SQLException {
        String sql = """
                INSERT INTO workflow (workflow_name, description, status, workflow_config, created_by)
                VALUES (?, ?, ?, ?, ?)
                """;
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, w.getWorkflowName());
            ps.setString(2, w.getDescription());
            ps.setString(3, w.getStatus() != null ? w.getStatus() : "DRAFT");
            ps.setString(4, w.getWorkflowConfig());
            if (w.getCreatedBy() > 0) {
                ps.setInt(5, w.getCreatedBy());
            } else {
                ps.setNull(5, java.sql.Types.INTEGER);
            }
            return ps.executeUpdate() > 0;
        }
    }

    // ---------------------------------------------------------------
    // READ: find workflow by name (case-insensitive)
    // ---------------------------------------------------------------
    public Workflow getWorkflowByName(String name) throws SQLException {
        if (name == null) return null;
        String sql = """
                SELECT w.workflow_id, w.workflow_name, w.description, w.status,
                       w.workflow_config, w.created_by, w.updated_at,
                       u.full_name AS created_by_name
                FROM workflow w
                LEFT JOIN `user` u ON w.created_by = u.user_id
                WHERE LOWER(w.workflow_name) = LOWER(?)
                LIMIT 1
                """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    // ---------------------------------------------------------------
    // UPDATE
    // ---------------------------------------------------------------
    public boolean updateWorkflow(Workflow w) throws SQLException {
        String sql = """
                UPDATE workflow
                SET workflow_name = ?, description = ?, status = ?, workflow_config = ?
                WHERE workflow_id = ?
                """;
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, w.getWorkflowName());
            ps.setString(2, w.getDescription());
            ps.setString(3, w.getStatus());
            ps.setString(4, w.getWorkflowConfig());
            ps.setInt(5, w.getWorkflowId());
            return ps.executeUpdate() > 0;
        }
    }

    // ---------------------------------------------------------------
    // DELETE
    // ---------------------------------------------------------------
    public boolean deleteWorkflow(int id) throws SQLException {
        String sql = "DELETE FROM workflow WHERE workflow_id = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    // ---------------------------------------------------------------
    // ENABLE / DISABLE (toggle ACTIVE <-> INACTIVE)
    // ---------------------------------------------------------------
    public boolean toggleStatus(int id, String newStatus) throws SQLException {
        String sql = "UPDATE workflow SET status = ? WHERE workflow_id = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        }
    }

    // ---------------------------------------------------------------
    // Helper: map ResultSet row → Workflow object
    // ---------------------------------------------------------------
    private Workflow mapRow(ResultSet rs) throws SQLException {
        Workflow w = new Workflow();
        w.setWorkflowId(rs.getInt("workflow_id"));
        w.setWorkflowName(rs.getString("workflow_name"));
        w.setDescription(rs.getString("description"));
        w.setStatus(rs.getString("status"));
        w.setWorkflowConfig(rs.getString("workflow_config"));
        w.setCreatedBy(rs.getInt("created_by"));
        w.setUpdatedAt(rs.getTimestamp("updated_at"));
        w.setCreatedByName(rs.getString("created_by_name"));
        return w;
    }
}
