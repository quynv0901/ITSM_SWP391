<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
<jsp:include page="/includes/header.jsp">
    <jsp:param name="pageTitle" value="${empty article.articleId ? 'Tạo bài viết mới' : 'Chỉnh sửa bài viết'}" />
</jsp:include>

<div class="container-fluid bg-white p-4 rounded shadow-sm">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="h4 text-primary m-0">
            <i class="bi bi-journal-plus me-2"></i>
            ${empty article.articleId ? 'Tạo bài viết mới' : 'Chỉnh sửa bài viết'}
        </h2>
        <a href="${pageContext.request.contextPath}/support-agent/knowledge-article?action=list"
           class="btn btn-outline-secondary">
            <i class="bi bi-arrow-left me-1"></i> Quay lại
        </a>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle me-2"></i>${error}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/support-agent/knowledge-article?action=${empty article.articleId ? 'add' : 'edit'}"
          method="post">
        <input type="hidden" name="articleId" value="${article.articleId}">

        <div class="row g-4">
            <%-- LEFT --%>
            <div class="col-lg-8">
                <div class="card border-0 shadow-sm mb-4">
                    <div class="card-header bg-light fw-bold">
                        <i class="bi bi-info-circle me-2 text-primary"></i>Thông tin cơ bản
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label fw-bold">
                                Tiêu đề <span class="text-danger">*</span>
                            </label>
                            <input type="text" name="title" class="form-control"
                                   placeholder="Nhập tiêu đề..."
                                   required value="${article.title}">
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Mô tả bài viết</label>
                            <textarea name="summary" class="form-control" rows="3"
                                      placeholder="Nhập mô tả...">${article.summary}</textarea>
                        </div>
                        <div class="mb-0">
                            <label class="form-label fw-bold">
                                Nội dung <span class="text-danger">*</span>
                            </label>
                            <textarea name="content" class="form-control" rows="12"
                                      placeholder="Viết nội dung bài viết..."
                                      required>${article.content}</textarea>
                        </div>
                    </div>
                </div>

                <div class="card border-0 shadow-sm">
                    <div class="card-header bg-light fw-bold">
                        <i class="bi bi-tools me-2 text-warning"></i>Thông tin kỹ thuật
                        <span class="fw-normal text-muted small ms-1">(optional)</span>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Mã lỗi</label>
                            <select name="errorCode" id="errorCode" class="form-select" style="width:100%">
                                <option value="">-- Chọn mã lỗi đã biết --</option>
                                <c:forEach var="ke" items="${knownErrors}">
                                    <option value="${ke.articleNumber}"
                                            ${article.errorCode == ke.articleNumber ? 'selected' : ''}>
                                        ${ke.articleNumber} - ${ke.title}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Triệu chứng</label>
                            <textarea name="symptom" class="form-control" rows="3"
                                      placeholder="Mô tả triệu chứng...">${article.symptom}</textarea>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Nguyên nhân</label>
                            <textarea name="cause" class="form-control" rows="3"
                                      placeholder="Nguyên nhân gây ra lỗi này là gì...">${article.cause}</textarea>
                        </div>
                        <div class="mb-0">
                            <label class="form-label fw-bold">Giải pháp</label>
                            <textarea name="solution" class="form-control" rows="4"
                                      placeholder="Các bước sửa lỗi...">${article.solution}</textarea>
                        </div>
                    </div>
                </div>
            </div>

            <%-- RIGHT --%>
            <div class="col-lg-4">
                <div class="card border-0 shadow-sm mb-4">
                    <div class="card-header bg-light fw-bold">
                        <i class="bi bi-gear me-2 text-secondary"></i>Cài đạt
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label fw-bold">
                                Loại bài viết: Cơ sở kiến thức 
                            </label> <br/>
                        </div>
                    </div>
                </div>

                <div class="card border-0 shadow-sm">
                    <div class="card-body d-grid gap-2">
                        <button type="submit" name="submitAction" value="publish" class="btn btn-primary">
                            <i class="bi bi-save me-2"></i>Lưu
                        </button>
                        <a href="${pageContext.request.contextPath}/support-agent/knowledge-article?action=list"
                           class="btn btn-outline-danger">
                            <i class="bi bi-x-circle me-2"></i>Hủy
                        </a>
                    </div>
                </div>

            </div>
        </div>
    </form>
</div>

<jsp:include page="/includes/footer.jsp" />
<script>
    $(document).ready(function () {
        $('#errorCode').select2({
            placeholder: '-- Chọn mã lỗi đã sửa --',
            allowClear: true,
            width: '100%'
        });
    });
</script>