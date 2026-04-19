<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    .breadcrumb-custom {
        display: flex;
        justify-content: flex-end;
        font-size: 0.9rem;
        color: #666;
        margin-bottom: 20px;
    }
    .action-bar {
        display: flex;
        gap: 15px;
        margin-bottom: 20px;
    }
    .btn-add-staff {
        background-color: #00bcd4;
        color: white;
        border: none;
        padding: 8px 15px;
        border-radius: 4px;
        display: flex;
        align-items: center;
        gap: 8px;
        font-weight: 500;
    }
    .btn-manage-dept {
        background-color: #f39c12;
        color: white;
        border: none;
        padding: 8px 15px;
        border-radius: 4px;
        display: flex;
        align-items: center;
        gap: 8px;
        font-weight: 500;
    }
    .search-panel {
        background: #fff;
        padding: 15px;
        border: 1px solid #ddd;
        border-radius: 4px;
        margin-bottom: 20px;
        display: flex;
        gap: 15px;
    }
    .search-input {
        flex: 1;
        max-width: 300px;
    }
    .table-container {
        background: #fff;
        border: 1px solid #ddd;
        border-radius: 4px;
        overflow-x: auto;
    }
    .admin-table thead {
        background-color: #3c8dbc;
        color: white;
    }
    .admin-table th {
        font-weight: 500;
        border-bottom: none;
    }
    .admin-table td {
        vertical-align: middle;
        padding: 12px;
    }
    .badge-active {
        background-color: #00bcd4;
        color: white;
        padding: 5px 12px;
        border-radius: 50px;
        font-size: 0.75rem;
        font-weight: bold;
    }
    .btn-action-edit {
        background-color: #f39c12;
        color: white;
        border: none;
        padding: 5px 10px;
        border-radius: 4px;
    }
    .btn-action-delete {
        background-color: #dd4b39;
        color: white;
        border: none;
        padding: 5px 10px;
        border-radius: 4px;
    }
    /* Toggle Switch */
    .switch {
        position: relative;
        display: inline-block;
        width: 34px;
        height: 20px;
    }
    .switch input {
        opacity: 0;
        width: 0;
        height: 0;
    }
    .slider {
        position: absolute;
        cursor: pointer;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background-color: #ccc;
        transition: .4s;
        border-radius: 34px;
    }
    .slider:before {
        position: absolute;
        content: "";
        height: 14px;
        width: 14px;
        left: 3px;
        bottom: 3px;
        background-color: white;
        transition: .4s;
        border-radius: 50%;
    }
    input:checked + .slider {
        background-color: #00bcd4;
    }
    input:checked + .slider:before {
        transform: translateX(14px);
    }
</style>
<%@include file="../common/admin-layout-top.jsp" %>
<div class="breadcrumb-custom">
    <i class="bi bi-house-door me-1"></i> Trang chủ > Nhân viên
</div>

<div class="action-bar">
    <button class="btn-add-staff" data-bs-toggle="modal" data-bs-target="#addUserModal">
        <i class="bi bi-pencil-square"></i> Thêm nhân viên
    </button>
    <button class="btn-manage-dept"><i class="bi bi-search"></i> Quản lý bộ phận</button>
</div>

<form id="filterForm" action="${pageContext.request.contextPath}/admin/users" method="get">
    <div class="search-panel shadow-sm">
        <input type="text" name="search" class="form-control search-input" placeholder="Tên, Email,..." value="${search}">
        <select name="roleId" class="form-select" style="max-width: 150px;">
            <option value="">Tất cả Vai trò</option>
            <c:forEach var="r" items="${roles}">
                <option value="${r.roleId}" ${roleId == r.roleId ? 'selected' : ''}>${r.roleName}</option>
            </c:forEach>
        </select>
        <select name="deptId" class="form-select" style="max-width: 150px;">
            <option value="">Tất cả Phòng ban</option>
            <c:forEach var="d" items="${departments}">
                <option value="${d.departmentId}" ${deptId == d.departmentId ? 'selected' : ''}>${d.departmentName}</option>
            </c:forEach>
        </select>
        <button type="submit" class="btn btn-primary px-4"><i class="bi bi-search"></i></button>
        <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline-secondary">Tải lại trang</a>

        <input type="hidden" name="sortBy" id="sortBy" value="${sortBy}">
        <input type="hidden" name="order" id="order" value="${order}">
    </div>
</form>

<div class="table-container shadow-sm">
    <table class="table admin-table mb-0">
        <thead>
            <tr>
                <th><a href="javascript:void(0)" onclick="setSort('user_id')" class="text-dark text-decoration-none">ID <i class="bi bi-sort-numeric-down"></i></a></th>
                <th><a href="javascript:void(0)" onclick="setSort('full_name')" class="text-dark text-decoration-none">Họ tên <i class="bi bi-sort-alpha-down"></i></a></th>
                <th><a href="javascript:void(0)" onclick="setSort('email')" class="text-dark text-decoration-none">Email <i class="bi bi-sort-alpha-down"></i></a></th>
                <th>SĐT</th>
                <th>Phòng ban</th>
                <th>Vai trò</th>
                <th>Trạng thái</th>
                <th>Thao tác</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="u" items="${userList}">
                <tr>
                    <td class="text-muted">#${u.userId}</td>
                    <td class="text-primary fw-bold">${u.fullName}</td>
                    <td>${u.email}</td>
                    <td>${u.phone}</td>
                    <td>${u.departmentName != null ? u.departmentName : 'N/A'}</td>
                    <td><span class="badge bg-secondary">${u.roleName}</span></td>
                    <td>
                        <div class="d-flex align-items-center gap-2">
                            <span class="badge ${u.isActive ? 'bg-info' : 'bg-danger'}">${u.isActive ? 'Hoạt động' : 'Không hoạt động'}</span>
                            <label class="switch">
                                <input type="checkbox" ${u.isActive ? 'checked' : ''} 
                                       onclick="handleStatusToggle('${u.userId}', ${u.isActive})">
                                <span class="slider"></span>
                            </label>
                        </div>
                    </td>
                    <td>
                        <div class="d-flex gap-2">
                            <button class="btn-action-edit" onclick="editUser(${u.userId})"><i class="bi bi-pencil"></i></button>
                            <button class="btn-action-delete" onclick="handleDelete('${u.userId}')"><i class="bi bi-trash"></i></button>
                        </div>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>

    <div class="p-3 bg-light border-top d-flex justify-content-between align-items-center">
        <span class="text-muted small">Trang ${currentPage} / ${totalPages}</span>

        <nav>
            <ul class="pagination pagination-sm mb-0">
                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                    <a class="page-link" href="javascript:void(0)" onclick="handlePageChange(${currentPage - 1})">Trước</a>
                </li>
                <c:forEach var="i" begin="1" end="${totalPages}">
                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                        <a class="page-link" href="javascript:void(0)" onclick="handlePageChange(${i})">${i}</a>
                    </li>
                </c:forEach>
                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                    <a class="page-link" href="javascript:void(0)" onclick="handlePageChange(${currentPage + 1})">Sau</a>
                </li>
            </ul>
        </nav>
    </div>
</div>

<!-- Add User Modal -->
<div class="modal fade" id="addUserModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content border-0 shadow">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title">Thêm nhân viên mới</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/users?action=add" method="post">
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label fw-bold">Họ và tên</label>
                        <input type="text" name="fullName" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Email</label>
                        <input type="email" name="email" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Tên đăng nhập</label>
                        <input type="text" name="username" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Mật khẩu</label>
                        <input type="password" name="password" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Vai trò</label>
                        <select name="roleId" class="form-select" required>
                            <c:forEach var="r" items="${roles}">
                                <option value="${r.roleId}">${r.roleName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Bộ phận</label>
                        <select name="deptId" class="form-select">
                            <option value="">-- Chọn bộ phận --</option>
                            <c:forEach var="d" items="${departments}">
                                <option value="${d.departmentId}">${d.departmentName}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary px-4">Lưu lại</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Edit User Modal -->
<div class="modal fade" id="editUserModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content border-0 shadow">
            <div class="modal-header bg-warning text-dark">
                <h5 class="modal-title">Chỉnh sửa nhân viên</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/users?action=update" method="post">
                <input type="hidden" name="userId" id="editUserId">
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label fw-bold">Họ và tên</label>
                        <input type="text" name="fullName" id="editFullName" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Email</label>
                        <input type="email" name="email" id="editEmail" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Vai trò</label>
                        <select name="roleId" id="editRoleId" class="form-select" required>
                            <c:forEach var="r" items="${roles}">
                                <option value="${r.roleId}">${r.roleName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Bộ phận</label>
                        <select name="deptId" id="editDeptId" class="form-select">
                            <option value="">-- Chọn bộ phận --</option>
                            <c:forEach var="d" items="${departments}">
                                <option value="${d.departmentId}">${d.departmentName}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-warning px-4">Cập nhật</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    function editUser(userId) {
        fetch('${pageContext.request.contextPath}/admin/users?action=getInfo&id=' + userId)
                .then(response => {
                    if (!response.ok)
                        throw new Error('Network response was not ok');
                    return response.json();
                })
                .then(data => {
                    document.getElementById('editUserId').value = data.userId;
                    document.getElementById('editFullName').value = data.fullName;
                    document.getElementById('editEmail').value = data.email;
                    document.getElementById('editRoleId').value = data.roleId;
                    document.getElementById('editDeptId').value = data.departmentId || "";

                    // Use existing modal instance if possible or create new
                    let modalEl = document.getElementById('editUserModal');
                    let modal = bootstrap.Modal.getInstance(modalEl);
                    if (!modal)
                        modal = new bootstrap.Modal(modalEl);
                    modal.show();
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Không thể tải thông tin người dùng. Vui lòng thử lại!');
                });
    }
    function handleStatusToggle(userId, currentStatus) {
        toggleUserStatus(userId, !currentStatus);
    }

    function handleDelete(userId) {
        deleteUser(userId);
    }

    function handlePageChange(page) {
        setPage(page);
    }

    function toggleUserStatus(userId, status) {
        window.location.href = '${pageContext.request.contextPath}/admin/users?action=toggle&id=' + userId + '&status=' + status;
    }

// deleteUser
    function deleteUser(userId) {
        if (confirm('Xóa người dùng này?')) {
            window.location.href = '${pageContext.request.contextPath}/admin/users?action=delete&id=' + userId;
        }
    }

    function setSort(field) {
        let currentSort = document.getElementById('sortBy').value;
        let currentOrder = document.getElementById('order').value;

        if (currentSort === field) {
            document.getElementById('order').value = (currentOrder === 'ASC') ? 'DESC' : 'ASC';
        } else {
            document.getElementById('sortBy').value = field;
            document.getElementById('order').value = 'ASC';
        }
        document.getElementById('filterForm').submit();
    }

    function setPage(page) {
        let urlParams = new URLSearchParams(window.location.search);
        urlParams.set('page', page);
        window.location.search = urlParams.toString();
    }
</script>

<jsp:include page="/common/admin-layout-bottom.jsp" />
