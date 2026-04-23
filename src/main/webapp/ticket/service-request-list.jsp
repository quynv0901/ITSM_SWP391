<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setLocale value="vi_VN" />
<jsp:include page="/includes/header.jsp" />

<c:set var="userRole" value="${sessionScope.user.roleId}" />

<div class="container-fluid bg-white p-4 rounded shadow-sm">

    <c:if test="${not empty param.msg}">
        <div class="alert alert-info alert-dismissible fade show" role="alert">
            <c:choose>
                <c:when test="${param.msg eq 'created'}">Tạo yêu cầu dịch vụ thành công.</c:when>
                <c:when test="${param.msg eq 'deleted'}">Xóa yêu cầu dịch vụ thành công.</c:when>
                <c:when test="${param.msg eq 'bulk_deleted'}">Đã xóa hàng loạt. Số lượng đã xóa: ${param.count}</c:when>
                <c:when test="${param.msg eq 'bulk_approved'}">Đã duyệt hàng loạt. Số lượng đã cập nhật: ${param.count}</c:when>
                <c:when test="${param.msg eq 'bulk_rejected'}">Đã từ chối hàng loạt. Số lượng đã cập nhật: ${param.count}</c:when>
                <c:when test="${param.msg eq 'not_found'}">Không tìm thấy yêu cầu dịch vụ.</c:when>
                <c:when test="${param.msg eq 'invalid_id'}">Mã yêu cầu không hợp lệ.</c:when>
                <c:otherwise>Thao tác đã hoàn tất.</c:otherwise>
            </c:choose>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
        <h2 class="h4 text-primary m-0">
            <i class="bi bi-ticket-detailed me-2"></i>Danh sách yêu cầu dịch vụ
        </h2>

        <c:if test="${userRole == 1}">
            <a href="${pageContext.request.contextPath}/service-request?action=createForm"
               class="btn btn-primary shadow-sm">
                <i class="bi bi-plus-circle me-1"></i> Tạo yêu cầu dịch vụ
            </a>
        </c:if>
    </div>

    <form action="${pageContext.request.contextPath}/service-request" method="get"
          class="row g-3 mb-4 bg-light p-3 rounded border mx-0">
        <input type="hidden" name="action" value="list">

        <div class="col-md-4">
            <input type="text" name="keyword" class="form-control"
                   placeholder="Tìm theo mã yêu cầu, tiêu đề, dịch vụ..."
                   value="${keyword}">
        </div>

        <div class="col-md-3">
            <select name="status" class="form-select">
                <option value="">-- Tất cả trạng thái --</option>
                <option value="NEW" ${status eq 'NEW' ? 'selected' : ''}>Mới</option>
                <option value="ASSIGNED" ${status eq 'ASSIGNED' ? 'selected' : ''}>Đã phân công</option>
                <option value="IN_PROGRESS" ${status eq 'IN_PROGRESS' ? 'selected' : ''}>Đang xử lý</option>
                <option value="PENDING" ${status eq 'PENDING' ? 'selected' : ''}>Đang chờ</option>
                <option value="RESOLVED" ${status eq 'RESOLVED' ? 'selected' : ''}>Đã xử lý</option>
                <option value="CLOSED" ${status eq 'CLOSED' ? 'selected' : ''}>Đã đóng</option>
                <option value="CANCELLED" ${status eq 'CANCELLED' ? 'selected' : ''}>Đã hủy</option>
            </select>
        </div>

        <div class="col-md-3">
            <select name="approvalStatus" class="form-select">
                <option value="">-- Tất cả trạng thái duyệt --</option>
                <option value="PENDING" ${approvalStatus eq 'PENDING' ? 'selected' : ''}>Chờ duyệt</option>
                <option value="APPROVED" ${approvalStatus eq 'APPROVED' ? 'selected' : ''}>Đã duyệt</option>
                <option value="REJECTED" ${approvalStatus eq 'REJECTED' ? 'selected' : ''}>Đã từ chối</option>
            </select>
        </div>

        <div class="col-md-2 d-flex gap-2">
            <button type="submit" class="btn btn-primary w-100">
                <i class="bi bi-search"></i>
            </button>
            <a href="${pageContext.request.contextPath}/service-request?action=list"
               class="btn btn-outline-secondary">
                <i class="bi bi-x-circle"></i>
            </a>
        </div>
    </form>

    <form id="bulkForm" method="post" accept-charset="UTF-8">
        <input type="hidden" name="action" id="bulkAction" value="">
        <input type="hidden" name="rejectionReason" id="bulkRejectionReason" value="">

        <div class="d-flex justify-content-end gap-2 mb-3 flex-wrap">
            <c:if test="${userRole == 1}">
                <button type="button" class="btn btn-danger btn-sm shadow-sm"
                        onclick="submitBulkDelete()">
                    <i class="bi bi-trash"></i> Xóa đã chọn
                </button>
            </c:if>

            <c:if test="${userRole == 3}">
                <button type="button" class="btn btn-success btn-sm shadow-sm"
                        onclick="submitBulkApprove()">
                    <i class="bi bi-check-circle"></i> Duyệt đã chọn
                </button>

                <button type="button" class="btn btn-outline-danger btn-sm shadow-sm"
                        onclick="submitBulkReject()">
                    <i class="bi bi-x-circle"></i> Từ chối đã chọn
                </button>
            </c:if>
        </div>

        <div class="table-responsive">
            <table class="table table-hover table-bordered align-middle">
                <thead class="table-light">
                    <tr>
                        <th style="width: 40px;" class="text-center">
                            <input type="checkbox" id="selectAll" class="form-check-input">
                        </th>
                        <th>Mã yêu cầu</th>
                        <th>Tiêu đề</th>
                        <th>Dịch vụ</th>
                        <th>Người yêu cầu</th>
                        <th>Người xử lý</th>
                        <th>Trạng thái</th>
                        <th>Duyệt</th>
                        <th>Ngày tạo</th>
                        <th class="text-center">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="sr" items="${requestList}">
                        <tr>
                            <td class="text-center">
                                <input type="checkbox" class="rowCheckbox form-check-input"
                                       name="ticketIds" value="${sr.ticketId}">
                            </td>

                            <td><strong>${sr.ticketNumber}</strong></td>
                            <td>${sr.title}</td>
                            <td>
                                <div class="fw-bold text-primary">${sr.serviceName}</div>
                                <small class="text-muted">${sr.serviceCode}</small>
                            </td>
                            <td>${sr.reportedByName}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty sr.assignedToName}">
                                        ${sr.assignedToName}
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted fst-italic">Chưa phân công</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <span class="badge
                                      ${sr.status eq 'NEW' ? 'bg-primary' :
                                        sr.status eq 'ASSIGNED' ? 'bg-info text-dark' :
                                        sr.status eq 'IN_PROGRESS' ? 'bg-warning text-dark' :
                                        sr.status eq 'RESOLVED' ? 'bg-success' :
                                        sr.status eq 'CLOSED' ? 'bg-dark' :
                                        sr.status eq 'CANCELLED' ? 'bg-secondary' : 'bg-light text-dark'}">
                                    <c:choose>
                                        <c:when test="${sr.status eq 'NEW'}">Mới</c:when>
                                        <c:when test="${sr.status eq 'ASSIGNED'}">Đã phân công</c:when>
                                        <c:when test="${sr.status eq 'IN_PROGRESS'}">Đang xử lý</c:when>
                                        <c:when test="${sr.status eq 'PENDING'}">Đang chờ</c:when>
                                        <c:when test="${sr.status eq 'RESOLVED'}">Đã xử lý</c:when>
                                        <c:when test="${sr.status eq 'CLOSED'}">Đã đóng</c:when>
                                        <c:when test="${sr.status eq 'CANCELLED'}">Đã hủy</c:when>
                                        <c:otherwise>${sr.status}</c:otherwise>
                                    </c:choose>
                                </span>
                            </td>
                            <td>
                                <span class="badge
                                      ${sr.approvalStatus eq 'APPROVED' ? 'bg-success' :
                                        sr.approvalStatus eq 'REJECTED' ? 'bg-danger' : 'bg-warning text-dark'}">
                                    <c:choose>
                                        <c:when test="${sr.approvalStatus eq 'PENDING'}">Chờ duyệt</c:when>
                                        <c:when test="${sr.approvalStatus eq 'APPROVED'}">Đã duyệt</c:when>
                                        <c:when test="${sr.approvalStatus eq 'REJECTED'}">Đã từ chối</c:when>
                                        <c:otherwise>${sr.approvalStatus}</c:otherwise>
                                    </c:choose>
                                </span>
                            </td>
                            <td>
                                <fmt:formatDate value="${sr.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                            </td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${sessionScope.user.roleId == 3 || sessionScope.user.roleId == 2}">
                                        <a href="${pageContext.request.contextPath}/service-request-manage?action=edit&id=${sr.ticketId}"
                                           class="btn btn-outline-primary btn-sm">
                                            <i class="bi bi-eye"></i> Xem
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/service-request?action=detail&id=${sr.ticketId}"
                                           class="btn btn-outline-primary btn-sm">
                                            <i class="bi bi-eye"></i> Xem
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty requestList}">
                        <tr>
                            <td colspan="10" class="text-center text-muted py-4">
                                Không có yêu cầu dịch vụ nào.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </form>
