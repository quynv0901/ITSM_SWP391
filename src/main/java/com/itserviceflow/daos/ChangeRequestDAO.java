package com.itserviceflow.daos;

import com.itserviceflow.dtos.ChangeRequestDetailDTO;
import com.itserviceflow.dtos.ChangeRequestFilterDTO;
import com.itserviceflow.dtos.ChangeRequestListDTO;
import com.itserviceflow.dtos.ServiceRequestCommentDTO;
import com.itserviceflow.dtos.UserOptionDTO;
import com.itserviceflow.utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ChangeRequestDAO {

    private ChangeRequestListDTO mapListDTO(ResultSet rs) throws SQLException {
        ChangeRequestListDTO dto = new ChangeRequestListDTO();
        dto.setTicketId(rs.getInt("ticket_id"));
        dto.setTicketNumber(rs.getString("ticket_number"));
        dto.setTitle(rs.getString("title"));
        dto.setDescription(rs.getString("description"));
        dto.setStatus(rs.getString("status"));
        dto.setPriority(rs.getString("priority"));
        dto.setChangeType(rs.getString("change_type"));
        dto.setRiskLevel(rs.getString("risk_level"));
        dto.setApprovalStatus(rs.getString("approval_status"));
        dto.setReportedBy(rs.getInt("reported_by"));
        dto.setReportedByName(rs.getString("reported_by_name"));

        int assignedTo = rs.getInt("assigned_to");
        dto.setAssignedTo(rs.wasNull() ? null : assignedTo);
        dto.setAssignedToName(rs.getString("assigned_to_name"));

        dto.setScheduledStart(rs.getTimestamp("scheduled_start"));
        dto.setScheduledEnd(rs.getTimestamp("scheduled_end"));
        dto.setCreatedAt(rs.getTimestamp("created_at"));
        return dto;
    }

    private ChangeRequestDetailDTO mapDetailDTO(ResultSet rs) throws SQLException {
        ChangeRequestDetailDTO dto = new ChangeRequestDetailDTO();
        dto.setTicketId(rs.getInt("ticket_id"));
        dto.setTicketNumber(rs.getString("ticket_number"));
        dto.setTitle(rs.getString("title"));
        dto.setDescription(rs.getString("description"));
        dto.setStatus(rs.getString("status"));
        dto.setPriority(rs.getString("priority"));
        dto.setApprovalStatus(rs.getString("approval_status"));
        dto.setChangeType(rs.getString("change_type"));
        dto.setRiskLevel(rs.getString("risk_level"));
        dto.setImpactAssessment(rs.getString("impact_assessment"));
        dto.setImplementationPlan(rs.getString("implementation_plan"));
        dto.setRollbackPlan(rs.getString("rollback_plan"));
        dto.setTestPlan(rs.getString("test_plan"));
        dto.setJustification(rs.getString("justification"));
        dto.setSolution(rs.getString("solution"));
        dto.setCabRiskAssessment(rs.getString("cab_risk_assessment"));
        dto.setCabComment(rs.getString("cab_comment"));
        dto.setReportedBy(rs.getInt("reported_by"));
        dto.setReportedByName(rs.getString("reported_by_name"));

        int assignedTo = rs.getInt("assigned_to");
        dto.setAssignedTo(rs.wasNull() ? null : assignedTo);
        dto.setAssignedToName(rs.getString("assigned_to_name"));

        int cabMemberId = rs.getInt("cab_member_id");
        dto.setCabMemberId(rs.wasNull() ? null : cabMemberId);
        dto.setCabMemberName(rs.getString("cab_member_name"));

        dto.setScheduledStart(rs.getTimestamp("scheduled_start"));
        dto.setScheduledEnd(rs.getTimestamp("scheduled_end"));
        dto.setActualStart(rs.getTimestamp("actual_start"));
        dto.setActualEnd(rs.getTimestamp("actual_end"));
        dto.setCreatedAt(rs.getTimestamp("created_at"));
        dto.setUpdatedAt(rs.getTimestamp("updated_at"));
        return dto;
    }

    private ServiceRequestCommentDTO mapCommentDTO(ResultSet rs) throws SQLException {
        ServiceRequestCommentDTO dto = new ServiceRequestCommentDTO();
        dto.setCommentId(rs.getInt("comment_id"));
        dto.setTicketId(rs.getInt("ticket_id"));
        dto.setUserId(rs.getInt("user_id"));
        dto.setUserName(rs.getString("user_name"));
        int roleId = rs.getInt("user_role_id");
        dto.setUserRoleId(rs.wasNull() ? null : roleId);
        dto.setCommentText(rs.getString("comment_text"));
        dto.setCreatedAt(rs.getTimestamp("created_at"));
        dto.setUpdatedAt(rs.getTimestamp("updated_at"));
        return dto;
    }

    private UserOptionDTO mapUserOption(ResultSet rs) throws SQLException {
        UserOptionDTO dto = new UserOptionDTO();
        dto.setUserId(rs.getInt("user_id"));
        dto.setFullName(rs.getString("full_name"));
        int roleId = rs.getInt("role_id");
        dto.setRoleId(rs.wasNull() ? null : roleId);
        int departmentId = rs.getInt("department_id");
        dto.setDepartmentId(rs.wasNull() ? null : departmentId);
        return dto;
    }

    public List<ChangeRequestListDTO> getChangeRequestList(ChangeRequestFilterDTO filter) {
        List<ChangeRequestListDTO> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT t.ticket_id, t.ticket_number, t.title, t.description, t.status, t.priority, ")
           .append("t.change_type, t.risk_level, t.approval_status, ")
           .append("t.reported_by, rb.full_name AS reported_by_name, ")
           .append("t.assigned_to, au.full_name AS assigned_to_name, ")
           .append("t.scheduled_start, t.scheduled_end, t.created_at ")
           .append("FROM ticket t ")
           .append("LEFT JOIN `user` rb ON t.reported_by = rb.user_id ")
           .append("LEFT JOIN `user` au ON t.assigned_to = au.user_id ")
           .append("WHERE t.ticket_type = 'CHANGE' ");

        if (filter != null) {
            if (filter.getSearch() != null && !filter.getSearch().trim().isEmpty()) {
                sql.append("AND (t.ticket_number LIKE ? OR t.title LIKE ? OR t.description LIKE ?) ");
            }
            if (filter.getStatusFilter() != null && !filter.getStatusFilter().trim().isEmpty()) {
                sql.append("AND t.status = ? ");
            }
            if (filter.getRequesterId() != null) {
                sql.append("AND t.reported_by = ? ");
            }
        }

        sql.append("ORDER BY t.created_at DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int idx = 1;
            if (filter != null) {
                if (filter.getSearch() != null && !filter.getSearch().trim().isEmpty()) {
                    String search = "%" + filter.getSearch().trim() + "%";
                    ps.setString(idx++, search);
                    ps.setString(idx++, search);
                    ps.setString(idx++, search);
                }
                if (filter.getStatusFilter() != null && !filter.getStatusFilter().trim().isEmpty()) {
                    ps.setString(idx++, filter.getStatusFilter().trim());
                }
                if (filter.getRequesterId() != null) {
                    ps.setInt(idx++, filter.getRequesterId());
                }
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapListDTO(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public ChangeRequestDetailDTO getChangeRequestDetail(int ticketId) {
        String sql = "SELECT t.ticket_id, t.ticket_number, t.title, t.description, t.status, t.priority, " +
                "t.approval_status, t.change_type, t.risk_level, t.impact_assessment, t.implementation_plan, " +
                "t.rollback_plan, t.test_plan, t.justification, t.solution, t.cab_risk_assessment, t.cab_comment, " +
                "t.reported_by, rb.full_name AS reported_by_name, t.assigned_to, au.full_name AS assigned_to_name, " +
                "t.cab_member_id, cb.full_name AS cab_member_name, t.scheduled_start, t.scheduled_end, " +
                "t.actual_start, t.actual_end, t.created_at, t.updated_at " +
                "FROM ticket t " +
                "LEFT JOIN `user` rb ON t.reported_by = rb.user_id " +
                "LEFT JOIN `user` au ON t.assigned_to = au.user_id " +
                "LEFT JOIN `user` cb ON t.cab_member_id = cb.user_id " +
                "WHERE t.ticket_id = ? AND t.ticket_type = 'CHANGE'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                ChangeRequestDetailDTO dto = mapDetailDTO(rs);
                dto.setComments(getCommentsByTicketId(ticketId));
                return dto;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean createChangeRequest(ChangeRequestDetailDTO dto) {
        String sql = "INSERT INTO ticket (" +
                "ticket_number, ticket_type, title, description, status, priority, approval_status, " +
                "reported_by, department_id, change_type, risk_level, justification, impact_assessment, " +
                "implementation_plan, rollback_plan, test_plan, scheduled_start, scheduled_end, downtime_required, estimated_downtime_hour" +
                ") VALUES (?, 'CHANGE', ?, ?, 'NEW', ?, 'PENDING', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, dto.getTicketNumber());
            ps.setString(2, dto.getTitle());
            ps.setString(3, dto.getDescription());
            ps.setString(4, dto.getPriority());
            ps.setInt(5, dto.getReportedBy());
            ps.setInt(6, dto.getAssignedTo() == null ? dto.getReportedBy() : dto.getAssignedTo()); // placeholder if needed
            ps.setString(7, dto.getChangeType());
            ps.setString(8, dto.getRiskLevel());
            ps.setString(9, dto.getJustification());
            ps.setString(10, dto.getImpactAssessment());
            ps.setString(11, dto.getImplementationPlan());
            ps.setString(12, dto.getRollbackPlan());
            ps.setString(13, dto.getTestPlan());
            ps.setTimestamp(14, dto.getScheduledStart());
            ps.setTimestamp(15, dto.getScheduledEnd());
            ps.setBoolean(16, false);
            ps.setNull(17, Types.DECIMAL);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateChangeRequest(ChangeRequestDetailDTO dto) {
        String sql = "UPDATE ticket SET " +
                "title = ?, description = ?, priority = ?, change_type = ?, risk_level = ?, " +
                "justification = ?, impact_assessment = ?, implementation_plan = ?, rollback_plan = ?, test_plan = ?, " +
                "scheduled_start = ?, scheduled_end = ?, updated_at = CURRENT_TIMESTAMP " +
                "WHERE ticket_id = ? AND ticket_type = 'CHANGE' AND status = 'NEW'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, dto.getTitle());
            ps.setString(2, dto.getDescription());
            ps.setString(3, dto.getPriority());
            ps.setString(4, dto.getChangeType());
            ps.setString(5, dto.getRiskLevel());
            ps.setString(6, dto.getJustification());
            ps.setString(7, dto.getImpactAssessment());
            ps.setString(8, dto.getImplementationPlan());
            ps.setString(9, dto.getRollbackPlan());
            ps.setString(10, dto.getTestPlan());
            ps.setTimestamp(11, dto.getScheduledStart());
            ps.setTimestamp(12, dto.getScheduledEnd());
            ps.setInt(13, dto.getTicketId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteChangeRequest(int ticketId) {
        String sql = "DELETE FROM ticket WHERE ticket_id = ? AND ticket_type = 'CHANGE' AND status = 'NEW' " +
                "AND (cab_risk_assessment IS NULL OR TRIM(cab_risk_assessment) = '')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public int bulkDeleteChangeRequests(String[] ticketIds) {
        if (ticketIds == null || ticketIds.length == 0) return 0;
        int count = 0;
        String sql = "DELETE FROM ticket WHERE ticket_id = ? AND ticket_type = 'CHANGE' AND status = 'NEW' " +
                "AND (cab_risk_assessment IS NULL OR TRIM(cab_risk_assessment) = '')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (String id : ticketIds) {
                ps.setInt(1, Integer.parseInt(id));
                ps.addBatch();
            }
            int[] results = ps.executeBatch();
            for (int r : results) {
                if (r > 0) count++;
            }
        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
        }
        return count;
    }

    public boolean cancelChangeRequest(int ticketId) {
        String sql = "UPDATE ticket SET status = 'CANCELLED', updated_at = CURRENT_TIMESTAMP WHERE ticket_id = ? AND ticket_type = 'CHANGE'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean assignChangeRequest(int ticketId, int engineerId) {
        String sql = "UPDATE ticket SET assigned_to = ?, status = CASE WHEN status = 'NEW' THEN 'ASSIGNED' ELSE status END, updated_at = CURRENT_TIMESTAMP WHERE ticket_id = ? AND ticket_type = 'CHANGE'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, engineerId);
            ps.setInt(2, ticketId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean assessRisk(int ticketId, int cabMemberId, String riskLevel, String impactAssessment, String cabRiskAssessment, Timestamp scheduledStart, Timestamp scheduledEnd) {
        String sql = "UPDATE ticket SET cab_member_id = ?, risk_level = ?, impact_assessment = ?, cab_risk_assessment = ?, scheduled_start = ?, scheduled_end = ?, updated_at = CURRENT_TIMESTAMP WHERE ticket_id = ? AND ticket_type = 'CHANGE'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cabMemberId);
            ps.setString(2, riskLevel);
            ps.setString(3, impactAssessment);
            ps.setString(4, cabRiskAssessment);
            ps.setTimestamp(5, scheduledStart);
            ps.setTimestamp(6, scheduledEnd);
            ps.setInt(7, ticketId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean reviewChangeRequest(int ticketId, int cabMemberId, boolean approve, String cabComment) {
        String sql = "UPDATE ticket SET cab_member_id = ?, approval_status = ?, status = ?, cab_comment = ?, updated_at = CURRENT_TIMESTAMP WHERE ticket_id = ? AND ticket_type = 'CHANGE'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cabMemberId);
            ps.setString(2, approve ? "APPROVED" : "REJECTED");
            ps.setString(3, approve ? "ASSIGNED" : "CANCELLED");
            ps.setString(4, cabComment);
            ps.setInt(5, ticketId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean addComment(int ticketId, int userId, String commentText) {
        String sql = "INSERT INTO comment (ticket_id, user_id, comment_text) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ps.setInt(2, userId);
            ps.setString(3, commentText);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<ServiceRequestCommentDTO> getCommentsByTicketId(int ticketId) {
        List<ServiceRequestCommentDTO> comments = new ArrayList<>();
        String sql = "SELECT c.comment_id, c.ticket_id, c.user_id, u.full_name AS user_name, u.role_id AS user_role_id, c.comment_text, c.created_at, c.updated_at " +
                "FROM comment c JOIN `user` u ON c.user_id = u.user_id WHERE c.ticket_id = ? ORDER BY c.created_at ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                comments.add(mapCommentDTO(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return comments;
    }

    public List<UserOptionDTO> getSystemEngineers() {
        List<UserOptionDTO> list = new ArrayList<>();
        String sql = "SELECT user_id, full_name, role_id, department_id FROM `user` WHERE role_id = 6 AND is_active = 1 ORDER BY full_name ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapUserOption(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public String generateNextChangeRequestNumber() {
        String sql = "SELECT COUNT(*) + 1 AS next_no FROM ticket WHERE ticket_type = 'CHANGE'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return "CHG-" + String.format("%06d", rs.getInt("next_no"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return "CHG-000001";
    }
}
