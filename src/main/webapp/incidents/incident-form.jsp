<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${not empty incident ? 'Chỉnh sửa Sự cố' : 'Tạo Sự cố'}</title>
    <style>
        :root {
            --primary-color: #3b82f6;
            --primary-hover: #2563eb;
            --success-color: #10b981;
            --success-hover: #059669;
            --danger-color: #ef4444;
            --danger-hover: #dc2626;
            --warning-color: #f59e0b;
             --text-primary: #1f2937;
            --text-secondary: #6b7280;
            --bg-color: #f8fafc;
            --card-bg: #ffffff;
            --border-color: #e5e7eb;
            --shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            background-color: var(--bg-color);
            color: var(--text-primary);
            line-height: 1.6;
            padding: 20px;
        }

        .container {
            max-width: 800px;
            margin: 0 auto;
            background: var(--card-bg);
            border-radius: 16px;
            box-shadow: var(--shadow);
            overflow: hidden;
        }

        .header {
            background: linear-gradient(135deg, var(--primary-color), #8b5cf6);
            color: white;
            padding: 30px;
            text-align: center;
        }

        .header h1 {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 10px;
        }

        .header p {
            font-size: 1.1rem;
            opacity: 0.9;
        }

        .form-container {
            padding: 40px;
        }

        .form-section {
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid var(--border-color);
        }

        .form-section:last-child {
            border-bottom: none;
            margin-bottom: 0;
        }

        .section-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .form-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }

        .form-group label {
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 8px;
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .required {
            color: var(--danger-color);
            margin-left: 4px;
        }

        .form-control {
            width: 100%;
            padding: 14px 16px;
            border: 2px solid var(--border-color);
            border-radius: 10px;
            font-size: 1rem;
            transition: all 0.3s ease;
            background-color: #fafafa;
        }

        .form-control:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
            background-color: white;
        }

        .form-control::placeholder {
            color: var(--text-secondary);
        }

        textarea.form-control {
            resize: vertical;
            min-height: 120px;
        }

        select.form-control {
            background-color: white;
            cursor: pointer;
        }

        .help-text {
            font-size: 0.85rem;
            color: var(--text-secondary);
            margin-top: 5px;
            font-style: italic;
        }

        .btn-group {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
        }

        .btn {
            padding: 14px 32px;
            border-radius: 10px;
            font-size: 1rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            min-width: 150px;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary-color), #8b5cf6);
            color: white;
            box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(59, 130, 246, 0.4);
            background: linear-gradient(135deg, var(--primary-hover), #7c3aed);
        }

        .btn-secondary {
            background-color: var(--text-secondary);
            color: white;
        }

        .btn-secondary:hover {
            background-color: var(--text-primary);
            transform: translateY(-2px);
        }

        .btn-danger {
            background-color: var(--danger-color);
            color: white;
        }

        .btn-danger:hover {
            background-color: var(--danger-hover);
            transform: translateY(-2px);
        }

        .btn-warning {
            background-color: var(--warning-color);
            color: white;
        }

        .btn-warning:hover {
            background-color: #d97706;
            transform: translateY(-2px);
        }

        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
            text-transform: uppercase;
        }

        .status-new { background-color: #dbeafe; color: #1d4ed8; }
        .status-in-progress { background-color: #f3e8ff; color: #5b21b6; }
        .status-resolved { background-color: #d1fae5; color: #065f46; }
        .status-cancelled { background-color: #fee2e2; color: #991b1b; }

        .alert {
            padding: 12px 14px;
            border-radius: 10px;
            margin-bottom: 16px;
            font-size: 0.95rem;
            font-weight: 600;
        }

        .alert-error {
            background: #fff1f2;
            border: 1px solid #fecdd3;
            color: #be123c;
        }

        .incident-info {
            background-color: #f8fafc;
            border: 1px solid var(--border-color);
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
        }

        .incident-info h3 {
            margin-bottom: 15px;
            color: var(--text-primary);
            font-size: 1.1rem;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
        }

        .info-item {
            background: white;
            padding: 15px;
            border-radius: 8px;
            border: 1px solid var(--border-color);
        }

        .info-label {
            font-size: 0.8rem;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 5px;
        }

        .info-value {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--text-primary);
        }

        @media (max-width: 768px) {
            .container {
                margin: 10px;
                border-radius: 12px;
            }
            
            .header {
                padding: 20px;
            }
            
            .header h1 {
                font-size: 1.5rem;
            }
            
            .form-container {
                padding: 20px;
            }
            
            .form-row {
                grid-template-columns: 1fr;
            }
            
            .btn-group {
                flex-direction: column;
                align-items: center;
            }
            
            .btn {
                width: 100%;
                max-width: 300px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>${not empty incident ? '✏️ Chỉnh sửa Sự cố' : '➕ Tạo Sự cố mới'}</h1>
            <p>Báo cáo và quản lý sự cố dịch vụ CNTT hiệu quả</p>
        </div>

        <div class="form-container">
            <c:if test="${not empty param.error}">
                <div class="alert alert-error">
                    <c:choose>
                        <c:when test="${param.error == 'missingTitle'}">Vui lòng nhập tiêu đề sự cố.</c:when>
                        <c:when test="${param.error == 'missingDescription'}">Vui lòng nhập mô tả chi tiết.</c:when>
                        <c:when test="${param.error == 'invalidCategory'}">Danh mục không hợp lệ. Vui lòng chọn lại.</c:when>
                        <c:when test="${param.error == 'invalidPriority'}">Mức ưu tiên không hợp lệ.</c:when>
                        <c:when test="${param.error == 'invalidTitleFormat'}">Tiêu đề chỉ được chứa chữ cái và khoảng trắng (không số, không ký tự đặc biệt).</c:when>
                        <c:when test="${param.error == 'invalidDescriptionFormat'}">Mô tả chỉ được chứa chữ cái và khoảng trắng (không số, không ký tự đặc biệt).</c:when>
                        <c:when test="${param.error == 'invalidTextFormat'}">Tiêu đề/Mô tả không hợp lệ: chỉ cho phép chữ cái và khoảng trắng.</c:when>
                        <c:otherwise>Dữ liệu không hợp lệ. Vui lòng kiểm tra lại thông tin nhập.</c:otherwise>
                    </c:choose>
                </div>
            </c:if>
            <form action="${pageContext.request.contextPath}/incident?action=${not empty incident ? 'update' : 'insert'}" method="post">
                <c:if test="${not empty incident}">
                    <input type="hidden" name="id" value="${incident.ticketId}">
                    
                    <!-- Khu vực thông tin incident -->
                    <div class="incident-info">
                        <h3>📋 Thông tin Sự cố</h3>
                        <div class="info-grid">
                            <div class="info-item">
                                <div class="info-label">Mã ticket</div>
                                <div class="info-value">${incident.ticketNumber}</div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Trạng thái hiện tại</div>
                                <div class="info-value">
                                    <span class="status-badge status-${incident.status}">${incident.status}</span>
                                </div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Ngày tạo</div>
                                <div class="info-value">
                                    ${incident.createdAt}
                                </div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Người báo cáo</div>
                                <div class="info-value">User #${incident.reportedBy}</div>
                            </div>
                        </div>
                    </div>
                </c:if>

                <!-- Khu vực thông tin cơ bản -->
                <div class="form-section">
                    <div class="section-title">📝 Thông tin cơ bản</div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="title">
                                Tiêu đề sự cố <span class="required">*</span>
                            </label>
                            <input type="text" id="title" name="title" class="form-control" 
                                   value="${incident.title}" 
                                   placeholder="Mô tả ngắn gọn sự cố..." 
                                   required>
                        </div>
                        <div class="form-group">
                            <label for="priority">
                                Mức ưu tiên
                            </label>
                            <select id="priority" name="priority" class="form-control">
                                <option value="LOW" ${incident.priority=='LOW' ? 'selected' : ''}>🟢 Thấp</option>
                                <option value="MEDIUM" ${incident.priority=='MEDIUM' ? 'selected' : ''}>🟡 Trung bình</option>
                                <option value="HIGH" ${incident.priority=='HIGH' ? 'selected' : ''}>🟠 Cao</option>
                            </select>
                            <div class="help-text">Chọn theo mức độ ảnh hưởng đến nghiệp vụ</div>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="description">
                            Mô tả chi tiết <span class="required">*</span>
                        </label>
                        <textarea id="description" name="description" class="form-control" 
                                  placeholder="Vui lòng cung cấp thông tin chi tiết về sự cố..." 
                                  required>${incident.description}</textarea>
                        <div class="help-text">Nên bao gồm lỗi, các bước tái hiện và hệ thống bị ảnh hưởng</div>
                    </div>
                </div>

                <!-- Khu vực phân loại -->
                <div class="form-section">
                    <div class="section-title">🏷️ Phân loại</div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="categoryId">
                                Danh mục <span class="required">*</span>
                            </label>
                            <select id="categoryId" name="categoryId" class="form-control" required>
                                <option value="">-- Chọn danh mục --</option>
                                <c:forEach var="category" items="${categories}">
                                    <option value="${category.categoryId}" 
                                            ${incident.categoryId == category.categoryId ? 'selected' : ''}>
                                        ${category.categoryName} (${category.categoryCode})
                                    </option>
                                </c:forEach>
                            </select>
                            <div class="help-text">Chọn danh mục phù hợp nhất với sự cố này</div>
                        </div>
                        <c:if test="${not empty incident}">
                            <div class="form-group">
                                <label for="status">
                                    Trạng thái
                                </label>
                                <c:choose>
                                    <c:when test="${isEndUserEditingOwnTicket}">
                                        <input type="text" class="form-control" value="${incident.status}" readonly>
                                        <input type="hidden" name="status" value="${incident.status}">
                                        <div class="help-text">End-user không được đổi trạng thái ticket.</div>
                                    </c:when>
                                    <c:otherwise>
                                        <select id="status" name="status" class="form-control">
                                            <option value="NEW" ${incident.status=='NEW' ? 'selected' : ''}>🆕 Mới</option>
                                            <option value="IN_PROGRESS" ${incident.status=='IN_PROGRESS' ? 'selected' : ''}>🔄 Đang xử lý</option>
                                            <option value="RESOLVED" ${incident.status=='RESOLVED' ? 'selected' : ''}>✅ Đã xử lý</option>
                                            <option value="CANCELLED" ${incident.status=='CANCELLED' ? 'selected' : ''}>❌ Đã hủy</option>
                                        </select>
                                        <div class="help-text">Cập nhật trạng thái trong quá trình xử lý sự cố</div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:if>
                    </div>
                </div>

                <!-- Khu vực incident liên quan -->
                <c:if test="${empty incident}">
                    <div class="form-section">
                    <div class="section-title">🔗 Sự cố liên quan</div>
                        <div class="form-group">
                            <label for="relatedIds">
                                Liên kết sự cố liên quan
                            </label>
                            <input type="text" id="relatedIds" name="relatedIds" class="form-control" 
                                   placeholder="ví dụ: 101, 102, 103">
                            <div class="help-text">Tùy chọn: Nhập ID sự cố, cách nhau bởi dấu phẩy nếu có liên quan</div>
                        </div>
                    </div>
                </c:if>

                <!-- Nhóm nút thao tác -->
                <div class="btn-group">
                    <button type="submit" class="btn btn-primary">
                        ${not empty incident ? '💾 Lưu thay đổi' : '➕ Tạo sự cố'}
                    </button>
                    <a href="${pageContext.request.contextPath}/incident?action=list" class="btn btn-secondary">
                        ↩️ Hủy
                    </a>
                </div>
            </form>
        </div>
    </div>

</body>
</html>
