<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="/includes/header.jsp" />

<style>
    .sla-page-title { font-size: 1.35rem; font-weight: 700; color: #2c3e50; margin-bottom: 4px; }
    .sla-page-sub { color: #6c757d; font-size: .92rem; margin-bottom: 14px; }
    .sla-card { background: #fff; border: 1px solid #e9ecef; border-radius: 14px; box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05); padding: 16px; margin-bottom: 16px; }
    .sla-card-title { font-size: .95rem; font-weight: 700; color: #344767; text-transform: uppercase; letter-spacing: .4px; margin-bottom: 12px; }
    .sla-tabs { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 14px; }
    .sla-tab { border: 1px solid #b6d9ec; background: #eef7fc; color: #2f77a3; padding: 7px 12px; border-radius: 999px; text-decoration: none; font-size: 13px; font-weight: 600; }
    .sla-tab.active { background: #3c8dbc; color: #fff; border-color: #3c8dbc; }
    .sla-filter-row { display: flex; gap: 12px; align-items: end; flex-wrap: wrap; }
    .sla-filter-group label { font-size: 12px; color: #6c757d; margin-bottom: 4px; display: block; }
    .sla-filter-group input { border: 1px solid #d1d5db; border-radius: 8px; padding: 8px 10px; min-width: 150px; }
    .sla-btn { border: 0; border-radius: 8px; padding: 8px 14px; font-size: 13px; font-weight: 600; text-decoration: none; display: inline-flex; align-items: center; gap: 6px; cursor: pointer; }
    .sla-btn-primary { color: #fff; background: #3c8dbc; }
    .sla-btn-outline { color: #3c8dbc; background: #eef7fc; border: 1px solid #b6d9ec; }
    .sla-alert { border-radius: 10px; padding: 10px 12px; margin-bottom: 14px; font-size: 13px; border: 1px solid #ffe69c; background: #fff8e1; color: #8a6d3b; }
    .sla-kpi-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 12px; }
    .sla-kpi { border-radius: 12px; color: #fff; padding: 14px 14px 12px; position: relative; overflow: hidden; box-shadow: 0 6px 16px rgba(0,0,0,0.08); }
    .kpi-blue { background: linear-gradient(135deg,#3c8dbc,#2f77a3); } .kpi-green { background: linear-gradient(135deg,#16a085,#0e7a67); } .kpi-red { background: linear-gradient(135deg,#e74c3c,#c0392b); } .kpi-purple { background: linear-gradient(135deg,#8e44ad,#6f34a0); }
    .sla-kpi-label { font-size: 12px; color: rgba(255,255,255,.9); margin-bottom: 6px; }
    .sla-kpi-value { font-size: 1.75rem; font-weight: 700; line-height: 1.1; }
    .sla-table { width: 100%; border-collapse: collapse; font-size: 13px; }
    .sla-table th { text-align: left; background: #f7fafc; color: #6b7280; font-size: 11px; text-transform: uppercase; letter-spacing: .45px; padding: 10px 12px; border-bottom: 2px solid #edf2f7; }
    .sla-table td { padding: 10px 12px; border-bottom: 1px solid #f1f5f9; vertical-align: top; }
    .sla-pill { display: inline-block; border-radius: 999px; background: #eef2ff; color: #3730a3; padding: 2px 8px; font-size: 12px; font-weight: 600; }
    .pri-low { background:#ecfdf5; color:#047857; border:1px solid #a7f3d0; } .pri-medium, .pri-normal { background:#fffbeb; color:#b45309; border:1px solid #fde68a; } .pri-high { background:#fff7ed; color:#c2410c; border:1px solid #fdba74; } .pri-critical, .pri-urgent { background:#fef2f2; color:#b91c1c; border:1px solid #fecaca; }
    .txt-danger { color: #c0392b; font-weight: 600; } .txt-success { color: #0b8457; font-weight: 600; } .mono { font-family: Consolas, monospace; }
    .sla-paging { display: flex; justify-content: space-between; align-items: center; gap: 8px; margin-top: 12px; flex-wrap: wrap; }
</style>

<c:url var="overviewUrl" value="/sla-dashboard"><c:param name="view" value="overview" /><c:param name="responseHours" value="${responseHours}" /></c:url>
<c:url var="performanceUrl" value="/sla-dashboard"><c:param name="view" value="performance" /><c:param name="responseHours" value="${responseHours}" /><c:param name="pageSize" value="${pageSize}" /></c:url>
<c:url var="escalationUrl" value="/sla-dashboard"><c:param name="view" value="escalation" /><c:param name="responseHours" value="${responseHours}" /><c:param name="pageSize" value="${pageSize}" /></c:url>
<c:url var="matrixUrl" value="/sla-dashboard"><c:param name="view" value="matrix" /></c:url>
<c:url var="feedbackUrl" value="/sla-dashboard"><c:param name="view" value="feedback" /><c:param name="pageSize" value="${pageSize}" /></c:url>

<div class="container-fluid bg-white p-4 rounded shadow-sm">
<div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
    <div>
<div class="sla-page-title">SLA & Năng suất xử lý</div>
<div class="sla-page-sub">
    Mỗi màn hình chỉ hiển thị một nhóm thông tin để giảm tải nội dung.
</div>
    </div>
    <div class="d-flex gap-2 flex-wrap">
        <a class="sla-btn sla-btn-outline" href="${pageContext.request.contextPath}/incident?action=list">Danh sách incident</a>
        <a class="sla-btn sla-btn-outline" href="${pageContext.request.contextPath}/home">Trang chủ</a>
    </div>
</div>

<div class="sla-tabs">
    <a class="sla-tab ${view eq 'overview' ? 'active' : ''}" href="${overviewUrl}">Tổng quan SLA</a>
    <a class="sla-tab ${view eq 'performance' ? 'active' : ''}" href="${performanceUrl}">Năng suất nhân sự</a>
    <a class="sla-tab ${view eq 'escalation' ? 'active' : ''}" href="${escalationUrl}">Hàng chờ leo thang</a>
    <a class="sla-tab ${view eq 'matrix' ? 'active' : ''}" href="${matrixUrl}">Ma trận tác động/khẩn cấp</a>
    <a class="sla-tab ${view eq 'feedback' ? 'active' : ''}" href="${feedbackUrl}">Phản hồi người dùng</a>
</div>

<div class="sla-card">
    <div class="sla-card-title">Bộ lọc</div>
    <form method="get" action="${pageContext.request.contextPath}/sla-dashboard" class="sla-filter-row">
        <input type="hidden" name="view" value="${view}" />
        <div class="sla-filter-group">
            <label for="responseHours">Ngưỡng NEW quá hạn (giờ)</label>
            <input id="responseHours" name="responseHours" type="number" min="1" max="336" value="${responseHours}">
        </div>
        <div class="sla-filter-group">
            <label for="pageSize">Số dòng mỗi trang</label>
            <input id="pageSize" name="pageSize" type="number" min="1" max="50" value="${pageSize}">
        </div>
        <c:if test="${view eq 'escalation'}">
            <div class="sla-filter-group">
                <label for="onlyUnassigned">Lọc backlog</label>
                <input id="onlyUnassigned" name="onlyUnassigned" type="checkbox" value="1" ${onlyUnassigned ? 'checked' : ''}>
                <span style="font-size:12px;color:#6c757d;">Chỉ ticket chưa gán</span>
            </div>
        </c:if>
        <c:if test="${view eq 'feedback'}">
            <div class="sla-filter-group">
                <label for="rating">Lọc số sao</label>
                <input id="rating" name="rating" type="number" min="1" max="5" value="${rating}">
            </div>
        </c:if>
        <button class="sla-btn sla-btn-primary" type="submit">Áp dụng</button>
        <a class="sla-btn sla-btn-outline" href="${pageContext.request.contextPath}/sla-dashboard?view=${view}">Đặt lại</a>
        <a class="sla-btn sla-btn-outline" href="${pageContext.request.contextPath}/sla-dashboard?action=impact-urgency-template">Tải mẫu Excel/CSV</a>
    </form>
</div>

<c:if test="${responseHoursAdjusted or pageAdjusted or pageSizeAdjusted}">
    <div class="sla-alert">Một số tham số không hợp lệ đã được tự động chỉnh về giá trị an toàn.</div>
</c:if>

<c:if test="${view eq 'feedback'}">
    <div class="sla-card">
        <div class="sla-card-title">Danh sách feedback từ end-user</div>
        <table class="sla-table">
            <thead>
                <tr>
                    <th>Thời điểm</th><th>Phiếu</th><th>Người gửi</th><th>Nhân sự xử lý</th><th>Đánh giá</th><th>Nội dung</th><th>Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="f" items="${feedbackList}">
                    <tr>
                        <td><fmt:formatDate value="${f.submittedAt}" pattern="dd/MM/yyyy HH:mm" /></td>
                        <td><span class="mono"><c:out value="${f.ticketNumber}" /></span><br><span style="color:#64748b;"><c:out value="${f.title}" /></span></td>
                        <td><c:out value="${f.userName}" /></td>
                        <td><c:out value="${empty f.agentName ? 'Chưa gán' : f.agentName}" /></td>
                        <td><span class="sla-pill"><c:out value="${f.rating}" />/5</span></td>
                        <td><c:out value="${f.feedbackText}" /></td>
                        <td><a href="${pageContext.request.contextPath}/incident?action=detail&id=${f.ticketId}">Xem ticket</a></td>
                    </tr>
                </c:forEach>
                <c:if test="${empty feedbackList}">
                    <tr><td colspan="7">Chưa có feedback phù hợp điều kiện lọc.</td></tr>
                </c:if>
            </tbody>
        </table>

        <div class="sla-paging">
            <div>Trang <b><c:out value="${page}" /></b>/<c:out value="${totalPages}" /> - Tổng <b><c:out value="${totalRecords}" /></b> feedback</div>
            <div class="sla-filter-row">
                <c:if test="${page > 1}">
                    <a class="sla-btn sla-btn-outline" href="${pageContext.request.contextPath}/sla-dashboard?view=feedback&responseHours=${responseHours}&pageSize=${pageSize}&rating=${rating}&page=${page-1}">Trang trước</a>
                </c:if>
                <c:if test="${page < totalPages}">
                    <a class="sla-btn sla-btn-outline" href="${pageContext.request.contextPath}/sla-dashboard?view=feedback&responseHours=${responseHours}&pageSize=${pageSize}&rating=${rating}&page=${page+1}">Trang sau</a>
                </c:if>
            </div>
        </div>
    </div>
</c:if>

<c:if test="${view eq 'overview'}">
    <div class="sla-card">
        <div class="sla-card-title">Tổng quan SLA</div>
        <div class="sla-kpi-grid">
            <div class="sla-kpi kpi-blue"><div class="sla-kpi-label">Sự cố đang mở</div><div class="sla-kpi-value"><c:out value="${summary.openIncidents}" /></div></div>
            <div class="sla-kpi kpi-green"><div class="sla-kpi-label">Sự cố đang ở trạng thái NEW</div><div class="sla-kpi-value"><c:out value="${summary.totalNew}" /></div></div>
            <div class="sla-kpi kpi-red"><div class="sla-kpi-label">NEW quá hạn phản hồi</div><div class="sla-kpi-value"><c:out value="${summary.overdueNew}" /></div></div>
            <div class="sla-kpi kpi-purple"><div class="sla-kpi-label">Tỷ lệ NEW quá hạn</div><div class="sla-kpi-value"><fmt:formatNumber value="${summary.overdueRatio}" maxFractionDigits="1" />%</div></div>
        </div>
    </div>

    <div class="sla-card">
        <div class="sla-card-title">Sự cố NEW quá hạn theo mức ưu tiên</div>
        <table class="sla-table">
            <thead><tr><th>Mức ưu tiên</th><th>Số phiếu NEW quá hạn</th></tr></thead>
            <tbody>
                <c:forEach var="row" items="${overdueByPriority}">
                    <tr>
                        <c:set var="priorityCss" value="${fn:toLowerCase(row.priority)}" />
                        <td><span class="sla-pill pri-${priorityCss}"><c:out value="${row.priority}" /></span></td>
                        <td class="txt-danger"><c:out value="${row.count}" /></td>
                    </tr>
                </c:forEach>
                <c:if test="${empty overdueByPriority}"><tr><td colspan="2">Không có ticket NEW quá hạn.</td></tr></c:if>
            </tbody>
        </table>
    </div>
</c:if>

<c:if test="${view eq 'performance'}">
    <div class="sla-card">
        <div class="sla-card-title">Năng suất Support Agent / Technical Expert</div>
        <table class="sla-table">
            <thead>
                <tr>
                    <th>Nhân sự</th><th>Vai trò</th><th>Được giao</th><th>Đã xử lý/đóng</th><th>Xử lý đúng hạn</th><th>Tỷ lệ đúng hạn</th><th>TB thời gian xử lý (giờ)</th><th>Tổng giờ log</th><th>Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="p" items="${performance}">
                    <tr>
                        <td><c:out value="${p.fullName}" /> <span style="color:#94a3b8;">#<c:out value="${p.userId}" /></span></td>
                        <td><c:out value="${p.roleName}" /></td>
                        <td><c:out value="${p.assignedCount}" /></td>
                        <td><c:out value="${p.resolvedCount}" /></td>
                        <td><c:out value="${p.onTimeResolved}" /></td>
                        <td>
                            <c:choose>
                                <c:when test="${p.onTimeRate >= 80}"><span class="txt-success"><fmt:formatNumber value="${p.onTimeRate}" maxFractionDigits="1" />%</span></c:when>
                                <c:otherwise><span class="txt-danger"><fmt:formatNumber value="${p.onTimeRate}" maxFractionDigits="1" />%</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td><fmt:formatNumber value="${p.avgResolutionHours}" maxFractionDigits="1" /></td>
                        <td><fmt:formatNumber value="${p.totalLoggedHours}" maxFractionDigits="1" /></td>
                        <td><a href="${pageContext.request.contextPath}/incident">Xem ticket</a></td>
                    </tr>
                </c:forEach>
                <c:if test="${empty performance}"><tr><td colspan="9">Chưa có dữ liệu năng suất cho support/expert.</td></tr></c:if>
            </tbody>
        </table>

        <div class="sla-paging">
            <div>Trang <b><c:out value="${page}" /></b>/<c:out value="${totalPages}" /> - Tổng <b><c:out value="${totalRecords}" /></b> nhân sự</div>
            <div class="sla-filter-row">
                <c:if test="${page > 1}">
                    <a class="sla-btn sla-btn-outline" href="${pageContext.request.contextPath}/sla-dashboard?view=performance&responseHours=${responseHours}&pageSize=${pageSize}&page=${page-1}">Trang trước</a>
                </c:if>
                <c:if test="${page < totalPages}">
                    <a class="sla-btn sla-btn-outline" href="${pageContext.request.contextPath}/sla-dashboard?view=performance&responseHours=${responseHours}&pageSize=${pageSize}&page=${page+1}">Trang sau</a>
                </c:if>
            </div>
        </div>
    </div>
</c:if>

<c:if test="${view eq 'escalation'}">
    <div class="sla-card">
        <div class="sla-card-title">Hàng chờ leo thang (NEW quá hạn)</div>
        <table class="sla-table">
            <thead><tr><th>Phiếu</th><th>Tiêu đề</th><th>Ưu tiên</th><th>Người báo cáo</th><th>Người xử lý</th><th>Tuổi phiếu (giờ)</th><th>Thao tác</th></tr></thead>
            <tbody>
                <c:forEach var="t" items="${overdueTickets}">
                    <tr>
                        <td class="mono"><c:out value="${t.ticketNumber}" /></td>
                        <td><c:out value="${t.title}" /></td>
                        <c:set var="ticketPriorityCss" value="${fn:toLowerCase(t.priority)}" />
                        <td><span class="sla-pill pri-${ticketPriorityCss}"><c:out value="${t.priority}" /></span></td>
                        <td><c:out value="${t.reporterName}" /></td>
                        <td><c:out value="${empty t.assigneeName ? 'Chưa gán' : t.assigneeName}" /></td>
                        <td class="txt-danger"><c:out value="${t.ageHours}" /></td>
                        <td>
                            <div class="sla-filter-row">
                                <a href="${pageContext.request.contextPath}/incident?action=detail&id=${t.ticketId}">Xem chi tiết</a>
                                <c:if test="${empty t.assignedTo}">
                                    <form action="${pageContext.request.contextPath}/incident" method="post" class="sla-filter-row" style="margin:0;">
                                        <input type="hidden" name="action" value="assign">
                                        <input type="hidden" name="id" value="${t.ticketId}">
                                        <select name="assignedTo" required style="border:1px solid #d1d5db;border-radius:6px;padding:4px 6px;font-size:12px;min-width:170px;">
                                            <option value="">-- Giao nhanh --</option>
                                            <c:forEach var="a" items="${assignableAgents}">
                                                <option value="${a.userId}"><c:out value="${a.fullName}" /> (<c:out value="${a.roleName}" />)</option>
                                            </c:forEach>
                                        </select>
                                        <button class="sla-btn sla-btn-primary" type="submit" style="padding:5px 10px;font-size:12px;">Giao</button>
                                    </form>
                                </c:if>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty overdueTickets}"><tr><td colspan="7">Không có ticket NEW quá hạn cần escalation.</td></tr></c:if>
            </tbody>
        </table>

        <div class="sla-paging">
            <div>Trang <b><c:out value="${page}" /></b>/<c:out value="${totalPages}" /> - Tổng <b><c:out value="${totalRecords}" /></b> ticket quá hạn</div>
            <div class="sla-filter-row">
                <c:if test="${page > 1}">
                    <a class="sla-btn sla-btn-outline" href="${pageContext.request.contextPath}/sla-dashboard?view=escalation&responseHours=${responseHours}&pageSize=${pageSize}&onlyUnassigned=${onlyUnassigned ? 1 : 0}&page=${page-1}">Trang trước</a>
                </c:if>
                <c:if test="${page < totalPages}">
                    <a class="sla-btn sla-btn-outline" href="${pageContext.request.contextPath}/sla-dashboard?view=escalation&responseHours=${responseHours}&pageSize=${pageSize}&onlyUnassigned=${onlyUnassigned ? 1 : 0}&page=${page+1}">Trang sau</a>
                </c:if>
            </div>
        </div>
    </div>
</c:if>

<c:if test="${view eq 'matrix'}">
    <div class="sla-card">
        <div class="sla-card-title">Ma trận tác động và độ khẩn cấp (mẫu)</div>
        <table class="sla-table">
            <thead><tr><th>Tác động</th><th>Khẩn cấp</th><th>Ưu tiên</th><th>Mục tiêu phản hồi đầu tiên</th><th>Mục tiêu xử lý xong</th><th>Quy tắc leo thang</th></tr></thead>
            <tbody>
                <tr><td>Thấp</td><td>Thấp</td><td>LOW</td><td>Trong ngày làm việc</td><td>2-4 tuần</td><td>Leo thang quản lý nếu NEW &gt; 48h</td></tr>
                <tr><td>Trung bình</td><td>Trung bình</td><td>MEDIUM/NORMAL</td><td>Trong ngày làm việc</td><td>1-2 tuần</td><td>Leo thang quản lý nếu NEW &gt; 48h</td></tr>
                <tr><td>Cao</td><td>Trung bình</td><td>HIGH</td><td>Trong 3 giờ</td><td>2-5 ngày</td><td>Leo thang quản lý nếu NEW &gt; 24h</td></tr>
                <tr><td>Cao</td><td>Cao</td><td>CRITICAL/URGENT</td><td>Trong 1 giờ</td><td>Trong 1 ngày</td><td>Báo quản lý ngay và thông báo trưởng nhóm hỗ trợ</td></tr>
            </tbody>
        </table>
    </div>
</c:if>
</div>

<jsp:include page="/includes/footer.jsp" />
