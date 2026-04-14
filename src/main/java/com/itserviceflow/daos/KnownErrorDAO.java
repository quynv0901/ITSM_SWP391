package com.itserviceflow.daos;

import com.itserviceflow.models.Ticket;
import com.itserviceflow.utils.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class KnownErrorDAO {

    public List<Ticket> getBasicKnownErrors() {
        List<Ticket> errors = new ArrayList<>();
        String sql = "SELECT * FROM ticket WHERE ticket_type = 'KNOWN_ERROR' ORDER BY created_at DESC LIMIT 50";
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Ticket t = new Ticket();
                t.setTicketId(rs.getInt("ticket_id"));
                t.setTicketNumber(rs.getString("ticket_number"));
                t.setTitle(rs.getString("title"));
                t.setDescription(rs.getString("description"));
                t.setStatus(rs.getString("status"));
                t.setCause(rs.getString("cause"));
                t.setSolution(rs.getString("solution"));
                t.setCreatedAt(rs.getTimestamp("created_at"));
                errors.add(t);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return errors;
    }

    public Ticket getKnownErrorById(int ticketId) {
        String sql = "SELECT * FROM ticket WHERE ticket_id = ? AND ticket_type = 'KNOWN_ERROR'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, ticketId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Ticket t = new Ticket();
                    t.setTicketId(rs.getInt("ticket_id"));
                    t.setTicketNumber(rs.getString("ticket_number"));
                    t.setTitle(rs.getString("title"));
                    t.setDescription(rs.getString("description"));
                    t.setStatus(rs.getString("status"));
                    t.setCause(rs.getString("cause"));
                    t.setSolution(rs.getString("solution"));
                    t.setCreatedAt(rs.getTimestamp("created_at"));
                    t.setUpdatedAt(rs.getTimestamp("updated_at"));
                    t.setReportedBy(rs.getInt("reported_by"));
                    return t;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean createKnownError(Ticket ticket) {
        String sql = "INSERT INTO ticket (ticket_number, ticket_type, title, description, status, cause, solution, reported_by, priority, difficulty_level) " +
                     "VALUES (?, 'KNOWN_ERROR', ?, ?, ?, ?, ?, ?, 'MEDIUM', 'MEDIUM')";
        
        // Generate a random ticket number for Known Error
        String ticketNumber = "KE-" + System.currentTimeMillis() % 100000;
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, ticketNumber);
            stmt.setString(2, ticket.getTitle());
            stmt.setString(3, ticket.getDescription());
            stmt.setString(4, ticket.getStatus() != null ? ticket.getStatus() : "NEW");
            stmt.setString(5, ticket.getCause());
            stmt.setString(6, ticket.getSolution());
            stmt.setInt(7, ticket.getReportedBy());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateKnownError(Ticket ticket) {
        String sql = "UPDATE ticket SET title = ?, description = ?, status = ?, cause = ?, solution = ?, updated_at = CURRENT_TIMESTAMP WHERE ticket_id = ? AND ticket_type = 'KNOWN_ERROR'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, ticket.getTitle());
            stmt.setString(2, ticket.getDescription());
            stmt.setString(3, ticket.getStatus());
            stmt.setString(4, ticket.getCause());
            stmt.setString(5, ticket.getSolution());
            stmt.setInt(6, ticket.getTicketId());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteKnownError(int ticketId) {
        String sql = "DELETE FROM ticket WHERE ticket_id = ? AND ticket_type = 'KNOWN_ERROR'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, ticketId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
