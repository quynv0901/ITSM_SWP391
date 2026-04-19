<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/includes/header.jsp" />

<div class="container-fluid bg-white p-5 rounded shadow-sm mb-4">
    <%-- Tiêu đề tài liệu --%>
    <div class="d-flex justify-content-between align-items-start mb-4 border-bottom pb-4">
        <div>
            <div class="d-flex align-items-center gap-3 mb-2">
                <h2 class="h3 fw-bold text-dark m-0">${knownError.title}</h2>
                <c:choose>
                    <c:when test="${knownError.status eq 'APPROVED'}">
                        <span class="badge bg-success shadow-sm">ĐÃ DUYỆT</span>
                    </c:when>
                    <c:when test="${knownError.status eq 'PENDING'}">
                        <span class="badge bg-warning text-dark shadow-sm">CHỜ DUYỆT</span>
                    </c:when>
                    <c:when test="${knownError.status eq 'REJECTED'}">
                        <span class="badge bg-danger shadow-sm">BỊ TỪ CHỐI</span>
                    </c:when>
                    <c:when test="${knownError.status eq 'INACTIVE'}">
                        <span class="badge bg-secondary shadow-sm">KHÔNG HOẠT ĐỘNG</span>
                    </c:when>
                    <c:otherwise>
                        <span class="badge bg-primary shadow-sm">${knownError.status}</span>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="text-muted small">
                <span class="me-3"><i class="bi bi-file-earmark-text"></i> ${knownError.articleNumber}</span>
                <span class="me-3"><i class="bi bi-person"></i> Tác giả: ${knownError.authorName != null ? knownError.authorName : knownError.authorId}</span>
                <span><i class="bi bi-clock"></i> Cập nhật lần cuối: ${knownError.updatedAt}</span>
            </div>
        </div>
        <div class="d-flex gap-2">
            <c:if test="${knownError.authorId == sessionScope.user.userId || sessionScope.user.roleId == 3 || sessionScope.user.roleId == 10}">
                <a href="${pageContext.request.contextPath}/known-error?action=edit&id=${knownError.articleId}"
                   class="btn btn-outline-warning btn-sm">
                    <i class="bi bi-pencil"></i> Chỉnh sửa
                </a>
            </c:if>
            <a href="${pageContext.request.contextPath}/known-error?action=list"
               class="btn btn-outline-secondary btn-sm">
                <i class="bi bi-arrow-left"></i> Quay lại danh sách
            </a>
        </div>
    </div>

    <c:if test="${knownError.status eq 'REJECTED'}">
        <div class="alert alert-danger" role="alert">
            <i class="bi bi-exclamation-triangle-fill flex-shrink-0 me-2"></i>
            <strong>Bài viết này đã bị TỪ CHỐI.</strong> Vui lòng chỉnh sửa để khắc phục các vấn đề.
        </div>
    </c:if>

    <%-- Tóm tắt --%>
    <div class="mb-5 lead text-secondary border-start border-4 border-primary ps-3" style="font-size: 1.1rem;">
        ${knownError.summary}
    </div>

    <h4 class="h5 fw-bold text-primary mb-3 border-bottom pb-2">Chi tiết kỹ thuật</h4>

    <div class="row g-4 mb-5">
        <div class="col-md-6">
            <div class="card h-100 border-0 shadow-sm bg-light">
                <div class="card-body">
                    <h5 class="card-title h6 fw-bold text-dark">
                        <i class="bi bi-bug text-danger"></i> Triệu chứng
                    </h5>
                    <p class="card-text text-secondary mt-3" style="white-space: pre-wrap;">${knownError.symptom}</p>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="card h-100 border-0 shadow-sm bg-light">
                <div class="card-body">
                    <h5 class="card-title h6 fw-bold text-dark">
                        <i class="bi bi-search text-warning"></i> Nguyên nhân gốc rễ
                    </h5>
                    <p class="card-text text-secondary mt-3" style="white-space: pre-wrap;">${knownError.cause}</p>
                </div>
            </div>
        </div>
    </div>

    <div class="card border-0 shadow-sm bg-light mb-5 border-start border-success border-4">
        <div class="card-body p-4">
            <h5 class="card-title h6 fw-bold text-success mb-3">
                <i class="bi bi-check-circle-fill"></i> Giải pháp tạm thời & Vĩnh viễn
            </h5>
            <p class="card-text text-dark" style="white-space: pre-wrap; font-size: 1.05rem;">${knownError.solution}</p>
        </div>
    </div>

    <c:if test="${not empty knownError.content}">
        <h4 class="h5 fw-bold text-primary mb-3 border-bottom pb-2">Nội dung chi tiết / Tài liệu tham khảo</h4>
        <div class="p-4 bg-light rounded" style="white-space: pre-wrap;">${knownError.content}</div>
    </c:if>

    <%-- Bảng duyệt (chỉ hiện khi PENDING và Manager/Admin) --%>
    <c:if test="${knownError.status eq 'PENDING'}">
        <c:if test="${sessionScope.user.roleId == 10 || sessionScope.user.roleId == 3}">
            <div class="mt-5 p-4 rounded shadow-sm border border-warning bg-white">
                <h3 class="h5 text-warning mb-3 fw-bold">
                    <i class="bi bi-shield-check"></i> Bảng duyệt bài
                </h3>
                <p class="text-muted mb-4">
                    Vui lòng xem xét nội dung ở trên để duyệt hoặc từ chối bài viết này.
                    Bài viết được duyệt sẽ được công bố lên cơ sở tri thức.
                </p>

                <form action="${pageContext.request.contextPath}/known-error?action=review" method="post">
                    <input type="hidden" name="id" value="${knownError.articleId}">

                    <div class="mb-3">
                        <label class="form-label fw-bold">Lý do từ chối (Tùy chọn):</label>
                        <textarea class="form-control bg-light" name="rejectionReason" rows="3"
                                  placeholder="Nếu từ chối, vui lòng nêu rõ lý do..."></textarea>
                    </div>

                    <div class="d-flex gap-2 mt-4">
                        <button type="submit" name="status" value="APPROVED" class="btn btn-success px-4">
                            <i class="bi bi-check-circle"></i> Duyệt bài
                        </button>
                        <button type="submit" name="status" value="REJECTED" class="btn btn-danger px-4">
                            <i class="bi bi-x-circle"></i> Từ chối bài
                        </button>
                    </div>
                </form>
            </div>
        </c:if>
    </c:if>
</div>

<jsp:include page="/includes/footer.jsp" />
