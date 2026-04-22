<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

            <style>
                /* ── Shared with workflow-list ── */
                .breadcrumb-custom {
                    display: flex;
                    justify-content: flex-end;
                    font-size: 0.9rem;
                    color: #666;
                    margin-bottom: 20px;
                }

                /* Status badges */
                .badge-status {
                    font-size: 11px;
                    font-weight: 600;
                    padding: 4px 10px;
                    border-radius: 50px;
                    display: inline-flex;
                    align-items: center;
                    gap: 5px;
                }

                .badge-status::before {
                    content: '';
                    width: 6px;
                    height: 6px;
                    border-radius: 50%;
                    display: inline-block;
                }

                .badge-active {
                    background: #e0f7f4;
                    color: #00897b;
                }

                .badge-active::before {
                    background: #10b981;
                }

                .badge-inactive {
                    background: #fff8e1;
                    color: #d97706;
                }

                .badge-inactive::before {
                    background: #f59e0b;
                }

                .badge-draft {
                    background: #e8eaf6;
                    color: #3949ab;
                }

                .badge-draft::before {
                    background: #3b82f6;
                }

                /* Action buttons (small icon) */
                .btn-act {
                    width: 30px;
                    height: 30px;
                    display: inline-flex;
                    align-items: center;
                    justify-content: center;
                    border-radius: 4px;
                    border: none;
                    font-size: 13px;
                    transition: opacity .15s;
                    cursor: pointer;
                }

                .btn-act:hover {
                    opacity: .8;
                }

                /* ── Detail-specific styles ── */
                .action-bar-detail {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    margin-bottom: 20px;
                    gap: 12px;
                    flex-wrap: wrap;
                }

                .action-bar-detail .page-heading {
                    font-size: 1.15rem;
                    font-weight: 700;
                    color: #333;
                    display: flex;
                    align-items: center;
                    gap: 8px;
                }

                .action-bar-detail .page-heading .badge-status {
                    font-size: 12px;
                }

                .detail-card {
                    background: #fff;
                    border: 1px solid #ddd;
                    border-radius: 6px;
                    box-shadow: 0 1px 4px rgba(0, 0, 0, .06);
                    margin-bottom: 20px;
                    overflow: hidden;
                }

                .detail-card-header {
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    padding: 12px 16px;
                    border-bottom: 1px solid #eee;
                    background: #fafafa;
                    font-weight: 600;
                    font-size: 0.9rem;
                    color: #444;
                }

                .detail-card-header[data-bs-toggle="collapse"] {
                    cursor: pointer;
                }

                .detail-card-body {
                    padding: 16px;
                }

                .detail-label {
                    font-size: 11px;
                    font-weight: 600;
                    text-transform: uppercase;
                    letter-spacing: .5px;
                    color: #888;
                    margin-bottom: 4px;
                }

                .detail-value {
                    font-size: 0.92rem;
                    color: #333;
                }

                /* Config preview */
                .config-preview {
                    background: #f8f9fa;
                    border: 1px solid #ddd;
                    border-radius: 4px;
                    padding: 14px;
                    font-size: 12px;
                    max-height: 380px;
                    overflow-y: auto;
                    white-space: pre-wrap;
                    word-break: break-all;
                    color: #333;
                    margin: 0;
                }

                /* Sidebar quick-action buttons */
                .btn-quick {
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    padding: 8px 12px;
                    border-radius: 4px;
                    font-size: 0.88rem;
                    font-weight: 500;
                    border: 1px solid #ddd;
                    background: #fff;
                    color: #444;
                    text-decoration: none;
                    transition: background .15s, border-color .15s;
                    cursor: pointer;
                    width: 100%;
                }

                .btn-quick:hover {
                    background: #f0f0f0;
                    border-color: #bbb;
                    color: #333;
                }

                .btn-quick-danger {
                    color: #dc3545;
                    border-color: #f5c6cb;
                }

                .btn-quick-danger:hover {
                    background: #fff0f0;
                    border-color: #dc3545;
                    color: #dc3545;
                }

                /* Summary step list */
                .step-item {
                    display: flex;
                    align-items: center;
                    gap: 12px;
                    padding: 10px 0;
                    border-bottom: 1px solid #f0f0f0;
                }

                .step-item:last-child {
                    border-bottom: none;
                }

                .step-num {
                    width: 30px;
                    height: 30px;
                    border-radius: 50%;
                    background: #e0f7f4;
                    color: #00897b;
                    font-weight: 700;
                    font-size: 13px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    flex-shrink: 0;
                }

                /* Avatar sm */
                .avatar-sm {
                    width: 28px;
                    height: 28px;
                    border-radius: 50%;
                    background: #e0e0e0;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    flex-shrink: 0;
                }
            </style>

            <%@ include file="/common/admin-layout-top.jsp" %>

                <%-- Breadcrumb --%>
                    <div class="breadcrumb-custom">
                        <i class="bi bi-house-door me-1"></i> Trang chủ &gt;
                        <a href="${pageContext.request.contextPath}/workflows"
                            class="text-decoration-none text-secondary ms-1 me-1">Quản lý Workflow</a>
                        &gt; <span class="ms-1">
                            <c:out value="${workflow.workflowName}" />
                        </span>
                    </div>

                    <%-- Flash messages --%>
                        <c:if test="${not empty sessionScope.flashSuccess}">
                            <div class="alert alert-success alert-dismissible fade show d-flex align-items-center gap-2"
                                role="alert">
                                <i class="bi bi-check-circle-fill"></i>
                                <span>${sessionScope.flashSuccess}</span>
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                            <c:remove var="flashSuccess" scope="session" />
                        </c:if>
                        <c:if test="${not empty sessionScope.flashError}">
                            <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center gap-2"
                                role="alert">
                                <i class="bi bi-exclamation-triangle-fill"></i>
                                <span>${sessionScope.flashError}</span>
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                            <c:remove var="flashError" scope="session" />
                        </c:if>

                        <%-- Action bar --%>
                            <div class="action-bar-detail">
                                <div class="page-heading">
                                    <i class="bi bi-diagram-3-fill text-primary"></i>
                                    <c:out value="${workflow.workflowName}" />
                                    <span class="badge-status badge-${workflow.status.toLowerCase()}">
                                        <c:out value="${workflow.status}" />
                                    </span>
                                </div>
                                <div class="d-flex gap-2 flex-wrap">
                                    <a href="${pageContext.request.contextPath}/workflows"
                                        class="btn btn-secondary btn-sm d-flex align-items-center gap-1">
                                        <i class="bi bi-arrow-left"></i> Quay lại
                                    </a>
                                    <a href="${pageContext.request.contextPath}/workflows?action=edit&id=${workflow.workflowId}"
                                        class="btn btn-warning btn-sm d-flex align-items-center gap-1">
                                        <i class="bi bi-pencil"></i> Chỉnh sửa
                                    </a>
                                    <c:choose>
                                        <c:when test="${workflow.status == 'ACTIVE'}">
                                            <button
                                                class="btn btn-outline-warning btn-sm d-flex align-items-center gap-1"
                                                onclick="confirmToggle(${workflow.workflowId}, 'INACTIVE', '${workflow.workflowName}')">
                                                <i class="bi bi-pause-circle"></i> Vô hiệu hóa
                                            </button>
                                        </c:when>
                                        <c:when test="${workflow.status == 'INACTIVE'}">
                                            <button
                                                class="btn btn-outline-success btn-sm d-flex align-items-center gap-1"
                                                onclick="confirmToggle(${workflow.workflowId}, 'ACTIVE', '${workflow.workflowName}')">
                                                <i class="bi bi-play-circle"></i> Kích hoạt
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button
                                                class="btn btn-outline-primary btn-sm d-flex align-items-center gap-1"
                                                onclick="confirmToggle(${workflow.workflowId}, 'ACTIVE', '${workflow.workflowName}')">
                                                <i class="bi bi-send-check"></i> Publish
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                    <button class="btn btn-outline-danger btn-sm d-flex align-items-center gap-1"
                                        onclick="confirmDelete(${workflow.workflowId}, '${workflow.workflowName}')">
                                        <i class="bi bi-trash3"></i> Xóa
                                    </button>
                                </div>
                            </div>

                            <%-- Main content: 2-column layout --%>
                                <div class="row g-4">

                                    <%-- ── Left col: main info ─────────────────────────────── --%>
                                        <div class="col-lg-8">

                                            <%-- Info card --%>
                                                <div class="detail-card">
                                                    <div class="detail-card-header">
                                                        <i class="bi bi-diagram-3-fill text-primary"></i>
                                                        Thông tin Workflow
                                                    </div>
                                                    <div class="detail-card-body">
                                                        <div class="mb-3">
                                                            <div class="detail-label">Tên Workflow</div>
                                                            <div class="detail-value fs-6 fw-semibold">
                                                                <c:out value="${workflow.workflowName}" />
                                                            </div>
                                                        </div>

                                                        <div class="mb-3">
                                                            <div class="detail-label">Mô tả</div>
                                                            <div class="detail-value text-muted">
                                                                <c:choose>
                                                                    <c:when test="${not empty workflow.description}">
                                                                        <c:out value="${workflow.description}" />
                                                                    </c:when>
                                                                    <c:otherwise><em>Không có mô tả.</em></c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </div>

                                                        <hr />

                                                        <%-- Meta grid --%>
                                                            <div class="row g-3">
                                                                <div class="col-sm-6">
                                                                    <div class="detail-label">Workflow ID</div>
                                                                    <div class="detail-value">
                                                                        <code
                                                                            class="text-info">#${workflow.workflowId}</code>
                                                                    </div>
                                                                </div>
                                                                <div class="col-sm-6">
                                                                    <div class="detail-label">Người tạo</div>
                                                                    <div
                                                                        class="detail-value d-flex align-items-center gap-2 mt-1">
                                                                        <div class="avatar-sm">
                                                                            <i class="bi bi-person-fill text-secondary"
                                                                                style="font-size:12px;"></i>
                                                                        </div>
                                                                        <span>
                                                                            <c:choose>
                                                                                <c:when
                                                                                    test="${not empty workflow.createdByName}">
                                                                                    <c:out
                                                                                        value="${workflow.createdByName}" />
                                                                                </c:when>
                                                                                <c:otherwise>Không xác định
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </span>
                                                                    </div>
                                                                </div>
                                                                <div class="col-sm-6">
                                                                    <div class="detail-label">Cập nhật lần cuối</div>
                                                                    <div class="detail-value">
                                                                        <c:choose>
                                                                            <c:when
                                                                                test="${not empty workflow.updatedAt}">
                                                                                <fmt:formatDate
                                                                                    value="${workflow.updatedAt}"
                                                                                    pattern="dd/MM/yyyy" /><br />
                                                                                <span class="text-muted"
                                                                                    style="font-size:11px;">
                                                                                    <fmt:formatDate
                                                                                        value="${workflow.updatedAt}"
                                                                                        pattern="HH:mm" />
                                                                                </span>
                                                                            </c:when>
                                                                            <c:otherwise><span
                                                                                    class="text-muted">—</span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </div>
                                                                </div>
                                                                <div class="col-sm-6">
                                                                    <div class="detail-label">Trạng thái</div>
                                                                    <div class="detail-value mt-1">
                                                                        <span
                                                                            class="badge-status badge-${workflow.status.toLowerCase()}">
                                                                            <c:out value="${workflow.status}" />
                                                                        </span>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                    </div>
                                                </div>

                                                <%-- Workflow Summary card --%>
                                                    <div class="detail-card">
                                                        <div class="detail-card-header">
                                                            <i class="bi bi-eye text-success"></i>
                                                            Tóm tắt Workflow
                                                        </div>
                                                        <div class="detail-card-body" id="workflowSummary">
                                                            <div class="text-center py-4 text-muted"
                                                                id="summaryLoading">
                                                                <div class="spinner-border spinner-border-sm mb-2">
                                                                </div>
                                                                <p class="mb-0">Đang tải tóm tắt...</p>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <%-- Raw JSON config (collapsible) --%>
                                                        <div class="detail-card">
                                                            <!--                                                            <div class="detail-card-header" data-bs-toggle="collapse"
                data-bs-target="#jsonCollapse">
                <i class="bi bi-code-square text-info"></i>
                Cấu hình thô (JSON)
                <i class="bi bi-chevron-down ms-auto text-muted"></i>
            </div>-->
                                                            <div class="collapse" id="jsonCollapse">
                                                                <div class="detail-card-body">
                                                                    <c:choose>
                                                                        <c:when
                                                                            test="${not empty workflow.workflowConfig}">
                                                                            <pre class="config-preview"
                                                                                id="rawConfigJson"><c:out value="${workflow.workflowConfig}"/></pre>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <div class="text-center py-4 text-muted">
                                                                                <i
                                                                                    class="bi bi-braces fs-3 opacity-50"></i>
                                                                                <p class="mt-2 mb-0">Chưa có cấu hình.
                                                                                </p>
                                                                            </div>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </div>
                                                            </div>
                                                        </div>

                                        </div><%-- /.col-lg-8 --%>

                                            <%-- ── Right col: sidebar ────────────────── --%>
                                                <div class="col-lg-4">

                                                    <%-- Status control card --%>
                                                        <div class="detail-card">
                                                            <div class="detail-card-header">
                                                                <i class="bi bi-toggle-on text-success"></i>
                                                                Điều khiển trạng thái
                                                            </div>
                                                            <div class="detail-card-body">
                                                                <p class="text-muted small mb-3">
                                                                    Thay đổi trạng thái để kiểm soát workflow có được sử
                                                                    dụng bởi hệ thống ticket hay không.
                                                                </p>
                                                                <c:if test="${workflow.status != 'ACTIVE'}">
                                                                    <button
                                                                        class="btn btn-success w-100 mb-2 d-flex align-items-center justify-content-center gap-2"
                                                                        onclick="confirmToggle(${workflow.workflowId}, 'ACTIVE', '${workflow.workflowName}')">
                                                                        <i class="bi bi-play-circle-fill"></i>
                                                                        ${workflow.status == 'DRAFT' ? 'Publish & Kích
                                                                        hoạt' : 'Kích hoạt Workflow'}
                                                                    </button>
                                                                </c:if>
                                                                <c:if test="${workflow.status == 'ACTIVE'}">
                                                                    <button
                                                                        class="btn btn-warning w-100 mb-2 d-flex align-items-center justify-content-center gap-2"
                                                                        onclick="confirmToggle(${workflow.workflowId}, 'INACTIVE', '${workflow.workflowName}')">
                                                                        <i class="bi bi-pause-circle-fill"></i> Vô hiệu
                                                                        hóa Workflow
                                                                    </button>
                                                                </c:if>
                                                                <c:if test="${workflow.status != 'DRAFT'}">
                                                                    <div class="text-center mt-2">
                                                                        <small class="text-muted">
                                                                            Trạng thái hiện tại:
                                                                            <span
                                                                                class="badge-status badge-${workflow.status.toLowerCase()} ms-1">
                                                                                <c:out value="${workflow.status}" />
                                                                            </span>
                                                                        </small>
                                                                    </div>
                                                                </c:if>
                                                                <c:if test="${workflow.status == 'DRAFT'}">
                                                                    <div class="alert alert-info d-flex gap-2 p-2 mt-2"
                                                                        role="alert">
                                                                        <i
                                                                            class="bi bi-info-circle-fill flex-shrink-0"></i>
                                                                        <small>Workflow ở trạng thái Draft chưa được hệ
                                                                            thống ticket sử dụng.</small>
                                                                    </div>
                                                                </c:if>
                                                            </div>
                                                        </div>

                                                        <%-- Quick actions card --%>
                                                            <div class="detail-card">
                                                                <div class="detail-card-header">
                                                                    <i class="bi bi-lightning text-warning"></i>
                                                                    Thao tác nhanh
                                                                </div>
                                                                <div class="detail-card-body d-flex flex-column gap-2">
                                                                    <a href="${pageContext.request.contextPath}/workflows?action=edit&id=${workflow.workflowId}"
                                                                        class="btn-quick">
                                                                        <i class="bi bi-pencil-square text-warning"></i>
                                                                        Chỉnh sửa Workflow
                                                                    </a>
                                                                    <a href="${pageContext.request.contextPath}/workflows"
                                                                        class="btn-quick">
                                                                        <i class="bi bi-list-ul text-info"></i> Tất cả
                                                                        Workflow
                                                                    </a>
                                                                    <a href="${pageContext.request.contextPath}/workflows?action=create"
                                                                        class="btn-quick">
                                                                        <i class="bi bi-plus-lg text-success"></i> Thêm
                                                                        Workflow mới
                                                                    </a>
                                                                    <hr class="my-1" />
                                                                    <button class="btn-quick btn-quick-danger"
                                                                        onclick="confirmDelete(${workflow.workflowId}, '${workflow.workflowName}')">
                                                                        <i class="bi bi-trash3"></i> Xóa Workflow
                                                                    </button>
                                                                </div>
                                                            </div>

                                                </div><%-- /.col-lg-4 --%>
                                </div><%-- /.row --%>

                                    <%-- DELETE MODAL (light theme, matches workflow-list) --%>
                                        <div class="modal fade" id="deleteModal" tabindex="-1">
                                            <div class="modal-dialog modal-dialog-centered">
                                                <div class="modal-content border-0 shadow">
                                                    <div class="modal-header bg-danger text-white">
                                                        <h5 class="modal-title"><i class="bi bi-trash3 me-2"></i>Xóa
                                                            Workflow</h5>
                                                        <button type="button" class="btn-close btn-close-white"
                                                            data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <p class="text-muted mb-0">
                                                            Bạn có chắc muốn xóa workflow <strong
                                                                id="deleteWfName"></strong>?
                                                            Hành động này <span class="text-danger fw-semibold">không
                                                                thể hoàn tác</span>.
                                                        </p>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn btn-secondary"
                                                            data-bs-dismiss="modal">Hủy</button>
                                                        <button type="button" class="btn btn-danger"
                                                            id="confirmDeleteBtn">
                                                            <i class="bi bi-trash3 me-1"></i> Xóa
                                                        </button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <%-- TOGGLE MODAL (matches workflow-list) --%>
                                            <div class="modal fade" id="toggleModal" tabindex="-1">
                                                <div class="modal-dialog modal-dialog-centered">
                                                    <div class="modal-content border-0 shadow">
                                                        <div class="modal-header">
                                                            <h5 class="modal-title" id="toggleModalTitle">Thay đổi trạng
                                                                thái</h5>
                                                            <button type="button" class="btn-close"
                                                                data-bs-dismiss="modal"></button>
                                                        </div>
                                                        <div class="modal-body">
                                                            <p class="text-muted mb-0" id="toggleModalBody"></p>
                                                        </div>
                                                        <div class="modal-footer">
                                                            <button type="button" class="btn btn-secondary"
                                                                data-bs-dismiss="modal">Hủy</button>
                                                            <button type="button" class="btn btn-primary"
                                                                id="confirmToggleBtn">Xác nhận</button>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <%-- Categories metadata for summary rendering --%>
                                                <script type="application/json" id="metaCategories">
    [
    <c:forEach items="${categories}" var="cat" varStatus="loop">
        {"id": ${cat.categoryId}, "name": "${cat.categoryName}"}${!loop.last ? ',' : ''}
    </c:forEach>
    ]
</script>

                                                <script>
                                                    const CTX = '${pageContext.request.contextPath}';
                                                    const CATEGORIES = JSON.parse(document.getElementById('metaCategories').textContent || '[]');

                                                    // ── Tooltips ──
                                                    document.addEventListener('DOMContentLoaded', function () {
                                                        document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(function (el) {
                                                            new bootstrap.Tooltip(el, { trigger: 'hover' });
                                                        });
                                                    });

                                                    // ── Modal helpers ──
                                                    function getDeleteModal() {
                                                        return bootstrap.Modal.getOrCreateInstance(document.getElementById('deleteModal'));
                                                    }
                                                    function getToggleModal() {
                                                        return bootstrap.Modal.getOrCreateInstance(document.getElementById('toggleModal'));
                                                    }

                                                    // ── Safe JSON parser ──
                                                    async function safeJson(res) {
                                                        var text = await res.text();
                                                        try {
                                                            return JSON.parse(text);
                                                        } catch (e) {
                                                            return { success: false, message: 'Server error (HTTP ' + res.status + ').' };
                                                        }
                                                    }

                                                    // ── DELETE ──
                                                    var pendingDeleteId = null;
                                                    function confirmDelete(id, name) {
                                                        pendingDeleteId = id;
                                                        document.getElementById('deleteWfName').textContent = name;
                                                        var btn = document.getElementById('confirmDeleteBtn');
                                                        btn.disabled = false;
                                                        btn.innerHTML = '<i class="bi bi-trash3 me-1"></i> Xóa';
                                                        getDeleteModal().show();
                                                    }

                                                    document.getElementById('confirmDeleteBtn').addEventListener('click', async function () {
                                                        if (!pendingDeleteId)
                                                            return;
                                                        var btn = document.getElementById('confirmDeleteBtn');
                                                        btn.disabled = true;
                                                        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Đang xóa…';
                                                        try {
                                                            var form = new FormData();
                                                            form.append('action', 'delete');
                                                            form.append('workflowId', pendingDeleteId);
                                                            var res = await fetch(CTX + '/workflows', { method: 'POST', body: form });
                                                            var data = await safeJson(res);
                                                            getDeleteModal().hide();
                                                            if (data.success) {
                                                                showToast('Xóa workflow thành công.', 'success');
                                                                setTimeout(function () {
                                                                    window.location.href = CTX + '/workflows';
                                                                }, 900);
                                                            } else {
                                                                showToast(data.message || 'Xóa thất bại.', 'danger');
                                                                btn.disabled = false;
                                                                btn.innerHTML = '<i class="bi bi-trash3 me-1"></i> Xóa';
                                                            }
                                                        } catch (err) {
                                                            showToast('Lỗi kết nối. Vui lòng thử lại.', 'danger');
                                                            btn.disabled = false;
                                                            btn.innerHTML = '<i class="bi bi-trash3 me-1"></i> Xóa';
                                                        }
                                                    });

                                                    // ── TOGGLE ──
                                                    var pendingToggleId = null;
                                                    var pendingNewStatus = null;
                                                    function confirmToggle(id, newStatus, name) {
                                                        pendingToggleId = id;
                                                        pendingNewStatus = newStatus;
                                                        var label = newStatus === 'ACTIVE' ? 'kích hoạt' : 'vô hiệu hóa';
                                                        document.getElementById('toggleModalTitle').textContent = 'Xác nhận thay đổi trạng thái';
                                                        document.getElementById('toggleModalBody').innerHTML =
                                                            'Bạn sắp <strong>' + label + '</strong> workflow <strong>' + name + '</strong>. Tiếp tục?';
                                                        var btn = document.getElementById('confirmToggleBtn');
                                                        btn.disabled = false;
                                                        btn.className = newStatus === 'ACTIVE' ? 'btn btn-success' : 'btn btn-warning';
                                                        btn.textContent = newStatus === 'ACTIVE' ? 'Kích hoạt' : 'Vô hiệu hóa';
                                                        getToggleModal().show();
                                                    }

                                                    document.getElementById('confirmToggleBtn').addEventListener('click', async function () {
                                                        if (!pendingToggleId)
                                                            return;
                                                        var btn = document.getElementById('confirmToggleBtn');
                                                        btn.disabled = true;
                                                        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Đang lưu…';
                                                        try {
                                                            var form = new FormData();
                                                            form.append('action', 'toggle');
                                                            form.append('workflowId', pendingToggleId);
                                                            form.append('newStatus', pendingNewStatus);
                                                            var res = await fetch(CTX + '/workflows', { method: 'POST', body: form });
                                                            var data = await safeJson(res);
                                                            getToggleModal().hide();
                                                            if (data.success) {
                                                                showToast('Cập nhật trạng thái thành công.', 'success');
                                                                setTimeout(function () {
                                                                    location.reload();
                                                                }, 900);
                                                            } else {
                                                                showToast(data.message || 'Cập nhật thất bại.', 'danger');
                                                                btn.disabled = false;
                                                                btn.textContent = pendingNewStatus === 'ACTIVE' ? 'Kích hoạt' : 'Vô hiệu hóa';
                                                            }
                                                        } catch (err) {
                                                            showToast('Lỗi kết nối. Vui lòng thử lại.', 'danger');
                                                            btn.disabled = false;
                                                            btn.textContent = pendingNewStatus === 'ACTIVE' ? 'Kích hoạt' : 'Vô hiệu hóa';
                                                        }
                                                    });

                                                    // ── Toast helper (same as workflow-list) ──
                                                    function showToast(message, type) {
                                                        var t = document.createElement('div');
                                                        t.className = 'toast align-items-center text-white bg-' + type + ' border-0 position-fixed bottom-0 end-0 m-3';
                                                        t.setAttribute('role', 'alert');
                                                        t.style.zIndex = 9999;
                                                        t.innerHTML = '<div class="d-flex"><div class="toast-body fw-semibold">' + message +
                                                            '</div><button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button></div>';
                                                        document.body.appendChild(t);
                                                        new bootstrap.Toast(t, { delay: 3000 }).show();
                                                        t.addEventListener('hidden.bs.toast', function () {
                                                            t.remove();
                                                        });
                                                    }

                                                    // ── SUMMARY RENDERING ──
                                                    (function initSummary() {
                                                        const configEl = document.getElementById('rawConfigJson');
                                                        const raw = configEl ? configEl.textContent.trim() : '';
                                                        const summaryDiv = document.getElementById('workflowSummary');
                                                        if (!raw || raw === 'null' || raw === '') {
                                                            summaryDiv.innerHTML = '<div class="alert alert-info">Chưa có cấu hình.</div>';
                                                            return;
                                                        }
                                                        try {
                                                            const cfg = JSON.parse(raw);
                                                            let html = '';

                                                            // Trigger
                                                            html += `<div class="mb-4">
                                <div class="detail-label mb-2"><i class="bi bi-lightning-fill text-warning me-1"></i> Trigger</div>
                                <span class="badge bg-primary fs-6">\${cfg.trigger || 'Unknown'}</span>
                            </div>`;

                                                            // Conditions
                                                            if (cfg.conditions) {
                                                                html += `<div class="mb-4">
                                    <div class="detail-label mb-2"><i class="bi bi-filter-circle text-info me-1"></i> Điều kiện kích hoạt</div>`;

                                                                function renderSummaryNode(node) {
                                                                    if (!node)
                                                                        return '';
                                                                    if (node.type === 'condition' || node.field) {
                                                                        let fieldLabel = (node.field || '').replace('_', ' ').toUpperCase();
                                                                        let val = node.value;
                                                                        if (node.field === 'category_id') {
                                                                            const cat = CATEGORIES.find(c => c.id == val);
                                                                            val = cat ? cat.name : ('Category #' + val);
                                                                        }
                                                                        let badgeClass = 'bg-info bg-opacity-25 border-info';
                                                                        if (node.field === 'priority')
                                                                            badgeClass = 'bg-warning bg-opacity-25 border-warning';
                                                                        if (node.field === 'ticket_type')
                                                                            badgeClass = 'bg-primary bg-opacity-25 border-primary';
                                                                        return `<span class="badge border ${badgeClass} fw-semibold p-2 px-3 rounded-pill my-1" style="color:#212529">
                                            <span class="opacity-75 fw-normal">\${fieldLabel}</span>
                                            <span class="mx-1">\${node.operator === 'NOT_EQUALS' ? 'không phải' : 'là'}</span>
                                            <strong>\${val}</strong>
                                        </span>`;
                                                                    } else if (node.type === 'group' || node.logic) {
                                                                        const logic = node.logic || 'AND';
                                                                        const criteria = node.criteria || [];
                                                                        if (criteria.length === 0)
                                                                            return '';
                                                                        const childrenHtml = criteria.map(c => renderSummaryNode(c)).join('');
                                                                        return `<div class="border rounded p-2 px-3 bg-light my-2">
                                            <div class="small text-muted mb-1" style="font-size:10px;">MATCH \${logic}</div>
                                            <div class="d-flex flex-wrap gap-2">\${childrenHtml}</div>
                                        </div>`;
                                                                    }
                                                                    return '';
                                                                }

                                                                if (Array.isArray(cfg.conditions)) {
                                                                    html += `<div class="d-flex flex-wrap gap-2">` + cfg.conditions.map(c => renderSummaryNode(c)).join('') + `</div>`;
                                                                } else {
                                                                    html += renderSummaryNode(cfg.conditions);
                                                                }
                                                                html += `</div>`;
                                                            }

                                                            // Steps
                                                            if (cfg.steps && cfg.steps.length > 0) {
                                                                html += `<div class="mb-0">
                                <div class="detail-label mb-2"><i class="bi bi-list-ol text-success me-1"></i> Các bước xử lý</div>
                                <div>`;
                                                                cfg.steps.forEach((s, idx) => {
                                                                    let assignees = '';
                                                                    if (s.users && s.users.length > 0) {
                                                                        assignees = s.users.map(u => `<span class="badge bg-primary bg-opacity-10 text-primary border border-primary-subtle rounded-pill px-2 py-1"><i class="bi bi-person-fill"></i> \${u.fullName}</span>`).join(' ');
                                                                    } else if (s.legacyRole) {
                                                                        assignees = `<span class="badge bg-secondary bg-opacity-10 text-secondary border border-secondary-subtle rounded-pill px-2 py-1"><i class="bi bi-people-fill"></i> \${s.legacyRole}</span>`;
                                                                    } else if (s.role) {
                                                                        assignees = `<span class="badge bg-secondary bg-opacity-10 text-secondary border border-secondary-subtle rounded-pill px-2 py-1"><i class="bi bi-people-fill"></i> \${s.role}</span>`;
                                                                    } else {
                                                                        assignees = `<span class="text-muted fst-italic">Chưa phân công</span>`;
                                                                    }

                                                                    html += `<div class="step-item">
                                        <div class="step-num">\${idx + 1}</div>
                                        <div class="flex-grow-1">
                                            <div class="fw-semibold">\${s.name || 'Bước ' + (idx + 1)}</div>
                                            \${s.description ? '<div class="small text-muted mb-1">' + s.description + '</div>' : ''}
                                            <div class="small text-muted mt-2 d-flex flex-wrap align-items-center gap-2">
                                                <span>Phụ trách:</span> \${assignees}
                                                <span class="text-muted mx-1">&bull;</span>
                                                <span>Hành động: <span class="text-primary fw-semibold">\${s.action}</span></span>
                                            </div>
                                        </div>
                                    </div>`;
                                                                });
                                                                html += `</div></div>`;
                                                            }

                                                            summaryDiv.innerHTML = html;
                                                        } catch (e) {
                                                            summaryDiv.innerHTML = '<div class="alert alert-danger">Lỗi khi phân tích cấu hình JSON.</div>';
                                                        }
                                                    })();
                                                </script>

                                                <jsp:include page="/common/admin-layout-bottom.jsp" />