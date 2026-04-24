package com.itserviceflow.daos;

import com.itserviceflow.dtos.MyAssignedTicketDTO;
import com.itserviceflow.utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MyAssignedTicketDAO {

    public List<MyAssignedTicketDTO> getAssignedTicketsByUser(int userId) {
        List<MyAssignedTicketDTO> list = new ArrayList<>();
        String sql = "SELECT ticket_id, ticket_number, ticket_type, title, status, priority, created_at, scheduled_start " +
                "FROM ticket WHERE assigned_to = ? ORDER BY updated_at DESC, created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                MyAssignedTicketDTO dto = new MyAssignedTicketDTO();
                dto.setTicketId(rs.getInt("ticket_id"));
                dto.setTicketNumber(rs.getString("ticket_number"));
                dto.setTicketType(rs.getString("ticket_type"));
                dto.setTitle(rs.getString("title"));
                dto.setStatus(rs.getString("status"));
                dto.setPriority(rs.getString("priority"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
                dto.setScheduledStart(rs.getTimestamp("scheduled_start"));
                list.add(dto);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
