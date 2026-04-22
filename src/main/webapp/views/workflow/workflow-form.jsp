<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ page import="com.google.gson.Gson" %>
        <%@ page import="java.util.List" %>
            <% Gson gson=new Gson(); %>
                <%@ include file="/common/admin-layout-top.jsp" %>

                    <!-- Font Awesome 6 -->
                    <link rel="stylesheet"
                        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css"
                        crossorigin="anonymous" />

                    <style>
                        /* ===== VALIDATION STYLES ===== */
                        .validation-summary {
                            display: none;
                            background: #fff5f5;
                            border: 1.5px solid #f87171;
                            border-radius: 10px;
                            padding: 16px 20px;
                            margin-bottom: 20px;
                            animation: slideInDown 0.25s ease;
                        }
                        .validation-summary.show { display: block; }
                        .validation-summary .vs-title {
                            font-weight: 700;
                            color: #b91c1c;
                            font-size: 0.95rem;
                            margin-bottom: 8px;
                            display: flex;
                            align-items: center;
                            gap: 8px;
                        }
                        .validation-summary ul {
                            margin: 0;
                            padding-left: 20px;
                        }
                        .validation-summary ul li {
                            color: #7f1d1d;
                            font-size: 0.88rem;
                            line-height: 1.7;
                        }
                        @keyframes slideInDown {
                            from { opacity:0; transform:translateY(-10px); }
                            to   { opacity:1; transform:translateY(0); }
                        }
                        /* highlight invalid step cards */
                        .step-card.step-invalid {
                            border-color: #f87171 !important;
                            background: #fff8f8 !important;
                        }
                        /* inline error text */
                        .field-error {
                            color: #dc2626;
                            font-size: 0.82rem;
                            margin-top: 4px;
                            display: flex;
                            align-items: center;
                            gap: 5px;
                        }
                        /* step users error */
                        .users-error-hint {
                            color: #dc2626;
                            font-size: 0.8rem;
                            margin-top: 3px;
                        }

                        .step-card {
                            background: #fff;
                            border: 1px solid #dee2e6;
                            border-radius: 8px;
                        }

                        .step-card:hover {
                            border-color: #0d6efd;
                        }

                        .step-number {
                            width: 28px;
                            height: 28px;
                            border-radius: 50%;
                            background: #0d6efd;
                            color: #fff;
                            font-size: 13px;
                            font-weight: 700;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            flex-shrink: 0;
                        }

                        .step-connector {
                            width: 2px;
                            background: #dee2e6;
                            min-height: 16px;
                             margin-left: 27px;
                        }

                        .trigger-option {
                            cursor: pointer;
                            border: 2px solid #dee2e6;
                            border-radius: 8px;
                            padding: 14px 16px;
                            user-select: none;
                            background: #fff;
                        }

                        .trigger-option:hover {
                            border-color: #0d6efd;
                            background: #f0f5ff;
                        }

                        .trigger-option.selected {
                            border-color: #0d6efd;
                            background: #e7f0ff;
                        }

                        .trigger-option .trigger-icon {
                            font-size: 1.4rem;
                            color: #0d6efd;
                            margin-bottom: 8px;
                        }

                        .action-badge {
                            font-size: 11px;
                            padding: 2px 10px;
                            border-radius: 4px;
                            font-weight: 600;
                            display: inline-block;
                        }

                        .badge-approve {
                            background: #cfe2ff;
                            color: #084298;
                        }

                        .badge-review {
                            background: #cff4fc;
                            color: #055160;
                        }

                        .badge-execute {
                            background: #d1e7dd;
                            color: #0a3622;
                        }

                        .badge-notify {
                            background: #fff3cd;
                            color: #664d03;
                        }

                        .empty-steps-placeholder {
                            border: 2px dashed #dee2e6;
                            border-radius: 8px;
                            padding: 36px;
                            text-align: center;
                            color: #6c757d;
                            background: #f8f9fa;
                        }

                        .workflow-card {
                            background: #fff;
                            border: 1px solid #dee2e6;
                            border-radius: 10px;
                            overflow: hidden;
                        }

                        .btn-add-step {
                            border: 1px dashed #0d6efd;
                            color: #0d6efd;
                            background: transparent;
                            border-radius: 8px;
                        }

                        .btn-add-step:hover {
                            background: #e7f0ff;
                            color: #0a58ca;
                        }

                        .json-preview-box {
                            background: #f8f9fa;
                            border: 1px solid #dee2e6;
                            border-radius: 8px;
                            font-family: 'Courier New', monospace;
                            font-size: 12px;
                            color: #0550ae;
                            padding: 14px;
                            max-height: 180px;
                            overflow-y: auto;
                            white-space: pre;
                        }

                        .card-header-bar {
                            background: #f8f9fa;
                            border-bottom: 1px solid #dee2e6;
                        }

                        .user-chip-list {
                            display: flex;
                            flex-wrap: wrap;
                            gap: 10px;
                            align-items: flex-start;
                        }

                        .user-chip {
                            display: inline-block;
                            width: 200px;
                            padding: 12px 12px 10px 12px;
                            background: #ffffff;
                            border: 1px solid #e9eef6;
                            border-radius: 10px;
                            box-shadow: 0 1px 2px rgba(16, 24, 40, 0.04);
                            vertical-align: top;
                            position: relative;
                        }

                        .user-chip-name {
                            font-weight: 600;
                            color: #0f172a;
                            font-size: 0.95rem;
                        }

                        .user-chip-meta {
                            margin-top: 6px;
                            font-size: 0.82rem;
                            color: #6b7280;
                        }

                        .user-chip-remove {
                            position: absolute;
                            top: 6px;
                            right: 6px;
                            border: none;
                            background: transparent;
                            color: #9ca3af;
                            font-weight: 700;
                            cursor: pointer;
                            font-size: 14px;
                            line-height: 1;
                            padding: 0 6px;
                        }

                        .user-chip-remove:hover {
                            color: #dc2626;
                        }

                        .btn-user-add {
                            padding: 6px 10px;
                        }

                        /* Dropdown picker styles */
                        .user-picker-dropdown {
                            background: #fff;
                            border: 1px solid #e6eef8;
                            border-radius: 8px;
                            overflow: hidden;
                            box-shadow: 0 6px 18px rgba(15, 23, 42, 0.12);
                        }

                        .user-picker-dropdown .dropdown-header {
                            background: #fbfdff;
                        }

                        .user-picker-dropdown .dropdown-footer {
                            background: #fbfdff;
                        }

                        .user-picker-selected-pill {
                            display: inline-flex;
                            align-items: center;
                            gap: 8px;
                            background: #eef2ff;
                            color: #0f172a;
                            padding: 6px 8px;
                            border-radius: 999px;
                            font-size: 0.85rem;
                            margin-right: 6px;
                            margin-bottom: 6px;
                        }

                        .user-picker-selected-pill .pill-remove {
                            color: #6b7280;
                            cursor: pointer;
                            margin-left: 6px;
                            font-weight: 700;
                        }
                    </style>

                    <div class="breadcrumb-custom">
                        <i class="bi bi-house-door me-1"></i> Trang chủ &gt;
                        <a href="${pageContext.request.contextPath}/workflows"
                            class="text-decoration-none text-secondary">Quản lý Workflow</a>
                        &gt;
                        <c:choose>
                            <c:when test="${formAction == 'create'}">Tạo mới</c:when>
                            <c:otherwise>
                                <c:out value="${workflow.workflowName}" />
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="mb-0 fw-bold">
                            <c:choose>
                                <c:when test="${formAction == 'create'}"><i
                                        class="bi bi-plus-circle me-2 text-primary"></i>Tạo Workflow mới</c:when>
                                <c:otherwise><i class="bi bi-pencil-square me-2 text-warning"></i>Chỉnh sửa Workflow
                                </c:otherwise>
                            </c:choose>
                        </h5>
                        <a href="${pageContext.request.contextPath}/workflows" class="btn btn-sm btn-outline-secondary">
                            <i class="bi bi-arrow-left me-1"></i>Quay lại danh sách
                        </a>
                    </div>

                    <c:if test="${not empty error}">
                        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center gap-2 mb-4"
                            role="alert">
                            <i class="fa fa-triangle-exclamation flex-shrink-0"></i>
                            <span>
                                <c:out value="${error}" />
                            </span>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>

                    <!-- Validation Summary Panel -->
                    <div class="validation-summary" id="validationSummary">
                        <div class="vs-title">
                            <i class="fa fa-circle-exclamation"></i>
                            Vui lòng kiểm tra lại các thông tin sau:
                        </div>
                        <ul id="validationErrors"></ul>
                    </div>

                    <form id="workflowForm" method="post" action="${pageContext.request.contextPath}/workflows"
                        novalidate>
                        <input type="hidden" name="action" value="${formAction}" />
                        <input type="hidden" name="workflowId" value="${workflow.workflowId}" />
                        <input type="hidden" name="createdBy"
                            value="${sessionScope.user != null ? sessionScope.user.userId : ''}" />
                        <input type="hidden" name="workflowConfig" id="workflowConfigHidden" />

                        <div class="workflow-card mb-4">
                            <div class="card-header-bar d-flex align-items-center gap-2 px-4 py-3">
                                <i class="fa fa-circle-info text-primary"></i>
                                <span class="fw-bold">Basic Information</span>
                            </div>
                            <div class="p-4">
                                <div class="row g-4">
                                    <div class="col-12">
                                        <label class="form-label" for="workflowName">Tên Workflow <span
                                                class="text-danger">*</span></label>
                                        <input type="text" id="workflowName" name="workflowName" class="form-control"
                                            placeholder="VD: Quy trình phê duyệt mua sắm IT"
                                            value="<c:out value='${workflow.workflowName}'/>" maxlength="255"
                                            required />
                                        <div class="invalid-feedback">Tên Workflow không được để trống.</div>
                                        <div class="field-error" id="nameError" style="display:none;"><i class="fa fa-circle-exclamation"></i><span></span></div>
                                    </div>
                                    <div class="col-12">
                                        <label class="form-label" for="description">Mô tả</label>
                                        <textarea id="description" name="description" class="form-control" rows="3"
                                            placeholder="Mô tả mục đích của workflow này…" maxlength="500"><c:out value="${workflow.description}"/></textarea>
                                        <div class="form-text text-secondary mt-1"><span id="descCharCount">0</span>/500 ký tự</div>
                                        <div class="field-error" id="descError" style="display:none;"><i class="fa fa-circle-exclamation"></i><span></span></div>
                                    </div>
                                    <div class="col-sm-6">
                                        <label class="form-label" for="status">Status <span
                                                class="text-danger">*</span></label>
                                        <select id="status" name="status" class="form-select" required>
                                            <option value="DRAFT" <c:if
                                                test="${workflow.status == 'DRAFT' || empty workflow.status}">selected
                                                </c:if>>Draft</option>
                                            <option value="ACTIVE" <c:if test="${workflow.status == 'ACTIVE'}">selected
                                                </c:if>>Active</option>
                                            <option value="INACTIVE" <c:if test="${workflow.status == 'INACTIVE'}">
                                                selected</c:if>>Inactive</option>
                                        </select>
                                        <div id="statusHint" class="mt-2"></div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="workflow-card mb-4">
                            <div class="card-header-bar d-flex align-items-center gap-2 px-4 py-3">
                                <i class="fa fa-bolt text-warning"></i>
                                <span class="fw-bold">Trigger</span>
                            </div>
                            <div class="p-4">
                                <div class="row g-3" id="triggerOptions">
                                    <div class="col-sm-6 col-lg-3">
                                        <div class="trigger-option" data-trigger="TICKET_CREATED"
                                            onclick="selectTrigger(this)">
                                            <div class="trigger-icon"><i class="fa fa-ticket"></i></div>
                                            <div class="fw-semibold text-dark" style="font-size:13px;">Ticket Created
                                            </div>
                                        </div>
                                    </div>
