<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setLocale value="vi_VN" />
<jsp:include page="/includes/header.jsp" />

<div class="container mt-5 mb-5">
    <div class="row justify-content-center">
        <div class="col-md-8">

            <nav aria-label="breadcrumb" class="mb-3">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item">
                        <a href="${pageContext.request.contextPath}/service-catalog">Danh mục dịch vụ</a>
                    </li>
                    <li class="breadcrumb-item active" aria-current="page">Tạo yêu cầu dịch vụ</li>
                </ol>
            </nav>

            <div class="card shadow-sm border-0">
                <div class="card-header bg-success text-white py-3">
                    <h4 class="mb-0">
                        <i class="bi bi-file-earmark-plus me-2"></i>Tạo yêu cầu dịch vụ
                    </h4>
                </div>

                <div class="card-body p-4">
                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger">${errorMessage}</div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/service-request" method="post" accept-charset="UTF-8">
                        <input type="hidden" name="action" value="create">

                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Dịch vụ</label>
                                <select name="serviceId" class="form-select" required>
                                    <option value="">-- Chọn dịch vụ --</option>
                                    <c:forEach var="svc" items="${serviceOptions}">
                                        <option value="${svc.serviceId}"
                                                <c:if test="${selectedServiceId == svc.serviceId || param.serviceId == svc.serviceId}">selected</c:if>>
                                            ${svc.serviceName} (${svc.serviceCode})
                                        </option>
                                    </c:forEach>
                                </select>
                                <div class="form-text">Chỉ hiển thị các dịch vụ đang hoạt động.</div>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">Phòng ban</label>
                                <select name="departmentId" class="form-select" required>
                                    <option value="">-- Chọn phòng ban --</option>
                                    <c:forEach var="dept" items="${departmentOptions}">
                                        <option value="${dept.departmentId}"
                                                <c:if test="${selectedDepartmentId == dept.departmentId || sessionScope.user.departmentId == dept.departmentId}">selected</c:if>>
                                            ${dept.departmentName}
                                            <c:if test="${not empty dept.departmentCode}">(${dept.departmentCode})</c:if>
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">Danh mục</label>
                                <select name="categoryId" class="form-select">
                                    <option value="">-- Chọn danh mục --</option>
                                    <c:forEach var="cat" items="${categoryOptions}">
                                        <option value="${cat.categoryId}"
                                                <c:if test="${selectedCategoryId == cat.categoryId || param.categoryId == cat.categoryId}">selected</c:if>>
                                            ${cat.categoryName}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">Mức độ ưu tiên</label>
                                <select name="priority" class="form-select" required>
                                    <option value="">-- Chọn mức độ ưu tiên --</option>
                                    <option value="LOW" ${priority eq 'LOW' ? 'selected' : ''}>Thấp</option>
                                    <option value="MEDIUM" ${priority eq 'MEDIUM' ? 'selected' : ''}>Trung bình</option>
                                    <option value="HIGH" ${priority eq 'HIGH' ? 'selected' : ''}>Cao</option>
                                    <option value="CRITICAL" ${priority eq 'CRITICAL' ? 'selected' : ''}>Khẩn cấp</option>
                                </select>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-bold">Tiêu đề</label>
                                <input type="text" name="title" class="form-control" value="${title}" required>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-bold">Mô tả</label>
                                <textarea name="description" class="form-control" rows="4"
                                          placeholder="Mô tả chi tiết nhu cầu của bạn...">${description}</textarea>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-bold">Lý do yêu cầu</label>
                                <textarea name="justification" class="form-control" rows="4"
                                          placeholder="Giải thích lý do bạn cần yêu cầu này..." required>${justification}</textarea>
                            </div>
                        </div>

                        <hr class="my-4">

                        <div class="d-flex justify-content-between">
                            <a href="${pageContext.request.contextPath}/service-request?action=list"
                               class="btn btn-outline-secondary">
                                <i class="bi bi-arrow-left me-1"></i>Quay lại
                            </a>

                            <button type="submit" class="btn btn-success">
                                <i class="bi bi-send-check me-1"></i>Gửi yêu cầu
                            </button>
                        </div>
                    </form>
                </div>
            </div>

        </div>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />
