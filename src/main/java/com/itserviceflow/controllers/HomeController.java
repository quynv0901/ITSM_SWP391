package com.itserviceflow.controllers;

import com.itserviceflow.daos.KnowledgeArticleDAO;
import com.itserviceflow.daos.KnowledgeBaseDAO;
import com.itserviceflow.models.User;
import com.itserviceflow.utils.AuthUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/home")
public class HomeController extends HttpServlet {

    private KnowledgeBaseDAO kbDAO = new KnowledgeBaseDAO();
    private KnowledgeArticleDAO kaDAO = new KnowledgeArticleDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!AuthUtils.isLoggedIn(request, response))
            return;
        User currentUser = AuthUtils.getCurrentUser(request);
        request.setAttribute("currentUser", currentUser);
        request.setAttribute("newArticleCount", kbDAO.countNewArticles());
        request.setAttribute("newKnowledgeArticleCount", kaDAO.countNewArticles());
        request.getRequestDispatcher("/home/dashboard.jsp").forward(request, response);
    }
}