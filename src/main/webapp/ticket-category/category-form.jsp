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
        .f-row {
            grid-template-columns: 1fr;
        }
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

    .diff-btn:hover {
        border-color: #3c8dbc;
    }

    .diff-btn.sel-LEVEL_1 {
        border-color: #27ae60;
        background: #f0fff4;
    }

    .diff-btn.sel-LEVEL_2 {
        border-color: #dd6b20;
        background: #fffaf0;
    }

    .diff-btn.sel-LEVEL_3 {
        border-color: #c53030;
        background: #fff5f5;
    }

    .diff-btn .d-title {
        font-size: 13px;
        font-weight: 700;
    }

    .diff-btn .d-sub {
        font-size: 11px;
        color: #a0aec0;
        margin-top: 2px;
    }

    .form-actions {
        display: flex;
        gap: 10px;
        justify-content: flex-end;
        padding-top: 20px;
        border-top: 1px solid #edf2f7;
    }
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

        <div class="f-row">
            <div class="f-group">
                <label class="f-label" for="categoryName">Category Name <span
                        class="req">*</span></label>
                <input class="f-input" type="text" id="categoryName" name="categoryName"
                       value="${fn:escapeXml(cat.categoryName)}" placeholder="Hardware Issue"
                       required maxlength="120">
            </div>
            <div class="f-group">
                <label class="f-label" for="categoryCode">Category Code</label>
                <input class="f-input" type="text" id="categoryCode" name="categoryCode"
                       value="${fn:escapeXml(cat.categoryCode)}" placeholder="HW-001"
                       maxlength="30">
            </div>
        </div>

        <div class="f-row">
            <div class="f-group">
                <label class="f-label" for="categoryType">Category Type <span
                        class="req">*</span></label>
                <select class="f-input" id="categoryType" name="categoryType" required>
                    <option value="">— Select type —</option>
                    <option value="INCIDENT" ${cat.categoryType=='INCIDENT' ? 'selected' : '' }>
                        Incident</option>
                    <option value="SERVICE_REQUEST" ${cat.categoryType=='SERVICE_REQUEST'
                                                      ? 'selected' : '' }>Service Request</option>
                    <option value="CHANGE" ${cat.categoryType=='CHANGE' ? 'selected' : '' }>
                        Change</option>
                    <option value="PROBLEM" ${cat.categoryType=='PROBLEM' ? 'selected' : '' }>
                        Problem</option>
                </select>
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
    
        </div>

        <%-- Section: Routing / Difficulty --%>

        <div class="f-group">
            <label class="f-label">Độ khó <span class="req">*</span></label>
            <input type="hidden" id="difficultyLevel" name="difficultyLevel"
                   value="${cat.difficultyLevel}" required>
            <div class="diff-hints">
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
    // ── Difficulty picker ─────────────────────────────────────────────────
    function selectDiff(val) {
        document.querySelectorAll('.diff-btn').forEach(b => b.className = 'diff-btn');
        document.querySelector('.diff-btn:nth-child(' + ({LEVEL_1: 1, LEVEL_2: 2, LEVEL_3: 3}[val]) + ')').classList.add('sel-' + val);
        document.getElementById('difficultyLevel').value = val;
    }

    // ── Active toggle ─────────────────────────────────────────────────────
    const activeToggle = document.getElementById('isActiveToggle');
    const activeHidden = document.getElementById('isActiveHidden');
    const activeLbl = document.getElementById('activeLbl');
    const activeSub = document.getElementById('activeSub');

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

    // ── Client-side validation ────────────────────────────────────────────
    document.getElementById('catForm').addEventListener('submit', function (e) {
        const name = document.getElementById('categoryName').value.trim();
        const type = document.getElementById('categoryType').value;
        const diff = document.getElementById('difficultyLevel').value;
        if (!name) {
            alert('Vui lòng nhập tên danh mục.');
            e.preventDefault();
            return;
        }
        if (!type) {
            alert('Vui lòng chọn loại danh mục.');
            e.preventDefault();
            return;
        }
        if (!diff) {
            alert('Vui lòng chọn mức độ khó.');
            e.preventDefault();
            return;
        }
    });
</script>

<jsp:include page="/common/admin-layout-bottom.jsp" />