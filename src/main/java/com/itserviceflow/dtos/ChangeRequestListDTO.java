package com.itserviceflow.dtos;

import java.sql.Timestamp;

public class ChangeRequestListDTO {
    private int ticketId;
    private String ticketNumber;
    private String title;
    private String description;
    private String status;
    private String priority;
    private String changeType;
    private String riskLevel;
    private String approvalStatus;
    private Integer reportedBy;
    private String reportedByName;
    private Integer assignedTo;
    private String assignedToName;
    private Timestamp scheduledStart;
    private Timestamp scheduledEnd;
    private Timestamp createdAt;

    public int getTicketId() { return ticketId; }
    public void setTicketId(int ticketId) { this.ticketId = ticketId; }
    public String getTicketNumber() { return ticketNumber; }
    public void setTicketNumber(String ticketNumber) { this.ticketNumber = ticketNumber; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }
    public String getChangeType() { return changeType; }
    public void setChangeType(String changeType) { this.changeType = changeType; }
    public String getRiskLevel() { return riskLevel; }
    public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }
    public String getApprovalStatus() { return approvalStatus; }
    public void setApprovalStatus(String approvalStatus) { this.approvalStatus = approvalStatus; }
    public Integer getReportedBy() { return reportedBy; }
    public void setReportedBy(Integer reportedBy) { this.reportedBy = reportedBy; }
    public String getReportedByName() { return reportedByName; }
    public void setReportedByName(String reportedByName) { this.reportedByName = reportedByName; }
    public Integer getAssignedTo() { return assignedTo; }
    public void setAssignedTo(Integer assignedTo) { this.assignedTo = assignedTo; }
    public String getAssignedToName() { return assignedToName; }
    public void setAssignedToName(String assignedToName) { this.assignedToName = assignedToName; }
    public Timestamp getScheduledStart() { return scheduledStart; }
    public void setScheduledStart(Timestamp scheduledStart) { this.scheduledStart = scheduledStart; }
    public Timestamp getScheduledEnd() { return scheduledEnd; }
    public void setScheduledEnd(Timestamp scheduledEnd) { this.scheduledEnd = scheduledEnd; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
