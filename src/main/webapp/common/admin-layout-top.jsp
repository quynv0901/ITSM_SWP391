<!DOCTYPE html>
<html lang="vi">
    <%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
        <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap" rel="stylesheet">
        <style>
            :root {
                --sidebar-bg: #222d32;
                --sidebar-hover: #1e282c;
                --sidebar-header-bg: #1a2226;
                --primary-blue: #3c8dbc;
                --text-muted: #4b646f;
                --text-color: #b8c7ce;
            }

            body {
                font-family: 'Outfit', sans-serif;
                margin: 0;
            }

            .wrapper {
                display: flex;
                min-height: 100vh;
                background-color: #f4f7f6;
            }

            /* Sidebar */
            .sidebar {
                width: 250px;
                background-color: var(--sidebar-bg);
                color: #fff;
                flex-shrink: 0;
                transition: all 0.3s;
                z-index: 1000;
            }

            .sidebar-header {
                padding: 15px 20px;
                background-color: var(--primary-blue);
                text-align: center;
                font-weight: 700;
                font-size: 1.25rem;
                letter-spacing: 1px;
                color: #fff;
                text-transform: uppercase;
            }

            .sidebar-menu {
                list-style: none;
                padding: 0;
                margin: 0;
            }

            .menu-header {
                padding: 12px 15px 7px 15px;
                font-size: 0.75rem;
                color: var(--text-muted);
                background: var(--sidebar-header-bg);
                text-transform: uppercase;
                font-weight: 600;
                letter-spacing: 0.5px;
            }

            .sidebar-menu li a {
                padding: 12px 15px;
                display: flex;
                align-items: flex-start;
                gap: 12px;
                color: var(--text-color);
                text-decoration: none;
                transition: all 0.2s ease;
                border-left: 3px solid transparent;
            }

            .sidebar-menu li a:hover,
            .sidebar-menu li a.active {
                color: #fff;
                background-color: var(--sidebar-hover);
                border-left-color: var(--primary-blue);
            }

            .sidebar-menu li a i {
                width: 20px;
                text-align: center;
                font-size: 1.1rem;
                margin-top: 2px;
            }

            .sidebar-menu li a span {
                font-size: 0.95rem;
                line-height: 1.4;
            }

            /* Topbar & Content Area */
            .admin-main {
                flex: 1;
                display: flex;
                flex-direction: column;
                min-width: 0;
            }

            .topbar {
                height: 60px;
                background-color: var(--primary-blue);
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 0 20px;
                color: #fff;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }

            .topbar-left {
                display: flex;
                align-items: center;
                gap: 15px;
            }

            .topbar-right {
                display: flex;
                align-items: center;
                gap: 20px;
            }

            .user-info img {
                width: 32px;
                height: 32px;
                border-radius: 50%;
                border: 1px solid rgba(255,255,255,0.3);
            }

            .content-area {
                padding: 25px;
                flex: 1;
                overflow-x: hidden;
            }

            /* Notifications Dropdown Custom */
            .notification-dropdown {
                width: 350px !important;
                padding: 0;
                border: none;
                box-shadow: 0 10px 25px rgba(0,0,0,0.15);
            }
            .notification-item {
                border-bottom: 1px solid #eee;
                padding: 10px 15px;
                transition: background 0.2s;
                display: flex;
                align-items: flex-start;
                justify-content: space-between;
                gap: 10px;
            }
            .notification-content {
                flex: 1;
                text-decoration: none;
                color: inherit;
            }
            .notification-item.unread {
                background-color: #eef2ff;
            }
            .btn-mark-done {
                background: none;
                border: none;
                color: #adb5bd;
                font-size: 1.25rem;
                cursor: pointer;
                padding: 0;
            }
            .btn-mark-done:hover {
                color: #198754;
            }
        </style>
    </head>

    <div class="wrapper">
        <!-- Sidebar -->
        <div class="sidebar">
            <div class="sidebar-header">
                ITSM
            </div>
            <ul class="sidebar-menu">

                <%-- BẢNG ĐIỀU KHIỂN --%>
                <c:if test="${sessionScope.user.roleId == 10}">
                    <li>
                        <a href="${pageContext.request.contextPath}/dashboard"
                           class="${pageContext.request.requestURI.contains('/dashboard') and !pageContext.request.requestURI.contains('/sla-dashboard') ? 'active' : ''}">
                            <i class="bi bi-speedometer2"></i>
                            <span>Bảng điều khiển</span>
                        </a>
                    </li>
                </c:if>

                <%-- HỆ THỐNG --%>
                <c:if test="${sessionScope.user.roleId == 10 || sessionScope.user.roleId == 3 || sessionScope.user.roleId == 5}">
                    <li class="menu-header">HỆ THỐNG</li>
                    <c:if test="${sessionScope.user.roleId == 10}">
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/users"
                               class="${pageContext.request.requestURI.contains('/admin/users') ? 'active' : ''}">
                                <i class="bi bi-person-gear"></i>
                                <span>Quản lý người dùng</span>
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/departments"
                               class="${pageContext.request.requestURI.contains('/admin/departments') ? 'active' : ''}">
                                <i class="bi bi-diagram-3"></i>
                                <span>Quản lý phòng ban</span>
                            </a>
                        </li>
                    </c:if>
                    <li>
                        <a href="${pageContext.request.contextPath}/admin/knowledge-base"
                           class="${pageContext.request.requestURI.contains('/admin/knowledge-base') ? 'active' : ''}">
                            <i class="bi bi-journal-text"></i>
                            <span>Quản lý bài viết</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/admin/knowledge-article"
                           class="${pageContext.request.requestURI.contains('/admin/knowledge-article') ? 'active' : ''}">
                            <i class="bi bi-journal-bookmark"></i>
                            <span>Quản lý cơ sở kiến thức</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/workflows"
                           class="${pageContext.request.requestURI.contains('/workflows') ? 'active' : ''}">
                            <i class="bi bi-diagram-3"></i>
                            <span>Tự động điều hướng Ticket</span>
                        </a>
                    </li>
                </c:if>

                <%-- QUẢN LÝ PHIẾU --%>
                <li class="menu-header">QUẢN LÝ PHIẾU</li>
                <li>
                    <a href="${pageContext.request.contextPath}/incident?action=list"
                       class="${pageContext.request.requestURI.contains('/incident/') ? 'active' : ''}">
                        <i class="bi bi-exclamation-circle"></i>
                        <span>Quản lý Sự cố</span>
                    </a>
                </li>

                <c:if test="${sessionScope.user.roleId != 1}">
                    <li>
                        <a href="${pageContext.request.contextPath}/problem?action=list"
                           class="${pageContext.request.requestURI.contains('/problem/') ? 'active' : ''}">
                            <i class="bi bi-exclamation-octagon"></i>
                            <span>Quản lý Vấn đề</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/known-error?action=list"
                           class="${pageContext.request.requestURI.contains('/known-error/') ? 'active' : ''}">
                            <i class="bi bi-bug"></i>
                            <span>Lỗi đã biết</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/time-tracking"
                           class="${pageContext.request.requestURI.contains('/time-tracking') ? 'active' : ''}">
                            <i class="bi bi-clock-history"></i>
                            <span>Theo dõi Thời gian</span>
                        </a>
                    </li>
                </c:if>

                <c:if test="${sessionScope.user.roleId == 10}">
                    <li>
                        <a href="${pageContext.request.contextPath}/ticket-category"
                           class="${pageContext.request.requestURI.contains('/ticket-category') ? 'active' : ''}">
                            <i class="bi bi-tags"></i>
                            <span>Danh mục phiếu</span>
                        </a>
                    </li>
                </c:if>

                <%-- HẠ TẦNG & TÀI SẢN --%>
                <c:if test="${sessionScope.user.roleId != 1}">
                    <li class="menu-header">HẠ TẦNG &amp; TÀI SẢN</li>
                    <li>
                        <a href="${pageContext.request.contextPath}/configuration-item"
                           class="${pageContext.request.requestURI.contains('/configuration-item') ? 'active' : ''}">
                            <i class="bi bi-server"></i>
                            <span>Mục cấu hình</span>
                        </a>
                    </li>
                    <c:if test="${sessionScope.user.roleId != 1 && sessionScope.user.roleId != 2}">
                        <li>
                            <a href="${pageContext.request.contextPath}/vendor"
                               class="${pageContext.request.requestURI.contains('/vendor') ? 'active' : ''}">
                                <i class="bi bi-building"></i>
                                <span>Nhà cung cấp</span>
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/maintenance-log"
                               class="${pageContext.request.requestURI.contains('/maintenance-log') ? 'active' : ''}">
                                <i class="bi bi-tools"></i>
                                <span>Nhật ký bảo trì</span>
                            </a>
                        </li>
                    </c:if>
                </c:if>

                <%-- DỊCH VỤ --%>
                <li class="menu-header">DỊCH VỤ</li>
                <c:set var="roleId" value="${sessionScope.user.roleId}" />
                <c:set var="serviceUrl" value="${roleId == 1 ? '/service-catalog' : (roleId == 3 ? '/service-request' : '/admin-services')}" />
                <li>
                    <a href="${pageContext.request.contextPath}${serviceUrl}"
                       class="${pageContext.request.requestURI.contains(serviceUrl) or pageContext.request.requestURI.contains('/service') ? 'active' : ''}">
                        <i class="bi bi-hdd-network"></i>
                        <span>Quản lý dịch vụ</span>
                    </a>
                </li>

                <%-- BÁO CÁO & PHÂN TÍCH --%>
                <li class="menu-header">BÁO CÁO &amp; PHÂN TÍCH</li>
                <li>
                    <a href="${pageContext.request.contextPath}/sla-dashboard"
                       class="${pageContext.request.requestURI.contains('/sla-dashboard') ? 'active' : ''}">
                        <i class="bi bi-graph-up-arrow"></i>
                        <span>SLA &amp; Năng suất</span>
                    </a>
                </li>
            </ul>
        </div>

        <div class="admin-main">
            <!-- Topbar -->
            <div class="topbar">
                <div class="topbar-left">
                    <i class="bi bi-list fs-4" style="cursor:pointer;"></i>
                    <span class="fw-bold">
                        <c:choose>
                            <c:when test="${pageContext.request.requestURI.contains('/dashboard') and !pageContext.request.requestURI.contains('/sla-dashboard')}">Bảng điều khiển</c:when>
                            <c:when test="${pageContext.request.requestURI.contains('/admin/users')}">Quản lý người dùng</c:when>
                            <c:when test="${pageContext.request.requestURI.contains('/admin/departments')}">Quản lý phòng ban</c:when>
                            <c:when test="${pageContext.request.requestURI.contains('/admin/knowledge-base')}">Quản lý bài viết</c:when>
                            <c:when test="${pageContext.request.requestURI.contains('/admin/knowledge-article')}">Quản lý cơ sở kiến thức</c:when>
                            <c:when test="${pageContext.request.requestURI.contains('/ticket-category')}">Danh mục Ticket</c:when>
                            <c:when test="${pageContext.request.requestURI.contains('/workflows')}">Tự động điều hướng Ticket</c:when>
                            <c:when test="${pageContext.request.requestURI.contains('/time-tracking')}">Theo dõi Thời gian</c:when>
                            <c:when test="${pageContext.request.requestURI.contains('/sla-dashboard')}">SLA &amp; Năng suất</c:when>
                            <c:otherwise>IT Service Management</c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <div class="topbar-right">
                    <!-- Notifications -->
                    <div class="dropdown me-3">
                        <a class="badge-notification text-decoration-none text-white" id="notificationDropdown" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="bi bi-bell fs-5"></i>
                            <span class="badge bg-danger d-none" id="notificationCount">0</span>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end shadow border-0 notification-dropdown pt-0" aria-labelledby="notificationDropdown">
                            <li class="dropdown-header d-flex justify-content-between align-items-center bg-light border-bottom pt-2 pb-2">
                                <span class="fw-bold text-dark">Thông báo</span>
                                <a href="#" class="text-decoration-none small text-primary" onclick="markAllNotificationsAsRead(event)">Đánh dấu tất cả đã đọc</a>
                            </li>
                            <li class="bg-light px-2 pt-2 border-bottom">
                                <ul class="nav nav-tabs nav-justified border-0" id="notificationTabs" role="tablist" style="font-size: 0.85rem;">
                                    <li class="nav-item">
                                        <button class="nav-link active py-2 fw-semibold" id="nav-task-tab" data-bs-toggle="tab" data-bs-target="#nav-task" type="button" role="tab" style="border:none; border-bottom: 2px solid transparent;">Nhiệm vụ <span class="badge bg-danger ms-1" id="badge-task" style="display:none;">0</span></button>
                                    </li>
                                    <li class="nav-item">
                                        <button class="nav-link py-2 fw-semibold" id="nav-system-tab" data-bs-toggle="tab" data-bs-target="#nav-system" type="button" role="tab" style="border:none; border-bottom: 2px solid transparent;">Hệ thống <span class="badge bg-danger ms-1" id="badge-system" style="display:none;">0</span></button>
                                    </li>
                                </ul>
                            </li>
                            <div class="tab-content">
                                <div class="tab-pane fade show active" id="nav-task" role="tabpanel">
                                    <div id="notificationListTask" style="max-height: 300px; overflow-y: auto;"></div>
                                </div>
                                <div class="tab-pane fade" id="nav-system" role="tabpanel">
                                    <div id="notificationListSystem" style="max-height: 300px; overflow-y: auto;"></div>
                                </div>
                            </div>
                        </ul>
                    </div>
                    <!-- User Profile -->
                    <div class="user-info dropdown">
                        <a class="d-flex align-items-center text-white text-decoration-none dropdown-toggle" href="#" id="adminDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <img src="https://ui-avatars.com/api/?name=${sessionScope.user.fullName}&background=random" alt="User">
                            <span class="ms-2 d-none d-md-inline">${sessionScope.user.fullName}</span>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end shadow border-0">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile"><i class="bi bi-person me-2"></i> Hồ sơ</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile#change-pass"><i class="bi bi-shield-lock me-2"></i> Đổi mật khẩu</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/auth?action=logout"><i class="bi bi-box-arrow-right me-2"></i> Đăng xuất</a></li>
                        </ul>
                    </div>
                </div>
            </div>

            <!-- Content Area -->
            <div class="content-area">
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
                <script>
                    document.addEventListener("DOMContentLoaded", function () {
                        fetchNotifications();
                        setInterval(fetchNotifications, 30000);
                    });

                    function fetchNotifications() {
                        Promise.all([
                            fetch('${pageContext.request.contextPath}/notifications?action=api-get-unread&limit=5&type=TICKET').then(r => r.json()),
                            fetch('${pageContext.request.contextPath}/notifications?action=api-get-unread&limit=5&type=SYSTEM').then(r => r.json())
                        ]).then(([taskData, systemData]) => {
                            const totalCount = (taskData.count || 0) + (systemData.count || 0);
                            const countBadge = document.getElementById("notificationCount");
                            if (countBadge) {
                                if (totalCount > 0) {
                                    countBadge.innerText = totalCount > 99 ? '99+' : totalCount;
                                    countBadge.classList.remove("d-none");
                                } else {
                                    countBadge.classList.add("d-none");
                                }
                            }

                            const bTask = document.getElementById("badge-task");
                            if(bTask){ bTask.innerText = taskData.count || 0; bTask.style.display = (taskData.count > 0) ? "inline-block" : "none"; }
                            
                            const bSystem = document.getElementById("badge-system");
                            if(bSystem){ bSystem.innerText = systemData.count || 0; bSystem.style.display = (systemData.count > 0) ? "inline-block" : "none"; }

                            renderNotificationList(taskData, "notificationListTask");
                            renderNotificationList(systemData, "notificationListSystem");
                        }).catch(err => console.error("Error fetching notifications:", err));
                    }

                    function renderNotificationList(data, containerId) {
                        const notifList = document.getElementById(containerId);
                        if (!notifList) return;
                        notifList.innerHTML = "";
                        if (!data.notifications || data.notifications.length === 0) {
                            notifList.innerHTML = '<li class="text-center p-3 text-muted small">Không có thông báo mới</li>';
                            return;
                        }
                        data.notifications.forEach(noti => {
                            const li = document.createElement("li");
                            li.className = "notification-item unread";
                            let link = noti.relatedTicketId ? '${pageContext.request.contextPath}/incident?action=detail&id=' + noti.relatedTicketId : '${pageContext.request.contextPath}/admin/knowledge-base';
                            li.innerHTML = `
                                <a href="${link}" class="notification-content unread-text d-block">
                                    <div class="d-flex justify-content-between align-items-start mb-1">
                                        <div class="fw-bold small">\${noti.title}</div>
                                        <span class="badge bg-primary rounded-pill ms-1" style="font-size:0.65rem;">Mới</span>
                                    </div>
                                    <div class="small text-muted">\${noti.message}</div>
                                </a>
                                <button class="btn-mark-done" onclick="markNotificationAsDone(\${noti.notificationId}, event)"><i class="bi bi-check-circle"></i></button>
                            `;
                            notifList.appendChild(li);
                        });
                    }

                    function markNotificationAsDone(id, event) {
                        if (event) { event.stopPropagation(); event.preventDefault(); }
                        fetch('${pageContext.request.contextPath}/notifications?action=api-mark-seen', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                            body: 'id=' + id
                        }).then(() => fetchNotifications());
                    }

                    function markAllNotificationsAsRead(e) {
                        e.preventDefault(); e.stopPropagation();
                        fetch('${pageContext.request.contextPath}/notifications?action=api-mark-seen', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                            body: 'id=all'
                        }).then(() => fetchNotifications());
                    }
                </script>