package com.itserviceflow.controllers;

import com.itserviceflow.daos.ConfigurationItemDAO;
import com.itserviceflow.models.ConfigurationItem;
import com.itserviceflow.utils.AuthUtils;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "ConfigurationItemController", urlPatterns = {"/configuration-item"})
public class ConfigurationItemController extends HttpServlet {

    private final ConfigurationItemDAO ciDAO = new ConfigurationItemDAO();

    private static final Set<String> VALID_TYPES = new HashSet<>(
            Arrays.asList("Hardware", "Software", "Network", "Service", "Other"));
    private static final Set<String> VALID_STATUSES = new HashSet<>(
            Arrays.asList("ACTIVE", "INACTIVE", "RETIRED"));

    // ==================== GET ====================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Must be logged in
        if (!AuthUtils.isLoggedIn(request, response)) return;

        String action = request.getParameter("action");
        if (action == null) action = "list";

        switch (action) {
            case "list":
                if (!AuthUtils.hasRole(request, response,
                        AuthUtils.ROLE_SUPPORT_AGENT,
                        AuthUtils.ROLE_TECHNICAL_EXPERT,
                        AuthUtils.ROLE_MANAGER,
                        AuthUtils.ROLE_ASSET_MANAGER,
                        AuthUtils.ROLE_IT_DIRECTOR)) {
                    return;
                }
                String keyword = request.getParameter("q");
                String status  = request.getParameter("status");

                // ── Pagination ──────────────────────────────────
                final int PAGE_SIZE = 10;
                int currentPage = 1;
                try {
                    String pageParam = request.getParameter("page");
                    if (pageParam != null && !pageParam.isEmpty()) {
                        currentPage = Integer.parseInt(pageParam);
                        if (currentPage < 1) currentPage = 1;
                    }
                } catch (NumberFormatException ignored) {}

                int totalItems = ciDAO.countConfigurationItems(keyword, status);
                int totalPages = (int) Math.ceil((double) totalItems / PAGE_SIZE);
                if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;

                List<ConfigurationItem> list = ciDAO.getConfigurationItemsPaged(
                        keyword, status, currentPage, PAGE_SIZE);

                request.setAttribute("ciList",      list);
                request.setAttribute("q",            keyword);
                request.setAttribute("status",       status);
                request.setAttribute("currentPage",  currentPage);
                request.setAttribute("totalPages",   totalPages);
                request.setAttribute("totalItems",   totalItems);
                request.getRequestDispatcher("/cmdb/list.jsp").forward(request, response);
                break;

            case "add":
                // Only Asset Manager(8) and Admin(10) can create
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_ASSET_MANAGER)) {
                    return;
                }
                request.getRequestDispatcher("/cmdb/form.jsp").forward(request, response);
                break;

            case "edit":
                // Only Asset Manager(8) and Admin(10) can edit
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_ASSET_MANAGER)) {
                    return;
                }
                try {
                    int editId = Integer.parseInt(request.getParameter("id"));
                    ConfigurationItem ciToEdit = ciDAO.getConfigurationItemById(editId);
                    if (ciToEdit == null) {
                        request.getSession().setAttribute("errorMessage", "Không tìm thấy mục cấu hình.");
                        response.sendRedirect(request.getContextPath() + "/configuration-item");
                        return;
                    }
                    request.setAttribute("ci", ciToEdit);
                    request.getRequestDispatcher("/cmdb/form.jsp").forward(request, response);
                } catch (NumberFormatException e) {
                    response.sendRedirect(request.getContextPath() + "/configuration-item");
                }
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/configuration-item");
        }
    }

    // ==================== POST ====================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // Must be logged in
        if (!AuthUtils.isLoggedIn(request, response)) return;

        String action = request.getParameter("action");
        if (action == null) action = "add";

        switch (action) {
            case "add": {
                // Only Asset Manager(8) and Admin(10)
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_ASSET_MANAGER)) return;

                String name        = trim(request.getParameter("name"));
                String type        = trim(request.getParameter("type"));
                String version     = trim(request.getParameter("version"));
                String description = trim(request.getParameter("description"));
                String status      = trim(request.getParameter("status"));

                String error = validateCI(name, type, version, description, status);
                if (error != null) {
                    ConfigurationItem formData = buildCI(0, name, type, version, description, status);
                    request.setAttribute("ci", formData);
                    request.setAttribute("errorMsg", error);
                    request.setAttribute("isNew", true);
                    request.getRequestDispatcher("/cmdb/form.jsp").forward(request, response);
                    return;
                }

                // ── Kiểm tra trùng tên ─────────────────────────────────────
                if (ciDAO.isDuplicateName(name, 0)) {
                    ConfigurationItem formData = buildCI(0, name, type, version, description, status);
                    request.setAttribute("ci", formData);
                    request.setAttribute("isNew", true);
                    request.setAttribute("errorMsg",
                            "⚠️ Tên “" + name + "” đã tồn tại trong CMDB. " +
                            "Mỗi mục cấu hình phải có tên duy nhất.");
                    request.getRequestDispatcher("/cmdb/form.jsp").forward(request, response);
                    return;
                }

                if (ciDAO.createConfigurationItem(buildCI(0, name, type, version, description, status))) {
                    request.getSession().setAttribute("successMessage", "✅ Thêm mục cấu hình thành công!");
                } else {
                    request.getSession().setAttribute("errorMessage", "❌ Thêm mục cấu hình thất bại. Vui lòng thử lại.");
                }
                response.sendRedirect(request.getContextPath() + "/configuration-item");
                break;
            }

            case "edit": {
                // Only Asset Manager(8) and Admin(10)
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_ASSET_MANAGER)) return;

                int idToUpdate;
                try {
                    idToUpdate = Integer.parseInt(request.getParameter("id"));
                } catch (NumberFormatException e) {
                    response.sendRedirect(request.getContextPath() + "/configuration-item");
                    return;
                }

                String name        = trim(request.getParameter("name"));
                String type        = trim(request.getParameter("type"));
                String version     = trim(request.getParameter("version"));
                String description = trim(request.getParameter("description"));
                String status      = trim(request.getParameter("status"));

                String error = validateCI(name, type, version, description, status);
                if (error != null) {
                    ConfigurationItem formData = buildCI(idToUpdate, name, type, version, description, status);
                    request.setAttribute("ci", formData);
                    request.setAttribute("errorMsg", error);
                    request.getRequestDispatcher("/cmdb/form.jsp").forward(request, response);
                    return;
                }

                // ── Kiểm tra trùng tên (loại trừ item đang sửa) ──────────────────────
                if (ciDAO.isDuplicateName(name, idToUpdate)) {
                    ConfigurationItem formData = buildCI(idToUpdate, name, type, version, description, status);
                    request.setAttribute("ci", formData);
                    request.setAttribute("errorMsg",
                            "⚠️ Tên “" + name + "” đã được dùng bởi mục cấu hình khác. " +
                            "Vui lòng đặt tên khác.");
                    request.getRequestDispatcher("/cmdb/form.jsp").forward(request, response);
                    return;
                }

                if (ciDAO.updateConfigurationItem(buildCI(idToUpdate, name, type, version, description, status))) {
                    request.getSession().setAttribute("successMessage", "✅ Cập nhật mục cấu hình thành công!");
                } else {
                    request.getSession().setAttribute("errorMessage", "❌ Cập nhật mục cấu hình thất bại. Vui lòng thử lại.");
                }
                response.sendRedirect(request.getContextPath() + "/configuration-item");
                break;
            }

            case "delete": {
                // Only Asset Manager(8) and Admin(10)
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_ASSET_MANAGER)) return;

                try {
                    int idToDelete = Integer.parseInt(request.getParameter("id"));
                    if (ciDAO.deleteConfigurationItem(idToDelete)) {
                        request.getSession().setAttribute("successMessage", "Xóa mục cấu hình thành công!");
                    } else {
                        request.getSession().setAttribute("errorMessage", "Xóa mục cấu hình thất bại.");
                    }
                } catch (NumberFormatException e) {
                    request.getSession().setAttribute("errorMessage", "ID không hợp lệ.");
                }
                response.sendRedirect(request.getContextPath() + "/configuration-item");
                break;
            }

            default:
                response.sendRedirect(request.getContextPath() + "/configuration-item");
        }
    }

    // ==================== Helpers ====================

    private String trim(String value) {
        if (value == null) return "";
        return value.trim();
    }

    private ConfigurationItem buildCI(int id, String name, String type,
                                      String version, String description, String status) {
        ConfigurationItem ci = new ConfigurationItem();
        ci.setCiId(id);
        ci.setName(name);
        ci.setType(type);
        ci.setVersion(version.isEmpty() ? null : version);
        ci.setDescription(description.isEmpty() ? null : description);
        ci.setStatus(status.isEmpty() ? "ACTIVE" : status);
        return ci;
    }

    private String validateCI(String name, String type, String version,
                               String description, String status) {
        if (name == null || name.isEmpty())
            return "Tên là bắt buộc và không được để trống.";
        if (name.length() > 100)
            return "Tên không được vượt quá 100 ký tự (hiện tại: " + name.length() + ").";
        if (!name.matches("^[\\p{L}0-9 .\\-_()/#]+$"))
            return "Tên chứa ký tự không hợp lệ. Chỉ chấp nhận chữ cái, số và ký tự cơ bản (. - _ ( ) / #).";
        if (type == null || type.isEmpty())
            return "Loại là bắt buộc. Vui lòng chọn loại hợp lệ.";
        if (!VALID_TYPES.contains(type))
            return "Giá trị loại không hợp lệ: '" + type + "'.";
        if (version != null && version.length() > 50)
            return "Phiên bản không được vượt quá 50 ký tự (hiện tại: " + version.length() + ").";
        if (description != null && description.length() > 2000)
            return "Mô tả không được vượt quá 2000 ký tự (hiện tại: " + description.length() + ").";
        if (status == null || status.isEmpty())
            return "Trạng thái là bắt buộc.";
        if (!VALID_STATUSES.contains(status))
            return "Giá trị trạng thái không hợp lệ: '" + status + "'.";
        return null;
    }
}
