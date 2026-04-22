<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/common/admin-layout-top.jsp" />

<div class="container-fluid px-4 py-4">
    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h3 class="mb-1 fw-bold text-dark">
                <i class="bi bi-tools text-primary me-2"></i>
                ${log != null ? 'Cập nhật Nhật ký Bảo trì' : 'Tạo Nhật ký Bảo trì'}
            </h3>
            <p class="text-muted mb-0">
                Ghi nhận sự kiện bảo trì, lên lịch xử lý và theo dõi liên hệ nhà cung cấp.
            </p>
        </div>
        <a href="${pageContext.request.contextPath}/maintenance-log" class="btn btn-outline-secondary shadow-sm">
            <i class="bi bi-arrow-left me-2"></i>Quay lại danh sách
        </a>
    </div>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i> ${errorMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <div class="row">
        <!-- Main Form Column -->
        <div class="col-lg-8">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white py-3">
                    <h5 class="card-title mb-0 fw-bold">Thông tin Bảo trì</h5>
                </div>
                <div class="card-body p-4">
                    <form action="${pageContext.request.contextPath}/maintenance-log" method="POST" id="maintenanceForm" novalidate>
                        <input type="hidden" name="action" value="save">
                        <input type="hidden" name="logId" value="${log != null ? log.logId : ''}">

                        <%-- Thiết bị cần bảo trì --%>
                        <div class="mb-4">
                            <label for="ciId" class="form-label fw-semibold">
                                Thiết bị (CI) cần bảo trì <span class="text-danger">*</span>
                            </label>
                            <div class="input-group">
                                <span class="input-group-text bg-light"><i class="bi bi-server"></i></span>
                                <select class="form-select" id="ciId" name="ciId" required onchange="loadVendorInfo(this)">
                                    <option value="">-- Chọn thiết bị từ CMDB --</option>
                                    <c:forEach var="ci" items="${cis}">
                                        <option value="${ci.ciId}"
                                                data-vendor-id="${ci.vendorId}"
                                                data-type="${ci.type}"
                                                ${log != null && log.ciId == ci.ciId ? 'selected' : ''}>
                                            ${ci.name} [${ci.type}]
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="form-text">
                                <i class="bi bi-info-circle me-1"></i>
                                Danh sách bao gồm tất cả các CI — ưu tiên chọn thiết bị đang ở trạng thái INACTIVE hoặc cần bảo trì.
                            </div>
                        </div>

                        <%-- Loại bảo trì (nhập tự do, có gợi ý) --%>
                        <div class="row mb-4">
                            <div class="col-md-6">
                                <label for="maintenanceType" class="form-label fw-semibold">
                                    Loại bảo trì <span class="text-danger">*</span>
                                </label>
                                <input type="text" class="form-control" id="maintenanceType" name="maintenanceType"
                                       list="maintenanceTypeSuggestions"
                                       placeholder="Nhập hoặc chọn loại bảo trì..."
                                       value="${log != null ? log.maintenanceType : ''}" required>
                                <datalist id="maintenanceTypeSuggestions">
                                    <option value="Vá lỗi bảo mật">
                                    <option value="Cập nhật Firmware">
                                    <option value="Nâng cấp phần cứng">
                                    <option value="Bảo dưỡng định kỳ">
                                    <option value="Thay thế linh kiện">
                                    <option value="Cài đặt lại hệ điều hành">
                                    <option value="Khắc phục sự cố mạng">
                                    <option value="Kiểm tra và làm sạch">
                                    <option value="Cập nhật phần mềm">
                                    <option value="Thay thế thiết bị hỏng">
                                    <option value="Mở rộng dung lượng lưu trữ">
                                    <option value="Kiểm tra UPS / nguồn điện">
                                    <option value="Sao lưu và khôi phục dữ liệu">
                                </datalist>
                                <div class="form-text">Có thể nhập tự do — không bị giới hạn danh sách.</div>
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
                                <div class="form-text">Ngày đã thực hiện hoặc ngày dự kiến bảo trì (tương lai).</div>
                            </div>
                        </div>

                        <%-- Trạng thái xử lý (luồng nghiệp vụ) --%>
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
                            <div class="form-text">
                                Cập nhật trạng thái để theo dõi tiến độ xử lý bảo trì.
                            </div>
                        </div>

                        <%-- Downtime ước tính (tùy chọn, không bắt buộc) --%>
                        <div class="mb-4">
                            <label for="downtimeMinutes" class="form-label fw-semibold">
                                Thời gian gián đoạn ước tính (Phút)
                                <span class="badge bg-secondary fw-normal ms-1">Tùy chọn</span>
                            </label>
                            <div class="input-group">
                                <span class="input-group-text bg-light"><i class="bi bi-clock-history"></i></span>
                                <input type="number" class="form-control" id="downtimeMinutes" name="downtimeMinutes"
                                       value="${log != null ? log.downtimeMinutes : '0'}" min="0">
                                <span class="input-group-text bg-light">Phút</span>
                            </div>
                            <div class="form-text">
                                Ước tính thời gian thiết bị tạm ngừng hoạt động. Nhập <strong>0</strong> nếu không gây gián đoạn.
                                Downtime chính xác sẽ được tính từ lịch sử trạng thái CI.
                            </div>
                        </div>

                        <%-- Chi tiết công việc --%>
                        <div class="mb-4">
                            <label for="description" class="form-label fw-semibold">
                                Chi tiết công việc bảo trì <span class="text-danger">*</span>
                            </label>
                            <textarea class="form-control" id="description" name="description" rows="4"
                                      placeholder="Mô tả chi tiết: vấn đề phát sinh, các bước đã thực hiện, linh kiện đã thay, phiên bản đã nâng cấp..." required>${log != null ? log.description : ''}</textarea>
                        </div>

                    </form>
                </div>
                <div class="card-footer bg-light px-4 py-3 text-end">
                    <a href="${pageContext.request.contextPath}/maintenance-log" class="btn btn-light border me-2 shadow-sm">
                        Hủy bỏ
                    </a>
                    <button type="submit" form="maintenanceForm" class="btn btn-primary px-4 shadow-sm">
                        <i class="bi bi-save me-1"></i> Lưu nhật ký
                    </button>
                </div>
            </div>
        </div>

        <!-- Sidebar: Thông tin nhà cung cấp + hướng dẫn -->
        <div class="col-lg-4 mt-4 mt-lg-0">

            <%-- Card thông tin nhà cung cấp (hiện khi chọn CI) --%>
            <div class="card shadow-sm border-0 border-start border-4 border-warning mb-3" id="vendorCard" style="display:none!important;">
                <div class="card-body">
                    <h6 class="fw-bold mb-3"><i class="bi bi-building text-warning me-2"></i>Nhà cung cấp thiết bị</h6>
                    <p class="text-muted small mb-1">Nếu thiết bị hỏng và cần hỗ trợ, hãy liên hệ:</p>
                    <div id="vendorInfo" class="bg-light rounded p-3 small">
                        <span class="text-muted">Chưa có thông tin nhà cung cấp.</span>
                    </div>
                    <div class="mt-2">
                        <a href="${pageContext.request.contextPath}/vendor" class="btn btn-sm btn-outline-warning w-100" target="_blank">
                            <i class="bi bi-box-arrow-up-right me-1"></i> Xem tất cả nhà cung cấp
                        </a>
                    </div>
                </div>
            </div>

            <%-- Hướng dẫn quy trình --%>
            <div class="card shadow-sm border-0 bg-light">
                <div class="card-body">
                    <h5 class="fw-bold mb-3"><i class="bi bi-diagram-3 text-primary"></i> Quy trình xử lý</h5>
                    <div class="d-flex align-items-start mb-3">
                        <span class="badge bg-primary rounded-pill me-3 mt-1" style="min-width:22px">1</span>
                        <div class="small">
                            <strong>Chờ xử lý</strong><br>
                            <span class="text-muted">CI bị đưa vào trạng thái INACTIVE, tạo nhật ký để ghi nhận sự kiện.</span>
                        </div>
                    </div>
                    <div class="d-flex align-items-start mb-3">
                        <span class="badge bg-warning rounded-pill me-3 mt-1" style="min-width:22px">2</span>
                        <div class="small">
                            <strong>Liên hệ nhà cung cấp</strong><br>
                            <span class="text-muted">Dùng thông tin Vendor đã lưu để liên hệ sửa chữa hoặc cấp linh kiện thay thế.</span>
                        </div>
                    </div>
                    <div class="d-flex align-items-start mb-3">
                        <span class="badge bg-info rounded-pill me-3 mt-1" style="min-width:22px">3</span>
                        <div class="small">
                            <strong>Đang tiến hành</strong><br>
                            <span class="text-muted">Kỹ thuật viên thực hiện bảo trì, hệ thống tìm thiết bị thay thế nếu cần.</span>
                        </div>
                    </div>
                    <div class="d-flex align-items-start">
                        <span class="badge bg-success rounded-pill me-3 mt-1" style="min-width:22px">4</span>
                        <div class="small">
                            <strong>Hoàn thành</strong><br>
                            <span class="text-muted">Cập nhật CI về trạng thái ACTIVE, hệ thống hoạt động bình thường.</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    // Dữ liệu vendor được truyền từ Controller
    const vendorMap = {};
    <c:forEach var="ci" items="${cis}">
        <c:if test="${not empty ci.vendorId}">
        vendorMap['${ci.ciId}'] = {
            vendorId: '${ci.vendorId}',
            name: '${ci.vendorName != null ? ci.vendorName : "Chưa có nhà cung cấp"}'
        };
        </c:if>
    </c:forEach>

    function loadVendorInfo(select) {
        const ciId = select.value;
        const vendorCard = document.getElementById('vendorCard');
        const vendorInfo = document.getElementById('vendorInfo');

        if (!ciId || !vendorMap[ciId]) {
            vendorCard.style.setProperty('display', 'none', 'important');
            return;
        }

        const v = vendorMap[ciId];
        if (v && v.vendorId) {
            vendorInfo.innerHTML = `<strong><i class="bi bi-building me-1"></i>${v.name}</strong><br>
                <a href="${pageContext.request.contextPath}/vendor?action=detail&id=${v.vendorId}" target="_blank" class="btn btn-sm btn-outline-secondary mt-2 w-100">
                    <i class="bi bi-telephone me-1"></i>Xem chi tiết &amp; liên hệ
                </a>`;
            vendorCard.style.removeProperty('display');
        }
    }

    // Trigger nếu đang ở chế độ edit
    window.addEventListener('DOMContentLoaded', function () {
        const ciSelect = document.getElementById('ciId');
        if (ciSelect.value) loadVendorInfo(ciSelect);
    });

    // Validate form
    (function () {
        'use strict'
        var form = document.getElementById('maintenanceForm')
        form.addEventListener('submit', function (event) {
            if (!form.checkValidity()) {
                event.preventDefault()
                event.stopPropagation()
            }
            form.classList.add('was-validated')
        }, false)
    })()
</script>

<jsp:include page="/common/admin-layout-bottom.jsp" />
