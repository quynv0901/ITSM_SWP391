<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setLocale value="vi_VN" />
<jsp:include page="/includes/header.jsp" />

<c:set var="ticket" value="${serviceRequest}" />
<c:set var="userRole" value="${sessionScope.user.roleId}" />

<div class="container-fluid bg-light p-4 rounded shadow-sm mb-5">

    <c:if test="${not empty param.msg}">
        <div class="alert alert-info alert-dismissible fade show" role="alert">
            <c:choose>
                <c:when test="${param.msg eq 'updated'}">Cập nhật yêu cầu thành công.</c:when>
                <c:when test="${param.msg eq 'assigned'}">Phân công yêu cầu thành công.</c:when>
                <c:when test="${param.msg eq 'approved'}">Duyệt yêu cầu thành công.</c:when>
                <c:when test="${param.msg eq 'rejected'}">Từ chối yêu cầu thành công.</c:when>
                <c:when test="${param.msg eq 'cancelled'}">Hủy yêu cầu thành công.</c:when>
                <c:when test="${param.msg eq 'comment_added'}">Thêm bình luận thành công.</c:when>
                <c:when test="${param.msg eq 'invalid_status'}">Trạng thái không hợp lệ đối với Support Agent.</c:when>
                <c:otherwise>Thao tác đã hoàn tất.</c:otherwise>
            </c:choose>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb bg-transparent p-0 m-0">
                <li class="breadcrumb-item">
                    <a href="${pageContext.request.contextPath}/service-request?action=list">Danh sách yêu cầu dịch vụ</a>
                </li>
                <li class="breadcrumb-item active" aria-current="page">${ticket.ticketNumber}</li>
            </ol>
        </nav>

        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/service-request?action=list"
               class="btn btn-outline-secondary btn-sm shadow-sm">
                <i class="bi bi-arrow-left"></i> Quay lại
            </a>

            <c:if test="${userRole == 3 and ticket.status ne 'CANCELLED' and ticket.status ne 'CLOSED' and ticket.status ne 'RESOLVED'}">
                <form action="${pageContext.request.contextPath}/service-request" method="post"
                      onsubmit="return confirm('Bạn có chắc muốn hủy yêu cầu này không?');">
                    <input type="hidden" name="action" value="cancel">
                    <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                    <button type="submit" class="btn btn-warning btn-sm shadow-sm text-dark">
                        <i class="bi bi-x-circle"></i> Hủy yêu cầu
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

                    <h6 class="fw-bold text-dark mb-2 mt-4">Ghi chú xử lý / kết quả thực hiện</h6>
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

            <div class="card shadow-sm border-0 mb-4">
                <div class="card-header bg-white border-bottom py-3">
                    <h6 class="mb-0 fw-bold">Cập nhật tiến độ xử lý</h6>
                </div>
                <div class="card-body p-4">
                    <form action="${pageContext.request.contextPath}/service-request-manage" method="post" accept-charset="UTF-8">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="ticketId" value="${ticket.ticketId}">

                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Tiêu đề</label>
                                <input type="text" name="title" class="form-control" value="${ticket.title}" required>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">Trạng thái</label>
                                <select name="status" class="form-select" required>
                                    <c:choose>
                                        <c:when test="${userRole == 2}">
                                            <option value="IN_PROGRESS" ${ticket.status eq 'IN_PROGRESS' ? 'selected' : ''}>Đang xử lý</option>
                                            <option value="PENDING" ${ticket.status eq 'PENDING' ? 'selected' : ''}>Đang chờ</option>
                                            <option value="RESOLVED" ${ticket.status eq 'RESOLVED' ? 'selected' : ''}>Đã xử lý</option>
                                        </c:when>
                                        <c:otherwise>
                                            <option value="ASSIGNED" ${ticket.status eq 'ASSIGNED' ? 'selected' : ''}>Đã phân công</option>
                                            <option value="IN_PROGRESS" ${ticket.status eq 'IN_PROGRESS' ? 'selected' : ''}>Đang xử lý</option>
                                            <option value="PENDING" ${ticket.status eq 'PENDING' ? 'selected' : ''}>Đang chờ</option>
                                            <option value="RESOLVED" ${ticket.status eq 'RESOLVED' ? 'selected' : ''}>Đã xử lý</option>
                                            <option value="CLOSED" ${ticket.status eq 'CLOSED' ? 'selected' : ''}>Đã đóng</option>
                                        </c:otherwise>
                                    </c:choose>
                                </select>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-bold">Mô tả</label>
                                <textarea name="description" rows="4" class="form-control">${ticket.description}</textarea>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-bold">Ghi chú xử lý</label>
                                <textarea name="solution" rows="4" class="form-control"
                                          placeholder="Cập nhật tiến độ, kết quả thực hiện, ghi chú...">${ticket.solution}</textarea>
                            </div>
                        </div>

                        <div class="text-end mt-3">
                            <button type="submit" class="btn btn-primary">
                                <i class="bi bi-save me-1"></i> Cập nhật yêu cầu
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <div class="card shadow-sm border-0">
                <div class="card-header bg-white border-bottom py-3">
                    <h6 class="mb-0 fw-bold">Bình luận</h6>
                </div>
                <div class="card-body p-4 bg-light">
                    <form action="${pageContext.request.contextPath}/service-request-manage" method="post"
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
                    <h5 class="fw-bold mb-3 text-primary">Thông tin yêu cầu</h5>
                    <p class="mb-2"><strong>Mã yêu cầu:</strong> ${ticket.ticketNumber}</p>
                    <p class="mb-2"><strong>Dịch vụ:</strong> ${ticket.serviceName}</p>
                    <p class="mb-2"><strong>Mã dịch vụ:</strong> ${ticket.serviceCode}</p>
                    <p class="mb-2"><strong>Danh mục:</strong> ${ticket.categoryName}</p>
                    <p class="mb-2"><strong>Người yêu cầu:</strong> ${ticket.reportedByName}</p>
                    <p class="mb-2"><strong>Phòng ban:</strong> ${ticket.departmentName}</p>
                    <p class="mb-2"><strong>Mức độ ưu tiên:</strong>
                        <c:choose>
                            <c:when test="${ticket.priority eq 'LOW'}">Thấp</c:when>
                            <c:when test="${ticket.priority eq 'MEDIUM'}">Trung bình</c:when>
                            <c:when test="${ticket.priority eq 'HIGH'}">Cao</c:when>
                            <c:when test="${ticket.priority eq 'CRITICAL'}">Khẩn cấp</c:when>
                            <c:otherwise>${ticket.priority}</c:otherwise>
                        </c:choose>
                    </p>
                    <p class="mb-2"><strong>Trạng thái:</strong>
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
                    </p>
                    <p class="mb-2"><strong>Trạng thái duyệt:</strong>
                        <c:choose>
                            <c:when test="${ticket.approvalStatus eq 'PENDING'}">Chờ duyệt</c:when>
                            <c:when test="${ticket.approvalStatus eq 'APPROVED'}">Đã duyệt</c:when>
                            <c:when test="${ticket.approvalStatus eq 'REJECTED'}">Đã từ chối</c:when>
                            <c:otherwise>${ticket.approvalStatus}</c:otherwise>
                        </c:choose>
                    </p>
                    <p class="mb-2"><strong>Nhân viên xử lý:</strong>
                        <c:choose>
                            <c:when test="${not empty ticket.assignedToName}">${ticket.assignedToName}</c:when>
                            <c:otherwise>Chưa phân công</c:otherwise>
                        </c:choose>
                    </p>
                    <p class="mb-0"><strong>Ngày tạo:</strong> <fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy HH:mm"/></p>
                </div>
            </div>

            <c:if test="${userRole == 3}">
                <div class="card shadow-sm border-0 mb-4">
                    <div class="card-header bg-white border-bottom py-3">
                        <h6 class="mb-0 fw-bold">Phân công nhân viên hỗ trợ</h6>
                    </div>
                    <div class="card-body p-4">
                        <form action="${pageContext.request.contextPath}/service-request-manage" method="post">
                            <input type="hidden" name="action" value="assign">
                            <input type="hidden" name="ticketId" value="${ticket.ticketId}">

                            <div class="mb-3">
                                <label class="form-label fw-bold">Chọn nhân viên hỗ trợ</label>
                                <select name="assignedTo" class="form-select" required>
                                    <option value="">-- Chọn nhân viên hỗ trợ --</option>
                                    <c:forEach var="agent" items="${agentOptions}">
                                        <option value="${agent.userId}" ${ticket.assignedTo == agent.userId ? 'selected' : ''}>
                                            ${agent.fullName}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="text-end">
                                <button type="submit" class="btn btn-primary btn-sm">
                                    <i class="bi bi-person-check me-1"></i> Phân công
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                <div class="card shadow-sm border-0">
                    <div class="card-header bg-white border-bottom py-3">
                        <h6 class="mb-0 fw-bold">Duyệt yêu cầu</h6>
                    </div>
                    <div class="card-body p-4">
                        <form action="${pageContext.request.contextPath}/service-request-manage" method="post" class="mb-3">
                            <input type="hidden" name="action" value="approve">
                            <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                            <button type="submit" class="btn btn-success w-100">
                                <i class="bi bi-check-circle me-1"></i> Duyệt yêu cầu
                            </button>
                        </form>

                        <form action="${pageContext.request.contextPath}/service-request-manage" method="post" accept-charset="UTF-8">
                            <input type="hidden" name="action" value="reject">
                            <input type="hidden" name="ticketId" value="${ticket.ticketId}">

                            <div class="mb-3">
                                <label class="form-label fw-bold">Lý do từ chối</label>
                                <textarea name="rejectionReason" rows="3" class="form-control" placeholder="Nhập lý do từ chối nếu có..."></textarea>
                            </div>

                            <button type="submit" class="btn btn-outline-danger w-100">
                                <i class="bi bi-x-circle me-1"></i> Từ chối yêu cầu
                            </button>
                        </form>
                    </div>
                </div>
            </c:if>
        </div>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />
