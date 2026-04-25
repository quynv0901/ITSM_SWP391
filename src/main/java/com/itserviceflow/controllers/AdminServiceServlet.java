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
    public void init() throws ServletException {
        serviceDAO = new ServiceDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User loginUser = getLoggedInUser(request);
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (loginUser.getRoleId() != ROLE_ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "list";
        }

        switch (action) {
            case "detail":
                viewServiceDetail(request, response, loginUser);
                break;
            case "edit":
                showEditPopup(request, response, loginUser);
                break;
            case "create":
                showCreatePopup(request, response, loginUser);
                break;
            default:
                listServices(request, response, loginUser);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User loginUser = getLoggedInUser(request);
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (loginUser.getRoleId() != ROLE_ADMIN && loginUser.getRoleId() != ROLE_END_USER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "list";
        }

        switch (action) {

            case "create":
                // cho phép cả 1 và 10
                createService(request, response, loginUser);
                break;

            case "update":
            case "delete":
            case "toggleStatus":
            case "bulkStatus":
                // chỉ admin
                if (loginUser.getRoleId() != ROLE_ADMIN) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
                    return;
                }
                break;
        }
    }

    private void listServices(HttpServletRequest request, HttpServletResponse response, User loginUser) throws ServletException, IOException {
        loadListData(request);
        request.setAttribute("roleId", loginUser.getRoleId());
        request.getRequestDispatcher("/admin/service-management.jsp").forward(request, response);
    }

    private void viewServiceDetail(HttpServletRequest request, HttpServletResponse response, User loginUser) throws ServletException, IOException {
        loadListData(request);
        request.setAttribute("roleId", loginUser.getRoleId());
        String idRaw = request.getParameter("id");
        try {
            int serviceId = Integer.parseInt(idRaw);
            Service service = serviceDAO.getServiceById(serviceId);
            if (service == null) {
                request.setAttribute("errorMessage", "Không tìm thấy dịch vụ.");
            } else {
                request.setAttribute("selectedService", service);
                request.setAttribute("openModal", "detail");
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Mã dịch vụ không hợp lệ.");
        }
        request.getRequestDispatcher("/admin/service-management.jsp").forward(request, response);
    }

    private void showCreatePopup(HttpServletRequest request, HttpServletResponse response, User loginUser) throws ServletException, IOException {
        loadListData(request);
        request.setAttribute("roleId", loginUser.getRoleId());
        request.setAttribute("openModal", "create");
        request.getRequestDispatcher("/admin/service-management.jsp").forward(request, response);
    }

    private void showEditPopup(HttpServletRequest request, HttpServletResponse response, User loginUser) throws ServletException, IOException {
        loadListData(request);
        request.setAttribute("roleId", loginUser.getRoleId());
        try {
            int serviceId = Integer.parseInt(request.getParameter("id"));
            Service service = serviceDAO.getServiceById(serviceId);
            if (service == null) {
                request.setAttribute("errorMessage", "Không tìm thấy dịch vụ.");
            } else {
                request.setAttribute("selectedService", service);
                request.setAttribute("openModal", "edit");
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Mã dịch vụ không hợp lệ.");
        }
        request.getRequestDispatcher("/admin/service-management.jsp").forward(request, response);
    }

    private void createService(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws ServletException, IOException {

        Service service = readServiceFromRequest(request, false);

        boolean created = serviceDAO.createService(service);

        if (created) {

            String redirectUrl;

            if (loginUser.getRoleId() == ROLE_END_USER) {
                redirectUrl = "/service-catalog";
            } else {
                redirectUrl = "/admin-services";
            }

            response.sendRedirect(request.getContextPath() + redirectUrl + "?msg=created");

        } else {

            loadListData(request);
            request.setAttribute("roleId", loginUser.getRoleId());
            request.setAttribute("errorMessage", "Mã dịch vụ đã tồn tại!");
            request.setAttribute("selectedService", service);
            request.setAttribute("openModal", "create");

            request.getRequestDispatcher("/admin/service-management.jsp").forward(request, response);
        }
    }

    private void updateService(HttpServletRequest request, HttpServletResponse response, User loginUser) throws ServletException, IOException {
        Service service = readServiceFromRequest(request, true);
        String error = validateServiceInput(service.getServiceName(), service.getServiceCode(), String.valueOf(service.getEstimatedDeliveryDay()), request.getParameter("estimatedDeliveryDay"));
        if (error != null) {
            loadListData(request);
            request.setAttribute("roleId", loginUser.getRoleId());
            request.setAttribute("errorMessage", error);
            request.setAttribute("selectedService", service);
            request.setAttribute("openModal", "edit");
            request.getRequestDispatcher("/admin/service-management.jsp").forward(request, response);
            return;
        }
        boolean updated = serviceDAO.updateService(service);
        if (updated) {
            response.sendRedirect(request.getContextPath() + "/admin-services?msg=updated");
        } else {
            loadListData(request);
            request.setAttribute("roleId", loginUser.getRoleId());
            request.setAttribute("errorMessage", "Cập nhật thất bại. Mã dịch vụ có thể đã tồn tại.");
            request.setAttribute("selectedService", service);
            request.setAttribute("openModal", "edit");
            request.getRequestDispatcher("/admin/service-management.jsp").forward(request, response);
        }
    }

    private Service readServiceFromRequest(HttpServletRequest request, boolean includeId) {
        Service service = new Service();
        if (includeId) {
            try {
                service.setServiceId(Integer.parseInt(request.getParameter("serviceId")));
            } catch (Exception ignored) {
            }
        }
        service.setServiceName(request.getParameter("serviceName") == null ? "" : request.getParameter("serviceName").trim());
        service.setServiceCode(request.getParameter("serviceCode") == null ? "" : request.getParameter("serviceCode").trim());
        service.setDescription(request.getParameter("description") == null ? "" : request.getParameter("description").trim());
        service.setStatus(request.getParameter("status") == null || request.getParameter("status").trim().isEmpty() ? "ACTIVE" : request.getParameter("status").trim());
        try {
            service.setEstimatedDeliveryDay(Integer.parseInt(request.getParameter("estimatedDeliveryDay")));
        } catch (Exception e) {
            service.setEstimatedDeliveryDay(-1);
        }
        return service;
    }

    private void deleteService(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int serviceId = Integer.parseInt(request.getParameter("serviceId"));
            String result = serviceDAO.deleteService(serviceId);
            switch (result) {
                case "success":
                    response.sendRedirect(request.getContextPath() + "/admin-services?msg=deleted");
                    break;
                case "cannot_delete":
                    response.sendRedirect(request.getContextPath() + "/admin-services?msg=cannot_delete");
                    break;
                case "not_found":
                    response.sendRedirect(request.getContextPath() + "/admin-services?msg=not_found");
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/admin-services?msg=error");
                    break;
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin-services?msg=error");
        }
    }

    private void toggleStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int serviceId = Integer.parseInt(request.getParameter("serviceId"));
            boolean updated = serviceDAO.toggleServiceStatus(serviceId);
            response.sendRedirect(request.getContextPath() + "/admin-services?msg=" + (updated ? "status_updated" : "error"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin-services?msg=error");
        }
    }

    private void bulkUpdateStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String[] selectedIds = request.getParameterValues("serviceIds");
        String newStatus = request.getParameter("newStatus");
        int updatedCount = serviceDAO.bulkUpdateStatus(selectedIds, newStatus);
        response.sendRedirect(request.getContextPath() + "/admin-services?msg=bulk_updated&count=" + updatedCount);
    }

    private void loadListData(HttpServletRequest request) {
        String keyword = request.getParameter("q");
        String status = request.getParameter("status");
        if (keyword == null) {
            keyword = "";
        }
        if (status == null) {
            status = "";
        }

        List<Service> fullServices = serviceDAO.getAllServices(keyword, status);
        int currentPage = 1;
        try {
            currentPage = Math.max(1, Integer.parseInt(request.getParameter("page")));
        } catch (Exception ignored) {
        }
        int totalItems = fullServices.size();
        int totalPages = Math.max(1, (int) Math.ceil((double) totalItems / PAGE_SIZE));
        if (currentPage > totalPages) {
            currentPage = totalPages;
        }
        int fromIndex = Math.max(0, (currentPage - 1) * PAGE_SIZE);
        int toIndex = Math.min(fromIndex + PAGE_SIZE, totalItems);
        List<Service> services = totalItems == 0 ? new ArrayList<>() : fullServices.subList(fromIndex, toIndex);

        request.setAttribute("services", services);
        request.setAttribute("keyword", keyword);
        request.setAttribute("status", status);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
    }

    private String validateServiceInput(String serviceName, String serviceCode, String estimatedDayCalculated, String estimatedDayRaw) {
        if (serviceName == null || serviceName.trim().isEmpty()) {
            return "Tên dịch vụ không được để trống.";
        }
        if (serviceCode == null || serviceCode.trim().isEmpty()) {
            return "Mã dịch vụ không được để trống.";
        }
        if (estimatedDayRaw == null || estimatedDayRaw.trim().isEmpty()) {
            return "Số ngày dự kiến không được để trống.";
        }
        try {
            int estimatedDay = Integer.parseInt(estimatedDayRaw);
            if (estimatedDay < 0) {
                return "Số ngày dự kiến phải lớn hơn hoặc bằng 0.";
            }
        } catch (NumberFormatException e) {
            return "Số ngày dự kiến phải là số.";
        }
        return null;
    }

    private User getLoggedInUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session == null ? null : (User) session.getAttribute("user");
    }
}
