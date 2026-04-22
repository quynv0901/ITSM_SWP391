package com.itserviceflow.controllers;

import com.itserviceflow.daos.MaintenanceLogDAO;
import com.itserviceflow.daos.ConfigurationItemDAO;
import com.itserviceflow.models.MaintenanceLog;
import com.itserviceflow.models.ConfigurationItem;
import com.itserviceflow.models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;
import java.util.List;

@WebServlet("/maintenance-log")
public class MaintenanceLogController extends HttpServlet {

    private MaintenanceLogDAO maintenanceLogDAO;
    private ConfigurationItemDAO configurationItemDAO;

    // Các trạng thái hợp lệ theo luồng nghiệp vụ
    private static final java.util.Set<String> VALID_STATUSES = java.util.Set.of(
        "PENDING", "CONTACTED_VENDOR", "IN_PROGRESS", "COMPLETED"
    );

    // Các role được phép TẠO/SỬA/XÓA (kỹ sư hệ thống, quản lý tài sản, admin)
    private static final java.util.Set<Integer> WRITE_ROLES = java.util.Set.of(6, 8, 10);

    @Override
    public void init() throws ServletException {
        maintenanceLogDAO = new MaintenanceLogDAO();
        configurationItemDAO = new ConfigurationItemDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "list";

        switch (action) {
            case "new":
                requireWriteRole(req, res, () -> showForm(req, res, null));
                break;
            case "edit":
                requireWriteRole(req, res, () -> showEditForm(req, res));
                break;
            case "delete":
                requireWriteRole(req, res, () -> softDelete(req, res));
                break;
            case "restore":
                requireWriteRole(req, res, () -> restore(req, res));
                break;
            case "list":
            default:
                listLogs(req, res);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if ("save".equals(action)) {
            requireWriteRole(req, res, () -> saveLog(req, res));
        } else {
            res.sendRedirect(req.getContextPath() + "/maintenance-log");
        }
    }

    // ── Danh sách ─────────────────────────────────────────────────────────────

    private void listLogs(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String keyword  = req.getParameter("keyword");
        String type     = req.getParameter("type");
        String status   = req.getParameter("status");
        String ciIdStr  = req.getParameter("ciId");

        Integer ciId = null;
        if (ciIdStr != null && !ciIdStr.isEmpty()) {
            try { ciId = Integer.parseInt(ciIdStr); } catch (NumberFormatException ignored) {}
        }

        int page     = parsePage(req.getParameter("page"));
        int pageSize = 5;

        int total      = maintenanceLogDAO.countLogs(keyword, ciId, type, status);
        int totalPages = (int) Math.ceil((double) total / pageSize);
        if (page > totalPages && totalPages > 0) page = totalPages;

        List<MaintenanceLog> logs = maintenanceLogDAO.getLogsPaged(keyword, ciId, type, status, page, pageSize);
        List<ConfigurationItem> cis = configurationItemDAO.getAllConfigurationItems(null, null);

        // Cảnh báo CI đang INACTIVE chưa có log bảo trì đang mở
        List<String> inactiveCIsWithoutLog = maintenanceLogDAO.getInactiveCIsWithoutOpenLog();

        req.setAttribute("logs", logs);
        req.setAttribute("cis", cis);
        req.setAttribute("inactiveCIsWithoutLog", inactiveCIsWithoutLog);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalRecords", total);
        req.setAttribute("keyword", keyword);
        req.setAttribute("type", type);
        req.setAttribute("status", status);
        req.setAttribute("ciId", ciId);

        req.getRequestDispatcher("/maintenance/list.jsp").forward(req, res);
    }

    // ── Form ──────────────────────────────────────────────────────────────────

    private void showForm(HttpServletRequest req, HttpServletResponse res, MaintenanceLog log)
            throws ServletException, IOException {
        // Load tất cả CI (kể cả INACTIVE) — cần log thiết bị đang hỏng
        List<ConfigurationItem> cis = configurationItemDAO.getAllConfigurationItems(null, null);
        req.setAttribute("cis", cis);
        if (log != null) req.setAttribute("log", log);
        req.getRequestDispatcher("/maintenance/form.jsp").forward(req, res);
    }

    private void showEditForm(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            MaintenanceLog log = maintenanceLogDAO.getLogById(id);
            if (log == null) {
                res.sendRedirect(req.getContextPath() + "/maintenance-log?error=notfound");
                return;
            }
            showForm(req, res, log);
        } catch (NumberFormatException e) {
            res.sendRedirect(req.getContextPath() + "/maintenance-log");
        }
    }

