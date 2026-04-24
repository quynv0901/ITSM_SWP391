<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/includes/header.jsp" />

<style>
    .info-label {
        font-weight: 700;
        color: #1f2937;
    }

    .info-value {
        color: #374151;
    }

    .content-box {
        background: #f8fafc;
        border-left: 4px solid #e5e7eb;
        border-radius: 10px;
        padding: 14px 16px;
        min-height: 56px;
        color: #374151;
        white-space: pre-wrap;
        word-break: break-word;
    }

    .content-box.warning {
        border-left-color: #f59e0b;
    }

    .content-box.primary {
        border-left-color: #2563eb;
    }

    .content-box.danger {
        border-left-color: #ef4444;
    }

    .content-box.success {
        border-left-color: #10b981;
    }

    .comment-card {
        border: 1px solid #e5e7eb;
        border-radius: 12px;
        background: #ffffff;
        padding: 14px 16px;
        margin-bottom: 12px;
    }

    .history-table th,
    .history-table td {
        vertical-align: middle;
        font-size: 14px;
    }

    .history-table thead th {
        white-space: nowrap;
    }

    .badge-soft {
        display: inline-block;
        padding: 6px 10px;
        border-radius: 999px;
        font-size: 13px;
        font-weight: 700;
    }

    .badge-status {
        background: #dbeafe;
        color: #1d4ed8;
    }

    .badge-approval {
        background: #fef3c7;
        color: #b45309;
    }

    .badge-risk {
        background: #ede9fe;
        color: #6d28d9;
    }
</style>

