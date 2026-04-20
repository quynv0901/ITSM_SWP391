package com.itserviceflow.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Legacy/detail URL: forwards to {@link IncidentController} so chi tiết incident
 * luôn dùng đúng JSP và đủ dữ liệu ({@code incident}, {@code relatedIncidents}, …).
 */
@WebServlet(name = "IncidentDetailServlet", urlPatterns = {"/incident-detail"})
public class IncidentDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/incident?action=list");
            return;
        }
        try {
            int id = Integer.parseInt(idParam.trim());
            if (id <= 0) {
                response.sendRedirect(request.getContextPath() + "/incident?action=list");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + id);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/incident?action=list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
