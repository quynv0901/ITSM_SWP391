package com.itserviceflow.controllers;

import com.itserviceflow.daos.DepartmentDAO;
import com.itserviceflow.daos.UserDAO;
import com.itserviceflow.models.Department;
import com.itserviceflow.models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "DepartmentManagementController", urlPatterns = {"/admin/departments"})
public class DepartmentManagementController extends HttpServlet {

    private final DepartmentDAO departmentDAO = new DepartmentDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        action = (action == null || action.isEmpty()) ? "list" : action;

        switch (action) {
            case "create":
                showForm(req, resp, null, false);
                break;
            case "edit":
                showEditForm(req, resp);
                break;
            case "detail":
                showDetail(req, resp);
                break;
            default:
                listDepartments(req, resp);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        action = (action == null || action.isEmpty()) ? "" : action;

        switch (action) {
            case "create":
                createDepartment(req, resp);
                break;
            case "update":
                updateDepartment(req, resp);
                break;
            case "toggleStatus":
                toggleStatus(req, resp);
                break;
            case "delete":
                deleteDepartment(req, resp);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/admin/departments");
                break;
        }
    }

    private void listDepartments(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String keyword = req.getParameter("q");
        String managerFilter = req.getParameter("managerFilter");
        String statusFilter = req.getParameter("status");
        int page = parsePositiveInt(req.getParameter("page"), 1);
        int pageSize = parsePositiveInt(req.getParameter("pageSize"), 5);
        int offset = (page - 1) * pageSize;

        List<Department> departments = departmentDAO.listDepartments(keyword, managerFilter, statusFilter, offset, pageSize);
        int total = departmentDAO.countDepartments(keyword, managerFilter, statusFilter);
        int totalPages = (int) Math.ceil((double) total / pageSize);
        if (totalPages < 1) {
            totalPages = 1;
        }
        if (page > totalPages) {
            page = totalPages;
            offset = (page - 1) * pageSize;
            departments = departmentDAO.listDepartments(keyword, managerFilter, statusFilter, offset, pageSize);
        }

        int fromIdx = total == 0 ? 0 : offset + 1;
        int toIdx = Math.min(offset + departments.size(), total);
        int totalActive = departmentDAO.countDepartments(null, null, "ACTIVE");
        int totalInactive = departmentDAO.countDepartments(null, null, "INACTIVE");
        req.setAttribute("departments", departments);
        req.setAttribute("keyword", keyword);
        req.setAttribute("managerFilter", managerFilter);
        req.setAttribute("statusFilter", statusFilter);
        req.setAttribute("currentPage", page);
        req.setAttribute("pageSize", pageSize);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("total", total);
        req.setAttribute("fromIdx", fromIdx);
        req.setAttribute("toIdx", toIdx);
        req.setAttribute("totalActive", totalActive);
        req.setAttribute("totalInactive", totalInactive);
        req.getRequestDispatcher("/admin/department-list.jsp").forward(req, resp);
    }

    private void showEditForm(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer id = parseIntOrNull(req.getParameter("id"));
        if (id == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/departments");
            return;
        }

        Department department = departmentDAO.findById(id);
        if (department == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/departments?error=not_found");
            return;
        }
        showForm(req, resp, department, true);
    }

    private void showForm(HttpServletRequest req, HttpServletResponse resp, Department department, boolean editMode)
            throws ServletException, IOException {
        req.setAttribute("editMode", editMode);
        req.setAttribute("department", department);
        req.setAttribute("allDepartments", departmentDAO.listAll());
        req.setAttribute("managers", userDAO.listUsers(null, null, null, "full_name", "ASC", 0, 300));
        req.getRequestDispatcher("/admin/department-form.jsp").forward(req, resp);
    }

    private void showDetail(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer id = parseIntOrNull(req.getParameter("id"));
        if (id == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/departments");
            return;
        }

        Department department = departmentDAO.findById(id);
        if (department == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/departments?error=not_found");
            return;
        }

        List<User> users = departmentDAO.listUsersByDepartment(id);
        req.setAttribute("department", department);
        req.setAttribute("users", users);
        req.getRequestDispatcher("/admin/department-detail.jsp").forward(req, resp);
    }

    private void createDepartment(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Department department = buildDepartmentFromRequest(req, null);
        if (department == null) {
            showForm(req, resp, null, false);
            return;
        }

        if (departmentDAO.createDepartment(department)) {
            resp.sendRedirect(req.getContextPath() + "/admin/departments?message=created");
        } else {
            req.setAttribute("error", "Không thể tạo phòng ban. Vui lòng kiểm tra mã phòng ban có thể đã tồn tại.");
            req.setAttribute("department", department);
            showForm(req, resp, department, false);
        }
    }

    private void updateDepartment(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer id = parseIntOrNull(req.getParameter("departmentId"));
        if (id == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/departments");
            return;
        }

        Department department = buildDepartmentFromRequest(req, id);
        if (department == null) {
            Department existing = departmentDAO.findById(id);
            req.setAttribute("department", existing);
            req.setAttribute("editMode", true);
            showForm(req, resp, existing, true);
            return;
        }

        if (departmentDAO.updateDepartment(department)) {
            resp.sendRedirect(req.getContextPath() + "/admin/departments?message=updated");
        } else {
            req.setAttribute("error", "Không thể cập nhật phòng ban. Vui lòng kiểm tra lại dữ liệu.");
            req.setAttribute("department", department);
            showForm(req, resp, department, true);
        }
    }

    private Department buildDepartmentFromRequest(HttpServletRequest req, Integer departmentId) {
        String departmentName = req.getParameter("departmentName");
        String departmentCode = req.getParameter("departmentCode");
        Integer managerId = parseIntOrNull(req.getParameter("managerId"));
        Integer parentDepartmentId = parseIntOrNull(req.getParameter("parentDepartmentId"));
        String status = req.getParameter("status");

        if (departmentName == null || departmentName.trim().isEmpty()) {
            req.setAttribute("error", "Tên phòng ban không được để trống.");
            return null;
        }
        if (departmentCode == null || departmentCode.trim().isEmpty()) {
            req.setAttribute("error", "Mã phòng ban không được để trống.");
            return null;
        }
        Department department = new Department();
        if (departmentId != null) {
            department.setDepartmentId(departmentId);
        }
        department.setDepartmentName(departmentName.trim());
        department.setDepartmentCode(departmentCode.trim());
        department.setManagerId(managerId);
        department.setParentDepartmentId(parentDepartmentId);
        department.setStatus((status == null || status.trim().isEmpty()) ? "ACTIVE" : status.trim());
        return department;
    }

    private void toggleStatus(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Integer id = parseIntOrNull(req.getParameter("id"));
        String status = req.getParameter("status");
        if (id == null || status == null || (!"ACTIVE".equals(status) && !"INACTIVE".equals(status))) {
            resp.sendRedirect(req.getContextPath() + "/admin/departments?error=invalid_status");
            return;
        }

        if (departmentDAO.updateStatus(id, status)) {
            resp.sendRedirect(req.getContextPath() + "/admin/departments?message=status_updated");
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/departments?error=status_failed");
        }
    }

    private void deleteDepartment(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Integer id = parseIntOrNull(req.getParameter("id"));
        if (id == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/departments?error=invalid_id");
            return;
        }

        if (departmentDAO.deleteDepartment(id)) {
            resp.sendRedirect(req.getContextPath() + "/admin/departments?message=deleted");
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/departments?error=delete_failed");
        }
    }

    private Integer parseIntOrNull(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.valueOf(value);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private int parsePositiveInt(String value, int defaultValue) {
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            int parsed = Integer.parseInt(value.trim());
            return parsed > 0 ? parsed : defaultValue;
        } catch (Exception e) {
            return defaultValue;
        }
    }
}
