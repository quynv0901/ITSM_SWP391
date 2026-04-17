<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="UTF-8">
        <title>Chi tiết Sự cố - ${incident.ticketNumber}</title>
        <style>
            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }

            body {
                font-family: 'Segoe UI', sans-serif;
                background: #f0f4f8;
                color: #2d3748;
                padding: 24px;
            }

            .page-header {
                display: flex;
                align-items: center;
                gap: 16px;
                margin-bottom: 24px;
            }

            .back-btn {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                padding: 8px 16px;
                background: #fff;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                color: #4a5568;
                text-decoration: none;
                font-size: 14px;
                font-weight: 500;
            }

            .back-btn:hover {
                background: #edf2f7;
            }

            .page-title {
                font-size: 22px;
                font-weight: 700;
                color: #1a202c;
            }

            .card {
                background: #fff;
                border-radius: 12px;
                box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
                padding: 24px;
                margin-bottom: 20px;
            }

            .card-title {
                font-size: 16px;
                font-weight: 700;
                color: #2d3748;
                margin-bottom: 16px;
                padding-bottom: 10px;
                border-bottom: 2px solid #e2e8f0;
            }

            .detail-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
                gap: 16px;
            }

            .detail-item label {
                font-size: 11px;
                font-weight: 600;
                color: #718096;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                display: block;
                margin-bottom: 4px;
            }

            .detail-item span {
                font-size: 14px;
                color: #2d3748;
                font-weight: 500;
            }

            .badge {
                display: inline-block;
                padding: 3px 10px;
                border-radius: 99px;
                font-size: 12px;
                font-weight: 600;
            }

            .badge-critical {
                background: #fff5f5;
                color: #c53030;
            }

            .badge-high {
                background: #fffaf0;
                color: #c05621;
            }

            .badge-medium {
                background: #fffff0;
                color: #b7791f;
            }

            .badge-low {
                background: #f0fff4;
                color: #276749;
            }

            .badge-new {
                background: #ebf8ff;
                color: #2b6cb0;
            }

            .badge-in_progress {
                background: #faf5ff;
                color: #6b46c1;
            }

            .badge-resolved {
                background: #f0fff4;
                color: #276749;
            }

            .badge-closed {
                background: #edf2f7;
                color: #4a5568;
            }

            .badge-cancelled {
                background: #fff5f5;
                color: #c53030;
            }

            .action-bar {
                display: flex;
                gap: 10px;
                flex-wrap: wrap;
                margin-top: 20px;
                padding-top: 16px;
                border-top: 1px solid #e2e8f0;
            }

            .btn {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                padding: 9px 18px;
                border-radius: 8px;
                border: none;
                cursor: pointer;
                font-size: 14px;
                font-weight: 600;
                text-decoration: none;
                transition: all 0.15s;
            }

            .btn-primary {
                background: #4299e1;
                color: #fff;
            }

            .btn-primary:hover {
                background: #3182ce;
            }

            .btn-warning {
                background: #ecc94b;
                color: #744210;
            }

            .btn-warning:hover {
                background: #d69e2e;
            }

            .btn-danger {
                background: #fc8181;
                color: #742a2a;
            }

            .btn-danger:hover {
                background: #f56565;
            }

            .tabs {
                display: flex;
                gap: 4px;
                border-bottom: 2px solid #e2e8f0;
            }

            .tab-btn {
                padding: 10px 22px;
                background: none;
                border: none;
                cursor: pointer;
                font-size: 14px;
                font-weight: 600;
                color: #718096;
                border-bottom: 2px solid transparent;
                margin-bottom: -2px;
                transition: all .15s;
            }

            .tab-btn.active {
                color: #4299e1;
                border-bottom-color: #4299e1;
            }

            .tab-btn:hover {
                color: #4299e1;
            }

            .tab-content {
                display: none;
                padding-top: 20px;
            }

            .tab-content.active {
                display: block;
            }

            .timelog-summary {
                display: flex;
                gap: 16px;
                margin-bottom: 20px;
                flex-wrap: wrap;
            }

            .timelog-stat {
                border-radius: 10px;
                padding: 16px 24px;
                min-width: 160px;
                color: #fff;
            }

            .ts-purple {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            }

            .ts-green {
                background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
            }

            .stat-value {
                font-size: 28px;
                font-weight: 800;
            }

            .stat-label {
                font-size: 12px;
                opacity: 0.85;
                margin-top: 2px;
            }

            .timelog-table {
                width: 100%;
                border-collapse: collapse;
                font-size: 14px;
            }

            .timelog-table th {
                background: #f7fafc;
                color: #718096;
                font-size: 11px;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                padding: 10px 14px;
                text-align: left;
            }

            .timelog-table td {
                padding: 12px 14px;
                border-bottom: 1px solid #f0f4f8;
                vertical-align: middle;
            }

            .timelog-table tr:hover td {
                background: #f7fafc;
            }

            .timelog-table tr:last-child td {
                border-bottom: none;
            }

            .activity-chip {
                display: inline-block;
                padding: 3px 10px;
                border-radius: 6px;
                font-size: 11px;
                font-weight: 700;
            }

            .chip-assigned {
                background: #ebf8ff;
                color: #2b6cb0;
            }

            .chip-investigation {
                background: #faf5ff;
                color: #6b46c1;
            }

            .chip-resolved {
                background: #f0fff4;
                color: #276749;
            }

            .chip-closed {
                background: #edf2f7;
                color: #4a5568;
            }

            .chip-manual {
                background: #fffaf0;
                color: #c05621;
            }

            .time-value {
                font-weight: 700;
                color: #6b46c1;
            }

            .manual-log-form {
                background: #f7fafc;
                border: 1px solid #e2e8f0;
                border-radius: 10px;
                padding: 20px;
                margin-top: 24px;
            }

            .manual-log-form h4 {
                font-size: 14px;
                font-weight: 700;
                margin-bottom: 14px;
                color: #4a5568;
            }

            .form-row {
                display: flex;
                gap: 12px;
                flex-wrap: wrap;
                align-items: flex-end;
            }

            .form-group {
                display: flex;
                flex-direction: column;
                gap: 4px;
            }

            .form-group label {
                font-size: 12px;
                font-weight: 600;
                color: #718096;
            }

            .form-group input {
                padding: 9px 12px;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                font-size: 14px;
            }

            .form-group input:focus {
                outline: none;
                border-color: #4299e1;
                box-shadow: 0 0 0 3px rgba(66, 153, 225, 0.15);
            }

            .fg-time {
                width: 140px;
            }

            .fg-desc {
                flex: 1;
                min-width: 220px;
            }

            .related-list {
                list-style: none;
            }

            .related-list li {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 10px 14px;
                background: #f7fafc;
                border-radius: 8px;
                margin-bottom: 6px;
            }

            .related-list li strong {
                color: #4299e1;
            }

            .empty-state {
                text-align: center;
                padding: 40px;
                color: #a0aec0;
            }

            .empty-icon {
                font-size: 36px;
                margin-bottom: 8px;
            }

            .alert {
                padding: 12px 16px;
                border-radius: 8px;
                font-size: 14px;
                margin-bottom: 16px;
                font-weight: 500;
            }

            .alert-success {
                background: #f0fff4;
                color: #276749;
                border: 1px solid #9ae6b4;
            }

            .alert-error {
                background: #fff5f5;
                color: #c53030;
                border: 1px solid #feb2b2;
            }

            /* Kiểu hiển thị Modal hủy ticket */
            .modal-overlay {
                display: none;
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0, 0, 0, 0.5);
                z-index: 1000;
                align-items: center;
                justify-content: center;
            }

            .modal-overlay.active {
                display: flex;
            }

            .modal-content {
                background: #fff;
                border-radius: 12px;
                width: 500px;
                max-width: 95vw;
                box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
                animation: modalSlideIn 0.2s ease-out;
            }

            @keyframes modalSlideIn {
                from {
                    opacity: 0;
                    transform: translateY(-20px) scale(0.98);
                }
                to {
                    opacity: 1;
                    transform: translateY(0) scale(1);
                }
            }

            .modal-header {
                padding: 20px 24px;
                border-bottom: 1px solid #e2e8f0;
                display: flex;
                align-items: center;
                gap: 12px;
            }

            .modal-title {
                font-size: 18px;
                font-weight: 700;
                color: #2d3748;
            }

            .modal-body {
                padding: 20px 24px;
                display: flex;
                flex-direction: column;
                gap: 16px;
            }

            .reason-group {
                display: flex;
                flex-direction: column;
                gap: 8px;
            }

            .reason-group label {
                font-size: 14px;
                font-weight: 600;
                color: #4a5568;
            }

            .reason-options {
                display: flex;
                flex-direction: column;
                gap: 8px;
            }

            .reason-option {
                display: flex;
                align-items: center;
                gap: 10px;
                padding: 10px 12px;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                cursor: pointer;
                transition: all 0.15s;
            }

            .reason-option:hover {
                border-color: #cbd5e0;
                background: #f7fafc;
            }

            .reason-option input[type="radio"] {
                width: 18px;
                height: 18px;
                cursor: pointer;
            }

            .reason-option.active {
                border-color: #4299e1;
                background: #ebf8ff;
            }

            .reason-detail {
                display: none;
                margin-top: 8px;
            }

            .reason-detail.active {
                display: block;
            }

            .reason-detail textarea {
                width: 100%;
                min-height: 80px;
                padding: 10px 12px;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                font-size: 14px;
                font-family: inherit;
                resize: vertical;
            }

            .reason-detail textarea:focus {
                outline: none;
                border-color: #4299e1;
                box-shadow: 0 0 0 3px rgba(66, 153, 225, 0.15);
            }

            .modal-footer {
                padding: 16px 24px 24px;
                display: flex;
                justify-content: flex-end;
                gap: 10px;
                border-top: 1px solid #e2e8f0;
            }

            .btn-cancel {
                background: #edf2f7;
                color: #4a5568;
            }

            .btn-cancel:hover {
                background: #e2e8f0;
            }

            .btn-confirm {
                background: #fc8181;
                color: #742a2a;
                opacity: 0.5;
                cursor: not-allowed;
            }

            .btn-confirm.active {
                opacity: 1;
                cursor: pointer;
            }

            .btn-confirm.active:hover {
                background: #f56565;
            }
        </style>
    </head>

    <body>

        <div class="page-header">
            <a href="${pageContext.request.contextPath}/incident?action=list" class="back-btn">&#8592; Quay lại
                danh sách</a>
            <div class="page-title">Sự cố: ${incident.ticketNumber}</div>
        </div>

        <c:if test="${param.logSuccess eq '1'}">
            <div class="alert alert-success">Lưu nhật ký thời gian thành công.</div>
        </c:if>
        <c:if test="${not empty param.logError}">
            <div class="alert alert-error">Không thể lưu nhật ký thời gian (${param.logError}).</div>
        </c:if>
        <c:if test="${param.editError eq 'locked'}">
            <div class="alert alert-error">Bạn không thể chỉnh sửa incident này vì trạng thái đã được Agent/Expert cập nhật.</div>
        </c:if>

        <!-- Card thông tin chi tiết -->
        <div class="card">
            <div class="card-title">Chi tiết Sự cố</div>
            <div class="detail-grid">
                <div class="detail-item">
                    <label>Tiêu đề</label>
                    <span>${incident.title}</span>
                </div>
                <div class="detail-item">
                    <label>Trạng thái</label>
                    <span class="badge badge-${fn:toLowerCase(incident.status)}">${incident.status}</span>
                </div>
                <div class="detail-item">
                    <label>Mức ưu tiên</label>
                    <span
                        class="badge badge-${fn:toLowerCase(incident.priority)}">${incident.priority}</span>
                </div>
                <div class="detail-item">
                    <label>Độ khó</label>
                    <span>${not empty incident.difficultyLevel ? incident.difficultyLevel : 'N/A'}</span>
                </div>
                <div class="detail-item">
                    <label>Mã danh mục</label>
                    <span>${incident.categoryId}</span>
                </div>
                <div class="detail-item">
                    <label>Người báo cáo</label>
                    <span>
                        <c:choose>
                            <c:when test="${not empty incident.reportedByName}">${incident.reportedByName}</c:when>
                            <c:otherwise>User #${incident.reportedBy}</c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <div class="detail-item">
                    <label>Người xử lý</label>
                    <c:choose>
                        <c:when test="${incident.assignedTo == null}">
                            <span style="color:#a0aec0;">Chưa phân công</span>
                        </c:when>
                        <c:otherwise>
                            <span>
                                <c:choose>
                                    <c:when test="${not empty incident.assignedToName}">${incident.assignedToName}</c:when>
                                    <c:otherwise>Agent #${incident.assignedTo}</c:otherwise>
                                </c:choose>
                            </span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            <div class="detail-item" style="margin-top:16px;">
                    <label>Mô tả</label>
                <span>${incident.description}</span>
            </div>
            <div class="action-bar">
                <c:if test="${canCurrentUserEditIncident}">
                    <a href="${pageContext.request.contextPath}/incident?action=edit&id=${incident.ticketId}"
                       class="btn btn-warning">Sửa</a>
                </c:if>
                <c:if test="${not canCurrentUserEditIncident and sessionScope.user.userId == incident.reportedBy and sessionScope.user.roleId == 1}">
                    <span style="display:inline-flex;align-items:center;padding:9px 14px;border-radius:8px;background:#edf2f7;color:#4a5568;font-size:13px;font-weight:600;">
                        Edit bị khóa sau khi Agent/Expert đổi trạng thái
                    </span>
                </c:if>
                
                <!-- Nút hủy cho người tạo ticket (Reported By) -->
                <c:if test="${incident.status ne 'CANCELLED' and incident.status ne 'CLOSED' 
                              and sessionScope.user.userId == incident.reportedBy}">
                    <button type="button" class="btn btn-danger" onclick="openCancelModal()">
                        Hủy
                    </button>
                </c:if>
                
                <!-- Nút hủy cho quản trị hệ thống (System Admin) -->
                <c:if test="${incident.status ne 'CANCELLED' and incident.status ne 'CLOSED' 
                              and sessionScope.user.roleId == 10}">
                    <button type="button" class="btn btn-danger" onclick="openCancelModal()">
                        Hủy
                    </button>
                </c:if>
                
                <!-- Nút nhận xử lý (ẩn với End-user và System Admin) -->
                <c:if test="${incident.assignedTo == null and incident.status ne 'CANCELLED' 
                              and sessionScope.user.roleId != 1 and sessionScope.user.roleId != 10}">
                    <form action="${pageContext.request.contextPath}/incident" method="post"
                          style="margin:0;">
                        <input type="hidden" name="action" value="assign">
                        <input type="hidden" name="id" value="${incident.ticketId}">
                        <input type="hidden" name="assignedTo" value="${sessionScope.user.userId}">
                        <button type="submit" class="btn btn-primary">Nhận xử lý</button>
                    </form>
                </c:if>
            </div>
        </div>

        <!-- Card chứa các tab -->
        <c:if test="${sessionScope.user.roleId != 1}">
            <div class="card" style="padding-bottom: 28px;">
                <div class="tabs">
                    <button class="tab-btn active" onclick="switchTab('timelog', this)">&#9201; Nhật ký thời gian</button>
                    <button class="tab-btn" onclick="switchTab('related', this)">&#128279; Sự cố
                        liên quan</button>
                </div>

                <!-- Tab nhật ký thời gian -->
                <div id="tab-timelog" class="tab-content active">
                    <div class="timelog-summary">
                        <div class="timelog-stat ts-purple">
                            <div class="stat-value">
                                <fmt:formatNumber value="${totalTimeSpent}" maxFractionDigits="2" />h
                            </div>
                            <div class="stat-label">Tổng thời gian đã ghi</div>
                        </div>
                        <div class="timelog-stat ts-green">
                            <div class="stat-value">${fn:length(timeLogs)}</div>
                            <div class="stat-label">Số lượt ghi log</div>
                        </div>
                    </div>

                    <c:choose>
                        <c:when test="${not empty timeLogs}">
                            <table class="timelog-table">
                                <thead>
                                    <tr>
                                        <th>#</th>
                                        <th>Hoạt động</th>
                                        <th>Nhân sự</th>
                                        <th>Thời gian</th>
                                        <th>Mô tả</th>
                                        <th>Thời điểm ghi</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="log" items="${timeLogs}" varStatus="s">
                                        <tr>
                                            <td style="color:#a0aec0;">${s.index + 1}</td>
                                            <td>
                                                <span
                                                    class="activity-chip chip-${fn:toLowerCase(log.activityType)}">${log.activityType}</span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty log.agentName}">${log.agentName}
                                                    </c:when>
                                                    <c:otherwise>User #${log.userId}</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td><span class="time-value">
                                                    <fmt:formatNumber value="${log.timeSpent}"
                                                                      maxFractionDigits="2" />h
                                                </span></td>
                                            <td style="color:#718096;">${log.description}</td>
                                            <td style="color:#a0aec0; font-size:12px;">
                                                <fmt:formatDate value="${log.loggedAt}"
                                                                pattern="dd/MM/yyyy HH:mm" />
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state">
                                <p>Chưa có bản ghi thời gian.</p>
                                <p style="font-size:13px; margin-top:6px;">Hệ thống sẽ tự ghi thời gian khi
                                    nhân sự nhận xử lý, resolve hoặc đóng ticket.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>

                    <c:if test="${incident.status ne 'CLOSED' and incident.status ne 'CANCELLED'}">
                        <div class="manual-log-form">
                            <h4>Ghi thời gian thủ công</h4>
                            <form action="${pageContext.request.contextPath}/incident" method="post">
                                <input type="hidden" name="action" value="logtime">
                                <input type="hidden" name="id" value="${incident.ticketId}">
                                <div class="form-row">
                                    <div class="form-group fg-time">
                                        <label for="timeSpent">Số giờ thực hiện</label>
                                        <input type="number" id="timeSpent" name="timeSpent" step="any"
                                               min="0.25" max="24" placeholder="1.5" required>
                                    </div>
                                    <div class="form-group fg-desc">
                                        <label for="logDescription">Mô tả</label>
                                        <input type="text" id="logDescription" name="logDescription"
                                               placeholder="Bạn đã thực hiện công việc gì?" required>
                                    </div>
                                    <div class="form-group">
                                        <label>&nbsp;</label>
                                        <button type="submit" class="btn btn-primary">
                                            Lưu log</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </c:if>
                </div>

                <!-- Tab incident liên quan -->
                <div id="tab-related" class="tab-content">
                    <c:choose>
                        <c:when test="${not empty relatedIncidents}">
                            <ul class="related-list">
                                <c:forEach var="inc" items="${relatedIncidents}">
                                    <li>
                                        <div>
                                            <strong>${inc.ticketNumber}</strong>
                                            <span style="margin-left:10px; color:#4a5568;">${inc.title}</span>
                                        </div>
                                        <span
                                            class="badge badge-${fn:toLowerCase(inc.status)}">${inc.status}</span>
                                    </li>
                                </c:forEach>
                            </ul>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state">
                                <div class="empty-icon">&#128279;</div>
                                <p>Không có sự cố liên quan.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </c:if>

        <!-- Modal xác nhận hủy ticket -->
        <div class="modal-overlay" id="cancelModal">
            <div class="modal-content">
                <div class="modal-header">
                    <span style="font-size: 24px;">⚠️</span>
                    <div class="modal-title">Xác nhận hủy ticket</div>
                </div>
                <div class="modal-body">
                    <div class="reason-group">
                        <label>Chọn lý do hủy ticket:</label>
                        <div class="reason-options">
                            <div class="reason-option active" onclick="selectReason('Tôi không cần hỗ trợ nữa')">
                                <input type="radio" name="cancelReason" value="Tôi không cần hỗ trợ nữa" checked>
                                <span>Tôi không cần hỗ trợ nữa</span>
                            </div>
                            <div class="reason-option" onclick="selectReason('Tôi đã tự giải quyết được')">
                                <input type="radio" name="cancelReason" value="Tôi đã tự giải quyết được">
                                <span>Tôi đã tự giải quyết được</span>
                            </div>
                            <div class="reason-option" onclick="selectReason('Tôi tạo nhầm ticket')">
                                <input type="radio" name="cancelReason" value="Tôi tạo nhầm ticket">
                                <span>Tôi tạo nhầm ticket</span>
                            </div>
                            <div class="reason-option" onclick="selectReason('Vấn đề đã được giải quyết qua kênh khác')">
                                <input type="radio" name="cancelReason" value="Vấn đề đã được giải quyết qua kênh khác">
                                <span>Vấn đề đã được giải quyết qua kênh khác</span>
                            </div>
                            <div class="reason-option" onclick="selectReason('Lý do khác')">
                                <input type="radio" name="cancelReason" value="Lý do khác">
                                <span>Lý do khác</span>
                            </div>
                        </div>
                    </div>
                    
                    <div class="reason-detail" id="reasonDetail">
                        <label>Nhập lý do chi tiết:</label>
                        <textarea id="reasonDetailText" placeholder="Vui lòng nhập lý do chi tiết..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-cancel" onclick="closeCancelModal()">Hủy bỏ</button>
                    <button type="button" class="btn btn-confirm" id="confirmCancelBtn" onclick="confirmCancel()">Xác nhận</button>
                </div>
            </div>
        </div>

        <script>
            function switchTab(tabId, btnEl) {
                document.querySelectorAll('.tab-btn').forEach(function (b) {
                    b.classList.remove('active');
                });
                document.querySelectorAll('.tab-content').forEach(function (t) {
                    t.classList.remove('active');
                });
                btnEl.classList.add('active');
                document.getElementById('tab-' + tabId).classList.add('active');
            }

            // Các hàm xử lý Modal hủy ticket
            function openCancelModal() {
                document.getElementById('cancelModal').classList.add('active');
                document.getElementById('reasonDetail').classList.remove('active');
                document.getElementById('reasonDetailText').value = '';
                document.getElementById('confirmCancelBtn').classList.remove('active');
            }

            function closeCancelModal() {
                document.getElementById('cancelModal').classList.remove('active');
            }

            function selectReason(reason) {
                // Cập nhật lựa chọn radio
                const options = document.querySelectorAll('.reason-option');
                options.forEach(option => {
                    option.classList.remove('active');
                    const radio = option.querySelector('input[type="radio"]');
                    radio.checked = false;
                });

                // Tìm và kích hoạt lựa chọn đang được chọn
                const selectedOption = Array.from(options).find(option => 
                    option.querySelector('input[type="radio"]').value === reason
                );
                if (selectedOption) {
                    selectedOption.classList.add('active');
                    selectedOption.querySelector('input[type="radio"]').checked = true;
                }

                // Hiện/ẩn ô nhập lý do chi tiết
                const detailDiv = document.getElementById('reasonDetail');
                if (reason === 'Lý do khác') {
                    detailDiv.classList.add('active');
                } else {
                    detailDiv.classList.remove('active');
                }

                // Cập nhật trạng thái nút xác nhận
                updateConfirmButton();
            }

            function updateConfirmButton() {
                const selectedReason = document.querySelector('input[name="cancelReason"]:checked');
                const detailText = document.getElementById('reasonDetailText').value.trim();
                const detailRequired = document.getElementById('reasonDetail').classList.contains('active');

                const confirmBtn = document.getElementById('confirmCancelBtn');
                
                if (selectedReason) {
                    if (detailRequired && detailText === '') {
                        confirmBtn.classList.remove('active');
                    } else {
                        confirmBtn.classList.add('active');
                    }
                } else {
                    confirmBtn.classList.remove('active');
                }
            }

            function confirmCancel() {
                const confirmBtn = document.getElementById('confirmCancelBtn');
                if (!confirmBtn.classList.contains('active')) {
                    return;
                }

                const selectedReason = document.querySelector('input[name="cancelReason"]:checked').value;
                const detailText = document.getElementById('reasonDetailText').value.trim();
                
                // Chuẩn bị nội dung lý do gửi lên server
                let reasonText = selectedReason;
                if (detailText && detailText !== '') {
                    reasonText += ' - Chi tiết: ' + detailText;
                }

                // Gửi form kèm lý do hủy
                const form = document.createElement('form');
                form.method = 'post';
                form.action = '${pageContext.request.contextPath}/incident';

                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'cancel';

                const idInput = document.createElement('input');
                idInput.type = 'hidden';
                idInput.name = 'id';
                idInput.value = '${incident.ticketId}';

                const reasonInput = document.createElement('input');
                reasonInput.type = 'hidden';
                reasonInput.name = 'cancelReason';
                reasonInput.value = reasonText;

                form.appendChild(actionInput);
                form.appendChild(idInput);
                form.appendChild(reasonInput);
                document.body.appendChild(form);
                form.submit();
            }

            // Gắn sự kiện cho ô nhập chi tiết lý do
            document.getElementById('reasonDetailText').addEventListener('input', updateConfirmButton);
            document.querySelectorAll('.reason-option').forEach(option => {
                option.addEventListener('click', () => {
                    const reason = option.querySelector('input[type="radio"]').value;
                    selectReason(reason);
                });
            });

        </script>
    </body>

</html>