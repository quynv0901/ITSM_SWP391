package com.itserviceflow.controllers;

import com.itserviceflow.daos.ServiceDAO;
import com.itserviceflow.models.Service;
import com.itserviceflow.models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminServiceServlet", urlPatterns = {"/admin-services"})
public class AdminServiceServlet extends HttpServlet {

    private static final int ROLE_ADMIN = 10;

    private ServiceDAO serviceDAO;

    @Override
    public void init() throws ServletException {
        serviceDAO = new ServiceDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

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
            case "list":
            default:
                listServices(request, response, loginUser);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User loginUser = getLoggedInUser(request);
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (loginUser.getRoleId() != ROLE_ADMIN) {
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
                createService(request, response, loginUser);
                break;
            case "update":
                updateService(request, response, loginUser);
                break;
            case "delete":
                deleteService(request, response);
                break;
            case "toggleStatus":
                toggleStatus(request, response);
                break;
            case "bulkStatus":
                bulkUpdateStatus(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin-services");
                break;
        }
    }

    private void listServices(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws ServletException, IOException {

        loadListData(request);
        request.setAttribute("roleId", loginUser.getRoleId());
        request.getRequestDispatcher("/admin/service-management.jsp").forward(request, response);
    }

    private void viewServiceDetail(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws ServletException, IOException {

        loadListData(request);
        request.setAttribute("roleId", loginUser.getRoleId());

        String idRaw = request.getParameter("id");
        if (idRaw == null || idRaw.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Invalid service id.");
            request.getRequestDispatcher("/admin/service-management.jsp").forward(request, response);
            return;
        }

        try {
            int serviceId = Integer.parseInt(idRaw);
            Service service = serviceDAO.getServiceById(serviceId);

            if (service == null) {
                request.setAttribute("errorMessage", "Service not found.");
            } else {
                request.setAttribute("selectedService", service);
                request.setAttribute("openModal", "detail");
            }

            request.getRequestDispatcher("/admin/service-management.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid service id.");
            request.getRequestDispatcher("/admin/service-management.jsp").forward(request, response);
        }
    }

    private void showCreatePopup(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws ServletException, IOException {

        loadListData(request);
        request.setAttribute("roleId", loginUser.getRoleId());
        request.setAttribute("openModal", "create");
        request.getRequestDispatcher("/admin/service-management.jsp").forward(request, response);
    }

    private void showEditPopup(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws ServletException, IOException {

        loadListData(request);
        request.setAttribute("roleId", loginUser.getRoleId());

        String idRaw = request.getParameter("id");
        if (idRaw == null || idRaw.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Invalid service id.");
            request.getRequestDispatcher("/admin/service-management.jsp").forward(request, response);
            return;
        }

        try {
            int serviceId = Integer.parseInt(idRaw);
            Service service = serviceDAO.getServiceById(serviceId);

            if (service == null) {
                request.setAttribute("errorMessage", "Service not found.");
            } else {
                request.setAttribute("selectedService", service);
                request.setAttribute("openModal", "edit");
            }

            request.getRequestDispatcher("/admin/service-management.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid service id.");
            request.getRequestDispatcher("/admin/service-management.jsp").forward(request, response);
        }
    }

    private void createService(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws ServletException, IOException {

        String serviceName = request.getParameter("serviceName");
        String serviceCode = request.getParameter("serviceCode");
        String description = request.getParameter("description");
        String estimatedDayRaw = request.getParameter("estimatedDeliveryDay");
        String status = request.getParameter("status");

        String error = validateServiceInput(serviceName, serviceCode, estimatedDayRaw);

        Service service = new Service();
        service.setServiceName(serviceName != null ? serviceName.trim() : "");
        service.setServiceCode(serviceCode != null ? serviceCode.trim() : "");
        service.setDescription(description != null ? description.trim() : "");
        service.setStatus((status == null || status.trim().isEmpty()) ? "ACTIVE" : status.trim());

        if (error != null) {
            loadListData(request);
            request.setAttribute("roleId", loginUser.getRoleId());
            request.setAttribute("errorMessage", error);
            request.setAttribute("selectedService", service);
            request.setAttribute("openModal", "create");
            request.getRequestDispatcher("/admin/service-management.jsp").forward(request, response);
            return;
        }

        int estimatedDeliveryDay = Integer.parseInt(estimatedDayRaw);
        service.setEstimatedDeliveryDay(estimatedDeliveryDay);

        boolean created = serviceDAO.createService(service);

        if (created) {
            response.sendRedirect(request.getContextPath() + "/admin-services?msg=created");
        } else {
            loadListData(request);
            request.setAttribute("roleId", loginUser.getRoleId());
            request.setAttribute("errorMessage", "Create failed. Service code may already exist.");
            request.setAttribute("selectedService", service);
            request.setAttribute("openModal", "create");
            request.getRequestDispatcher("/admin/service-management.jsp").forward(request, response);
        }
    }

    private void updateService(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws ServletException, IOException {

        String idRaw = request.getParameter("serviceId");
        String serviceName = request.getParameter("serviceName");
        String serviceCode = request.getParameter("serviceCode");
        String description = request.getParameter("description");
        String estimatedDayRaw = request.getParameter("estimatedDeliveryDay");
        String status = request.getParameter("status");

        if (idRaw == null || idRaw.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin-services?msg=error");
            return;
        }

        Service service = new Service();
        try {
            service.setServiceId(Integer.parseInt(idRaw));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin-services?msg=error");
            return;
        }

        service.setServiceName(serviceName != null ? serviceName.trim() : "");
        service.setServiceCode(serviceCode != null ? serviceCode.trim() : "");
        service.setDescription(description != null ? description.trim() : "");
        service.setStatus((status == null || status.trim().isEmpty()) ? "ACTIVE" : status.trim());

        String error = validateServiceInput(serviceName, serviceCode, estimatedDayRaw);
        if (error != null) {
            loadListData(request);
            request.setAttribute("roleId", loginUser.getRoleId());
            request.setAttribute("errorMessage", error);
            request.setAttribute("selectedService", service);
            request.setAttribute("openModal", "edit");
            request.getRequestDispatcher("/admin/service-management.jsp").forward(request, response);
            return;
        }

        int estimatedDeliveryDay = Integer.parseInt(estimatedDayRaw);
        service.setEstimatedDeliveryDay(estimatedDeliveryDay);

        boolean updated = serviceDAO.updateService(service);

        if (updated) {
            response.sendRedirect(request.getContextPath() + "/admin-services?msg=updated");
        } else {
            loadListData(request);
            request.setAttribute("roleId", loginUser.getRoleId());
            request.setAttribute("errorMessage", "Update failed. Service code may already exist.");
            request.setAttribute("selectedService", service);
            request.setAttribute("openModal", "edit");
            request.getRequestDispatcher("/admin/service-management.jsp").forward(request, response);
        }
    }

    private void deleteService(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String idRaw = request.getParameter("serviceId");

        if (idRaw == null || idRaw.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin-services?msg=error");
            return;
        }

        try {
            int serviceId = Integer.parseInt(idRaw);
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

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin-services?msg=error");
        }
    }

    private void toggleStatus(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String idRaw = request.getParameter("serviceId");

        if (idRaw == null || idRaw.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin-services?msg=error");
            return;
        }

        try {
            int serviceId = Integer.parseInt(idRaw);
            boolean updated = serviceDAO.toggleServiceStatus(serviceId);

            if (updated) {
                response.sendRedirect(request.getContextPath() + "/admin-services?msg=status_updated");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin-services?msg=error");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin-services?msg=error");
        }
    }

    private void bulkUpdateStatus(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String[] selectedIds = request.getParameterValues("serviceIds");
        String newStatus = request.getParameter("newStatus");

        int updatedCount = serviceDAO.bulkUpdateStatus(selectedIds, newStatus);

        response.sendRedirect(request.getContextPath()
                + "/admin-services?msg=bulk_updated&count=" + updatedCount);
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

        List<Service> services = serviceDAO.getAllServices(keyword, status);

        request.setAttribute("services", services);
        request.setAttribute("keyword", keyword);
        request.setAttribute("status", status);
    }

    private String validateServiceInput(String serviceName, String serviceCode, String estimatedDayRaw) {
        if (serviceName == null || serviceName.trim().isEmpty()) {
            return "Service name is required.";
        }

        if (serviceCode == null || serviceCode.trim().isEmpty()) {
            return "Service code is required.";
        }

        if (estimatedDayRaw == null || estimatedDayRaw.trim().isEmpty()) {
            return "Estimated delivery day is required.";
        }

        try {
            int estimatedDay = Integer.parseInt(estimatedDayRaw);
            if (estimatedDay < 0) {
                return "Estimated delivery day must be greater than or equal to 0.";
            }
        } catch (NumberFormatException e) {
            return "Estimated delivery day must be a number.";
        }

        return null;
    }

    private User getLoggedInUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        return (User) session.getAttribute("user");
    }
}