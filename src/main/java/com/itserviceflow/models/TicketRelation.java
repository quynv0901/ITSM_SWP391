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
public class TicketRelation {

    private int relationId;
    private int sourceTicketId;
    private int targetTicketId;
    private String relationType;
    private int createdBy;
    private Date createdAt;

    public int getRelationId() {
        return relationId;
    }

    public void setRelationId(int relationId) {
        this.relationId = relationId;
    }

    public int getSourceTicketId() {
        return sourceTicketId;
    }

    public void setSourceTicketId(int sourceTicketId) {
        this.sourceTicketId = sourceTicketId;
    }

    public int getTargetTicketId() {
        return targetTicketId;
    }

    public void setTargetTicketId(int targetTicketId) {
        this.targetTicketId = targetTicketId;
    }

    public String getRelationType() {
        return relationType;
    }

    public void setRelationType(String relationType) {
        this.relationType = relationType;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }
}
