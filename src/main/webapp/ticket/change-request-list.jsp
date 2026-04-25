<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/includes/header.jsp" />

<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js"></script>

<style>
    .change-tabs .nav-link {
        font-weight: 700;
        color: #334155;
        border-radius: 12px 12px 0 0;
        padding: 12px 18px;
    }

    .change-tabs .nav-link.active {
        color: #0d6efd;
        background-color: #fff;
        border-color: #dee2e6 #dee2e6 #fff;
    }

    .calendar-wrapper {
        background: #fff;
        border: 1px solid #e5e7eb;
        border-radius: 16px;
        padding: 16px;
        box-shadow: 0 0.125rem 0.25rem rgba(0,0,0,.04);
    }

    .calendar-legend {
        display: flex;
        flex-wrap: wrap;
        gap: 12px 20px;
        margin-bottom: 14px;
        font-size: 14px;
    }

    .calendar-legend-item {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        color: #334155;
        font-weight: 600;
    }

    .calendar-legend-dot {
        width: 12px;
        height: 12px;
        border-radius: 50%;
        display: inline-block;
    }

    #changeCalendar {
        min-height: 780px;
    }

    .fc .fc-toolbar-title {
        font-size: 2rem;
        font-weight: 800;
        color: #0f172a;
        text-transform: lowercase;
    }

    .fc .fc-button {
        border-radius: 10px !important;
        padding: 8px 14px !important;
        font-weight: 700;
        box-shadow: none !important;
    }

    .fc .fc-daygrid-day-number,
    .fc .fc-col-header-cell-cushion {
        color: #334155;
        text-decoration: none !important;
        font-weight: 700;
    }

    .fc .fc-day-today {
        background: #eff6ff !important;
    }

    .fc .fc-daygrid-day-frame {
        min-height: 120px;
        padding: 4px;
    }

    .fc .fc-event {
        border: none !important;
        border-radius: 10px !important;
        padding: 3px 6px !important;
        font-size: 12px;
        font-weight: 700;
        cursor: pointer;
        box-shadow: 0 2px 6px rgba(15, 23, 42, 0.10);
    }

    .fc-event-main-custom {
        display: flex;
        flex-direction: column;
        gap: 2px;
        line-height: 1.3;
    }

    .fc-event-time-custom {
        font-size: 11px;
        opacity: 0.95;
    }

    .fc-event-title-custom {
        font-size: 12px;
        white-space: normal;
        word-break: break-word;
    }

    .calendar-helper-text {
        color: #64748b;
        font-size: 14px;
        margin-bottom: 12px;
    }

    @media (max-width: 768px) {
        .fc .fc-toolbar {
            flex-direction: column;
            gap: 10px;
            align-items: flex-start;
        }

        .fc .fc-toolbar-title {
            font-size: 1.5rem;
        }

        #changeCalendar {
            min-height: 650px;
        }
    }
</style>

<div class="container-fluid bg-white p-4 rounded shadow-sm">
    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
        <h2 class="h4 text-primary m-0">
            <i class="bi bi-arrow-repeat me-2"></i>Danh sách yêu cầu thay đổi
        </h2>

        <c:if test="${sessionScope.user.roleId == 6}">
            <a href="${pageContext.request.contextPath}/change-request-list/create" class="btn btn-primary">
                <i class="bi bi-plus-circle me-1"></i>Tạo yêu cầu thay đổi
            </a>
        </c:if>
    </div>

    <c:if test="${not empty param.msg}">
        <div class="alert alert-info alert-dismissible fade show" role="alert">
            <c:choose>
                <c:when test="${param.msg eq 'created'}">Tạo yêu cầu thay đổi thành công.</c:when>
                <c:when test="${param.msg eq 'updated'}">Cập nhật yêu cầu thay đổi thành công.</c:when>
                <c:when test="${param.msg eq 'deleted'}">Xóa yêu cầu thay đổi thành công.</c:when>
                <c:when test="${param.msg eq 'bulk_deleted'}">Đã xóa ${param.count} yêu cầu thay đổi.</c:when>
                <c:when test="${param.msg eq 'delete_failed'}">Không thể xóa yêu cầu thay đổi.</c:when>
                <c:when test="${param.msg eq 'create_failed'}">Tạo yêu cầu thay đổi thất bại.</c:when>
                <c:otherwise>Thao tác đã được thực hiện.</c:otherwise>
            </c:choose>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/change-request-list/list"
          method="get"
          accept-charset="UTF-8"
          class="row g-3 mb-4 bg-light p-3 rounded border mx-0">
        <div class="col-md-6">
            <input type="text" name="search" class="form-control" placeholder="Tìm theo mã phiếu, tiêu đề hoặc mô tả..." value="${search}">
        </div>
        <div class="col-md-3">
            <select name="statusFilter" class="form-select">
                <option value="">Tất cả trạng thái</option>
                <option value="NEW" ${statusFilter eq 'NEW' ? 'selected' : ''}>Mới</option>
                <option value="ASSIGNED" ${statusFilter eq 'ASSIGNED' ? 'selected' : ''}>Đã phân công</option>
                <option value="APPROVED" ${statusFilter eq 'APPROVED' ? 'selected' : ''}>Đã duyệt</option>
                <option value="IN_PROGRESS" ${statusFilter eq 'IN_PROGRESS' ? 'selected' : ''}>Đang thực hiện</option>
                <option value="RESOLVED" ${statusFilter eq 'RESOLVED' ? 'selected' : ''}>Đã hoàn tất</option>
                <option value="CANCELLED" ${statusFilter eq 'CANCELLED' ? 'selected' : ''}>Đã hủy</option>
                <option value="CLOSED" ${statusFilter eq 'CLOSED' ? 'selected' : ''}>Đã đóng</option>
            </select>
        </div>
        <div class="col-md-3 d-flex gap-2">
            <button type="submit" class="btn btn-primary w-100"><i class="bi bi-search"></i> Lọc</button>
            <a href="${pageContext.request.contextPath}/change-request-list/list" class="btn btn-outline-secondary"><i class="bi bi-x-circle"></i></a>
        </div>
    </form>

    <ul class="nav nav-tabs mb-4 change-tabs" id="changeRequestTabs" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-link active fw-bold" id="list-tab" data-bs-toggle="tab" data-bs-target="#list-view" type="button" role="tab">
                <i class="bi bi-list-task me-1"></i>Dạng danh sách
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link fw-bold" id="calendar-tab" data-bs-toggle="tab" data-bs-target="#calendar-view" type="button" role="tab">
                <i class="bi bi-calendar-month me-1"></i>Dạng lịch
            </button>
        </li>
    </ul>

    <div class="tab-content">
        <div class="tab-pane fade show active" id="list-view" role="tabpanel">
            <c:if test="${sessionScope.user.roleId == 6}">
                <form action="${pageContext.request.contextPath}/change-request-list/delete" method="post" onsubmit="return confirm('Bạn có chắc chắn muốn xóa các phiếu đã chọn không?');">
                    <input type="hidden" name="actionType" value="bulk">
                    <div class="mb-3">
                        <button type="submit" class="btn btn-danger btn-sm"><i class="bi bi-trash"></i> Xóa hàng loạt</button>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-hover table-bordered align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th style="width: 40px;"><input type="checkbox" onclick="toggleAll(this)"></th>
                                    <th>Mã phiếu</th>
                                    <th>Tiêu đề</th>
                                    <th>Loại thay đổi</th>
                                    <th>Mức rủi ro</th>
                                    <th>Trạng thái</th>
                                    <th>Người tạo</th>
                                    <th>Người xử lý</th>
                                    <th>Lịch dự kiến</th>
                                    <th class="text-center">Chi tiết</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="cr" items="${changeRequests}">
                                    <tr>
                                        <td><input type="checkbox" name="ticketIds" value="${cr.ticketId}"></td>
                                        <td>${cr.ticketNumber}</td>
                                        <td>${cr.title}</td>
                                        <td>${cr.changeType}</td>
                                        <td>${cr.riskLevel}</td>
                                        <td>${cr.status}</td>
                                        <td>${cr.reportedByName}</td>
                                        <td>
                                            ${empty cr.assignedToName 
                                              ? '<span class="badge bg-secondary">Không có</span>' 
                                              : cr.assignedToName}
                                        </td>
                                        <td>
                                            <div><fmt:formatDate value="${cr.scheduledStart}" pattern="dd/MM/yyyy HH:mm" /></div>
                                            <div><fmt:formatDate value="${cr.scheduledEnd}" pattern="dd/MM/yyyy HH:mm" /></div>
                                        </td>
                                        <td class="text-center">
                                            <div class="d-flex justify-content-center gap-1 flex-wrap">
                                                <a href="${pageContext.request.contextPath}/change-request-list/detail?id=${cr.ticketId}"
                                                   class="btn btn-info btn-sm text-white">
                                                    Xem
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty changeRequests}">
                                    <tr><td colspan="10" class="text-center text-muted">Không có yêu cầu thay đổi nào.</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </form>
            </c:if>

            <c:if test="${sessionScope.user.roleId != 6}">
                <div class="table-responsive">
                    <table class="table table-hover table-bordered align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>Mã phiếu</th>
                                <th>Tiêu đề</th>
                                <th>Loại thay đổi</th>
                                <th>Mức rủi ro</th>
                                <th>Trạng thái</th>
                                <th>Người tạo</th>
                                <th>Người xử lý</th>
                                <th>Lịch dự kiến</th>
                                <th class="text-center">Chi tiết</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="cr" items="${changeRequests}">
                                <tr>
                                    <td>${cr.ticketNumber}</td>
                                    <td>${cr.title}</td>
                                    <td>${cr.changeType}</td>
                                    <td>${cr.riskLevel}</td>
                                    <td>${cr.status}</td>
                                    <td>${cr.reportedByName}</td>
                                    <td>
                                        ${empty cr.assignedToName 
                                          ? '<span class="badge bg-secondary">Không có</span>' 
                                          : cr.assignedToName}
                                    </td>
                                    <td>
                                        <div><fmt:formatDate value="${cr.scheduledStart}" pattern="dd/MM/yyyy HH:mm" /></div>
                                        <div><fmt:formatDate value="${cr.scheduledEnd}" pattern="dd/MM/yyyy HH:mm" /></div>
                                    </td>
                                    <td class="text-center">
                                        <a href="${pageContext.request.contextPath}/change-request-list/detail?id=${cr.ticketId}" class="btn btn-info btn-sm text-white">Xem</a>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty changeRequests}">
                                <tr><td colspan="9" class="text-center text-muted">Không có yêu cầu thay đổi nào.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </c:if>
        </div>

        <div class="tab-pane fade" id="calendar-view" role="tabpanel">
            <div class="calendar-wrapper">
                <div class="calendar-helper-text">
                    Lịch hiển thị các yêu cầu thay đổi theo thời gian dự kiến thực hiện. Nhấp vào một mục trên lịch để mở chi tiết phiếu.
                </div>

                <div class="calendar-legend">
                    <span class="calendar-legend-item"><span class="calendar-legend-dot" style="background:#3b82f6;"></span>Mới</span>
                    <span class="calendar-legend-item"><span class="calendar-legend-dot" style="background:#8b5cf6;"></span>Đã phân công</span>
                    <span class="calendar-legend-item"><span class="calendar-legend-dot" style="background:#f59e0b;"></span>Đang thực hiện</span>
                    <span class="calendar-legend-item"><span class="calendar-legend-dot" style="background:#10b981;"></span>Đã hoàn tất</span>
                    <span class="calendar-legend-item"><span class="calendar-legend-dot" style="background:#ef4444;"></span>Đã hủy</span>
                    <span class="calendar-legend-item"><span class="calendar-legend-dot" style="background:#64748b;"></span>Khác</span>
                </div>

                <div id="changeCalendar"></div>
            </div>
        </div>

        <div class="d-flex justify-content-between align-items-center mt-4 flex-wrap gap-2">
            <div class="text-muted">
                Tổng số: ${totalItems} bản ghi
            </div>

            <nav>
                <ul class="pagination mb-0">
                    <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                        <a class="page-link"
                           href="${pageContext.request.contextPath}/change-request-list/list?page=${currentPage - 1}&search=${search}&statusFilter=${statusFilter}">
                            Trước
                        </a>
                    </li>

                    <c:forEach begin="1" end="${totalPages}" var="p">
                        <li class="page-item ${p == currentPage ? 'active' : ''}">
                            <a class="page-link"
                               href="${pageContext.request.contextPath}/change-request-list/list?page=${p}&search=${search}&statusFilter=${statusFilter}">
                                ${p}
                            </a>
                        </li>
                    </c:forEach>

                    <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                        <a class="page-link"
                           href="${pageContext.request.contextPath}/change-request-list/list?page=${currentPage + 1}&search=${search}&statusFilter=${statusFilter}">
                            Sau
                        </a>
                    </li>
                </ul>
            </nav>
        </div>
    </div>
</div>



<script>
    function toggleAll(source) {
        const checkboxes = document.querySelectorAll('input[name="ticketIds"]');
        checkboxes.forEach(cb => cb.checked = source.checked);
    }

    function getEventColorByStatus(status) {
        switch (status) {
            case 'NEW':
                return '#3b82f6';
            case 'ASSIGNED':
            case 'APPROVED':
                return '#8b5cf6';
            case 'IN_PROGRESS':
                return '#f59e0b';
            case 'RESOLVED':
            case 'CLOSED':
                return '#10b981';
            case 'CANCELLED':
                return '#ef4444';
            default:
                return '#64748b';
        }
    }

    let changeCalendar = null;
    let calendarInitialized = false;

    function initChangeCalendar() {
        const calendarEl = document.getElementById('changeCalendar');
        if (!calendarEl || calendarInitialized) {
            if (changeCalendar) {
                changeCalendar.updateSize();
            }
            return;
        }

        const events = [
    <c:forEach var="cr" items="${changeRequests}" varStatus="loop">
        {
        title: '${cr.ticketNumber} - ${cr.title}',
                        start: '<fmt:formatDate value="${cr.scheduledStart}" pattern="yyyy-MM-dd'T'HH:mm:ss" />',
                        end: '<fmt:formatDate value="${cr.scheduledEnd}" pattern="yyyy-MM-dd'T'HH:mm:ss" />',
                        url: '${pageContext.request.contextPath}/change-request-list/detail?id=${cr.ticketId}',
                                        backgroundColor: getEventColorByStatus('${cr.status}'),
                                        borderColor: getEventColorByStatus('${cr.status}'),
                                        extendedProps: {
                                        status: '${cr.status}',
                                                ticketNumber: '${cr.ticketNumber}'
                                        }
                                }<c:if test="${not loop.last}">,</c:if>
    </c:forEach>
                                ];

                                changeCalendar = new FullCalendar.Calendar(calendarEl, {
                                    initialView: 'dayGridMonth',
                                    height: 'auto',
                                    expandRows: true,
                                    locale: 'vi',
                                    firstDay: 1,
                                    dayMaxEvents: 3,
                                    navLinks: true,
                                    displayEventTime: true,
                                    eventTimeFormat: {
                                        hour: '2-digit',
                                        minute: '2-digit',
                                        hour12: false
                                    },
                                    headerToolbar: {
                                        left: 'prev,next today',
                                        center: 'title',
                                        right: 'dayGridMonth,timeGridWeek'
                                    },
                                    buttonText: {
                                        today: 'Hôm nay',
                                        month: 'Tháng',
                                        week: 'Tuần',
                                    },
                                    noEventsContent: 'Không có lịch thay đổi trong khoảng thời gian này.',
                                    events: events,
                                    eventDisplay: 'block',
                                    eventContent: function (arg) {
                                        const timeText = arg.timeText ? '<div class="fc-event-time-custom">' + arg.timeText + '</div>' : '';
                                        const titleText = '<div class="fc-event-title-custom">' + arg.event.title + '</div>';
                                        return {
                                            html: '<div class="fc-event-main-custom">' + timeText + titleText + '</div>'
                                        };
                                    },
                                    eventDidMount: function (info) {
                                        const status = info.event.extendedProps.status || '';
                                        info.el.setAttribute('title', info.event.title + (status ? ' - ' + status : ''));
                                    }
                                });

                                changeCalendar.render();
                                calendarInitialized = true;
                            }

                            document.addEventListener('DOMContentLoaded', function () {
                                const calendarTab = document.getElementById('calendar-tab');
                                const calendarView = document.getElementById('calendar-view');

                                if (calendarView.classList.contains('show') || calendarView.classList.contains('active')) {
                                    initChangeCalendar();
                                }

                                if (calendarTab) {
                                    calendarTab.addEventListener('shown.bs.tab', function () {
                                        if (!calendarInitialized) {
                                            initChangeCalendar();
                                        } else if (changeCalendar) {
                                            changeCalendar.updateSize();
                                            changeCalendar.render();
                                        }
                                    });
                                }
                            });
</script>

<jsp:include page="/includes/footer.jsp" />
