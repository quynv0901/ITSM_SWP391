<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
    .breadcrumb-custom {
        display: flex;
        justify-content: flex-end;
        font-size: 0.9rem;
        color: #666;
        margin-bottom: 20px;
    }

    .action-bar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
        gap: 12px;
        flex-wrap: wrap;
    }

    .btn-add-workflow {
        background-color: #00bcd4;
        color: white;
        border: none;
        padding: 8px 15px;
        border-radius: 4px;
        display: flex;
        align-items: center;
        gap: 8px;
        font-weight: 500;
        text-decoration: none;
        font-size: 0.9rem;
        transition: background-color 0.2s;
    }

    .btn-add-workflow:hover {
        background-color: #00acc1;
        color: white;
    }

    /* Stat cards */
    .stat-row {
        display: flex;
        gap: 15px;
        margin-bottom: 20px;
        flex-wrap: wrap;
    }

    .stat-card {
        background: #fff;
        border: 1px solid #ddd;
        border-radius: 6px;
        padding: 14px 20px;
        flex: 1;
        min-width: 130px;
        display: flex;
        align-items: center;
        gap: 14px;
        box-shadow: 0 1px 4px rgba(0, 0, 0, .06);
    }

    .stat-icon {
        width: 42px;
        height: 42px;
        border-radius: 8px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        flex-shrink: 0;
    }

    .stat-label {
        font-size: 11px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: .6px;
        color: #888;
    }

    .stat-value {
        font-size: 22px;
        font-weight: 700;
        color: #333;
        line-height: 1.2;
    }

    /* Search panel */
    .search-panel {
        background: #fff;
        padding: 12px 15px;
        border: 1px solid #ddd;
        border-radius: 4px;
        margin-bottom: 20px;
        display: flex;
        gap: 10px;
        align-items: center;
        flex-wrap: wrap;
    }

    /* Filter tabs */
    .filter-tabs {
        display: flex;
        gap: 4px;
    }

    .filter-tab {
        padding: 5px 13px;
        border-radius: 4px;
        font-size: 13px;
        font-weight: 500;
        color: #555;
        text-decoration: none;
        background: #f4f4f4;
        border: 1px solid #ddd;
        transition: all .15s;
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }

    .filter-tab:hover {
        background: #e0e0e0;
        color: #333;
    }

    .filter-tab.active {
        background: #3c8dbc;
        color: #fff;
        border-color: #3c8dbc;
    }

    .filter-tab .fc {
        background: rgba(0, 0, 0, .12);
        padding: 1px 6px;
        border-radius: 10px;
        font-size: 10px;
        font-weight: 700;
    }

    .filter-tab.active .fc {
        background: rgba(255, 255, 255, .25);
    }

    /* Table */
    .table-container {
        background: #fff;
        border: 1px solid #ddd;
        border-radius: 4px;
        overflow-x: auto;
    }

    .admin-table thead {
        background-color: #3c8dbc;
        color: white;
    }

    .admin-table th {
        font-weight: 500;
        border-bottom: none;
        padding: 11px 14px;
    }

    .admin-table td {
        vertical-align: middle;
        padding: 11px 14px;
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

    /* Action buttons */
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

    /* Empty state */
    .empty-state {
        padding: 60px 20px;
        text-align: center;
        color: #999;
    }

    .empty-state i {
        font-size: 52px;
        opacity: .3;
    }
</style>

<%@ include file="/common/admin-layout-top.jsp" %>

<div class="breadcrumb-custom">
    <i class="bi bi-house-door me-1"></i> Trang chủ &gt; Quản lý Workflow
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
<div class="action-bar">
    <div class="stat-row mb-0" style="flex:1;">
        <div class="stat-card">
            <div class="stat-icon" style="background:#e3f2fd;">
                <i class="bi bi-diagram-3-fill text-primary"></i>
            </div>
            <div>
                <div class="stat-label">Tổng</div>
                <div class="stat-value">${countAll}</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#e0f7f4;">
                <i class="bi bi-play-circle-fill" style="color:#00897b;"></i>
            </div>
            <div>
                <div class="stat-label">Active</div>
                <div class="stat-value">${countActive}</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#fff8e1;">
                <i class="bi bi-pause-circle-fill text-warning"></i>
            </div>
            <div>
                <div class="stat-label">Inactive</div>
                <div class="stat-value">${countInactive}</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#e8eaf6;">
                <i class="bi bi-pencil-square" style="color:#3949ab;"></i>
            </div>
            <div>
                <div class="stat-label">Draft</div>
                <div class="stat-value">${countDraft}</div>
            </div>
        </div>
    </div>
    <a href="${pageContext.request.contextPath}/workflows?action=create"
       class="btn-add-workflow flex-shrink-0">
        <i class="bi bi-plus-lg"></i> Thêm Workflow
    </a>
</div>

<%-- Search + filter --%>
<div class="search-panel shadow-sm">
    <div class="filter-tabs">
        <a class="filter-tab ${statusFilter == '' ? 'active' : ''}"
           href="${pageContext.request.contextPath}/workflows">
            Tất cả <span class="fc">${countAll}</span>
        </a>
        <a class="filter-tab ${statusFilter == 'ACTIVE' ? 'active' : ''}"
           href="${pageContext.request.contextPath}/workflows?status=ACTIVE">
            Active <span class="fc">${countActive}</span>
        </a>
        <a class="filter-tab ${statusFilter == 'INACTIVE' ? 'active' : ''}"
           href="${pageContext.request.contextPath}/workflows?status=INACTIVE">
            Inactive <span class="fc">${countInactive}</span>
        </a>
        <a class="filter-tab ${statusFilter == 'DRAFT' ? 'active' : ''}"
           href="${pageContext.request.contextPath}/workflows?status=DRAFT">
            Draft <span class="fc">${countDraft}</span>
        </a>
    </div>
    <div class="ms-auto" style="max-width:280px; width:100%;">
        <div class="input-group input-group-sm">
            <input type="text" id="searchInput" class="form-control"
                   placeholder="Tìm workflow…" value="${search}"
                                            onkeydown="if(event.key==='Enter') filterTable()" />
                                        <button class="btn btn-primary" type="button" onclick="filterTable()">
                                            <i class="bi bi-search"></i>
                                        </button>
        </div>
    </div>
</div>

<%-- Table --%>
<div class="table-container shadow-sm">
    <table class="table admin-table mb-0" id="workflowTable">
        <thead>
            <tr>
                <th>#</th>
                <th>Tên Workflow</th>
                <th>Mô tả</th>
                <th>Trạng thái</th>
                <th>Người tạo</th>
                <th>Cập nhật</th>
                <th class="text-center">Thao tác</th>
            </tr>
        </thead>
        <tbody>
            <c:choose>
                <c:when test="${empty workflows}">
                    <tr>
                        <td colspan="7">
                            <div class="empty-state">
                                <i class="bi bi-diagram-3"></i>
                                <h5 class="mt-3">Chưa có workflow nào</h5>
                                <p class="mb-4">Bắt đầu bằng cách tạo workflow đầu tiên.
                                </p>
                                <a href="${pageContext.request.contextPath}/workflows?action=create"
                                   class="btn btn-primary">
                                    <i class="bi bi-plus-lg me-1"></i> Tạo Workflow
                                </a>
                            </div>
                        </td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="wf" items="${workflows}" varStatus="loop">
                        <tr data-name="${wf.workflowName}">
                            <td class="text-muted">${loop.index + 1}</td>
                            <td>
                                <a href="${pageContext.request.contextPath}/workflows?action=detail&id=${wf.workflowId}"
                                   class="text-primary fw-bold text-decoration-none">
                                    <i class="bi bi-diagram-3 me-1 text-muted"></i>
                                    <c:out value="${wf.workflowName}" />
                                </a>
                            </td>
                            <td>
                                <span class="text-muted" style="font-size:13px;">
                                    <c:choose>
                                        <c:when test="${not empty wf.description}">
                                            <c:out value="${wf.description.length() > 60
                                                            ? wf.description.substring(0, 60).concat('…')
                                                            : wf.description}" />
                                        </c:when>
                                        <c:otherwise><em>Không có mô tả</em>
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                            </td>
                            <td>
                                <span
                                    class="badge-status badge-${wf.status.toLowerCase()}">
                                    <c:out value="${wf.status}" />
                                </span>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty wf.createdByName}">
                                        <div class="d-flex align-items-center gap-2">
                                            <div class="d-flex align-items-center justify-content-center bg-secondary bg-opacity-25 rounded-circle flex-shrink-0"
                                                 style="width:26px;height:26px;">
                                                <i class="bi bi-person-fill text-secondary"
                                                   style="font-size:11px;"></i>
                                            </div>
                                            <span style="font-size:13px;">
                                                <c:out value="${wf.createdByName}" />
                                            </span>
                                        </div>
                                    </c:when>
                                    <c:otherwise><span class="text-muted">—</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td style="font-size:13px;">
                                <c:choose>
                                    <c:when test="${not empty wf.updatedAt}">
                                        <fmt:formatDate value="${wf.updatedAt}"
                                                        pattern="dd/MM/yyyy" /><br />
                                        <span class="text-muted"
                                              style="font-size:11px;">
                                            <fmt:formatDate value="${wf.updatedAt}"
                                                            pattern="HH:mm" />
                                        </span>
                                    </c:when>
                                    <c:otherwise><span class="text-muted">—</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center">
                                <div
                                    class="d-flex align-items-center justify-content-center gap-1">
                                    <%-- View --%>
                                    <a href="${pageContext.request.contextPath}/workflows?action=detail&id=${wf.workflowId}"
                                       class="btn-act bg-info text-white"
                                       title="Xem chi tiết"
                                       data-bs-toggle="tooltip">
                                        <i class="bi bi-eye"></i>
                                    </a>
                                    <%-- Edit --%>
                                    <a href="${pageContext.request.contextPath}/workflows?action=edit&id=${wf.workflowId}"
                                       class="btn-act bg-warning text-dark"
                                       title="Chỉnh sửa"
                                       data-bs-toggle="tooltip">
                                        <i class="bi bi-pencil"></i>
                                    </a>
                                    <%-- Toggle --%>
                                    <c:choose>
                                        <c:when
                                            test="${wf.status == 'ACTIVE'}">
                                            <button
                                                class="btn-act bg-warning text-dark"
                                                title="Vô hiệu hóa"
                                                data-bs-toggle="tooltip"
                                                onclick="confirmToggle(${wf.workflowId}, 'INACTIVE', '${wf.workflowName}')">
                                                <i
                                                    class="bi bi-pause-circle"></i>
                                            </button>
                                        </c:when>
                                        <c:when
                                            test="${wf.status == 'INACTIVE'}">
                                            <button
                                                class="btn-act bg-success text-white"
                                                title="Kích hoạt"
                                                data-bs-toggle="tooltip"
                                                onclick="confirmToggle(${wf.workflowId}, 'ACTIVE', '${wf.workflowName}')">
                                                <i
                                                    class="bi bi-play-circle"></i>
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button
                                                class="btn-act bg-primary text-white"
                                                title="Publish"
                                                data-bs-toggle="tooltip"
                                                onclick="confirmToggle(${wf.workflowId}, 'ACTIVE', '${wf.workflowName}')">
                                                <i
                                                    class="bi bi-send-check"></i>
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                    <%-- Delete --%>
                                    <button
                                        class="btn-act bg-danger text-white"
                                        title="Xóa"
                                        data-bs-toggle="tooltip"
                                        onclick="confirmDelete(${wf.workflowId}, '${wf.workflowName}')">
                                        <i class="bi bi-trash3"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </tbody>
    </table>

    <c:if test="${totalPages > 0}">
        <div
            class="p-3 bg-light border-top d-flex justify-content-between align-items-center flex-wrap gap-2">
                                            <span class="text-muted small">
                                                Trang <strong>${currentPage}</strong> / <strong>${totalPages}</strong>
                                                <!--&nbsp;&mdash;&nbsp;-->
<!--                                                Hiển thị <strong>${fromIdx}&ndash;${toIdx}</strong> /
                                                <strong>${totalCount}</strong> workflow-->
                                            </span>
                                            <nav>
                                                <ul class="pagination pagination-sm mb-0">
                                                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                                        <a class="page-link" href="javascript:void(0)"
                                                            onclick="handlePageChange(${currentPage - 1})">Trước</a>
                                                    </li>
                                                    <c:forEach var="i" begin="1" end="${totalPages}">
                                                        <li class="page-item ${currentPage == i ? 'active' : ''}">
                                                            <a class="page-link" href="javascript:void(0)"
                                                                onclick="handlePageChange(${i})">${i}</a>
                                                        </li>
                                                    </c:forEach>
                                                    <li
                                                        class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                                        <a class="page-link" href="javascript:void(0)"
                                                            onclick="handlePageChange(${currentPage + 1})">Sau</a>
                                                    </li>
                                                </ul>
                                            </nav>
        </div>
    </c:if>
</div>

<%-- DELETE MODAL --%>
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
                    Hành động này <span class="text-danger fw-semibold">không thể
                        hoàn tác</span>.
                </p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary"
                        data-bs-dismiss="modal">Hủy</button>
                <button type="button" class="btn btn-danger" id="confirmDeleteBtn"
                        onclick="doDelete()">
                    <i class="bi bi-trash3 me-1"></i> Xóa
                </button>
            </div>
        </div>
    </div>
</div>

<%-- TOGGLE MODAL --%>
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
                        id="confirmToggleBtn" onclick="doToggle()">Xác nhận</button>
            </div>
        </div>
    </div>
</div>

<script>
    const CTX = '${pageContext.request.contextPath}';

    // Tooltips
    document.addEventListener('DOMContentLoaded', function () {
        document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(function (el) {
            new bootstrap.Tooltip(el, {trigger: 'hover'});
        });
    });

                                            // Client-side search (redirect to server with keyword)
    function filterTable() {
        var q = document.getElementById('searchInput').value;
        var params = new URLSearchParams(window.location.search);
                                                params.set('search', q);
                                                params.set('page', '1');
                                                window.location.search = params.toString();
                                            }

                                            // Pagination
                                            function handlePageChange(page) {
                                                var params = new URLSearchParams(window.location.search);
                                                params.set('page', page);
                                                window.location.search = params.toString();
                                            }

    // Modal helpers
    function getDeleteModal() {
        return bootstrap.Modal.getOrCreateInstance(document.getElementById('deleteModal'));
    }
    function getToggleModal() {
        return bootstrap.Modal.getOrCreateInstance(document.getElementById('toggleModal'));
    }

    // Safe JSON parser
    async function safeJson(res) {
        var text = await res.text();
        try {
            return JSON.parse(text);
        } catch (e) {
            return {success: false, message: 'Server error (HTTP ' + res.status + ').'};
        }
    }

    // Delete
    var pendingDeleteId = null;
    function confirmDelete(id, name) {
        pendingDeleteId = id;
        document.getElementById('deleteWfName').textContent = name;
        var btn = document.getElementById('confirmDeleteBtn');
        btn.disabled = false;
        btn.innerHTML = '<i class="bi bi-trash3 me-1"></i> Xóa';
        getDeleteModal().show();
    }
    async function doDelete() {
        if (!pendingDeleteId)
            return;
        var btn = document.getElementById('confirmDeleteBtn');
        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Đang xóa…';
        try {
            var form = new URLSearchParams();
            form.append('action', 'delete');
            form.append('workflowId', pendingDeleteId);
            var res = await fetch(CTX + '/workflows', {method: 'POST', body: form, headers: {'Content-Type': 'application/x-www-form-urlencoded'}});
            var data = await safeJson(res);
            getDeleteModal().hide();
            if (data.success) {
                showToast('Xóa workflow thành công.', 'success');
                setTimeout(function () {
                    location.reload();
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
    }

    // Toggle
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
    async function doToggle() {
        if (!pendingToggleId)
            return;
        var btn = document.getElementById('confirmToggleBtn');
        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Đang lưu…';
        try {
            var form = new URLSearchParams();
            form.append('action', 'toggle');
            form.append('workflowId', pendingToggleId);
            form.append('newStatus', pendingNewStatus);
            var res = await fetch(CTX + '/workflows', {method: 'POST', body: form, headers: {'Content-Type': 'application/x-www-form-urlencoded'}});
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
    }

    // Toast helper
    function showToast(message, type) {
        var t = document.createElement('div');
        t.className = 'toast align-items-center text-white bg-' + type + ' border-0 position-fixed bottom-0 end-0 m-3';
        t.setAttribute('role', 'alert');
        t.style.zIndex = 9999;
        t.innerHTML = '<div class="d-flex"><div class="toast-body fw-semibold">' + message +
                '</div><button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button></div>';
        document.body.appendChild(t);
        new bootstrap.Toast(t, {delay: 3000}).show();
        t.addEventListener('hidden.bs.toast', function () {
            t.remove();
        });
    }
</script>

<jsp:include page="/common/admin-layout-bottom.jsp" />