</div>

<script>
    document.getElementById('selectAll')?.addEventListener('change', function () {
        document.querySelectorAll('.rowCheckbox').forEach(cb => cb.checked = this.checked);
    });

    function getCheckedCount() {
        return document.querySelectorAll('.rowCheckbox:checked').length;
    }

    function submitBulkDelete() {
        if (getCheckedCount() === 0) {
            alert('Vui lòng chọn ít nhất một yêu cầu.');
            return;
        }
        if (!confirm('Bạn có chắc muốn xóa các yêu cầu đã chọn không?')) {
            return;
        }

        const form = document.getElementById('bulkForm');
        form.action = '${pageContext.request.contextPath}/service-request';
        document.getElementById('bulkAction').value = 'bulkDelete';
        form.submit();
    }

    function submitBulkApprove() {
        if (getCheckedCount() === 0) {
            alert('Vui lòng chọn ít nhất một yêu cầu.');
            return;
        }
        if (!confirm('Bạn có chắc muốn duyệt các yêu cầu đã chọn không?')) {
            return;
        }

        const form = document.getElementById('bulkForm');
        form.action = '${pageContext.request.contextPath}/service-request-manage';
        document.getElementById('bulkAction').value = 'bulkApprove';
        form.submit();
    }

    function submitBulkReject() {
        if (getCheckedCount() === 0) {
            alert('Vui lòng chọn ít nhất một yêu cầu.');
            return;
        }

        const reason = prompt('Nhập lý do từ chối (có thể để trống):', '');
        if (reason === null) {
            return;
        }

        const form = document.getElementById('bulkForm');
        form.action = '${pageContext.request.contextPath}/service-request-manage';
        document.getElementById('bulkAction').value = 'bulkReject';
        document.getElementById('bulkRejectionReason').value = reason;
        form.submit();
    }
</script>

<jsp:include page="/includes/footer.jsp" />
