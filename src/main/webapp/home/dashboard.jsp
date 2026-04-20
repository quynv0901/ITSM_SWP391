<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/includes/header.jsp" />

<style>
    .home-hero {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border-radius: 16px;
        padding: 40px 48px;
        color: white;
        margin-bottom: 32px;
        position: relative;
        overflow: hidden;
    }

    .home-hero::before {
        content: '';
        position: absolute;
        top: -50%;
        right: -20%;
        width: 400px;
        height: 400px;
        background: rgba(255, 255, 255, 0.08);
        border-radius: 50%;
    }

    .home-hero::after {
        content: '';
        position: absolute;
        bottom: -30%;
        right: 10%;
        width: 250px;
        height: 250px;
        background: rgba(255, 255, 255, 0.05);
        border-radius: 50%;
    }

    .home-hero h1 {
        font-size: 2rem;
        font-weight: 700;
        margin-bottom: 8px;
        position: relative;
        z-index: 1;
    }

    .home-hero p {
        font-size: 1.1rem;
        opacity: 0.9;
        margin: 0;
        position: relative;
        z-index: 1;
    }

    .home-hero .role-badge {
        display: inline-block;
        background: rgba(255, 255, 255, 0.2);
        backdrop-filter: blur(10px);
        padding: 6px 16px;
        border-radius: 20px;
        font-size: 0.85rem;
        font-weight: 600;
        margin-top: 12px;
        position: relative;
        z-index: 1;
    }

    .section-title {
        font-size: 1.15rem;
        font-weight: 700;
        color: #343a40;
        margin-bottom: 20px;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .section-title i {
        color: #667eea;
    }

    .action-cards {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
        gap: 20px;
        margin-bottom: 36px;
    }

    .action-card {
        background: white;
        border-radius: 14px;
        padding: 28px 24px;
        border: 1px solid #e9ecef;
        text-decoration: none;
        color: inherit;
        transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        display: flex;
        flex-direction: column;
        position: relative;
        overflow: hidden;
    }

    .action-card:hover {
        transform: translateY(-6px);
        box-shadow: 0 12px 40px rgba(0, 0, 0, 0.12);
        border-color: transparent;
    }

    .action-card .card-icon {
        width: 56px;
        height: 56px;
        border-radius: 14px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.5rem;
        margin-bottom: 18px;
        color: white;
    }

    .action-card .card-icon.blue {
        background: linear-gradient(135deg, #4e73df, #224abe);
    }
    .action-card .card-icon.green {
        background: linear-gradient(135deg, #1cc88a, #13855c);
    }
    .action-card .card-icon.purple {
        background: linear-gradient(135deg, #6f42c1, #5a32a3);
    }
    .action-card .card-icon.orange {
        background: linear-gradient(135deg, #f6c23e, #dda20a);
    }
    .action-card .card-icon.red {
        background: linear-gradient(135deg, #e74a3b, #be2617);
    }
    .action-card .card-icon.teal {
        background: linear-gradient(135deg, #36b9cc, #258391);
    }

    .action-card h3 {
        font-size: 1.05rem;
        font-weight: 700;
        color: #2d3436;
        margin-bottom: 8px;
    }

    .action-card p {
        font-size: 0.88rem;
        color: #6c757d;
        margin: 0;
        line-height: 1.5;
        flex: 1;
    }

    .action-card .card-arrow {
        margin-top: 16px;
        color: #adb5bd;
        font-size: 1.1rem;
        transition: all 0.3s;
        align-self: flex-end;
    }

    .action-card:hover .card-arrow {
        color: #4e73df;
        transform: translateX(4px);
    }

    .info-cards {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
        gap: 16px;
    }

    .info-card {
        background: white;
        border-radius: 12px;
        padding: 20px;
        border: 1px solid #e9ecef;
        text-align: center;
        transition: all 0.3s ease;
    }

    .info-card .info-icon {
        font-size: 1.8rem;
        margin-bottom: 8px;
    }

    .info-card h4 {
        font-size: 0.95rem;
        font-weight: 600;
        color: #495057;
        margin-bottom: 4px;
    }

    .info-card:hover {
        transform: translateY(-4px);
        box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
        border-color: #667eea;
    }

    .info-card p {
        font-size: 0.8rem;
        color: #adb5bd;
        margin: 0;
    }
    .action-cards {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
        gap: 16px;
    }

    .action-card {
        background: #fff;
        border-radius: 16px;
        padding: 16px 14px;
        text-decoration: none;
        color: #333;
        position: relative;
        transition: all 0.25s ease;
        border: 1px solid #eee;
        min-height: 150px;
    }

    .action-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 25px rgba(0,0,0,0.08);
    }

    /* Icon */
    .card-icon {
        width: 42px;
        height: 42px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 18px;
        margin-bottom: 10px;
    }

    /* Title */
    .action-card h3 {
        font-size: 15px;
        font-weight: 600;
        margin-bottom: 6px;
    }

    /* Description */
    .action-card p {
        font-size: 12.5px;
        color: #666;
        margin: 0;
    }

    /* Arrow */
    .card-arrow {
        position: absolute;
        right: 12px;
        bottom: 12px;
        font-size: 14px;
        color: #aaa;
    }

    /* Màu icon (giữ tone đẹp hơn) */
    .blue {
        background: #e3f2fd;
        color: #2196f3;
    }
    .green {
        background: #e8f5e9;
        color: #4caf50;
    }
    .red {
        background: #fdecea;
        color: #e53935;
    }
    .orange {
        background: #fff3e0;
        color: #fb8c00;
    }
    .teal {
        background: #e0f2f1;
        color: #009688;
    }
    .purple {
        background: #f3e5f5;
        color: #8e24aa;
    }
</style>

<div class="home-hero">
    <h1>Xin chào, ${sessionScope.user.fullName}! 👋</h1>
    <p>Chào mừng bạn đến với hệ thống ITServiceFlow — Quản lý dịch vụ IT theo chuẩn ITIL.</p>
    <div class="role-badge">
        <i class="bi bi-shield-check me-1"></i>
        <c:choose>
            <c:when test="${sessionScope.user.roleId == 1}">End User</c:when>
            <c:when test="${sessionScope.user.roleId == 2}">Support Agent</c:when>
            <c:when test="${sessionScope.user.roleId == 3}">IT Manager</c:when>
            <c:when test="${sessionScope.user.roleId == 4}">Technical Expert</c:when>
            <c:when test="${sessionScope.user.roleId == 5}">IT Director</c:when>
            <c:when test="${sessionScope.user.roleId == 10}">System Admin</c:when>
            <c:otherwise>User</c:otherwise>
        </c:choose>
    </div>
</div>

<div class="section-title"><i class="bi bi-lightning-charge-fill"></i> Hành động nhanh</div>
<div class="action-cards">

    <a href="${pageContext.request.contextPath}/incident?action=create" class="action-card">
        <div class="card-icon blue"><i class="bi bi-exclamation-triangle-fill"></i></div>
        <h3>Tạo Incident Ticket</h3>
        <p>Báo cáo sự cố IT để được hỗ trợ nhanh chóng từ đội ngũ kỹ thuật.</p>
        <i class="bi bi-arrow-right card-arrow"></i>
    </a>

    <a href="${pageContext.request.contextPath}/create-request" class="action-card">
        <div class="card-icon green"><i class="bi bi-clipboard2-plus-fill"></i></div>
        <h3>Tạo Service Request</h3>
        <p>Yêu cầu dịch vụ IT mới như cấp tài khoản, cài phần mềm, hỗ trợ thiết bị.</p>
        <i class="bi bi-arrow-right card-arrow"></i>
    </a>

    <c:if test="${sessionScope.user.roleId != 1}">
        <a href="${pageContext.request.contextPath}/known-error?action=list" class="action-card">
            <div class="card-icon red"><i class="bi bi-bug-fill"></i></div>
            <h3>Known Error Database</h3>
            <p>Tra cứu các lỗi đã biết kèm triệu chứng, nguyên nhân gốc và cách xử lý.</p>
            <i class="bi bi-arrow-right card-arrow"></i>
        </a>
    </c:if>

    <a href="${pageContext.request.contextPath}/service-catalog" class="action-card">
        <div class="card-icon orange"><i class="bi bi-grid-3x3-gap-fill"></i></div>
        <h3>Service Catalog</h3>
        <p>Xem danh mục các dịch vụ IT đang cung cấp trong tổ chức.</p>
        <i class="bi bi-arrow-right card-arrow"></i>
    </a>
    <a href="${pageContext.request.contextPath}/change-request/list" class="action-card">
        <div class="card-icon orange"><i class="bi bi-arrow-repeat me-2"></i></div>
        <h3>Change Request</h3>
        <p>Hiển thị danh sách yêu cầu thay đổi dưới dạng lịch cho các thay đổi đã lên lịch.</p>
        <i class="bi bi-arrow-right card-arrow"></i>
    </a>
    <a href="${pageContext.request.contextPath}/profile" class="action-card">
        <div class="card-icon teal"><i class="bi bi-person-fill-gear"></i></div>
        <h3>Hồ sơ cá nhân</h3>
        <p>Xem và cập nhật thông tin cá nhân, đổi mật khẩu tài khoản.</p>
        <i class="bi bi-arrow-right card-arrow"></i>
    </a>

    <a href="${pageContext.request.contextPath}/knowledge-base?action=list" 
       class="action-card" style="position: relative;">
        <c:if test="${newArticleCount > 0}">
            <span style="position: absolute; top: 8px; right: 8px;
                  background: #dc3545; color: white;
                  border-radius: 50%; width: 22px; height: 22px;
                  font-size: 12px; font-weight: bold;
                  display: flex; align-items: center; justify-content: center;">
                ${newArticleCount}
            </span>
        </c:if>
        <div class="card-icon purple"><i class="bi bi-book-fill"></i></div>
        <h3>Thông báo</h3>
        <p>Tra cứu thông tin về công ty TECHNICOM.</p>
        <i class="bi bi-arrow-right card-arrow"></i>
    </a>
    <a href="${pageContext.request.contextPath}/knowledge-article?action=list" 
       class="action-card" style="position: relative;">
        <c:if test="${newKnowledgeArticleCount  > 0}">
            <span style="position: absolute; top: 8px; right: 8px;
                  background: #dc3545; color: white;
                  border-radius: 50%; width: 22px; height: 22px;
                  font-size: 12px; font-weight: bold;
                  display: flex; align-items: center; justify-content: center;">
                ${newKnowledgeArticleCount} 
            </span>
        </c:if>
        <div class="card-icon purple"><i class="bi bi-book-fill"></i></div>
        <h3>Cơ sở kiến thức</h3>
        <p>Tra cứu tài liệu hướng dẫn, FAQ và giải pháp từ kho tri thức nội bộ.</p>
        <i class="bi bi-arrow-right card-arrow"></i>
    </a>


</div>

<div class="section-title"><i class="bi bi-info-circle-fill"></i> Hệ thống ITServiceFlow</div>
<div class="info-cards">
    <a href="${pageContext.request.contextPath}/incident?action=list" class="info-card" style="text-decoration:none; color:inherit;">
        <div class="info-icon">🎫</div>
        <h4>Incident Management</h4>
        <p>Quản lý sự cố IT</p>
    </a>
    <c:if test="${sessionScope.user.roleId != 1}">
        <a href="${pageContext.request.contextPath}/problem?action=list" class="info-card" style="text-decoration:none; color:inherit;">
            <div class="info-icon">🧠</div>
            <h4>Problem Management</h4>
            <p>Phân tích nguyên nhân gốc</p>
        </a>
    </c:if>
    <c:if test="${sessionScope.user.roleId != 1}">
        <a href="${pageContext.request.contextPath}/cmdb?action=list" class="info-card" style="text-decoration:none; color:inherit;">
            <div class="info-icon">🖥️</div>
            <h4>CMDB</h4>
            <p>Cơ sở dữ liệu cấu hình</p>
        </a>
    </c:if>
</div>

<jsp:include page="/includes/footer.jsp" />
