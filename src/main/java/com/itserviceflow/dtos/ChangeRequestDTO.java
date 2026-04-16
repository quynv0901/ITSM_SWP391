package com.itserviceflow.dtos;

import java.util.Date;

public class ChangeRequestDTO {
    private int ticketId;
    private String ticketNumber;
    private String ticketType;
    private String title;
    private String description;
    private String status;
    private String priority;
    private String approvalStatus;

    private Integer categoryId;
    private int reportedBy;
    private String reportedByName;
    private Integer assignedTo;
    private String assignedToName;
    private Integer departmentId;

    private String justification;
    private Integer serviceId;
    private Integer ciId;

    private String impact;
    private String urgency;
    private String changeType;
    private String riskLevel;
    private String impactAssessment;
    private String rollbackPlan;
    private String implementationPlan;
    private String testPlan;

    private String cabDecision;
    private Integer cabMemberId;
    private String cabMemberName;
    private String cabRiskAssessment;
    private String cabComment;
    private Date cabDecidedAt;

    private Integer approvedBy;
    private String approvedByName;
    private Date approvedAt;
    private String rejectionReason;

    private Date scheduledStart;
    private Date scheduledEnd;
    private Date actualStart;
    private Date actualEnd;

    private boolean downtimeRequired;
    private Double estimatedDowntimeHour;

    private Date createdAt;
    private Date updatedAt;
    private Date cancelledAt;
    private Date completedAt;
    private Date closedAt;

    public ChangeRequestDTO() {
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

    public String getApprovalStatus() {
        return approvalStatus;
    }

    public void setApprovalStatus(String approvalStatus) {
        this.approvalStatus = approvalStatus;
    }

    public Integer getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Integer categoryId) {
        this.categoryId = categoryId;
    }

    public int getReportedBy() {
        return reportedBy;
    }

    public void setReportedBy(int reportedBy) {
        this.reportedBy = reportedBy;
    }

    public String getReportedByName() {
        return reportedByName;
    }

    public void setReportedByName(String reportedByName) {
        this.reportedByName = reportedByName;
    }

    public Integer getAssignedTo() {
        return assignedTo;
    }

    public void setAssignedTo(Integer assignedTo) {
        this.assignedTo = assignedTo;
    }

    public String getAssignedToName() {
        return assignedToName;
    }

    public void setAssignedToName(String assignedToName) {
        this.assignedToName = assignedToName;
    }

    public Integer getDepartmentId() {
        return departmentId;
    }

    public void setDepartmentId(Integer departmentId) {
        this.departmentId = departmentId;
    }

    public String getJustification() {
        return justification;
    }

    public void setJustification(String justification) {
        this.justification = justification;
    }

    public Integer getServiceId() {
        return serviceId;
    }

    public void setServiceId(Integer serviceId) {
        this.serviceId = serviceId;
    }

    public Integer getCiId() {
        return ciId;
    }

    public void setCiId(Integer ciId) {
        this.ciId = ciId;
    }

    public String getImpact() {
        return impact;
    }

    public void setImpact(String impact) {
        this.impact = impact;
    }

    public String getUrgency() {
        return urgency;
    }

    public void setUrgency(String urgency) {
        this.urgency = urgency;
    }

    public String getChangeType() {
        return changeType;
    }

    public void setChangeType(String changeType) {
        this.changeType = changeType;
    }

    public String getRiskLevel() {
        return riskLevel;
    }

    public void setRiskLevel(String riskLevel) {
        this.riskLevel = riskLevel;
    }

    public String getImpactAssessment() {
        return impactAssessment;
    }

    public void setImpactAssessment(String impactAssessment) {
        this.impactAssessment = impactAssessment;
    }

    public String getRollbackPlan() {
        return rollbackPlan;
    }

    public void setRollbackPlan(String rollbackPlan) {
        this.rollbackPlan = rollbackPlan;
    }

    public String getImplementationPlan() {
        return implementationPlan;
    }

    public void setImplementationPlan(String implementationPlan) {
        this.implementationPlan = implementationPlan;
    }

    public String getTestPlan() {
        return testPlan;
    }

    public void setTestPlan(String testPlan) {
        this.testPlan = testPlan;
    }

    public String getCabDecision() {
        return cabDecision;
    }

    public void setCabDecision(String cabDecision) {
        this.cabDecision = cabDecision;
    }

    public Integer getCabMemberId() {
        return cabMemberId;
    }

    public void setCabMemberId(Integer cabMemberId) {
        this.cabMemberId = cabMemberId;
    }

    public String getCabMemberName() {
        return cabMemberName;
    }

    public void setCabMemberName(String cabMemberName) {
        this.cabMemberName = cabMemberName;
    }

    public String getCabRiskAssessment() {
        return cabRiskAssessment;
    }

    public void setCabRiskAssessment(String cabRiskAssessment) {
        this.cabRiskAssessment = cabRiskAssessment;
    }

    public String getCabComment() {
        return cabComment;
    }

    public void setCabComment(String cabComment) {
        this.cabComment = cabComment;
    }

    public Date getCabDecidedAt() {
        return cabDecidedAt;
    }

    public void setCabDecidedAt(Date cabDecidedAt) {
        this.cabDecidedAt = cabDecidedAt;
    }

    public Integer getApprovedBy() {
        return approvedBy;
    }

    public void setApprovedBy(Integer approvedBy) {
        this.approvedBy = approvedBy;
    }

    public String getApprovedByName() {
        return approvedByName;
    }

    public void setApprovedByName(String approvedByName) {
        this.approvedByName = approvedByName;
    }

    public Date getApprovedAt() {
        return approvedAt;
    }

    public void setApprovedAt(Date approvedAt) {
        this.approvedAt = approvedAt;
    }

    public String getRejectionReason() {
        return rejectionReason;
    }

    public void setRejectionReason(String rejectionReason) {
        this.rejectionReason = rejectionReason;
    }

    public Date getScheduledStart() {
        return scheduledStart;
    }

    public void setScheduledStart(Date scheduledStart) {
        this.scheduledStart = scheduledStart;
    }

    public Date getScheduledEnd() {
        return scheduledEnd;
    }

    public void setScheduledEnd(Date scheduledEnd) {
        this.scheduledEnd = scheduledEnd;
    }

    public Date getActualStart() {
        return actualStart;
    }

    public void setActualStart(Date actualStart) {
        this.actualStart = actualStart;
    }

    public Date getActualEnd() {
        return actualEnd;
    }

    public void setActualEnd(Date actualEnd) {
        this.actualEnd = actualEnd;
    }

    public boolean isDowntimeRequired() {
        return downtimeRequired;
    }

    public void setDowntimeRequired(boolean downtimeRequired) {
        this.downtimeRequired = downtimeRequired;
    }

    public Double getEstimatedDowntimeHour() {
        return estimatedDowntimeHour;
    }

    public void setEstimatedDowntimeHour(Double estimatedDowntimeHour) {
        this.estimatedDowntimeHour = estimatedDowntimeHour;
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

    public Date getCancelledAt() {
        return cancelledAt;
    }

    public void setCancelledAt(Date cancelledAt) {
        this.cancelledAt = cancelledAt;
    }

    public Date getCompletedAt() {
        return completedAt;
    }

    public void setCompletedAt(Date completedAt) {
        this.completedAt = completedAt;
    }

    public Date getClosedAt() {
        return closedAt;
    }

    public void setClosedAt(Date closedAt) {
        this.closedAt = closedAt;
    }
}