<jsp:include page="/includes/header.jsp" />
<%-- N?u b? l?i 500 "Redefine prefix", hãy xóa dòng taglib bên d??i --%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="container-fluid bg-white p-4 rounded shadow-sm">
    <%-- Hi?n th? thông báo k?t qu? --%>
    <c:if test="${not empty sessionScope.message}">
        <div class="alert alert-info alert-dismissible fade show" role="alert">
            <i class="bi bi-info-circle me-2"></i> ${sessionScope.message}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            <c:remove var="message" scope="session"/>
        </div>
    </c:if>

    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="h4 text-primary m-0"><i class="bi bi-hdd-network me-2"></i>Service Management</h2>
        <div class="d-flex gap-2">
            <button type="button" class="btn btn-danger" onclick="submitBulkAction('DELETE')">
                <i class="bi bi-trash"></i> Bulk Delete
            </button>
            <button type="button" class="btn btn-secondary" onclick="submitBulkAction('INACTIVE')">
                <i class="bi bi-pause-circle"></i> Bulk Disable
            </button>
            <button type="button" class="btn btn-success" onclick="submitBulkAction('ACTIVE')">
                <i class="bi bi-play-circle"></i> Bulk Enable
            </button>
            <a href="${pageContext.request.contextPath}/admin/create-service" class="btn btn-primary">
                <i class="bi bi-plus-circle"></i> Create New Service
            </a>
        </div>
    </div>

    <form action="${pageContext.request.contextPath}/admin/service-management" method="get"
          class="row g-3 mb-4 bg-light p-3 rounded border mx-0">
        <div class="col-md-5">
            <input type="text" name="search" class="form-control" placeholder="Search by Service Name or Code..."
                   value="${lastSearch}">
        </div>
        <div class="col-md-3">
            <select name="statusFilter" class="form-select">
                <option value="">All Statuses</option>
                <option value="ACTIVE" ${param.statusFilter eq 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                <option value="INACTIVE" ${param.statusFilter eq 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
            </select>
        </div>
        <div class="col-md-4 d-flex gap-2">
            <button type="submit" class="btn btn-primary"><i class="bi bi-search"></i> Search</button>
            <a href="${pageContext.request.contextPath}/admin/service-management" class="btn btn-outline-secondary">
                <i class="bi bi-x-circle"></i> Clear
            </a>
        </div>
    </form>

    <form id="bulkForm" method="post">
        <input type="hidden" name="statusAction" id="statusAction" value="">

        <div class="table-responsive">
            <table class="table table-hover table-bordered align-middle mt-3">
                <thead class="table-light">
                    <tr>
                        <th style="width: 40px;" class="text-center">
                            <input type="checkbox" id="selectAll" class="form-check-input" onclick="toggleAll(this)">
                        </th>
                        <th>Code</th>
                        <th>Service Name</th>
                        <th>Description</th>
                        <th>Delivery (Days)</th>
                        <th>Status</th>
                        <th class="text-center">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="svc" items="${allServices}">
                        <tr>
                            <td class="text-center">
                                <input type="checkbox" name="serviceIds" value="${svc.serviceId}" class="rowCheckbox form-check-input">
                            </td>
                            <td><strong>${svc.serviceCode}</strong></td>
                            <td class="text-primary fw-bold">${svc.serviceName}</td>
                            <td class="text-muted" style="max-width: 250px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                ${svc.description}
                            </td>
                            <td>${svc.estimatedDeliveryDay}</td>
                            <td>
                                <span class="badge ${svc.status == 'ACTIVE' ? 'bg-success' : 'bg-secondary'}">
                                    ${svc.status}
                                </span>
                            </td>
                            <td class="d-flex justify-content-center gap-1">
                                <a href="${pageContext.request.contextPath}/admin/service-managedetail?id=${svc.serviceId}" 
                                   class="btn btn-info btn-sm text-white" title="View Detail">
                                    <i class="bi bi-eye"></i>
                                </a>
                                <a href="${pageContext.request.contextPath}/admin/update-service?id=${svc.serviceId}" 
                                   class="btn btn-warning btn-sm text-white" title="Edit Service">
                                    <i class="bi bi-pencil"></i>
                                </a>
                                <button type="button" class="btn btn-danger btn-sm" title="Delete Service"
                                        onclick="confirmDeleteOne('${svc.serviceId}')">
                                    <i class="bi bi-trash"></i>
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                    
                    <c:if test="${empty allServices}">
                        <tr>
                            <td colspan="7" class="text-center text-muted fst-italic py-4">
                                <i class="bi bi-inbox fs-4 d-block mb-2"></i> No services found.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </form>
</div>

<script>
    // Hàm ch?n t?t c? Checkbox
    function toggleAll(source) {
        var checkboxes = document.getElementsByClassName('rowCheckbox');
        for (var i = 0, n = checkboxes.length; i < n; i++) {
            if (!checkboxes[i].disabled) {
                checkboxes[i].checked = source.checked;
            }
        }
    }

    // X? lý các nút Bulk Action (Delete, Enable, Disable)
    function submitBulkAction(actionType) {
        var checkboxes = document.querySelectorAll('.rowCheckbox:checked');
        if (checkboxes.length === 0) {
            alert('Please select at least one service.');
            return;
        }

        var form = document.getElementById('bulkForm');
        
        if (actionType === 'DELETE') {
            if (confirm('Are you sure you want to DELETE the selected services?')) {
                form.action = '${pageContext.request.contextPath}/admin/delete-service';
                form.submit();
            }
        } else {
            // Tr??ng h?p ACTIVE ho?c INACTIVE
            var actionName = actionType === 'ACTIVE' ? 'KÍCH HO?T' : 'T?M ?N';
            if (confirm('Do you want ' + actionName + ' selected services?')) {
                form.action = '${pageContext.request.contextPath}/admin/toggle-service';
                document.getElementById('statusAction').value = actionType;
                form.submit();
            }
        }
    }
    
    function toggleOne(id, newStatus) {
        var actionName = newStatus === 'ACTIVE' ? 'KÍCH HO?T' : 'T?M ?N';
        if (confirm('Do you want ' + actionName + ' this service?')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/admin/toggle-service';
            
            form.innerHTML = `<input type="hidden" name="serviceIds" value="`+id+`">
                              <input type="hidden" name="statusAction" value="`+newStatus+`">`;
            document.body.appendChild(form);
            form.submit();
        }
    }
    
    // Xóa m?t dòng duy nh?t
    function confirmDeleteOne(id) {
        if (confirm('Delete this service? ')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/admin/delete-service';
            form.innerHTML = `<input type="hidden" name="serviceIds" value="`+id+`">`;
            document.body.appendChild(form);
            form.submit();
        }
    }
</script>

<jsp:include page="/includes/footer.jsp" />