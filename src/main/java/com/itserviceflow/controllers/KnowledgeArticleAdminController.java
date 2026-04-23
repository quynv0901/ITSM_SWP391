package com.itserviceflow.controllers;

import com.itserviceflow.daos.KnowledgeArticleDAO;
import com.itserviceflow.models.Article;
import com.itserviceflow.models.User;
import com.itserviceflow.utils.AuthUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "KnowledgeArticleAdminController", urlPatterns = {"/admin/knowledge-article"})
public class KnowledgeArticleAdminController extends HttpServlet {

    private KnowledgeArticleDAO kbDAO = new KnowledgeArticleDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!hasAccess(req, resp)) return;
        String action = req.getParameter("action");
        action = (action == null) ? "list" : action;
        switch (action) {
            case "list":   listArticles(req, resp); break;
            case "detail": detailView(req, resp);   break;
            default:
                resp.sendRedirect(req.getContextPath() + "/admin/knowledge-article?action=list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!hasAccess(req, resp)) return;
        String action = req.getParameter("action");
        action = (action == null) ? "list" : action;
        switch (action) {
            case "approve":         approveArticle(req, resp);   break;
            case "reject":          rejectArticle(req, resp);    break;
            case "toggle":          toggleStatus(req, resp);     break;
            case "delete":          deleteArticle(req, resp);    break;
            case "bulkReview":      bulkApprove(req, resp);      break;
            case "bulkDelete":      bulkDelete(req, resp);       break;
            case "bulkToggleStatus":bulkToggleStatus(req, resp); break;
            default:
                resp.sendRedirect(req.getContextPath() + "/admin/knowledge-article?action=list");
        }
    }

    // ===================== LIST =====================
    private void listArticles(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String keyword      = req.getParameter("keyword");
        String statusFilter = req.getParameter("status");
        String pageStr      = req.getParameter("page");

        int page   = (pageStr != null && !pageStr.isEmpty()) ? Integer.parseInt(pageStr) : 1;
        int limit  = 10;
        int offset = (page - 1) * limit;

        List<Article> articles = kbDAO.listArticles(keyword, statusFilter, null, offset, limit);
        int total      = kbDAO.countArticles(keyword, statusFilter, null);
        int totalPages = (int) Math.ceil((double) total / limit);

        // Stats chips
        req.setAttribute("totalAll",      kbDAO.countArticles(null, null,         null));
        req.setAttribute("totalPending",  kbDAO.countArticles(null, "PENDING",    null));
        req.setAttribute("totalApproved", kbDAO.countArticles(null, "APPROVED",   null));
        req.setAttribute("totalRejected", kbDAO.countArticles(null, "REJECTED",   null));
        req.setAttribute("totalArchived", kbDAO.countArticles(null, "ARCHIVED",   null));

        req.setAttribute("articles",     articles);
        req.setAttribute("currentPage",  page);
        req.setAttribute("totalPages",   totalPages);
        req.setAttribute("keyword",      keyword);
        req.setAttribute("statusFilter", statusFilter);

        req.getRequestDispatcher("/admin/knowledge-article-admin.jsp").forward(req, resp);
    }

    // ===================== DETAIL =====================
    private void detailView(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/knowledge-article?action=list");
            return;
        }
        Article article = kbDAO.findById(Integer.parseInt(idStr));
        if (article == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/knowledge-article?action=list&error="
                    + encode("Không tìm thấy bài viết"));
            return;
        }
        req.setAttribute("article", article);
        req.getRequestDispatcher("/admin/knowledge-article-detail-admin.jsp").forward(req, resp);
    }

    // ===================== APPROVE → APPROVED =====================
    private void approveArticle(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/knowledge-article?action=list");
            return;
        }
        User currentUser = AuthUtils.getCurrentUser(req);
        boolean ok = kbDAO.approveArticle(Integer.parseInt(idStr), currentUser.getUserId());
        redirect(resp, req, ok, "Đã duyệt bài viết thành công", "Không thể duyệt bài viết");
    }

    // ===================== REJECT → REJECTED =====================
    private void rejectArticle(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String idStr  = req.getParameter("id");
        String reason = req.getParameter("rejectionReason");
        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/knowledge-article?action=list");
            return;
        }
        User currentUser = AuthUtils.getCurrentUser(req);
        boolean ok = kbDAO.rejectArticle(Integer.parseInt(idStr), currentUser.getUserId(), reason);
        redirect(resp, req, ok, "Đã từ chối bài viết", "Không thể từ chối bài viết");
    }

    // ===================== TOGGLE: APPROVED→ARCHIVED hoặc ARCHIVED→APPROVED =====================
    private void toggleStatus(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String idStr    = req.getParameter("id");
        String newStatus = req.getParameter("status"); // "ARCHIVED" hoặc "APPROVED"
        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/knowledge-article?action=list");
            return;
        }
        kbDAO.toggleStatus(Integer.parseInt(idStr), newStatus);
        redirect(resp, req, true, "Đã cập nhật trạng thái", null);
    }

    // ===================== DELETE =====================
    private void deleteArticle(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/knowledge-article?action=list");
            return;
        }
        kbDAO.deleteArticle(Integer.parseInt(idStr));
        redirect(resp, req, true, "Đã xóa bài viết", null);
    }

    // ===================== BULK APPROVE =====================
    private void bulkApprove(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String[] ids = req.getParameterValues("selectedIds");
        User currentUser = AuthUtils.getCurrentUser(req);
        if (ids != null)
            for (String id : ids)
                kbDAO.approveArticle(Integer.parseInt(id), currentUser.getUserId());
        redirect(resp, req, true, "Đã duyệt các bài viết được chọn", null);
    }

    // ===================== BULK DELETE =====================
    private void bulkDelete(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String[] ids = req.getParameterValues("selectedIds");
        if (ids != null)
            for (String id : ids)
                kbDAO.deleteArticle(Integer.parseInt(id));
        redirect(resp, req, true, "Đã xóa các bài viết được chọn", null);
    }

    // ===================== BULK TOGGLE =====================
    private void bulkToggleStatus(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String[] ids    = req.getParameterValues("selectedIds");
        String toggleTo = req.getParameter("toggleTo"); // "ARCHIVED" hoặc "APPROVED"
        if (ids != null && toggleTo != null)
            for (String id : ids)
                kbDAO.toggleStatus(Integer.parseInt(id), toggleTo);
        redirect(resp, req, true, "Đã cập nhật trạng thái hàng loạt", null);
    }

    // ===================== HELPER =====================
    private boolean hasAccess(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        if (!AuthUtils.isLoggedIn(req, resp)) return false;
        User user = AuthUtils.getCurrentUser(req);
        if (user.getRoleId() != 10 && user.getRoleId() != 3) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return false;
        }
        return true;
    }

    private void redirect(HttpServletResponse resp, HttpServletRequest req,
                          boolean ok, String successMsg, String errorMsg) throws IOException {
        String param = ok ? "message" : "error";
        String msg   = ok ? successMsg : errorMsg;
        resp.sendRedirect(req.getContextPath() + "/admin/knowledge-article?action=list&"
                + param + "=" + encode(msg));
    }

    private String encode(String s) {
        try { return java.net.URLEncoder.encode(s, "UTF-8"); }
        catch (Exception e) { return s; }
    }
}
