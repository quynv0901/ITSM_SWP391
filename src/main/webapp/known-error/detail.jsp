<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/includes/header.jsp" />

<div class="container-fluid bg-white p-4 rounded shadow-sm" style="max-width: 900px; margin: auto;">
    <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-2">
        <h2 class="h4 text-primary m-0">
            Known Error Details: ${knownError.ticketNumber}
        </h2>
        <div>
            <a href="${pageContext.request.contextPath}/known-error?action=edit&id=${knownError.ticketId}" class="btn btn-warning btn-sm text-dark">
                <i class="bi bi-pencil"></i> Edit
            </a>
            <a href="${pageContext.request.contextPath}/known-error?action=list" class="btn btn-outline-secondary btn-sm">
                <i class="bi bi-arrow-left"></i> Back to List
            </a>
        </div>
    </div>

    <div class="row mb-4">
        <div class="col-md-6 mb-3">
            <h5 class="text-muted fw-bold">Title</h5>
            <p class="fs-5">${knownError.title}</p>
        </div>
        <div class="col-md-6 mb-3">
            <h5 class="text-muted fw-bold">Status</h5>
            <p>
                <c:choose>
                    <c:when test="${knownError.status == 'NEW'}"><span class="badge bg-info text-dark">NEW</span></c:when>
                    <c:when test="${knownError.status == 'IN_PROGRESS'}"><span class="badge bg-primary">IN_PROGRESS</span></c:when>
                    <c:when test="${knownError.status == 'RESOLVED'}"><span class="badge bg-success">RESOLVED</span></c:when>
                    <c:when test="${knownError.status == 'CLOSED'}"><span class="badge bg-secondary">CLOSED</span></c:when>
                    <c:otherwise><span class="badge bg-dark">${knownError.status}</span></c:otherwise>
                </c:choose>
            </p>
        </div>
        
        <div class="col-md-6 mb-3">
            <h5 class="text-muted fw-bold">Created At</h5>
            <p><fmt:formatDate value="${knownError.createdAt}" pattern="dd/MM/yyyy HH:mm" /></p>
        </div>
        <div class="col-md-6 mb-3">
            <h5 class="text-muted fw-bold">Updated At</h5>
            <p><fmt:formatDate value="${knownError.updatedAt}" pattern="dd/MM/yyyy HH:mm" /></p>
        </div>
    </div>

    <div class="mb-4">
        <h5 class="text-muted fw-bold">Description</h5>
        <div class="p-3 bg-light rounded border">
            ${knownError.description}
        </div>
    </div>

    <div class="mb-4">
        <h5 class="text-muted fw-bold">Root Cause</h5>
        <div class="p-3 bg-danger bg-opacity-10 rounded border border-danger">
            ${empty knownError.cause ? '<em class="text-muted">Not specified</em>' : knownError.cause}
        </div>
    </div>

    <div class="mb-4">
        <h5 class="text-muted fw-bold">Workaround / Solution</h5>
        <div class="p-3 bg-success bg-opacity-10 rounded border border-success">
            ${empty knownError.solution ? '<em class="text-muted">Not specified</em>' : knownError.solution}
        </div>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />
