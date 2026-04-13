<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <style>
        body {
            background-color: #f8f9fa;
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .error-container {
            text-align: center;
            padding: 3rem;
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            max-width: 500px;
        }
        .error-icon {
            font-size: 5rem;
            color: #dc3545;
            margin-bottom: 1rem;
        }
    </style>
</head>
<body>

<div class="error-container border-top border-danger border-5">
    <i class="bi bi-shield-lock-fill error-icon"></i>
    <h1 class="h3 text-dark fw-bold mb-3">403 - Access Denied</h1>
    <p class="text-muted mb-4">
        Oops! You don't have permission to access this page or perform this action.
        Only personnel with authorized roles can view this restricted area.
    </p>

    <div class="d-grid gap-2 d-md-flex justify-content-md-center">
        <button onclick="window.history.back()" class="btn btn-outline-secondary px-4">
            <i class="bi bi-arrow-left"></i> Go Back
        </button>
        <a href="${pageContext.request.contextPath}/home" class="btn btn-primary px-4">
            <i class="bi bi-house-door"></i> Return Home
        </a>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
