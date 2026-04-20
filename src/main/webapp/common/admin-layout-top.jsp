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
    </style>
</head>

<div class="wrapper">
    <div class="sidebar">
        <div class="sidebar-header">
            ITSM
        </div>
        <ul class="sidebar-menu">
            <!-- Dashboard placed at top for quick access -->
            <a href="${pageContext.request.contextPath}/dashboard"
               class="menu-item ${pageContext.request.requestURI.contains('/dashboard') ? 'active' : ''}">
                <i class="bi bi-speedometer2"></i> Bảng điều khiển
            </a>
            <li class="menu-header">Hệ thống</li>
            <a href="${pageContext.request.contextPath}/admin/users"
               class="menu-item ${pageContext.request.requestURI.endsWith('/admin/users.jsp') ? 'active' : ''}">
                <i class="bi bi-person-gear"></i> Quản lý người dùng
            </a>
                        <a href="${pageContext.request.contextPath}/admin/knowledge-base"
               class="menu-item ${pageContext.request.requestURI.endsWith('/admin/knowledge-base.jsp') ? 'active' : ''}">
                <i class="bi bi-journal-text"></i> Quản lý bài viết
            </a>
            <a href="#" class="menu-item"><i class="bi bi-shield-lock"></i> Danh sách Quyền</a>
            <a href="#" class="menu-item"><i class="bi bi-gear"></i> Cấu hình hệ thống</a>

            <li class="menu-header">Ticket Management</li>
            <a href="${pageContext.request.contextPath}/incident?action=list"
               class="menu-item ${pageContext.request.requestURI.contains('/incident/') ? 'active' : ''}">
                <i class="bi bi-exclamation-circle"></i> Incident Management
            </a>
            <a href="${pageContext.request.contextPath}/problem?action=list"
               class="menu-item ${pageContext.request.requestURI.contains('/problem/') ? 'active' : ''}">
                <i class="bi bi-exclamation-octagon"></i> Problem Management
            </a>
            <a href="${pageContext.request.contextPath}/known-error?action=list"
               class="menu-item ${pageContext.request.requestURI.contains('/known-error/') ? 'active' : ''}">
                <i class="bi bi-bug"></i> Known Error Database
            </a>

            <li class="menu-header">Infrastructure</li>
            <a href="${pageContext.request.contextPath}/configuration-item"
               class="menu-item ${pageContext.request.requestURI.contains('/configuration-item') ? 'active' : ''}">
                <i class="bi bi-server"></i> CMDB
            </a>

            <li class="menu-header">Service</li>
            <a href="${pageContext.request.contextPath}/admin/service-management"
               class="menu-item ${pageContext.request.requestURI.contains('/admin/service-management') ? 'active' : ''}">
                <i class="bi bi-hdd-network"></i> Service Management
            </a>
            <li class="menu-header">Ticket Management</li>
            <a href="${pageContext.request.contextPath}/ticket-category"
               class="menu-item ${pageContext.request.requestURI.contains('/ticket-category') ? 'active' : ''}">
                <i class="bi bi-tags"></i> Ticket Categories
            </a>
            <a href="${pageContext.request.contextPath}/time-tracking"
               class="menu-item ${pageContext.request.requestURI.contains('/time-tracking') ? 'active' : ''}">
                <i class="bi bi-clock-history"></i> Time Tracking
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
                        <c:when test="${pageContext.request.requestURI.contains('/ticket-category')}">Ticket Categories</c:when>
                        <c:otherwise>IT Service Management</c:otherwise>
                    </c:choose>
                </span>
            </div>
            <div class="topbar-right">
                <i class="bi bi-bell badge-notification"></i>
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