<!--                                    <div class="col-sm-6 col-lg-3">
                                        <div class="trigger-option" data-trigger="TICKET_UPDATED"
                                            onclick="selectTrigger(this)">
                                            <div class="trigger-icon"><i class="fa fa-pen-to-square"></i></div>
                                            <div class="fw-semibold text-dark" style="font-size:13px;">Ticket Updated
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-sm-6 col-lg-3">
                                        <div class="trigger-option" data-trigger="SLA_BREACH"
                                            onclick="selectTrigger(this)">
                                            <div class="trigger-icon"><i class="fa fa-clock"></i></div>
                                            <div class="fw-semibold text-dark" style="font-size:13px;">SLA Breach</div>
                                        </div>
                                    </div>-->
                                </div>
                            </div>
                        </div>

                        <div class="workflow-card mb-4" id="conditionsCard" style="display:none;">
                            <div class="card-header-bar d-flex align-items-center justify-content-between px-4 py-3">
                                <div class="d-flex align-items-center gap-2">
                                    <i class="fa fa-filter text-info"></i>
                                    <span class="fw-bold">Trigger Conditions</span>
                                    <span class="badge bg-info ms-1" id="conditionCountBadge"
                                        style="font-size:10px;">All tickets</span>
                                </div>
                                <button type="button" class="btn btn-sm btn-outline-info" onclick="addCondition()"><i
                                        class="bi bi-plus-circle me-1"></i>Add Condition</button>
                            </div>
                            <div class="p-4">
                                <div id="conditionsContainer">
                                    <div class="text-center py-2 text-muted" id="noConditionsMsg">
                                        <small><i class="fa fa-info-circle me-1"></i> No conditions set.</small>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="workflow-card mb-4" id="stepsCard">
                            <div class="card-header-bar d-flex align-items-center justify-content-between px-4 py-3">
                                <div class="d-flex align-items-center gap-2">
                                    <i class="fa fa-list-ol text-success"></i>
                                    <span class="fw-bold">Approval Steps</span>
                                    <span class="badge bg-success ms-1" id="stepCountBadge" style="font-size:10px;">0
                                        steps</span>
                                </div>
                                <button type="button" class="btn btn-sm btn-primary" onclick="addStep()"><i
                                        class="fa fa-plus me-1"></i>Thêm Step</button>
                            </div>
                            <div class="p-4">
                                <div class="field-error mb-2" id="stepsGlobalError" style="display:none;"><i class="fa fa-circle-exclamation"></i><span></span></div>
                                <div id="stepsContainer">
                                    <div class="empty-steps-placeholder" id="emptyStepsPlaceholder">
                                        <div class="fw-semibold">Chưa có step nào được thêm</div>
                                    </div>
                                </div>
                                <button type="button" class="btn btn-add-step w-100 mt-3 py-2 d-none" id="addStepBtn"
                                    onclick="addStep()">
                                    <i class="fa fa-plus-circle me-2"></i>Thêm Step khác
                                </button>
                            </div>
                        </div>

                        <!--                        <div class="workflow-card mb-4">
            <div class="card-header-bar d-flex align-items-center justify-content-between px-4 py-3"
                style="cursor:pointer;" data-bs-toggle="collapse" data-bs-target="#jsonPreviewCollapse">
                <div class="d-flex align-items-center gap-2">
                    <i class="fa fa-code text-secondary"></i>
                    <span class="text-secondary fw-semibold" style="font-size:13px;">Preview Generated
                        JSON</span>
                </div>
                <i class="fa fa-chevron-down text-secondary"></i>
            </div>
            <div class="collapse" id="jsonPreviewCollapse">
                <div class="px-4 pb-4 pt-3">
                    <div class="json-preview-box" id="jsonPreview">{}</div>
                </div>
            </div>
        </div>-->

                        <div class="d-flex align-items-center justify-content-end gap-3">
                            <a href="${pageContext.request.contextPath}/workflows" class="btn btn-secondary px-4"><i
                                    class="fa fa-xmark me-1"></i>Cancel</a>
                            <button type="button" class="btn btn-outline-secondary px-4" onclick="saveDraft()"><i
                                    class="fa fa-floppy-disk me-1"></i>Save as Draft</button>
                            <button type="submit" class="btn btn-primary px-4" id="submitBtn"><i
                                    class="fa fa-check-circle me-1"></i>Save</button>
                        </div>
                    </form>

                    <%-- Data Islands --%>
                        <script type="application/json"
                            id="existingConfig"><c:out value="${workflow.workflowConfig}" escapeXml="false"/></script>
                        <script type="application/json" id="metaTicketTypes"><%
List<?> _tt = (List<?>) request.getAttribute("ticketTypes");
if (_tt == null) _tt = List.of("INCIDENT","SERVICE_REQUEST","PROBLEM","CHANGE");
out.print(gson.toJson(_tt));
    %></script>
                        <script type="application/json" id="metaPriorities"><%
List<?> _pr = (List<?>) request.getAttribute("priorities");
if (_pr == null) _pr = List.of("LOW","MEDIUM","HIGH","CRITICAL");
out.print(gson.toJson(_pr));
    %></script>
                        <script type="application/json" id="metaCategories"><%
    List<?> _cats = (List<?>) request.getAttribute("categories");
    if (_cats == null) _cats = List.of();
    out.print(gson.toJson(_cats));
    %></script>

                        <script>
                            // STATE
                            let selectedTrigger = 'TICKET_CREATED';
                            let steps = [];
                            let conditions = [];
                            let conditionLogic = 'AND';
                            let stepIdCounter = 0;
                            let conditionIdCounter = 0;
                            let TICKET_TYPES = [];
                            let PRIORITIES = [];
                            let CATEGORIES = [];

                            // INIT DATA FROM ISLANDS
                            try {
                                TICKET_TYPES = JSON.parse(document.getElementById('metaTicketTypes').textContent.trim() || '[]');
                                PRIORITIES = JSON.parse(document.getElementById('metaPriorities').textContent.trim() || '[]');
                                CATEGORIES = JSON.parse(document.getElementById('metaCategories').textContent.trim() || '[]');
                            } catch (e) {
                                console.error('Error parsing metadata islands:', e);
                            }

                            const ROLES = ['Manager', 'Finance', 'IT Support', 'HR', 'Director', 'Security Team', 'Legal'];
                            const ACTIONS = [
//                                { value: 'APPROVE_REJECT', label: 'Approve / Reject', badgeClass: 'badge-approve' },
                                { value: 'REVIEW', label: 'Review Only', badgeClass: 'badge-review' },
                                { value: 'EXECUTE', label: 'Execute Task', badgeClass: 'badge-execute' },
//                                { value: 'NOTIFY', label: 'Notify Only', badgeClass: 'badge-notify' },
                            ];

                            var _placeholder = document.getElementById('emptyStepsPlaceholder');
                            var _addStepBtn = document.getElementById('addStepBtn');

                            (function init() {
                                const dataEl = document.getElementById('existingConfig');
                                const raw = dataEl ? dataEl.textContent.trim() : '';
                                if (raw && raw !== 'null') {
                                    try {
                                        const cfg = JSON.parse(raw);
                                        if (cfg.trigger)
                                            selectedTrigger = cfg.trigger;
                                        if (cfg.conditions) {
                                            conditionLogic = cfg.conditions.logic || 'AND';
                                            (cfg.conditions.criteria || []).forEach(c => {
                                                conditions.push({ id: ++conditionIdCounter, field: c.field, operator: c.operator || 'EQUALS', value: c.value });
                                            });
                                        }
                                        if (Array.isArray(cfg.steps)) {
                                            cfg.steps.forEach(s => {
                                                // If action is NOTIFY, SLA should always be 0 and not editable
                                                const actionVal = s.action || 'APPROVE_REJECT';
                                                const slaVal = (actionVal === 'NOTIFY') ? 0 : (s.sla_hours || 24);
                                                // Prefer explicit users array in config; fall back to legacy role
                                                const usersArr = Array.isArray(s.users) ? s.users.map(u => ({ userId: u.userId, fullName: u.fullName, role: u.roleName || u.role || '', departmentName: u.departmentName || u.department || '' })) : [];
                                                steps.push({ id: ++stepIdCounter, name: s.name || '', description: s.description || '', users: usersArr, legacyRole: s.role || null, action: actionVal, sla_hours: slaVal });
                                            });
                                        }
                                    } catch (e) {
                                    }
                                }
                                renderTriggerSelection();
                                renderConditions();
                                renderSteps();
                                updateJsonPreview();
                                updateTriggerUI();
                                loadTicketTypesFromApi();
                            })();

                            function loadTicketTypesFromApi() {
                                var ctxMeta = document.querySelector('meta[name="ctx-path"]');
                                var ctx = ctxMeta ? ctxMeta.getAttribute('content') : '';
                                fetch(ctx + '/workflows?action=api-ticket-types')
                                    .then(res => res.ok ? res.json() : [])
                                    .then(data => {
                                        if (Array.isArray(data) && data.length > 0) {
                                            TICKET_TYPES = data;
                                            renderConditions();
                                        }
                                    }).catch(() => {
                                    });
                            }

                            function selectTrigger(el) {
                                document.querySelectorAll('.trigger-option').forEach(o => o.classList.remove('selected'));
                                el.classList.add('selected');
                                selectedTrigger = el.dataset.trigger;
                                updateTriggerUI();
                                updateJsonPreview();
                            }

                            function updateTriggerUI() {
                                const card = document.getElementById('conditionsCard');
                                card.style.display = ['TICKET_CREATED', 'TICKET_UPDATED', 'SLA_BREACH'].includes(selectedTrigger) ? 'block' : 'none';
                            }

                            function renderTriggerSelection() {
                                document.querySelectorAll('.trigger-option').forEach(o => {
                                    if (o.dataset.trigger === selectedTrigger)
                                        o.classList.add('selected');
                                });
                                updateTriggerUI();
                            }

                            function addCondition() {
                                conditionIdCounter++;
                                const nextField = conditions.length === 0 ? 'ticket_type' : (conditions.length === 1 ? 'priority' : 'category_id');
                                conditions.push({ id: conditionIdCounter, field: nextField, operator: 'EQUALS', value: '' });
                                renderConditions();
                                updateJsonPreview();
                            }

                            function removeCondition(id) {
                                conditions = conditions.filter(c => c.id !== id);
                                renderConditions();
                                updateJsonPreview();
                            }

                            function updateCondition(id, field, value) {
                                const c = conditions.find(c => c.id === id);
                                if (c) {
                                    c[field] = value;
                                    if (field === 'field')
                                        c.value = '';
                                }
                                if (field === 'field')
                                    renderConditions();
                                updateJsonPreview();
                            }

                            function renderConditions() {
                                const container = document.getElementById('conditionsContainer');
                                const badge = document.getElementById('conditionCountBadge');
                                if (!container) return;
                                if (conditions.length === 0) {
                                    container.innerHTML = '<div class="text-center py-4 text-secondary opacity-50"><small>No conditions set.</small></div>';
                                    badge.textContent = 'All tickets';
                                    return;
                                }
                                badge.textContent = conditions.length + (conditions.length === 1 ? ' condition' : ' conditions');
                                let html = '';
                                if (conditions.length > 1) {
                                    html += '<div class="d-flex align-items-center gap-2 mb-3 pb-2 border-bottom border-secondary-subtle">'
                                        + '<span class="text-secondary small">Match</span>'
                                        + '<select class="form-select form-select-sm fw-bold border-secondary-subtle" style="width: auto;" onchange="conditionLogic = this.value; updateJsonPreview();">'
                                        + '<option value="AND" ' + (conditionLogic === 'AND' ? 'selected' : '') + '>ALL (AND)</option>'
                                        + '<option value="OR" ' + (conditionLogic === 'OR' ? 'selected' : '') + '>ANY (OR)</option>'
                                        + '</select>'
                                        + '<span class="text-secondary small">of the following conditions:</span>'
                                        + '</div>';
                                }
                                html += '<div class="conditions-list">';
                                conditions.forEach(c => html += renderConditionRow(c));
                                html += '</div>';
                                container.innerHTML = html;
                            }

                            function renderConditionRow(c) {
                                var fieldList = [
                                    { value: 'ticket_type', label: 'Ticket Type' },
                                    { value: 'priority', label: 'Priority' },
                                    { value: 'category_id', label: 'Category' }
                                ];
                                var fieldOptions = fieldList.map(function (f) {
                                    return '<option value="' + f.value + '" ' + (c.field === f.value ? 'selected' : '') + '>' + f.label + '</option>';
                                }).join('');

                                var operatorList = [
                                    { value: 'EQUALS', label: 'is' },
                                    { value: 'NOT_EQUALS', label: 'is not' }
                                ];
                                var operatorOptions = operatorList.map(function (o) {
                                    return '<option value="' + o.value + '" ' + (c.operator === o.value ? 'selected' : '') + '>' + o.label + '</option>';
                                }).join('');

                                var valueInput = '';
                                if (c.field === 'ticket_type') {
                                    valueInput = '<select class="form-select form-select-sm" onchange="updateCondition(' + c.id + ', \'value\', this.value)">'
                                        + '<option value="">-- Type --</option>'
                                        + (TICKET_TYPES.map(function (t) { return '<option value="' + t + '"' + (c.value === t ? ' selected' : '') + '>' + t + '</option>'; }).join(''))
                                        + '</select>';
                                } else if (c.field === 'priority') {
                                    valueInput = '<select class="form-select form-select-sm" onchange="updateCondition(' + c.id + ', \'value\', this.value)">'
                                        + '<option value="">-- Priority --</option>'
                                        + (PRIORITIES.map(function (p) { return '<option value="' + p + '"' + (c.value === p ? ' selected' : '') + '>' + p + '</option>'; }).join(''))
                                        + '</select>';
                                } else if (c.field === 'category_id') {
                                    valueInput = '<select class="form-select form-select-sm" onchange="updateCondition(' + c.id + ', \'value\', this.value)">'
                                        + '<option value="">-- Category --</option>'
                                        + (CATEGORIES.map(function (cat) { return '<option value="' + cat.categoryId + '"' + (c.value == cat.categoryId ? ' selected' : '') + '>' + cat.categoryName + '</option>'; }).join(''))
                                        + '</select>';
                                }

                                var html = '';
                                html += '<div class="row g-2 mb-2 align-items-center condition-row p-2 border border-secondary-subtle rounded bg-light bg-opacity-10">';
                                html += '<div class="col-md-3">';
                                html += '<select class="form-select form-select-sm" onchange="updateCondition(' + c.id + ', \'field\', this.value)">' + fieldOptions + '</select>';
                                html += '</div>';
                                html += '<div class="col-md-2">';
                                html += '<select class="form-select form-select-sm" onchange="updateCondition(' + c.id + ', \'operator\', this.value)">' + operatorOptions + '</select>';
                                html += '</div>';
                                html += '<div class="col-md-6">' + valueInput + '</div>';
                                html += '<div class="col-md-1 text-end">';
                                html += '<button type="button" class="btn btn-sm text-danger" onclick="removeCondition(' + c.id + ')"><i class="bi bi-trash"></i></button>';
                                html += '</div>';
                                html += '</div>';
                                return html;
                            }

                            function addStep() {
                                stepIdCounter++;
                                steps.push({ id: stepIdCounter, name: '', description: '', users: [], legacyRole: null, action: 'APPROVE_REJECT', sla_hours: 24 });
                                renderSteps();
                                updateJsonPreview();
                            }

                            function renderSteps() {
                                var container = document.getElementById('stepsContainer');
                                var badge = document.getElementById('stepCountBadge');
                                badge.textContent = steps.length + ' step' + (steps.length !== 1 ? 's' : '');
                                if (steps.length === 0) {
                                    container.innerHTML = '<div class="empty-steps-placeholder"><div class="fw-semibold">No steps added yet</div></div>';
                                    _addStepBtn.classList.add('d-none');
                                    return;
                                }
                                _addStepBtn.classList.remove('d-none');
                                let html = '';
                                steps.forEach(function (s, i) {
                                    // users preview (chips) and picker button
                                    var usersHtml = '';
                                    var selectedUsers = s.users || [];
                                    if (selectedUsers.length === 0 && s.legacyRole) {
                                        // show legacy role as hint
                                        usersHtml = '<div class="small text-muted px-1">Role: ' + escHtml(s.legacyRole) + '</div>';
                                    } else if (selectedUsers.length > 0) {
                                        var show = 3;
                                        var innerHtml = selectedUsers.slice(0, show).map(function (u) {
                                            return '<div class="user-picker-selected-pill py-1 m-0">' + escHtml(u.fullName) + '<span class="pill-remove" onclick="event.stopPropagation(); removeSelectedUserFromStep(' + s.id + ',' + (u.userId || 'null') + ')">×</span></div>';
                                        }).join('');
                                        if (selectedUsers.length > show) {
                                            innerHtml += '<div class="user-picker-selected-pill py-1 m-0">' + (selectedUsers.length - show) + ' more...</div>';
                                        }
                                        usersHtml = innerHtml;
                                    }
                                    var actionOptions = ACTIONS.map(function (a) { return '<option value="' + a.value + '"' + (a.value === s.action ? ' selected' : '') + '>' + a.label + '</option>'; }).join('');
                                    var upBtn = i > 0 ? '<button type="button" class="btn btn-sm p-0 text-secondary" title="Move Up" onclick="moveStep(' + s.id + ', -1)"><i class="fa fa-chevron-up"></i></button>' : '<span style="display:inline-block;width:22px;"></span>';
                                    var downBtn = i < steps.length - 1 ? '<button type="button" class="btn btn-sm p-0 text-secondary" title="Move Down" onclick="moveStep(' + s.id + ', 1)"><i class="fa fa-chevron-down"></i></button>' : '<span style="display:inline-block;width:22px;"></span>';
                                    // SLA input is not editable for NOTIFY-only steps; show disabled 0
                                    // Per-step SLA input removed from UI (SLA still stored in model).
                                    var slaHtml = '';
                                    html += '<div class="step-card p-3 mb-2 d-flex align-items-start gap-3">'
                                        + '<div class="d-flex flex-column align-items-center gap-1">'
                                        + '<div class="step-number">' + (i + 1) + '</div>'
                                        + upBtn + ' ' + downBtn
                                        + '</div>'
                                        + '<div class="flex-grow-1">'
                                        + '<div class="row g-3 mb-2">'
                                        // Adjusted column widths: name (5), users (4), action (3). SLA removed from UI
                                        + '<div class="col-md-5"><input type="text" class="form-control form-control-sm" placeholder="Step Name" value="' + escHtml(s.name) + '" oninput="updateStepField(' + s.id + ', \'name\', this.value)" /></div>'
                                        + '<div class="col-md-4">'
                                        + '<div class="form-control form-control-sm btn-user-add d-flex flex-wrap align-items-center gap-1" style="min-height:31px; height:auto; cursor:text; padding:3px 6px;" onclick="openUserPicker(event, ' + s.id + ')">'
                                        + usersHtml
                                        + '<input type="text" onclick="openUserPicker(event, ' + s.id + ')" onfocus="openUserPicker(event, ' + s.id + ')" oninput="fetchUsersForPicker(this.value)" style="border:none; outline:none; box-shadow:none; flex-grow:1; min-width:60px; background:transparent; font-size:13px;" placeholder="' + (selectedUsers.length > 0 ? '' : 'Search users...') + '" />'
                                        + '</div>'
                                        + '</div>'
                                        + '<div class="col-md-3"><select class="form-select form-select-sm" onchange="updateStepField(' + s.id + ', \'action\', this.value)">' + actionOptions + '</select></div>'
                                        + '</div>'
                                        + '<div class="row g-3">'
                                        + '<div class="col-12"><input type="text" class="form-control form-control-sm" placeholder="Step Description (Optional)" value="' + escHtml(s.description || '') + '" oninput="updateStepField(' + s.id + ', \'description\', this.value)" /></div>'
                                        + '</div>'
                                        + '</div>'
                                        + '<button type="button" class="btn btn-sm text-danger" onclick="removeStep(' + s.id + ')"><i class="fa fa-trash"></i></button>'
                                        + '</div>';
                                });
                                container.innerHTML = html;
                            }

                            function updateStepField(id, field, value) {
                                var s = steps.find(s => s.id === id);
                                if (s) {
                                    if (field === 'action') {
                                        s[field] = value;
                                        // If switched to NOTIFY, SLA must be 0 and not editable
                                        if (String(value).toUpperCase() === 'NOTIFY') {
                                            s.sla_hours = 0;
                                        } else {
                                            // If previously 0 due to NOTIFY, reset to reasonable default
                                            if (!s.sla_hours || s.sla_hours === 0) s.sla_hours = 24;
                                        }
                                        // Re-render steps so SLA input shows/hides correctly
                                        renderSteps();
                                        updateJsonPreview();
                                        return;
                                    }
                                    if (field === 'sla_hours') {
                                        s[field] = parseInt(value, 10) || 0;
                                    } else {
                                        s[field] = value;
                                    }
                                }
                                updateJsonPreview();
                            }

                            // ----- User picker logic -----
                            var _userPickerState = { stepId: null, selected: {} };
                            function openUserPicker(e, stepId) {
                                // e is the click event from the Add button
                                _userPickerState.stepId = stepId;
                                _userPickerState.selected = {};
                                // preselect existing users
                                var s = steps.find(x => x.id === stepId);
                                if (s && Array.isArray(s.users)) {
                                    s.users.forEach(u => { if (u && u.userId) _userPickerState.selected[u.userId] = u; });
                                }
                                renderUserPickerDropdown();
                                positionUserPickerDropdown(e);
                                // perform initial fetch
                                fetchUsersForPicker('');
                            }

                            function renderUserPickerDropdown() {
                                if (document.getElementById('userPickerDropdown')) return;
                                var container = document.createElement('div');
                                container.id = 'userPickerDropdown';
                                container.className = 'user-picker-dropdown shadow border rounded';
                                container.style.position = 'absolute';
                                container.style.zIndex = 1080;
                                container.style.display = 'none';
                                container.innerHTML = `
    <div class="dropdown-header p-2 border-bottom bg-light">
        <input type="text" id="userPickerSearch" class="form-control form-control-sm w-100" placeholder="Search by name, email or role..." oninput="fetchUsersForPicker(this.value)" autofocus />
        <select id="userPickerRole" class="form-select form-select-sm mt-2" style="display:none;" onchange="fetchUsersForPicker(document.getElementById('userPickerSearch').value)">
            <option value="">All Roles</option>
        </select>
    </div>
    <div id="userPickerResults" style="max-height:240px; overflow:auto;"></div>`;
                                document.body.appendChild(container);
                                // populate role select from client-side ROLES array
                                try {
                                    var roleSel = document.getElementById('userPickerRole');
                                    if (roleSel && Array.isArray(ROLES)) {
                                        ROLES.forEach(function (r) {
                                            var opt = document.createElement('option');
                                            opt.value = r;
                                            opt.textContent = r;
                                            roleSel.appendChild(opt);
                                        });
                                    }
                                } catch (e) { }
                            }

                            function positionUserPickerDropdown(e) {
                                var dropdown = document.getElementById('userPickerDropdown');
                                if (!dropdown) return;
                                var target = e.currentTarget || e.target;
                                if (target && !target.classList.contains('btn-user-add') && target.closest) {
                                    target = target.closest('.btn-user-add') || target;
                                }
                                var btnRect = target.getBoundingClientRect();
                                var top = window.scrollY + btnRect.bottom + 6;
                                var left = window.scrollX + btnRect.left;
                                dropdown.style.top = top + 'px';
                                dropdown.style.left = left + 'px';
                                dropdown.style.minWidth = Math.max(300, btnRect.width * 1.2) + 'px';
                                dropdown.style.display = 'block';
                                // close when clicking outside
                                window.removeEventListener('click', outsideClickHandler);
                                setTimeout(function () {
                                    window.addEventListener('click', outsideClickHandler);
                                }, 10);
                            }

                            function hideUserPickerDropdown() {
                                var dropdown = document.getElementById('userPickerDropdown');
                                if (!dropdown) return;
                                dropdown.style.display = 'none';
                                window.removeEventListener('click', outsideClickHandler);
                            }

                            function outsideClickHandler(evt) {
                                var dropdown = document.getElementById('userPickerDropdown');
                                if (!dropdown) return;
                                if (!dropdown.contains(evt.target) && !evt.target.closest('.btn-user-add')) {
                                    hideUserPickerDropdown();
                                }
                            }

                            function fetchUsersForPicker(q) {
                                var role = document.getElementById('userPickerRole') ? document.getElementById('userPickerRole').value : '';
                                var ctxMeta = document.querySelector('meta[name="ctx-path"]');
                                var ctx = ctxMeta ? ctxMeta.getAttribute('content') : '';
                                var params = new URLSearchParams();
                                if (q) params.set('q', q);
                                if (role) params.set('roleName', role);
                                // call our new JSON endpoint
                                var url = ctx + '/admin/users?action=searchJson&q=' + encodeURIComponent(q);
                                if (role) url += '&roleName=' + encodeURIComponent(role);
                                console.debug('User picker search URL:', url);
                                var out = document.getElementById('userPickerResults');
                                fetch(url)
                                    .then(res => {
                                        if (!res.ok) {
                                            console.warn('User search responded with status', res.status, res.statusText);
                                            if (out) {
                                                if (res.status === 403) {
                                                    out.innerHTML = '<div class="text-center text-muted py-3"><strong>Access denied</strong><div class="small">You do not have permission to search users.</div></div>';
                                                } else {
                                                    out.innerHTML = '<div class="text-center text-muted py-3">No users found</div>';
                                                }
                                            }
                                            return [];
                                        }
                                        var ct = (res.headers.get('content-type') || '').toLowerCase();
                                        if (ct.indexOf('application/json') !== -1) {
                                            return res.json().catch(e => {
                                                console.error('Failed to parse JSON from user search', e);
                                                return [];
                                            });
                                        }
                                        // non-json response (likely HTML login/redirect). read text for debug and return empty
                                        return res.text().then(t => {
                                            console.warn('User search returned non-JSON response (showing first 300 chars):', t && t.substring ? t.substring(0, 300) : t);
                                            if (out) {
                                                var tl = (t || '').toLowerCase();
                                                if (tl.indexOf('access denied') !== -1 || tl.indexOf('accessdenied') !== -1) {
                                                    out.innerHTML = '<div class="text-center text-muted py-3"><strong>Access denied</strong><div class="small">You do not have permission to search users.</div></div>';
                                                } else {
                                                    out.innerHTML = '<div class="text-center text-muted py-3">No users found</div>';
                                                }
                                            }
                                            return [];
                                        }).catch(e => {
                                            console.error('Error reading non-JSON user search response', e);
                                            if (out) out.innerHTML = '<div class="text-center text-muted py-3">No users found</div>';
                                            return [];
                                        });
                                    })
                                    .then(data => {
                                        var out = document.getElementById('userPickerResults');
                                        if (!out) return;
                                        if (!Array.isArray(data) || data.length === 0) {
                                            out.innerHTML = '<div class="text-center text-muted py-3">No users found</div>';
                                            return;
                                        }
                                        var html = '<div class="list-group list-group-flush">';
                                        data.forEach(function (u) {
                                            var checked = _userPickerState.selected[u.userId] ? 'checked' : '';
                                            html += '<label class="list-group-item d-flex align-items-center" style="cursor:pointer;">'
                                                + '<input type="checkbox" class="me-3 user-picker-checkbox" data-id="' + u.userId + '" ' + checked + ' onchange="toggleUserSelectionInPicker(' + u.userId + ', this)" />'
                                                + '<div>'
                                                + '<div class="fw-semibold">' + escHtml(u.fullName) + '</div>'
                                                + '<div class="small text-secondary">' + (u.roleName ? escHtml(u.roleName) + (u.departmentName ? ' · ' + escHtml(u.departmentName) : '') : (u.departmentName ? escHtml(u.departmentName) : '')) + '</div>'
                                                + '</div>'
                                                + '</label>';
                                        });
                                        html += '</div>';
                                        out.innerHTML = html;
                                    }).catch(err => {
                                        console.error('User search error', err);
                                    });
                            }

                            function toggleUserSelectionInPicker(userId, checkbox) {
                                var stepId = _userPickerState.stepId;
                                var s = steps.find(x => x.id === stepId);
                                if (!s) return;

                                if (checkbox.checked) {
                                    // optimistic placeholder so UI updates immediately
                                    _userPickerState.selected[userId] = { userId: userId, fullName: '...', role: '', departmentName: '' };
                                    s.users = Object.values(_userPickerState.selected);
                                    s.legacyRole = null;
                                    renderSteps();

                                    // fetch user info and fill
                                    var ctxMeta = document.querySelector('meta[name="ctx-path"]');
                                    var ctx = ctxMeta ? ctxMeta.getAttribute('content') : '';
                                    fetch(ctx + '/admin/users?action=getInfo&id=' + userId)
                                        .then(res => res.ok ? res.json() : null)
                                        .then(u => {
                                            if (u) {
                                                _userPickerState.selected[u.userId] = { userId: u.userId, fullName: u.fullName, role: u.roleName, departmentName: u.departmentName };
                                                s.users = Object.values(_userPickerState.selected);
                                                renderSteps();
                                                updateJsonPreview();
                                            }
                                        })
                                        .catch(() => { /* ignore */ });
                                } else {
                                    delete _userPickerState.selected[userId];
                                    s.users = Object.values(_userPickerState.selected);
                                    renderSteps();
                                    updateJsonPreview();
                                }
                            }

                            function removeSelectedUserFromStep(stepId, userId) {
                                var s = steps.find(x => x.id === stepId);
                                if (!s || !Array.isArray(s.users)) return;
                                s.users = s.users.filter(u => (u.userId || null) !== (userId || null));

                                if (_userPickerState.stepId === stepId) {
                                    delete _userPickerState.selected[userId];
                                    var cb = document.querySelector('#userPickerResults input.user-picker-checkbox[data-id="' + userId + '"]');
                                    if (cb) cb.checked = false;
                                }

                                renderSteps();
                                updateJsonPreview();
                            }
                            function removeStep(id) {
                                steps = steps.filter(s => s.id !== id);
                                renderSteps();
                                updateJsonPreview();
                            }
                            function moveStep(id, dir) {
                                var idx = steps.findIndex(s => s.id === id);
                                if (idx < 0)
                                    return;
                                var newIdx = idx + dir;
                                if (newIdx < 0 || newIdx >= steps.length)
                                    return;
                                var tmp = steps[idx];
                                steps[idx] = steps[newIdx];
                                steps[newIdx] = tmp;
                                renderSteps();
                                updateJsonPreview();
                            }

                            function buildConfig() {
                                return {
                                    trigger: selectedTrigger,
                                    conditions: { type: 'group', logic: conditionLogic, criteria: conditions.map(c => ({ type: 'condition', field: c.field, operator: c.operator, value: c.value })) },
                                    steps: steps.map(s => ({ name: s.name, description: s.description, users: s.users || [], legacyRole: s.legacyRole || null, action: s.action, sla_hours: s.sla_hours }))
                                };
                            }
                            function updateJsonPreview() {
                                var json = JSON.stringify(buildConfig(), null, 2);
                                // Update preview if present (the preview panel may be commented out)
                                var previewEl = document.getElementById('jsonPreview');
                                if (previewEl) {
                                    previewEl.textContent = json;
                                }
                                // Always update the hidden input so server receives the config
                                var hidden = document.getElementById('workflowConfigHidden');
                                if (hidden) {
                                    hidden.value = json;
                                }
                            }

                            var statusSelect = document.getElementById('status');
                            function updateStatusHint() {
                                const h = { DRAFT: 'Draft: Not yet active.', ACTIVE: 'Active: Live.', INACTIVE: 'Inactive: Paused.' }[statusSelect.value];
                                document.getElementById('statusHint').innerHTML = h ? '<div class="alert alert-info p-2 small">' + escHtml(h) + '</div>' : '';
                            }
                            statusSelect.addEventListener('change', updateStatusHint);
                            updateStatusHint();

                            var descArea = document.getElementById('description');
                            var charCount = document.getElementById('descCharCount');
                            function updateCharCount() {
                                var len = descArea.value.length;
                                charCount.textContent = len;
                                charCount.style.color = len > 480 ? '#ef4444' : '';
                            }
                            descArea.addEventListener('input', updateCharCount);
                            updateCharCount();

                            // ===== VALIDATION ENGINE =====
                            function validateWorkflowForm(isDraft) {
                                var errors = [];

                                // 1. Workflow Name
                                var nameEl = document.getElementById('workflowName');
                                var nameVal = nameEl ? nameEl.value.trim() : '';
                                var nameErrorEl = document.getElementById('nameError');
                                if (!nameVal) {
                                    errors.push('Tên Workflow không được để trống.');
                                    if (nameEl) nameEl.classList.add('is-invalid');
                                    if (nameErrorEl) { nameErrorEl.style.display = 'flex'; nameErrorEl.querySelector('span').textContent = 'Tên Workflow không được để trống.'; }
                                } else {
                                    if (nameEl) nameEl.classList.remove('is-invalid');
                                    if (nameErrorEl) nameErrorEl.style.display = 'none';
                                }

                                // 2. Description max 500
                                var descEl = document.getElementById('description');
                                var descErrorEl = document.getElementById('descError');
                                if (descEl && descEl.value.length > 500) {
                                    errors.push('Mô tả không được vượt quá 500 ký tự (hiện tại: ' + descEl.value.length + ').');
                                    descEl.classList.add('is-invalid');
                                    if (descErrorEl) { descErrorEl.style.display = 'flex'; descErrorEl.querySelector('span').textContent = 'Mô tả vượt quá 500 ký tự.'; }
                                } else {
                                    if (descEl) descEl.classList.remove('is-invalid');
                                    if (descErrorEl) descErrorEl.style.display = 'none';
                                }

                                if (!isDraft) {
                                    // 3. Trigger must be selected
                                    if (!selectedTrigger) {
                                        errors.push('Vui lòng chọn một Trigger cho workflow.');
                                    }

                                    // 4. At least one step required
                                    var stepsGlobalErr = document.getElementById('stepsGlobalError');
                                    if (steps.length === 0) {
                                        errors.push('Workflow phải có ít nhất 1 Approval Step.');
                                        if (stepsGlobalErr) { stepsGlobalErr.style.display = 'flex'; stepsGlobalErr.querySelector('span').textContent = 'Phải có ít nhất 1 step.'; }
                                    } else {
                                        if (stepsGlobalErr) stepsGlobalErr.style.display = 'none';

                                        // 5. Each step must have a name and at least 1 user
                                        steps.forEach(function(s, idx) {
                                            var stepNum = idx + 1;
                                            if (!s.name || !s.name.trim()) {
                                                errors.push('Step ' + stepNum + ': Tên step không được để trống.');
                                            }
                                            if (!s.users || s.users.length === 0) {
                                                errors.push('Step ' + stepNum + ' ("' + (s.name.trim() || 'Không tên') + '"): Phải chọn ít nhất 1 người phụ trách.');
                                            }
                                        });

                                        // Highlight invalid step cards in the DOM
                                        document.querySelectorAll('.step-card').forEach(function(card, idx) {
                                            var s = steps[idx];
                                            if (s && (!s.name || !s.name.trim() || !s.users || s.users.length === 0)) {
                                                card.classList.add('step-invalid');
                                            } else {
                                                card.classList.remove('step-invalid');
                                            }
                                        });
                                    }
                                }

                                return errors;
                            }

                            function showValidationSummary(errors) {
                                var panel = document.getElementById('validationSummary');
                                var list  = document.getElementById('validationErrors');
                                if (!panel || !list) return;
                                if (errors.length === 0) {
                                    panel.classList.remove('show');
                                    return;
                                }
                                list.innerHTML = errors.map(function(e) { return '<li>' + escHtml(e) + '</li>'; }).join('');
                                panel.classList.add('show');
                                panel.scrollIntoView({ behavior: 'smooth', block: 'start' });
                            }

                            document.getElementById('workflowForm').addEventListener('submit', function (e) {
                                e.preventDefault();
                                updateJsonPreview();

                                var errors = validateWorkflowForm(false);
                                showValidationSummary(errors);
                                if (errors.length > 0) {
                                    this.classList.add('was-validated');
                                    return;
                                }

                                // Clear validation state and submit
                                document.getElementById('validationSummary').classList.remove('show');
                                this.classList.remove('was-validated');
                                var btn = document.getElementById('submitBtn');
                                btn.disabled = true;
                                btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Đang lưu...';
                                this.submit();
                            });

                            // Live-clear name error on input
                            document.getElementById('workflowName').addEventListener('input', function() {
                                if (this.value.trim()) {
                                    this.classList.remove('is-invalid');
                                    var er = document.getElementById('nameError');
                                    if (er) er.style.display = 'none';
                                }
                            });

                            function saveDraft() {
                                updateJsonPreview();
                                // Draft only validates name
                                var errors = validateWorkflowForm(true);
                                showValidationSummary(errors);
                                if (errors.length > 0) return;

                                document.getElementById('validationSummary').classList.remove('show');
                                document.getElementById('status').value = 'DRAFT';
                                var form = document.getElementById('workflowForm');
                                form.submit();
                            }
                            function escHtml(str) {
                                return str ? String(str).replace(/[&<>"']/g, m => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[m])) : '';
                            }
                        </script>

                        <jsp:include page="/common/admin-layout-bottom.jsp" />