    // ── Lưu (tạo mới / cập nhật) với validate đầy đủ ────────────────────────

    private void saveLog(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String idStr       = req.getParameter("logId");
        String ciIdStr     = req.getParameter("ciId");
        String type        = req.getParameter("maintenanceType");
        String dateStr     = req.getParameter("maintenanceDate");
        String description = req.getParameter("description");
        String status      = req.getParameter("status");

        int id = 0;
        try { id = Integer.parseInt(idStr); } catch (Exception ignored) {}

        MaintenanceLog log = new MaintenanceLog();
        log.setLogId(id);

        // ── Validate CI ───────────────────────────────────────────────────────
        try {
            int ciId = Integer.parseInt(ciIdStr);
            if (ciId <= 0) throw new NumberFormatException();
            log.setCiId(ciId);
        } catch (Exception e) {
            setError(req, "Vui lòng chọn thiết bị hợp lệ từ danh sách.");
            showForm(req, res, log);
            return;
        }

        // ── Validate loại bảo trì ─────────────────────────────────────────────
        if (type == null || type.trim().isEmpty()) {
            setError(req, "Loại bảo trì không được để trống.");
            showForm(req, res, log);
            return;
        }
        if (type.trim().length() > 200) {
            setError(req, "Loại bảo trì quá dài (tối đa 200 ký tự).");
            showForm(req, res, log);
            return;
        }
        log.setMaintenanceType(type.trim());

        // ── Validate ngày ─────────────────────────────────────────────────────
        if (dateStr == null || dateStr.trim().isEmpty()) {
            setError(req, "Vui lòng chọn ngày thực hiện hoặc ngày lên lịch.");
            showForm(req, res, log);
            return;
        }
        try {
            Date d = Date.valueOf(dateStr);
            // Giới hạn hợp lý: không quá khứ quá 5 năm, không tương lai quá 1 năm
            long now = System.currentTimeMillis();
            long diff = d.getTime() - now;
            if (d.getTime() < now - (5L * 365 * 24 * 60 * 60 * 1000)) {
                setError(req, "Ngày thực hiện không hợp lệ (quá xa trong quá khứ).");
                showForm(req, res, log);
                return;
            }
            if (diff > (366L * 24 * 60 * 60 * 1000)) {
                setError(req, "Ngày lên lịch không được quá 1 năm trong tương lai.");
                showForm(req, res, log);
                return;
            }
            log.setMaintenanceDate(d);
        } catch (IllegalArgumentException e) {
            setError(req, "Ngày không hợp lệ. Vui lòng chọn lại.");
            showForm(req, res, log);
            return;
        }

        // ── Validate mô tả ────────────────────────────────────────────────────
        if (description == null || description.trim().length() < 10) {
            setError(req, "Chi tiết công việc phải có ít nhất 10 ký tự.");
            showForm(req, res, log);
            return;
        }
        if (description.trim().length() > 3000) {
            setError(req, "Chi tiết công việc quá dài (tối đa 3000 ký tự).");
            showForm(req, res, log);
            return;
        }
        log.setDescription(description.trim());

        // ── Validate trạng thái ───────────────────────────────────────────────
        if (status == null || !VALID_STATUSES.contains(status)) {
            status = "PENDING";
        }
        log.setStatus(status);

        // Nếu chuyển sang COMPLETED và chưa có completed_at → set về thời điểm hiện tại
        if ("COMPLETED".equals(status)) {
            MaintenanceLog existing = (id > 0) ? maintenanceLogDAO.getLogById(id) : null;
            if (existing == null || existing.getCompletedAt() == null) {
                log.setCompletedAt(new java.sql.Timestamp(System.currentTimeMillis()));
            } else {
                log.setCompletedAt(existing.getCompletedAt());
            }
            // Auto set started_at nếu chưa có
            if (existing != null && existing.getStartedAt() != null) {
                log.setStartedAt(existing.getStartedAt());
            }
        } else if ("IN_PROGRESS".equals(status) || "CONTACTED_VENDOR".equals(status)) {
            // Bắt đầu tiến hành (Tự sửa) hoặc Liên hệ NCC (NCC sửa) → đều ghi nhận started_at nếu chưa có
            MaintenanceLog existing = (id > 0) ? maintenanceLogDAO.getLogById(id) : null;
            if (existing == null || existing.getStartedAt() == null) {
                log.setStartedAt(new java.sql.Timestamp(System.currentTimeMillis()));
            } else {
                log.setStartedAt(existing.getStartedAt());
            }
            // Reset completedAt nếu đang từ COMPLETED quay ngược về các trạng thái đang xử lý
            log.setCompletedAt(null);
        } else {
            // Trường hợp PENDING → xoá hết thời gian tính toán
            log.setStartedAt(null);
            log.setCompletedAt(null);
        }

        // Tự động khôi phục CI status nếu chọn
        String autoActiveCi = req.getParameter("autoActiveCi");
        if ("COMPLETED".equals(status) && "true".equals(autoActiveCi)) {
            configurationItemDAO.updateCiStatus(log.getCiId(), "ACTIVE");
        }

        // ── Người tạo = người phụ trách (lấy từ session) ───────────────────────
        try {
            User sessionUser = (User) req.getSession().getAttribute("user");
            if (sessionUser != null) {
                log.setCreatedBy(sessionUser.getUserId());
                log.setPerformedBy(sessionUser.getUserId());
            }
        } catch (Exception ignored) {}

        // ── Lưu vào DB ───────────────────────────────────────────────────────
        boolean ok = (id > 0) ? maintenanceLogDAO.updateLog(log) : maintenanceLogDAO.createLog(log);

        if (ok) {
            res.sendRedirect(req.getContextPath() + "/maintenance-log?success=" + (id > 0 ? "updated" : "created"));
        } else {
            setError(req, "Có lỗi khi lưu dữ liệu. Vui lòng thử lại.");
            showForm(req, res, log);
        }
    }

