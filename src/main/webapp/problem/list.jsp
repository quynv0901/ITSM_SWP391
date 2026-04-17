<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/includes/header.jsp" />

<div class="container-fluid bg-white p-4 rounded shadow-sm">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="h4 text-primary m-0">Danh sách phiếu vấn đề</h2>
        <div class="d-flex gap-2">
            <c:if test="${sessionScope.user.roleId == 3 || sessionScope.user.roleId == 5}">
                <button type="button" class="btn btn-danger" onclick="submitBulkAction('bulkDelete')">
                    <i class="bi bi-trash"></i> Xóa đã chọn
                </button>
            </c:if>
            <c:if test="${sessionScope.user.roleId == 3 || sessionScope.user.roleId == 5}">
                <a href="${pageContext.request.contextPath}/problem?action=add" class="btn btn-primary"
                   style="white-space:nowrap;">
                    <i class="bi bi-plus-circle"></i> Tạo phiếu vấn đề
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

    <form action="${pageContext.request.contextPath}/problem" method="get"
          class="bg-light p-3 rounded mb-4 border d-flex gap-3 align-items-center">
        <input type="hidden" name="action" value="list">
        <div class="flex-grow-1">
            <input type="text" class="form-control" name="keyword"
                   placeholder="Tìm theo tên hoặc mã phiếu..." value="${keyword}">
        </div>
        <div style="width: 250px;">
            <select class="form-select" name="status">
                <option value="ALL"         ${statusFilter=='ALL'         ? 'selected' : ''}>Tất cả trạng thái</option>
                <option value="NEW"         ${statusFilter=='NEW'         ? 'selected' : ''}>Mới</option>
                <option value="IN_PROGRESS" ${statusFilter=='IN_PROGRESS' ? 'selected' : ''}>Đang xử lý</option>
                <option value="RESOLVED"    ${statusFilter=='RESOLVED'    ? 'selected' : ''}>Đã giải quyết</option>
                <option value="CLOSED"      ${statusFilter=='CLOSED'      ? 'selected' : ''}>Đã đóng</option>
                <option value="CANCELLED"   ${statusFilter=='CANCELLED'   ? 'selected' : ''}>Đã hủy</option>
            </select>
        </div>
        <button type="submit" class="btn btn-primary"><i class="bi bi-search"></i> Tìm kiếm</button>
        <a href="${pageContext.request.contextPath}/problem?action=list"
           class="btn btn-outline-secondary">Xóa bộ lọc</a>
    </form>

    <form id="bulkForm" action="${pageContext.request.contextPath}/problem" method="post" style="display:none;">
        <input type="hidden" name="action" id="bulkActionType" value="bulkDelete">
    </form>

    <div class="table-responsive">
        <table class="table table-hover table-bordered align-middle mt-3">
            <thead class="table-light">
                <tr>
                    <th style="width: 40px;">
                        <input class="form-check-input" type="checkbox" id="selectAll" onclick="toggleAll(this)">
                    </th>
                    <th>ID</th>
                    <th>Số phiếu</th>
                    <th>Tiêu đề</th>
                    <th>Trạng thái</th>
                    <th>Ngày tạo</th>
                    <th>Thao tác</th>
                </tr>
            </thead>
            <tbody id="problemsTableBody">
                <c:forEach var="problem" items="${problems}">
                    <tr class="problem-row">
                        <td>
                            <c:choose>
                                <c:when test="${problem.status eq 'NEW' && problem.assignedTo == null}">
                                    <input class="form-check-input rowCheckbox" type="checkbox"
                                           name="selectedIds" value="${problem.ticketId}">
                                </c:when>
                                <c:otherwise>
                                    <input class="form-check-input" type="checkbox" disabled>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>${problem.ticketId}</td>
                        <td>${problem.ticketNumber}</td>
                        <td>${problem.title}</td>
                        <td>
                            <c:choose>
                                <c:when test="${problem.status == 'NEW'}">
                                    <span class="badge bg-info text-dark">MỚI</span>
                                </c:when>
                                <c:when test="${problem.status == 'IN_PROGRESS'}">
                                    <span class="badge bg-primary">ĐANG XỬ LÝ</span>
                                </c:when>
                                <c:when test="${problem.status == 'RESOLVED'}">
                                    <span class="badge bg-success">ĐÃ GIẢI QUYẾT</span>
                                </c:when>
                                <c:when test="${problem.status == 'CANCELLED'}">
                                    <span class="badge bg-danger">ĐÃ HỦY</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-dark">${problem.status}</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>${problem.createdAt}</td>
                        <td class="d-flex gap-1">
                            <a href="${pageContext.request.contextPath}/problem?action=detail&id=${problem.ticketId}"
                               class="btn btn-info btn-sm text-white">
                                <i class="bi bi-eye"></i> Xem
                            </a>
                            <c:if test="${sessionScope.user.roleId == 3 || sessionScope.user.roleId == 5}">
                                <c:choose>
                                    <c:when test="${problem.status eq 'NEW' && (problem.assignedTo == null || problem.assignedTo == 0) && (problem.reportedBy == sessionScope.user.userId || sessionScope.user.roleId == 3 || sessionScope.user.roleId == 10)}">
                                        <form action="${pageContext.request.contextPath}/problem?action=delete"
                                              method="post" class="m-0">
                                            <input type="hidden" name="id" value="${problem.ticketId}">
                                            <button type="submit" class="btn btn-danger btn-sm"
                                                onclick="return confirm('Bạn có chắc muốn xóa phiếu vấn đề này không?');">
                                                <i class="bi bi-trash"></i> Xóa
                                            </button>
                                        </form>
                                    </c:when>
                                    <c:otherwise>
                                        <button type="button" class="btn btn-danger btn-sm" disabled
                                            title="Chỉ phiếu MỚI chưa phân công và do bạn tạo mới có thể xóa.">
                                            <i class="bi bi-trash"></i> Xóa
                                        </button>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty problems}">
                    <tr>
                        <td colspan="7" class="text-center text-muted fst-italic py-4">
                            Không tìm thấy phiếu vấn đề nào.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>

        <c:if test="${totalPages > 1}">
            <nav aria-label="Phân trang" class="mt-3">
                <ul class="pagination justify-content-center">
                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                        <a class="page-link"
                           href="?action=list&keyword=${keyword}&status=${statusFilter}&page=${currentPage - 1}">Trước</a>
                    </li>
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <li class="page-item ${currentPage == i ? 'active' : ''}">
                            <a class="page-link"
                               href="?action=list&keyword=${keyword}&status=${statusFilter}&page=${i}">${i}</a>
                        </li>
                    </c:forEach>
                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                        <a class="page-link"
                           href="?action=list&keyword=${keyword}&status=${statusFilter}&page=${currentPage + 1}">Sau</a>
                    </li>
                </ul>
            </nav>
        </c:if>
    </div>
</div>

<script>
    function toggleAll(source) {
        const checkboxes = document.getElementsByClassName('rowCheckbox');
        for (let i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = source.checked;
        }
    }

    function submitBulkAction(actionType) {
        const checkboxes = document.querySelectorAll('.rowCheckbox:checked');
        if (checkboxes.length === 0) {
            alert('Vui lòng chọn ít nhất một phiếu để xóa.');
            return;
        }
        if (confirm('Bạn có chắc muốn xóa các phiếu đã chọn?\nLưu ý: Đảm bảo các mục đã chọn ở trạng thái hợp lệ.')) {
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
            bulkForm.submit();
        }
    }
</script>

<jsp:include page="/includes/footer.jsp" />