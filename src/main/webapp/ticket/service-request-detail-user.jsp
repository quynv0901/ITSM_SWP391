<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setLocale value="vi_VN" />
<jsp:include page="/includes/header.jsp" />

<c:set var="ticket" value="${serviceRequest}" />

<div class="container-fluid bg-light p-4 rounded shadow-sm mb-5">

    <c:if test="${not empty param.msg}">
        <div class="alert alert-info alert-dismissible fade show" role="alert">
            <c:choose>
                <c:when test="${param.msg eq 'cancelled'}">Hủy yêu cầu thành công.</c:when>
                <c:when test="${param.msg eq 'deleted'}">Xóa yêu cầu thành công.</c:when>
                <c:when test="${param.msg eq 'comment_added'}">Thêm bình luận thành công.</c:when>
                <c:otherwise>Thao tác đã hoàn tất.</c:otherwise>
            </c:choose>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb bg-transparent p-0 m-0">
                <li class="breadcrumb-item">
                    <a href="${pageContext.request.contextPath}/service-request?action=list">Yêu cầu của tôi</a>
                </li>
                <li class="breadcrumb-item active" aria-current="page">${ticket.ticketNumber}</li>
            </ol>
        </nav>

        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/service-request?action=list"
               class="btn btn-outline-secondary btn-sm shadow-sm">
                <i class="bi bi-arrow-left"></i> Quay lại
            </a>

            <c:if test="${ticket.status ne 'CANCELLED' and ticket.status ne 'CLOSED' and ticket.status ne 'RESOLVED'}">
                <form action="${pageContext.request.contextPath}/service-request" method="post"
                      onsubmit="return confirm('Bạn có chắc muốn hủy yêu cầu dịch vụ này không?');">
                    <input type="hidden" name="action" value="cancel">
                    <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                    <button type="submit" class="btn btn-warning btn-sm shadow-sm text-dark">
                        <i class="bi bi-x-circle"></i> Hủy yêu cầu
                    </button>
                </form>
            </c:if>

            <c:if test="${ticket.status eq 'NEW' and empty ticket.assignedTo}">
                <form action="${pageContext.request.contextPath}/service-request" method="post"
                      onsubmit="return confirm('Bạn có chắc muốn xóa yêu cầu này không?');">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                    <button type="submit" class="btn btn-danger btn-sm shadow-sm">
                        <i class="bi bi-trash"></i> Xóa
                    </button>
                </form>
            </c:if>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-md-8">
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-header bg-white border-bottom py-3">
                    <h4 class="mb-0 text-primary">${ticket.title}</h4>
                </div>
                <div class="card-body p-4">
                    <h6 class="fw-bold text-dark mb-2">Mô tả yêu cầu</h6>
                    <p class="text-secondary">${ticket.description}</p>

                    <h6 class="fw-bold text-dark mb-2 mt-4">Lý do yêu cầu</h6>
                    <p class="text-secondary bg-light p-3 rounded border">
                        ${not empty ticket.justification ? ticket.justification : 'Không có'}
                    </p>

                    <h6 class="fw-bold text-dark mb-2 mt-4">Tiến độ xử lý / Kết quả</h6>
                    <p class="text-secondary bg-light p-3 rounded border">
                        ${not empty ticket.solution ? ticket.solution : 'Chưa có cập nhật xử lý.'}
                    </p>

                    <c:if test="${ticket.approvalStatus eq 'REJECTED' and not empty ticket.rejectionReason}">
                        <h6 class="fw-bold text-danger mb-2 mt-4">Lý do từ chối</h6>
                        <p class="text-danger bg-light p-3 rounded border border-danger">
                            ${ticket.rejectionReason}
                        </p>
                    </c:if>
                </div>
            </div>

            <div class="card shadow-sm border-0">
                <div class="card-header bg-white border-bottom py-3">
                    <h6 class="mb-0 fw-bold">Bình luận</h6>
                </div>
                <div class="card-body p-4 bg-light">
                    <form action="${pageContext.request.contextPath}/service-request" method="post"
                          class="mb-4 bg-white p-3 rounded shadow-sm border" accept-charset="UTF-8">
                        <input type="hidden" name="action" value="comment">
                        <input type="hidden" name="ticketId" value="${ticket.ticketId}">

                        <div class="mb-2">
                            <textarea class="form-control" name="commentText" rows="3"
                                      placeholder="Nhập bình luận..." required></textarea>
                        </div>

                        <div class="text-end">
                            <button type="submit" class="btn btn-primary btn-sm">
                                <i class="bi bi-send-fill me-1"></i> Gửi bình luận
                            </button>
                        </div>
                    </form>

                    <c:forEach var="cmt" items="${ticket.comments}">
                        <div class="bg-white p-3 rounded shadow-sm border mb-3">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <strong>${cmt.userName}</strong>
                                <small class="text-muted">
                                    <fmt:formatDate value="${cmt.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                </small>
                            </div>
                            <div class="text-secondary" style="white-space: pre-wrap;">
                                ${cmt.commentText}
                            </div>
                        </div>
                    </c:forEach>

                    <c:if test="${empty ticket.comments}">
                        <div class="text-center text-muted fst-italic py-3">
                            Chưa có bình luận nào.
                        </div>
                    </c:if>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-body p-4">
                    <h6 class="fw-bold border-bottom pb-2 mb-3">Thông tin yêu cầu</h6>
                    <ul class="list-unstyled mb-0">
                        <li class="mb-3">
                            <small class="text-muted d-block">Mã yêu cầu</small>
                            <strong>${ticket.ticketNumber}</strong>
                        </li>
                        <li class="mb-3">
                            <small class="text-muted d-block">Trạng thái</small>
                            <span class="badge bg-primary">
                                <c:choose>
                                    <c:when test="${ticket.status eq 'NEW'}">Mới</c:when>
                                    <c:when test="${ticket.status eq 'ASSIGNED'}">Đã phân công</c:when>
                                    <c:when test="${ticket.status eq 'IN_PROGRESS'}">Đang xử lý</c:when>
                                    <c:when test="${ticket.status eq 'PENDING'}">Đang chờ</c:when>
                                    <c:when test="${ticket.status eq 'RESOLVED'}">Đã xử lý</c:when>
                                    <c:when test="${ticket.status eq 'CLOSED'}">Đã đóng</c:when>
                                    <c:when test="${ticket.status eq 'CANCELLED'}">Đã hủy</c:when>
                                    <c:otherwise>${ticket.status}</c:otherwise>
                                </c:choose>
                            </span>
                        </li>
                        <li class="mb-3">
                            <small class="text-muted d-block">Trạng thái duyệt</small>
                            <span class="badge ${ticket.approvalStatus eq 'APPROVED' ? 'bg-success' : (ticket.approvalStatus eq 'REJECTED' ? 'bg-danger' : 'bg-warning text-dark')}">
                                <c:choose>
                                    <c:when test="${ticket.approvalStatus eq 'PENDING'}">Chờ duyệt</c:when>
                                    <c:when test="${ticket.approvalStatus eq 'APPROVED'}">Đã duyệt</c:when>
                                    <c:when test="${ticket.approvalStatus eq 'REJECTED'}">Đã từ chối</c:when>
                                    <c:otherwise>${ticket.approvalStatus}</c:otherwise>
                                </c:choose>
                            </span>
                        </li>
                        <li class="mb-3">
                            <small class="text-muted d-block">Mức độ ưu tiên</small>
                            <strong>
                                <c:choose>
                                    <c:when test="${ticket.priority eq 'LOW'}">Thấp</c:when>
                                    <c:when test="${ticket.priority eq 'MEDIUM'}">Trung bình</c:when>
                                    <c:when test="${ticket.priority eq 'HIGH'}">Cao</c:when>
                                    <c:when test="${ticket.priority eq 'CRITICAL'}">Khẩn cấp</c:when>
                                    <c:otherwise>${ticket.priority}</c:otherwise>
                                </c:choose>
                            </strong>
                        </li>
                        <li class="mb-3">
                            <small class="text-muted d-block">Ngày tạo</small>
                            <strong><fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy HH:mm"/></strong>
                        </li>
                        <li class="mb-3">
                            <small class="text-muted d-block">Người xử lý</small>
                            <strong>
                                <c:choose>
                                    <c:when test="${not empty ticket.assignedToName}">
                                        ${ticket.assignedToName}
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted">Chưa phân công</span>
                                    </c:otherwise>
                                </c:choose>
                            </strong>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="card shadow-sm border-0">
                <div class="card-body p-4">
                    <h6 class="fw-bold border-bottom pb-2 mb-3">Dịch vụ đã yêu cầu</h6>
                    <ul class="list-unstyled mb-0">
                        <li class="mb-3">
                            <small class="text-muted d-block">Tên dịch vụ</small>
                            <strong>${ticket.serviceName}</strong>
                        </li>
                        <li class="mb-3">
                            <small class="text-muted d-block">Mã dịch vụ</small>
                            <strong>${ticket.serviceCode}</strong>
                        </li>
                        <li class="mb-3">
                            <small class="text-muted d-block">Thời gian dự kiến hoàn thành (ngày)</small>
                            <strong>${ticket.estimatedDeliveryDay}</strong>
                        </li>
                        <li class="mb-3">
                            <small class="text-muted d-block">Mô tả dịch vụ</small>
                            <div class="text-secondary">${ticket.serviceDescription}</div>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />
