package com.itserviceflow.controllers;

import com.itserviceflow.daos.TimeLogDAO;
import com.itserviceflow.daos.UserDAO;
import com.itserviceflow.models.TimeLog;
import com.itserviceflow.models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Handles the Time Tracking module.
 *
 * GET /time-tracking → list all logs (filterable, paginated) POST
 * /time-tracking?action=update → update a log entry POST
 * /time-tracking?action=delete → delete a log entry
 */
@WebServlet("/time-tracking")
public class TimeTrackingController extends HttpServlet {

    private static final int PAGE_SIZE = 15;

    private TimeLogDAO timeLogDAO;

    @Override
    public void init() throws ServletException {
        timeLogDAO = new TimeLogDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // --- Filter params ---
        String ticketIdStr = request.getParameter("ticketId");
        String userIdStr = request.getParameter("userId");
        String dateFrom = request.getParameter("dateFrom");
        String dateTo = request.getParameter("dateTo");
        String activityType = request.getParameter("activityType");
    String pageStr = request.getParameter("page");
    String pageSizeStr = request.getParameter("pageSize");

    Integer ticketId = parseIntOrNull(ticketIdStr);
    Integer userId = parseIntOrNull(userIdStr);
    int page = (pageStr != null && !pageStr.isEmpty()) ? Math.max(1, Integer.parseInt(pageStr)) : 1;
    // allow client to request page size; fallback to default PAGE_SIZE
    int pageSize = (pageSizeStr != null && !pageSizeStr.isEmpty()) ? Math.max(1, Integer.parseInt(pageSizeStr)) : PAGE_SIZE;
    int offset = (page - 1) * pageSize;

        // --- Fetch data ---
    List<TimeLog> logs = timeLogDAO.getAllLogs(ticketId, userId, dateFrom, dateTo, activityType, offset, pageSize);
    int totalCount = timeLogDAO.countAllLogs(ticketId, userId, dateFrom, dateTo, activityType);
    int totalPages = (int) Math.ceil((double) totalCount / pageSize);

        // total hours for filtered result (sum from full result set without pagination)
        double filteredHours = 0;
        // Fetch all (no limit) just to sum - only do for small counts; otherwise sum in SQL
        List<TimeLog> allFiltered = timeLogDAO.getAllLogs(ticketId, userId, dateFrom, dateTo, activityType, 0, Integer.MAX_VALUE);
        for (TimeLog l : allFiltered) {
            filteredHours += l.getTimeSpent();
        }

        // --- User list for filter dropdown ---
        UserDAO userDAO = new UserDAO();
        List<User> users = userDAO.listUsers(null, null, null, "full_name", "ASC", 0, 200);

    // --- Pass to JSP ---
        request.setAttribute("logs", logs);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentPage", page);
    request.setAttribute("pageSize", pageSize);
        request.setAttribute("filteredHours", filteredHours);
        request.setAttribute("users", users);

        // pass back filter params for sticky form
    request.setAttribute("fTicketId", ticketIdStr != null ? ticketIdStr : "");
        request.setAttribute("fUserId", userIdStr != null ? userIdStr : "");
        request.setAttribute("fDateFrom", dateFrom != null ? dateFrom : "");
        request.setAttribute("fDateTo", dateTo != null ? dateTo : "");
        request.setAttribute("fActivity", activityType != null ? activityType : "");
    request.setAttribute("fPageSize", pageSizeStr != null ? pageSizeStr : String.valueOf(pageSize));

        request.getRequestDispatcher("/time-tracking/time-tracking.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String action = request.getParameter("action");
        if (action == null) {
            action = "";
        }

        switch (action) {
            case "update":
                handleUpdate(request, response);
                break;
            case "delete":
                handleDelete(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/time-tracking");
        }
    }

    // -----------------------------------------------------------------------
    private void handleUpdate(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int logId = parseIntOrZero(request.getParameter("logId"));
        String backUrl = buildBackUrl(request);

        if (logId <= 0) {
            response.sendRedirect(backUrl + "&updateError=invalidId");
            return;
        }

        // Permission: only creator or Manager/Admin
        TimeLog existing = timeLogDAO.getLogById(logId);
        if (existing == null) {
            response.sendRedirect(backUrl + "&updateError=notFound");
            return;
        }

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (!canEdit(currentUser, existing.getUserId())) {
            response.sendRedirect(backUrl + "&updateError=unauthorized");
            return;
        }

        double timeSpent;
        try {
            timeSpent = Double.parseDouble(request.getParameter("timeSpent"));
            if (timeSpent <= 0 || timeSpent > 999.99) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(backUrl + "&updateError=invalidTime");
            return;
        }

        String description = request.getParameter("description");
        boolean ok = timeLogDAO.updateLog(logId, timeSpent, description);
        response.sendRedirect(backUrl + (ok ? "&updateSuccess=1" : "&updateError=saveFailed"));
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int logId = parseIntOrZero(request.getParameter("logId"));
        String backUrl = buildBackUrl(request);

        if (logId <= 0) {
            response.sendRedirect(backUrl + "&deleteError=invalidId");
            return;
        }

        TimeLog existing = timeLogDAO.getLogById(logId);
        if (existing == null) {
            response.sendRedirect(backUrl + "&deleteError=notFound");
            return;
        }

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (!canEdit(currentUser, existing.getUserId())) {
            response.sendRedirect(backUrl + "&deleteError=unauthorized");
            return;
        }

        boolean ok = timeLogDAO.deleteLog(logId);
        response.sendRedirect(backUrl + (ok ? "&deleteSuccess=1" : "&deleteError=failed"));
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------
    /**
     * Builds a redirect URL back to the list, preserving filter params.
     */
    private String buildBackUrl(HttpServletRequest request) {
        String ctx = request.getContextPath();
        StringBuilder sb = new StringBuilder(ctx + "/time-tracking?_=1");
        appendIfPresent(sb, request, "ticketId");
        appendIfPresent(sb, request, "userId");
        appendIfPresent(sb, request, "dateFrom");
        appendIfPresent(sb, request, "dateTo");
        appendIfPresent(sb, request, "activityType");
        appendIfPresent(sb, request, "page");
        appendIfPresent(sb, request, "pageSize");
        return sb.toString();
    }

    private void appendIfPresent(StringBuilder sb, HttpServletRequest req, String param) {
        String val = req.getParameter(param);
        if (val != null && !val.isEmpty()) {
            sb.append("&").append(param).append("=").append(val);
        }
    }

    /**
     * Returns true if the current user can edit/delete the given log entry.
     * Allowed: the creator of the log, or any Manager / Administrator.
     */
    private boolean canEdit(User currentUser, int logOwnerId) {
        if (currentUser == null) {
            return false;
        }
        if (currentUser.getUserId() == logOwnerId) {
            return true;
        }
        String role = currentUser.getRoleName();
        return role != null && (role.equalsIgnoreCase("Manager") || role.equalsIgnoreCase("Administrator")
                || role.equalsIgnoreCase("Admin"));
    }

    private Integer parseIntOrNull(String s) {
        if (s == null || s.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.parseInt(s.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private int parseIntOrZero(String s) {
        if (s == null || s.trim().isEmpty()) {
            return 0;
        }
        try {
            return Integer.parseInt(s.trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }
}
