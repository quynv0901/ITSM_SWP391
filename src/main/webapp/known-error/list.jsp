<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<jsp:include page="/includes/header.jsp">
    <jsp:param name="pageTitle" value="Cơ sở dữ liệu lỗi đã biết" />
</jsp:include>

<div class="container-fluid bg-white p-4 rounded shadow-sm">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="h4 text-primary m-0">Cơ sở dữ liệu lỗi đã xác định </h2>
        <div class="d-flex gap-2">
            <c:if test="${sessionScope.user.roleId == 10 || sessionScope.user.roleId == 3}">
                <button type="button" class="btn btn-danger" onclick="submitBulkAction('bulkDelete')">
                    <i class="bi bi-trash"></i> Xóa hàng loạt
                </button>
                <button type="button" class="btn btn-primary" onclick="submitBulkAction('bulkReview', 'APPROVED')">
                    <i class="bi bi-shield-check"></i> Duyệt hàng loạt
                </button>
                <button type="button" class="btn btn-warning text-dark" onclick="submitBulkAction('bulkToggleStatus', 'INACTIVE')">
                    <i class="bi bi-pause-circle"></i> Vô hiệu hóa hàng loạt
                </button>
                <button type="button" class="btn btn-success" onclick="submitBulkAction('bulkToggleStatus', 'APPROVED')">
                    <i class="bi bi-play-circle"></i> Kích hoạt hàng loạt
                </button>
            </c:if>
            <%-- Chỉ Technical Expert và Manager (+ Admin) mới được tạo bài --%>
            <c:if test="${sessionScope.user.roleId == 5 || sessionScope.user.roleId == 3 || sessionScope.user.roleId == 10}">
                <a href="${pageContext.request.contextPath}/known-error?action=add" class="btn btn-primary">
                    <i class="bi bi-plus-circle"></i> Tạo bài viết mới
                </a>
            </c:if>
        </div>
    </div>

    <c:if test="${not empty sessionScope.message}">
        <div class="alert alert-info alert-dismissible fade show" role="alert">
            <i class="bi bi-info-circle-fill me-2"></i> ${sessionScope.message}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="message" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.errorMsg}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i> ${sessionScope.errorMsg}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="errorMsg" scope="session"/>
    </c:if>

    <form action="${pageContext.request.contextPath}/known-error" method="get"
        class="row g-3 mb-4 bg-light p-3 rounded border mx-0">
        <input type="hidden" name="action" value="list">
        <div class="col-md-5">
            <input type="text" name="searchQuery" class="form-control"
                   placeholder="Tìm theo tiêu đề hoặc số bài viết..."
                   value="${searchQuery}">
        </div>
        <div class="col-md-3">
            <select name="statusFilter" class="form-select">
                <option value="ALL" ${empty statusFilter || statusFilter eq 'ALL' ? 'selected' : ''}>Tất cả trạng thái</option>
                <option value="APPROVED" ${statusFilter eq 'APPROVED' ? 'selected' : ''}>ĐÃ DUYỆT</option>
                <option value="PENDING"  ${statusFilter eq 'PENDING'  ? 'selected' : ''}>CHỜ DUYỆT</option>
                <option value="REJECTED" ${statusFilter eq 'REJECTED' ? 'selected' : ''}>BỊ TỪ CHỐI</option>
                <option value="INACTIVE" ${statusFilter eq 'INACTIVE' ? 'selected' : ''}>KHÔNG HOẠT ĐỘNG</option>
            </select>
        </div>
        <div class="col-md-4 d-flex gap-2">
            <button type="submit" class="btn btn-primary"><i class="bi bi-search"></i> Tìm kiếm</button>
            <a href="${pageContext.request.contextPath}/known-error?action=list"
               class="btn btn-outline-secondary"><i class="bi bi-x-circle"></i> Xóa bộ lọc</a>
        </div>
    </form>

    <%-- Hidden form for bulk POST submission --%>
    <form id="bulkForm" action="${pageContext.request.contextPath}/known-error" method="post" style="display:none;">
        <input type="hidden" name="action"   id="bulkActionType" value="">
        <input type="hidden" name="status"   id="bulkStatus"     value="">
        <input type="hidden" name="toggleTo" id="bulkToggleTo"   value="">
    </form>

    <%-- Bootstrap confirmation modal (replaces native confirm() which gets blocked by browsers) --%>
    <div class="modal fade" id="bulkConfirmModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="bi bi-exclamation-triangle-fill text-warning me-2"></i>Xác nhận thao tác</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body" id="bulkConfirmMsg">Bạn có chắc muốn thực hiện thao tác này?</div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="button" class="btn btn-danger" id="bulkConfirmOk">Xác nhận</button>
                </div>
            </div>
        </div>
    </div>

    <div class="table-responsive">
        <table class="table table-hover table-bordered align-middle mt-3">
            <thead class="table-light">
                <tr>
                    <th style="width: 40px;">
                        <input type="checkbox" id="selectAll" class="form-check-input"
                               onclick="toggleAll(this)">
                    </th>
                    <th>ID</th>
                    <th>Số bài viết</th>
                    <th>Tiêu đề</th>
                    <th>Trạng thái</th>
                    <th>Tác giả</th>
                    <th>Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="error" items="${knownErrors}">
                    <tr>
                        <td>
                            <input type="checkbox" name="selectedIds" value="${error.articleId}"
                                class="rowCheckbox form-check-input"
                                ${(sessionScope.user.roleId != 10 and sessionScope.user.roleId != 3) ? 'disabled' : ''}>
                        </td>
                        <td>${error.articleId}</td>
                        <td>${error.articleNumber}</td>
                        <td>${error.title}</td>
                        <td>
                            <c:choose>
                                <c:when test="${error.status eq 'APPROVED'}"><span class="badge bg-success">ĐÃ DUYỆT</span></c:when>
                                <c:when test="${error.status eq 'PENDING'}"><span class="badge bg-warning text-dark">CHỜ DUYỆT</span></c:when>
                                <c:when test="${error.status eq 'REJECTED'}"><span class="badge bg-danger">BỊ TỪ CHỐI</span></c:when>
                                <c:when test="${error.status eq 'INACTIVE'}"><span class="badge bg-secondary">KHÔNG HOẠT ĐỘNG</span></c:when>
                                <c:otherwise><span class="badge bg-primary">${error.status}</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td>${not empty error.authorName ? error.authorName : error.authorId}</td>
                        <td class="d-flex gap-1">
                            <a href="${pageContext.request.contextPath}/known-error?action=detail&id=${error.articleId}"
                               class="btn btn-info btn-sm text-white">
                                <i class="bi bi-eye"></i> Xem
                            </a>

                            <c:if test="${error.status eq 'PENDING' || error.status eq 'REJECTED'}">
                                <c:if test="${error.authorId == sessionScope.user.userId || sessionScope.user.roleId == 10 || sessionScope.user.roleId == 3}">
                                    <form action="${pageContext.request.contextPath}/known-error?action=delete"
                                          method="post" class="m-0">
                                        <input type="hidden" name="id" value="${error.articleId}">
                                        <button type="submit" class="btn btn-danger btn-sm"
                                            onclick="return confirm('Bạn có chắc muốn xóa bài viết này không?');">
                                            <i class="bi bi-trash"></i> Xóa
                                        </button>
                                    </form>
                                </c:if>
                            </c:if>

                            <c:if test="${error.status eq 'APPROVED' || error.status eq 'INACTIVE'}">
                                <c:if test="${sessionScope.user.roleId == 10 || sessionScope.user.roleId == 3}">
                                    <form action="${pageContext.request.contextPath}/known-error?action=toggleStatus"
                                          method="post" class="m-0">
                                        <input type="hidden" name="id" value="${error.articleId}">
                                        <input type="hidden" name="currentStatus" value="${error.status}">
                                        <button type="submit"
                                            class="btn ${error.status eq 'APPROVED' ? 'btn-secondary' : 'btn-success'} btn-sm">
                                            <i class="bi ${error.status eq 'APPROVED' ? 'bi-pause-circle' : 'bi-play-circle'}"></i>
                                            ${error.status eq 'APPROVED' ? 'Vô hiệu hóa' : 'Kích hoạt'}
                                        </button>
                                    </form>
                                </c:if>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty knownErrors}">
                    <tr>
                        <td colspan="7" class="text-center text-muted fst-italic py-4">
                            Không tìm thấy lỗi đã biết nào.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>

        <c:if test="${totalPages > 1}">
            <div class="card-footer bg-white border-top-0 py-3 d-flex justify-content-between align-items-center px-4">
                <span class="text-muted small">Tổng <strong>${totalRecords}</strong> mục</span>
                <nav>
                    <ul class="pagination pagination-sm mb-0">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="?action=list&page=${currentPage - 1}&searchQuery=${searchQuery}&statusFilter=${statusFilter}">‹</a>
                        </li>
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                <a class="page-link" href="?action=list&page=${i}&searchQuery=${searchQuery}&statusFilter=${statusFilter}">${i}</a>
                            </li>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="?action=list&page=${currentPage + 1}&searchQuery=${searchQuery}&statusFilter=${statusFilter}">›</a>
                        </li>
                    </ul>
                </nav>
            </div>
        </c:if>
    </div>
</div>

<script>
    function toggleAll(source) {
        const checkboxes = document.getElementsByClassName('rowCheckbox');
        for (let i = 0; i < checkboxes.length; i++) {
            if (!checkboxes[i].disabled) checkboxes[i].checked = source.checked;
        }
    }

    let pendingBulkAction = null;
    let pendingExtraParam = null;

    function submitBulkAction(actionType, extraParam) {
        const checkboxes = document.querySelectorAll('.rowCheckbox:checked');
        if (checkboxes.length === 0) {
            alert('Vui lòng chọn ít nhất một mục.');
            return;
        }

        pendingBulkAction = actionType;
        pendingExtraParam = extraParam;

        let msg = 'Bạn có chắc muốn thực hiện thao tác này với <strong>' + checkboxes.length + '</strong> mục đã chọn?';
        if (actionType === 'bulkDelete')
            msg = 'Bạn có chắc muốn <strong>xóa vĩnh viễn</strong> ' + checkboxes.length + ' mục đã chọn?<br><small class="text-muted">Chỉ xóa được bài PENDING hoặc REJECTED.</small>';
        else if (actionType === 'bulkReview' && extraParam === 'APPROVED')
            msg = 'Bạn có chắc muốn <strong>duyệt hàng loạt</strong> ' + checkboxes.length + ' mục đã chọn?<br><small class="text-muted">Chỉ duyệt được bài PENDING.</small>';
        else if (actionType === 'bulkToggleStatus' && extraParam === 'INACTIVE')
            msg = 'Bạn có chắc muốn <strong>vô hiệu hóa</strong> ' + checkboxes.length + ' mục đã chọn?<br><small class="text-muted">Chỉ áp dụng cho bài APPROVED.</small>';
        else if (actionType === 'bulkToggleStatus' && extraParam === 'APPROVED')
            msg = 'Bạn có chắc muốn <strong>kích hoạt lại</strong> ' + checkboxes.length + ' mục đã chọn?<br><small class="text-muted">Chỉ áp dụng cho bài INACTIVE.</small>';

        document.getElementById('bulkConfirmMsg').innerHTML = msg;
        const modal = new bootstrap.Modal(document.getElementById('bulkConfirmModal'));
        modal.show();
    }

    document.getElementById('bulkConfirmOk').addEventListener('click', function () {
        const checkboxes = document.querySelectorAll('.rowCheckbox:checked');
        const bulkForm   = document.getElementById('bulkForm');

        // Remove previously appended selectedIds
        bulkForm.querySelectorAll('input[name="selectedIds"]').forEach(el => el.remove());

        // Append currently selected IDs
        checkboxes.forEach(cb => {
            const input = document.createElement('input');
            input.type  = 'hidden';
            input.name  = 'selectedIds';
            input.value = cb.value;
            bulkForm.appendChild(input);
        });

        document.getElementById('bulkActionType').value = pendingBulkAction;
        document.getElementById('bulkStatus').value     = '';
        document.getElementById('bulkToggleTo').value   = '';

        if (pendingBulkAction === 'bulkReview') {
            document.getElementById('bulkStatus').value   = pendingExtraParam;
        } else if (pendingBulkAction === 'bulkToggleStatus') {
            document.getElementById('bulkToggleTo').value = pendingExtraParam;
        }

        bootstrap.Modal.getInstance(document.getElementById('bulkConfirmModal')).hide();
        bulkForm.submit();
    });
</script>

<jsp:include page="/includes/footer.jsp" />
