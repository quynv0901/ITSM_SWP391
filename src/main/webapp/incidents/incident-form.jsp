<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/includes/header.jsp" />
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

        .incident-form-page {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            background-color: var(--bg-color);
            color: var(--text-primary);
            line-height: 1.6;
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

        .suggest-box {
            border: 1px solid var(--border-color);
            background: #f8fafc;
            border-radius: 12px;
            padding: 16px;
        }

        .suggest-title {
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .suggest-list {
            display: flex;
            flex-direction: column;
            gap: 10px;
            margin-top: 10px;
        }

        .suggest-item {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            align-items: center;
            padding: 12px 12px;
            background: #fff;
            border: 1px solid var(--border-color);
            border-radius: 10px;
        }

        .suggest-main {
            display: flex;
            flex-direction: column;
            gap: 2px;
            min-width: 0;
        }

        .suggest-code {
            font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;
            font-size: 12px;
            font-weight: 800;
            color: #64748b;
        }

        .suggest-text {
            font-size: 14px;
            font-weight: 600;
            color: var(--text-primary);
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            max-width: 520px;
        }

        .suggest-meta {
            font-size: 12px;
            color: var(--text-secondary);
        }

        .chip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 10px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 700;
            border: 1px solid var(--border-color);
            background: #fff;
            color: #334155;
            white-space: nowrap;
        }

        .chip-selected {
            background: #eff6ff;
            border-color: #93c5fd;
            color: #1d4ed8;
        }

        .btn-mini {
            padding: 8px 12px;
            border-radius: 10px;
            font-size: 12px;
            font-weight: 800;
            border: none;
            cursor: pointer;
            background: #e2e8f0;
            color: #0f172a;
        }

        .btn-mini:hover {
            background: #cbd5e1;
        }

        .btn-mini-primary {
            background: #3b82f6;
            color: #fff;
        }

        .btn-mini-primary:hover {
            background: #2563eb;
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

    <div class="incident-form-page container-fluid bg-white p-4 rounded shadow-sm">
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

                        <!-- Suggest similar incidents (End-user + Agent/Expert) -->
                        <c:choose>
                            <c:when test="${sessionScope.user.roleId == 1}">
                                <div class="suggest-box">
                                    <div class="suggest-title">✨ Gợi ý sự cố tương tự</div>
                                    <div class="help-text">
                                        Dựa trên tiêu đề/mô tả bạn nhập, hệ thống sẽ gợi ý các sự cố có thể trùng.
                                        Nếu đúng, bạn có thể chọn để liên kết (giúp xử lý nhanh hơn).
                                    </div>
                                    <input type="hidden" id="relatedIds" name="relatedIds" value="">
                                    <div class="suggest-list" id="suggestList">
                                        <div class="help-text" id="suggestHint">Nhập tiêu đề/mô tả để xem gợi ý.</div>
                                    </div>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="suggest-box">
                                    <div class="suggest-title">🔎 Tra cứu sự cố đã từng xảy ra</div>
                                    <div class="help-text">
                                        Agent/Expert: hệ thống sẽ gợi ý theo <b>ticket number</b>, <b>mã lỗi</b> (trong tiêu đề/mô tả/cause/solution) và
                                        <b>cả ticket đã đóng/đã hủy</b> để bạn kiểm tra lịch sử.
                                    </div>
                                    <input type="hidden" id="relatedIds" name="relatedIds" value="">
                                    <div class="suggest-list" id="suggestList">
                                        <div class="help-text" id="suggestHint">Nhập tiêu đề/mô tả để xem gợi ý.</div>
                                    </div>
                                </div>
                            </c:otherwise>
                        </c:choose>
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

    <c:if test="${empty incident}">
        <script>
            (function () {
                const titleEl = document.getElementById('title');
                const descEl = document.getElementById('description');
                const categoryEl = document.getElementById('categoryId');
                const suggestList = document.getElementById('suggestList');
                const hiddenRelated = document.getElementById('relatedIds');
                const __isEndUser = ${sessionScope.user.roleId == 1 ? 'true' : 'false'};

                let debounceTimer = null;
                let selectedIds = new Set();

                function normalize(value) {
                    if (value == null) return '';
                    return String(value).trim().replace(/\s+/g, ' ');
                }

                function renderHint(text) {
                    suggestList.innerHTML = '';
                    const div = document.createElement('div');
                    div.className = 'help-text';
                    div.textContent = text;
                    suggestList.appendChild(div);
                }

                function updateHidden() {
                    hiddenRelated.value = Array.from(selectedIds).join(',');
                }

                function toggleSelect(id, btn, chip) {
                    if (selectedIds.has(id)) {
                        selectedIds.delete(id);
                        btn.textContent = 'Chọn';
                        btn.classList.remove('btn-mini-primary');
                        chip.classList.remove('chip-selected');
                    } else {
                        // End-user keep small; Agent/Expert can select more
                        const max = __isEndUser ? 3 : 10;
                        if (selectedIds.size >= max) return;
                        selectedIds.add(id);
                        btn.textContent = 'Đã chọn';
                        btn.classList.add('btn-mini-primary');
                        chip.classList.add('chip-selected');
                    }
                    updateHidden();
                }

                async function fetchSuggestions() {
                    // Agent/Expert: use both title + description to improve matching
                    const q = __isEndUser
                        ? (normalize(titleEl.value) || normalize(descEl.value))
                        : normalize((titleEl.value || '') + ' ' + (descEl.value || ''));
                    const categoryId = categoryEl.value;

                    if (!q || q.length < 3) {
                        renderHint('Nhập ít nhất 3 ký tự trong tiêu đề hoặc mô tả để xem gợi ý.');
                        return;
                    }

                    const params = new URLSearchParams();
                    params.set('action', 'suggest');
                    params.set('q', q);
                    if (categoryId) params.set('categoryId', categoryId);
                    if (!__isEndUser) params.set('mode', 'agent');

                    renderHint('Đang tìm gợi ý...');

                    try {
                        const res = await fetch('${pageContext.request.contextPath}/incident?' + params.toString(), {
                            headers: { 'Accept': 'application/json' }
                        });
                        if (!res.ok) throw new Error('HTTP ' + res.status);
                        const data = await res.json();

                        suggestList.innerHTML = '';
                        if (!Array.isArray(data) || data.length === 0) {
                            renderHint('Không tìm thấy sự cố tương tự.');
                            return;
                        }

                        data.forEach(item => {
                            const id = String(item.ticketId);
                            const wrap = document.createElement('div');
                            wrap.className = 'suggest-item';

                            const main = document.createElement('div');
                            main.className = 'suggest-main';

                            const code = document.createElement('div');
                            code.className = 'suggest-code';
                            code.textContent = item.ticketNumber || ('#' + id);

                            const text = document.createElement('div');
                            text.className = 'suggest-text';
                            text.textContent = item.title || '';

                            const meta = document.createElement('div');
                            meta.className = 'suggest-meta';
                            const parts = [];
                            parts.push('Trạng thái: ' + (item.status || 'N/A'));
                            if (!__isEndUser && item.priority) parts.push('Ưu tiên: ' + item.priority);
                            meta.textContent = parts.join(' • ');

                            main.appendChild(code);
                            main.appendChild(text);
                            main.appendChild(meta);

                            const right = document.createElement('div');
                            right.style.display = 'flex';
                            right.style.alignItems = 'center';
                            right.style.gap = '10px';

                            const chip = document.createElement('span');
                            chip.className = 'chip' + (selectedIds.has(id) ? ' chip-selected' : '');
                            chip.textContent = selectedIds.has(id) ? 'Đã chọn' : 'Gợi ý';

                            const btn = document.createElement('button');
                            btn.type = 'button';
                            btn.className = 'btn-mini' + (selectedIds.has(id) ? ' btn-mini-primary' : '');
                            btn.textContent = selectedIds.has(id) ? 'Đã chọn' : 'Chọn';
                            btn.addEventListener('click', function () {
                                toggleSelect(id, btn, chip);
                            });

                            right.appendChild(chip);
                            right.appendChild(btn);

                            wrap.appendChild(main);
                            wrap.appendChild(right);

                            suggestList.appendChild(wrap);
                        });
                        updateHidden();
                    } catch (e) {
                        renderHint('Không thể tải gợi ý. Vui lòng thử lại.');
                    }
                }

                function scheduleFetch() {
                    if (debounceTimer) clearTimeout(debounceTimer);
                    debounceTimer = setTimeout(fetchSuggestions, 350);
                }

                titleEl.addEventListener('input', scheduleFetch);
                descEl.addEventListener('input', scheduleFetch);
                categoryEl.addEventListener('change', scheduleFetch);

                renderHint('Nhập tiêu đề/mô tả để xem gợi ý.');
            })();
        </script>
    </c:if>

</div>

<jsp:include page="/includes/footer.jsp" />
