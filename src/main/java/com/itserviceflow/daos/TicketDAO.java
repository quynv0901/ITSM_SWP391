package com.itserviceflow.daos;

import com.itserviceflow.models.Ticket;
import com.itserviceflow.models.User;
import static com.itserviceflow.utils.DBConnection.getConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import com.itserviceflow.utils.DBConnection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author ADMIN
 */
public class TicketDAO {

    public boolean createServiceRequest(Ticket ticket) {
        // mặc định là 'SERVICE_REQUEST' theo US06
        String sql = "INSERT INTO ticket (ticket_number, ticket_type, title, description, justification, "
                + "status, priority, service_id, reported_by, department_id, created_at) "
                + "VALUES (?, 'SERVICE_REQUEST', ?, ?, ?, 'NEW', ?, ?, ?, ?, CURRENT_TIMESTAMP)";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            // Tạo mã ticket tự động 
            String ticketNum = "SR-" + System.currentTimeMillis() / 1000;

            ps.setString(1, ticketNum);
            ps.setString(2, ticket.getTitle());
            ps.setString(3, ticket.getDescription());
            ps.setString(4, ticket.getJustification());
            ps.setString(5, ticket.getPriority());
            ps.setInt(6, ticket.getServiceId());
            ps.setInt(7, ticket.getReportedBy());
            ps.setInt(8, ticket.getDepartmentId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Ticket> getRequestsByRole(int userId, String role, String search, String statusFilter) {
        List<Ticket> list = new ArrayList<>();

        // Nối bảng ticket với bảng service để lấy tên hiển thị
        StringBuilder sql = new StringBuilder(
                "SELECT t.*, s.service_name FROM ticket t "
                + "LEFT JOIN service s ON t.service_id = s.service_id "
                + "WHERE t.ticket_type = 'SERVICE_REQUEST' " // Chỉ lấy các ticket là Service Request
        );

        // Phân quyền dữ liệu 
        if ("END_USER".equals(role)) {
           
            // sql.append(" AND t.reported_by = ").append(userId); 

        } else if ("SUPPORT".equals(role)) {
            sql.append(" AND (t.assigned_to = ").append(userId).append(" OR t.assigned_to IS NULL) ");
        }

        //Tìm kiếm 
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (t.title LIKE ? OR s.service_name LIKE ? OR t.ticket_number LIKE ?) ");
        }

        //Lọc theo trạng thái 
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append(" AND t.status = ? ");
        }

        sql.append(" ORDER BY t.created_at DESC");

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                String searchStr = "%" + search + "%";
                ps.setString(paramIndex++, searchStr);
                ps.setString(paramIndex++, searchStr);
                ps.setString(paramIndex++, searchStr);
            }
            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                ps.setString(paramIndex++, statusFilter);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Ticket t = new Ticket();
                t.setTicketId(rs.getInt("ticket_id"));
                t.setTicketNumber(rs.getString("ticket_number"));
                t.setTitle(rs.getString("title"));
                t.setStatus(rs.getString("status"));
                t.setPriority(rs.getString("priority"));
                t.setCreatedAt(rs.getTimestamp("created_at"));
                t.setReportedBy(rs.getInt("reported_by"));
                t.setAssignedTo((Integer) rs.getObject("assigned_to"));
                
                if (rs.getString("service_name") != null) {
                    t.setTitle(t.getTitle() + " (" + rs.getString("service_name") + ")");
                }

                list.add(t);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean cancelServiceRequest(int ticketId) {
        // Cập nhật trạng thái thành CANCELLED và ghi nhận thời gian cập nhật
        String sql = "UPDATE ticket SET status = 'CANCELLED', updated_at = CURRENT_TIMESTAMP WHERE ticket_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, ticketId);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

   
    public Ticket getTicketWithDetailss(int ticketId) {
        Ticket t = null;
        // Nối bảng ticket với bảng service và bảng user để lấy tên hiển thị
        String sql = "SELECT t.*, s.service_name, u.full_name as reported_by_name "
                + "FROM ticket t "
                + "LEFT JOIN service s ON t.service_id = s.service_id "
                + "LEFT JOIN user u ON t.reported_by = u.user_id "
                + "WHERE t.ticket_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, ticketId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                t = new Ticket();
                t.setTicketId(rs.getInt("ticket_id"));
                t.setTicketNumber(rs.getString("ticket_number"));
                t.setTitle(rs.getString("title"));
                t.setTicketType(rs.getString("ticket_type"));
                t.setDescription(rs.getString("description"));
                t.setJustification(rs.getString("justification"));
                t.setStatus(rs.getString("status"));
                t.setPriority(rs.getString("priority"));
                t.setCreatedAt(rs.getTimestamp("created_at"));
                t.setReportedBy(rs.getInt("reported_by"));
                t.setAssignedTo((Integer) rs.getObject("assigned_to"));
                t.setSolution(rs.getString("solution"));
                t.setReportedByName(rs.getString("reported_by_name"));
                
                if (rs.getString("service_name") != null) {
                    t.setTitle(t.getTitle() + " (" + rs.getString("service_name") + ")");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return t;
    }

    public boolean updateServiceRequestProgress(int ticketId, String status, String solution, Integer assignedTo) {
        // Cập nhật trạng thái, giải pháp, người xử lý và thời gian cập nhật
        String sql = "UPDATE ticket SET status = ?, solution = ?, assigned_to = ?, updated_at = CURRENT_TIMESTAMP WHERE ticket_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setString(2, solution);

            if (assignedTo != null && assignedTo > 0) {
                ps.setInt(3, assignedTo);
            } else {
                ps.setNull(3, java.sql.Types.INTEGER); // Cho phép null nếu chưa ai nhận
            }

            ps.setInt(4, ticketId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Xóa một Request (Dành cho màn hình Detail)
    public boolean deleteNewServiceRequest(int ticketId, int currentUserId) {
        // Chỉ xóa nếu ticket là của user đó tạo, status='NEW' và chưa ai nhận việc
        String sql = "DELETE FROM ticket WHERE ticket_id = ? AND reported_by = ? AND status = 'NEW' AND assigned_to IS NULL";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ps.setInt(2, currentUserId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 2. Xóa hàng loạt (Dành cho màn hình List)
    public int bulkDeleteNewServiceRequests(String[] ticketIds, int currentUserId) {
        int count = 0;
        String sql = "DELETE FROM ticket WHERE ticket_id = ? AND reported_by = ? AND status = 'NEW' AND assigned_to IS NULL";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            for (String idStr : ticketIds) {
                ps.setInt(1, Integer.parseInt(idStr));
                ps.setInt(2, currentUserId);
                ps.addBatch(); // Thêm vào danh sách chờ thực thi
            }

            int[] results = ps.executeBatch(); // Chạy 1 lần cho tất cả
            for (int res : results) {
                if (res > 0) {
                    count++;
                }
            }
        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
        }
        return count; // Trả về số lượng ticket đã xóa thành công
    }

    public boolean assignServiceRequest(int ticketId, int assignedToUserId) {
        // Gán người xử lý, đổi trạng thái sang IN_PROGRESS và cập nhật thời gian
        String sql = "UPDATE ticket SET assigned_to = ?, status = 'APPROVED', updated_at = CURRENT_TIMESTAMP "
                + "WHERE ticket_id = ? AND ticket_type = 'SERVICE_REQUEST'";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, assignedToUserId);
            ps.setInt(2, ticketId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 3. Cập nhật trạng thái hàng loạt (Bulk Approve/Reject)
    public int bulkUpdateTicketStatus(String[] ticketIds, String newStatus) {
        int count = 0;
        String sql = "UPDATE ticket SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE ticket_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            for (String idStr : ticketIds) {
                ps.setString(1, newStatus);
                ps.setInt(2, Integer.parseInt(idStr));
                ps.addBatch(); // Thêm vào danh sách chờ thực thi
            }

            int[] results = ps.executeBatch(); // Chạy 1 lần cho tất cả
            for (int res : results) {
                if (res > 0) {
                    count++;
                }
            }
        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
        }
        return count; // Trả về số lượng ticket đã cập nhật thành công
    }

    // ================== UC63: QUẢN LÝ BÌNH LUẬN (COMMENT) ==================
    public boolean addComment(int ticketId, int userId, String commentText) {
        String sql = "INSERT INTO comment (ticket_id, user_id, comment_text, created_at) VALUES (?, ?, ?, CURRENT_TIMESTAMP)";
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

    public List<com.itserviceflow.models.Comment> getCommentsByTicketId(int ticketId) {
        List<com.itserviceflow.models.Comment> list = new ArrayList<>();
        // Nối bảng để lấy full_name và role_id của người bình luận
        String sql = "SELECT c.*, u.full_name, u.role_id FROM comment c "
                + "JOIN user u ON c.user_id = u.user_id "
                + "WHERE c.ticket_id = ? ORDER BY c.created_at ASC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                com.itserviceflow.models.Comment c = new com.itserviceflow.models.Comment();
                c.setCommentId(rs.getInt("comment_id"));
                c.setTicketId(rs.getInt("ticket_id"));
                c.setUserId(rs.getInt("user_id"));
                c.setCommentText(rs.getString("comment_text"));
                c.setCreatedAt(rs.getTimestamp("created_at"));

                // Set tên và role bằng 2 biến trong model Comment của bạn
                c.setUserName(rs.getString("full_name"));
                c.setUserRoleId(rs.getInt("role_id"));

                list.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ================== UC64: CHANGE MANAGEMENT ==================
    public List<Ticket> getChangeRequestList(String search, String statusFilter) {
        List<Ticket> list = new ArrayList<>();
        // Lấy các ticket có type là CHANGE
        StringBuilder sql = new StringBuilder("SELECT * FROM ticket WHERE ticket_type = 'CHANGE' ");

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (title LIKE ? OR ticket_number LIKE ?) ");
        }
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append(" AND status = ? ");
        }
        sql.append(" ORDER BY created_at DESC");

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                String searchStr = "%" + search + "%";
                ps.setString(paramIndex++, searchStr);
                ps.setString(paramIndex++, searchStr);
            }
            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                ps.setString(paramIndex++, statusFilter);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Ticket t = new Ticket();
                t.setTicketId(rs.getInt("ticket_id"));
                t.setTicketNumber(rs.getString("ticket_number"));
                t.setTitle(rs.getString("title"));
                t.setStatus(rs.getString("status"));
                t.setPriority(rs.getString("priority"));
                t.setCreatedAt(rs.getTimestamp("created_at"));
                t.setScheduledStart(rs.getTimestamp("scheduled_start"));
                t.setScheduledEnd(rs.getTimestamp("scheduled_end"));
                
                list.add(t);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Ticket getChangeRequestDetail(int ticketId) {
        Ticket t = null;
        String sql = "SELECT t.*, u.full_name AS reported_by_name, a.full_name AS assigned_to_name "
                + "FROM ticket t "
                + "LEFT JOIN user u ON t.reported_by = u.user_id "
                + "LEFT JOIN user a ON t.assigned_to = a.user_id "
                + "WHERE t.ticket_id = ? AND t.ticket_type = 'CHANGE'";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, ticketId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                t = new Ticket();
                t.setTicketId(rs.getInt("ticket_id"));
                t.setTicketNumber(rs.getString("ticket_number"));
                t.setTitle(rs.getString("title"));
                t.setDescription(rs.getString("description"));
                t.setStatus(rs.getString("status"));
                t.setPriority(rs.getString("priority"));
                t.setCreatedAt(rs.getTimestamp("created_at"));
                t.setReportedBy(rs.getInt("reported_by"));
                t.setReportedByName(rs.getString("reported_by_name"));
                t.setAssignedToName(rs.getString("assigned_to_name"));

                // Gắn dữ liệu đặc thù của Change Request
                t.setChangeType(rs.getString("change_type"));
                t.setRiskLevel(rs.getString("risk_level"));
                t.setImpactAssessment(rs.getString("impact_assessment"));
                t.setRollbackPlan(rs.getString("rollback_plan"));
                t.setImplementationPlan(rs.getString("implementation_plan"));
                t.setTestPlan(rs.getString("test_plan"));
                t.setCabDecision(rs.getString("cab_decision"));
                t.setCabComment(rs.getString("cab_comment"));
                t.setCabRiskAssessment(rs.getString("cab_risk_assessment")); 
                
                t.setCabComment(rs.getString("cab_comment"));
                t.setScheduledStart(rs.getTimestamp("scheduled_start"));
                t.setScheduledStart(rs.getTimestamp("scheduled_start"));
                t.setScheduledEnd(rs.getTimestamp("scheduled_end"));
                t.setDowntimeRequired(rs.getBoolean("downtime_required"));
                t.setEstimatedDowntimeHour(rs.getDouble("estimated_downtime_hour"));
                
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return t;
    }

    public boolean createChangeRequest(Ticket cr) {
        String sql = "INSERT INTO ticket (ticket_number, ticket_type, title, description, status, priority, "
                + "reported_by, department_id, change_type, risk_level, impact_assessment, "
                + "implementation_plan, rollback_plan, test_plan, scheduled_start, scheduled_end, "
                + "downtime_required, estimated_downtime_hour, created_at) "
                + "VALUES (?, 'CHANGE', ?, ?, 'NEW', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            // Tự động sinh mã Ticket: CR-17...
            String ticketNum = "CR-" + System.currentTimeMillis() / 1000;

            ps.setString(1, ticketNum);
            ps.setString(2, cr.getTitle());
            ps.setString(3, cr.getDescription());
            ps.setString(4, cr.getPriority());
            ps.setInt(5, cr.getReportedBy());

            if (cr.getDepartmentId() != null) {
                ps.setInt(6, cr.getDepartmentId());
            } else {
                ps.setNull(6, java.sql.Types.INTEGER);
            }

            ps.setString(7, cr.getChangeType());
            ps.setString(8, cr.getRiskLevel());
            ps.setString(9, cr.getImpactAssessment());
            ps.setString(10, cr.getImplementationPlan());
            ps.setString(11, cr.getRollbackPlan());
            ps.setString(12, cr.getTestPlan());

            if (cr.getScheduledStart() != null) {
                ps.setTimestamp(13, new java.sql.Timestamp(cr.getScheduledStart().getTime()));
            } else {
                ps.setNull(13, java.sql.Types.TIMESTAMP);
            }

            if (cr.getScheduledEnd() != null) {
                ps.setTimestamp(14, new java.sql.Timestamp(cr.getScheduledEnd().getTime()));
            } else {
                ps.setNull(14, java.sql.Types.TIMESTAMP);
            }

            ps.setBoolean(15, cr.isDowntimeRequired());

            if (cr.getEstimatedDowntimeHour() != null) {
                ps.setDouble(16, cr.getEstimatedDowntimeHour());
            } else {
                ps.setNull(16, java.sql.Types.DOUBLE);
            }

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateChangeRequest(Ticket cr) {
        String sql = "UPDATE ticket SET title=?, description=?, priority=?, change_type=?, "
                + "risk_level=?, impact_assessment=?, implementation_plan=?, rollback_plan=?, "
                + "test_plan=?, scheduled_start=?, scheduled_end=?, downtime_required=?, "
                + "estimated_downtime_hour=?, updated_at=CURRENT_TIMESTAMP "
                + "WHERE ticket_id=? AND reported_by=?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, cr.getTitle());
            ps.setString(2, cr.getDescription());
            ps.setString(3, cr.getPriority());
            ps.setString(4, cr.getChangeType());
            ps.setString(5, cr.getRiskLevel());
            ps.setString(6, cr.getImpactAssessment());
            ps.setString(7, cr.getImplementationPlan());
            ps.setString(8, cr.getRollbackPlan());
            ps.setString(9, cr.getTestPlan());

            if (cr.getScheduledStart() != null) {
                ps.setTimestamp(10, new java.sql.Timestamp(cr.getScheduledStart().getTime()));
            } else {
                ps.setNull(10, java.sql.Types.TIMESTAMP);
            }

            if (cr.getScheduledEnd() != null) {
                ps.setTimestamp(11, new java.sql.Timestamp(cr.getScheduledEnd().getTime()));
            } else {
                ps.setNull(11, java.sql.Types.TIMESTAMP);
            }

            ps.setBoolean(12, cr.isDowntimeRequired());

            if (cr.getEstimatedDowntimeHour() != null) {
                ps.setDouble(13, cr.getEstimatedDowntimeHour());
            } else {
                ps.setNull(13, java.sql.Types.DOUBLE);
            }

            ps.setInt(14, cr.getTicketId());
            ps.setInt(15, cr.getReportedBy()); // Ràng buộc bảo mật: Chỉ người tạo mới được update

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Xóa 1 Change Request
    public boolean deleteChangeRequest(int ticketId) {
        String sql = "DELETE FROM ticket WHERE ticket_id = ? AND ticket_type = 'CHANGE' "
                   + "AND status = 'NEW' AND (cab_risk_assessment IS NULL OR cab_risk_assessment = '')";
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Xóa hàng loạt Change Request (Bulk Delete)
    public int bulkDeleteChangeRequests(String[] ticketIds) {
        int count = 0;
        String sql = "DELETE FROM ticket WHERE ticket_id = ? AND ticket_type = 'CHANGE' "
                   + "AND status = 'NEW' AND (cab_risk_assessment IS NULL OR cab_risk_assessment = '')";
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (String idStr : ticketIds) {
                ps.setInt(1, Integer.parseInt(idStr));
                ps.addBatch();
            }
            int[] results = ps.executeBatch();
            for (int res : results) {
                if (res > 0) count++;
            }
        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
        }
        return count; // Trả về số lượng đã xóa thành công
    }
    
    public boolean cancelChangeRequest(int ticketId) {
        String sql = "UPDATE ticket SET status = 'CANCELLED', updated_at = CURRENT_TIMESTAMP "
                   + "WHERE ticket_id = ? AND ticket_type = 'CHANGE'";
        
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, ticketId);
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Lấy danh sách System Engineer (Role ID = 6) để Manager phân công
    public List<User> getSystemEngineers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT user_id, full_name FROM user WHERE role_id = 6 AND is_active = 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                u.setFullName(rs.getString("full_name"));
                list.add(u);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // UC70: Manager Assign Change Request cho System Engineer
    public boolean assignChangeRequest(int ticketId, int assignedToUserId) {
        String sql = "UPDATE ticket SET assigned_to = ?,status = 'IN_PROGRESS',updated_at = CURRENT_TIMESTAMP "
                   + "WHERE ticket_id = ? AND ticket_type = 'CHANGE'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, assignedToUserId);
            ps.setInt(2, ticketId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // UC71: CAB Member đánh giá rủi ro và khuyến nghị lịch trình
    public boolean assessChangeRisk(int ticketId, int cabMemberId, String riskAssessment, String comment) {
        String sql = "UPDATE ticket SET cab_risk_assessment = ?, cab_comment = ?, cab_member_id = ?, updated_at = CURRENT_TIMESTAMP "
                   + "WHERE ticket_id = ? AND ticket_type = 'CHANGE'";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, riskAssessment);
            ps.setString(2, comment);
            ps.setInt(3, cabMemberId);
            ps.setInt(4, ticketId);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // UC72: CAB Duyệt / Từ chối 1 Change Request
    public boolean reviewChangeRequest(int ticketId, int cabMemberId, String decision) {
        String status = "APPROVED".equals(decision) ? "APPROVED" : "REJECTED";
        String sql = "UPDATE ticket SET cab_decision = ?, status = ?, cab_member_id = ?, cab_decided_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP "
                   + "WHERE ticket_id = ? AND ticket_type = 'CHANGE'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, decision);
            ps.setString(2, status);
            ps.setInt(3, cabMemberId);
            ps.setInt(4, ticketId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // UC72: CAB Duyệt / Từ chối Hàng loạt (Bulk)
    public int bulkReviewChangeRequests(String[] ticketIds, int cabMemberId, String decision) {
        int count = 0;
        String status = "APPROVED".equals(decision) ? "APPROVED" : "REJECTED";
        // Chỉ duyệt những vé đang ở trạng thái PENDING hoặc NEW/IN_PROGRESS (Chưa duyệt)
        String sql = "UPDATE ticket SET cab_decision = ?, status = ?, cab_member_id = ?, cab_decided_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP "
                   + "WHERE ticket_id = ? AND ticket_type = 'CHANGE' AND (cab_decision IS NULL OR cab_decision = 'PENDING')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (String idStr : ticketIds) {
                ps.setString(1, decision);
                ps.setString(2, status);
                ps.setInt(3, cabMemberId);
                ps.setInt(4, Integer.parseInt(idStr));
                ps.addBatch();
            }
            int[] results = ps.executeBatch();
            for (int res : results) {
                if (res > 0) count++;
            }
        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
        }
        return count;
    }
    
    
    
    
    public Ticket getTicketById(int ticketId) {
        String sql = "SELECT * FROM ticket WHERE ticket_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, ticketId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRowToTicket(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Ticket> getIncidentList(int userId, String roleName) {
        List<Ticket> list = new ArrayList<>();

        String sql;
        boolean isEndUser = "End-user".equalsIgnoreCase(roleName);

        if (isEndUser) {
            sql = "SELECT * FROM ticket "
                    + "WHERE ticket_type = 'INCIDENT' "
                    + "AND reported_by = ? "
                    + "ORDER BY ticket_id DESC";
        } else {
            sql = "SELECT * FROM ticket "
                    + "WHERE ticket_type = 'INCIDENT' "
                    + "ORDER BY ticket_id DESC";
        }

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            if (isEndUser) {
                ps.setInt(1, userId);
            }

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Ticket t = new Ticket();
                t.setTicketId(rs.getInt("ticket_id"));
                t.setTicketNumber(rs.getString("ticket_number"));
                t.setTitle(rs.getString("title"));
                t.setStatus(rs.getString("status"));
                t.setPriority(rs.getString("priority"));
                t.setReportedBy(rs.getInt("reported_by"));
                t.setCreatedAt(rs.getTimestamp("created_at"));

                list.add(t);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // ---------- incident-specific operations ----------
    public Ticket getIncidentById(int ticketId) {
        String sql = "SELECT * FROM ticket WHERE ticket_id = ? AND ticket_type = 'INCIDENT'";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, ticketId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRowToTicket(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Ticket> getRelatedIncidents(int incidentId) {
        List<Ticket> list = new ArrayList<>();
        String sql = "SELECT t.* FROM ticket t "
                + "JOIN ticket_relation tr ON t.ticket_id = tr.target_ticket_id "
                + "WHERE tr.source_ticket_id = ? AND tr.relation_type = 'RELATED' "
                + "AND t.ticket_type = 'INCIDENT'";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, incidentId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToTicket(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean createIncidentTicket(Ticket incident, int createdBy) {
        String sql = "INSERT INTO ticket (ticket_number, ticket_type, title, description, status, priority, category_id, reported_by) "
                + "VALUES (?, 'INCIDENT', ?, ?, 'NEW', ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, "INC-" + System.currentTimeMillis());
            stmt.setString(2, incident.getTitle());
            stmt.setString(3, incident.getDescription());
            stmt.setString(4, incident.getPriority());
            stmt.setInt(5, incident.getCategoryId());
            stmt.setInt(6, incident.getReportedBy());
            stmt.executeUpdate();

            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    incident.setTicketId(rs.getInt(1));
                }
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateIncidentTicket(Ticket incident) {
        String sql = "UPDATE ticket SET title = ?, description = ?, status = ?, priority = ?, category_id = ? "
                + "WHERE ticket_id = ? AND ticket_type = 'INCIDENT'";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, incident.getTitle());
            stmt.setString(2, incident.getDescription());
            stmt.setString(3, incident.getStatus());
            stmt.setString(4, incident.getPriority());
            stmt.setInt(5, incident.getCategoryId());
            stmt.setInt(6, incident.getTicketId());
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteIncidentTicket(int ticketId) {
        String checkSql = "SELECT status, assigned_to FROM ticket WHERE ticket_id = ? AND ticket_type = 'INCIDENT'";
        String deleteSql = "DELETE FROM ticket WHERE ticket_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
            checkStmt.setInt(1, ticketId);
            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next()) {
                    String status = rs.getString("status");
                    Integer assignedTo = (Integer) rs.getObject("assigned_to");
                    if ("NEW".equals(status) && assignedTo == null) {
                        try (PreparedStatement delStmt = conn.prepareStatement(deleteSql)) {
                            delStmt.setInt(1, ticketId);
                            return delStmt.executeUpdate() > 0;
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean cancelIncidentTicket(int ticketId) {
        String sql = "UPDATE ticket SET status = 'CANCELLED', cancelled_at = CURRENT_TIMESTAMP "
                + "WHERE ticket_id = ? AND ticket_type = 'INCIDENT'";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, ticketId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean requestCancelIncidentTicket(int ticketId, int requesterUserId) {
        // Use existing DB-allowed status 'PENDING' to represent "cancel requested"
        String sql = "UPDATE ticket SET status = 'PENDING', updated_at = CURRENT_TIMESTAMP "
                + "WHERE ticket_id = ? AND ticket_type = 'INCIDENT' "
                + "AND reported_by = ? "
                + "AND status NOT IN ('CANCELLED', 'CLOSED')";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, ticketId);
            stmt.setInt(2, requesterUserId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean approveCancelIncidentTicket(int ticketId) {
        // Only approve when it is explicitly requested
        String sql = "UPDATE ticket SET status = 'CANCELLED', cancelled_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP "
                + "WHERE ticket_id = ? AND ticket_type = 'INCIDENT' AND status = 'PENDING'";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, ticketId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean rejectCancelIncidentTicket(int ticketId) {
        // Restore a sensible status based on whether it is assigned
        String sql = "UPDATE ticket SET status = (CASE WHEN assigned_to IS NULL THEN 'NEW' ELSE 'IN_PROGRESS' END), "
                + "updated_at = CURRENT_TIMESTAMP "
                + "WHERE ticket_id = ? AND ticket_type = 'INCIDENT' AND status = 'PENDING'";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, ticketId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean assignIncidentTicket(int ticketId, int assignedToUserId) {
        String sql = "UPDATE ticket SET assigned_to = ?, status = 'IN_PROGRESS' "
                + "WHERE ticket_id = ? AND ticket_type = 'INCIDENT'";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, assignedToUserId);
            stmt.setInt(2, ticketId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean categorizeIncidentTicket(int ticketId, int categoryId) {
        String sql = "UPDATE ticket SET category_id = ? WHERE ticket_id = ? AND ticket_type = 'INCIDENT'";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, categoryId);
            stmt.setInt(2, ticketId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean linkRelatedIncidents(int sourceId, List<Integer> relatedIds, int createdBy) {
        if (relatedIds == null || relatedIds.isEmpty()) {
            return true;
        }
        String sql = "INSERT INTO ticket_relation (source_ticket_id, target_ticket_id, relation_type, created_by) "
                + "VALUES (?, ?, 'RELATED', ?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            for (int rid : relatedIds) {
                stmt.setInt(1, sourceId);
                stmt.setInt(2, rid);
                stmt.setInt(3, createdBy);
                stmt.addBatch();
            }
            stmt.executeBatch();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private Ticket mapRowToTicket(ResultSet rs) throws SQLException {
        Ticket t = new Ticket();
        t.setTicketId(rs.getInt("ticket_id"));
        t.setTicketNumber(rs.getString("ticket_number"));
        t.setTicketType(rs.getString("ticket_type"));
        t.setTitle(rs.getString("title"));
        t.setDescription(rs.getString("description"));
        t.setStatus(rs.getString("status"));
        t.setPriority(rs.getString("priority"));
        t.setDifficultyLevel(rs.getString("difficulty_level"));
        t.setCategoryId(rs.getInt("category_id"));
        t.setReportedBy(rs.getInt("reported_by"));
        t.setAssignedTo((Integer) rs.getObject("assigned_to"));
        t.setDepartmentId((Integer) rs.getObject("department_id"));
        t.setCause(rs.getString("cause"));
        t.setSolution(rs.getString("solution"));
        t.setCreatedAt(rs.getTimestamp("created_at"));
        t.setUpdatedAt(rs.getTimestamp("updated_at"));
        return t;
    }

    public List<Ticket> suggestSimilarIncidents(String query, Integer categoryId, int limit, Integer excludeTicketId) {
        List<Ticket> list = new ArrayList<>();
        if (query == null) {
            return list;
        }
        String normalized = query.trim().replaceAll("\\s+", " ");
        if (normalized.isEmpty()) {
            return list;
        }

        // Flexible LIKE pattern: "wifi mất kết nối" -> "%wifi%mất%kết%nối%"
        String like = "%" + normalized.replace(" ", "%") + "%";

        StringBuilder sql = new StringBuilder(
                "SELECT ticket_id, ticket_number, title, status, created_at "
                + "FROM ticket "
                + "WHERE ticket_type = 'INCIDENT' "
                + "AND status NOT IN ('CANCELLED', 'CLOSED') "
                + "AND (title LIKE ? OR description LIKE ?) "
        );
        if (categoryId != null && categoryId > 0) {
            sql.append(" AND category_id = ? ");
        }
        if (excludeTicketId != null && excludeTicketId > 0) {
            sql.append(" AND ticket_id <> ? ");
        }
        sql.append(" ORDER BY created_at DESC LIMIT ?");

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setString(idx++, like);
            ps.setString(idx++, like);
            if (categoryId != null && categoryId > 0) {
                ps.setInt(idx++, categoryId);
            }
            if (excludeTicketId != null && excludeTicketId > 0) {
                ps.setInt(idx++, excludeTicketId);
            }
            ps.setInt(idx, Math.max(1, Math.min(limit, 20)));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Ticket t = new Ticket();
                    t.setTicketId(rs.getInt("ticket_id"));
                    t.setTicketNumber(rs.getString("ticket_number"));
                    t.setTitle(rs.getString("title"));
                    t.setStatus(rs.getString("status"));
                    t.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(t);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Fetches a ticket and joins ticket_category to get difficulty_level. Use
     * this when you need difficulty for logtime calculation.
     */
    public Ticket getTicketWithDetails(int ticketId) {
        // Join ticket_category for difficulty and user table twice to fetch reporter/assignee names
        String sql = "SELECT t.*, tc.difficulty_level, "
                + "ru.full_name AS reported_by_name, au.full_name AS assigned_to_name "
                + "FROM ticket t "
                + "LEFT JOIN ticket_category tc ON t.category_id = tc.category_id "
                + "LEFT JOIN `user` ru ON t.reported_by = ru.user_id "
                + "LEFT JOIN `user` au ON t.assigned_to = au.user_id "
                + "WHERE t.ticket_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, ticketId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Ticket t = mapRowToTicket(rs);
                    // Set virtual/display fields
                    t.setDifficultyLevel(rs.getString("difficulty_level"));
                    t.setReportedByName(rs.getString("reported_by_name"));
                    t.setAssignedToName(rs.getString("assigned_to_name"));
                    return t;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ---------- workflow-driven operations ----------
    /**
     * Lấy các ticket đang mở (chưa đóng/huỷ/hoàn tất) để kiểm tra SLA
     */
    public List<Ticket> getOpenTicketsForSLA() {
        List<Ticket> list = new ArrayList<>();
        String sql = "SELECT * FROM ticket WHERE status NOT IN ('CLOSED', 'RESOLVED', 'CANCELLED', 'Closed', 'Resolved', 'Cancelled')";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRowToTicket(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Cập nhật status của ticket bất kỳ (dùng bởi WorkflowService).
     */
    public boolean updateTicketStatus(int ticketId, String newStatus) {
        String sql = "UPDATE ticket SET status = ? WHERE ticket_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, newStatus);
            stmt.setInt(2, ticketId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Cập nhật priority của ticket bất kỳ (dùng bởi WorkflowService).
     */
    public boolean updateTicketPriority(int ticketId, String newPriority) {
        String sql = "UPDATE ticket SET priority = ? WHERE ticket_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, newPriority);
            stmt.setInt(2, ticketId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ---------- incident-specific operations ----------
}
