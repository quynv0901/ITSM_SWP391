<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quên mật khẩu | ITServiceFlow</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Outfit', sans-serif; height: 100vh; margin: 0; overflow: hidden; background-color: #f8f9fa; }
        .login-container { display: flex; height: 100vh; }
        .login-left {
            flex: 1.2;
            background: linear-gradient(rgba(0,0,0,0.6), rgba(0,0,0,0.6)), url('${pageContext.request.contextPath}/assets/img/auth_bg_astronaut.png');
            background-size: cover; background-position: center;
            display: flex; flex-direction: column; justify-content: center; padding: 100px; color: white;
        }
        .login-right {
            flex: 1; background: white; display: flex; flex-direction: column; justify-content: center; padding: 100px;
            box-shadow: -10px 0 30px rgba(0,0,0,0.05);
        }
        .brand-logo { width: 70px; height: 70px; background: rgba(255,255,255,0.2); backdrop-filter: blur(15px); border-radius: 16px; display: flex; align-items: center; justify-content: center; margin-bottom: 2.5rem; box-shadow: 0 8px 32px rgba(0,0,0,0.1); }
        .login-left h1 { font-size: 4rem; font-weight: 700; margin-bottom: 1.5rem; letter-spacing: -1px; }
        .login-left p { font-size: 1.25rem; opacity: 0.9; max-width: 500px; margin-bottom: 3rem; line-height: 1.6; }
        .form-label { font-weight: 700; color: #495057; margin-top: 2rem; font-size: 0.9rem; text-transform: uppercase; letter-spacing: 0.5px; }
        .input-wrapper { position: relative; margin-top: 0.5rem; }
        .input-wrapper input { border: none; border-bottom: 2px solid #e9ecef; border-radius: 0; padding: 15px 45px 15px 0; width: 100%; outline: none; transition: all 0.3s ease; font-size: 1.1rem; font-weight: 500; }
        .input-wrapper input:focus { border-color: #4e73df; padding-left: 5px; }
        .input-wrapper i { position: absolute; right: 15px; top: 50%; transform: translateY(-50%); color: #ced4da; font-size: 1.25rem; transition: all 0.3s; }
        .input-wrapper input:focus + i { color: #4e73df; }
        .btn-submit { background: #212529; color: white; border: none; padding: 18px 40px; border-radius: 12px; font-weight: 700; font-size: 1.1rem; transition: all 0.3s; width: 100%; margin-top: 3rem; box-shadow: 0 10px 20px rgba(0,0,0,0.1); }
        .btn-submit:hover { background: #000; transform: translateY(-2px); box-shadow: 0 15px 30px rgba(0,0,0,0.15); }
    </style>
</head>
<body>

<div class="login-container">
    <div class="login-left">
        <div class="brand-logo"><i class="bi bi-cpu fs-3 text-white"></i></div>
        <h1>Lost?</h1>
        <p>Don't worry, even astronauts get lost sometimes. Enter your email to receive instructions on how to reset your password.</p>
    </div>
    <div class="login-right">
        <div class="mb-5">
            <a href="${pageContext.request.contextPath}/auth?action=login" class="text-decoration-none text-primary fw-bold small"><i class="bi bi-arrow-left me-1"></i> TRỞ LẠI ĐĂNG NHẬP</a>
        </div>

        <form action="${pageContext.request.contextPath}/auth?action=forgotPassword" method="post">
            <h2 class="fw-bold mb-2">Quên mật khẩu?</h2>
            <p class="text-muted mb-5">Đừng lo, hãy nhập email để nhận mã đặt lại mật khẩu.</p>
            
            <c:if test="${not empty error}">
                <div class="alert alert-danger border-0 shadow-sm">${error}</div>
            </c:if>
            <c:if test="${not empty message}">
                <div class="alert alert-success border-0 shadow-sm">${message}</div>
            </c:if>

            <label class="form-label">Địa chỉ Email</label>
            <div class="input-wrapper">
                <input type="email" name="email" placeholder="example@gmail.com" required>
                <i class="bi bi-envelope"></i>
            </div>

            <button type="submit" class="btn btn-submit">
                Gửi yêu cầu đặt lại <i class="bi bi-send ms-2"></i>
            </button>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
