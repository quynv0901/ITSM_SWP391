package com.itserviceflow.controllers;

import com.itserviceflow.daos.ConfigurationItemDAO;
import com.itserviceflow.models.ConfigurationItem;
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
        String action = request.getParameter("action");
        if (action == null) action = "list";

        switch (action) {
            case "add":
                request.getRequestDispatcher("/cmdb/form.jsp").forward(request, response);
                break;

            case "edit":
                try {
                    int editId = Integer.parseInt(request.getParameter("id"));
                    ConfigurationItem ciToEdit = ciDAO.getConfigurationItemById(editId);
                    if (ciToEdit == null) {
                        request.getSession().setAttribute("errorMessage", "Configuration Item not found.");
                        response.sendRedirect(request.getContextPath() + "/configuration-item");
                        return;
                    }
                    request.setAttribute("ci", ciToEdit);
                    request.getRequestDispatcher("/cmdb/form.jsp").forward(request, response);
                } catch (NumberFormatException e) {
                    response.sendRedirect(request.getContextPath() + "/configuration-item");
                }
                break;

            case "list":
            default:
                String keyword = request.getParameter("q");
                String status  = request.getParameter("status");
                List<ConfigurationItem> list = ciDAO.getAllConfigurationItems(keyword, status);
                request.setAttribute("ciList", list);
                request.setAttribute("q", keyword);
                request.setAttribute("status", status);
                request.getRequestDispatcher("/cmdb/list.jsp").forward(request, response);
                break;
        }
    }

    // ==================== POST ====================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) action = "add";

        switch (action) {
            case "add": {
                // --- Đọc dữ liệu ---
                String name        = trim(request.getParameter("name"));
                String type        = trim(request.getParameter("type"));
                String version     = trim(request.getParameter("version"));
                String description = trim(request.getParameter("description"));
                String status      = trim(request.getParameter("status"));

                // --- Server-side validation ---
                String error = validateCI(name, type, version, description, status);
                if (error != null) {
                    // Trả về form, giữ lại dữ liệu người dùng đã nhập
                    ConfigurationItem formData = buildCI(0, name, type, version, description, status);
                    request.setAttribute("ci",       formData);
                    request.setAttribute("errorMsg", error);
                    request.setAttribute("isNew",    true);
                    request.getRequestDispatcher("/cmdb/form.jsp").forward(request, response);
                    return;
                }

                ConfigurationItem newCi = buildCI(0, name, type, version, description, status);
                if (ciDAO.createConfigurationItem(newCi)) {
                    request.getSession().setAttribute("successMessage", "Configuration Item added successfully!");
                } else {
                    request.getSession().setAttribute("errorMessage", "Failed to add Configuration Item. Please try again.");
                }
                response.sendRedirect(request.getContextPath() + "/configuration-item");
                break;
            }

            case "edit": {
                int idToUpdate;
                try {
                    idToUpdate = Integer.parseInt(request.getParameter("id"));
                } catch (NumberFormatException e) {
                    response.sendRedirect(request.getContextPath() + "/configuration-item");
                    return;
                }

                // --- Đọc dữ liệu ---
                String name        = trim(request.getParameter("name"));
                String type        = trim(request.getParameter("type"));
                String version     = trim(request.getParameter("version"));
                String description = trim(request.getParameter("description"));
                String status      = trim(request.getParameter("status"));

                // --- Server-side validation ---
                String error = validateCI(name, type, version, description, status);
                if (error != null) {
                    ConfigurationItem formData = buildCI(idToUpdate, name, type, version, description, status);
                    request.setAttribute("ci",       formData);
                    request.setAttribute("errorMsg", error);
                    request.getRequestDispatcher("/cmdb/form.jsp").forward(request, response);
                    return;
                }

                ConfigurationItem updateCi = buildCI(idToUpdate, name, type, version, description, status);
                if (ciDAO.updateConfigurationItem(updateCi)) {
                    request.getSession().setAttribute("successMessage", "Configuration Item updated successfully!");
                } else {
                    request.getSession().setAttribute("errorMessage", "Failed to update Configuration Item. Please try again.");
                }
                response.sendRedirect(request.getContextPath() + "/configuration-item");
                break;
            }

            case "delete": {
                try {
                    int idToDelete = Integer.parseInt(request.getParameter("id"));
                    if (ciDAO.deleteConfigurationItem(idToDelete)) {
                        request.getSession().setAttribute("successMessage", "Configuration Item deleted successfully!");
                    } else {
                        request.getSession().setAttribute("errorMessage", "Failed to delete Configuration Item. It may have already been removed.");
                    }
                } catch (NumberFormatException e) {
                    request.getSession().setAttribute("errorMessage", "Invalid ID for deletion.");
                }
                response.sendRedirect(request.getContextPath() + "/configuration-item");
                break;
            }

            default:
                response.sendRedirect(request.getContextPath() + "/configuration-item");
        }
    }

    // ==================== Helpers ====================

    /** Trim và trả về null nếu chuỗi rỗng */
    private String trim(String value) {
        if (value == null) return "";
        return value.trim();
    }

    /** Tạo một ConfigurationItem từ các tham số */
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

    /**
     * Kiểm tra dữ liệu server-side.
     * @return thông báo lỗi nếu có, null nếu hợp lệ.
     */
    private String validateCI(String name, String type, String version,
                               String description, String status) {
        // --- Name ---
        if (name == null || name.isEmpty()) {
            return "Name is required and cannot be blank.";
        }
        if (name.length() > 100) {
            return "Name must not exceed 100 characters (current: " + name.length() + ").";
        }
        if (!name.matches("^[\\p{L}0-9 .\\-_()/#]+$")) {
            return "Name contains invalid characters. Only letters, numbers and basic symbols (. - _ ( ) / #) are allowed.";
        }

        // --- Type ---
        if (type == null || type.isEmpty()) {
            return "Type is required. Please select a valid type.";
        }
        if (!VALID_TYPES.contains(type)) {
            return "Invalid Type value: '" + type + "'.";
        }

        // --- Version (optional) ---
        if (version != null && version.length() > 50) {
            return "Version must not exceed 50 characters (current: " + version.length() + ").";
        }

        // --- Description (optional) ---
        if (description != null && description.length() > 2000) {
            return "Description must not exceed 2000 characters (current: " + description.length() + ").";
        }

        // --- Status ---
        if (status == null || status.isEmpty()) {
            return "Status is required.";
        }
        if (!VALID_STATUSES.contains(status)) {
            return "Invalid Status value: '" + status + "'.";
        }

        return null; // OK
    }
}
