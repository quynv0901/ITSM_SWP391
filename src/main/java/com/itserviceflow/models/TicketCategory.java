package com.itserviceflow.models;

import java.sql.Timestamp;

/**
 * Represents a row in the ticket_category table. Extra joined fields
 * (parentCategoryName) are populated when needed.
 */
public class TicketCategory {

    private int categoryId;
    private String categoryName;
    private String categoryCode;
    private String categoryType;      // INCIDENT, SERVICE_REQUEST, CHANGE, PROBLEM, KNOWLEDGE
    private String description;
    private Integer parentCategoryId;
    private String difficultyLevel;   // LEVEL_1, LEVEL_2, LEVEL_3
    private boolean isActive;
    private Timestamp updatedAt;

    // ── Joined / derived fields ────────────────────────────────────
    private String parentCategoryName;
    private int childCount;        // how many direct sub-categories exist
    private int ticketCount;       // how many tickets use this category

    public TicketCategory() {
    }

    // ── Getters / Setters ──────────────────────────────────────────
    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int v) {
        this.categoryId = v;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String v) {
        this.categoryName = v;
    }

    public String getCategoryCode() {
        return categoryCode;
    }

    public void setCategoryCode(String v) {
        this.categoryCode = v;
    }

    public String getCategoryType() {
        return categoryType;
    }

    public void setCategoryType(String v) {
        this.categoryType = v;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String v) {
        this.description = v;
    }

    public Integer getParentCategoryId() {
        return parentCategoryId;
    }

    public void setParentCategoryId(Integer v) {
        this.parentCategoryId = v;
    }

    public String getDifficultyLevel() {
        return difficultyLevel;
    }

    public void setDifficultyLevel(String v) {
        this.difficultyLevel = v;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean v) {
        this.isActive = v;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp v) {
        this.updatedAt = v;
    }

    public String getParentCategoryName() {
        return parentCategoryName;
    }

    public void setParentCategoryName(String v) {
        this.parentCategoryName = v;
    }

    public int getChildCount() {
        return childCount;
    }

    public void setChildCount(int v) {
        this.childCount = v;
    }

    public int getTicketCount() {
        return ticketCount;
    }

    public void setTicketCount(int v) {
        this.ticketCount = v;
    }
}
