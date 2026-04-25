package com.itserviceflow.controllers;

import com.itserviceflow.daos.SlaDashboardDAO;
import com.itserviceflow.utils.AuthUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

@WebServlet("/sla-dashboard")
public class SlaDashboardServlet extends HttpServlet {

    private static final int DEFAULT_RESPONSE_HOURS = 48;
    private static final int MIN_RESPONSE_HOURS = 1;
    private static final int MAX_RESPONSE_HOURS = 24 * 14; // 14 days
    private static final int DEFAULT_STAFF_LIMIT = 20;
    private static final int DEFAULT_OVERDUE_LIMIT = 20;
    private static final int DEFAULT_PAGE = 1;
    private static final int DEFAULT_PAGE_SIZE = 10;
    private static final int MIN_LIMIT = 1;
    private static final int MAX_LIMIT = 100;
    private static final int MAX_PAGE_SIZE = 50;
    private static final String VIEW_OVERVIEW = "overview";
    private static final String VIEW_PERFORMANCE = "performance";
    private static final String VIEW_ESCALATION = "escalation";
    private static final String VIEW_MATRIX = "matrix";
    private static final String VIEW_FEEDBACK = "feedback";

    private final SlaDashboardDAO slaDashboardDAO = new SlaDashboardDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!AuthUtils.hasRole(request, response,
                AuthUtils.ROLE_MANAGER,
                AuthUtils.ROLE_ADMIN)) {
            return;
        }

        String action = trimToNull(request.getParameter("action"));
        if (action != null && !"impact-urgency-template".equalsIgnoreCase(action)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unsupported action");
            return;
        }
        if ("impact-urgency-template".equalsIgnoreCase(action)) {
            exportImpactUrgencyTemplate(response);
            return;
        }

        String view = normalizeView(request.getParameter("view"));
        BoundedInt responseHoursInput = parseBoundedInt(
                request.getParameter("responseHours"),
                DEFAULT_RESPONSE_HOURS,
                MIN_RESPONSE_HOURS,
                MAX_RESPONSE_HOURS);
        BoundedInt staffLimitInput = parseBoundedInt(
                request.getParameter("staffLimit"),
                DEFAULT_STAFF_LIMIT,
                MIN_LIMIT,
                MAX_LIMIT);
        BoundedInt overdueLimitInput = parseBoundedInt(
                request.getParameter("overdueLimit"),
                DEFAULT_OVERDUE_LIMIT,
                MIN_LIMIT,
                MAX_LIMIT);
        BoundedInt pageInput = parseBoundedInt(
                request.getParameter("page"),
                DEFAULT_PAGE,
                DEFAULT_PAGE,
                Integer.MAX_VALUE);
        BoundedInt pageSizeInput = parseBoundedInt(
                request.getParameter("pageSize"),
                DEFAULT_PAGE_SIZE,
                MIN_LIMIT,
                MAX_PAGE_SIZE);

        int responseHours = responseHoursInput.value();
        int staffLimit = staffLimitInput.value();
        int overdueLimit = overdueLimitInput.value();
        int page = pageInput.value();
        int pageSize = pageSizeInput.value();
        int offset = (page - 1) * pageSize;
        boolean onlyUnassigned = parseBooleanFlag(request.getParameter("onlyUnassigned"));

        Map<String, Object> summary = null;
        List<Map<String, Object>> overdueByPriority = null;
        List<Map<String, Object>> performance = null;
        List<Map<String, Object>> overdueTickets = null;
        List<Map<String, Object>> feedbackList = null;
        List<Map<String, Object>> assignableAgents = null;
        int totalRecords = 0;
        int totalPages = 1;
        Integer ratingFilter = parseRatingFilter(request.getParameter("rating"));

        if (VIEW_OVERVIEW.equals(view)) {
            summary = slaDashboardDAO.getIncidentSlaSummary(responseHours);
            overdueByPriority = slaDashboardDAO.getOverdueByPriority(responseHours);
        } else if (VIEW_PERFORMANCE.equals(view)) {
            totalRecords = slaDashboardDAO.countAgentPerformance();
            totalPages = Math.max(1, (int) Math.ceil(totalRecords / (double) pageSize));
            if (page > totalPages) {
                page = totalPages;
                pageInput = new BoundedInt(page, true);
                offset = (page - 1) * pageSize;
            }
            performance = slaDashboardDAO.getAgentPerformance(offset, pageSize);
        } else if (VIEW_ESCALATION.equals(view)) {
            totalRecords = slaDashboardDAO.countOverdueNewIncidents(responseHours, onlyUnassigned);
            totalPages = Math.max(1, (int) Math.ceil(totalRecords / (double) pageSize));
            if (page > totalPages) {
                page = totalPages;
                pageInput = new BoundedInt(page, true);
                offset = (page - 1) * pageSize;
            }
            overdueTickets = slaDashboardDAO.getOverdueNewIncidents(responseHours, onlyUnassigned, offset, pageSize);
            assignableAgents = slaDashboardDAO.getAssignableAgents();
        } else if (VIEW_FEEDBACK.equals(view)) {
            totalRecords = slaDashboardDAO.countFeedback(ratingFilter);
            totalPages = Math.max(1, (int) Math.ceil(totalRecords / (double) pageSize));
            if (page > totalPages) {
                page = totalPages;
                pageInput = new BoundedInt(page, true);
                offset = (page - 1) * pageSize;
            }
            feedbackList = slaDashboardDAO.getFeedbackList(ratingFilter, offset, pageSize);
        }

        request.setAttribute("responseHoursAdjusted", responseHoursInput.adjusted());
        request.setAttribute("staffLimitAdjusted", staffLimitInput.adjusted());
        request.setAttribute("overdueLimitAdjusted", overdueLimitInput.adjusted());
        request.setAttribute("pageAdjusted", pageInput.adjusted());
        request.setAttribute("pageSizeAdjusted", pageSizeInput.adjusted());
        request.setAttribute("responseHours", responseHours);
        request.setAttribute("staffLimit", staffLimit);
        request.setAttribute("overdueLimit", overdueLimit);
        request.setAttribute("page", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("view", view);
        request.setAttribute("rating", ratingFilter);
        request.setAttribute("onlyUnassigned", onlyUnassigned);
        request.setAttribute("summary", summary);
        request.setAttribute("overdueByPriority", overdueByPriority);
        request.setAttribute("performance", performance);
        request.setAttribute("overdueTickets", overdueTickets);
        request.setAttribute("feedbackList", feedbackList);
        request.setAttribute("assignableAgents", assignableAgents);
        request.getRequestDispatcher("/dashboard/sla-manager.jsp").forward(request, response);
    }

    private BoundedInt parseBoundedInt(String raw, int defaultValue, int min, int max) {
        if (raw == null || raw.trim().isEmpty()) {
            return new BoundedInt(defaultValue, false);
        }
        try {
            int value = Integer.parseInt(raw.trim());
            if (value < min) {
                return new BoundedInt(min, true);
            }
            if (value > max) {
                return new BoundedInt(max, true);
            }
            return new BoundedInt(value, false);
        } catch (NumberFormatException e) {
            return new BoundedInt(defaultValue, true);
        }
    }

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String normalized = value.trim();
        return normalized.isEmpty() ? null : normalized;
    }

    private String normalizeView(String rawView) {
        String view = trimToNull(rawView);
        if (view == null) {
            return VIEW_OVERVIEW;
        }
        return switch (view.toLowerCase()) {
            case VIEW_OVERVIEW, VIEW_PERFORMANCE, VIEW_ESCALATION, VIEW_MATRIX, VIEW_FEEDBACK -> view.toLowerCase();
            default -> VIEW_OVERVIEW;
        };
    }

    private Integer parseRatingFilter(String raw) {
        String normalized = trimToNull(raw);
        if (normalized == null) {
            return null;
        }
        try {
            int value = Integer.parseInt(normalized);
            if (value >= 1 && value <= 5) {
                return value;
            }
        } catch (NumberFormatException e) {
            return null;
        }
        return null;
    }

    private boolean parseBooleanFlag(String raw) {
        String value = trimToNull(raw);
        if (value == null) {
            return false;
        }
        return "1".equals(value) || "true".equalsIgnoreCase(value) || "on".equalsIgnoreCase(value);
    }

    private void exportImpactUrgencyTemplate(HttpServletResponse response) throws IOException {
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"impact-urgency-sla-matrix.csv\"");

        try (PrintWriter out = response.getWriter()) {
            out.print('\uFEFF'); // UTF-8 BOM for better Excel compatibility
            out.println("Impact/Urgency Matrix for Incident SLA");
            out.println("Impact,Urgency,Priority,First Response Target,Resolution Target,Escalation Rule");
            out.println("Low,Low,LOW,Same business day,2-4 weeks,Notify manager when NEW > 48h");
            out.println("Low,Medium,LOW,Same business day,2-4 weeks,Notify manager when NEW > 48h");
            out.println("Medium,Low,NORMAL,Same business day,1-2 weeks,Notify manager when NEW > 48h");
            out.println("Medium,Medium,MEDIUM,Same business day,1-2 weeks,Notify manager when NEW > 48h");
            out.println("High,Medium,HIGH,Within 3 hours,2-5 days,Notify manager when NEW > 24h");
            out.println("High,High,CRITICAL,Within 1 hour,Within 1 day,Notify manager immediately when NEW > 1h");
            out.println("Very High,High,URGENT,Within 1 hour,Within 1 day,Notify manager immediately and alert support lead");
        }
    }

    private record BoundedInt(int value, boolean adjusted) {
    }
}
