<jsp:include page="/includes/header.jsp" />
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

    <div class="container-fluid bg-white p-4 rounded shadow-sm" style="max-width: 800px; margin: auto;">
        <h2 class="h4 text-primary mb-4 border-bottom pb-2">${not empty knownError ? 'Update Known Error' : 'Create
            Known Error'}</h2>

        <form
            action="${pageContext.request.contextPath}/known-error?action=${not empty knownError ? 'update' : 'insert'}"
            method="post">
            <c:if test="${not empty knownError}">
                <input type="hidden" name="id" value="${knownError.articleId}">
            </c:if>

            <div class="mb-3">
                <label for="title" class="form-label fw-bold">Article Title <span class="text-danger">*</span></label>
                <input type="text" class="form-control" id="title" name="title" value="${knownError.title}" required>
            </div>

            <div class="mb-3">
                <label for="summary" class="form-label fw-bold">Short Summary <span class="text-danger">*</span></label>
                <textarea class="form-control" id="summary" name="summary" rows="2"
                    required>${knownError.summary}</textarea>
            </div>

            <div class="mb-3">
                <label for="symptom" class="form-label fw-bold">Symptoms & Errors <span
                        class="text-danger">*</span></label>
                <textarea class="form-control" id="symptom" name="symptom" rows="4" required
                    placeholder="What error messages appear? What does the user see?">${knownError.symptom}</textarea>
            </div>

            <div class="mb-3">
                <label for="cause" class="form-label fw-bold">Root Cause</label>
                <textarea class="form-control" id="cause" name="cause" rows="4"
                    placeholder="Why is this happening? (Optional if not fully root caused yet)">${knownError.cause}</textarea>
            </div>

            <div class="mb-3">
                <label for="solution" class="form-label fw-bold">Workaround / Permanent Solution <span
                        class="text-danger">*</span></label>
                <textarea class="form-control" id="solution" name="solution" rows="5" required
                    placeholder="Step-by-step instructions to fix it.">${knownError.solution}</textarea>
            </div>

            <div class="mb-3">
                <label for="content" class="form-label fw-bold">Additional References / Content</label>
                <textarea class="form-control" id="content" name="content" rows="4">${knownError.content}</textarea>
            </div>

            <div class="d-grid gap-2 mt-4">
                <button type="submit" class="btn btn-primary btn-lg">
                    <i class="bi bi-save"></i> ${not empty knownError ? 'Save Updates' : 'Publish Article'}
                </button>
                <a href="${pageContext.request.contextPath}/known-error?action=list"
                    class="btn btn-outline-secondary">Cancel and Return</a>
            </div>
        </form>
    </div>

    <jsp:include page="/includes/footer.jsp" />
