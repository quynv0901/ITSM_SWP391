<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đặt lại mật khẩu | ITServiceFlow</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
        <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap" rel="stylesheet">
        <style>
            body {
                font-family: 'Outfit', sans-serif;
                height: 100vh;
                margin: 0;
                overflow: hidden;
                background-color: #f8f9fa;
            }
            .login-container {
                display: flex;
                height: 100vh;
            }
            .login-left {
                flex: 1.2;
                background: linear-gradient(rgba(0,0,0,0.6), rgba(0,0,0,0.6)), url('${pageContext.request.contextPath}/assets/img/auth_bg_astronaut.png');
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
                box-shadow: -10px 0 30px rgba(0,0,0,0.05);
            }
            .brand-logo {
                width: 70px;
                height: 70px;
                background: rgba(255,255,255,0.2);
                backdrop-filter: blur(15px);
                border-radius: 16px;
                display: flex;
                align-items: center;
                justify-content: center;
                margin-bottom: 2.5rem;
                box-shadow: 0 8px 32px rgba(0,0,0,0.1);
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
                font-size: 1.25rem;
                transition: all 0.3s;
            }
            .input-wrapper input:focus + i {
                color: #4e73df;
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
                box-shadow: 0 10px 20px rgba(0,0,0,0.1);
            }
            .btn-submit:hover {
                background: #000;
                transform: translateY(-2px);
                box-shadow: 0 15px 30px rgba(0,0,0,0.15);
            }
        </style>
    </head>
    <body>

        <div class="login-container">
            <div class="login-left">
                <div class="brand-logo"><i class="bi bi-cpu fs-3 text-white"></i></div>
                <h1>New Start!</h1>
                <p>Your journey continues with a secure new identity. Set your new password below to regain full access to the ITServiceFlow system.</p>
            </div>
            <div class="login-right">
                <form action="${pageContext.request.contextPath}/auth?action=resetPassword" method="post">
                    <input type="hidden" name="token" value="${token}">
                    <h2 class="fw-bold mb-2">Đặt lại mật khẩu</h2>
                    <p class="text-muted mb-5">Hành trình mới bắt đầu! Hãy thiết lập mật khẩu an toàn hơn.</p>

                    <c:if test="${not empty error}">
                        <div class="alert alert-danger border-0 shadow-sm">${error}</div>
                        <c:if test="${empty token}">
                            <a href="${pageContext.request.contextPath}/auth?action=login" class="btn btn-submit text-decoration-none d-flex align-items-center justify-content-center">
                                <i class="bi bi-arrow-left me-2"></i> Quay lại Đăng nhập
                            </a>
                        </c:if>
                    </c:if>

                    <c:if test="${not empty token}">
                        <label class="form-label">Mật khẩu mới</label>
                        <div class="input-wrapper">
                            <input type="password" name="password" placeholder="Tối thiểu 8 ký tự..." required>
                            <i class="bi bi-shield-lock"></i>
                        </div>

                        <label class="form-label">Xác nhận mật khẩu</label>
                        <div class="input-wrapper">
                            <input type="password" name="confirm_password" placeholder="Nhập lại mật khẩu..." required>
                            <i class="bi bi-check2-circle"></i>
                        </div>

                        <button type="submit" class="btn btn-submit">
                            Đặt lại & Đăng nhập <i class="bi bi-check-lg ms-2"></i>
                        </button>
                    </c:if>
                </form>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
