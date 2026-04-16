<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Configuration Items - ITSM</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <style>
            body { background-color: #f8f9fa; }
            .container { margin-top: 30px; }
            .action-btns .btn { margin-right: 5px; }
        </style>
    </head>
    <body>
        <div class="container">
            <h2 class="mb-4">Configuration Items Management</h2>
            
            <c:if test="${not empty sessionScope.successMessage}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    ${sessionScope.successMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="successMessage" scope="session" />
            </c:if>
            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    ${sessionScope.errorMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="errorMessage" scope="session" />
            </c:if>

            <div class="d-flex justify-content-between align-items-center mb-3">
                <form action="configuration-item" method="GET" class="d-flex">
                    <input type="hidden" name="action" value="list">
                    <input type="text" name="q" value="${requestScope.q}" class="form-control me-2" placeholder="Search..." style="max-width: 200px;">
                    <select name="status" class="form-select me-2" style="max-width: 150px;">
                        <option value="">All Status</option>
                        <option value="ACTIVE" ${requestScope.status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                        <option value="INACTIVE" ${requestScope.status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                        <option value="RETIRED" ${requestScope.status == 'RETIRED' ? 'selected' : ''}>Retired</option>
                    </select>
                    <button type="submit" class="btn btn-outline-primary">Search</button>
                    <a href="configuration-item?action=list" class="btn btn-outline-secondary ms-2">Reset</a>
                </form>
                <a href="configuration-item?action=add" class="btn btn-primary"><i class="fas fa-plus"></i> Add New CI</a>
            </div>

            <div class="card shadow-sm">
                <div class="card-body p-0">
                    <table class="table table-hover table-striped mb-0">
                        <thead class="table-dark">
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Type</th>
                                <th>Version</th>
                                <th>Status</th>
                                <th class="text-center">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="ci" items="${ciList}">
                                <tr>
                                    <td>${ci.ciId}</td>
                                    <td>${ci.name}</td>
                                    <td><span class="badge bg-info text-dark">${ci.type}</span></td>
                                    <td>${ci.version}</td>
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
                                    <td class="text-center action-btns">
                                        <a href="configuration-item?action=edit&id=${ci.ciId}" class="btn btn-sm btn-outline-primary" title="Edit">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <form action="configuration-item" method="POST" class="d-inline" onsubmit="return confirm('Are you sure you want to delete this CI?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="${ci.ciId}">
                                            <button type="submit" class="btn btn-sm btn-outline-danger" title="Delete">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty ciList}">
                                <tr>
                                    <td colspan="6" class="text-center py-4 text-muted">No Configuration Items found.</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
