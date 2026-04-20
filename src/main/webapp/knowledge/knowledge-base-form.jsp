<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/includes/header.jsp">
    <jsp:param name="pageTitle" value="${empty article.articleId ? 'Tạo bài viết mới' : 'Chỉnh sửa bài viết'}" />
</jsp:include>

<div class="container-fluid bg-white p-4 rounded shadow-sm">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="h4 text-primary m-0">
            <i class="bi bi-journal-plus me-2"></i>
            ${empty article.articleId ? 'Tạo bài viết mới' : 'Chỉnh sửa bài viết'}
        </h2>
        <a href="${pageContext.request.contextPath}/admin/knowledge-base?action=list"
           class="btn btn-outline-secondary">
            <i class="bi bi-arrow-left me-1"></i> Quay lại
        </a>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle me-2"></i>${error}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <%-- Validation error alert --%>
    <div id="validationAlert" class="alert alert-danger d-none">
        <i class="bi bi-exclamation-triangle me-2"></i>
        <strong>Vui lòng kiểm tra lại các trường sau:</strong>
        <ul id="validationList" class="mb-0 mt-1"></ul>
    </div>

    <form id="articleForm"
          action="${pageContext.request.contextPath}/admin/knowledge-base?action=${empty article.articleId ? 'add' : 'edit'}"
          method="post" novalidate>
        <input type="hidden" name="articleId" value="${article.articleId}">

        <div class="row g-4">
            <%-- LEFT --%>
            <div class="col-lg-8">
                <div class="card border-0 shadow-sm mb-4">
                    <div class="card-header bg-light fw-bold">
                        <i class="bi bi-info-circle me-2 text-primary"></i>Thông tin cơ bản
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label fw-bold">
                                Tiêu đề <span class="text-danger">*</span>
                            </label>
                            <input type="text" id="title" name="title" class="form-control"
                                   placeholder="Nhập tiêu đề..."
                                   required maxlength="255"
                                   value="${article.title}">
                            <div class="d-flex justify-content-between mt-1">
                                <div class="invalid-feedback d-block" id="titleError"></div>
                                <small id="titleCount" class="text-muted ms-auto">0/255</small>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">Mô tả bài viết</label>
                            <textarea id="summary" name="summary" class="form-control" rows="3"
                                      placeholder="Nhập mô tả bài viết..."
                                      maxlength="500">${article.summary}</textarea>
                            <div class="d-flex justify-content-between mt-1">
                                <div class="invalid-feedback d-block" id="summaryError"></div>
                                <small id="summaryCount" class="text-muted ms-auto">0/500</small>
                            </div>
                        </div>

                        <div class="mb-0">
                            <label class="form-label fw-bold">
                                Nội dung <span class="text-danger">*</span>
                            </label>
                            <textarea id="content" name="content" class="form-control" rows="12"
                                      placeholder="Viết nội dung..."
                                      required>${article.content}</textarea>
                            <div class="d-flex justify-content-between mt-1">
                                <div class="invalid-feedback d-block" id="contentError"></div>
                                <small id="contentCount" class="text-muted ms-auto">0/65535</small>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="card border-0 shadow-sm">
                    <div class="card-header bg-light fw-bold">
                        <i class="bi bi-tools me-2 text-warning"></i>Thông tin chi tiết
                        <span class="fw-normal text-muted small ms-1">(lựa chọn)</span>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Triệu chứng</label>
                            <textarea id="symptom" name="symptom" class="form-control" rows="3"
                                      placeholder="Nhập triệu chứng...">${article.symptom}</textarea>
                            <small id="symptomCount" class="text-muted">0/65535</small>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">Nguyên nhân</label>
                            <textarea id="cause" name="cause" class="form-control" rows="3"
                                      placeholder="Nguyên nhân bài viết này...">${article.cause}</textarea>
                            <small id="causeCount" class="text-muted">0/65535</small>
                        </div>

                        <div class="mb-0">
                            <label class="form-label fw-bold">Giải pháp</label>
                            <textarea id="solution" name="solution" class="form-control" rows="4"
                                      placeholder="Các bước giải pháp...">${article.solution}</textarea>
                            <small id="solutionCount" class="text-muted">0/65535</small>
                        </div>
                    </div>
                </div>
            </div>

            <%-- RIGHT --%>
            <div class="col-lg-4">
                <div class="card border-0 shadow-sm mb-4">
                    <div class="card-header bg-light fw-bold">
                        <i class="bi bi-gear me-2 text-secondary"></i>Cài đặt
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label fw-bold">
                                Loại bài viết: Thông báo của công ty
                            </label>
                        </div>
                    </div>
                </div>

                <div class="card border-0 shadow-sm">
                    <div class="card-body d-grid gap-2">
                        <button type="submit" name="submitAction" value="publish" class="btn btn-primary">
                            <i class="bi bi-save me-2"></i>Lưu
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/knowledge-base?action=list"
                           class="btn btn-outline-danger">
                            <i class="bi bi-x-circle me-2"></i>Hủy
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </form>
</div>

<script>
    // Cấu hình giới hạn ký tự
    const limits = {
        title: {max: 255, countId: 'titleCount', errorId: 'titleError', label: 'Tiêu đề'},
        summary: {max: 500, countId: 'summaryCount', errorId: 'summaryError', label: 'Mô tả bài viết'},
        content: {max: 3000, countId: 'contentCount', errorId: 'contentError', label: 'Nội dung'},
        symptom: {max: 3000, countId: 'symptomCount', errorId: null, label: 'Triệu chứng'},
        cause: {max: 3000, countId: 'causeCount', errorId: null, label: 'Nguyên nhân'},
        solution: {max: 3000, countId: 'solutionCount', errorId: null, label: 'Giải pháp'},
    };
// Kiểm tra từ độc hại trong tất cả các trường text
    const textFields = [
        {id: 'title', label: 'Tiêu đề'},
        {id: 'summary', label: 'Mô tả'},
        {id: 'content', label: 'Nội dung'},
        {id: 'symptom', label: 'Triệu chứng'},
        {id: 'cause', label: 'Nguyên nhân'},
        {id: 'solution', label: 'Giải pháp'},
    ];

    textFields.forEach(({ id, label }) => {
        const el = document.getElementById(id);
        if (!el || !el.value.trim())
            return;
        const found = containsBannedWords(el.value);
        if (found.length > 0) {
            errors.push(`${label} chứa từ không phù hợp: "${found.join('", "')}"`);
            el.classList.add('is-invalid');
            if (!firstErrorField)
                firstErrorField = el;
    }
    });
    // Cập nhật counter realtime
    function updateCounter(fieldId) {
        const cfg = limits[fieldId];
        const el = document.getElementById(fieldId);
        const countEl = document.getElementById(cfg.countId);
        if (!el || !countEl)
            return;

        const len = el.value.length;
        countEl.textContent = len + '/' + cfg.max;

        if (len > cfg.max) {
            countEl.classList.remove('text-muted');
            countEl.classList.add('text-danger', 'fw-bold');
            if (cfg.errorId) {
                document.getElementById(cfg.errorId).textContent =
                        cfg.label + ' vượt quá ' + cfg.max + ' ký tự (' + len + '/' + cfg.max + ')';
                document.getElementById(fieldId).classList.add('is-invalid');
            }
        } else {
            countEl.classList.remove('text-danger', 'fw-bold');
            countEl.classList.add('text-muted');
            if (cfg.errorId) {
                document.getElementById(cfg.errorId).textContent = '';
                document.getElementById(fieldId).classList.remove('is-invalid');
            }
        }
    }

    // Gắn event listener cho tất cả các field
    Object.keys(limits).forEach(fieldId => {
        const el = document.getElementById(fieldId);
        if (!el)
            return;
        el.addEventListener('input', () => updateCounter(fieldId));
        updateCounter(fieldId); // khởi tạo khi load trang
    });

    // Validate khi submit
    document.getElementById('articleForm').addEventListener('submit', function (e) {
        const errors = [];
        let firstErrorField = null;

        // Kiểm tra required
        const title = document.getElementById('title');
        const content = document.getElementById('content');

        if (!title.value.trim()) {
            errors.push('Tiêu đề không được để trống');
            title.classList.add('is-invalid');
            if (!firstErrorField)
                firstErrorField = title;
        }

        if (!content.value.trim()) {
            errors.push('Nội dung không được để trống');
            content.classList.add('is-invalid');
            if (!firstErrorField)
                firstErrorField = content;
        }

        // Kiểm tra giới hạn ký tự
        Object.keys(limits).forEach(fieldId => {
            const cfg = limits[fieldId];
            const el = document.getElementById(fieldId);
            if (!el)
                return;
            const len = el.value.length;
            if (len > cfg.max) {
                errors.push(cfg.label + ' vượt quá ' + cfg.max + ' ký tự (' + len + '/' + cfg.max + ')');
                el.classList.add('is-invalid');
                if (!firstErrorField)
                    firstErrorField = el;
            }
        });

        if (errors.length > 0) {
            e.preventDefault();
            const alert = document.getElementById('validationAlert');
            const list = document.getElementById('validationList');
            list.innerHTML = errors.map(e => '<li>' + e + '</li>').join('');
            alert.classList.remove('d-none');

            // Scroll lên đầu để thấy lỗi
            alert.scrollIntoView({behavior: 'smooth', block: 'start'});

            // Highlight field lỗi đầu tiên
            if (firstErrorField)
                firstErrorField.focus();
        }
    });

    // Xóa lỗi khi user sửa field
    ['title', 'content'].forEach(fieldId => {
        const el = document.getElementById(fieldId);
        if (el) {
            el.addEventListener('input', function () {
                if (this.value.trim()) {
                    this.classList.remove('is-invalid');
                }
            });
        }
    });
    // ===================== TỪ ĐỘC HẠI =====================
    const BANNED_WORDS = [
        "vãi", "chó", "mẹ kiếp", "ma túy", "pod",
        "fuck", "shit", "bitch", "asshole", "bastard", "damn"
    ];

    function containsBannedWords(text) {
        const lower = text.toLowerCase();
        return BANNED_WORDS.filter(w => lower.includes(w.toLowerCase()));
    }
</script>

<jsp:include page="/includes/footer.jsp" />