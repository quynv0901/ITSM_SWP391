package com.itserviceflow.daos;

import com.itserviceflow.models.Feedback;
import com.itserviceflow.utils.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class FeedbackDAO {
    
    public boolean saveFeedback(Feedback feedback) {
        String sql = "INSERT INTO feedback (ticket_id, user_id, agent_id, rating, feedback_text, submitted_at, updated_at) "
                   + "VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, feedback.getTicketId());
            ps.setInt(2, feedback.getUserId());
            ps.setInt(3, feedback.getAgentId());
            ps.setInt(4, feedback.getRating());
            
            // Xử lý feedback_text an toàn
            String feedbackText = feedback.getFeedbackText();
            if (feedbackText == null) {
                feedbackText = "";
            }
            // Cắt ngắn nếu quá dài (giới hạn 250 ký tự để an toàn)
            if (feedbackText.length() > 250) {
                feedbackText = feedbackText.substring(0, 250);
            }
            // Encode lại để tránh lỗi charset
            feedbackText = feedbackText.replace("\n", " ").replace("\r", " ").trim();
            ps.setString(5, feedbackText);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public Feedback getFeedbackByTicketId(int ticketId) {
        String sql = "SELECT * FROM feedback WHERE ticket_id = ?";
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, ticketId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Feedback feedback = new Feedback();
                    feedback.setFeedbackId(rs.getInt("feedback_id"));
                    feedback.setTicketId(rs.getInt("ticket_id"));
                    feedback.setUserId(rs.getInt("user_id"));
                    feedback.setAgentId(rs.getInt("agent_id"));
                    feedback.setRating(rs.getInt("rating"));
                    feedback.setFeedbackText(rs.getString("feedback_text"));
                    feedback.setSubmittedAt(rs.getTimestamp("submitted_at"));
                    feedback.setUpdatedAt(rs.getTimestamp("updated_at"));
                    return feedback;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    public boolean hasFeedback(int ticketId) {
        String sql = "SELECT COUNT(*) FROM feedback WHERE ticket_id = ?";
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, ticketId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public int getTotalFeedbackCount() {
        String sql = "SELECT COUNT(*) FROM feedback";
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    public int getSatisfiedFeedbackCount() {
        String sql = "SELECT COUNT(*) FROM feedback WHERE rating = 1";
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    public java.util.Map<String, Integer> getFeedbackCountByAgent() {
        java.util.Map<String, Integer> result = new java.util.HashMap<>();
        String sql = "SELECT u.username, COUNT(*) as count FROM feedback f " +
                    "JOIN users u ON f.agent_id = u.user_id " +
                    "GROUP BY f.agent_id, u.username " +
                    "ORDER BY count DESC";
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    result.put(rs.getString("username"), rs.getInt("count"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }
    
    public java.util.Map<String, Integer> getFeedbackCountByTime() {
        java.util.Map<String, Integer> result = new java.util.HashMap<>();
        String sql = "SELECT DATE(submitted_at) as date, COUNT(*) as count FROM feedback " +
                    "WHERE submitted_at >= DATE_SUB(NOW(), INTERVAL 7 DAY) " +
                    "GROUP BY DATE(submitted_at) " +
                    "ORDER BY date DESC";
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    result.put(rs.getString("date"), rs.getInt("count"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }
}