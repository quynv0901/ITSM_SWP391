package com.itserviceflow.models;

import java.sql.Date;
import java.sql.Timestamp;

public class MaintenanceLog {
    private int logId;
    private int ciId;
    private String maintenanceType;
    private Date maintenanceDate;
    private int downtimeMinutes;
    private String description;
    private Integer performedBy;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Transient fields for UI
    private String ciName;
    private String performedByName;

    public MaintenanceLog() {
    }

    public int getLogId() { return logId; }
    public void setLogId(int logId) { this.logId = logId; }

    public int getCiId() { return ciId; }
    public void setCiId(int ciId) { this.ciId = ciId; }

    public String getMaintenanceType() { return maintenanceType; }
    public void setMaintenanceType(String maintenanceType) { this.maintenanceType = maintenanceType; }

    public Date getMaintenanceDate() { return maintenanceDate; }
    public void setMaintenanceDate(Date maintenanceDate) { this.maintenanceDate = maintenanceDate; }

    public int getDowntimeMinutes() { return downtimeMinutes; }
    public void setDowntimeMinutes(int downtimeMinutes) { this.downtimeMinutes = downtimeMinutes; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Integer getPerformedBy() { return performedBy; }
    public void setPerformedBy(Integer performedBy) { this.performedBy = performedBy; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getCiName() { return ciName; }
    public void setCiName(String ciName) { this.ciName = ciName; }

    public String getPerformedByName() { return performedByName; }
    public void setPerformedByName(String performedByName) { this.performedByName = performedByName; }
}
