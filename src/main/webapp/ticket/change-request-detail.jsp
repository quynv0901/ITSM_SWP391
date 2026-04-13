<jsp:include page="/includes/header.jsp" />
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<div class="container-fluid bg-light p-4 rounded shadow-sm mb-5">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb bg-transparent p-0 m-0">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/change-request/list">Change Management</a></li>
                <li class="breadcrumb-item active" aria-current="page">#CR-${ticket.ticketId}</li>
            </ol>
        </nav>

        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/change-request/list" class="btn btn-outline-secondary btn-sm shadow-sm">
                <i class="bi bi-arrow-left"></i> Back to List
            </a>

            <%-- HIỂN THỊ NÚT EDIT NẾU NGƯỜI DÙNG CHÍNH LÀ NGƯỜI TẠO VÀ STATUS ĐANG LÀ NEW --%>
            <c:if test="${ticket.reportedBy == sessionScope.user.userId and ticket.status eq 'NEW'}">
                <a href="${pageContext.request.contextPath}/change-request/edit?id=${ticket.ticketId}" class="btn btn-warning btn-sm shadow-sm fw-bold">
                    <i class="bi bi-pencil-square"></i> Edit Request
                </a>
                <form action="${pageContext.request.contextPath}/change-request/delete" method="post" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn XÓA VĨNH VIỄN Change Request này không?');">
                    <input type="hidden" name="actionType" value="single">
                    <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                    <button type="submit" class="btn btn-danger btn-sm shadow-sm fw-bold">
                        <i class="bi bi-trash"></i> Delete
                    </button>
                </form>
            </c:if>
            <c:if test="${(sessionScope.user.roleId == 3 or sessionScope.user.roleId == 6) and ticket.status ne 'CANCELLED' and ticket.status ne 'CLOSED' and ticket.status ne 'RESOLVED'}">
                <form action="${pageContext.request.contextPath}/change-request/cancel" method="post" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn HỦY Change Request này không? Mọi tiến trình sẽ dừng lại.');">
                    <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                    <button type="submit" class="btn btn-dark btn-sm shadow-sm">
                        <i class="bi bi-slash-circle"></i> Cancel Request
                    </button>
                </form>
            </c:if>
            <%-- NÚT TAKE REQUEST: Dành riêng cho System Engineer khi phiếu chưa có ai nhận --%>
            <c:if test="${sessionScope.user.roleId == 6 and empty ticket.assignedToName and ticket.status ne 'CLOSED' and ticket.status ne 'CANCELLED'}">
                <form action="${pageContext.request.contextPath}/change-request/assign" method="post" class="m-0">
                    <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                    <%-- Gửi ngầm ID của chính user đang đăng nhập lên server --%>
                    <input type="hidden" name="assignedTo" value="${sessionScope.user.userId}">
                    <button type="submit" class="btn btn-info btn-sm shadow-sm fw-bold text-dark" onclick="return confirm('Bạn muốn nhận triển khai Change Request này?');">
                        <i class="bi bi-person-raised-hand"></i> Take Request
                    </button>
                </form>
            </c:if>
        </div>
    </div>

    <div class="row g-4">
        <%-- CỘT TRÁI: THÔNG TIN CHI TIẾT --%>
        <div class="col-md-8">
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-header bg-white border-bottom py-3">
                    <h4 class="mb-0 text-primary">${ticket.title}</h4>
                </div>
                <div class="card-body p-4">
                    <h6 class="fw-bold text-dark mb-2"><i class="bi bi-card-text me-2"></i>Change Description</h6>
                    <p class="text-secondary mb-4">${ticket.description}</p>

                    <h6 class="fw-bold text-dark mb-2"><i class="bi bi-shield-exclamation me-2"></i>Impact & Risk Assessment</h6>
                    <p class="text-muted bg-light p-3 rounded border-start border-4 border-warning mb-4">
                        ${not empty ticket.impactAssessment ? ticket.impactAssessment : 'No impact assessment provided.'}
                    </p>

                    <div class="row g-3">
                        <div class="col-12">
                            <h6 class="fw-bold text-dark mb-2"><i class="bi bi-tools me-2"></i>Implementation Plan</h6>
                            <p class="text-secondary bg-white border p-3 rounded">${not empty ticket.implementationPlan ? ticket.implementationPlan : 'N/A'}</p>
                        </div>
                        <div class="col-12">
                            <h6 class="fw-bold text-dark mb-2"><i class="bi bi-arrow-counterclockwise me-2"></i>Rollback Plan</h6>
                            <p class="text-secondary bg-white border p-3 rounded">${not empty ticket.rollbackPlan ? ticket.rollbackPlan : 'N/A'}</p>
                        </div>
                        <div class="col-12">
                            <h6 class="fw-bold text-dark mb-2"><i class="bi bi-check2-square me-2"></i>Test Plan</h6>
                            <p class="text-secondary bg-white border p-3 rounded">${not empty ticket.testPlan ? ticket.testPlan : 'N/A'}</p>
                        </div>
                    </div>
                </div>
            </div>
            <%-- UC73: PHẦN THẢO LUẬN (DISCUSSION BOARD) --%>
            <div class="card shadow-sm border-0 mb-4 mt-4 border-top border-4 border-primary">
                <div class="card-header bg-white border-bottom py-3 d-flex justify-content-between align-items-center">
                    <h6 class="mb-0 fw-bold text-dark"><i class="bi bi-chat-dots me-2 text-primary"></i>Discussion Board</h6>
                    <span class="badge bg-primary rounded-pill">${comments.size()} Comments</span>
                </div>
                <div class="card-body p-4 bg-light">

                    <%-- Khung nhập bình luận --%>
                    <form action="${pageContext.request.contextPath}/ticket/add-comment" method="post" class="mb-4 bg-white p-3 rounded shadow-sm border">
                        <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                        <%-- Biến này để báo cho Servlet biết đây là Change Request --%>
                        <input type="hidden" name="ticketType" value="CHANGE">

                        <div class="mb-2">
                            <textarea class="form-control border-0" name="commentText" placeholder="Nhập nội dung thảo luận, ý kiến đánh giá hoặc ghi chú tại đây..." rows="3" required style="box-shadow: none; resize: none;"></textarea>
                        </div>
                        <div class="d-flex justify-content-end border-top pt-2">
                            <button type="submit" class="btn btn-primary btn-sm fw-bold px-4">
                                <i class="bi bi-send-fill me-1"></i> Send Message
                            </button>
                        </div>
                    </form>

                    <%-- Danh sách các bình luận cũ --%>
                    <div class="comment-list">
                        <c:forEach var="cmt" items="${comments}">
                            <div class="d-flex mb-3 bg-white p-3 rounded shadow-sm border-start border-3 border-secondary">
                                <div class="flex-shrink-0">
                                    <div class="bg-dark text-white rounded-circle d-flex align-items-center justify-content-center fw-bold shadow-sm" style="width: 45px; height: 45px; font-size: 1.2rem; text-transform: uppercase;">
                                        ${cmt.userName.substring(0,1)}
                                    </div>
                                </div>
                                <div class="flex-grow-1 ms-3">
                                    <div class="d-flex justify-content-between align-items-center mb-1">
                                        <h6 class="mb-0 fw-bold text-dark">${cmt.userName} 
                                            <span class="badge bg-info text-dark ms-2 fw-normal" style="font-size: 0.7rem;">
                                                <c:choose>
                                                    <c:when test="${cmt.userRoleId == 3}">Manager</c:when>
                                                    <c:when test="${cmt.userRoleId == 6}">System Engineer</c:when>
                                                    <c:when test="${cmt.userRoleId == 7}">CAB Member</c:when>
                                                    <c:otherwise>Staff</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </h6>
                                        <small class="text-muted"><i class="bi bi-clock me-1"></i><fmt:formatDate value="${cmt.createdAt}" pattern="dd/MM/yyyy HH:mm" /></small>
                                    </div>
                                    <p class="mb-0 text-secondary mt-2" style="white-space: pre-wrap;">${cmt.commentText}</p>
                                </div>
                            </div>
                        </c:forEach>

                        <c:if test="${empty comments}">
                            <div class="text-center text-muted py-4 fst-italic">
                                <i class="bi bi-chat-square-text fs-1 d-block mb-2 text-light"></i>
                                Chưa có cuộc thảo luận nào.
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>

        <%-- CỘT PHẢI: THUỘC TÍNH VÀ LỊCH TRÌNH --%>
        <div class="col-md-4">
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-body p-4">
                    <h6 class="fw-bold text-dark border-bottom pb-2 mb-3">Change Details</h6>
                    <ul class="list-unstyled mb-0">
                        <li class="mb-3"><small class="text-muted d-block">Status</small>
                            <span class="badge bg-secondary fs-6 ${ticket.status == 'NEW' ? 'bg-primary' : (ticket.status == 'APPROVED' ? 'bg-success' : 'bg-secondary')}">${ticket.status}</span>
                        </li>
                        <li class="mb-3"><small class="text-muted d-block">Change Type</small>
                            <span class="badge bg-info text-dark">${not empty ticket.changeType ? ticket.changeType : 'NORMAL'}</span>
                        </li>
                        <li class="mb-3"><small class="text-muted d-block">Risk Level</small>
                            <span class="badge ${ticket.riskLevel == 'HIGH' or ticket.riskLevel == 'CRITICAL' ? 'bg-danger' : 'bg-warning text-dark'}">${not empty ticket.riskLevel ? ticket.riskLevel : 'MEDIUM'}</span>
                        </li>
                        <li class="mb-3"><small class="text-muted d-block">Requester</small><strong><i class="bi bi-person me-1"></i> ${ticket.reportedByName}</strong></li>
                        <li class="mb-3"><small class="text-muted d-block">Assigned To</small>
                            <strong><i class="bi bi-headset me-1"></i> ${not empty ticket.assignedToName ? ticket.assignedToName : '<span class="text-warning">Chưa phân công</span>'}</strong>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="card shadow-sm border-0 mb-4 border-top border-4 border-info">
                <div class="card-body p-4">
                    <h6 class="fw-bold text-dark border-bottom pb-2 mb-3"><i class="bi bi-calendar-event me-2"></i>Schedule Info</h6>
                    <ul class="list-unstyled mb-0">
                        <li class="mb-3"><small class="text-muted d-block">Scheduled Start</small>
                            <span class="fw-bold text-primary">
                                <c:choose>
                                    <c:when test="${not empty ticket.scheduledStart}">
                                        <fmt:formatDate value="${ticket.scheduledStart}" pattern="dd/MM/yyyy HH:mm" />
                                    </c:when>
                                    <c:otherwise>TBD</c:otherwise>
                                </c:choose>
                            </span>
                        </li>
                        <li class="mb-3"><small class="text-muted d-block">Scheduled End</small>
                            <span class="fw-bold text-primary">
                                <c:choose>
                                    <c:when test="${not empty ticket.scheduledEnd}">
                                        <fmt:formatDate value="${ticket.scheduledEnd}" pattern="dd/MM/yyyy HH:mm" />
                                    </c:when>
                                    <c:otherwise>TBD</c:otherwise>
                                </c:choose>
                            </span>
                        </li>
                        <li class="mb-3"><small class="text-muted d-block">Downtime Required?</small>
                            <span class="badge ${ticket.downtimeRequired ? 'bg-danger' : 'bg-success'}">${ticket.downtimeRequired ? 'YES' : 'NO'}</span>
                        </li>
                    </ul>
                </div>
            </div>

            <%-- UC70: FORM ASSIGN CHANGE REQUEST (CHỈ DÀNH CHO MANAGER - ROLE 3) --%>
            <c:if test="${sessionScope.user.roleId == 3 and ticket.status ne 'CLOSED' and ticket.status ne 'CANCELLED'}">
                <div class="card shadow-sm border-0 mb-4 bg-white border-top border-4 border-warning">
                    <div class="card-body p-4">
                        <h6 class="fw-bold text-dark mb-3"><i class="bi bi-person-plus me-2"></i>Assign Request</h6>
                        <form action="${pageContext.request.contextPath}/change-request/assign" method="post" class="row g-2 align-items-center">
                            <input type="hidden" name="ticketId" value="${ticket.ticketId}">

                            <div class="col-md-12 mb-2">
                                <select name="assignedTo" class="form-select border-primary" required>
                                    <option value="">-- Select System Engineer --</option>
                                    <c:forEach var="eng" items="${engineerList}">
                                        <option value="${eng.userId}" ${ticket.assignedTo == eng.userId ? 'selected' : ''}>
                                            ${eng.fullName} (ID: ${eng.userId})
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-md-12">
                                <button type="submit" class="btn btn-primary w-100 shadow-sm fw-bold">
                                    <i class="bi bi-send-check me-1"></i> Confirm Assign
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </c:if>

            <%-- CAB DECISION INFO --%>
            <%-- HIỂN THỊ KẾT QUẢ ĐÁNH GIÁ & QUYẾT ĐỊNH CỦA CAB (Ai cũng xem được) --%>
            <div class="card shadow-sm border-0 bg-dark text-white mb-4">
                <div class="card-body p-4">
                    <h6 class="fw-bold border-bottom border-secondary pb-2 mb-3"><i class="bi bi-bank me-2"></i>CAB Assessment & Decision</h6>

                    <div class="mb-3">
                        <small class="text-secondary d-block fw-bold">Risk & Schedule Assessment:</small>
                        <p class="text-light mb-2 fst-italic border-start border-3 border-secondary ps-2">
                            ${not empty ticket.cabRiskAssessment ? ticket.cabRiskAssessment : 'Đang chờ hội đồng đánh giá rủi ro...'}
                        </p>
                    </div>
                    <div class="mb-3">
                        <small class="text-secondary d-block fw-bold">CAB Comments:</small>
                        <p class="text-light mb-0">${not empty ticket.cabComment ? ticket.cabComment : 'Chưa có bình luận.'}</p>
                    </div>

                    <div class="d-flex align-items-center justify-content-between mt-4 pt-3 border-top border-secondary">
                        <div class="d-flex align-items-center">
                            <h4 class="m-0 me-2 ${ticket.cabDecision == 'APPROVED' ? 'text-success' : (ticket.cabDecision == 'REJECTED' ? 'text-danger' : 'text-warning')}">
                                <i class="bi ${ticket.cabDecision == 'APPROVED' ? 'bi-check-circle-fill' : (ticket.cabDecision == 'REJECTED' ? 'bi-x-circle-fill' : 'bi-hourglass-split')}"></i>
                            </h4>
                            <span class="fs-5 fw-bold">${not empty ticket.cabDecision ? ticket.cabDecision : 'PENDING'}</span>
                        </div>

                        <%-- HAI NÚT APPROVE/REJECT DÀNH CHO CAB MEMBER --%>
                        <c:if test="${sessionScope.user.roleId == 7 and ticket.cabDecision ne 'APPROVED' and ticket.cabDecision ne 'REJECTED'}">
                            <form action="${pageContext.request.contextPath}/change-request/review" method="post" class="m-0">
                                <input type="hidden" name="actionType" value="single">
                                <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                                <button type="submit" name="decision" value="APPROVED" class="btn btn-success btn-sm fw-bold me-2 shadow-sm" onclick="return confirm('Duyệt phiếu Change Request này?');">
                                    <i class="bi bi-check-lg"></i> Approve
                                </button>
                                <button type="submit" name="decision" value="REJECTED" class="btn btn-outline-light btn-sm fw-bold shadow-sm" onclick="return confirm('Từ chối phiếu Change Request này?');">
                                    <i class="bi bi-x-lg"></i> Reject
                                </button>
                            </form>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- FORM ĐÁNH GIÁ (CHỈ DÀNH CHO CAB MEMBER - ROLE 7) --%>
    <%-- CAB được quyền sửa đánh giá nếu chưa chốt Approved/Rejected --%>
    <c:if test="${sessionScope.user.roleId == 7 and ticket.cabDecision ne 'APPROVED' and ticket.cabDecision ne 'REJECTED'}">
        <div class="card shadow-sm border-0 mb-4 border-top border-4 border-danger">
            <div class="card-body p-4">
                <h6 class="fw-bold text-dark mb-3"><i class="bi bi-clipboard2-pulse me-2"></i>Assess Change Risk</h6>
                <form action="${pageContext.request.contextPath}/change-request/assess" method="post">
                    <input type="hidden" name="ticketId" value="${ticket.ticketId}">

                    <div class="mb-3">
                        <label class="form-label fw-bold text-danger small">Risk & Schedule Assessment <span class="text-danger">*</span></label>
                        <textarea name="cabRiskAssessment" class="form-control border-danger" rows="3" required placeholder="Đánh giá mức độ rủi ro, thời gian downtime có hợp lý không?">${ticket.cabRiskAssessment}</textarea>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold text-secondary small">Additional Comments</label>
                        <textarea name="cabComment" class="form-control border-secondary" rows="2" placeholder="Góp ý hoặc yêu cầu điều chỉnh...">${ticket.cabComment}</textarea>
                    </div>

                    <button type="submit" class="btn btn-danger w-100 fw-bold shadow-sm">
                        <i class="bi bi-save me-1"></i> Save Assessment
                    </button>
                </form>
            </div>
        </div>
    </c:if>
</div>
</div>
</div>

<jsp:include page="/includes/footer.jsp" />