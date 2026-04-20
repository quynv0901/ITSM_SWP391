package com.itserviceflow.utils;

import com.itserviceflow.daos.TimeLogDAO;
import com.itserviceflow.models.TimeLog;
import com.itserviceflow.models.Ticket;

/**
 * Service that encapsulates the business logic for automatically calculating
 * and recording time entries (logtime) when agents act on tickets.
 *
 * ┌──────────────────────────────────────────────────────────────────────────┐
 * │ time_spent = Base × Priority × Difficulty × Activity │
 * ├──────────────────────────────────────────────────────────────────────────┤
 * │ Base (ticket_type) │ Priority multiplier │ │ INCIDENT 1.0 h │ LOW 0.5× │ │
 * SERVICE_REQUEST 0.5 h │ MEDIUM 1.0× │ │ PROBLEM 2.0 h │ HIGH 1.5× │ │ CHANGE
 * 3.0 h │ CRITICAL 2.0× │ │ │ │ │ Difficulty multiplier │ Activity multiplier │
 * │ LEVEL_1 1.0× │ ASSIGNED 0.25× │ │ LEVEL_2 1.5× │ INVESTIGATION 1.0× │ │
 * LEVEL_3 2.0× │ RESOLVED 0.5× │ │ │ CLOSED 0.25× │ │ │ MANUAL 1.0× (user sets
 * value) │
 * └──────────────────────────────────────────────────────────────────────────┘
 */
public class TimeLogService {

    private final TimeLogDAO timeLogDAO = new TimeLogDAO();
    /**
     * Global toggle to enable/disable automatic time logging.
     * Set to false to temporarily disable all auto-log flows (autoLog/autoLogWithReason).
     */
    public static volatile boolean AUTO_LOG_ENABLED = false;

    // -----------------------------------------------------------------------
    // Public API
    // -----------------------------------------------------------------------
    /**
     * Calculates the expected time (in hours) for the given activity based on
     * the ticket's type, priority, and difficulty level.
     *
     * @param ticket the ticket being worked on
     * @param activityType one of ASSIGNED | INVESTIGATION | RESOLVED | CLOSED |
     * MANUAL
     * @return time in hours, rounded to 2 decimal places
     */
    public double calculateTimeSpent(Ticket ticket, String activityType) {
        double base = baseTime(ticket.getTicketType());
        double priority = priorityMultiplier(ticket.getPriority());
        double difficulty = difficultyMultiplier(ticket.getDifficultyLevel());
        double activity = activityMultiplier(activityType);

        double result = base * priority * difficulty * activity;
        // round to 2 decimal places
        return Math.round(result * 100.0) / 100.0;
    }

    /**
     * Calculates time spent and persists a time_log record automatically.
     *
     * @param ticket the ticket (must have ticketId, ticketType, priority,
     * difficultyLevel set)
     * @param agentUserId the user_id of the agent performing the action
     * @param activityType one of ASSIGNED | INVESTIGATION | RESOLVED | CLOSED
     * @return true if the log was saved successfully
     */
    public boolean autoLog(Ticket ticket, int agentUserId, String activityType) {
        // Central switch: if auto-logging is disabled, do nothing
        if (!AUTO_LOG_ENABLED) {
            return false;
        }
        double timeSpent = calculateTimeSpent(ticket, activityType);
        String description = buildDescription(ticket, activityType, timeSpent);

        TimeLog log = new TimeLog(ticket.getTicketId(), agentUserId, activityType, timeSpent, description);
        return timeLogDAO.insertLog(log);
    }

    /**
     * Persists a manual time_log entry. The caller provides the exact time
     * spent.
     *
     * @param ticketId the ticket being logged for
     * @param agentUserId the agent user_id
     * @param timeSpent hours (positive value, max 999.99)
     * @param description free-text description required for manual entries
     * @return true if saved
     */
    public boolean manualLog(int ticketId, int agentUserId, double timeSpent, String description) {
        if (timeSpent <= 0 || timeSpent > 999.99) {
            return false;
        }
        TimeLog log = new TimeLog(ticketId, agentUserId, "MANUAL", timeSpent, description);
        return timeLogDAO.insertLog(log);
    }

