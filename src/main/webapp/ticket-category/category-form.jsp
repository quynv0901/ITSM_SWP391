<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<style>
    @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap');

    body { font-family: 'Inter', sans-serif; background-color: #f4f7f6; }
    h4 { font-family: 'Outfit', sans-serif; }

    .form-card {
        background: #fff;
        border: 1px solid #dde3ec;
        border-radius: 16px;
        padding: 30px 32px;
        box-shadow: 0 4px 15px rgba(0, 0, 0, .03);
        max-width: 780px;
        margin: 0 auto;
    }

    .form-section-title {
        font-size: 13px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: .5px;
        color: #5a6a85;
        margin-bottom: 20px;
        padding-bottom: 10px;
        border-bottom: 1px solid #edf2f7;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .f-label {
        font-size: 12px;
        font-weight: 700;
        color: #4a5568;
        margin-bottom: 5px;
        display: block;
    }

    .f-label .req {
        color: #e53e3e;
        margin-left: 2px;
    }

    .f-input {
        width: 100%;
        padding: 9px 12px;
        border: 1px solid #dde3ec;
        border-radius: 7px;
        font-size: 13.5px;
        color: #2d3748;
        background: #f9fbfd;
        transition: border-color .15s, box-shadow .15s;
        box-sizing: border-box;
    }

    .f-input:focus {
        outline: none;
        border-color: #3c8dbc;
        box-shadow: 0 0 0 3px rgba(60, 141, 188, .15);
        background: #fff;
    }

    /* ── Validation states ── */
    .f-input.is-invalid {
        border-color: #e53e3e !important;
        box-shadow: 0 0 0 3px rgba(229, 62, 62, .12) !important;
        background: #fff5f5;
    }
    .f-input.is-valid {
        border-color: #27ae60 !important;
        box-shadow: 0 0 0 3px rgba(39, 174, 96, .10) !important;
    }

    /* ── Inline error message ── */
    .f-error {
        display: none;
        align-items: center;
        gap: 5px;
        font-size: 11.5px;
        color: #e53e3e;
        font-weight: 600;
        margin-top: 5px;
        padding: 4px 8px;
        background: #fff5f5;
        border-left: 3px solid #e53e3e;
        border-radius: 0 4px 4px 0;
        animation: slideIn .2s ease;
    }
    .f-error.show { display: flex; }
    @keyframes slideIn {
        from { opacity: 0; transform: translateY(-4px); }
        to   { opacity: 1; transform: translateY(0); }
    }

    /* ── Char counter ── */
    .f-footer {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-top: 4px;
    }
    .char-counter {
        font-size: 11px;
        color: #a0aec0;
        margin-left: auto;
    }
    .char-counter.warn  { color: #dd6b20; font-weight: 600; }
    .char-counter.limit { color: #e53e3e; font-weight: 700; }

    .f-help {
        font-size: 11.5px;
        color: #a0aec0;
        margin-top: 4px;
    }

    .f-row {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 18px;
    }

    @media(max-width:600px) {
        .f-row { grid-template-columns: 1fr; }
    }

    .f-group {
        display: flex;
        flex-direction: column;
        margin-bottom: 18px;
    }

    .toggle-group {
        display: flex;
        align-items: center;
        gap: 14px;
        padding: 12px 16px;
        background: #f9fbfd;
        border: 1px solid #dde3ec;
        border-radius: 7px;
    }

    .toggle-group label {
        font-size: 13.5px;
        font-weight: 600;
        color: #2d3748;
        cursor: pointer;
        margin: 0;
    }

    .toggle-group .sub {
        font-size: 12px;
        color: #a0aec0;
    }

    .form-switch .form-check-input {
        width: 2.5em;
        height: 1.3em;
        cursor: pointer;
    }

    .form-switch .form-check-input:checked {
        background-color: #27ae60;
        border-color: #27ae60;
    }

    .diff-hints {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 10px;
        margin-top: 4px;
    }

    .diff-btn {
        border: 2px solid #dde3ec;
        border-radius: 8px;
        padding: 10px 14px;
        cursor: pointer;
        transition: all .15s;
        background: #fff;
        text-align: center;
    }

    .diff-btn:hover { border-color: #3c8dbc; }

    .diff-btn.sel-LEVEL_1 { border-color: #27ae60; background: #f0fff4; }
    .diff-btn.sel-LEVEL_2 { border-color: #dd6b20; background: #fffaf0; }
    .diff-btn.sel-LEVEL_3 { border-color: #c53030; background: #fff5f5; }
    .diff-hints.diff-invalid .diff-btn { border-color: #e53e3e !important; }

    .diff-btn .d-title { font-size: 13px; font-weight: 700; }
    .diff-btn .d-sub   { font-size: 11px; color: #a0aec0; margin-top: 2px; }

    .form-actions {
        display: flex;
        gap: 10px;
        justify-content: flex-end;
        padding-top: 20px;
        border-top: 1px solid #edf2f7;
    }

    /* ── Top-level validation banner ── */
    .validation-banner {
        display: none;
        align-items: center;
        gap: 10px;
        background: linear-gradient(135deg, #fff5f5, #ffe8e8);
        border: 1.5px solid #fc8181;
        border-radius: 10px;
        padding: 12px 16px;
        margin-bottom: 20px;
        font-size: 13px;
        color: #c53030;
        font-weight: 600;
        animation: slideIn .25s ease;
    }
    .validation-banner.show { display: flex; }
    .validation-banner .vb-icon { font-size: 18px; flex-shrink: 0; }
    .validation-banner ul { margin: 4px 0 0 0; padding-left: 18px; font-weight: 400; color: #742a2a; }
    .validation-banner ul li { margin-top: 2px; }
</style>

<%@ include file="/common/admin-layout-top.jsp" %>

<%-- Breadcrumb --%>
<nav aria-label="breadcrumb" style="margin-bottom:18px;">
    <ol class="breadcrumb mb-0" style="font-size:13px; background:none; padding:0;">
        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/ticket-category"
                                       class="text-decoration-none text-primary">Danh mục Ticket</a></li>
            <c:if test="${isEdit}">
            <li class="breadcrumb-item"><a
                    href="${pageContext.request.contextPath}/ticket-category?action=detail&id=${cat.categoryId}"
                    class="text-decoration-none text-primary">${cat.categoryName}</a></li>
            </c:if>
        <li class="breadcrumb-item active">${isEdit ? 'Chỉnh sửa' : 'Danh mục mới'}</li>
    </ol>
</nav>

<h4 class="fw-bold mb-4" style="color:#222d32;">
    <i class="bi bi-tag${isEdit ? '-fill' : ''} me-2 text-primary"></i>
    ${isEdit ? 'Chỉnh sửa Danh mục' : 'Tạo Danh mục Mới'}
</h4>

<c:if test="${not empty error}">
    <div class="alert alert-danger" role="alert">
        <strong>Error:</strong> <c:out value="${error}" />
    </div>
</c:if>

<div class="form-card">
    <form method="post" action="${pageContext.request.contextPath}/ticket-category" id="catForm"
          novalidate>
        <input type="hidden" name="action" value="${isEdit ? 'update' : 'create'}">
        <c:if test="${isEdit}"><input type="hidden" name="id" value="${cat.categoryId}"></c:if>

        <%-- Section: Basic Info --%>
        <div class="form-section-title"><i class="bi bi-info-circle-fill text-primary"></i>
            Thông tin cơ bản</div>

        <%-- Validation banner --%>
        <div class="validation-banner" id="validationBanner">
            <span class="vb-icon"><i class="bi bi-exclamation-triangle-fill"></i></span>
            <div>
                <strong>Vui lòng kiểm tra lại các trường bên dưới:</strong>
                <ul id="bannerList"></ul>
            </div>
        </div>

        <div class="f-row">
            <div class="f-group">
                <label class="f-label" for="categoryName">Category Name <span class="req">*</span></label>
                <input class="f-input" type="text" id="categoryName" name="categoryName"
                       value="${fn:escapeXml(cat.categoryName)}" placeholder="Hardware Issue"
                       maxlength="120">
                <div class="f-footer">
                    <span class="f-error" id="err-categoryName"><i class="bi bi-x-circle-fill"></i> <span class="err-text"></span></span>
                    <span class="char-counter" id="cnt-categoryName">0 / 120</span>
                </div>
            </div>
            <div class="f-group">
                <label class="f-label" for="categoryCode">Category Code <span class="req">*</span></label>
                <input class="f-input" type="text" id="categoryCode" name="categoryCode"
                       value="${fn:escapeXml(cat.categoryCode)}" placeholder="HW-001"
                       maxlength="30">
                <div class="f-footer">
                    <span class="f-error" id="err-categoryCode"><i class="bi bi-x-circle-fill"></i> <span class="err-text"></span></span>
                    <span class="char-counter" id="cnt-categoryCode">0 / 30</span>
                </div>
            </div>
        </div>

        <div class="f-row">
            <div class="f-group">
                <label class="f-label" for="categoryType">Category Type <span class="req">*</span></label>
                <select class="f-input" id="categoryType" name="categoryType">
                    <option value="">— Select type —</option>
                    <option value="INCIDENT" ${cat.categoryType=='INCIDENT' ? 'selected' : '' }>Incident</option>
                    <option value="SERVICE_REQUEST" ${cat.categoryType=='SERVICE_REQUEST' ? 'selected' : '' }>Service Request</option>
                    <option value="CHANGE" ${cat.categoryType=='CHANGE' ? 'selected' : '' }>Change</option>
                    <option value="PROBLEM" ${cat.categoryType=='PROBLEM' ? 'selected' : '' }>Problem</option>
                </select>
                <span class="f-error" id="err-categoryType"><i class="bi bi-x-circle-fill"></i> <span class="err-text"></span></span>
            </div>
            <div class="f-group">
                <label class="f-label" for="parentCategoryId">Parent Category</label>
                <select class="f-input" id="parentCategoryId" name="parentCategoryId">
                    <option value="">— None (Root Category) —</option>
                    <c:forEach var="p" items="${allCats}">
                        <option value="${p.categoryId}" ${cat.parentCategoryId==p.categoryId || param.parentId==p.categoryId ? 'selected' : ''}>${p.categoryName}<c:if test="${not empty p.categoryCode}"> (${p.categoryCode})</c:if></option>
                    </c:forEach>
                </select>
            </div>
        </div>

        <div class="f-group">
            <label class="f-label" for="description">Mô tả</label>
            <textarea class="f-input" id="description" name="description" rows="3"
                      placeholder="Mô tả danh mục này bao gồm những gì…" maxlength="500"
                      style="resize:vertical;">${fn:escapeXml(cat.description)}</textarea>
            <div class="f-footer">
                <span class="f-error" id="err-description"><i class="bi bi-x-circle-fill"></i> <span class="err-text"></span></span>
                <span class="char-counter" id="cnt-description">0 / 500</span>
            </div>
        </div>

        <%-- Section: Routing / Difficulty --%>

        <div class="f-group">
            <label class="f-label">Độ khó <span class="req">*</span></label>
            <input type="hidden" id="difficultyLevel" name="difficultyLevel"
                   value="${cat.difficultyLevel}">
            <div class="diff-hints" id="diffHints">
                <div class="diff-btn ${cat.difficultyLevel == 'LEVEL_1' ? 'sel-LEVEL_1' : ''}" onclick="selectDiff('LEVEL_1')">
                    <div class="d-title" style="color:#27ae60;">Dễ</div>
                    <div class="d-sub">Nhiệm vụ tiêu chuẩn, tác động thấp.</div>
                </div>
                <div class="diff-btn ${cat.difficultyLevel == 'LEVEL_2' ? 'sel-LEVEL_2' : ''}" onclick="selectDiff('LEVEL_2')">
                    <div class="d-title" style="color:#dd6b20;">Trung bình</div>
                    <div class="d-sub">Cần nhiều nỗ lực hơn.</div>
                </div>
                <div class="diff-btn ${cat.difficultyLevel == 'LEVEL_3' ? 'sel-LEVEL_3' : ''}" onclick="selectDiff('LEVEL_3')">
                    <div class="d-title" style="color:#c53030;">Khó</div>
                    <div class="d-sub">Độ phức tạp cao hoặc tác động quan trọng.</div>
                </div>
            </div>
            <span class="f-error" id="err-difficultyLevel" style="margin-top:6px;"><i class="bi bi-x-circle-fill"></i> <span class="err-text"></span></span>
        </div>

        <%-- Section: Status --%>
        <div class="form-section-title mt-2">Trạng thái</div>
        <div class="f-group">
            <div class="toggle-group">
                <div class="form-check form-switch mb-0">
                    <input class="form-check-input" type="checkbox" id="isActiveToggle" value="true" ${empty cat.categoryId || cat.active ? 'checked' : ''}>
                </div>
                <div>
                    <label class="mb-0 fw-semibold" for="isActiveToggle" id="activeLbl"
                           style="font-size:14px;">Active</label>
                    <div class="sub" id="activeSub">Category will appear in ticket
                        forms.</div>
                </div>
            </div>
            <input type="hidden" id="isActiveHidden" name="isActive"
                   value="${empty cat.categoryId || cat.active ? 'true' : 'false'}">
        </div>

        <%-- Actions --%>
        <div class="form-actions">
            <a href="${pageContext.request.contextPath}/${isEdit ? 'ticket-category?action=detail&id='.concat(cat.categoryId) : 'ticket-category'}"
               class="btn btn-outline-secondary btn-sm px-4">Hủy</a>
            <button type="submit" class="btn btn-primary btn-sm px-5"
                    id="submitBtn">
                <i class="bi bi-${isEdit ? 'floppy' : 'plus-circle'} me-1"></i>
                ${isEdit ? 'Lưu thay đổi' : 'Tạo danh mục'}
            </button>
        </div>
    </form>
</div>

<script>
    // ════════════════════════════════════════════════════════════
    //  DIFFICULTY PICKER
    // ════════════════════════════════════════════════════════════
    function selectDiff(val) {
        document.querySelectorAll('.diff-btn').forEach(b => b.className = 'diff-btn');
        document.querySelector('.diff-btn:nth-child(' + ({LEVEL_1: 1, LEVEL_2: 2, LEVEL_3: 3}[val]) + ')').classList.add('sel-' + val);
        document.getElementById('difficultyLevel').value = val;
        // clear error when user picks
        clearError('difficultyLevel');
        document.getElementById('diffHints').classList.remove('diff-invalid');
    }

    // ════════════════════════════════════════════════════════════
    //  ACTIVE TOGGLE
    // ════════════════════════════════════════════════════════════
    const activeToggle = document.getElementById('isActiveToggle');
    const activeHidden = document.getElementById('isActiveHidden');
    const activeLbl    = document.getElementById('activeLbl');
    const activeSub    = document.getElementById('activeSub');

    function updateToggleLabel() {
        const on = activeToggle.checked;
        activeHidden.value = on;
        activeLbl.textContent = on ? 'Active' : 'Inactive';
        activeSub.textContent = on
            ? 'Danh mục sẽ xuất hiện trong các form ticket.'
            : 'Danh mục sẽ bị ẩn khỏi các form ticket.';
        activeLbl.style.color = on ? '#27ae60' : '#a0aec0';
    }
    activeToggle.addEventListener('change', updateToggleLabel);
    updateToggleLabel();

    // ════════════════════════════════════════════════════════════
    //  CHARACTER COUNTERS
    // ════════════════════════════════════════════════════════════
    const counterFields = [
        { id: 'categoryName', max: 120 },
        { id: 'categoryCode', max: 30  },
        { id: 'description',  max: 500 }
    ];

    function updateCounter(fieldId, max) {
        const el  = document.getElementById(fieldId);
        const cnt = document.getElementById('cnt-' + fieldId);
        if (!el || !cnt) return;
        const len = el.value.length;
        cnt.textContent = len + ' / ' + max;
        cnt.className = 'char-counter';
        if (len >= max)         cnt.classList.add('limit');
        else if (len >= max * 0.85) cnt.classList.add('warn');
    }

    counterFields.forEach(function(f) {
        const el = document.getElementById(f.id);
        if (!el) return;
        updateCounter(f.id, f.max);
        el.addEventListener('input', function() {
            updateCounter(f.id, f.max);
            clearError(f.id); // clear error as user types
        });
    });

    // Also clear type error when user changes select
    document.getElementById('categoryType').addEventListener('change', function() {
        clearError('categoryType');
    });

    // ════════════════════════════════════════════════════════════
    //  VALIDATION HELPERS
    // ════════════════════════════════════════════════════════════
    function showError(fieldId, message) {
        const input = document.getElementById(fieldId);
        const err   = document.getElementById('err-' + fieldId);
        if (input) { input.classList.add('is-invalid'); input.classList.remove('is-valid'); }
        if (err)   { err.querySelector('.err-text').textContent = message; err.classList.add('show'); }
    }

    function clearError(fieldId) {
        const input = document.getElementById(fieldId);
        const err   = document.getElementById('err-' + fieldId);
        if (input) { input.classList.remove('is-invalid'); }
        if (err)   { err.classList.remove('show'); }
    }

    function markValid(fieldId) {
        const input = document.getElementById(fieldId);
        if (input) { input.classList.add('is-valid'); input.classList.remove('is-invalid'); }
    }

    // ════════════════════════════════════════════════════════════
    //  FORM SUBMIT VALIDATION
    // ════════════════════════════════════════════════════════════
    document.getElementById('catForm').addEventListener('submit', function (e) {
        // Reset all
        ['categoryName','categoryCode','categoryType','difficultyLevel','description'].forEach(clearError);
        document.getElementById('diffHints').classList.remove('diff-invalid');
        document.getElementById('validationBanner').classList.remove('show');
        document.getElementById('bannerList').innerHTML = '';

        const errors = [];

        // 1. Category Name – bắt buộc, tối đa 120 ký tự
        const name = document.getElementById('categoryName').value.trim();
        if (!name) {
            showError('categoryName', 'Tên danh mục không được để trống.');
            errors.push('Tên danh mục là bắt buộc.');
        } else if (name.length > 120) {
            showError('categoryName', 'Tối đa 120 ký tự (hiện tại: ' + name.length + ').');
            errors.push('Tên danh mục vượt quá 120 ký tự.');
        } else {
            markValid('categoryName');
        }

        // 2. Category Code – bắt buộc, tối đa 30 ký tự
        const code = document.getElementById('categoryCode').value.trim();
        if (!code) {
            showError('categoryCode', 'Category Code không được để trống.');
            errors.push('Category Code là bắt buộc.');
        } else if (code.length > 30) {
            showError('categoryCode', 'Tối đa 30 ký tự (hiện tại: ' + code.length + ').');
            errors.push('Category Code vượt quá 30 ký tự.');
        } else {
            markValid('categoryCode');
        }

        // 3. Category Type – bắt buộc
        const type = document.getElementById('categoryType').value;
        if (!type) {
            showError('categoryType', 'Vui lòng chọn loại danh mục.');
            errors.push('Category Type là bắt buộc.');
        } else {
            markValid('categoryType');
        }

        // 4. Difficulty Level – bắt buộc
        const diff = document.getElementById('difficultyLevel').value;
        if (!diff) {
            showError('difficultyLevel', 'Vui lòng chọn mức độ khó.');
            document.getElementById('diffHints').classList.add('diff-invalid');
            errors.push('Độ khó là bắt buộc.');
        }

        // 5. Description – tùy chọn, tối đa 500 ký tự
        const desc = document.getElementById('description').value;
        if (desc.length > 500) {
            showError('description', 'Mô tả tối đa 500 ký tự (hiện tại: ' + desc.length + ').');
            errors.push('Mô tả vượt quá 500 ký tự.');
        }

        if (errors.length > 0) {
            e.preventDefault();
            // Show banner
            const banner = document.getElementById('validationBanner');
            const list   = document.getElementById('bannerList');
            errors.forEach(function(msg) {
                const li = document.createElement('li');
                li.textContent = msg;
                list.appendChild(li);
            });
            banner.classList.add('show');
            // Scroll to top of form
            banner.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    });
</script>

<jsp:include page="/common/admin-layout-bottom.jsp" />