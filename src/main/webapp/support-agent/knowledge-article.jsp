<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/includes/header.jsp">
    <jsp:param name="pageTitle" value="Knowledge Article" />
</jsp:include>

<div class="container-fluid bg-white p-4 rounded shadow-sm">

    <%-- Header --%>
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="h4 text-primary m-0">
            <i class="bi bi-journal-text me-2"></i>Quản lý kiến thức
        </h2>
        <a href="${pageContext.request.contextPath}/support-agent/knowledge-article?action=add"
           class="btn btn-primary">
            <i class="bi bi-plus-circle me-1"></i> Tạo bài viết mới
        </a>
    </div>

    <%-- Alerts --%>
    <c:if test="${not empty param.message}">
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle me-2"></i>${param.message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${not empty param.error}">
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle me-2"></i>${param.error}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <%-- Filter & Search --%>
    <form action="${pageContext.request.contextPath}/support-agent/knowledge-article" method="get"
          class="bg-light p-3 rounded mb-4 border d-flex gap-3 align-items-center flex-wrap">
        <input type="hidden" name="action" value="list">

        <input type="text" class="form-control" name="keyword"
               placeholder="Tìm theo tiêu đề"
               value="${keyword}" style="max-width: 280px;">

        <select class="form-select" name="status" style="max-width: 180px;">
            <option value="ALL" ${empty statusFilter || statusFilter=='ALL' ? 'selected' : ''}>Tất cả trạng thái</option>
            <option value="PUBLISHED" ${statusFilter=='PUBLISHED' ? 'selected' : ''}>Đã đăng</option>
            <option value="ARCHIVED"  ${statusFilter=='ARCHIVED'  ? 'selected' : ''}>Lưu trữ</option>
        </select>

        <button type="submit" class="btn btn-primary">
            <i class="bi bi-search"></i> Tìm
        </button>
        <a href="${pageContext.request.contextPath}/support-agent/knowledge-article?action=list"
           class="btn btn-outline-secondary">Tải lại trang</a>
    </form>

    <%-- Table --%>
    <div class="table-responsive">
        <table class="table table-hover table-bordered align-middle">
            <thead class="table-light">
                <tr>
                    <th>Stt</th>
                    <th>Tiêu đề</th>
                    <th>Trạng thái</th>
                    <th>Cập nhật</th>
                    <th>Hành động</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="a" items="${articles}" varStatus="loop">
                    <tr>
                        <td class="text-muted">${(currentPage - 1) * 10 + loop.count}</td>
                        <td>
                            <a href="${pageContext.request.contextPath}/support-agent/knowledge-article?action=detail&id=${a.articleId}"
                               class="fw-bold text-decoration-none">
                                ${a.title}
                            </a>
                            <c:if test="${not empty a.summary}">
                                <div class="text-muted small">${a.summary}</div>
                            </c:if>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${a.status == 'PUBLISHED'}">
                                    <span class="badge bg-success">Đã đăng</span></c:when>
                                <c:when test="${a.status == 'ARCHIVED'}">
                                    <span class="badge bg-dark">Lưu trữ</span></c:when>
                            </c:choose>
                        </td>
                        <td class="text-muted small">${a.updatedAt}</td>
                        <td>
                            <div class="d-flex gap-1">
                                <%-- View --%>
                                <a href="${pageContext.request.contextPath}/support-agent/knowledge-article?action=detail&id=${a.articleId}"
                                   class="btn btn-info btn-sm text-white" title="View">
                                    <i class="bi bi-eye"></i>
                                </a>
                                <%-- Edit --%>
                                <a href="${pageContext.request.contextPath}/support-agent/knowledge-article?action=edit&id=${a.articleId}"
                                   class="btn btn-warning btn-sm" title="Edit">
                                    <i class="bi bi-pencil"></i>
                                </a>
                                <%-- Toggle Status --%>
                                <c:choose>
                                    <c:when test="${a.status == 'PUBLISHED'}">
                                        <a href="${pageContext.request.contextPath}/support-agent/knowledge-article?action=toggle&id=${a.articleId}&status=ARCHIVED"
                                           class="btn btn-secondary btn-sm" title="Archive"
                                           onclick="return confirm('Archive this article?')">
                                            <i class="bi bi-archive"></i>
                                        </a>
                                    </c:when>
                                    <c:when test="${a.status == 'ARCHIVED'}">
                                        <a href="${pageContext.request.contextPath}/support-agent/knowledge-article?action=toggle&id=${a.articleId}&status=PUBLISHED"
                                           class="btn btn-success btn-sm" title="Restore"
                                           onclick="return confirm('Restore this article?')">
                                            <i class="bi bi-arrow-counterclockwise"></i>
                                        </a>
                                    </c:when>
                                </c:choose>
                                <%-- Delete --%>
                                <a href="${pageContext.request.contextPath}/support-agent/knowledge-article?action=delete&amp;id=${a.articleId}"
                                   class="btn btn-danger btn-sm" title="Delete"
                                   onclick="return confirm('Delete?')">
                                    <i class="bi bi-trash"></i>
                                </a>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty articles}">
                    <tr>
                        <td colspan="6" class="text-center text-muted fst-italic py-5">
                            <i class="bi bi-journal-x fs-3 d-block mb-2"></i>
                            Không tìm thấy bài viết.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>

    <%-- Pagination --%>
    <c:if test="${totalPages > 1}">
        <nav class="mt-3">
            <ul class="pagination justify-content-center">
                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                    <a class="page-link"
                       href="?action=list&keyword=${keyword}&status=${statusFilter}&type=${typeFilter}&page=${currentPage - 1}">
                        Trước
                    </a>
                </li>
                <c:forEach begin="1" end="${totalPages}" var="i">
                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                        <a class="page-link"
                           href="?action=list&keyword=${keyword}&status=${statusFilter}&type=${typeFilter}&page=${i}">
                            ${i}
                        </a>
                    </li>
                </c:forEach>
                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                    <a class="page-link"
                       href="?action=list&keyword=${keyword}&status=${statusFilter}&type=${typeFilter}&page=${currentPage + 1}">
                        Sau
                    </a>
                </li>
            </ul>
        </nav>
    </c:if>
</div>

<jsp:include page="/includes/footer.jsp" />