    /**
     * Calculates time spent and persists a time_log record automatically with custom reason.
     * Used for CANCELLED activity with reason.
     *
     * @param ticket the ticket (must have ticketId, ticketType, priority, difficultyLevel set)
     * @param agentUserId the user_id of the agent performing the action
     * @param activityType one of ASSIGNED | INVESTIGATION | RESOLVED | CLOSED | CANCELLED
     * @param reason custom reason for the activity (e.g., cancellation reason)
     * @return true if the log was saved successfully
     */
    public boolean autoLogWithReason(Ticket ticket, int agentUserId, String activityType, String reason) {
        // Central switch: if auto-logging is disabled, do nothing
        if (!AUTO_LOG_ENABLED) {
            return false;
        }
        double timeSpent = calculateTimeSpent(ticket, activityType);
        String description = buildDescriptionWithReason(ticket, activityType, timeSpent, reason);

        TimeLog log = new TimeLog(ticket.getTicketId(), agentUserId, activityType, timeSpent, description);
        return timeLogDAO.insertLog(log);
    }

    // -----------------------------------------------------------------------
    // Formula helpers
    // -----------------------------------------------------------------------
    private double baseTime(String ticketType) {
        if (ticketType == null) {
            return 1.0;
        }
        switch (ticketType.toUpperCase()) {
            case "SERVICE_REQUEST":
                return 0.5;
            case "PROBLEM":
                return 2.0;
            case "CHANGE":
                return 3.0;
            case "INCIDENT":
            default:
                return 1.0;
        }
    }

    private double priorityMultiplier(String priority) {
        if (priority == null) {
            return 1.0;
        }
        switch (priority.toUpperCase()) {
            case "LOW":
                return 0.5;
            case "HIGH":
                return 1.5;
            case "CRITICAL":
                return 2.0;
            case "MEDIUM":
            default:
                return 1.0;
        }
    }

    private double difficultyMultiplier(String difficultyLevel) {
        if (difficultyLevel == null) {
            return 1.0;
        }
        switch (difficultyLevel.toUpperCase()) {
            case "LEVEL_2":
                return 1.5;
            case "LEVEL_3":
                return 2.0;
            case "LEVEL_1":
            default:
                return 1.0;
        }
    }

    private double activityMultiplier(String activityType) {
        if (activityType == null) {
            return 1.0;
        }
        switch (activityType.toUpperCase()) {
            case "ASSIGNED":
                return 0.25;
            case "RESOLVED":
                return 0.5;
            case "CLOSED":
                return 0.25;
            case "INVESTIGATION":
            case "MANUAL":
            default:
                return 1.0;
        }
    }

    private String buildDescription(Ticket ticket, String activityType, double timeSpent) {
        return String.format(
                "Auto-logged: [%s] on ticket %s | Type: %s | Priority: %s | Difficulty: %s | Time: %.2f h",
                activityType,
                ticket.getTicketNumber() != null ? ticket.getTicketNumber() : "#" + ticket.getTicketId(),
                ticket.getTicketType(),
                ticket.getPriority(),
                ticket.getDifficultyLevel() != null ? ticket.getDifficultyLevel() : "N/A",
                timeSpent
        );
    }

    private String buildDescriptionWithReason(Ticket ticket, String activityType, double timeSpent, String reason) {
        return String.format(
                "Auto-logged: [%s] on ticket %s | Type: %s | Priority: %s | Difficulty: %s | Time: %.2f h | Reason: %s",
                activityType,
                ticket.getTicketNumber() != null ? ticket.getTicketNumber() : "#" + ticket.getTicketId(),
                ticket.getTicketType(),
                ticket.getPriority(),
                ticket.getDifficultyLevel() != null ? ticket.getDifficultyLevel() : "N/A",
                timeSpent,
                reason
        );
    }
}
