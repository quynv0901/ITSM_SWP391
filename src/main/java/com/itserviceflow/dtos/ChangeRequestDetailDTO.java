package com.itserviceflow.dtos;

import java.sql.Timestamp;
import java.util.List;

public class ChangeRequestDetailDTO {
    private int ticketId;
    private String ticketNumber;
    private String title;
    private String description;
    private String status;
    private String priority;
    private String approvalStatus;
    private String changeType;
    private String riskLevel;
    private String impactAssessment;
    private String implementationPlan;
    private String rollbackPlan;
    private String testPlan;
    private String justification;
    private String solution;
    private String cabRiskAssessment;
    private String cabComment;
    private Integer reportedBy;
    private String reportedByName;
    private Integer assignedTo;
    private String assignedToName;
    private Integer cabMemberId;
    private String cabMemberName;
    private Timestamp scheduledStart;
    private Timestamp scheduledEnd;
    private Timestamp actualStart;
    private Timestamp actualEnd;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private List<ServiceRequestCommentDTO> comments;

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
    public String getApprovalStatus() { return approvalStatus; }
    public void setApprovalStatus(String approvalStatus) { this.approvalStatus = approvalStatus; }
    public String getChangeType() { return changeType; }
    public void setChangeType(String changeType) { this.changeType = changeType; }
    public String getRiskLevel() { return riskLevel; }
    public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }
    public String getImpactAssessment() { return impactAssessment; }
    public void setImpactAssessment(String impactAssessment) { this.impactAssessment = impactAssessment; }
    public String getImplementationPlan() { return implementationPlan; }
    public void setImplementationPlan(String implementationPlan) { this.implementationPlan = implementationPlan; }
    public String getRollbackPlan() { return rollbackPlan; }
    public void setRollbackPlan(String rollbackPlan) { this.rollbackPlan = rollbackPlan; }
    public String getTestPlan() { return testPlan; }
    public void setTestPlan(String testPlan) { this.testPlan = testPlan; }
    public String getJustification() { return justification; }
    public void setJustification(String justification) { this.justification = justification; }
    public String getSolution() { return solution; }
    public void setSolution(String solution) { this.solution = solution; }
    public String getCabRiskAssessment() { return cabRiskAssessment; }
    public void setCabRiskAssessment(String cabRiskAssessment) { this.cabRiskAssessment = cabRiskAssessment; }
    public String getCabComment() { return cabComment; }
    public void setCabComment(String cabComment) { this.cabComment = cabComment; }
    public Integer getReportedBy() { return reportedBy; }
    public void setReportedBy(Integer reportedBy) { this.reportedBy = reportedBy; }
    public String getReportedByName() { return reportedByName; }
    public void setReportedByName(String reportedByName) { this.reportedByName = reportedByName; }
    public Integer getAssignedTo() { return assignedTo; }
    public void setAssignedTo(Integer assignedTo) { this.assignedTo = assignedTo; }
    public String getAssignedToName() { return assignedToName; }
    public void setAssignedToName(String assignedToName) { this.assignedToName = assignedToName; }
    public Integer getCabMemberId() { return cabMemberId; }
    public void setCabMemberId(Integer cabMemberId) { this.cabMemberId = cabMemberId; }
    public String getCabMemberName() { return cabMemberName; }
    public void setCabMemberName(String cabMemberName) { this.cabMemberName = cabMemberName; }
    public Timestamp getScheduledStart() { return scheduledStart; }
    public void setScheduledStart(Timestamp scheduledStart) { this.scheduledStart = scheduledStart; }
    public Timestamp getScheduledEnd() { return scheduledEnd; }
    public void setScheduledEnd(Timestamp scheduledEnd) { this.scheduledEnd = scheduledEnd; }
    public Timestamp getActualStart() { return actualStart; }
    public void setActualStart(Timestamp actualStart) { this.actualStart = actualStart; }
    public Timestamp getActualEnd() { return actualEnd; }
    public void setActualEnd(Timestamp actualEnd) { this.actualEnd = actualEnd; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
    public List<ServiceRequestCommentDTO> getComments() { return comments; }
    public void setComments(List<ServiceRequestCommentDTO> comments) { this.comments = comments; }
}
