/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.itserviceflow.models;

import java.util.Date;

/**
 *
 * @author Admin
 */
public class Ticket {
    private int ticketId;
    private String ticketNumber;
    private String ticketType;
    private String title;
    private String description;
    private String status;
    private String priority;
    private String difficultyLevel;
    private int categoryId;
    private int reportedBy;
    private Integer assignedTo;
    private Integer departmentId;
    private String cause;
    private String solution;
    private String justification;
    private Integer serviceId;
    private Date createdAt;
    private Date updatedAt;
    private String reportedByName;
    private String assignedToName;

    private String changeType;
    private String riskLevel;
    private String impactAssessment;
    private String rollbackPlan;
    private String implementationPlan;
    private String testPlan;
    private String cabDecision;
    private Integer cabMemberId;
    private String cabRiskAssessment;
    private String cabComment;
    private Date scheduledStart;
    private Date scheduledEnd;
    private boolean downtimeRequired;
    private Double estimatedDowntimeHour;

    public Ticket() {
    }

    public Ticket(int ticketId, String ticketNumber, String ticketType, String title, String description, String status,
            String priority, String difficultyLevel, int categoryId, int reportedBy, Integer assignedTo,
            Integer departmentId, String cause, String solution, Date createdAt, Date updatedAt) {
        this.ticketId = ticketId;
        this.ticketNumber = ticketNumber;
        this.ticketType = ticketType;
        this.title = title;
        this.description = description;
        this.status = status;
        this.priority = priority;
        this.difficultyLevel = difficultyLevel;
        this.categoryId = categoryId;
        this.reportedBy = reportedBy;
        this.assignedTo = assignedTo;
        this.departmentId = departmentId;
        this.cause = cause;
        this.solution = solution;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getTicketId() {
        return ticketId;
    }

    public void setTicketId(int ticketId) {
        this.ticketId = ticketId;
    }

    public String getTicketNumber() {
        return ticketNumber;
    }

    public void setTicketNumber(String ticketNumber) {
        this.ticketNumber = ticketNumber;
    }

    public String getTicketType() {
        return ticketType;
    }

    public void setTicketType(String ticketType) {
        this.ticketType = ticketType;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getPriority() {
        return priority;
    }

    public void setPriority(String priority) {
        this.priority = priority;
    }

    public String getDifficultyLevel() {
        return difficultyLevel;
    }

    public void setDifficultyLevel(String difficultyLevel) {
        this.difficultyLevel = difficultyLevel;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public int getReportedBy() {
        return reportedBy;
    }

    public void setReportedBy(int reportedBy) {
        this.reportedBy = reportedBy;
    }

    public Integer getAssignedTo() {
        return assignedTo;
    }

    public void setAssignedTo(Integer assignedTo) {
        this.assignedTo = assignedTo;
    }

    public Integer getDepartmentId() {
        return departmentId;
    }

    public void setDepartmentId(Integer departmentId) {
        this.departmentId = departmentId;
    }

    public String getCause() {
        return cause;
    }

    public void setCause(String cause) {
        this.cause = cause;
    }

    public String getSolution() {
        return solution;
    }

    public void setSolution(String solution) {
        this.solution = solution;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Integer getServiceId() {
        return serviceId;
    }

    public void setServiceId(Integer serviceId) {
        this.serviceId = serviceId;
    }

    public String getJustification() {
        return justification;
    }

    public void setJustification(String justification) {
        this.justification = justification;
    }


    public String getReportedByName() {
        return reportedByName;
    }

    public void setReportedByName(String reportedByName) {
        this.reportedByName = reportedByName;
    }

    public String getAssignedToName() {
        return assignedToName;
    }

    public void setAssignedToName(String assignedToName) {
        this.assignedToName = assignedToName;
    }
    
    public String getChangeType() { return changeType; }
    public void setChangeType(String changeType) { this.changeType = changeType; }
    
    public String getRiskLevel() { return riskLevel; }
    public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }
    
    public String getImpactAssessment() { return impactAssessment; }
    public void setImpactAssessment(String impactAssessment) { this.impactAssessment = impactAssessment; }
    
    public String getRollbackPlan() { return rollbackPlan; }
    public void setRollbackPlan(String rollbackPlan) { this.rollbackPlan = rollbackPlan; }
    
    public String getImplementationPlan() { return implementationPlan; }
    public void setImplementationPlan(String implementationPlan) { this.implementationPlan = implementationPlan; }
    
    public String getTestPlan() { return testPlan; }
    public void setTestPlan(String testPlan) { this.testPlan = testPlan; }
    
    public String getCabDecision() { return cabDecision; }
    public void setCabDecision(String cabDecision) { this.cabDecision = cabDecision; }
    
    public Integer getCabMemberId() { return cabMemberId; }
    public void setCabMemberId(Integer cabMemberId) { this.cabMemberId = cabMemberId; }
    
    public String getCabRiskAssessment() { return cabRiskAssessment; }
    public void setCabRiskAssessment(String cabRiskAssessment) { this.cabRiskAssessment = cabRiskAssessment; }
    
    public String getCabComment() { return cabComment; }
    public void setCabComment(String cabComment) { this.cabComment = cabComment; }
    
    public Date getScheduledStart() { return scheduledStart; }
    public void setScheduledStart(Date scheduledStart) { this.scheduledStart = scheduledStart; }
    
    public Date getScheduledEnd() { return scheduledEnd; }
    public void setScheduledEnd(Date scheduledEnd) { this.scheduledEnd = scheduledEnd; }
    
    public boolean isDowntimeRequired() { return downtimeRequired; }
    public void setDowntimeRequired(boolean downtimeRequired) { this.downtimeRequired = downtimeRequired; }
    
    public Double getEstimatedDowntimeHour() { return estimatedDowntimeHour; }
    public void setEstimatedDowntimeHour(Double estimatedDowntimeHour) { this.estimatedDowntimeHour = estimatedDowntimeHour; }
}
