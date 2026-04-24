package com.itserviceflow.dtos;

import java.sql.Timestamp;

public class MyAssignedTicketDTO {
    private int ticketId;
    private String ticketNumber;
    private String ticketType;
    private String title;
    private String status;
    private String priority;
    private Timestamp createdAt;
    private Timestamp scheduledStart;

    public int getTicketId() { return ticketId; }
    public void setTicketId(int ticketId) { this.ticketId = ticketId; }
    public String getTicketNumber() { return ticketNumber; }
    public void setTicketNumber(String ticketNumber) { this.ticketNumber = ticketNumber; }
    public String getTicketType() { return ticketType; }
    public void setTicketType(String ticketType) { this.ticketType = ticketType; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getScheduledStart() { return scheduledStart; }
    public void setScheduledStart(Timestamp scheduledStart) { this.scheduledStart = scheduledStart; }
}
