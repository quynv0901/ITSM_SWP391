<jsp:include page="/includes/header.jsp" />
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%-- Thư viện FullCalendar để vẽ Lịch --%>
<script src='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js'></script>

<div class="container-fluid bg-white p-4 rounded shadow-sm">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="h4 text-primary m-0"><i class="bi bi-arrow-repeat me-2"></i>Change Request Management</h2>
        <a href="${pageContext.request.contextPath}/change-request/create" class="btn btn-primary">
                <i class="bi bi-plus-lg me-1"></i> New Change
            </a>
<!--        <button class="btn btn-success shadow-sm"><i class="bi bi-plus-lg me-1"></i> New Change</button>-->
    </div>

    <%-- Thanh Filter --%>
    <form action="${pageContext.request.contextPath}/change-request/list" method="get" class="row g-3 mb-4 bg-light p-3 rounded border mx-0">
        <div class="col-md-6">
            <input type="text" name="search" class="form-control" placeholder="Search Change Requests..." value="${search}">
        </div>
        <div class="col-md-3">
            <select name="statusFilter" class="form-select">
                <option value="">All Statuses</option>
                <option value="NEW" ${statusFilter == 'NEW' ? 'selected' : ''}>NEW</option>
                <option value="APPROVED" ${statusFilter == 'APPROVED' ? 'selected' : ''}>APPROVED</option>
                <option value="IN_PROGRESS" ${statusFilter == 'IN_PROGRESS' ? 'selected' : ''}>IN PROGRESS</option>
                <option value="RESOLVED" ${statusFilter == 'RESOLVED' ? 'selected' : ''}>RESOLVED</option>
                <option value="CLOSED" ${statusFilter == 'CLOSED' ? 'selected' : ''}>CLOSED</option>
            </select>
        </div>
        <div class="col-md-3 d-flex gap-2">
            <button type="submit" class="btn btn-primary w-100"><i class="bi bi-search"></i> Filter</button>
            <a href="${pageContext.request.contextPath}/change-request/list" class="btn btn-outline-secondary"><i class="bi bi-x-circle"></i></a>
        </div>
    </form>

    <%-- ĐIỀU HƯỚNG TAB: LIST VIEW & CALENDAR VIEW --%>
    <ul class="nav nav-tabs mb-4" id="changeRequestTabs" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-link active fw-bold" id="list-tab" data-bs-toggle="tab" data-bs-target="#list-view" type="button" role="tab">
                <i class="bi bi-list-task me-1"></i> List View
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link fw-bold" id="calendar-tab" data-bs-toggle="tab" data-bs-target="#calendar-view" type="button" role="tab">
                <i class="bi bi-calendar-month me-1"></i> Calendar View
            </button>
        </li>
    </ul>

    <div class="tab-content" id="myTabContent">
        <%-- TAB 1: LIST VIEW --%>
        <div class="tab-pane fade show active" id="list-view" role="tabpanel">
            
            <%-- FORM DÙNG CHO BULK DELETE --%>
            <form action="${pageContext.request.contextPath}/change-request/delete" method="post" id="bulkDeleteForm">
                <input type="hidden" name="actionType" value="bulk">
                
                <div class="d-flex justify-content-end mb-2">
                    <button type="submit" class="btn btn-danger btn-sm shadow-sm" onclick="return confirm('Xóa vĩnh viễn các Change Request đã chọn?');">
                        <i class="bi bi-trash"></i> Delete Selected
                    </button>
                </div>
                <%-- Nút Approve/Reject: Dành cho CAB Member (Chuyển hướng form sang Review Servlet) --%>
                    <c:if test="${sessionScope.user.roleId == 7}">
                        <button type="submit" name="decision" value="APPROVED" class="btn btn-success btn-sm shadow-sm" 
                                formaction="${pageContext.request.contextPath}/change-request/review" onclick="return confirm('Duyệt tất cả các phiếu đã chọn?');">
                            <i class="bi bi-check-circle"></i> Approve Selected
                        </button>
                        <button type="submit" name="decision" value="REJECTED" class="btn btn-outline-danger btn-sm shadow-sm" 
                                formaction="${pageContext.request.contextPath}/change-request/review" onclick="return confirm('Từ chối tất cả các phiếu đã chọn?');">
                            <i class="bi bi-x-circle"></i> Reject Selected
                        </button>
                    </c:if>

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
                                        <c:if test="${((sessionScope.user.roleId == 6 or sessionScope.user.roleId == 3) and cr.status eq 'NEW' and empty cr.cabRiskAssessment) 
                                                   or (sessionScope.user.roleId == 7 and cr.cabDecision ne 'APPROVED' and cr.cabDecision ne 'REJECTED')}">
                                            <input class="form-check-input cr-checkbox" type="checkbox" name="ticketIds" value="${cr.ticketId}">
                                        </c:if>
                                    </td>
                                    <td><strong>#CR-${cr.ticketId}</strong></td>
                                    <td class="text-primary fw-bold">${cr.title}</td>
                                    <td><span class="badge ${cr.priority == 'CRITICAL' ? 'bg-danger' : 'bg-warning text-dark'}">${cr.priority}</span></td>
                                    <td><span class="badge bg-secondary ${cr.status eq 'NEW' ? 'bg-primary' : (cr.status eq 'APPROVED' ? 'bg-primary' : 'bg-secondary')}">${cr.status}</span></td>
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
                                        <a href="${pageContext.request.contextPath}/change-request/detail?id=${cr.ticketId}" class="btn btn-sm btn-outline-primary"><i class="bi bi-eye"></i> View</a>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty crList}">
                                <tr><td colspan="7" class="text-center text-muted py-4">No change requests found.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </form>
        </div>

        <%-- TAB 2: CALENDAR VIEW --%>
        <div class="tab-pane fade" id="calendar-view" role="tabpanel">
            <div id="calendar" style="min-height: 600px; padding: 10px;"></div>
        </div>
    </div>
