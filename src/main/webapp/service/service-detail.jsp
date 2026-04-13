<jsp:include page="/includes/header.jsp" />
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="container-fluid bg-white p-4 rounded shadow-sm">
    <%-- Breadcrumb ?i?u h??ng --%>
    <nav aria-label="breadcrumb" class="mb-4">
        <ol class="breadcrumb">
            <li class="breadcrumb-item">
                <a href="${pageContext.request.contextPath}/service-catalog" class="text-decoration-none">
                    <i class="bi bi-collection"></i> Service Catalog
                </a>
            </li>
            <li class="breadcrumb-item active" aria-current="page">Service Detail</li>
        </ol>
    </nav>

    <div class="card shadow-sm border-0">
        <div class="card-header bg-primary text-white py-3">
            <h3 class="mb-0">${service.serviceName}</h3>
            <small class="opacity-75">Code: <strong>${service.serviceCode}</strong></small>
        </div>
        
        <div class="card-body p-4">
            <div class="row">
                <%-- C?t bên trái: Mô t? và Yêu c?u --%>
                <div class="col-md-8">
                    <h5 class="fw-bold text-dark"><i class="bi bi-info-circle me-2"></i>Description</h5>
                    <p class="text-muted bg-light p-3 rounded border-start border-4 border-primary">
                        ${service.description}
                    </p>

                    <h5 class="mt-4 fw-bold text-dark"><i class="bi bi-list-check me-2"></i>Service Requirements</h5>
                    <ul class="text-secondary">
                        <li>User must belong to a valid department.</li>
                        <li>Justification is required for high-priority requests.</li>
                    </ul>
                </div>
                
                <%-- C?t bên ph?i: SLA và Th?i gian d? ki?n --%>
                <div class="col-md-4 border-start">
                    <div class="p-2 mb-3">
                        <h6 class="text-uppercase text-secondary fw-bold small">Estimated Delivery</h6>
                        <p class="h3 text-success">${service.estimatedDeliveryDay} Working Days</p>
                    </div>
                    <hr>
                    <div class="p-2">
                        <h6 class="text-uppercase text-secondary fw-bold small mb-3">SLA Policy</h6>
                        <div class="d-grid gap-2">
                            <span class="badge bg-info text-dark p-2 text-start fs-6">
                                <i class="bi bi-clock-history me-2"></i>Standard Response: 8h
                            </span>
                            <span class="badge bg-warning text-dark p-2 text-start fs-6">
                                <i class="bi bi-check2-circle me-2"></i>Resolution: 72h
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <%-- Ph?n nút thao tác --%>
        <div class="card-footer bg-white p-3 text-end border-top-0">
            <a href="${pageContext.request.contextPath}/service-catalog" class="btn btn-secondary me-2 shadow-sm">
                <i class="bi bi-arrow-left me-1"></i> Back to Catalog
            </a>
            <a href="${pageContext.request.contextPath}/create-request?serviceId=${service.serviceId}" class="btn btn-success px-4 shadow-sm">
                <i class="bi bi-send-plus me-1"></i> Request Service
            </a>
        </div>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />