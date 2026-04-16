<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/includes/header.jsp">
    <jsp:param name="pageTitle" value="CMDB - Configuration Items" />
</jsp:include>

<div class="container-fluid bg-white p-4 rounded shadow-sm">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="h4 text-primary m-0">
            <i class="bi bi-server me-2"></i>Configuration Items (CMDB)
        </h2>
        <a href="${pageContext.request.contextPath}/configuration-item?action=add" class="btn btn-primary">
            <i class="bi bi-plus-circle me-1"></i> Add New CI
        </a>
    </div>

    <%-- Thông báo thành công / lỗi --%>
    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i>${sessionScope.successMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="successMessage" scope="session" />
    </c:if>
    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>${sessionScope.errorMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="errorMessage" scope="session" />
    </c:if>

    <%-- Form tìm kiếm / lọc --%>
    <form action="${pageContext.request.contextPath}/configuration-item" method="GET"
          class="bg-light p-3 rounded mb-4 border d-flex gap-3 align-items-center flex-wrap">
        <input type="hidden" name="action" value="list">

        <div class="flex-grow-1">
            <input type="text" name="q" value="${q}" class="form-control"
                   placeholder="Search by name, type or description...">
        </div>

        <div style="width: 200px;">
            <select name="status" class="form-select">
                <option value="">All Status</option>
                <option value="ACTIVE"   ${status == 'ACTIVE'   ? 'selected' : ''}>Active</option>
                <option value="INACTIVE" ${status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                <option value="RETIRED"  ${status == 'RETIRED'  ? 'selected' : ''}>Retired</option>
            </select>
        </div>

        <button type="submit" class="btn btn-primary"><i class="bi bi-search me-1"></i>Search</button>
        <a href="${pageContext.request.contextPath}/configuration-item" class="btn btn-outline-secondary">Clear</a>
    </form>

    <%-- Bảng danh sách --%>
    <div class="table-responsive">
        <table class="table table-hover table-bordered align-middle">
            <thead class="table-dark">
                <tr>
                    <th style="width:60px;">ID</th>
                    <th>Name</th>
                    <th>Type</th>
                    <th>Version</th>
                    <th>Status</th>
                    <th>Created At</th>
                    <th class="text-center" style="width:130px;">Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="ci" items="${ciList}">
                    <tr>
                        <td>${ci.ciId}</td>
                        <td><strong>${ci.name}</strong></td>
                        <td><span class="badge bg-info text-dark">${ci.type}</span></td>
                        <td>${not empty ci.version ? ci.version : '<span class="text-muted fst-italic">—</span>'}</td>
                        <td>
                            <c:choose>
                                <c:when test="${ci.status == 'ACTIVE'}">
                                    <span class="badge bg-success">Active</span>
                                </c:when>
                                <c:when test="${ci.status == 'INACTIVE'}">
                                    <span class="badge bg-warning text-dark">Inactive</span>
                                </c:when>
                                <c:when test="${ci.status == 'RETIRED'}">
                                    <span class="badge bg-secondary">Retired</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-light text-dark">${ci.status}</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>${ci.createdAt}</td>
                        <td class="text-center">
                            <a href="${pageContext.request.contextPath}/configuration-item?action=edit&id=${ci.ciId}"
                               class="btn btn-sm btn-outline-primary" title="Edit">
                                <i class="bi bi-pencil-square"></i>
                            </a>
                            <form action="${pageContext.request.contextPath}/configuration-item"
                                  method="POST" class="d-inline"
                                  onsubmit="return confirm('Are you sure you want to delete this Configuration Item?');">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="id" value="${ci.ciId}">
                                <button type="submit" class="btn btn-sm btn-outline-danger" title="Delete">
                                    <i class="bi bi-trash"></i>
                                </button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty ciList}">
                    <tr>
                        <td colspan="7" class="text-center text-muted fst-italic py-4">
                            <i class="bi bi-inbox me-2"></i>No Configuration Items found.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />
