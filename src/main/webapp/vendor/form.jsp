<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/includes/header.jsp" />

<div class="container-fluid py-4">
    <!-- Nút Quay lại -->
    <div class="mb-3">
        <a href="${pageContext.request.contextPath}/vendor" class="text-decoration-none text-muted">
            <i class="bi bi-arrow-left"></i> Quay lại Danh sách
        </a>
    </div>

    <!-- Tiêu đề trang -->
    <div class="mb-4">
        <h2 class="mb-1 text-primary">
            <i class="bi ${vendor != null && vendor.vendorId > 0 ? 'bi-pencil-square' : 'bi-plus-circle'}"></i> 
            ${vendor != null && vendor.vendorId > 0 ? 'Chỉnh sửa Nhà cung cấp' : 'Thêm Nhà cung cấp Mới'}
        </h2>
        <p class="text-muted">Nhập thông tin chi tiết của đối tác cung cấp tài sản/dịch vụ IT.</p>
    </div>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger shadow-sm border-0 border-start border-4 border-danger fade show mb-4">
            <i class="bi bi-exclamation-octagon-fill me-2 text-danger"></i>${errorMessage}
        </div>
    </c:if>

    <div class="row">
        <!-- Main Form Column -->
        <div class="col-lg-8">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white py-3">
                    <h5 class="card-title mb-0 fw-bold">Thông tin chung</h5>
                </div>
                <div class="card-body p-4">
                    <form action="${pageContext.request.contextPath}/vendor" method="POST" id="vendorForm">
                        <input type="hidden" name="action" value="save">
                        <input type="hidden" name="vendorId" value="${vendor != null ? vendor.vendorId : ''}">

                        <div class="mb-4">
                            <label for="name" class="form-label fw-semibold">Tên Nhà cung cấp <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text bg-light"><i class="bi bi-buildings"></i></span>
                                <input type="text" class="form-control" id="name" name="name" 
                                       value="${vendor != null ? vendor.name : ''}" required
                                       placeholder="Ví dụ: Dell Technologies, FPT Shop, Microsoft...">
                            </div>
                            <div class="form-text">Nhập tên đầy đủ của đơn vị đối tác.</div>
                        </div>

                        <div class="row mb-4">
                            <div class="col-md-6">
                                <label for="contactEmail" class="form-label fw-semibold">Email Liên hệ</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light"><i class="bi bi-envelope"></i></span>
                                    <input type="email" class="form-control" id="contactEmail" name="contactEmail" 
                                           value="${vendor != null ? vendor.contactEmail : ''}"
                                           placeholder="contact@domain.com">
                                </div>
                            </div>
                            <div class="col-md-6 mt-3 mt-md-0">
                                <label for="contactPhone" class="form-label fw-semibold">Số điện thoại</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light"><i class="bi bi-telephone"></i></span>
                                    <input type="text" class="form-control" id="contactPhone" name="contactPhone" 
                                           value="${vendor != null ? vendor.contactPhone : ''}"
                                           placeholder="09xx.xxx.xxx">
                                </div>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label for="address" class="form-label fw-semibold">Địa chỉ</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light"><i class="bi bi-geo-alt"></i></span>
                                <input type="text" class="form-control" id="address" name="address" 
                                       value="${vendor != null ? vendor.address : ''}"
                                       placeholder="Số nhà, đường, Quận, Thành phố...">
                            </div>
                        </div>
                        
                        <div class="mb-4">
                            <label for="status" class="form-label fw-semibold">Trạng thái (Tùy chọn)</label>
                            <select class="form-select" id="status" name="status">
                                <option value="ACTIVE" ${vendor != null && vendor.status == 'ACTIVE' ? 'selected' : ''}>Hoạt động (Active)</option>
                                <option value="INACTIVE" ${vendor != null && vendor.status == 'INACTIVE' ? 'selected' : ''}>Ngừng hoạt động (Inactive)</option>
                            </select>
                        </div>

                    </form>
                </div>
                <div class="card-footer bg-light px-4 py-3 text-end">
                    <a href="${pageContext.request.contextPath}/vendor" class="btn btn-light border me-2 shadow-sm">
                        Hủy bỏ
                    </a>
                    <button type="submit" form="vendorForm" class="btn btn-primary px-4 shadow-sm">
                        <i class="bi bi-save me-1"></i> Lưu thông tin
                    </button>
                </div>
            </div>
        </div>
        
        <!-- Sidebar Column (Hướng dẫn) -->
        <div class="col-lg-4 mt-4 mt-lg-0">
            <div class="card shadow-sm border-0 bg-light">
                <div class="card-body">
                    <h5 class="fw-bold mb-3"><i class="bi bi-info-circle text-primary"></i> Hướng dẫn nhập liệu</h5>
                    <p class="text-secondary small mb-3">
                        Danh mục <strong>Nhà cung cấp</strong> hỗ trợ việc theo dõi và quản lý xuất xứ của các thiết bị (Configuration Items - CMDB) và dịch vụ liên quan.
                    </p>
                    <ul class="text-secondary small ps-3 mb-0">
                        <li class="mb-2"><strong>Tên Nhà cung cấp:</strong> Là trường bắt buộc, điền chính xác tên doanh nghiệp.</li>
                        <li class="mb-2"><strong>Email / SĐT:</strong> Nên điền thông tin của bộ phận Sale / Hỗ trợ kỹ thuật trực tiếp để tiện bảo hành.</li>
                        <li><strong>Trạng thái Inactive:</strong> Sẽ ẩn đối tác này khỏi danh sách chọn khi tạo mới Thiết bị trong CMDB.</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />
