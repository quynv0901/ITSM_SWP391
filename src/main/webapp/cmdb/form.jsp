<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/includes/header.jsp">
    <jsp:param name="pageTitle" value="${empty ci || isNew ? 'Thêm mục cấu hình' : 'Chỉnh sửa mục cấu hình'}" />
</jsp:include>

<style>
    .form-label .required { color: #dc3545; }
    .char-counter { font-size: 0.78rem; color: #6c757d; text-align: right; }
    .char-counter.warning   { color: #fd7e14; font-weight: 600; }
    .char-counter.over-limit { color: #dc3545; font-weight: 700; }
    .field-hint { font-size: 0.8rem; color: #6c757d; margin-top: 3px; }
</style>

<div class="container-fluid">
    <div class="row justify-content-center">
        <div class="col-lg-7 col-md-9">
            <div class="bg-white rounded shadow-sm p-4">

                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h4 class="text-primary m-0">
                        <i class="bi bi-server me-2"></i>
                        <c:choose>
                            <c:when test="${empty ci || isNew}">Thêm mục cấu hình mới</c:when>
                            <c:otherwise>Chỉnh sửa mục cấu hình #${ci.ciId}</c:otherwise>
                        </c:choose>
                    </h4>
                    <a href="${pageContext.request.contextPath}/configuration-item"
                       class="btn btn-outline-secondary btn-sm">
                        <i class="bi bi-arrow-left me-1"></i> Quay lại danh sách
                    </a>
                </div>

                <c:if test="${not empty errorMsg}">
                    <div class="alert alert-danger d-flex align-items-center" role="alert">
                        <i class="bi bi-exclamation-triangle-fill me-2 flex-shrink-0"></i>
                        <div>${errorMsg}</div>
                    </div>
                </c:if>

                <form id="ciForm" action="${pageContext.request.contextPath}/configuration-item"
                      method="POST" novalidate>
                    <input type="hidden" name="action" value="${empty ci || isNew ? 'add' : 'edit'}">
                    <c:if test="${not empty ci && !isNew}">
                        <input type="hidden" name="id" value="${ci.ciId}">
                    </c:if>

                    <%-- Tên --%>
                    <div class="mb-3">
                        <label for="name" class="form-label fw-semibold">
                            Tên <span class="required">*</span>
                        </label>
                        <input type="text" class="form-control" id="name" name="name"
                               maxlength="100" autocomplete="off"
                               value="${ci.name}" placeholder="Ví dụ: Máy chủ cơ sở dữ liệu chính"
                               oninput="updateCounter('name', 100)">
                        <div class="d-flex justify-content-between">
                            <div class="field-hint">Chữ cái, số và ký tự cơ bản (. - _ ( ) / #).</div>
                            <div id="name-counter" class="char-counter">0 / 100</div>
                        </div>
                        <div class="invalid-feedback" id="name-error"></div>
                    </div>

                    <%-- Loại --%>
                    <div class="mb-3">
                        <label for="type" class="form-label fw-semibold">
                            Loại <span class="required">*</span>
                        </label>
                        <select class="form-select" id="type" name="type">
                            <option value="" disabled ${empty ci.type ? 'selected' : ''}>Chọn loại mục cấu hình...</option>
                            <option value="Hardware" ${ci.type == 'Hardware' ? 'selected' : ''}>Phần cứng (Hardware)</option>
                            <option value="Software" ${ci.type == 'Software' ? 'selected' : ''}>Phần mềm (Software)</option>
                            <option value="Network"  ${ci.type == 'Network'  ? 'selected' : ''}>Mạng (Network)</option>
                            <option value="Service"  ${ci.type == 'Service'  ? 'selected' : ''}>Dịch vụ (Service)</option>
                            <option value="Other"    ${ci.type == 'Other'    ? 'selected' : ''}>Khác (Other)</option>
                        </select>
                        <div class="invalid-feedback" id="type-error"></div>
                    </div>

                    <%-- Phiên bản --%>
                    <div class="mb-3">
                        <label for="version" class="form-label fw-semibold">Phiên bản</label>
                        <input type="text" class="form-control" id="version" name="version"
                               maxlength="50" autocomplete="off"
                               value="${ci.version}" placeholder="Ví dụ: v2.0, Ubuntu 22.04"
                               oninput="updateCounter('version', 50)">
                        <div class="d-flex justify-content-between">
                            <div class="field-hint">Tùy chọn. Tối đa 50 ký tự.</div>
                            <div id="version-counter" class="char-counter">0 / 50</div>
                        </div>
                    </div>

                    <%-- Trạng thái --%>
                    <div class="mb-3">
                        <label for="status" class="form-label fw-semibold">
                            Trạng thái <span class="required">*</span>
                        </label>
                        <select class="form-select" id="status" name="status">
                            <option value="ACTIVE"   ${ci.status == 'ACTIVE'   || empty ci.status ? 'selected' : ''}>Hoạt động</option>
                            <option value="INACTIVE" ${ci.status == 'INACTIVE' ? 'selected' : ''}>Không hoạt động</option>
                            <option value="RETIRED"  ${ci.status == 'RETIRED'  ? 'selected' : ''}>Đã loại bỏ</option>
                        </select>
                    </div>

                    <%-- Nhà cung cấp --%>
                    <div class="mb-3">
                        <label for="vendorId" class="form-label fw-semibold">
                            Nhà cung cấp <span class="required">*</span>
                        </label>
                        <select class="form-select" id="vendorId" name="vendorId" required>
                            <option value="" disabled ${empty ci.vendorId ? 'selected' : ''}>-- Chọn nhà cung cấp --</option>
                            <c:forEach var="v" items="${vendors}">
                                <option value="${v.vendorId}" ${ci.vendorId == v.vendorId ? 'selected' : ''}>${v.name}</option>
                            </c:forEach>
                        </select>
                        <div class="invalid-feedback" id="vendorId-error"></div>
                        <div class="form-text text-muted small">Đối tác quản lý hoặc cung cấp tài sản/dịch vụ này.</div>
                    </div>

                    <%-- Mô tả --%>
                    <div class="mb-4">
                        <label for="description" class="form-label fw-semibold">Mô tả</label>
                        <textarea class="form-control" id="description" name="description"
                                  rows="4" maxlength="2000"
                                  placeholder="Mô tả ngắn về mục cấu hình này..."
                                  oninput="updateCounter('description', 2000)">${ci.description}</textarea>
                        <div class="d-flex justify-content-between">
                            <div class="field-hint">Tùy chọn. Tối đa 2000 ký tự.</div>
                            <div id="description-counter" class="char-counter">0 / 2000</div>
                        </div>
                    </div>

                    <div class="d-flex justify-content-end gap-2">
                        <a href="${pageContext.request.contextPath}/configuration-item"
                           class="btn btn-secondary">
                            <i class="bi bi-x-circle me-1"></i>Hủy
                        </a>
                        <button type="submit" id="submitBtn" class="btn btn-primary">
                            <i class="bi bi-save me-1"></i>
                            <c:choose>
                                <c:when test="${empty ci || isNew}">Lưu mục cấu hình</c:when>
                                <c:otherwise>Cập nhật</c:otherwise>
                            </c:choose>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    function updateCounter(fieldId, maxLen) {
        const field   = document.getElementById(fieldId);
        const counter = document.getElementById(fieldId + '-counter');
        if (!field || !counter) return;
        const len   = field.value.length;
        const ratio = len / maxLen;
        counter.textContent = len.toLocaleString('vi-VN') + ' / ' + maxLen.toLocaleString('vi-VN');
        counter.classList.remove('warning', 'over-limit');
        if (ratio >= 1)         counter.classList.add('over-limit');
        else if (ratio >= 0.85) counter.classList.add('warning');
    }

    window.addEventListener('DOMContentLoaded', function () {
        updateCounter('name',        100);
        updateCounter('version',      50);
        updateCounter('description', 2000);
    });

    document.getElementById('ciForm').addEventListener('submit', function (e) {
        let valid = true;
        clearErrors();

        const name    = document.getElementById('name').value.trim();
        const type    = document.getElementById('type').value;
        const version  = document.getElementById('version').value.trim();
        const vendorId = document.getElementById('vendorId').value;
        const desc     = document.getElementById('description').value.trim();
        const namePattern = /^[\p{L}0-9 .\-_()\/#]+$/u;

        if (name === '') {
            showError('name', 'Tên là bắt buộc.');
            valid = false;
        } else if (name.length > 100) {
            showError('name', 'Tên không được vượt quá 100 ký tự.');
            valid = false;
        } else if (!namePattern.test(name)) {
            showError('name', 'Tên chứa ký tự không hợp lệ. Chỉ chấp nhận chữ cái, số và ký tự cơ bản (. - _ ( ) / #).');
            valid = false;
        }

        if (!type) {
            showError('type', 'Vui lòng chọn loại mục cấu hình.');
            valid = false;
        }

        if (!vendorId) {
            showError('vendorId', 'Vui lòng chọn Nhà cung cấp.');
            valid = false;
        }

        if (version.length > 50) {
            showError('version', 'Phiên bản không được vượt quá 50 ký tự.');
            valid = false;
        }

        if (desc.length > 2000) {
            showError('description', 'Mô tả không được vượt quá 2000 ký tự.');
            valid = false;
        }

        if (!valid) {
            e.preventDefault();
            window.scrollTo({ top: 0, behavior: 'smooth' });
        }
    });

    function showError(fieldId, message) {
        const field = document.getElementById(fieldId);
        const errEl = document.getElementById(fieldId + '-error');
        if (field)  field.classList.add('is-invalid');
        if (errEl)  errEl.textContent = message;
    }

    function clearErrors() {
        document.querySelectorAll('.is-invalid').forEach(el => el.classList.remove('is-invalid'));
        document.querySelectorAll('.invalid-feedback').forEach(el => el.textContent = '');
    }
</script>

<jsp:include page="/includes/footer.jsp" />
