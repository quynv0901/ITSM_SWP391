package com.itserviceflow.models;

import java.sql.Timestamp;

public class Notification {
    private int notificationId;
    private int userId;
    private String notificationType;
    private String title;
    private String message;
    private Integer relatedTicketId;
    private Integer relatedArticleId;
    private boolean isSeen;
    private Timestamp createdAt;

    public Notification() {
    }

    public Notification(int notificationId, int userId, String notificationType, String title, String message,
            Integer relatedTicketId, Integer relatedArticleId, boolean isSeen, Timestamp createdAt) {
        this.notificationId = notificationId;
        this.userId = userId;
        this.notificationType = notificationType;
        this.title = title;
        this.message = message;
        this.relatedTicketId = relatedTicketId;
        this.relatedArticleId = relatedArticleId;
        this.isSeen = isSeen;
        this.createdAt = createdAt;
    }

    public int getNotificationId() {
        return notificationId;
    }

    public void setNotificationId(int notificationId) {
        this.notificationId = notificationId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getNotificationType() {
        return notificationType;
    }

    public void setNotificationType(String notificationType) {
        this.notificationType = notificationType;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Integer getRelatedTicketId() {
        return relatedTicketId;
    }

    public void setRelatedTicketId(Integer relatedTicketId) {
        this.relatedTicketId = relatedTicketId;
    }

    public Integer getRelatedArticleId() {
        return relatedArticleId;
    }

    public void setRelatedArticleId(Integer relatedArticleId) {
        this.relatedArticleId = relatedArticleId;
    }

    public boolean isSeen() {
        return isSeen;
    }

    public void setSeen(boolean seen) {
        isSeen = seen;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
