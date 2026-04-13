<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/includes/header.jsp" />

<c:set var="currentUser" value="${sessionScope.user}" />
<c:set var="roleId" value="${currentUser.roleId}" />
<c:set var="isAdmin" value="${roleId == 10}" />
<c:set var="isEndUser" value="${roleId == 2}" />

<div class="container-fluid bg-white p-4 rounded shadow-sm">
    <c:if test="${not empty param.msg}">
        <div class="alert alert-info alert-dismissible fade show" role="alert">
            <c:choose>
                <c:when test="${param.msg eq 'created'}">Service created successfully.</c:when>
                <c:when test="${param.msg eq 'updated'}">Service updated successfully.</c:when>
                <c:when test="${param.msg eq 'deleted'}">Service deleted successfully.</c:when>
                <c:when test="${param.msg eq 'cannot_delete'}">Cannot delete this service because it is already used in ticket(s).</c:when>
                <c:when test="${param.msg eq 'not_found'}">Service not found.</c:when>
                <c:when test="${param.msg eq 'status_updated'}">Service status updated successfully.</c:when>
                <c:when test="${param.msg eq 'bulk_updated'}">Bulk status updated successfully. Updated: ${param.count}</c:when>
                <c:otherwise>Action completed.</c:otherwise>
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
            ${isAdmin ? 'Service Management' : 'Service Catalog'}
        </h2>

        <c:if test="${isAdmin}">
            <div class="d-flex gap-2 flex-wrap">
                <button type="button" class="btn btn-danger" onclick="submitBulkAction('DELETE')">
                    <i class="bi bi-trash"></i> Bulk Delete
                </button>
                <button type="button" class="btn btn-secondary" onclick="submitBulkAction('INACTIVE')">
                    <i class="bi bi-pause-circle"></i> Bulk Disable
                </button>
                <button type="button" class="btn btn-success" onclick="submitBulkAction('ACTIVE')">
                    <i class="bi bi-play-circle"></i> Bulk Enable
                </button>
                <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createServiceModal">
                    <i class="bi bi-plus-circle"></i> Create New Service
                </button>
            </div>
        </c:if>
    </div>

    <form action="${pageContext.request.contextPath}${isAdmin ? '/admin-services' : '/service-catalog'}"
          method="get"
          class="row g-3 mb-4 bg-light p-3 rounded border mx-0">
        <input type="hidden" name="action" value="list">

        <div class="${isAdmin ? 'col-md-5' : 'col-md-8'}">
            <input type="text" name="q" class="form-control"
                   placeholder="Search by service name, code, or description..."
                   value="${keyword}">
        </div>

        <c:if test="${isAdmin}">
            <div class="col-md-3">
                <select name="status" class="form-select">
                    <option value="">All Statuses</option>
                    <option value="ACTIVE" ${status eq 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                    <option value="INACTIVE" ${status eq 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
                </select>
            </div>
        </c:if>

        <div class="${isAdmin ? 'col-md-4' : 'col-md-4'} d-flex gap-2">
            <button type="submit" class="btn btn-primary">
                <i class="bi bi-search"></i> Search
            </button>
            <a href="${pageContext.request.contextPath}${isAdmin ? '/admin-services' : '/service-catalog'}"
               class="btn btn-outline-secondary">
                <i class="bi bi-x-circle"></i> Clear
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
                        <th>Code</th>
                        <th>Service Name</th>
                        <th>Description</th>
                        <th>Delivery (Days)</th>
                        <c:if test="${isAdmin}">
                            <th>Status</th>
                        </c:if>
                        <th class="text-center">Actions</th>
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
                            <td>${svc.estimatedDeliveryDay}</td>

                            <c:if test="${isAdmin}">
                                <td>
                                    <span class="badge ${svc.status == 'ACTIVE' ? 'bg-success' : 'bg-secondary'}">
                                        ${svc.status}
                                    </span>
                                </td>
                            </c:if>

                            <td class="text-center">
                                <div class="d-flex justify-content-center gap-1 flex-wrap">
                                    <a href="${pageContext.request.contextPath}${isAdmin ? '/admin-services' : '/service-catalog'}?action=detail&id=${svc.serviceId}&q=${keyword}${isAdmin ? '&status='.concat(status) : ''}"
                                       class="btn btn-info btn-sm text-white"
                                       title="View Detail">
                                        <i class="bi bi-eye"></i>
                                    </a>

                                    <c:if test="${isAdmin}">
                                        <a href="${pageContext.request.contextPath}/admin-services?action=edit&id=${svc.serviceId}&q=${keyword}&status=${status}"
                                           class="btn btn-warning btn-sm text-white"
                                           title="Edit Service">
                                            <i class="bi bi-pencil"></i>
                                        </a>

                                        <button type="button"
                                                class="btn btn-${svc.status == 'ACTIVE' ? 'secondary' : 'success'} btn-sm"
                                                title="${svc.status == 'ACTIVE' ? 'Disable' : 'Enable'}"
                                                onclick="toggleOne('${svc.serviceId}')">
                                            <i class="bi ${svc.status == 'ACTIVE' ? 'bi-pause-circle' : 'bi-play-circle'}"></i>
                                        </button>

                                        <button type="button"
                                                class="btn btn-danger btn-sm"
                                                title="Delete Service"
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
                                No services found.
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
                <form method="post" action="${pageContext.request.contextPath}/admin-services">
                    <input type="hidden" name="action" value="create">

                    <div class="modal-header">
                        <h5 class="modal-title">Create Service</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>

                    <div class="modal-body row g-3">
                        <div class="col-md-6">
                            <label class="form-label">Service Name</label>
                            <input type="text" name="serviceName" class="form-control"
                                   value="${openModal eq 'create' ? selectedService.serviceName : ''}" required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Service Code</label>
                            <input type="text" name="serviceCode" class="form-control"
                                   value="${openModal eq 'create' ? selectedService.serviceCode : ''}" required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Estimated Delivery Day</label>
                            <input type="number" min="0" name="estimatedDeliveryDay" class="form-control"
                                   value="${openModal eq 'create' ? selectedService.estimatedDeliveryDay : ''}" required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Status</label>
                            <select name="status" class="form-select">
                                <option value="ACTIVE"
                                    ${openModal eq 'create' && selectedService.status eq 'INACTIVE' ? '' : 'selected'}>ACTIVE</option>
                                <option value="INACTIVE"
                                    ${openModal eq 'create' && selectedService.status eq 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
                            </select>
                        </div>

                        <div class="col-12">
                            <label class="form-label">Description</label>
                            <textarea name="description" rows="4" class="form-control">${openModal eq 'create' ? selectedService.description : ''}</textarea>
                        </div>
                    </div>

                    <div class="modal-footer">
                        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="submit" class="btn btn-primary">Create</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="modal fade" id="editServiceModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <form method="post" action="${pageContext.request.contextPath}/admin-services">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="serviceId" value="${selectedService.serviceId}">

                    <div class="modal-header">
                        <h5 class="modal-title">Edit Service</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>

                    <div class="modal-body row g-3">
                        <div class="col-md-6">
                            <label class="form-label">Service Name</label>
                            <input type="text" name="serviceName" class="form-control"
                                   value="${selectedService.serviceName}" required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Service Code</label>
                            <input type="text" name="serviceCode" class="form-control"
                                   value="${selectedService.serviceCode}" required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Estimated Delivery Day</label>
                            <input type="number" min="0" name="estimatedDeliveryDay" class="form-control"
                                   value="${selectedService.estimatedDeliveryDay}" required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Status</label>
                            <select name="status" class="form-select">
                                <option value="ACTIVE" ${selectedService.status eq 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                                <option value="INACTIVE" ${selectedService.status eq 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
                            </select>
                        </div>

                        <div class="col-12">
                            <label class="form-label">Description</label>
                            <textarea name="description" rows="4" class="form-control">${selectedService.description}</textarea>
                        </div>
                    </div>

                    <div class="modal-footer">
                        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="submit" class="btn btn-warning text-white">Update</button>
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
                <h5 class="modal-title">Service Detail</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body">
                <c:if test="${not empty selectedService}">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Service Code</label>
                            <div class="form-control bg-light">${selectedService.serviceCode}</div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-bold">Service Name</label>
                            <div class="form-control bg-light">${selectedService.serviceName}</div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-bold">Estimated Delivery Day</label>
                            <div class="form-control bg-light">${selectedService.estimatedDeliveryDay}</div>
                        </div>

                        <c:if test="${isAdmin}">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Status</label>
                                <div class="form-control bg-light">${selectedService.status}</div>
                            </div>
                        </c:if>

                        <div class="col-12">
                            <label class="form-label fw-bold">Description</label>
                            <div class="form-control bg-light" style="min-height: 120px;">
                                ${selectedService.description}
                            </div>
                        </div>
                    </div>
                </c:if>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button>
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

    function submitBulkAction(actionType) {
        const checkboxes = document.querySelectorAll('.rowCheckbox:checked');
        if (checkboxes.length === 0) {
            alert('Please select at least one service.');
            return;
        }

        const form = document.getElementById('bulkForm');

        if (actionType === 'DELETE') {
            if (confirm('Are you sure you want to delete the selected services?')) {
                form.action = '${pageContext.request.contextPath}/admin-services';
                document.getElementById('bulkAction').value = 'delete';

                const existing = document.getElementsByName('serviceId');
                if (existing.length > 0) {
                    for (let i = existing.length - 1; i >= 0; i--) {
                        existing[i].remove();
                    }
                }

                form.submit();
            }
        } else {
            if (confirm('Do you want to update status for selected services?')) {
                form.action = '${pageContext.request.contextPath}/admin-services';
                document.getElementById('bulkAction').value = 'bulkStatus';
                document.getElementById('newStatus').value = actionType;
                form.submit();
            }
        }
    }

    function toggleOne(id) {
        if (confirm('Do you want to change status of this service?')) {
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
        if (confirm('Delete this service?')) {
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