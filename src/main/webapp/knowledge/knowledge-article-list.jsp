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
        box-shadow: 0 10px 25px rgba(0,0,0,0.05);
    }

    .search-box input {
        border-radius: 50px;
        padding-left: 20px;
    }

    .search-box button {
        border-radius: 50px;
        padding: 0 20px;
    }

    .article-item {
        border-radius: 12px;
        transition: all 0.25s ease;
    }

    .article-item:hover {
        background-color: #f1f6ff;
        transform: translateY(-2px);
    }

    .pagination .page-link {
        border-radius: 10px;
        margin: 0 3px;
    }
</style>

<div class="container py-4">

    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold text-primary">
            <i class="bi bi-journal-bookmark-fill me-2"></i>Cơ sở kiến thức
        </h2>
        <a href="${pageContext.request.contextPath}/home/dashboard.jsp" class="btn btn-outline-primary">
            <i class="bi bi-arrow-left"></i> Quay lại
        </a>
    </div>

    <!-- Error -->
    <c:if test="${not empty param.error}">
        <div class="alert alert-danger alert-dismissible fade show shadow-sm">
            <i class="bi bi-exclamation-triangle me-2"></i>${param.error}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <!-- Search -->
    <form action="${pageContext.request.contextPath}/knowledge-article" method="get"
          class="card card-custom p-3 mb-4 search-box d-flex flex-row gap-3 align-items-center">
        <input type="text" class="form-control" name="keyword"
               placeholder="🔍 Tìm kiếm bài viết..."
               value="${keyword}">
        <button type="submit" class="btn btn-primary">
            Tìm
        </button>
        <a href="${pageContext.request.contextPath}/knowledge-article" class="btn btn-light">
            Xóa
        </a>
    </form>

    <!-- Articles -->
    <div class="card card-custom p-2">
        <div class="list-group list-group-flush">
            <c:forEach var="a" items="${articles}">
                <a href="${pageContext.request.contextPath}/knowledge-article?action=detail&id=${a.articleId}"
                   class="list-group-item article-item border-0 py-3">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="fw-semibold fs-5 text-dark">${a.title}</div>
                            <c:if test="${not empty a.summary}">
                                <div class="text-muted small mt-1">${a.summary}</div>
                            </c:if>
                        </div>
                        <i class="bi bi-arrow-right-circle fs-5 text-primary"></i>
                    </div>
                </a>
            </c:forEach>

            <c:if test="${empty articles}">
                <div class="text-center text-muted py-5">
                    <i class="bi bi-journal-x fs-1 mb-2"></i>
                    <div>Không tìm thấy bài viết</div>
                </div>
            </c:if>
        </div>
    </div>

    <!-- Pagination -->
    <c:if test="${totalPages > 1}">
        <nav class="mt-4">
            <ul class="pagination justify-content-center">
                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                    <a class="page-link" href="?keyword=${keyword}&page=${currentPage - 1}">
                        <i class="bi bi-chevron-left"></i>
                    </a>
                </li>

                <c:forEach begin="1" end="${totalPages}" var="i">
                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                        <a class="page-link" href="?keyword=${keyword}&page=${i}">${i}</a>
                    </li>
                </c:forEach>

                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                    <a class="page-link" href="?keyword=${keyword}&page=${currentPage + 1}">
                        <i class="bi bi-chevron-right"></i>
                    </a>
                </li>
            </ul>
        </nav>
    </c:if>

</div>

<jsp:include page="/includes/footer.jsp" />
