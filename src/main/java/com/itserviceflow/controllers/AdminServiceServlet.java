package com.itserviceflow.controllers;

import com.itserviceflow.daos.ServiceDAO;
import com.itserviceflow.models.Service;
import com.itserviceflow.models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "AdminServiceServlet", urlPatterns = {"/admin-services"})
public class AdminServiceServlet extends HttpServlet {

    private static final int ROLE_END_USER = 1;
    private static final int ROLE_ADMIN = 10;
    private static final int PAGE_SIZE = 8;
    private ServiceDAO serviceDAO;

    @Override
    public void init() {
        serviceDAO = new ServiceDAO();
    }

    // ================= GET =================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User loginUser = getLoggedInUser(request);

        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (loginUser.getRoleId() != ROLE_ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        // 👉 LOAD LIST TRƯỚC
        loadListData(request);

        // 👉 XỬ LÝ POPUP
        if ("detail".equals(action) || "edit".equals(action)) {

            int id = Integer.parseInt(request.getParameter("id"));
            Service svc = serviceDAO.getServiceById(id);

            request.setAttribute("selectedService", svc);
            request.setAttribute("openModal", action);

        } else if ("create".equals(action)) {
            request.setAttribute("openModal", "create");
        }

        // 👉 LUÔN forward về JSP DUY NHẤT
        request.getRequestDispatcher("/admin/service-management.jsp").forward(request, response);
    }

    // ================= POST =================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User loginUser = getLoggedInUser(request);

        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {

            case "create":
                createService(request, response, loginUser);
                break;

            case "update":
                checkAdmin(loginUser, response);
                updateService(request, response);
                break;

            case "delete":
                checkAdmin(loginUser, response);
                deleteService(request, response);
                break;

            case "toggleStatus":
                checkAdmin(loginUser, response);
                toggleStatus(request, response);
                break;

            case "bulkStatus":
                checkAdmin(loginUser, response);
                bulkUpdateStatus(request, response);
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/admin-services");
        }
    }

    // ================= BUSINESS =================
    private void listServices(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        loadListData(request);
        request.setAttribute("roleId", user.getRoleId());
        request.getRequestDispatcher("/admin/service-management.jsp").forward(request, response);
    }

    private void createService(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException, ServletException {

        Service service = readServiceFromRequest(request, false);
        boolean created = serviceDAO.createService(service);

        if (created) {
            response.sendRedirect(request.getContextPath() + "/admin-services?msg=created");
        } else {
            loadListData(request);
            request.setAttribute("errorMessage", "Mã dịch vụ đã tồn tại!");
            request.setAttribute("selectedService", service);
            request.setAttribute("openModal", "create");
            request.getRequestDispatcher("/admin/service-management.jsp").forward(request, response);
        }
    }

    private void updateService(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        Service service = readServiceFromRequest(request, true);

        boolean updated = serviceDAO.updateService(service);

        String redirect = buildRedirectUrl(request, "updated");

        response.sendRedirect(redirect);
    }

    private void deleteService(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int id = Integer.parseInt(request.getParameter("serviceId"));
        serviceDAO.deleteService(id);

        response.sendRedirect(buildRedirectUrl(request, "deleted"));
    }

    private void toggleStatus(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int id = Integer.parseInt(request.getParameter("serviceId"));
        serviceDAO.toggleServiceStatus(id);

        response.sendRedirect(buildRedirectUrl(request, "status_updated"));
    }

    private void bulkUpdateStatus(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String[] ids = request.getParameterValues("serviceIds");
        String newStatus = request.getParameter("newStatus");

        serviceDAO.bulkUpdateStatus(ids, newStatus);

        response.sendRedirect(buildRedirectUrl(request, "bulk_updated"));
    }

    // ================= HELPER =================
    private String buildRedirectUrl(HttpServletRequest request, String msg) {
        String page = request.getParameter("page");
        String q = request.getParameter("q");
        String status = request.getParameter("status");

        return request.getContextPath()
                + "/admin-services?page=" + (page == null ? "1" : page)
                + "&q=" + (q == null ? "" : q)
                + "&status=" + (status == null ? "" : status)
                + "&msg=" + msg;
    }

    private void checkAdmin(User user, HttpServletResponse response) throws IOException {
        if (user.getRoleId() != ROLE_ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
        }
    }

    private Service readServiceFromRequest(HttpServletRequest request, boolean includeId) {
        Service s = new Service();

        if (includeId) {
            s.setServiceId(Integer.parseInt(request.getParameter("serviceId")));
        }

        s.setServiceName(request.getParameter("serviceName"));
        s.setServiceCode(request.getParameter("serviceCode"));
        s.setDescription(request.getParameter("description"));
        s.setStatus(request.getParameter("status"));

        try {
            s.setEstimatedDeliveryDay(Integer.parseInt(request.getParameter("estimatedDeliveryDay")));
        } catch (Exception e) {
            s.setEstimatedDeliveryDay(0);
        }

        return s;
    }

    private void loadListData(HttpServletRequest request) {
        String q = request.getParameter("q");
        String status = request.getParameter("status");

        if (q == null) {
            q = "";
        }
        if (status == null) {
            status = "";
        }

        List<Service> full = serviceDAO.getAllServices(q, status);

        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (Exception ignored) {
        }

        int total = full.size();
        int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

        int from = (page - 1) * PAGE_SIZE;
        int to = Math.min(from + PAGE_SIZE, total);

        List<Service> list = total == 0 ? new ArrayList<>() : full.subList(from, to);

        request.setAttribute("services", list);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", total);
        request.setAttribute("keyword", q);
        request.setAttribute("status", status);
    }

    private User getLoggedInUser(HttpServletRequest request) {
        HttpSession s = request.getSession(false);
        return s == null ? null : (User) s.getAttribute("user");
    }
}
