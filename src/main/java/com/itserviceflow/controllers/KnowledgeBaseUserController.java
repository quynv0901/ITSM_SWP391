package com.itserviceflow.controllers;


import com.itserviceflow.daos.KnowledgeBaseDAO;
import com.itserviceflow.models.Article;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "KnowledgeBaseUserController", urlPatterns = {"/knowledge-base"})
public class KnowledgeBaseUserController extends HttpServlet {

    private KnowledgeBaseDAO kbDAO = new KnowledgeBaseDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        action = (action == null) ? "list" : action;

        switch (action) {
        }
    }

    private void listView(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        String pageStr = req.getParameter("page");

        int page   = (pageStr != null && !pageStr.isEmpty()) ? Integer.parseInt(pageStr) : 1;
        int limit  = 10;
        int offset = (page - 1) * limit;

        // Chỉ lấy bài PUBLISHED
        List<Article> articles = kbDAO.listArticles(keyword, "PUBLISHED", "KNOWLEDGE_BASE", offset, limit);
        int total              = kbDAO.countArticles(keyword, "PUBLISHED", "KNOWLEDGE_BASE");
        int totalPages         = (int) Math.ceil((double) total / limit);

        req.setAttribute("articles",    articles);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages",  totalPages);
        req.setAttribute("keyword",     keyword);

        req.getRequestDispatcher("/knowledge/knowledge-base-list.jsp").forward(req, resp);
    }

    
}