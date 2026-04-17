<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<!-- Bootstrap Icons -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
<!-- Google Fonts -->
<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap"
      rel="stylesheet">

<div class="container-fluid bg-white p-4 rounded shadow-sm">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="h4 text-primary m-0">
            <i class="bi bi-journal-text me-2"></i>Thông tin bài viết
        </h2>
        <div class="d-flex gap-2">
            <c:if test="${article.status == 'PENDING'}">
                <form action="${pageContext.request.contextPath}/admin/knowledge-base?action=approve"
                      method="post" class="d-inline">
                    <input type="hidden" name="articleId" value="${article.articleId}">
                </c:if>
                <a href="${pageContext.request.contextPath}/knowledge-base?action=list"
                   class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-left me-1"></i> Quay lại
                </a>
        </div>
    </div>

    <div class="row g-4">
        <%-- LEFT --%>
        <div class="col-lg-8">
            <div class="card border-0 shadow-sm mb-4">
                <div class="card-body p-4">
                    <h3 class="fw-bold mb-1">${article.title}</h3>
                    <p class="text-muted mb-4">${article.summary}</p>
                    <hr>
                    <div class="lh-lg">${article.content}</div>
                </div>
            </div>

            <c:if test="${not empty article.symptom or not empty article.cause
                          or not empty article.solution or not empty article.errorCode}">
                  <div class="card border-0 shadow-sm">
                      <div class="card-header bg-light fw-bold">
                          <i class="bi bi-tools me-2 text-warning"></i>Technical Details
                      </div>
                      <div class="card-body">
                          <c:if test="${not empty article.errorCode}">
                              <div class="mb-4">
                                  <p class="text-uppercase text-muted mb-1" style="font-size:11px;letter-spacing:.06em;font-weight:600;">Error code</p>
                                  <p class="text-decoration-none">
                                      <code class="bg-light border px-2 py-1 rounded text-primary">${article.errorCode}</code>
                                  </p>
                              </div>
                          </c:if>
                          <c:if test="${not empty article.symptom}">
                              <div class="mb-3">
                                  <label class="fw-bold text-muted small d-block">Triệu chứng</label>
                                  <p class="mb-0">${article.symptom}</p>
                              </div>
                          </c:if>
                          <c:if test="${not empty article.cause}">
                              <div class="mb-3">
                                  <label class="fw-bold text-muted small d-block">Nguyên nhân</label>
                                  <p class="mb-0">${article.cause}</p>
                              </div>
                          </c:if>
                          <c:if test="${not empty article.solution}">
                              <div class="mb-0">
                                  <label class="fw-bold text-muted small d-block">Giải pháp</label>
                                  <p class="mb-0">${article.solution}</p>
                              </div>
                          </c:if>
                      </div>
                  </div>
            </c:if>
        </div>

        <%-- RIGHT --%>
        <div class="col-lg-4">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-light fw-bold">
                    <i class="bi bi-info-circle me-2"></i>Thông báo
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <label class="fw-bold text-muted small d-block">Số</label>
                        <span>${article.articleNumber}</span>
                    </div>
                    <div class="mb-3">
                        <label class="fw-bold text-muted small d-block">Loại</label>
                        <span class="badge bg-info text-dark">Thông báo của công ty</span>
                    </div>
                    <div class="mb-3">
                        <label class="fw-bold text-muted small d-block">Trạng thái</label>
                        <c:choose>
                            <c:when test="${article.status == 'DRAFT'}">
                                <span class="badge bg-secondary">Draft</span></c:when>
                            <c:when test="${article.status == 'PENDING'}">
                                <span class="badge bg-warning text-dark">Pending</span></c:when>
                            <c:when test="${article.status == 'PUBLISHED'}">
                                <span class="badge bg-success">Đã đăng</span></c:when>
                            <c:when test="${article.status == 'REJECTED'}">
                                <span class="badge bg-danger">Rejected</span></c:when>
                            <c:when test="${article.status == 'ARCHIVED'}">
                                <span class="badge bg-dark">Lưu trữ</span></c:when>
                        </c:choose>
                    </div>
                    <div class="mb-0">
                        <label class="fw-bold text-muted small d-block">Cập nhật lần cuối</label>
                        <span class="text-muted small">${article.updatedAt}</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />