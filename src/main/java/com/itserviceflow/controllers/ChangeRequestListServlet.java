/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package com.itserviceflow.controllers;

import com.itserviceflow.daos.ChangeRequestDAO;
import com.itserviceflow.dtos.*;
import com.itserviceflow.models.*;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Timestamp;
import java.util.List;

/**
 *
 * @author catim
 */
@WebServlet(name = "ChangeRequestListServlet", urlPatterns = {"/change-request-list/*"})
public class ChangeRequestListServlet extends HttpServlet {

    private static final int ROLE_MANAGER = 3;
    private static final int ROLE_SYSTEM_ENGINEER = 6;
    private static final int ROLE_CAB_MEMBER = 7;

    private ChangeRequestDAO changeRequestDAO;

    @Override
    public void init() throws ServletException {
        changeRequestDAO = new ChangeRequestDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User loginUser = getLoggedInUser(request);
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        String path = request.getPathInfo();
        if (path == null || "/".equals(path) || "/list".equals(path)) {
            showList(request, response, loginUser);
        } else if ("/detail".equals(path)) {
            showDetail(request, response, loginUser);
        } else if ("/create".equals(path)) {
            showCreateForm(request, response, loginUser);
        } else if ("/edit".equals(path)) {
            showUpdateForm(request, response, loginUser);
        } else {
            response.sendRedirect(request.getContextPath() + "/change-request-list/list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User loginUser = getLoggedInUser(request);
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        String path = request.getPathInfo();
        if ("/create".equals(path)) {
            createChangeRequest(request, response, loginUser);
        } else if ("/edit".equals(path)) {
            updateChangeRequest(request, response, loginUser);
        } else if ("/delete".equals(path)) {
            deleteChangeRequest(request, response, loginUser);
        } else if ("/cancel".equals(path)) {
            cancelChangeRequest(request, response, loginUser);
        } else if ("/assign".equals(path)) {
            assignChangeRequest(request, response, loginUser);
        } else if ("/assess".equals(path)) {
            assessChangeRisk(request, response, loginUser);
        } else if ("/review".equals(path)) {
            reviewChangeRequest(request, response, loginUser);
        } else {
            response.sendRedirect(request.getContextPath() + "/change-request-list/list");
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response, User loginUser) throws ServletException, IOException {
        if (!canAccess(loginUser)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập.");
            return;
        }

        ChangeRequestFilterDTO filter = new ChangeRequestFilterDTO();
        filter.setSearch(trim(request.getParameter("search")));
        filter.setStatusFilter(trim(request.getParameter("statusFilter")));

        if (loginUser.getRoleId() == ROLE_SYSTEM_ENGINEER) {
            filter.setRequesterId(loginUser.getUserId());
        }

        List<ChangeRequestListDTO> list = changeRequestDAO.getChangeRequestList(filter);
        request.setAttribute("changeRequests", list);
        request.setAttribute("search", filter.getSearch());
        request.setAttribute("statusFilter", filter.getStatusFilter());
        request.getRequestDispatcher("/ticket/change-request-list.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response, User loginUser) throws ServletException, IOException {
        if (!canAccess(loginUser)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập.");
            return;
        }

        int ticketId = parseInt(request.getParameter("id"));
        if (ticketId <= 0) {
            response.sendRedirect(request.getContextPath() + "/change-request-list/list");
            return;
        }

        ChangeRequestDetailDTO ticket = changeRequestDAO.getChangeRequestDetail(ticketId);
        if (ticket == null) {
            response.sendRedirect(request.getContextPath() + "/change-request-list/list");
            return;
        }

        request.setAttribute("ticket", ticket);
        request.setAttribute("comments", ticket.getComments());
        request.setAttribute("engineers", changeRequestDAO.getSystemEngineers());
        request.getRequestDispatcher("/ticket/change-request-detail.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response, User loginUser) throws ServletException, IOException {
        if (loginUser.getRoleId() != ROLE_SYSTEM_ENGINEER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ System Engineer mới được tạo yêu cầu thay đổi.");
            return;
        }
        request.getRequestDispatcher("/ticket/create-change-request.jsp").forward(request, response);
    }

    private void showUpdateForm(HttpServletRequest request, HttpServletResponse response, User loginUser) throws ServletException, IOException {
        if (loginUser.getRoleId() != ROLE_SYSTEM_ENGINEER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ System Engineer mới được sửa yêu cầu thay đổi.");
            return;
        }

        int ticketId = parseInt(request.getParameter("id"));
        ChangeRequestDetailDTO ticket = changeRequestDAO.getChangeRequestDetail(ticketId);
        if (ticket == null || ticket.getReportedBy() == null || ticket.getReportedBy() != loginUser.getUserId()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ người tạo mới được sửa.");
            return;
        }

        request.setAttribute("ticket", ticket);
        request.getRequestDispatcher("/ticket/update-change-request.jsp").forward(request, response);
    }

    private void createChangeRequest(HttpServletRequest request, HttpServletResponse response, User loginUser) throws IOException {
        if (loginUser.getRoleId() != ROLE_SYSTEM_ENGINEER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ System Engineer mới được tạo yêu cầu thay đổi.");
            return;
        }

        ChangeRequestDetailDTO dto = buildDtoFromRequest(request);
        dto.setTicketNumber(changeRequestDAO.generateNextChangeRequestNumber());
        dto.setReportedBy(loginUser.getUserId());
        dto.setAssignedTo(loginUser.getDepartmentId());

        boolean created = changeRequestDAO.createChangeRequest(dto);
        response.sendRedirect(request.getContextPath() + "/change-request-list/list" + (created ? "?msg=created" : "?msg=create_failed"));
    }

    private void updateChangeRequest(HttpServletRequest request, HttpServletResponse response, User loginUser) throws IOException {
        if (loginUser.getRoleId() != ROLE_SYSTEM_ENGINEER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ System Engineer mới được sửa yêu cầu thay đổi.");
            return;
        }

        int ticketId = parseInt(request.getParameter("ticketId"));
        ChangeRequestDetailDTO current = changeRequestDAO.getChangeRequestDetail(ticketId);
        if (current == null || current.getReportedBy() == null || current.getReportedBy() != loginUser.getUserId()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ người tạo mới được sửa.");
            return;
        }

        ChangeRequestDetailDTO dto = buildDtoFromRequest(request);
        dto.setTicketId(ticketId);

        boolean updated = changeRequestDAO.updateChangeRequest(dto);
        response.sendRedirect(request.getContextPath() + "/change-request-list/detail?id=" + ticketId + (updated ? "&msg=updated" : "&msg=update_failed"));
    }

    private void deleteChangeRequest(HttpServletRequest request, HttpServletResponse response, User loginUser) throws IOException {
        if (loginUser.getRoleId() != ROLE_SYSTEM_ENGINEER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ System Engineer mới được xóa yêu cầu thay đổi.");
            return;
        }

        String actionType = trim(request.getParameter("actionType"));
        if ("single".equals(actionType)) {
            int ticketId = parseInt(request.getParameter("ticketId"));
            boolean deleted = changeRequestDAO.deleteChangeRequest(ticketId);
            response.sendRedirect(request.getContextPath() + "/change-request-list/list" + (deleted ? "?msg=deleted" : "?msg=delete_failed"));
        } else {
            String[] ticketIds = request.getParameterValues("ticketIds");
            int count = changeRequestDAO.bulkDeleteChangeRequests(ticketIds);
            response.sendRedirect(request.getContextPath() + "/change-request-list/list?msg=bulk_deleted&count=" + count);
        }
    }

    private void cancelChangeRequest(HttpServletRequest request, HttpServletResponse response, User loginUser) throws IOException {
        if (loginUser.getRoleId() != ROLE_SYSTEM_ENGINEER && loginUser.getRoleId() != ROLE_MANAGER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền hủy yêu cầu thay đổi.");
            return;
        }
        int ticketId = parseInt(request.getParameter("ticketId"));
        boolean cancelled = changeRequestDAO.cancelChangeRequest(ticketId);
        response.sendRedirect(request.getContextPath() + "/change-request-list/detail?id=" + ticketId + (cancelled ? "&msg=cancelled" : "&msg=cancel_failed"));
    }

    private void assignChangeRequest(HttpServletRequest request, HttpServletResponse response, User loginUser) throws IOException {
        if (loginUser.getRoleId() != ROLE_MANAGER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ Manager mới được phân công.");
            return;
        }
        int ticketId = parseInt(request.getParameter("ticketId"));
        int engineerId = parseInt(request.getParameter("assignedTo"));
        boolean assigned = changeRequestDAO.assignChangeRequest(ticketId, engineerId);
        response.sendRedirect(request.getContextPath() + "/change-request-list/detail?id=" + ticketId + (assigned ? "&msg=assigned" : "&msg=assign_failed"));
    }

    private void assessChangeRisk(HttpServletRequest request, HttpServletResponse response, User loginUser) throws IOException {
        if (loginUser.getRoleId() != ROLE_CAB_MEMBER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ CAB Member mới được đánh giá rủi ro.");
            return;
        }
        int ticketId = parseInt(request.getParameter("ticketId"));
        boolean ok = changeRequestDAO.assessRisk(
                ticketId,
                loginUser.getUserId(),
                trim(request.getParameter("riskLevel")),
                trim(request.getParameter("impactAssessment")),
                trim(request.getParameter("cabRiskAssessment")),
                parseTimestamp(request.getParameter("scheduledStart")),
                parseTimestamp(request.getParameter("scheduledEnd"))
        );
        response.sendRedirect(request.getContextPath() + "/change-request-list/detail?id=" + ticketId + (ok ? "&msg=assessed" : "&msg=assess_failed"));
    }

    private void reviewChangeRequest(HttpServletRequest request, HttpServletResponse response, User loginUser) throws IOException {
        if (loginUser.getRoleId() != ROLE_CAB_MEMBER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ CAB Member mới được duyệt hoặc từ chối.");
            return;
        }
        int ticketId = parseInt(request.getParameter("ticketId"));
        String decision = trim(request.getParameter("decision"));
        boolean approve = "APPROVE".equalsIgnoreCase(decision);
        boolean ok = changeRequestDAO.reviewChangeRequest(ticketId, loginUser.getUserId(), approve, trim(request.getParameter("cabComment")));
        response.sendRedirect(request.getContextPath() + "/change-request-list/detail?id=" + ticketId + (ok ? (approve ? "&msg=approved" : "&msg=rejected") : "&msg=review_failed"));
    }

    private ChangeRequestDetailDTO buildDtoFromRequest(HttpServletRequest request) {
        ChangeRequestDetailDTO dto = new ChangeRequestDetailDTO();
        dto.setTitle(trim(request.getParameter("title")));
        dto.setDescription(trim(request.getParameter("description")));
        dto.setPriority(trim(request.getParameter("priority")));
        dto.setChangeType(trim(request.getParameter("changeType")));
        dto.setRiskLevel(trim(request.getParameter("riskLevel")));
        dto.setImpactAssessment(trim(request.getParameter("impactAssessment")));
        dto.setImplementationPlan(trim(request.getParameter("implementationPlan")));
        dto.setRollbackPlan(trim(request.getParameter("rollbackPlan")));
        dto.setTestPlan(trim(request.getParameter("testPlan")));
        dto.setJustification(trim(request.getParameter("description")));
        dto.setScheduledStart(parseTimestamp(request.getParameter("scheduledStart")));
        dto.setScheduledEnd(parseTimestamp(request.getParameter("scheduledEnd")));
        return dto;
    }

    private boolean canAccess(User user) {
        return user.getRoleId() == ROLE_SYSTEM_ENGINEER || user.getRoleId() == ROLE_CAB_MEMBER || user.getRoleId() == ROLE_MANAGER;
    }

    private int parseInt(String value) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return -1;
        }
    }

    private Timestamp parseTimestamp(String value) {
        try {
            if (value == null || value.trim().isEmpty()) return null;
            return Timestamp.valueOf(value.replace("T", " ") + ":00");
        } catch (Exception e) {
            return null;
        }
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private User getLoggedInUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        return (User) session.getAttribute("user");
    }
}
