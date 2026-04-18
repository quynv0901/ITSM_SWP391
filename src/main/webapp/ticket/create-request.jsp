<jsp:include page="/includes/header.jsp" />
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<div class="container mt-5 mb-5">
    <div class="row justify-content-center">
        <div class="col-md-8">

            <nav aria-label="breadcrumb" class="mb-3">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item">
                        <a href="${pageContext.request.contextPath}/service-catalog">Service Catalog</a>
                    </li>
                    <li class="breadcrumb-item active">Create Service Request</li>
                </ol>
            </nav>

            <div class="card shadow-sm border-0">
                <div class="card-header bg-success text-white py-3">
                    <h4 class="mb-0">
                        <i class="bi bi-file-earmark-plus me-2"></i>Create Service Request
                    </h4>
                </div>

                <div class="card-body p-4">
                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger">${errorMessage}</div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/service-request" method="post">
                        <input type="hidden" name="action" value="create">

                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Service</label>
                                <select name="serviceId" class="form-select" required>
                                    <option value="">Select service</option>
                                    <c:forEach var="svc" items="${serviceOptions}">
                                        <option value="${svc.serviceId}"
                                                ${param.serviceId == svc.serviceId ? 'selected' : ''}>
                                            ${svc.serviceName} (${svc.serviceCode})
                                        </option>
                                    </c:forEach>
                                </select>
                                <div class="form-text">Only active services are shown.</div>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">Category</label>
                                <select name="categoryId" class="form-select">
                                    <option value="">Select category</option>
                                    <c:forEach var="cat" items="${categoryOptions}">
                                        <option value="${cat.categoryId}"
                                                ${param.categoryId == cat.categoryId ? 'selected' : ''}>
                                            ${cat.categoryName}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-bold">Title</label>
                                <input type="text" name="title" class="form-control"
                                       value="${title}" required>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">Priority</label>
                                <select name="priority" class="form-select" required>
                                    <option value="">Select priority</option>
                                    <option value="LOW" ${priority eq 'LOW' ? 'selected' : ''}>LOW</option>
                                    <option value="MEDIUM" ${priority eq 'MEDIUM' ? 'selected' : ''}>MEDIUM</option>
                                    <option value="HIGH" ${priority eq 'HIGH' ? 'selected' : ''}>HIGH</option>
                                    <option value="CRITICAL" ${priority eq 'CRITICAL' ? 'selected' : ''}>CRITICAL</option>
                                </select>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-bold">Description</label>
                                <textarea name="description" class="form-control" rows="4"
                                          placeholder="Describe what you need...">${description}</textarea>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-bold">Justification</label>
                                <textarea name="justification" class="form-control" rows="4"
                                          placeholder="Explain why you need this request..." required>${justification}</textarea>
                            </div>
                        </div>

                        <hr class="my-4">

                        <div class="d-flex justify-content-between">
                            <a href="${pageContext.request.contextPath}/service-request?action=list"
                               class="btn btn-outline-secondary">
                                <i class="bi bi-arrow-left me-1"></i> Back
                            </a>

                            <button type="submit" class="btn btn-success">
                                <i class="bi bi-send-check me-1"></i> Submit Request
                            </button>
                        </div>
                    </form>
                </div>
            </div>

        </div>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />