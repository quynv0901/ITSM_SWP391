package com.itserviceflow.controllers;

import com.itserviceflow.daos.ServiceRequestDAO;
import com.itserviceflow.dtos.ServiceRequestDetailDTO;
import com.itserviceflow.dtos.UserOptionDTO;
import com.itserviceflow.models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "ServiceRequestManageServlet", urlPatterns = {"/service-request-manage"})
public class ServiceRequestManageServlet extends HttpServlet {

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
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        User loginUser = getLoggedInUser(request);
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/service-request?action=list");
            return;
        }

        switch (action) {
            case "edit":
            case "assignForm":
            case "approvalForm":
                showManageDetail(request, response, loginUser);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/service-request?action=list");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        User loginUser = getLoggedInUser(request);
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/service-request?action=list");
            return;
        }

        switch (action) {
            case "update":
                updateServiceRequest(request, response, loginUser);
                break;
            case "assign":
                assignServiceRequest(request, response, loginUser);
                break;
            case "approve":
                approveServiceRequest(request, response, loginUser);
                break;
            case "reject":
                rejectServiceRequest(request, response, loginUser);
                break;
            case "bulkApprove":
                bulkApproveServiceRequests(request, response, loginUser);
                break;
            case "bulkReject":
                bulkRejectServiceRequests(request, response, loginUser);
                break;
            case "comment":
                addComment(request, response, loginUser);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/service-request?action=list");
                break;
        }
    }

    private void showManageDetail(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws ServletException, IOException {

        if (!isSupportOrManager(loginUser)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập.");
            return;
        }

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

            if (!canManage(loginUser, dto)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập.");
                return;
            }

            List<UserOptionDTO> agentOptions;
            if (dto.getDepartmentId() != null) {
                agentOptions = serviceRequestDAO.getSupportAgentsByDepartment(dto.getDepartmentId());
            } else {
                agentOptions = serviceRequestDAO.getSupportAgents();
            }

            request.setAttribute("serviceRequest", dto);
            request.setAttribute("agentOptions", agentOptions);

            request.getRequestDispatcher("/ticket/service-request-detail-manager.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/service-request?action=list&msg=invalid_id");
        }
    }

    private void updateServiceRequest(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws IOException {

        if (!isSupportOrManager(loginUser)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập.");
            return;
        }

        String ticketIdRaw = request.getParameter("ticketId");
        String title = trim(request.getParameter("title"));
        String description = trim(request.getParameter("description"));
        String status = trim(request.getParameter("status"));
        String assignedToRaw = request.getParameter("assignedTo");
        String solution = trim(request.getParameter("solution"));

        if (ticketIdRaw == null || ticketIdRaw.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/service-request?action=list&msg=invalid_id");
            return;
        }

        try {
            int ticketId = Integer.parseInt(ticketIdRaw);
            ServiceRequestDetailDTO current = serviceRequestDAO.getServiceRequestById(ticketId);

            if (current == null || !canManage(loginUser, current)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập.");
                return;
            }

            if (loginUser.getRoleId() == ROLE_SUPPORT_AGENT && !isValidAgentStatus(status)) {
                response.sendRedirect(request.getContextPath() + "/service-request-manage?action=edit&id=" + ticketId + "&msg=invalid_status");
                return;
            }

            ServiceRequestDetailDTO dto = new ServiceRequestDetailDTO();
            dto.setTicketId(ticketId);
            dto.setTitle(title);
            dto.setDescription(description);
            dto.setStatus(status);
            dto.setSolution(solution);

            if (assignedToRaw != null && !assignedToRaw.trim().isEmpty()) {
                dto.setAssignedTo(Integer.parseInt(assignedToRaw));
            }

            boolean updated = serviceRequestDAO.updateServiceRequest(dto);

            if (updated) {
                response.sendRedirect(request.getContextPath() + "/service-request-manage?action=edit&id=" + ticketId + "&msg=updated");
            } else {
                response.sendRedirect(request.getContextPath() + "/service-request-manage?action=edit&id=" + ticketId + "&msg=update_failed");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/service-request?action=list&msg=invalid_id");
        }
    }

    private void assignServiceRequest(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws IOException {

        if (loginUser.getRoleId() != ROLE_MANAGER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ quản lý mới được phân công yêu cầu dịch vụ.");
            return;
        }

        String ticketIdRaw = request.getParameter("ticketId");
        String assignedToRaw = request.getParameter("assignedTo");

        if (ticketIdRaw == null || assignedToRaw == null
                || ticketIdRaw.trim().isEmpty() || assignedToRaw.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/service-request?action=list&msg=invalid_input");
            return;
        }

        try {
            int ticketId = Integer.parseInt(ticketIdRaw);
            int assignedTo = Integer.parseInt(assignedToRaw);

            ServiceRequestDetailDTO current = serviceRequestDAO.getServiceRequestById(ticketId);
            if (current == null || !canManage(loginUser, current)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập.");
                return;
            }

            boolean assigned = serviceRequestDAO.assignServiceRequest(ticketId, assignedTo);

            if (assigned) {
                response.sendRedirect(request.getContextPath() + "/service-request-manage?action=edit&id=" + ticketId + "&msg=assigned");
            } else {
                response.sendRedirect(request.getContextPath() + "/service-request-manage?action=edit&id=" + ticketId + "&msg=assign_failed");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/service-request?action=list&msg=invalid_id");
        }
    }

    private void approveServiceRequest(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws IOException {

        if (loginUser.getRoleId() != ROLE_MANAGER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ quản lý mới được duyệt.");
            return;
        }

        String ticketIdRaw = request.getParameter("ticketId");
        if (ticketIdRaw == null || ticketIdRaw.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/service-request?action=list&msg=invalid_id");
            return;
        }

        try {
            int ticketId = Integer.parseInt(ticketIdRaw);
            ServiceRequestDetailDTO current = serviceRequestDAO.getServiceRequestById(ticketId);

            if (current == null || !canManage(loginUser, current)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập.");
                return;
            }

            boolean approved = serviceRequestDAO.approveServiceRequest(ticketId, loginUser.getUserId());

            if (approved) {
                response.sendRedirect(request.getContextPath() + "/service-request-manage?action=edit&id=" + ticketId + "&msg=approved");
            } else {
                response.sendRedirect(request.getContextPath() + "/service-request-manage?action=edit&id=" + ticketId + "&msg=approve_failed");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/service-request?action=list&msg=invalid_id");
        }
    }

    private void rejectServiceRequest(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws IOException {

        if (loginUser.getRoleId() != ROLE_MANAGER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ quản lý mới được từ chối.");
            return;
        }

        String ticketIdRaw = request.getParameter("ticketId");
        String rejectionReason = trim(request.getParameter("rejectionReason"));

        if (ticketIdRaw == null || ticketIdRaw.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/service-request?action=list&msg=invalid_id");
            return;
        }

        try {
            int ticketId = Integer.parseInt(ticketIdRaw);
            ServiceRequestDetailDTO current = serviceRequestDAO.getServiceRequestById(ticketId);

            if (current == null || !canManage(loginUser, current)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập.");
                return;
            }

            boolean rejected = serviceRequestDAO.rejectServiceRequest(ticketId, loginUser.getUserId(), rejectionReason);

            if (rejected) {
                response.sendRedirect(request.getContextPath() + "/service-request-manage?action=edit&id=" + ticketId + "&msg=rejected");
            } else {
                response.sendRedirect(request.getContextPath() + "/service-request-manage?action=edit&id=" + ticketId + "&msg=reject_failed");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/service-request?action=list&msg=invalid_id");
        }
    }

    private void bulkApproveServiceRequests(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws IOException {

        if (loginUser.getRoleId() != ROLE_MANAGER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ quản lý mới được duyệt hàng loạt.");
            return;
        }

        String[] ticketIds = request.getParameterValues("ticketIds");
        int updatedCount = serviceRequestDAO.bulkApproveServiceRequests(ticketIds, loginUser.getUserId());

        response.sendRedirect(request.getContextPath() + "/service-request?action=list&msg=bulk_approved&count=" + updatedCount);
    }

    private void bulkRejectServiceRequests(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws IOException {

        if (loginUser.getRoleId() != ROLE_MANAGER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ quản lý mới được từ chối hàng loạt.");
            return;
        }

        String[] ticketIds = request.getParameterValues("ticketIds");
        String rejectionReason = trim(request.getParameter("rejectionReason"));

        int updatedCount = serviceRequestDAO.bulkRejectServiceRequests(ticketIds, loginUser.getUserId(), rejectionReason);

        response.sendRedirect(request.getContextPath() + "/service-request?action=list&msg=bulk_rejected&count=" + updatedCount);
    }

    private void addComment(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws IOException {

        if (!isSupportOrManager(loginUser)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập.");
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
            ServiceRequestDetailDTO current = serviceRequestDAO.getServiceRequestById(ticketId);

            if (current == null || !canManage(loginUser, current)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập.");
                return;
            }

            boolean added = serviceRequestDAO.addComment(ticketId, loginUser.getUserId(), commentText);

            if (added) {
                response.sendRedirect(request.getContextPath() + "/service-request-manage?action=edit&id=" + ticketId + "&msg=comment_added");
            } else {
                response.sendRedirect(request.getContextPath() + "/service-request-manage?action=edit&id=" + ticketId + "&msg=comment_failed");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/service-request?action=list&msg=invalid_id");
        }
    }

    private boolean isSupportOrManager(User user) {
        return user.getRoleId() == ROLE_SUPPORT_AGENT || user.getRoleId() == ROLE_MANAGER;
    }

    private boolean canManage(User loginUser, ServiceRequestDetailDTO dto) {
        if (loginUser.getRoleId() == ROLE_MANAGER) {
            return true;
        }

        if (loginUser.getRoleId() == ROLE_SUPPORT_AGENT) {
            return true;
        }

        return false;
    }

    private boolean isValidAgentStatus(String status) {
        return "IN_PROGRESS".equals(status)
                || "PENDING".equals(status)
                || "RESOLVED".equals(status);
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
