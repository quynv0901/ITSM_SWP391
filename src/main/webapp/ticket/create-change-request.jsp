<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/includes/header.jsp" />
<c:set var="fd" value="${formData}" />
<c:set var="fe" value="${fieldErrors}" />

<style>
.field-error{font-size:.875rem;color:#dc3545;margin-top:6px;}
.is-invalid-lite{border-color:#dc3545!important;}
</style>

<div class="container-fluid bg-light p-4 rounded shadow-sm mb-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="h4 text-primary m-0"><i class="bi bi-file-earmark-plus me-2"></i>Tạo yêu cầu thay đổi</h2>
        <a href="${pageContext.request.contextPath}/change-request-list/list" class="btn btn-outline-secondary btn-sm shadow-sm">
            <i class="bi bi-arrow-left"></i> Quay lại
        </a>
    </div>

    <form id="createChangeForm" action="${pageContext.request.contextPath}/change-request-list/create" method="post" accept-charset="UTF-8" novalidate onsubmit="return validateCreateChangeForm();">
        <div class="row g-4">
            <div class="col-md-8">
                <div class="card shadow-sm border-0 mb-4">
                    <div class="card-header bg-white border-bottom py-3">
                        <h6 class="mb-0 fw-bold text-dark"><i class="bi bi-info-circle me-2"></i>Thông tin chung</h6>
                    </div>
                    <div class="card-body p-4">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Tiêu đề thay đổi <span class="text-danger">*</span></label>
                            <input type="text" id="title" name="title" class="form-control border-secondary ${not empty fe.title ? 'is-invalid-lite' : ''}" value="${fd.title}" placeholder="Ví dụ: Nâng cấp RAM máy chủ cơ sở dữ liệu">
                            <div class="field-error" id="titleError">${fe.title}</div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Lý do và mô tả <span class="text-danger">*</span></label>
                            <textarea id="description" name="description" class="form-control border-secondary ${not empty fe.description ? 'is-invalid-lite' : ''}" rows="3" placeholder="Nhập lý do cần thay đổi và mô tả chi tiết...">${fd.description}</textarea>
                            <div class="field-error" id="descriptionError">${fe.description}</div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold text-warning"><i class="bi bi-shield-exclamation me-1"></i>Đánh giá tác động và rủi ro <span class="text-danger">*</span></label>
                            <textarea id="impactAssessment" name="impactAssessment" class="form-control border-warning ${not empty fe.impactAssessment ? 'is-invalid-lite' : ''}" rows="2" placeholder="Mô tả rủi ro và các hệ thống bị ảnh hưởng...">${fd.impactAssessment}</textarea>
                            <div class="field-error" id="impactAssessmentError">${fe.impactAssessment}</div>
                        </div>
                    </div>
                </div>

                <div class="card shadow-sm border-0">
                    <div class="card-header bg-white border-bottom py-3">
                        <h6 class="mb-0 fw-bold text-dark"><i class="bi bi-clipboard-check me-2"></i>Kế hoạch thực hiện</h6>
                    </div>
                    <div class="card-body p-4">
                        <div class="mb-4">
                            <label class="form-label fw-bold text-primary"><i class="bi bi-tools me-1"></i>Kế hoạch triển khai <span class="text-danger">*</span></label>
                            <textarea id="implementationPlan" name="implementationPlan" class="form-control border-primary ${not empty fe.implementationPlan ? 'is-invalid-lite' : ''}" rows="3" placeholder="Nhập các bước triển khai chi tiết...">${fd.implementationPlan}</textarea>
                            <div class="field-error" id="implementationPlanError">${fe.implementationPlan}</div>
                        </div>
                        <div class="mb-4">
                            <label class="form-label fw-bold text-danger"><i class="bi bi-arrow-counterclockwise me-1"></i>Kế hoạch hoàn tác <span class="text-danger">*</span></label>
                            <textarea id="rollbackPlan" name="rollbackPlan" class="form-control border-danger ${not empty fe.rollbackPlan ? 'is-invalid-lite' : ''}" rows="3" placeholder="Nhập kế hoạch khôi phục khi có sự cố...">${fd.rollbackPlan}</textarea>
                            <div class="field-error" id="rollbackPlanError">${fe.rollbackPlan}</div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold text-success"><i class="bi bi-check2-square me-1"></i>Kế hoạch kiểm thử</label>
                            <textarea id="testPlan" name="testPlan" class="form-control border-success" rows="2" placeholder="Nhập các bước kiểm thử sau triển khai...">${fd.testPlan}</textarea>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card shadow-sm border-0 mb-4">
                    <div class="card-body p-4">
                        <h6 class="fw-bold text-dark border-bottom pb-2 mb-3"><i class="bi bi-tags me-2"></i>Phân loại</h6>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Loại thay đổi</label>
                            <select name="changeType" class="form-select border-secondary">
                                <option value="STANDARD" ${fd.changeType eq 'STANDARD' ? 'selected' : ''}>Chuẩn (rủi ro thấp, đã duyệt sẵn)</option>
                                <option value="NORMAL" ${empty fd.changeType or fd.changeType eq 'NORMAL' ? 'selected' : ''}>Thông thường (cần CAB duyệt)</option>
                                <option value="EMERGENCY" ${fd.changeType eq 'EMERGENCY' ? 'selected' : ''}>Khẩn cấp</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Mức độ rủi ro</label>
                            <select name="riskLevel" class="form-select border-secondary">
                                <option value="LOW" ${fd.riskLevel eq 'LOW' ? 'selected' : ''}>Thấp</option>
                                <option value="MEDIUM" ${empty fd.riskLevel or fd.riskLevel eq 'MEDIUM' ? 'selected' : ''}>Trung bình</option>
                                <option value="HIGH" ${fd.riskLevel eq 'HIGH' ? 'selected' : ''}>Cao</option>
                                <option value="CRITICAL" ${fd.riskLevel eq 'CRITICAL' ? 'selected' : ''}>Rất cao</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Mức độ ưu tiên</label>
                            <select name="priority" class="form-select border-secondary">
                                <option value="LOW" ${fd.priority eq 'LOW' ? 'selected' : ''}>Thấp</option>
                                <option value="MEDIUM" ${empty fd.priority or fd.priority eq 'MEDIUM' ? 'selected' : ''}>Trung bình</option>
                                <option value="HIGH" ${fd.priority eq 'HIGH' ? 'selected' : ''}>Cao</option>
                                <option value="CRITICAL" ${fd.priority eq 'CRITICAL' ? 'selected' : ''}>Khẩn cấp</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="card shadow-sm border-0 mb-4 border-top border-4 border-info">
                    <div class="card-body p-4">
                        <h6 class="fw-bold text-dark border-bottom pb-2 mb-3"><i class="bi bi-calendar-event me-2"></i>Lịch thực hiện</h6>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Thời gian bắt đầu dự kiến <span class="text-danger">*</span></label>
                            <input type="datetime-local" id="scheduledStart" name="scheduledStart" class="form-control border-secondary ${not empty fe.scheduledStart ? 'is-invalid-lite' : ''}" value="${not empty fd.scheduledStart ? fd.scheduledStart.toLocalDateTime().toString().substring(0,16) : ''}">
                            <div class="field-error" id="scheduledStartError">${fe.scheduledStart}</div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Thời gian kết thúc dự kiến <span class="text-danger">*</span></label>
                            <input type="datetime-local" id="scheduledEnd" name="scheduledEnd" class="form-control border-secondary ${not empty fe.scheduledEnd ? 'is-invalid-lite' : ''}" value="${not empty fd.scheduledEnd ? fd.scheduledEnd.toLocalDateTime().toString().substring(0,16) : ''}">
                            <div class="field-error" id="scheduledEndError">${fe.scheduledEnd}</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="mt-4 d-flex gap-2">
            <button type="submit" class="btn btn-primary"><i class="bi bi-save me-1"></i>Tạo yêu cầu thay đổi</button>
            <a href="${pageContext.request.contextPath}/change-request-list/list" class="btn btn-outline-secondary">Hủy</a>
        </div>
    </form>
</div>

<script>
function setFieldError(id, message) {
    const el = document.getElementById(id);
    const input = document.getElementById(id.replace('Error', ''));
    if (el) el.textContent = message || '';
    if (input) {
        if (message) input.classList.add('is-invalid-lite');
        else input.classList.remove('is-invalid-lite');
    }
}
function validateCreateChangeForm() {
    let valid = true;
    ['title','description','impactAssessment','implementationPlan','rollbackPlan','scheduledStart','scheduledEnd'].forEach(function(id){
        setFieldError(id + 'Error', '');
    });

    const title = document.getElementById('title').value.trim();
    const description = document.getElementById('description').value.trim();
    const impactAssessment = document.getElementById('impactAssessment').value.trim();
    const implementationPlan = document.getElementById('implementationPlan').value.trim();
    const rollbackPlan = document.getElementById('rollbackPlan').value.trim();
    const scheduledStart = document.getElementById('scheduledStart').value.trim();
    const scheduledEnd = document.getElementById('scheduledEnd').value.trim();

    if (!title) { setFieldError('titleError', 'Tiêu đề thay đổi không được để trống.'); valid = false; }
    if (!description) { setFieldError('descriptionError', 'Lý do và mô tả không được để trống.'); valid = false; }
    if (!impactAssessment) { setFieldError('impactAssessmentError', 'Đánh giá tác động và rủi ro không được để trống.'); valid = false; }
    if (!implementationPlan) { setFieldError('implementationPlanError', 'Kế hoạch triển khai không được để trống.'); valid = false; }
    if (!rollbackPlan) { setFieldError('rollbackPlanError', 'Kế hoạch hoàn tác không được để trống.'); valid = false; }
    if (!scheduledStart) { setFieldError('scheduledStartError', 'Vui lòng chọn thời gian bắt đầu dự kiến.'); valid = false; }
    if (!scheduledEnd) { setFieldError('scheduledEndError', 'Vui lòng chọn thời gian kết thúc dự kiến.'); valid = false; }

    if (scheduledStart) {
        const now = new Date();
        const start = new Date(scheduledStart);
        if (start.getTime() < now.getTime()) {
            setFieldError('scheduledStartError', 'Thời gian bắt đầu dự kiến không được nằm trong quá khứ.');
            valid = false;
        }
    }

    if (scheduledStart && scheduledEnd) {
        const start = new Date(scheduledStart);
        const end = new Date(scheduledEnd);
        if (end.getTime() < start.getTime()) {
            setFieldError('scheduledEndError', 'Thời gian kết thúc dự kiến phải lớn hơn hoặc bằng thời gian bắt đầu dự kiến.');
            valid = false;
        }
    }

    return valid;
}
</script>

<jsp:include page="/includes/footer.jsp" />
