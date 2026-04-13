<jsp:include page="/includes/header.jsp" />
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
        <%@ taglib prefix="c" uri="jakarta.tags.core" %>

            <div class="container-fluid bg-white p-4 rounded shadow-sm mb-4">
                <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-2">
                    <h2 class="h4 text-primary m-0">Problem Detail: ${problem.ticketNumber}</h2>
                    <a href="${pageContext.request.contextPath}/problem?action=list" class="btn btn-secondary">
                        <i class="bi bi-arrow-left"></i> Back to List
                    </a>
                </div>
                <div class="row mb-3">
                    <div class="col-md-6">
                        <p class="mb-2"><strong>Title:</strong> ${problem.title}</p>
                        <p class="mb-2"><strong>Status:</strong> <span class="badge bg-info">${problem.status}</span>
                        </p>
                    </div>
                    <div class="col-md-6">
                        <p class="mb-2"><strong>Reported By:</strong> ${not empty problem.reportedByName ?
                            problem.reportedByName : 'User ID '.concat(problem.reportedBy)}</p>

                        <p class="mb-2 d-flex align-items-center gap-2">
                            <strong>Assigned To:</strong>
                            <span
                                class="${empty problem.assignedToName ? 'text-muted fst-italic' : 'text-primary fw-bold'}">
                                ${not empty problem.assignedToName ? problem.assignedToName : 'Unassigned'}
                            </span>
                            
                            <%-- Technical Expert: Self-Assign if Unassigned & NOT reported by them --%>
                            <c:if test="${problem.status ne 'CANCELLED'}">
                                <c:if test="${sessionScope.user.roleId == 5 && (empty problem.assignedTo || problem.assignedTo == 0) && sessionScope.user.userId ne problem.reportedBy}">
                                    <form action="${pageContext.request.contextPath}/problem?action=assign" method="post" class="m-0 p-0">
                                        <input type="hidden" name="id" value="${problem.ticketId}">
                                        <input type="hidden" name="assignedTo" value="${sessionScope.user.userId}">
                                        <button class="btn btn-outline-primary btn-sm py-0 px-2" style="font-size: 0.8rem;" type="submit">
                                            <i class="bi bi-person-check-fill"></i> Assign To Me
                                        </button>
                                    </form>
                                </c:if>
                            </c:if>
                        </p>

                        <%-- Assignment Form (Hidden for CANCELLED) --%>
                            <c:if test="${problem.status ne 'CANCELLED'}">

                                <%-- Manager: Can Assign to Anyone --%>
                                    <c:if test="${sessionScope.user.roleId == 3}">
                                        <form action="${pageContext.request.contextPath}/problem?action=assign"
                                            method="post" class="mt-3 p-3 bg-light border rounded">
                                            <input type="hidden" name="id" value="${problem.ticketId}">
                                            <label for="assignedTo" class="form-label fw-bold fade-in text-secondary"
                                                style="font-size: 0.9em;">Assign to Technical Expert:</label>
                                            <div class="input-group input-group-sm">
                                                <select name="assignedTo" id="assignedTo" class="form-select" required>
                                                    <option value="" disabled selected>Select an Expert...</option>
                                                    <c:forEach var="expert" items="${technicalExperts}">
                                                        <option value="${expert.userId}"
                                                            ${problem.assignedTo==expert.userId ? 'selected' : '' }>
                                                            ${expert.fullName} (@${expert.username})
                                                        </option>
                                                    </c:forEach>
                                                </select>
                                                <button class="btn btn-primary" type="submit">Assign</button>
                                            </div>
                                        </form>
                                    </c:if>
                            </c:if>
                    </div>
                </div>

                <div class="mb-4">
                    <strong>Description:</strong>
                    <div class="p-3 bg-light rounded mt-2 border">${problem.description}</div>
                </div>

                <c:if test="${problem.status eq 'CANCELLED'}">
                    <div class="mb-4">
                        <strong>Cancellation Reason:</strong>
                        <div class="p-3 bg-danger bg-opacity-10 text-danger rounded mt-2 border border-danger">
                            ${not empty problem.justification ? problem.justification : '<i>No reason provided</i>'}
                        </div>
                    </div>
                </c:if>

                <hr>
                <h3 class="h5 mt-4 mb-3 text-secondary">Root Cause Analysis (RCA)</h3>
                <div class="row">
                    <div class="col-md-6">
                        <strong>Root Cause:</strong>
                        <div class="p-3 bg-white border rounded mt-2 text-danger">
                            ${problem.cause == null ? '<i>Not identified yet</i>' : problem.cause}
                        </div>
                    </div>
                    <div class="col-md-6">
                        <strong>Workaround/Solution:</strong>
                        <div class="p-3 bg-white border rounded mt-2 text-success">
                            ${problem.solution == null ? '<i>No solution provided</i>' : problem.solution}
                        </div>
                    </div>
                </div>

                <c:set var="canManage" value="false" />
                <c:if test="${problem.status ne 'CANCELLED'}">
                    <c:choose>
                        <c:when test="${not empty problem.assignedTo}">
                            <c:if test="${problem.assignedTo == sessionScope.user.userId}">
                                <c:set var="canManage" value="true" />
                            </c:if>
                        </c:when>
                        <c:otherwise>
                            <c:if test="${problem.reportedBy == sessionScope.user.userId}">
                                <c:set var="canManage" value="true" />
                            </c:if>
                        </c:otherwise>
                    </c:choose>
                </c:if>

                <div class="d-flex gap-2 mt-4">
                    <c:if test="${canManage}">
                        <c:if test="${problem.status eq 'NEW' || problem.status eq 'IN_PROGRESS'}">
                            <a href="${pageContext.request.contextPath}/problem?action=edit&id=${problem.ticketId}"
                                class="btn btn-warning">
                                <i class="bi bi-pencil"></i> Edit/Update RCA
                            </a>
                            <button type="button" class="btn btn-danger" data-bs-toggle="modal"
                                data-bs-target="#cancelModal">
                                <i class="bi bi-x-circle"></i> Cancel Ticket
                            </button>
                        </c:if>
                    </c:if>
                </div>
            </div>

            <div class="container-fluid bg-white p-4 rounded shadow-sm mb-4">
                <h3 class="h5 mb-3 text-secondary">Linked Incidents</h3>
                <c:if test="${not empty linkedIncidents}">
                    <ul class="list-group">
                        <c:forEach var="inc" items="${linkedIncidents}">
                            <li class="list-group-item d-flex justify-content-between align-items-center">
                                <span><strong>${inc.ticketNumber}</strong> - ${inc.title}</span>
                                <span class="badge bg-secondary rounded-pill">${inc.status}</span>
                            </li>
                        </c:forEach>
                    </ul>
                </c:if>
                <c:if test="${empty linkedIncidents}">
                    <p class="text-muted fst-italic">No incidents linked to this problem.</p>
                </c:if>
            </div>

            <div class="container-fluid bg-white p-4 rounded shadow-sm mb-4">
                <h3 class="h5 mb-3 text-secondary">Investigation Comments</h3>

                <c:if test="${not empty comments}">
                    <div class="mb-4">
                        <c:forEach var="cmt" items="${comments}">
                            <div class="card mb-2 border-0 bg-light">
                                <div class="card-body py-2 px-3">
                                    <div class="d-flex justify-content-between align-items-center mb-1">
                                        <strong><i class="bi bi-person-circle"></i> ${cmt.userName}</strong>
                                        <small class="text-muted">
                                            <fmt:formatDate value="${cmt.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                        </small>
                                    </div>
                                    <p class="mb-0 text-dark" style="white-space: pre-wrap;">${cmt.commentText}</p>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/problem?action=addComment" method="post">
                    <input type="hidden" name="id" value="${problem.ticketId}">
                    <div class="mb-3">
                        <textarea class="form-control" name="commentText" rows="3"
                            placeholder="Add a new finding, note, or update..." required></textarea>
                    </div>
                    <button type="submit" class="btn btn-primary btn-sm">
                        <i class="bi bi-chat-dots"></i> Post Comment
                    </button>
                    <!-- Small instruction label -->
                    <div class="form-text mt-2">
                        Use this to document findings and communicate between IT Manager and Technical Expert.
                    </div>
                </form>
            </div>

            <!-- Cancel Problem Modal -->
            <div class="modal fade" id="cancelModal" tabindex="-1" aria-labelledby="cancelModalLabel"
                aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="cancelModalLabel">Cancel Problem Ticket</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <form action="${pageContext.request.contextPath}/problem?action=cancel" method="post">
                            <div class="modal-body">
                                <input type="hidden" name="id" value="${problem.ticketId}">
                                <div class="mb-3">
                                    <label for="cancelReason" class="form-label fw-bold">Cancellation Reason <span
                                            class="text-danger">*</span></label>
                                    <textarea class="form-control" id="cancelReason" name="cancelReason" rows="3"
                                        required></textarea>
                                    <div class="form-text">Please provide a reason for cancelling this investigation.
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                <button type="submit" class="btn btn-danger">Confirm Cancel</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <jsp:include page="/includes/footer.jsp" />