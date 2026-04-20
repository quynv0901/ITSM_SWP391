package com.itserviceflow.controllers;

import com.itserviceflow.daos.TimeLogDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Map;

/**
 * Serves the Executive Dashboard page. Loads KPI data and forwards to
 * executive-dashboard.jsp.
 *
 * GET /dashboard
 */
@WebServlet("/dashboard")
public class DashboardController extends HttpServlet {

    private TimeLogDAO timeLogDAO;

    @Override
    public void init() throws ServletException {
        timeLogDAO = new TimeLogDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // --- KPI summary numbers ---
        double[] kpis = timeLogDAO.getDashboardKpis();
        request.setAttribute("kpiTotalTickets", (int) kpis[0]);
        request.setAttribute("kpiOpenTickets", (int) kpis[1]);
        request.setAttribute("kpiResolvedTickets", (int) kpis[2]);
        request.setAttribute("kpiTotalHours", kpis[3]);
        request.setAttribute("kpiLogEntries", (int) kpis[4]);

        // --- Breakdown charts data ---
        Map<String, Integer> byStatus = timeLogDAO.getTicketCountByStatus();
        Map<String, Integer> byType = timeLogDAO.getTicketCountByType();
        Map<String, Integer> byPriority = timeLogDAO.getTicketCountByPriority();
        Map<String, Double> byAgent = timeLogDAO.getTotalHoursPerAgent(10);

        request.setAttribute("byStatus", byStatus);
        request.setAttribute("byType", byType);
        request.setAttribute("byPriority", byPriority);
        request.setAttribute("byAgent", byAgent);

        request.getRequestDispatcher("/dashboard/executive-dashboard.jsp").forward(request, response);
    }
}
