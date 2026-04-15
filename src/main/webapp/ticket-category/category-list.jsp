<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<style>
    @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&family=Inter:wght@400;500;600;700&display=swap');

    body {
        font-family: 'Inter', sans-serif;
        background-color: #f4f7f6;
    }
    
    h4, .modal-title {
        font-family: 'Outfit', sans-serif;
    }

    .stat-row {
        display: flex; gap: 20px; flex-wrap: wrap; margin-bottom: 24px;
    }

    .stat-card {
        flex: 1; min-width: 160px;
        background: rgba(255, 255, 255, 0.85);
        backdrop-filter: blur(10px);
        border: 1px solid rgba(255, 255, 255, 0.5);
        border-radius: 16px; padding: 20px 24px;
        display: flex; align-items: center; gap: 18px;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.03), 0 1px 3px rgba(0,0,0,0.02);
        transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        cursor: pointer; text-decoration: none; color: inherit;
        position: relative; overflow: hidden;
    }

    .stat-card::before {
        content: ''; position: absolute;
        top: 0; left: 0; right: 0; height: 4px;
        background: linear-gradient(90deg, #3c8dbc, #00d2ff);
        opacity: 0; transition: opacity 0.3s;
    }

    .stat-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 12px 25px rgba(0, 0, 0, 0.08);
        color: inherit;
    }

    .stat-card:hover::before { opacity: 1; }

    .stat-icon {
        width: 54px; height: 54px; border-radius: 14px;
        display: flex; align-items: center; justify-content: center;
        font-size: 24px; flex-shrink: 0;
        background: linear-gradient(135deg, #f0f7fd, #e0effc);
        box-shadow: inset 0 2px 4px rgba(255,255,255,0.5);
    }

    .stat-label {
        font-size: 13px; font-weight: 600; text-transform: uppercase;
        letter-spacing: 0.8px; color: #718096; margin-bottom: 2px;
        font-family: 'Outfit', sans-serif;
    }

    .stat-value {
        font-size: 32px; font-weight: 800; color: #1a202c; line-height: 1;
        font-family: 'Outfit', sans-serif;
    }

    .filter-card {
        background: #ffffff; border: 1px solid #e2e8f0; border-radius: 16px;
        padding: 20px 24px; margin-bottom: 24px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
    }

    .filter-row { display: flex; gap: 16px; flex-wrap: wrap; align-items: flex-end; }
    .filter-group { display: flex; flex-direction: column; gap: 6px; flex: 1; min-width: 150px; }
    .filter-group label { font-size: 12px; font-weight: 600; color: #4a5568; text-transform: uppercase; letter-spacing: 0.5px; }
    .filter-group select, .filter-group input {
        padding: 10px 14px; border: 1px solid #cbd5e0; border-radius: 8px;
        font-size: 14px; color: #2d3748; background: #f7fafc; transition: all 0.2s ease;
        font-family: 'Inter', sans-serif;
    }
    .filter-group select:focus, .filter-group input:focus {
        outline: none; border-color: #4299e1; box-shadow: 0 0 0 3px rgba(66, 153, 225, 0.2); background: #fff;
    }

    .table-card {
        background: #ffffff; border: 1px solid #e2e8f0; border-radius: 16px;
        overflow: hidden; box-shadow: 0 4px 15px rgba(0, 0, 0, 0.03);
    }

    .cat-table { width: 100%; border-collapse: separate; border-spacing: 0; font-size: 14px; font-family: 'Inter', sans-serif; }
    .cat-table thead { background: #f8fafc; }
    .cat-table th { padding: 14px 16px; font-weight: 600; color: #4a5568; text-transform: uppercase; font-size: 12px; letter-spacing: 0.5px; white-space: nowrap; border-bottom: 2px solid #e2e8f0; }
    .cat-table td { padding: 14px 16px; border-bottom: 1px solid #edf2f7; vertical-align: middle; color: #2d3748; transition: background-color 0.15s ease; }
    .cat-table tbody tr { transition: all 0.2s ease; }
    .cat-table tbody tr:hover { background: #f0f7fa; transform: scale(1.001); box-shadow: inset 2px 0 0 #3c8dbc; }
    .cat-table tbody tr:last-child td { border-bottom: none; }

    .badge-type { display: inline-flex; align-items: center; gap: 6px; padding: 4px 10px; border-radius: 8px; font-size: 12px; font-weight: 600; letter-spacing: 0.3px; }
    .badge-type i { font-size: 11px; }
    .bt-incident { background: #fff8eb; color: #d97706; border: 1px solid #fde68a; }
    .bt-service  { background: #ecfdf5; color: #059669; border: 1px solid #a7f3d0; }
    .bt-change   { background: #fdf4ff; color: #c026d3; border: 1px solid #f5d0fe; }
    .bt-problem  { background: #fef2f2; color: #dc2626; border: 1px solid #fecaca; }

    .badge-diff { display: inline-block; padding: 4px 10px; border-radius: 8px; font-size: 12px; font-weight: 600; position: relative; }
    .bd-easy { background: linear-gradient(135deg, #dcfce7, #bbf7d0); color: #166534; box-shadow: 0 1px 2px rgba(0,0,0,0.05); }
    .bd-medium { background: linear-gradient(135deg, #fef3c7, #fde68a); color: #92400e; box-shadow: 0 1px 2px rgba(0,0,0,0.05); }
    .bd-hard { background: linear-gradient(135deg, #fee2e2, #fecaca); color: #991b1b; box-shadow: 0 1px 2px rgba(0,0,0,0.05); }

    .status-on { display: inline-flex; align-items: center; gap: 6px; padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: 600; background: rgba(16, 185, 129, 0.1); color: #059669; border: 1px solid rgba(16, 185, 129, 0.2); }
    .status-off { display: inline-flex; align-items: center; gap: 6px; padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: 600; background: rgba(239, 68, 68, 0.1); color: #dc2626; border: 1px solid rgba(239, 68, 68, 0.2); }

    .status-on .bi-circle-fill { color: #10b981; text-shadow: 0 0 5px rgba(16,185,129,0.5); }
    .status-off .bi-circle-fill { color: #ef4444; text-shadow: 0 0 5px rgba(239,68,68,0.5); }

    .btn-icon { width: 34px; height: 34px; display: inline-flex; align-items: center; justify-content: center; border-radius: 8px; border: none; cursor: pointer; font-size: 14px; transition: all 0.2s; color: #fff; }
    .btn-icon:hover { transform: translateY(-2px) scale(1.05); box-shadow: 0 4px 8px rgba(0,0,0,0.1); }
    .btn-icon.bg-info { background: linear-gradient(135deg, #0ea5e9, #0284c7) !important; }
    .btn-icon.bg-warning { background: linear-gradient(135deg, #f59e0b, #d97706) !important; color:#fff !important; }
    .btn-icon.bg-danger { background: linear-gradient(135deg, #ef4444, #dc2626) !important; }

    .btn-primary { background: linear-gradient(135deg, #3b82f6, #2563eb); border: none; border-radius: 8px; font-weight: 600; letter-spacing: 0.3px; transition: all 0.2s ease; box-shadow: 0 4px 6px rgba(37, 99, 235, 0.2); }
    .btn-primary:hover { background: linear-gradient(135deg, #2563eb, #1d4ed8); transform: translateY(-1px); box-shadow: 0 6px 12px rgba(37, 99, 235, 0.3); }

    .bulk-bar { display: none; background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 12px; padding: 12px 20px; margin-bottom: 20px; align-items: center; gap: 16px; flex-wrap: wrap; box-shadow: 0 2px 4px rgba(0,0,0,0.02); animation: slideDown 0.3s ease-out; }
    @keyframes slideDown { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }
    .bulk-bar.visible { display: flex; }
    .bulk-count { font-weight: 700; color: #166534; font-size: 14px; font-family: 'Outfit', sans-serif; }

    .pager-row { display: flex; justify-content: space-between; align-items: center; padding: 16px 20px; background: #f8fafc; border-top: 1px solid #e2e8f0; flex-wrap: wrap; gap: 10px; }
    .pagination .page-link { border-radius: 6px; margin: 0 2px; color: #4a5568; border: 1px solid transparent; font-weight: 500; }
    .pagination .page-item.active .page-link { background: #3b82f6; color: white; border: none; box-shadow: 0 2px 4px rgba(59, 130, 246, 0.3); }

    .flash { padding: 14px 20px; border-radius: 12px; font-size: 14px; font-weight: 500; margin-bottom: 20px; display: flex; align-items: center; gap: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.02); }
    .flash i { font-size: 20px; }
    .flash-success { background: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; }
    .flash-error { background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; }

    .empty-state { padding: 80px 20px; text-align: center; color: #718096; }
    .empty-state-icon { font-size: 64px; color: #cbd5e0; margin-bottom: 16px; display: block; }
    .empty-state h5 { font-family: 'Outfit', sans-serif; color: #2d3748; font-weight: 700; margin-bottom: 8px; }

    .cat-name-link { color: #2563eb; font-weight: 600; text-decoration: none; transition: color 0.15s; }
    .cat-name-link:hover { color: #1d4ed8; text-decoration: underline; }
    .parent-pill { background: #f1f5f9; color: #475569; padding: 4px 10px; border-radius: 8px; font-size: 12px; font-weight: 600; border: 1px dashed #cbd5e0; }

    .switch { position: relative; display: inline-block; width: 40px; height: 22px; margin-bottom:0;}
    .switch input { opacity: 0; width: 0; height: 0; }
    .slider { position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: #cbd5e0; transition: .3s; border-radius: 34px; box-shadow: inset 0 1px 3px rgba(0,0,0,0.1); }
    .slider:before { position: absolute; content: ""; height: 16px; width: 16px; left: 3px; bottom: 3px; background-color: white; transition: .3s cubic-bezier(0.68, -0.55, 0.265, 1.55); border-radius: 50%; box-shadow: 0 1px 3px rgba(0,0,0,0.2); }
    input:checked+.slider { background-color: #10b981; }
    input:focus+.slider { box-shadow: 0 0 1px #10b981; }
    input:checked+.slider:before { transform: translateX(18px); }
</style>

<%@ include file="/common/admin-layout-top.jsp" %>

<c:if test="${not empty param.createSuccess}"><div class="flash flash-success"><i class="bi bi-check-circle-fill"></i> Tạo hạng mục thành công.</div></c:if>
<c:if test="${not empty param.updateSuccess}"><div class="flash flash-success"><i class="bi bi-check-circle-fill"></i> Cập nhật thành công.</div></c:if>
<c:if test="${not empty param.deleteSuccess}"><div class="flash flash-success"><i class="bi bi-check-circle-fill"></i> Đã xóa thành công.</div></c:if>
<c:if test="${not empty param.toggleSuccess}"><div class="flash flash-success"><i class="bi bi-check-circle-fill"></i> Đã cập nhật trạng thái hạng mục.</div></c:if>
<c:if test="${not empty param.bulkDeleteSuccess}"><div class="flash flash-success"><i class="bi bi-check-circle-fill"></i> Đã xóa <strong>${param.bulkDeleteSuccess}</strong> mục.</div></c:if>
<c:if test="${not empty param.bulkToggleSuccess}"><div class="flash flash-success"><i class="bi bi-check-circle-fill"></i> Đã trạng thái <strong>${param.bulkToggleSuccess}</strong> mục.</div></c:if>
<c:choose>
    <c:when test="${param.error == 'has_tickets'}"><div class="flash flash-error"><i class="bi bi-exclamation-triangle-fill"></i> Không thể xóa — danh mục này đã chứa vé.</div></c:when>
    <c:when test="${param.error == 'has_children'}"><div class="flash flash-error"><i class="bi bi-exclamation-triangle-fill"></i> Không thể xóa — danh mục này có chứa các danh mục con.</div></c:when>
    <c:when test="${not empty param.error}"><div class="flash flash-error"><i class="bi bi-exclamation-triangle-fill"></i> Thao tác thất bại: ${param.error}</div></c:when>
</c:choose>

<div class="d-flex align-items-center justify-content-between mb-3">
    <div>
        <h4 class="fw-bold mb-0" style="color:#222d32;"><i class="bi bi-tags-fill me-2 text-primary"></i>Quản lý Danh mục Ticket</h4>
        <small class="text-muted">Quản lý danh sách phân cấp danh mục ticket, quy tắc định tuyến và mức độ khó.</small>
    </div>
    <a href="${pageContext.request.contextPath}/ticket-category?action=form" class="btn btn-primary btn-sm px-3">
        <i class="bi bi-plus-circle me-1"></i>Thêm Danh mục
    </a>
</div>

<div class="stat-row">
    <a href="${pageContext.request.contextPath}/ticket-category" class="stat-card">
        <div class="stat-icon" style="background:#e8f4fd;"><i class="bi bi-tags text-primary"></i></div>
        <div><div class="stat-label">Tổng cộng</div><div class="stat-value">${totalAll}</div></div>
    </a>
    <a href="${pageContext.request.contextPath}/ticket-category?status=active" class="stat-card">
        <div class="stat-icon" style="background:#e0fff4;"><i class="bi bi-check-circle" style="color:#27ae60;"></i></div>
        <div><div class="stat-label">Active</div><div class="stat-value">${totalActive}</div></div>
    </a>
    <a href="${pageContext.request.contextPath}/ticket-category?status=inactive" class="stat-card">
        <div class="stat-icon" style="background:#fff5f5;"><i class="bi bi-slash-circle" style="color:#c53030;"></i></div>
        <div><div class="stat-label">Inactive</div><div class="stat-value">${totalInact}</div></div>
    </a>
</div>

<div class="filter-card">
    <form method="get" action="${pageContext.request.contextPath}/ticket-category" id="filterForm">
        <div class="filter-row">
            <div class="filter-group" style="max-width:280px;">
                <label>Tìm kiếm</label>
                <input type="text" name="search" placeholder="Tên, mã, mô tả…" value="${fSearch}">
            </div>
            <div class="filter-group" style="max-width:200px;">
                <label>Loại</label>
                <select name="categoryType">
                    <option value="">— Tất cả loại —</option>
                    <option value="INCIDENT" ${fType=='INCIDENT' ? 'selected' : ''}>Incident</option>
                    <option value="SERVICE_REQUEST" ${fType=='SERVICE_REQUEST' ? 'selected' : ''}>Service request</option>
                    <option value="CHANGE" ${fType=='CHANGE' ? 'selected' : ''}>Thay đổi</option>
                    <option value="PROBLEM" ${fType=='PROBLEM' ? 'selected' : ''}>Vấn đề</option>
                </select>
            </div>
            <div class="filter-group" style="max-width:170px;">
                <label>Trạng thái</label>
                <select name="status">
                    <option value="">— Tất cả —</option>
                    <option value="active" ${fStatus=='active' ? 'selected' : ''}>Active</option>
                    <option value="inactive" ${fStatus=='inactive' ? 'selected' : ''}>Inactive</option>
                </select>
            </div>
            <div class="filter-group" style="max-width:110px;">
                <label>Hiển thị</label>
                <select name="pageSize" onchange="this.form.submit()">
                    <option value="10" ${pageSize==10 ? 'selected' : ''}>10 dòng</option>
                    <option value="15" ${pageSize==15 || empty pageSize ? 'selected' : ''}>15 dòng</option>
                    <option value="25" ${pageSize==25 ? 'selected' : ''}>25 dòng</option>
                    <option value="50" ${pageSize==50 ? 'selected' : ''}>50 dòng</option>
                    <option value="100" ${pageSize==100 ? 'selected' : ''}>100 dòng</option>
                </select>
            </div>
            <div class="filter-group" style="max-width:200px; flex-direction:row; gap:8px; align-items:flex-end;">
                <input type="hidden" name="page" value="1" id="filterPageInp">
                <button type="submit" class="btn btn-primary btn-sm px-3" style="white-space:nowrap;"><i class="bi bi-search me-1"></i>Tìm</button>
                <a href="${pageContext.request.contextPath}/ticket-category" class="btn btn-outline-secondary btn-sm px-3" style="white-space:nowrap;"><i class="bi bi-x-circle me-1"></i>Xóa lọc</a>
            </div>
        </div>
    </form>
</div>

<div class="bulk-bar" id="bulkBar">
    <span class="bulk-count" id="bulkCount">0 đã chọn</span>
    <form method="post" action="${pageContext.request.contextPath}/ticket-category" id="bulkDeleteForm" style="display:inline;">
        <input type="hidden" name="action" value="bulkDelete">
        <div id="bulkDeleteIds"></div>
        <button type="button" class="btn btn-danger btn-sm" onclick="confirmBulkDelete()">
            <i class="bi bi-trash3 me-1"></i>Xóa đã chọn
        </button>
    </form>
    <form method="post" action="${pageContext.request.contextPath}/ticket-category" id="bulkEnableForm" style="display:inline;">
        <input type="hidden" name="action" value="bulkToggle">
        <input type="hidden" name="active" value="true">
        <div id="bulkEnableIds"></div>
        <button type="button" class="btn btn-success btn-sm" onclick="bulkToggle('enable')"><i class="bi bi-toggle-on me-1"></i>Bật</button>
    </form>
    <form method="post" action="${pageContext.request.contextPath}/ticket-category" id="bulkDisableForm" style="display:inline;">
        <input type="hidden" name="action" value="bulkToggle">
        <input type="hidden" name="active" value="false">
        <div id="bulkDisableIds"></div>
        <button type="button" class="btn btn-secondary btn-sm" onclick="bulkToggle('disable')"><i class="bi bi-toggle-off me-1"></i>Tắt</button>
    </form>
</div>

<div class="table-card">
    <table class="cat-table">
        <thead>
            <tr>
                <th style="width:38px;"><input type="checkbox" id="selectAll" title="Chọn tất cả" class="form-check-input"></th>
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
                                <i class="bi bi-folder-x empty-state-icon"></i>
                                <h5>Chưa có danh mục nào</h5>
                                <p class="mb-3 text-muted" style="font-size:14px;">Bắt đầu bằng cách tạo danh mục đầu tiên để tổ chức các yêu cầu hỗ trợ.</p>
                                <a href="${pageContext.request.contextPath}/ticket-category?action=form" class="btn btn-primary px-4 py-2" style="border-radius: 8px;">
                                    <i class="bi bi-plus-circle me-2"></i>Tạo danh mục mới
                                </a>
                            </div>
                        </td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="cat" items="${categories}" varStatus="s">
                        <tr>
                            <td><input type="checkbox" class="form-check-input row-check" value="${cat.categoryId}"></td>
                            <td class="text-muted">${(currentPage - 1) * pageSize + s.index + 1}</td>
                            <td>
                                <a href="${pageContext.request.contextPath}/ticket-category?action=detail&id=${cat.categoryId}" class="cat-name-link">${cat.categoryName}</a>
                                <c:if test="${not empty cat.categoryCode}">
                                    <div style="font-size:11px; color:#a0aec0; margin-top:1px;"><i class="bi bi-hash"></i>${cat.categoryCode}</div>
                                </c:if>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${cat.categoryType == 'INCIDENT'}"><span class="badge-type bt-incident"><i class="bi bi-exclamation-octagon me-1"></i>Incident</span></c:when>
                                    <c:when test="${cat.categoryType == 'SERVICE_REQUEST'}"><span class="badge-type bt-service"><i class="bi bi-cart2 me-1"></i>Service Request</span></c:when>
                                    <c:when test="${cat.categoryType == 'CHANGE'}"><span class="badge-type bt-change"><i class="bi bi-arrow-repeat me-1"></i>Change</span></c:when>
                                    <c:when test="${cat.categoryType == 'PROBLEM'}"><span class="badge-type bt-problem"><i class="bi bi-bug me-1"></i>Problem</span></c:when>
                                    <c:otherwise><span class="badge-type" style="background:#edf2f7; color:#4a5568;"><i class="bi bi-tag me-1"></i>${cat.categoryType}</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty cat.parentCategoryName}"><span class="parent-pill"><i class="bi bi-arrow-return-right me-1"></i>${cat.parentCategoryName}</span></c:when>
                                    <c:otherwise><span class="text-muted" style="font-size:12px;">— Root —</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${cat.difficultyLevel == 'LEVEL_1'}"><span class="badge-diff bd-easy">Easy</span></c:when>
                                    <c:when test="${cat.difficultyLevel == 'LEVEL_2'}"><span class="badge-diff bd-medium">Medium</span></c:when>
                                    <c:when test="${cat.difficultyLevel == 'LEVEL_3'}"><span class="badge-diff bd-hard">Hard</span></c:when>
                                    <c:otherwise><span class="text-muted" style="font-size:12px;">—</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${cat.childCount > 0}"><span class="fw-bold text-primary">${cat.childCount}</span></c:when>
                                    <c:otherwise><span class="text-muted">0</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${cat.ticketCount > 0}"><span class="fw-bold text-warning">${cat.ticketCount}</span></c:when>
                                    <c:otherwise><span class="text-muted">0</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div class="d-flex align-items-center gap-2">
                                    <span class="${cat.active ? 'status-on' : 'status-off'}">
                                        <i class="bi bi-circle-fill" style="font-size:7px;"></i> ${cat.active ? 'Active' : 'Inactive'}
                                    </span>
                                    <label class="switch">
                                        <input type="checkbox" ${cat.active ? 'checked' : ''} data-id="${cat.categoryId}" data-active="${!cat.active}" data-name="${fn:escapeXml(cat.categoryName)}" onclick="confirmToggle(this.dataset.id, this.dataset.active === 'true', this.dataset.name)">
                                        <span class="slider"></span>
                                    </label>
                                </div>
                            </td>
                            <td style="font-size:12px; color:#718096; white-space:nowrap;">
                                <c:if test="${not empty cat.updatedAt}">
                                    <fmt:formatDate value="${cat.updatedAt}" pattern="dd/MM/yyyy" />
                                </c:if>
                            </td>
                            <td class="text-center">
                                <div class="d-flex align-items-center justify-content-center gap-1">
                                    <a href="${pageContext.request.contextPath}/ticket-category?action=detail&id=${cat.categoryId}" class="btn-icon bg-info text-white"><i class="bi bi-eye"></i></a>
                                    <a href="${pageContext.request.contextPath}/ticket-category?action=form&id=${cat.categoryId}" class="btn-icon bg-warning text-dark"><i class="bi bi-pencil"></i></a>
                                    <button class="btn-icon bg-danger text-white" data-id="${cat.categoryId}" data-name="${fn:escapeXml(cat.categoryName)}" data-tc="${cat.ticketCount}" data-cc="${cat.childCount}" onclick="confirmDelete(this.dataset.id, this.dataset.name, this.dataset.tc, this.dataset.cc)"><i class="bi bi-trash3"></i></button>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </tbody>
    </table>

    <c:if test="${totalPages >= 1}">
        <div class="pager-row">
            <span class="text-muted small">Hiển thị <strong>${fromIdx}</strong> – <strong>${toIdx}</strong> trong <strong>${total}</strong> danh mục &nbsp;·&nbsp; Trang <strong>${currentPage}</strong> / <strong>${totalPages}</strong></span>
            <nav>
                <ul class="pagination pagination-sm mb-0">
                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}"><a class="page-link" href="javascript:void(0)" onclick="goPage(${currentPage-1})">‹</a></li>
                    <c:forEach var="i" begin="1" end="${totalPages}">
                        <c:if test="${i >= currentPage-2 && i <= currentPage+2}">
                            <li class="page-item ${currentPage == i ? 'active' : ''}"><a class="page-link" href="javascript:void(0)" onclick="goPage(${i})">${i}</a></li>
                        </c:if>
                    </c:forEach>
                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}"><a class="page-link" href="javascript:void(0)" onclick="goPage(${currentPage+1})">›</a></li>
                </ul>
            </nav>
        </div>
    </c:if>
</div>

<div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered" style="max-width:420px;">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title"><i class="bi bi-trash3 me-2"></i>Xóa Danh mục</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/ticket-category">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="id" id="deleteId">
                <div class="modal-body">
                    <p class="mb-0">Xóa danh mục <strong id="deleteName"></strong>? Hành động này <span class="text-danger fw-semibold">không thể hoàn tác</span>.</p>
                </div>
                <div class="modal-footer border-0">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-danger btn-sm px-4"><i class="bi bi-trash3 me-1"></i>Xóa</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="toggleModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered" style="max-width:400px;">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header" id="toggleModalHeader">
                <h5 class="modal-title" id="toggleModalTitle"></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/ticket-category">
                <input type="hidden" name="action" value="toggle">
                <input type="hidden" name="id" id="toggleId">
                <input type="hidden" name="active" id="toggleActive">
                <input type="hidden" name="back" value="${pageContext.request.contextPath}/ticket-category?search=${fSearch}&categoryType=${fType}&status=${fStatus}&page=${currentPage}">
                <div class="modal-body">
                    <p class="mb-0" id="toggleMsg"></p>
                </div>
                <div class="modal-footer border-0">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-sm px-4" id="toggleSubmitBtn">Xác nhận</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    const selectAll = document.getElementById('selectAll');
    selectAll.addEventListener('change', () => {
        document.querySelectorAll('.row-check').forEach(cb => cb.checked = selectAll.checked);
        updateBulkBar();
    });
    document.addEventListener('change', e => { if (e.target.classList.contains('row-check')) updateBulkBar(); });

    function getCheckedIds() { return [...document.querySelectorAll('.row-check:checked')].map(cb => cb.value); }

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
            inp.type = 'hidden'; inp.name = 'ids'; inp.value = id;
            c.appendChild(inp);
        });
    }

    function confirmBulkDelete() {
        const ids = getCheckedIds();
        if (!ids.length) return;
        if (!confirm('Xóa ' + ids.length + ' danh mục đã chọn? Danh mục có vé hoặc hệ thống con sẽ bị bỏ qua.')) return;
        syncIds('bulkDeleteIds', ids);
        document.getElementById('bulkDeleteForm').submit();
    }

    function bulkToggle(mode) {
        const ids = getCheckedIds();
        if (!ids.length) return;
        syncIds(mode === 'enable' ? 'bulkEnableIds' : 'bulkDisableIds', ids);
        document.getElementById(mode === 'enable' ? 'bulkEnableForm' : 'bulkDisableForm').submit();
    }

    function confirmDelete(id, name, ticketCount, childCount) {
        if (ticketCount > 0) { alert('Không thể xóa — có ' + ticketCount + ' vé đang sử dụng.'); return; }
        if (childCount > 0) { alert('Không thể xóa — có ' + childCount + ' danh mục con.'); return; }
        document.getElementById('deleteId').value = id;
        document.getElementById('deleteName').textContent = name;
        bootstrap.Modal.getOrCreateInstance(document.getElementById('deleteModal')).show();
    }

    function confirmToggle(id, newActive, name) {
        document.getElementById('toggleId').value = id;
        document.getElementById('toggleActive').value = newActive;
        const on = newActive;
        const header = document.getElementById('toggleModalHeader');
        header.className = 'modal-header ' + (on ? 'bg-success text-white' : 'bg-secondary text-white');
        document.getElementById('toggleModalTitle').textContent = on ? 'Kích hoạt' : 'Vô hiệu hóa';
        document.getElementById('toggleMsg').innerHTML = (on ? 'Kích hoạt ' : 'Vô hiệu hóa ') + '<strong>' + name + '</strong>?';
        const btn = document.getElementById('toggleSubmitBtn');
        btn.className = 'btn btn-sm px-4 ' + (on ? 'btn-success' : 'btn-secondary');
        btn.textContent = on ? 'Kích hoạt' : 'Hủy kích hoạt';
        bootstrap.Modal.getOrCreateInstance(document.getElementById('toggleModal')).show();
    }

    function goPage(p) {
        const inp = document.getElementById('filterPageInp');
        if (inp) inp.value = p;
        document.getElementById('filterForm').submit();
    }
</script>

<jsp:include page="/common/admin-layout-bottom.jsp" />