<jsp:include page="/includes/header.jsp" />
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<div class="container-fluid bg-light p-4 rounded shadow-sm mb-5">

    <c:if test="${not empty param.msg}">
        <div class="alert alert-info alert-dismissible fade show" role="alert">
            <c:choose>
                <c:when test="${param.msg eq 'assessed'}">Risk assessment saved successfully.</c:when>
                <c:when test="${param.msg eq 'assess_failed'}">Failed to save risk assessment.</c:when>
                <c:when test="${param.msg eq 'review_success'}">CAB review completed successfully.</c:when>
                <c:when test="${param.msg eq 'review_failed'}">CAB review failed.</c:when>
                <c:otherwise>Action completed.</c:otherwise>
            </c:choose>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="d-flex justify-content-between align-items-center mb-4">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb bg-transparent p-0 m-0">
                <li class="breadcrumb-item">
                    <a href="${pageContext.request.contextPath}/change-request?action=list">Change Management</a>
                </li>
                <li class="breadcrumb-item active" aria-current="page">#CR-${ticket.ticketId}</li>
            </ol>
        </nav>

        <div class="d-flex gap-2 flex-wrap">
            <a href="${pageContext.request.contextPath}/change-request?action=list"
               class="btn btn-outline-secondary btn-sm shadow-sm">
                <i class="bi bi-arrow-left"></i> Back to List
            </a>

            <c:if test="${ticket.reportedBy == sessionScope.user.userId and ticket.status eq 'NEW'}">
                <a href="${pageContext.request.contextPath}/change-request/edit?id=${ticket.ticketId}"
                   class="btn btn-warning btn-sm shadow-sm fw-bold">
                    <i class="bi bi-pencil-square"></i> Edit Request
                </a>
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
                    <h6 class="fw-bold text-dark mb-2">
                        <i class="bi bi-card-text me-2"></i>Change Description
                    </h6>
                    <p class="text-secondary mb-4">${ticket.description}</p>

                    <h6 class="fw-bold text-dark mb-2">
                        <i class="bi bi-shield-exclamation me-2"></i>Impact & Risk Assessment
                    </h6>
                    <p class="text-muted bg-light p-3 rounded border-start border-4 border-warning mb-4">
                        ${not empty ticket.impactAssessment ? ticket.impactAssessment : 'No impact assessment provided.'}
                    </p>

                    <div class="row g-3">
                        <div class="col-12">
                            <h6 class="fw-bold text-dark mb-2">
                                <i class="bi bi-tools me-2"></i>Implementation Plan
                            </h6>
                            <p class="text-secondary bg-white border p-3 rounded">
                                ${not empty ticket.implementationPlan ? ticket.implementationPlan : 'N/A'}
                            </p>
                        </div>

                        <div class="col-12">
                            <h6 class="fw-bold text-dark mb-2">
                                <i class="bi bi-arrow-counterclockwise me-2"></i>Rollback Plan
                            </h6>
                            <p class="text-secondary bg-white border p-3 rounded">
                                ${not empty ticket.rollbackPlan ? ticket.rollbackPlan : 'N/A'}
                            </p>
                        </div>

                        <div class="col-12">
                            <h6 class="fw-bold text-dark mb-2">
                                <i class="bi bi-check2-square me-2"></i>Test Plan
                            </h6>
                            <p class="text-secondary bg-white border p-3 rounded">
                                ${not empty ticket.testPlan ? ticket.testPlan : 'N/A'}
                            </p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card shadow-sm border-0 mb-4 mt-4 border-top border-4 border-primary">
                <div class="card-header bg-white border-bottom py-3 d-flex justify-content-between align-items-center">
                    <h6 class="mb-0 fw-bold text-dark">
                        <i class="bi bi-chat-dots me-2 text-primary"></i>Discussion Board
                    </h6>
                    <span class="badge bg-primary rounded-pill">${comments != null ? comments.size() : 0} Comments</span>
                </div>

                <div class="card-body p-4 bg-light">
                    <form action="${pageContext.request.contextPath}/ticket/add-comment" method="post"
                          class="mb-4 bg-white p-3 rounded shadow-sm border">
                        <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                        <input type="hidden" name="ticketType" value="CHANGE">

                        <div class="mb-2">
                            <textarea class="form-control border-0" name="commentText"
                                      placeholder="Enter discussion content here..." rows="3" required
                                      style="box-shadow: none; resize: none;"></textarea>
                        </div>

                        <div class="d-flex justify-content-end border-top pt-2">
                            <button type="submit" class="btn btn-primary btn-sm fw-bold px-4">
                                <i class="bi bi-send-fill me-1"></i> Send Message
                            </button>
                        </div>
                    </form>

                    <div class="comment-list">
                        <c:forEach var="cmt" items="${comments}">
                            <div class="d-flex mb-3 bg-white p-3 rounded shadow-sm border-start border-3 border-secondary">
                                <div class="flex-shrink-0">
                                    <div class="bg-dark text-white rounded-circle d-flex align-items-center justify-content-center fw-bold shadow-sm"
                                         style="width: 45px; height: 45px; font-size: 1.2rem; text-transform: uppercase;">
                                        ${cmt.userName.substring(0,1)}
                                    </div>
                                </div>
                                <div class="flex-grow-1 ms-3">
                                    <div class="d-flex justify-content-between align-items-center mb-1">
                                        <h6 class="mb-0 fw-bold text-dark">${cmt.userName}</h6>
                                        <small class="text-muted">
                                            <i class="bi bi-clock me-1"></i>
                                            <fmt:formatDate value="${cmt.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                        </small>
                                    </div>
                                    <p class="mb-0 text-secondary mt-2" style="white-space: pre-wrap;">
                                        ${cmt.commentText}
                                    </p>
                                </div>
                            </div>
                        </c:forEach>

                        <c:if test="${empty comments}">
                            <div class="text-center text-muted py-4 fst-italic">
                                <i class="bi bi-chat-square-text fs-1 d-block mb-2 text-light"></i>
                                No discussion yet.
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-body p-4">
                    <h6 class="fw-bold text-dark border-bottom pb-2 mb-3">Change Details</h6>
                    <ul class="list-unstyled mb-0">
                        <li class="mb-3">
                            <small class="text-muted d-block">Status</small>
                            <span class="badge bg-secondary fs-6 ${ticket.status == 'NEW' ? 'bg-primary' : (ticket.status == 'APPROVED' ? 'bg-success' : 'bg-secondary')}">
                                ${ticket.status}
                            </span>
                        </li>
                        <li class="mb-3">
                            <small class="text-muted d-block">Change Type</small>
                            <span class="badge bg-info text-dark">${not empty ticket.changeType ? ticket.changeType : 'NORMAL'}</span>
                        </li>
                        <li class="mb-3">
                            <small class="text-muted d-block">Risk Level</small>
                            <span class="badge ${ticket.riskLevel == 'HIGH' or ticket.riskLevel == 'CRITICAL' ? 'bg-danger' : 'bg-warning text-dark'}">
                                ${not empty ticket.riskLevel ? ticket.riskLevel : 'MEDIUM'}
                            </span>
                        </li>
                        <li class="mb-3">
                            <small class="text-muted d-block">Requester</small>
                            <strong><i class="bi bi-person me-1"></i> ${ticket.reportedByName}</strong>
                        </li>
                        <li class="mb-3">
                            <small class="text-muted d-block">Assigned To</small>
                            <strong>
                                <i class="bi bi-headset me-1"></i>
                                <c:choose>
                                    <c:when test="${not empty ticket.assignedToName}">
                                        ${ticket.assignedToName}
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-warning">Unassigned</span>
                                    </c:otherwise>
                                </c:choose>
                            </strong>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="card shadow-sm border-0 mb-4 border-top border-4 border-info">
                <div class="card-body p-4">
                    <h6 class="fw-bold text-dark border-bottom pb-2 mb-3">
                        <i class="bi bi-calendar-event me-2"></i>Schedule Info
                    </h6>
                    <ul class="list-unstyled mb-0">
                        <li class="mb-3">
                            <small class="text-muted d-block">Scheduled Start</small>
                            <span class="fw-bold text-primary">
                                <c:choose>
                                    <c:when test="${not empty ticket.scheduledStart}">
                                        <fmt:formatDate value="${ticket.scheduledStart}" pattern="dd/MM/yyyy HH:mm" />
                                    </c:when>
                                    <c:otherwise>TBD</c:otherwise>
                                </c:choose>
                            </span>
                        </li>
                        <li class="mb-3">
                            <small class="text-muted d-block">Scheduled End</small>
                            <span class="fw-bold text-primary">
                                <c:choose>
                                    <c:when test="${not empty ticket.scheduledEnd}">
                                        <fmt:formatDate value="${ticket.scheduledEnd}" pattern="dd/MM/yyyy HH:mm" />
                                    </c:when>
                                    <c:otherwise>TBD</c:otherwise>
                                </c:choose>
                            </span>
                        </li>
                        <li class="mb-3">
                            <small class="text-muted d-block">Downtime Required?</small>
                            <span class="badge ${ticket.downtimeRequired ? 'bg-danger' : 'bg-success'}">
                                ${ticket.downtimeRequired ? 'YES' : 'NO'}
                            </span>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="card shadow-sm border-0 bg-dark text-white mb-4">
                <div class="card-body p-4">
                    <h6 class="fw-bold border-bottom border-secondary pb-2 mb-3">
                        <i class="bi bi-bank me-2"></i>CAB Assessment & Decision
                    </h6>

                    <div class="mb-3">
                        <small class="text-secondary d-block fw-bold">Risk & Schedule Assessment:</small>
                        <p class="text-light mb-2 fst-italic border-start border-3 border-secondary ps-2">
                            ${not empty ticket.cabRiskAssessment ? ticket.cabRiskAssessment : 'Waiting for CAB assessment...'}
                        </p>
                    </div>

                    <div class="mb-3">
                        <small class="text-secondary d-block fw-bold">CAB Comments:</small>
                        <p class="text-light mb-0">
                            ${not empty ticket.cabComment ? ticket.cabComment : 'No comment yet.'}
                        </p>
                    </div>

                    <div class="d-flex align-items-center justify-content-between mt-4 pt-3 border-top border-secondary flex-wrap gap-2">
                        <div class="d-flex align-items-center">
                            <h4 class="m-0 me-2 ${ticket.cabDecision == 'APPROVED' ? 'text-success' : (ticket.cabDecision == 'REJECTED' ? 'text-danger' : 'text-warning')}">
                                <i class="bi ${ticket.cabDecision == 'APPROVED' ? 'bi-check-circle-fill' : (ticket.cabDecision == 'REJECTED' ? 'bi-x-circle-fill' : 'bi-hourglass-split')}"></i>
                            </h4>
                            <span class="fs-5 fw-bold">${not empty ticket.cabDecision ? ticket.cabDecision : 'PENDING'}</span>
                        </div>

                        <c:if test="${sessionScope.user.roleId == 7 and ticket.cabDecision ne 'APPROVED' and ticket.cabDecision ne 'REJECTED'}">
                            <form action="${pageContext.request.contextPath}/change-request" method="post" class="m-0">
                                <input type="hidden" name="action" value="reviewSingle">
                                <input type="hidden" name="ticketId" value="${ticket.ticketId}">

                                <button type="submit" name="decision" value="APPROVED"
                                        class="btn btn-success btn-sm fw-bold me-2 shadow-sm"
                                        onclick="return confirm('Approve this change request?');">
                                    <i class="bi bi-check-lg"></i> Approve
                                </button>

                                <button type="submit" name="decision" value="REJECTED"
                                        class="btn btn-outline-light btn-sm fw-bold shadow-sm"
                                        onclick="return confirm('Reject this change request?');">
                                    <i class="bi bi-x-lg"></i> Reject
                                </button>
                            </form>
                        </c:if>
                    </div>
                </div>
            </div>

            <c:if test="${sessionScope.user.roleId == 7 and ticket.cabDecision ne 'APPROVED' and ticket.cabDecision ne 'REJECTED'}">
                <div class="card shadow-sm border-0 mb-4 border-top border-4 border-danger">
                    <div class="card-body p-4">
                        <h6 class="fw-bold text-dark mb-3">
                            <i class="bi bi-clipboard2-pulse me-2"></i>Assess Change Risk
                        </h6>
                        <form action="${pageContext.request.contextPath}/change-request" method="post">
                            <input type="hidden" name="action" value="assess">
                            <input type="hidden" name="ticketId" value="${ticket.ticketId}">

                            <div class="mb-3">
                                <label class="form-label fw-bold text-danger small">
                                    Risk & Schedule Assessment <span class="text-danger">*</span>
                                </label>
                                <textarea name="cabRiskAssessment" class="form-control border-danger"
                                          rows="3" required
                                          placeholder="Evaluate risk level, impact, and recommend schedule...">${ticket.cabRiskAssessment}</textarea>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold text-secondary small">Additional Comments</label>
                                <textarea name="cabComment" class="form-control border-secondary"
                                          rows="2"
                                          placeholder="Additional notes or requested adjustments...">${ticket.cabComment}</textarea>
                            </div>

                            <button type="submit" class="btn btn-danger w-100 fw-bold shadow-sm">
                                <i class="bi bi-save me-1"></i> Save Assessment
                            </button>
                        </form>
                    </div>
                </div>
            </c:if>
        </div>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />