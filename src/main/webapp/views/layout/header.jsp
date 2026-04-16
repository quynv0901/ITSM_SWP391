<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html lang="en" data-bs-theme="light">

    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>${param.pageTitle != null ? param.pageTitle : 'ITServiceFlow'} | ITServiceFlow ITSM</title>
        <meta name="description" content="ITServiceFlow - ITIL-Compliant IT Service Management Platform" />

        <%-- Bootstrap 5.3 CSS --%>
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
                integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
                crossorigin="anonymous" />

            <%-- Bootstrap 5.3 JS --%>
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
                    crossorigin="anonymous"></script>

                <%-- Bootstrap Icons --%>
                    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
                        rel="stylesheet" />

                    <%-- Google Fonts --%>
                        <link
                            href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
                            rel="stylesheet" />

                        <%-- Custom overrides on top of Bootstrap --%>
                            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css" />
    </head>

    <body class="d-flex">

        <!-- ══════════════════════════════════════════
     SIDEBAR
══════════════════════════════════════════ -->
        <aside class="sidebar d-flex flex-column" id="sidebar">
            <%-- Brand --%>
                <div
                    class="sidebar-brand d-flex align-items-center gap-2 px-3 py-3 border-bottom border-secondary-subtle">
                    <div class="brand-icon rounded-3 d-flex align-items-center justify-content-center flex-shrink-0">
                        <i class="bi bi-lightning-charge-fill text-white fs-5"></i>
                    </div>
                    <div>
                        <div class="fw-bold text-white small">ITServiceFlow</div>
                        <div class="text-secondary" style="font-size:10px;">ITSM Platform</div>
                    </div>
                </div>

                <%-- Nav --%>
                    <nav class="flex-grow-1 py-2 overflow-y-auto">
                        <div class="sidebar-section text-uppercase text-secondary px-3 py-2"
                            style="font-size:10px;letter-spacing:1px;font-weight:600;">Core</div>

                        <a class="nav-item d-flex align-items-center gap-2 px-3 py-2 rounded mx-2
                   ${param.activeNav == 'dashboard' ? 'active' : ''}" href="${pageContext.request.contextPath}/">
                            <i class="bi bi-grid-1x2-fill"></i> Dashboard
                        </a>
                        <a class="nav-item d-flex align-items-center gap-2 px-3 py-2 rounded mx-2
                   ${param.activeNav == 'tickets' ? 'active' : ''}" href="#">
                            <i class="bi bi-ticket-perforated-fill"></i> Tickets
                        </a>

                        <div class="sidebar-section text-uppercase text-secondary px-3 pt-3 pb-2"
                            style="font-size:10px;letter-spacing:1px;font-weight:600;">Service</div>

                        <a class="nav-item d-flex align-items-center gap-2 px-3 py-2 rounded mx-2
                   ${param.activeNav == 'catalog' ? 'active' : ''}" href="#">
                            <i class="bi bi-grid-fill"></i> Service Catalog
                        </a>
                        <a class="nav-item d-flex align-items-center gap-2 px-3 py-2 rounded mx-2
                   ${param.activeNav == 'sla' ? 'active' : ''}" href="#">
                            <i class="bi bi-clock-history"></i> SLA Policies
                        </a>
                        <a class="nav-item d-flex align-items-center gap-2 px-3 py-2 rounded mx-2
                  ${param.activeNav == 'problem' ? 'active' : ''}"
                            href="${pageContext.request.contextPath}/problem?action=list">
                            <i class="bi bi-exclamation-octagon-fill"></i> Problem
                        </a>
                        <a class="nav-item d-flex align-items-center gap-2 px-3 py-2 rounded mx-2
                  ${param.activeNav == 'known-error' ? 'active' : ''}"
                            href="${pageContext.request.contextPath}/known-error?action=list">
                            <i class="bi bi-bug-fill"></i> Known Error
                        </a>

                        <div class="sidebar-section text-uppercase text-secondary px-3 pt-3 pb-2"
                            style="font-size:10px;letter-spacing:1px;font-weight:600;">Knowledge</div>

                        <a class="nav-item d-flex align-items-center gap-2 px-3 py-2 rounded mx-2
                   ${param.activeNav == 'kb' ? 'active' : ''}" href="#">
                            <i class="bi bi-book-fill"></i> Knowledge Base
                        </a>

                        <div class="sidebar-section text-uppercase text-secondary px-3 pt-3 pb-2"
                            style="font-size:10px;letter-spacing:1px;font-weight:600;">Infrastructure</div>

                        <a class="nav-item d-flex align-items-center gap-2 px-3 py-2 rounded mx-2
                   ${param.activeNav == 'configuration-item' ? 'active' : ''}"
                            href="${pageContext.request.contextPath}/configuration-item">
                            <i class="bi bi-hdd-network-fill"></i> CMDB
                        </a>

                        <div class="sidebar-section text-uppercase text-secondary px-3 pt-3 pb-2"
                            style="font-size:10px;letter-spacing:1px;font-weight:600;">Admin</div>

                        <a class="nav-item d-flex align-items-center gap-2 px-3 py-2 rounded mx-2
                   ${param.activeNav == 'users' ? 'active' : ''}" href="#">
                            <i class="bi bi-people-fill"></i> Users
                        </a>
                        <a class="nav-item d-flex align-items-center gap-2 px-3 py-2 rounded mx-2
                   ${param.activeNav == 'roles' ? 'active' : ''}" href="#">
                            <i class="bi bi-shield-lock-fill"></i> Roles & Permissions
                        </a>
                    </nav>

                    <%-- Bottom user area --%>
                        <div class="p-3 border-top border-secondary-subtle d-flex align-items-center gap-2">
                            <div
                                class="avatar-sm rounded-circle bg-primary d-flex align-items-center justify-content-center flex-shrink-0">
                                <i class="bi bi-person-fill text-white" style="font-size:14px;"></i>
                            </div>
                            <div class="overflow-hidden">
                                <div class="text-white fw-semibold"
                                    style="font-size:12px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                                    Admin</div>
                                <div class="text-secondary" style="font-size:11px;">System Administrator</div>
                            </div>
                        </div>
        </aside>

        <!-- ══════════════════════════════════════════
     MAIN CONTENT WRAPPER (starts here)
     Each page closes this div in footer.jsp
══════════════════════════════════════════ -->
        <div class="main-content d-flex flex-column min-vh-100">