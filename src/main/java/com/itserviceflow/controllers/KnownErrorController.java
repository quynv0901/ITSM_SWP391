package com.itserviceflow.controllers;

import com.itserviceflow.daos.KnownErrorDAO;
import com.itserviceflow.models.Ticket;
import com.itserviceflow.models.User;
import com.itserviceflow.utils.AuthUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/known-error")
public class KnownErrorController extends HttpServlet {

    private KnownErrorDAO knownErrorDAO;

    @Override
    public void init() throws ServletException {
        knownErrorDAO = new KnownErrorDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
            
        if (!AuthUtils.isLoggedIn(request, response)) {
            return;
        }

        User currentUser = AuthUtils.getCurrentUser(request);
        request.setAttribute("currentUser", currentUser);

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "list":
                List<Ticket> errors = knownErrorDAO.getBasicKnownErrors();
                request.setAttribute("knownErrors", errors);
                request.getRequestDispatcher("/known-error/list.jsp").forward(request, response);
                break;
            case "detail":
                viewKnownErrorDetail(request, response);
                break;
            case "add":
                showAddForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/known-error?action=list");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!AuthUtils.isLoggedIn(request, response)) return;

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/known-error?action=list");
            return;
        }

        switch (action) {
            case "insert":
                insertKnownError(request, response);
                break;
            case "update":
                updateKnownError(request, response);
                break;
            case "delete":
                deleteKnownError(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/known-error?action=list");
                break;
        }
    }
    
    private void viewKnownErrorDetail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Ticket ticket = knownErrorDAO.getKnownErrorById(id);
        request.setAttribute("knownError", ticket);
        request.getRequestDispatcher("/known-error/detail.jsp").forward(request, response);
    }

    private void showAddForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/known-error/form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Ticket ticket = knownErrorDAO.getKnownErrorById(id);
        request.setAttribute("knownError", ticket);
        request.getRequestDispatcher("/known-error/form.jsp").forward(request, response);
    }

    private void insertKnownError(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String cause = request.getParameter("cause");
        String solution = request.getParameter("solution");
        String status = request.getParameter("status");

        User user = AuthUtils.getCurrentUser(request);

        Ticket ticket = new Ticket();
        ticket.setTitle(title);
        ticket.setDescription(description);
        ticket.setCause(cause);
        ticket.setSolution(solution);
        ticket.setStatus(status);
        ticket.setReportedBy(user.getUserId());

        knownErrorDAO.createKnownError(ticket);
        response.sendRedirect(request.getContextPath() + "/known-error?action=list");
    }

    private void updateKnownError(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String cause = request.getParameter("cause");
        String solution = request.getParameter("solution");
        String status = request.getParameter("status");

        Ticket ticket = new Ticket();
        ticket.setTicketId(id);
        ticket.setTitle(title);
        ticket.setDescription(description);
        ticket.setCause(cause);
        ticket.setSolution(solution);
        ticket.setStatus(status);

        knownErrorDAO.updateKnownError(ticket);
        response.sendRedirect(request.getContextPath() + "/known-error?action=detail&id=" + id);
    }

    private void deleteKnownError(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        knownErrorDAO.deleteKnownError(id);
        response.sendRedirect(request.getContextPath() + "/known-error?action=list");
    }
}
