<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/includes/header.jsp" />

<div class="container-fluid py-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="mb-1 text-info"><i class="bi bi-building"></i> Chi tiết Nhà cung cấp</h2>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-0">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/vendor">Nhà cung cấp</a></li>
                    <li class="breadcrumb-item active" aria-current="page">${vendor.name}</li>
                </ol>
            </nav>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/vendor?action=edit&id=${vendor.vendorId}" class="btn btn-primary shadow-sm">
                <i class="bi bi-pencil"></i> Chỉnh sửa
            </a>
            <a href="${pageContext.request.contextPath}/vendor" class="btn btn-secondary shadow-sm ms-2">
                <i class="bi bi-arrow-left"></i> Quay lại
            </a>
        </div>
    </div>

    <!-- Thông tin tổng quan -->
    <div class="card shadow-sm border-0 mb-4">
        <div class="card-header bg-white py-3 border-bottom d-flex align-items-center">
            <h5 class="card-title fw-bold text-dark mb-0"><i class="bi bi-info-circle me-2 text-info"></i> Thông tin chung</h5>
            <div class="ms-auto">
                <c:choose>
                    <c:when test="${vendor.status == 'ACTIVE'}">
                        <span class="badge bg-success px-3 py-2 rounded-pill"><i class="bi bi-check-circle me-1"></i> Đang hợp tác</span>
                    </c:when>
                    <c:otherwise>
                        <span class="badge bg-secondary px-3 py-2 rounded-pill"><i class="bi bi-x-circle me-1"></i> Ngừng hợp tác</span>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
        <div class="card-body p-4">
            <div class="row g-4">
                <div class="col-md-6">
                    <div class="mb-3">
                        <small class="text-muted text-uppercase fw-semibold d-block mb-1">Tên Nhà Cung Cấp</small>
                        <div class="fs-5 fw-bold text-dark">${vendor.name}</div>
                    </div>
                </div>
                <div class="col-md-6"></div> <!-- Empty column for grid alignment -->

                <div class="col-md-6">
                    <div class="d-flex align-items-center">
                        <div class="bg-light rounded-circle p-3 d-flex align-items-center justify-content-center me-3" style="width: 50px; height: 50px;">
                            <i class="bi bi-envelope text-primary fs-4"></i>
                        </div>
                        <div>
                            <small class="text-muted text-uppercase fw-semibold d-block mb-1">Email Liên Hệ</small>
                            <span class="text-dark fw-medium">${vendor.contactEmail != null && vendor.contactEmail != '' ? vendor.contactEmail : 'Chưa cập nhật'}</span>
                        </div>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="d-flex align-items-center">
                        <div class="bg-light rounded-circle p-3 d-flex align-items-center justify-content-center me-3" style="width: 50px; height: 50px;">
                            <i class="bi bi-telephone text-success fs-4"></i>
                        </div>
                        <div>
                            <small class="text-muted text-uppercase fw-semibold d-block mb-1">Số Điện Thoại</small>
                            <span class="text-dark fw-medium">${vendor.contactPhone != null && vendor.contactPhone != '' ? vendor.contactPhone : 'Chưa cập nhật'}</span>
                        </div>
                    </div>
                </div>

                <div class="col-md-12 mt-4">
                    <div class="d-flex align-items-start">
                        <div class="bg-light rounded-circle p-3 d-flex align-items-center justify-content-center me-3" style="width: 50px; height: 50px;">
                            <i class="bi bi-geo-alt text-danger fs-4"></i>
                        </div>
                        <div>
                            <small class="text-muted text-uppercase fw-semibold d-block mb-1">Địa Chỉ Văn Phòng</small>
                            <span class="text-dark fw-medium">${vendor.address != null && vendor.address != '' ? vendor.address : 'Chưa cập nhật'}</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Danh sách thiết bị (CI) -->
    <div class="card shadow-sm border-0 border-top border-info border-3">
        <div class="card-header bg-white py-3 border-bottom">
            <h5 class="card-title fw-bold text-dark mb-0">
                <i class="bi bi-pc-display-horizontal me-2 text-info"></i> Các thiết bị thuộc quản lý
                <span class="badge bg-info text-white ms-2 rounded-pill">${vendorCIs.size()}</span>
            </h5>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light text-secondary">
                        <tr>
                            <th class="ps-4">ID</th>
                            <th>Tên Thiết Bị / Cấu Hình</th>
                            <th>Phân Loại</th>
                            <th>Phiên Bản</th>
                            <th>Trạng Thái</th>
                            <th class="text-end pe-4">Chi Tiết Cấu Hình</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty vendorCIs}">
                                <tr>
                                    <td colspan="6" class="text-center py-5">
                                        <div class="text-muted">
                                            <i class="bi bi-pc-display fs-1 d-block mb-3 opacity-50"></i>
                                            <span class="fs-6">Hiện tại chưa có thiết bị nào được gắn với nhà cung cấp này.</span><br>
                                            <a href="${pageContext.request.contextPath}/configuration-item?action=add&vendorId=${vendor.vendorId}" class="btn btn-sm btn-outline-info mt-3">
                                                <i class="bi bi-plus-circle"></i> Thêm cấu hình mới
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="ci" items="${vendorCIs}">
                                    <tr>
                                        <td class="ps-4 fw-bold text-muted">CI-${ci.ciId}</td>
                                        <td>
                                            <div class="fw-semibold text-dark">${ci.name}</div>
                                            <small class="text-muted text-truncate d-inline-block" style="max-width: 250px;">${ci.description}</small>
                                        </td>
                                        <td>
                                            <!-- Icon theo type -->
                                            <c:choose>
                                                <c:when test="${ci.type == 'Hardware'}"><i class="bi bi-hdd text-secondary me-1"></i> Phần cứng</c:when>
                                                <c:when test="${ci.type == 'Software'}"><i class="bi bi-window text-primary me-1"></i> Phần mềm</c:when>
                                                <c:when test="${ci.type == 'Network'}"><i class="bi bi-router text-success me-1"></i> Mạng</c:when>
                                                <c:when test="${ci.type == 'Service'}"><i class="bi bi-cloud text-info me-1"></i> Dịch vụ</c:when>
                                                <c:otherwise><i class="bi bi-hdd-stack text-secondary me-1"></i> Khác</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>${ci.version != null && ci.version != '' ? ci.version : '-'}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${ci.status == 'ACTIVE'}"><span class="badge bg-success bg-opacity-10 text-success border border-success border-opacity-25 px-2 py-1">Đang hoạt động</span></c:when>
                                                <c:when test="${ci.status == 'INACTIVE'}"><span class="badge bg-warning bg-opacity-10 text-warning border border-warning border-opacity-25 px-2 py-1">Tạm ngưng</span></c:when>
                                                <c:otherwise><span class="badge bg-secondary bg-opacity-10 text-secondary border border-secondary border-opacity-25 px-2 py-1">Đã loại bỏ</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-end pe-4">
                                            <a href="${pageContext.request.contextPath}/configuration-item?action=detail&id=${ci.ciId}" 
                                               class="btn btn-sm btn-outline-info" title="Xem chi tiết thiết bị">
                                                <i class="bi bi-arrow-up-right-square"></i> Xem
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
