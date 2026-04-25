package com.itserviceflow.daos;

import com.itserviceflow.models.Article;
import com.itserviceflow.utils.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class KnowledgeArticleDAO {

    private Connection conn;

    public KnowledgeArticleDAO() {
        try {
            conn = DBConnection.getConnection();
        } catch (Exception e) {
            System.err.println("KnowledgeArticleDAO error: " + e.getMessage());
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
        if (approvedAt != null) a.setApprovedAt(approvedAt.toLocalDateTime());

        Timestamp publishedAt = rs.getTimestamp("published_at");
        if (publishedAt != null) a.setPublishedAt(publishedAt.toLocalDateTime());

        a.setUpdatedAt(rs.getTimestamp("updated_at"));
        return a;
    }

    // ===================== LIST =====================

    /** Admin: xem tất cả bài viết */
    public List<Article> listArticles(String keyword, String status, String type, int offset, int limit) {
        List<Article> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM article WHERE article_type = 'KNOWLEDGE_ARTICLE'");

        if (keyword != null && !keyword.isEmpty())
            sql.append(" AND (title LIKE ? OR article_number LIKE ?)");
        if (status != null && !status.isEmpty() && !"ALL".equals(status))
            sql.append(" AND status = ?");
        if (type != null && !type.isEmpty() && !"ALL".equals(type))
            sql.append(" AND article_type = ?");
        sql.append(" ORDER BY updated_at DESC LIMIT ? OFFSET ?");

        try (PreparedStatement st = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null && !keyword.isEmpty()) {
                st.setString(idx++, "%" + keyword + "%");
                st.setString(idx++, "%" + keyword + "%");
            }
            if (status != null && !status.isEmpty() && !"ALL".equals(status)) st.setString(idx++, status);
            if (type != null && !type.isEmpty() && !"ALL".equals(type)) st.setString(idx++, type);
            st.setInt(idx++, limit);
            st.setInt(idx, offset);
            ResultSet rs = st.executeQuery();
            while (rs.next()) list.add(mapArticle(rs));
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /** Support Agent: chỉ xem bài của chính mình */
    public List<Article> listArticlesByAuthor(int authorId, String keyword, String status, int offset, int limit) {
        List<Article> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT * FROM article WHERE article_type = 'KNOWLEDGE_ARTICLE' AND author_id = ?");

        if (keyword != null && !keyword.isEmpty())
            sql.append(" AND (title LIKE ? OR article_number LIKE ?)");
        if (status != null && !status.isEmpty() && !"ALL".equals(status))
            sql.append(" AND status = ?");
        sql.append(" ORDER BY updated_at DESC LIMIT ? OFFSET ?");

        try (PreparedStatement st = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            st.setInt(idx++, authorId);
            if (keyword != null && !keyword.isEmpty()) {
                st.setString(idx++, "%" + keyword + "%");
                st.setString(idx++, "%" + keyword + "%");
            }
            if (status != null && !status.isEmpty() && !"ALL".equals(status)) st.setString(idx++, status);
            st.setInt(idx++, limit);
            st.setInt(idx, offset);
            ResultSet rs = st.executeQuery();
            while (rs.next()) list.add(mapArticle(rs));
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ===================== COUNT =====================

    public int countArticles(String keyword, String status, String type) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM article WHERE article_type = 'KNOWLEDGE_ARTICLE'");
        if (keyword != null && !keyword.isEmpty())
            sql.append(" AND (title LIKE ? OR article_number LIKE ?)");
        if (status != null && !status.isEmpty() && !"ALL".equals(status))
            sql.append(" AND status = ?");
        if (type != null && !type.isEmpty() && !"ALL".equals(type))
            sql.append(" AND article_type = ?");

        try (PreparedStatement st = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null && !keyword.isEmpty()) {
                st.setString(idx++, "%" + keyword + "%");
                st.setString(idx++, "%" + keyword + "%");
            }
            if (status != null && !status.isEmpty() && !"ALL".equals(status)) st.setString(idx++, status);
            if (type != null && !type.isEmpty() && !"ALL".equals(type)) st.setString(idx++, type);
            ResultSet rs = st.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    public int countArticlesByAuthor(int authorId, String keyword, String status) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM article WHERE article_type = 'KNOWLEDGE_ARTICLE' AND author_id = ?");
        if (keyword != null && !keyword.isEmpty())
            sql.append(" AND (title LIKE ? OR article_number LIKE ?)");
        if (status != null && !status.isEmpty() && !"ALL".equals(status))
            sql.append(" AND status = ?");

        try (PreparedStatement st = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            st.setInt(idx++, authorId);
            if (keyword != null && !keyword.isEmpty()) {
                st.setString(idx++, "%" + keyword + "%");
                st.setString(idx++, "%" + keyword + "%");
            }
            if (status != null && !status.isEmpty() && !"ALL".equals(status)) st.setString(idx++, status);
            ResultSet rs = st.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    public int countNewArticles() {
        String sql = "SELECT COUNT(*) FROM article "
                + "WHERE article_type = 'KNOWLEDGE_ARTICLE' AND status = 'APPROVED' "
                + "AND updated_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            ResultSet rs = st.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    // ===================== FIND =====================

    public Article findById(int id) {
        String sql = "SELECT * FROM article WHERE article_id = ?";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, id);
            ResultSet rs = st.executeQuery();
            if (rs.next()) return mapArticle(rs);
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public Article findByErrorCode(String errorCode) {
        String sql = "SELECT * FROM article WHERE article_number = ? AND article_type = 'KNOWN_ERROR'";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setString(1, errorCode);
            ResultSet rs = st.executeQuery();
            if (rs.next()) return mapArticle(rs);
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    // ===================== SUPPORT AGENT CRUD =====================

    /**
     * Thêm bài viết mới — status luôn PENDING
     */
    public boolean addArticle(Article a) {
    String sql = "INSERT INTO article (title, summary, content, article_type, tag, status, "
            + "author_id, error_code, symptom, cause, solution) "
            + "VALUES (?, ?, ?, 'KNOWLEDGE_ARTICLE', ?, 'PENDING', ?, ?, ?, ?, ?)";
    try (PreparedStatement st = conn.prepareStatement(sql)) {
        st.setString(1, a.getTitle());
        st.setString(2, a.getSummary());
        st.setString(3, a.getContent());
        // idx 4 = 'KNOWLEDGE_ARTICLE' hardcode, bỏ qua
        st.setString(4, a.getTag());
        // idx 6 = 'PENDING' hardcode, bỏ qua
        if (a.getAuthorId() != null) st.setInt(5, a.getAuthorId());
        else st.setNull(5, Types.INTEGER);
        st.setString(6, a.getErrorCode());
        st.setString(7, a.getSymptom());
        st.setString(8, a.getCause());
        st.setString(9, a.getSolution());
        return st.executeUpdate() > 0;
    } catch (Exception e) {
        e.printStackTrace();
    }
    return false;
}

    /**
     * Chỉnh sửa bài viết — chỉ được sửa nếu đúng author_id
     * Status tự động reset về PENDING, xóa approved_by / approved_at / rejection_reason
     */
    public boolean updateArticle(Article a) {
        String sql = "UPDATE article SET title=?, summary=?, content=?, error_code=?, "
                + "symptom=?, cause=?, solution=?, "
                + "status='PENDING', approved_by=NULL, approved_at=NULL, rejection_reason=NULL, "
                + "updated_at=NOW() "
                + "WHERE article_id=? AND author_id=?";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setString(1, a.getTitle());
            st.setString(2, a.getSummary());
            st.setString(3, a.getContent());
            st.setString(4, a.getErrorCode());
            st.setString(5, a.getSymptom());
            st.setString(6, a.getCause());
            st.setString(7, a.getSolution());
            st.setInt(8, a.getArticleId());
            st.setInt(9, a.getAuthorId()); // ← bảo vệ: chỉ sửa bài của chính mình
            return st.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    /**
     * Xóa bài viết — chỉ được xóa nếu đúng author_id (dùng cho support agent)
     */
    public boolean deleteArticleByAuthor(int id, int authorId) {
        String sql = "DELETE FROM article WHERE article_id = ? AND author_id = ?";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, id);
            st.setInt(2, authorId);
            return st.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    // ===================== ADMIN ACTIONS =====================

    /**
     * Admin duyệt → APPROVED
     */
    public boolean approveArticle(int id, int approvedById) {
        String sql = "UPDATE article SET status='APPROVED', "
                + "approved_by=?, approved_at=NOW(), rejection_reason=NULL, updated_at=NOW() "
                + "WHERE article_id=?";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, approvedById);
            st.setInt(2, id);
            return st.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    /**
     * Admin từ chối → REJECTED
     */
    public boolean rejectArticle(int id, int rejectedById, String reason) {
        String sql = "UPDATE article SET status='REJECTED', "
                + "rejection_reason=?, approved_by=?, updated_at=NOW() "
                + "WHERE article_id=?";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setString(1, reason);
            st.setInt(2, rejectedById);
            st.setInt(3, id);
            return st.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    /**
     * Admin vô hiệu hóa → ARCHIVED | Bật lại → APPROVED
     */
    public boolean toggleStatus(int id, String newStatus) {
        String sql = "UPDATE article SET status=?, updated_at=NOW() WHERE article_id=?";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setString(1, newStatus);
            st.setInt(2, id);
            return st.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    /**
     * Admin xóa bất kỳ bài viết nào
     */
    public boolean deleteArticle(int id) {
        String sql = "DELETE FROM article WHERE article_id = ?";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, id);
            return st.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    // ===================== KNOWN ERRORS =====================

    public List<Article> listKnownErrors() {
        List<Article> list = new ArrayList<>();
        String sql = "SELECT * FROM article WHERE article_type = 'KNOWN_ERROR' AND status = 'APPROVED'";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            ResultSet rs = st.executeQuery();
            while (rs.next()) list.add(mapArticle(rs));
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}
