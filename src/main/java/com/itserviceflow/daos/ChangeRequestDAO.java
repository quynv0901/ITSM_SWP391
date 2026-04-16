package com.itserviceflow.daos;

import com.itserviceflow.dtos.ChangeRequestDTO;
import com.itserviceflow.utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ChangeRequestDAO {

    private ChangeRequestDTO mapChangeRequestDTO(ResultSet rs) throws SQLException {
        ChangeRequestDTO dto = new ChangeRequestDTO();

        dto.setTicketId(rs.getInt("ticket_id"));
        dto.setTicketNumber(rs.getString("ticket_number"));
        dto.setTicketType(rs.getString("ticket_type"));
        dto.setTitle(rs.getString("title"));
        dto.setDescription(rs.getString("description"));
        dto.setStatus(rs.getString("status"));
        dto.setPriority(rs.getString("priority"));
        dto.setApprovalStatus(rs.getString("approval_status"));

        int categoryId = rs.getInt("category_id");
        dto.setCategoryId(rs.wasNull() ? null : categoryId);

        dto.setReportedBy(rs.getInt("reported_by"));
        dto.setReportedByName(rs.getString("reported_by_name"));

        int assignedTo = rs.getInt("assigned_to");
        dto.setAssignedTo(rs.wasNull() ? null : assignedTo);
        dto.setAssignedToName(rs.getString("assigned_to_name"));

        int departmentId = rs.getInt("department_id");
        dto.setDepartmentId(rs.wasNull() ? null : departmentId);

        int serviceId = rs.getInt("service_id");
        dto.setServiceId(rs.wasNull() ? null : serviceId);

        int ciId = rs.getInt("ci_id");
        dto.setCiId(rs.wasNull() ? null : ciId);

        dto.setJustification(rs.getString("justification"));
        dto.setImpact(rs.getString("impact"));
        dto.setUrgency(rs.getString("urgency"));

        dto.setChangeType(rs.getString("change_type"));
        dto.setRiskLevel(rs.getString("risk_level"));
        dto.setImpactAssessment(rs.getString("impact_assessment"));
        dto.setRollbackPlan(rs.getString("rollback_plan"));
        dto.setImplementationPlan(rs.getString("implementation_plan"));
        dto.setTestPlan(rs.getString("test_plan"));

        dto.setCabDecision(rs.getString("cab_decision"));

        int cabMemberId = rs.getInt("cab_member_id");
        dto.setCabMemberId(rs.wasNull() ? null : cabMemberId);
        dto.setCabMemberName(rs.getString("cab_member_name"));

        dto.setCabRiskAssessment(rs.getString("cab_risk_assessment"));
        dto.setCabComment(rs.getString("cab_comment"));
        dto.setCabDecidedAt(rs.getTimestamp("cab_decided_at"));

        int approvedBy = rs.getInt("approved_by");
        dto.setApprovedBy(rs.wasNull() ? null : approvedBy);
        dto.setApprovedByName(rs.getString("approved_by_name"));

        dto.setApprovedAt(rs.getTimestamp("approved_at"));
        dto.setRejectionReason(rs.getString("rejection_reason"));

        dto.setScheduledStart(rs.getTimestamp("scheduled_start"));
        dto.setScheduledEnd(rs.getTimestamp("scheduled_end"));
        dto.setActualStart(rs.getTimestamp("actual_start"));
        dto.setActualEnd(rs.getTimestamp("actual_end"));

        dto.setDowntimeRequired(rs.getBoolean("downtime_required"));

        double estimatedDowntimeHour = rs.getDouble("estimated_downtime_hour");
        dto.setEstimatedDowntimeHour(rs.wasNull() ? null : estimatedDowntimeHour);

        dto.setCreatedAt(rs.getTimestamp("created_at"));
        dto.setUpdatedAt(rs.getTimestamp("updated_at"));
        dto.setCancelledAt(rs.getTimestamp("cancelled_at"));
        dto.setCompletedAt(rs.getTimestamp("completed_at"));
        dto.setClosedAt(rs.getTimestamp("closed_at"));

        return dto;
    }

    public List<ChangeRequestDTO> getAllChangeRequests(String search, String statusFilter) {
        List<ChangeRequestDTO> list = new ArrayList<>();

        if (search == null) {
            search = "";
        }
        if (statusFilter == null) {
            statusFilter = "";
        }

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ")
           .append(" t.ticket_id, t.ticket_number, t.ticket_type, t.title, t.description, ")
           .append(" t.status, t.priority, t.approval_status, t.category_id, ")
           .append(" t.reported_by, rb.full_name AS reported_by_name, ")
           .append(" t.assigned_to, at.full_name AS assigned_to_name, ")
           .append(" t.department_id, t.service_id, t.ci_id, t.justification, ")
           .append(" t.impact, t.urgency, ")
           .append(" t.change_type, t.risk_level, t.impact_assessment, ")
           .append(" t.rollback_plan, t.implementation_plan, t.test_plan, ")
           .append(" t.cab_decision, t.cab_member_id, cb.full_name AS cab_member_name, ")
           .append(" t.cab_risk_assessment, t.cab_comment, t.cab_decided_at, ")
           .append(" t.approved_by, ab.full_name AS approved_by_name, ")
           .append(" t.approved_at, t.rejection_reason, ")
           .append(" t.scheduled_start, t.scheduled_end, t.actual_start, t.actual_end, ")
           .append(" t.downtime_required, t.estimated_downtime_hour, ")
           .append(" t.created_at, t.updated_at, t.cancelled_at, t.completed_at, t.closed_at ")
           .append("FROM ticket t ")
           .append("LEFT JOIN `user` rb ON t.reported_by = rb.user_id ")
           .append("LEFT JOIN `user` at ON t.assigned_to = at.user_id ")
           .append("LEFT JOIN `user` cb ON t.cab_member_id = cb.user_id ")
           .append("LEFT JOIN `user` ab ON t.approved_by = ab.user_id ")
           .append("WHERE t.ticket_type = 'CHANGE' ")
           .append("AND (t.title LIKE ? OR t.ticket_number LIKE ? OR t.description LIKE ?) ");

        if (!statusFilter.trim().isEmpty()) {
            sql.append("AND t.status = ? ");
        }

        sql.append("ORDER BY t.created_at DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            String keyword = "%" + search.trim() + "%";
            ps.setString(1, keyword);
            ps.setString(2, keyword);
            ps.setString(3, keyword);

            if (!statusFilter.trim().isEmpty()) {
                ps.setString(4, statusFilter.trim());
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapChangeRequestDTO(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public ChangeRequestDTO getChangeRequestById(int ticketId) {
        String sql = "SELECT " +
                " t.ticket_id, t.ticket_number, t.ticket_type, t.title, t.description, " +
                " t.status, t.priority, t.approval_status, t.category_id, " +
                " t.reported_by, rb.full_name AS reported_by_name, " +
                " t.assigned_to, at.full_name AS assigned_to_name, " +
                " t.department_id, t.service_id, t.ci_id, t.justification, " +
                " t.impact, t.urgency, " +
                " t.change_type, t.risk_level, t.impact_assessment, " +
                " t.rollback_plan, t.implementation_plan, t.test_plan, " +
                " t.cab_decision, t.cab_member_id, cb.full_name AS cab_member_name, " +
                " t.cab_risk_assessment, t.cab_comment, t.cab_decided_at, " +
                " t.approved_by, ab.full_name AS approved_by_name, " +
                " t.approved_at, t.rejection_reason, " +
                " t.scheduled_start, t.scheduled_end, t.actual_start, t.actual_end, " +
                " t.downtime_required, t.estimated_downtime_hour, " +
                " t.created_at, t.updated_at, t.cancelled_at, t.completed_at, t.closed_at " +
                "FROM ticket t " +
                "LEFT JOIN `user` rb ON t.reported_by = rb.user_id " +
                "LEFT JOIN `user` at ON t.assigned_to = at.user_id " +
                "LEFT JOIN `user` cb ON t.cab_member_id = cb.user_id " +
                "LEFT JOIN `user` ab ON t.approved_by = ab.user_id " +
                "WHERE t.ticket_type = 'CHANGE' AND t.ticket_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, ticketId);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapChangeRequestDTO(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean assessChangeRisk(int ticketId, int cabMemberId, String cabRiskAssessment, String cabComment) {
        String sql = "UPDATE ticket " +
                "SET cab_risk_assessment = ?, " +
                "    cab_comment = ?, " +
                "    cab_member_id = ?, " +
                "    updated_at = CURRENT_TIMESTAMP " +
                "WHERE ticket_id = ? " +
                "  AND ticket_type = 'CHANGE' " +
                "  AND (cab_decision IS NULL OR cab_decision = 'PENDING')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, cabRiskAssessment);
            ps.setString(2, cabComment);
            ps.setInt(3, cabMemberId);
            ps.setInt(4, ticketId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean reviewChangeRequest(int ticketId, int cabMemberId, String decision) {
        String sql = "UPDATE ticket " +
                "SET cab_decision = ?, " +
                "    cab_member_id = ?, " +
                "    cab_decided_at = CURRENT_TIMESTAMP, " +
                "    approval_status = ?, " +
                "    status = CASE " +
                "               WHEN ? = 'APPROVED' THEN 'APPROVED' " +
                "               WHEN ? = 'REJECTED' THEN 'PENDING' " +
                "               ELSE status " +
                "             END, " +
                "    updated_at = CURRENT_TIMESTAMP " +
                "WHERE ticket_id = ? " +
                "  AND ticket_type = 'CHANGE' " +
                "  AND (cab_decision IS NULL OR cab_decision = 'PENDING')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, decision);
            ps.setInt(2, cabMemberId);
            ps.setString(3, decision);
            ps.setString(4, decision);
            ps.setString(5, decision);
            ps.setInt(6, ticketId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public int bulkReviewChangeRequests(String[] ticketIds, int cabMemberId, String decision) {
        if (ticketIds == null || ticketIds.length == 0) {
            return 0;
        }

        String sql = "UPDATE ticket " +
                "SET cab_decision = ?, " +
                "    cab_member_id = ?, " +
                "    cab_decided_at = CURRENT_TIMESTAMP, " +
                "    approval_status = ?, " +
                "    status = CASE " +
                "               WHEN ? = 'APPROVED' THEN 'APPROVED' " +
                "               WHEN ? = 'REJECTED' THEN 'PENDING' " +
                "               ELSE status " +
                "             END, " +
                "    updated_at = CURRENT_TIMESTAMP " +
                "WHERE ticket_id = ? " +
                "  AND ticket_type = 'CHANGE' " +
                "  AND (cab_decision IS NULL OR cab_decision = 'PENDING')";

        int updatedCount = 0;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            for (String id : ticketIds) {
                ps.setString(1, decision);
                ps.setInt(2, cabMemberId);
                ps.setString(3, decision);
                ps.setString(4, decision);
                ps.setString(5, decision);
                ps.setInt(6, Integer.parseInt(id));
                ps.addBatch();
            }

            int[] results = ps.executeBatch();
            for (int r : results) {
                if (r > 0) {
                    updatedCount++;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return updatedCount;
    }
}