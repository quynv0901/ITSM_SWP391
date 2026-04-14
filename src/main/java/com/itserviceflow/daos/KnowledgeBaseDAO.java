package com.itserviceflow.daos;

import com.itserviceflow.models.Article;
import com.itserviceflow.utils.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class KnowledgeBaseDAO {

    private Connection conn;

    public KnowledgeBaseDAO() {
        try {
            conn = DBConnection.getConnection();
        } catch (Exception e) {
            System.err.println("KnowledgeBaseDAO error: " + e.getMessage());
        }
    }

    private Article mapArticle(ResultSet rs) throws Exception {
        Article a = new Article();
        a.setArticleId(rs.getInt("article_id"));
        a.setArticleNumber(rs.getString("article_number"));
        a.setArticleType(rs.getString("article_type"));
        a.setTitle(rs.getString("title"));
        a.setContent(rs.getString("content"));
        a.setSummary(rs.getString("summary"));
        a.setTag(rs.getString("tag"));
        a.setStatus(rs.getString("status"));
        a.setAuthorId((Integer) rs.getObject("author_id"));
        a.setApprovedBy((Integer) rs.getObject("approved_by"));
        a.setRejectionReason(rs.getString("rejection_reason"));
        a.setErrorCode(rs.getString("error_code"));
        a.setSymptom(rs.getString("symptom"));
        a.setCause(rs.getString("cause"));
        a.setSolution(rs.getString("solution"));

        Timestamp approvedAt = rs.getTimestamp("approved_at");
        if (approvedAt != null) {
            a.setApprovedAt(approvedAt.toLocalDateTime());
        }

        Timestamp publishedAt = rs.getTimestamp("published_at");
        if (publishedAt != null) {
            a.setPublishedAt(publishedAt.toLocalDateTime());
        }

        a.setUpdatedAt(rs.getTimestamp("updated_at"));

        return a;
    }

    public List<Article> listArticles(String keyword, String status, String type, int offset, int limit) {
        List<Article> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM article WHERE article_type = 'KNOWLEDGE_BASE'");

        if (keyword != null && !keyword.isEmpty()) {
            sql.append(" AND (title LIKE ? OR article_number LIKE ?)");
        }
        if (status != null && !status.isEmpty() && !"ALL".equals(status)) {
            sql.append(" AND status = ?");
        }
        if (type != null && !type.isEmpty() && !"ALL".equals(type)) {
            sql.append(" AND article_type = ?");
        }

        sql.append(" ORDER BY updated_at DESC LIMIT ? OFFSET ?");

        try (PreparedStatement st = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null && !keyword.isEmpty()) {
                String kw = "%" + keyword + "%";
                st.setString(idx++, kw);
                st.setString(idx++, kw);
            }
            if (status != null && !status.isEmpty() && !"ALL".equals(status)) {
                st.setString(idx++, status);
            }
            if (type != null && !type.isEmpty() && !"ALL".equals(type)) {
                st.setString(idx++, type);
            }
            st.setInt(idx++, limit);
            st.setInt(idx, offset);

            ResultSet rs = st.executeQuery();
            while (rs.next()) {
                list.add(mapArticle(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countArticles(String keyword, String status, String type) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM article WHERE article_type = 'KNOWLEDGE_BASE'");

        if (keyword != null && !keyword.isEmpty()) {
            sql.append(" AND (title LIKE ? OR article_number LIKE ?)");
        }
        if (status != null && !status.isEmpty() && !"ALL".equals(status)) {
            sql.append(" AND status = ?");
        }
        if (type != null && !type.isEmpty() && !"ALL".equals(type)) {
            sql.append(" AND article_type = ?");
        }

        try (PreparedStatement st = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null && !keyword.isEmpty()) {
                String kw = "%" + keyword + "%";
                st.setString(idx++, kw);
                st.setString(idx++, kw);
            }
            if (status != null && !status.isEmpty() && !"ALL".equals(status)) {
                st.setString(idx++, status);
            }
            if (type != null && !type.isEmpty() && !"ALL".equals(type)) {
                st.setString(idx++, type);
            }

            ResultSet rs = st.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

}
