package com.itserviceflow.utils;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.itserviceflow.daos.NotificationDAO;
import com.itserviceflow.daos.TicketDAO;
import com.itserviceflow.daos.UserDAO;
import com.itserviceflow.daos.WorkflowDAO;
import com.itserviceflow.models.Notification;
import com.itserviceflow.models.Ticket;
import com.itserviceflow.models.User;
import com.itserviceflow.models.Workflow;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * WorkflowService — engine tự động áp dụng workflow vào ticket.
 *
 * <p>Khi một ticket được tạo hoặc cập nhật, gọi {@link #triggerForTicket(Ticket, String)}
 * để hệ thống:
 * <ol>
 *   <li>Lấy tất cả workflow đang ACTIVE</li>
 *   <li>Lọc theo trigger phù hợp (TICKET_CREATED / TICKET_UPDATED / SLA_BREACH)</li>
 *   <li>Đánh giá conditions (ticket_type, priority, category_id)</li>
 *   <li>Nếu khớp → thực thi steps (ASSIGN_AGENT, SET_PRIORITY, SET_STATUS, NOTIFY)</li>
 * </ol>
 *
 * <p>Cấu trúc JSON của workflow_config:
 * <pre>
 * {
 *   "trigger": "TICKET_CREATED",
 *   "conditions": {
 *     "logic": "AND",
 *     "criteria": [
 *       { "field": "ticket_type", "operator": "EQUALS",     "value": "INCIDENT" },
 *       { "field": "priority",    "operator": "EQUALS",     "value": "HIGH"     },
 *       { "field": "category_id", "operator": "EQUALS",     "value": "3"        }
 *     ]
 *   },
 *   "steps": [
 *     { "name": "Auto Assign",    "action": "ASSIGN_AGENT",  "role": "SUPPORT_AGENT", "sla_hours": 2  },
 *     { "name": "Set Priority",   "action": "SET_PRIORITY",  "value": "HIGH"                          },
 *     { "name": "Set Status",     "action": "SET_STATUS",    "value": "IN_PROGRESS"                   },
 *     { "name": "Notify Manager", "action": "NOTIFY",        "role": "MANAGER"                        }
 *   ]
 * }
 * </pre>
 */
public class WorkflowService {

    private static final Logger LOGGER = Logger.getLogger(WorkflowService.class.getName());

    private final WorkflowDAO workflowDAO = new WorkflowDAO();
    private final TicketDAO   ticketDAO   = new TicketDAO();
    private final UserDAO     userDAO     = new UserDAO();
    private final EmailService emailService = new EmailService();
    private final NotificationDAO notificationDAO = new NotificationDAO();
    private final Gson        gson        = new Gson();

    // -----------------------------------------------------------------------
    // Public API
    // -----------------------------------------------------------------------

    /**
     * Điểm vào chính: gọi sau khi ticket được tạo.
     *
     * @param ticket  ticket vừa được tạo (phải có ticketId, ticketType, priority, categoryId)
     */
    public void onTicketCreated(Ticket ticket) {
        triggerForTicket(ticket, "TICKET_CREATED");
    }

    /**
     * Điểm vào chính: gọi sau khi ticket được cập nhật trạng thái.
     *
     * @param ticket  ticket vừa được cập nhật
     */
    public void onTicketUpdated(Ticket ticket) {
        triggerForTicket(ticket, "TICKET_UPDATED");
    }

    /**
     * Tìm tất cả ACTIVE workflow khớp với trigger + điều kiện, sau đó thực thi steps.
     *
     * @param ticket      ticket cần xử lý
     * @param triggerType "TICKET_CREATED" | "TICKET_UPDATED" | "SLA_BREACH"
     */
    public void triggerForTicket(Ticket ticket, String triggerType) {
        if (ticket == null) return;

        List<Workflow> activeWorkflows;
        try {
            activeWorkflows = workflowDAO.getActiveWorkflows();
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "WorkflowService: cannot load active workflows", e);
            return;
        }

        for (Workflow wf : activeWorkflows) {
            String configJson = wf.getWorkflowConfig();
            if (configJson == null || configJson.isBlank()) continue;

            try {
                JsonObject cfg = gson.fromJson(configJson, JsonObject.class);

                // 1. Kiểm tra trigger
                String wfTrigger = getStringOrNull(cfg, "trigger");
                if (!triggerType.equals(wfTrigger)) continue;

                // 2. Đánh giá conditions
                if (!evaluateConditions(cfg, ticket)) continue;

                // 3. Thực thi steps
                LOGGER.info(String.format(
                        "WorkflowService: applying workflow [%d] '%s' to ticket [%d]",
                        wf.getWorkflowId(), wf.getWorkflowName(), ticket.getTicketId()));
                executeSteps(cfg, ticket);

            } catch (Exception e) {
                LOGGER.log(Level.WARNING,
                        "WorkflowService: error processing workflow id=" + wf.getWorkflowId(), e);
            }
        }
    }

    /**
     * Dành riêng cho Scheduled Task, quét các ticket đang mở và check xem có vi phạm SLA không.
     */
    public void runSlaBreachCheck() {
        List<Workflow> activeWorkflows;
        try {
            activeWorkflows = workflowDAO.getActiveWorkflows();
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "WorkflowService: cannot load workflows for SLA", e);
            return;
        }

        // 1. Lấy danh sách ticket đang mở
        List<Ticket> openTickets = ticketDAO.getOpenTicketsForSLA();
        if (openTickets == null || openTickets.isEmpty()) return;

        // 2. Lấy workflows SLA 
        List<Workflow> slaWorkflows = new ArrayList<>();
        for (Workflow wf : activeWorkflows) {
            String configJson = wf.getWorkflowConfig();
            if (configJson == null || configJson.isBlank()) continue;
            try {
                JsonObject cfg = gson.fromJson(configJson, JsonObject.class);
                if ("SLA_BREACH".equals(getStringOrNull(cfg, "trigger"))) {
                    slaWorkflows.add(wf);
                }
            } catch (Exception e) {}
        }
        if (slaWorkflows.isEmpty()) return; 

        long currentTime = System.currentTimeMillis();

        // 3. Áp dụng rules SLA
        for (Ticket ticket : openTickets) {
            for (Workflow wf : slaWorkflows) {
                try {
                    JsonObject cfg = gson.fromJson(wf.getWorkflowConfig(), JsonObject.class);
                    
                    int slaHours = 0;
                    if (cfg.has("sla_hours") && !cfg.get("sla_hours").isJsonNull()) {
                        slaHours = cfg.get("sla_hours").getAsInt();
                    } else if (cfg.has("steps") && cfg.getAsJsonArray("steps").size() > 0) {
                        JsonObject firstStep = cfg.getAsJsonArray("steps").get(0).getAsJsonObject();
                        if (firstStep.has("sla_hours") && !firstStep.get("sla_hours").isJsonNull()) {
                            slaHours = firstStep.get("sla_hours").getAsInt();
                        }
                    }

                    if (slaHours <= 0 || ticket.getCreatedAt() == null) continue;
                    
                    if (!evaluateConditions(cfg, ticket)) continue;
                    
                    // Tính giờ đã trôi qua
                    long diffHours = (currentTime - ticket.getCreatedAt().getTime()) / (1000 * 60 * 60);

                    if (diffHours >= slaHours) {
                        LOGGER.info(String.format("WorkflowService [SLA_BREACH] ticket=%d, wf=%d (passed %d h)", 
                                ticket.getTicketId(), wf.getWorkflowId(), diffHours));
                        
                        executeSteps(cfg, ticket);
                    }
                } catch (Exception e) {
                    LOGGER.log(Level.WARNING, "Error on SLA check wf=" + wf.getWorkflowId(), e);
                }
            }
        }
    }

    // -----------------------------------------------------------------------
    // Condition evaluation
    // -----------------------------------------------------------------------

    /**
     * Trả về true nếu ticket thỏa mãn tất cả/bất kỳ điều kiện của workflow.
     */
    private boolean evaluateConditions(JsonObject cfg, Ticket ticket) {
        if (!cfg.has("conditions") || cfg.get("conditions").isJsonNull()) {
            return true; // không có điều kiện → áp dụng cho tất cả
        }

        JsonObject condObj = cfg.getAsJsonObject("conditions");
        String logic = "AND";
        if (condObj.has("logic") && !condObj.get("logic").isJsonNull()) {
            logic = condObj.get("logic").getAsString();
        }

        JsonArray criteria = condObj.has("criteria") ? condObj.getAsJsonArray("criteria") : new JsonArray();
        if (criteria.size() == 0) return true;

        boolean isAnd = "AND".equalsIgnoreCase(logic);

        for (JsonElement el : criteria) {
            if (!el.isJsonObject()) continue;
            JsonObject cond = el.getAsJsonObject();

            boolean match = evaluateSingleCondition(cond, ticket);

            if (isAnd && !match) return false;  // AND: một false → toàn bộ false
            if (!isAnd && match) return true;   // OR:  một true  → toàn bộ true
        }

        // AND: tất cả đều true → true
        // OR:  không có cái nào true → false
        return isAnd;
    }

    private boolean evaluateSingleCondition(JsonObject cond, Ticket ticket) {
        String field    = getStringOrNull(cond, "field");
        String operator = getStringOrNull(cond, "operator");
        String value    = getStringOrNull(cond, "value");

        if (field == null || value == null) return true;
        if (operator == null) operator = "EQUALS";

        String ticketValue = getTicketFieldValue(ticket, field);
        if (ticketValue == null) return false;

        return switch (operator.toUpperCase()) {
            case "EQUALS"     -> ticketValue.equalsIgnoreCase(value);
            case "NOT_EQUALS" -> !ticketValue.equalsIgnoreCase(value);
            default           -> ticketValue.equalsIgnoreCase(value);
        };
    }

    /**
     * Lấy giá trị của field tương ứng từ ticket để so sánh với điều kiện.
     */
    private String getTicketFieldValue(Ticket ticket, String field) {
        return switch (field.toLowerCase()) {
            case "ticket_type"  -> ticket.getTicketType();
            case "priority"     -> ticket.getPriority();
            case "category_id"  -> String.valueOf(ticket.getCategoryId());
            case "status"       -> ticket.getStatus();
            default             -> null;
        };
    }

    // -----------------------------------------------------------------------
    // Step execution
    // -----------------------------------------------------------------------

    private void executeSteps(JsonObject cfg, Ticket ticket) {
        if (!cfg.has("steps") || cfg.get("steps").isJsonNull()) return;

        JsonArray steps = cfg.getAsJsonArray("steps");
        for (JsonElement el : steps) {
            if (!el.isJsonObject()) continue;
            JsonObject step = el.getAsJsonObject();
            String action = getStringOrNull(step, "action");
            if (action == null) continue;

            try {
                switch (action.toUpperCase()) {
                    case "ASSIGN_AGENT", "EXECUTE", "APPROVE_REJECT" -> executeAssignAgent(step, ticket);
                    case "SET_PRIORITY"  -> executeSetPriority(step, ticket);
                    case "SET_STATUS"    -> executeSetStatus(step, ticket);
                    case "NOTIFY", "REVIEW" -> executeNotify(step, ticket);
                    default              -> LOGGER.warning("WorkflowService: unknown action: " + action);
                }
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "WorkflowService: error executing step action=" + action, e);
            }
        }
    }

    private String extractTargetUsers(JsonObject step) {
        if (step.has("users") && step.get("users").isJsonArray()) {
            JsonArray usersArr = step.getAsJsonArray("users");
            StringBuilder sb = new StringBuilder();
            for (JsonElement el : usersArr) {
                if (!el.isJsonObject()) continue;
                JsonObject u = el.getAsJsonObject();
                if (u.has("fullName") && !u.get("fullName").isJsonNull()) {
                    if (sb.length() > 0) sb.append(", ");
                    sb.append(u.get("fullName").getAsString());
                }
            }
            if (sb.length() > 0) return sb.toString();
        }
        String fallback = getStringOrNull(step, "legacyRole");
        if (fallback != null) return fallback;
        return getStringOrNull(step, "role");
    }

    /**
     * ASSIGN_AGENT / EXECUTE: nếu ticket chưa được assign, gán cho người dùng đầu tiên trong danh sách (nếu có)
     * và chuyển trạng thái sang IN_PROGRESS.
     */
    private void executeAssignAgent(JsonObject step, Ticket ticket) {
        String targetUsers = extractTargetUsers(step);
        LOGGER.info(String.format(
                "WorkflowService [ASSIGN/EXECUTE] ticket=%d, target users=%s",
                ticket.getTicketId(), targetUsers));

        // Nếu ticket chưa có người assign 
        if (ticket.getAssignedTo() == null || ticket.getAssignedTo() == 0) {
            Integer assigneeId = null;
            
            if (step.has("users") && step.get("users").isJsonArray()) {
                JsonArray usersArr = step.getAsJsonArray("users");
                if (usersArr.size() > 0 && usersArr.get(0).isJsonObject()) {
                    JsonObject firstUser = usersArr.get(0).getAsJsonObject();
                    if (firstUser.has("userId") && !firstUser.get("userId").isJsonNull()) {
                        assigneeId = firstUser.get("userId").getAsInt();
                    }
                }
            }

            if (assigneeId != null && assigneeId > 0) {
                // Gán người xử lý cụ thể
                if ("INCIDENT".equalsIgnoreCase(ticket.getTicketType())) {
                    ticketDAO.assignIncidentTicket(ticket.getTicketId(), assigneeId);
                } else {
                    ticketDAO.assignServiceRequest(ticket.getTicketId(), assigneeId);
                }
                ticket.setAssignedTo(assigneeId);
                ticket.setStatus("IN_PROGRESS");
                LOGGER.info("WorkflowService [ASSIGN/EXECUTE] ticket " + ticket.getTicketId() + " assigned to userId=" + assigneeId + " & status → IN_PROGRESS");
                
                // Gửi notification cho người được xử lý luôn
                User user = userDAO.findById(assigneeId);
                if (user != null) {
                    // 1. In-app notification
                    Notification noti = new Notification();
                    noti.setUserId(user.getUserId());
                    noti.setNotificationType("TICKET");
                    noti.setTitle("Nhiệm vụ mới: Ticket #" + ticket.getTicketId());
                    noti.setMessage("Bạn vừa được tự động gán nhiệm vụ (Giao nhiệm vụ / Execute) cho Ticket #" + ticket.getTicketId() + " (" + ticket.getTicketType() + "). Vui lòng xử lý.");
                    noti.setRelatedTicketId(ticket.getTicketId());
                    noti.setSeen(false);
                    try {
                        notificationDAO.createNotification(noti);
                    } catch (SQLException e) {
                        LOGGER.log(Level.WARNING, "WorkflowService: Failed to insert in-app notification", e);
                    }

                    // 2. Email notification
                    if (user.getEmail() != null && !user.getEmail().isBlank()) {
                        String subject = "ITServiceFlow - Ticket Assigned to You: #" + ticket.getTicketId();
                        String body = "Hello " + user.getFullName() + ",\n\n" +
                                      "Ticket #" + ticket.getTicketId() + " (" + ticket.getTicketType() + ") has been auto-assigned to you by the system.\n" +
                                      "Title: " + ticket.getTitle() + "\n" +
                                      "Priority: " + ticket.getPriority() + "\n\n" +
                                      "Please log in to the system to begin processing this ticket.\n\n" +
                                      "Best regards,\nIT Service Flow Engine";
                        try {
                            emailService.sendEmail(user.getEmail(), subject, body);
                            LOGGER.info("WorkflowService: Assignment email sent to " + user.getEmail());
                        } catch (Exception e) {
                            LOGGER.log(Level.WARNING, "WorkflowService: Failed to send assignment email to " + user.getEmail(), e);
                        }
                    }
                }
            } else {
                LOGGER.info("WorkflowService [ASSIGN/EXECUTE] ticket " + ticket.getTicketId() + " -> No specific user found, status remains unchanged.");
            }
        }
    }

    /**
     * SET_PRIORITY: đặt lại priority cho ticket.
     */
    private void executeSetPriority(JsonObject step, Ticket ticket) {
        String value = getStringOrNull(step, "value");
        if (value == null || value.isBlank()) return;

        ticketDAO.updateTicketPriority(ticket.getTicketId(), value.toUpperCase());
        ticket.setPriority(value.toUpperCase());
        LOGGER.info(String.format(
                "WorkflowService [SET_PRIORITY] ticket=%d → %s",
                ticket.getTicketId(), value.toUpperCase()));
    }

    /**
     * SET_STATUS: đặt lại status cho ticket.
     */
    private void executeSetStatus(JsonObject step, Ticket ticket) {
        String value = getStringOrNull(step, "value");
        if (value == null || value.isBlank()) return;

        ticketDAO.updateTicketStatus(ticket.getTicketId(), value.toUpperCase());
        ticket.setStatus(value.toUpperCase());
        LOGGER.info(String.format(
                "WorkflowService [SET_STATUS] ticket=%d → %s",
                ticket.getTicketId(), value.toUpperCase()));
    }

    /**
     * NOTIFY: ghi log thông báo (có thể mở rộng gửi email qua EmailService).
     */
    private void executeNotify(JsonObject step, Ticket ticket) {
        String targetUsers = extractTargetUsers(step);
        LOGGER.info(String.format(
                "WorkflowService [NOTIFY/REVIEW] ticket=%d, notify users=%s",
                ticket.getTicketId(), targetUsers));
        
        if (step.has("users") && step.get("users").isJsonArray()) {
            JsonArray usersArr = step.getAsJsonArray("users");
            String subject = "ITServiceFlow - Ticket Notification: #" + ticket.getTicketId();
            String body = "Hello,\n\n" +
                          "You have been notified regarding Ticket #" + ticket.getTicketId() + " (" + ticket.getTicketType() + ").\n" +
                          "Current Status: " + ticket.getStatus() + "\n" +
                          "Priority: " + ticket.getPriority() + "\n\n" +
                          "Please review this ticket in the IT Service Flow system.\n\n" +
                          "Best regards,\nIT Service Flow Team";

            for (JsonElement el : usersArr) {
                if (!el.isJsonObject()) continue;
                JsonObject u = el.getAsJsonObject();
                if (u.has("userId") && !u.get("userId").isJsonNull()) {
                    int userId = u.get("userId").getAsInt();
                    User user = userDAO.findById(userId);
                    if (user != null) {
                        // 1. In-app notification
                        Notification noti = new Notification();
                        noti.setUserId(user.getUserId());
                        noti.setNotificationType("TICKET");
                        noti.setTitle("Thông báo theo dõi: Ticket #" + ticket.getTicketId());
                        noti.setMessage("Bạn được cấp quyền theo dõi (Chỉ xem / Review) tiến trình của Ticket #" + ticket.getTicketId() + " (Loại: " + ticket.getTicketType() + "). Không đặc tả yêu cầu thao tác.");
                        noti.setRelatedTicketId(ticket.getTicketId());
                        noti.setSeen(false);
                        try {
                            notificationDAO.createNotification(noti);
                        } catch (SQLException e) {
                            LOGGER.log(Level.WARNING, "WorkflowService: Failed to insert in-app notification", e);
                        }

                        // 2. Email notification
                        if (user.getEmail() != null && !user.getEmail().isBlank()) {
                            try {
                                emailService.sendEmail(user.getEmail(), subject, body);
                                LOGGER.info("WorkflowService: Notification email sent to " + user.getEmail());
                            } catch (Exception e) {
                                LOGGER.log(Level.WARNING, "WorkflowService: Failed to send email to " + user.getEmail(), e);
                            }
                        }
                    }
                }
            }
        }
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------

    private String getStringOrNull(JsonObject obj, String key) {
        if (obj == null || !obj.has(key) || obj.get(key).isJsonNull()) return null;
        return obj.get(key).getAsString();
    }
}
