package com.itserviceflow.models;

import java.util.Date;

/**
 * Model for the time_log table. Records how much time an agent spent on a
 * specific activity for a ticket.
 */
public class TimeLog {

    private int logId;
    private int ticketId;
    private int userId;          // agent who performed the action
    private String activityType; // ASSIGNED | INVESTIGATION | RESOLVED | CLOSED | MANUAL
    private double timeSpent;    // hours (DECIMAL 5,2)
    private String description;
    private Date loggedAt;
    private Date updatedAt;

    // Extra display fields (joined from other tables)
    private String agentName;
    private String ticketNumber;

    public TimeLog() {
    }

    public TimeLog(int ticketId, int userId, String activityType, double timeSpent, String description) {
        this.ticketId = ticketId;
        this.userId = userId;
        this.activityType = activityType;
        this.timeSpent = timeSpent;
        this.description = description;
    }

    // -------- Getters & Setters --------
    public int getLogId() {
        return logId;
    }

    public void setLogId(int logId) {
        this.logId = logId;
    }

    public int getTicketId() {
        return ticketId;
    }

    public void setTicketId(int ticketId) {
        this.ticketId = ticketId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getActivityType() {
        return activityType;
    }

    public void setActivityType(String activityType) {
        this.activityType = activityType;
    }

    public double getTimeSpent() {
        return timeSpent;
    }

    public void setTimeSpent(double timeSpent) {
        this.timeSpent = timeSpent;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Date getLoggedAt() {
        return loggedAt;
    }

    public void setLoggedAt(Date loggedAt) {
        this.loggedAt = loggedAt;
    }

    public Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getAgentName() {
        return agentName;
    }

    public void setAgentName(String agentName) {
        this.agentName = agentName;
    }

    public String getTicketNumber() {
        return ticketNumber;
    }

    public void setTicketNumber(String ticketNumber) {
        this.ticketNumber = ticketNumber;
    }
}
