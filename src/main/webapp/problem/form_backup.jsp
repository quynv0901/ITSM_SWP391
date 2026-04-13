<jsp:include page="/includes/header.jsp" />

<div class="container-fluid bg-white p-4 rounded shadow-sm" style="max-width: 800px; margin: auto;">
    <h2 class="h4 text-primary mb-4 border-bottom pb-2">${not empty problem ? 'Update Problem Ticket' : 'Create Problem
        Ticket'}</h2>

    <form action="${pageContext.request.contextPath}/problem?action=${not empty problem ? 'update' : 'insert'}"
        method="post">
        <c:if test="${not empty problem}">
            <input type="hidden" name="id" value="${problem.ticketId}">
        </c:if>

        <div class="mb-3">
            <label for="title" class="form-label fw-bold">Problem Title / Summary <span
                    class="text-danger">*</span></label>
            <input type="text" class="form-control" id="title" name="title" value="${problem.title}" required>
        </div>

        <div class="mb-3">
            <label for="description" class="form-label fw-bold">Detailed Description <span
                    class="text-danger">*</span></label>
            <textarea class="form-control" id="description" name="description" rows="5"
                required>${problem.description}</textarea>
        </div>

        <c:if test="${not empty problem}">
            <div class="mb-3">
                <label for="status" class="form-label fw-bold">Status</label>
                <select class="form-select" id="status" name="status">
                    <option value="NEW" ${problem.status=='NEW' ? 'selected' : '' }>New</option>
                    <option value="IN_PROGRESS" ${problem.status=='IN_PROGRESS' ? 'selected' : '' }>In Progress</option>
                    <option value="RESOLVED" ${problem.status=='RESOLVED' ? 'selected' : '' }>Resolved</option>
                </select>
            </div>
        </c:if>

        <div class="mb-3">
            <label for="cause" class="form-label fw-bold">Root Cause</label>
            <textarea class="form-control" id="cause" name="cause" rows="4">${problem.cause}</textarea>
        </div>

        <div class="mb-3">
            <label for="solution" class="form-label fw-bold">Workaround / Permanent Solution</label>
            <textarea class="form-control" id="solution" name="solution" rows="4">${problem.solution}</textarea>
        </div>

        <c:if test="${empty problem}">
            <div class="mb-3">
                <label for="incidentIds" class="form-label fw-bold">Link Incidents (Optional)</label>
                <select multiple class="form-select" id="incidentIds" name="incidentIds" size="5">
                    <c:forEach var="inc" items="${incidents}">
                        <option value="${inc.ticketId}">${inc.ticketNumber} - ${inc.title}</option>
                    </c:forEach>
                </select>
                <div class="form-text">Hold Ctrl (Windows) or Command (Mac) to select multiple incidents matching this
                    problem.</div>
            </div>
        </c:if>

        <div class="d-grid gap-2 mt-4">
            <button type="submit" class="btn btn-primary btn-lg">
                <i class="bi bi-save"></i> ${not empty problem ? 'Save Update' : 'Submit Problem Ticket'}
            </button>
            <a href="${pageContext.request.contextPath}/problem?action=list" class="btn btn-outline-secondary">Cancel
                and Return</a>
        </div>
    </form>
</div>

<jsp:include page="/includes/footer.jsp" />