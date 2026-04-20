<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/includes/header.jsp">
    <jsp:param name="pageTitle" value="Chi tiết: ${ci.name}" />
</jsp:include>

<c:set var="canManage" value="${sessionScope.user.roleId == 8 || sessionScope.user.roleId == 10}" />

<style>
    .badge-type { font-size: 0.78rem; }
    .rel-badge  { font-size: 0.75rem; padding: 4px 10px; border-radius: 20px; }
    .impact-card { border-left: 4px solid #fd7e14; }
    .section-title { font-size: 1rem; font-weight: 600; color: #495057; }
</style>

<div class="container-fluid">

    <%-- ── Thông báo ── --%>
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

    <%-- ══════════════════════════════════════════════════════
         PANEL 1: Thông tin cơ bản
    ═══════════════════════════════════════════════════════ --%>
    <div class="card shadow-sm mb-4">
        <div class="card-header bg-white d-flex justify-content-between align-items-center py-3">
            <div>
                <h4 class="text-primary m-0">
                    <i class="bi bi-server me-2"></i>${ci.name}
                </h4>
                <small class="text-muted">Danh mục cấu hình — ID #${ci.ciId}</small>
            </div>
            <div class="d-flex gap-2">
                <a href="${pageContext.request.contextPath}/configuration-item"
                   class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-arrow-left me-1"></i> Quay lại
                </a>
                <c:if test="${canManage}">
                    <a href="${pageContext.request.contextPath}/configuration-item?action=edit&id=${ci.ciId}"
                       class="btn btn-warning btn-sm">
                        <i class="bi bi-pencil me-1"></i> Chỉnh sửa
                    </a>
                </c:if>
            </div>
        </div>

        <div class="card-body">
            <div class="row g-4">
                <div class="col-md-6">
                    <p class="section-title mb-3"><i class="bi bi-info-circle me-1"></i> Thông tin chung</p>
                    <table class="table table-sm table-borderless">
                        <tr>
                            <td class="text-muted fw-semibold" style="width:130px;">Loại:</td>
                            <td><span class="badge bg-info text-dark badge-type">${ci.type}</span></td>
                        </tr>
                        <tr>
                            <td class="text-muted fw-semibold">Phiên bản:</td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty ci.version}">${ci.version}</c:when>
                                    <c:otherwise><span class="text-muted fst-italic">—</span></c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                        <tr>
                            <td class="text-muted fw-semibold">Trạng thái:</td>
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
                        </tr>
                        <tr>
                            <td class="text-muted fw-semibold">Nhà cung cấp:</td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty ci.vendorName}">
                                        <strong>${ci.vendorName}</strong>
                                    </c:when>
                                    <c:otherwise><span class="text-muted fst-italic">—</span></c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                        <tr>
                            <td class="text-muted fw-semibold">Ngày tạo:</td>
                            <td><fmt:formatDate value="${ci.createdAt}" pattern="dd/MM/yyyy HH:mm" /></td>
                        </tr>
                        <tr>
                            <td class="text-muted fw-semibold">Cập nhật:</td>
                            <td><fmt:formatDate value="${ci.updatedAt}" pattern="dd/MM/yyyy HH:mm" /></td>
                        </tr>
                    </table>
                </div>

                <div class="col-md-6">
                    <p class="section-title mb-3"><i class="bi bi-card-text me-1"></i> Mô tả</p>
                    <c:choose>
                        <c:when test="${not empty ci.description}">
                            <div class="p-3 bg-light rounded border" style="white-space: pre-wrap;">${ci.description}</div>
                        </c:when>
                        <c:otherwise>
                            <p class="text-muted fst-italic">Chưa có mô tả.</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <%-- ══════════════════════════════════════════════════════
         PANEL 2: Phân tích tác động
    ═══════════════════════════════════════════════════════ --%>
    <div class="card shadow-sm mb-4 impact-card">
        <div class="card-header bg-white py-3">
            <h5 class="m-0 text-warning">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>
                Phân tích tác động — Điều gì xảy ra nếu CI này gặp sự cố?
            </h5>
            <small class="text-muted">
                Các mục cấu hình bên dưới <strong>phụ thuộc trực tiếp</strong> vào CI này.
                Nếu CI này ngừng hoạt động, chúng có thể bị ảnh hưởng.
            </small>
        </div>
        <div class="card-body pb-2">
            <c:choose>
                <c:when test="${not empty impactedCIs}">
                    <ul class="list-group list-group-flush">
                        <c:forEach var="imp" items="${impactedCIs}">
                            <li class="list-group-item d-flex justify-content-between align-items-center px-0">
                                <div>
                                    <i class="bi bi-diagram-2 me-2 text-warning"></i>
                                    <a href="${pageContext.request.contextPath}/configuration-item?action=detail&id=${imp.ciId}"
                                       class="fw-semibold text-decoration-none">${imp.name}</a>
                                    <span class="badge bg-info text-dark ms-2 badge-type">${imp.type}</span>
                                    <c:if test="${not empty imp.version}">
                                        <span class="text-muted small ms-1">v${imp.version}</span>
                                    </c:if>
                                </div>
                                <c:choose>
                                    <c:when test="${imp.status == 'ACTIVE'}">
                                        <span class="badge bg-success">Hoạt động</span>
                                    </c:when>
                                    <c:when test="${imp.status == 'INACTIVE'}">
                                        <span class="badge bg-warning text-dark">Không hoạt động</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary">${imp.status}</span>
                                    </c:otherwise>
                                </c:choose>
                            </li>
                        </c:forEach>
                    </ul>
                </c:when>
                <c:otherwise>
                    <div class="alert alert-success mb-0">
                        <i class="bi bi-check-circle-fill me-2"></i>
                        Không phát hiện CI nào phụ thuộc trực tiếp vào mục cấu hình này. Tác động bị cô lập.
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <%-- ══════════════════════════════════════════════════════
         PANEL 3: Quan hệ CI
    ═══════════════════════════════════════════════════════ --%>
    <div class="card shadow-sm mb-4">
        <div class="card-header bg-white d-flex justify-content-between align-items-center py-3">
            <h5 class="m-0">
                <i class="bi bi-diagram-2 me-2 text-secondary"></i>Quan hệ với các mục cấu hình khác
            </h5>
            <c:if test="${canManage}">
                <button type="button" class="btn btn-primary btn-sm"
                        data-bs-toggle="modal" data-bs-target="#addRelModal">
                    <i class="bi bi-link-45deg me-1"></i> Thêm quan hệ
                </button>
            </c:if>
        </div>

        <div class="card-body">
            <c:choose>
                <c:when test="${not empty relationships}">
                    <div class="table-responsive">
                        <table class="table table-hover table-bordered align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>CI Cha (Cung cấp)</th>
                                    <th class="text-center" style="width:200px;">Kiểu quan hệ</th>
                                    <th>CI Con (Phụ thuộc)</th>
                                    <th>Ghi chú</th>
                                    <th>Ngày tạo</th>
                                    <c:if test="${canManage}">
                                        <th class="text-center" style="width:80px;">Xóa</th>
                                    </c:if>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="rel" items="${relationships}">
                                    <tr>
                                        <td>
                                            <c:choose>
                                                <c:when test="${rel.parentCiId == ci.ciId}">
                                                    <span class="badge bg-primary me-1">CI này</span>
                                                    <strong>${rel.parentCiName}</strong>
                                                </c:when>
                                                <c:otherwise>
                                                    <a href="${pageContext.request.contextPath}/configuration-item?action=detail&id=${rel.parentCiId}"
                                                       class="text-decoration-none">${rel.parentCiName}</a>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center">
                                            <span class="badge rel-badge
                                                <c:choose>
                                                    <c:when test="${rel.relationshipType == 'DEPENDS_ON'}">bg-danger</c:when>
                                                    <c:when test="${rel.relationshipType == 'HOSTED_BY'}">bg-warning text-dark</c:when>
                                                    <c:when test="${rel.relationshipType == 'RUNS_ON'}">bg-info text-dark</c:when>
                                                    <c:when test="${rel.relationshipType == 'CONNECTED_TO'}">bg-primary</c:when>
                                                    <c:otherwise>bg-secondary</c:otherwise>
                                                </c:choose>">
                                                <i class="bi bi-arrow-right me-1"></i>${rel.relationshipTypeLabel}
                                            </span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${rel.childCiId == ci.ciId}">
                                                    <span class="badge bg-primary me-1">CI này</span>
                                                    <strong>${rel.childCiName}</strong>
                                                </c:when>
                                                <c:otherwise>
                                                    <a href="${pageContext.request.contextPath}/configuration-item?action=detail&id=${rel.childCiId}"
                                                       class="text-decoration-none">${rel.childCiName}</a>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-muted small">
                                            <c:choose>
                                                <c:when test="${not empty rel.description}">${rel.description}</c:when>
                                                <c:otherwise><span class="fst-italic">—</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-muted small">
                                            <fmt:formatDate value="${rel.createdAt}" pattern="dd/MM/yyyy" />
                                        </td>
                                        <c:if test="${canManage}">
                                            <td class="text-center">
                                                <form action="${pageContext.request.contextPath}/configuration-item"
                                                      method="POST" class="d-inline"
                                                      onsubmit="return confirm('Xóa quan hệ này?');">
                                                    <input type="hidden" name="action" value="deleteRelationship">
                                                    <input type="hidden" name="relationshipId" value="${rel.relationshipId}">
                                                    <input type="hidden" name="ciId" value="${ci.ciId}">
                                                    <button type="submit" class="btn btn-sm btn-outline-danger" title="Xóa quan hệ">
                                                        <i class="bi bi-x-lg"></i>
                                                    </button>
                                                </form>
                                            </td>
                                        </c:if>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="alert alert-secondary mb-0">
                        <i class="bi bi-info-circle me-2"></i>
                        Mục cấu hình này chưa có quan hệ nào với các mục khác trong CMDB.
                        <c:if test="${canManage}">
                            Nhấn <strong>Thêm quan hệ</strong> để bắt đầu.
                        </c:if>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

</div>

<%-- ══════════════════════════════════════════════════════
     MODAL: Thêm quan hệ
═══════════════════════════════════════════════════════ --%>
<c:if test="${canManage}">
<div class="modal fade" id="addRelModal" tabindex="-1" aria-labelledby="addRelModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <form action="${pageContext.request.contextPath}/configuration-item" method="POST">
            <input type="hidden" name="action"    value="addRelationship">
            <input type="hidden" name="parentCiId" value="${ci.ciId}">

            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title" id="addRelModalLabel">
                        <i class="bi bi-link-45deg me-2"></i>Thêm quan hệ mới
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <div class="p-2 bg-light rounded border mb-3">
                        <small class="text-muted">CI hiện tại (đóng vai trò Cha):</small><br>
                        <strong><i class="bi bi-server me-1 text-primary"></i>${ci.name}</strong>
                    </div>

                    <div class="mb-3">
                        <label for="relationshipType" class="form-label fw-semibold">
                            Kiểu quan hệ <span class="text-danger">*</span>
                        </label>
                        <select class="form-select" id="relationshipType" name="relationshipType" required>
                            <option value="">-- Chọn kiểu quan hệ --</option>
                            <option value="DEPENDS_ON">Phụ thuộc vào (DEPENDS_ON)</option>
                            <option value="CONNECTED_TO">Kết nối tới (CONNECTED_TO)</option>
                            <option value="RUNS_ON">Chạy trên (RUNS_ON)</option>
                            <option value="HOSTED_BY">Được lưu trữ bởi (HOSTED_BY)</option>
                            <option value="PART_OF">Là một phần của (PART_OF)</option>
                        </select>
                        <div class="form-text">
                            <strong>"CI cha" [kiểu quan hệ] → "CI con"</strong><br>
                            Ví dụ: <em>Máy chủ web</em> → DEPENDS_ON → <em>Database server</em>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label for="childCiId" class="form-label fw-semibold">
                            Kết nối tới (CI Con) <span class="text-danger">*</span>
                        </label>
                        <select class="form-select" id="childCiId" name="childCiId" required>
                            <option value="">-- Chọn mục cấu hình --</option>
                            <c:forEach var="other" items="${allCIs}">
                                <option value="${other.ciId}">[${other.type}] ${other.name}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label for="relDescription" class="form-label fw-semibold">Ghi chú</label>
                        <textarea class="form-control" id="relDescription" name="relDescription"
                                  rows="2" maxlength="500"
                                  placeholder="Mô tả ngắn về quan hệ này (tùy chọn)..."></textarea>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-diagram-2 me-1"></i> Tạo quan hệ
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>
</c:if>

<jsp:include page="/includes/footer.jsp" />
