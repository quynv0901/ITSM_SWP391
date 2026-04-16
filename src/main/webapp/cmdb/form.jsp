<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/includes/header.jsp">
    <jsp:param name="pageTitle" value="${empty ci ? 'Add Configuration Item' : 'Edit Configuration Item'}" />
</jsp:include>

<div class="container-fluid">
    <div class="row justify-content-center">
        <div class="col-lg-7 col-md-9">

            <div class="bg-white rounded shadow-sm p-4">
                <%-- Tiêu đề form --%>
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h4 class="text-primary m-0">
                        <i class="bi bi-server me-2"></i>
                        ${empty ci ? 'Add New Configuration Item' : 'Edit Configuration Item'}
                    </h4>
                    <a href="${pageContext.request.contextPath}/configuration-item"
                       class="btn btn-outline-secondary btn-sm">
                        <i class="bi bi-arrow-left me-1"></i> Back to List
                    </a>
                </div>

                <form action="${pageContext.request.contextPath}/configuration-item" method="POST">
                    <input type="hidden" name="action" value="${empty ci ? 'add' : 'edit'}">
                    <c:if test="${not empty ci}">
                        <input type="hidden" name="id" value="${ci.ciId}">
                    </c:if>

                    <%-- Name --%>
                    <div class="mb-3">
                        <label for="name" class="form-label fw-semibold">
                            Name <span class="text-danger">*</span>
                        </label>
                        <input type="text" class="form-control" id="name" name="name"
                               required maxlength="100"
                               value="${ci.name}" placeholder="e.g., Main Database Server">
                    </div>

                    <%-- Type --%>
                    <div class="mb-3">
                        <label for="type" class="form-label fw-semibold">
                            Type <span class="text-danger">*</span>
                        </label>
                        <select class="form-select" id="type" name="type" required>
                            <option value="" disabled ${empty ci ? 'selected' : ''}>Select CI Type...</option>
                            <option value="Hardware" ${ci.type == 'Hardware' ? 'selected' : ''}>Hardware</option>
                            <option value="Software" ${ci.type == 'Software' ? 'selected' : ''}>Software</option>
                            <option value="Network"  ${ci.type == 'Network'  ? 'selected' : ''}>Network</option>
                            <option value="Service"  ${ci.type == 'Service'  ? 'selected' : ''}>Service</option>
                            <option value="Other"    ${ci.type == 'Other'    ? 'selected' : ''}>Other</option>
                        </select>
                    </div>

                    <%-- Version --%>
                    <div class="mb-3">
                        <label for="version" class="form-label fw-semibold">Version</label>
                        <input type="text" class="form-control" id="version" name="version"
                               maxlength="50"
                               value="${ci.version}" placeholder="e.g., v2.0, Ubuntu 22.04">
                    </div>

                    <%-- Status --%>
                    <div class="mb-3">
                        <label for="status" class="form-label fw-semibold">Status</label>
                        <select class="form-select" id="status" name="status">
                            <option value="ACTIVE"   ${ci.status == 'ACTIVE'   || empty ci ? 'selected' : ''}>Active</option>
                            <option value="INACTIVE" ${ci.status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                            <option value="RETIRED"  ${ci.status == 'RETIRED'  ? 'selected' : ''}>Retired</option>
                        </select>
                    </div>

                    <%-- Description --%>
                    <div class="mb-4">
                        <label for="description" class="form-label fw-semibold">Description</label>
                        <textarea class="form-control" id="description" name="description"
                                  rows="4" placeholder="Brief description of this configuration item...">${ci.description}</textarea>
                    </div>

                    <%-- Buttons --%>
                    <div class="d-flex justify-content-end gap-2">
                        <a href="${pageContext.request.contextPath}/configuration-item"
                           class="btn btn-secondary">Cancel</a>
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-save me-1"></i>
                            ${empty ci ? 'Save Item' : 'Update Item'}
                        </button>
                    </div>
                </form>
            </div>

        </div>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />
