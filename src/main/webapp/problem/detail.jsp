<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/includes/header.jsp" />

<div class="container-fluid bg-white p-4 rounded shadow-sm mb-4">
    <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-2">
        <h2 class="h4 text-primary m-0">Chi tiết phiếu vấn đề: ${problem.ticketNumber}</h2>
        <a href="${pageContext.request.contextPath}/problem?action=list" class="btn btn-secondary">
            <i class="bi bi-arrow-left"></i> Quay lại danh sách
        </a>
    </div>

    <div class="row mb-3">
        <div class="col-md-6">
            <p class="mb-2"><strong>Tiêu đề:</strong> ${problem.title}</p>
            <p class="mb-2"><strong>Trạng thái:</strong>
                <c:choose>
                    <c:when test="${problem.status == 'NEW'}"><span class="badge bg-info text-dark">MỚI</span></c:when>
                    <c:when test="${problem.status == 'IN_PROGRESS'}"><span class="badge bg-primary">ĐANG XỬ LÝ</span></c:when>
                    <c:when test="${problem.status == 'RESOLVED'}"><span class="badge bg-success">ĐÃ GIẢI QUYẾT</span></c:when>
                    <c:when test="${problem.status == 'CANCELLED'}"><span class="badge bg-danger">ĐÃ HỦY</span></c:when>
                    <c:otherwise><span class="badge bg-dark">${problem.status}</span></c:otherwise>
                </c:choose>
            </p>
        </div>
        <div class="col-md-6">
            <p class="mb-2"><strong>Báo cáo bởi:</strong>
                ${not empty problem.reportedByName ? problem.reportedByName : 'Người dùng '.concat(problem.reportedBy)}
            </p>
            <p class="mb-2 d-flex align-items-center gap-2">
                <strong>Phân công cho:</strong>
                <span class="${empty problem.assignedToName ? 'text-muted fst-italic' : 'text-primary fw-bold'}">
                    ${not empty problem.assignedToName ? problem.assignedToName : 'Chưa phân công'}
                </span>

                <%-- Chuyên gia kỹ thuật: tự nhận nếu chưa có người phụ trách --%>
                <c:if test="${problem.status ne 'CANCELLED'}">
                    <c:if test="${sessionScope.user.roleId == 5 && (empty problem.assignedTo || problem.assignedTo == 0) && sessionScope.user.userId ne problem.reportedBy}">
                        <form action="${pageContext.request.contextPath}/problem?action=assign" method="post" class="m-0 p-0">
                            <input type="hidden" name="id"         value="${problem.ticketId}">
                            <input type="hidden" name="assignedTo" value="${sessionScope.user.userId}">
                            <button class="btn btn-outline-primary btn-sm py-0 px-2" style="font-size: 0.8rem;" type="submit">
                                <i class="bi bi-person-check-fill"></i> Nhận xử lý
                            </button>
                        </form>
                    </c:if>
                </c:if>
            </p>

            <%-- Manager: phân công cho chuyên gia --%>
            <c:if test="${problem.status ne 'CANCELLED'}">
                <c:if test="${sessionScope.user.roleId == 3}">
                    <form action="${pageContext.request.contextPath}/problem?action=assign"
                          method="post" class="mt-3 p-3 bg-light border rounded">
                        <input type="hidden" name="id" value="${problem.ticketId}">
                        <label for="assignedTo" class="form-label fw-bold text-secondary" style="font-size: 0.9em;">
                            Phân công cho chuyên gia kỹ thuật:
                        </label>
                        <div class="input-group input-group-sm">
                            <select name="assignedTo" id="assignedTo" class="form-select" required>
                                <option value="" disabled selected>Chọn chuyên gia...</option>
                                <c:forEach var="expert" items="${technicalExperts}">
                                    <option value="${expert.userId}"
                                            ${problem.assignedTo == expert.userId ? 'selected' : ''}>
                                        ${expert.fullName} (@${expert.username})
                                    </option>
                                </c:forEach>
                            </select>
                            <button class="btn btn-primary" type="submit">Phân công</button>
                        </div>
                    </form>
                </c:if>
            </c:if>
        </div>
    </div>

    <div class="mb-4">
        <strong>Mô tả:</strong>
        <div class="p-3 bg-light rounded mt-2 border">${problem.description}</div>
    </div>

    <c:if test="${problem.status eq 'CANCELLED'}">
        <div class="mb-4">
            <strong>Lý do hủy:</strong>
            <div class="p-3 bg-danger bg-opacity-10 text-danger rounded mt-2 border border-danger">
                ${not empty problem.justification ? problem.justification : '<i>Không có lý do</i>'}
            </div>
        </div>
    </c:if>

    <hr>
    <h3 class="h5 mt-4 mb-3 text-secondary">Phân tích nguyên nhân gốc rễ (RCA)</h3>
    <div class="row">
        <div class="col-md-6">
            <strong>Nguyên nhân gốc rễ:</strong>
            <div class="p-3 bg-white border rounded mt-2 text-danger">
                ${problem.cause == null ? '<i>Chưa xác định</i>' : problem.cause}
            </div>
        </div>
        <div class="col-md-6">
            <strong>Giải pháp tạm thời / Vĩnh viễn:</strong>
            <div class="p-3 bg-white border rounded mt-2 text-success">
                ${problem.solution == null ? '<i>Chưa có giải pháp</i>' : problem.solution}
            </div>
        </div>
    </div>

    <c:set var="canManage" value="false" />
    <c:if test="${problem.status ne 'CANCELLED'}">
        <c:choose>
            <c:when test="${not empty problem.assignedTo}">
                <c:if test="${problem.assignedTo == sessionScope.user.userId}">
                    <c:set var="canManage" value="true" />
                </c:if>
            </c:when>
            <c:otherwise>
                <c:if test="${problem.reportedBy == sessionScope.user.userId}">
                    <c:set var="canManage" value="true" />
                </c:if>
            </c:otherwise>
        </c:choose>
    </c:if>

    <div class="d-flex gap-2 mt-4">
        <c:if test="${canManage}">
            <c:if test="${problem.status eq 'NEW' || problem.status eq 'IN_PROGRESS'}">
                <a href="${pageContext.request.contextPath}/problem?action=edit&id=${problem.ticketId}"
                   class="btn btn-warning">
                    <i class="bi bi-pencil"></i> Chỉnh sửa / Cập nhật RCA
                </a>
                <button type="button" class="btn btn-danger" data-bs-toggle="modal" data-bs-target="#cancelModal">
                    <i class="bi bi-x-circle"></i> Hủy phiếu
                </button>
            </c:if>
        </c:if>
    </div>
</div>

<%-- Sự cố liên kết --%>
<div class="container-fluid bg-white p-4 rounded shadow-sm mb-4">
    <h3 class="h5 mb-3 text-secondary">Sự cố liên kết</h3>
    <c:if test="${not empty linkedIncidents}">
        <ul class="list-group">
            <c:forEach var="inc" items="${linkedIncidents}">
                <li class="list-group-item d-flex justify-content-between align-items-center">
                    <span><strong>${inc.ticketNumber}</strong> - ${inc.title}</span>
                    <span class="badge bg-secondary rounded-pill">${inc.status}</span>
                </li>
            </c:forEach>
        </ul>
    </c:if>
    <c:if test="${empty linkedIncidents}">
        <p class="text-muted fst-italic">Không có sự cố nào được liên kết với phiếu vấn đề này.</p>
    </c:if>
</div>

<%-- Bình luận điều tra --%>
<div class="container-fluid bg-white p-4 rounded shadow-sm mb-4">
    <h3 class="h5 mb-3 text-secondary">Nhận xét & Điều tra</h3>

    <c:if test="${not empty comments}">
        <div class="mb-4">
            <c:forEach var="cmt" items="${comments}">
                <div class="card mb-2 border-0 bg-light">
                    <div class="card-body py-2 px-3">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <strong><i class="bi bi-person-circle"></i> ${cmt.userName}</strong>
                            <small class="text-muted">
                                <fmt:formatDate value="${cmt.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                            </small>
                        </div>
                        <p class="mb-0 text-dark" style="white-space: pre-wrap;">${cmt.commentText}</p>
                    </div>
                </div>
            </c:forEach>
        </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/problem?action=addComment" method="post">
        <input type="hidden" name="id" value="${problem.ticketId}">
        <div class="mb-3">
            <textarea class="form-control" name="commentText" rows="3"
                      placeholder="Thêm phát hiện mới, ghi chú hoặc cập nhật tiến độ..." required></textarea>
        </div>
        <button type="submit" class="btn btn-primary btn-sm">
            <i class="bi bi-chat-dots"></i> Đăng bình luận
        </button>
        <div class="form-text mt-2">
            Dùng để ghi lại phát hiện và trao đổi giữa Quản lý IT và Chuyên gia kỹ thuật.
        </div>
    </form>
</div>

<%-- Modal hủy phiếu --%>
<div class="modal fade" id="cancelModal" tabindex="-1" aria-labelledby="cancelModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="cancelModalLabel">Hủy phiếu vấn đề</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
            </div>
            <form action="${pageContext.request.contextPath}/problem?action=cancel" method="post">
                <div class="modal-body">
                    <input type="hidden" name="id" value="${problem.ticketId}">
                    <div class="mb-3">
                        <label for="cancelReason" class="form-label fw-bold">
                            Lý do hủy <span class="text-danger">*</span>
                        </label>
                        <textarea class="form-control" id="cancelReason" name="cancelReason"
                                  rows="3" required
                                  placeholder="Vui lòng nhập lý do hủy phiếu điều tra này..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn btn-danger">Xác nhận hủy</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />