<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/includes/header.jsp" />

<c:set var="currentUser" value="${sessionScope.user}" />
<c:set var="roleId" value="${currentUser.roleId}" />
<c:set var="isAdmin" value="${roleId == 10}" />
<c:set var="isEndUser" value="${roleId == 1}" />

<div class="container-fluid bg-white p-4 rounded shadow-sm">
    <c:if test="${not empty param.msg}">
        <div class="alert alert-info alert-dismissible fade show" role="alert">
            <c:choose>
                <c:when test="${param.msg eq 'created'}">Tạo dịch vụ thành công.</c:when>
                <c:when test="${param.msg eq 'updated'}">Cập nhật dịch vụ thành công.</c:when>
                <c:when test="${param.msg eq 'deleted'}">Xóa dịch vụ thành công.</c:when>
                <c:when test="${param.msg eq 'cannot_delete'}">Không thể xóa dịch vụ này vì đã được sử dụng trong phiếu yêu cầu.</c:when>
                <c:when test="${param.msg eq 'not_found'}">Không tìm thấy dịch vụ.</c:when>
                <c:when test="${param.msg eq 'status_updated'}">Cập nhật trạng thái dịch vụ thành công.</c:when>
                <c:when test="${param.msg eq 'bulk_updated'}">Cập nhật hàng loạt thành công. Số bản ghi đã cập nhật: ${param.count}</c:when>
                <c:otherwise>Thao tác đã được thực hiện.</c:otherwise>
            </c:choose>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            ${errorMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
        <h2 class="h4 text-primary m-0">
            <i class="bi bi-hdd-network me-2"></i>
            ${isAdmin ? 'Quản lý dịch vụ' : 'Danh mục dịch vụ'}
        </h2>

        <c:if test="${isAdmin}">
            <div class="d-flex gap-2 flex-wrap">
                <button type="button" class="btn btn-secondary" onclick="submitBulkAction('INACTIVE')">
                    <i class="bi bi-pause-circle"></i> Ngừng kích hoạt hàng loạt
                </button>
                <button type="button" class="btn btn-success" onclick="submitBulkAction('ACTIVE')">
                    <i class="bi bi-play-circle"></i> Kích hoạt hàng loạt
                </button>
                <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createServiceModal">
                    <i class="bi bi-plus-circle"></i> Tạo dịch vụ mới
                </button>
            </div>
        </c:if>
    </div>

    <form action="${pageContext.request.contextPath}${isAdmin ? '/admin-services' : '/service-catalog'}"
          method="get"
          accept-charset="UTF-8"
          class="row g-3 mb-4 bg-light p-3 rounded border mx-0">
        <input type="hidden" name="action" value="list">

        <div class="${isAdmin ? 'col-md-5' : 'col-md-8'}">
            <input type="text" name="q" class="form-control"
                   placeholder="Tìm theo tên dịch vụ, mã dịch vụ hoặc mô tả..."
                   value="${keyword}">
        </div>

        <c:if test="${isAdmin}">
            <div class="col-md-3">
                <select name="status" class="form-select">
                    <option value="">Tất cả trạng thái</option>
                    <option value="ACTIVE" ${status eq 'ACTIVE' ? 'selected' : ''}>Đang hoạt động</option>
                    <option value="INACTIVE" ${status eq 'INACTIVE' ? 'selected' : ''}>Ngừng hoạt động</option>
                </select>
            </div>
        </c:if>

        <div class="${isAdmin ? 'col-md-4' : 'col-md-4'} d-flex gap-2">
            <button type="submit" class="btn btn-primary">
                <i class="bi bi-search"></i> Tìm kiếm
            </button>
            <a href="${pageContext.request.contextPath}${isAdmin ? '/admin-services' : '/service-catalog'}"
               class="btn btn-outline-secondary">
                <i class="bi bi-x-circle"></i> Xóa lọc
            </a>
        </div>
    </form>

    <form id="bulkForm" method="post" action="${pageContext.request.contextPath}/admin-services">
        <input type="hidden" name="action" id="bulkAction" value="">
        <input type="hidden" name="newStatus" id="newStatus" value="">

        <div class="table-responsive">
            <table class="table table-hover table-bordered align-middle mt-3">
                <thead class="table-light">
                    <tr>
                        <c:if test="${isAdmin}">
                            <th style="width: 40px;" class="text-center">
                                <input type="checkbox" id="selectAll" class="form-check-input" onclick="toggleAll(this)">
                            </th>
                        </c:if>
                        <th>Mã dịch vụ</th>
                        <th>Tên dịch vụ</th>
                        <th>Mô tả</th>
                        <th>Thời gian</th>
                        <c:if test="${isAdmin}">
                            <th>Trạng thái</th>
                        </c:if>
                        <th class="text-center">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="svc" items="${services}">
                        <tr>
                            <c:if test="${isAdmin}">
                                <td class="text-center">
                                    <input type="checkbox" name="serviceIds" value="${svc.serviceId}"
                                           class="rowCheckbox form-check-input">
                                </td>
                            </c:if>

                            <td><strong>${svc.serviceCode}</strong></td>
                            <td class="text-primary fw-bold">${svc.serviceName}</td>
                            <td class="text-muted"
                                style="max-width: 280px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                ${svc.description}
                            </td>
                            <td>${svc.estimatedDeliveryDay} ngày</td>

                            <c:if test="${isAdmin}">
                                <td>
                                    <span class="badge ${svc.status == 'ACTIVE' ? 'bg-success' : 'bg-secondary'}">
                                        ${svc.status == 'ACTIVE' ? 'Đang hoạt động' : 'Ngừng hoạt động'}
                                    </span>
                                </td>
                            </c:if>

                            <td class="text-center">
                                <div class="d-flex justify-content-center gap-1 flex-wrap">
                                    <a href="${pageContext.request.contextPath}${isAdmin ? '/admin-services' : '/service-catalog'}?action=detail&id=${svc.serviceId}&q=${keyword}${isAdmin ? '&status='.concat(status) : ''}"
                                       class="btn btn-info btn-sm text-white"
                                       title="Xem chi tiết">
                                        <i class="bi bi-eye"></i>
                                    </a>

                                    <c:if test="${isAdmin}">
                                        <a href="${pageContext.request.contextPath}/admin-services?action=edit&id=${svc.serviceId}&q=${keyword}&status=${status}"
                                           class="btn btn-warning btn-sm text-white"
                                           title="Sửa dịch vụ">
                                            <i class="bi bi-pencil"></i>
                                        </a>

                                        <button type="button"
                                                class="btn btn-${svc.status == 'ACTIVE' ? 'secondary' : 'success'} btn-sm"
                                                title="${svc.status == 'ACTIVE' ? 'Ngừng hoạt động' : 'Kích hoạt'}"
                                                onclick="toggleOne('${svc.serviceId}')">
                                            <i class="bi ${svc.status == 'ACTIVE' ? 'bi-pause-circle' : 'bi-play-circle'}"></i>
                                        </button>

                                        <button type="button"
                                                class="btn btn-danger btn-sm"
                                                title="Xóa dịch vụ"
                                                onclick="confirmDeleteOne('${svc.serviceId}')">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </c:if>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty services}">
                        <tr>
                            <td colspan="${isAdmin ? 7 : 5}" class="text-center text-muted fst-italic py-4">
                                <i class="bi bi-inbox fs-4 d-block mb-2"></i>
                                Không có dịch vụ nào.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </form>
</div>

<c:if test="${isAdmin}">
    <div class="modal fade" id="createServiceModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <form method="post"
                      action="${pageContext.request.contextPath}/admin-services"
                      accept-charset="UTF-8"
                      onsubmit="return validateCreateServiceForm();">
                    <input type="hidden" name="action" value="create">

                    <div class="modal-header">
                        <h5 class="modal-title">Tạo dịch vụ mới</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>

                    <div class="modal-body row g-3">
                        <div class="col-12">
                            <div id="createErrorMessage" class="alert alert-danger d-none mb-0"></div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Tên dịch vụ</label>
                            <input type="text" id="createServiceName" name="serviceName" class="form-control"
                                   maxlength="255"
                                   value="${openModal eq 'create' ? selectedService.serviceName : ''}" required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Mã dịch vụ</label>
                            <input type="text" id="createServiceCode" name="serviceCode" class="form-control"
                                   maxlength="50"
                                   value="${openModal eq 'create' ? selectedService.serviceCode : ''}" required>
                            <div class="form-text">Chỉ được nhập chữ cái, số, dấu gạch ngang (-), gạch dưới (_) và dấu chấm (.). Tối đa 50 ký tự.</div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Số ngày dự kiến</label>
                            <input type="number" id="createEstimatedDeliveryDay" min="0" name="estimatedDeliveryDay" class="form-control"
                                   value="${openModal eq 'create' ? selectedService.estimatedDeliveryDay : ''}" required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Trạng thái</label>
                            <select name="status" class="form-select">
                                <option value="ACTIVE"
                                    ${openModal eq 'create' && selectedService.status eq 'INACTIVE' ? '' : 'selected'}>Đang hoạt động</option>
                                <option value="INACTIVE"
                                    ${openModal eq 'create' && selectedService.status eq 'INACTIVE' ? 'selected' : ''}>Ngừng hoạt động</option>
                            </select>
                        </div>

                        <div class="col-12">
                            <label class="form-label">Mô tả</label>
                            <textarea id="createDescription" name="description" rows="4" class="form-control" maxlength="2000">${openModal eq 'create' ? selectedService.description : ''}</textarea>
                        </div>
                    </div>

                    <div class="modal-footer">
                        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Đóng</button>
                        <button type="submit" class="btn btn-primary">Tạo mới</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="modal fade" id="editServiceModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <form method="post"
                      action="${pageContext.request.contextPath}/admin-services"
                      accept-charset="UTF-8"
                      onsubmit="return validateEditServiceForm();">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="serviceId" value="${selectedService.serviceId}">

                    <div class="modal-header">
                        <h5 class="modal-title">Cập nhật dịch vụ</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>

                    <div class="modal-body row g-3">
                        <div class="col-12">
                            <div id="editErrorMessage" class="alert alert-danger d-none mb-0"></div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Tên dịch vụ</label>
                            <input type="text" id="editServiceName" name="serviceName" class="form-control"
                                   maxlength="255"
                                   value="${selectedService.serviceName}" required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Mã dịch vụ</label>
                            <input type="text" id="editServiceCode" name="serviceCode" class="form-control"
                                   maxlength="50"
                                   value="${selectedService.serviceCode}" required>
                            <div class="form-text">Chỉ được nhập chữ cái, số, dấu gạch ngang (-), gạch dưới (_) và dấu chấm (.). Tối đa 50 ký tự.</div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Số ngày dự kiến</label>
                            <input type="number" id="editEstimatedDeliveryDay" min="0" name="estimatedDeliveryDay" class="form-control"
                                   value="${selectedService.estimatedDeliveryDay}" required>
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
                            <textarea id="editDescription" name="description" rows="4" class="form-control" maxlength="2000">${selectedService.description}</textarea>
                        </div>
                    </div>

                    <div class="modal-footer">
                        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Đóng</button>
                        <button type="submit" class="btn btn-warning text-white">Cập nhật</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</c:if>

<div class="modal fade" id="detailServiceModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Chi tiết dịch vụ</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body">
                <c:if test="${not empty selectedService}">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Mã dịch vụ</label>
                            <div class="form-control bg-light">${selectedService.serviceCode}</div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-bold">Tên dịch vụ</label>
                            <div class="form-control bg-light">${selectedService.serviceName}</div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-bold">Số ngày dự kiến</label>
                            <div class="form-control bg-light">${selectedService.estimatedDeliveryDay}</div>
                        </div>

                        <c:if test="${isAdmin}">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Trạng thái</label>
                                <div class="form-control bg-light">
                                    ${selectedService.status eq 'ACTIVE' ? 'Đang hoạt động' : 'Ngừng hoạt động'}
                                </div>
                            </div>
                        </c:if>

                        <div class="col-12">
                            <label class="form-label fw-bold">Mô tả</label>
                            <div class="form-control bg-light" style="min-height: 120px;">
                                ${selectedService.description}
                            </div>
                        </div>
                    </div>
                </c:if>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<script>
    function toggleAll(source) {
        const checkboxes = document.getElementsByClassName('rowCheckbox');
        for (let i = 0; i < checkboxes.length; i++) {
            if (!checkboxes[i].disabled) {
                checkboxes[i].checked = source.checked;
            }
        }
    }

    function showFormError(elementId, message) {
        const box = document.getElementById(elementId);
        box.textContent = message;
        box.classList.remove('d-none');
    }

    function clearFormError(elementId) {
        const box = document.getElementById(elementId);
        box.textContent = '';
        box.classList.add('d-none');
    }

    function validateServiceFields(serviceName, serviceCode, estimatedDeliveryDay, errorElementId) {
        clearFormError(errorElementId);

        if (!serviceName) {
            showFormError(errorElementId, 'Tên dịch vụ không được để trống.');
            return false;
        }

        if (serviceName.length > 255) {
            showFormError(errorElementId, 'Tên dịch vụ không được vượt quá 255 ký tự.');
            return false;
        }

        if (!serviceCode) {
            showFormError(errorElementId, 'Mã dịch vụ không được để trống.');
            return false;
        }

        if (serviceCode.length > 50) {
            showFormError(errorElementId, 'Mã dịch vụ không được vượt quá 50 ký tự.');
            return false;
        }

        if (!/^[A-Za-z0-9._-]+$/.test(serviceCode)) {
            showFormError(errorElementId, 'Mã dịch vụ không hợp lệ. Chỉ được nhập chữ cái, số, dấu gạch ngang (-), gạch dưới (_) và dấu chấm (.).');
            return false;
        }

        if (estimatedDeliveryDay === '') {
            showFormError(errorElementId, 'Số ngày dự kiến không được để trống.');
            return false;
        }

        if (!/^\d+$/.test(estimatedDeliveryDay)) {
            showFormError(errorElementId, 'Số ngày dự kiến phải là số nguyên không âm.');
            return false;
        }

        if (parseInt(estimatedDeliveryDay, 10) < 0) {
            showFormError(errorElementId, 'Số ngày dự kiến phải lớn hơn hoặc bằng 0.');
            return false;
        }

        return true;
    }

    function validateCreateServiceForm() {
        const serviceName = document.getElementById('createServiceName').value.trim();
        const serviceCode = document.getElementById('createServiceCode').value.trim();
        const estimatedDeliveryDay = document.getElementById('createEstimatedDeliveryDay').value.trim();

        return validateServiceFields(serviceName, serviceCode, estimatedDeliveryDay, 'createErrorMessage');
    }

    function validateEditServiceForm() {
        const serviceName = document.getElementById('editServiceName').value.trim();
        const serviceCode = document.getElementById('editServiceCode').value.trim();
        const estimatedDeliveryDay = document.getElementById('editEstimatedDeliveryDay').value.trim();

        return validateServiceFields(serviceName, serviceCode, estimatedDeliveryDay, 'editErrorMessage');
    }

    function submitBulkAction(actionType) {
        const checkboxes = document.querySelectorAll('.rowCheckbox:checked');
        if (checkboxes.length === 0) {
            alert('Vui lòng chọn ít nhất một dịch vụ.');
            return;
        }

        const form = document.getElementById('bulkForm');

        if (confirm('Bạn có muốn cập nhật trạng thái cho các dịch vụ đã chọn không?')) {
            form.action = '${pageContext.request.contextPath}/admin-services';
            document.getElementById('bulkAction').value = 'bulkStatus';
            document.getElementById('newStatus').value = actionType;
            form.submit();
        }
    }

    function toggleOne(id) {
        if (confirm('Bạn có muốn thay đổi trạng thái của dịch vụ này không?')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/admin-services';
            form.innerHTML =
                '<input type="hidden" name="action" value="toggleStatus">' +
                '<input type="hidden" name="serviceId" value="' + id + '">';
            document.body.appendChild(form);
            form.submit();
        }
    }

    function confirmDeleteOne(id) {
        if (confirm('Bạn có chắc chắn muốn xóa dịch vụ này không?')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/admin-services';
            form.innerHTML =
                '<input type="hidden" name="action" value="delete">' +
                '<input type="hidden" name="serviceId" value="' + id + '">';
            document.body.appendChild(form);
            form.submit();
        }
    }

    document.addEventListener('DOMContentLoaded', function () {
        const openModal = '${openModal}';

        if (openModal === 'detail') {
            const detailModal = new bootstrap.Modal(document.getElementById('detailServiceModal'));
            detailModal.show();
        }

        if (openModal === 'create') {
            const createModal = new bootstrap.Modal(document.getElementById('createServiceModal'));
            createModal.show();
        }

        if (openModal === 'edit') {
            const editModal = new bootstrap.Modal(document.getElementById('editServiceModal'));
            editModal.show();
        }
    });
</script>

<jsp:include page="/includes/footer.jsp" />
