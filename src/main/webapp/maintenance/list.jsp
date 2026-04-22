<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/common/admin-layout-top.jsp" />

<div class="container-fluid px-4 py-4">

    <%-- Alert CI đang INACTIVE chưa có log --%>
    <c:if test="${not empty inactiveCIsWithoutLog}">
        <div class="alert alert-warning alert-dismissible fade show border-start border-4 border-warning shadow-sm mb-4" role="alert">
            <div class="d-flex align-items-start">
                <i class="bi bi-exclamation-triangle-fill fs-4 me-3 text-warning"></i>
                <div>
                    <strong>Có ${inactiveCIsWithoutLog.size()} thiết bị đang ngừng hoạt động chưa được ghi nhật ký:</strong>
                    <ul class="mb-1 mt-1">
                        <c:forEach var="ciName" items="${inactiveCIsWithoutLog}">
                            <li>${ciName}</li>
                        </c:forEach>
                    </ul>
                    <a href="${pageContext.request.contextPath}/maintenance-log?action=new" class="btn btn-sm btn-warning mt-1">
                        <i class="bi bi-plus-circle me-1"></i> Tạo nhật ký ngay
                    </a>
                </div>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <%-- Thông báo thành công --%>
    <c:choose>
        <c:when test="${param.success == 'created'}">
            <div class="alert alert-success alert-dismissible fade show shadow-sm mb-3">
                <i class="bi bi-check-circle me-2"></i>Đã tạo nhật ký bảo trì thành công.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:when>
        <c:when test="${param.success == 'updated'}">
            <div class="alert alert-success alert-dismissible fade show shadow-sm mb-3">
                <i class="bi bi-check-circle me-2"></i>Đã cập nhật nhật ký bảo trì.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:when>
        <c:when test="${param.success == 'deleted'}">
            <div class="alert alert-info alert-dismissible fade show shadow-sm mb-3">
                <i class="bi bi-archive me-2"></i>Nhật ký đã được hủy. Dữ liệu vẫn được lưu trữ.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:when>
    </c:choose>

    <%-- Header --%>
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h3 class="mb-1 fw-bold text-dark"><i class="bi bi-tools text-primary me-2"></i>Nhật ký Bảo trì IT</h3>
            <p class="text-muted mb-0">Theo dõi lịch sử bảo dưỡng, sự cố phần cứng/phần mềm và lịch bảo trì sắp tới.</p>
        </div>
        <c:if test="${sessionScope.user.roleId == 6 || sessionScope.user.roleId == 8 || sessionScope.user.roleId == 10}">
            <a href="${pageContext.request.contextPath}/maintenance-log?action=new" class="btn btn-primary shadow-sm px-4">
                <i class="bi bi-plus-circle me-2"></i>Thêm nhật ký
            </a>
        </c:if>
    </div>

    <%-- Bộ lọc — gộp keyword + type thành 1 ô tìm kiếm --%>
    <div class="card shadow-sm border-0 mb-4 bg-white rounded-3">
        <div class="card-body py-3 px-4">
            <form action="${pageContext.request.contextPath}/maintenance-log" method="GET" class="row g-2 align-items-end">
                <input type="hidden" name="action" value="list">

                <%-- Tìm kiếm chung (tên CI + loại bảo trì + mô tả) --%>
                <div class="col-md-5">
                    <label class="form-label text-muted small fw-bold text-uppercase mb-1">Tìm kiếm</label>
                    <div class="input-group">
                        <span class="input-group-text bg-light border-end-0"><i class="bi bi-search text-muted"></i></span>
                        <input type="text" class="form-control border-start-0 ps-0" name="keyword"
                               value="${param.keyword}"
                               placeholder="Tên thiết bị, loại bảo trì, mô tả...">
                    </div>
                </div>

                <%-- Trạng thái --%>
                <div class="col-md-3">
                    <label class="form-label text-muted small fw-bold text-uppercase mb-1">Trạng thái</label>
                    <select name="status" class="form-select">
                        <option value="">-- Tất cả --</option>
                        <option value="PENDING"          ${param.status == 'PENDING'          ? 'selected' : ''}>Chờ xử lý</option>
                        <option value="CONTACTED_VENDOR" ${param.status == 'CONTACTED_VENDOR' ? 'selected' : ''}>Đã liên hệ NCC</option>
                        <option value="IN_PROGRESS"      ${param.status == 'IN_PROGRESS'      ? 'selected' : ''}>Đang tiến hành</option>
                        <option value="COMPLETED"        ${param.status == 'COMPLETED'        ? 'selected' : ''}>Đã hoàn thành</option>
                    </select>
                </div>

                <%-- Lọc theo thiết bị --%>
                <div class="col-md-2">
                    <label class="form-label text-muted small fw-bold text-uppercase mb-1">Thiết bị</label>
                    <select name="ciId" class="form-select" id="ciFilterSelect">
                        <option value="">-- Tất cả --</option>
                        <c:forEach var="ci" items="${cis}">
                            <option value="${ci.ciId}" ${param.ciId == ci.ciId ? 'selected' : ''}>${ci.name}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="col-md-2 d-flex gap-2">
                    <button type="submit" class="btn btn-dark flex-grow-1"><i class="bi bi-funnel me-1"></i>Lọc</button>
                    <a href="${pageContext.request.contextPath}/maintenance-log" class="btn btn-light border" title="Xóa bộ lọc">
                        <i class="bi bi-x-circle"></i>
                    </a>
                </div>
            </form>
        </div>
    </div>

    <%-- Bảng dữ liệu --%>
    <div class="card shadow-sm border-0 rounded-3">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light text-muted small text-uppercase">
                        <tr>
                            <th class="ps-4" style="width:60px">ID</th>
                            <th>Thiết bị (CI)</th>
                            <th>Loại bảo trì</th>
                            <th>Ngày</th>
                            <th>Trạng thái</th>
                            <th>T.Gian Thực Hiện</th>
                            <th>Người tạo / Phụ trách</th>
                            <c:if test="${sessionScope.user.roleId == 6 || sessionScope.user.roleId == 8 || sessionScope.user.roleId == 10}">
                                <th class="text-end pe-4">Thao tác</th>
                            </c:if>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty logs}">
                                <tr>
                                    <td colspan="8" class="text-center py-5 text-muted">
                                        <i class="bi bi-inbox fs-2 d-block mb-2 text-muted"></i>
                                        Không tìm thấy nhật ký bảo trì nào.
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="log" items="${logs}">
                                    <tr>
                                        <td class="ps-4 fw-bold text-muted">#${log.logId}</td>

                                        <%-- Thiết bị --%>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/configuration-item?action=detail&id=${log.ciId}"
                                               class="fw-semibold text-primary text-decoration-none">${log.ciName}</a>
                                            <c:if test="${log.ciStatus == 'INACTIVE'}">
                                                <span class="badge bg-danger ms-1" style="font-size:10px">INACTIVE</span>
                                            </c:if>
                                            <div class="small text-muted text-truncate mt-1" style="max-width:200px" title="${log.description}">
                                                ${log.description}
                                            </div>
                                        </td>

                                        <%-- Loại bảo trì --%>
                                        <td><span class="badge bg-dark">${log.maintenanceType}</span></td>

                                        <%-- Ngày --%>
                                        <td>
                                            <fmt:formatDate value="${log.maintenanceDate}" pattern="dd/MM/yyyy"/>
                                            <c:if test="${log.scheduled}">
                                                <span class="badge bg-info text-dark d-block mt-1" style="font-size:10px">Lên lịch</span>
                                            </c:if>
                                        </td>

                                        <%-- Trạng thái --%>
                                        <td>
                                            <c:choose>
                                                <c:when test="${log.status == 'PENDING'}"><span class="badge bg-secondary">Chờ xử lý</span></c:when>
                                                <c:when test="${log.status == 'CONTACTED_VENDOR'}"><span class="badge bg-warning text-dark">Liên hệ NCC</span></c:when>
                                                <c:when test="${log.status == 'IN_PROGRESS'}"><span class="badge bg-primary">Đang tiến hành</span></c:when>
                                                <c:when test="${log.status == 'COMPLETED'}"><span class="badge bg-success">Hoàn thành</span></c:when>
                                                <c:otherwise><span class="badge bg-light text-dark border">${log.status}</span></c:otherwise>
                                            </c:choose>
                                        </td>

                                        <%-- Downtime tự động --%>
                                        <td>
                                            <c:choose>
                                                <c:when test="${log.actualDowntimeMinutes >= 0}">
                                                    <c:choose>
                                                        <c:when test="${log.actualDowntimeMinutes == 0}">
                                                            <span class="text-success small"><i class="bi bi-check-circle me-1"></i>0 phút</span>
                                                        </c:when>
                                                        <c:when test="${log.actualDowntimeMinutes > 60}">
                                                            <span class="text-danger fw-bold small"><i class="bi bi-clock-history me-1"></i>${log.actualDowntimeMinutes} phút</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-warning small"><i class="bi bi-clock-history me-1"></i>${log.actualDowntimeMinutes} phút</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted small">—</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <%-- Người tạo / Phụ trách --%>
                                        <td>
                                            <c:if test="${not empty log.performedByName}">
                                                <div class="small fw-medium">${log.performedByName}</div>
                                            </c:if>
                                            <c:if test="${not empty log.createdByName && log.createdByName != log.performedByName}">
                                                <div class="small text-muted">Tạo bởi: ${log.createdByName}</div>
                                            </c:if>
                                            <c:if test="${empty log.performedByName && empty log.createdByName}">
                                                <span class="text-muted small">—</span>
                                            </c:if>
                                        </td>

                                        <%-- Thao tác --%>
                                        <c:if test="${sessionScope.user.roleId == 6 || sessionScope.user.roleId == 8 || sessionScope.user.roleId == 10}">
                                            <td class="text-end pe-4">
                                                <div class="btn-group">
                                                    <a href="${pageContext.request.contextPath}/maintenance-log?action=edit&id=${log.logId}"
                                                       class="btn btn-sm btn-outline-primary" title="Sửa">
                                                        <i class="bi bi-pencil"></i>
                                                    </a>
                                                    <button type="button" class="btn btn-sm btn-outline-danger"
                                                            onclick="confirmSoftDelete(${log.logId}, '${log.ciName}')"
                                                            title="Hủy nhật ký (xóa mềm)">
                                                        <i class="bi bi-archive"></i>
                                                    </button>
                                                </div>
                                            </td>
                                        </c:if>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <%-- Pagination --%>
            <c:if test="${totalPages > 1}">
                <div class="card-footer bg-white border-top-0 py-3 d-flex justify-content-between align-items-center px-4">
                    <span class="text-muted small">Tổng <strong>${totalRecords}</strong> nhật ký</span>
                    <nav>
                        <ul class="pagination pagination-sm mb-0">
                            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                <a class="page-link" href="?action=list&page=${currentPage - 1}&keyword=${param.keyword}&status=${param.status}&ciId=${param.ciId}">‹</a>
                            </li>
                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <li class="page-item ${currentPage == i ? 'active' : ''}">
                                    <a class="page-link" href="?action=list&page=${i}&keyword=${param.keyword}&status=${param.status}&ciId=${param.ciId}">${i}</a>
                                </li>
                            </c:forEach>
                            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                <a class="page-link" href="?action=list&page=${currentPage + 1}&keyword=${param.keyword}&status=${param.status}&ciId=${param.ciId}">›</a>
                            </li>
                        </ul>
                    </nav>
                </div>
            </c:if>
        </div>
    </div>
</div>

<script>
    function confirmSoftDelete(id, ciName) {
        if (confirm(
            'Hủy nhật ký bảo trì cho "' + ciName + '"?\n\n' +
            'Dữ liệu KHÔNG bị xóa — chỉ ẩn khỏi danh sách.\n' +
            'Liên hệ Admin để khôi phục nếu cần.'
        )) {
            window.location.href = '${pageContext.request.contextPath}/maintenance-log?action=delete&id=' + id;
        }
    }

    // Live search cho dropdown thiết bị ở filter
    document.addEventListener('DOMContentLoaded', function () {
        const ciSelect = document.getElementById('ciFilterSelect');
        if (!ciSelect) return;
        const allOptions = Array.from(ciSelect.options);

        const searchBox = document.createElement('input');
        searchBox.type = 'text';
        searchBox.className = 'form-control form-control-sm mb-1';
        searchBox.placeholder = 'Tìm thiết bị...';
        ciSelect.parentNode.insertBefore(searchBox, ciSelect);

        searchBox.addEventListener('input', function () {
            const q = this.value.toLowerCase();
            allOptions.forEach(opt => {
                opt.hidden = opt.value !== '' && !opt.text.toLowerCase().includes(q);
            });
        });
    });
</script>

<jsp:include page="/common/admin-layout-bottom.jsp" />
