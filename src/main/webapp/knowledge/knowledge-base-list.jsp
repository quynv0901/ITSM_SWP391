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
            <i class="bi bi-journal-text me-2"></i>Thông báo
        </h2>
        <a href="${pageContext.request.contextPath}/home/dashboard.jsp"
           class="btn btn-outline-secondary">
            <i class="bi bi-arrow-left me-1"></i> Quay lại
        </a>
    </div>

    <c:if test="${not empty param.error}">
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle me-2"></i>${param.error}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <%-- Search --%>
    <form action="${pageContext.request.contextPath}/knowledge-base" method="get"
          class="bg-light p-3 rounded mb-4 border d-flex gap-3 align-items-center">
        <input type="text" class="form-control" name="keyword"
               placeholder="Search articles..."
               value="${keyword}" style="max-width: 400px;">
        <button type="submit" class="btn btn-primary">
            <i class="bi bi-search"></i> Search
        </button>
        <a href="${pageContext.request.contextPath}/knowledge-base"
           class="btn btn-outline-secondary">Xóa</a>
    </form>

    <%-- List --%>
    <div class="list-group shadow-sm">
        <c:forEach var="a" items="${articles}">
            <a href="${pageContext.request.contextPath}/knowledge-base?action=detail&id=${a.articleId}"
               class="list-group-item list-group-item-action py-3">
                <div class="d-flex justify-content-between align-items-start">
                    <div>
                        <div class="fw-bold mb-1">${a.title}</div>
                        <c:if test="${not empty a.summary}">
                            <div class="text-muted small">${a.summary}</div>
                        </c:if>
                    </div>
                    <i class="bi bi-chevron-right text-muted ms-3 mt-1"></i>
                </div>
            </a>
        </c:forEach>

        <c:if test="${empty articles}">
            <div class="list-group-item text-center text-muted fst-italic py-5">
                <i class="bi bi-journal-x fs-3 d-block mb-2"></i>
                Không tìm thấy bài viết.
            </div>
        </c:if>
    </div>


    <%-- Pagination --%>
    <c:if test="${totalPages > 1}">
        <nav class="mt-4">
            <ul class="pagination justify-content-center">
                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                    <a class="page-link"
                       href="?keyword=${keyword}&page=${currentPage - 1}">Trước</a>
                </li>
                <c:forEach begin="1" end="${totalPages}" var="i">
                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                        <a class="page-link"
                           href="?keyword=${keyword}&page=${i}">${i}</a>
                    </li>
                </c:forEach>
                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                    <a class="page-link"
                       href="?keyword=${keyword}&page=${currentPage + 1}">Sau</a>
                </li>
            </ul>
        </nav>
    </c:if>
</div>

<jsp:include page="/includes/footer.jsp" />