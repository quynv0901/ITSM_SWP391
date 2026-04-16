<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>${empty ci ? 'Add Configuration Item' : 'Edit Configuration Item'} - ITSM</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body class="bg-light">
        <div class="container mt-5" style="max-width: 600px;">
            <div class="card shadow">
                <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">${empty ci ? 'Add New Configuration Item' : 'Edit Configuration Item'}</h5>
                    <a href="configuration-item" class="btn btn-sm btn-light">Back to List</a>
                </div>
                <div class="card-body">
                    <form action="configuration-item" method="POST">
                        <input type="hidden" name="action" value="${empty ci ? 'add' : 'edit'}">
                        
                        <c:if test="${not empty ci}">
                            <input type="hidden" name="id" value="${ci.ciId}">
                        </c:if>

                        <div class="mb-3">
                            <label for="name" class="form-label">Name <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="name" name="name" required value="${ci.name}" placeholder="e.g., Mail Server">
                        </div>

                        <div class="mb-3">
                            <label for="type" class="form-label">Type <span class="text-danger">*</span></label>
                            <select class="form-select" id="type" name="type" required>
                                <option value="" disabled ${empty ci ? 'selected' : ''}>Select Type...</option>
                                <option value="Hardware" ${ci.type == 'Hardware' ? 'selected' : ''}>Hardware</option>
                                <option value="Software" ${ci.type == 'Software' ? 'selected' : ''}>Software</option>
                                <option value="Network" ${ci.type == 'Network' ? 'selected' : ''}>Network</option>
                                <option value="Service" ${ci.type == 'Service' ? 'selected' : ''}>Service</option>
                                <option value="Other" ${ci.type == 'Other' ? 'selected' : ''}>Other</option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label for="version" class="form-label">Version</label>
                            <input type="text" class="form-control" id="version" name="version" value="${ci.version}" placeholder="e.g., v2.0, 2023">
                        </div>

                        <div class="mb-3">
                            <label for="status" class="form-label">Status</label>
                            <select class="form-select" id="status" name="status">
                                <option value="ACTIVE" ${ci.status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                                <option value="INACTIVE" ${ci.status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                                <option value="RETIRED" ${ci.status == 'RETIRED' ? 'selected' : ''}>Retired</option>
                            </select>
                        </div>

                        <div class="mb-4">
                            <label for="description" class="form-label">Description</label>
                            <textarea class="form-control" id="description" name="description" rows="4">${ci.description}</textarea>
                        </div>

                        <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                            <a href="configuration-item" class="btn btn-secondary me-md-2">Cancel</a>
                            <button type="submit" class="btn btn-primary">${empty ci ? 'Save Item' : 'Update Item'}</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