<div class="container-fluid bg-light p-4 rounded shadow-sm mb-5">
    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb bg-transparent p-0 m-0">
                <li class="breadcrumb-item">
                    <a href="${pageContext.request.contextPath}/change-request-list/list">Quản lý thay đổi</a>
                </li>
                <li class="breadcrumb-item active" aria-current="page">
                    #${ticket.ticketNumber}
                </li>
            </ol>
        </nav>

        <div class="d-flex gap-2 flex-wrap">
            <a href="${pageContext.request.contextPath}/change-request-list/list"
               class="btn btn-outline-secondary btn-sm shadow-sm">
                <i class="bi bi-arrow-left"></i> Quay lại danh sách
            </a>

            <c:if test="${ticket.reportedBy == sessionScope.user.userId and ticket.status eq 'NEW'}">
                <a href="${pageContext.request.contextPath}/change-request-list/edit?id=${ticket.ticketId}"
                   class="btn btn-warning btn-sm shadow-sm fw-bold text-white">
                    <i class="bi bi-pencil-square"></i> Sửa phiếu
                </a>
            </c:if>

            <c:if test="${(sessionScope.user.roleId == 3 || sessionScope.user.roleId == 6) and ticket.status ne 'CANCELLED'}">
                <form action="${pageContext.request.contextPath}/change-request-list/cancel"
                      method="post"
                      style="display:inline;"
                      onsubmit="return confirm('Bạn có chắc chắn muốn hủy yêu cầu này không?');">
                    <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                    <button type="submit" class="btn btn-dark btn-sm shadow-sm fw-bold">
                        <i class="bi bi-slash-circle"></i> Hủy yêu cầu
                    </button>
                </form>
            </c:if>
        </div>
    </div>

    <c:if test="${not empty param.msg}">
        <div class="alert alert-info alert-dismissible fade show" role="alert">
            <c:choose>
                <c:when test="${param.msg eq 'updated'}">Cập nhật yêu cầu thay đổi thành công.</c:when>
                <c:when test="${param.msg eq 'assigned'}">Phân công yêu cầu thay đổi thành công.</c:when>
                <c:when test="${param.msg eq 'approved'}">CAB đã duyệt yêu cầu thay đổi.</c:when>
                <c:when test="${param.msg eq 'rejected'}">CAB đã từ chối yêu cầu thay đổi.</c:when>
                <c:when test="${param.msg eq 'assessed'}">Đánh giá rủi ro thành công.</c:when>
                <c:when test="${param.msg eq 'cancelled'}">Đã hủy yêu cầu thay đổi.</c:when>
                <c:when test="${param.msg eq 'comment_added'}">Đã thêm bình luận thành công.</c:when>
                <c:otherwise>Thao tác đã được thực hiện.</c:otherwise>
            </c:choose>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="row g-4">
        <div class="col-lg-8">
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-header bg-white border-bottom py-3">
                    <h5 class="mb-0 fw-bold text-dark">
                        <i class="bi bi-file-earmark-text me-2"></i>Thông tin yêu cầu thay đổi
                    </h5>
                </div>

                <div class="card-body p-4">
                    <h3 class="fw-bold text-primary mb-2">${ticket.title}</h3>
                    <p class="text-muted mb-4">
                        Mã phiếu: <strong>${ticket.ticketNumber}</strong>
                    </p>

                    <div class="row g-3 mb-4">
                        <div class="col-md-4">
                            <span class="info-label">Trạng thái:</span><br>
                            <span class="badge-soft badge-status">${ticket.status}</span>
                        </div>
                        <div class="col-md-4">
                            <span class="info-label">Trạng thái duyệt:</span><br>
                            <span class="badge-soft badge-approval">${ticket.approvalStatus}</span>
                        </div>
                        <div class="col-md-4">
                            <span class="info-label">Mức rủi ro:</span><br>
                            <span class="badge-soft badge-risk">${ticket.riskLevel}</span>
                        </div>
                    </div>

                    <div class="mb-4">
                        <h6 class="fw-bold text-dark mb-2">
                            <i class="bi bi-card-text me-2"></i>Mô tả thay đổi
                        </h6>
                        <div class="content-box">
                            ${empty ticket.description ? 'Chưa có mô tả.' : ticket.description}
                        </div>
                    </div>

                    <div class="mb-4">
                        <h6 class="fw-bold text-dark mb-2">
                            <i class="bi bi-shield-exclamation me-2"></i>Đánh giá tác động & rủi ro
                        </h6>
                        <div class="content-box warning">
                            ${empty ticket.impactAssessment ? 'Chưa có đánh giá tác động.' : ticket.impactAssessment}
                        </div>
                    </div>

                    <div class="mb-4">
                        <h6 class="fw-bold text-dark mb-2">
                            <i class="bi bi-tools me-2"></i>Kế hoạch triển khai
                        </h6>
                        <div class="content-box primary">
                            ${empty ticket.implementationPlan ? 'Chưa có dữ liệu.' : ticket.implementationPlan}
                        </div>
                    </div>

                    <div class="mb-4">
                        <h6 class="fw-bold text-dark mb-2">
                            <i class="bi bi-arrow-counterclockwise me-2"></i>Kế hoạch hoàn tác
                        </h6>
                        <div class="content-box danger">
                            ${empty ticket.rollbackPlan ? 'Chưa có dữ liệu.' : ticket.rollbackPlan}
                        </div>
                    </div>

                    <div class="mb-4">
                        <h6 class="fw-bold text-dark mb-2">
                            <i class="bi bi-check2-square me-2"></i>Kế hoạch kiểm thử
                        </h6>
                        <div class="content-box success">
                            ${empty ticket.testPlan ? 'Chưa có dữ liệu.' : ticket.testPlan}
                        </div>
                    </div>

                    <div class="mb-4">
                        <h6 class="fw-bold text-dark mb-2">
                            <i class="bi bi-journal-text me-2"></i>Nhận định rủi ro của CAB
                        </h6>
                        <div class="content-box">
                            ${empty ticket.cabRiskAssessment ? 'Chưa có đánh giá của CAB.' : ticket.cabRiskAssessment}
                        </div>
                    </div>

                    <div class="mb-0">
                        <h6 class="fw-bold text-dark mb-2">
                            <i class="bi bi-chat-left-text me-2"></i>Ghi chú CAB
                        </h6>
                        <div class="content-box">
                            ${empty ticket.cabComment ? 'Chưa có ghi chú của CAB.' : ticket.cabComment}
                        </div>
                    </div>
                </div>
            </div>

            <div class="card shadow-sm border-0 mb-4">
                <div class="card-header bg-white border-bottom py-3">
                    <h6 class="mb-0 fw-bold text-dark">
                        <i class="bi bi-chat-dots me-2"></i>Bình luận
                    </h6>
                </div>

                <div class="card-body p-4">
                    <form action="${pageContext.request.contextPath}/change-request-list/comment"
                          method="post"
                          class="mb-4">
                        <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                        <div class="mb-2">
                            <textarea name="commentText"
                                      class="form-control"
                                      rows="3"
                                      placeholder="Nhập nội dung bình luận..."
                                      required></textarea>
                        </div>
                        <button type="submit" class="btn btn-primary btn-sm">
                            <i class="bi bi-send"></i> Gửi bình luận
                        </button>
                    </form>

                    <c:if test="${empty comments}">
                        <div class="text-muted">Chưa có bình luận nào.</div>
                    </c:if>

                    <c:forEach var="cmt" items="${comments}">
                        <div class="comment-card">
                            <div class="d-flex justify-content-between align-items-start flex-wrap gap-2">
                                <div>
                                    <div class="fw-bold">${cmt.userName}</div>
                                    <div class="small text-muted">
                                        <fmt:formatDate value="${cmt.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                    </div>
                                </div>
                            </div>
                            <div class="mt-2">
                                ${cmt.commentText}
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>

            <c:if test="${sessionScope.user.roleId == 3 || sessionScope.user.roleId == 6 || sessionScope.user.roleId == 7}">
                <div class="card shadow-sm border-0 mt-4" id="history-section">
                    <div class="card-header bg-white border-bottom py-3">
                        <h6 class="mb-0 fw-bold text-primary">
                            <i class="bi bi-clock-history me-2"></i>Lịch sử thay đổi trạng thái
                        </h6>
                    </div>

                    <div class="card-body">
                        <c:if test="${empty historyList}">
                            <div class="text-muted">Chưa có lịch sử thay đổi nào.</div>
                        </c:if>

                        <c:if test="${not empty historyList}">
                            <div class="table-responsive">
                                <table class="table table-bordered table-hover align-middle history-table">
                                    <thead class="table-light">
                                        <tr>
                                            <th style="width: 160px;">Thời gian</th>
                                            <th style="width: 170px;">Người thực hiện</th>
                                            <th style="width: 160px;">Trường thay đổi</th>
                                            <th style="width: 180px;">Giá trị cũ</th>
                                            <th style="width: 180px;">Giá trị mới</th>
                                            <th>Diễn giải</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="h" items="${historyList}">
                                            <tr>
                                                <td>
                                                    <fmt:formatDate value="${h.changedAt}" pattern="dd/MM/yyyy HH:mm" />
                                                </td>
                                                <td>
                                                    ${empty h.changedByName ? '---' : h.changedByName}
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${h.fieldName eq 'status'}">Trạng thái</c:when>
                                                        <c:when test="${h.fieldName eq 'approval_status'}">Trạng thái duyệt</c:when>
                                                        <c:when test="${h.fieldName eq 'assigned_to'}">Người xử lý</c:when>
                                                        <c:when test="${h.fieldName eq 'risk_level'}">Mức rủi ro</c:when>
                                                        <c:when test="${h.fieldName eq 'scheduled_start'}">Bắt đầu dự kiến</c:when>
                                                        <c:when test="${h.fieldName eq 'scheduled_end'}">Kết thúc dự kiến</c:when>
                                                        <c:when test="${h.fieldName eq 'title'}">Tiêu đề</c:when>
                                                        <c:when test="${h.fieldName eq 'description'}">Mô tả</c:when>
                                                        <c:otherwise>${h.fieldName}</c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>${empty h.oldValue ? '---' : h.oldValue}</td>
                                                <td>${empty h.newValue ? '---' : h.newValue}</td>
                                                <td>
                                                    ${empty h.changedByName ? 'Người dùng' : h.changedByName}
                                                    thay đổi
                                                    <strong>
                                                        <c:choose>
                                                            <c:when test="${h.fieldName eq 'status'}">trạng thái</c:when>
                                                            <c:when test="${h.fieldName eq 'approval_status'}">trạng thái duyệt</c:when>
                                                            <c:when test="${h.fieldName eq 'assigned_to'}">người xử lý</c:when>
                                                            <c:when test="${h.fieldName eq 'risk_level'}">mức rủi ro</c:when>
                                                            <c:when test="${h.fieldName eq 'scheduled_start'}">bắt đầu dự kiến</c:when>
                                                            <c:when test="${h.fieldName eq 'scheduled_end'}">kết thúc dự kiến</c:when>
                                                            <c:when test="${h.fieldName eq 'title'}">tiêu đề</c:when>
                                                            <c:when test="${h.fieldName eq 'description'}">mô tả</c:when>
                                                            <c:otherwise>${h.fieldName}</c:otherwise>
                                                        </c:choose>
                                                    </strong>
                                                    từ
                                                    <strong>${empty h.oldValue ? '---' : h.oldValue}</strong>
                                                    sang
                                                    <strong>${empty h.newValue ? '---' : h.newValue}</strong>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:if>
                    </div>
                </div>
            </c:if>
        </div>

        <div class="col-lg-4">
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-header bg-white border-bottom py-3">
                    <h6 class="mb-0 fw-bold text-dark">
                        <i class="bi bi-person-lines-fill me-2"></i>Thông tin xử lý
                    </h6>
                </div>

                <div class="card-body">
                    <p><span class="info-label">Người tạo:</span> <span class="info-value">${ticket.reportedByName}</span></p>
                    <p><span class="info-label">Người xử lý:</span> <span class="info-value">${ticket.assignedToName}</span></p>
                    <p><span class="info-label">CAB phụ trách:</span> <span class="info-value">${ticket.cabMemberName}</span></p>
                    <p><span class="info-label">Bắt đầu dự kiến:</span>
                        <span class="info-value">
                            <fmt:formatDate value="${ticket.scheduledStart}" pattern="dd/MM/yyyy HH:mm" />
                        </span>
                    </p>
                    <p><span class="info-label">Kết thúc dự kiến:</span>
                        <span class="info-value">
                            <fmt:formatDate value="${ticket.scheduledEnd}" pattern="dd/MM/yyyy HH:mm" />
                        </span>
                    </p>
                    <p><span class="info-label">Bắt đầu thực tế:</span>
                        <span class="info-value">
                            <fmt:formatDate value="${ticket.actualStart}" pattern="dd/MM/yyyy HH:mm" />
                        </span>
                    </p>
                    <p class="mb-0"><span class="info-label">Kết thúc thực tế:</span>
                        <span class="info-value">
                            <fmt:formatDate value="${ticket.actualEnd}" pattern="dd/MM/yyyy HH:mm" />
                        </span>
                    </p>
                </div>
            </div>

            <c:if test="${sessionScope.user.roleId == 3}">
                <div class="card shadow-sm border-0 mb-4">
                    <div class="card-header bg-white border-bottom py-3">
                        <h6 class="mb-0 fw-bold text-dark">
                            <i class="bi bi-person-check me-2"></i>Phân công yêu cầu thay đổi
                        </h6>
                    </div>

                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/change-request-list/assign" method="post">
                            <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                            <div class="mb-3">
                                <label class="form-label fw-bold">Chọn System Engineer</label>
                                <select name="assignedTo" class="form-select" required>
                                    <option value="">-- Chọn người xử lý --</option>
                                    <c:forEach var="eng" items="${engineers}">
                                        <option value="${eng.userId}" ${ticket.assignedTo == eng.userId ? 'selected' : ''}>
                                            ${eng.fullName}
                                        </option>
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
                        <h6 class="mb-0 fw-bold text-dark">
                            <i class="bi bi-shield-check me-2"></i>Đánh giá rủi ro / Duyệt CAB
                        </h6>
                    </div>

                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/change-request-list/assess"
                              method="post"
                              class="mb-4">
                            <input type="hidden" name="ticketId" value="${ticket.ticketId}">

                            <div class="mb-3">
                                <label class="form-label fw-bold">Mức rủi ro</label>
                                <select name="riskLevel" class="form-select">
                                    <option value="LOW" ${ticket.riskLevel eq 'LOW' ? 'selected' : ''}>LOW</option>
                                    <option value="MEDIUM" ${ticket.riskLevel eq 'MEDIUM' ? 'selected' : ''}>MEDIUM</option>
                                    <option value="HIGH" ${ticket.riskLevel eq 'HIGH' ? 'selected' : ''}>HIGH</option>
                                    <option value="CRITICAL" ${ticket.riskLevel eq 'CRITICAL' ? 'selected' : ''}>CRITICAL</option>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Đánh giá tác động</label>
                                <textarea name="impactAssessment" class="form-control" rows="2">${ticket.impactAssessment}</textarea>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Nhận định rủi ro của CAB</label>
                                <textarea name="cabRiskAssessment" class="form-control" rows="2">${ticket.cabRiskAssessment}</textarea>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Bắt đầu dự kiến</label>
                                <input type="datetime-local"
                                       name="scheduledStart"
                                       class="form-control"
                                       value="<fmt:formatDate value='${ticket.scheduledStart}' pattern="dd/MM/yyyy HH:mm" />">
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Kết thúc dự kiến</label>
                                <input type="datetime-local"
                                       name="scheduledEnd"
                                       class="form-control"
                                       value="<fmt:formatDate value='${ticket.scheduledEnd}' pattern="dd/MM/yyyy HH:mm" />">
                            </div>

                            <button type="submit" class="btn btn-outline-primary w-100">
                                Lưu đánh giá
                            </button>
                        </form>

                        <form action="${pageContext.request.contextPath}/change-request-list/review"
                              method="post"
                              class="mb-2">
                            <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                            <input type="hidden" name="decision" value="APPROVE">
                            <textarea name="cabComment"
                                      class="form-control mb-2"
                                      rows="2"
                                      placeholder="Nhập ghi chú duyệt..."></textarea>
                            <button type="submit" class="btn btn-success w-100">
                                Duyệt yêu cầu
                            </button>
                        </form>

                        <form action="${pageContext.request.contextPath}/change-request-list/review"
                              method="post">
                            <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                            <input type="hidden" name="decision" value="REJECT">
                            <textarea name="cabComment"
                                      class="form-control mb-2"
                                      rows="2"
                                      placeholder="Nhập lý do từ chối..."></textarea>
                            <button type="submit" class="btn btn-danger w-100">
                                Từ chối yêu cầu
                            </button>
                        </form>
                    </div>
                </div>
            </c:if>
        </div>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />