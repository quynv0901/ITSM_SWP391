<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap" rel="stylesheet">

<style>
    body {
        font-family: 'Outfit', sans-serif;
        background: linear-gradient(135deg, #f5f7fa, #e4ecf7);
    }

    .card-custom {
        border-radius: 16px;
        box-shadow: 0 10px 25px rgba(0,0,0,0.06);
    }

    .section-title {
        font-size: 12px;
        text-transform: uppercase;
        letter-spacing: 0.06em;
        color: #6c757d;
        font-weight: 600;
        margin-bottom: 4px;
    }

    .badge-soft {
        padding: 6px 10px;
        border-radius: 10px;
        font-size: 12px;
    }

    .hover-card {
        transition: all 0.25s ease;
    }

    .hover-card:hover {
        transform: translateY(-3px);
    }
</style>

<div class="container py-4">

    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold text-primary">
            <i class="bi bi-file-earmark-text-fill me-2"></i>Thông tin bài viết
        </h2>
        <a href="${pageContext.request.contextPath}/knowledge-base?action=list"
           class="btn btn-outline-primary">
            <i class="bi bi-arrow-left"></i> Quay lại
        </a>
    </div>

    <div class="row g-4">

        <!-- LEFT -->
        <div class="col-lg-8">

            <!-- Main Content -->
            <div class="card card-custom p-4 mb-4 hover-card">
                <h3 class="fw-bold mb-2">${article.title}</h3>
                <p class="text-muted mb-3">${article.summary}</p>
                <hr>
                <div class="lh-lg">${article.content}</div>
            </div>

            <!-- Detail Info -->
            <c:if test="${not empty article.symptom or not empty article.cause or not empty article.solution or not empty article.errorCode}">
                <div class="card card-custom p-4 hover-card">
                    <h5 class="fw-bold mb-3">
                        <i class="bi bi-tools me-2 text-warning"></i>Thông tin chi tiết
                    </h5>

                    <c:if test="${not empty article.errorCode}">
                        <div class="mb-3">
                            <div class="section-title">Error code</div>
                            <code class="bg-light border px-2 py-1 rounded text-primary">${article.errorCode}</code>
                        </div>
                    </c:if>

                    <c:if test="${not empty article.symptom}">
                        <div class="mb-3">
                            <div class="section-title">Triệu chứng</div>
                            <p class="mb-0">${article.symptom}</p>
                        </div>
                    </c:if>

                    <c:if test="${not empty article.cause}">
                        <div class="mb-3">
                            <div class="section-title">Nguyên nhân</div>
                            <p class="mb-0">${article.cause}</p>
                        </div>
                    </c:if>

                    <c:if test="${not empty article.solution}">
                        <div>
                            <div class="section-title">Giải pháp</div>
                            <p class="mb-0">${article.solution}</p>
                        </div>
                    </c:if>
                </div>
            </c:if>

        </div>

        <!-- RIGHT -->
        <div class="col-lg-4">
            <div class="card card-custom p-4 hover-card">
                <h5 class="fw-bold mb-3">
                    <i class="bi bi-info-circle-fill me-2"></i>Thông tin
                </h5>

                <div class="mb-3">
                    <div class="section-title">Số bài</div>
                    <div>${article.articleNumber}</div>
                </div>

                <div class="mb-3">
                    <div class="section-title">Loại</div>
                    <span class="badge bg-info-subtle text-dark badge-soft">Thông báo</span>
                </div>

                <div class="mb-3">
                    <div class="section-title">Trạng thái</div>
                    <c:choose>
                        <c:when test="${article.status == 'DRAFT'}">
                            <span class="badge bg-secondary badge-soft">Draft</span>
                        </c:when>
                        <c:when test="${article.status == 'PENDING'}">
                            <span class="badge bg-warning text-dark badge-soft">Pending</span>
                        </c:when>
                        <c:when test="${article.status == 'PUBLISHED'}">
                            <span class="badge bg-success badge-soft">Đã đăng</span>
                        </c:when>
                        <c:when test="${article.status == 'REJECTED'}">
                            <span class="badge bg-danger badge-soft">Rejected</span>
                        </c:when>
                        <c:when test="${article.status == 'ARCHIVED'}">
                            <span class="badge bg-dark badge-soft">Lưu trữ</span>
                        </c:when>
                    </c:choose>
                </div>

                <div>
                    <div class="section-title">Cập nhật</div>
                    <div class="text-muted small">${article.updatedAt}</div>
                </div>
            </div>
        </div>

    </div>
</div>

<jsp:include page="/includes/footer.jsp" />