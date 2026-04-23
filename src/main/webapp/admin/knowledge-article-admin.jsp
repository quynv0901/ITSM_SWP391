<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/includes/header.jsp">
    <jsp:param name="pageTitle" value="Phê duyệt bài viết Knowledge Article" />
</jsp:include>

<style>
    .page-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:24px; }
    .page-header h2 { font-size:1.4rem; font-weight:700; color:#2d3436; margin:0; }
    .page-header h2 i { color:#6f42c1; margin-right:8px; }

    .stats-bar { display:flex; gap:12px; margin-bottom:20px; flex-wrap:wrap; }
    .stat-chip {
        display:flex; align-items:center; gap:8px;
        background:#fff; border:1px solid #e9ecef; border-radius:8px;
        padding:8px 16px; font-size:0.85rem; font-weight:600; color:#495057;
        text-decoration:none; transition:all 0.2s;
    }
    .stat-chip:hover { box-shadow:0 2px 8px rgba(0,0,0,0.08); color:#495057; text-decoration:none; }
    .stat-chip .dot { width:10px; height:10px; border-radius:50%; }
    .dot-pending  { background:#ffc107; }
    .dot-approved { background:#28a745; }
    .dot-rejected { background:#dc3545; }
    .dot-archived { background:#6c757d; }
    .stat-chip .count { font-size:1rem; color:#212529; }

    .filter-bar { background:#f8f9fa; border:1px solid #e9ecef; border-radius:10px; padding:16px 20px; margin-bottom:20px; }

    .table thead th {
        background:#f3f0ff; color:#5a32a3; font-weight:600; font-size:0.85rem;
        border-bottom:2px solid #d8b4fe; white-space:nowrap; vertical-align:middle;
    }
    .table tbody tr:hover { background:#faf7ff; }
    .table td { vertical-align:middle; font-size:0.88rem; }

    .status-badge { display:inline-block; padding:3px 10px; border-radius:20px; font-size:0.75rem; font-weight:600; }
    .badge-pending  { background:#fff3cd; color:#856404; border:1px solid #ffc107; }
    .badge-approved { background:#d1f0da; color:#155724; border:1px solid #28a745; }
    .badge-rejected { background:#f8d7da; color:#721c24; border:1px solid #dc3545; }
    .badge-archived { background:#e2e3e5; color:#383d41; border:1px solid #6c757d; }

    .btn-approve  { background:#28a745; color:#fff; border:none; padding:4px 12px; border-radius:6px; font-size:0.8rem; font-weight:600; }
    .btn-approve:hover  { background:#218838; color:#fff; }
    .btn-reject   { background:#dc3545; color:#fff; border:none; padding:4px 12px; border-radius:6px; font-size:0.8rem; font-weight:600; }
    .btn-reject:hover   { background:#c82333; color:#fff; }
    .btn-view     { background:#17a2b8; color:#fff; border:none; padding:4px 12px; border-radius:6px; font-size:0.8rem; font-weight:600; }
    .btn-view:hover     { background:#138496; color:#fff; }
    .btn-archive  { background:#6c757d; color:#fff; border:none; padding:4px 12px; border-radius:6px; font-size:0.8rem; font-weight:600; }
    .btn-archive:hover  { background:#545b62; color:#fff; }
    .btn-restore  { background:#20c997; color:#fff; border:none; padding:4px 12px; border-radius:6px; font-size:0.8rem; font-weight:600; }
    .btn-restore:hover  { background:#17a589; color:#fff; }

    .modal-header { background:#dc3545; color:white; }
    .modal-header .btn-close { filter:invert(1); }

    .empty-state { text-align:center; padding:48px 24px; color:#adb5bd; }
    .empty-state i { font-size:3rem; margin-bottom:12px; display:block; }
    .title-cell { max-width:220px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
</style>

<div class="container-fluid bg-white p-4 rounded shadow-sm">

    <!-- Header -->
    <div class="page-header">
        <h2><i class="bi bi-shield-check"></i> Phê duyệt bài viết Knowledge Article</h2>
        <div class="d-flex gap-2">
            <button type="button" class="btn btn-danger btn-sm" onclick="submitBulkAction('bulkDelete')">
                <i class="bi bi-trash"></i> Xóa hàng loạt
            </button>
            <button type="button" class="btn btn-success btn-sm" onclick="submitBulkAction('bulkReview')">
                <i class="bi bi-check-circle"></i> Duyệt hàng loạt
            </button>
            <button type="button" class="btn btn-secondary btn-sm" onclick="submitBulkAction('bulkArchive')">
                <i class="bi bi-archive"></i> Vô hiệu hóa hàng loạt
            </button>
        </div>
    </div>

    <!-- Alerts -->
    <c:if test="${not empty param.message}">
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle-fill me-2"></i> ${param.message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${not empty param.error}">
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle-fill me-2"></i> ${param.error}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <!-- Stats bar -->
    <div class="stats-bar">
        <a href="?action=list" class="stat-chip">
            <span class="dot" style="background:#6f42c1;"></span> Tất cả
            <span class="count">${totalAll}</span>
        </a>
        <a href="?action=list&status=PENDING" class="stat-chip">
            <span class="dot dot-pending"></span> Chờ duyệt
            <span class="count">${totalPending}</span>
        </a>
        <a href="?action=list&status=APPROVED" class="stat-chip">
            <span class="dot dot-approved"></span> Đã duyệt
            <span class="count">${totalApproved}</span>
        </a>
        <a href="?action=list&status=REJECTED" class="stat-chip">
            <span class="dot dot-rejected"></span> Bị từ chối
            <span class="count">${totalRejected}</span>
        </a>
        <a href="?action=list&status=ARCHIVED" class="stat-chip">
            <span class="dot dot-archived"></span> Vô hiệu hóa
            <span class="count">${totalArchived}</span>
        </a>
    </div>

    <!-- Filter -->
    <div class="filter-bar">
        <form action="${pageContext.request.contextPath}/admin/knowledge-article" method="get" class="row g-2 align-items-end">
            <input type="hidden" name="action" value="list">
            <div class="col-md-5">
                <label class="form-label small fw-semibold mb-1">Tìm kiếm</label>
                <input type="text" name="keyword" class="form-control form-control-sm"
                       placeholder="Tiêu đề hoặc số bài viết..." value="${keyword}">
            </div>
            <div class="col-md-3">
                <label class="form-label small fw-semibold mb-1">Trạng thái</label>
                <select name="status" class="form-select form-select-sm">
                    <option value="ALL"      ${empty statusFilter || statusFilter eq 'ALL'      ? 'selected' : ''}>Tất cả</option>
                    <option value="PENDING"  ${statusFilter eq 'PENDING'  ? 'selected' : ''}>Chờ duyệt</option>
                    <option value="APPROVED" ${statusFilter eq 'APPROVED' ? 'selected' : ''}>Đã duyệt</option>
                    <option value="REJECTED" ${statusFilter eq 'REJECTED' ? 'selected' : ''}>Bị từ chối</option>
                    <option value="ARCHIVED" ${statusFilter eq 'ARCHIVED' ? 'selected' : ''}>Vô hiệu hóa</option>
                </select>
            </div>
            <div class="col-md-4 d-flex gap-2 align-items-end">
                <button type="submit" class="btn btn-primary btn-sm"><i class="bi bi-search"></i> Tìm kiếm</button>
                <a href="${pageContext.request.contextPath}/admin/knowledge-article?action=list"
                   class="btn btn-outline-secondary btn-sm"><i class="bi bi-x-circle"></i> Xóa bộ lọc</a>
            </div>
        </form>
    </div>

    <!-- Bulk form ẩn -->
    <form id="bulkForm" action="${pageContext.request.contextPath}/admin/knowledge-article" method="post" style="display:none;">
        <input type="hidden" name="action" id="bulkActionType" value="">
    </form>

    <!-- Table -->
    <div class="table-responsive">
        <table class="table table-hover table-bordered align-middle mt-2">
            <thead>
                <tr>
                    <th style="width:40px;">
                        <input type="checkbox" id="selectAll" class="form-check-input" onclick="toggleAll(this)">
                    </th>
                    <th>ID</th>
                    <th>Số bài viết</th>
                    <th>Tiêu đề</th>
                    <th>Tác giả</th>
                    <th>Trạng thái</th>
                    <th>Ngày cập nhật</th>
                    <th style="width:240px;">Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="art" items="${articles}">
                    <tr>
                        <td><input type="checkbox" name="selectedIds" value="${art.articleId}" class="rowCheckbox form-check-input"></td>
                        <td>${art.articleId}</td>
                        <td><code>${art.articleNumber}</code></td>
                        <td class="title-cell" title="${art.title}">${art.title}</td>
                        <td>${not empty art.authorName ? art.authorName : art.authorId}</td>
                        <td>
                            <c:choose>
                                <c:when test="${art.status eq 'PENDING'}">
                                    <span class="status-badge badge-pending">CHỜ DUYỆT</span>
                                </c:when>
                                <c:when test="${art.status eq 'APPROVED'}">
                                    <span class="status-badge badge-approved">ĐÃ DUYỆT</span>
                                </c:when>
                                <c:when test="${art.status eq 'REJECTED'}">
                                    <span class="status-badge badge-rejected">BỊ TỪ CHỐI</span>
                                </c:when>
                                <c:when test="${art.status eq 'ARCHIVED'}">
                                    <span class="status-badge badge-archived">VÔ HIỆU HÓA</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="status-badge" style="background:#e2e3e5;">${art.status}</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td><small class="text-muted">${art.updatedAt}</small></td>
                        <td>
                            <div class="d-flex gap-1 flex-wrap">

                                <!-- Xem -->
                                <a href="${pageContext.request.contextPath}/admin/knowledge-article?action=detail&id=${art.articleId}"
                                   class="btn-view btn"><i class="bi bi-eye"></i> Xem</a>

                                <!-- PENDING: Duyệt + Từ chối -->
                                <c:if test="${art.status eq 'PENDING'}">
                                    <form action="${pageContext.request.contextPath}/admin/knowledge-article" method="post" class="m-0">
                                        <input type="hidden" name="action" value="approve">
                                        <input type="hidden" name="id"     value="${art.articleId}">
                                        <button type="submit" class="btn-approve btn"
                                                onclick="return confirm('Duyệt bài viết này?');">
                                            <i class="bi bi-check-lg"></i> Duyệt
                                        </button>
                                    </form>
                                    <button type="button" class="btn-reject btn"
                                            onclick="openRejectModal(${art.articleId})">
                                        <i class="bi bi-x-lg"></i> Từ chối
                                    </button>
                                </c:if>

                                <!-- APPROVED: Vô hiệu hóa → ARCHIVED -->
                                <c:if test="${art.status eq 'APPROVED'}">
                                    <form action="${pageContext.request.contextPath}/admin/knowledge-article" method="post" class="m-0">
                                        <input type="hidden" name="action" value="toggle">
                                        <input type="hidden" name="id"     value="${art.articleId}">
                                        <input type="hidden" name="status" value="ARCHIVED">
                                        <button type="submit" class="btn-deactivate btn"
                                                onclick="return confirm('Vô hiệu hóa bài viết này?');">
                                            <i class="bi bi-archive"></i> Vô hiệu hóa
                                        </button>
                                    </form>
                                </c:if>

                                <!-- ARCHIVED: Kích hoạt lại → APPROVED -->
                                <c:if test="${art.status eq 'ARCHIVED'}">
                                    <form action="${pageContext.request.contextPath}/admin/knowledge-article" method="post" class="m-0">
                                        <input type="hidden" name="action" value="toggle">
                                        <input type="hidden" name="id"     value="${art.articleId}">
                                        <input type="hidden" name="status" value="APPROVED">
                                        <button type="submit" class="btn-activate btn"
                                                onclick="return confirm('Kích hoạt lại bài viết này?');">
                                            <i class="bi bi-play-circle"></i> Kích hoạt
                                        </button>
                                    </form>
                                </c:if>

                                <!-- Xóa: PENDING hoặc REJECTED -->
                                <c:if test="${art.status eq 'PENDING' || art.status eq 'REJECTED'}">
                                    <form action="${pageContext.request.contextPath}/admin/knowledge-article" method="post" class="m-0">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id"     value="${art.articleId}">
                                        <button type="submit" class="btn btn-outline-danger btn-sm"
                                                onclick="return confirm('Xóa bài viết này?');">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </form>
                                </c:if>

                            </div>
                        </td>
                    </tr>
                </c:forEach>

                <c:if test="${empty articles}">
                    <tr><td colspan="8">
                        <div class="empty-state">
                            <i class="bi bi-inbox"></i>
                            Không có bài viết nào phù hợp.
                        </div>
                    </td></tr>
                </c:if>
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <c:if test="${totalPages > 1}">
        <nav class="mt-3">
            <ul class="pagination justify-content-center">
                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                    <a class="page-link" href="?action=list&keyword=${keyword}&status=${statusFilter}&page=${currentPage - 1}">Trước</a>
                </li>
                <c:forEach begin="1" end="${totalPages}" var="i">
                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                        <a class="page-link" href="?action=list&keyword=${keyword}&status=${statusFilter}&page=${i}">${i}</a>
                    </li>
                </c:forEach>
                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                    <a class="page-link" href="?action=list&keyword=${keyword}&status=${statusFilter}&page=${currentPage + 1}">Sau</a>
                </li>
            </ul>
        </nav>
    </c:if>
</div>

<!-- Modal từ chối -->
<div class="modal fade" id="rejectModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="bi bi-x-circle me-2"></i>Từ chối bài viết</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/knowledge-article" method="post">
                <input type="hidden" name="action" value="reject">
                <input type="hidden" name="id"     id="rejectArticleId" value="">
                <div class="modal-body">
                    <label class="form-label fw-semibold">Lý do từ chối <span class="text-danger">*</span></label>
                    <textarea name="rejectionReason" class="form-control" rows="4"
                              placeholder="Nhập lý do từ chối để tác giả chỉnh sửa lại..." required></textarea>
                    <div class="form-text text-muted mt-1">Lý do sẽ được hiển thị cho tác giả khi xem lại bài viết.</div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-danger">
                        <i class="bi bi-x-circle"></i> Xác nhận từ chối
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    function toggleAll(source) {
        document.querySelectorAll('.rowCheckbox').forEach(cb => cb.checked = source.checked);
    }

    function openRejectModal(articleId) {
        document.getElementById('rejectArticleId').value = articleId;
        new bootstrap.Modal(document.getElementById('rejectModal')).show();
    }

    function submitBulkAction(actionType) {
        const checked = document.querySelectorAll('.rowCheckbox:checked');
        if (checked.length === 0) { alert('Vui lòng chọn ít nhất một bài viết.'); return; }

        const messages = {
            bulkDelete:  'Xóa ' + checked.length + ' bài viết đã chọn?',
            bulkReview:  'Duyệt ' + checked.length + ' bài viết đã chọn?',
            bulkArchive: 'Vô hiệu hóa ' + checked.length + ' bài viết đã chọn?'
        };
        if (!confirm(messages[actionType] || 'Thực hiện thao tác?')) return;

        const form = document.getElementById('bulkForm');
        form.querySelectorAll('input[name="selectedIds"]').forEach(el => el.remove());
        checked.forEach(cb => {
            const inp = document.createElement('input');
            inp.type = 'hidden'; inp.name = 'selectedIds'; inp.value = cb.value;
            form.appendChild(inp);
        });
        document.getElementById('bulkActionType').value = actionType;
        form.submit();
    }
</script>

<jsp:include page="/includes/footer.jsp" />
