package com.itserviceflow.controllers;

import com.itserviceflow.daos.TicketDAO;
import com.itserviceflow.daos.RoleDAO;
import com.itserviceflow.daos.ActivityLogDAO;
import com.itserviceflow.daos.CmdbDAO;
import com.itserviceflow.daos.FeedbackDAO;
import com.itserviceflow.models.Ticket;
import com.itserviceflow.models.User;
import com.itserviceflow.models.ConfigurationItem;
import com.itserviceflow.utils.TimeLogService;
import com.itserviceflow.utils.AuthUtils;
import com.itserviceflow.daos.UserDAO;
import com.itserviceflow.utils.WorkflowService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@WebServlet("/incident")
public class IncidentController extends HttpServlet {

    private static final Set<String> ALLOWED_PRIORITIES = new HashSet<>(
            Arrays.asList("LOW", "MEDIUM", "HIGH", "CRITICAL")
    );
    private static final Set<String> ALLOWED_STATUSES = new HashSet<>(
            Arrays.asList("NEW", "OPEN", "IN_PROGRESS", "RESOLVED", "CLOSED", "CANCELLED")
    );

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
        Ticket incident = ticketDAO.getTicketWithDetails(id);
        if (incident == null) {
            response.sendRedirect(request.getContextPath() + "/incident?action=list");
            return;
        }
        List<Ticket> related = ticketDAO.getRelatedIncidents(id);

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
        if ("CANCELLED".equals(incident.getStatus())) {
            ActivityLogDAO activityLogDAO = new ActivityLogDAO();
            cancelReason = activityLogDAO.getCancelReason(id);
        }

        // Đẩy dữ liệu sang JSP
        User currentUser = (User) request.getSession().getAttribute("user");
        request.setAttribute("canCurrentUserEditIncident", canCurrentUserEditIncident(currentUser, incident));
        request.setAttribute("incident", incident);
        request.setAttribute("relatedIncidents", related);
        request.setAttribute("timeLogs", timeLogs);
        request.setAttribute("totalTimeSpent", totalTimeSpent);
        request.setAttribute("category", category);
        request.setAttribute("cancelReason", cancelReason);

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

        ticketDAO.cancelIncidentTicket(id);

        if (cancelReason != null && !cancelReason.trim().isEmpty()) {
            ActivityLogDAO activityLogDAO = new ActivityLogDAO();
            activityLogDAO.logActivity(id, userId, "CANCELLED", cancelReason);

            Ticket ticket = ticketDAO.getTicketWithDetails(id);
            if (ticket != null) {
                HttpSession session2 = request.getSession();
                User currentUser2 = (User) session2.getAttribute("user");
                if (currentUser2 == null || currentUser2.getRoleId() == null || currentUser2.getRoleId() != AuthUtils.ROLE_END_USER) {
                    timeLogService.autoLogWithReason(ticket, userId, "CANCELLED", cancelReason);
                }
            }
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
        ticketDAO.assignIncidentTicket(id, assignedTo);

        Ticket ticket = ticketDAO.getTicketWithDetails(id);
        if (ticket != null) {
            UserDAO userDAO = new UserDAO();
            User assignee = userDAO.findById(assignedTo);
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
        if (timeSpent <= 0) {
            response.sendRedirect(request.getContextPath() + "/incident?action=detail&id=" + ticketId + "&logError=invalidTime");
            return;
        }
        String description = request.getParameter("logDescription");

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

    private boolean isValidPriority(String priority) {
        return priority != null && ALLOWED_PRIORITIES.contains(priority.toUpperCase());
    }

    private boolean isValidStatus(String status) {
        return status != null && ALLOWED_STATUSES.contains(status.toUpperCase());
    }

    private boolean isValidTextOnly(String value) {
        return value != null && value.matches("^[\\p{L} ]+$");
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
