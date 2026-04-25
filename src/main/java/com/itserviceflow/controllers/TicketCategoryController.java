package com.itserviceflow.controllers;

import com.itserviceflow.daos.TicketCategoryDAO;
import com.itserviceflow.models.TicketCategory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet(name = "TicketCategoryController", urlPatterns = {"/ticket-category", "/ticket-category/"})
public class TicketCategoryController extends HttpServlet {

    private final TicketCategoryDAO dao = new TicketCategoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "detail" ->
                showDetail(req, resp);
            case "form" ->
                showForm(req, resp);
            case "api" ->
                sendCategoriesApi(req, resp);
            default ->
                showList(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if (action == null) {
            action = "";
        }

        switch (action) {
            case "create" ->
                handleCreate(req, resp);
            case "update" ->
                handleUpdate(req, resp);
            case "delete" ->
                handleDelete(req, resp);
            case "toggle" ->
                handleToggle(req, resp);
            case "bulkDelete" ->
                handleBulkDelete(req, resp);
            case "bulkToggle" ->
                handleBulkToggle(req, resp);
            default ->
                resp.sendRedirect(req.getContextPath() + "/ticket-category");
        }
    }

    private void showList(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String search = req.getParameter("search");
        String categoryType = req.getParameter("categoryType");
        String status = req.getParameter("status"); // active, inactive, or empty (all)

        Boolean activeOnly = null;
        if ("active".equalsIgnoreCase(status)) {
            activeOnly = true;
        } else if ("inactive".equalsIgnoreCase(status)) {
            activeOnly = false;
        }

        int page = 1;
        try {
            String pStr = req.getParameter("page");
            if (pStr != null && !pStr.isBlank()) {
                page = Integer.parseInt(pStr);
            }
        } catch (NumberFormatException ignored) {
        }

        int limit = 15;
        try {
            String psStr = req.getParameter("pageSize");
            if (psStr != null && !psStr.isBlank()) {
                limit = Math.max(1, Integer.parseInt(psStr));
            }
        } catch (NumberFormatException ignored) {
        }

        int offset = (page - 1) * limit;

        List<TicketCategory> categories = dao.query(search, categoryType, activeOnly, offset, limit);
        int total = dao.count(search, categoryType, activeOnly);
        int totalPages = (int) Math.ceil((double) total / limit);
        if (totalPages < 1) {
            totalPages = 1;
        }
        if (page > totalPages) {
            page = totalPages;
            offset = (page - 1) * limit;
            categories = dao.query(search, categoryType, activeOnly, offset, limit);
        }

        int fromIdx = offset + 1;
        int toIdx = Math.min(offset + categories.size(), total);

        // Stats for cards
        int totalAll = dao.count(null, null, null);
        int totalActive = dao.count(null, null, true);
        int totalInact = dao.count(null, null, false);

        req.setAttribute("categories", categories);
        req.setAttribute("totalAll", totalAll);
        req.setAttribute("totalActive", totalActive);
        req.setAttribute("totalInact", totalInact);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("total", total);
        req.setAttribute("pageSize", limit);
        req.setAttribute("fromIdx", fromIdx);
        req.setAttribute("toIdx", toIdx);

        req.setAttribute("fSearch", search);
        req.setAttribute("fType", categoryType);
        req.setAttribute("fStatus", status);

        req.getRequestDispatcher("/ticket-category/category-list.jsp").forward(req, resp);
    }

    private void showDetail(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int id = parseId(req.getParameter("id"));
        TicketCategory cat = dao.findById(id);
        if (cat == null) {
            resp.sendRedirect(req.getContextPath() + "/ticket-category?error=not_found");
            return;
        }
        req.setAttribute("cat", cat);
        req.setAttribute("children", dao.getChildren(id));
        req.getRequestDispatcher("/ticket-category/category-detail.jsp").forward(req, resp);
    }

