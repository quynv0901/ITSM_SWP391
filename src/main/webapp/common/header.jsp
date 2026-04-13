<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
            <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap"
                rel="stylesheet">
            <style>
                :root {
                    --primary-color: #4e73df;
                    --secondary-color: #858796;
                }

                body {
                    background-color: #f8f9fc;
                    font-family: 'Outfit', sans-serif;
                }

                .navbar {
                    background-color: #fff;
                    box-shadow: 0 .15rem 1.75rem 0 rgba(58, 59, 69, .15);
                }

                .nav-link {
                    font-weight: 600;
                    color: var(--secondary-color);
                }

                .nav-link:hover {
                    color: var(--primary-color);
                }
            </style>
        </head>

        <body>
            <nav class="navbar navbar-expand-lg sticky-top mb-4">
                <div class="container">
                    <a class="navbar-brand fw-bold text-primary" href="${pageContext.request.contextPath}/">
                        <i class="bi bi-cpu"></i> ITServiceFlow
                    </a>
                    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                        <span class="navbar-toggler-icon"></span>
                    </button>
                    <div class="collapse navbar-collapse" id="navbarNav">
                        <ul class="navbar-nav ms-auto align-items-center">
                            <c:choose>
                                <c:when test="${not empty sessionScope.user}">
                                    <c:if test="${sessionScope.user.roleName == 'Admin'}">
                                        <li class="nav-item">
                                            <a class="nav-link me-3"
                                                href="${pageContext.request.contextPath}/admin/users">Quản lý User</a>
                                        </li>
                                    </c:if>
                                    <li class="nav-item dropdown">
                                        <a class="nav-link d-flex align-items-center" href="#" id="userDropdown"
                                            role="button" data-bs-toggle="dropdown">
                                            <i class="bi bi-person-circle fs-4 me-2"></i>
                                            <span>${sessionScope.user.fullName}</span>
                                        </a>
                                    <li><a class="nav-link d-flex align-items-center dropdown-item text-danger"
                                            href="${pageContext.request.contextPath}/auth?action=logout">Đăng xuất</a>
                                    </li>
                                    </li>
                                </c:when>
                                <c:otherwise>
                                    <li class="nav-item">
                                        <a class="btn btn-primary px-4 rounded-pill"
                                            href="${pageContext.request.contextPath}/login">Đăng nhập</a>
                                    </li>
                                </c:otherwise>
                            </c:choose>
                        </ul>
                    </div>
                </div>
            </nav>

            <script>
                // Xử lý xóa query params để tránh lặp lại thông báo khi refresh
                if (window.history.replaceState) {
                    const url = new URL(window.location.href);
                    if (url.searchParams.has('message') || url.searchParams.has('error') || url.searchParams.has('logout') || url.searchParams.has('reset')) {
                        url.searchParams.delete('message');
                        url.searchParams.delete('error');
                        url.searchParams.delete('logout');
                        url.searchParams.delete('reset');
                        window.history.replaceState({ path: url.href }, '', url.href);
                    }
                }
            </script>