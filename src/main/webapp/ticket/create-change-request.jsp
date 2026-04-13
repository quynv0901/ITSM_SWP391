<jsp:include page="/includes/header.jsp" />
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<div class="container-fluid bg-light p-4 rounded shadow-sm mb-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="h4 text-primary m-0"><i class="bi bi-file-earmark-plus me-2"></i>Create Request for Change (RFC)</h2>
        <a href="${pageContext.request.contextPath}/change-request/list" class="btn btn-outline-secondary btn-sm shadow-sm">
            <i class="bi bi-arrow-left"></i> Cancel
        </a>
    </div>

    <c:if test="${not empty sessionScope.error}">
        <div class="alert alert-danger"><i class="bi bi-exclamation-triangle-fill me-2"></i> ${sessionScope.error}</div>
        <c:remove var="error" scope="session"/>
    </c:if>

    <form action="${pageContext.request.contextPath}/change-request/create" method="post">
        <div class="row g-4">
            <%-- CỘT TRÁI: THÔNG TIN CHUNG & KẾ HOẠCH --%>
            <div class="col-md-8">
                <div class="card shadow-sm border-0 mb-4">
                    <div class="card-header bg-white border-bottom py-3">
                        <h6 class="mb-0 fw-bold text-dark"><i class="bi bi-info-circle me-2"></i>General Information</h6>
                    </div>
                    <div class="card-body p-4">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Change Title <span class="text-danger">*</span></label>
                            <input type="text" name="title" class="form-control border-secondary" required placeholder="Ví dụ: Nâng cấp RAM máy chủ Database">
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Reason & Description <span class="text-danger">*</span></label>
                            <textarea name="description" class="form-control border-secondary" rows="3" required placeholder="Lý do cần thay đổi và mô tả chi tiết..."></textarea>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold text-warning"><i class="bi bi-shield-exclamation me-1"></i>Impact & Risk Assessment <span class="text-danger">*</span></label>
                            <textarea name="impactAssessment" class="form-control border-warning" rows="2" required placeholder="Đánh giá rủi ro và các hệ thống bị ảnh hưởng..."></textarea>
                        </div>
                    </div>
                </div>

                <div class="card shadow-sm border-0">
                    <div class="card-header bg-white border-bottom py-3">
                        <h6 class="mb-0 fw-bold text-dark"><i class="bi bi-clipboard-check me-2"></i>Action Plans</h6>
                    </div>
                    <div class="card-body p-4">
                        <div class="mb-4">
                            <label class="form-label fw-bold text-primary"><i class="bi bi-tools me-1"></i>Implementation Plan <span class="text-danger">*</span></label>
                            <textarea name="implementationPlan" class="form-control border-primary" rows="3" required placeholder="Các bước triển khai cụ thể..."></textarea>
                        </div>
                        <div class="mb-4">
                            <label class="form-label fw-bold text-danger"><i class="bi bi-arrow-counterclockwise me-1"></i>Rollback Plan <span class="text-danger">*</span></label>
                            <textarea name="rollbackPlan" class="form-control border-danger" rows="3" required placeholder="Kế hoạch khôi phục nếu xảy ra sự cố..."></textarea>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold text-success"><i class="bi bi-check2-square me-1"></i>Test Plan</label>
                            <textarea name="testPlan" class="form-control border-success" rows="2" placeholder="Các bước kiểm tra sau khi triển khai..."></textarea>
                        </div>
                    </div>
                </div>
            </div>

            <%-- CỘT PHẢI: PHÂN LOẠI & LỊCH TRÌNH --%>
            <div class="col-md-4">
                <div class="card shadow-sm border-0 mb-4">
                    <div class="card-body p-4">
                        <h6 class="fw-bold text-dark border-bottom pb-2 mb-3"><i class="bi bi-tags me-2"></i>Classification</h6>
                        
                        <div class="mb-3">
                            <label class="form-label fw-bold">Change Type</label>
                            <select name="changeType" class="form-select border-secondary">
                                <option value="STANDARD">Standard (Rủi ro thấp, đã duyệt trước)</option>
                                <option value="NORMAL" selected>Normal (Cần CAB duyệt)</option>
                                <option value="EMERGENCY">Emergency (Khẩn cấp)</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Risk Level</label>
                            <select name="riskLevel" class="form-select border-secondary">
                                <option value="LOW">Low</option>
                                <option value="MEDIUM" selected>Medium</option>
                                <option value="HIGH">High</option>
                                <option value="CRITICAL">Critical</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Priority</label>
                            <select name="priority" class="form-select border-secondary">
                                <option value="LOW">Low</option>
                                <option value="MEDIUM" selected>Medium</option>
                                <option value="HIGH">High</option>
                                <option value="CRITICAL">Critical</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="card shadow-sm border-0 mb-4 border-top border-4 border-info">
                    <div class="card-body p-4">
                        <h6 class="fw-bold text-dark border-bottom pb-2 mb-3"><i class="bi bi-calendar-event me-2"></i>Schedule</h6>
                        
                        <div class="mb-3">
                            <label class="form-label fw-bold">Scheduled Start</label>
                            <input type="datetime-local" name="scheduledStart" class="form-control border-secondary" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Scheduled End</label>
                            <input type="datetime-local" name="scheduledEnd" class="form-control border-secondary" required>
                        </div>
                        
                        <hr>
                        
                        <div class="mb-3">
                            <label class="form-label fw-bold">Downtime Required?</label>
                            <select name="downtimeRequired" class="form-select border-secondary">
                                <option value="false">No</option>
                                <option value="true">Yes</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Est. Downtime (Hours)</label>
                            <input type="number" step="0.1" name="estimatedDowntimeHour" class="form-control border-secondary" placeholder="Ví dụ: 1.5">
                        </div>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary w-100 shadow-sm py-2 fw-bold fs-5">
                    <i class="bi bi-send-check me-2"></i> Submit Change Request
                </button>
            </div>
        </div>
    </form>
</div>

<jsp:include page="/includes/footer.jsp" />