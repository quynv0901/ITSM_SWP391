<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap');

    body { font-family: 'Inter', sans-serif; background-color: #f4f7f6; }
    h4 { font-family: 'Outfit', sans-serif; }
    .form-card {
        background: #fff; border: 1px solid #e2e8f0; border-radius: 16px;
        padding: 26px 28px; box-shadow: 0 4px 15px rgba(0,0,0,.03);
    }
    .section-title {
        font-size: 12px; font-weight: 700; letter-spacing: .6px; text-transform: uppercase;
        color: #5a6a85; margin-bottom: 18px; padding-bottom: 8px; border-bottom: 1px solid #edf2f7;
    }
    .f-label {
        font-size: 12px; font-weight: 700; color: #4a5568; margin-bottom: 6px; text-transform: uppercase;
    }
    .f-input {
        border: 1px solid #cbd5e0; border-radius: 8px; background: #f8fafc; font-size: 14px; padding: 10px 12px;
    }
    .f-input:focus {
        border-color: #4299e1; box-shadow: 0 0 0 3px rgba(66,153,225,.2); background: #fff;
    }
    .flash { padding: 12px 16px; border-radius: 12px; margin-bottom: 16px; font-weight: 500; }
    .flash-error { background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; }
</style>

<%@include file="../common/admin-layout-top.jsp" %>

<div class="d-flex justify-content-between align-items-center mb-3">
    <h4 class="fw-bold mb-0" style="color:#222d32;">
        <i class="bi bi-diagram-3-fill me-2 text-primary"></i>
        ${editMode ? 'Cập nhật phòng ban' : 'Tạo phòng ban mới'}
    </h4>
    <a href="${pageContext.request.contextPath}/admin/departments" class="btn btn-outline-secondary btn-sm">
        <i class="bi bi-arrow-left"></i> Quay lại danh sách
    </a>
</div>

<c:if test="${not empty error}">
    <div class="flash flash-error"><i class="bi bi-exclamation-triangle-fill me-2"></i>${error}</div>
</c:if>

<div class="form-card">
    <form action="${pageContext.request.contextPath}/admin/departments" method="post" class="row g-3">
        <div class="section-title">
            Thông tin phòng ban
        </div>
            <input type="hidden" name="action" value="${editMode ? 'update' : 'create'}">
            <c:if test="${editMode}">
                <input type="hidden" name="departmentId" value="${department.departmentId}">
            </c:if>

            <div class="col-md-6">
                <label class="f-label">Tên phòng ban <span class="text-danger">*</span></label>
                <input type="text" name="departmentName" class="form-control f-input"
                       value="${department.departmentName}" maxlength="100" required>
            </div>

            <div class="col-md-6">
                <label class="f-label">Mã phòng ban <span class="text-danger">*</span></label>
                <input type="text" name="departmentCode" class="form-control f-input"
                       value="${department.departmentCode}" maxlength="20" required>
            </div>

            <div class="col-md-6">
                <label class="f-label">Trưởng phòng</label>
                <select name="managerId" class="form-select f-input">
                    <option value="">-- Chọn trưởng phòng --</option>
                    <c:forEach var="u" items="${managers}">
                        <option value="${u.userId}" ${department.managerId == u.userId ? 'selected' : ''}>
                            ${u.fullName} - ${u.email}
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div class="col-md-6">
                <label class="f-label">Phòng ban cha</label>
                <select name="parentDepartmentId" class="form-select f-input">
                    <option value="">-- Không có --</option>
                    <c:forEach var="d" items="${allDepartments}">
                        <c:if test="${!editMode || d.departmentId != department.departmentId}">
                            <option value="${d.departmentId}" ${department.parentDepartmentId == d.departmentId ? 'selected' : ''}>
                                ${d.departmentName}
                            </option>
                        </c:if>
                    </c:forEach>
                </select>
            </div>

            <div class="col-md-6">
                <label class="f-label">Trạng thái</label>
                <select name="status" class="form-select f-input">
                    <option value="ACTIVE" ${department.status == null || department.status eq 'ACTIVE' ? 'selected' : ''}>Đang hoạt động</option>
                    <option value="INACTIVE" ${department.status eq 'INACTIVE' ? 'selected' : ''}>Ngừng hoạt động</option>
                </select>
            </div>

            <div class="col-12 d-flex justify-content-end gap-2 pt-2 border-top mt-2">
                <a href="${pageContext.request.contextPath}/admin/departments" class="btn btn-outline-secondary btn-sm px-4">Hủy</a>
                <button type="submit" class="btn btn-primary btn-sm px-4">
                    <i class="bi ${editMode ? 'bi-check2-circle' : 'bi-plus-circle'}"></i>
                    ${editMode ? 'Cập nhật' : 'Tạo mới'}
                </button>
            </div>
    </form>
</div>

<jsp:include page="/common/admin-layout-bottom.jsp" />
