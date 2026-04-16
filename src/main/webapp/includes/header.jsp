<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ITSM System</title>
        <!-- Bootstrap 5 CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <!-- Bootstrap Icons -->
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
        <!-- Google Fonts -->
        <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap"
              rel="stylesheet">
        <style>
            :root {
                --sidebar-bg: #222d32;
                --sidebar-hover: #1e282c;
                --primary-blue: #3c8dbc;
            }

            body {
                font-family: 'Outfit', sans-serif;
                background-color: #f4f7f6;
            }

            .wrapper {
                display: flex;
                min-height: 100vh;
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
                color: #fff;
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
                overflow-x: hidden;
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
                overflow-y: auto;
            }

            /* Override default anchor styles in content */
            .content-area a {
                text-decoration: none;
            }
        </style>
    </head>

    <body>

        <div class="wrapper">
            <!-- Sidebar -->
            <div class="sidebar">
                <div class="sidebar-header">
                    ITSM
                </div>
                <ul class="sidebar-menu">

                    <c:if test="${sessionScope.user != null && sessionScope.user.roleId == 2}">
                        <a href="${pageContext.request.contextPath}/home"
                           class="menu-item ${pageContext.request.requestURI.contains('/home/') ? 'active' : ''}">
                            <i class="bi bi-house-door-fill"></i> Trang chủ
                        </a>
                        <li class="menu-header">Hệ thống</li>
                        <a href="${pageContext.request.contextPath}/admin/users"
                           class="menu-item ${pageContext.request.requestURI.endsWith('/admin/users.jsp') ? 'active' : ''}">
                            <i class="bi bi-person-gear"></i> Quản lý người dùng
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/knowledge-base"
                               class="menu-item ${pageContext.request.requestURI.endsWith('/admin/knowledge-base.jsp') ? 'active' : ''}">
                                <i class="bi bi-journal-text"></i> Knowledge Base
                            </a>
                        <c:if test="${sessionScope.user != null && sessionScope.user.roleId == 10}">
                            <li class="menu-header">Hệ thống</li>
                            <a href="${pageContext.request.contextPath}/admin/users"
                               class="menu-item ${pageContext.request.requestURI.endsWith('/admin/users.jsp') ? 'active' : ''}">
                                <i class="bi bi-person-gear"></i> Quản lý người dùng
                            </a>
                        </c:if>

                        <li class="menu-header">Ticket Management</li>
                        <a href="${pageContext.request.contextPath}/incident?action=list"
                           class="menu-item ${pageContext.request.requestURI.contains('/incident/') ? 'active' : ''}">
                            <i class="bi bi-exclamation-circle"></i> Incident Management
                        </a>
                        <a href="${pageContext.request.contextPath}/problem?action=list"
                           class="menu-item ${pageContext.request.requestURI.contains('/problem/') ? 'active' : ''}">
                            <i class="bi bi-exclamation-octagon"></i> Problem Management
                        </a>
                        <a href="${pageContext.request.contextPath}/ticket-category"
                           class="menu-item ${pageContext.request.requestURI.contains('/ticket-category') ? 'active' : ''}">
                            <i class="bi bi-tags"></i> Ticket Categories
                        </a>
                        <a href="${pageContext.request.contextPath}/known-error?action=list"
                           class="menu-item ${pageContext.request.requestURI.contains('/known-error/') ? 'active' : ''}">
                            <i class="bi bi-bug"></i> Known Error Database
                        </a>
                        <li class="menu-header">Service</li>
                        <a href="${pageContext.request.contextPath}/service"
                           class="menu-item ${pageContext.request.requestURI.contains('/service') ? 'active' : ''}">
                            <i class="bi bi-hdd-network"></i> Service Catalog
                        </a>

                        <li class="menu-header">Reports &amp; Analytics</li>
                        <a href="${pageContext.request.contextPath}/dashboard"
                           class="menu-item ${pageContext.request.requestURI.contains('/dashboard') ? 'active' : ''}">
                            <i class="bi bi-speedometer2"></i> Executive Dashboard
                        </a>
                    </c:if>
                    <li class="menu-header">Ticket Management</li>
                    <a href="${pageContext.request.contextPath}/incident?action=list"
                       class="menu-item ${pageContext.request.requestURI.contains('/incident/') ? 'active' : ''}">
                        <i class="bi bi-exclamation-circle"></i> Incident Management
                    </a>
                    <a href="${pageContext.request.contextPath}/problem?action=list"
                       class="menu-item ${pageContext.request.requestURI.contains('/problem/') ? 'active' : ''}">
                        <i class="bi bi-exclamation-octagon"></i> Problem Management
                    </a>
                    <a href="${pageContext.request.contextPath}/ticket-category"
                       class="menu-item ${pageContext.request.requestURI.contains('/ticket-category') ? 'active' : ''}">
                        <i class="bi bi-tags"></i> Ticket Categories
                    </a>
                    <a href="${pageContext.request.contextPath}/known-error?action=list"
                       class="menu-item ${pageContext.request.requestURI.contains('/known-error/') ? 'active' : ''}">
                        <i class="bi bi-bug"></i> Known Error Database
                    </a>
                    <li class="menu-header">Service</li>
                    <a href="${pageContext.request.contextPath}/service"
                       class="menu-item ${pageContext.request.requestURI.contains('/service') ? 'active' : ''}">
                        <i class="bi bi-hdd-network"></i> Service Catalog
                    </a>

                    <li class="menu-header">Reports &amp; Analytics</li>
                    <a href="${pageContext.request.contextPath}/dashboard"
                       class="menu-item ${pageContext.request.requestURI.contains('/dashboard') ? 'active' : ''}">
                        <i class="bi bi-speedometer2"></i> Executive Dashboard
                    </a>
                </ul>
            </div>

            <!-- Main Content -->
            <div class="admin-main">
                <!-- Topbar -->
                <div class="topbar">
                    <div class="topbar-left">
                        <i class="bi bi-list fs-4 cursor-pointer"></i>
                        <span class="fw-bold">
                            <c:choose>
                                <c:when test="${pageContext.request.requestURI.contains('/problem/')}">Problem
                                    Management</c:when>
                                <c:when test="${pageContext.request.requestURI.contains('/known-error/')}">Known
                                    Error Database</c:when>

                                <c:when test="${pageContext.request.requestURI.contains('/ticket-category')}">Ticket
                                    Categories</c:when>

                                <c:when test="${pageContext.request.requestURI.contains('/dashboard')}">Executive
                                    Dashboard</c:when>
                                <c:when test="${pageContext.request.requestURI.contains('/home/')}">Trang chủ</c:when>
                                <c:otherwise>IT Service Management</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                    <div class="topbar-right">
                        <i class="bi bi-bell badge-notification"></i>
                        <div class="user-info dropdown">
                            <a class="d-flex align-items-center text-white text-decoration-none dropdown-toggle"
                               href="#" id="adminDropdown" role="button" data-bs-toggle="dropdown"
                               aria-expanded="false">
                                <!-- Fallback user info if session doesn't exist -->
                                <img src="https://ui-avatars.com/api/?name=${not empty sessionScope.user ? sessionScope.user.fullName : 'Admin'}&background=random"
                                     alt="User">
                                <span class="ms-2 d-none d-md-inline">${not empty sessionScope.user ?
                                                                        sessionScope.user.fullName : 'Hảo Hảo'}</span>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end shadow border-0"
                                aria-labelledby="adminDropdown">
                                <li><a class="dropdown-item" href="#"><i class="bi bi-person me-2"></i> Hồ sơ</a>
                                </li>
                                <li><a class="dropdown-item" href="#"><i class="bi bi-shield-lock me-2"></i> Đổi mật
                                        khẩu</a></li>
                                <li>
                                    <hr class="dropdown-divider">
                                </li>
                                <li><a class="dropdown-item text-danger"
                                       href="${pageContext.request.contextPath}/auth?action=logout"><i
                                            class="bi bi-box-arrow-right me-2"></i> Đăng xuất</a></li>
                            </ul>
                        </div>
                    </div>
                </div>

                <div class="content-area">