<jsp:include page="/includes/header.jsp" />
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js"></script>

<div class="container-fluid bg-white p-4 rounded shadow-sm">
    <c:if test="${not empty param.msg}">
        <div class="alert alert-info alert-dismissible fade show" role="alert">
            <c:choose>
                <c:when test="${param.msg eq 'review_success'}">Review completed successfully.</c:when>
                <c:when test="${param.msg eq 'bulk_review_success'}">Bulk review completed successfully. Updated: ${param.count}</c:when>
                <c:when test="${param.msg eq 'assessed'}">Risk assessment saved successfully.</c:when>
                <c:when test="${param.msg eq 'not_found'}">Change request not found.</c:when>
                <c:when test="${param.msg eq 'invalid_id'}">Invalid request id.</c:when>
                <c:when test="${param.msg eq 'invalid_input'}">Invalid input.</c:when>
                <c:otherwise>Action completed.</c:otherwise>
            </c:choose>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="h4 text-primary m-0">
            <i class="bi bi-arrow-repeat me-2"></i>Change Request Management
        </h2>
        <a href="${pageContext.request.contextPath}/change-request/create" class="btn btn-primary">
            <i class="bi bi-plus-lg me-1"></i> New Change
        </a>
    </div>

    <form action="${pageContext.request.contextPath}/change-request" method="get"
          class="row g-3 mb-4 bg-light p-3 rounded border mx-0">
        <input type="hidden" name="action" value="list">

        <div class="col-md-6">
            <input type="text" name="search" class="form-control"
                   placeholder="Search Change Requests..."
                   value="${search}">
        </div>

        <div class="col-md-3">
            <select name="statusFilter" class="form-select">
                <option value="">All Statuses</option>
                <option value="NEW" ${statusFilter == 'NEW' ? 'selected' : ''}>NEW</option>
                <option value="APPROVED" ${statusFilter == 'APPROVED' ? 'selected' : ''}>APPROVED</option>
                <option value="IN_PROGRESS" ${statusFilter == 'IN_PROGRESS' ? 'selected' : ''}>IN PROGRESS</option>
                <option value="RESOLVED" ${statusFilter == 'RESOLVED' ? 'selected' : ''}>RESOLVED</option>
                <option value="CLOSED" ${statusFilter == 'CLOSED' ? 'selected' : ''}>CLOSED</option>
                <option value="PENDING" ${statusFilter == 'PENDING' ? 'selected' : ''}>PENDING</option>
                <option value="CANCELLED" ${statusFilter == 'CANCELLED' ? 'selected' : ''}>CANCELLED</option>
            </select>
        </div>

        <div class="col-md-3 d-flex gap-2">
            <button type="submit" class="btn btn-primary w-100">
                <i class="bi bi-search"></i> Filter
            </button>
            <a href="${pageContext.request.contextPath}/change-request?action=list"
               class="btn btn-outline-secondary">
                <i class="bi bi-x-circle"></i>
            </a>
        </div>
    </form>

    <ul class="nav nav-tabs mb-4" id="changeRequestTabs" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-link active fw-bold" id="list-tab" data-bs-toggle="tab"
                    data-bs-target="#list-view" type="button" role="tab">
                <i class="bi bi-list-task me-1"></i> List View
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link fw-bold" id="calendar-tab" data-bs-toggle="tab"
                    data-bs-target="#calendar-view" type="button" role="tab">
                <i class="bi bi-calendar-month me-1"></i> Calendar View
            </button>
        </li>
    </ul>

    <div class="tab-content">
        <div class="tab-pane fade show active" id="list-view" role="tabpanel">
            <form action="${pageContext.request.contextPath}/change-request" method="post" id="bulkReviewForm">
                <input type="hidden" name="action" id="bulkAction" value="">

                <div class="d-flex justify-content-between align-items-center mb-2 flex-wrap gap-2">
                    <div>
                        <c:if test="${sessionScope.user.roleId == 7}">
                            <button type="submit" name="decision" value="APPROVED"
                                    class="btn btn-success btn-sm shadow-sm"
                                    onclick="document.getElementById('bulkAction').value='reviewBulk'; return confirm('Approve selected change requests?');">
                                <i class="bi bi-check-circle"></i> Approve Selected
                            </button>
                            <button type="submit" name="decision" value="REJECTED"
                                    class="btn btn-outline-danger btn-sm shadow-sm"
                                    onclick="document.getElementById('bulkAction').value='reviewBulk'; return confirm('Reject selected change requests?');">
                                <i class="bi bi-x-circle"></i> Reject Selected
                            </button>
                        </c:if>
                    </div>

                    <div>
                        <button type="submit" class="btn btn-danger btn-sm shadow-sm"
                                onclick="document.getElementById('bulkAction').value='deleteBulk'; return confirm('Delete selected change requests?');">
                            <i class="bi bi-trash"></i> Delete Selected
                        </button>
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="table table-hover table-bordered align-middle">
                        <thead class="table-light">
                            <tr>
                                <th class="text-center" style="width: 40px;">
                                    <input class="form-check-input" type="checkbox" id="selectAll">
                                </th>
                                <th>Ticket ID</th>
                                <th>Change Title</th>
                                <th>Priority</th>
                                <th>Status</th>
                                <th>Scheduled Start</th>
                                <th class="text-center">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="cr" items="${crList}">
                                <tr>
                                    <td class="text-center">
                                        <c:if test="${sessionScope.user.roleId == 7 and cr.cabDecision ne 'APPROVED' and cr.cabDecision ne 'REJECTED'}">
                                            <input class="form-check-input cr-checkbox" type="checkbox"
                                                   name="ticketIds" value="${cr.ticketId}">
                                        </c:if>
                                    </td>

                                    <td><strong>#CR-${cr.ticketId}</strong></td>
                                    <td class="text-primary fw-bold">${cr.title}</td>

                                    <td>
                                        <span class="badge ${cr.priority == 'CRITICAL' ? 'bg-danger' : (cr.priority == 'HIGH' ? 'bg-warning text-dark' : 'bg-secondary')}">
                                            ${cr.priority}
                                        </span>
                                    </td>

                                    <td>
                                        <span class="badge ${cr.status eq 'NEW' ? 'bg-primary' :
                                                             (cr.status eq 'APPROVED' ? 'bg-success' :
                                                             (cr.status eq 'IN_PROGRESS' ? 'bg-info text-dark' :
                                                             (cr.status eq 'PENDING' ? 'bg-warning text-dark' : 'bg-secondary')))}">
                                            ${cr.status}
                                        </span>
                                    </td>

                                    <td>
                                        <span class="fw-bold text-dark">
                                            <c:choose>
                                                <c:when test="${not empty cr.scheduledStart}">
                                                    <fmt:formatDate value="${cr.scheduledStart}" pattern="dd/MM/yyyy HH:mm" />
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted fst-italic">TBD</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </span>
                                    </td>

                                    <td class="text-center">
                                        <a href="${pageContext.request.contextPath}/change-request?action=detail&id=${cr.ticketId}"
                                           class="btn btn-sm btn-outline-primary">
                                            <i class="bi bi-eye"></i> View
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty crList}">
                                <tr>
                                    <td colspan="7" class="text-center text-muted py-4">
                                        No change requests found.
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </form>
        </div>

        <div class="tab-pane fade" id="calendar-view" role="tabpanel">
            <div id="calendar" style="min-height: 600px; padding: 10px;"></div>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        var calendarEl = document.getElementById('calendar');

        var calendar = new FullCalendar.Calendar(calendarEl, {
            initialView: 'dayGridMonth',
            headerToolbar: {
                left: 'prev,next today',
                center: 'title',
                right: 'dayGridMonth,timeGridWeek,listMonth'
            },
            themeSystem: 'bootstrap5',
            eventTimeFormat: {
                hour: '2-digit',
                minute: '2-digit',
                hour12: false
            },
            events: [
                <c:forEach var="cr" items="${crList}" varStatus="loop">
                {
                    title: '#CR-${cr.ticketId} - ${cr.title}',
                    start: '<fmt:formatDate value="${not empty cr.scheduledStart ? cr.scheduledStart : cr.createdAt}" pattern="yyyy-MM-dd\'T\'HH:mm:ss" />',
                    <c:if test="${not empty cr.scheduledEnd}">
                    end: '<fmt:formatDate value="${cr.scheduledEnd}" pattern="yyyy-MM-dd\'T\'HH:mm:ss" />',
                    </c:if>
                    url: '${pageContext.request.contextPath}/change-request?action=detail&id=${cr.ticketId}',
                    color: '${cr.status eq "NEW" ? "#0d6efd" : (cr.status eq "APPROVED" ? "#198754" : (cr.status eq "IN_PROGRESS" ? "#0dcaf0" : "#6c757d"))}'
                }${!loop.last ? ',' : ''}
                </c:forEach>
            ]
        });

        document.getElementById('calendar-tab').addEventListener('shown.bs.tab', function () {
            calendar.render();
        });

        const selectAll = document.getElementById('selectAll');
        const checkboxes = document.querySelectorAll('.cr-checkbox');
        if (selectAll) {
            selectAll.addEventListener('change', function () {
                checkboxes.forEach(cb => cb.checked = selectAll.checked);
            });
        }
    });
</script>

<jsp:include page="/includes/footer.jsp" />