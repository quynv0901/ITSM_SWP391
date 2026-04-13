<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<style>
    /* ── Stat cards ──────────────────────────────────────────────── */
    .stat-row {
        display: flex;
        gap: 16px;
        flex-wrap: wrap;
        margin-bottom: 22px;
    }

    .stat-card {
        flex: 1;
        min-width: 140px;
        background: #fff;
        border: 1px solid #dde3ec;
        border-radius: 10px;
        padding: 16px 20px;
        display: flex;
        align-items: center;
        gap: 14px;
        box-shadow: 0 1px 4px rgba(0, 0, 0, .05);
        transition: transform .15s, box-shadow .15s;
        cursor: pointer;
        text-decoration: none;
        color: inherit;
    }

    .stat-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 14px rgba(0, 0, 0, .09);
        color: inherit;
    }

    .stat-icon {
        width: 44px;
        height: 44px;
        border-radius: 10px;
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
        letter-spacing: .5px;
        color: #8899aa;
    }

    .stat-value {
        font-size: 26px;
        font-weight: 800;
        color: #1a202c;
        line-height: 1.1;
    }

    /* ── Filter card ─────────────────────────────────────────────── */
    .filter-card {
        background: #fff;
        border: 1px solid #dde3ec;
        border-radius: 8px;
        padding: 16px 20px;
        margin-bottom: 20px;
        box-shadow: 0 1px 4px rgba(0, 0, 0, .05);
    }

    .filter-row {
        display: flex;
        gap: 12px;
        flex-wrap: wrap;
        align-items: flex-end;
    }

    .filter-group {
        display: flex;
        flex-direction: column;
        gap: 4px;
        flex: 1;
        min-width: 140px;
    }

    .filter-group label {
        font-size: 11px;
        font-weight: 600;
        color: #718096;
        text-transform: uppercase;
        letter-spacing: .4px;
    }

    .filter-group select,
    .filter-group input {
        padding: 8px 10px;
        border: 1px solid #dde3ec;
        border-radius: 6px;
        font-size: 13px;
        color: #2d3748;
        background: #f9fbfd;
    }

    .filter-group select:focus,
    .filter-group input:focus {
        outline: none;
        border-color: #3c8dbc;
        box-shadow: 0 0 0 3px rgba(60, 141, 188, .15);
        background: #fff;
    }

    /* ── Table card ──────────────────────────────────────────────── */
    .table-card {
        background: #fff;
        border: 1px solid #dde3ec;
        border-radius: 8px;
        overflow: hidden;
        box-shadow: 0 1px 4px rgba(0, 0, 0, .05);
    }

    .cat-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 13.5px;
    }

    .cat-table thead {
        background: linear-gradient(135deg, #3c8dbc, #1a6896);
        color: #fff;
    }

    .cat-table th {
        padding: 11px 14px;
        font-weight: 600;
        white-space: nowrap;
    }

    .cat-table td {
        padding: 11px 14px;
        border-bottom: 1px solid #f0f4f8;
        vertical-align: middle;
    }

    .cat-table tbody tr:last-child td {
        border-bottom: none;
    }

    .cat-table tbody tr:hover td {
        background: #f7fbff;
    }

    /* ── Badges ──────────────────────────────────────────────────── */
    .badge-type {
        display: inline-block;
        padding: 3px 9px;
        border-radius: 5px;
        font-size: 11px;
        font-weight: 700;
    }

    .bt-incident {
        background: #fef9e7;
        color: #b7770d;
        border: 1px solid #fdebd0;
    }

    .bt-service {
        background: #e8f8f5;
        color: #1e8449;
        border: 1px solid #d5f5e3;
    }

    .bt-change {
        background: #f4ecf7;
        color: #7d3c98;
        border: 1px solid #e8daef;
    }

    .bt-problem {
        background: #fdedec;
        color: #c0392b;
        border: 1px solid #fadbd8;
    }

    .badge-diff {
        display: inline-block;
        padding: 3px 9px;
        border-radius: 5px;
        font-size: 11px;
        font-weight: 700;
    }

    .bd-easy {
        background: #f0fff4;
        color: #276749;
        border: 1px solid #9ae6b4;
    }

    .bd-medium {
        background: #fffaf0;
        color: #c05621;
        border: 1px solid #fbd38d;
    }

    .bd-hard {
        background: #fff5f5;
        color: #c53030;
        border: 1px solid #feb2b2;
    }

    .status-on {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        padding: 3px 9px;
        border-radius: 12px;
        font-size: 11px;
        font-weight: 700;
        background: #f0fff4;
        color: #276749;
        border: 1px solid #9ae6b4;
    }

    .status-off {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        padding: 3px 9px;
        border-radius: 12px;
        font-size: 11px;
        font-weight: 700;
        background: #fff5f5;
        color: #c53030;
        border: 1px solid #feb2b2;
    }

    /* ── Action buttons ──────────────────────────────────────────── */
    .btn-icon {
        width: 30px;
        height: 30px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 6px;
        border: none;
        cursor: pointer;
        font-size: 13px;
        transition: opacity .15s;
    }

    .btn-icon:hover {
        opacity: .78;
    }

    /* ── Bulk toolbar ────────────────────────────────────────────── */
    .bulk-bar {
        display: none;
        background: #ebf5fb;
        border: 1px solid #aed6f1;
        border-radius: 7px;
        padding: 10px 16px;
        margin-bottom: 14px;
        align-items: center;
        gap: 12px;
        flex-wrap: wrap;
    }

    .bulk-bar.visible {
        display: flex;
    }

    .bulk-count {
        font-weight: 700;
        color: #2e86c1;
        font-size: 13px;
    }

    /* ── Pagination ──────────────────────────────────────────────── */
    .pager-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 12px 16px;
        background: #f7fafc;
        border-top: 1px solid #edf2f7;
        flex-wrap: wrap;
        gap: 10px;
    }

    /* ── Flash ───────────────────────────────────────────────────── */
    .flash {
        padding: 11px 16px;
        border-radius: 7px;
        font-size: 13.5px;
        font-weight: 500;
        margin-bottom: 16px;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .flash-success {
        background: #f0fff4;
        color: #276749;
        border: 1px solid #9ae6b4;
    }

    .flash-error {
        background: #fff5f5;
        color: #c53030;
        border: 1px solid #feb2b2;
    }

    .flash-warn {
        background: #fffaf0;
        color: #c05621;
        border: 1px solid #fbd38d;
    }

    /* ── Empty ───────────────────────────────────────────────────── */
    .empty-state {
        padding: 60px 20px;
        text-align: center;
        color: #a0aec0;
    }

    .empty-state i {
        font-size: 48px;
        opacity: .3;
    }

    .cat-name-link {
        color: #2e86c1;
        font-weight: 600;
        text-decoration: none;
    }

    .cat-name-link:hover {
        text-decoration: underline;
    }

    .parent-pill {
        background: #edf2f7;
        color: #718096;
        padding: 2px 8px;
        border-radius: 8px;
        font-size: 11px;
        font-weight: 600;
    }

    /* ── Toggle Switch (giống user-list) ─────────────────── */
    .switch {
        position: relative;
        display: inline-block;
        width: 34px;
        height: 20px;
    }

    .switch input {
        opacity: 0;
        width: 0;
        height: 0;
    }

    .slider {
        position: absolute;
        cursor: pointer;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background-color: #ccc;
        transition: .4s;
        border-radius: 34px;
    }

    .slider:before {
        position: absolute;
        content: "";
        height: 14px;
        width: 14px;
        left: 3px;
        bottom: 3px;
        background-color: white;
        transition: .4s;
        border-radius: 50%;
    }

    input:checked+.slider {
        background-color: #00bcd4;
    }

    input:checked+.slider:before {
        transform: translateX(14px);
    }
</style>

<%@ include file="/common/admin-layout-top.jsp" %>

<%-- Flash messages --%>
<c:if test="${not empty param.createSuccess}">
    <div class="flash flash-success"><i class="bi bi-check-circle-fill"></i> Tạo danh mục thành
        công.</div>
    </c:if>
    <c:if test="${not empty param.updateSuccess}">
    <div class="flash flash-success"><i class="bi bi-check-circle-fill"></i> Cập nhật danh mục
        thành công.</div>
    </c:if>
    <c:if test="${not empty param.deleteSuccess}">
    <div class="flash flash-success"><i class="bi bi-check-circle-fill"></i> Xóa danh mục thành
        công.</div>
    </c:if>
    <c:if test="${not empty param.toggleSuccess}">
    <div class="flash flash-success"><i class="bi bi-check-circle-fill"></i> Cập nhật trạng thái
        thành công.</div>
    </c:if>
    <c:if test="${not empty param.bulkDeleteSuccess}">
    <div class="flash flash-success"><i class="bi bi-check-circle-fill"></i>
        Đã xóa <strong>${param.bulkDeleteSuccess}</strong> danh mục.
    </div>
</c:if>
<c:if test="${not empty param.bulkToggleSuccess}">
    <div class="flash flash-success"><i class="bi bi-check-circle-fill"></i>
        Đã cập nhật <strong>${param.bulkToggleSuccess}</strong> danh mục.
    </div>
</c:if>
<c:choose>
    <c:when test="${param.error == 'has_tickets'}">
        <div class="flash flash-error"><i class="bi bi-exclamation-triangle-fill"></i> Không thể
            xóa — có ticket đang sử dụng danh mục này.</div>
        </c:when>
        <c:when test="${param.error == 'has_children'}">
        <div class="flash flash-error"><i class="bi bi-exclamation-triangle-fill"></i> Không thể
            xóa — danh mục này có danh mục con. Hãy xóa chúng trước.</div>
        </c:when>
        <c:when test="${not empty param.error}">
        <div class="flash flash-error"><i class="bi bi-exclamation-triangle-fill"></i> Thao tác
            thất bại: ${param.error}</div>
        </c:when>
    </c:choose>

<%-- Page header --%>
<div class="d-flex align-items-center justify-content-between mb-3">
    <div>
        <h4 class="fw-bold mb-0" style="color:#222d32;"><i
                class="bi bi-tags-fill me-2 text-primary"></i>Quản lý Danh mục Ticket</h4>
        <small class="text-muted">Quản lý danh sách phân cấp danh mục ticket, quy tắc định
            tuyến và mức độ khó.</small>
    </div>
    <a href="${pageContext.request.contextPath}/ticket-category?action=form"
       class="btn btn-primary btn-sm px-3">
        <i class="bi bi-plus-circle me-1"></i>Thêm Danh mục
    </a>
</div>

<%-- Stat cards --%>
<div class="stat-row">
    <a href="${pageContext.request.contextPath}/ticket-category" class="stat-card">
        <div class="stat-icon" style="background:#e8f4fd;"><i
                class="bi bi-tags text-primary"></i></div>
        <div>
            <div class="stat-label">Tổng cộng</div>
            <div class="stat-value">${totalAll}</div>
        </div>
    </a>
    <a href="${pageContext.request.contextPath}/ticket-category?status=active"
       class="stat-card">
        <div class="stat-icon" style="background:#e0fff4;"><i class="bi bi-check-circle"
                                                              style="color:#27ae60;"></i></div>
        <div>
            <div class="stat-label">Active</div>
            <div class="stat-value">${totalActive}</div>
        </div>
    </a>
    <a href="${pageContext.request.contextPath}/ticket-category?status=inactive"
       class="stat-card">
        <div class="stat-icon" style="background:#fff5f5;"><i class="bi bi-slash-circle"
                                                              style="color:#c53030;"></i></div>
        <div>
            <div class="stat-label">Inac</div>
            <div class="stat-value">${totalInact}</div>
        </div>
    </a>
</div>

<%-- Filter --%>
<div class="filter-card">
    <form method="get" action="${pageContext.request.contextPath}/ticket-category"
          id="filterForm">
        <div class="filter-row">
            <div class="filter-group" style="max-width:280px;">
                <label>Tìm kiếm</label>
                <input type="text" name="search" placeholder="Tên, mã, mô tả…"
                       value="${fSearch}">
            </div>
            <div class="filter-group" style="max-width:200px;">
                <label>Loại</label>
                <select name="categoryType">
                    <option value="">— Tất cả loại —</option>
                    <option value="INCIDENT" ${fType=='INCIDENT' ? 'selected' : ''
                            }>Incident</option>
                    <option value="SERVICE_REQUEST" ${fType=='SERVICE_REQUEST'
                                                      ? 'selected' : '' }>Service request</option>
                    <option value="CHANGE" ${fType=='CHANGE' ? 'selected' : '' }>
                        Thay đổi</option>
                    <option value="PROBLEM" ${fType=='PROBLEM' ? 'selected' : '' }>
                        Vấn đề</option>
                </select>
            </div>
            <div class="filter-group" style="max-width:170px;">
                <label>Trạng thái</label>
                <select name="status">
                    <option value="">— Tất cả —</option>
                    <option value="active" ${fStatus=='active' ? 'selected' : '' }>
                        Active</option>
                    <option value="inactive" ${fStatus=='inactive' ? 'selected' : ''
                            }>Inactive</option>
                </select>
            </div>
            <div class="filter-group" style="max-width:110px;">
                <label>Hiển thị</label>
                <select name="pageSize" onchange="this.form.submit()">
                    <option value="10" ${pageSize==10 ? 'selected' : '' }>10 dòng
                    </option>
                    <option value="15" ${pageSize==15 || empty pageSize ? 'selected'
                                         : '' }>15 dòng</option>
                    <option value="25" ${pageSize==25 ? 'selected' : '' }>25 dòng
                    </option>
                    <option value="50" ${pageSize==50 ? 'selected' : '' }>50 dòng
                    </option>
                    <option value="100" ${pageSize==100 ? 'selected' : '' }>100 dòng
                    </option>
                </select>
            </div>
            <div class="filter-group"
                 style="max-width:200px; flex-direction:row; gap:8px; align-items:flex-end;">
                <input type="hidden" name="page" value="1" id="filterPageInp">
                <button type="submit" class="btn btn-primary btn-sm px-3"
                        style="white-space:nowrap;"><i
                        class="bi bi-search me-1"></i>Tìm</button>
                <a href="${pageContext.request.contextPath}/ticket-category"
                   class="btn btn-outline-secondary btn-sm px-3"
                   style="white-space:nowrap;"><i
                        class="bi bi-x-circle me-1"></i>Xóa lọc</a>
            </div>
        </div>
    </form>
</div>

<%-- Bulk action bar --%>
<div class="bulk-bar" id="bulkBar">
    <span class="bulk-count" id="bulkCount">0 đã chọn</span>
    <form method="post"
          action="${pageContext.request.contextPath}/ticket-category"
          id="bulkDeleteForm" style="display:inline;">
        <input type="hidden" name="action" value="bulkDelete">
        <div id="bulkDeleteIds"></div>
        <button type="button" class="btn btn-danger btn-sm"
                onclick="confirmBulkDelete()">
            <i class="bi bi-trash3 me-1"></i>Xóa đã chọn
        </button>
    </form>
    <form method="post"
          action="${pageContext.request.contextPath}/ticket-category"
          id="bulkEnableForm" style="display:inline;">
        <input type="hidden" name="action" value="bulkToggle">
        <input type="hidden" name="active" value="true">
        <div id="bulkEnableIds"></div>
        <button type="button" class="btn btn-success btn-sm"
                onclick="bulkToggle('enable')">
            <i class="bi bi-toggle-on me-1"></i>Bật
        </button>
    </form>
    <form method="post"
          action="${pageContext.request.contextPath}/ticket-category"
          id="bulkDisableForm" style="display:inline;">
        <input type="hidden" name="action" value="bulkToggle">
        <input type="hidden" name="active" value="false">
        <div id="bulkDisableIds"></div>
        <button type="button" class="btn btn-secondary btn-sm"
                onclick="bulkToggle('disable')">
            <i class="bi bi-toggle-off me-1"></i>Tắt
        </button>
    </form>
</div>

<%-- Table --%>
<div class="table-card">
    <table class="cat-table">
        <thead>
            <tr>
                <th style="width:38px;"><input type="checkbox"
                                               id="selectAll" title="Chọn tất cả"
                                               class="form-check-input"></th>
                <th>#</th>
                <th>Tên / Mã</th>
                <th>Loại</th>
                <th>Danh mục cha</th>
                <th>Độ khó</th>
                <th>Danh mục con</th>
                <th>Tickets</th>
                <th>Trạng thái</th>
                <th>Cập nhật</th>
                <th class="text-center">Thao tác</th>
            </tr>
        </thead>
        <tbody>
            <c:choose>
                <c:when test="${empty categories}">
                    <tr>
                        <td colspan="11">
                            <div class="empty-state">
                                <i class="bi bi-tags d-block mb-2"></i>
                                <strong>Không tìm thấy danh mục
                                    nào.</strong>
                                <p class="mt-1 mb-0"
                                   style="font-size:13px;">
                                    <a
                                        href="${pageContext.request.contextPath}/ticket-category?action=form">Tạo
                                        danh mục đầu tiên →</a>
                                </p>
                            </div>
                        </td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="cat" items="${categories}"
                               varStatus="s">
                        <tr>
                            <td><input type="checkbox"
                                       class="form-check-input row-check"
                                       value="${cat.categoryId}"></td>
                            <td class="text-muted">${(currentPage - 1) *
                                                     pageSize + s.index + 1}</td>
                            <td>
                                <a href="${pageContext.request.contextPath}/ticket-category?action=detail&id=${cat.categoryId}"
                                   class="cat-name-link">${cat.categoryName}</a>
                                <c:if test="${not empty cat.categoryCode}">
                                    <div
                                        style="font-size:11px; color:#a0aec0; margin-top:1px;">
                                        <i
                                            class="bi bi-hash"></i>${cat.categoryCode}
                                    </div>
                                </c:if>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when
                                        test="${cat.categoryType == 'INCIDENT'}">
                                        <span
                                            class="badge-type bt-incident">Incident</span>
                                        </c:when>
                                        <c:when
                                            test="${cat.categoryType == 'SERVICE_REQUEST'}">
                                        <span
                                            class="badge-type bt-service">Service Request</span>
                                        </c:when>
                                        <c:when
                                            test="${cat.categoryType == 'CHANGE'}">
                                        <span
                                            class="badge-type bt-change">Change</span>
                                        </c:when>
                                        <c:when
                                            test="${cat.categoryType == 'PROBLEM'}">
                                        <span
                                            class="badge-type bt-problem">Problem</span>
                                        </c:when>
                                        <c:otherwise><span class="badge-type"
                                              style="background:#edf2f7; color:#4a5568;">${cat.categoryType}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when
                                        test="${not empty cat.parentCategoryName}">
                                        <span class="parent-pill"><i
                                                class="bi bi-arrow-return-right me-1"></i>${cat.parentCategoryName}</span>
                                        </c:when>
                                        <c:otherwise><span class="text-muted"
                                              style="font-size:12px;">— Root
                                            —</span></c:otherwise>
                                    </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when
                                        test="${cat.difficultyLevel == 'EASY'}">
                                        <span
                                            class="badge-diff bd-easy">Easy</span>
                                    </c:when>
                                    <c:when
                                        test="${cat.difficultyLevel == 'MEDIUM'}">
                                        <span
                                            class="badge-diff bd-medium">Medium
                                        </span>
                                    </c:when>
                                    <c:when
                                        test="${cat.difficultyLevel == 'HARD'}">
                                        <span
                                            class="badge-diff bd-hard">Hard</span>
                                    </c:when>
                                    <c:otherwise><span class="text-muted"
                                          style="font-size:12px;">—</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${cat.childCount > 0}">
                                        <span
                                            class="fw-bold text-primary">${cat.childCount}</span>
                                    </c:when>
                                    <c:otherwise><span
                                            class="text-muted">0</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${cat.ticketCount > 0}">
                                        <span
                                            class="fw-bold text-warning">${cat.ticketCount}</span>
                                    </c:when>
                                    <c:otherwise><span
                                            class="text-muted">0</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div
                                    class="d-flex align-items-center gap-2">
                                    <span
                                        class="${cat.active ? 'status-on' : 'status-off'}">
                                        <i class="bi bi-circle-fill"
                                           style="font-size:7px;"></i>
                                        ${cat.active ? 'Active' : 'Inactive'}
                                    </span>
                                    <label class="switch">
                                        <input type="checkbox" ${cat.active
                                                                 ? 'checked' : '' }
                                               onclick="confirmToggle(${cat.categoryId}, ${!cat.active}, '${fn:escapeXml(cat.categoryName)}')">
                                        <span class="slider"></span>
                                    </label>
                                </div>
                            </td>
                            <td
                                style="font-size:12px; color:#718096; white-space:nowrap;">
                                <c:if test="${not empty cat.updatedAt}">
                                    <fmt:formatDate value="${cat.updatedAt}"
                                                    pattern="dd/MM/yyyy" />
                                </c:if>
                            </td>
                            <td class="text-center">
                                <div
                                    class="d-flex align-items-center justify-content-center gap-1">
                                    <%-- View --%>
                                    <a href="${pageContext.request.contextPath}/ticket-category?action=detail&id=${cat.categoryId}"
                                       class="btn-icon bg-info text-white">
                                        <i class="bi bi-eye"></i>
                                    </a>
                                    <%-- Edit --%>
                                    <a href="${pageContext.request.contextPath}/ticket-category?action=form&id=${cat.categoryId}"
                                       class="btn-icon bg-warning text-dark">
                                        <i class="bi bi-pencil"></i>
                                    </a>
                                    <%-- Delete --%>
                                    <button
                                        class="btn-icon bg-danger text-white"
                                        onclick="confirmDelete(${cat.categoryId}, '${fn:escapeXml(cat.categoryName)}', ${cat.ticketCount}, ${cat.childCount})">
                                        <i
                                            class="bi bi-trash3"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </tbody>
    </table>

    <%-- Pagination --%>
    <c:if test="${totalPages >= 1}">
        <div class="pager-row">
            <span class="text-muted small">
                Hiển thị <strong>${fromIdx}</strong> –
                <strong>${toIdx}</strong>
                trong <strong>${total}</strong> danh mục
                &nbsp;·&nbsp; Trang <strong>${currentPage}</strong> /
                <strong>${totalPages}</strong>
            </span>
            <nav>
                <ul class="pagination pagination-sm mb-0">
                    <li
                        class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="javascript:void(0)"
                           onclick="goPage(${currentPage-1})">‹</a>
                    </li>
                    <c:forEach var="i" begin="1" end="${totalPages}">
                        <c:if
                            test="${i >= currentPage-2 && i <= currentPage+2}">
                            <li
                                class="page-item ${currentPage == i ? 'active' : ''}">
                                <a class="page-link"
                                   href="javascript:void(0)"
                                   onclick="goPage(${i})">${i}</a>
                            </li>
                        </c:if>
                    </c:forEach>
                    <li
                        class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="javascript:void(0)"
                           onclick="goPage(${currentPage+1})">›</a>
                    </li>
                </ul>
            </nav>
        </div>
    </c:if>
</div>

<%-- Delete confirm modal --%>
<div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered"
         style="max-width:420px;">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title"><i
                        class="bi bi-trash3 me-2"></i>Xóa Danh mục
                </h5>
                <button type="button" class="btn-close btn-close-white"
                        data-bs-dismiss="modal"></button>
            </div>
            <form method="post"
                  action="${pageContext.request.contextPath}/ticket-category">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="id" id="deleteId">
                <div class="modal-body">
                    <p class="mb-0">Xóa danh mục <strong
                            id="deleteName"></strong>?
                        Hành động này <span
                            class="text-danger fw-semibold">không thể
                            hoàn tác</span>
                        và sẽ thất bại nếu có ticket hoặc danh mục con
                        đang tham chiếu.</p>
                </div>
                <div class="modal-footer border-0">
                    <button type="button"
                            class="btn btn-secondary btn-sm"
                            data-bs-dismiss="modal">Hủy</button>
                    <button type="submit"
                            class="btn btn-danger btn-sm px-4"><i
                            class="bi bi-trash3 me-1"></i>Xóa</button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- Toggle confirm modal --%>
<div class="modal fade" id="toggleModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered"
         style="max-width:400px;">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header" id="toggleModalHeader">
                <h5 class="modal-title" id="toggleModalTitle"></h5>
                <button type="button" class="btn-close"
                        data-bs-dismiss="modal"></button>
            </div>
            <form method="post"
                  action="${pageContext.request.contextPath}/ticket-category">
                <input type="hidden" name="action" value="toggle">
                <input type="hidden" name="id" id="toggleId">
                <input type="hidden" name="active"
                       id="toggleActive">
                <input type="hidden" name="back"
                       value="${pageContext.request.contextPath}/ticket-category?search=${fSearch}&categoryType=${fType}&status=${fStatus}&page=${currentPage}">
                <div class="modal-body">
                    <p class="mb-0" id="toggleMsg"></p>
                </div>
                <div class="modal-footer border-0">
                    <button type="button"
                            class="btn btn-secondary btn-sm"
                            data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-sm px-4"
                            id="toggleSubmitBtn">Xác nhận</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    // ── Checkboxes ────────────────────────────────────────────────────────
    const selectAll = document.getElementById('selectAll');
    selectAll.addEventListener('change', () => {
        document.querySelectorAll('.row-check').forEach(cb => cb.checked = selectAll.checked);
        updateBulkBar();
    });
    document.addEventListener('change', e => {
        if (e.target.classList.contains('row-check'))
            updateBulkBar();
    });

    function getCheckedIds() {
        return [...document.querySelectorAll('.row-check:checked')].map(cb => cb.value);
    }

    function updateBulkBar() {
        const ids = getCheckedIds();
        const bar = document.getElementById('bulkBar');
        bar.classList.toggle('visible', ids.length > 0);
        document.getElementById('bulkCount').textContent = ids.length + ' đã chọn';
    }

    function syncIds(containerId, ids) {
        const c = document.getElementById(containerId);
        c.innerHTML = '';
        ids.forEach(id => {
            const inp = document.createElement('input');
            inp.type = 'hidden';
            inp.name = 'ids';
            inp.value = id;
            c.appendChild(inp);
        });
    }

    function confirmBulkDelete() {
        const ids = getCheckedIds();
        if (!ids.length)
            return;
        if (!confirm('Xóa ' + ids.length + ' danh mục đã chọn? Danh mục có ticket hoặc danh mục con sẽ bị bỏ qua.'))
            return;
        syncIds('bulkDeleteIds', ids);
        document.getElementById('bulkDeleteForm').submit();
    }

    function bulkToggle(mode) {
        const ids = getCheckedIds();
        if (!ids.length)
            return;
        const formId = mode === 'enable' ? 'bulkEnableForm' : 'bulkDisableForm';
        const idsDiv = mode === 'enable' ? 'bulkEnableIds' : 'bulkDisableIds';
        syncIds(idsDiv, ids);
        document.getElementById(formId).submit();
    }

    // ── Single delete ─────────────────────────────────────────────────────
    function confirmDelete(id, name, ticketCount, childCount) {
        if (ticketCount > 0) {
            alert('Không thể xóa "' + name + '" — có ' + ticketCount + ' ticket đang tham chiếu.');
            return;
        }
        if (childCount > 0) {
            alert('Không thể xóa "' + name + '" — có ' + childCount + ' danh mục con. Hãy xóa chúng trước.');
            return;
        }
        document.getElementById('deleteId').value = id;
        document.getElementById('deleteName').textContent = name;
        bootstrap.Modal.getOrCreateInstance(document.getElementById('deleteModal')).show();
    }

    // ── Toggle status ─────────────────────────────────────────────────────
    function confirmToggle(id, newActive, name) {
        document.getElementById('toggleId').value = id;
        document.getElementById('toggleActive').value = newActive;
        const on = newActive;
        const header = document.getElementById('toggleModalHeader');
        header.className = 'modal-header ' + (on ? 'bg-success text-white' : 'bg-secondary text-white');
        document.getElementById('toggleModalTitle').textContent = on ? 'Kích hoạt Danh mục' : 'Vô hiệu hóa Danh mục';
        document.getElementById('toggleMsg').innerHTML =
                (on ? 'Kích hoạt' : 'Vô hiệu hóa') + ' danh mục <strong>' + name + '</strong>? ' +
                (on ? 'Danh mục sẽ xuất hiện trong form ticket.' : 'Danh mục sẽ bị ẩn khỏi form ticket.');
        const btn = document.getElementById('toggleSubmitBtn');
        btn.className = 'btn btn-sm px-4 ' + (on ? 'btn-success' : 'btn-secondary');
        btn.textContent = on ? 'Kích hoạt' : 'Vô hiệu hóa';
        bootstrap.Modal.getOrCreateInstance(document.getElementById('toggleModal')).show();
    }

    // ── Pagination ────────────────────────────────────────────────────────
    function goPage(p) {
        const inp = document.getElementById('filterPageInp');
        if (inp)
            inp.value = p;
        document.getElementById('filterForm').submit();
    }

    // ── Tooltips ──────────────────────────────────────────────────────────
    document.addEventListener('DOMContentLoaded', () => {
        document.querySelectorAll('[title]').forEach(el => new bootstrap.Tooltip(el, {trigger: 'hover', placement: 'top'}));
    });
</script>

<jsp:include page="/common/admin-layout-bottom.jsp" />