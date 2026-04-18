<jsp:include page="/includes/header.jsp" />
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<c:set var="ticket" value="${serviceRequest}" />

<div class="container-fluid bg-light p-4 rounded shadow-sm mb-5">

    <c:if test="${not empty param.msg}">
        <div class="alert alert-info alert-dismissible fade show" role="alert">
            <c:choose>
                <c:when test="${param.msg eq 'cancelled'}">Request cancelled successfully.</c:when>
                <c:when test="${param.msg eq 'deleted'}">Request deleted successfully.</c:when>
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
                    <a href="${pageContext.request.contextPath}/service-request?action=list">My Requests</a>
                </li>
                <li class="breadcrumb-item active" aria-current="page">${ticket.ticketNumber}</li>
            </ol>
        </nav>

        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/service-request?action=list"
               class="btn btn-outline-secondary btn-sm shadow-sm">
                <i class="bi bi-arrow-left"></i> Back
            </a>

            <c:if test="${ticket.status ne 'CANCELLED' and ticket.status ne 'CLOSED' and ticket.status ne 'RESOLVED'}">
                <form action="${pageContext.request.contextPath}/service-request" method="post"
                      onsubmit="return confirm('Cancel this service request?');">
                    <input type="hidden" name="action" value="cancel">
                    <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                    <button type="submit" class="btn btn-warning btn-sm shadow-sm text-dark">
                        <i class="bi bi-x-circle"></i> Cancel
                    </button>
                </form>
            </c:if>

            <c:if test="${ticket.status eq 'NEW' and empty ticket.assignedTo}">
                <form action="${pageContext.request.contextPath}/service-request" method="post"
                      onsubmit="return confirm('Delete this request?');">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                    <button type="submit" class="btn btn-danger btn-sm shadow-sm">
                        <i class="bi bi-trash"></i> Delete
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

                    <h6 class="fw-bold text-dark mb-2 mt-4">Fulfillment Progress / Solution</h6>
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
                            <small class="text-muted d-block">Priority</small>
                            <strong>${ticket.priority}</strong>
                        </li>
                        <li class="mb-3">
                            <small class="text-muted d-block">Created At</small>
                            <strong><fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy HH:mm"/></strong>
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
                    </ul>
                </div>
            </div>

            <div class="card shadow-sm border-0">
                <div class="card-body p-4">
                    <h6 class="fw-bold border-bottom pb-2 mb-3">Requested Service</h6>
                    <ul class="list-unstyled mb-0">
                        <li class="mb-3">
                            <small class="text-muted d-block">Service Name</small>
                            <strong>${ticket.serviceName}</strong>
                        </li>
                        <li class="mb-3">
                            <small class="text-muted d-block">Service Code</small>
                            <strong>${ticket.serviceCode}</strong>
                        </li>
                        <li class="mb-3">
                            <small class="text-muted d-block">Estimated Delivery (Days)</small>
                            <strong>${ticket.estimatedDeliveryDay}</strong>
                        </li>
                        <li class="mb-3">
                            <small class="text-muted d-block">Service Description</small>
                            <div class="text-secondary">${ticket.serviceDescription}</div>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />