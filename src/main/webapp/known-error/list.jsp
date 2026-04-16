<jsp:include page="/includes/header.jsp" />
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

    <div class="container-fluid bg-white p-4 rounded shadow-sm">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="h4 text-primary m-0">Known Error Database (KEDB)</h2>
            <div class="d-flex gap-2">
                <c:if test="${sessionScope.user.roleId == 10 || sessionScope.user.roleId == 3}">
                    <button type="button" class="btn btn-danger" onclick="submitBulkAction('bulkDelete')">
                        <i class="bi bi-trash"></i> Bulk Delete
                    </button>
                    <button type="button" class="btn btn-primary" onclick="submitBulkAction('bulkReview', 'APPROVED')">
                        <i class="bi bi-shield-check"></i> Bulk Approve
                    </button>
                    <button type="button" class="btn btn-warning text-dark" onclick="submitBulkAction('bulkToggleStatus', 'INACTIVE')">
                        <i class="bi bi-pause-circle"></i> Bulk Disable
                    </button>
                    <button type="button" class="btn btn-success" onclick="submitBulkAction('bulkToggleStatus', 'APPROVED')">
                        <i class="bi bi-play-circle"></i> Bulk Enable
                    </button>
                </c:if>
                <a href="${pageContext.request.contextPath}/known-error?action=add" class="btn btn-primary">
                    <i class="bi bi-plus-circle"></i> Create New Article
                </a>
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
                <input type="text" name="searchQuery" class="form-control" placeholder="Search by Title or Number..."
                    value="${searchQuery}">
            </div>
            <div class="col-md-3">
                <select name="statusFilter" class="form-select">
                    <option value="ALL" ${empty statusFilter || statusFilter eq 'ALL' ? 'selected' : '' }>All Statuses
                    </option>
                    <option value="APPROVED" ${statusFilter eq 'APPROVED' ? 'selected' : '' }>APPROVED</option>
                    <option value="PENDING" ${statusFilter eq 'PENDING' ? 'selected' : '' }>PENDING</option>
                    <option value="REJECTED" ${statusFilter eq 'REJECTED' ? 'selected' : '' }>REJECTED</option>
                    <option value="INACTIVE" ${statusFilter eq 'INACTIVE' ? 'selected' : '' }>INACTIVE</option>
                </select>
            </div>
            <div class="col-md-4 d-flex gap-2">
                <button type="submit" class="btn btn-primary"><i class="bi bi-search"></i> Search</button>
                <a href="${pageContext.request.contextPath}/known-error?action=list"
                    class="btn btn-outline-secondary"><i class="bi bi-x-circle"></i> Clear</a>
            </div>
        </form>

        <form id="bulkForm" action="${pageContext.request.contextPath}/known-error" method="post" style="display:none;">
            <input type="hidden" name="action" id="bulkActionType" value="">
            <input type="hidden" name="status" id="bulkStatus" value="">
            <input type="hidden" name="toggleTo" id="bulkToggleTo" value="">
        </form>

        <div class="table-responsive">
                <table class="table table-hover table-bordered align-middle mt-3">
                    <thead class="table-light">
                        <tr>
                            <th style="width: 40px;"><input type="checkbox" id="selectAll" class="form-check-input"
                                    onclick="toggleAll(this)"></th>
                            <th>ID</th>
                            <th>Article Number</th>
                            <th>Title</th>
                            <th>Status</th>
                            <th>Author</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="error" items="${knownErrors}">
                            <tr>
                                <td>
                                    <input type="checkbox" name="selectedIds" value="${error.articleId}"
                                        class="rowCheckbox form-check-input" ${ (sessionScope.user.roleId !=10 and
                                        sessionScope.user.roleId !=3) ? 'disabled' : '' }>
                                </td>
                                <td>${error.articleId}</td>
                                <td>${error.articleNumber}</td>
                                <td>${error.title}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${error.status eq 'APPROVED'}"><span
                                                class="badge bg-success">APPROVED</span></c:when>
                                        <c:when test="${error.status eq 'PENDING'}"><span
                                                class="badge bg-warning text-dark">PENDING</span></c:when>
                                        <c:when test="${error.status eq 'REJECTED'}"><span
                                                class="badge bg-danger">REJECTED</span></c:when>
                                        <c:when test="${error.status eq 'INACTIVE'}"><span
                                                class="badge bg-secondary">INACTIVE</span></c:when>
                                        <c:otherwise><span class="badge bg-primary">${error.status}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${not empty error.authorName ? error.authorName : error.authorId}</td>
                                <td class="d-flex gap-1">
                                    <a href="${pageContext.request.contextPath}/known-error?action=detail&id=${error.articleId}"
                                        class="btn btn-info btn-sm text-white">
                                        <i class="bi bi-eye"></i> View
                                    </a>

                                    <c:if test="${error.status eq 'PENDING' || error.status eq 'REJECTED'}">
                                        <c:if test="${error.authorId == sessionScope.user.userId || sessionScope.user.roleId == 10 || sessionScope.user.roleId == 3}">
                                            <form action="${pageContext.request.contextPath}/known-error?action=delete"
                                                method="post" class="m-0">
                                                <input type="hidden" name="id" value="${error.articleId}">
                                                <button type="submit" class="btn btn-danger btn-sm"
                                                    onclick="return confirm('Are you sure you want to delete this known error?');">
                                                    <i class="bi bi-trash"></i> Delete
                                                </button>
                                            </form>
                                        </c:if>
                                    </c:if>

                                    <c:if test="${error.status eq 'APPROVED' || error.status eq 'INACTIVE'}">
                                        <c:if test="${sessionScope.user.roleId == 10 || sessionScope.user.roleId == 3}">
                                            <form
                                                action="${pageContext.request.contextPath}/known-error?action=toggleStatus"
                                                method="post" class="m-0">
                                                <input type="hidden" name="id" value="${error.articleId}">
                                                <input type="hidden" name="currentStatus" value="${error.status}">
                                                <button type="submit"
                                                    class="btn ${error.status eq 'APPROVED' ? 'btn-secondary' : 'btn-success'} btn-sm">
                                                    <i
                                                        class="bi ${error.status eq 'APPROVED' ? 'bi-pause-circle' : 'bi-play-circle'}"></i>
                                                    ${error.status eq 'APPROVED' ? 'Disable' : 'Enable'}
                                                </button>
                                            </form>
                                        </c:if>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty knownErrors}">
                            <tr>
                                <td colspan="7" class="text-center text-muted fst-italic py-4">No Known Errors found.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>

                <c:if test="${totalPages > 1}">
                    <nav aria-label="Page navigation" class="mt-3">
                        <ul class="pagination justify-content-center">
                            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                <a class="page-link"
                                    href="?action=list&searchQuery=${searchQuery}&statusFilter=${statusFilter}&page=${currentPage - 1}">Previous</a>
                            </li>
                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <li class="page-item ${currentPage == i ? 'active' : ''}">
                                    <a class="page-link"
                                        href="?action=list&searchQuery=${searchQuery}&statusFilter=${statusFilter}&page=${i}">${i}</a>
                                </li>
                            </c:forEach>
                            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                <a class="page-link"
                                    href="?action=list&searchQuery=${searchQuery}&statusFilter=${statusFilter}&page=${currentPage + 1}">Next</a>
                            </li>
                        </ul>
                    </nav>
                </c:if>
            </div>
        </div>

    <script>
        function toggleAll(source) {
            checkboxes = document.getElementsByClassName('rowCheckbox');
            for (var i = 0, n = checkboxes.length; i < n; i++) {
                if (!checkboxes[i].disabled) {
                    checkboxes[i].checked = source.checked;
                }
            }
        }

        function submitBulkAction(actionType, extraParam) {
            var checkboxes = document.querySelectorAll('.rowCheckbox:checked');
            if (checkboxes.length === 0) {
                alert('Please select at least one item.');
                return;
            }
            let msg = 'Are you sure you want to perform this action?';
            if (actionType === 'bulkDelete') msg = 'Are you sure you want to delete selected items?';
            else if (actionType === 'bulkReview' && extraParam === 'APPROVED') msg = 'Are you sure you want to approve the selected items?';
            else if (actionType === 'bulkToggleStatus') msg = 'Are you sure you want to change status to ' + extraParam + '?';

            if (confirm(msg + '\nWarning: Ensure the selected items are in a valid state.')) {
                const bulkForm = document.getElementById('bulkForm');
                bulkForm.querySelectorAll('input[name="selectedIds"]').forEach(el => el.remove());
                checkboxes.forEach(cb => {
                    const input = document.createElement('input');
                    input.type = 'hidden';
                    input.name = 'selectedIds';
                    input.value = cb.value;
                    bulkForm.appendChild(input);
                });
                
                document.getElementById('bulkActionType').value = actionType;

                if (actionType === 'bulkReview') {
                    document.getElementById('bulkStatus').value = extraParam;
                } else if (actionType === 'bulkToggleStatus') {
                    document.getElementById('bulkToggleTo').value = extraParam;
                }

                bulkForm.submit();
            }
        }
    </script>

    <jsp:include page="/includes/footer.jsp" />
