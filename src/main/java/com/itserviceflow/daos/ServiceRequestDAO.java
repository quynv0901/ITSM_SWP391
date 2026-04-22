package com.itserviceflow.daos;

import com.itserviceflow.dtos.ServiceRequestCommentDTO;
import com.itserviceflow.dtos.ServiceRequestDetailDTO;
import com.itserviceflow.dtos.ServiceRequestFilterDTO;
import com.itserviceflow.dtos.ServiceRequestListDTO;
import com.itserviceflow.dtos.CategoryOptionDTO;
import com.itserviceflow.dtos.DepartmentOptionDTO;
import com.itserviceflow.dtos.ServiceOptionDTO;
import com.itserviceflow.dtos.UserOptionDTO;
import com.itserviceflow.utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ServiceRequestDAO {

    private ServiceRequestListDTO mapListDTO(ResultSet rs) throws SQLException {
        ServiceRequestListDTO dto = new ServiceRequestListDTO();

        dto.setTicketId(rs.getInt("ticket_id"));
        dto.setTicketNumber(rs.getString("ticket_number"));
        dto.setTitle(rs.getString("title"));
        dto.setStatus(rs.getString("status"));
        dto.setPriority(rs.getString("priority"));
        dto.setApprovalStatus(rs.getString("approval_status"));

        int serviceId = rs.getInt("service_id");
        dto.setServiceId(rs.wasNull() ? null : serviceId);
        dto.setServiceName(rs.getString("service_name"));
        dto.setServiceCode(rs.getString("service_code"));

        dto.setReportedBy(rs.getInt("reported_by"));
        dto.setReportedByName(rs.getString("reported_by_name"));

        int assignedTo = rs.getInt("assigned_to");
        dto.setAssignedTo(rs.wasNull() ? null : assignedTo);
        dto.setAssignedToName(rs.getString("assigned_to_name"));

        int departmentId = rs.getInt("department_id");
        dto.setDepartmentId(rs.wasNull() ? null : departmentId);
        dto.setDepartmentName(rs.getString("department_name"));

        dto.setCreatedAt(rs.getTimestamp("created_at"));
        dto.setUpdatedAt(rs.getTimestamp("updated_at"));

        return dto;
    }

    private ServiceRequestDetailDTO mapDetailDTO(ResultSet rs) throws SQLException {
        ServiceRequestDetailDTO dto = new ServiceRequestDetailDTO();

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
        dto.setCategoryName(rs.getString("category_name"));

        int serviceId = rs.getInt("service_id");
        dto.setServiceId(rs.wasNull() ? null : serviceId);
        dto.setServiceName(rs.getString("service_name"));
        dto.setServiceCode(rs.getString("service_code"));
        dto.setServiceDescription(rs.getString("service_description"));

        int estimatedDeliveryDay = rs.getInt("estimated_delivery_day");
        dto.setEstimatedDeliveryDay(rs.wasNull() ? null : estimatedDeliveryDay);

        dto.setReportedBy(rs.getInt("reported_by"));
        dto.setReportedByName(rs.getString("reported_by_name"));

        int assignedTo = rs.getInt("assigned_to");
        dto.setAssignedTo(rs.wasNull() ? null : assignedTo);
        dto.setAssignedToName(rs.getString("assigned_to_name"));

        int departmentId = rs.getInt("department_id");
        dto.setDepartmentId(rs.wasNull() ? null : departmentId);
        dto.setDepartmentName(rs.getString("department_name"));

        dto.setJustification(rs.getString("justification"));
        dto.setSolution(rs.getString("solution"));
        dto.setRejectionReason(rs.getString("rejection_reason"));

        int approvedBy = rs.getInt("approved_by");
        dto.setApprovedBy(rs.wasNull() ? null : approvedBy);
        dto.setApprovedByName(rs.getString("approved_by_name"));
        dto.setApprovedAt(rs.getTimestamp("approved_at"));

        dto.setCreatedAt(rs.getTimestamp("created_at"));
        dto.setUpdatedAt(rs.getTimestamp("updated_at"));
        dto.setCompletedAt(rs.getTimestamp("completed_at"));
        dto.setCancelledAt(rs.getTimestamp("cancelled_at"));

        return dto;
    }

    private ServiceRequestCommentDTO mapCommentDTO(ResultSet rs) throws SQLException {
        ServiceRequestCommentDTO dto = new ServiceRequestCommentDTO();

        dto.setCommentId(rs.getInt("comment_id"));
        dto.setTicketId(rs.getInt("ticket_id"));
        dto.setUserId(rs.getInt("user_id"));
        dto.setUserName(rs.getString("user_name"));

        int userRoleId = rs.getInt("user_role_id");
        dto.setUserRoleId(rs.wasNull() ? null : userRoleId);

        dto.setCommentText(rs.getString("comment_text"));
        dto.setCreatedAt(rs.getTimestamp("created_at"));
        dto.setUpdatedAt(rs.getTimestamp("updated_at"));

        return dto;
    }

    private String buildCommonListSql(ServiceRequestFilterDTO filter) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ")
                .append(" t.ticket_id, t.ticket_number, t.title, t.status, t.priority, t.approval_status, ")
                .append(" t.service_id, s.service_name, s.service_code, ")
                .append(" t.reported_by, rb.full_name AS reported_by_name, ")
                .append(" t.assigned_to, au.full_name AS assigned_to_name, ")
                .append(" t.department_id, d.department_name, ")
                .append(" t.created_at, t.updated_at ")
                .append("FROM ticket t ")
                .append("LEFT JOIN service s ON t.service_id = s.service_id ")
                .append("LEFT JOIN `user` rb ON t.reported_by = rb.user_id ")
                .append("LEFT JOIN `user` au ON t.assigned_to = au.user_id ")
                .append("LEFT JOIN department d ON t.department_id = d.department_id ")
                .append("WHERE t.ticket_type = 'SERVICE_REQUEST' ");

        if (filter != null) {
            if (filter.getKeyword() != null && !filter.getKeyword().trim().isEmpty()) {
                sql.append("AND (")
                        .append(" t.ticket_number LIKE ? ")
                        .append(" OR t.title LIKE ? ")
                        .append(" OR t.description LIKE ? ")
                        .append(" OR s.service_name LIKE ? ")
                        .append(" OR s.service_code LIKE ? ")
                        .append(") ");
            }

            if (filter.getStatus() != null && !filter.getStatus().trim().isEmpty()) {
                sql.append("AND t.status = ? ");
            }

            if (filter.getApprovalStatus() != null && !filter.getApprovalStatus().trim().isEmpty()) {
                sql.append("AND t.approval_status = ? ");
            }
        }

        return sql.toString();
    }

    private int bindCommonListParams(PreparedStatement ps, ServiceRequestFilterDTO filter) throws SQLException {
        int idx = 1;

        if (filter != null) {
            if (filter.getKeyword() != null && !filter.getKeyword().trim().isEmpty()) {
                String keyword = "%" + filter.getKeyword().trim() + "%";
                ps.setString(idx++, keyword);
                ps.setString(idx++, keyword);
                ps.setString(idx++, keyword);
                ps.setString(idx++, keyword);
                ps.setString(idx++, keyword);
            }

            if (filter.getStatus() != null && !filter.getStatus().trim().isEmpty()) {
                ps.setString(idx++, filter.getStatus().trim());
            }

            if (filter.getApprovalStatus() != null && !filter.getApprovalStatus().trim().isEmpty()) {
                ps.setString(idx++, filter.getApprovalStatus().trim());
            }
        }

        return idx;
    }

    public List<ServiceRequestListDTO> getAllServiceRequests(ServiceRequestFilterDTO filter) {
        List<ServiceRequestListDTO> list = new ArrayList<>();
        String sql = buildCommonListSql(filter) + " ORDER BY t.created_at DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            bindCommonListParams(ps, filter);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapListDTO(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<ServiceRequestListDTO> getServiceRequestsByRequester(int requesterId, ServiceRequestFilterDTO filter) {
        List<ServiceRequestListDTO> list = new ArrayList<>();
        String sql = buildCommonListSql(filter)
                + " AND t.reported_by = ? "
                + " ORDER BY t.created_at DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            int idx = bindCommonListParams(ps, filter);
            ps.setInt(idx, requesterId);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapListDTO(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<ServiceRequestListDTO> getServiceRequestsByAssignee(int assigneeId, ServiceRequestFilterDTO filter) {
        List<ServiceRequestListDTO> list = new ArrayList<>();
        String sql = buildCommonListSql(filter)
                + " AND t.assigned_to = ? "
                + " ORDER BY t.created_at DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            int idx = bindCommonListParams(ps, filter);
            ps.setInt(idx, assigneeId);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapListDTO(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<ServiceRequestListDTO> getServiceRequestsByDepartment(int departmentId, ServiceRequestFilterDTO filter) {
        List<ServiceRequestListDTO> list = new ArrayList<>();
        String sql = buildCommonListSql(filter)
                + " AND t.department_id = ? "
                + " ORDER BY t.created_at DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            int idx = bindCommonListParams(ps, filter);
            ps.setInt(idx, departmentId);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapListDTO(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public ServiceRequestDetailDTO getServiceRequestById(int ticketId) {
        String sql = "SELECT "
                + " t.ticket_id, t.ticket_number, t.ticket_type, t.title, t.description, "
                + " t.status, t.priority, t.approval_status, "
                + " t.category_id, tc.category_name, "
                + " t.service_id, s.service_name, s.service_code, s.description AS service_description, s.estimated_delivery_day, "
                + " t.reported_by, rb.full_name AS reported_by_name, "
                + " t.assigned_to, au.full_name AS assigned_to_name, "
                + " t.department_id, d.department_name, "
                + " t.justification, t.solution, t.rejection_reason, "
                + " t.approved_by, ap.full_name AS approved_by_name, t.approved_at, "
                + " t.created_at, t.updated_at, t.completed_at, t.cancelled_at "
                + "FROM ticket t "
                + "LEFT JOIN service s ON t.service_id = s.service_id "
                + "LEFT JOIN ticket_category tc ON t.category_id = tc.category_id "
                + "LEFT JOIN `user` rb ON t.reported_by = rb.user_id "
                + "LEFT JOIN `user` au ON t.assigned_to = au.user_id "
                + "LEFT JOIN `user` ap ON t.approved_by = ap.user_id "
                + "LEFT JOIN department d ON t.department_id = d.department_id "
                + "WHERE t.ticket_id = ? "
                + "AND t.ticket_type = 'SERVICE_REQUEST'";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, ticketId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                ServiceRequestDetailDTO dto = mapDetailDTO(rs);
                dto.setComments(getCommentsByTicketId(ticketId));
                return dto;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public List<ServiceRequestCommentDTO> getCommentsByTicketId(int ticketId) {
        List<ServiceRequestCommentDTO> comments = new ArrayList<>();

        String sql = "SELECT "
                + " c.comment_id, c.ticket_id, c.user_id, "
                + " u.full_name AS user_name, u.role_id AS user_role_id, "
                + " c.comment_text, c.created_at, c.updated_at "
                + "FROM comment c "
                + "JOIN `user` u ON c.user_id = u.user_id "
                + "WHERE c.ticket_id = ? "
                + "ORDER BY c.created_at ASC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

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

    private ServiceOptionDTO mapServiceOptionDTO(ResultSet rs) throws SQLException {
        ServiceOptionDTO dto = new ServiceOptionDTO();

        dto.setServiceId(rs.getInt("service_id"));
        dto.setServiceName(rs.getString("service_name"));
        dto.setServiceCode(rs.getString("service_code"));

        int estimatedDeliveryDay = rs.getInt("estimated_delivery_day");
        dto.setEstimatedDeliveryDay(rs.wasNull() ? null : estimatedDeliveryDay);

        return dto;
    }

    private CategoryOptionDTO mapCategoryOptionDTO(ResultSet rs) throws SQLException {
        CategoryOptionDTO dto = new CategoryOptionDTO();

        dto.setCategoryId(rs.getInt("category_id"));
        dto.setCategoryName(rs.getString("category_name"));
        dto.setCategoryCode(rs.getString("category_code"));

        return dto;
    }

    private DepartmentOptionDTO mapDepartmentOptionDTO(ResultSet rs) throws SQLException {
        DepartmentOptionDTO dto = new DepartmentOptionDTO();
        dto.setDepartmentId(rs.getInt("department_id"));
        dto.setDepartmentName(rs.getString("department_name"));
        dto.setDepartmentCode(rs.getString("department_code"));
        return dto;
    }

    private UserOptionDTO mapUserOptionDTO(ResultSet rs) throws SQLException {
        UserOptionDTO dto = new UserOptionDTO();

        dto.setUserId(rs.getInt("user_id"));
        dto.setFullName(rs.getString("full_name"));

        int roleId = rs.getInt("role_id");
        dto.setRoleId(rs.wasNull() ? null : roleId);

        int departmentId = rs.getInt("department_id");
        dto.setDepartmentId(rs.wasNull() ? null : departmentId);

        return dto;
    }

    public boolean isServiceActive(int serviceId) {
        String sql = "SELECT COUNT(*) FROM service WHERE service_id = ? AND status = 'ACTIVE'";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, serviceId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean createServiceRequest(ServiceRequestDetailDTO dto) {
        if (dto == null || dto.getServiceId() == null || !isServiceActive(dto.getServiceId())) {
            return false;
        }

        String sql = "INSERT INTO ticket ("
                + " ticket_number, ticket_type, title, description, status, priority, "
                + " category_id, reported_by, department_id, approval_status, service_id, justification "
                + ") VALUES (?, 'SERVICE_REQUEST', ?, ?, 'NEW', ?, ?, ?, ?, 'PENDING', ?, ?)";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, dto.getTicketNumber());
            ps.setString(2, dto.getTitle());
            ps.setString(3, dto.getDescription());
            ps.setString(4, dto.getPriority());

            if (dto.getCategoryId() != null) {
                ps.setInt(5, dto.getCategoryId());
            } else {
                ps.setNull(5, Types.INTEGER);
            }

            ps.setInt(6, dto.getReportedBy());

            if (dto.getDepartmentId() != null) {
                ps.setInt(7, dto.getDepartmentId());
            } else {
                ps.setNull(7, Types.INTEGER);
            }

            ps.setInt(8, dto.getServiceId());
            ps.setString(9, dto.getJustification());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean updateServiceRequest(ServiceRequestDetailDTO dto) {
        if (dto == null || dto.getTicketId() <= 0) {
            return false;
        }

        String sql = "UPDATE ticket SET "
                + " title = ?, "
                + " description = ?, "
                + " status = ?, "
                + " assigned_to = ?, "
                + " solution = ?, "
                + " updated_at = CURRENT_TIMESTAMP "
                + "WHERE ticket_id = ? "
                + "AND ticket_type = 'SERVICE_REQUEST'";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, dto.getTitle());
            ps.setString(2, dto.getDescription());
            ps.setString(3, dto.getStatus());

            if (dto.getAssignedTo() != null) {
                ps.setInt(4, dto.getAssignedTo());
            } else {
                ps.setNull(4, Types.INTEGER);
            }

            ps.setString(5, dto.getSolution());
            ps.setInt(6, dto.getTicketId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean canDeleteServiceRequest(int ticketId, int requesterId) {
        String sql = "SELECT COUNT(*) "
                + "FROM ticket "
                + "WHERE ticket_id = ? "
                + "AND ticket_type = 'SERVICE_REQUEST' "
                + "AND reported_by = ? "
                + "AND status = 'NEW' "
                + "AND assigned_to IS NULL";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, ticketId);
            ps.setInt(2, requesterId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean deleteServiceRequest(int ticketId, int requesterId) {
        if (!canDeleteServiceRequest(ticketId, requesterId)) {
            return false;
        }

        String sql = "DELETE FROM ticket "
                + "WHERE ticket_id = ? "
                + "AND ticket_type = 'SERVICE_REQUEST'";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, ticketId);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public int bulkDeleteServiceRequests(String[] ticketIds, int requesterId) {
        if (ticketIds == null || ticketIds.length == 0) {
            return 0;
        }

        String sql = "DELETE FROM ticket "
                + "WHERE ticket_id = ? "
                + "AND ticket_type = 'SERVICE_REQUEST' "
                + "AND reported_by = ? "
                + "AND status = 'NEW' "
                + "AND assigned_to IS NULL";

        int deletedCount = 0;

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            for (String id : ticketIds) {
                ps.setInt(1, Integer.parseInt(id));
                ps.setInt(2, requesterId);
                ps.addBatch();
            }

            int[] results = ps.executeBatch();
            for (int r : results) {
                if (r > 0) {
                    deletedCount++;
                }
            }

        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
        }

        return deletedCount;
    }

    public boolean cancelServiceRequest(int ticketId) {
        String sql = "UPDATE ticket SET "
                + " status = 'CANCELLED', "
                + " cancelled_at = CURRENT_TIMESTAMP, "
                + " updated_at = CURRENT_TIMESTAMP "
                + "WHERE ticket_id = ? "
                + "AND ticket_type = 'SERVICE_REQUEST'";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, ticketId);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean cancelServiceRequestByRequester(int ticketId, int requesterId) {
        String sql = "UPDATE ticket SET "
                + " status = 'CANCELLED', "
                + " cancelled_at = CURRENT_TIMESTAMP, "
                + " updated_at = CURRENT_TIMESTAMP "
                + "WHERE ticket_id = ? "
                + "AND ticket_type = 'SERVICE_REQUEST' "
                + "AND reported_by = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, ticketId);
            ps.setInt(2, requesterId);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean assignServiceRequest(int ticketId, int assignedTo) {
        String sql = "UPDATE ticket SET "
                + " assigned_to = ?, "
                + " status = CASE WHEN status = 'NEW' THEN 'ASSIGNED' ELSE status END, "
                + " updated_at = CURRENT_TIMESTAMP "
                + "WHERE ticket_id = ? "
                + "AND ticket_type = 'SERVICE_REQUEST'";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, assignedTo);
            ps.setInt(2, ticketId);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean approveServiceRequest(int ticketId, int approvedBy) {
        String sql = "UPDATE ticket SET "
                + " approval_status = 'APPROVED', "
                + " approved_by = ?, "
                + " approved_at = CURRENT_TIMESTAMP, "
                + " rejection_reason = NULL, "
                + " updated_at = CURRENT_TIMESTAMP "
                + "WHERE ticket_id = ? "
                + "AND ticket_type = 'SERVICE_REQUEST'";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, approvedBy);
            ps.setInt(2, ticketId);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean rejectServiceRequest(int ticketId, int approvedBy, String rejectionReason) {
        String sql = "UPDATE ticket SET "
                + " approval_status = 'REJECTED', "
                + " approved_by = ?, "
                + " approved_at = CURRENT_TIMESTAMP, "
                + " rejection_reason = ?, "
                + " updated_at = CURRENT_TIMESTAMP "
                + "WHERE ticket_id = ? "
                + "AND ticket_type = 'SERVICE_REQUEST'";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, approvedBy);
            ps.setString(2, rejectionReason);
            ps.setInt(3, ticketId);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public int bulkApproveServiceRequests(String[] ticketIds, int approvedBy) {
        if (ticketIds == null || ticketIds.length == 0) {
            return 0;
        }

        String sql = "UPDATE ticket SET "
                + " approval_status = 'APPROVED', "
                + " approved_by = ?, "
                + " approved_at = CURRENT_TIMESTAMP, "
                + " rejection_reason = NULL, "
                + " updated_at = CURRENT_TIMESTAMP "
                + "WHERE ticket_id = ? "
                + "AND ticket_type = 'SERVICE_REQUEST'";

        int updatedCount = 0;

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            for (String id : ticketIds) {
                ps.setInt(1, approvedBy);
                ps.setInt(2, Integer.parseInt(id));
                ps.addBatch();
            }

            int[] results = ps.executeBatch();
            for (int r : results) {
                if (r > 0) {
                    updatedCount++;
                }
            }

        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
        }

        return updatedCount;
    }

    public int bulkRejectServiceRequests(String[] ticketIds, int approvedBy, String rejectionReason) {
        if (ticketIds == null || ticketIds.length == 0) {
            return 0;
        }

        String sql = "UPDATE ticket SET "
                + " approval_status = 'REJECTED', "
                + " approved_by = ?, "
                + " approved_at = CURRENT_TIMESTAMP, "
                + " rejection_reason = ?, "
                + " updated_at = CURRENT_TIMESTAMP "
                + "WHERE ticket_id = ? "
                + "AND ticket_type = 'SERVICE_REQUEST'";

        int updatedCount = 0;

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            for (String id : ticketIds) {
                ps.setInt(1, approvedBy);
                ps.setString(2, rejectionReason);
                ps.setInt(3, Integer.parseInt(id));
                ps.addBatch();
            }

            int[] results = ps.executeBatch();
            for (int r : results) {
                if (r > 0) {
                    updatedCount++;
                }
            }

        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
        }

        return updatedCount;
    }

    public boolean addComment(int ticketId, int userId, String commentText) {
        String sql = "INSERT INTO comment (ticket_id, user_id, comment_text) VALUES (?, ?, ?)";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, ticketId);
            ps.setInt(2, userId);
            ps.setString(3, commentText);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public String generateNextServiceRequestNumber() {
        String sql = "SELECT COUNT(*) + 1 AS next_no "
                + "FROM ticket "
                + "WHERE ticket_type = 'SERVICE_REQUEST'";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                int nextNo = rs.getInt("next_no");
                return "SR-" + String.format("%06d", nextNo);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return "SR-000001";
    }

    public List<ServiceOptionDTO> getActiveServicesForOption() {
        List<ServiceOptionDTO> services = new ArrayList<>();

        String sql = "SELECT service_id, service_name, service_code, estimated_delivery_day "
                + "FROM service "
                + "WHERE status = 'ACTIVE' "
                + "ORDER BY service_name ASC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                services.add(mapServiceOptionDTO(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return services;
    }

    public List<CategoryOptionDTO> getServiceRequestCategories() {
        List<CategoryOptionDTO> categories = new ArrayList<>();

        String sql = "SELECT category_id, category_name, category_code "
                + "FROM ticket_category "
                + "WHERE category_type = 'SERVICE_REQUEST' "
                + "ORDER BY category_name ASC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                categories.add(mapCategoryOptionDTO(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return categories;
    }

    public List<DepartmentOptionDTO> getActiveDepartments() {
        List<DepartmentOptionDTO> departments = new ArrayList<>();

        String sql = "SELECT department_id, department_name, department_code "
                + "FROM department "
                + "WHERE status = 'ACTIVE' "
                + "ORDER BY department_name ASC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                departments.add(mapDepartmentOptionDTO(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return departments;
    }

    public List<UserOptionDTO> getSupportAgents() {
        List<UserOptionDTO> agents = new ArrayList<>();

        String sql = "SELECT user_id, full_name, role_id, department_id "
                + "FROM `user` "
                + "WHERE role_id = 2 "
                + "AND is_active = 1 "
                + "ORDER BY full_name ASC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                agents.add(mapUserOptionDTO(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return agents;
    }

    public List<UserOptionDTO> getSupportAgentsByDepartment(int departmentId) {
        List<UserOptionDTO> agents = new ArrayList<>();

        String sql = "SELECT user_id, full_name, role_id, department_id "
                + "FROM `user` "
                + "WHERE role_id = 2 "
                + "AND is_active = 1 "
                + "AND department_id = ? "
                + "ORDER BY full_name ASC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, departmentId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                agents.add(mapUserOptionDTO(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return agents;
    }
}
