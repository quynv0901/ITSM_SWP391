package com.itserviceflow.controllers;

import com.itserviceflow.daos.TicketDAO;
import com.itserviceflow.daos.RoleDAO;
import com.itserviceflow.models.Ticket;
import com.itserviceflow.models.User;
import com.itserviceflow.utils.AuthUtils;
import com.itserviceflow.daos.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/incident")
public class IncidentController extends HttpServlet {
    private TicketDAO ticketDAO;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "list":
                listIncidents(request, response);
                break;
            case "detail":
                viewIncidentDetail(request, response);
                break;
            case "add":
                showForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            default:
                listIncidents(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/incident?action=list");
            return;
        }

        switch (action) {
            case "insert":
                insertIncident(request, response);
                break;
            case "update":
                updateIncident(request, response);
                break;
            case "delete":
                deleteIncident(request, response);
                break;
            case "cancel":
                cancelIncident(request, response);
                break;
            case "assign":
                assignIncident(request, response);
                break;
            case "categorize":
                categorizeIncident(request, response);
                break;
            case "link":
                linkIncident(request, response);
                break;
            case "logtime":
                manualLogTime(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/incident?action=list");
                break;
        }
    }

    private void listIncidents(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // use session user info to filter for end‑users
        jakarta.servlet.http.HttpSession session = request.getSession();
        com.itserviceflow.models.User user = (com.itserviceflow.models.User) session.getAttribute("user");
        int userId = 0;
        String roleName = "";
        if (user != null) {
            userId = user.getUserId();
            // if roleName not yet set, lookup from DB
            if (user.getRoleName() == null || user.getRoleName().isEmpty()) {
                RoleDAO rdao = new RoleDAO();
                String rn = rdao.getRoleNameById(user.getRoleId());
                user.setRoleName(rn);
            }
            roleName = user.getRoleName();
        }
        List<Ticket> list = ticketDAO.getIncidentList(userId, roleName);
        request.setAttribute("incidentList", list);
        request.getRequestDispatcher("/incidents/incidentList.jsp").forward(request, response);
    }

    private void viewIncidentDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Ticket incident = ticketDAO.getTicketWithDetails(id);
        List<Ticket> related = ticketDAO.getRelatedIncidents(id);


        // Load category information for dynamic display
        com.itserviceflow.daos.TicketCategoryDAO categoryDAO = new com.itserviceflow.daos.TicketCategoryDAO();
        com.itserviceflow.models.TicketCategory category = null;
        if (incident.getCategoryId() != 0) {
            category = categoryDAO.findById(incident.getCategoryId());
        }
        
        // Set attributes for JSP
        request.setAttribute("incident", incident);
        request.setAttribute("relatedIncidents", related);
        request.setAttribute("category", category);
        
