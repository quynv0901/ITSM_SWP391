<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/includes/header.jsp" />

<div class="container-fluid py-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="mb-1 text-primary"><i class="bi bi-buildings"></i> Quản lý Nhà cung cấp</h2>
            <p class="text-muted mb-0">Thiết lập danh mục các đối tác, nhà cung cấp phần cứng, phần mềm.</p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/vendor?action=add" class="btn btn-primary shadow-sm">
                <i class="bi bi-plus-circle"></i> Thêm mới
            </a>
        </div>
    </div>

    <!-- Hiển thị thông báo -->
    <c:if test="${not empty param.success}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i>${param.success}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${not empty param.error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>${param.error}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <!-- Bộ lọc tìm kiếm -->
    <div class="card shadow-sm border-0 mb-4">
        <div class="card-body bg-light rounded">
            <form action="${pageContext.request.contextPath}/vendor" method="GET" class="row g-3 align-items-end">
                <div class="col-md-5">
                    <label class="form-label text-secondary fw-semibold">Tìm kiếm</label>
                    <div class="input-group">
                        <span class="input-group-text bg-white"><i class="bi bi-search text-muted"></i></span>
                        <input type="text" class="form-control border-start-0" name="keyword" 
                               placeholder="Tên, Email, SĐT hoặc Địa chỉ..." value="${keyword}">
                    </div>
                </div>
                <div class="col-md-4">
                    <label class="form-label text-secondary fw-semibold">Trạng thái</label>
                    <select name="status" class="form-select">
                        <option value="">Tất cả</option>
                        <option value="ACTIVE" ${status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                        <option value="INACTIVE" ${status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-primary w-100"><i class="bi bi-funnel"></i> Lọc dữ liệu</button>
                        <a href="${pageContext.request.contextPath}/vendor" class="btn btn-outline-secondary w-100"><i class="bi bi-x-circle"></i> Xóa bộ lọc</a>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <!-- Danh sách Vendor -->
    <div class="card shadow-sm border-0">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light text-secondary">
                        <tr>
                            <th class="ps-4">ID</th>
                            <th>Tên nhà cung cấp</th>
                            <th>Liên hệ</th>
                            <th>Địa chỉ</th>
                            <th>Trạng thái</th>
                            <th class="text-end pe-4">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty vendors}">
                                <tr>
                                    <td colspan="6" class="text-center py-5 text-muted">
                                        <i class="bi bi-inbox fs-1 d-block mb-3"></i>
                                        Không tìm thấy nhà cung cấp nào.
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="v" items="${vendors}">
                                    <tr>
                                        <td class="ps-4 fw-bold text-muted">#${v.vendorId}</td>
                                        <td>
                                            <span class="fw-semibold text-dark">${v.name}</span>
                                        </td>
                                        <td>
                                            <div class="small">
                                                <i class="bi bi-envelope text-secondary me-1"></i> ${v.contactEmail != null && v.contactEmail != '' ? v.contactEmail : 'N/A'}<br>
                                                <i class="bi bi-telephone text-secondary me-1"></i> ${v.contactPhone != null && v.contactPhone != '' ? v.contactPhone : 'N/A'}
                                            </div>
                                        </td>
                                        <td>
                                            <span class="text-truncate d-inline-block" style="max-width: 250px;" title="${v.address}">
                                                ${v.address != null && v.address != '' ? v.address : '---'}
                                            </span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${v.status == 'ACTIVE'}">
                                                    <span class="badge bg-success bg-opacity-10 text-success border border-success border-opacity-25 px-2 py-1">Active</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary bg-opacity-10 text-secondary border border-secondary border-opacity-25 px-2 py-1">Inactive</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-end pe-4">
                                            <a href="${pageContext.request.contextPath}/vendor?action=detail&id=${v.vendorId}" 
                                               class="btn btn-sm btn-outline-info" title="Xem chi tiết">
                                                <i class="bi bi-eye"></i>
                                            </a>
                                            <a href="${pageContext.request.contextPath}/vendor?action=edit&id=${v.vendorId}" 
                                               class="btn btn-sm btn-outline-primary ms-1" title="Chỉnh sửa">
                                                <i class="bi bi-pencil"></i>
                                            </a>
                                            <!-- Nút Toggle Active/Inactive -->
                                            <a href="${pageContext.request.contextPath}/vendor?action=toggle&id=${v.vendorId}" 
                                               class="btn btn-sm btn-outline-warning ms-1" 
                                               onclick="return confirm('Bạn có chắc muốn chuyển đổi trạng thái của nhà cung cấp này?');"
                                               title="Đổi trạng thái">
                                                <i class="bi bi-arrow-repeat"></i>
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />
