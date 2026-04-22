<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/common/admin-layout-top.jsp" />

<div class="container-fluid px-4 py-4">
    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h3 class="mb-1 fw-bold text-dark"><i class="bi bi-tools text-primary me-2"></i>Nhật ký Nâng cấp & Bảo trì IT</h3>
            <p class="text-muted mb-0">Quản lý lịch sử bảo dưỡng, vá lỗi và cập nhật phần cứng/phần mềm của thiết bị mạng.</p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/maintenance-log?action=new" class="btn btn-primary shadow-sm px-4">
                <i class="bi bi-plus-circle me-2"></i>Thêm nhật ký bảo trì
            </a>
        </div>
    </div>

    <!-- Filter Card -->
    <div class="card shadow-sm border-0 mb-4 bg-white rounded-3">
        <div class="card-body p-4">
            <form action="${pageContext.request.contextPath}/maintenance-log" method="GET" class="row g-3 align-items-end">
                <input type="hidden" name="action" value="list">
                
                <div class="col-md-4">
                    <label class="form-label text-muted small fw-bold text-uppercase">Tìm kiếm</label>
                    <div class="input-group">
                        <span class="input-group-text bg-light border-end-0"><i class="bi bi-search text-muted"></i></span>
                        <input type="text" class="form-control border-start-0 ps-0" name="keyword" 
                               value="${param.keyword}" placeholder="Tên thiết bị, nội dung công việc...">
                    </div>
                </div>

                <div class="col-md-3">
                    <label class="form-label text-muted small fw-bold text-uppercase">Loại bảo trì</label>
                    <select name="type" class="form-select">
                        <option value="">-- Tất cả loại --</option>
                        <option value="SECURITY_PATCH" ${param.type == 'SECURITY_PATCH' ? 'selected' : ''}>Vá lỗi bảo mật (Patch)</option>
                        <option value="FIRMWARE_UPDATE" ${param.type == 'FIRMWARE_UPDATE' ? 'selected' : ''}>Cập nhật Firmware</option>
                        <option value="HARDWARE_UPGRADE" ${param.type == 'HARDWARE_UPGRADE' ? 'selected' : ''}>Nâng cấp phần cứng</option>
                        <option value="ROUTINE" ${param.type == 'ROUTINE' ? 'selected' : ''}>Bảo dưỡng định kỳ</option>
                    </select>
                </div>

                <div class="col-md-3">
                    <label class="form-label text-muted small fw-bold text-uppercase">Thiết bị (CMDB)</label>
                    <select name="ciId" class="form-select">
                        <option value="">-- Tất cả thiết bị --</option>
                        <c:forEach var="ci" items="${cis}">
                            <option value="${ci.ciId}" ${param.ciId == ci.ciId ? 'selected' : ''}>${ci.name}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="col-md-2 d-flex">
                    <button type="submit" class="btn btn-dark w-100 me-2"><i class="bi bi-funnel me-2"></i>Lọc</button>
                    <a href="${pageContext.request.contextPath}/maintenance-log" class="btn btn-light border text-nowrap" title="Xóa bộ lọc">
                        <i class="bi bi-x-circle"></i> Xóa
                    </a>
                </div>
            </form>
        </div>
    </div>

    <!-- Data Table Card -->
    <div class="card shadow-sm border-0 rounded-3">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light text-muted small text-uppercase">
                        <tr>
                            <th class="ps-4">ID</th>
                            <th>Thiết bị (CI)</th>
                            <th>Loại bảo trì</th>
                            <th>Ngày thực hiện</th>
                            <th>Downtime</th>
                            <th>Người thực hiện</th>
                            <th class="text-end pe-4">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty logs}">
                                <tr>
                                    <td colspan="7" class="text-center py-5 text-muted">
                                        <i class="bi bi-inbox fs-1 d-block mb-3"></i>
                                        Không tìm thấy nhật ký bảo trì nào.
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="log" items="${logs}">
                                    <tr>
                                        <td class="ps-4 fw-bold text-muted">#${log.logId}</td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/cmdb?action=detail&id=${log.ciId}" class="fw-semibold text-primary text-decoration-none">
                                                ${log.ciName}
                                            </a>
                                            <div class="small text-muted text-truncate mt-1" style="max-width: 250px;" title="${log.description}">
                                                ${log.description}
                                            </div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${log.maintenanceType == 'SECURITY_PATCH'}"><span class="badge bg-danger">Vá lỗi bảo mật</span></c:when>
                                                <c:when test="${log.maintenanceType == 'FIRMWARE_UPDATE'}"><span class="badge bg-info text-dark">Update Firmware</span></c:when>
                                                <c:when test="${log.maintenanceType == 'HARDWARE_UPGRADE'}"><span class="badge bg-primary">Nâng cấp HW</span></c:when>
                                                <c:when test="${log.maintenanceType == 'ROUTINE'}"><span class="badge bg-secondary">Định kỳ</span></c:when>
                                                <c:otherwise><span class="badge bg-dark">${log.maintenanceType}</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="fw-medium text-dark"><fmt:formatDate value="${log.maintenanceDate}" pattern="dd/MM/yyyy" /></div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${log.downtimeMinutes > 60}">
                                                    <span class="text-danger fw-bold"><i class="bi bi-clock-history me-1"></i>${log.downtimeMinutes} phút</span>
                                                </c:when>
                                                <c:when test="${log.downtimeMinutes > 0}">
                                                    <span class="text-warning text-dark fw-bold"><i class="bi bi-clock-history me-1"></i>${log.downtimeMinutes} phút</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-success"><i class="bi bi-check-circle me-1"></i>0 phút (Không gián đoạn)</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="d-flex align-items-center">
                                                <div class="avatar-circle bg-light text-primary fw-bold me-2" style="width: 32px; height: 32px; line-height: 32px; text-align: center; border-radius: 50%;">
                                                    ${log.performedByName != null ? log.performedByName.substring(0,1) : '?'}
                                                </div>
                                                <span class="fw-medium">${log.performedByName != null ? log.performedByName : 'N/A'}</span>
                                            </div>
                                        </td>
                                        <td class="text-end pe-4">
                                            <div class="btn-group">
                                                <a href="${pageContext.request.contextPath}/maintenance-log?action=edit&id=${log.logId}" 
                                                   class="btn btn-sm btn-outline-primary" title="Sửa">
                                                    <i class="bi bi-pencil"></i>
                                                </a>
                                                <button type="button" class="btn btn-sm btn-outline-danger" 
                                                        onclick="confirmDelete(${log.logId})" title="Xóa">
                                                    <i class="bi bi-trash"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
                <div class="card-footer bg-white border-top-0 py-3">
                    <nav aria-label="Page navigation">
                        <ul class="pagination justify-content-center mb-0">
                            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                <a class="page-link" href="?action=list&page=${currentPage - 1}&keyword=${param.keyword}&type=${param.type}&ciId=${param.ciId}">Trước</a>
                            </li>
                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <li class="page-item ${currentPage == i ? 'active' : ''}">
                                    <a class="page-link" href="?action=list&page=${i}&keyword=${param.keyword}&type=${param.type}&ciId=${param.ciId}">${i}</a>
                                </li>
                            </c:forEach>
                            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                <a class="page-link" href="?action=list&page=${currentPage + 1}&keyword=${param.keyword}&type=${param.type}&ciId=${param.ciId}">Sau</a>
                            </li>
                        </ul>
                    </nav>
                </div>
            </c:if>

        </div>
    </div>
</div>

<script>
    function confirmDelete(id) {
        if (confirm('Bạn có chắc chắn muốn xóa nhật ký bảo trì này? Hành động này không thể hoàn tác.')) {
            window.location.href = '${pageContext.request.contextPath}/maintenance-log?action=delete&id=' + id;
        }
    }
</script>

<jsp:include page="/common/admin-layout-bottom.jsp" />
