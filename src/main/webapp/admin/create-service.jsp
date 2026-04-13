<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ include file="/common/admin-layout-top.jsp" %>
<c:set var="pageTitle" value="Define New Service Offering" scope="request"/>

<div class="container-fluid">
    <nav aria-label="breadcrumb" class="mb-4">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/service-management">Service Management</a></li>
            <li class="breadcrumb-item active" aria-current="page">Create New Service</li>
        </ol>
    </nav>

    <div class="row justify-content-center">
        <div class="col-xl-9 col-lg-10">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-dark text-white py-3">
                    <h5 class="mb-0"><i class="bi bi-plus-circle me-2"></i>Define New Service Offering</h5>
                </div>
                <div class="card-body p-4">
                    <%-- Display Error Message if exists --%>
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger border-0 shadow-sm mb-4">
                            <i class="bi bi-exclamation-triangle me-2"></i>${error}
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/admin/create-service" method="post">
                        <div class="row mb-4">
                            <div class="col-md-8">
                                <label class="form-label fw-bold">Service Name</label>
                                <input type="text" name="serviceName" class="form-control shadow-none" 
                                       required placeholder="e.g., Cloud Storage Expansion">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-bold">Service Code</label>
                                <input type="text" name="serviceCode" class="form-control shadow-none" 
                                       required placeholder="SR-CLOUD-01">
                            </div>
                        </div>
                        <div class="card-body">
                            <!--<c:if test="${not empty error}">
                                <div class="alert alert-danger">${error}</div>
                            </c:if>-->
                            <form action="create-service" method="post">
<!--                                <div class="row mb-3">
                                    <div class="col-md-8">
                                        <label class="form-label font-weight-bold">Service Name</label>
                                        <input type="text" name="serviceName" class="form-control" required placeholder="e.g., Cloud Storage Expansion">
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label">Service Code</label>
                                        <input type="text" name="serviceCode" class="form-control" required placeholder="SR-CLOUD-01">
                                    </div>
                                </div>-->

                        <div class="mb-4">
                            <label class="form-label fw-bold">Detailed Description</label>
                            <textarea name="description" class="form-control shadow-none" rows="5" 
                                      required placeholder="Provide a detailed description of the service..."></textarea>
                        </div>

                        <div class="row mb-4">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Estimated Delivery (Days)</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-white"><i class="bi bi-calendar-event"></i></span>
                                    <input type="number" name="deliveryDay" class="form-control shadow-none" 
                                           min="1" value="1" required>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Initial Status</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light"><i class="bi bi-check-circle"></i></span>
                                    <input type="text" class="form-control bg-light" value="ACTIVE" readonly>
                                </div>
                                <input type="hidden" name="status" value="ACTIVE">
                            </div>
                        </div>

                        <hr class="my-4">
                        
                        <div class="d-flex justify-content-end gap-2">
                            <a href="${pageContext.request.contextPath}/admin/service-management" 
                               class="btn btn-light border px-4">Cancel</a>
                            <button type="submit" class="btn btn-primary px-5 shadow-sm">
                                <i class="bi bi-cloud-upload me-2"></i>Publish Service
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<%@ include file="/common/admin-layout-bottom.jsp" %>
