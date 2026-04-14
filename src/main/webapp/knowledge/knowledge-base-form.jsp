<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/includes/header.jsp">
    <jsp:param name="pageTitle" value="${empty article.articleId ? 'Create Knowledge Base' : 'Edit Knowledge Base'}" />
</jsp:include>

<div class="container-fluid bg-white p-4 rounded shadow-sm">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="h4 text-primary m-0">
            <i class="bi bi-journal-plus me-2"></i>
            ${empty article.articleId ? 'Create New Knowledge Base' : 'Edit Knowledge Base'}
        </h2>
        <a href="${pageContext.request.contextPath}/admin/knowledge-base?action=list"
           class="btn btn-outline-secondary">
            <i class="bi bi-arrow-left me-1"></i> Back
        </a>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle me-2"></i>${error}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/admin/knowledge-base?action=${empty article.articleId ? 'add' : 'edit'}"
          method="post">
        <input type="hidden" name="articleId" value="${article.articleId}">

        <div class="row g-4">
            <%-- LEFT --%>
            <div class="col-lg-8">
                <div class="card border-0 shadow-sm mb-4">
                    <div class="card-header bg-light fw-bold">
                        <i class="bi bi-info-circle me-2 text-primary"></i>Basic Information
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label fw-bold">
                                Title <span class="text-danger">*</span>
                            </label>
                            <input type="text" name="title" class="form-control"
                                   placeholder="Enter article title..."
                                   required value="${article.title}">
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Summary</label>
                            <textarea name="summary" class="form-control" rows="3"
                                      placeholder="Brief description...">${article.summary}</textarea>
                        </div>
                        <div class="mb-0">
                            <label class="form-label fw-bold">
                                Content <span class="text-danger">*</span>
                            </label>
                            <textarea name="content" class="form-control" rows="12"
                                      placeholder="Write article content here..."
                                      required>${article.content}</textarea>
                        </div>
                    </div>
                </div>

                <div class="card border-0 shadow-sm">
                    <div class="card-header bg-light fw-bold">
                        <i class="bi bi-tools me-2 text-warning"></i>Technical Details
                        <span class="fw-normal text-muted small ms-1">(optional)</span>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label fw-bold">
                                Error Code: No 
                            </label> <br/>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Symptom</label>
                            <textarea name="symptom" class="form-control" rows="3"
                                      placeholder="Describe the symptom...">${article.symptom}</textarea>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Cause</label>
                            <textarea name="cause" class="form-control" rows="3"
                                      placeholder="What causes this issue...">${article.cause}</textarea>
                        </div>
                        <div class="mb-0">
                            <label class="form-label fw-bold">Solution</label>
                            <textarea name="solution" class="form-control" rows="4"
                                      placeholder="Step-by-step solution...">${article.solution}</textarea>
                        </div>
                    </div>
                </div>
            </div>

            <%-- RIGHT --%>
            <div class="col-lg-4">
                <div class="card border-0 shadow-sm mb-4">
                    <div class="card-header bg-light fw-bold">
                        <i class="bi bi-gear me-2 text-secondary"></i>Settings
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label fw-bold">
                                Article Type: KNOWLEDGE BASE 
                            </label> <br/>
                        </div>
                    </div>
                </div>

                <div class="card border-0 shadow-sm">
                    <div class="card-body d-grid gap-2">
                        <button type="submit" name="submitAction" value="publish" class="btn btn-primary">
                            <i class="bi bi-save me-2"></i>Save
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/knowledge-base?action=list"
                           class="btn btn-outline-danger">
                            <i class="bi bi-x-circle me-2"></i>Cancel
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </form>
</div>

<jsp:include page="/includes/footer.jsp" />