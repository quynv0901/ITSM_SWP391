package com.itserviceflow.controllers;

import com.google.gson.Gson;
import com.itserviceflow.daos.WorkflowDAO;
import com.itserviceflow.models.Workflow;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;

/**
 * WorkflowServlet — handles all workflow-related HTTP requests.
 *
 * URL patterns: GET /workflows -> list page (with optional ?status= filter) GET
 * /workflows?action=detail&id= -> detail page GET /workflows?action=create ->
 * blank create form GET /workflows?action=edit&id= -> edit form pre-filled POST
 * /workflows?action=create -> persist new workflow POST
 * /workflows?action=update -> update existing workflow POST
 * /workflows?action=delete -> delete workflow (id in body) POST
 * /workflows?action=toggle -> enable / disable (id + newStatus in body)
 */
@WebServlet(name = "WorkflowServlet", urlPatterns = {"/workflows"})
public class WorkflowServlet extends HttpServlet {

    private final WorkflowDAO dao = new WorkflowDAO();
    private final com.itserviceflow.daos.TicketCategoryDAO categoryDAO = new com.itserviceflow.daos.TicketCategoryDAO();
    private final Gson gson = new Gson();

    // ==================================================================
    // GET
    // ==================================================================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if (action == null) {
            action = "list";
        }

        try {
            switch (action) {
                case "detail" ->
                    showDetail(req, resp);
                case "create" ->
                    showCreateForm(req, resp);
                case "edit" ->
                    showEditForm(req, resp);
                case "api-ticket-types" ->
                    sendTicketTypes(req, resp);
                default ->
                    showList(req, resp);
            }
        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        }
    }

    // ==================================================================
    // POST
    // ==================================================================
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if (action == null) {
            action = "";
        }

        try {
            switch (action) {
                case "create" ->
                    handleCreate(req, resp);
                case "update" ->
                    handleUpdate(req, resp);
                case "delete" ->
                    handleDelete(req, resp);
                case "toggle" ->
                    handleToggle(req, resp);
                default ->
                    resp.sendRedirect(req.getContextPath() + "/workflows");
            }
        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        }
    }

    // ==================================================================
    // GET handlers
    // ==================================================================
    private static final int DEFAULT_PAGE_SIZE = 10;

    private void showList(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {

        String statusFilter = req.getParameter("status");
        String search = req.getParameter("search");

        List<Workflow> allFiltered;
        if (statusFilter != null && !statusFilter.isBlank()) {
            allFiltered = dao.getWorkflowsByStatus(statusFilter.toUpperCase());
        } else {
            allFiltered = dao.getAllWorkflows();
        }

        // Apply keyword search filter
        if (search != null && !search.isBlank()) {
            final String kw = search.trim().toLowerCase();
            allFiltered = allFiltered.stream()
                .filter(w -> (w.getWorkflowName() != null && w.getWorkflowName().toLowerCase().contains(kw))
                          || (w.getDescription()   != null && w.getDescription().toLowerCase().contains(kw)))
                .toList();
        }

        // Counts for the filter tabs (always from full list)
        List<Workflow> all     = dao.getAllWorkflows();
        long countAll      = all.size();
        long countActive   = all.stream().filter(w -> "ACTIVE".equals(w.getStatus())).count();
        long countInactive = all.stream().filter(w -> "INACTIVE".equals(w.getStatus())).count();
        long countDraft = all.stream().filter(w -> "DRAFT".equals(w.getStatus())).count();

        // Pagination
        int pageSize = DEFAULT_PAGE_SIZE;
        try {
            String ps = req.getParameter("pageSize");
            if (ps != null && !ps.isBlank()) {
                pageSize = Math.max(1, Integer.parseInt(ps.trim()));
            }
        } catch (NumberFormatException ignored) {
        }

        int total = allFiltered.size();
        int totalPages = (int) Math.ceil((double) total / pageSize);
        if (totalPages < 1) {
            totalPages = 1;
        }

        int currentPage = 1;
        try {
            String p = req.getParameter("page");
            if (p != null && !p.isBlank()) {
                currentPage = Integer.parseInt(p.trim());
            }
        } catch (NumberFormatException ignored) {
        }
        if (currentPage < 1) {
            currentPage = 1;
        }
        if (currentPage > totalPages) {
            currentPage = totalPages;
        }

        int fromIdx = (currentPage - 1) * pageSize;
        int toIdx = Math.min(fromIdx + pageSize, total);
        List<Workflow> workflows = allFiltered.subList(fromIdx, toIdx);

        req.setAttribute("workflows", workflows);
        req.setAttribute("statusFilter", statusFilter == null ? "" : statusFilter);
        req.setAttribute("search",       search == null ? "" : search);
        req.setAttribute("countAll",     countAll);
        req.setAttribute("countActive",  countActive);
        req.setAttribute("countInactive",countInactive);
        req.setAttribute("countDraft",   countDraft);
        req.setAttribute("currentPage",  currentPage);
        req.setAttribute("totalPages",   totalPages);
        req.setAttribute("pageSize",     pageSize);
        req.setAttribute("totalCount",   total);
        req.setAttribute("fromIdx",      fromIdx + 1);
        req.setAttribute("toIdx",        toIdx);

        req.getRequestDispatcher("/views/workflow/workflow-list.jsp")
                .forward(req, resp);
    }

    private void showDetail(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {

        int id = parseId(req.getParameter("id"));
        Workflow workflow = dao.getWorkflowById(id);

        if (workflow == null) {
            resp.sendRedirect(req.getContextPath() + "/workflows");
            return;
        }

        req.setAttribute("workflow", workflow);
        addReferenceData(req);
        req.getRequestDispatcher("/views/workflow/workflow-detail.jsp")
                .forward(req, resp);
    }

    private void showCreateForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setAttribute("workflow", new Workflow()); // empty object
        req.setAttribute("formAction", "create");
        addReferenceData(req);
        req.getRequestDispatcher("/views/workflow/workflow-form.jsp")
                .forward(req, resp);
    }

    private void showEditForm(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {

        int id = parseId(req.getParameter("id"));
        Workflow workflow = dao.getWorkflowById(id);

        if (workflow == null) {
            resp.sendRedirect(req.getContextPath() + "/workflows");
            return;
        }

        req.setAttribute("workflow", workflow);
        req.setAttribute("formAction", "update");
        addReferenceData(req);
        req.getRequestDispatcher("/views/workflow/workflow-form.jsp")
                .forward(req, resp);
    }

    /**
     * Ticket types used both for SSR data island and the JSON API.
     */
    private static final List<String> TICKET_TYPES
            = List.of("INCIDENT", "SERVICE_REQUEST", "PROBLEM", "CHANGE");

    private void addReferenceData(HttpServletRequest req) {
        req.setAttribute("categories", categoryDAO.getActiveCategories());
        req.setAttribute("ticketTypes", TICKET_TYPES);
        req.setAttribute("priorities", List.of("LOW", "MEDIUM", "HIGH", "CRITICAL"));
    }

    /**
     * GET /workflows?action=api-ticket-types Returns a JSON array of all
     * supported ticket types. Example:
     * ["INCIDENT","SERVICE_REQUEST","PROBLEM","CHANGE"]
     */
    private void sendTicketTypes(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        resp.setHeader("Cache-Control", "max-age=300"); // cache 5 min
        resp.getWriter().print(gson.toJson(TICKET_TYPES));
    }

    // ==================================================================
    // POST handlers
    // ==================================================================
    private void handleCreate(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, IOException, ServletException {

        Workflow w = buildFromRequest(req);

        // Validate
        if (w.getWorkflowName() == null || w.getWorkflowName().isBlank()) {
            req.setAttribute("error", "Workflow name is required.");
            req.setAttribute("workflow", w);
            req.setAttribute("formAction", "create");
            req.getRequestDispatcher("/views/workflow/workflow-form.jsp")
                    .forward(req, resp);
            return;
        }

        // Check duplicate name
        Workflow exists = dao.getWorkflowByName(w.getWorkflowName());
        if (exists != null) {
            req.setAttribute("error", "A workflow with this name already exists.");
            req.setAttribute("workflow", w);
            req.setAttribute("formAction", "create");
            addReferenceData(req);
            req.getRequestDispatcher("/views/workflow/workflow-form.jsp").forward(req, resp);
            return;
        }

        boolean ok = dao.createWorkflow(w);
        if (ok) {
            req.getSession().setAttribute("flashSuccess", "Workflow created successfully.");
        } else {
            req.getSession().setAttribute("flashError", "Failed to create workflow.");
        }
        resp.sendRedirect(req.getContextPath() + "/workflows");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, IOException, ServletException {

        Workflow w = buildFromRequest(req);
        w.setWorkflowId(parseId(req.getParameter("workflowId")));

        if (w.getWorkflowName() == null || w.getWorkflowName().isBlank()) {
            req.setAttribute("error", "Workflow name is required.");
            req.setAttribute("workflow", w);
            req.setAttribute("formAction", "update");
            req.getRequestDispatcher("/views/workflow/workflow-form.jsp")
                    .forward(req, resp);
            return;
        }

        // Check duplicate name (allow same name for the same workflow id)
        Workflow exists = dao.getWorkflowByName(w.getWorkflowName());
        if (exists != null && exists.getWorkflowId() != w.getWorkflowId()) {
            req.setAttribute("error", "A workflow with this name already exists.");
            req.setAttribute("workflow", w);
            req.setAttribute("formAction", "update");
            addReferenceData(req);
            req.getRequestDispatcher("/views/workflow/workflow-form.jsp").forward(req, resp);
            return;
        }

        boolean ok = dao.updateWorkflow(w);
        if (ok) {
            req.getSession().setAttribute("flashSuccess", "Workflow updated successfully.");
        } else {
            req.getSession().setAttribute("flashError", "Failed to update workflow.");
        }
        resp.sendRedirect(req.getContextPath() + "/workflows");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        int id = parseId(req.getParameter("workflowId"));
        if (id <= 0) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"message\":\"Invalid workflow ID.\"}");
            out.flush();
            return;
        }

        try {
            boolean ok = dao.deleteWorkflow(id);
            if (ok) {
                out.print("{\"success\":true,\"message\":\"Workflow deleted.\"}");
            } else {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"success\":false,\"message\":\"Workflow not found or already deleted.\"}");
            }
        } catch (SQLException e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Database error";
            out.print("{\"success\":false,\"message\":\"" + msg + "\"}");
        }
        out.flush();
    }

    private void handleToggle(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        int id = parseId(req.getParameter("workflowId"));
        String newStatus = req.getParameter("newStatus");

        if (id <= 0 || (!"ACTIVE".equals(newStatus) && !"INACTIVE".equals(newStatus))) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"message\":\"Invalid parameters.\"}");
            out.flush();
            return;
        }

        try {
            boolean ok = dao.toggleStatus(id, newStatus);
            if (ok) {
                out.print("{\"success\":true,\"newStatus\":\"" + newStatus + "\"}");
            } else {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"success\":false,\"message\":\"Workflow not found.\"}");
            }
        } catch (SQLException e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Database error";
            out.print("{\"success\":false,\"message\":\"" + msg + "\"}");
        }
        out.flush();
    }

    // ==================================================================
    // Helpers
    // ==================================================================
    private Workflow buildFromRequest(HttpServletRequest req) {
        Workflow w = new Workflow();
        w.setWorkflowName(trim(req.getParameter("workflowName")));
        w.setDescription(trim(req.getParameter("description")));
        w.setStatus(trim(req.getParameter("status")));
        w.setWorkflowConfig(trim(req.getParameter("workflowConfig")));

        String createdByStr = req.getParameter("createdBy");
        if (createdByStr != null && !createdByStr.isBlank()) {
            try {
                w.setCreatedBy(Integer.parseInt(createdByStr.trim()));
            } catch (NumberFormatException ignored) {
            }
        }
        return w;
    }

    private int parseId(String val) {
        if (val == null) {
            return 0;
        }
        try {
            return Integer.parseInt(val.trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private String trim(String val) {
        return val == null ? null : val.trim();
    }
}
