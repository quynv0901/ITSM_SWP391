<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<jsp:include page="/includes/header.jsp">
    <jsp:param name="pageTitle" value="Danh mục cấu hình (CMDB)" />
</jsp:include>

<c:set var="canManage"
       value="${sessionScope.user.roleId == 8 || sessionScope.user.roleId == 10}" />

<div class="container-fluid bg-white p-4 rounded shadow-sm">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="h4 text-primary m-0">
                <i class="bi bi-server me-2"></i>Danh mục cấu hình (CMDB)
            </h2>
            <small class="text-muted">
                <c:choose>
                    <c:when test="${canManage}">
                        Bạn có quyền <strong>quản lý toàn phần</strong> module này.
                    </c:when>
                    <c:otherwise>
                        Bạn chỉ có quyền <strong>xem</strong>. Liên hệ Quản lý tài sản để thay đổi.
                    </c:otherwise>
                </c:choose>
            </small>
        </div>
        <c:if test="${canManage}">
            <a href="${pageContext.request.contextPath}/configuration-item?action=add"
               class="btn btn-primary">
                <i class="bi bi-plus-circle me-1"></i> Thêm mục cấu hình
            </a>
        </c:if>
    </div>

    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i>${sessionScope.successMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="successMessage" scope="session" />
    </c:if>
    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>${sessionScope.errorMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="errorMessage" scope="session" />
    </c:if>

    <form action="${pageContext.request.contextPath}/configuration-item" method="GET"
          class="bg-light p-3 rounded mb-4 border d-flex gap-3 align-items-center flex-wrap">
        <input type="hidden" name="action" value="list">
        <div class="flex-grow-1">
            <input type="text" name="q" value="${q}" class="form-control"
                   placeholder="Tìm theo tên, loại, phiên bản hoặc mô tả...">
        </div>
        <div style="width: 200px;">
            <select name="status" class="form-select">
                <option value="">Tất cả trạng thái</option>
                <option value="ACTIVE"   ${status == 'ACTIVE'   ? 'selected' : ''}>Hoạt động</option>
                <option value="INACTIVE" ${status == 'INACTIVE' ? 'selected' : ''}>Không hoạt động</option>
                <option value="RETIRED"  ${status == 'RETIRED'  ? 'selected' : ''}>Đã loại bỏ</option>
            </select>
        </div>
        <button type="submit" class="btn btn-primary"><i class="bi bi-search me-1"></i>Tìm kiếm</button>
        <a href="${pageContext.request.contextPath}/configuration-item"
           class="btn btn-outline-secondary">Xóa bộ lọc</a>
    </form>

    <div class="table-responsive">
        <table class="table table-hover table-bordered align-middle">
            <thead class="table-dark">
                <tr>
                    <th style="width:60px;">ID</th>
                    <th>Tên</th>
                    <th>Loại</th>
                    <th>Phiên bản</th>
                    <th>Trạng thái</th>
                    <th>Ngày tạo</th>
                    <th class="text-center" style="width:150px;">Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="ci" items="${ciList}">
                    <tr>
                        <td>${ci.ciId}</td>
                        <td><strong>${ci.name}</strong></td>
                        <td><span class="badge bg-info text-dark">${ci.type}</span></td>
                        <td>
                            <c:choose>
                                <c:when test="${not empty ci.version}">${ci.version}</c:when>
                                <c:otherwise><span class="text-muted fst-italic">—</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${ci.status == 'ACTIVE'}">
                                    <span class="badge bg-success">Hoạt động</span>
                                </c:when>
                                <c:when test="${ci.status == 'INACTIVE'}">
                                    <span class="badge bg-warning text-dark">Không hoạt động</span>
                                </c:when>
                                <c:when test="${ci.status == 'RETIRED'}">
                                    <span class="badge bg-secondary">Đã loại bỏ</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-light text-dark">${ci.status}</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>${ci.createdAt}</td>
                        <td class="text-center">
                            <a href="${pageContext.request.contextPath}/configuration-item?action=detail&id=${ci.ciId}"
                               class="btn btn-sm btn-outline-info" title="Xem chi tiết">
                                <i class="bi bi-eye"></i>
                            </a>
                            <c:if test="${canManage}">
                                <a href="${pageContext.request.contextPath}/configuration-item?action=edit&id=${ci.ciId}"
                                   class="btn btn-sm btn-outline-primary" title="Chỉnh sửa">
                                    <i class="bi bi-pencil-square"></i>
                                </a>
                                <form action="${pageContext.request.contextPath}/configuration-item"
                                      method="POST" class="d-inline"
                                      onsubmit="return confirm('Bạn có chắc muốn xóa mục cấu hình này không?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="${ci.ciId}">
                                    <button type="submit" class="btn btn-sm btn-outline-danger" title="Xóa">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </form>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty ciList}">
                    <tr>
                        <td colspan="7"
                            class="text-center text-muted fst-italic py-4">
                            <i class="bi bi-inbox me-2"></i>Không tìm thấy mục cấu hình nào.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>

    <%-- Phân trang --%>
    <c:if test="${totalPages > 1}">
        <div class="card-footer bg-white border-top-0 py-3 d-flex justify-content-between align-items-center px-4">
            <span class="text-muted small">Tổng <strong>${totalItems}</strong> mục</span>
            <nav>
                <ul class="pagination pagination-sm mb-0">
                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${currentPage - 1}&q=${q}&status=${status}">‹</a>
                    </li>
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <li class="page-item ${currentPage == i ? 'active' : ''}">
                            <a class="page-link" href="?page=${i}&q=${q}&status=${status}">${i}</a>
                        </li>
                    </c:forEach>
                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${currentPage + 1}&q=${q}&status=${status}">›</a>
                    </li>
                </ul>
            </nav>
        </div>
    </c:if>
</div>

<jsp:include page="/includes/footer.jsp" />
