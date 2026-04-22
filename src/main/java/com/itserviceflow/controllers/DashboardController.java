package com.itserviceflow.controllers;

import com.itserviceflow.utils.AuthUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/dashboard")
public class DashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!AuthUtils.isLoggedIn(request, response)) return;
        request.setAttribute("currentUser", AuthUtils.getCurrentUser(request));
        request.getRequestDispatcher("/dashboard/executive-dashboard.jsp").forward(request, response);
    }
}
