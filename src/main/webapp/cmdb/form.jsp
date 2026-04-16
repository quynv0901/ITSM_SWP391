<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/includes/header.jsp">
    <jsp:param name="pageTitle" value="${empty ci || isNew ? 'Add Configuration Item' : 'Edit Configuration Item'}" />
</jsp:include>

<style>
    .form-label .required { color: #dc3545; }
    .char-counter { font-size: 0.78rem; color: #6c757d; text-align: right; }
    .char-counter.over-limit { color: #dc3545; font-weight: 600; }
    .field-hint { font-size: 0.8rem; color: #6c757d; margin-top: 3px; }
</style>

<div class="container-fluid">
    <div class="row justify-content-center">
        <div class="col-lg-7 col-md-9">

            <div class="bg-white rounded shadow-sm p-4">
                <%-- Tiêu đề --%>
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h4 class="text-primary m-0">
                        <i class="bi bi-server me-2"></i>
                        <c:choose>
                            <c:when test="${empty ci || isNew}">Add New Configuration Item</c:when>
                            <c:otherwise>Edit Configuration Item #${ci.ciId}</c:otherwise>
                        </c:choose>
                    </h4>
                    <a href="${pageContext.request.contextPath}/configuration-item"
                       class="btn btn-outline-secondary btn-sm">
                        <i class="bi bi-arrow-left me-1"></i> Back to List
                    </a>
                </div>

                <%-- Thông báo lỗi server-side --%>
                <c:if test="${not empty errorMsg}">
                    <div class="alert alert-danger d-flex align-items-center" role="alert">
                        <i class="bi bi-exclamation-triangle-fill me-2 flex-shrink-0"></i>
                        <div>${errorMsg}</div>
                    </div>
                </c:if>

                <form id="ciForm" action="${pageContext.request.contextPath}/configuration-item"
                      method="POST" novalidate>
                    <input type="hidden" name="action" value="${empty ci || isNew ? 'add' : 'edit'}">
                    <c:if test="${not empty ci && !isNew}">
                        <input type="hidden" name="id" value="${ci.ciId}">
                    </c:if>

                    <%-- Name --%>
                    <div class="mb-3">
                        <label for="name" class="form-label fw-semibold">
                            Name <span class="required">*</span>
                        </label>
                        <input type="text" class="form-control" id="name" name="name"
                               maxlength="100" autocomplete="off"
                               value="${ci.name}" placeholder="e.g., Main Database Server"
                               oninput="updateCounter('name', 100)">
                        <div class="d-flex justify-content-between">
                            <div class="field-hint">Letters, numbers and basic symbols (. - _ ( ) / #) only.</div>
                            <div id="name-counter" class="char-counter">0 / 100</div>
                        </div>
                        <div class="invalid-feedback" id="name-error"></div>
                    </div>

                    <%-- Type --%>
                    <div class="mb-3">
                        <label for="type" class="form-label fw-semibold">
                            Type <span class="required">*</span>
                        </label>
                        <select class="form-select" id="type" name="type">
                            <option value="" disabled ${empty ci.type ? 'selected' : ''}>Select CI Type...</option>
                            <option value="Hardware" ${ci.type == 'Hardware' ? 'selected' : ''}>Hardware</option>
                            <option value="Software" ${ci.type == 'Software' ? 'selected' : ''}>Software</option>
                            <option value="Network"  ${ci.type == 'Network'  ? 'selected' : ''}>Network</option>
                            <option value="Service"  ${ci.type == 'Service'  ? 'selected' : ''}>Service</option>
                            <option value="Other"    ${ci.type == 'Other'    ? 'selected' : ''}>Other</option>
                        </select>
                        <div class="invalid-feedback" id="type-error"></div>
                    </div>

                    <%-- Version --%>
                    <div class="mb-3">
                        <label for="version" class="form-label fw-semibold">Version</label>
                        <input type="text" class="form-control" id="version" name="version"
                               maxlength="50" autocomplete="off"
                               value="${ci.version}" placeholder="e.g., v2.0, Ubuntu 22.04"
                               oninput="updateCounter('version', 50)">
                        <div class="d-flex justify-content-between">
                            <div class="field-hint">Optional. Max 50 characters.</div>
                            <div id="version-counter" class="char-counter">0 / 50</div>
                        </div>
                    </div>

                    <%-- Status --%>
                    <div class="mb-3">
                        <label for="status" class="form-label fw-semibold">
                            Status <span class="required">*</span>
                        </label>
                        <select class="form-select" id="status" name="status">
                            <option value="ACTIVE"   ${ci.status == 'ACTIVE'   || empty ci.status ? 'selected' : ''}>Active</option>
                            <option value="INACTIVE" ${ci.status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                            <option value="RETIRED"  ${ci.status == 'RETIRED'  ? 'selected' : ''}>Retired</option>
                        </select>
                    </div>

                    <%-- Description --%>
                    <div class="mb-4">
                        <label for="description" class="form-label fw-semibold">Description</label>
                        <textarea class="form-control" id="description" name="description"
                                  rows="4" maxlength="2000"
                                  placeholder="Brief description of this configuration item..."
                                  oninput="updateCounter('description', 2000)">${ci.description}</textarea>
                        <div class="d-flex justify-content-between">
                            <div class="field-hint">Optional. Max 2000 characters.</div>
                            <div id="description-counter" class="char-counter">0 / 2000</div>
                        </div>
                    </div>

                    <%-- Buttons --%>
                    <div class="d-flex justify-content-end gap-2">
                        <a href="${pageContext.request.contextPath}/configuration-item"
                           class="btn btn-secondary">
                            <i class="bi bi-x-circle me-1"></i>Cancel
                        </a>
                        <button type="submit" id="submitBtn" class="btn btn-primary">
                            <i class="bi bi-save me-1"></i>
                            <c:choose>
                                <c:when test="${empty ci || isNew}">Save Item</c:when>
                                <c:otherwise>Update Item</c:otherwise>
                            </c:choose>
                        </button>
                    </div>
                </form>
            </div>

        </div>
    </div>
</div>

<script>
    // ─── Bộ đếm ký tự ───────────────────────────────────────────────────────
    function updateCounter(fieldId, maxLen) {
        const field   = document.getElementById(fieldId);
        const counter = document.getElementById(fieldId + '-counter');
        if (!field || !counter) return;
        const len = field.value.length;
        counter.textContent = len + ' / ' + maxLen;
        counter.classList.toggle('over-limit', len > maxLen);
    }

    // Khởi tạo bộ đếm ngay khi tải trang (trường hợp đang edit, đã có sẵn dữ liệu)
    window.addEventListener('DOMContentLoaded', function () {
        updateCounter('name',        100);
        updateCounter('version',      50);
        updateCounter('description', 2000);
    });

    // ─── Validate client-side trước khi submit ───────────────────────────────
    document.getElementById('ciForm').addEventListener('submit', function (e) {
        let valid = true;

        // Xóa hết lỗi cũ
        clearErrors();

        const name    = document.getElementById('name').value.trim();
        const type    = document.getElementById('type').value;
        const version = document.getElementById('version').value.trim();
        const desc    = document.getElementById('description').value.trim();
        const namePattern = /^[\p{L}0-9 .\-_()\/#]+$/u;

        // Name
        if (name === '') {
            showError('name', 'Name is required.');
            valid = false;
        } else if (name.length > 100) {
            showError('name', 'Name must not exceed 100 characters.');
            valid = false;
        } else if (!namePattern.test(name)) {
            showError('name', 'Name contains invalid characters. Only letters, numbers and basic symbols (. - _ ( ) / #) are allowed.');
            valid = false;
        }

        // Type
        if (!type) {
            showError('type', 'Please select a Type.');
            valid = false;
        }

        // Version (optional)
        if (version.length > 50) {
            showError('version', 'Version must not exceed 50 characters.');
            valid = false;
        }

        // Description (optional)
        if (desc.length > 2000) {
            showError('description', 'Description must not exceed 2000 characters.');
            valid = false;
        }

        if (!valid) {
            e.preventDefault(); // chặn submit
            window.scrollTo({ top: 0, behavior: 'smooth' });
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
