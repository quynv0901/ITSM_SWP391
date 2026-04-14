package com.itserviceflow.controllers;

import com.itserviceflow.daos.ProblemDAO;
import com.itserviceflow.daos.TicketDAO;
import com.itserviceflow.daos.UserDAO;
import com.itserviceflow.models.Comment;
import com.itserviceflow.models.Ticket;
import com.itserviceflow.models.User;
import com.itserviceflow.utils.AuthUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/problem")
public class ProblemController extends HttpServlet {

    private ProblemDAO problemDAO;
    private TicketDAO ticketDAO;

    @Override
    public void init() throws ServletException {
        problemDAO = new ProblemDAO();
        ticketDAO = new TicketDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        if (!AuthUtils.isLoggedIn(request, response)) {
            return;
        }

        User currentUser = AuthUtils.getCurrentUser(request);
        request.setAttribute("currentUser", currentUser);

        switch (action) {
            case "list":
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_MANAGER, AuthUtils.ROLE_TECHNICAL_EXPERT,
                        AuthUtils.ROLE_IT_DIRECTOR)) {
                    return;
                }
                listProblems(request, response);
                break;
            case "detail":
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_MANAGER, AuthUtils.ROLE_TECHNICAL_EXPERT,
                        AuthUtils.ROLE_IT_DIRECTOR)) {
                    return;
                }
                viewProblemDetail(request, response);
                break;
            case "add":
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_MANAGER, AuthUtils.ROLE_TECHNICAL_EXPERT)) {
                    return;
                }
                showProblemForm(request, response);
                break;
            case "edit":
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_MANAGER, AuthUtils.ROLE_TECHNICAL_EXPERT)) {
                    return;
                }
                showEditForm(request, response);
                break;
            default:
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_MANAGER, AuthUtils.ROLE_TECHNICAL_EXPERT,
                        AuthUtils.ROLE_IT_DIRECTOR)) {
                    return;
                }
                listProblems(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/problem?action=list");
            return;
        }

        if (!AuthUtils.isLoggedIn(request, response)) {
            return;
        }

        switch (action) {
            case "insert":
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_MANAGER, AuthUtils.ROLE_TECHNICAL_EXPERT)) {
                    return;
                }
                insertProblem(request, response);
                break;
            case "update":
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_MANAGER, AuthUtils.ROLE_TECHNICAL_EXPERT)) {
                    return;
                }
                updateProblem(request, response);
                break;
            case "delete":
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_MANAGER, AuthUtils.ROLE_TECHNICAL_EXPERT)) {
                    return;
                }
                deleteProblem(request, response);
                break;
            case "bulkDelete":
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_MANAGER, AuthUtils.ROLE_TECHNICAL_EXPERT)) {
                    return;
                }
                bulkDeleteProblem(request, response);
                break;
            case "assign":
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_MANAGER, AuthUtils.ROLE_TECHNICAL_EXPERT)) {
                    return;
                }
                assignProblem(request, response);
                break;
            case "cancel":
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_MANAGER, AuthUtils.ROLE_TECHNICAL_EXPERT)) {
                    return;
                }
                cancelProblem(request, response);
                break;

            case "addComment":
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_MANAGER, AuthUtils.ROLE_TECHNICAL_EXPERT)) {
                    return;
                }
                addComment(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/problem?action=list");
                break;
        }
    }

    private void listProblems(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        String statusFilter = request.getParameter("status");

        int page = 1;
        int pageSize = 5;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        int offset = (page - 1) * pageSize;

        int totalRecords = problemDAO.getTotalProblems(keyword, statusFilter);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);

        List<Ticket> problems = problemDAO.getAllProblems(keyword, statusFilter, offset, pageSize);

        request.setAttribute("problems", problems);
        request.setAttribute("keyword", keyword);
        request.setAttribute("statusFilter", statusFilter != null ? statusFilter : "ALL");
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.getRequestDispatcher("/problem/list.jsp").forward(request, response);
    }

    private void viewProblemDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Ticket problem = problemDAO.getProblemById(id);
        List<Ticket> linkedIncidents = problemDAO.getLinkedIncidents(id);
        List<Comment> comments = problemDAO.getCommentsByTicketId(id);

        UserDAO userDAO = new UserDAO();
        List<User> technicalExperts = userDAO.getUsersByRoleId(AuthUtils.ROLE_TECHNICAL_EXPERT);

        request.setAttribute("problem", problem);
        request.setAttribute("linkedIncidents", linkedIncidents);
        request.setAttribute("comments", comments);
        request.setAttribute("technicalExperts", technicalExperts);
        request.getRequestDispatcher("/problem/detail.jsp").forward(request, response);
    }

    private void showProblemForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = AuthUtils.getCurrentUser(request);
        List<Ticket> incidents = ticketDAO.getIncidentList(currentUser.getUserId(), currentUser.getRoleName());
        
        request.setAttribute("incidents", incidents);
        request.getRequestDispatcher("/problem/form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Ticket problem = problemDAO.getProblemById(id);
        User currentUser = AuthUtils.getCurrentUser(request);

        if (problem == null || !canManageProblem(problem, currentUser)) {
            response.sendRedirect(request.getContextPath() + "/problem?action=detail&id=" + id);
            return;
        }

        List<Ticket> incidents = ticketDAO.getIncidentList(currentUser.getUserId(), currentUser.getRoleName());
        List<Ticket> linkedIncidents = problemDAO.getLinkedIncidents(id);
        
        request.setAttribute("problem", problem);
        request.setAttribute("incidents", incidents);
        request.setAttribute("linkedIncidents", linkedIncidents);
        request.getRequestDispatcher("/problem/form.jsp").forward(request, response);
    }

    private void insertProblem(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String cause = request.getParameter("cause");
        String solution = request.getParameter("solution");

        Ticket problem = new Ticket();
        problem.setTitle(title);
        problem.setDescription(description);
        problem.setCause(cause);
        problem.setSolution(solution);

        User user = AuthUtils.getCurrentUser(request);
        problem.setReportedBy(user.getUserId());

        String[] incidentIdStrs = request.getParameterValues("incidentIds");
        List<Integer> incidentIds = new ArrayList<>();
        if (incidentIdStrs != null) {
            String combined = String.join(",", incidentIdStrs);
            for (String str : combined.split(",")) {
                if (!str.trim().isEmpty()) {
                    try {
                        incidentIds.add(Integer.parseInt(str.trim()));
                    } catch (NumberFormatException ignored) {
                    }
                }
            }
        }

        problemDAO.createProblemTicket(problem, incidentIds, user.getUserId());
        response.sendRedirect(request.getContextPath() + "/problem?action=list");
    }

    private void updateProblem(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));

        Ticket existingProblem = problemDAO.getProblemById(id);
        User currentUser = AuthUtils.getCurrentUser(request);
        if (existingProblem == null || "CANCELLED".equals(existingProblem.getStatus())
                || !canManageProblem(existingProblem, currentUser)) {
            response.sendRedirect(request.getContextPath() + "/problem?action=detail&id=" + id);
            return;
        }

        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String status = request.getParameter("status");
        String cause = request.getParameter("cause");
        String solution = request.getParameter("solution");

        Ticket problem = new Ticket();
        problem.setTicketId(id);
        problem.setTitle(title);
        problem.setDescription(description);
        problem.setStatus(status);
        problem.setCause(cause);
        problem.setSolution(solution);

        problemDAO.updateProblemTicket(problem);

        String[] incidentIdStrs = request.getParameterValues("incidentIds");
        List<Integer> incidentIds = new ArrayList<>();
        if (incidentIdStrs != null) {
            String combined = String.join(",", incidentIdStrs);
            for (String str : combined.split(",")) {
                if (!str.trim().isEmpty()) {
                    try {
                        incidentIds.add(Integer.parseInt(str.trim()));
                    } catch (NumberFormatException ignored) {
                    }
                }
            }
        }
        User user = AuthUtils.getCurrentUser(request);
        problemDAO.updateProblemRelations(id, incidentIds, user.getUserId());

        response.sendRedirect(request.getContextPath() + "/problem?action=detail&id=" + id);
    }

    private void deleteProblem(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Ticket ticket = problemDAO.getProblemById(id);
        User user = AuthUtils.getCurrentUser(request);

        if (ticket != null && "NEW".equals(ticket.getStatus()) && (ticket.getAssignedTo() == null || ticket.getAssignedTo() == 0)) {
            if (ticket.getReportedBy() == user.getUserId() || user.getRoleId() == AuthUtils.ROLE_MANAGER || user.getRoleId() == AuthUtils.ROLE_ADMIN) {
                boolean deleted = problemDAO.deleteProblemTicket(id);
                if (deleted) {
                    request.getSession().setAttribute("message", "Problem ticket deleted successfully.");
                } else {
                    request.getSession().setAttribute("errorMsg", "Failed to delete problem ticket.");
                }
            } else {
                request.getSession().setAttribute("errorMsg", "You can only delete your own problem tickets, unless you are a Manager.");
            }
        } else {
            request.getSession().setAttribute("errorMsg", "Can only delete NEW problem tickets that are unassigned.");
        }

        response.sendRedirect(request.getContextPath() + "/problem?action=list");
    }

    private void bulkDeleteProblem(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String[] ids = request.getParameterValues("selectedIds");
        User user = AuthUtils.getCurrentUser(request);
        int successCount = 0;
        int failCount = 0;

        if (ids != null) {
            for (String idStr : ids) {
                try {
                    int id = Integer.parseInt(idStr);
                    Ticket ticket = problemDAO.getProblemById(id);
                    if (ticket != null && "NEW".equals(ticket.getStatus()) && (ticket.getAssignedTo() == null || ticket.getAssignedTo() == 0)) {
                        if (ticket.getReportedBy() == user.getUserId() || user.getRoleId() == AuthUtils.ROLE_MANAGER || user.getRoleId() == AuthUtils.ROLE_ADMIN) {
                            boolean deleted = problemDAO.deleteProblemTicket(id);
                            if (deleted) {
                                successCount++;
                            } else {
                                failCount++;
                            }
                        } else {
                            failCount++;
                        }
                    } else {
                        failCount++;
                    }
                } catch (NumberFormatException ignored) {
                }
            }
        }
        request.getSession().setAttribute("message", "Bulk Delete execution complete. Success: " + successCount + ". Skipped: " + failCount + " (Rule: Must be NEW, unassigned, and owned by you, or you must be Admin/Manager).");
        response.sendRedirect(request.getContextPath() + "/problem?action=list");
    }

    private void assignProblem(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Ticket existingProblem = problemDAO.getProblemById(id);
        if (existingProblem == null || "CANCELLED".equals(existingProblem.getStatus())
                || "RESOLVED".equals(existingProblem.getStatus())) {
            response.sendRedirect(request.getContextPath() + "/problem?action=detail&id=" + id);
            return;
        }

        int assignedTo = Integer.parseInt(request.getParameter("assignedTo"));

        User currentUser = AuthUtils.getCurrentUser(request);
        if (currentUser.getRoleId() == AuthUtils.ROLE_TECHNICAL_EXPERT) {
            if (assignedTo != currentUser.getUserId()
                    || (existingProblem.getAssignedTo() != null && existingProblem.getAssignedTo() != 0)
                    || existingProblem.getReportedBy() == currentUser.getUserId()) {
                response.sendRedirect(request.getContextPath() + "/problem?action=detail&id=" + id);
                return;
            }
        }

        problemDAO.assignProblemTicket(id, assignedTo);
        response.sendRedirect(request.getContextPath() + "/problem?action=detail&id=" + id);
    }

    private void cancelProblem(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));

        Ticket existingProblem = problemDAO.getProblemById(id);
        User currentUser = AuthUtils.getCurrentUser(request);
        if (existingProblem == null || "CANCELLED".equals(existingProblem.getStatus())
                || "RESOLVED".equals(existingProblem.getStatus())
                || "CLOSED".equals(existingProblem.getStatus())
                || !canManageProblem(existingProblem, currentUser)) {
            response.sendRedirect(request.getContextPath() + "/problem?action=detail&id=" + id);
            return;
        }

        String cancelReason = request.getParameter("cancelReason");
        problemDAO.cancelProblemTicket(id, cancelReason);
        response.sendRedirect(request.getContextPath() + "/problem?action=detail&id=" + id);
    }

    private void addComment(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String commentText = request.getParameter("commentText");

        User user = AuthUtils.getCurrentUser(request);

        Comment comment = new Comment();
        comment.setTicketId(id);
        comment.setUserId(user.getUserId());
        comment.setCommentText(commentText);

        problemDAO.addCommentToProblem(comment);
        response.sendRedirect(request.getContextPath() + "/problem?action=detail&id=" + id);
    }

    private boolean canManageProblem(Ticket problem, User user) {
        if ("CANCELLED".equals(problem.getStatus())) {
            return false;
        }
        if (problem.getAssignedTo() != null) {
            return problem.getAssignedTo().equals(user.getUserId());
        } else {
            return problem.getReportedBy() == user.getUserId();
        }
    }
}
