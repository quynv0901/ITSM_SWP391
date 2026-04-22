package com.itserviceflow.controllers;

import com.itserviceflow.daos.MaintenanceLogDAO;
import com.itserviceflow.daos.ConfigurationItemDAO;
import com.itserviceflow.models.MaintenanceLog;
import com.itserviceflow.models.ConfigurationItem;

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

    @Override
    public void init() throws ServletException {
        maintenanceLogDAO = new MaintenanceLogDAO();
        configurationItemDAO = new ConfigurationItemDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "new":
                showForm(request, response, null);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteLog(request, response);
                break;
            case "list":
            default:
                listLogs(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("save".equals(action)) {
            saveLog(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/maintenance-log");
        }
    }

    private void listLogs(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        String type = request.getParameter("type");
        String ciIdStr = request.getParameter("ciId");
        
        Integer ciId = null;
        if (ciIdStr != null && !ciIdStr.isEmpty()) {
            try { ciId = Integer.parseInt(ciIdStr); } catch (NumberFormatException ignored) {}
        }

        int page = 1;
        int pageSize = 10;
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.isEmpty()) {
            try { page = Integer.parseInt(pageStr); } catch (NumberFormatException ignored) {}
        }

        int totalRecords = maintenanceLogDAO.countLogs(keyword, ciId, type);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
        if (page > totalPages && totalPages > 0) page = totalPages;

        List<MaintenanceLog> logs = maintenanceLogDAO.getLogsPaged(keyword, ciId, type, page, pageSize);
        // Load tất cả CI (bao gồm INACTIVE) để có thể ghi nhật ký cho thiết bị đang hỏng
        List<ConfigurationItem> cis = configurationItemDAO.getAllConfigurationItems(null, null);

        request.setAttribute("logs", logs);
        request.setAttribute("cis", cis);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("keyword", keyword);
        request.setAttribute("type", type);
        request.setAttribute("ciId", ciId);

        request.getRequestDispatcher("/maintenance/list.jsp").forward(request, response);
    }

    private void showForm(HttpServletRequest request, HttpServletResponse response, MaintenanceLog log)
            throws ServletException, IOException {
        // Load tất cả CI (bao gồm INACTIVE) — đặc biệt quan trọng để ghi log cho thiết bị đang hỏng
        List<ConfigurationItem> cis = configurationItemDAO.getAllConfigurationItems(null, null);
        request.setAttribute("cis", cis);
        
        if (log != null) {
            request.setAttribute("log", log);
        }
        request.getRequestDispatcher("/maintenance/form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            MaintenanceLog log = maintenanceLogDAO.getLogById(id);
            if (log == null) {
                response.sendRedirect(request.getContextPath() + "/maintenance-log?error=" + java.net.URLEncoder.encode("Không tìm thấy nhật ký", "UTF-8"));
                return;
            }
            showForm(request, response, log);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/maintenance-log");
        }
    }

    private void saveLog(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("logId");
        String ciIdStr = request.getParameter("ciId");
        String type = request.getParameter("maintenanceType");
        String dateStr = request.getParameter("maintenanceDate");
        String downtimeStr = request.getParameter("downtimeMinutes");
        String description = request.getParameter("description");
        String status = request.getParameter("status");

        int id = (idStr != null && !idStr.isEmpty()) ? Integer.parseInt(idStr) : 0;
        
        MaintenanceLog log = new MaintenanceLog();
        log.setLogId(id);
        
        try {
            log.setCiId(Integer.parseInt(ciIdStr));
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Vui lòng chọn Thiết bị hợp lệ.");
            showForm(request, response, log);
            return;
        }
        
        log.setMaintenanceType(type);
        
        try {
            log.setMaintenanceDate(Date.valueOf(dateStr));
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Ngày bảo trì không hợp lệ.");
            showForm(request, response, log);
            return;
        }
        
        try {
            int downtime = Integer.parseInt(downtimeStr);
            if (downtime < 0) {
                request.setAttribute("errorMessage", "Thời gian Downtime không được là số âm.");
                showForm(request, response, log);
                return;
            }
            log.setDowntimeMinutes(downtime);
        } catch (Exception e) {
            log.setDowntimeMinutes(0);
        }
        
        log.setDescription(description != null ? description.trim() : "");
        // Các trạng thái hợp lệ mới theo luồng nghiệp vụ
        String validStatus = "PENDING";
        if (status != null && (status.equals("PENDING") || status.equals("CONTACTED_VENDOR")
                || status.equals("IN_PROGRESS") || status.equals("COMPLETED"))) {
            validStatus = status;
        }
        log.setStatus(validStatus);

        // Lấy performedBy từ session nếu có
        try {
            com.itserviceflow.models.User sessionUser =
                (com.itserviceflow.models.User) request.getSession().getAttribute("user");
            log.setPerformedBy(sessionUser != null ? sessionUser.getUserId() : 6);
        } catch (Exception e) {
            log.setPerformedBy(6);
        }

        boolean success;
        if (id > 0) {
            success = maintenanceLogDAO.updateLog(log);
        } else {
            success = maintenanceLogDAO.createLog(log);
        }

        if (success) {
            response.sendRedirect(request.getContextPath() + "/maintenance-log?success=true");
        } else {
            request.setAttribute("errorMessage", "Có lỗi xảy ra khi lưu trữ dữ liệu.");
            showForm(request, response, log);
        }
    }

    private void deleteLog(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            maintenanceLogDAO.deleteLog(id);
        } catch (NumberFormatException ignored) {}
        response.sendRedirect(request.getContextPath() + "/maintenance-log");
    }
}
