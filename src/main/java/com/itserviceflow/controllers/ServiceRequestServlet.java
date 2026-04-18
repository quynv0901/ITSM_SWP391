package com.itserviceflow.controllers;

import com.itserviceflow.daos.ServiceRequestDAO;
import com.itserviceflow.dtos.CategoryOptionDTO;
import com.itserviceflow.dtos.ServiceOptionDTO;
import com.itserviceflow.dtos.ServiceRequestDetailDTO;
import com.itserviceflow.dtos.ServiceRequestFilterDTO;
import com.itserviceflow.dtos.ServiceRequestListDTO;
import com.itserviceflow.models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "ServiceRequestServlet", urlPatterns = {"/service-request"})
public class ServiceRequestServlet extends HttpServlet {

    private static final int ROLE_END_USER = 1;
    private static final int ROLE_SUPPORT_AGENT = 2;
    private static final int ROLE_MANAGER = 3;

    private ServiceRequestDAO serviceRequestDAO;

    @Override
    public void init() throws ServletException {
        serviceRequestDAO = new ServiceRequestDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User loginUser = getLoggedInUser(request);
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "list";
        }

        switch (action) {
            case "detail":
                viewServiceRequestDetail(request, response, loginUser);
                break;
            case "createForm":
                showCreateForm(request, response, loginUser);
                break;
            case "list":
            default:
                listServiceRequests(request, response, loginUser);
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

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "list";
        }

        switch (action) {
            case "create":
                createServiceRequest(request, response, loginUser);
                break;
            case "delete":
                deleteServiceRequest(request, response, loginUser);
                break;
            case "bulkDelete":
                bulkDeleteServiceRequests(request, response, loginUser);
                break;
            case "cancel":
                cancelServiceRequest(request, response, loginUser);
                break;
            case "comment":
                addComment(request, response, loginUser);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/service-request?action=list");
                break;
        }
    }

    private void listServiceRequests(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws ServletException, IOException {

        ServiceRequestFilterDTO filter = buildFilter(request);

        List<ServiceRequestListDTO> requests;

        if (loginUser.getRoleId() == ROLE_END_USER) {
            requests = serviceRequestDAO.getServiceRequestsByRequester(loginUser.getUserId(), filter);
        } else if (loginUser.getRoleId() == ROLE_SUPPORT_AGENT) {
            requests = serviceRequestDAO.getServiceRequestsByAssignee(loginUser.getUserId(), filter);
        } else if (loginUser.getRoleId() == ROLE_MANAGER) {
            requests = serviceRequestDAO.getServiceRequestsByDepartment(loginUser.getDepartmentId(), filter);
        } else {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
            return;
        }

        request.setAttribute("requestList", requests);
        request.setAttribute("keyword", filter.getKeyword());
        request.setAttribute("status", filter.getStatus());
        request.setAttribute("approvalStatus", filter.getApprovalStatus());

        request.getRequestDispatcher("/ticket/service-request-list.jsp").forward(request, response);
    }

    private void viewServiceRequestDetail(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws ServletException, IOException {

        String idRaw = request.getParameter("id");
        if (idRaw == null || idRaw.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/service-request?action=list");
            return;
        }

        try {
            int ticketId = Integer.parseInt(idRaw);
            ServiceRequestDetailDTO dto = serviceRequestDAO.getServiceRequestById(ticketId);

            if (dto == null) {
                response.sendRedirect(request.getContextPath() + "/service-request?action=list&msg=not_found");
                return;
            }

            if (!canViewRequest(loginUser, dto)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
                return;
            }

            request.setAttribute("serviceRequest", dto);

            if (loginUser.getRoleId() == ROLE_END_USER) {
                request.getRequestDispatcher("/ticket/service-request-detail-user.jsp").forward(request, response);
            } else {
                request.getRequestDispatcher("/ticket/service-request-detail-manager.jsp").forward(request, response);
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/service-request?action=list&msg=invalid_id");
        }
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws ServletException, IOException {

        if (loginUser.getRoleId() != ROLE_END_USER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only end-user can create service requests.");
            return;
        }

        List<ServiceOptionDTO> serviceOptions = serviceRequestDAO.getActiveServicesForOption();
        List<CategoryOptionDTO> categoryOptions = serviceRequestDAO.getServiceRequestCategories();

        request.setAttribute("serviceOptions", serviceOptions);
        request.setAttribute("categoryOptions", categoryOptions);

        request.getRequestDispatcher("/ticket/create-request.jsp").forward(request, response);
    }

    private void createServiceRequest(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws ServletException, IOException {

        if (loginUser.getRoleId() != ROLE_END_USER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only end-user can create service requests.");
            return;
        }

        String serviceIdRaw = request.getParameter("serviceId");
        String title = trim(request.getParameter("title"));
        String description = trim(request.getParameter("description"));
        String priority = trim(request.getParameter("priority"));
        String categoryIdRaw = request.getParameter("categoryId");
        String justification = trim(request.getParameter("justification"));

        String error = validateCreateInput(serviceIdRaw, title, priority, justification);
        if (error != null) {
            request.setAttribute("errorMessage", error);
            request.setAttribute("title", title);
            request.setAttribute("description", description);
            request.setAttribute("priority", priority);
            request.setAttribute("justification", justification);
            request.getRequestDispatcher("/ticket/create-request.jsp").forward(request, response);
            return;
        }

        try {
            ServiceRequestDetailDTO dto = new ServiceRequestDetailDTO();
            dto.setTicketNumber(serviceRequestDAO.generateNextServiceRequestNumber());
            dto.setServiceId(Integer.parseInt(serviceIdRaw));
            dto.setTitle(title);
            dto.setDescription(description);
            dto.setPriority(priority);
            dto.setJustification(justification);
            dto.setReportedBy(loginUser.getUserId());
            dto.setDepartmentId(loginUser.getDepartmentId());

            if (categoryIdRaw != null && !categoryIdRaw.trim().isEmpty()) {
                dto.setCategoryId(Integer.parseInt(categoryIdRaw));
            }

            boolean created = serviceRequestDAO.createServiceRequest(dto);

            if (created) {
                response.sendRedirect(request.getContextPath() + "/service-request?action=list&msg=created");
            } else {
                request.setAttribute("errorMessage", "Create failed. Service may be inactive or data is invalid.");
                request.getRequestDispatcher("/ticket/create-request.jsp").forward(request, response);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid numeric input.");
            request.getRequestDispatcher("/ticket/create-request.jsp").forward(request, response);
        }
    }

    private void deleteServiceRequest(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws IOException {

        if (loginUser.getRoleId() != ROLE_END_USER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only end-user can delete service request.");
            return;
        }

        String ticketIdRaw = request.getParameter("ticketId");
        if (ticketIdRaw == null || ticketIdRaw.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/service-request?action=list&msg=invalid_id");
            return;
        }

        try {
            int ticketId = Integer.parseInt(ticketIdRaw);
            boolean deleted = serviceRequestDAO.deleteServiceRequest(ticketId, loginUser.getUserId());

            if (deleted) {
                response.sendRedirect(request.getContextPath() + "/service-request?action=list&msg=deleted");
            } else {
                response.sendRedirect(request.getContextPath() + "/service-request?action=detail&id=" + ticketId + "&msg=delete_failed");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/service-request?action=list&msg=invalid_id");
        }
    }

    private void bulkDeleteServiceRequests(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws IOException {

        if (loginUser.getRoleId() != ROLE_END_USER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only end-user can bulk delete.");
            return;
        }

        String[] ticketIds = request.getParameterValues("ticketIds");
        int deletedCount = serviceRequestDAO.bulkDeleteServiceRequests(ticketIds, loginUser.getUserId());

        response.sendRedirect(request.getContextPath() + "/service-request?action=list&msg=bulk_deleted&count=" + deletedCount);
    }

    private void cancelServiceRequest(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws IOException {

        String ticketIdRaw = request.getParameter("ticketId");
        if (ticketIdRaw == null || ticketIdRaw.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/service-request?action=list&msg=invalid_id");
            return;
        }

        try {
            int ticketId = Integer.parseInt(ticketIdRaw);
            boolean cancelled;

            if (loginUser.getRoleId() == ROLE_END_USER) {
                cancelled = serviceRequestDAO.cancelServiceRequestByRequester(ticketId, loginUser.getUserId());
            } else if (loginUser.getRoleId() == ROLE_MANAGER) {
                cancelled = serviceRequestDAO.cancelServiceRequest(ticketId);
            } else {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
                return;
            }

            if (cancelled) {
                response.sendRedirect(request.getContextPath() + "/service-request?action=detail&id=" + ticketId + "&msg=cancelled");
            } else {
                response.sendRedirect(request.getContextPath() + "/service-request?action=detail&id=" + ticketId + "&msg=cancel_failed");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/service-request?action=list&msg=invalid_id");
        }
    }

    private void addComment(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws IOException {

        if (!isRequesterOrAgentOrManager(loginUser)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
            return;
        }

        String ticketIdRaw = request.getParameter("ticketId");
        String commentText = trim(request.getParameter("commentText"));

        if (ticketIdRaw == null || ticketIdRaw.trim().isEmpty() || commentText == null || commentText.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/service-request?action=list&msg=invalid_input");
            return;
        }

        try {
            int ticketId = Integer.parseInt(ticketIdRaw);
            boolean added = serviceRequestDAO.addComment(ticketId, loginUser.getUserId(), commentText);

            if (added) {
                response.sendRedirect(request.getContextPath() + "/service-request?action=detail&id=" + ticketId + "&msg=comment_added");
            } else {
                response.sendRedirect(request.getContextPath() + "/service-request?action=detail&id=" + ticketId + "&msg=comment_failed");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/service-request?action=list&msg=invalid_id");
        }
    }

    private boolean canViewRequest(User loginUser, ServiceRequestDetailDTO dto) {
        if (loginUser.getRoleId() == ROLE_MANAGER) {
            return dto.getDepartmentId() != null && dto.getDepartmentId().equals(loginUser.getDepartmentId());
        }
        if (loginUser.getRoleId() == ROLE_SUPPORT_AGENT) {
            return dto.getAssignedTo() != null && dto.getAssignedTo().equals(loginUser.getUserId());
        }
        if (loginUser.getRoleId() == ROLE_END_USER) {
            return dto.getReportedBy() == loginUser.getUserId();
        }
        return false;
    }

    private boolean isRequesterOrAgentOrManager(User loginUser) {
        return loginUser.getRoleId() == ROLE_END_USER
                || loginUser.getRoleId() == ROLE_SUPPORT_AGENT
                || loginUser.getRoleId() == ROLE_MANAGER;
    }

    private ServiceRequestFilterDTO buildFilter(HttpServletRequest request) {
        ServiceRequestFilterDTO filter = new ServiceRequestFilterDTO();
        filter.setKeyword(trim(request.getParameter("keyword")));
        filter.setStatus(trim(request.getParameter("status")));
        filter.setApprovalStatus(trim(request.getParameter("approvalStatus")));
        return filter;
    }

    private String validateCreateInput(String serviceIdRaw, String title, String priority, String justification) {
        if (serviceIdRaw == null || serviceIdRaw.trim().isEmpty()) {
            return "Service is required.";
        }
        if (title == null || title.isEmpty()) {
            return "Title is required.";
        }
        if (priority == null || priority.isEmpty()) {
            return "Priority is required.";
        }
        if (justification == null || justification.isEmpty()) {
            return "Justification is required.";
        }
        try {
            Integer.parseInt(serviceIdRaw);
        } catch (NumberFormatException e) {
            return "Invalid service id.";
        }
        return null;
    }

    private String trim(String s) {
        return s == null ? null : s.trim();
    }

    private User getLoggedInUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        return (User) session.getAttribute("user");
    }
}
