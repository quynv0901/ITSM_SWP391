package com.itserviceflow.controllers;

import com.itserviceflow.daos.KnowledgeArticleDAO;
import com.itserviceflow.models.Article;
import com.itserviceflow.models.User;
import com.itserviceflow.utils.ProfanityFilter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "KnowledgeArticleController", urlPatterns = {"/support-agent/knowledge-article"})
public class KnowledgeArticleController extends HttpServlet {

    private KnowledgeArticleDAO kbDAO = new KnowledgeArticleDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        action = (action == null) ? "list" : action;
        switch (action) {
            case "list":   listArticles(req, resp); break;
            case "add":    addView(req, resp);      break;
            case "edit":   editView(req, resp);     break;
            case "detail": detailView(req, resp);   break;
            case "delete": deleteArticle(req, resp);break;
            default:
                resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        action = (action == null) ? "list" : action;
        switch (action) {
            case "add":  addArticle(req, resp);    break;
            case "edit": updateArticle(req, resp); break;
            default:
                resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article");
        }
    }

    // ===================== LIST =====================
    private void listArticles(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User currentUser = (User) req.getSession().getAttribute("user");
        String keyword = req.getParameter("keyword");
        String status  = req.getParameter("status");
        String pageStr = req.getParameter("page");

        int page   = (pageStr != null && !pageStr.isEmpty()) ? Integer.parseInt(pageStr) : 1;
        int limit  = 10;
        int offset = (page - 1) * limit;

        // Support agent chỉ thấy bài của chính mình
        List<Article> articles = kbDAO.listArticlesByAuthor(currentUser.getUserId(), keyword, status, offset, limit);
        int total      = kbDAO.countArticlesByAuthor(currentUser.getUserId(), keyword, status);
        int totalPages = (int) Math.ceil((double) total / limit);

        req.setAttribute("articles",     articles);
        req.setAttribute("currentPage",  page);
        req.setAttribute("totalPages",   totalPages);
        req.setAttribute("keyword",      keyword);
        req.setAttribute("statusFilter", status);
        req.getRequestDispatcher("/support-agent/knowledge-article.jsp").forward(req, resp);
    }

    // ===================== ADD VIEW =====================
    private void addView(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("article", new Article());
        req.setAttribute("knownErrors", kbDAO.listKnownErrors());
        req.getRequestDispatcher("/knowledge/knowledge-article-form.jsp").forward(req, resp);
    }

    // ===================== EDIT VIEW =====================
    private void editView(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User currentUser = (User) req.getSession().getAttribute("user");
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article");
            return;
        }
        Article article = kbDAO.findById(Integer.parseInt(idStr));
        if (article == null) {
            resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article?error="
                    + encode("Không tìm thấy bài viết"));
            return;
        }
        // Chỉ được sửa bài của chính mình
        if (!article.getAuthorId().equals(currentUser.getUserId())) {
            resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article?error="
                    + encode("Bạn không có quyền chỉnh sửa bài viết này"));
            return;
        }
        req.setAttribute("article", article);
        req.setAttribute("knownErrors", kbDAO.listKnownErrors());
        req.getRequestDispatcher("/knowledge/knowledge-article-form.jsp").forward(req, resp);
    }

    // ===================== DETAIL VIEW =====================
    private void detailView(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String errorCode = req.getParameter("errorCode");
        if (errorCode != null && !errorCode.isEmpty()) {
            Article article = kbDAO.findByErrorCode(errorCode);
            if (article == null) {
                resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article?error="
                        + encode("Không tìm thấy bài viết"));
                return;
            }
            req.setAttribute("article", article);
            req.getRequestDispatcher("/support-agent/knowledge-article-detail-agent.jsp").forward(req, resp);
            return;
        }
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article");
            return;
        }
        Article article = kbDAO.findById(Integer.parseInt(idStr));
        if (article == null) {
            resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article?error="
                    + encode("Không tìm thấy bài viết"));
            return;
        }
        req.setAttribute("article", article);
        req.getRequestDispatcher("/support-agent/knowledge-article-detail-agent.jsp").forward(req, resp);
    }

    // ===================== ADD ARTICLE =====================
    private void addArticle(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            User currentUser = (User) req.getSession().getAttribute("user");
            Article article  = buildArticleFromRequest(req);
            article.setAuthorId(currentUser.getUserId());
            // Status luôn PENDING khi tạo mới — DAO cũng hardcode 'PENDING'

            String profanityError = checkProfanity(article);
            if (profanityError != null) {
                req.setAttribute("error", profanityError);
                req.setAttribute("article", article);
                req.setAttribute("knownErrors", kbDAO.listKnownErrors());
                req.getRequestDispatcher("/knowledge/knowledge-article-form.jsp").forward(req, resp);
                return;
            }

            if (kbDAO.addArticle(article)) {
                resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article?message="
                        + encode("Thêm bài viết thành công. Vui lòng chờ admin phê duyệt."));
            } else {
                req.setAttribute("error", "Không thể tạo bài viết");
                req.setAttribute("article", article);
                req.setAttribute("knownErrors", kbDAO.listKnownErrors());
                req.getRequestDispatcher("/knowledge/knowledge-article-form.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            System.out.println("addArticle error: " + e);
        }
    }

    // ===================== UPDATE ARTICLE =====================
    private void updateArticle(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            User currentUser = (User) req.getSession().getAttribute("user");
            String idStr = req.getParameter("articleId");
            if (idStr == null || idStr.isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article");
                return;
            }

            // Kiểm tra quyền sở hữu trước khi cho sửa
            Article existing = kbDAO.findById(Integer.parseInt(idStr));
            if (existing == null || !existing.getAuthorId().equals(currentUser.getUserId())) {
                resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article?error="
                        + encode("Bạn không có quyền chỉnh sửa bài viết này"));
                return;
            }

            Article article = buildArticleFromRequest(req);
            article.setArticleId(Integer.parseInt(idStr));
            article.setAuthorId(currentUser.getUserId());
            // DAO sẽ tự reset status = PENDING, xóa approved_by/approved_at/rejection_reason

            String profanityError = checkProfanity(article);
            if (profanityError != null) {
                req.setAttribute("error", profanityError);
                req.setAttribute("article", article);
                req.setAttribute("knownErrors", kbDAO.listKnownErrors());
                req.getRequestDispatcher("/knowledge/knowledge-article-form.jsp").forward(req, resp);
                return;
            }

            if (kbDAO.updateArticle(article)) {
                resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article?message="
                        + encode("Cập nhật thành công. Bài viết đang chờ admin phê duyệt lại."));
            } else {
                req.setAttribute("error", "Không thể cập nhật bài viết");
                req.setAttribute("article", article);
                req.setAttribute("knownErrors", kbDAO.listKnownErrors());
                req.getRequestDispatcher("/knowledge/knowledge-article-form.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            System.out.println("updateArticle error: " + e);
        }
    }

    // ===================== DELETE ARTICLE =====================
    private void deleteArticle(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        User currentUser = (User) req.getSession().getAttribute("user");
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article");
            return;
        }
        // deleteArticleByAuthor: chỉ xóa được nếu đúng author_id → tự động chặn xóa bài người khác
        boolean ok = kbDAO.deleteArticleByAuthor(Integer.parseInt(idStr), currentUser.getUserId());
        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article?message="
                    + encode("Xóa bài viết thành công"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article?error="
                    + encode("Không thể xóa. Bạn chỉ có thể xóa bài viết của chính mình."));
        }
    }

    // ===================== HELPER =====================
    private Article buildArticleFromRequest(HttpServletRequest req) {
        Article a = new Article();
        a.setTitle(req.getParameter("title"));
        a.setSummary(req.getParameter("summary"));
        a.setContent(req.getParameter("content"));
        a.setArticleType(req.getParameter("articleType"));
        a.setTag(req.getParameter("tag"));
        a.setErrorCode(req.getParameter("errorCode"));
        a.setSymptom(req.getParameter("symptom"));
        a.setCause(req.getParameter("cause"));
        a.setSolution(req.getParameter("solution"));
        return a;
    }

    private String checkProfanity(Article a) {
        java.util.Map<String, String> fields = new java.util.LinkedHashMap<>();
        fields.put("Tiêu đề",     a.getTitle());
        fields.put("Mô tả",       a.getSummary());
        fields.put("Nội dung",    a.getContent());
        fields.put("Triệu chứng", a.getSymptom());
        fields.put("Nguyên nhân", a.getCause());
        fields.put("Giải pháp",   a.getSolution());
        for (java.util.Map.Entry<String, String> entry : fields.entrySet()) {
            String found = ProfanityFilter.findBannedWord(entry.getValue());
            if (found != null)
                return entry.getKey() + " chứa từ không phù hợp: \"" + found + "\"";
        }
        return null;
    }

    private String encode(String s) {
        try { return java.net.URLEncoder.encode(s, "UTF-8"); }
        catch (Exception e) { return s; }
    }
}
