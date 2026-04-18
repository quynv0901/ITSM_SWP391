package com.itserviceflow.models;

import java.sql.Timestamp;

public class CiRelationship {

    private int    relationshipId;
    private int    parentCiId;
    private int    childCiId;
    private String relationshipType;
    private String description;
    private Timestamp createdAt;

    // Display fields populated from JOIN
    private String parentCiName;
    private String childCiName;
    private String parentCiStatus;   // ACTIVE | INACTIVE | RETIRED
    private String childCiStatus;    // ACTIVE | INACTIVE | RETIRED

    public CiRelationship() {}

    // ── Getters & Setters ─────────────────────────────────────────────────

    public int getRelationshipId() { return relationshipId; }
    public void setRelationshipId(int relationshipId) { this.relationshipId = relationshipId; }

    public int getParentCiId() { return parentCiId; }
    public void setParentCiId(int parentCiId) { this.parentCiId = parentCiId; }

    public int getChildCiId() { return childCiId; }
    public void setChildCiId(int childCiId) { this.childCiId = childCiId; }

    public String getRelationshipType() { return relationshipType; }
    public void setRelationshipType(String relationshipType) { this.relationshipType = relationshipType; }

    /** Nhãn tiếng Việt cho kiểu quan hệ. */
    public String getRelationshipTypeLabel() {
        if (relationshipType == null) return "";
        return switch (relationshipType) {
            case "DEPENDS_ON"    -> "Phụ thuộc vào";
            case "CONNECTED_TO"  -> "Kết nối tới";
            case "RUNS_ON"       -> "Chạy trên";
            case "HOSTED_BY"     -> "Được lưu trữ bởi";
            case "PART_OF"       -> "Là một phần của";
            default              -> relationshipType;
        };
    }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getParentCiName() { return parentCiName; }
    public void setParentCiName(String parentCiName) { this.parentCiName = parentCiName; }

    public String getChildCiName() { return childCiName; }
    public void setChildCiName(String childCiName) { this.childCiName = childCiName; }

    public String getParentCiStatus() { return parentCiStatus; }
    public void setParentCiStatus(String parentCiStatus) { this.parentCiStatus = parentCiStatus; }

    public String getChildCiStatus() { return childCiStatus; }
    public void setChildCiStatus(String childCiStatus) { this.childCiStatus = childCiStatus; }

    /**
     * Kiểm tra quan hệ này có rủi ro không:
     * rủi ro = CI cha (có vai trò cung cấp) đang INACTIVE hoặc RETIRED.
     */
    public boolean isParentAtRisk() {
        return "INACTIVE".equals(parentCiStatus) || "RETIRED".equals(parentCiStatus);
    }

    /**
     * CI con hiện có đang phụ thuộc vào một CI cha không lành mạnh không?
     * Trả true nếu CI cha của quan hệ này là INACTIVE hoặc RETIRED.
     */
    public boolean isRiskyDependency() {
        boolean impacting = "DEPENDS_ON".equals(relationshipType)
                || "RUNS_ON".equals(relationshipType)
                || "HOSTED_BY".equals(relationshipType)
                || "PART_OF".equals(relationshipType);
        return impacting && isParentAtRisk();
    }
}
