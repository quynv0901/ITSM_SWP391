package com.itserviceflow.controllers;

import com.google.gson.Gson;
import com.itserviceflow.daos.DepartmentDAO;
import com.itserviceflow.daos.RoleDAO;
import com.itserviceflow.daos.UserDAO;
import com.itserviceflow.models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "UserManagementController", urlPatterns = {"/admin/users"})
public class UserManagementController extends HttpServlet {

    private UserDAO userDAO = new UserDAO();
    private Gson gson = com.itserviceflow.utils.GsonConfig.getGson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        action = (action == null) ? "list" : action;

        switch (action) {
            case "list":
                listUsers(req, resp);
                break;
            case "searchJson":
                searchUsersJson(req, resp);
                break;
            case "getInfo":
                getUserInfo(req, resp);
                break;
            case "toggle":
                toggleStatus(req, resp);
                break;
            case "delete":
                deleteUser(req, resp);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/admin/users");
        }
    }

    private void searchUsersJson(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String q = req.getParameter("q");
        String roleIdStr = req.getParameter("roleId");
        String roleName = req.getParameter("roleName");
        Integer roleId = parseIntOrNull(roleIdStr);

        // reuse listUsers with a reasonable limit and no pagination
        List<com.itserviceflow.models.User> users = userDAO.listUsers(q, roleId, null, "full_name", "ASC", 0, 50);
        // if caller provided roleName (client-side), apply simple post-filter by role name
        if (roleName != null && !roleName.isEmpty()) {
            String rn = roleName.trim().toLowerCase();
            users.removeIf(u -> u.getRoleName() == null || !u.getRoleName().toLowerCase().contains(rn));
        }
        resp.setContentType("application/json");
        resp.getWriter().write(gson.toJson(users));
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        action = (action == null) ? "list" : action;

        switch (action) {
            case "add":
                addUser(req, resp);
                break;
            case "update":
                updateUser(req, resp);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/admin/users");
        }
    }

    // ===================== GET HANDLERS =====================
    private void listUsers(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String search = req.getParameter("search");
        String roleIdStr = req.getParameter("roleId");
        String deptIdStr = req.getParameter("deptId");
        String sortBy = req.getParameter("sortBy");
        String order = req.getParameter("order");
        String pageStr = req.getParameter("page");

        Integer roleId = parseIntOrNull(roleIdStr);
        Integer deptId = parseIntOrNull(deptIdStr);
        int page = (pageStr != null && !pageStr.isEmpty()) ? Integer.parseInt(pageStr) : 1;
        int limit = 10;
        int offset = (page - 1) * limit;

        List<User> userList = userDAO.listUsers(search, roleId, deptId, sortBy, order, offset, limit);
        int totalUsers = userDAO.countUsers(search, roleId, deptId);
        int totalPages = (int) Math.ceil((double) totalUsers / limit);

        req.setAttribute("userList", userList);
        req.setAttribute("roles", new RoleDAO().listAll());
        req.setAttribute("departments", new DepartmentDAO().listAll());
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("search", search);
        req.setAttribute("roleId", roleId);
        req.setAttribute("deptId", deptId);
        req.setAttribute("sortBy", sortBy);
        req.setAttribute("order", order);

        req.getRequestDispatcher("/admin/user-list.jsp").forward(req, resp);
    }

    private void getUserInfo(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }
        User u = userDAO.findById(Integer.parseInt(idStr));
        resp.setContentType("application/json");
        resp.getWriter().write(gson.toJson(u));
    }

    private void toggleStatus(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        // Không cho toggle chính mình
        HttpSession session = req.getSession(false);
        User currentUser = (User) session.getAttribute("user");
        if (currentUser != null && currentUser.getUserId() == Integer.parseInt(idStr)) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?error=Cannot change your own status");
            return;
        }

        boolean newStatus = "true".equals(req.getParameter("status"));
        userDAO.toggleStatus(Integer.parseInt(idStr), newStatus);
        resp.sendRedirect(req.getContextPath() + "/admin/users?message=Status updated");
    }

    private void deleteUser(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        // Không cho xóa chính mình
        HttpSession session = req.getSession(false);
        User currentUser = (User) session.getAttribute("user");
        if (currentUser != null && currentUser.getUserId() == Integer.parseInt(idStr)) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?error=Cannot delete your own account");
            return;
        }

        userDAO.deleteUser(Integer.parseInt(idStr));
        resp.sendRedirect(req.getContextPath() + "/admin/users?message=User deleted");
    }

    private void addUser(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String roleIdStr = req.getParameter("roleId");
        String deptIdStr = req.getParameter("deptId");

        User u = new User();
        u.setFullName(fullName);
        u.setEmail(email);
        u.setUsername(username);
        u.setPasswordHash(password); // TODO: hash password
        u.setRoleId(Integer.parseInt(roleIdStr));
        u.setDepartmentId(parseIntOrNull(deptIdStr));
        u.setIsActive(true);

        if (userDAO.addUser(u)) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?message=User added successfully");
        } else {
            req.setAttribute("error", "Could not add user");
            listUsers(req, resp);
        }
    }

    private void updateUser(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String userIdStr = req.getParameter("userId");
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String roleIdStr = req.getParameter("roleId");
        String deptIdStr = req.getParameter("deptId");

        if (userIdStr == null || userIdStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        User u = userDAO.findById(Integer.parseInt(userIdStr));
        if (u != null) {
            u.setFullName(fullName);
            u.setEmail(email);
            u.setRoleId(Integer.parseInt(roleIdStr));
            u.setDepartmentId(parseIntOrNull(deptIdStr));

            if (userDAO.updateUserByAdmin(u)) {
                resp.sendRedirect(req.getContextPath() + "/admin/users?message=User updated successfully");
            } else {
                req.setAttribute("error", "Update failed");
                listUsers(req, resp);
            }
        } else {
            req.setAttribute("error", "User not found");
            listUsers(req, resp);
        }
    }

    // ===================== HELPER =====================
    private Integer parseIntOrNull(String value) {
        return (value != null && !value.isEmpty()) ? Integer.parseInt(value) : null;
    }

    @Override
    public String getServletInfo() {
        return "UserManagementController - Handles all admin user operations";
    }
}
