<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/includes/header.jsp" />

<div class="container-fluid bg-light p-4 rounded shadow-sm mb-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="h4 text-primary m-0"><i class="bi bi-file-earmark-plus me-2"></i>Tạo yêu cầu thay đổi</h2>
        <a href="${pageContext.request.contextPath}/change-request-list/list" class="btn btn-outline-secondary btn-sm shadow-sm">
            <i class="bi bi-arrow-left"></i> Quay lại
        </a>
    </div>

    <form action="${pageContext.request.contextPath}/change-request-list/create" method="post" accept-charset="UTF-8" onsubmit="return validateChangeDateTime();">
        <div class="row g-4">
            <div class="col-md-8">
                <div class="card shadow-sm border-0 mb-4">
                    <div class="card-header bg-white border-bottom py-3">
                        <h6 class="mb-0 fw-bold text-dark"><i class="bi bi-info-circle me-2"></i>Thông tin chung</h6>
                    </div>
                    <div class="card-body p-4">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Tiêu đề thay đổi <span class="text-danger">*</span></label>
                            <input type="text" name="title" class="form-control border-secondary" required placeholder="Ví dụ: Nâng cấp RAM máy chủ cơ sở dữ liệu">
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Lý do và mô tả <span class="text-danger">*</span></label>
                            <textarea name="description" class="form-control border-secondary" rows="3" required placeholder="Nhập lý do cần thay đổi và mô tả chi tiết..."></textarea>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold text-warning"><i class="bi bi-shield-exclamation me-1"></i>Đánh giá tác động và rủi ro <span class="text-danger">*</span></label>
                            <textarea name="impactAssessment" class="form-control border-warning" rows="2" required placeholder="Mô tả rủi ro và các hệ thống bị ảnh hưởng..."></textarea>
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
                            <textarea name="implementationPlan" class="form-control border-primary" rows="3" required placeholder="Nhập các bước triển khai chi tiết..."></textarea>
                        </div>
                        <div class="mb-4">
                            <label class="form-label fw-bold text-danger"><i class="bi bi-arrow-counterclockwise me-1"></i>Kế hoạch hoàn tác <span class="text-danger">*</span></label>
                            <textarea name="rollbackPlan" class="form-control border-danger" rows="3" required placeholder="Nhập kế hoạch khôi phục khi có sự cố..."></textarea>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold text-success"><i class="bi bi-check2-square me-1"></i>Kế hoạch kiểm thử</label>
                            <textarea name="testPlan" class="form-control border-success" rows="2" placeholder="Nhập các bước kiểm thử sau triển khai..."></textarea>
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
                                <option value="STANDARD">Chuẩn (rủi ro thấp, đã duyệt sẵn)</option>
                                <option value="NORMAL" selected>Thông thường (cần CAB duyệt)</option>
                                <option value="EMERGENCY">Khẩn cấp</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Mức độ rủi ro</label>
                            <select name="riskLevel" class="form-select border-secondary">
                                <option value="LOW">Thấp</option>
                                <option value="MEDIUM" selected>Trung bình</option>
                                <option value="HIGH">Cao</option>
                                <option value="CRITICAL">Rất cao</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Mức độ ưu tiên</label>
                            <select name="priority" class="form-select border-secondary">
                                <option value="LOW">Thấp</option>
                                <option value="MEDIUM" selected>Trung bình</option>
                                <option value="HIGH">Cao</option>
                                <option value="CRITICAL">Khẩn cấp</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="card shadow-sm border-0 mb-4 border-top border-4 border-info">
                    <div class="card-body p-4">
                        <h6 class="fw-bold text-dark border-bottom pb-2 mb-3"><i class="bi bi-calendar-event me-2"></i>Lịch thực hiện</h6>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Thời gian bắt đầu dự kiến</label>
                            <input type="datetime-local" id="scheduledStart" name="scheduledStart" class="form-control border-secondary" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Thời gian kết thúc dự kiến</label>
                            <input type="datetime-local" id="scheduledEnd" name="scheduledEnd" class="form-control border-secondary" required>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div id="dateTimeErrorMessage" class="alert alert-danger d-none mt-4 mb-0"></div>

        <div class="mt-4 d-flex gap-2">
            <button type="submit" class="btn btn-primary"><i class="bi bi-save me-1"></i>Tạo yêu cầu thay đổi</button>
            <a href="${pageContext.request.contextPath}/change-request-list/list" class="btn btn-outline-secondary">Hủy</a>
        </div>
    </form>
</div>


<script>
function validateChangeDateTime() {
    const startInput = document.getElementById('scheduledStart');
    const endInput = document.getElementById('scheduledEnd');
    const errorBox = document.getElementById('dateTimeErrorMessage');

    if (!startInput || !endInput || !errorBox) {
        return true;
    }

    errorBox.classList.add('d-none');
    errorBox.textContent = '';

    const startValue = startInput.value ? startInput.value.trim() : '';
    const endValue = endInput.value ? endInput.value.trim() : '';

    if (startValue === '' || endValue === '') {
        errorBox.textContent = 'Vui lòng nhập đầy đủ thời gian bắt đầu dự kiến và thời gian kết thúc dự kiến.';
        errorBox.classList.remove('d-none');
        return false;
    }

    const start = new Date(startValue);
    const end = new Date(endValue);

    if (isNaN(start.getTime()) || isNaN(end.getTime())) {
        errorBox.textContent = 'Định dạng ngày giờ không hợp lệ.';
        errorBox.classList.remove('d-none');
        return false;
    }

    const startDateOnly = startValue.split('T')[0];
    const endDateOnly = endValue.split('T')[0];
    const startTimeOnly = startValue.split('T')[1];
    const endTimeOnly = endValue.split('T')[1];

    if (endDateOnly < startDateOnly) {
        errorBox.textContent = 'Ngày kết thúc dự kiến không được nhỏ hơn ngày bắt đầu dự kiến.';
        errorBox.classList.remove('d-none');
        return false;
    }

    if (endDateOnly === startDateOnly && endTimeOnly < startTimeOnly) {
        errorBox.textContent = 'Nếu cùng một ngày, thời gian kết thúc dự kiến phải lớn hơn hoặc bằng thời gian bắt đầu dự kiến.';
        errorBox.classList.remove('d-none');
        return false;
    }

    if (end.getTime() < start.getTime()) {
        errorBox.textContent = 'Thời gian kết thúc dự kiến phải lớn hơn hoặc bằng thời gian bắt đầu dự kiến.';
        errorBox.classList.remove('d-none');
        return false;
    }

    return true;
}
</script>

<jsp:include page="/includes/footer.jsp" />