</div>

<%-- Script Render Calendar --%>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Lấy thẻ hiển thị lịch
        var calendarEl = document.getElementById('calendar');
        
        // Khởi tạo Lịch
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
                <%-- Chuyển đổi List Java thành mảng JSON cho Calendar --%>
                <c:forEach var="cr" items="${crList}" varStatus="loop">
                {
                    title: '#CR-${cr.ticketId} - ${cr.title}',
                    
                    <%-- ĐÃ SỬA: Thêm 'T'HH:mm:ss vào pattern để FullCalendar nhận diện chính xác giờ kết thúc --%>
                    start: '<fmt:formatDate value="${not empty cr.scheduledStart ? cr.scheduledStart : cr.createdAt}" pattern="yyyy-MM-dd\'T\'HH:mm:ss" />', 
                    
                    <c:if test="${not empty cr.scheduledEnd}">
                    end: '<fmt:formatDate value="${cr.scheduledEnd}" pattern="yyyy-MM-dd\'T\'HH:mm:ss" />',
                    </c:if>
                    
                    url: '${pageContext.request.contextPath}/change-request/detail?id=${cr.ticketId}',
                    color: '${cr.status eq "NEW" ? "#0d6efd" : (cr.status eq "APPROVED" ? "#198754" : (cr.status eq "IN_PROGRESS" ? "#0dcaf0" : "#6c757d"))}'
                }${!loop.last ? ',' : ''}
                </c:forEach>
            ]
        });

        // Fix lỗi lịch bị bóp nhỏ khi nằm trong Tab ẩn (Fix của Bootstrap)
        var calendarTab = document.getElementById('calendar-tab');
        calendarTab.addEventListener('shown.bs.tab', function () {
            calendar.render(); // Render lại lịch khi bấm sang Tab Lịch
        });
    });
</script>
<script>
    // Xử lý Checkbox Select All cho Tab List
    document.addEventListener("DOMContentLoaded", function() {
        const selectAll = document.getElementById('selectAll');
        const checkboxes = document.querySelectorAll('.cr-checkbox');
        if(selectAll) {
            selectAll.addEventListener('change', function() {
                checkboxes.forEach(cb => cb.checked = selectAll.checked);
            });
        }
    });
</script>
<jsp:include page="/includes/footer.jsp" />