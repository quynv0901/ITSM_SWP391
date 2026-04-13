package com.itserviceflow.controllers;

import com.itserviceflow.daos.KnowledgeBaseDAO;
import com.itserviceflow.models.Article;
import com.itserviceflow.models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "KnowledgeBaseController", urlPatterns = {"/admin/knowledge-base"})
public class KnowledgeBaseController extends HttpServlet {

    private KnowledgeBaseDAO kbDAO = new KnowledgeBaseDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        action = (action == null) ? "list" : action;

        switch (action) {
            case "list":
                listArticles(req, resp);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/admin/knowledge-base");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        action = (action == null) ? "list" : action;

        switch (action) {
            default:
                resp.sendRedirect(req.getContextPath() + "/admin/knowledge-base");
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

        req.getRequestDispatcher("/admin/knowledge-base.jsp").forward(req, resp);
    }

    @Override
    public String getServletInfo() {
        return "KnowledgeBaseController - Handles knowledge base CRUD";
    }
}
