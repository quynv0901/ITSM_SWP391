<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/includes/header.jsp" />

<div class="container-fluid bg-white p-4 rounded shadow-sm">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="h4 text-primary m-0"><i class="bi bi-list-check me-2"></i>Việc được giao cho tôi</h2>
    </div>

    <div class="table-responsive">
        <table class="table table-hover table-bordered align-middle">
            <thead class="table-light">
                <tr>
                    <th>Mã phiếu</th>
                    <th>Loại phiếu</th>
                    <th>Tiêu đề</th>
                    <th>Ưu tiên</th>
                    <th>Trạng thái</th>
                    <th>Ngày tạo</th>
                    <th>Lịch dự kiến</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="item" items="${myTickets}">
                    <tr>
                        <td>${item.ticketNumber}</td>
                        <td>${item.ticketType}</td>
                        <td>${item.title}</td>
                        <td>${item.priority}</td>
                        <td>${item.status}</td>
                        <td><fmt:formatDate value="${item.createdAt}" pattern="dd/MM/yyyy HH:mm" /></td>
                        <td><fmt:formatDate value="${item.scheduledStart}" pattern="dd/MM/yyyy HH:mm" /></td>
                    </tr>
                </c:forEach>
                <c:if test="${empty myTickets}">
                    <tr><td colspan="7" class="text-center text-muted">Hiện chưa có công việc nào được giao cho bạn.</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />
