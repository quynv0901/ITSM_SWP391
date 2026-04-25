<!DOCTYPE html>
<html lang="vi">
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

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
            --primary-blue: #3c8dbc;
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
        }

        .sidebar-header {
            padding: 20px;
            background-color: var(--primary-blue);
            text-align: center;
            font-weight: bold;
            font-size: 1.2rem;
        }

        .sidebar-menu {
            list-style: none;
            padding: 0;
            margin-top: 20px;
        }

        .menu-header {
            padding: 10px 20px;
            font-size: 0.8rem;
            color: #4b646f;
            background: #1a2226;
            text-transform: uppercase;
        }

        .menu-item {
            padding: 12px 20px;
            display: flex;
            align-items: center;
            gap: 15px;
            color: #b8c7ce;
            text-decoration: none;
            transition: 0.3s;
        }

        .menu-item:hover,
        .menu-item.active {
            color: #fff;
            background-color: var(--sidebar-hover);
            border-left: 3px solid var(--primary-blue);
        }

        .menu-item i {
            width: 20px;
            text-align: center;
        }

        /* Topbar */
        .admin-main {
            flex: 1;
            display: flex;
            flex-direction: column;
        }

        .topbar {
            height: 60px;
            background-color: var(--primary-blue);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 20px;
            color: #fff;
        }

        .topbar-left {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .topbar-right {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 10px;
            cursor: pointer;
        }

        .user-info img {
            width: 35px;
            height: 35px;
            border-radius: 50%;
            border: 2px solid rgba(255, 255, 255, 0.2);
        }

        /* Content Area */
        .content-area {
            padding: 30px;
            flex: 1;
        }

        /* Notifications Dropdown */
        .notification-dropdown {
            width: 320px;
            max-height: 400px;
            overflow-y: auto;
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
        .notification-content.unread-text {
            color: #000;
        }
        .notification-content:hover {
            color: var(--primary-blue);
        }
        .btn-mark-done {
            background: none;
            border: none;
            color: #adb5bd;
            font-size: 1.25rem;
            cursor: pointer;
            padding: 0;
            line-height: 1;
            transition: color 0.2s, transform 0.1s;
        }
        .btn-mark-done:hover {
            color: #198754;
            transform: scale(1.1);
        }
        .notification-item:hover {
            background-color: #f8f9fa;
        }
        .notification-item.unread {
            background-color: #eef2ff;
        }
        .badge-notification {
            position: relative;
            cursor: pointer;
        }
        .badge-notification .badge {
            position: absolute;
            top: -5px;
            right: -10px;
            font-size: 0.6rem;
            padding: 3px 5px;
            border-radius: 50%;
        }
    </style>
</head>

<div class="wrapper">
    <div class="sidebar">
        <div class="sidebar-header">
            ITSM
        </div>
        <ul class="sidebar-menu">

            <%-- Bảng điều khiển — chỉ Admin (10) --%>
            <c:if test="${sessionScope.user.roleId == 10}">
                <a href="${pageContext.request.contextPath}/dashboard"
                   class="menu-item ${pageContext.request.requestURI.contains('/dashboard') ? 'active' : ''}">
                    <i class="bi bi-speedometer2"></i> Bảng điều khiển
                </a>
            </c:if>

            <%-- Trang chủ — tất cả trừ Admin --%>
            <c:if test="${sessionScope.user.roleId != 10}">
                <a href="${pageContext.request.contextPath}/home"
                   class="menu-item ${pageContext.request.requestURI.contains('/home/') ? 'active' : ''}">
                    <i class="bi bi-house-door-fill"></i> Trang chủ
                </a>
            </c:if>

            <%-- Hệ thống — chỉ Admin (10) --%>
            <c:if test="${sessionScope.user.roleId == 10}">
                <li class="menu-header">Hệ thống</li>
                <a href="${pageContext.request.contextPath}/admin/users"
                   class="menu-item ${pageContext.request.requestURI.contains('/admin/users') ? 'active' : ''}">
                    <i class="bi bi-person-gear"></i> Quản lý người dùng
                </a>
                <a href="${pageContext.request.contextPath}/admin/departments"
                   class="menu-item ${pageContext.request.requestURI.contains('/admin/departments') ? 'active' : ''}">
                    <i class="bi bi-diagram-3"></i> Quản lý phòng ban
                </a>
                <a href="${pageContext.request.contextPath}/admin/knowledge-base"
                   class="menu-item ${pageContext.request.requestURI.contains('/admin/knowledge-base') ? 'active' : ''}">
                    <i class="bi bi-journal-text"></i> Quản lý bài viết
                </a>
                <a href="${pageContext.request.contextPath}/admin/knowledge-article"
                   class="menu-item ${pageContext.request.requestURI.contains('/admin/knowledge-article') ? 'active' : ''}">
                    <i class="bi bi-journal-text"></i> Quản lý cơ sở kiến thức
                </a>
                <a href="#" class="menu-item"><i class="bi bi-shield-lock"></i> Danh sách quyền</a>
                <a href="#" class="menu-item"><i class="bi bi-gear"></i> Cấu hình hệ thống</a>
                <a href="${pageContext.request.contextPath}/workflows"
                   class="menu-item ${pageContext.request.requestURI.contains('/workflows') ? 'active' : ''}">
                    <i class="bi bi-diagram-3"></i> Tự động điều hướng Ticket
                </a>
            </c:if>

            <%-- Quản lý phiếu — tất cả mọi role --%>
            <li class="menu-header">Quản lý phiếu</li>
            <a href="${pageContext.request.contextPath}/incident?action=list"
               class="menu-item ${pageContext.request.requestURI.contains('/incident/') ? 'active' : ''}">
                <i class="bi bi-exclamation-circle"></i> Quản lý Sự cố
            </a>

            <%-- Problem, Known Error — chỉ role != End User (1) --%>
            <c:if test="${sessionScope.user.roleId != 1}">
                <a href="${pageContext.request.contextPath}/problem?action=list"
                   class="menu-item ${pageContext.request.requestURI.contains('/problem/') ? 'active' : ''}">
                    <i class="bi bi-exclamation-octagon"></i> Quản lý Vấn đề
                </a>
                <a href="${pageContext.request.contextPath}/known-error?action=list"
                   class="menu-item ${pageContext.request.requestURI.contains('/known-error/') ? 'active' : ''}">
                    <i class="bi bi-bug"></i> Lỗi đã biết
                </a>
                <a href="${pageContext.request.contextPath}/time-tracking"
                   class="menu-item ${pageContext.request.requestURI.contains('/time-tracking') ? 'active' : ''}">
                    <i class="bi bi-clock-history"></i> Theo dõi Thời gian
                </a>
            </c:if>

            <%-- Danh mục phiếu — chỉ Admin (10) --%>
            <c:if test="${sessionScope.user.roleId == 10}">
                <a href="${pageContext.request.contextPath}/ticket-category"
                   class="menu-item ${pageContext.request.requestURI.contains('/ticket-category') ? 'active' : ''}">
                    <i class="bi bi-tags"></i> Danh mục phiếu
                </a>
            </c:if>

            <%-- Hạ tầng & Tài sản — chỉ role != End User (1) --%>
            <c:if test="${sessionScope.user.roleId != 1}">
                <li class="menu-header">Hạ tầng &amp; Tài sản</li>
                <a href="${pageContext.request.contextPath}/configuration-item"
                   class="menu-item ${pageContext.request.requestURI.contains('/configuration-item') ? 'active' : ''}">
                    <i class="bi bi-server"></i> Mục cấu hình
                </a>
                <c:if test="${sessionScope.user.roleId == 8 || sessionScope.user.roleId == 10}">
                    <a href="${pageContext.request.contextPath}/vendor"
                       class="menu-item ${pageContext.request.requestURI.contains('/vendor') ? 'active' : ''}">
                        <i class="bi bi-building"></i> Nhà cung cấp
                    </a>
                </c:if>
                <c:if test="${sessionScope.user.roleId == 6 || sessionScope.user.roleId == 8 || sessionScope.user.roleId == 10}">
                    <a href="${pageContext.request.contextPath}/maintenance-log"
                       class="menu-item ${pageContext.request.requestURI.contains('/maintenance-log') ? 'active' : ''}">
                        <i class="bi bi-tools"></i> Nhật ký bảo trì
                    </a>
                </c:if>
            </c:if>

            <%-- Dịch vụ — tất cả --%>
            <li class="menu-header">Dịch vụ</li>
            <a href="${pageContext.request.contextPath}/service"
               class="menu-item ${pageContext.request.requestURI.contains('/service') ? 'active' : ''}">
                <i class="bi bi-hdd-network"></i> Quản lý dịch vụ
            </a>

        </ul>
    </div>

    <div class="admin-main">
        <!-- Topbar -->
        <div class="topbar">
            <div class="topbar-left">
                <i class="bi bi-list fs-4 cursor-pointer"></i>
                <span class="fw-bold">
                    <c:choose>
                        <c:when test="${pageContext.request.requestURI.contains('/dashboard')}">Bảng điều khiển</c:when>
                        <c:when test="${pageContext.request.requestURI.contains('/admin/users')}">Quản lý người dùng</c:when>
                        <c:when test="${pageContext.request.requestURI.contains('/admin/departments')}">Quản lý phòng ban</c:when>
                        <c:when test="${pageContext.request.requestURI.contains('/admin/knowledge-base')}">Quản lý bài viết</c:when>
                        <c:when test="${pageContext.request.requestURI.contains('/admin/knowledge-article')}">Quản lý cơ sở kiến thức</c:when>
                        <c:when test="${pageContext.request.requestURI.contains('/ticket-category')}">Danh mục Ticket</c:when>
                        <c:when test="${pageContext.request.requestURI.contains('/workflows')}">Tự động điều hướng Ticket</c:when>
                        <c:when test="${pageContext.request.requestURI.contains('/time-tracking')}">Theo dõi thời gian</c:when>
                        <c:otherwise>Dịch vụ quản lý IT</c:otherwise>
                    </c:choose>
                </span>
            </div>
            <div class="topbar-right">
                <div class="dropdown me-3">
                    <div class="badge-notification" id="notificationDropdown" role="button" data-bs-toggle="dropdown">
                        <i class="bi bi-bell fs-5"></i>
                        <span class="badge bg-danger d-none" id="notificationCount">0</span>
                    </div>
                    <ul class="dropdown-menu dropdown-menu-end shadow border-0 notification-dropdown pt-0" aria-labelledby="notificationDropdown">
                        <li class="dropdown-header d-flex justify-content-between align-items-center bg-light border-bottom">
                            <span class="fw-bold text-dark">Thông báo</span>
                            <a href="#" class="text-decoration-none small text-primary" onclick="markAllNotificationsAsRead(event)">Đánh dấu tất cả đã đọc</a>
                        </li>
                        <div id="notificationList">
                            <!-- Notifications will be loaded here via JS -->
                        </div>
                    </ul>
                </div>
                <div class="user-info dropdown">
                    <a class="d-flex align-items-center text-white text-decoration-none dropdown-toggle"
                       href="#" id="adminDropdown" role="button" data-bs-toggle="dropdown">
                        <img src="https://ui-avatars.com/api/?name=${sessionScope.user.fullName}&background=random"
                             alt="User">
                        <span class="ms-2 d-none d-md-inline">${sessionScope.user.fullName}</span>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end shadow border-0">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile">
                                <i class="bi bi-person me-2"></i> Hồ sơ</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile#change-pass">
                                <i class="bi bi-shield-lock me-2"></i> Đổi mật khẩu</a></li>
                        <li>
                            <hr class="dropdown-divider">
                        </li>
                        <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/auth?action=logout">
                                <i class="bi bi-box-arrow-right me-2"></i> Đăng xuất</a></li>
                    </ul>
                </div>
            </div>
        </div>

        <div class="content-area">

<script>
    document.addEventListener("DOMContentLoaded", function() {
        fetchNotifications();
        // Poll every 30 seconds
        setInterval(fetchNotifications, 30000);
    });

    function fetchNotifications() {
        fetch('${pageContext.request.contextPath}/notifications?action=api-get-unread&limit=5')
            .then(res => res.json())
            .then(data => {
                const countBadge = document.getElementById("notificationCount");
                if (data.count > 0) {
                    countBadge.innerText = data.count > 99 ? '99+' : data.count;
                    countBadge.classList.remove("d-none");
                } else {
                    countBadge.classList.add("d-none");
                }

                const notifList = document.getElementById("notificationList");
                notifList.innerHTML = "";
                
                if (!data.notifications || data.notifications.length === 0) {
                    notifList.innerHTML = '<li class="text-center p-3 text-muted small">Không có thông báo mới</li>';
                    return;
                }

                data.notifications.forEach(noti => {
                    const li = document.createElement("li");
                    li.className = "notification-item unread";
                    
                    let link = "#";
                    if (noti.relatedTicketId) {
                        link = '${pageContext.request.contextPath}/incident?action=view&id=' + noti.relatedTicketId;
                    }
                    
                    li.innerHTML = `
                        <a href="\${link}" class="notification-content unread-text d-block">
                            <div class="d-flex justify-content-between align-items-start mb-1">
                                <div class="fw-bold small">\${noti.title}</div>
                                <span class="badge bg-primary rounded-pill ms-1" style="font-size:0.65rem; padding: 0.25rem 0.4rem;">Mới</span>
                            </div>
                            <div class="small text-muted">\${noti.message}</div>
                        </a>
                        <button class="btn-mark-done mt-1" onclick="markNotificationAsDone(\${noti.notificationId}, event)" title="Đánh dấu đã xong (Xóa)">
                            <i class="bi bi-check-circle"></i>
                        </button>
                    `;
                    notifList.appendChild(li);
                });
            })
            .catch(err => console.error("Error fetching notifications:", err));
    }

    function markNotificationAsDone(id, event) {
        if(event) {
            event.stopPropagation();
            event.preventDefault();
        }
        // Thêm hiệu ứng chớp tắt nhỏ trước khi xóa
        if(event && event.target) {
            const btn = event.target.closest('button');
            if(btn) btn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true" style="width:1rem;height:1rem;border-width:0.15em"></span>';
        }

        fetch('${pageContext.request.contextPath}/notifications?action=api-mark-seen', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'id=' + id
        })
        .then(() => {
            fetchNotifications();
        });
    }

    function markAllNotificationsAsRead(e) {
        e.preventDefault();
        e.stopPropagation();
        fetch('${pageContext.request.contextPath}/notifications?action=api-mark-seen', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'id=all'
        })
        .then(() => fetchNotifications());
    }
</script>