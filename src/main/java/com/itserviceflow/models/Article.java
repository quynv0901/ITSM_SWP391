/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.itserviceflow.models;

import java.time.LocalDateTime;
import java.util.Date;

/**
 *
 * @author Admin
 */
public class Article {
    private Integer articleId;
    private String articleNumber;
    private String articleType;
    private String title;
    private String content;
    private String summary;
    private Integer categoryId;
    private String tag;
    private String status;
    private Integer authorId;
    private String authorName; // Field to display author name
    private Integer approvedBy;
    private LocalDateTime approvedAt;
    private String rejectionReason;
    private LocalDateTime publishedAt;
    private String errorCode;
    private String symptom;
    private String cause;
    private String solution;
    private Date updatedAt;

    public Article() {
    }

    public Article(Integer articleId, String articleNumber, String articleType, String title, String content,
            String summary, Integer categoryId, String tag, String status, Integer authorId, Integer approvedBy,
            LocalDateTime approvedAt, String rejectionReason, LocalDateTime publishedAt, String errorCode,
            String symptom, String cause, String solution, Date updatedAt) {
        this.articleId = articleId;
        this.articleNumber = articleNumber;
        this.articleType = articleType;
        this.title = title;
        this.content = content;
        this.summary = summary;
        this.categoryId = categoryId;
        this.tag = tag;
        this.status = status;
        this.authorId = authorId;
        this.approvedBy = approvedBy;
        this.approvedAt = approvedAt;
        this.rejectionReason = rejectionReason;
        this.publishedAt = publishedAt;
        this.errorCode = errorCode;
        this.symptom = symptom;
        this.cause = cause;
        this.solution = solution;
        this.updatedAt = updatedAt;
    }

    public Integer getArticleId() {
        return articleId;
    }

    public void setArticleId(Integer articleId) {
        this.articleId = articleId;
    }

    public String getArticleNumber() {
        return articleNumber;
    }

    public void setArticleNumber(String articleNumber) {
        this.articleNumber = articleNumber;
    }

    public String getArticleType() {
        return articleType;
    }

    public void setArticleType(String articleType) {
        this.articleType = articleType;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getSummary() {
        return summary;
    }

    public void setSummary(String summary) {
        this.summary = summary;
    }

    public Integer getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Integer categoryId) {
        this.categoryId = categoryId;
    }

    public String getTag() {
        return tag;
    }

    public void setTag(String tag) {
        this.tag = tag;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getAuthorId() {
        return authorId;
    }

    public void setAuthorId(Integer authorId) {
        this.authorId = authorId;
    }

    public String getAuthorName() {
        return authorName;
    }

    public void setAuthorName(String authorName) {
        this.authorName = authorName;
    }

    public Integer getApprovedBy() {
        return approvedBy;
    }

    public void setApprovedBy(Integer approvedBy) {
        this.approvedBy = approvedBy;
    }

    public LocalDateTime getApprovedAt() {
        return approvedAt;
    }

    public void setApprovedAt(LocalDateTime approvedAt) {
        this.approvedAt = approvedAt;
    }

    public String getRejectionReason() {
        return rejectionReason;
    }

    public void setRejectionReason(String rejectionReason) {
        this.rejectionReason = rejectionReason;
    }

    public LocalDateTime getPublishedAt() {
        return publishedAt;
    }

    public void setPublishedAt(LocalDateTime publishedAt) {
        this.publishedAt = publishedAt;
    }

    public String getErrorCode() {
        return errorCode;
    }

    public void setErrorCode(String errorCode) {
        this.errorCode = errorCode;
    }

    public String getSymptom() {
        return symptom;
    }

    public void setSymptom(String symptom) {
        this.symptom = symptom;
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

    public Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }

}