        request.getRequestDispatcher("/incidents/incident-detail.jsp").forward(request, response);
    }

    private void showForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Load categories for dropdown
        com.itserviceflow.daos.TicketCategoryDAO categoryDAO = new com.itserviceflow.daos.TicketCategoryDAO();
        java.util.List<com.itserviceflow.models.TicketCategory> categories = categoryDAO.getActiveCategories();
        request.setAttribute("categories", categories);
        
        request.getRequestDispatcher("/incidents/incident-form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Ticket incident = ticketDAO.getIncidentById(id);
        
        // Load categories for dropdown
        com.itserviceflow.daos.TicketCategoryDAO categoryDAO = new com.itserviceflow.daos.TicketCategoryDAO();
        java.util.List<com.itserviceflow.models.TicketCategory> categories = categoryDAO.getActiveCategories();
        request.setAttribute("categories", categories);
        
        request.setAttribute("incident", incident);
        request.getRequestDispatcher("/incidents/incident-form.jsp").forward(request, response);
    }

    private void insertIncident(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String priority = request.getParameter("priority");
        int categoryId = Integer.parseInt(request.getParameter("categoryId"));

    // Get current logged-in user
    HttpSession session = request.getSession();
    User currentUser = (User) session.getAttribute("user");
    int creatorId = (currentUser != null) ? currentUser.getUserId() : 1;

        Ticket incident = new Ticket();
        incident.setTitle(title);
        incident.setDescription(description);
        incident.setPriority(priority);
        incident.setCategoryId(categoryId);
        incident.setReportedBy(creatorId);
        incident.setTicketType("INCIDENT");

        String relatedIdsStr = request.getParameter("relatedIds");
        List<Integer> relatedIds = new ArrayList<>();
        if (relatedIdsStr != null && !relatedIdsStr.trim().isEmpty()) {
            for (String s : relatedIdsStr.split(",")) {
                try {
                    relatedIds.add(Integer.parseInt(s.trim()));
                } catch (NumberFormatException ignored) {
                }
            }
        }

        boolean created = ticketDAO.createIncidentTicket(incident, creatorId);
        if (created && incident.getTicketId() > 0) {
            // Load full details (including difficulty_level) for logtime calc
            Ticket full = ticketDAO.getTicketWithDetails(incident.getTicketId());
        }
        if (!relatedIds.isEmpty()) {
            ticketDAO.linkRelatedIncidents(incident.getTicketId(), relatedIds, creatorId);
        }
        response.sendRedirect(request.getContextPath() + "/incident?action=list");
    }

    private void updateIncident(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String newStatus = request.getParameter("status");
        String priority = request.getParameter("priority");
        int categoryId = Integer.parseInt(request.getParameter("categoryId"));

        // Fetch current status before update to detect transitions
        Ticket existing = ticketDAO.getTicketWithDetails(id);
        String oldStatus = (existing != null) ? existing.getStatus() : "";

        Ticket incident = new Ticket();
        incident.setTicketId(id);
        incident.setTitle(title);
        incident.setDescription(description);
        incident.setStatus(newStatus);
        incident.setPriority(priority);
        incident.setCategoryId(categoryId);

        ticketDAO.updateIncidentTicket(incident);

        // Auto-log on status transitions
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        int agentId = (currentUser != null) ? currentUser.getUserId() : 1;

        if (existing != null && newStatus != null && !newStatus.equals(oldStatus)) {
            // Do not auto-log if the user performing the update is an end-user
            HttpSession session2 = request.getSession();
            User currentUser2 = (User) session2.getAttribute("user");
            boolean isEndUserActor = (currentUser2 != null && currentUser2.getRoleId() != null
                    && currentUser2.getRoleId() == AuthUtils.ROLE_END_USER);
        }

        response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + id);
    }

    private void deleteIncident(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        ticketDAO.deleteIncidentTicket(id);
        response.sendRedirect(request.getContextPath() + "/incident?action=list");
    }

    private void cancelIncident(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String cancelReason = request.getParameter("cancelReason");
        
        // Get current user
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        int userId = (currentUser != null) ? currentUser.getUserId() : 1;
        
        // Cancel the incident
        ticketDAO.cancelIncidentTicket(id);
        
        // Log the cancellation with reason
        if (cancelReason != null && !cancelReason.trim().isEmpty()) {
            // Auto-log CANCELLED activity with reason, but skip if actor is end-user
            Ticket ticket = ticketDAO.getTicketWithDetails(id);
            if (ticket != null) {
                HttpSession session2 = request.getSession();
                User currentUser2 = (User) session2.getAttribute("user");
            }
        }
        
        response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + id);
    }

    private void assignIncident(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        int assignedTo = Integer.parseInt(request.getParameter("assignedTo"));

        ticketDAO.assignIncidentTicket(id, assignedTo);

        // Auto-log ASSIGNED activity
        Ticket ticket = ticketDAO.getTicketWithDetails(id);
        if (ticket != null) {
            // Only auto-log if the assignee is not an end-user
            UserDAO userDAO = new UserDAO();
            User assignee = userDAO.findById(assignedTo);
        }

        response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + id);
    }

    private void categorizeIncident(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        int categoryId = Integer.parseInt(request.getParameter("categoryId"));
        ticketDAO.categorizeIncidentTicket(id, categoryId);
        response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + id);
    }

    private void linkIncident(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String relatedIdsStr = request.getParameter("relatedIds");
        List<Integer> relatedIds = new ArrayList<>();
        if (relatedIdsStr != null && !relatedIdsStr.trim().isEmpty()) {
            for (String s : relatedIdsStr.split(",")) {
                try {
                    relatedIds.add(Integer.parseInt(s.trim()));
                } catch (NumberFormatException ignored) {
                }
            }
        }
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        int userId = (currentUser != null) ? currentUser.getUserId() : 1;
        ticketDAO.linkRelatedIncidents(id, relatedIds, userId);
        response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + id);
    }

    /**
     * Handles manual time log submission from the agent via the incident-detail form.
     */
    private void manualLogTime(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int ticketId = Integer.parseInt(request.getParameter("id"));
        double timeSpent;
        try {
            timeSpent = Double.parseDouble(request.getParameter("timeSpent"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + ticketId + "&logError=invalidTime");
            return;
        }
        String description = request.getParameter("logDescription");

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        int agentId = (currentUser != null) ? currentUser.getUserId() : 1;

        // Prevent end-users from creating manual time logs
        if (currentUser != null && currentUser.getRoleId() != null && currentUser.getRoleId() == AuthUtils.ROLE_END_USER) {
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + ticketId + "&logError=forbidden");
            return;
        }
    }
}
