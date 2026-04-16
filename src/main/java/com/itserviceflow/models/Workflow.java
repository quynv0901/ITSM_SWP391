package com.itserviceflow.models;

import java.sql.Timestamp;

/**
 * Model class mapping to the `workflow` table in the database.
 */
public class Workflow {

    private int workflowId;
    private String workflowName;
    private String description;
    private String status; // DRAFT, ACTIVE, INACTIVE
    private String workflowConfig; // JSON string
    private int createdBy;
    private Timestamp updatedAt;

    // Extra fields for display (joined from user table)
    private String createdByName;

    public Workflow() {
    }

    public Workflow(int workflowId, String workflowName, String description,
            String status, String workflowConfig, int createdBy, Timestamp updatedAt) {
        this.workflowId = workflowId;
        this.workflowName = workflowName;
        this.description = description;
        this.status = status;
        this.workflowConfig = workflowConfig;
        this.createdBy = createdBy;
        this.updatedAt = updatedAt;
    }

    // Getters & Setters
    public int getWorkflowId() {
        return workflowId;
    }

    public void setWorkflowId(int workflowId) {
        this.workflowId = workflowId;
    }

    public String getWorkflowName() {
        return workflowName;
    }

    public void setWorkflowName(String workflowName) {
        this.workflowName = workflowName;
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

    public String getWorkflowConfig() {
        return workflowConfig;
    }

    public void setWorkflowConfig(String workflowConfig) {
        this.workflowConfig = workflowConfig;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getCreatedByName() {
        return createdByName;
    }

    public void setCreatedByName(String createdByName) {
        this.createdByName = createdByName;
    }

    /**
     * Returns true if this workflow can be toggled (ACTIVE &lt;-&gt; INACTIVE).
     * DRAFT workflows cannot be toggled.
     */
    public boolean isToggleable() {
        return "ACTIVE".equals(status) || "INACTIVE".equals(status);
    }

    /**
     * Returns badge CSS class based on status.
     */
    public String getStatusBadgeClass() {
        return switch (status) {
            case "ACTIVE" ->
                "badge-active";
            case "INACTIVE" ->
                "badge-inactive";
            default ->
                "badge-draft";
        };
    }
}
