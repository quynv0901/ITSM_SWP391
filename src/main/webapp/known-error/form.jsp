<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/includes/header.jsp" />

<div class="container-fluid bg-white p-4 rounded shadow-sm" style="max-width: 800px; margin: auto;">
    <h2 class="h4 text-primary mb-4 border-bottom pb-2">
        ${not empty knownError ? 'Update Known Error' : 'Create Known Error'}
    </h2>

    <form action="${pageContext.request.contextPath}/known-error?action=${not empty knownError ? 'update' : 'insert'}" method="post">
        
        <c:if test="${not empty knownError}">
            <input type="hidden" name="id" value="${knownError.ticketId}">
        </c:if>

        <div class="mb-3">
            <label for="title" class="form-label fw-bold">Title / Summary <span class="text-danger">*</span></label>
            <input type="text" class="form-control" id="title" name="title" value="${not empty knownError ? knownError.title : ''}" required>
        </div>

        <div class="mb-3">
            <label for="description" class="form-label fw-bold">Detailed Description <span class="text-danger">*</span></label>
            <textarea class="form-control" id="description" name="description" rows="5" required>${not empty knownError ? knownError.description : ''}</textarea>
        </div>

        <div class="mb-3">
            <label for="status" class="form-label fw-bold">Status</label>
            <select class="form-select" id="status" name="status">
                <option value="NEW" ${knownError.status == 'NEW' ? 'selected' : ''}>New</option>
                <option value="IN_PROGRESS" ${knownError.status == 'IN_PROGRESS' ? 'selected' : ''}>In Progress</option>
                <option value="RESOLVED" ${knownError.status == 'RESOLVED' ? 'selected' : ''}>Resolved</option>
                <option value="CLOSED" ${knownError.status == 'CLOSED' ? 'selected' : ''}>Closed</option>
            </select>
        </div>

        <div class="mb-3">
            <label for="cause" class="form-label fw-bold">Root Cause</label>
            <textarea class="form-control" id="cause" name="cause" rows="4">${not empty knownError ? knownError.cause : ''}</textarea>
        </div>

        <div class="mb-3">
            <label for="solution" class="form-label fw-bold">Workaround / Permanent Solution</label>
            <textarea class="form-control" id="solution" name="solution" rows="4">${not empty knownError ? knownError.solution : ''}</textarea>
        </div>

        <div class="d-grid gap-2 mt-4">
            <button type="submit" class="btn btn-primary btn-lg">
                <i class="bi bi-save"></i> ${not empty knownError ? 'Save Update' : 'Submit Known Error'}
            </button>
            <a href="${pageContext.request.contextPath}/known-error?action=list" class="btn btn-outline-secondary">Cancel and Return</a>
        </div>
    </form>
</div>

<jsp:include page="/includes/footer.jsp" />
