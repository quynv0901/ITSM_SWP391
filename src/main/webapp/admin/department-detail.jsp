<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap');

    body { font-family: 'Inter', sans-serif; background-color: #f4f7f6; }
    h4, h6 { font-family: 'Outfit', sans-serif; }
    .info-card, .table-card, .stat-card {
        background: #fff; border: 1px solid #e2e8f0; border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.03);
    }
    .stat-card { padding: 20px 24px; }
    .stat-label { font-size: 12px; text-transform: uppercase; letter-spacing: .5px; color: #718096; font-weight: 700; }
    .stat-value { font-size: 34px; font-weight: 800; color: #1a202c; line-height: 1; font-family: 'Outfit', sans-serif; }
    .field-label { font-size: 12px; text-transform: uppercase; font-weight: 700; color: #4a5568; margin-bottom: 6px; }
    .field-box { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 10px 12px; color: #2d3748; }
    .status-on, .status-off {
        display: inline-flex; align-items: center; gap: 6px; padding: 4px 10px; border-radius: 12px;
        font-size: 12px; font-weight: 600;
    }
    .status-on { background: rgba(16,185,129,.1); color: #059669; border: 1px solid rgba(16,185,129,.2); }
    .status-off { background: rgba(239,68,68,.1); color: #dc2626; border: 1px solid rgba(239,68,68,.2); }
    .user-table { width: 100%; border-collapse: separate; border-spacing: 0; }
    .user-table th {
        padding: 14px 16px; text-transform: uppercase; font-size: 12px; color: #4a5568; font-weight: 700;
        background: #f8fafc; border-bottom: 2px solid #e2e8f0;
    }
    .user-table td { padding: 14px 16px; border-bottom: 1px solid #edf2f7; }
    .user-table tbody tr:hover { background: #f0f7fa; }
</style>

<%@include file="../common/admin-layout-top.jsp" %>

<div class="d-flex justify-content-between align-items-center mb-3">
    <h4 class="fw-bold mb-0" style="color:#222d32;">
        <i class="bi bi-building me-2 text-primary"></i>Chi tiết phòng ban
    </h4>
    <div class="d-flex gap-2">
        <a href="${pageContext.request.contextPath}/admin/departments?action=edit&id=${department.departmentId}" class="btn btn-warning text-white btn-sm">
            <i class="bi bi-pencil"></i> Chỉnh sửa
        </a>
        <a href="${pageContext.request.contextPath}/admin/departments" class="btn btn-outline-secondary btn-sm">
            <i class="bi bi-arrow-left"></i> Quay lại danh sách
        </a>
    </div>
</div>

<div class="row g-3 mb-3">
    <div class="col-md-4">
        <div class="stat-card">
            <div class="stat-label">Tổng số người trong phòng ban</div>
            <div class="stat-value text-primary">${department.totalUsers}</div>
        </div>
    </div>
    <div class="col-md-8">
        <div class="info-card h-100">
            <div class="p-3 p-md-4 row g-3">
                <div class="col-md-6">
                    <div class="field-label">Tên phòng ban</div>
                    <div class="field-box">${department.departmentName}</div>
                </div>
                <div class="col-md-6">
                    <div class="field-label">Mã phòng ban</div>
                    <div class="field-box">${department.departmentCode}</div>
                </div>
                <div class="col-md-6">
                    <div class="field-label">Trưởng phòng</div>
                    <div class="field-box">${department.managerName != null ? department.managerName : 'Chưa có'}</div>
                </div>
                <div class="col-md-6">
                    <div class="field-label">Phòng ban cha</div>
                    <div class="field-box">${department.parentDepartmentName != null ? department.parentDepartmentName : 'Không có'}</div>
                </div>
                <div class="col-md-6">
                    <div class="field-label">Trạng thái</div>
                    <div class="field-box">
                        <span class="${department.status eq 'ACTIVE' ? 'status-on' : 'status-off'}">
                            <i class="bi bi-circle-fill" style="font-size:7px;"></i>
                            ${department.status eq 'ACTIVE' ? 'Active' : 'Inactive'}
                        </span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="table-card">
    <div class="px-4 py-3 border-bottom">
        <h6 class="mb-0 fw-bold">Danh sách nhân sự</h6>
    </div>
    <div class="table-responsive">
        <table class="user-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Họ tên</th>
                    <th>Email</th>
                    <th>SĐT</th>
                    <th>Trạng thái</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="u" items="${users}">
                    <tr>
                        <td>#${u.userId}</td>
                        <td class="fw-semibold text-primary">${u.fullName}</td>
                        <td>${u.email}</td>
                        <td>${u.phone}</td>
                        <td>
                            <span class="${u.isActive ? 'status-on' : 'status-off'}">
                                <i class="bi bi-circle-fill" style="font-size:7px;"></i>
                                ${u.isActive ? 'Hoạt động' : 'Không hoạt động'}
                            </span>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty users}">
                    <tr>
                        <td colspan="5" class="text-center text-muted py-4">Chưa có nhân sự trong phòng ban.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="/common/admin-layout-bottom.jsp" />
