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
        <title>Incident Management - ITServiceFlow</title>
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

            /* Header Styles */
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

            /* Main Container */
            .container {
                max-width: 1200px;
                margin: 30px auto;
                padding: 0 20px;
            }

            /* Card Styles */
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

            /* Table Styles */
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

            /* Badge Styles */
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

            /* Status Badges */
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

            /* Priority Badges */
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

            /* Action Buttons */
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

            /* Empty State */
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

            /* Responsive Design */
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

            /* Additional Enhancements */
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

            /* Search Box Styles */
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

            /* Responsive Search */
            @media (max-width: 768px) {
                .search-container {
                    width: 100%;
                    margin-bottom: 15px;
                }
            }

            /* Pagination Styles */
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

            /* Responsive Pagination */
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
        <!-- Header -->
        <div class="header">
            <h1>🚨 Incident Management</h1>
            <div class="user-info">
                <div class="user-name">👤 ${user.fullName}</div>
                <div class="user-role">${user.roleName}</div>
            </div>
        </div>

        <!-- Main Container -->
        <div class="container">
            <div class="card">
                <!-- Card Header -->
                <div class="card-header">
                    <div class="card-title">📋 Incident List</div>
                    <div class="card-actions">
                        <div class="search-container">
                            <span class="search-icon">🔍</span>
                            <input type="text" id="searchInput" class="search-input" 
                                   placeholder="Tìm theo mã ticket, tiêu đề hoặc người báo cáo..." 
                                   onkeyup="searchIncidents()">
                        </div>
                        <a href="${pageContext.request.contextPath}/home" class="btn btn-secondary">
                            ← Back to Home
                        </a>
                        <a href="${pageContext.request.contextPath}/incident?action=add" class="btn btn-primary">
                            ➕ New Incident
                        </a>
                        <a href="${pageContext.request.contextPath}/incident?action=list" class="btn btn-secondary">
                            🔄 Refresh
                        </a>
                    </div>
                </div>

                <!-- Table Container -->
                <div class="table-container">
                    <table id="incidentTable">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Ticket Number</th>
                                <th>Title</th>
                                <th>Status</th>
                                <th>Priority</th>
                                <th>Created</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty incidentList}">
                                    <tr>
                                        <td colspan="7">
                                            <div class="empty-state">
                                                <h3>📭 No Incidents Found</h3>
                                                <p>There are no incidents to display at the moment.</p>
                                                <a href="${pageContext.request.contextPath}/incident?action=add" class="btn btn-primary">
                                                    ➕ Create Your First Incident
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
                                                        Reported by User #${incident.reportedBy}
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${incident.status == 'NEW'}">
                                                        <span class="badge status-new">${incident.status}</span>
                                                    </c:when>
                                                    <c:when test="${incident.status == 'IN_PROGRESS'}">
                                                        <span class="badge status-in-progress">${incident.status}</span>
                                                    </c:when>
                                                    <c:when test="${incident.status == 'RESOLVED'}">
                                                        <span class="badge status-resolved">${incident.status}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge status-cancelled">${incident.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${incident.priority == 'LOW'}">
                                                        <span class="badge priority-low">🟢 Low</span>
                                                    </c:when>
                                                    <c:when test="${incident.priority == 'MEDIUM'}">
                                                        <span class="badge priority-medium">🟡 Medium</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge priority-high">🟠 High</span>
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
                                                        👁️ View
                                                    </a>
                                                    <c:if test="${incident.status != 'RESOLVED' && incident.status != 'CANCELLED'}">
                                                        <a href="${pageContext.request.contextPath}/incident?action=edit&id=${incident.ticketId}" 
                                                           class="btn btn-warning">
                                                            ✏️ Edit
                                                        </a>
                                                    </c:if>
                                                    <c:if test="${incident.status == 'NEW'}">
                                                        <a href="${pageContext.request.contextPath}/incident?action=cancel&id=${incident.ticketId}" 
                                                           class="btn btn-danger">
                                                            ❌ Cancel
                                                        </a>
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

                <!-- Pagination -->
                <div class="pagination-container">
                    <div class="pagination-info" id="paginationInfo">
                        Hiển thị 1-10 của 0 incident
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
                            <!-- Pagination buttons will be generated here -->
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </body>
    
    <script>
        // Pagination variables
        let currentPage = 1;
        let pageSize = 10;
        let totalPages = 1;
        let allRows = [];
        let visibleRows = [];

        // Initialize pagination when page loads
        document.addEventListener('DOMContentLoaded', function() {
            initializePagination();
        });

        function initializePagination() {
            const table = document.getElementById('incidentTable');
            const tbody = table.getElementsByTagName('tbody')[0];
            allRows = Array.from(tbody.getElementsByTagName('tr'));
            
            // Filter out empty state row
            allRows = allRows.filter(row => !row.querySelector('.empty-state'));
            
            if (allRows.length === 0) {
                document.getElementById('paginationInfo').textContent = 'Hiển thị 0-0 của 0 incident';
                document.getElementById('paginationButtons').innerHTML = '';
                return;
            }

            // Set default page size from dropdown
            const savedPageSize = localStorage.getItem('incidentPageSize');
            if (savedPageSize) {
                pageSize = parseInt(savedPageSize);
                document.getElementById('pageSizeSelector').value = pageSize;
            }

            updatePagination();
        }

        function updatePagination() {
            // Filter visible rows based on search
            const searchInput = document.getElementById('searchInput');
            const searchTerm = searchInput.value.toLowerCase();
            
            visibleRows = allRows.filter(row => {
                const tdTicketNumber = row.getElementsByTagName('td')[1];
                const tdTitle = row.getElementsByTagName('td')[2];
                
                if (tdTicketNumber && tdTitle) {
                    const ticketNumber = tdTicketNumber.textContent || tdTicketNumber.innerText;
                    const title = tdTitle.textContent || tdTitle.innerText;
                    
                    return ticketNumber.toLowerCase().indexOf(searchTerm) > -1 || 
                           title.toLowerCase().indexOf(searchTerm) > -1;
                }
                return false;
            });

            // Calculate pagination
            totalPages = Math.ceil(visibleRows.length / pageSize);
            
            // Ensure current page is valid
            if (currentPage > totalPages) {
                currentPage = totalPages;
            }
            if (currentPage < 1) {
                currentPage = 1;
            }

            // Update display
            updateTableDisplay();
            updatePaginationInfo();
            updatePaginationButtons();
        }

        function updateTableDisplay() {
            // Hide all rows first
            allRows.forEach(row => {
                row.style.display = 'none';
            });

            // Show only rows for current page
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
                ? 'Hiển thị 0-0 của 0 incident'
                : `Hiển thị ${startIndex}-${endIndex} của ${totalVisible} incident`;
            
            document.getElementById('paginationInfo').textContent = infoText;
        }

        function updatePaginationButtons() {
            const container = document.getElementById('paginationButtons');
            container.innerHTML = '';

            // Previous button
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

            // Page numbers
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
                firstBtn.onclick = () => { currentPage = 1; updatePagination(); };
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
                btn.onclick = () => { currentPage = i; updatePagination(); };
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
                lastBtn.onclick = () => { currentPage = totalPages; updatePagination(); };
                container.appendChild(lastBtn);
            }

            // Next button
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
    </script>
</html>
