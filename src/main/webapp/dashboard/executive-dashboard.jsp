<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
    /* ── KPI Hero cards ──────────────────────────────────────────────── */
    .hero-kpi-row {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(190px, 1fr));
        gap: 16px;
        margin-bottom: 28px;
    }

    .hero-card {
        border-radius: 12px;
        padding: 22px 24px;
        color: #fff;
        position: relative;
        overflow: hidden;
        box-shadow: 0 4px 18px rgba(0, 0, 0, .14);
        transition: transform .2s, box-shadow .2s;
    }

    .hero-card:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 28px rgba(0, 0, 0, .18);
    }

    .hero-card .hc-label {
        font-size: 12px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: .6px;
        opacity: .85;
    }

    .hero-card .hc-value {
        font-size: 36px;
        font-weight: 900;
        line-height: 1.1;
        margin: 6px 0 2px;
    }

    .hero-card .hc-sub {
        font-size: 12px;
        opacity: .75;
    }

    .hero-card .hc-icon {
        position: absolute;
        right: 18px;
        top: 50%;
        transform: translateY(-50%);
        font-size: 52px;
        opacity: .18;
    }

    .hc-blue {
        background: linear-gradient(135deg, #3c8dbc 0%, #1a5f8a 100%);
    }

    .hc-orange {
        background: linear-gradient(135deg, #f39c12 0%, #d35400 100%);
    }

    .hc-green {
        background: linear-gradient(135deg, #27ae60 0%, #1e8449 100%);
    }

    .hc-purple {
        background: linear-gradient(135deg, #8e44ad 0%, #6c3483 100%);
    }

    .hc-teal {
        background: linear-gradient(135deg, #16a085 0%, #0e6655 100%);
    }

    /* ── Section title ───────────────────────────────────────────────── */
    .section-title {
        font-size: 14px;
        font-weight: 700;
        color: #344767;
        text-transform: uppercase;
        letter-spacing: .5px;
        margin-bottom: 14px;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    /* ── Chart grid ──────────────────────────────────────────────────── */
    .chart-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
        gap: 20px;
        margin-bottom: 28px;
    }

    .chart-card {
        background: #fff;
        border: 1px solid #e4ecf7;
        border-radius: 12px;
        padding: 20px 22px;
        box-shadow: 0 2px 10px rgba(0, 0, 0, .06);
    }

    .chart-card .chart-title {
        font-size: 14px;
        font-weight: 700;
        color: #344767;
        margin-bottom: 16px;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    /* ── Bar chart (CSS-only) ────────────────────────────────────────── */
    .bar-chart {
        width: 100%;
    }

    .bar-row {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 10px;
        font-size: 13px;
    }

    .bar-label {
        width: 120px;
        flex-shrink: 0;
        color: #4a5568;
        font-weight: 500;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }

    .bar-track {
        flex: 1;
        height: 10px;
        background: #edf2f7;
        border-radius: 99px;
        overflow: hidden;
    }

    .bar-fill {
        height: 100%;
        border-radius: 99px;
        transition: width .5s ease;
    }

    .bar-count {
        width: 50px;
        text-align: right;
        font-weight: 700;
        color: #2d3748;
        font-size: 13px;
    }

    /* ── Priority doughnut — drawn with CSS conic-gradient ─────────── */
    .donut-wrap {
        display: flex;
        align-items: center;
        gap: 22px;
        flex-wrap: wrap;
    }

    .donut-legend {
        flex: 1;
        min-width: 140px;
    }

    .legend-row {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 9px;
        font-size: 13px;
        color: #4a5568;
    }

    .legend-dot {
        width: 12px;
        height: 12px;
        border-radius: 3px;
        flex-shrink: 0;
    }

    .legend-pct {
        margin-left: auto;
        font-weight: 700;
        color: #2d3748;
    }

    /* ── Workload table ──────────────────────────────────────────────── */
    .workload-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 13.5px;
    }

    .workload-table th {
        background: #f7fafc;
        text-align: left;
        padding: 10px 14px;
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: .5px;
        color: #718096;
        border-bottom: 2px solid #edf2f7;
    }

    .workload-table td {
        padding: 10px 14px;
        border-bottom: 1px solid #f0f4f8;
        vertical-align: middle;
    }

    .workload-table tbody tr:last-child td {
        border-bottom: none;
    }

    .workload-table tbody tr:hover td {
        background: #f7fbff;
    }

    /* ── Quick-link nav ──────────────────────────────────────────────── */
    .quick-nav {
        display: flex;
        gap: 12px;
        flex-wrap: wrap;
        margin-bottom: 28px;
    }

    .qn-btn {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 10px 18px;
        border-radius: 8px;
        font-size: 13.5px;
        font-weight: 600;
        text-decoration: none;
        transition: all .15s;
    }

    .qn-btn:hover {
        filter: brightness(1.08);
        transform: translateY(-1px);
    }

    .qn-blue {
        background: #ebf5fb;
        color: #2e86c1;
        border: 1px solid #d6eaf8;
    }

    .qn-green {
        background: #eafaf1;
        color: #1e8449;
        border: 1px solid #d5f5e3;
    }

    .qn-orange {
        background: #fef9e7;
        color: #b7770d;
        border: 1px solid #fdebd0;
    }

    .qn-purple {
        background: #f4ecf7;
        color: #7d3c98;
        border: 1px solid #e8daef;
    }

    .qn-red {
        background: #fdedec;
        color: #c0392b;
        border: 1px solid #fadbd8;
    }
</style>

<%@ include file="/common/admin-layout-top.jsp" %>

<%-- ── Page header ─────────────────────────────────────────────── --%>
<div class="d-flex align-items-center justify-content-between mb-4">
    <div>
        <h4 class="fw-bold mb-0" style="color:#222d32;">
            <i class="bi bi-speedometer2 me-2 text-primary"></i>Bảng điều hành
        </h4>
        <small class="text-muted">
            Các chỉ số KPI, tuân thủ SLA và tổng quan phân bổ khối lượng công việc.
        </small>
    </div>
    <a href="${pageContext.request.contextPath}/time-tracking"
       class="btn btn-sm btn-outline-secondary">
        <i class="bi bi-clock-history me-1"></i>Theo dõi Thời gian
    </a>
</div>

<%-- ── Quick navigation ───────────────────────────────────────── --%>
<div class="quick-nav">
    <a href="${pageContext.request.contextPath}/incident?action=list" class="qn-btn qn-blue">
        <i class="bi bi-lightning-fill"></i>Sự cố</a>
    <a href="${pageContext.request.contextPath}/problem?action=list" class="qn-btn qn-orange">
        <i class="bi bi-exclamation-octagon-fill"></i>Vấn đề</a>
    <a href="${pageContext.request.contextPath}/known-error?action=list" class="qn-btn qn-red">
        <i class="bi bi-bug-fill"></i>Lỗi đã biết</a>
    <a href="${pageContext.request.contextPath}/cmdb?action=list" class="qn-btn qn-green">
        <i class="bi bi-server"></i>CMDB</a>
    <a href="${pageContext.request.contextPath}/time-tracking" class="qn-btn qn-purple">
        <i class="bi bi-clock-fill"></i>Nhật ký Thời gian</a>
</div>

<%-- ── KPI Hero Cards ─────────────────────────────────────────── --%>
<div class="hero-kpi-row">
    <div class="hero-card hc-blue">
        <div class="hc-label">Tổng phiếu</div>
        <div class="hc-value">${kpiTotalTickets}</div>
        <div class="hc-sub">Tổng hợp tất cả loại</div>
        <i class="bi bi-ticket-perforated hc-icon"></i>
    </div>
    <div class="hero-card hc-orange">
        <div class="hc-label">Phiếu đang mở</div>
        <div class="hc-value">${kpiOpenTickets}</div>
        <div class="hc-sub">Cần chú ý</div>
        <i class="bi bi-hourglass-split hc-icon"></i>
    </div>
    <div class="hero-card hc-green">
        <div class="hc-label">Đã giải quyết / Đóng</div>
        <div class="hc-value">${kpiResolvedTickets}</div>
        <div class="hc-sub">Hoàn tất</div>
        <i class="bi bi-check2-circle hc-icon"></i>
    </div>
    <div class="hero-card hc-purple">
        <div class="hc-label">Tổng giờ đã ghi</div>
        <div class="hc-value">
            <fmt:formatNumber value="${kpiTotalHours}" maxFractionDigits="1" />h
        </div>
        <div class="hc-sub">Tổng giờ cho tất cả phiếu</div>
        <i class="bi bi-clock-fill hc-icon"></i>
    </div>
    <div class="hero-card hc-teal">
        <div class="hc-label">Bản ghi Log</div>
        <div class="hc-value">${kpiLogEntries}</div>
        <div class="hc-sub">Số bản ghi Log</div>
        <i class="bi bi-journal-check hc-icon"></i>
    </div>
</div>

<%-- ── SLA Compliance indicator ───────────────────────────────── --%>
<c:set var="slaRate"
       value="${kpiTotalTickets > 0 ? (kpiResolvedTickets * 100 / kpiTotalTickets) : 0}" />
<div class="chart-card mb-4">
    <div class="chart-title"><i class="bi bi-shield-check text-success"></i> Tỷ lệ tuân thủ SLA</div>
    <div class="d-flex align-items-center gap-4 flex-wrap">
        <div
            style="font-size:48px; font-weight:900; color: ${slaRate >= 80 ? '#27ae60' : slaRate >= 50 ? '#f39c12' : '#c0392b'};">
            <fmt:formatNumber value="${slaRate}" maxFractionDigits="2" minFractionDigits="2" />%
        </div>
        <div style="flex:1; min-width:200px;">
            <div
                style="height:16px; background:#edf2f7; border-radius:99px; overflow:hidden;">
                <div
                    style="height:100%; width:${slaRate}%; border-radius:99px;
                    background: ${slaRate >= 80 ? 'linear-gradient(90deg,#27ae60,#2ecc71)' : slaRate >= 50 ? 'linear-gradient(90deg,#f39c12,#f1c40f)' : 'linear-gradient(90deg,#c0392b,#e74c3c)'};">
                </div>
            </div>
            <div class="mt-2 text-muted" style="font-size:13px;">
                <strong>${kpiResolvedTickets}</strong> đã giải quyết trong tổng
                <strong>${kpiTotalTickets}</strong> phiếu.
        <c:choose>
            <c:when test="${slaRate >= 80}"><span
                class="text-success fw-semibold"> ✓ Đạt mục tiêu</span></c:when>
            <c:when test="${slaRate >= 50}"><span
                class="text-warning fw-semibold"> ⚠ Cần chú ý</span>
            </c:when>
            <c:otherwise><span class="text-danger fw-semibold"> ✗ Chưa đạt mục tiêu</span></c:otherwise>
            </c:choose>
            </div>
        </div>
    </div>
</div>

<%-- ── Charts grid ─────────────────────────────────────────────── --%>
<div class="chart-grid">

    <%-- Ticket count by Status --%>
    <div class="chart-card">
    <div class="chart-title"><i
        class="bi bi-bar-chart-fill text-primary"></i> Phiếu theo trạng thái
    </div>
        <c:set var="maxStatus" value="1" />
        <c:forEach var="e" items="${byStatus}">
            <c:if test="${e.value > maxStatus}">
                <c:set var="maxStatus" value="${e.value}" />
            </c:if>
        </c:forEach>
        <div class="bar-chart">
            <c:forEach var="e" items="${byStatus}">
                <c:set var="pct"
                       value="${maxStatus > 0 ? (e.value * 100 / maxStatus) : 0}" />
                <c:set var="statusLabel"
                       value="${e.key == 'NEW' ? 'Mới' :
                                e.key == 'IN_PROGRESS' ? 'Đang xử lý' :
                                e.key == 'RESOLVED' ? 'Đã giải quyết' :
                                e.key == 'CLOSED' ? 'Đã đóng' :
                                e.key == 'CANCELLED' ? 'Đã hủy' :
                                e.key == 'INVESTIGATING' ? 'Đang điều tra' :
                                e.key == 'ASSIGNED' ? 'Đã phân công' :
                                e.key == 'PENDING' ? 'Đang chờ' : e.key}" />
                <div class="bar-row">
                    <div class="bar-label" title="${statusLabel}">${statusLabel}</div>
                    <div class="bar-track">
                        <div class="bar-fill" style="width:${pct}%;
                             background:${e.key == 'RESOLVED' || e.key == 'CLOSED' ? '#27ae60' :
                                          e.key == 'IN_PROGRESS' ? '#3c8dbc' :
                                          e.key == 'CANCELLED' ? '#c0392b' :
                                          e.key == 'NEW' ? '#8e44ad' : '#f39c12'};"></div>
                    </div>
                    <div class="bar-count">${e.value}</div>
                </div>
            </c:forEach>
            <c:if test="${empty byStatus}">
                <p class="text-muted text-center py-3">Chưa có dữ liệu phiếu.</p>
            </c:if>
        </div>
    </div>

    <%-- Ticket count by Type --%>
    <div class="chart-card">
    <div class="chart-title"><i
        class="bi bi-layers-fill text-warning"></i> Phiếu theo loại
    </div>
        <c:set var="maxType" value="1" />
        <c:forEach var="e" items="${byType}">
            <c:if test="${e.value > maxType}">
                <c:set var="maxType" value="${e.value}" />
            </c:if>
        </c:forEach>
        <div class="bar-chart">
            <c:forEach var="e" items="${byType}">
                <c:set var="pct"
                       value="${maxType > 0 ? (e.value * 100 / maxType) : 0}" />
                <c:set var="typeLabel"
                       value="${e.key == 'INCIDENT' ? 'Sự cố' :
                                e.key == 'SERVICE_REQUEST' ? 'Yêu cầu dịch vụ' :
                                e.key == 'PROBLEM' ? 'Vấn đề' :
                                e.key == 'CHANGE' ? 'Thay đổi' : e.key}" />
                <div class="bar-row">
                    <div class="bar-label" title="${typeLabel}">${typeLabel}</div>
                    <div class="bar-track">
                        <div class="bar-fill" style="width:${pct}%;
                             background:${e.key == 'INCIDENT' ? '#e74c3c' :
                                          e.key == 'PROBLEM' ? '#8e44ad' :
                                          e.key == 'CHANGE' ? '#f39c12' :
                                          e.key == 'SERVICE_REQUEST' ? '#3c8dbc' : '#16a085'};"></div>
                    </div>
                    <div class="bar-count">${e.value}</div>
                </div>
            </c:forEach>
            <c:if test="${empty byType}">
                <p class="text-muted text-center py-3">Chưa có dữ liệu phiếu.
                </p>
            </c:if>
        </div>
    </div>

    <%-- Ticket count by Priority --%>
    <div class="chart-card">
    <div class="chart-title"><i
        class="bi bi-flag-fill text-danger"></i> Phiếu theo mức độ ưu tiên</div>
            <c:set var="totalPri" value="0" />
            <c:forEach var="e" items="${byPriority}">
                <c:set var="totalPri" value="${totalPri + e.value}" />
            </c:forEach>

        <div class="donut-wrap">
            <div class="donut-legend" style="width:100%;">
                <c:forEach var="e" items="${byPriority}">
                    <c:set var="pct"
                           value="${totalPri > 0 ? (e.value * 100 / totalPri) : 0}" />
                    <div class="legend-row">
                        <div class="legend-dot"
                             style="background:${e.key == 'CRITICAL' ? '#c0392b' : e.key == 'HIGH' ? '#e67e22' : e.key == 'MEDIUM' ? '#f1c40f' : '#27ae60'};">
                        </div>
                        <span style="font-weight:600;">${e.key}</span>
                        <div class="bar-track"
                             style="flex:1; height:8px; margin:0 6px;">
                            <div class="bar-fill"
                                 style="width:${pct}%;
                                 background:${e.key == 'CRITICAL' ? '#c0392b' : e.key == 'HIGH' ? '#e67e22' : e.key == 'MEDIUM' ? '#f1c40f' : '#27ae60'};">
                            </div>
                        </div>
                        <span class="legend-pct">${e.value}</span>
                    </div>
                </c:forEach>
                <c:if test="${empty byPriority}">
                    <p class="text-muted text-center py-3">Chưa có dữ liệu phiếu.</p>
                    </c:if>
            </div>
        </div>
    </div>

    <%-- Agent Workload (hours logged) --%>
    <div class="chart-card">
        <div class="chart-title"><i
                class="bi bi-people-fill text-info"></i> Khối lượng công việc (Giờ đã ghi)</div>
            <c:set var="maxHours" value="1" />
            <c:forEach var="e" items="${byAgent}">
                <c:if test="${e.value > maxHours}">
                    <c:set var="maxHours" value="${e.value}" />
                </c:if>
            </c:forEach>
            <c:choose>
                <c:when test="${not empty byAgent}">
                <table class="workload-table">
                    <thead>
                        <tr>
                            <th>Nhân viên</th>
                            <th>Tiến độ</th>
                            <th style="text-align:right;">Giờ</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="e" items="${byAgent}"
                                   varStatus="s">
                            <c:set var="pct"
                                   value="${maxHours > 0 ? (e.value * 100 / maxHours) : 0}" />
                            <tr>
                                <td>
                                    <div
                                        class="d-flex align-items-center gap-2">
                                        <div class="rounded-circle d-flex align-items-center justify-content-center flex-shrink-0"
                                             style="width:28px;height:28px;background:#e8f4fd;">
                                            <i class="bi bi-person-fill text-primary"
                                               style="font-size:12px;"></i>
                                        </div>
                                        <span
                                            style="font-size:13px;font-weight:500;">${e.key}</span>
                                    </div>
                                </td>
                                <td>
                                    <div class="bar-track"
                                         style="height:8px;">
                                        <div class="bar-fill"
                                             style="width:${pct}%; background:linear-gradient(90deg,#3c8dbc,#1a6896);">
                                        </div>
                                    </div>
                                </td>
                                <td
                                    style="text-align:right; font-weight:700; color:#553c9a;">
                                    <fmt:formatNumber
                                        value="${e.value}"
                                        maxFractionDigits="1" />h
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:when>
            <c:otherwise>
                <p class="text-muted text-center py-3">Chưa có dữ liệu nhật ký thời gian.</p>
                </c:otherwise>
            </c:choose>
    </div>

</div><%-- end chart-grid --%>

<%-- ── Footer note ─────────────────────────────────────────────── --%>
<div class="text-muted text-end"
     style="font-size:12px; margin-top:8px; margin-bottom: 20px;">
    <i class="bi bi-info-circle me-1"></i>
    Dữ liệu phản ánh số liệu thời gian thực. Vui lòng làm mới trang để nhận các giá trị mới nhất.
</div>

<jsp:include page="/common/admin-layout-bottom.jsp" />