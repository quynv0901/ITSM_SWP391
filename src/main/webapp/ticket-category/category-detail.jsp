<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

                <style>
                    .detail-card {
                        background: #fff;
                        border: 1px solid #dde3ec;
                        border-radius: 10px;
                        padding: 28px 30px;
                        box-shadow: 0 2px 10px rgba(0, 0, 0, .06);
                        margin-bottom: 22px;
                    }

                    .detail-section-title {
                        font-size: 13px;
                        font-weight: 700;
                        text-transform: uppercase;
                        letter-spacing: .5px;
                        color: #5a6a85;
                        margin-bottom: 18px;
                        padding-bottom: 10px;
                        border-bottom: 1px solid #edf2f7;
                        display: flex;
                        align-items: center;
                        gap: 8px;
                    }

                    .detail-grid {
                        display: grid;
                        grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
                        gap: 20px;
                    }

                    .detail-field {
                        display: flex;
                        flex-direction: column;
                        gap: 4px;
                    }

                    .detail-field .field-label {
                        font-size: 11px;
                        font-weight: 700;
                        text-transform: uppercase;
                        letter-spacing: .5px;
                        color: #a0aec0;
                    }

                    .detail-field .field-value {
                        font-size: 14px;
                        color: #2d3748;
                        font-weight: 500;
                    }

                    .badge-type {
                        display: inline-block;
                        padding: 4px 11px;
                        border-radius: 6px;
                        font-size: 12px;
                        font-weight: 700;
                    }

                    .bt-incident {
                        background: #fef9e7;
                        color: #b7770d;
                        border: 1px solid #fdebd0;
                    }

                    .bt-service {
                        background: #e8f8f5;
                        color: #1e8449;
                        border: 1px solid #d5f5e3;
                    }

                    .bt-change {
                        background: #f4ecf7;
                        color: #7d3c98;
                        border: 1px solid #e8daef;
                    }

                    .bt-problem {
                        background: #fdedec;
                        color: #c0392b;
                        border: 1px solid #fadbd8;
                    }

                    .badge-diff {
                        display: inline-block;
                        padding: 4px 11px;
                        border-radius: 6px;
                        font-size: 12px;
                        font-weight: 700;
                    }

                    .bd-easy {
                        background: #f0fff4;
                        color: #276749;
                        border: 1px solid #9ae6b4;
                    }

                    .bd-medium {
                        background: #fffaf0;
                        color: #c05621;
                        border: 1px solid #fbd38d;
                    }

                    .bd-hard {
                        background: #fff5f5;
                        color: #c53030;
                        border: 1px solid #feb2b2;
                    }

                    .status-on {
                        padding: 4px 12px;
                        border-radius: 12px;
                        font-size: 12px;
                        font-weight: 700;
                        background: #f0fff4;
                        color: #276749;
                        border: 1px solid #9ae6b4;
                    }

                    .status-off {
                        padding: 4px 12px;
                        border-radius: 12px;
                        font-size: 12px;
                        font-weight: 700;
                        background: #fff5f5;
                        color: #c53030;
                        border: 1px solid #feb2b2;
                    }

                    .sub-table {
                        width: 100%;
                        border-collapse: collapse;
                        font-size: 13.5px;
                    }

                    .sub-table th {
                        background: #f7fafc;
                        text-align: left;
                        padding: 9px 14px;
                        font-size: 11px;
                        font-weight: 700;
                        text-transform: uppercase;
                        letter-spacing: .5px;
                        color: #718096;
                        border-bottom: 2px solid #edf2f7;
                    }

                    .sub-table td {
                        padding: 9px 14px;
                        border-bottom: 1px solid #f0f4f8;
                        vertical-align: middle;
                    }

                    .sub-table tbody tr:last-child td {
                        border-bottom: none;
                    }

                    .sub-table tbody tr:hover td {
                        background: #f7fbff;
                    }

                    .action-strip {
                        display: flex;
                        gap: 10px;
                        flex-wrap: wrap;
                        margin-bottom: 22px;
                    }

                    .stat-pill {
                        display: inline-flex;
                        align-items: center;
                        gap: 6px;
                        padding: 6px 14px;
                        border-radius: 8px;
                        font-size: 13px;
                        font-weight: 700;
                    }

                    .sp-blue {
                        background: #e8f4fd;
                        color: #2e86c1;
                    }

                    .sp-orange {
                        background: #fef9e7;
                        color: #b7770d;
                    }

                    .desc-box {
                        background: #f9fbfd;
                        border: 1px solid #edf2f7;
                        border-radius: 7px;
                        padding: 14px 16px;
                        font-size: 13.5px;
                        color: #4a5568;
                        line-height: 1.6;
                    }
                </style>

                <%@ include file="/common/admin-layout-top.jsp" %>

                    <c:if test="${empty cat}">
                        <div class="alert alert-warning">Category not found. <a
                                href="${pageContext.request.contextPath}/ticket-category">Back to list</a>.</div>
                    </c:if>
                    <c:if test="${not empty cat}">

                        <%-- Breadcrumb --%>
                            <nav aria-label="breadcrumb" style="margin-bottom:18px;">
                                <ol class="breadcrumb mb-0" style="font-size:13px; background:none; padding:0;">
                                    <li class="breadcrumb-item"><a
                                            href="${pageContext.request.contextPath}/ticket-category"
                                            class="text-decoration-none text-primary">Ticket Categories</a></li>
                                    <c:if test="${not empty cat.parentCategoryName}">
                                        <li class="breadcrumb-item text-muted">${cat.parentCategoryName}</li>
                                    </c:if>
                                    <li class="breadcrumb-item active">${cat.categoryName}</li>
                                </ol>
                            </nav>

                            <%-- Page header --%>
                                <div class="d-flex align-items-start justify-content-between mb-3 flex-wrap gap-2">
                                    <div>
                                        <h4 class="fw-bold mb-1" style="color:#222d32;">
                                            <i class="bi bi-tag-fill me-2 text-primary"></i>${cat.categoryName}
                                        </h4>
                                        <c:if test="${not empty cat.categoryCode}">
                                            <code
                                                style="font-size:13px; color:#718096; background:#edf2f7; padding:2px 8px; border-radius:4px;">${cat.categoryCode}</code>
                                        </c:if>
                                    </div>
                                    <div class="action-strip">
                                        <a href="${pageContext.request.contextPath}/ticket-category?action=form&id=${cat.categoryId}"
                                            class="btn btn-warning btn-sm px-3"><i
                                                class="bi bi-pencil me-1"></i>Edit</a>
                                        <button class="btn btn-sm px-3 ${cat.active ? 'btn-secondary' : 'btn-success'}"
                                            onclick="confirmToggle(${cat.categoryId}, ${!cat.active}, '${fn:escapeXml(cat.categoryName)}')">
                                            <i class="bi bi-toggle-${cat.active ? 'on' : 'off'} me-1"></i>${cat.active ?
                                            'Deactivate' : 'Activate'}
                                        </button>
                                        <button class="btn btn-danger btn-sm px-3"
                                            onclick="confirmDelete(${cat.categoryId}, '${fn:escapeXml(cat.categoryName)}', ${cat.ticketCount}, ${cat.childCount})">
                                            <i class="bi bi-trash3 me-1"></i>Delete
                                        </button>
                                        <a href="${pageContext.request.contextPath}/ticket-category"
                                            class="btn btn-outline-secondary btn-sm px-3">
                                            <i class="bi bi-arrow-left me-1"></i>Back
                                        </a>
                                    </div>
                                </div>

                                <%-- Stats pills --%>
                                    <div class="d-flex gap-3 flex-wrap mb-4">
                                        <span class="stat-pill sp-blue"><i class="bi bi-diagram-3"></i>
                                            ${cat.childCount} Sub-categories</span>
                                        <span class="stat-pill sp-orange"><i class="bi bi-ticket-perforated"></i>
                                            ${cat.ticketCount} Tickets</span>
                                        <c:choose>
                                            <c:when test="${cat.active}"><span class="status-on"><i
                                                        class="bi bi-circle-fill"
                                                        style="font-size:8px;"></i>Active</span></c:when>
                                            <c:otherwise><span class="status-off"><i class="bi bi-circle-fill"
                                                        style="font-size:8px;"></i>Inactive</span></c:otherwise>
                                        </c:choose>
                                    </div>

                                    <%-- Details card --%>
                                        <div class="detail-card">
                                            <div class="detail-section-title"><i
                                                    class="bi bi-info-circle-fill text-primary"></i> Category
                                                Information
                                            </div>
                                            <div class="detail-grid">
                                                <div class="detail-field">
                                                    <div class="field-label">Category Name</div>
                                                    <div class="field-value">${cat.categoryName}</div>
                                                </div>
                                                <div class="detail-field">
                                                    <div class="field-label">Category Code</div>
                                                    <div class="field-value">${not empty cat.categoryCode ?
                                                        cat.categoryCode : '—'}</div>
                                                </div>
                                                <div class="detail-field">
                                                    <div class="field-label">Type</div>
                                                    <div class="field-value">
                                                        <c:choose>
                                                            <c:when test="${cat.categoryType == 'INCIDENT'}"> <span
                                                                    class="badge-type bt-incident">Incident</span>
                                                            </c:when>
                                                            <c:when test="${cat.categoryType == 'SERVICE_REQUEST'}">
                                                                <span class="badge-type bt-service">Service
                                                                    Request</span>
                                                            </c:when>
                                                            <c:when test="${cat.categoryType == 'CHANGE'}"> <span
                                                                    class="badge-type bt-change">Change</span>
                                                            </c:when>
                                                            <c:when test="${cat.categoryType == 'PROBLEM'}"> <span
                                                                    class="badge-type bt-problem">Problem</span>
                                                            </c:when>
                                                            <c:otherwise>${cat.categoryType}</c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                                <div class="detail-field">
                                                    <div class="field-label">Difficulty Level</div>
                                                    <div class="field-value">
                                                        <c:choose>
                                                            <c:when test="${cat.difficultyLevel == 'EASY'}"> <span
                                                                    class="badge-diff bd-easy">Easy</span></c:when>
                                                            <c:when test="${cat.difficultyLevel == 'MEDIUM'}"> <span
                                                                    class="badge-diff bd-medium">Medium</span>
                                                            </c:when>
                                                            <c:when test="${cat.difficultyLevel == 'HARD'}"> <span
                                                                    class="badge-diff bd-hard">Hard</span></c:when>
                                                            <c:otherwise>—</c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                                <div class="detail-field">
                                                    <div class="field-label">Parent Category</div>
                                                    <div class="field-value">
                                                        <c:choose>
                                                            <c:when test="${not empty cat.parentCategoryName}">
                                                                <a href="${pageContext.request.contextPath}/ticket-category?action=detail&id=${cat.parentCategoryId}"
                                                                    style="color:#3c8dbc; text-decoration:none; font-weight:600;">
                                                                    <i
                                                                        class="bi bi-arrow-return-right me-1"></i>${cat.parentCategoryName}
                                                                </a>
                                                            </c:when>
                                                            <c:otherwise><span class="text-muted">— Root (no parent)
                                                                    —</span></c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                                <div class="detail-field">
                                                    <div class="field-label">Last Updated</div>
                                                    <div class="field-value">
                                                        <c:choose>
                                                            <c:when test="${not empty cat.updatedAt}">
                                                                <fmt:formatDate value="${cat.updatedAt}"
                                                                    pattern="dd/MM/yyyy HH:mm" />
                                                            </c:when>
                                                            <c:otherwise>—</c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </div>
                                            <c:if test="${not empty cat.description}">
                                                <div class="mt-4">
                                                    <div class="field-label mb-2">Description</div>
                                                    <div class="desc-box">${cat.description}</div>
                                                </div>
                                            </c:if>
                                        </div>

                                        <%-- Sub-categories --%>
                                            <div class="detail-card">
                                                <div class="detail-section-title">
                                                    <i class="bi bi-diagram-3 text-primary"></i>
                                                    Sub-categories
                                                    <span
                                                        class="badge bg-primary bg-opacity-10 text-primary ms-2">${cat.childCount}</span>
                                                    <a href="${pageContext.request.contextPath}/ticket-category?action=form&parentId=${cat.categoryId}"
                                                        class="btn btn-sm btn-outline-primary ms-auto"
                                                        style="font-size:12px;">
                                                        <i class="bi bi-plus-circle me-1"></i>Add Sub-category
                                                    </a>
                                                </div>
                                                <c:choose>
                                                    <c:when test="${empty children}">
                                                        <p class="text-muted text-center py-3" style="font-size:13px;">
                                                            No sub-categories found.</p>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <table class="sub-table">
                                                            <thead>
                                                                <tr>
                                                                    <th>Name</th>
                                                                    <th>Code</th>
                                                                    <th>Type</th>
                                                                    <th>Difficulty</th>
                                                                    <th>Tickets</th>
                                                                    <th>Status</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <c:forEach var="child" items="${children}">
                                                                    <tr>
                                                                        <td>
                                                                            <a href="${pageContext.request.contextPath}/ticket-category?action=detail&id=${child.categoryId}"
                                                                                style="color:#3c8dbc; font-weight:600; text-decoration:none;">${child.categoryName}</a>
                                                                        </td>
                                                                        <td style="font-size:12px; color:#718096;">${not
                                                                            empty child.categoryCode ?
                                                                            child.categoryCode : '—'}</td>
                                                                        <td>
                                                                            <c:choose>
                                                                                <c:when
                                                                                    test="${child.categoryType == 'INCIDENT'}">
                                                                                    <span
                                                                                        class="badge-type bt-incident">Incident</span>
                                                                                </c:when>
                                                                                <c:when
                                                                                    test="${child.categoryType == 'SERVICE_REQUEST'}">
                                                                                    <span
                                                                                        class="badge-type bt-service">Service
                                                                                        Req.</span>
                                                                                </c:when>
                                                                                <c:when
                                                                                    test="${child.categoryType == 'CHANGE'}">
                                                                                    <span
                                                                                        class="badge-type bt-change">Change</span>
                                                                                </c:when>
                                                                                <c:when
                                                                                    test="${child.categoryType == 'PROBLEM'}">
                                                                                    <span
                                                                                        class="badge-type bt-problem">Problem</span>
                                                                                </c:when>
                                                                                <c:otherwise>${child.categoryType}
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </td>
                                                                        <td>
                                                                            <c:choose>
                                                                                <c:when
                                                                                    test="${child.difficultyLevel == 'EASY'}">
                                                                                    <span
                                                                                        class="badge-diff bd-easy">Easy</span>
                                                                                </c:when>
                                                                                <c:when
                                                                                    test="${child.difficultyLevel == 'MEDIUM'}">
                                                                                    <span
                                                                                        class="badge-diff bd-medium">Medium</span>
                                                                                </c:when>
                                                                                <c:when
                                                                                    test="${child.difficultyLevel == 'HARD'}">
                                                                                    <span
                                                                                        class="badge-diff bd-hard">Hard</span>
                                                                                </c:when>
                                                                                <c:otherwise>—</c:otherwise>
                                                                            </c:choose>
                                                                        </td>
                                                                        <td class="text-center">${child.ticketCount}
                                                                        </td>
                                                                        <td>
                                                                            <c:choose>
                                                                                <c:when test="${child.active}"><span
                                                                                        class="status-on"
                                                                                        style="font-size:11px;">Active</span>
                                                                                </c:when>
                                                                                <c:otherwise><span class="status-off"
                                                                                        style="font-size:11px;">Inactive</span>
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </td>
                                                                    </tr>
                                                                </c:forEach>
                                                            </tbody>
                                                        </table>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>

                                            <%-- Delete modal --%>
                                                <div class="modal fade" id="deleteModal" tabindex="-1">
                                                    <div class="modal-dialog modal-dialog-centered"
                                                        style="max-width:420px;">
                                                        <div class="modal-content border-0 shadow-lg">
                                                            <div class="modal-header bg-danger text-white">
                                                                <h5 class="modal-title"><i
                                                                        class="bi bi-trash3 me-2"></i>Delete Category
                                                                </h5>
                                                                <button type="button" class="btn-close btn-close-white"
                                                                    data-bs-dismiss="modal"></button>
                                                            </div>
                                                            <form method="post"
                                                                action="${pageContext.request.contextPath}/ticket-category">
                                                                <input type="hidden" name="action" value="delete">
                                                                <input type="hidden" name="id" id="deleteId">
                                                                <div class="modal-body">
                                                                    <p class="mb-0">Delete category <strong
                                                                            id="deleteName"></strong>? This action
                                                                        <span class="text-danger fw-semibold">cannot be
                                                                            undone</span>.
                                                                    </p>
                                                                </div>
                                                                <div class="modal-footer border-0">
                                                                    <button type="button"
                                                                        class="btn btn-secondary btn-sm"
                                                                        data-bs-dismiss="modal">Cancel</button>
                                                                    <button type="submit"
                                                                        class="btn btn-danger btn-sm px-4">Delete</button>
                                                                </div>
                                                            </form>
                                                        </div>
                                                    </div>
                                                </div>

                                                <%-- Toggle modal --%>
                                                    <div class="modal fade" id="toggleModal" tabindex="-1">
                                                        <div class="modal-dialog modal-dialog-centered"
                                                            style="max-width:400px;">
                                                            <div class="modal-content border-0 shadow-lg">
                                                                <div class="modal-header" id="toggleHdr">
                                                                    <h5 class="modal-title" id="toggleTitle"></h5>
                                                                    <button type="button" class="btn-close"
                                                                        id="toggleClosBtn"
                                                                        data-bs-dismiss="modal"></button>
                                                                </div>
                                                                <form method="post"
                                                                    action="${pageContext.request.contextPath}/ticket-category">
                                                                    <input type="hidden" name="action" value="toggle">
                                                                    <input type="hidden" name="id" id="toggleId">
                                                                    <input type="hidden" name="active"
                                                                        id="toggleActive">
                                                                    <input type="hidden" name="back"
                                                                        value="${pageContext.request.contextPath}/ticket-category?action=detail&id=${cat.categoryId}">
                                                                    <div class="modal-body">
                                                                        <p class="mb-0" id="toggleMsg"></p>
                                                                    </div>
                                                                    <div class="modal-footer border-0">
                                                                        <button type="button"
                                                                            class="btn btn-secondary btn-sm"
                                                                            data-bs-dismiss="modal">Cancel</button>
                                                                        <button type="submit" class="btn btn-sm px-4"
                                                                            id="toggleBtn"></button>
                                                                    </div>
                                                                </form>
                                                            </div>
                                                        </div>
                                                    </div>

                    </c:if><%-- end cat check --%>

                        <script>
                            function confirmDelete(id, name, ticketCount, childCount) {
                                if (ticketCount > 0) {
                                    alert('Cannot delete — ' + ticketCount + ' ticket(s) are referencing this category.');
                                    return;
                                }
                                if (childCount > 0) {
                                    alert('Cannot delete — this category has ' + childCount + ' sub-categorie(s).');
                                    return;
                                }
                                document.getElementById('deleteId').value = id;
                                document.getElementById('deleteName').textContent = name;
                                bootstrap.Modal.getOrCreateInstance(document.getElementById('deleteModal')).show();
                            }
                            function confirmToggle(id, newActive, name) {
                                document.getElementById('toggleId').value = id;
                                document.getElementById('toggleActive').value = newActive;
                                const hdr = document.getElementById('toggleHdr');
                                hdr.className = 'modal-header ' + (newActive ? 'bg-success text-white' : 'bg-secondary text-white');
                                document.getElementById('toggleTitle').textContent = newActive ? 'Activate Category' : 'Deactivate Category';
                                document.getElementById('toggleMsg').innerHTML = (newActive ? 'Activate' : 'Deactivate') + ' <strong>' + name + '</strong>?';
                                document.getElementById('toggleClosBtn').className = 'btn-close' + (newActive || !newActive ? ' btn-close-white' : '');
                                const btn = document.getElementById('toggleBtn');
                                btn.className = 'btn btn-sm px-4 ' + (newActive ? 'btn-success' : 'btn-secondary');
                                btn.textContent = newActive ? 'Activate' : 'Deactivate';
                                bootstrap.Modal.getOrCreateInstance(document.getElementById('toggleModal')).show();
                            }
                        </script>

                        <jsp:include page="/common/admin-layout-bottom.jsp" />