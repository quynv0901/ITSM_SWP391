<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.itserviceflow.models.Ticket" %>
<%@ page import="com.itserviceflow.models.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    User user = (User) session.getAttribute("user");
    List<Ticket> list = (List<Ticket>) request.getAttribute("incidentList");
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Quản lý Sự cố - ITServiceFlow</title>
        <style>
            :root {
                --primary-color: #3b82f6;
                --primary-hover: #2563eb;
                --success-color: #10b981;
                --success-hover: #059669;
                --danger-color: #ef4444;
                --danger-hover: #dc2626;
                --warning-color: #f59e0b;
                --warning-hover: #d97706;
                --text-primary: #1f2937;
                --text-secondary: #6b7280;
                --bg-color: #f8fafc;
                --card-bg: #ffffff;
                --border-color: #e5e7eb;
                --shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
            }

            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }

            body {
                font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                background-color: var(--bg-color);
                color: var(--text-primary);
                line-height: 1.6;
            }

            /* Khu vực Header */
            .header {
                background: linear-gradient(135deg, var(--primary-color), #8b5cf6);
                color: white;
                padding: 20px 40px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                box-shadow: var(--shadow);
            }

            .header h1 {
                font-size: 1.5rem;
                font-weight: 700;
                display: flex;
                align-items: center;
                gap: 15px;
            }

            .user-info {
                display: flex;
                align-items: center;
                gap: 15px;
                background: rgba(255, 255, 255, 0.1);
                padding: 10px 20px;
                border-radius: 25px;
            }

            .user-name {
                font-weight: 600;
                font-size: 1.1rem;
            }

            .user-role {
                font-size: 0.9rem;
                opacity: 0.8;
                background: rgba(255, 255, 255, 0.2);
                padding: 4px 12px;
                border-radius: 15px;
            }

            /* Khung chứa chính */
            .container {
                max-width: 1200px;
                margin: 30px auto;
                padding: 0 20px;
            }

            /* Kiểu hiển thị Card */
            .card {
                background: var(--card-bg);
                border-radius: 16px;
                box-shadow: var(--shadow);
                overflow: hidden;
            }

            .card-header {
                background-color: var(--card-bg);
                padding: 25px 30px;
                border-bottom: 1px solid var(--border-color);
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            .card-title {
                font-size: 1.5rem;
                font-weight: 700;
                color: var(--text-primary);
                display: flex;
                align-items: center;
                gap: 10px;
            }

            .card-actions {
                display: flex;
                gap: 10px;
                align-items: center;
            }

            /* Kiểu hiển thị Bảng */
            .table-container {
                overflow-x: auto;
                max-height: 70vh;
                overflow-y: auto;
            }

            table {
                width: 100%;
                border-collapse: separate;
                border-spacing: 0;
                min-width: 800px;
            }

            thead th {
                position: sticky;
                top: 0;
                background-color: #f8fafc;
                color: var(--text-secondary);
                font-weight: 600;
                font-size: 0.85rem;
                text-transform: uppercase;
                letter-spacing: 0.05em;
                padding: 15px;
                border-bottom: 2px solid var(--border-color);
                text-align: left;
                z-index: 10;
            }

            tbody td {
                padding: 15px;
                border-bottom: 1px solid var(--border-color);
                vertical-align: middle;
                font-size: 0.95rem;
            }

            tbody tr:hover {
                background-color: #f8fafc;
                transition: background-color 0.2s ease;
            }

            /* Kiểu hiển thị Badge */
            .badge {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                padding: 6px 12px;
                border-radius: 20px;
                font-size: 0.8rem;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 0.05em;
            }

            /* Badge theo trạng thái */
            .status-new {
                background-color: #dbeafe;
                color: #1d4ed8;
            }
            .status-in-progress {
                background-color: #f3e8ff;
                color: #5b21b6;
            }
            .status-resolved {
                background-color: #d1fae5;
                color: #065f46;
            }
            .status-cancelled {
                background-color: #fee2e2;
                color: #991b1b;
            }

            /* Badge theo mức ưu tiên */
            .priority-low {
                background-color: #e5e7eb;
                color: #374151;
            }
            .priority-medium {
                background-color: #fef3c7;
                color: #92400e;
            }
            .priority-high {
                background-color: #fee2e2;
                color: #991b1b;
            }

            /* Nút thao tác */
            .btn {
                padding: 8px 16px;
                border-radius: 8px;
                font-size: 0.85rem;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 0.05em;
                transition: all 0.3s ease;
                border: none;
                cursor: pointer;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                gap: 6px;
            }

            .btn-primary {
                background: linear-gradient(135deg, var(--primary-color), #8b5cf6);
                color: white;
                box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3);
            }

            .btn-primary:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 20px rgba(59, 130, 246, 0.4);
                background: linear-gradient(135deg, var(--primary-hover), #7c3aed);
            }

            .btn-secondary {
                background-color: var(--text-secondary);
                color: white;
            }

            .btn-secondary:hover {
                background-color: var(--text-primary);
                transform: translateY(-2px);
            }

            .btn-success {
                background-color: var(--success-color);
                color: white;
            }

            .btn-success:hover {
                background-color: var(--success-hover);
                transform: translateY(-2px);
            }

            .btn-warning {
                background-color: var(--warning-color);
                color: white;
            }

            .btn-warning:hover {
                background-color: var(--warning-hover);
                transform: translateY(-2px);
            }

            .btn-danger {
                background-color: var(--danger-color);
                color: white;
            }

            .btn-danger:hover {
                background-color: var(--danger-hover);
                transform: translateY(-2px);
            }

            /* Trạng thái rỗng */
            .empty-state {
                text-align: center;
                padding: 60px 20px;
                color: var(--text-secondary);
            }

            .empty-state h3 {
                font-size: 1.5rem;
                margin-bottom: 10px;
            }

            .empty-state p {
                font-size: 1rem;
                margin-bottom: 30px;
            }

            /* Giao diện đáp ứng */
            @media (max-width: 768px) {
                .header {
                    padding: 15px 20px;
                    flex-direction: column;
                    gap: 15px;
                    text-align: center;
                }

                .container {
                    margin: 20px auto;
                    padding: 0 15px;
                }

                .card-header {
                    padding: 20px;
                    flex-direction: column;
                    gap: 15px;
                    align-items: flex-start;
                }

                .table-container {
                    font-size: 0.8rem;
                }

                tbody td {
                    padding: 12px 8px;
                }

                thead th {
                    padding: 12px 8px;
                }
            }

            /* Tăng cường hiển thị bổ sung */
            .incident-id {
                font-family: 'Courier New', monospace;
                font-weight: 700;
                color: var(--primary-color);
            }

            .incident-title {
                font-weight: 600;
                color: var(--text-primary);
            }

            .incident-title:hover {
                color: var(--primary-color);
            }

            .timestamp {
                font-size: 0.8rem;
                color: var(--text-secondary);
            }

            /* Kiểu ô tìm kiếm */
            .search-container {
                position: relative;
                display: flex;
                align-items: center;
                background: white;
                border: 2px solid var(--border-color);
                border-radius: 25px;
                padding: 8px 16px;
                transition: all 0.3s ease;
                width: 300px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            }

            .search-container:focus-within {
                border-color: var(--primary-color);
                box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
            }

            .search-icon {
                color: var(--text-secondary);
                margin-right: 8px;
                font-size: 1.1rem;
            }

            .search-input {
                border: none;
                outline: none;
                flex: 1;
                font-size: 0.9rem;
                color: var(--text-primary);
                background: transparent;
            }

            .search-input::placeholder {
                color: var(--text-secondary);
                font-size: 0.9rem;
            }

            /* Tìm kiếm trên màn hình nhỏ */
            @media (max-width: 768px) {
                .search-container {
                    width: 100%;
                    margin-bottom: 15px;
                }
            }

            /* Kiểu phân trang */
            .pagination-container {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 20px 0;
                border-top: 1px solid var(--border-color);
                margin-top: 20px;
            }

            .pagination-info {
                font-size: 0.9rem;
                color: var(--text-secondary);
            }

            .pagination-controls {
                display: flex;
                align-items: center;
                gap: 10px;
            }

            .page-size-selector {
                display: flex;
                align-items: center;
                gap: 8px;
                font-size: 0.9rem;
                color: var(--text-secondary);
            }

            .page-size-selector select {
                padding: 6px 12px;
                border: 1px solid var(--border-color);
                border-radius: 6px;
                background: white;
                font-size: 0.9rem;
                cursor: pointer;
            }

            .pagination-buttons {
                display: flex;
                gap: 5px;
            }

            .page-btn {
                padding: 8px 12px;
                border: 1px solid var(--border-color);
                background: white;
                color: var(--text-primary);
                border-radius: 6px;
                cursor: pointer;
                font-size: 0.9rem;
                transition: all 0.3s ease;
                min-width: 40px;
                text-align: center;
            }

            .page-btn:hover {
                background-color: var(--primary-color);
                color: white;
                border-color: var(--primary-color);
            }

            .page-btn.active {
                background-color: var(--primary-color);
                color: white;
                border-color: var(--primary-color);
            }

            .page-btn.disabled {
                opacity: 0.5;
                cursor: not-allowed;
                background-color: #f3f4f6;
                color: #9ca3af;
                border-color: #e5e7eb;
            }

            .page-ellipsis {
                padding: 8px 12px;
                color: var(--text-secondary);
                font-size: 0.9rem;
            }

            /* Modal xác nhận hủy incident */
            .modal-overlay {
                display: none;
                position: fixed;
                inset: 0;
                background: rgba(15, 23, 42, 0.45);
                backdrop-filter: blur(2px);
                z-index: 1000;
                align-items: center;
                justify-content: center;
                padding: 20px;
            }

            .modal-overlay.active {
                display: flex;
            }

            .modal-card {
                width: 100%;
                max-width: 460px;
                background: #ffffff;
                border-radius: 16px;
                box-shadow: 0 20px 45px rgba(15, 23, 42, 0.24);
                overflow: hidden;
                animation: modalFadeIn 0.18s ease-out;
            }

            @keyframes modalFadeIn {
                from {
                    opacity: 0;
                    transform: translateY(-10px) scale(0.98);
                }
                to {
                    opacity: 1;
                    transform: translateY(0) scale(1);
                }
            }

            .modal-header {
                display: flex;
                align-items: center;
                gap: 10px;
                padding: 18px 20px;
                border-bottom: 1px solid #e5e7eb;
                background: linear-gradient(135deg, #fff7ed, #ffedd5);
            }

            .modal-icon {
                font-size: 20px;
            }

            .modal-title {
                font-size: 1.05rem;
                font-weight: 700;
                color: #7c2d12;
            }

            .modal-body {
                padding: 18px 20px 10px;
                color: #374151;
                font-size: 0.95rem;
                line-height: 1.5;
            }

            .modal-ticket-id {
                font-weight: 700;
                color: #b45309;
            }

            .modal-actions {
                display: flex;
                justify-content: flex-end;
                gap: 10px;
                padding: 14px 20px 20px;
            }

            /* Phân trang trên màn hình nhỏ */
            @media (max-width: 768px) {
                .pagination-container {
                    flex-direction: column;
                    gap: 15px;
                    align-items: flex-end;
                }

                .pagination-info {
                    align-self: flex-start;
                }

                .pagination-controls {
                    width: 100%;
                    justify-content: space-between;
                }

                .page-size-selector {
                    display: none; /* Ẩn dropdown trên mobile để tiết kiệm không gian */
                }
            }
        </style>
    </head>
    <body>
        <!-- Phần đầu trang -->
        <div class="header">
            <h1>🚨 Quản lý Sự cố</h1>
            <div class="user-info">
                <div class="user-name">👤 ${user.fullName}</div>
                <div class="user-role">${user.roleName}</div>
            </div>
        </div>

        <!-- Khung nội dung chính -->
        <div class="container">
            <div class="card">
                <!-- Phần đầu của Card -->
                <div class="card-header">
                    <div class="card-title">📋 Danh sách Sự cố</div>
                    <div class="card-actions">
                        <div class="search-container">
                            <span class="search-icon">🔍</span>
                            <input type="text" id="searchInput" class="search-input" 
                                   placeholder="Tìm theo mã ticket, tiêu đề hoặc người báo cáo..." 
                                   onkeyup="searchIncidents()">
                        </div>
                        <a href="${pageContext.request.contextPath}/home" class="btn btn-secondary">
                            ← Về trang chủ
                        </a>
                        <a href="${pageContext.request.contextPath}/incident?action=add" class="btn btn-primary">
                            ➕ Tạo sự cố mới
                        </a>
                        <a href="${pageContext.request.contextPath}/incident?action=list" class="btn btn-secondary">
                            🔄 Làm mới
                        </a>
                    </div>
                </div>

                <!-- Khung chứa bảng -->
                <div class="table-container">
                    <table id="incidentTable">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Mã ticket</th>
                                <th>Tiêu đề</th>
                                <th>Trạng thái</th>
                                <th>Mức ưu tiên</th>
                                <th>Ngày tạo</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty incidentList}">
                                    <tr>
                                        <td colspan="7">
                                            <div class="empty-state">
                                                <h3>📭 Không có sự cố</h3>
                                                <p>Hiện chưa có sự cố nào để hiển thị.</p>
                                                <a href="${pageContext.request.contextPath}/incident?action=add" class="btn btn-primary">
                                                    ➕ Tạo sự cố đầu tiên
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="incident" items="${incidentList}">
                                        <tr>
                                            <td>
                                                <span class="incident-id">#${incident.ticketId}</span>
                                            </td>
                                            <td>
                                                <span style="font-family: 'Courier New', monospace; font-weight: 600; color: #6b7280;">
                                                    ${incident.ticketNumber}
                                                </span>
                                            </td>
                                            <td>
                                                <div>
                                                    <div class="incident-title">${incident.title}</div>
                                                    <div class="timestamp">
                                                        Người báo cáo: User #${incident.reportedBy}
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${incident.status == 'NEW'}">
                                                        <span class="badge status-new">MỚI</span>
                                                    </c:when>
                                                    <c:when test="${incident.status == 'IN_PROGRESS'}">
                                                        <span class="badge status-in-progress">ĐANG XỬ LÝ</span>
                                                    </c:when>
                                                    <c:when test="${incident.status == 'INVESTIGATING'}">
                                                        <span class="badge status-in-progress">ĐANG ĐIỀU TRA</span>
                                                    </c:when>
                                                    <c:when test="${incident.status == 'OPEN'}">
                                                        <span class="badge status-new">ĐANG MỞ</span>
                                                    </c:when>
                                                    <c:when test="${incident.status == 'RESOLVED'}">
                                                        <span class="badge status-resolved">ĐÃ XỬ LÝ</span>
                                                    </c:when>
                                                    <c:when test="${incident.status == 'CLOSED'}">
                                                        <span class="badge status-cancelled">ĐÃ ĐÓNG</span>
                                                    </c:when>
                                                    <c:when test="${incident.status == 'PENDING'}">
                                                        <span class="badge status-in-progress">CHỜ DUYỆT HỦY</span>
                                                    </c:when>
                                                    <c:when test="${incident.status == 'CANCELLED'}">
                                                        <span class="badge status-cancelled">ĐÃ HỦY</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge status-cancelled">${incident.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${incident.priority == 'LOW'}">
                                                        <span class="badge priority-low">🟢 Thấp</span>
                                                    </c:when>
                                                    <c:when test="${incident.priority == 'MEDIUM'}">
                                                        <span class="badge priority-medium">🟡 Trung bình</span>
                                                    </c:when>
                                                    <c:when test="${incident.priority == 'CRITICAL'}">
                                                        <span class="badge priority-high">🔴 Khẩn cấp</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge priority-high">🟠 Cao</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <div class="timestamp">
                                                    ${incident.createdAt}
                                                </div>
                                            </td>
                                            <td>
                                                <div style="display: flex; gap: 8px;">
                                                    <a href="${pageContext.request.contextPath}/incident?action=detail&id=${incident.ticketId}" 
                                                       class="btn btn-primary">
                                                        👁️ Xem
                                                    </a>
                                                    <c:set var="isEndUser" value="${sessionScope.user.roleId == 1}" />
                                                    <c:set var="isReporter" value="${sessionScope.user.userId == incident.reportedBy}" />
                                                    <c:set var="isEditableStatusForUser" value="${incident.status != 'IN_PROGRESS' && incident.status != 'RESOLVED'}" />
                                                    <c:if test="${(!isEndUser && incident.status != 'RESOLVED' && incident.status != 'CANCELLED') || (isEndUser && isReporter && isEditableStatusForUser)}">
                                                        <a href="${pageContext.request.contextPath}/incident?action=edit&id=${incident.ticketId}" 
                                                           class="btn btn-warning">
                                                            ✏️ Sửa
                                                        </a>
                                                    </c:if>
                                                    <c:if test="${incident.status == 'NEW'}">
                                                        <button type="button" class="btn btn-danger"
                                                                onclick="openCancelModal('${incident.ticketId}')">
                                                            ❌ Hủy
                                                        </button>
                                                    </c:if>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <!-- Khu vực phân trang -->
                <div class="pagination-container">
                    <div class="pagination-info" id="paginationInfo">
                        Hiển thị 1-10 của 0 sự cố
                    </div>
                    <div class="pagination-controls">
                        <div class="page-size-selector">
                            <span>Hiển thị:</span>
                            <select id="pageSizeSelector" onchange="changePageSize()">
                                <option value="10">10</option>
                                <option value="20">20</option>
                                <option value="50">50</option>
                                <option value="100">100</option>
                            </select>
                            <span>hàng mỗi trang</span>
                        </div>
                        <div class="pagination-buttons" id="paginationButtons">
                            <!-- Các nút phân trang sẽ được tạo động tại đây -->
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modal xác nhận hủy ticket -->
        <div id="cancelIncidentModal" class="modal-overlay">
            <div class="modal-card">
                <div class="modal-header">
                    <span class="modal-icon">⚠️</span>
                    <div class="modal-title">Xác nhận hủy sự cố</div>
                </div>
                <div class="modal-body">
                    Bạn có chắc muốn hủy sự cố
                    <span id="cancelTicketLabel" class="modal-ticket-id">#</span>?
                    Hành động này sẽ cập nhật trạng thái sự cố.
                    <c:if test="${sessionScope.user.roleId != 1}">
                        <div style="margin-top:12px;">
                            <label for="cancelReasonText" style="display:block;font-weight:700;margin-bottom:6px;">Lý do hủy (bắt buộc)</label>
                            <textarea id="cancelReasonText" class="search-input" style="width:100%;min-height:90px;padding:10px;border-radius:10px;border:1px solid #e5e7eb;"
                                      placeholder="Nhập lý do để người dùng hiểu vì sao ticket bị hủy..."></textarea>
                        </div>
                    </c:if>
                </div>
                <div class="modal-actions">
                    <button type="button" class="btn btn-secondary" onclick="closeCancelModal()">Quay lại</button>
                    <button type="button" class="btn btn-danger" onclick="submitCancel()">Xác nhận hủy</button>
                </div>
            </div>
        </div>

        <form id="cancelIncidentForm" action="${pageContext.request.contextPath}/incident" method="post" style="display:none;">
            <input type="hidden" name="action" value="cancel">
            <input type="hidden" name="id" id="cancelIncidentId">
            <input type="hidden" name="cancelReason" id="cancelReasonHidden">
        </form>

    </body>

    <script>
        // Biến dùng cho phân trang
        let currentPage = 1;
        let pageSize = 10;
        let totalPages = 1;
        let allRows = [];
        let visibleRows = [];

        // Khởi tạo phân trang khi trang tải xong
        document.addEventListener('DOMContentLoaded', function () {
            initializePagination();
        });

        function initializePagination() {
            const table = document.getElementById('incidentTable');
            const tbody = table.getElementsByTagName('tbody')[0];
            allRows = Array.from(tbody.getElementsByTagName('tr'));

            // Loại bỏ dòng trạng thái rỗng khỏi tập dữ liệu cần phân trang
            allRows = allRows.filter(row => !row.querySelector('.empty-state'));

            if (allRows.length === 0) {
                document.getElementById('paginationInfo').textContent = 'Hiển thị 0-0 của 0 sự cố';
                document.getElementById('paginationButtons').innerHTML = '';
                return;
            }

            // Thiết lập số dòng mặc định theo lựa chọn ở dropdown
            const savedPageSize = localStorage.getItem('incidentPageSize');
            if (savedPageSize) {
                pageSize = parseInt(savedPageSize);
                document.getElementById('pageSizeSelector').value = pageSize;
            }

            updatePagination();
        }

        function updatePagination() {
            // Lọc các dòng hiển thị theo từ khóa tìm kiếm
            const searchInput = document.getElementById('searchInput');
            const searchTerm = normalizeForSearch(searchInput.value);

            visibleRows = allRows.filter(row => {
                const tdTicketNumber = row.getElementsByTagName('td')[1];
                const tdTitle = row.getElementsByTagName('td')[2];

                if (tdTicketNumber && tdTitle) {
                    const ticketNumber = normalizeForSearch(tdTicketNumber.textContent || tdTicketNumber.innerText);
                    const title = normalizeForSearch(tdTitle.textContent || tdTitle.innerText);

                    if (!searchTerm) {
                        return true;
                    }

                    return ticketNumber.indexOf(searchTerm) > -1 ||
                            title.indexOf(searchTerm) > -1;
                }
                return false;
            });

            // Tính số trang
            totalPages = Math.ceil(visibleRows.length / pageSize);

            // Đảm bảo trang hiện tại luôn hợp lệ
            if (currentPage > totalPages) {
                currentPage = totalPages;
            }
            if (currentPage < 1) {
                currentPage = 1;
            }

            // Cập nhật lại phần hiển thị
            updateTableDisplay();
            updatePaginationInfo();
            updatePaginationButtons();
        }

        function updateTableDisplay() {
            // Ẩn toàn bộ dòng trước khi hiển thị theo trang
            allRows.forEach(row => {
                row.style.display = 'none';
            });

            // Chỉ hiển thị các dòng thuộc trang hiện tại
            const startIndex = (currentPage - 1) * pageSize;
            const endIndex = Math.min(startIndex + pageSize, visibleRows.length);

            for (let i = startIndex; i < endIndex; i++) {
                if (visibleRows[i]) {
                    visibleRows[i].style.display = '';
                }
            }
        }

        function updatePaginationInfo() {
            const totalVisible = visibleRows.length;
            const startIndex = (currentPage - 1) * pageSize + 1;
            const endIndex = Math.min(currentPage * pageSize, totalVisible);

            const infoText = totalVisible === 0
                    ? 'Hiển thị 0-0 của 0 sự cố'
                    : `Hiển thị ${startIndex}-${endIndex} của ${totalVisible} sự cố`;

            document.getElementById('paginationInfo').textContent = infoText;
        }

        function updatePaginationButtons() {
            const container = document.getElementById('paginationButtons');
            container.innerHTML = '';

            // Nút về trang trước
            const prevBtn = document.createElement('button');
            prevBtn.className = 'page-btn' + (currentPage === 1 ? ' disabled' : '');
            prevBtn.textContent = 'Trước';
            prevBtn.onclick = () => {
                if (currentPage > 1) {
                    currentPage--;
                    updatePagination();
                }
            };
            container.appendChild(prevBtn);

            // Các nút số trang
            const maxButtons = 5;
            let startPage = Math.max(1, currentPage - Math.floor(maxButtons / 2));
            let endPage = Math.min(totalPages, startPage + maxButtons - 1);

            if (endPage - startPage < maxButtons - 1) {
                startPage = Math.max(1, endPage - maxButtons + 1);
            }

            if (startPage > 1) {
                const firstBtn = document.createElement('button');
                firstBtn.className = 'page-btn';
                firstBtn.textContent = '1';
                firstBtn.onclick = () => {
                    currentPage = 1;
                    updatePagination();
                };
                container.appendChild(firstBtn);

                if (startPage > 2) {
                    const ellipsis = document.createElement('span');
                    ellipsis.className = 'page-ellipsis';
                    ellipsis.textContent = '...';
                    container.appendChild(ellipsis);
                }
            }

            for (let i = startPage; i <= endPage; i++) {
                const btn = document.createElement('button');
                btn.className = 'page-btn' + (i === currentPage ? ' active' : '');
                btn.textContent = i;
                btn.onclick = () => {
                    currentPage = i;
                    updatePagination();
                };
                container.appendChild(btn);
            }

            if (endPage < totalPages) {
                if (endPage < totalPages - 1) {
                    const ellipsis = document.createElement('span');
                    ellipsis.className = 'page-ellipsis';
                    ellipsis.textContent = '...';
                    container.appendChild(ellipsis);
                }

                const lastBtn = document.createElement('button');
                lastBtn.className = 'page-btn';
                lastBtn.textContent = totalPages;
                lastBtn.onclick = () => {
                    currentPage = totalPages;
                    updatePagination();
                };
                container.appendChild(lastBtn);
            }

            // Nút sang trang sau
            const nextBtn = document.createElement('button');
            nextBtn.className = 'page-btn' + (currentPage === totalPages ? ' disabled' : '');
            nextBtn.textContent = 'Sau';
            nextBtn.onclick = () => {
                if (currentPage < totalPages) {
                    currentPage++;
                    updatePagination();
                }
            };
            container.appendChild(nextBtn);
        }

        function changePageSize() {
            const select = document.getElementById('pageSizeSelector');
            pageSize = parseInt(select.value);
            localStorage.setItem('incidentPageSize', pageSize);
            currentPage = 1;
            updatePagination();
        }

        function searchIncidents() {
            currentPage = 1;
            updatePagination();
        }

        function normalizeForSearch(value) {
            if (value == null) {
                return '';
            }
            return String(value)
                    .trim()
                    .replace(/\s+/g, ' ')
                    .toLowerCase();
        }

        function openCancelModal(ticketId) {
            document.getElementById('cancelIncidentId').value = ticketId;
            document.getElementById('cancelTicketLabel').textContent = '#' + ticketId;
            const reasonEl = document.getElementById('cancelReasonText');
            if (reasonEl) {
                reasonEl.value = '';
            }
            document.getElementById('cancelReasonHidden').value = '';
            document.getElementById('cancelIncidentModal').classList.add('active');
        }

        function closeCancelModal() {
            document.getElementById('cancelIncidentModal').classList.remove('active');
        }

        function submitCancel() {
            const reasonEl = document.getElementById('cancelReasonText');
            if (reasonEl) {
                const reason = (reasonEl.value || '').trim();
                if (!reason) {
                    return;
                }
                document.getElementById('cancelReasonHidden').value = reason;
            }
            document.getElementById('cancelIncidentForm').submit();
        }

        document.getElementById('cancelIncidentModal').addEventListener('click', function (event) {
            if (event.target === this) {
                closeCancelModal();
            }
        });
    </script>
</html>
