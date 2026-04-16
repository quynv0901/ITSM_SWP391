<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<style>
    @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap');

    body { font-family: 'Inter', sans-serif; background-color: #f4f7f6; }
    h4 { font-family: 'Outfit', sans-serif; }

    .detail-card {
        background: #ffffff; border: 1px solid #e2e8f0; border-radius: 16px;
        padding: 32px 36px; box-shadow: 0 4px 15px rgba(0, 0, 0, .03); margin-bottom: 24px;
    }

    .detail-section-title {
        font-family: 'Outfit', sans-serif; font-size: 15px; font-weight: 700;
        text-transform: uppercase; letter-spacing: 0.8px; color: #2b6cb0;
        margin-bottom: 24px; padding-bottom: 12px; border-bottom: 2px solid #ebf8ff;
        display: flex; align-items: center; gap: 10px;
    }

    .detail-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 24px; }
    .detail-field { display: flex; flex-direction: column; gap: 6px; }
    .detail-field .field-label { font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: .5px; color: #718096; }
    .detail-field .field-value { font-size: 14.5px; color: #2d3748; font-weight: 500; }

    .badge-type { display: inline-flex; align-items: center; gap: 6px; padding: 4px 10px; border-radius: 8px; font-size: 12px; font-weight: 600; letter-spacing: 0.3px; }
    .bt-incident { background: #fff8eb; color: #d97706; border: 1px solid #fde68a; }
    .bt-service  { background: #ecfdf5; color: #059669; border: 1px solid #a7f3d0; }
    .bt-change   { background: #fdf4ff; color: #c026d3; border: 1px solid #f5d0fe; }
    .bt-problem  { background: #fef2f2; color: #dc2626; border: 1px solid #fecaca; }

    .badge-diff { display: inline-block; padding: 4px 10px; border-radius: 8px; font-size: 12px; font-weight: 600; }
    .bd-easy { background: linear-gradient(135deg, #dcfce7, #bbf7d0); color: #166534; box-shadow: 0 1px 2px rgba(0,0,0,0.05); }
    .bd-medium { background: linear-gradient(135deg, #fef3c7, #fde68a); color: #92400e; box-shadow: 0 1px 2px rgba(0,0,0,0.05); }
    .bd-hard { background: linear-gradient(135deg, #fee2e2, #fecaca); color: #991b1b; box-shadow: 0 1px 2px rgba(0,0,0,0.05); }

    .status-on { display: inline-flex; align-items: center; gap: 6px; padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: 600; background: rgba(16, 185, 129, 0.1); color: #059669; border: 1px solid rgba(16, 185, 129, 0.2); }
    .status-off { display: inline-flex; align-items: center; gap: 6px; padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: 600; background: rgba(239, 68, 68, 0.1); color: #dc2626; border: 1px solid rgba(239, 68, 68, 0.2); }

    .sub-table { width: 100%; border-collapse: separate; border-spacing: 0; font-size: 14px; }
    .sub-table th { background: #f8fafc; text-align: left; padding: 12px 16px; font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: .5px; color: #4a5568; border-bottom: 2px solid #e2e8f0; }
    .sub-table td { padding: 12px 16px; border-bottom: 1px solid #edf2f7; vertical-align: middle; transition: background-color 0.15s ease; }
    .sub-table tbody tr:last-child td { border-bottom: none; }
    .sub-table tbody tr:hover td { background: #f0f7fa; }

    .action-strip { display: flex; gap: 12px; flex-wrap: wrap; margin-bottom: 24px; }

    .stat-pill { display: inline-flex; align-items: center; gap: 8px; padding: 8px 16px; border-radius: 10px; font-size: 14px; font-weight: 600; }
    .sp-blue { background: linear-gradient(135deg, #e0effc, #f0f7fd); color: #2b6cb0; border: 1px solid #bee3f8; }
    .sp-orange { background: linear-gradient(135deg, #fffaf0, #fefcbf); color: #c05621; border: 1px solid #fbd38d; }

    .desc-box { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 16px 20px; font-size: 14px; color: #4a5568; line-height: 1.6; }
</style>

<%@ include file="/common/admin-layout-top.jsp" %>

<c:if test="${empty cat}">
    <div class="alert alert-warning">Category not found. <a href="${pageContext.request.contextPath}/ticket-category">Back to list</a>.</div>
</c:if>
<c:if test="${not empty cat}">
    <nav aria-label="breadcrumb" style="margin-bottom:18px;">
        <ol class="breadcrumb mb-0" style="font-size:13px; background:none; padding:0;">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/ticket-category" class="text-decoration-none text-primary">Ticket Categories</a></li>
            <c:if test="${not empty cat.parentCategoryName}">
                <li class="breadcrumb-item text-muted">${cat.parentCategoryName}</li>
            </c:if>
            <li class="breadcrumb-item active">${cat.categoryName}</li>
        </ol>
    </nav>

    <div class="d-flex align-items-start justify-content-between mb-3 flex-wrap gap-2">
        <div>
            <h4 class="fw-bold mb-1" style="color:#222d32;"><i class="bi bi-tag-fill me-2 text-primary"></i>${cat.categoryName}</h4>
            <c:if test="${not empty cat.categoryCode}"><code style="font-size:13px; color:#718096; background:#edf2f7; padding:2px 8px; border-radius:4px;">${cat.categoryCode}</code></c:if>
        </div>
        <div class="action-strip">
            <a href="${pageContext.request.contextPath}/ticket-category?action=form&id=${cat.categoryId}" class="btn btn-warning btn-sm px-3"><i class="bi bi-pencil me-1"></i>Sửa</a>
            <button class="btn btn-sm px-3 ${cat.active ? 'btn-secondary' : 'btn-success'}" data-id="${cat.categoryId}" data-active="${!cat.active}" data-name="${fn:escapeXml(cat.categoryName)}" onclick="confirmToggle(this.dataset.id, this.dataset.active === 'true', this.dataset.name)"><i class="bi bi-toggle-${cat.active ? 'on' : 'off'} me-1"></i>${cat.active ? 'Hủy kích hoạt' : 'Kích hoạt'}</button>
            <button class="btn btn-danger btn-sm px-3" data-id="${cat.categoryId}" data-name="${fn:escapeXml(cat.categoryName)}" data-tc="${cat.ticketCount}" data-cc="${cat.childCount}" onclick="confirmDelete(this.dataset.id, this.dataset.name, this.dataset.tc, this.dataset.cc)"><i class="bi bi-trash3 me-1"></i>Xóa</button>
            <a href="${pageContext.request.contextPath}/ticket-category" class="btn btn-outline-secondary btn-sm px-3"><i class="bi bi-arrow-left me-1"></i>Trở lại</a>
        </div>
    </div>

    <div class="d-flex gap-3 flex-wrap mb-4">
        <span class="stat-pill sp-blue"><i class="bi bi-diagram-3"></i> ${cat.childCount} Sub-categories</span>
        <span class="stat-pill sp-orange"><i class="bi bi-ticket-perforated"></i> ${cat.ticketCount} Tickets</span>
        <c:choose>
            <c:when test="${cat.active}"><span class="status-on"><i class="bi bi-circle-fill" style="font-size:8px;"></i>Active</span></c:when>
            <c:otherwise><span class="status-off"><i class="bi bi-circle-fill" style="font-size:8px;"></i>Inactive</span></c:otherwise>
        </c:choose>
    </div>

    <div class="detail-card">
        <div class="detail-section-title"><i class="bi bi-info-circle-fill text-primary"></i> Category Information</div>
        <div class="detail-grid">
            <div class="detail-field">
                <div class="field-label">Tên danh mục</div>
                <div class="field-value">${cat.categoryName}</div>
            </div>
            <div class="detail-field">
                <div class="field-label">Mã danh mục</div>
                <div class="field-value">${not empty cat.categoryCode ? cat.categoryCode : '—'}</div>
            </div>
            <div class="detail-field">
                <div class="field-label">Loại</div>
                <div class="field-value">
                    <c:choose>
                        <c:when test="${cat.categoryType == 'INCIDENT'}"><span class="badge-type bt-incident">Incident</span></c:when>
                        <c:when test="${cat.categoryType == 'SERVICE_REQUEST'}"><span class="badge-type bt-service">Service Request</span></c:when>
                        <c:when test="${cat.categoryType == 'CHANGE'}"><span class="badge-type bt-change">Change</span></c:when>
                        <c:when test="${cat.categoryType == 'PROBLEM'}"><span class="badge-type bt-problem">Problem</span></c:when>
                        <c:otherwise>${cat.categoryType}</c:otherwise>
                    </c:choose>
                </div>
            </div>
            <div class="detail-field">
                <div class="field-label">Độ khó</div>
                <div class="field-value">
                    <c:choose>
                        <c:when test="${cat.difficultyLevel == 'LEVEL_1'}"> <span class="badge-diff bd-easy">Dễ (Level 1)</span></c:when>
                        <c:when test="${cat.difficultyLevel == 'LEVEL_2'}"> <span class="badge-diff bd-medium">Thường (Level 2)</span></c:when>
                        <c:when test="${cat.difficultyLevel == 'LEVEL_3'}"> <span class="badge-diff bd-hard">Khó (Level 3)</span></c:when>
                        <c:otherwise>—</c:otherwise>
                    </c:choose>
                </div>
            </div>
            <div class="detail-field">
                <div class="field-label">Danh mục cha</div>
                <div class="field-value">
                    <c:choose>
                        <c:when test="${not empty cat.parentCategoryName}">
                            <a href="${pageContext.request.contextPath}/ticket-category?action=detail&id=${cat.parentCategoryId}" style="color:#3c8dbc; text-decoration:none; font-weight:600;"><i class="bi bi-arrow-return-right me-1"></i>${cat.parentCategoryName}</a>
                        </c:when>
                        <c:otherwise><span class="text-muted">— Root (Không có) —</span></c:otherwise>
                    </c:choose>
                </div>
            </div>
            <div class="detail-field">
                <div class="field-label">Cập nhật lần cuối</div>
                <div class="field-value"><c:choose><c:when test="${not empty cat.updatedAt}"><fmt:formatDate value="${cat.updatedAt}" pattern="dd/MM/yyyy HH:mm" /></c:when><c:otherwise>—</c:otherwise></c:choose></div>
            </div>
        </div>
        <c:if test="${not empty cat.description}">
            <div class="mt-4"><div class="field-label mb-2">Mô tả</div><div class="desc-box">${cat.description}</div></div>
        </c:if>
    </div>

    <div class="detail-card">
        <div class="detail-section-title">
            <i class="bi bi-diagram-3 text-primary"></i> Sub-categories
            <span class="badge bg-primary bg-opacity-10 text-primary ms-2">${cat.childCount}</span>
            <a href="${pageContext.request.contextPath}/ticket-category?action=form&parentId=${cat.categoryId}" class="btn btn-sm btn-outline-primary ms-auto" style="font-size:12px;"><i class="bi bi-plus-circle me-1"></i>Thêm danh mục con</a>
        </div>
        <c:choose>
            <c:when test="${empty children}"><p class="text-muted text-center py-3" style="font-size:13px;">Không có danh mục con.</p></c:when>
            <c:otherwise>
                <table class="sub-table">
                    <thead><tr><th>Name</th><th>Code</th><th>Type</th><th>Difficulty</th><th>Tickets</th><th>Status</th></tr></thead>
                    <tbody>
                        <c:forEach var="child" items="${children}">
                            <tr>
                                <td><a href="${pageContext.request.contextPath}/ticket-category?action=detail&id=${child.categoryId}" style="color:#3c8dbc; font-weight:600; text-decoration:none;">${child.categoryName}</a></td>
                                <td style="font-size:12px; color:#718096;">${not empty child.categoryCode ? child.categoryCode : '—'}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${child.categoryType == 'INCIDENT'}"><span class="badge-type bt-incident">Incident</span></c:when>
                                        <c:when test="${child.categoryType == 'SERVICE_REQUEST'}"><span class="badge-type bt-service">Service Req.</span></c:when>
                                        <c:when test="${child.categoryType == 'CHANGE'}"><span class="badge-type bt-change">Change</span></c:when>
                                        <c:when test="${child.categoryType == 'PROBLEM'}"><span class="badge-type bt-problem">Problem</span></c:when>
                                        <c:otherwise>${child.categoryType}</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${child.difficultyLevel == 'LEVEL_1'}"><span class="badge-diff bd-easy">Dễ</span></c:when>
                                        <c:when test="${child.difficultyLevel == 'LEVEL_2'}"><span class="badge-diff bd-medium">Thường</span></c:when>
                                        <c:when test="${child.difficultyLevel == 'LEVEL_3'}"><span class="badge-diff bd-hard">Khó</span></c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center">${child.ticketCount}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${child.active}"><span class="status-on" style="font-size:11px;">Active</span></c:when>
                                        <c:otherwise><span class="status-off" style="font-size:11px;">Inactive</span></c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
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
                    <div class="modal-body"><p class="mb-0">Bạn chắc chắn xóa <strong id="deleteName"></strong>? Hành động này <span class="text-danger fw-semibold">không thể hoàn tác</span>.</p></div>
                    <div class="modal-footer border-0">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-danger btn-sm px-4">Xóa</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="modal fade" id="toggleModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered" style="max-width:400px;">
            <div class="modal-content border-0 shadow-lg">
                <div class="modal-header" id="toggleHdr">
                    <h5 class="modal-title" id="toggleTitle"></h5>
                    <button type="button" class="btn-close" id="toggleClosBtn" data-bs-dismiss="modal"></button>
                </div>
                <form method="post" action="${pageContext.request.contextPath}/ticket-category">
                    <input type="hidden" name="action" value="toggle">
                    <input type="hidden" name="id" id="toggleId">
                    <input type="hidden" name="active" id="toggleActive">
                    <input type="hidden" name="back" value="${pageContext.request.contextPath}/ticket-category?action=detail&id=${cat.categoryId}">
                    <div class="modal-body"><p class="mb-0" id="toggleMsg"></p></div>
                    <div class="modal-footer border-0">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-sm px-4" id="toggleBtn"></button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</c:if>

<script>
    function confirmDelete(id, name, ticketCount, childCount) {
        if (ticketCount > 0) { alert('Không thể xóa — ' + ticketCount + ' vé đang sử dụng.'); return; }
        if (childCount > 0) { alert('Không thể xóa — danh mục này có ' + childCount + ' mục con.'); return; }
        document.getElementById('deleteId').value = id;
        document.getElementById('deleteName').textContent = name;
        bootstrap.Modal.getOrCreateInstance(document.getElementById('deleteModal')).show();
    }
    function confirmToggle(id, newActive, name) {
        document.getElementById('toggleId').value = id;
        document.getElementById('toggleActive').value = newActive;
        const hdr = document.getElementById('toggleHdr');
        hdr.className = 'modal-header ' + (newActive ? 'bg-success text-white' : 'bg-secondary text-white');
        document.getElementById('toggleTitle').textContent = newActive ? 'Kích hoạt' : 'Vô hiệu hóa';
        document.getElementById('toggleMsg').innerHTML = (newActive ? 'Kích hoạt thẻ ' : 'Vô hiệu hóa thẻ ') + ' <strong>' + name + '</strong>?';
        document.getElementById('toggleClosBtn').className = 'btn-close' + (newActive || !newActive ? ' btn-close-white' : '');
        const btn = document.getElementById('toggleBtn');
        btn.className = 'btn btn-sm px-4 ' + (newActive ? 'btn-success' : 'btn-secondary');
        btn.textContent = newActive ? 'Kích hoạt' : 'Hủy kích hoạt';
        bootstrap.Modal.getOrCreateInstance(document.getElementById('toggleModal')).show();
    }
</script>

<jsp:include page="/common/admin-layout-bottom.jsp" />