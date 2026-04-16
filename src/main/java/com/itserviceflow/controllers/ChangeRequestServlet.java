package com.itserviceflow.controllers;

import com.itserviceflow.daos.ChangeRequestDAO;
import com.itserviceflow.dtos.ChangeRequestDTO;
import com.itserviceflow.models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "ChangeRequestServlet", urlPatterns = {"/change-request"})
public class ChangeRequestServlet extends HttpServlet {

    private static final int ROLE_CAB_MEMBER = 7;

    private ChangeRequestDAO changeRequestDAO;

    @Override
    public void init() throws ServletException {
        changeRequestDAO = new ChangeRequestDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "list";
        }

        switch (action) {
            case "detail":
                showDetail(request, response);
                break;
            case "list":
            default:
                showList(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "list";
        }

        switch (action) {
            case "assess":
                assessRisk(request, response);
                break;
            case "reviewSingle":
                reviewSingle(request, response);
                break;
            case "reviewBulk":
                reviewBulk(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/change-request?action=list");
                break;
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String search = request.getParameter("search");
        String statusFilter = request.getParameter("statusFilter");

        if (search == null) {
            search = "";
        }
        if (statusFilter == null) {
            statusFilter = "";
        }

        List<ChangeRequestDTO> crList = changeRequestDAO.getAllChangeRequests(search, statusFilter);

        request.setAttribute("crList", crList);
        request.setAttribute("search", search);
        request.setAttribute("statusFilter", statusFilter);

        request.getRequestDispatcher("/ticket/change-request-list.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idRaw = request.getParameter("id");

        if (idRaw == null || idRaw.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/change-request?action=list");
            return;
        }

        try {
            int ticketId = Integer.parseInt(idRaw);
            ChangeRequestDTO ticket = changeRequestDAO.getChangeRequestById(ticketId);

            if (ticket == null) {
                response.sendRedirect(request.getContextPath() + "/change-request?action=list&msg=not_found");
                return;
            }

            request.setAttribute("ticket", ticket);

            // Nếu bạn có commentDAO hoặc engineer list thì set thêm ở đây
            // request.setAttribute("comments", ...);
            // request.setAttribute("engineerList", ...);

            request.getRequestDispatcher("/ticket/change-request-detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/change-request?action=list&msg=invalid_id");
        }
    }

    private void assessRisk(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        User loginUser = getLoggedInUser(request);
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (loginUser.getRoleId() != ROLE_CAB_MEMBER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
            return;
        }

        String ticketIdRaw = request.getParameter("ticketId");
        String cabRiskAssessment = request.getParameter("cabRiskAssessment");
        String cabComment = request.getParameter("cabComment");

        if (ticketIdRaw == null || ticketIdRaw.trim().isEmpty()
                || cabRiskAssessment == null || cabRiskAssessment.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/change-request?action=list&msg=invalid_input");
            return;
        }

        try {
            int ticketId = Integer.parseInt(ticketIdRaw);

            boolean success = changeRequestDAO.assessChangeRisk(
                    ticketId,
                    loginUser.getUserId(),
                    cabRiskAssessment.trim(),
                    cabComment != null ? cabComment.trim() : ""
            );

            if (success) {
                response.sendRedirect(request.getContextPath()
                        + "/change-request?action=detail&id=" + ticketId + "&msg=assessed");
            } else {
                response.sendRedirect(request.getContextPath()
                        + "/change-request?action=detail&id=" + ticketId + "&msg=assess_failed");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/change-request?action=list&msg=invalid_id");
        }
    }

    private void reviewSingle(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        User loginUser = getLoggedInUser(request);
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (loginUser.getRoleId() != ROLE_CAB_MEMBER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
            return;
        }

        String ticketIdRaw = request.getParameter("ticketId");
        String decision = request.getParameter("decision");

        if (ticketIdRaw == null || ticketIdRaw.trim().isEmpty()
                || (!"APPROVED".equals(decision) && !"REJECTED".equals(decision))) {
            response.sendRedirect(request.getContextPath() + "/change-request?action=list&msg=invalid_input");
            return;
        }

        try {
            int ticketId = Integer.parseInt(ticketIdRaw);

            boolean success = changeRequestDAO.reviewChangeRequest(
                    ticketId,
                    loginUser.getUserId(),
                    decision
            );

            if (success) {
                response.sendRedirect(request.getContextPath()
                        + "/change-request?action=detail&id=" + ticketId + "&msg=review_success");
            } else {
                response.sendRedirect(request.getContextPath()
                        + "/change-request?action=detail&id=" + ticketId + "&msg=review_failed");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/change-request?action=list&msg=invalid_id");
        }
    }

    private void reviewBulk(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        User loginUser = getLoggedInUser(request);
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (loginUser.getRoleId() != ROLE_CAB_MEMBER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
            return;
        }

        String[] ticketIds = request.getParameterValues("ticketIds");
        String decision = request.getParameter("decision");

        if (ticketIds == null || ticketIds.length == 0
                || (!"APPROVED".equals(decision) && !"REJECTED".equals(decision))) {
            response.sendRedirect(request.getContextPath() + "/change-request?action=list&msg=invalid_input");
            return;
        }

        int updatedCount = changeRequestDAO.bulkReviewChangeRequests(
                ticketIds,
                loginUser.getUserId(),
                decision
        );

        response.sendRedirect(request.getContextPath()
                + "/change-request?action=list&msg=bulk_review_success&count=" + updatedCount);
    }

    private User getLoggedInUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        return (User) session.getAttribute("user");
    }
}