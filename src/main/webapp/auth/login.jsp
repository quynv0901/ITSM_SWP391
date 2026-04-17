<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Đăng nhập | ITServiceFlow</title>
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
            <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap"
                rel="stylesheet">
            <style>
                body {
                    font-family: 'Outfit', sans-serif;
                    background-color: #f8f9fc;
                    margin: 0;
                }

                .login-wrapper {
                    display: flex;
                    min-height: 100vh;
                }

                .login-left {
                    flex: 1.2;
                    background: linear-gradient(rgba(0, 0, 0, 0.6), rgba(0, 0, 0, 0.6)),
                    url('${pageContext.request.contextPath}/assets/img/auth_bg_astronaut.png');
                    background-size: cover;
                    background-position: center;
                    display: flex;
                    flex-direction: column;
                    justify-content: center;
                    padding: 100px;
                    color: white;
                }

                .login-right {
                    flex: 1;
                    background: white;
                    display: flex;
                    flex-direction: column;
                    justify-content: center;
                    padding: 100px;
                    overflow-y: auto;
                    box-shadow: -10px 0 30px rgba(0, 0, 0, 0.05);
                }

                .brand-logo {
                    width: 70px;
                    height: 70px;
                    background: rgba(255, 255, 255, 0.2);
                    backdrop-filter: blur(15px);
                    border-radius: 16px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    margin-bottom: 2.5rem;
                    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
                }

                .login-left h1 {
                    font-size: 4rem;
                    font-weight: 700;
                    margin-bottom: 1.5rem;
                    letter-spacing: -1px;
                }

                .login-left p {
                    font-size: 1.25rem;
                    opacity: 0.9;
                    max-width: 500px;
                    margin-bottom: 3rem;
                    line-height: 1.6;
                }

                .feature-list {
                    list-style: none;
                    padding: 0;
                }

                .feature-list li {
                    margin-bottom: 1.5rem;
                    display: flex;
                    align-items: center;
                    font-size: 1.2rem;
                    font-weight: 500;
                }

                .feature-list li i {
                    margin-right: 20px;
                    color: #4e73df;
                    background: white;
                    width: 28px;
                    height: 28px;
                    border-radius: 50%;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 0.7rem;
                }

                .auth-tab {
                    display: flex;
                    gap: 25px;
                    margin-bottom: 3.5rem;
                    align-items: center;
                }

                .auth-tab a {
                    text-decoration: none;
                    color: #adb5bd;
                    font-weight: 700;
                    font-size: 1.4rem;
                    transition: all 0.3s;
                }

                .auth-tab a.active {
                    color: #212529;
                    position: relative;
                }

                .auth-tab a.active::after {
                    content: '';
                    position: absolute;
                    bottom: -5px;
                    left: 0;
                    width: 30px;
                    height: 4px;
                    background: #4e73df;
                    border-radius: 2px;
                }

                .auth-tab span {
                    color: #dee2e6;
                    font-size: 1.4rem;
                }

                .form-label {
                    font-weight: 700;
                    color: #495057;
                    margin-top: 2rem;
                    font-size: 0.9rem;
                    text-transform: uppercase;
                    letter-spacing: 0.5px;
                }

                .input-wrapper {
                    position: relative;
                    margin-top: 0.5rem;
                }

                .input-wrapper input {
                    border: none;
                    border-bottom: 2px solid #e9ecef;
                    border-radius: 0;
                    padding: 15px 45px 15px 0;
                    width: 100%;
                    outline: none;
                    transition: all 0.3s ease;
                    font-size: 1.1rem;
                    font-weight: 500;
                    color: #212529;
                }

                .input-wrapper input::placeholder {
                    color: #adb5bd;
                    font-weight: 400;
                }

                .input-wrapper input:focus {
                    border-color: #4e73df;
                    padding-left: 5px;
                }

                .input-wrapper i {
                    position: absolute;
                    right: 15px;
                    top: 50%;
                    transform: translateY(-50%);
                    color: #ced4da;
                    transition: all 0.3s;
                    font-size: 1.25rem;
                }

                .input-wrapper input:focus+i {
                    color: #4e73df;
                }

                .login-buttons {
                    display: flex;
                    gap: 20px;
                    margin-top: 3.5rem;
                    align-items: center;
                }

                .btn-facebook {
                    background-color: #f1f3f9;
                    color: #4e73df;
                    border: none;
                    padding: 15px 30px;
                    border-radius: 12px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    gap: 12px;
                    font-weight: 700;
                    transition: all 0.3s;
                    flex: 1;
                }

                .btn-facebook:hover {
                    background-color: #4e73df;
                    color: white;
                    transform: translateY(-2px);
                    box-shadow: 0 5px 15px rgba(78, 115, 223, 0.3);
                }

                .btn-submit {
                    background: #212529;
                    color: white;
                    border: none;
                    padding: 18px 40px;
                    border-radius: 12px;
                    font-weight: 700;
                    font-size: 1.1rem;
                    transition: all 0.3s;
                    width: 100%;
                    margin-top: 3rem;
                    box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
                }

                .btn-submit:hover {
                    background: #2c3e50;
                    /* Darker charcoal blue to differentiate from Facebook button */
                    transform: translateY(-2px);
                    box-shadow: 0 15px 30px rgba(0, 0, 0, 0.2);
                }

                .alert-container {
                    position: fixed;
                    top: 30px;
                    right: 30px;
                    z-index: 1000;
                }

                .alert {
                    border-radius: 12px;
                    border: none;
                    padding: 20px 25px;
                }
            </style>
        </head>

        <body>

            <div class="alert-container">
                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show shadow-lg" role="alert">
                        <i class="bi bi-exclamation-circle me-2"></i> ${error}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${param.reset == 'success'}">
                    <div class="alert alert-success alert-dismissible fade show shadow-lg" role="alert">
                        <i class="bi bi-check-circle me-2"></i> Đặt lại mật khẩu thành công!
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${param.logout == 'success'}">
                    <div class="alert alert-info alert-dismissible fade show shadow-lg" role="alert">
                        <i class="bi bi-info-circle me-2"></i> Bạn đã đăng xuất thành công!
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
            </div>

            <div class="login-wrapper">
                <div class="login-left">
                    <div class="brand-logo">
                        <i class="bi bi-cpu fs-3 text-white"></i>
                    </div>
                    <h1>Xin chào</h1>
                    <p>Bạn cảm thấy bối rối? Hãy tham gia cùng chúng tôi để tối ưu hóa quy trình dịch vụ CNTT của bạn với hệ thống quản lý chuyên nghiệp của chúng tôi.</p>

                    <ul class="feature-list">
                        <li><i class="bi bi-circle-fill"></i> Quản lý sự cố</li>
                        <li><i class="bi bi-circle-fill"></i> Theo dõi thông báo</li>
                        <li><i class="bi bi-circle-fill"></i> Cơ sở tri thức</li>
                    </ul>
                </div>
                <div class="login-right">
                    <div class="auth-tab">
                        <a href="#" class="active">Đăng nhập</a>
                    </div>

                    <form action="${pageContext.request.contextPath}/auth?action=login" method="post">
                        <h2 class="fw-bold mb-2">Chào mừng trở lại!</h2>
                        <p class="text-muted mb-5">Vui lòng đăng nhập.</p>

                        <label class="form-label">Tên đăng nhập / Email</label>
                        <div class="input-wrapper">
                            <input type="text" name="username" placeholder="Nhập tên đăng nhập hoặc email..." required>
                            <i class="bi bi-person"></i>
                        </div>

                        <label class="form-label">Mật khẩu</label>
                        <div class="input-wrapper">
                            <input type="password" name="password" placeholder="••••••••" required>
                            <i class="bi bi-shield-lock"></i>
                        </div>


                        <button type="submit" class="btn btn-submit mb-4">
                            Đăng nhập ngay <i class="bi bi-arrow-right ms-2"></i>
                        </button>
                    </form>
                </div>
            </div>

            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
            <script>
                // Xóa query parameters khỏi URL sau khi hiển thị thông báo để tránh lặp lại khi refresh
                if (window.history.replaceState) {
                    const url = new URL(window.location.href);
                    url.searchParams.delete('logout');
                    url.searchParams.delete('reset');
                    window.history.replaceState({ path: url.href }, '', url.href);
                }
            </script>
        </body>

        </html>