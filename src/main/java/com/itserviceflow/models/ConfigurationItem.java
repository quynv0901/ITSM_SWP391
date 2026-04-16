package com.itserviceflow.models;

import java.sql.Timestamp;

public class ConfigurationItem {
    private int ciId;
    private String name;
    private String type;
    private String version;
    private String description;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public ConfigurationItem() {
    }

    public ConfigurationItem(int ciId, String name, String type, String version, String description, String status, Timestamp createdAt, Timestamp updatedAt) {
        this.ciId = ciId;
        this.name = name;
        this.type = type;
        this.version = version;
        this.description = description;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getCiId() {
        return ciId;
    }

    public void setCiId(int ciId) {
        this.ciId = ciId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
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

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}
