package com.itserviceflow.controllers;

import com.itserviceflow.daos.KnowledgeArticleDAO;
import com.itserviceflow.models.Article;
import com.itserviceflow.models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
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
            case "list":
                listArticles(req, resp);
                break;
            case "add":
                addView(req, resp);
                break;
            case "edit":
                editView(req, resp);
                break;
            case "detail":
                detailView(req, resp);
                break;
            case "delete":
                deleteArticle(req, resp);
                break;
            case "toggle":
                toggleStatus(req, resp);
                break;
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
            case "add":
                addArticle(req, resp);
                break;
            case "edit":
                updateArticle(req, resp);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article");
        }
    }
    

    // ===================== VIEW HANDLERS =====================
    private void listArticles(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        String status = req.getParameter("status");
        String type = req.getParameter("type");
        String pageStr = req.getParameter("page");

        int page = (pageStr != null && !pageStr.isEmpty()) ? Integer.parseInt(pageStr) : 1;
        int limit = 10;
        int offset = (page - 1) * limit;

        List<Article> articles = kbDAO.listArticles(keyword, status, type, offset, limit);
        int total = kbDAO.countArticles(keyword, status, type);
        int totalPages = (int) Math.ceil((double) total / limit);

        req.setAttribute("articles", articles);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("keyword", keyword);
        req.setAttribute("statusFilter", status);
        req.setAttribute("typeFilter", type);

        req.getRequestDispatcher("/support-agent/knowledge-article.jsp").forward(req, resp);
    }

private void addView(HttpServletRequest req, HttpServletResponse resp)
        throws ServletException, IOException {
    req.setAttribute("article", new Article());
    req.setAttribute("knownErrors", kbDAO.listKnownErrors());
    req.getRequestDispatcher("/knowledge/knowledge-article-form.jsp").forward(req, resp);
}

private void editView(HttpServletRequest req, HttpServletResponse resp)
        throws ServletException, IOException {
    String idStr = req.getParameter("id");
    if (idStr == null || idStr.isEmpty()) {
        resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article");
        return;
    }
    Article article = kbDAO.findById(Integer.parseInt(idStr));
    if (article == null) {
        resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article?error=Article not found");
        return;
    }
    req.setAttribute("article", article);
    req.setAttribute("knownErrors", kbDAO.listKnownErrors());
    req.getRequestDispatcher("/knowledge/knowledge-article-form.jsp").forward(req, resp);
}

private void detailView(HttpServletRequest req, HttpServletResponse resp)
        throws ServletException, IOException {
    // Tìm theo errorCode (từ link click)
    String errorCode = req.getParameter("errorCode");
    if (errorCode != null && !errorCode.isEmpty()) {
        Article article = kbDAO.findByErrorCode(errorCode);
        if (article == null) {
            resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article?error=Article not found");
            return;
        }
        req.setAttribute("article", article);
        req.getRequestDispatcher("/support-agent/knowledge-article-detail-agent.jsp").forward(req, resp);
        return;
    }

    // Tìm theo id (bình thường)
    String idStr = req.getParameter("id");
    if (idStr == null || idStr.isEmpty()) {
        resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article");
        return;
    }
    Article article = kbDAO.findById(Integer.parseInt(idStr));
    if (article == null) {
        resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article?error=Article not found");
        return;
    }
    req.setAttribute("article", article);
    req.getRequestDispatcher("/support-agent/knowledge-article-detail-agent.jsp").forward(req, resp);
}

private void addArticle(HttpServletRequest req, HttpServletResponse resp)
        throws ServletException, IOException {
    try {
        User sessionUser = (User) req.getSession().getAttribute("user");
        Article article = buildArticleFromRequest(req);
        article.setAuthorId(sessionUser.getUserId());
        article.setStatus("PUBLISHED");

        if (kbDAO.addArticle(article)) {
            resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article?message=Article created successfully");
        } else {
            req.setAttribute("error", "Could not create article");
            req.setAttribute("article", article);
            req.setAttribute("knownErrors", kbDAO.listKnownErrors());
            req.getRequestDispatcher("/knowledge/knowledge-article-form.jsp").forward(req, resp);
        }
    } catch (Exception e) {
        System.out.println("addArticle error: " + e);
    }
}

private void updateArticle(HttpServletRequest req, HttpServletResponse resp)
        throws ServletException, IOException {
    try {
        String idStr = req.getParameter("articleId");
        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article");
            return;
        }
        Article article = buildArticleFromRequest(req);
        article.setArticleId(Integer.parseInt(idStr));
        article.setStatus("PUBLISHED");

        if (kbDAO.updateArticle(article)) {
            resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article?message=Article updated successfully");
        } else {
            req.setAttribute("error", "Could not update article");
            req.setAttribute("article", article);
            req.setAttribute("knownErrors", kbDAO.listKnownErrors());
            req.getRequestDispatcher("/knowledge/knowledge-article-form.jsp").forward(req, resp);
        }
    } catch (Exception e) {
        System.out.println("updateArticle error: " + e);
    }
}

    private void deleteArticle(HttpServletRequest req, HttpServletResponse resp)
        throws IOException {
    String idStr = req.getParameter("id");
    System.out.println(">>> deleteArticle controller idStr = " + idStr); // ← thêm dòng này
    if (idStr == null || idStr.isEmpty()) {
        resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article");
        return;
    }
    kbDAO.deleteArticle(Integer.parseInt(idStr));
    resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article?message=Article deleted successfully");
}

    private void toggleStatus(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String idStr = req.getParameter("id");
        String newStatus = req.getParameter("status");
        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article");
            return;
        }
        kbDAO.toggleStatus(Integer.parseInt(idStr), newStatus);
        resp.sendRedirect(req.getContextPath() + "/support-agent/knowledge-article?message=Status updated");
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

    @Override
    public String getServletInfo() {
        return "KnowledgeArticleController - Handles knowledge article CRUD";
    }
}
