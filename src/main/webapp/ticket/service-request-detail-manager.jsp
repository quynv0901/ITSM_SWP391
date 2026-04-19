<jsp:include page="/includes/header.jsp" />
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<c:set var="ticket" value="${serviceRequest}" />
<c:set var="userRole" value="${sessionScope.user.roleId}" />

<div class="container-fluid bg-light p-4 rounded shadow-sm mb-5">

    <c:if test="${not empty param.msg}">
        <div class="alert alert-info alert-dismissible fade show" role="alert">
            <c:choose>
                <c:when test="${param.msg eq 'updated'}">Request updated successfully.</c:when>
                <c:when test="${param.msg eq 'assigned'}">Request assigned successfully.</c:when>
                <c:when test="${param.msg eq 'approved'}">Request approved successfully.</c:when>
                <c:when test="${param.msg eq 'rejected'}">Request rejected successfully.</c:when>
                <c:when test="${param.msg eq 'cancelled'}">Request cancelled successfully.</c:when>
                <c:when test="${param.msg eq 'comment_added'}">Comment added successfully.</c:when>
                <c:otherwise>Action completed.</c:otherwise>
            </c:choose>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb bg-transparent p-0 m-0">
                <li class="breadcrumb-item">
                    <a href="${pageContext.request.contextPath}/service-request?action=list">Requests Management</a>
                </li>
                <li class="breadcrumb-item active" aria-current="page">${ticket.ticketNumber}</li>
            </ol>
        </nav>

        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/service-request?action=list"
               class="btn btn-outline-secondary btn-sm shadow-sm">
                <i class="bi bi-arrow-left"></i> Back
            </a>

            <c:if test="${userRole == 3 and ticket.status ne 'CANCELLED' and ticket.status ne 'CLOSED' and ticket.status ne 'RESOLVED'}">
                <form action="${pageContext.request.contextPath}/service-request" method="post"
                      onsubmit="return confirm('Cancel this request?');">
                    <input type="hidden" name="action" value="cancel">
                    <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                    <button type="submit" class="btn btn-warning btn-sm shadow-sm text-dark">
                        <i class="bi bi-x-circle"></i> Cancel
                    </button>
                </form>
            </c:if>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-md-8">
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-header bg-white border-bottom py-3">
                    <h4 class="mb-0 text-primary">${ticket.title}</h4>
                </div>
                <div class="card-body p-4">
                    <h6 class="fw-bold text-dark mb-2">Request Description</h6>
                    <p class="text-secondary">${ticket.description}</p>

                    <h6 class="fw-bold text-dark mb-2 mt-4">Justification</h6>
                    <p class="text-secondary bg-light p-3 rounded border">
                        ${not empty ticket.justification ? ticket.justification : 'N/A'}
                    </p>

                    <h6 class="fw-bold text-dark mb-2 mt-4">Current Solution / Fulfillment Note</h6>
                    <p class="text-secondary bg-light p-3 rounded border">
                        ${not empty ticket.solution ? ticket.solution : 'No fulfillment update yet.'}
                    </p>

                    <c:if test="${ticket.approvalStatus eq 'REJECTED' and not empty ticket.rejectionReason}">
                        <h6 class="fw-bold text-danger mb-2 mt-4">Rejection Reason</h6>
                        <p class="text-danger bg-light p-3 rounded border border-danger">
                            ${ticket.rejectionReason}
                        </p>
                    </c:if>
                </div>
            </div>

            <div class="card shadow-sm border-0 mb-4">
                <div class="card-header bg-white border-bottom py-3">
                    <h6 class="mb-0 fw-bold">Update Fulfillment Progress</h6>
                </div>
                <div class="card-body p-4">
                    <form action="${pageContext.request.contextPath}/service-request-manage" method="post">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="ticketId" value="${ticket.ticketId}">

                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Title</label>
                                <input type="text" name="title" class="form-control" value="${ticket.title}" required>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">Status</label>
                                <select name="status" class="form-select" required>
                                    <option value="NEW" ${ticket.status eq 'NEW' ? 'selected' : ''}>NEW</option>
                                    <option value="ASSIGNED" ${ticket.status eq 'ASSIGNED' ? 'selected' : ''}>ASSIGNED</option>
                                    <option value="IN_PROGRESS" ${ticket.status eq 'IN_PROGRESS' ? 'selected' : ''}>IN PROGRESS</option>
                                    <option value="PENDING" ${ticket.status eq 'PENDING' ? 'selected' : ''}>PENDING</option>
                                    <option value="RESOLVED" ${ticket.status eq 'RESOLVED' ? 'selected' : ''}>RESOLVED</option>
                                    <option value="CLOSED" ${ticket.status eq 'CLOSED' ? 'selected' : ''}>CLOSED</option>
                                    <option value="CANCELLED" ${ticket.status eq 'CANCELLED' ? 'selected' : ''}>CANCELLED</option>
                                </select>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-bold">Description</label>
                                <textarea name="description" rows="4" class="form-control">${ticket.description}</textarea>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-bold">Solution / Fulfillment Note</label>
                                <textarea name="solution" rows="4" class="form-control"
                                          placeholder="Update progress, fulfillment result, notes...">${ticket.solution}</textarea>
                            </div>
                        </div>

                        <div class="text-end mt-3">
                            <button type="submit" class="btn btn-primary">
                                <i class="bi bi-save me-1"></i> Update Request
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <div class="card shadow-sm border-0">
                <div class="card-header bg-white border-bottom py-3">
                    <h6 class="mb-0 fw-bold">Comments</h6>
                </div>
                <div class="card-body p-4 bg-light">
                    <form action="${pageContext.request.contextPath}/service-request" method="post"
                          class="mb-4 bg-white p-3 rounded shadow-sm border">
                        <input type="hidden" name="action" value="comment">
                        <input type="hidden" name="ticketId" value="${ticket.ticketId}">

                        <div class="mb-2">
                            <textarea class="form-control" name="commentText" rows="3"
                                      placeholder="Add a comment..." required></textarea>
                        </div>

                        <div class="text-end">
                            <button type="submit" class="btn btn-primary btn-sm">
                                <i class="bi bi-send-fill me-1"></i> Comment
                            </button>
                        </div>
                    </form>

                    <c:forEach var="cmt" items="${ticket.comments}">
                        <div class="bg-white p-3 rounded shadow-sm border mb-3">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <strong>${cmt.userName}</strong>
                                <small class="text-muted">
                                    <fmt:formatDate value="${cmt.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                </small>
                            </div>
                            <div class="text-secondary" style="white-space: pre-wrap;">
                                ${cmt.commentText}
                            </div>
                        </div>
                    </c:forEach>

                    <c:if test="${empty ticket.comments}">
                        <div class="text-center text-muted fst-italic py-3">
                            No comments yet.
                        </div>
                    </c:if>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-body p-4">
                    <h6 class="fw-bold border-bottom pb-2 mb-3">Request Information</h6>
                    <ul class="list-unstyled mb-0">
                        <li class="mb-3">
                            <small class="text-muted d-block">Ticket Number</small>
                            <strong>${ticket.ticketNumber}</strong>
                        </li>
                        <li class="mb-3">
                            <small class="text-muted d-block">Requester</small>
                            <strong>${ticket.reportedByName}</strong>
                        </li>
                        <li class="mb-3">
                            <small class="text-muted d-block">Status</small>
                            <span class="badge bg-primary">${ticket.status}</span>
                        </li>
                        <li class="mb-3">
                            <small class="text-muted d-block">Approval Status</small>
                            <span class="badge ${ticket.approvalStatus eq 'APPROVED' ? 'bg-success' : (ticket.approvalStatus eq 'REJECTED' ? 'bg-danger' : 'bg-warning text-dark')}">
                                ${ticket.approvalStatus}
                            </span>
                        </li>
                        <li class="mb-3">
                            <small class="text-muted d-block">Assigned To</small>
                            <strong>
                                <c:choose>
                                    <c:when test="${not empty ticket.assignedToName}">
                                        ${ticket.assignedToName}
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted">Unassigned</span>
                                    </c:otherwise>
                                </c:choose>
                            </strong>
                        </li>
                        <li class="mb-3">
                            <small class="text-muted d-block">Created At</small>
                            <strong><fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy HH:mm"/></strong>
                        </li>
                    </ul>
                </div>
            </div>

            <c:if test="${userRole == 3}">
                <div class="card shadow-sm border-0 mb-4">
                    <div class="card-body p-4">
                        <h6 class="fw-bold border-bottom pb-2 mb-3">Assign Request</h6>
                        <form action="${pageContext.request.contextPath}/service-request-manage" method="post">
                            <input type="hidden" name="action" value="assign">
                            <input type="hidden" name="ticketId" value="${ticket.ticketId}">

                            <div class="mb-3">
                                <label class="form-label fw-bold">Assign To</label>
                                <select name="assignedTo" class="form-select" required>
                                    <option value="">Select support agent</option>
                                    <c:forEach var="agent" items="${agentOptions}">
                                        <option value="${agent.userId}"
                                                ${ticket.assignedTo == agent.userId ? 'selected' : ''}>
                                            ${agent.fullName}
                                        </option>
                                    </c:forEach>
                                </select>
                                <div class="form-text">Only support agents are listed.</div>
                            </div>

                            <button type="submit" class="btn btn-info w-100 text-dark">
                                <i class="bi bi-person-check me-1"></i> Assign
                            </button>
                        </form>
                    </div>
                </div>

                <div class="card shadow-sm border-0">
                    <div class="card-body p-4">
                        <h6 class="fw-bold border-bottom pb-2 mb-3">Approval Action</h6>

                        <form action="${pageContext.request.contextPath}/service-request-manage" method="post" class="mb-3">
                            <input type="hidden" name="action" value="approve">
                            <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                            <button type="submit" class="btn btn-success w-100"
                                    onclick="return confirm('Approve this service request?');">
                                <i class="bi bi-check-circle me-1"></i> Approve
                            </button>
                        </form>

                        <form action="${pageContext.request.contextPath}/service-request-manage" method="post">
                            <input type="hidden" name="action" value="reject">
                            <input type="hidden" name="ticketId" value="${ticket.ticketId}">

                            <div class="mb-2">
                                <label class="form-label fw-bold">Rejection Reason</label>
                                <textarea name="rejectionReason" rows="3" class="form-control"
                                          placeholder="Enter rejection reason..."></textarea>
                            </div>

                            <button type="submit" class="btn btn-outline-danger w-100"
                                    onclick="return confirm('Reject this service request?');">
                                <i class="bi bi-x-circle me-1"></i> Reject
                            </button>
                        </form>
                    </div>
                </div>
            </c:if>
        </div>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />