<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/includes/header.jsp" />

<style>
    .char-counter {
        font-size: 0.78rem;
        color: #6c757d;
        text-align: right;
        margin-top: 3px;
        transition: color 0.2s;
    }
    .char-counter.warning  { color: #fd7e14; font-weight: 600; }
    .char-counter.over-limit { color: #dc3545; font-weight: 700; }
    .field-hint { font-size: 0.8rem; color: #6c757d; margin-top: 3px; }
    .required { color: #dc3545; }
    textarea  { resize: vertical; }
</style>

<div class="container-fluid bg-white p-4 rounded shadow-sm" style="max-width: 820px; margin: auto;">
    <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-3">
        <h2 class="h4 text-primary m-0">
            <i class="bi bi-bug me-2"></i>
            ${not empty knownError ? 'Cập nhật lỗi đã xác định' : 'Tạo lỗi đã xác định mới'}
        </h2>
        <a href="${pageContext.request.contextPath}/known-error?action=list"
           class="btn btn-outline-secondary btn-sm">
            <i class="bi bi-arrow-left me-1"></i> Quay lại danh sách
        </a>
    </div>

    <form id="keForm"
          action="${pageContext.request.contextPath}/known-error?action=${not empty knownError ? 'update' : 'insert'}"
          method="post" novalidate>

        <c:if test="${not empty knownError}">
            <input type="hidden" name="id" value="${knownError.articleId}">
        </c:if>

        <%-- ── Tiêu đề ── --%>
        <div class="mb-3">
            <label for="title" class="form-label fw-semibold">
                Tiêu đề bài viết <span class="required">*</span>
            </label>
            <input type="text" class="form-control" id="title" name="title"
                   maxlength="255" autocomplete="off"
                   value="${knownError.title}"
                   placeholder="Mô tả ngắn gọn về lỗi đã xác định..."
                   oninput="updateCounter('title', 255)">
            <div class="d-flex justify-content-between">
                <div class="field-hint">Bắt buộc. Tối đa 255 ký tự.</div>
                <div id="title-counter" class="char-counter">0 / 255</div>
            </div>
            <div class="invalid-feedback" id="title-error"></div>
        </div>

        <%-- ── Tóm tắt ── --%>
        <div class="mb-3">
            <label for="summary" class="form-label fw-semibold">
                Tóm tắt ngắn <span class="required">*</span>
            </label>
            <textarea class="form-control" id="summary" name="summary"
                      rows="2" maxlength="500"
                      placeholder="Một câu mô tả lõi của vấn đề..."
                      oninput="updateCounter('summary', 500)">${knownError.summary}</textarea>
            <div class="d-flex justify-content-between">
                <div class="field-hint">Bắt buộc. Tối đa 500 ký tự.</div>
                <div id="summary-counter" class="char-counter">0 / 500</div>
            </div>
            <div class="invalid-feedback" id="summary-error"></div>
        </div>

        <%-- ── Triệu chứng ── --%>
        <div class="mb-3">
            <label for="symptom" class="form-label fw-semibold">
                Triệu chứng và biểu hiện lỗi <span class="required">*</span>
            </label>
            <textarea class="form-control" id="symptom" name="symptom"
                      rows="4" maxlength="3000"
                      placeholder="Thông báo lỗi nào xuất hiện? Người dùng thấy gì? Hệ thống phản hồi ra sao?"
                      oninput="updateCounter('symptom', 3000)">${knownError.symptom}</textarea>
            <div class="d-flex justify-content-between">
                <div class="field-hint">Bắt buộc. Tối đa 3.000 ký tự.</div>
                <div id="symptom-counter" class="char-counter">0 / 3000</div>
            </div>
            <div class="invalid-feedback" id="symptom-error"></div>
        </div>

        <%-- ── Nguyên nhân ── --%>
        <div class="mb-3">
            <label for="cause" class="form-label fw-semibold">Nguyên nhân gốc rễ</label>
            <textarea class="form-control" id="cause" name="cause"
                      rows="4" maxlength="3000"
                      placeholder="Tại sao điều này xảy ra? Để trống nếu chưa xác định được nguyên nhân."
                      oninput="updateCounter('cause', 3000)">${knownError.cause}</textarea>
            <div class="d-flex justify-content-between">
                <div class="field-hint">Tùy chọn. Tối đa 3.000 ký tự.</div>
                <div id="cause-counter" class="char-counter">0 / 3000</div>
            </div>
        </div>

        <%-- ── Giải pháp ── --%>
        <div class="mb-3">
            <label for="solution" class="form-label fw-semibold">
                Giải pháp tạm thời / Giải pháp vĩnh viễn <span class="required">*</span>
            </label>
            <textarea class="form-control" id="solution" name="solution"
                      rows="6" maxlength="5000"
                      placeholder="Hướng dẫn từng bước để khắc phục. Ví dụ:&#10;1. Bước 1...&#10;2. Bước 2...&#10;3. Bước 3..."
                      oninput="updateCounter('solution', 5000)">${knownError.solution}</textarea>
            <div class="d-flex justify-content-between">
                <div class="field-hint">Bắt buộc. Tối đa 5.000 ký tự.</div>
                <div id="solution-counter" class="char-counter">0 / 5000</div>
            </div>
            <div class="invalid-feedback" id="solution-error"></div>
        </div>

        <%-- ── Nội dung bổ sung ── --%>
        <div class="mb-4">
            <label for="content" class="form-label fw-semibold">
                Tài liệu tham khảo / Nội dung bổ sung
            </label>
            <textarea class="form-control" id="content" name="content"
                      rows="4" maxlength="5000"
                      placeholder="Link tài liệu, ghi chú kỹ thuật, lệnh quan trọng hoặc thông tin bổ sung..."
                      oninput="updateCounter('content', 5000)">${knownError.content}</textarea>
            <div class="d-flex justify-content-between">
                <div class="field-hint">Tùy chọn. Tối đa 5.000 ký tự.</div>
                <div id="content-counter" class="char-counter">0 / 5000</div>
            </div>
        </div>

        <div class="d-flex justify-content-end gap-2 mt-4 pt-3 border-top">
            <a href="${pageContext.request.contextPath}/known-error?action=list"
               class="btn btn-secondary">
                <i class="bi bi-x-circle me-1"></i> Hủy và quay lại
            </a>
            <button type="submit" class="btn btn-primary px-4">
                <i class="bi bi-save me-1"></i>
                ${not empty knownError ? 'Lưu cập nhật' : 'Đăng bài viết'}
            </button>
        </div>
    </form>
</div>

<script>
    // ── Cập nhật bộ đếm ký tự ────────────────────────────────
    function updateCounter(fieldId, maxLen) {
        const field   = document.getElementById(fieldId);
        const counter = document.getElementById(fieldId + '-counter');
        if (!field || !counter) return;

        const len = field.value.length;
        counter.textContent = len.toLocaleString('vi-VN') + ' / ' + maxLen.toLocaleString('vi-VN');
        counter.classList.remove('warning', 'over-limit');

        const ratio = len / maxLen;
        if (ratio >= 1)      counter.classList.add('over-limit');
        else if (ratio >= 0.85) counter.classList.add('warning');
    }

    // ── Khởi tạo counter khi trang load (để hiển thị giá trị hiện có) ──
    window.addEventListener('DOMContentLoaded', function () {
        ['title', 'summary', 'symptom', 'cause', 'solution', 'content'].forEach(function (id) {
            const limits = { title: 255, summary: 500, symptom: 3000, cause: 3000, solution: 5000, content: 5000 };
            updateCounter(id, limits[id]);
        });
    });

    // ── Validate khi submit ────────────────────────────────────
    document.getElementById('keForm').addEventListener('submit', function (e) {
        clearErrors();
        let valid = true;

        const fields = [
            { id: 'title',    label: 'Tiêu đề',   max: 255,  required: true },
            { id: 'summary',  label: 'Tóm tắt',   max: 500,  required: true },
            { id: 'symptom',  label: 'Triệu chứng',max:3000, required: true },
            { id: 'cause',    label: 'Nguyên nhân',max:3000, required: false },
            { id: 'solution', label: 'Giải pháp',  max: 5000, required: true },
            { id: 'content',  label: 'Nội dung bổ sung', max: 5000, required: false }
        ];

        fields.forEach(function (f) {
            const el  = document.getElementById(f.id);
            const val = el.value.trim();

            if (f.required && val === '') {
                showError(f.id, f.label + ' là bắt buộc và không được chỉ chứa khoảng trắng.');
                valid = false;
            } else if (val.length > f.max) {
                showError(f.id, f.label + ' vượt quá giới hạn ' + f.max.toLocaleString('vi-VN') +
                          ' ký tự (hiện tại: ' + val.length.toLocaleString('vi-VN') + ').');
                valid = false;
            }
        });

        if (!valid) {
            e.preventDefault();
            // Cuộn đến trường lỗi đầu tiên
            const firstErr = document.querySelector('.is-invalid');
            if (firstErr) firstErr.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    });

    function showError(fieldId, message) {
        const field = document.getElementById(fieldId);
        const errEl = document.getElementById(fieldId + '-error');
        if (field)  field.classList.add('is-invalid');
        if (errEl)  errEl.textContent = message;
    }

    function clearErrors() {
        document.querySelectorAll('.is-invalid').forEach(el => el.classList.remove('is-invalid'));
        document.querySelectorAll('.invalid-feedback').forEach(el => el.textContent = '');
    }
</script>

<jsp:include page="/includes/footer.jsp" />
