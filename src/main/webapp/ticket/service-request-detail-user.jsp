<jsp:include page="/includes/header.jsp" />
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<style>
    /* CSS cho Thanh Tiến Trình */
    .step-progress { display: flex; justify-content: space-between; position: relative; margin-bottom: 2rem; }
    .step-progress::before { content: ""; position: absolute; top: 15px; left: 0; width: 100%; height: 3px; background-color: #e9ecef; z-index: 1; }
    .step { text-align: center; position: relative; z-index: 2; flex: 1; }
    .step-icon { width: 35px; height: 35px; border-radius: 50%; background-color: #e9ecef; color: #6c757d; display: flex; align-items: center; justify-content: center; margin: 0 auto 10px; font-weight: bold; border: 3px solid #fff; }
    .step.completed .step-icon { background-color: #198754; color: #fff; }
    .step.active .step-icon { background-color: #0d6efd; color: #fff; box-shadow: 0 0 0 3px rgba(13, 110, 253, 0.25); }
    .step-label { font-size: 0.85rem; font-weight: 600; color: #6c757d; }
    .step.completed .step-label, .step.active .step-label { color: #212529; }
</style>

<div class="d-flex justify-content-between align-items-center mb-4">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb bg-transparent p-0 m-0">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/ticket/service-request-list">My Requests</a></li>
                <li class="breadcrumb-item active" aria-current="page">#SR-${ticket.ticketId}</li>
            </ol>
        </nav>
        
        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/ticket/service-request-list" class="btn btn-outline-secondary btn-sm shadow-sm">
                <i class="bi bi-arrow-left"></i> Back to List
            </a>
            <%-- Nút Cancel (Chỉ hiện khi status chưa phải là các trạng thái kết thúc) --%>
            <c:if test="${ticket.status ne 'CANCELLED' and ticket.status ne 'CLOSED' and ticket.status ne 'RESOLVED'}">
                <form action="${pageContext.request.contextPath}/ticket/cancel-request" method="post" style="display: inline;" onsubmit="return confirm('Bạn có chắc chắn muốn HỦY Request này không? Hành động này sẽ dừng mọi quá trình xử lý.');">
                    <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                    <button type="submit" class="btn btn-warning btn-sm shadow-sm text-dark">
                        <i class="bi bi-x-circle"></i> Cancel Request
                    </button>
                </form>
            </c:if>
            <c:if test="${ticket.status == 'NEW' && empty ticket.assignedTo}">
                <form action="${pageContext.request.contextPath}/ticket/delete-request" method="post" onsubmit="return confirm('Bạn có chắc chắn muốn xóa Request này không? Hành động này không thể hoàn tác.');">
                    <input type="hidden" name="action" value="single">
                    <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                    <button type="submit" class="btn btn-danger btn-sm shadow-sm">
                        <i class="bi bi-trash"></i> Delete Request
                    </button>
                </form>
            </c:if>
        </div>
    </div>

    <div class="card shadow-sm border-0 mb-4">
        <div class="card-body p-4">
            <h5 class="card-title fw-bold mb-4 text-dark"><i class="bi bi-bar-chart-steps me-2"></i>Fulfillment Progress</h5>
            <c:set var="isNew" value="${ticket.status == 'NEW' || ticket.status == 'PENDING_APPROVAL'}" />
            <c:set var="isInProgress" value="${ticket.status == 'IN_PROGRESS' || ticket.status == 'APPROVED'}" />
            <c:set var="isResolved" value="${ticket.status == 'RESOLVED'}" />
            <c:set var="isClosed" value="${ticket.status == 'CLOSED'}" />
            <div class="step-progress">
                <div class="step ${isNew || isInProgress || isResolved || isClosed ? 'completed' : 'active'}">
                    <div class="step-icon"><i class="bi bi-file-earmark-check"></i></div><div class="step-label">Submitted</div>
                </div>
                <div class="step ${isInProgress || isResolved || isClosed ? 'completed' : (isNew ? '' : 'active')}">
                    <div class="step-icon"><i class="bi bi-person-check"></i></div><div class="step-label">Approved</div>
                </div>
                <div class="step ${isResolved || isClosed ? 'completed' : (isInProgress ? 'active' : '')}">
                    <div class="step-icon"><i class="bi bi-gear-wide-connected"></i></div><div class="step-label">Fulfillment</div>
                </div>
                <div class="step ${isClosed ? 'completed' : (isResolved ? 'active' : '')}">
                    <div class="step-icon"><i class="bi bi-check-circle"></i></div><div class="step-label">Resolved</div>
                </div>
            </div>
            
            <%-- Hiển thị ghi chú của Support để User xem tiến độ --%>
            <c:if test="${not empty ticket.solution}">
                <div class="alert alert-info mt-4 mb-0 border-0 shadow-sm">
                    <strong><i class="bi bi-chat-dots me-2"></i>Update from IT Support:</strong><br>
                    ${ticket.solution}
                </div>
            </c:if>
        </div>
    </div>

    <div class="row">
        <div class="col-md-8">
            <div class="card shadow-sm border-0 h-100">
                <div class="card-header bg-white border-bottom py-3">
                    <h4 class="mb-0 text-primary">${ticket.title}</h4>
                </div>
                <div class="card-body p-4">
                    <h6 class="fw-bold text-dark mb-2"><i class="bi bi-card-text me-2"></i>Business Justification</h6>
                    <p class="text-muted bg-light p-3 rounded border-start border-4 border-primary mb-4">${not empty ticket.justification ? ticket.justification : 'No justification provided.'}</p>
                    <h6 class="fw-bold text-dark mb-2"><i class="bi bi-info-square me-2"></i>Additional Description</h6>
                    <p class="text-secondary">${not empty ticket.description ? ticket.description : 'No additional information.'}</p>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card shadow-sm border-0 h-100">
                <div class="card-body p-4">
                    <h6 class="fw-bold text-dark border-bottom pb-2 mb-3">Request Details</h6>
                    <ul class="list-unstyled mb-0">
                        <li class="mb-3"><small class="text-muted d-block">Status</small><span class="badge ${ticket.status == 'NEW' ? 'bg-primary' : (ticket.status == 'RESOLVED' ? 'bg-success' : 'bg-secondary')} fs-6">${ticket.status}</span></li>
                        <li class="mb-3"><small class="text-muted d-block">Priority</small><span class="badge ${ticket.priority == 'CRITICAL' ? 'bg-danger' : (ticket.priority == 'HIGH' ? 'bg-warning text-dark' : 'bg-info text-dark')}">${ticket.priority}</span></li>
                        <li class="mb-3"><small class="text-muted d-block">Requester</small><strong><i class="bi bi-person me-1"></i> ${ticket.reportedByName}</strong></li>
                        <li class="mb-3"><small class="text-muted d-block">Created Date</small><span class="text-dark"><i class="bi bi-calendar3 me-1"></i> <fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy HH:mm" /></span></li>
                        <li><small class="text-muted d-block">Ticket ID</small><span class="font-monospace text-secondary">#SR-${ticket.ticketId}</span></li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
                    <%-- ============================================ --%>
    <%-- KHU VỰC 3: DISCUSSION / COMMENT (Dành cho TẤT CẢ) --%>
    <%-- ============================================ --%>
    <div class="card shadow-sm border-0 mt-4 border-top border-4 border-info">
        <div class="card-header bg-white py-3">
            <h5 class="mb-0 text-dark fw-bold"><i class="bi bi-chat-dots me-2"></i>Discussion & Updates</h5>
        </div>
        <div class="card-body p-4 bg-light">
            
            <%-- Hiển thị danh sách Comment như dạng khung Chat --%>
            <div class="mb-4 pe-2" style="max-height: 400px; overflow-y: auto;">
                <c:forEach var="cmt" items="${commentList}">
                    <%-- Ép phải nếu là comment của mình, ép trái nếu của người khác --%>
                    <div class="d-flex mb-3 ${cmt.userId == sessionScope.user.userId ? 'justify-content-end' : ''}">
                        <div class="card shadow-sm border-0" style="max-width: 80%; ${cmt.userId == sessionScope.user.userId ? 'background-color: #e3f2fd;' : 'background-color: #fff;'}">
                            <div class="card-body p-3">
                                <h6 class="card-subtitle mb-2 text-muted fw-bold" style="font-size: 0.85rem;">
                                    <%-- GỌI TÊN TỪ MODEL COMMENT CỦA BẠN --%>
                                    ${cmt.userName} 
                                    <span class="badge bg-secondary ms-1">${cmt.userRoleId == 1 ? 'End-User' : (cmt.userRoleId == 2 ? 'IT Support' : (cmt.userRoleId == 3 ? 'Manager' : 'Admin'))}</span>
                                    <span class="fw-normal ms-2" style="font-size: 0.75rem;">
                                        <i class="bi bi-clock me-1"></i><fmt:formatDate value="${cmt.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                    </span>
                                </h6>
                                <p class="card-text mb-0 text-dark" style="white-space: pre-wrap;">${cmt.commentText}</p>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                
                <c:if test="${empty commentList}">
                    <div class="text-center text-muted fst-italic py-4">
                        <i class="bi bi-chat-square-text fs-3 d-block mb-2 text-secondary"></i>
                        Chưa có bình luận nào. Hãy là người đầu tiên trao đổi!
                    </div>
                </c:if>
            </div>
            
            <%-- Form Gửi Comment (Ẩn form nếu Request đã CLOSED/CANCELLED) --%>
            <c:if test="${ticket.status ne 'CLOSED' and ticket.status ne 'CANCELLED'}">
                <form action="${pageContext.request.contextPath}/ticket/add-comment" method="post">
                    <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                    <div class="input-group shadow-sm">
                        <input type="text" name="commentText" class="form-control border-secondary p-3" placeholder="Nhập bình luận hoặc cập nhật tình hình..." required autocomplete="off">
                        <button class="btn btn-primary px-4 fw-bold" type="submit"><i class="bi bi-send me-1"></i> Send</button>
                    </div>
                </form>
            </c:if>
            <c:if test="${ticket.status eq 'CLOSED' or ticket.status eq 'CANCELLED'}">
                <div class="alert alert-secondary mb-0 text-center">
                    <i class="bi bi-lock me-1"></i> Ticket này đã đóng, không thể bình luận thêm.
                </div>
            </c:if>
        </div>
    </div>v>
<jsp:include page="/includes/footer.jsp" />
