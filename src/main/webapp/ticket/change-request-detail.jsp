<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/includes/header.jsp" />

<div class="container-fluid bg-light p-4 rounded shadow-sm mb-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb bg-transparent p-0 m-0">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/change-request-list/list">Quản lý thay đổi</a></li>
                <li class="breadcrumb-item active" aria-current="page">#${ticket.ticketNumber}</li>
            </ol>
        </nav>

        <div class="d-flex gap-2 flex-wrap">
            <a href="${pageContext.request.contextPath}/change-request-list/list" class="btn btn-outline-secondary btn-sm shadow-sm">
                <i class="bi bi-arrow-left"></i> Quay lại danh sách
            </a>

            <c:if test="${ticket.reportedBy == sessionScope.user.userId and ticket.status eq 'NEW'}">
                <a href="${pageContext.request.contextPath}/change-request-list/edit?id=${ticket.ticketId}" class="btn btn-warning btn-sm shadow-sm fw-bold">
                    <i class="bi bi-pencil-square"></i> Sửa phiếu
                </a>
                <form action="${pageContext.request.contextPath}/change-request-list/delete" method="post" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn xóa vĩnh viễn yêu cầu thay đổi này không?');">
                    <input type="hidden" name="actionType" value="single">
                    <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                    <button type="submit" class="btn btn-danger btn-sm shadow-sm fw-bold">
                        <i class="bi bi-trash"></i> Xóa
                    </button>
                </form>
            </c:if>

            <c:if test="${(sessionScope.user.roleId == 3 or sessionScope.user.roleId == 6) and ticket.status ne 'CANCELLED' and ticket.status ne 'CLOSED' and ticket.status ne 'RESOLVED'}">
                <form action="${pageContext.request.contextPath}/change-request-list/cancel" method="post" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn hủy yêu cầu thay đổi này không?');">
                    <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                    <button type="submit" class="btn btn-dark btn-sm shadow-sm">
                        <i class="bi bi-slash-circle"></i> Hủy yêu cầu
                    </button>
                </form>
            </c:if>
        </div>
    </div>

    <c:if test="${not empty param.msg}">
        <div class="alert alert-info">
            <c:choose>
                <c:when test="${param.msg eq 'updated'}">Cập nhật phiếu thành công.</c:when>
                <c:when test="${param.msg eq 'assigned'}">Phân công xử lý thành công.</c:when>
                <c:when test="${param.msg eq 'approved'}">CAB đã duyệt yêu cầu thay đổi.</c:when>
                <c:when test="${param.msg eq 'rejected'}">CAB đã từ chối yêu cầu thay đổi.</c:when>
                <c:when test="${param.msg eq 'assessed'}">Đánh giá rủi ro thành công.</c:when>
                <c:when test="${param.msg eq 'cancelled'}">Đã hủy yêu cầu thay đổi.</c:when>
                <c:when test="${param.msg eq 'comment_added'}">Đã thêm bình luận thành công.</c:when>
                <c:when test="${param.msg eq 'update_blocked'}">Không thể sửa vì phiếu đã có đánh giá rủi ro.</c:when>
                <c:otherwise>Thao tác đã được thực hiện.</c:otherwise>
            </c:choose>
        </div>
    </c:if>

    <div class="row g-4">
        <div class="col-lg-8">
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-header bg-white border-bottom py-3">
                    <h5 class="mb-0 fw-bold text-dark"><i class="bi bi-file-earmark-text me-2"></i>Thông tin yêu cầu thay đổi</h5>
                </div>
                <div class="card-body p-4">
                    <h4 class="fw-bold text-primary">${ticket.title}</h4>
                    <p class="text-muted mb-3">Mã phiếu: <strong>${ticket.ticketNumber}</strong></p>

                    <div class="row g-3 mb-4">
                        <div class="col-md-4"><strong>Trạng thái:</strong> ${ticket.status}</div>
                        <div class="col-md-4"><strong>Trạng thái duyệt:</strong> ${ticket.approvalStatus}</div>
                        <div class="col-md-4"><strong>Mức rủi ro:</strong> ${ticket.riskLevel}</div>
                    </div>

                    <h6 class="fw-bold text-dark mb-2"><i class="bi bi-card-text me-2"></i>Mô tả thay đổi</h6>
                    <p class="text-secondary mb-4">${ticket.description}</p>

                    <h6 class="fw-bold text-dark mb-2"><i class="bi bi-shield-exclamation me-2"></i>Đánh giá tác động & rủi ro</h6>
                    <p class="text-muted bg-light p-3 rounded border-start border-4 border-warning mb-4">
                        ${not empty ticket.impactAssessment ? ticket.impactAssessment : 'Chưa có đánh giá tác động.'}
                    </p>

                    <div class="row g-3">
                        <div class="col-12">
                            <h6 class="fw-bold text-dark mb-2"><i class="bi bi-tools me-2"></i>Kế hoạch triển khai</h6>
                            <p class="text-secondary bg-white border p-3 rounded">${not empty ticket.implementationPlan ? ticket.implementationPlan : 'Chưa có dữ liệu'}</p>
                        </div>
                        <div class="col-12">
                            <h6 class="fw-bold text-dark mb-2"><i class="bi bi-arrow-counterclockwise me-2"></i>Kế hoạch hoàn tác</h6>
                            <p class="text-secondary bg-white border p-3 rounded">${not empty ticket.rollbackPlan ? ticket.rollbackPlan : 'Chưa có dữ liệu'}</p>
                        </div>
                        <div class="col-12">
                            <h6 class="fw-bold text-dark mb-2"><i class="bi bi-check2-square me-2"></i>Kế hoạch kiểm thử</h6>
                            <p class="text-secondary bg-white border p-3 rounded">${not empty ticket.testPlan ? ticket.testPlan : 'Chưa có dữ liệu'}</p>
                        </div>
                        <div class="col-12">
                            <h6 class="fw-bold text-dark mb-2"><i class="bi bi-chat-left-text me-2"></i>Nhận định rủi ro của CAB</h6>
                            <p class="text-secondary bg-white border p-3 rounded">${not empty ticket.cabRiskAssessment ? ticket.cabRiskAssessment : 'Chưa có đánh giá của CAB'}</p>
                        </div>
                        <div class="col-12">
                            <h6 class="fw-bold text-dark mb-2"><i class="bi bi-journal-text me-2"></i>Ghi chú CAB</h6>
                            <p class="text-secondary bg-white border p-3 rounded">${not empty ticket.cabComment ? ticket.cabComment : 'Chưa có ghi chú CAB'}</p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card shadow-sm border-0 mb-4 mt-4 border-top border-4 border-primary">
                <div class="card-header bg-white border-bottom py-3 d-flex justify-content-between align-items-center">
                    <h6 class="mb-0 fw-bold text-dark"><i class="bi bi-chat-dots me-2 text-primary"></i>Bình luận</h6>
                    <span class="badge bg-primary rounded-pill">${comments.size()} bình luận</span>
                </div>
                <div class="card-body p-4 bg-light">
                    <form action="${pageContext.request.contextPath}/change-request-list/comment" method="post" class="mb-4 bg-white p-3 rounded shadow-sm border">
                        <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                        <div class="mb-2">
                            <textarea class="form-control border-0" name="commentText" placeholder="Nhập nội dung thảo luận, ý kiến đánh giá hoặc ghi chú..." rows="3" required style="box-shadow: none; resize: none;"></textarea>
                        </div>
                        <div class="d-flex justify-content-end border-top pt-2">
                            <button type="submit" class="btn btn-primary btn-sm fw-bold px-4">
                                <i class="bi bi-send-fill me-1"></i> Gửi bình luận
                            </button>
                        </div>
                    </form>

                    <div class="comment-list">
                        <c:forEach var="cmt" items="${comments}">
                            <div class="d-flex mb-3 bg-white p-3 rounded shadow-sm border-start border-3 border-secondary">
                                <div class="flex-grow-1">
                                    <div class="d-flex justify-content-between">
                                        <strong>${cmt.userName}</strong>
                                        <span class="text-muted small"><fmt:formatDate value="${cmt.createdAt}" pattern="dd/MM/yyyy HH:mm" /></span>
                                    </div>
                                    <div class="text-secondary mt-2">${cmt.commentText}</div>
                                </div>
                            </div>
                        </c:forEach>
                        <c:if test="${empty comments}">
                            <div class="text-muted">Chưa có bình luận nào.</div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-lg-4">
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-header bg-white border-bottom py-3">
                    <h6 class="mb-0 fw-bold text-dark"><i class="bi bi-person-lines-fill me-2"></i>Thông tin xử lý</h6>
                </div>
                <div class="card-body">
                    <p><strong>Người tạo:</strong> ${ticket.reportedByName}</p>
                    <p><strong>Người xử lý:</strong> ${ticket.assignedToName}</p>
                    <p><strong>CAB phụ trách:</strong> ${ticket.cabMemberName}</p>
                    <p><strong>Bắt đầu dự kiến:</strong> <fmt:formatDate value="${ticket.scheduledStart}" pattern="dd/MM/yyyy HH:mm" /></p>
                    <p><strong>Kết thúc dự kiến:</strong> <fmt:formatDate value="${ticket.scheduledEnd}" pattern="dd/MM/yyyy HH:mm" /></p>
                    <p><strong>Bắt đầu thực tế:</strong> <fmt:formatDate value="${ticket.actualStart}" pattern="dd/MM/yyyy HH:mm" /></p>
                    <p><strong>Kết thúc thực tế:</strong> <fmt:formatDate value="${ticket.actualEnd}" pattern="dd/MM/yyyy HH:mm" /></p>
                </div>
            </div>

            <c:if test="${sessionScope.user.roleId == 3}">
                <div class="card shadow-sm border-0 mb-4">
                    <div class="card-header bg-white border-bottom py-3">
                        <h6 class="mb-0 fw-bold text-dark"><i class="bi bi-person-check me-2"></i>Phân công yêu cầu thay đổi</h6>
                    </div>
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/change-request-list/assign" method="post">
                            <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                            <div class="mb-3">
                                <label class="form-label fw-bold">Chọn System Engineer</label>
                                <select name="assignedTo" class="form-select">
                                    <c:forEach var="eng" items="${engineers}">
                                        <option value="${eng.userId}" ${ticket.assignedTo == eng.userId ? 'selected' : ''}>${eng.fullName}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <button type="submit" class="btn btn-primary w-100">Phân công</button>
                        </form>
                    </div>
                </div>
            </c:if>

            <c:if test="${sessionScope.user.roleId == 7}">
                <div class="card shadow-sm border-0 mb-4">
                    <div class="card-header bg-white border-bottom py-3">
                        <h6 class="mb-0 fw-bold text-dark"><i class="bi bi-shield-check me-2"></i>Đánh giá rủi ro / Duyệt CAB</h6>
                    </div>
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/change-request-list/assess" method="post" class="mb-3">
                            <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                            <div class="mb-3">
                                <label class="form-label fw-bold">Mức rủi ro</label>
                                <select name="riskLevel" class="form-select">
                                    <option value="LOW">Thấp</option>
                                    <option value="MEDIUM">Trung bình</option>
                                    <option value="HIGH">Cao</option>
                                    <option value="CRITICAL">Rất cao</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Đánh giá tác động</label>
                                <textarea name="impactAssessment" class="form-control" rows="2">${ticket.impactAssessment}</textarea>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Nhận định rủi ro</label>
                                <textarea name="cabRiskAssessment" class="form-control" rows="2">${ticket.cabRiskAssessment}</textarea>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Lịch đề xuất bắt đầu</label>
                                <input type="datetime-local" name="scheduledStart" class="form-control">
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Lịch đề xuất kết thúc</label>
                                <input type="datetime-local" name="scheduledEnd" class="form-control">
                            </div>
                            <button type="submit" class="btn btn-outline-primary w-100">Lưu đánh giá</button>
                        </form>

                        <form action="${pageContext.request.contextPath}/change-request-list/review" method="post" class="mb-2">
                            <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                            <input type="hidden" name="decision" value="APPROVE">
                            <textarea name="cabComment" class="form-control mb-2" rows="2" placeholder="Nhập ghi chú duyệt..."></textarea>
                            <button type="submit" class="btn btn-success w-100">Duyệt yêu cầu</button>
                        </form>

                        <form action="${pageContext.request.contextPath}/change-request-list/review" method="post">
                            <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                            <input type="hidden" name="decision" value="REJECT">
                            <textarea name="cabComment" class="form-control mb-2" rows="2" placeholder="Nhập lý do từ chối..."></textarea>
                            <button type="submit" class="btn btn-danger w-100">Từ chối yêu cầu</button>
                        </form>
                    </div>
                </div>
            </c:if>
        </div>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />
