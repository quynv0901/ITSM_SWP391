<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/includes/header.jsp" />
<c:set var="currentUser" value="${sessionScope.user}" />
<c:set var="roleId" value="${currentUser.roleId}" />
<c:set var="isAdmin" value="${roleId == 10}" />

<style>
    .field-error{
        font-size:.875rem;
        color:#dc3545;
        margin-top:6px;
    }
</style>

<div class="container-fluid bg-white p-4 rounded shadow-sm">
    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
        <h2 class="h4 text-primary m-0"><i class="bi bi-hdd-network me-2"></i>Quản lý dịch vụ</h2>
        <div class="d-flex gap-2 flex-wrap">
            <c:if test="${isAdmin}">
                <button type="button" class="btn btn-secondary" onclick="submitBulkAction('INACTIVE')">
                    Ngừng kích hoạt hàng loạt
                </button>
                <button type="button" class="btn btn-success" onclick="submitBulkAction('ACTIVE')">
                    Kích hoạt hàng loạt
                </button>
            </c:if>
            <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createServiceModal">
                Tạo dịch vụ mới
            </button>
        </div>
    </div>

    <form action="${pageContext.request.contextPath}/admin-services" method="get" accept-charset="UTF-8" class="row g-3 mb-4 bg-light p-3 rounded border mx-0">
        <input type="hidden" name="action" value="list">
        <div class="col-md-5"><input type="text" name="q" class="form-control" placeholder="Tìm theo tên dịch vụ, mã dịch vụ hoặc mô tả..." value="${keyword}"></div>
        <div class="col-md-3">
            <select name="status" class="form-select">
                <option value="">Tất cả trạng thái</option>
                <option value="ACTIVE" ${status eq 'ACTIVE' ? 'selected' : ''}>Đang hoạt động</option>
                <option value="INACTIVE" ${status eq 'INACTIVE' ? 'selected' : ''}>Ngừng hoạt động</option>
            </select>
        </div>
        <div class="col-md-4 d-flex gap-2">
            <button type="submit" class="btn btn-primary"><i class="bi bi-search"></i> Tìm kiếm</button>
            <a href="${pageContext.request.contextPath}/admin-services" class="btn btn-outline-secondary"><i class="bi bi-x-circle"></i> Xóa lọc</a>
        </div>
    </form>

    <form id="bulkForm" method="post" action="${pageContext.request.contextPath}/admin-services">
        <input type="hidden" name="action" id="bulkAction" value="">
        <input type="hidden" name="newStatus" id="newStatus" value="">
        <div class="table-responsive">
            <table class="table table-hover table-bordered align-middle mt-3">
                <thead class="table-light">
                    <tr>
                        <th style="width:40px;" class="text-center">
                            <c:if test="${isAdmin}">
                                <input type="checkbox" onclick="toggleAll(this)">
                            </c:if>
                        </th>
                        <th>Mã dịch vụ</th>
                        <th>Tên dịch vụ</th>
                        <th>Mô tả</th>
                        <th>Số ngày dự kiến</th>
                        <th>Trạng thái</th>
                        <th class="text-center">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="svc" items="${services}">
                        <tr>
                            <td class="text-center">
                                <c:if test="${isAdmin}">
                                    <input type="checkbox" name="serviceIds" value="${svc.serviceId}" class="rowCheckbox form-check-input">
                                </c:if>
                            </td>
                            <td><strong>${svc.serviceCode}</strong></td>
                            <td class="text-primary fw-bold">${svc.serviceName}</td>
                            <td>${svc.description}</td>
                            <td>${svc.estimatedDeliveryDay}</td>
                            <td><span class="badge ${svc.status == 'ACTIVE' ? 'bg-success' : 'bg-secondary'}">${svc.status == 'ACTIVE' ? 'Đang hoạt động' : 'Ngừng hoạt động'}</span></td>
                            <td class="text-center">
                                <div class="d-flex justify-content-center gap-1 flex-wrap">

                                    <!-- AI CŨNG ĐƯỢC XEM -->
                                    <a href="${pageContext.request.contextPath}/admin-services?action=detail&id=${svc.serviceId}"
                                       class="btn btn-info btn-sm text-white">
                                        <i class="bi bi-eye"></i>
                                    </a>

                                    <!-- CHỈ ADMIN -->
                                    <c:if test="${isAdmin}">
                                        <a href="${pageContext.request.contextPath}/admin-services?action=edit&id=${svc.serviceId}"
                                           class="btn btn-warning btn-sm text-white">
                                            <i class="bi bi-pencil"></i>
                                        </a>

                                        <button type="button"
                                                class="btn btn-${svc.status == 'ACTIVE' ? 'secondary' : 'success'} btn-sm"
                                                onclick="toggleOne('${svc.serviceId}')">
                                            <i class="bi ${svc.status == 'ACTIVE' ? 'bi-pause-circle' : 'bi-play-circle'}"></i>
                                        </button>

                                        <button type="button"
                                                class="btn btn-danger btn-sm"
                                                onclick="confirmDeleteOne('${svc.serviceId}')">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </c:if>

                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty services}">
                        <tr><td colspan="7" class="text-center text-muted fst-italic py-4">Không có dịch vụ nào.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </form>

    <div class="d-flex justify-content-between align-items-center mt-4 flex-wrap gap-2">
        <div class="text-muted">Tổng số: ${totalItems} bản ghi</div>
        <nav>
            <ul class="pagination mb-0">

                <c:set var="baseUrl" value="${roleId == 1 ? '/service-catalog' : '/admin-services'}" />

                <!-- PREV -->
                <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                    <a class="page-link"
                       href="${pageContext.request.contextPath}${baseUrl}?page=${currentPage - 1}&q=${keyword}&status=${status}">
                        Trước
                    </a>
                </li>

                <!-- PAGE NUMBER -->
                <c:forEach begin="1" end="${totalPages}" var="p">
                    <li class="page-item ${p == currentPage ? 'active' : ''}">
                        <a class="page-link"
                           href="${pageContext.request.contextPath}${baseUrl}?page=${p}&q=${keyword}&status=${status}">
                            ${p}
                        </a>
                    </li>
                </c:forEach>

                <!-- NEXT -->
                <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                    <a class="page-link"
                       href="${pageContext.request.contextPath}${baseUrl}?page=${currentPage + 1}&q=${keyword}&status=${status}">
                        Sau
                    </a>
                </li>

            </ul>
        </nav>
    </div>
</div>

<div class="modal fade" id="createServiceModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg"><div class="modal-content">
            <form method="post" action="${pageContext.request.contextPath}/admin-services" accept-charset="UTF-8" onsubmit="return validateCreateServiceForm();" novalidate>
                <input type="hidden" name="action" value="create">
                <div class="modal-header"><h5 class="modal-title">Tạo dịch vụ mới</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
                <div class="modal-body row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Tên dịch vụ</label>
                        <input type="text" id="createServiceName" name="serviceName" class="form-control" value="${openModal eq 'create' ? selectedService.serviceName : ''}">
                        <div class="field-error" id="createServiceNameError"></div>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Mã dịch vụ</label>
                        <input type="text" id="createServiceCode" name="serviceCode" class="form-control" value="${openModal eq 'create' ? selectedService.serviceCode : ''}">
                        <div class="field-error" id="createServiceCodeError"></div>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Số ngày dự kiến</label>
                        <input type="number" id="createEstimatedDeliveryDay" min="0" name="estimatedDeliveryDay" class="form-control" value="${openModal eq 'create' ? selectedService.estimatedDeliveryDay : ''}">
                        <div class="field-error" id="createEstimatedDeliveryDayError"></div>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Trạng thái</label>
                        <select name="status" class="form-select">
                            <option value="ACTIVE">Đang hoạt động</option>
                            <option value="INACTIVE" ${openModal eq 'create' && selectedService.status eq 'INACTIVE' ? 'selected' : ''}>Ngừng hoạt động</option>
                        </select>
                    </div>
                    <div class="col-12">
                        <label class="form-label">Mô tả</label>
                        <textarea id="createDescription" name="description" rows="4" class="form-control">${openModal eq 'create' ? selectedService.description : ''}</textarea>
                    </div>
                </div>
                <div class="modal-footer"><button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Đóng</button><button type="submit" class="btn btn-primary">Tạo mới</button></div>
            </form>
        </div></div>
</div>  

<c:if test="${isAdmin}">

    <div class="modal fade" id="editServiceModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg"><div class="modal-content">
                <form method="post" action="${pageContext.request.contextPath}/admin-services" accept-charset="UTF-8" onsubmit="return validateEditServiceForm();" novalidate>
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="serviceId" value="${selectedService.serviceId}">
                    <div class="modal-header"><h5 class="modal-title">Cập nhật dịch vụ</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
                    <div class="modal-body row g-3">
                        <div class="col-md-6">
                            <label class="form-label">Tên dịch vụ</label>
                            <input type="text" id="editServiceName" name="serviceName" class="form-control" value="${selectedService.serviceName}">
                            <div class="field-error" id="editServiceNameError"></div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Mã dịch vụ</label>
                            <input type="text" id="editServiceCode" name="serviceCode" class="form-control" value="${selectedService.serviceCode}">
                            <div class="field-error" id="editServiceCodeError"></div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Số ngày dự kiến</label>
                            <input type="number" id="editEstimatedDeliveryDay" min="0" name="estimatedDeliveryDay" class="form-control" value="${selectedService.estimatedDeliveryDay}">
                            <div class="field-error" id="editEstimatedDeliveryDayError"></div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Trạng thái</label>
                            <select name="status" class="form-select">
                                <option value="ACTIVE" ${selectedService.status eq 'ACTIVE' ? 'selected' : ''}>Đang hoạt động</option>
                                <option value="INACTIVE" ${selectedService.status eq 'INACTIVE' ? 'selected' : ''}>Ngừng hoạt động</option>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Mô tả</label>
                            <textarea id="editDescription" name="description" rows="4" class="form-control">${selectedService.description}</textarea>
                        </div>
                    </div>
                    <div class="modal-footer"><button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Đóng</button><button type="submit" class="btn btn-warning text-white">Cập nhật</button></div>
                </form>
            </div></div>
    </div>
</c:if>



<div class="modal fade" id="detailServiceModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg"><div class="modal-content">
            <div class="modal-header"><h5 class="modal-title">Chi tiết dịch vụ</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <c:if test="${not empty selectedService}">
                    <div class="row g-3">
                        <div class="col-md-6"><label class="form-label fw-bold">Mã dịch vụ</label><div class="form-control bg-light">${selectedService.serviceCode}</div></div>
                        <div class="col-md-6"><label class="form-label fw-bold">Tên dịch vụ</label><div class="form-control bg-light">${selectedService.serviceName}</div></div>
                        <div class="col-md-6"><label class="form-label fw-bold">Số ngày dự kiến</label><div class="form-control bg-light">${selectedService.estimatedDeliveryDay}</div></div>
                        <div class="col-md-6"><label class="form-label fw-bold">Trạng thái</label><div class="form-control bg-light">${selectedService.status eq 'ACTIVE' ? 'Đang hoạt động' : 'Ngừng hoạt động'}</div></div>
                        <div class="col-12"><label class="form-label fw-bold">Mô tả</label><div class="form-control bg-light" style="min-height:120px;">${selectedService.description}</div></div>
                    </div>
                </c:if>
            </div>
            <div class="modal-footer"><button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Đóng</button></div>
        </div></div>
</div>

<script>
    function toggleAll(source) {
        document.querySelectorAll('.rowCheckbox').forEach(cb => cb.checked = source.checked);
    }
    function clearErr(id) {
        document.getElementById(id).textContent = '';
    }
    function setErr(id, msg) {
        document.getElementById(id).textContent = msg;
    }
    function validateServiceFields(prefix) {
        let valid = true;
        ['ServiceNameError', 'ServiceCodeError', 'EstimatedDeliveryDayError'].forEach(s => clearErr(prefix + s));
        const serviceName = document.getElementById(prefix + 'ServiceName').value.trim();
        const serviceCode = document.getElementById(prefix + 'ServiceCode').value.trim();
        const estimatedDeliveryDay = document.getElementById(prefix + 'EstimatedDeliveryDay').value.trim();
        if (!serviceName) {
            setErr(prefix + 'ServiceNameError', 'Tên dịch vụ không được để trống.');
            valid = false;
        }
        if (!serviceCode) {
            setErr(prefix + 'ServiceCodeError', 'Mã dịch vụ không được để trống.');
            valid = false;
        } else if (!/^[A-Za-z0-9._-]+$/.test(serviceCode)) {
            setErr(prefix + 'ServiceCodeError', 'Mã dịch vụ chỉ được chứa chữ, số, dấu gạch ngang, gạch dưới và dấu chấm.');
            valid = false;
        }
        if (!estimatedDeliveryDay) {
            setErr(prefix + 'EstimatedDeliveryDayError', 'Số ngày dự kiến không được để trống.');
            valid = false;
        } else if (!/^\d+$/.test(estimatedDeliveryDay)) {
            setErr(prefix + 'EstimatedDeliveryDayError', 'Số ngày dự kiến phải là số nguyên không âm.');
            valid = false;
        }
        return valid;
    }
    function validateCreateServiceForm() {
        return validateServiceFields('create');
    }
    function validateEditServiceForm() {
        return validateServiceFields('edit');
    }
    function submitBulkAction(actionType) {
        const checkboxes = document.querySelectorAll('.rowCheckbox:checked');
        if (checkboxes.length === 0) {
            alert('Vui lòng chọn ít nhất một dịch vụ.');
            return;
        }
        if (confirm('Bạn có muốn cập nhật trạng thái cho các dịch vụ đã chọn không?')) {
            document.getElementById('bulkAction').value = 'bulkStatus';
            document.getElementById('newStatus').value = actionType;
            document.getElementById('bulkForm').submit();
        }
    }
    function toggleOne(id) {
        if (confirm('Bạn có muốn thay đổi trạng thái của dịch vụ này không?')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/admin-services';
            form.innerHTML = '<input type="hidden" name="action" value="toggleStatus"><input type="hidden" name="serviceId" value="' + id + '">';
            document.body.appendChild(form);
            form.submit();
        }
    }
    function confirmDeleteOne(id) {
        if (confirm('Bạn có chắc chắn muốn xóa dịch vụ này không?')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/admin-services';
            form.innerHTML = '<input type="hidden" name="action" value="delete"><input type="hidden" name="serviceId" value="' + id + '">';
            document.body.appendChild(form);
            form.submit();
        }
    }
    document.addEventListener('DOMContentLoaded', function () {
        const openModal = '${openModal}';
        if (openModal === 'detail')
            new bootstrap.Modal(document.getElementById('detailServiceModal')).show();
        if (openModal === 'create')
            new bootstrap.Modal(document.getElementById('createServiceModal')).show();
        if (openModal === 'edit')
            new bootstrap.Modal(document.getElementById('editServiceModal')).show();
    });
</script>

<jsp:include page="/includes/footer.jsp" />
