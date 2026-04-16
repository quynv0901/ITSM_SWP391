/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.itserviceflow.models;

/**
 *
 * @author Admin
 */
public class CiRelationship {
    private int relationshipId;
    private int parentCiId;
    private int childCiId;
    private String relationshipType; 
    private String description;

    // Joined fields
    private String parentCiName;
    private String parentCiCode;
    private String childCiName;
    private String childCiCode;

    // Getters and Setters
    public int getRelationshipId() {
        return relationshipId;
    }

    public void setRelationshipId(int relationshipId) {
        this.relationshipId = relationshipId;
    }

    public int getParentCiId() {
        return parentCiId;
    }

    public void setParentCiId(int parentCiId) {
        this.parentCiId = parentCiId;
    }

    public int getChildCiId() {
        return childCiId;
    }

    public void setChildCiId(int childCiId) {
        this.childCiId = childCiId;
    }

    public String getRelationshipType() {
        return relationshipType;
    }

    public void setRelationshipType(String relationshipType) {
        this.relationshipType = relationshipType;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getParentCiName() {
        return parentCiName;
    }

    public void setParentCiName(String parentCiName) {
        this.parentCiName = parentCiName;
    }

    public String getParentCiCode() {
        return parentCiCode;
    }

    public void setParentCiCode(String parentCiCode) {
        this.parentCiCode = parentCiCode;
    }

    public String getChildCiName() {
        return childCiName;
    }

    public void setChildCiName(String childCiName) {
        this.childCiName = childCiName;
    }

    public String getChildCiCode() {
        return childCiCode;
    }

    public void setChildCiCode(String childCiCode) {
        this.childCiCode = childCiCode;
    }
}
