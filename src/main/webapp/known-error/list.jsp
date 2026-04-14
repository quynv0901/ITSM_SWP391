<jsp:include page="/includes/header.jsp" />
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid bg-white p-4 rounded shadow-sm mb-4">
    <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-2">
        <h2 class="h4 text-danger m-0"><i class="bi bi-bug"></i> Known Error Database</h2>
        <a href="${pageContext.request.contextPath}/known-error?action=add" class="btn btn-primary">
            <i class="bi bi-plus-circle"></i> Create Known Error
        </a>
    </div>

    <div class="table-responsive">
        <table class="table table-hover table-bordered align-middle">
            <thead class="table-light">
                <tr>
                    <th>#</th>
                    <th>Ticket Number</th>
                    <th>Title</th>
                    <th>Root Cause</th>
                    <th>Workaround</th>
                    <th>Date Added</th>
                    <th class="text-center" style="width: 150px;">Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${not empty knownErrors}">
                        <c:forEach var="err" items="${knownErrors}" varStatus="status">
                            <tr>
                                <td>${status.index + 1}</td>
                                <td><strong>${err.ticketNumber}</strong></td>
                                <td>${err.title}</td>
                                <td class="text-danger">${err.cause}</td>
                                <td class="text-success">${err.solution}</td>
                                <td><fmt:formatDate value="${err.createdAt}" pattern="dd/MM/yyyy" /></td>
                                <td>
                                    <div class="d-flex gap-1 justify-content-center">
                                        <a href="${pageContext.request.contextPath}/known-error?action=detail&id=${err.ticketId}" class="btn btn-info btn-sm text-white" title="View"><i class="bi bi-eye"></i></a>
                                        <a href="${pageContext.request.contextPath}/known-error?action=edit&id=${err.ticketId}" class="btn btn-warning btn-sm text-dark" title="Edit"><i class="bi bi-pencil"></i></a>
                                        <form action="${pageContext.request.contextPath}/known-error?action=delete" method="POST" onsubmit="return confirm('Do you want to delete this Known Error?');" style="display:inline;">
                                            <input type="hidden" name="id" value="${err.ticketId}">
                                            <button type="submit" class="btn btn-danger btn-sm" title="Delete"><i class="bi bi-trash"></i></button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="7" class="text-center text-muted">Không có Known Error nào trong hệ thống lúc này.</td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />
