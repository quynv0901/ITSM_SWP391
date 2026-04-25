package com.itserviceflow.controllers;

import com.itserviceflow.daos.TicketDAO;
import com.itserviceflow.daos.RoleDAO;
import com.itserviceflow.daos.ActivityLogDAO;
import com.itserviceflow.daos.CmdbDAO;
import com.itserviceflow.daos.FeedbackDAO;
import com.itserviceflow.models.Ticket;
import com.itserviceflow.models.User;
import com.itserviceflow.models.ConfigurationItem;
import com.itserviceflow.models.Feedback;
import com.itserviceflow.utils.TimeLogService;
import com.itserviceflow.utils.AuthUtils;
import com.itserviceflow.daos.UserDAO;
import com.itserviceflow.utils.WorkflowService;
import com.itserviceflow.utils.GsonConfig;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@WebServlet("/incident")
public class IncidentController extends HttpServlet {

    private static final Set<String> ALLOWED_PRIORITIES = new HashSet<>(
            Arrays.asList("LOW", "MEDIUM", "HIGH", "CRITICAL")
    );
    private static final Set<String> ALLOWED_STATUSES = new HashSet<>(
            Arrays.asList("NEW", "OPEN", "IN_PROGRESS", "PENDING", "RESOLVED", "CLOSED", "CANCELLED")
    );
    private static final int MAX_SEARCH_LENGTH = 255;

    private TicketDAO ticketDAO;
    private TimeLogService timeLogService;
    private WorkflowService workflowService;

    @Override
    public void init() throws ServletException {
        ticketDAO = new TicketDAO();
        timeLogService = new TimeLogService();
        workflowService = new WorkflowService();
    }

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
            case "suggest":
                suggestSimilarIncidents(request, response);
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
            case "comment":
                addIncidentComment(request, response);
                break;
            case "feedback":
                submitFeedback(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/incident?action=list");
                break;
        }
    }

    private void listIncidents(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Sử dụng thông tin user từ session để lọc ticket cho end-user
        jakarta.servlet.http.HttpSession session = request.getSession();
        com.itserviceflow.models.User user = (com.itserviceflow.models.User) session.getAttribute("user");
        int userId = 0;
        String roleName = "";
        if (user != null) {
            userId = user.getUserId();
            // Nếu chưa có roleName thì lấy từ DB
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
        Integer id = parsePositiveInt(request.getParameter("id"));
        if (id == null) {
            response.sendRedirect(request.getContextPath() + "/incident?action=list");
            return;
        }
        User currentUser = (User) request.getSession().getAttribute("user");
        Ticket incident = ticketDAO.getTicketWithDetails(id);
        if (incident == null) {
            response.sendRedirect(request.getContextPath() + "/incident?action=list");
            return;
        }
        List<Ticket> related = ticketDAO.getRelatedIncidents(id);
        List<com.itserviceflow.models.Comment> comments = ticketDAO.getCommentsByTicketId(id);

        // Load time logs cho ticket này
        com.itserviceflow.daos.TimeLogDAO timeLogDAO = new com.itserviceflow.daos.TimeLogDAO();
        java.util.List<com.itserviceflow.models.TimeLog> timeLogs = timeLogDAO.getLogsByTicketId(id);
        double totalTimeSpent = timeLogDAO.getTotalTimeByTicket(id);

        // Load thông tin category
        com.itserviceflow.daos.TicketCategoryDAO categoryDAO = new com.itserviceflow.daos.TicketCategoryDAO();
        com.itserviceflow.models.TicketCategory category = null;
        if (incident.getCategoryId() != 0) {
            category = categoryDAO.findById(incident.getCategoryId());
        }

        // Load lý do hủy từ activity log
        String cancelReason = null;
        String cancelRejectedReason = null;
        if ("CANCELLED".equals(incident.getStatus())) {
            ActivityLogDAO activityLogDAO = new ActivityLogDAO();
            cancelReason = activityLogDAO.getCancelReason(id);
        }
        // If a user requested cancellation but it was rejected, show them the latest reject reason.
        if (currentUser != null && currentUser.getRoleId() != null
                && currentUser.getRoleId() == AuthUtils.ROLE_END_USER
                && currentUser.getUserId() == incident.getReportedBy()
                && !"PENDING".equalsIgnoreCase(incident.getStatus())
                && !"CANCELLED".equalsIgnoreCase(incident.getStatus())) {
            ActivityLogDAO activityLogDAO = new ActivityLogDAO();
            cancelRejectedReason = activityLogDAO.getLatestReasonByActivityType(id, "CANCEL_REJECTED");
        }

        // Đẩy dữ liệu sang JSP
        request.setAttribute("canCurrentUserEditIncident", canCurrentUserEditIncident(currentUser, incident));
        request.setAttribute("incident", incident);
        request.setAttribute("relatedIncidents", related);
        request.setAttribute("comments", comments);
        request.setAttribute("timeLogs", timeLogs);
        request.setAttribute("totalTimeSpent", totalTimeSpent);
        request.setAttribute("category", category);
        request.setAttribute("cancelReason", cancelReason);
        request.setAttribute("cancelRejectedReason", cancelRejectedReason);
        FeedbackDAO feedbackDAO = new FeedbackDAO();
        Feedback userFeedback = null;
        boolean canGiveFeedback = false;
        if (currentUser != null && currentUser.getRoleId() != null
                && currentUser.getRoleId() == AuthUtils.ROLE_END_USER
                && currentUser.getUserId() == incident.getReportedBy()
                && ("RESOLVED".equalsIgnoreCase(incident.getStatus()) || "CLOSED".equalsIgnoreCase(incident.getStatus()))) {
            userFeedback = feedbackDAO.getFeedbackByTicketAndUser(id, currentUser.getUserId());
            canGiveFeedback = userFeedback == null;
        }
        request.setAttribute("canGiveFeedback", canGiveFeedback);
        request.setAttribute("userFeedback", userFeedback);

        request.getRequestDispatcher("/incidents/incident-detail.jsp").forward(request, response);
    }

    private void showForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Load danh sách category cho dropdown
        com.itserviceflow.daos.TicketCategoryDAO categoryDAO = new com.itserviceflow.daos.TicketCategoryDAO();
        java.util.List<com.itserviceflow.models.TicketCategory> categories = categoryDAO.getActiveCategories();
        request.setAttribute("categories", categories);

        // Load danh sách Configuration Item đang active
        CmdbDAO cmdbDAO = new CmdbDAO();
        List<ConfigurationItem> activeCis = cmdbDAO.searchConfigurationItems(null, "ACTIVE");
        request.setAttribute("activeCis", activeCis);

        request.getRequestDispatcher("/incidents/incident-form.jsp").forward(request, response);
    }

    private void suggestSimilarIncidents(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!AuthUtils.isLoggedIn(request, response)) {
            return;
        }

        String q = normalizeWhitespace(request.getParameter("q"));
        if (q != null && q.length() > MAX_SEARCH_LENGTH) {
            q = q.substring(0, MAX_SEARCH_LENGTH);
        }
        // Search should be readable text: trim spaces, no risky/special control symbols.
        if (q != null && !isValidSearchText(q)) {
            response.setCharacterEncoding(StandardCharsets.UTF_8.name());
            response.setContentType("application/json");
            try (PrintWriter out = response.getWriter()) {
                out.print("[]");
            }
            return;
        }
        Integer categoryId = parsePositiveInt(request.getParameter("categoryId"));
        String mode = request.getParameter("mode"); // "agent" | null
        Integer ticketId = parsePositiveInt(request.getParameter("excludeId"));

        User currentUser = (User) request.getSession().getAttribute("user");
        boolean isEndUser = currentUser != null && currentUser.getRoleId() != null
                && currentUser.getRoleId() == AuthUtils.ROLE_END_USER;
        boolean agentMode = !isEndUser && "agent".equalsIgnoreCase(mode);

        int limit = agentMode ? 10 : 5;
        // End-user: only open incidents; Agent/Expert: include closed/cancelled to check "has it happened before?"
        List<Ticket> suggestions = ticketDAO.suggestSimilarIncidents(q, categoryId, limit, ticketId, agentMode);

        // Return only minimal fields; agentMode can include a bit more metadata.
        List<java.util.Map<String, Object>> payload = suggestions.stream().map(t -> {
            java.util.Map<String, Object> m = new java.util.HashMap<>();
            m.put("ticketId", t.getTicketId());
            m.put("ticketNumber", t.getTicketNumber());
            m.put("title", t.getTitle());
            m.put("status", t.getStatus());
            m.put("createdAt", t.getCreatedAt());
            if (agentMode) {
                m.put("priority", t.getPriority());
            }
            return m;
        }).collect(Collectors.toList());

        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.setContentType("application/json");
        try (PrintWriter out = response.getWriter()) {
            out.print(GsonConfig.getGson().toJson(payload));
        }
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Integer id = parsePositiveInt(request.getParameter("id"));
        if (id == null) {
            response.sendRedirect(request.getContextPath() + "/incident?action=list");
            return;
        }
        Ticket incident = ticketDAO.getIncidentById(id);
        if (incident == null) {
            response.sendRedirect(request.getContextPath() + "/incident?action=list");
            return;
        }
        User currentUser = (User) request.getSession().getAttribute("user");
        if (!canCurrentUserEditIncident(currentUser, incident)) {
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + id + "&editError=locked");
            return;
        }

        // Load danh sách category cho dropdown
        com.itserviceflow.daos.TicketCategoryDAO categoryDAO = new com.itserviceflow.daos.TicketCategoryDAO();
        java.util.List<com.itserviceflow.models.TicketCategory> categories = categoryDAO.getActiveCategories();
        request.setAttribute("categories", categories);

        request.setAttribute("isEndUserEditingOwnTicket",
                currentUser != null && currentUser.getRoleId() != null
                && currentUser.getRoleId() == AuthUtils.ROLE_END_USER
                && currentUser.getUserId() == incident.getReportedBy());
        request.setAttribute("incident", incident);
        request.getRequestDispatcher("/incidents/incident-form.jsp").forward(request, response);
    }

    private void insertIncident(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String title = normalizeWhitespace(request.getParameter("title"));
        String description = normalizeWhitespace(request.getParameter("description"));
        String priority = trimToNull(request.getParameter("priority"));
        Integer categoryId = parsePositiveInt(request.getParameter("categoryId"));

        if (title == null) {
            response.sendRedirect(request.getContextPath() + "/incident?action=add&error=missingTitle");
            return;
        }
        if (description == null) {
            response.sendRedirect(request.getContextPath() + "/incident?action=add&error=missingDescription");
            return;
        }
        if (categoryId == null) {
            response.sendRedirect(request.getContextPath() + "/incident?action=add&error=invalidCategory");
            return;
        }
        if (!isValidPriority(priority)) {
            response.sendRedirect(request.getContextPath() + "/incident?action=add&error=invalidPriority");
            return;
        }
        if (!isValidTextOnly(title)) {
            response.sendRedirect(request.getContextPath() + "/incident?action=add&error=invalidTitleFormat");
            return;
        }
        if (!isValidTextOnly(description)) {
            response.sendRedirect(request.getContextPath() + "/incident?action=add&error=invalidDescriptionFormat");
            return;
        }

        // Lấy user đang đăng nhập
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        int creatorId = (currentUser != null) ? currentUser.getUserId() : 1;

        Ticket incident = new Ticket();
        incident.setTitle(title);
        incident.setDescription(description);
        incident.setPriority(priority.toUpperCase());
        incident.setCategoryId(categoryId);
        incident.setReportedBy(creatorId);
        incident.setTicketType("INCIDENT");

        String relatedIdsStr = request.getParameter("relatedIds");
        List<Integer> relatedIds = parseRelatedIncidentIds(relatedIdsStr);

        boolean created = ticketDAO.createIncidentTicket(incident, creatorId);
        if (created && incident.getTicketId() > 0) {
            Ticket full = ticketDAO.getTicketWithDetails(incident.getTicketId());
            if (full != null) {
                // Bỏ qua auto-log nếu là End-user
                if (currentUser == null || currentUser.getRoleId() == null || currentUser.getRoleId() != AuthUtils.ROLE_END_USER) {
                    timeLogService.autoLog(full, creatorId, "INVESTIGATION");
                }
                // Tự động áp dụng workflow
                workflowService.onTicketCreated(full);
            }
        }
        if (!relatedIds.isEmpty()) {
            ticketDAO.linkRelatedIncidents(incident.getTicketId(), relatedIds, creatorId);
        }
        response.sendRedirect(request.getContextPath() + "/incident?action=list");
    }

    private void updateIncident(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Integer id = parsePositiveInt(request.getParameter("id"));
        String title = normalizeWhitespace(request.getParameter("title"));
        String description = normalizeWhitespace(request.getParameter("description"));
        String newStatus = trimToNull(request.getParameter("status"));
        String priority = trimToNull(request.getParameter("priority"));
        Integer categoryId = parsePositiveInt(request.getParameter("categoryId"));

        if (id == null || title == null || description == null || categoryId == null
                || !isValidPriority(priority) || !isValidStatus(newStatus)) {
            response.sendRedirect(request.getContextPath() + "/incident?action=list&error=invalidInput");
            return;
        }
        if (!isValidTextOnly(title) || !isValidTextOnly(description)) {
            response.sendRedirect(request.getContextPath() + "/incident?action=edit&id=" + id + "&error=invalidTextFormat");
            return;
        }

        // Lấy trạng thái cũ để kiểm tra thay đổi
        Ticket existing = ticketDAO.getTicketWithDetails(id);
        if (existing == null) {
            response.sendRedirect(request.getContextPath() + "/incident?action=list&error=notFound");
            return;
        }

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (!canCurrentUserEditIncident(currentUser, existing)) {
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + id + "&editError=locked");
            return;
        }
        String oldStatus = (existing != null) ? existing.getStatus() : "";

        Ticket incident = new Ticket();
        incident.setTicketId(id);
        incident.setTitle(title);
        incident.setDescription(description);
        incident.setStatus(newStatus.toUpperCase());
        incident.setPriority(priority.toUpperCase());
        incident.setCategoryId(categoryId);

        ticketDAO.updateIncidentTicket(incident);

        // Auto-log khi thay đổi trạng thái
        int agentId = (currentUser != null) ? currentUser.getUserId() : 1;

        if (existing != null && newStatus != null && !newStatus.equals(oldStatus)) {
            HttpSession session2 = request.getSession();
            User currentUser2 = (User) session2.getAttribute("user");
            boolean isEndUserActor = (currentUser2 != null && currentUser2.getRoleId() != null
                    && currentUser2.getRoleId() == AuthUtils.ROLE_END_USER);
            if (!isEndUserActor) {
                if ("RESOLVED".equals(newStatus)) {
                    timeLogService.autoLog(existing, agentId, "RESOLVED");
                } else if ("CLOSED".equals(newStatus)) {
                    timeLogService.autoLog(existing, agentId, "CLOSED");
                }
            }
        }
        response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + id);
    }

    private void deleteIncident(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Integer id = parsePositiveInt(request.getParameter("id"));
        if (id == null) {
            response.sendRedirect(request.getContextPath() + "/incident?action=list&error=invalidId");
            return;
        }
        ticketDAO.deleteIncidentTicket(id);
        response.sendRedirect(request.getContextPath() + "/incident?action=list");
    }

    private void cancelIncident(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Integer id = parsePositiveInt(request.getParameter("id"));
        if (id == null) {
            response.sendRedirect(request.getContextPath() + "/incident?action=list&error=invalidId");
            return;
        }
        String cancelReason = request.getParameter("cancelReason");

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        int userId = (currentUser != null) ? currentUser.getUserId() : 1;
        Integer roleId = (currentUser != null) ? currentUser.getRoleId() : null;

        // End-user: only REQUEST cancellation, not cancel immediately
        boolean isEndUser = roleId != null && roleId == AuthUtils.ROLE_END_USER;
        if (isEndUser) {
            boolean requested = ticketDAO.requestCancelIncidentTicket(id, userId);
            if (requested) {
                String reason = (cancelReason != null && !cancelReason.trim().isEmpty())
                        ? normalizeWhitespace(cancelReason)
                        : "User requested cancellation";
                ActivityLogDAO activityLogDAO = new ActivityLogDAO();
                activityLogDAO.logActivity(id, userId, "CANCEL_REQUESTED", reason);
                response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + id);
            } else {
                // Most common cause: DB status constraint doesn't allow CANCEL_REQUESTED
                response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + id + "&error=cancelRequestFailed");
            }
            return;
        }

        // Agent/Expert/Admin: approve or reject cancellation request
        String decision = request.getParameter("cancelDecision");
        ActivityLogDAO activityLogDAO = new ActivityLogDAO();
        String reason = (cancelReason != null && !cancelReason.trim().isEmpty())
                ? normalizeWhitespace(cancelReason) : null;

        // Require reason for any non-end-user cancellation action
        if (reason == null) {
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + id + "&error=missingCancelReason");
            return;
        }
        if (reason.length() < 5 || reason.length() > 500 || !isSafeText(reason)) {
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + id + "&error=invalidCancelReason");
            return;
        }

        // If no decision is provided, treat it as a direct cancel by agent/expert/admin
        if (decision == null || decision.trim().isEmpty() || "REQUEST".equalsIgnoreCase(decision)) {
            boolean cancelled = ticketDAO.cancelIncidentTicket(id);
            if (cancelled) {
                activityLogDAO.logActivity(id, userId, "CANCELLED", reason);
                Ticket ticket = ticketDAO.getTicketWithDetails(id);
                if (ticket != null) {
                    timeLogService.autoLogWithReason(ticket, userId, "CANCELLED", reason);
                }
            }
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + id);
            return;
        }

        boolean ok;
        if ("APPROVE".equalsIgnoreCase(decision)) {
            ok = ticketDAO.approveCancelIncidentTicket(id);
            if (ok) {
                activityLogDAO.logActivity(id, userId, "CANCEL_APPROVED", reason);
                Ticket ticket = ticketDAO.getTicketWithDetails(id);
                if (ticket != null) {
                    timeLogService.autoLogWithReason(ticket, userId, "CANCELLED", reason);
                }
            }
        } else if ("REJECT".equalsIgnoreCase(decision)) {
            ok = ticketDAO.rejectCancelIncidentTicket(id);
            if (ok) {
                activityLogDAO.logActivity(id, userId, "CANCEL_REJECTED", reason);
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + id + "&error=invalidDecision");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + id);
    }

    private void assignIncident(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Integer id = parsePositiveInt(request.getParameter("id"));
        Integer assignedTo = parsePositiveInt(request.getParameter("assignedTo"));
        if (id == null || assignedTo == null) {
            response.sendRedirect(request.getContextPath() + "/incident?action=list&error=invalidInput");
            return;
        }
        User currentUser = (User) request.getSession().getAttribute("user");
        if (currentUser == null || currentUser.getRoleId() == null
                || currentUser.getRoleId() == AuthUtils.ROLE_END_USER) {
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + id + "&error=forbidden");
            return;
        }
        Ticket existing = ticketDAO.getTicketWithDetails(id);
        if (existing == null || "CLOSED".equalsIgnoreCase(existing.getStatus())
                || "CANCELLED".equalsIgnoreCase(existing.getStatus())) {
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + id + "&error=invalidState");
            return;
        }
        UserDAO userDAO = new UserDAO();
        User assignee = userDAO.findById(assignedTo);
        if (assignee == null || assignee.getRoleId() == null
                || assignee.getRoleId() == AuthUtils.ROLE_END_USER) {
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + id + "&error=invalidAssignee");
            return;
        }
        ticketDAO.assignIncidentTicket(id, assignedTo);

        Ticket ticket = ticketDAO.getTicketWithDetails(id);
        if (ticket != null) {
            if (assignee == null || assignee.getRoleId() == null || assignee.getRoleId() != AuthUtils.ROLE_END_USER) {
                timeLogService.autoLog(ticket, assignedTo, "ASSIGNED");
            }
        }
        response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + id);
    }

    private void categorizeIncident(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Integer id = parsePositiveInt(request.getParameter("id"));
        Integer categoryId = parsePositiveInt(request.getParameter("categoryId"));
        if (id == null || categoryId == null) {
            response.sendRedirect(request.getContextPath() + "/incident?action=list&error=invalidInput");
            return;
        }
        ticketDAO.categorizeIncidentTicket(id, categoryId);
        response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + id);
    }

    private void linkIncident(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Integer id = parsePositiveInt(request.getParameter("id"));
        if (id == null) {
            response.sendRedirect(request.getContextPath() + "/incident?action=list&error=invalidId");
            return;
        }
        String relatedIdsStr = request.getParameter("relatedIds");
        List<Integer> relatedIds = parseRelatedIncidentIds(relatedIdsStr);
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        int userId = (currentUser != null) ? currentUser.getUserId() : 1;
        ticketDAO.linkRelatedIncidents(id, relatedIds, userId);
        response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + id);
    }

    /**
     * Xử lý ghi thời gian thủ công từ form chi tiết ticket
     */
    private void manualLogTime(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Integer ticketId = parsePositiveInt(request.getParameter("id"));
        if (ticketId == null) {
            response.sendRedirect(request.getContextPath() + "/incident?action=list&error=invalidId");
            return;
        }
        double timeSpent;
        try {
            timeSpent = Double.parseDouble(request.getParameter("timeSpent"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + ticketId + "&logError=invalidTime");
            return;
        }
        if (timeSpent <= 0 || timeSpent > 24) {
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + ticketId + "&logError=invalidTime");
            return;
        }
        String description = normalizeWhitespace(request.getParameter("logDescription"));
        if (description == null || description.length() < 5 || description.length() > 500 || !isSafeText(description)) {
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + ticketId + "&logError=invalidDescription");
            return;
        }

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        int agentId = (currentUser != null) ? currentUser.getUserId() : 1;

        // Không cho End-user ghi log thủ công
        if (currentUser != null && currentUser.getRoleId() != null && currentUser.getRoleId() == AuthUtils.ROLE_END_USER) {
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + ticketId + "&logError=forbidden");
            return;
        }

        boolean saved = timeLogService.manualLog(ticketId, agentId, timeSpent, description);
        String param = saved ? "&logSuccess=1" : "&logError=saveFailed";
        response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + ticketId + param);
    }

    private void addIncidentComment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Integer ticketId = parsePositiveInt(request.getParameter("id"));
        if (ticketId == null) {
            response.sendRedirect(request.getContextPath() + "/incident?action=list&commentError=invalidId");
            return;
        }
        User currentUser = (User) request.getSession().getAttribute("user");
        if (currentUser == null || currentUser.getRoleId() == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }
        if (currentUser.getRoleId() == AuthUtils.ROLE_END_USER) {
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + ticketId + "&commentError=forbidden");
            return;
        }
        Ticket incident = ticketDAO.getTicketWithDetails(ticketId);
        if (incident == null || !"INCIDENT".equalsIgnoreCase(incident.getTicketType())) {
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + ticketId + "&commentError=notFound");
            return;
        }

        String commentText = normalizeWhitespace(request.getParameter("commentText"));
        if (commentText == null || commentText.length() < 2 || commentText.length() > 1000 || !isSafeText(commentText)) {
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + ticketId + "&commentError=invalidText");
            return;
        }

        boolean saved = ticketDAO.addComment(ticketId, currentUser.getUserId(), commentText);
        response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + ticketId
                + (saved ? "&commentSuccess=1" : "&commentError=saveFailed"));
    }

    private void submitFeedback(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Integer ticketId = parsePositiveInt(request.getParameter("id"));
        if (ticketId == null) {
            response.sendRedirect(request.getContextPath() + "/incident?action=list&feedbackError=invalidId");
            return;
        }

        User currentUser = (User) request.getSession().getAttribute("user");
        if (currentUser == null || currentUser.getRoleId() == null || currentUser.getRoleId() != AuthUtils.ROLE_END_USER) {
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + ticketId + "&feedbackError=forbidden");
            return;
        }

        Ticket incident = ticketDAO.getTicketWithDetails(ticketId);
        if (incident == null || !"INCIDENT".equalsIgnoreCase(incident.getTicketType())) {
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + ticketId + "&feedbackError=notFound");
            return;
        }
        if (incident.getReportedBy() != currentUser.getUserId()) {
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + ticketId + "&feedbackError=forbidden");
            return;
        }
        String status = incident.getStatus() == null ? "" : incident.getStatus().toUpperCase();
        if (!"RESOLVED".equals(status) && !"CLOSED".equals(status)) {
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + ticketId + "&feedbackError=invalidState");
            return;
        }

        String ratingRaw = trimToNull(request.getParameter("rating"));
        if (ratingRaw == null || !ratingRaw.matches("^[1-5]$")) {
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + ticketId + "&feedbackError=invalidRating");
            return;
        }
        int rating = Integer.parseInt(ratingRaw);

        String feedbackText = normalizeWhitespace(request.getParameter("feedbackText"));
        if (!isValidFeedbackText(feedbackText)) {
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + ticketId + "&feedbackError=invalidText");
            return;
        }

        FeedbackDAO feedbackDAO = new FeedbackDAO();
        if (feedbackDAO.hasFeedback(ticketId, currentUser.getUserId())) {
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + ticketId + "&feedbackError=exists");
            return;
        }

        Feedback feedback = new Feedback();
        feedback.setTicketId(ticketId);
        feedback.setUserId(currentUser.getUserId());
        feedback.setAgentId(incident.getAssignedTo());
        feedback.setRating(rating);
        feedback.setFeedbackText(feedbackText);

        boolean saved = feedbackDAO.saveFeedback(feedback);
        response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + ticketId
                + (saved ? "&feedbackSuccess=1" : "&feedbackError=saveFailed"));
    }

    private boolean isValidFeedbackText(String value) {
        if (value == null) {
            return false;
        }
        if (value.length() < 5 || value.length() > 250) {
            return false;
        }
        if (!isSafeText(value)) {
            return false;
        }
        // Allow natural-language feedback with common punctuation; block noisy/suspicious payloads.
        return value.matches("^[\\p{L}\\p{N}\\s.,!?;:'\"()\\-_/]+$");
    }

    private Integer parsePositiveInt(String raw) {
        if (raw == null || raw.trim().isEmpty()) {
            return null;
        }
        try {
            int value = Integer.parseInt(raw.trim());
            return value > 0 ? value : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String trimToNull(String raw) {
        if (raw == null) {
            return null;
        }
        String value = raw.trim();
        return value.isEmpty() ? null : value;
    }

    private String normalizeWhitespace(String raw) {
        if (raw == null) {
            return null;
        }
        String normalized = raw.trim().replaceAll("\\s+", " ");
        return normalized.isEmpty() ? null : normalized;
    }

    /**
     * Accepts both numeric ticket_id and ticket number (e.g. INC-2026-0012).
     */
    private List<Integer> parseRelatedIncidentIds(String raw) {
        List<Integer> ids = new ArrayList<>();
        if (raw == null || raw.trim().isEmpty()) {
            return ids;
        }
        java.util.Set<Integer> unique = new java.util.LinkedHashSet<>();
        for (String token : raw.split(",")) {
            String value = token == null ? "" : token.trim();
            if (value.isEmpty()) {
                continue;
            }
            Integer id = parsePositiveInt(value);
            if (id != null) {
                unique.add(id);
                continue;
            }
            Integer resolvedId = ticketDAO.findIncidentIdByTicketNumber(value);
            if (resolvedId != null && resolvedId > 0) {
                unique.add(resolvedId);
            }
        }
        ids.addAll(unique);
        return ids;
    }

    private boolean isValidPriority(String priority) {
        return priority != null && ALLOWED_PRIORITIES.contains(priority.toUpperCase());
    }

    private boolean isValidStatus(String status) {
        return status != null && ALLOWED_STATUSES.contains(status.toUpperCase());
    }

    private boolean isValidTextOnly(String value) {
        return value != null && value.matches("^[\\p{L} ]+$");
    }

    private boolean isSafeText(String value) {
        if (value == null) {
            return false;
        }
        String lowered = value.toLowerCase();
        return !lowered.contains("<script")
                && !lowered.contains("</script>")
                && !lowered.contains("javascript:");
    }

    private boolean isValidSearchText(String value) {
        if (value == null || value.isBlank()) {
            return true;
        }
        // Allow letters/numbers/space and common separators in incident text search.
        return value.matches("^[\\p{L}\\p{N}\\s\\-_/.,:()]+$");
    }

    private boolean canCurrentUserEditIncident(User currentUser, Ticket incident) {
        if (incident == null || currentUser == null || currentUser.getRoleId() == null) {
            return false;
        }
        boolean isEndUser = currentUser.getRoleId() == AuthUtils.ROLE_END_USER;
        if (!isEndUser) {
            return true;
        }

        boolean isReporter = currentUser.getUserId() == incident.getReportedBy();
        if (!isReporter) {
            return false;
        }

        // End-user chỉ bị khóa sửa khi ticket đã ở IN_PROGRESS hoặc RESOLVED.
        String status = incident.getStatus();
        return !"IN_PROGRESS".equalsIgnoreCase(status) && !"RESOLVED".equalsIgnoreCase(status);
    }

    /**
     * Lấy thống kê Feedback cho Dashboard
     */
    private void getFeedbackStats(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        FeedbackDAO feedbackDAO = new FeedbackDAO();

        int totalFeedback = feedbackDAO.getTotalFeedbackCount();
        request.setAttribute("feedbackTotal", totalFeedback);

        int satisfiedCount = feedbackDAO.getSatisfiedFeedbackCount();
        request.setAttribute("satisfiedCount", satisfiedCount);

        double csatScore = 0.0;
        if (totalFeedback > 0) {
            csatScore = (satisfiedCount * 100.0) / totalFeedback;
        }
        request.setAttribute("csatScore", csatScore);

        java.util.Map<String, Integer> feedbackByAgent = feedbackDAO.getFeedbackCountByAgent();
        request.setAttribute("feedbackByAgent", feedbackByAgent);

        java.util.Map<String, Integer> feedbackByTime = feedbackDAO.getFeedbackCountByTime();
        request.setAttribute("feedbackByTime", feedbackByTime);
    }
}
