<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<style>
    @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&family=Inter:wght@400;500;600;700&display=swap');

    body { font-family: 'Inter', sans-serif; background-color: #f4f7f6; }
    h4 { font-family: 'Outfit', sans-serif; }
    .stat-row { display: flex; gap: 20px; flex-wrap: wrap; margin-bottom: 24px; }
    .stat-card {
        flex: 1; min-width: 180px; background: #fff; border: 1px solid #e2e8f0; border-radius: 16px;
        padding: 20px 24px; display: flex; align-items: center; gap: 16px; text-decoration: none; color: inherit;
        box-shadow: 0 4px 15px rgba(0,0,0,0.03); transition: all .2s ease;
    }
    .stat-card:hover { transform: translateY(-4px); box-shadow: 0 10px 20px rgba(0,0,0,0.08); color: inherit; }
    .stat-icon { width: 50px; height: 50px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 22px; }
    .stat-label { font-size: 12px; color: #718096; text-transform: uppercase; letter-spacing: .6px; font-weight: 700; }
    .stat-value { font-size: 30px; font-weight: 800; color: #1a202c; font-family: 'Outfit', sans-serif; line-height: 1; }

    .filter-card, .table-card {
        background: #fff; border: 1px solid #e2e8f0; border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.03);
    }
    .filter-card { padding: 20px 24px; margin-bottom: 20px; }
    .filter-row { display: flex; gap: 16px; flex-wrap: wrap; align-items: flex-end; }
    .filter-group { display: flex; flex-direction: column; gap: 6px; min-width: 160px; }
    .filter-group label { font-size: 12px; font-weight: 600; color: #4a5568; text-transform: uppercase; }
    .filter-group input, .filter-group select {
        padding: 10px 12px; border: 1px solid #cbd5e0; border-radius: 8px; background: #f8fafc; font-size: 14px;
    }
    .filter-group input:focus, .filter-group select:focus {
        outline: none; border-color: #4299e1; box-shadow: 0 0 0 3px rgba(66,153,225,.2); background: #fff;
    }

    .dept-table { width: 100%; border-collapse: separate; border-spacing: 0; font-size: 14px; }
    .dept-table th {
        padding: 14px 16px; text-transform: uppercase; font-size: 12px; color: #4a5568; font-weight: 700;
        background: #f8fafc; border-bottom: 2px solid #e2e8f0;
    }
    .dept-table td { padding: 14px 16px; border-bottom: 1px solid #edf2f7; vertical-align: middle; }
    .dept-table tbody tr:hover { background: #f0f7fa; box-shadow: inset 2px 0 0 #3c8dbc; }
    .dept-name { color: #2563eb; font-weight: 700; text-decoration: none; }
    .dept-name:hover { color: #1d4ed8; text-decoration: underline; }

    .status-on, .status-off {
        display: inline-flex; align-items: center; gap: 6px; padding: 4px 10px; border-radius: 12px;
        font-size: 12px; font-weight: 600;
    }
    .status-on { background: rgba(16,185,129,.1); color: #059669; border: 1px solid rgba(16,185,129,.2); }
    .status-off { background: rgba(239,68,68,.1); color: #dc2626; border: 1px solid rgba(239,68,68,.2); }
    .btn-icon {
        width: 34px; height: 34px; display: inline-flex; align-items: center; justify-content: center;
        border: none; border-radius: 8px; color: #fff; transition: all .2s;
    }
    .btn-icon:hover { transform: translateY(-2px); }
    .pager-row {
        display: flex; justify-content: space-between; align-items: center; padding: 16px 20px;
        border-top: 1px solid #e2e8f0; background: #f8fafc; flex-wrap: wrap; gap: 10px;
    }
    .flash { padding: 14px 20px; border-radius: 12px; margin-bottom: 16px; font-weight: 500; }
    .flash-success { background: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; }
    .flash-error { background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; }
</style>

<%@include file="../common/admin-layout-top.jsp" %>

<div class="d-flex justify-content-between align-items-center mb-3">
    <div>
        <h4 class="fw-bold mb-0" style="color:#222d32;"><i class="bi bi-diagram-3-fill me-2 text-primary"></i>Quản lý Phòng ban</h4>
        <small class="text-muted">Danh sách phòng ban, trạng thái vận hành và số nhân sự.</small>
    </div>
    <a href="${pageContext.request.contextPath}/admin/departments?action=create" class="btn btn-primary btn-sm px-3">
        <i class="bi bi-plus-circle me-1"></i>Thêm phòng ban
    </a>
</div>

<c:if test="${param.message eq 'created'}">
    <div class="flash flash-success"><i class="bi bi-check-circle-fill me-2"></i>Tạo phòng ban thành công.</div>
</c:if>
<c:if test="${param.message eq 'updated'}">
    <div class="flash flash-success"><i class="bi bi-check-circle-fill me-2"></i>Cập nhật phòng ban thành công.</div>
</c:if>
<c:if test="${param.message eq 'deleted'}">
    <div class="flash flash-success"><i class="bi bi-check-circle-fill me-2"></i>Xóa phòng ban thành công.</div>
</c:if>
<c:if test="${param.message eq 'status_updated'}">
    <div class="flash flash-success"><i class="bi bi-check-circle-fill me-2"></i>Cập nhật trạng thái phòng ban thành công.</div>
</c:if>
<c:if test="${param.error eq 'not_found'}">
    <div class="flash flash-error"><i class="bi bi-exclamation-triangle-fill me-2"></i>Không tìm thấy phòng ban.</div>
</c:if>
<c:if test="${param.error eq 'delete_failed'}">
    <div class="flash flash-error"><i class="bi bi-exclamation-triangle-fill me-2"></i>Không thể xóa phòng ban (có thể đang được tham chiếu dữ liệu).</div>
</c:if>

<div class="stat-row">
    <a href="${pageContext.request.contextPath}/admin/departments" class="stat-card">
        <div class="stat-icon" style="background:#e8f4fd;"><i class="bi bi-diagram-3 text-primary"></i></div>
        <div><div class="stat-label">Tổng phòng ban</div><div class="stat-value">${total}</div></div>
    </a>
    <a href="${pageContext.request.contextPath}/admin/departments?status=ACTIVE" class="stat-card">
        <div class="stat-icon" style="background:#e0fff4;"><i class="bi bi-check-circle" style="color:#27ae60;"></i></div>
        <div><div class="stat-label">Active</div><div class="stat-value">${totalActive}</div></div>
    </a>
    <a href="${pageContext.request.contextPath}/admin/departments?status=INACTIVE" class="stat-card">
        <div class="stat-icon" style="background:#fff5f5;"><i class="bi bi-slash-circle" style="color:#c53030;"></i></div>
        <div><div class="stat-label">Inactive</div><div class="stat-value">${totalInactive}</div></div>
    </a>
</div>

<div class="filter-card">
    <form action="${pageContext.request.contextPath}/admin/departments" method="get" id="filterForm">
        <input type="hidden" name="action" value="list">
        <input type="hidden" name="page" id="filterPage" value="${currentPage}">
        <div class="filter-row">
            <div class="filter-group" style="min-width:280px; flex:1;">
                <label>Tìm kiếm</label>
                <input type="text" name="q" placeholder="Tên hoặc mã phòng ban..." value="${fn:escapeXml(keyword)}">
            </div>
            <div class="filter-group">
                <label>Trạng thái</label>
                <select name="status">
                    <option value="">Mọi trạng thái</option>
                    <option value="ACTIVE" ${statusFilter eq 'ACTIVE' ? 'selected' : ''}>Đang hoạt động</option>
                    <option value="INACTIVE" ${statusFilter eq 'INACTIVE' ? 'selected' : ''}>Ngừng hoạt động</option>
                </select>
            </div>
            <div class="filter-group">
                <label>Trưởng phòng</label>
                <select name="managerFilter">
                    <option value="">Tất cả phòng ban</option>
                    <option value="HAS_MANAGER" ${managerFilter eq 'HAS_MANAGER' ? 'selected' : ''}>Có trưởng phòng</option>
                    <option value="NO_MANAGER" ${managerFilter eq 'NO_MANAGER' ? 'selected' : ''}>Chưa có trưởng phòng</option>
                </select>
            </div>
            <div class="filter-group" style="flex-direction:row; gap:8px; align-items:flex-end; min-width:200px;">
                <button type="submit" class="btn btn-primary btn-sm px-3"><i class="bi bi-search me-1"></i>Tìm</button>
                <a href="${pageContext.request.contextPath}/admin/departments" class="btn btn-outline-secondary btn-sm px-3">Xóa lọc</a>
            </div>
        </div>
    </form>
</div>

<div class="table-card">
    <div class="table-responsive">
        <table class="dept-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Tên phòng ban</th>
                    <th>Mã</th>
                    <th>Trưởng phòng</th>
                    <th>Tổng người</th>
                    <th>Trạng thái</th>
                    <th class="text-center">Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="d" items="${departments}">
                    <tr>
                        <td>#${d.departmentId}</td>
                        <td>
                            <a class="dept-name" href="${pageContext.request.contextPath}/admin/departments?action=detail&id=${d.departmentId}">${d.departmentName}</a>
                        </td>
                        <td>${d.departmentCode}</td>
                        <td>${d.managerName != null ? d.managerName : 'Chưa có'}</td>
                        <td><span class="badge bg-info">${d.totalUsers}</span></td>
                        <td>
                            <span class="${d.status eq 'ACTIVE' ? 'status-on' : 'status-off'}">
                                <i class="bi bi-circle-fill" style="font-size:7px;"></i>
                                ${d.status eq 'ACTIVE' ? 'Active' : 'Inactive'}
                            </span>
                        </td>
                        <td class="text-center">
                            <div class="d-flex justify-content-center gap-1">
                                <a href="${pageContext.request.contextPath}/admin/departments?action=detail&id=${d.departmentId}"
                                   class="btn-icon bg-info" title="Chi tiết">
                                    <i class="bi bi-eye"></i>
                                </a>
                                <a href="${pageContext.request.contextPath}/admin/departments?action=edit&id=${d.departmentId}"
                                   class="btn-icon bg-warning" title="Chỉnh sửa">
                                    <i class="bi bi-pencil"></i>
                                </a>
                                <form action="${pageContext.request.contextPath}/admin/departments" method="post" class="d-inline">
                                    <input type="hidden" name="action" value="toggleStatus">
                                    <input type="hidden" name="id" value="${d.departmentId}">
                                    <input type="hidden" name="status" value="${d.status eq 'ACTIVE' ? 'INACTIVE' : 'ACTIVE'}">
                                    <button type="submit"
                                            class="btn-icon ${d.status eq 'ACTIVE' ? 'bg-secondary' : 'bg-success'}"
                                            onclick="return confirm('Bạn có chắc muốn đổi trạng thái phòng ban này?')"
                                            title="${d.status eq 'ACTIVE' ? 'Ngừng hoạt động' : 'Kích hoạt'}">
                                        <i class="bi ${d.status eq 'ACTIVE' ? 'bi-pause-circle' : 'bi-play-circle'}"></i>
                                    </button>
                                </form>
                                <form action="${pageContext.request.contextPath}/admin/departments" method="post" class="d-inline">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="${d.departmentId}">
                                    <button type="submit" class="btn-icon bg-danger"
                                            onclick="return confirm('Bạn có chắc chắn muốn xóa phòng ban này?')"
                                            title="Xóa">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty departments}">
                    <tr>
                        <td colspan="7" class="text-center text-muted py-5">Không có dữ liệu phòng ban.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
    <c:if test="${totalPages >= 1}">
        <div class="pager-row">
            <span class="text-muted small">
                Hiển thị <strong>${fromIdx}</strong> - <strong>${toIdx}</strong> trong <strong>${total}</strong> phòng ban
                · Trang <strong>${currentPage}</strong> / <strong>${totalPages}</strong>
            </span>
            <nav>
                <ul class="pagination pagination-sm mb-0">
                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="javascript:void(0)" onclick="goPage(${currentPage - 1})">‹</a>
                    </li>
                    <c:forEach var="i" begin="1" end="${totalPages}">
                        <c:if test="${i >= currentPage - 2 && i <= currentPage + 2}">
                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                <a class="page-link" href="javascript:void(0)" onclick="goPage(${i})">${i}</a>
                            </li>
                        </c:if>
                    </c:forEach>
                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="javascript:void(0)" onclick="goPage(${currentPage + 1})">›</a>
                    </li>
                </ul>
            </nav>
        </div>
    </c:if>
</div>

<script>
    function goPage(page) {
        document.getElementById('filterPage').value = page;
        document.getElementById('filterForm').submit();
    }
</script>

<jsp:include page="/common/admin-layout-bottom.jsp" />
