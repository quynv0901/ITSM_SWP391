<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ include file="/common/admin-layout-top.jsp" %>
<c:set var="pageTitle" value="Chi tiết dịch vụ: ${service.serviceName}" scope="request"/>

<div class="container-fluid">
    <div class="mb-4">
        <a href="${pageContext.request.contextPath}/admin/service-management" class="btn btn-light border shadow-sm">
            <i class="bi bi-arrow-left me-1"></i> Back to Management
        </a>
    </div>

    <div class="card shadow-sm border-0">
        <div class="card-header bg-primary text-white py-3">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h3 class="mb-0">${service.serviceName}</h3>
                    <small class="opacity-75">Code: <strong>${service.serviceCode}</strong></small>
                </div>
                <span class="badge ${service.status == 'ACTIVE' ? 'bg-success' : 'bg-secondary'} rounded-pill px-3">
                    ${service.status}
                </span>
            </div>
        </div>
        
        <div class="card-body p-4">
            <div class="row">
                <%-- Cột bên trái: Thông tin mô tả và yêu cầu --%>
                <div class="col-md-8">
                    <h5 class="fw-bold text-dark"><i class="bi bi-info-circle me-2"></i>Description</h5>
                    <p class="text-muted bg-light p-3 rounded">${service.description}</p>
                    
                    <h5 class="mt-4 fw-bold text-dark"><i class="bi bi-list-check me-2"></i>Service Requirements</h5>
                    <ul class="text-secondary">
                        <li>User must belong to a valid department.</li>
                        <li>Justification is required for high-priority requests.</li>
                    </ul>
                </div>

                <%-- Cột bên phải: SLA và Delivery --%>
                <div class="col-md-4 border-start">
                    <div class="p-2 mb-4">
                        <h6 class="text-uppercase text-secondary fw-bold small">Estimated Delivery</h6>
                        <p class="h3 text-success">${service.estimatedDeliveryDay}Working Days</p>
                    </div>
                    <hr>
                    <div class="p-2">
                        <h6 class="text-uppercase text-secondary fw-bold small mb-3">SLA Policy</h6>
                        <div class="d-grid gap-2">
                            <span class="badge bg-info text-dark p-2 text-start">
                                <i class="bi bi-clock-history me-2"></i>Response: 8h
                            </span>
                            <span class="badge bg-warning text-dark p-2 text-start">
                                <i class="bi bi-check2-circle me-2"></i>Resolution: 72h
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="/common/admin-layout-bottom.jsp" %>
