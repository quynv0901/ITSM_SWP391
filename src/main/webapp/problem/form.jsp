<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/includes/header.jsp" />

<div class="container-fluid bg-white p-4 rounded shadow-sm" style="max-width: 800px; margin: auto;">
    <h2 class="h4 text-primary mb-4 border-bottom pb-2">
        ${not empty problem ? 'Cập nhật phiếu vấn đề' : 'Tạo phiếu vấn đề mới'}
    </h2>

    <form action="${pageContext.request.contextPath}/problem?action=${not empty problem ? 'update' : 'insert'}" method="post">
        <c:if test="${not empty problem}">
            <input type="hidden" name="id" value="${problem.ticketId}">
        </c:if>

        <div class="mb-3">
            <label for="title" class="form-label fw-bold">Tiêu đề / Tóm tắt vấn đề <span class="text-danger">*</span></label>
            <input type="text" class="form-control" id="title" name="title" value="${problem.title}" required>
        </div>

        <div class="mb-3">
            <label for="description" class="form-label fw-bold">Mô tả chi tiết <span class="text-danger">*</span></label>
            <textarea class="form-control" id="description" name="description" rows="5" required>${problem.description}</textarea>
        </div>

        <c:if test="${not empty problem}">
            <div class="mb-3">
                <label for="status" class="form-label fw-bold">Trạng thái</label>
                <select class="form-select" id="status" name="status">
                    <c:if test="${problem.status == 'NEW'}">
                        <option value="NEW" selected>Mới</option>
                    </c:if>
                    <c:if test="${problem.status == 'OPEN'}">
                        <option value="OPEN" selected>Đang mở</option>
                    </c:if>
                    <c:if test="${not empty problem.assignedTo}">
                        <option value="IN_PROGRESS" ${problem.status=='IN_PROGRESS' ? 'selected' : ''}>Đang xử lý</option>
                        <option value="RESOLVED"    ${problem.status=='RESOLVED'    ? 'selected' : ''}>Đã giải quyết</option>
                    </c:if>
                </select>
                <c:if test="${empty problem.assignedTo}">
                    <div class="form-text text-warning">
                        <i class="bi bi-info-circle"></i>
                        Không thể chuyển sang "Đang xử lý" hay "Đã giải quyết" cho đến khi phiếu được phân công.
                    </div>
                </c:if>
            </div>
        </c:if>

        <div class="mb-3">
            <label for="cause" class="form-label fw-bold">Nguyên nhân gốc rễ</label>
            <textarea class="form-control" id="cause" name="cause" rows="4">${problem.cause}</textarea>
        </div>

        <div class="mb-3">
            <label for="solution" class="form-label fw-bold">Giải pháp tạm thời / Vĩnh viễn</label>
            <textarea class="form-control" id="solution" name="solution" rows="4">${problem.solution}</textarea>
        </div>

        <div class="mb-3">
            <label class="form-label fw-bold mb-2">Liên kết sự cố (Tùy chọn)</label>
            <div class="border rounded p-2" style="max-height: 200px; overflow-y: auto; background-color: #f8f9fa;">
                <c:if test="${empty incidents}">
                    <div class="text-muted fst-italic p-2">Không có sự cố nào để liên kết.</div>
                </c:if>
                <c:forEach var="inc" items="${incidents}">
                    <c:set var="isSelected" value="false" />
                    <c:forEach var="linked" items="${linkedIncidents}">
                        <c:if test="${linked.ticketId == inc.ticketId}">
                            <c:set var="isSelected" value="true" />
                        </c:if>
                    </c:forEach>
                    <div class="form-check mb-2 pb-2 border-bottom">
                        <input class="form-check-input" type="checkbox" name="incidentIds"
                               value="${inc.ticketId}" id="inc_${inc.ticketId}" ${isSelected ? 'checked' : ''}>
                        <label class="form-check-label" for="inc_${inc.ticketId}" style="cursor: pointer;">
                            <strong>${inc.ticketNumber}</strong> - ${inc.title}
                        </label>
                    </div>
                </c:forEach>
            </div>
        </div>

        <div class="d-grid gap-2 mt-4">
            <button type="submit" class="btn btn-primary btn-lg">
                <i class="bi bi-save"></i>
                ${not empty problem ? 'Lưu cập nhật' : 'Nộp phiếu vấn đề'}
            </button>
            <a href="${pageContext.request.contextPath}/problem?action=list"
               class="btn btn-outline-secondary">Hủy và quay lại</a>
        </div>
    </form>
</div>

<jsp:include page="/includes/footer.jsp" />