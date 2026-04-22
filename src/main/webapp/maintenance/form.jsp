<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/common/admin-layout-top.jsp" />

<style>
    /* Live search CI */
    .ci-search-wrapper { position: relative; }
    .ci-search-wrapper .ci-search-input {
        border-radius: 0.375rem 0.375rem 0 0;
        border-bottom: 0;
    }
    .ci-search-wrapper select.form-select {
        border-radius: 0 0 0.375rem 0.375rem;
    }
</style>

<div class="container-fluid px-4 py-4">
    <%-- Header --%>
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h3 class="mb-1 fw-bold text-dark">
                <i class="bi bi-tools text-primary me-2"></i>
                ${log != null ? 'Cập nhật Nhật ký Bảo trì' : 'Tạo Nhật ký Bảo trì'}
            </h3>
            <p class="text-muted mb-0">Ghi nhận sự kiện bảo trì và theo dõi tiến độ xử lý.</p>
        </div>
        <a href="${pageContext.request.contextPath}/maintenance-log" class="btn btn-outline-secondary shadow-sm">
            <i class="bi bi-arrow-left me-2"></i>Quay lại danh sách
        </a>
    </div>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show shadow-sm mb-4" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>${errorMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="row">
        <%-- Cột form chính --%>
        <div class="col-lg-8">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white py-3 border-bottom">
                    <h5 class="card-title mb-0 fw-bold">Thông tin Bảo trì</h5>
                </div>
                <div class="card-body p-4">
                    <form action="${pageContext.request.contextPath}/maintenance-log" method="POST"
                          id="maintenanceForm" novalidate>
                        <input type="hidden" name="action" value="save">
                        <input type="hidden" name="logId" value="${log != null ? log.logId : ''}">

                        <%-- Thiết bị với live search --%>
                        <div class="mb-4">
                            <label class="form-label fw-semibold">
                                Thiết bị cần bảo trì <span class="text-danger">*</span>
                            </label>
                            <%-- Search box lọc options --%>
                            <div class="input-group mb-1">
                                <span class="input-group-text bg-light"><i class="bi bi-search text-muted"></i></span>
                                <input type="text" class="form-control" id="ciSearchInput"
                                       placeholder="Gõ để lọc thiết bị..." autocomplete="off"
                                       onkeydown="if(event.key === 'Enter') { event.preventDefault(); return false; }">
                            </div>
                            <%-- Dropdown bình thường --%>
                            <select class="form-select" id="ciId" name="ciId" required
                                    onchange="onCiChange(this.value)">
                                <option value="">-- Chọn thiết bị từ CMDB --</option>
                                <c:forEach var="ci" items="${cis}">
                                    <option value="${ci.ciId}"
                                            data-status="${ci.status}"
                                            ${log != null && log.ciId == ci.ciId ? 'selected' : ''}>
                                        ${ci.name} [${ci.type}]<c:if test="${ci.status == 'INACTIVE'}"> ⚠ INACTIVE</c:if>
                                    </option>
                                </c:forEach>
                            </select>
                            <div class="form-text mt-1">
                                <i class="bi bi-info-circle me-1"></i>
                                Thiết bị có dấu ⚠ đang ngừng hoạt động — ưu tiên tạo nhật ký.
                            </div>
                        </div>

                        <%-- Loại bảo trì + Ngày --%>
                        <div class="row mb-4">
                            <div class="col-md-6">
                                <label for="maintenanceType" class="form-label fw-semibold">
                                    Loại bảo trì <span class="text-danger">*</span>
                                </label>
                                <input type="text" class="form-control" id="maintenanceType" name="maintenanceType"
                                       list="typeSuggestions"
                                       placeholder="Nhập hoặc chọn gợi ý..."
                                       maxlength="200"
                                       value="${log != null ? log.maintenanceType : ''}" required>
                                <datalist id="typeSuggestions">
                                    <option value="Vá lỗi bảo mật">
                                    <option value="Cập nhật Firmware">
                                    <option value="Nâng cấp phần cứng">
                                    <option value="Bảo dưỡng định kỳ">
                                    <option value="Thay thế linh kiện">
                                    <option value="Cài đặt lại hệ điều hành">
                                    <option value="Khắc phục sự cố mạng">
                                    <option value="Vệ sinh và kiểm tra">
                                    <option value="Cập nhật phần mềm">
                                    <option value="Thay thế thiết bị hỏng">
                                    <option value="Mở rộng dung lượng lưu trữ">
                                    <option value="Kiểm tra nguồn điện / UPS">
                                    <option value="Sao lưu và khôi phục dữ liệu">
                                </datalist>
                                <div class="form-text">Nhập tự do hoặc chọn từ gợi ý, tối đa 200 ký tự.</div>
                            </div>
                            <div class="col-md-6">
                                <label for="maintenanceDate" class="form-label fw-semibold">
                                    Ngày thực hiện / Lên lịch <span class="text-danger">*</span>
                                </label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light"><i class="bi bi-calendar-date"></i></span>
                                    <input type="date" class="form-control" id="maintenanceDate" name="maintenanceDate"
                                           value="${log != null ? log.maintenanceDate : ''}" required>
                                </div>
                                <div class="form-text">
                                    Ngày đã thực hiện hoặc ngày lên lịch bảo trì tương lai.
                                </div>
                            </div>
                        </div>

                        <%-- Trạng thái xử lý --%>
                        <div class="mb-4">
                            <label for="status" class="form-label fw-semibold">Trạng thái xử lý</label>
                            <select class="form-select" id="status" name="status">
                                <option value="PENDING"
                                        ${log == null || log.status == 'PENDING' ? 'selected' : ''}>
                                    Chờ xử lý
                                </option>
                                <option value="CONTACTED_VENDOR"
                                        ${log != null && log.status == 'CONTACTED_VENDOR' ? 'selected' : ''}>
                                    Đã liên hệ nhà cung cấp
                                </option>
                                <option value="IN_PROGRESS"
                                        ${log != null && log.status == 'IN_PROGRESS' ? 'selected' : ''}>
                                    Đang tiến hành
                                </option>
                                <option value="COMPLETED"
                                        ${log != null && log.status == 'COMPLETED' ? 'selected' : ''}>
                                    Đã hoàn thành
                                </option>
                            </select>
                            
                            <%-- Checkbox tự động khôi phục trạng thái CI, hiển thị khi Hoàn thành --%>
                            <div class="form-check mt-2" id="autoActiveDiv" style="display: none;">
                                <input class="form-check-input" type="checkbox" value="true" id="autoActiveCi" name="autoActiveCi" checked>
                                <label class="form-check-label text-success fw-medium" for="autoActiveCi">
                                    <i class="bi bi-arrow-clockwise me-1"></i> Tự động cập nhật trạng thái thiết bị thành ACTIVE
                                </label>
                            </div>

                            <div class="form-text mt-1">
                                <strong>Downtime thực tế</strong> được tính từ lúc <span class="text-primary">Đang tiến hành</span> đến lúc <span class="text-success">Hoàn thành</span>.
                            </div>
                        </div>

                        <%-- Chi tiết công việc --%>
                        <div class="mb-2">
                            <label for="description" class="form-label fw-semibold">
                                Chi tiết công việc <span class="text-danger">*</span>
                                <span class="text-muted fw-normal small">(ít nhất 10 ký tự)</span>
                            </label>
                            <textarea class="form-control" id="description" name="description" rows="5"
                                      maxlength="3000"
                                      placeholder="Mô tả chi tiết: vấn đề phát sinh, các bước xử lý, linh kiện đã thay, phiên bản đã cập nhật..."
                                      required>${log != null ? log.description : ''}</textarea>
                            <div class="d-flex justify-content-between mt-1">
                                <div class="form-text">Tối đa 3000 ký tự.</div>
                                <div class="form-text" id="descCounter">0 / 3000</div>
                            </div>
                        </div>

                    </form>
                </div>
                <div class="card-footer bg-light px-4 py-3 text-end">
                    <a href="${pageContext.request.contextPath}/maintenance-log" class="btn btn-light border me-2">
                        Hủy bỏ
                    </a>
                    <button type="submit" form="maintenanceForm" class="btn btn-primary px-4 shadow-sm">
                        <i class="bi bi-save me-1"></i>Lưu nhật ký
                    </button>
                </div>
            </div>
        </div>

        <%-- Cột phụ: quy trình + thông tin NCC --%>
        <div class="col-lg-4 mt-4 mt-lg-0">

            <%-- Thông tin NCC của thiết bị đang chọn --%>
            <div class="card shadow-sm border-0 border-start border-4 border-warning mb-3"
                 id="vendorCard" style="display:none">
                <div class="card-body">
                    <h6 class="fw-bold mb-2"><i class="bi bi-building text-warning me-2"></i>Nhà cung cấp</h6>
                    <div id="vendorInfo" class="bg-light rounded p-2 small">
                        <span class="text-muted">Đang tải...</span>
                    </div>
                    <a href="${pageContext.request.contextPath}/vendor" target="_blank"
                       class="btn btn-sm btn-outline-warning w-100 mt-2">
                        <i class="bi bi-box-arrow-up-right me-1"></i>Xem tất cả nhà cung cấp
                    </a>
                </div>
            </div>

            <%-- Hướng dẫn quy trình --%>
            <div class="card shadow-sm border-0 bg-light">
                <div class="card-body">
                    <h6 class="fw-bold mb-3"><i class="bi bi-diagram-3 text-primary me-2"></i>Quy trình xử lý</h6>
                    <div class="d-flex align-items-start mb-3">
                        <span class="badge bg-secondary rounded-pill me-3 mt-1" style="min-width:22px">1</span>
                        <div class="small"><strong>Chờ xử lý</strong><br>
                            <span class="text-muted">Lên lịch sự kiện / chờ duyệt kế hoạch.</span></div>
                    </div>
                    <div class="d-flex align-items-start mb-3">
                        <span class="badge bg-info rounded-pill me-3 mt-1" style="min-width:22px">2a</span>
                        <div class="small"><strong>Liên hệ NCC (Thuê ngoài)</strong><br>
                            <span class="text-muted">Giao cho Nhà cung cấp. Bắt đầu tính thời gian thực hiện.</span></div>
                    </div>
                    <div class="d-flex align-items-start mb-3">
                        <span class="badge bg-primary rounded-pill me-3 mt-1" style="min-width:22px">2b</span>
                        <div class="small"><strong>Đang tiến hành (Tự sửa)</strong><br>
                            <span class="text-muted">Sửa tại công ty. Bắt đầu tính thời gian thực hiện.</span></div>
                    </div>
                    <div class="d-flex align-items-start">
                        <span class="badge bg-success rounded-pill me-3 mt-1" style="min-width:22px">3</span>
                        <div class="small"><strong>Hoàn thành</strong><br>
                            <span class="text-muted">Xong → chốt thời gian → tính tổng T.Gian Thực Hiện.</span></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    // ── Live search cho CI select ──────────────────────────────
    const ciSearchInput = document.getElementById('ciSearchInput');
    const ciSelect      = document.getElementById('ciId');
    const ciAllOptions  = Array.from(ciSelect.options);

    ciSearchInput.addEventListener('input', function () {
        const q = this.value.toLowerCase().trim();
        ciAllOptions.forEach(opt => {
            opt.hidden = opt.value !== '' && !opt.text.toLowerCase().includes(q);
        });
    });

    ciSelect.addEventListener('change', function () {
        onCiChange(this.value);
    });

    // ── Thông tin NCC theo CI ─────────────────────────────────
    const vendorData = {};
    <c:forEach var="ci" items="${cis}">
        <c:if test="${not empty ci.vendorId}">
        vendorData['${ci.ciId}'] = {
            id:   '${ci.vendorId}',
            name: '${ci.vendorName != null ? ci.vendorName : ""}'
        };
        </c:if>
    </c:forEach>

    function onCiChange(ciId) {
        const card = document.getElementById('vendorCard');
        const info = document.getElementById('vendorInfo');
        if (!ciId || !vendorData[ciId]) {
            if (card) card.style.display = 'none';
            return;
        }
        const v = vendorData[ciId];
        info.innerHTML = '<strong><i class="bi bi-building me-1"></i>' + v.name + '</strong><br>' +
            '<a href="${pageContext.request.contextPath}/vendor?action=detail&id=' + v.id +
            '" target="_blank" class="btn btn-sm btn-outline-secondary mt-2 w-100">' +
            '<i class="bi bi-telephone me-1"></i>Xem chi tiết &amp; liên hệ</a>';
        if (card) card.style.display = 'block';
    }

    // Trigger khi load trang (chế độ edit)
    window.addEventListener('DOMContentLoaded', function () {
        if (ciSelect.value) onCiChange(ciSelect.value);
        toggleAutoActive();
    });

    // ── Toggle Auto Active Checkbox ──────────────────────────
    const statusSelect = document.getElementById('status');
    const autoActiveDiv = document.getElementById('autoActiveDiv');
    
    function toggleAutoActive() {
        if (statusSelect.value === 'COMPLETED') {
            autoActiveDiv.style.display = 'block';
        } else {
            autoActiveDiv.style.display = 'none';
        }
    }
    statusSelect.addEventListener('change', toggleAutoActive);

    // ── Đếm ký tự mô tả ──────────────────────────────────────
    const descEl      = document.getElementById('description');
    const descCounter = document.getElementById('descCounter');
    function updateCounter() {
        const len = descEl.value.length;
        descCounter.textContent = len + ' / 3000';
        descCounter.className = 'form-text ' + (len > 2800 ? 'text-danger' : len > 2000 ? 'text-warning' : '');
    }
    descEl.addEventListener('input', updateCounter);
    updateCounter();

    // ── Validate form ─────────────────────────────────────────
    (function () {
        'use strict';
        var form = document.getElementById('maintenanceForm');
        form.addEventListener('submit', function (event) {
            if (!form.checkValidity()) {
                event.preventDefault();
                event.stopPropagation();
            }
            form.classList.add('was-validated');
        }, false);
    })();
</script>

<jsp:include page="/common/admin-layout-bottom.jsp" />