    // ── Xóa mềm & Khôi phục ──────────────────────────────────────────────────

    private void softDelete(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            maintenanceLogDAO.softDeleteLog(id);
            res.sendRedirect(req.getContextPath() + "/maintenance-log?success=deleted");
        } catch (NumberFormatException e) {
            res.sendRedirect(req.getContextPath() + "/maintenance-log");
        }
    }

    private void restore(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            maintenanceLogDAO.restoreLog(id);
            res.sendRedirect(req.getContextPath() + "/maintenance-log?success=restored");
        } catch (NumberFormatException e) {
            res.sendRedirect(req.getContextPath() + "/maintenance-log");
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    /** Chỉ cho phép role có quyền ghi mới thực hiện action */
    private void requireWriteRole(HttpServletRequest req, HttpServletResponse res,
                                   CheckedRunnable action) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null || !WRITE_ROLES.contains(user.getRoleId())) {
            res.sendRedirect(req.getContextPath() + "/auth?action=forbid");
            return;
        }
        action.run();
    }

    private void setError(HttpServletRequest req, String msg) {
        req.setAttribute("errorMessage", msg);
    }

    private int parsePage(String pageStr) {
        try { return Math.max(1, Integer.parseInt(pageStr)); } catch (Exception e) { return 1; }
    }

    @FunctionalInterface
    interface CheckedRunnable {
        void run() throws ServletException, IOException;
    }
}