    private void showForm(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int id = parseId(req.getParameter("id"));
        TicketCategory cat;
        boolean isEdit = id > 0;

        if (isEdit) {
            cat = dao.findById(id);
            if (cat == null) {
                resp.sendRedirect(req.getContextPath() + "/ticket-category?error=not_found");
                return;
            }
        } else {
            cat = new TicketCategory();
            cat.setActive(true);
            // Pre-fill parent if provided
            int parentId = parseId(req.getParameter("parentId"));
            if (parentId > 0) {
                cat.setParentCategoryId(parentId);
            }
        }

        req.setAttribute("cat", cat);
        req.setAttribute("isEdit", isEdit);
        req.setAttribute("allCats", dao.getAllCategories());
        req.getRequestDispatcher("/ticket-category/category-form.jsp").forward(req, resp);
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        TicketCategory cat = buildFromRequest(req);

        // ── Server-side validation ────────────────────────────────────────
        String validationError = validateCategory(cat);
        if (validationError != null) {
            req.setAttribute("cat", cat);
            req.setAttribute("isEdit", false);
            req.setAttribute("allCats", dao.getAllCategories());
            req.setAttribute("error", validationError);
            try {
                req.getRequestDispatcher("/ticket-category/category-form.jsp").forward(req, resp);
            } catch (ServletException e) {
                resp.sendRedirect(req.getContextPath() + "/ticket-category?action=form&error=validation_failed");
            }
            return;
        }

        // Duplicate code check
        TicketCategory exists = dao.findByCode(cat.getCategoryCode());
        if (exists != null) {
            req.setAttribute("cat", cat);
            req.setAttribute("isEdit", false);
            req.setAttribute("allCats", dao.getAllCategories());
            req.setAttribute("error", "Category Code '" + cat.getCategoryCode() + "' đã được sử dụng. Vui lòng chọn mã khác.");
            try {
                req.getRequestDispatcher("/ticket-category/category-form.jsp").forward(req, resp);
            } catch (ServletException e) {
                resp.sendRedirect(req.getContextPath() + "/ticket-category?action=form&error=create_failed");
            }
            return;
        }

        int id = dao.insert(cat);
        if (id > 0) {
            resp.sendRedirect(req.getContextPath() + "/ticket-category?createSuccess=1");
        } else {
            resp.sendRedirect(req.getContextPath() + "/ticket-category?action=form&error=create_failed");
        }
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        TicketCategory cat = buildFromRequest(req);
        cat.setCategoryId(parseId(req.getParameter("id")));

        // ── Server-side validation ────────────────────────────────────────
        String validationError = validateCategory(cat);
        if (validationError != null) {
            req.setAttribute("cat", cat);
            req.setAttribute("isEdit", true);
            req.setAttribute("allCats", dao.getAllCategories());
            req.setAttribute("error", validationError);
            try {
                req.getRequestDispatcher("/ticket-category/category-form.jsp").forward(req, resp);
            } catch (ServletException e) {
                resp.sendRedirect(req.getContextPath() + "/ticket-category?action=form&id=" + cat.getCategoryId() + "&error=validation_failed");
            }
            return;
        }

        // Duplicate code check: allow same code for the same record
        TicketCategory exists = dao.findByCode(cat.getCategoryCode());
        if (exists != null && exists.getCategoryId() != cat.getCategoryId()) {
            req.setAttribute("cat", cat);
            req.setAttribute("isEdit", true);
            req.setAttribute("allCats", dao.getAllCategories());
            req.setAttribute("error", "Category Code '" + cat.getCategoryCode() + "' đã được sử dụng. Vui lòng chọn mã khác.");
            try {
                req.getRequestDispatcher("/ticket-category/category-form.jsp").forward(req, resp);
            } catch (ServletException e) {
                resp.sendRedirect(req.getContextPath() + "/ticket-category?action=form&id=" + cat.getCategoryId() + "&error=update_failed");
            }
            return;
        }

        if (dao.update(cat)) {
            resp.sendRedirect(req.getContextPath() + "/ticket-category?updateSuccess=1");
        } else {
            resp.sendRedirect(req.getContextPath() + "/ticket-category?action=form&id=" + cat.getCategoryId() + "&error=update_failed");
        }
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int id = parseId(req.getParameter("id"));
        String result = dao.safeDelete(id);
        if ("ok".equals(result)) {
            resp.sendRedirect(req.getContextPath() + "/ticket-category?deleteSuccess=1");
        } else {
            resp.sendRedirect(req.getContextPath() + "/ticket-category?error=" + result);
        }
    }

    private void handleToggle(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int id = parseId(req.getParameter("id"));
        boolean active = Boolean.parseBoolean(req.getParameter("active"));
        if (dao.toggleActive(id, active)) {
            resp.sendRedirect(req.getContextPath() + "/ticket-category?toggleSuccess=1");
        } else {
            resp.sendRedirect(req.getContextPath() + "/ticket-category?error=toggle_failed");
        }
    }

    private void handleBulkDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        List<Integer> ids = parseIds(req.getParameterValues("ids"));
        int deleted = dao.bulkSafeDelete(ids);
        resp.sendRedirect(req.getContextPath() + "/ticket-category?bulkDeleteSuccess=" + deleted);
    }

    private void handleBulkToggle(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        List<Integer> ids = parseIds(req.getParameterValues("ids"));
        boolean active = Boolean.parseBoolean(req.getParameter("active"));
        int updated = dao.bulkToggle(ids, active);
        resp.sendRedirect(req.getContextPath() + "/ticket-category?bulkToggleSuccess=" + updated);
    }

    /**
     * Validates required fields and max-length constraints.
     * Returns an error message string if invalid, or null if valid.
     */
    private String validateCategory(TicketCategory cat) {
        // Category Name – required, max 120
        String name = cat.getCategoryName();
        if (name == null || name.isBlank()) {
            return "Tên danh mục (Category Name) không được để trống.";
        }
        if (name.trim().length() > 120) {
            return "Tên danh mục không được vượt quá 120 ký tự (hiện tại: " + name.trim().length() + " ký tự).";
        }

        // Category Code – required, max 30
        String code = cat.getCategoryCode();
        if (code == null || code.isBlank()) {
            return "Category Code không được để trống.";
        }
        if (code.trim().length() > 30) {
            return "Category Code không được vượt quá 30 ký tự (hiện tại: " + code.trim().length() + " ký tự).";
        }

        // Category Type – required
        String type = cat.getCategoryType();
        if (type == null || type.isBlank()) {
            return "Vui lòng chọn Category Type.";
        }

        // Difficulty Level – required
        String diff = cat.getDifficultyLevel();
        if (diff == null || diff.isBlank()) {
            return "Vui lòng chọn mức Độ khó.";
        }

        // Description – optional, max 500
        String desc = cat.getDescription();
        if (desc != null && desc.length() > 500) {
            return "Mô tả không được vượt quá 500 ký tự (hiện tại: " + desc.length() + " ký tự).";
        }

        return null; // all valid
    }

    private TicketCategory buildFromRequest(HttpServletRequest req) {
        TicketCategory cat = new TicketCategory();
        cat.setCategoryName(trim(req.getParameter("categoryName")));
        cat.setCategoryCode(trim(req.getParameter("categoryCode")));
        cat.setCategoryType(trim(req.getParameter("categoryType")));
        cat.setDescription(req.getParameter("description"));
        cat.setParentCategoryId(parseId(req.getParameter("parentCategoryId")));
        cat.setDifficultyLevel(trim(req.getParameter("difficultyLevel")));
        cat.setActive(Boolean.parseBoolean(req.getParameter("isActive")));
        return cat;
    }

    /** Null-safe trim helper */
    private String trim(String val) {
        return val == null ? null : val.trim();
    }

    private int parseId(String val) {
        if (val == null || val.isBlank()) {
            return 0;
        }
        try {
            return Integer.parseInt(val.trim());
        } catch (Exception e) {
            return 0;
        }
    }

    private List<Integer> parseIds(String[] vals) {
        if (vals == null) {
            return List.of();
        }
        return Arrays.stream(vals)
                .map(this::parseId)
                .filter(id -> id > 0)
                .collect(Collectors.toList());
    }

    /**
     * GET /ticket-category?action=api
     * Returns all categories (active + inactive) as JSON for frontend consumption.
     * Format: [{"id":1,"name":"Network","type":"INCIDENT","status":"active"},
     *          {"id":2,"name":"Access","type":"SERVICE_REQUEST","status":"inactive"}]
     */
    private void sendCategoriesApi(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        resp.setHeader("Cache-Control", "max-age=300"); // cache 5 min
        
        // Get all categories (both active and inactive)
        List<TicketCategory> allCategories = dao.getAllCategories();
        
        // Build simple JSON array manually to avoid dependency on Gson
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < allCategories.size(); i++) {
            TicketCategory cat = allCategories.get(i);
            json.append("{");
            json.append("\"id\":").append(cat.getCategoryId()).append(",");
            json.append("\"name\":\"").append(escapeJson(cat.getCategoryName())).append("\",");
            json.append("\"type\":\"").append(escapeJson(cat.getCategoryType())).append("\",");
            json.append("\"status\":\"").append(cat.isActive() ? "active" : "inactive").append("\"");
            json.append("}");
            if (i < allCategories.size() - 1) {
                json.append(",");
            }
        }
        json.append("]");
        
        resp.getWriter().print(json.toString());
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
