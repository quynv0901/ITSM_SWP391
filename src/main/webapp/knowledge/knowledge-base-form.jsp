<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
<jsp:include page="/includes/header.jsp">
    <jsp:param name="pageTitle" value="${empty article.articleId ? 'Tạo bài viết mới' : 'Chỉnh sửa bài viết'}" />
</jsp:include>

<div class="container-fluid bg-white p-4 rounded shadow-sm">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="h4 text-primary m-0">
            <i class="bi bi-journal-plus me-2"></i>
            ${empty article.articleId ? 'Tạo bài viết mới' : 'Chỉnh sửa bài viết'}
        </h2>
        <a href="${pageContext.request.contextPath}/support-agent/knowledge-article?action=list"
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
          action="${pageContext.request.contextPath}/support-agent/knowledge-article?action=${empty article.articleId ? 'add' : 'edit'}"
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
                                      placeholder="Nhập mô tả..."
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
                                      placeholder="Viết nội dung bài viết..."
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
                        <i class="bi bi-tools me-2 text-warning"></i>Thông tin kỹ thuật
                        <span class="fw-normal text-muted small ms-1">(optional)</span>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Mã lỗi</label>
                            <select name="errorCode" id="errorCode" class="form-select" style="width:100%">
                                <option value="">-- Chọn mã lỗi đã biết --</option>
                                <c:forEach var="ke" items="${knownErrors}">
                                    <option value="${ke.articleNumber}"
                                            ${article.errorCode == ke.articleNumber ? 'selected' : ''}>
                                        ${ke.articleNumber} - ${ke.title}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">Triệu chứng</label>
                            <textarea id="symptom" name="symptom" class="form-control" rows="3"
                                      placeholder="Mô tả triệu chứng...">${article.symptom}</textarea>
                            <small id="symptomCount" class="text-muted">0/65535</small>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">Nguyên nhân</label>
                            <textarea id="cause" name="cause" class="form-control" rows="3"
                                      placeholder="Nguyên nhân gây ra lỗi này là gì...">${article.cause}</textarea>
                            <small id="causeCount" class="text-muted">0/65535</small>
                        </div>

                        <div class="mb-0">
                            <label class="form-label fw-bold">Giải pháp</label>
                            <textarea id="solution" name="solution" class="form-control" rows="4"
                                      placeholder="Các bước sửa lỗi...">${article.solution}</textarea>
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
                                Loại bài viết: Cơ sở kiến thức
                            </label>
                        </div>
                    </div>
                </div>

                <div class="card border-0 shadow-sm">
                    <div class="card-body d-grid gap-2">
                        <button type="submit" name="submitAction" value="publish" class="btn btn-primary">
                            <i class="bi bi-save me-2"></i>Lưu
                        </button>
                        <a href="${pageContext.request.contextPath}/support-agent/knowledge-article?action=list"
                           class="btn btn-outline-danger">
                            <i class="bi bi-x-circle me-2"></i>Hủy
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </form>
</div>

<jsp:include page="/includes/footer.jsp" />

<script>
    $(document).ready(function () {
        $('#errorCode').select2({
            placeholder: '-- Chọn mã lỗi đã sửa --',
            allowClear: true,
            width: '100%'
        });
    });

    const limits = {
        title:    { max: 255,   countId: 'titleCount',   errorId: 'titleError',   label: 'Tiêu đề' },
        summary:  { max: 500,   countId: 'summaryCount', errorId: 'summaryError', label: 'Mô tả bài viết' },
        content:  { max: 3000, countId: 'contentCount', errorId: 'contentError', label: 'Nội dung' },
        symptom:  { max: 3000, countId: 'symptomCount', errorId: null,           label: 'Triệu chứng' },
        cause:    { max: 3000, countId: 'causeCount',   errorId: null,           label: 'Nguyên nhân' },
        solution: { max: 3000, countId: 'solutionCount',errorId: null,           label: 'Giải pháp' },
    };

    function updateCounter(fieldId) {
        const cfg = limits[fieldId];
        const el = document.getElementById(fieldId);
        const countEl = document.getElementById(cfg.countId);
        if (!el || !countEl) return;

        const len = el.value.length;
        countEl.textContent = len + '/' + cfg.max;

        if (len > cfg.max) {
            countEl.classList.remove('text-muted');
            countEl.classList.add('text-danger', 'fw-bold');
            if (cfg.errorId) {
                document.getElementById(cfg.errorId).textContent =
                    cfg.label + ' vượt quá ' + cfg.max + ' ký tự (' + len + '/' + cfg.max + ')';
                el.classList.add('is-invalid');
            }
        } else {
            countEl.classList.remove('text-danger', 'fw-bold');
            countEl.classList.add('text-muted');
            if (cfg.errorId) {
                document.getElementById(cfg.errorId).textContent = '';
                el.classList.remove('is-invalid');
            }
        }
    }

    Object.keys(limits).forEach(fieldId => {
        const el = document.getElementById(fieldId);
        if (!el) return;
        el.addEventListener('input', () => updateCounter(fieldId));
        updateCounter(fieldId);
    });

    document.getElementById('articleForm').addEventListener('submit', function(e) {
        const errors = [];
        let firstErrorField = null;

        const title = document.getElementById('title');
        const content = document.getElementById('content');

        if (!title.value.trim()) {
            errors.push('Tiêu đề không được để trống');
            title.classList.add('is-invalid');
            if (!firstErrorField) firstErrorField = title;
        }

        if (!content.value.trim()) {
            errors.push('Nội dung không được để trống');
            content.classList.add('is-invalid');
            if (!firstErrorField) firstErrorField = content;
        }

        Object.keys(limits).forEach(fieldId => {
            const cfg = limits[fieldId];
            const el = document.getElementById(fieldId);
            if (!el) return;
            const len = el.value.length;
            if (len > cfg.max) {
                errors.push(cfg.label + ' vượt quá ' + cfg.max + ' ký tự (' + len + '/' + cfg.max + ')');
                el.classList.add('is-invalid');
                if (!firstErrorField) firstErrorField = el;
            }
        });

        if (errors.length > 0) {
            e.preventDefault();
            const alert = document.getElementById('validationAlert');
            const list = document.getElementById('validationList');
            list.innerHTML = errors.map(err => '<li>' + err + '</li>').join('');
            alert.classList.remove('d-none');
            alert.scrollIntoView({ behavior: 'smooth', block: 'start' });
            if (firstErrorField) firstErrorField.focus();
        }
    });

    ['title', 'content'].forEach(fieldId => {
        const el = document.getElementById(fieldId);
        if (el) {
            el.addEventListener('input', function() {
                if (this.value.trim()) this.classList.remove('is-invalid');
            });
        }
    });
</script>