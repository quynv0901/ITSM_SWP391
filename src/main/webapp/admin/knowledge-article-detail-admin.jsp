<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/includes/header.jsp">
    <jsp:param name="pageTitle" value="Chi tiết bài viết - Phê duyệt" />
</jsp:include>

<div class="container-fluid bg-white p-5 rounded shadow-sm mb-4">

    <%-- Tiêu đề --%>
    <div class="d-flex justify-content-between align-items-start mb-4 border-bottom pb-4">
        <div>
            <div class="d-flex align-items-center gap-3 mb-2">
                <h2 class="h3 fw-bold text-dark m-0">${article.title}</h2>
                <c:choose>
                    <c:when test="${article.status eq 'PUBLISHED'}">
                        <span class="badge bg-success shadow-sm">ĐÃ DUYỆT</span>
                    </c:when>
                    <c:when test="${article.status eq 'PENDING'}">
                        <span class="badge bg-warning text-dark shadow-sm">CHỜ DUYỆT</span>
                    </c:when>
                    <c:when test="${article.status eq 'REJECTED'}">
                        <span class="badge bg-danger shadow-sm">BỊ TỪ CHỐI</span>
                    </c:when>
                    <c:when test="${article.status eq 'INACTIVE'}">
                        <span class="badge bg-secondary shadow-sm">KHÔNG HOẠT ĐỘNG</span>
                    </c:when>
                    <c:otherwise>
                        <span class="badge bg-primary shadow-sm">${article.status}</span>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="text-muted small">
                <span class="me-3"><i class="bi bi-file-earmark-text"></i> ${article.articleNumber}</span>
                <span class="me-3"><i class="bi bi-person"></i> Tác giả: ${not empty article.authorName ? article.authorName : article.authorId}</span>
                <span><i class="bi bi-clock"></i> Cập nhật lần cuối: ${article.updatedAt}</span>
            </div>
        </div>
        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/admin/knowledge-article?action=list"
               class="btn btn-outline-secondary btn-sm">
                <i class="bi bi-arrow-left"></i> Quay lại danh sách
            </a>
        </div>
    </div>

    <%-- Alert nếu bị từ chối --%>
    <c:if test="${article.status eq 'REJECTED'}">
        <div class="alert alert-danger" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            <strong>Bài viết này đã bị TỪ CHỐI.</strong>
            <c:if test="${not empty article.rejectionReason}">
                Lý do: <em>${article.rejectionReason}</em>
            </c:if>
        </div>
    </c:if>

    <%-- Tóm tắt --%>
    <div class="mb-4 lead text-secondary border-start border-4 border-primary ps-3" style="font-size: 1.05rem;">
        ${article.summary}
    </div>

    <%-- Thông tin chung --%>
    <h4 class="h5 fw-bold text-primary mb-3 border-bottom pb-2">
        <i class="bi bi-info-circle"></i> Thông tin chung
    </h4>
    <div class="row g-3 mb-4">
        <div class="col-md-4">
            <div class="p-3 bg-light rounded border">
                <div class="text-muted small mb-1"><i class="bi bi-layers"></i> Loại bài viết</div>
                <div class="fw-semibold">${not empty article.articleType ? article.articleType : '—'}</div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="p-3 bg-light rounded border">
                <div class="text-muted small mb-1"><i class="bi bi-tag"></i> Tag</div>
                <div class="fw-semibold">${not empty article.tag ? article.tag : '—'}</div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="p-3 bg-light rounded border">
                <div class="text-muted small mb-1"><i class="bi bi-code-square"></i> Mã lỗi (Error Code)</div>
                <div class="fw-semibold font-monospace">${not empty article.errorCode ? article.errorCode : '—'}</div>
            </div>
        </div>
    </div>

    <%-- Chi tiết kỹ thuật --%>
    <h4 class="h5 fw-bold text-primary mb-3 border-bottom pb-2">
        <i class="bi bi-tools"></i> Chi tiết kỹ thuật
    </h4>
    <div class="row g-4 mb-4">
        <div class="col-md-6">
            <div class="card h-100 border-0 shadow-sm bg-light">
                <div class="card-body">
                    <h5 class="card-title h6 fw-bold text-dark">
                        <i class="bi bi-bug text-danger"></i> Triệu chứng
                    </h5>
                    <p class="card-text text-secondary mt-3" style="white-space: pre-wrap;">${not empty article.symptom ? article.symptom : '—'}</p>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="card h-100 border-0 shadow-sm bg-light">
                <div class="card-body">
                    <h5 class="card-title h6 fw-bold text-dark">
                        <i class="bi bi-search text-warning"></i> Nguyên nhân gốc rễ
                    </h5>
                    <p class="card-text text-secondary mt-3" style="white-space: pre-wrap;">${not empty article.cause ? article.cause : '—'}</p>
                </div>
            </div>
        </div>
    </div>

    <div class="card border-0 shadow-sm bg-light mb-4 border-start border-success border-4">
        <div class="card-body p-4">
            <h5 class="card-title h6 fw-bold text-success mb-3">
                <i class="bi bi-check-circle-fill"></i> Giải pháp
            </h5>
            <p class="card-text text-dark" style="white-space: pre-wrap; font-size: 1.05rem;">${not empty article.solution ? article.solution : '—'}</p>
        </div>
    </div>

    <%-- Nội dung chi tiết --%>
    <c:if test="${not empty article.content}">
        <h4 class="h5 fw-bold text-primary mb-3 border-bottom pb-2">
            <i class="bi bi-file-text"></i> Nội dung chi tiết / Tài liệu tham khảo
        </h4>
        <div class="p-4 bg-light rounded mb-4" style="white-space: pre-wrap;">${article.content}</div>
    </c:if>

    <%-- Bảng duyệt - chỉ hiện khi PENDING và Manager/Admin --%>
    <c:if test="${article.status eq 'PENDING'}">
        <div class="mt-5 p-4 rounded shadow-sm border border-warning bg-white">
            <h3 class="h5 text-warning mb-3 fw-bold">
                <i class="bi bi-shield-check"></i> Bảng duyệt bài
            </h3>
            <p class="text-muted mb-4">
                Vui lòng xem xét nội dung ở trên để duyệt hoặc từ chối bài viết này.
                Bài viết được duyệt sẽ được công bố lên cơ sở tri thức.
            </p>

            <%-- Duyệt --%>
            <form action="${pageContext.request.contextPath}/admin/knowledge-article" method="post" class="d-inline">
                <input type="hidden" name="action" value="approve">
                <input type="hidden" name="id"     value="${article.articleId}">
                <button type="submit" class="btn btn-success px-4 me-2"
                        onclick="return confirm('Duyệt bài viết này?');">
                    <i class="bi bi-check-circle"></i> Duyệt bài
                </button>
            </form>

            <%-- Từ chối - mở modal --%>
            <button type="button" class="btn btn-danger px-4"
                    data-bs-toggle="modal" data-bs-target="#rejectModal">
                <i class="bi bi-x-circle"></i> Từ chối bài
            </button>
        </div>
    </c:if>

    <%-- Kích hoạt / Vô hiệu hóa khi PUBLISHED hoặc INACTIVE --%>
    <c:if test="${article.status eq 'PUBLISHED' || article.status eq 'INACTIVE'}">
        <div class="mt-4">
            <form action="${pageContext.request.contextPath}/admin/knowledge-article" method="post" class="d-inline">
                <input type="hidden" name="action" value="toggle">
                <input type="hidden" name="id"     value="${article.articleId}">
                <c:choose>
                    <c:when test="${article.status eq 'PUBLISHED'}">
                        <input type="hidden" name="status" value="INACTIVE">
                        <button type="submit" class="btn btn-secondary"
                                onclick="return confirm('Vô hiệu hóa bài viết này?');">
                            <i class="bi bi-pause-circle"></i> Vô hiệu hóa
                        </button>
                    </c:when>
                    <c:otherwise>
                        <input type="hidden" name="status" value="PUBLISHED">
                        <button type="submit" class="btn btn-success"
                                onclick="return confirm('Kích hoạt lại bài viết này?');">
                            <i class="bi bi-play-circle"></i> Kích hoạt lại
                        </button>
                    </c:otherwise>
                </c:choose>
            </form>
        </div>
    </c:if>

</div>

<%-- Modal từ chối --%>
<div class="modal fade" id="rejectModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title"><i class="bi bi-x-circle me-2"></i>Từ chối bài viết</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/knowledge-article" method="post">
                <input type="hidden" name="action" value="reject">
                <input type="hidden" name="id"     value="${article.articleId}">
                <div class="modal-body">
                    <label class="form-label fw-semibold">
                        Lý do từ chối <span class="text-danger">*</span>
                    </label>
                    <textarea name="rejectionReason" class="form-control" rows="4"
                              placeholder="Nhập lý do từ chối để tác giả chỉnh sửa lại..."
                              required></textarea>
                    <div class="form-text text-muted mt-1">
                        Lý do sẽ hiển thị cho tác giả khi xem lại bài viết.
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-danger">
                        <i class="bi bi-x-circle"></i> Xác nhận từ chối
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />
