<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<jsp:include page="/common/admin-layout-top.jsp" />

<style>
    /* ── Page header ─────────────────────────────────────────────── */
    .page-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 24px;
        flex-wrap: wrap;
        gap: 12px;
    }

    .page-title {
        font-size: 1.4rem;
        font-weight: 700;
        color: #222d32;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    /* ── Stat cards ──────────────────────────────────────────────── */
    .stat-row {
        display: flex;
        gap: 16px;
        flex-wrap: wrap;
        margin-bottom: 24px;
    }

    .stat-card {
        flex: 1;
        min-width: 160px;
        background: #fff;
        border: 1px solid #dde3ec;
        border-radius: 10px;
        padding: 16px 20px;
        display: flex;
        align-items: center;
        gap: 14px;
        box-shadow: 0 1px 4px rgba(0,0,0,.05);
    }

    .stat-icon {
        width: 46px;
        height: 46px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        flex-shrink: 0;
    }

    .stat-label {
        font-size: 11px;
        color: #6c757d;
        text-transform: uppercase;
        letter-spacing: .5px;
        margin-bottom: 2px;
    }

    .stat-value {
        font-size: 1.35rem;
        font-weight: 700;
        color: #222d32;
        line-height: 1;
    }

    /* ── Filter card ─────────────────────────────────────────────── */
    .filter-card {
        background: #fff;
        border: 1px solid #dde3ec;
        border-radius: 10px;
        padding: 18px 20px;
        margin-bottom: 20px;
        box-shadow: 0 1px 4px rgba(0,0,0,.04);
    }

    .filter-card .row { row-gap: 10px; }

    /* ── Table ───────────────────────────────────────────────────── */
    .table-card {
        background: #fff;
        border: 1px solid #dde3ec;
        border-radius: 10px;
        overflow: hidden;
        box-shadow: 0 1px 4px rgba(0,0,0,.04);
    }

    .table-card table { margin: 0; font-size: .875rem; }

    .table-card thead th {
        background: #f8f9fa;
        color: #495057;
        font-weight: 600;
        font-size: .78rem;
        text-transform: uppercase;
        letter-spacing: .4px;
        border-bottom: 2px solid #dee2e6;
        white-space: nowrap;
        padding: 12px 14px;
    }

    .table-card tbody td {
        padding: 11px 14px;
        vertical-align: middle;
        border-color: #f0f2f5;
    }

    .table-card tbody tr:hover { background: #f8f9fb; }

    /* ── Activity badges ─────────────────────────────────────────── */
    .badge-activity {
        font-size: .72rem;
        padding: 4px 10px;
        border-radius: 20px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: .3px;
    }

    .act-ASSIGNED     { background: #e3f2fd; color: #1565c0; }
    .act-INVESTIGATION{ background: #fff3e0; color: #e65100; }
    .act-RESOLVED     { background: #e8f5e9; color: #2e7d32; }
    .act-CLOSED       { background: #ede7f6; color: #4527a0; }
    .act-MANUAL       { background: #fce4ec; color: #880e4f; }

    /* ── Pagination ──────────────────────────────────────────────── */
    .pagination-row {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 14px 18px;
        border-top: 1px solid #f0f2f5;
        flex-wrap: wrap;
        gap: 8px;
    }

    .pagination-info { font-size: .82rem; color: #6c757d; }

    /* ── Inline edit ─────────────────────────────────────────────── */
    .btn-action {
        width: 30px;
        height: 30px;
        border-radius: 6px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border: 1px solid transparent;
        cursor: pointer;
        transition: .2s;
        font-size: .85rem;
        text-decoration: none;
    }

    .btn-edit  { background: #e3f2fd; color: #1565c0; border-color: #bbdefb; }
    .btn-edit:hover  { background: #1565c0; color: #fff; }
    .btn-delete{ background: #fce4ec; color: #880e4f; border-color: #f8bbd9; }
    .btn-delete:hover{ background: #880e4f; color: #fff; }

    /* ── Alert toast ─────────────────────────────────────────────── */
    .alert-top {
        position: fixed;
        top: 70px;
        right: 24px;
        z-index: 9999;
        min-width: 280px;
        animation: fadeSlide .35s ease;
    }

    @keyframes fadeSlide {
        from { opacity: 0; transform: translateY(-12px); }
        to   { opacity: 1; transform: translateY(0); }
    }
</style>

<!-- ── Toast notifications ───────────────────────────────────────────────── -->
<c:if test="${not empty param.updateSuccess}">
    <div class="alert alert-success alert-dismissible alert-top shadow" id="toastMsg">
        <i class="bi bi-check-circle-fill me-2"></i> Cập nhật time log thành công.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
<c:if test="${not empty param.deleteSuccess}">
    <div class="alert alert-success alert-dismissible alert-top shadow" id="toastMsg">
        <i class="bi bi-check-circle-fill me-2"></i> Đã xóa time log.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
<c:if test="${not empty param.updateError}">
    <div class="alert alert-danger alert-dismissible alert-top shadow" id="toastMsg">
        <i class="bi bi-exclamation-triangle-fill me-2"></i>
        <c:choose>
            <c:when test="${param.updateError eq 'unauthorized'}">Bạn không có quyền chỉnh sửa log này.</c:when>
            <c:when test="${param.updateError eq 'invalidTime'}">Số giờ không hợp lệ (0 &lt; giờ ≤ 999.99).</c:when>
            <c:otherwise>Cập nhật thất bại. Vui lòng thử lại.</c:otherwise>
        </c:choose>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
<c:if test="${not empty param.deleteError}">
    <div class="alert alert-danger alert-dismissible alert-top shadow" id="toastMsg">
        <i class="bi bi-exclamation-triangle-fill me-2"></i>
        <c:choose>
            <c:when test="${param.deleteError eq 'unauthorized'}">Bạn không có quyền xóa log này.</c:when>
            <c:otherwise>Xóa thất bại. Vui lòng thử lại.</c:otherwise>
        </c:choose>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>

<!-- ── Page header ───────────────────────────────────────────────────────── -->
<div class="page-header">
    <div class="page-title">
        <i class="bi bi-clock-history text-primary"></i> Quản lý Time Log
    </div>
</div>

<!-- ── Stat cards ────────────────────────────────────────────────────────── -->
<div class="stat-row">
    <div class="stat-card">
        <div class="stat-icon" style="background:#e3f2fd; color:#1565c0;">
            <i class="bi bi-list-check"></i>
        </div>
        <div>
            <div class="stat-label">Tổng bản ghi</div>
            <div class="stat-value">${totalCount}</div>
        </div>
    </div>
    <div class="stat-card">
        <div class="stat-icon" style="background:#e8f5e9; color:#2e7d32;">
            <i class="bi bi-hourglass-split"></i>
        </div>
        <div>
            <div class="stat-label">Tổng giờ (filter)</div>
            <div class="stat-value">
                <fmt:formatNumber value="${filteredHours}" maxFractionDigits="2" />h
            </div>
        </div>
    </div>
    <div class="stat-card">
        <div class="stat-icon" style="background:#fff3e0; color:#e65100;">
            <i class="bi bi-journal-text"></i>
        </div>
        <div>
            <div class="stat-label">Trang hiện tại</div>
            <div class="stat-value">${currentPage} / ${totalPages > 0 ? totalPages : 1}</div>
        </div>
    </div>
</div>

<!-- ── Filter form ────────────────────────────────────────────────────────── -->
<div class="filter-card">
    <form id="filterForm" method="get" action="${pageContext.request.contextPath}/time-tracking">
        <input type="hidden" id="filterPageInp" name="page" value="1">
        <div class="row g-2 align-items-end">
            <div class="col-md-2">
                <label class="form-label fw-semibold mb-1" style="font-size:.8rem;">Ticket ID</label>
                <input type="number" class="form-control form-control-sm" name="ticketId"
                       placeholder="VD: 12" value="${fTicketId}">
            </div>
            <div class="col-md-3">
                <label class="form-label fw-semibold mb-1" style="font-size:.8rem;">Agent</label>
                <select class="form-select form-select-sm" name="userId">
                    <option value="">-- Tất cả --</option>
                    <c:forEach var="u" items="${users}">
                        <option value="${u.userId}" ${fUserId eq u.userId ? 'selected' : ''}>${u.fullName}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-md-2">
                <label class="form-label fw-semibold mb-1" style="font-size:.8rem;">Từ ngày</label>
                <input type="date" class="form-control form-control-sm" name="dateFrom" value="${fDateFrom}">
            </div>
            <div class="col-md-2">
                <label class="form-label fw-semibold mb-1" style="font-size:.8rem;">Đến ngày</label>
                <input type="date" class="form-control form-control-sm" name="dateTo" value="${fDateTo}">
            </div>
            <div class="col-md-2">
                <label class="form-label fw-semibold mb-1" style="font-size:.8rem;">Activity</label>
                <select class="form-select form-select-sm" name="activityType">
                    <option value="">-- Tất cả --</option>
                    <option value="ASSIGNED"      ${fActivity eq 'ASSIGNED'      ? 'selected' : ''}>ASSIGNED</option>
                    <option value="INVESTIGATION" ${fActivity eq 'INVESTIGATION' ? 'selected' : ''}>INVESTIGATION</option>
                    <option value="RESOLVED"      ${fActivity eq 'RESOLVED'      ? 'selected' : ''}>RESOLVED</option>
                    <option value="CLOSED"        ${fActivity eq 'CLOSED'        ? 'selected' : ''}>CLOSED</option>
                    <option value="MANUAL"        ${fActivity eq 'MANUAL'        ? 'selected' : ''}>MANUAL</option>
                </select>
            </div>
            <div class="col-md-1 d-flex gap-1">
                <button type="submit" class="btn btn-primary btn-sm w-100">
                    <i class="bi bi-search"></i>
                </button>
                <a href="${pageContext.request.contextPath}/time-tracking"
                   class="btn btn-outline-secondary btn-sm w-100" title="Reset">
                    <i class="bi bi-x-lg"></i>
                </a>
            </div>
            <div class="col-md-2">
                <label class="form-label fw-semibold mb-1" style="font-size:.8rem;">Số hàng / trang</label>
                <select class="form-select form-select-sm" name="pageSize">
                    <option value="10" ${fPageSize == '10' ? 'selected' : ''}>10</option>
                    <option value="15" ${fPageSize == '15' ? 'selected' : ''}>15</option>
                    <option value="25" ${fPageSize == '25' ? 'selected' : ''}>25</option>
                    <option value="50" ${fPageSize == '50' ? 'selected' : ''}>50</option>
                </select>
            </div>
        </div>
    </form>
</div>

<!-- ── Table ──────────────────────────────────────────────────────────────── -->
<div class="table-card">
    <table class="table table-hover mb-0">
        <thead>
            <tr>
                <th>#</th>
                <th>Ticket</th>
                <th>Agent</th>
                <th>Activity</th>
                <th>Giờ</th>
                <th>Mô tả</th>
                <th>Logged At</th>
                <th class="text-center">Thao tác</th>
            </tr>
        </thead>
        <tbody>
            <c:choose>
                <c:when test="${empty logs}">
                    <tr>
                        <td colspan="8" class="text-center text-muted py-5">
                            <i class="bi bi-inbox fs-2 d-block mb-2"></i>
                            Không có time log nào phù hợp.
                        </td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="log" items="${logs}" varStatus="s">
                        <tr>
                            <td class="text-muted" style="font-size:.8rem;">${(currentPage-1)*15 + s.index + 1}</td>
                            <td>
                                <a href="${pageContext.request.contextPath}/incident?action=detail&id=${log.ticketId}"
                                   class="fw-semibold text-decoration-none" style="color:#1565c0;">
                                    ${not empty log.ticketNumber ? log.ticketNumber : '#'.concat(log.ticketId)}
                                </a>
                            </td>
                            <td>
                                <i class="bi bi-person-circle text-secondary me-1"></i>${log.agentName}
                            </td>
                            <td>
                                <span class="badge-activity act-${log.activityType}">${log.activityType}</span>
                            </td>
                            <td class="fw-semibold" style="color:#2e7d32;">
                                <fmt:formatNumber value="${log.timeSpent}" maxFractionDigits="2" />h
                            </td>
                            <td style="max-width:260px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;"
                                title="${log.description}">
                                <c:choose>
                                    <c:when test="${not empty log.description}">${log.description}</c:when>
                                    <c:otherwise><span class="text-muted fst-italic">—</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-muted" style="font-size:.82rem; white-space:nowrap;">
                                <fmt:formatDate value="${log.loggedAt}" pattern="dd/MM/yyyy HH:mm" />
                            </td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${not empty sessionScope.user and (
                                        sessionScope.user.userId == log.userId
                                        or fn:toLowerCase(sessionScope.user.roleName) == 'manager'
                                        or fn:toLowerCase(sessionScope.user.roleName) == 'administrator'
                                        or fn:toLowerCase(sessionScope.user.roleName) == 'admin'
                                    )}">
                                        <button class="btn-action btn-edit btn-open-edit"
                                                title="Chỉnh sửa"
                                                data-log-id="${log.logId}"
                                                data-time-spent="${log.timeSpent}"
                                                data-description="${fn:escapeXml(log.description)}">
                                            <i class="bi bi-pencil"></i>
                                        </button>
                                        <button class="btn-action btn-delete btn-open-delete ms-1"
                                                title="Xóa"
                                                data-log-id="${log.logId}"
                                                data-ticket="${not empty log.ticketNumber ? log.ticketNumber : log.ticketId}"
                                                data-agent="${fn:escapeXml(log.agentName)}">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted">—</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </tbody>
    </table>

    <!-- Pagination -->
    <c:if test="${totalPages > 1}">
        <div class="pagination-row">
            <div class="pagination-info">
                Trang <strong>${currentPage}</strong> / <strong>${totalPages}</strong>
                &nbsp;·&nbsp; Tổng <strong>${totalCount}</strong> bản ghi
            </div>
            <nav>
                <ul class="pagination pagination-sm mb-0">
                    <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                        <a class="page-link" href="javascript:void(0)" onclick="handlePageChange('${currentPage - 1}')">
                            <i class="bi bi-chevron-left"></i>
                        </a>
                    </li>
                    <c:forEach begin="1" end="${totalPages}" var="p">
                        <c:if test="${p >= currentPage - 2 && p <= currentPage + 2}">
                            <li class="page-item ${p == currentPage ? 'active' : ''}">
                                <a class="page-link" href="javascript:void(0)" onclick="handlePageChange('${p}')">${p}</a>
                            </li>
                        </c:if>
                    </c:forEach>
                    <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="javascript:void(0)" onclick="handlePageChange('${currentPage + 1}')">
                            <i class="bi bi-chevron-right"></i>
                        </a>
                    </li>
                </ul>
            </nav>
        </div>
    </c:if>
</div>

<!-- ══════════════════════════════════════════════════════════════════════════
     MODAL: Edit Time Log
     ══════════════════════════════════════════════════════════════════════════ -->
<div class="modal fade" id="editModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <div class="modal-header" style="background:#1565c0; color:#fff;">
                <h5 class="modal-title"><i class="bi bi-pencil-square me-2"></i>Chỉnh sửa Time Log</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/time-tracking">
                <input type="hidden" name="action" value="update">
                <input type="hidden" id="editLogId" name="logId" value="">
                <!-- preserve filter params for redirect back -->
                <input type="hidden" name="ticketId"     value="${fTicketId}">
                <input type="hidden" name="userId"       value="${fUserId}">
                <input type="hidden" name="dateFrom"     value="${fDateFrom}">
                <input type="hidden" name="dateTo"       value="${fDateTo}">
                <input type="hidden" name="activityType" value="${fActivity}">
                <input type="hidden" name="page"         value="${currentPage}">
                <input type="hidden" name="pageSize"     value="${pageSize}">
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Số giờ <span class="text-danger">*</span></label>
                        <input type="number" class="form-control" id="editTimeSpent" name="timeSpent"
                               step="any" min="0.25" max="999.99" required>
                        <div class="form-text text-muted">Tối thiểu 0.25h, tối đa 999.99h</div>
                    </div>
                    <div class="mb-1">
                        <label class="form-label fw-semibold">Mô tả</label>
                        <textarea class="form-control" id="editDescription" name="description"
                                  rows="3" placeholder="Mô tả công việc đã thực hiện..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary btn-sm px-4">
                        <i class="bi bi-save me-1"></i>Lưu thay đổi
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ══════════════════════════════════════════════════════════════════════════
     MODAL: Delete Confirm
     ══════════════════════════════════════════════════════════════════════════ -->
<div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content border-0 shadow">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title"><i class="bi bi-trash me-2"></i>Xác nhận xóa</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body text-center py-4">
                <i class="bi bi-exclamation-triangle-fill text-danger fs-1 d-block mb-3"></i>
                <p class="mb-1">Xóa time log của ticket</p>
                <p class="fw-bold mb-1" id="deleteTicketLabel"></p>
                <p class="text-muted mb-0" style="font-size:.85rem;" id="deleteAgentLabel"></p>
                <p class="text-danger mt-2 mb-0" style="font-size:.82rem;">Hành động này không thể hoàn tác.</p>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/time-tracking">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" id="deleteLogId" name="logId" value="">
                <input type="hidden" name="ticketId"     value="${fTicketId}">
                <input type="hidden" name="userId"       value="${fUserId}">
                <input type="hidden" name="dateFrom"     value="${fDateFrom}">
                <input type="hidden" name="dateTo"       value="${fDateTo}">
                <input type="hidden" name="activityType" value="${fActivity}">
                <input type="hidden" name="page"         value="${currentPage}">
                <input type="hidden" name="pageSize"     value="${pageSize}">
                <div class="modal-footer justify-content-center">
                    <button type="button" class="btn btn-outline-secondary btn-sm px-4" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-danger btn-sm px-4">
                        <i class="bi bi-trash me-1"></i>Xóa
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    // ── Pagination ────────────────────────────────────────────────────────────
    function goPage(p) {
        document.getElementById('filterPageInp').value = p;
        document.getElementById('filterForm').submit();
    }

    // ── Page change handler (global) ───────────────────────────────────────
    // Mirrors behaviour in admin/user-list.jsp: update query param while keeping other filters
    function handlePageChange(page) {
        try {
            var urlParams = new URLSearchParams(window.location.search);
            urlParams.set('page', page);
            window.location.search = urlParams.toString();
        } catch (e) {
            // fallback to form submit when URLSearchParams not available
            document.getElementById('filterPageInp').value = page;
            document.getElementById('filterForm').submit();
        }
    }

    // ── Edit modal ────────────────────────────────────────────────────────────
    function openEditModal(logId, timeSpent, description) {
        document.getElementById('editLogId').value = logId;
        document.getElementById('editTimeSpent').value = timeSpent;
        document.getElementById('editDescription').value = description;
        bootstrap.Modal.getOrCreateInstance(document.getElementById('editModal')).show();
    }

    // ── Delete modal ──────────────────────────────────────────────────────────
    function openDeleteModal(logId, ticketLabel, agentName) {
        document.getElementById('deleteLogId').value = logId;
        document.getElementById('deleteTicketLabel').textContent = ticketLabel;
        document.getElementById('deleteAgentLabel').textContent = 'Agent: ' + agentName;
        bootstrap.Modal.getOrCreateInstance(document.getElementById('deleteModal')).show();
    }

    document.addEventListener('DOMContentLoaded', () => {
        // ── Edit buttons ──────────────────────────────────────────────────────
        document.querySelectorAll('.btn-open-edit').forEach(btn => {
            btn.addEventListener('click', () => {
                openEditModal(
                    btn.dataset.logId,
                    btn.dataset.timeSpent,
                    btn.dataset.description
                );
            });
        });

        // ── Delete buttons ────────────────────────────────────────────────────
        document.querySelectorAll('.btn-open-delete').forEach(btn => {
            btn.addEventListener('click', () => {
                openDeleteModal(
                    btn.dataset.logId,
                    btn.dataset.ticket,
                    btn.dataset.agent
                );
            });
        });

        

        // ── Auto-dismiss toast after 4s ───────────────────────────────────────
        const toast = document.getElementById('toastMsg');
        if (toast) setTimeout(() => {
            const alert = bootstrap.Alert.getOrCreateInstance(toast);
            if (alert) alert.close();
        }, 4000);
    });
</script>

<jsp:include page="/common/admin-layout-bottom.jsp" />
