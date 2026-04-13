<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/common/header.jsp" />
<style>
    .profile-card {
        border: none;
        border-radius: 15px;
        overflow: hidden;
    }
    .profile-header {
        background: linear-gradient(135deg, #4e73df 0%, #224abe 100%);
        height: 120px;
    }
    .profile-img-container {
        margin-top: -60px;
        position: relative;
    }
    .profile-img {
        width: 120px;
        height: 120px;
        border: 5px solid white;
        border-radius: 50%;
        background: #eee;
    }
    .status-badge {
        position: absolute;
        bottom: 5px;
        right: calc(50% - 50px);
        width: 20px;
        height: 20px;
        background: #1cc88a;
        border: 3px solid white;
        border-radius: 50%;
    }
    .nav-pills-custom .nav-link {
        color: #666;
        font-weight: 500;
        border-radius: 10px;
        padding: 12px 20px;
        margin-bottom: 10px;
    }
    .nav-pills-custom .nav-link.active {
        background-color: #f8f9fc;
        color: #4e73df;
        box-shadow: 0 4px 6px rgba(0,0,0,0.05);
    }
</style>

<div class="container py-5">
    <div class="row">
        <div class="col-lg-4">
            <div class="card profile-card shadow-sm mb-4">
                <div class="profile-header"></div>
                <div class="card-body text-center">
                    <div class="profile-img-container mb-3">
                        <img src="https://ui-avatars.com/api/?name=${currentUser.fullName}&size=120&background=4e73df&color=fff" class="profile-img shadow">
                        <div class="status-badge"></div>
                    </div>
                    <h3 class="fw-bold mb-0">${currentUser.fullName}</h3>
                    <p class="text-muted mb-3">@${currentUser.username}</p>
                    <div class="badge bg-primary-subtle text-primary border border-primary px-3 py-2 rounded-pill mb-4">
                        ${currentUser.roleName}
                    </div>
                </div>
            </div>
            
            <div class="nav flex-column nav-pills nav-pills-custom" id="v-pills-tab" role="tablist">
                <button class="nav-link active text-start" data-bs-toggle="pill" data-bs-target="#edit-profile">
                    <i class="bi bi-person-lines-fill me-2"></i> Hồ sơ cá nhân
                </button>
                <button class="nav-link text-start" data-bs-toggle="pill" data-bs-target="#change-pass">
                    <i class="bi bi-shield-lock-fill me-2"></i> Bảo mật & Mật khẩu
                </button>
            </div>
        </div>

        <div class="col-lg-8">
            <c:if test="${not empty message}">
                <div class="alert alert-success border-0 shadow-sm alert-dismissible fade show">
                    <i class="bi bi-check-circle me-2"></i> ${message}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-danger border-0 shadow-sm alert-dismissible fade show">
                    <i class="bi bi-exclamation-triangle me-2"></i> ${error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <div class="tab-content" id="v-pills-tabContent">
                <!-- Edit Profile Tab -->
                <div class="tab-pane fade show active" id="edit-profile">
                    <div class="card border-0 shadow-sm rounded-4">
                        <div class="card-body p-4 p-md-5">
                            <h4 class="fw-bold mb-4">Cập nhật hồ sơ</h4>
                            <form action="${pageContext.request.contextPath}/profile" method="post">
                                <input type="hidden" name="action" value="updateProfile">
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label small fw-bold text-muted">HỌ VÀ TÊN</label>
                                        <input type="text" name="fullName" class="form-control py-2 shadow-none border-0 bg-light" value="${currentUser.fullName}" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label small fw-bold text-muted">EMAIL DOCKER</label>
                                        <input type="email" class="form-control py-2 shadow-none border-0 bg-light" value="${currentUser.email}" readonly>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label small fw-bold text-muted">SỐ ĐIỆN THOẠI</label>
                                        <input type="text" name="phone" class="form-control py-2 shadow-none border-0 bg-light" value="${currentUser.phone}">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label small fw-bold text-muted">PHÒNG BAN</label>
                                        <div class="form-control py-2 shadow-none border-0 bg-light">IT Department</div>
                                    </div>
                                    <div class="col-12 mt-4 text-end">
                                        <button type="submit" class="btn btn-primary px-4 py-2 rounded-3 fw-bold">Lưu thay đổi</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Change Password Tab -->
                <div class="tab-pane fade" id="change-pass">
                    <div class="card border-0 shadow-sm rounded-4">
                        <div class="card-body p-4 p-md-5">
                            <h4 class="fw-bold mb-4 text-danger">Đổi mật khẩu bảo mật</h4>
                            <form action="${pageContext.request.contextPath}/profile" method="post">
                                <input type="hidden" name="action" value="changePassword">
                                <div class="mb-4">
                                    <label class="form-label small fw-bold text-muted">MẬT KHẨU HIỆN TẠI</label>
                                    <input type="password" name="currentPassword" class="form-control py-2 shadow-none border-0 bg-light" required>
                                </div>
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label small fw-bold text-muted">MẬT KHẨU MỚI</label>
                                        <input type="password" name="newPassword" class="form-control py-2 shadow-none border-0 bg-light" placeholder="Ít nhất 6 ký tự" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label small fw-bold text-muted">XÁC NHẬN MẬT KHẨU MỚI</label>
                                        <input type="password" name="confirmPassword" class="form-control py-2 shadow-none border-0 bg-light" placeholder="Nhập lại mật khẩu mới" required>
                                    </div>
                                </div>
                                <div class="col-12 mt-4 text-end">
                                    <button type="submit" class="btn btn-danger px-4 py-2 rounded-3 fw-bold">Cập nhật mật khẩu</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/common/footer.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        // Auto-select tab from hash
        let hash = window.location.hash;
        if (hash) {
            let triggerEl = document.querySelector('button[data-bs-target="' + hash + '"]');
            if (triggerEl) {
                bootstrap.Tab.getOrCreateInstance(triggerEl).show();
            }
        }
    });

    // Reset URL message params
    if (window.history.replaceState) {
        const url = new URL(window.location.href);
        if (url.searchParams.has('message') || url.searchParams.has('error')) {
            url.searchParams.delete('message');
            url.searchParams.delete('error');
            window.history.replaceState({ path: url.href }, '', url.href);
        }
    }
</script>
</body>
</html>
