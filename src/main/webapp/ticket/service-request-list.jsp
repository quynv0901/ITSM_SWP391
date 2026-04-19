<jsp:include page="/includes/header.jsp" />
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<c:set var="userRole" value="${sessionScope.user.roleId}" />

<div class="container-fluid bg-white p-4 rounded shadow-sm">

    <c:if test="${not empty param.msg}">
        <div class="alert alert-info alert-dismissible fade show" role="alert">
            <c:choose>
                <c:when test="${param.msg eq 'created'}">Service request created successfully.</c:when>
                <c:when test="${param.msg eq 'deleted'}">Service request deleted successfully.</c:when>
                <c:when test="${param.msg eq 'bulk_deleted'}">Bulk delete completed. Deleted: ${param.count}</c:when>
                <c:when test="${param.msg eq 'bulk_approved'}">Bulk approve completed. Updated: ${param.count}</c:when>
                <c:when test="${param.msg eq 'bulk_rejected'}">Bulk reject completed. Updated: ${param.count}</c:when>
                <c:when test="${param.msg eq 'not_found'}">Service request not found.</c:when>
                <c:when test="${param.msg eq 'invalid_id'}">Invalid request id.</c:when>
                <c:otherwise>Action completed.</c:otherwise>
            </c:choose>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
        <h2 class="h4 text-primary m-0">
            <i class="bi bi-ticket-detailed me-2"></i>Service Request List
        </h2>

        <c:if test="${userRole == 1}">
            <a href="${pageContext.request.contextPath}/service-request?action=createForm"
               class="btn btn-primary shadow-sm">
                <i class="bi bi-plus-circle me-1"></i> Create Service Request
            </a>
        </c:if>
    </div>

    <form action="${pageContext.request.contextPath}/service-request" method="get"
          class="row g-3 mb-4 bg-light p-3 rounded border mx-0">
        <input type="hidden" name="action" value="list">

        <div class="col-md-4">
            <input type="text" name="keyword" class="form-control"
                   placeholder="Search by ticket number, title, service..."
                   value="${keyword}">
        </div>

        <div class="col-md-3">
            <select name="status" class="form-select">
                <option value="">All Status</option>
                <option value="NEW" ${status eq 'NEW' ? 'selected' : ''}>NEW</option>
                <option value="ASSIGNED" ${status eq 'ASSIGNED' ? 'selected' : ''}>ASSIGNED</option>
                <option value="IN_PROGRESS" ${status eq 'IN_PROGRESS' ? 'selected' : ''}>IN PROGRESS</option>
                <option value="PENDING" ${status eq 'PENDING' ? 'selected' : ''}>PENDING</option>
                <option value="RESOLVED" ${status eq 'RESOLVED' ? 'selected' : ''}>RESOLVED</option>
                <option value="CLOSED" ${status eq 'CLOSED' ? 'selected' : ''}>CLOSED</option>
                <option value="CANCELLED" ${status eq 'CANCELLED' ? 'selected' : ''}>CANCELLED</option>
            </select>
        </div>

        <div class="col-md-3">
            <select name="approvalStatus" class="form-select">
                <option value="">All Approval Status</option>
                <option value="PENDING" ${approvalStatus eq 'PENDING' ? 'selected' : ''}>PENDING</option>
                <option value="APPROVED" ${approvalStatus eq 'APPROVED' ? 'selected' : ''}>APPROVED</option>
                <option value="REJECTED" ${approvalStatus eq 'REJECTED' ? 'selected' : ''}>REJECTED</option>
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

    <form id="bulkForm" method="post">
        <input type="hidden" name="action" id="bulkAction" value="">
        <input type="hidden" name="rejectionReason" id="bulkRejectionReason" value="">

        <div class="d-flex justify-content-end gap-2 mb-3 flex-wrap">
            <c:if test="${userRole == 1}">
                <button type="button" class="btn btn-danger btn-sm shadow-sm"
                        onclick="submitBulkDelete()">
                    <i class="bi bi-trash"></i> Bulk Delete
                </button>
            </c:if>

            <c:if test="${userRole == 3}">
                <button type="button" class="btn btn-success btn-sm shadow-sm"
                        onclick="submitBulkApprove()">
                    <i class="bi bi-check-circle"></i> Bulk Approve
                </button>

                <button type="button" class="btn btn-outline-danger btn-sm shadow-sm"
                        onclick="submitBulkReject()">
                    <i class="bi bi-x-circle"></i> Bulk Reject
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
                        <th>Ticket No.</th>
                        <th>Title</th>
                        <th>Service</th>
                        <th>Requester</th>
                        <th>Assigned To</th>
                        <th>Status</th>
                        <th>Approval</th>
                        <th>Created At</th>
                        <th class="text-center">Action</th>
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
                                        <span class="text-muted fst-italic">Unassigned</span>
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
                                          ${sr.status}
                                      </span>
                                </td>
                                <td>
                                    <span class="badge
                                          ${sr.approvalStatus eq 'APPROVED' ? 'bg-success' :
                                            sr.approvalStatus eq 'REJECTED' ? 'bg-danger' : 'bg-warning text-dark'}">
                                              ${sr.approvalStatus}
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
                                                    <i class="bi bi-eye"></i> View
                                                </a>
                                            </c:when>
                                            <c:otherwise>
                                                <a href="${pageContext.request.contextPath}/service-request?action=detail&id=${sr.ticketId}"
                                                   class="btn btn-outline-primary btn-sm">
                                                    <i class="bi bi-eye"></i> View
                                                </a>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty requestList}">
                                <tr>
                                    <td colspan="10" class="text-center text-muted py-4">
                                        No service requests found.
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
                    alert('Please select at least one request.');
                    return;
                }
                if (!confirm('Delete selected service requests?'))
                    return;

                const form = document.getElementById('bulkForm');
                form.action = '${pageContext.request.contextPath}/service-request';
                document.getElementById('bulkAction').value = 'bulkDelete';
                form.submit();
            }

            function submitBulkApprove() {
                if (getCheckedCount() === 0) {
                    alert('Please select at least one request.');
                    return;
                }
                if (!confirm('Approve selected service requests?'))
                    return;

                const form = document.getElementById('bulkForm');
                form.action = '${pageContext.request.contextPath}/service-request-manage';
                document.getElementById('bulkAction').value = 'bulkApprove';
                form.submit();
            }

            function submitBulkReject() {
                if (getCheckedCount() === 0) {
                    alert('Please select at least one request.');
                    return;
                }

                const reason = prompt('Enter rejection reason (optional):', '');
                if (reason === null)
                    return;

                const form = document.getElementById('bulkForm');
                form.action = '${pageContext.request.contextPath}/service-request-manage';
                document.getElementById('bulkAction').value = 'bulkReject';
                document.getElementById('bulkRejectionReason').value = reason;
                form.submit();
            }
        </script>

        <jsp:include page="/includes/footer.jsp" />