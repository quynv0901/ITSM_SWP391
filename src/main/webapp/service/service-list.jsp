<jsp:include page="/includes/header.jsp" />
<%-- B? comment dòng d??i n?u b?n ch?a khai báo taglib trong header.jsp --%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
    /* Hi?u ?ng m??t mà khi di chu?t vào Card */
    .hover-shadow { transition: all 0.3s ease; }
    .hover-shadow:hover { transform: translateY(-5px); box-shadow: 0 .5rem 1rem rgba(0,0,0,.15)!important; }
    .text-truncate-3 { display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden; }
</style>

<div class="container-fluid bg-white p-4 rounded shadow-sm">
    <div class="d-flex justify-content-between align-items-center mb-4">
    <h2 class="h4 text-primary m-0"><i class="bi bi-collection me-2"></i>Service Catalog</h2>
    
    <a href="${pageContext.request.contextPath}/ticket/service-request-list" class="btn btn-outline-primary shadow-sm fw-bold">
        <i class="bi bi-card-list me-1"></i> View Requests
    </a>
</div>

    <div class="row mb-4">
        <div class="col-md-6">
            <form action="${pageContext.request.contextPath}/service-catalog" method="get" class="d-flex shadow-sm rounded">
                <input type="text" name="search" class="form-control border-end-0"
                       placeholder="Search for services (e.g., Laptop, Software)..." value="${lastSearch}">
                <button type="submit" class="btn btn-primary px-4"><i class="bi bi-search"></i> Search</button>
            </form>
        </div>
    </div>

    <div class="row">
        <c:forEach var="svc" items="${listService}">
            <div class="col-md-4 mb-4">
                <div class="card h-100 shadow-sm border-0 hover-shadow bg-light">
                    <div class="card-header bg-transparent border-bottom-0 pt-3 pb-0">
                        <span class="badge bg-secondary rounded-pill px-3 py-2 shadow-sm">${svc.serviceCode}</span>
                    </div>
                    
                    <div class="card-body">
                        <h5 class="card-title fw-bold text-primary mb-3">${svc.serviceName}</h5>
                        <p class="card-text text-muted small text-truncate-3">
                            ${svc.description}
                        </p>
                    </div>
                    
                    <div class="card-footer bg-transparent border-top-0 pb-4">
                        <a href="${pageContext.request.contextPath}/service/service-detail?id=${svc.serviceId}"
                           class="btn btn-outline-primary w-100 shadow-sm fw-semibold">
                            <i class="bi bi-arrow-right-circle me-2"></i> Request Service
                        </a>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>

    <c:if test="${empty listService}">
        <div class="alert alert-warning text-center py-5 shadow-sm border-0 rounded">
            <i class="bi bi-search fs-1 d-block mb-3 text-warning"></i>
            <h5 class="text-dark">No services found</h5>
            <p class="text-muted mb-0">Try adjusting your search terms to find what you're looking for.</p>
        </div>
    </c:if>
</div>

<jsp:include page="/includes/footer.jsp" />