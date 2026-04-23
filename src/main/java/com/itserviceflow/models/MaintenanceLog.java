package com.itserviceflow.models;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * Nhật ký Bảo trì IT — ghi nhận sự kiện bảo trì thiết bị (CI).
 *
 * Luồng nghiệp vụ:
 *   PENDING → CONTACTED_VENDOR → IN_PROGRESS → COMPLETED
 *   Bất kỳ trạng thái nào → CANCELLED (xóa mềm bởi admin)
 *
 * Downtime thực tế = (completed_at - started_at) tính theo phút.
 */
public class MaintenanceLog {

    private int logId;
    private int ciId;

    /** Loại bảo trì — nhập tự do, tối đa 200 ký tự */
    private String maintenanceType;

    /** Ngày thực hiện hoặc ngày lên lịch (có thể là tương lai) */
    private Date maintenanceDate;

    /** Thời điểm bắt đầu bảo trì thực tế (null = chưa bắt đầu) */
    private Timestamp startedAt;

    /** Thời điểm hoàn thành (null = chưa xong) */
    private Timestamp completedAt;

    /** Mô tả chi tiết công việc bảo trì */
    private String description;

    /** Người phụ trách thực hiện bảo trì (kỹ thuật viên) */
    private Integer performedBy;

    /** Người tạo nhật ký (có thể là admin/asset manager, khác performedBy) */
    private Integer createdBy;

    /**
     * Trạng thái xử lý:
     *   PENDING, CONTACTED_VENDOR, IN_PROGRESS, COMPLETED, CANCELLED
     */
    private String status;

    /** Soft delete: 0 = bình thường, 1 = đã xóa (ẩn khỏi danh sách) */
    private int isDeleted;

    private Timestamp createdAt;
    private Timestamp updatedAt;

    // ── Transient fields (JOIN, không lưu DB) ─────────────────────────
    private String ciName;
    private String ciStatus;          // trạng thái hiện tại của CI trong CMDB
    private String performedByName;
    private String createdByName;

    public MaintenanceLog() {}

    // ── Getters / Setters ──────────────────────────────────────────────

    public int getLogId() { return logId; }
    public void setLogId(int logId) { this.logId = logId; }

    public int getCiId() { return ciId; }
    public void setCiId(int ciId) { this.ciId = ciId; }

    public String getMaintenanceType() { return maintenanceType; }
    public void setMaintenanceType(String maintenanceType) { this.maintenanceType = maintenanceType; }

    public Date getMaintenanceDate() { return maintenanceDate; }
    public void setMaintenanceDate(Date maintenanceDate) { this.maintenanceDate = maintenanceDate; }

    public Timestamp getStartedAt() { return startedAt; }
    public void setStartedAt(Timestamp startedAt) { this.startedAt = startedAt; }

    public Timestamp getCompletedAt() { return completedAt; }
    public void setCompletedAt(Timestamp completedAt) { this.completedAt = completedAt; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Integer getPerformedBy() { return performedBy; }
    public void setPerformedBy(Integer performedBy) { this.performedBy = performedBy; }

    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getIsDeleted() { return isDeleted; }
    public void setIsDeleted(int isDeleted) { this.isDeleted = isDeleted; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getCiName() { return ciName; }
    public void setCiName(String ciName) { this.ciName = ciName; }

    public String getCiStatus() { return ciStatus; }
    public void setCiStatus(String ciStatus) { this.ciStatus = ciStatus; }

    public String getPerformedByName() { return performedByName; }
    public void setPerformedByName(String performedByName) { this.performedByName = performedByName; }

    public String getCreatedByName() { return createdByName; }
    public void setCreatedByName(String createdByName) { this.createdByName = createdByName; }

    // ── Computed helpers (dùng trong JSP) ─────────────────────────────

    /** Tính downtime thực tế (phút) từ started_at đến completed_at */
    public long getActualDowntimeMinutes() {
        if (startedAt == null || completedAt == null) return -1;
        long diffMs = completedAt.getTime() - startedAt.getTime();
        return diffMs > 0 ? diffMs / 60000 : 0;
    }

    /** Trả về true nếu ngày bảo trì là tương lai (lên lịch) */
    public boolean isScheduled() {
        if (maintenanceDate == null) return false;
        return maintenanceDate.after(new java.util.Date());
    }
}
