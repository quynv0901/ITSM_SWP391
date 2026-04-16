package com.itserviceflow.controllers;

import com.itserviceflow.daos.KnownErrorDAO;
import com.itserviceflow.models.Article;
import com.itserviceflow.models.User;
import com.itserviceflow.utils.AuthUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/known-error")
public class KnownErrorController extends HttpServlet {

    private KnownErrorDAO knownErrorDAO;

    @Override
    public void init() throws ServletException {
        knownErrorDAO = new KnownErrorDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        if (!AuthUtils.isLoggedIn(request, response)) {
            return;
        }

        User currentUser = AuthUtils.getCurrentUser(request);
        request.setAttribute("currentUser", currentUser);

        switch (action) {
            case "list":
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_SUPPORT_AGENT, AuthUtils.ROLE_TECHNICAL_EXPERT,
                        AuthUtils.ROLE_MANAGER, AuthUtils.ROLE_IT_DIRECTOR, AuthUtils.ROLE_ADMIN)) {
                    return;
                }
                listKnownErrors(request, response);
                break;
            case "detail":
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_SUPPORT_AGENT, AuthUtils.ROLE_TECHNICAL_EXPERT,
                        AuthUtils.ROLE_MANAGER, AuthUtils.ROLE_IT_DIRECTOR, AuthUtils.ROLE_ADMIN)) {
                    return;
                }
                viewKnownErrorDetail(request, response);
                break;
            case "add":
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_TECHNICAL_EXPERT, AuthUtils.ROLE_MANAGER,
                        AuthUtils.ROLE_ADMIN)) {
                    return;
                }
                showKnownErrorForm(request, response);
                break;
            case "edit":
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_TECHNICAL_EXPERT, AuthUtils.ROLE_MANAGER,
                        AuthUtils.ROLE_ADMIN)) {
                    return;
                }
                showEditForm(request, response);
                break;
            default:
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_SUPPORT_AGENT, AuthUtils.ROLE_TECHNICAL_EXPERT,
                        AuthUtils.ROLE_MANAGER, AuthUtils.ROLE_IT_DIRECTOR, AuthUtils.ROLE_ADMIN)) {
                    return;
                }
                listKnownErrors(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/known-error?action=list");
            return;
        }

        if (!AuthUtils.isLoggedIn(request, response)) {
            return;
        }

        switch (action) {
            case "insert":
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_TECHNICAL_EXPERT, AuthUtils.ROLE_MANAGER,
                        AuthUtils.ROLE_ADMIN)) {
                    return;
                }
                insertKnownError(request, response);
                break;
            case "update":
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_TECHNICAL_EXPERT, AuthUtils.ROLE_MANAGER,
                        AuthUtils.ROLE_ADMIN)) {
                    return;
                }
                updateKnownError(request, response);
                break;
            case "delete":
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_TECHNICAL_EXPERT, AuthUtils.ROLE_MANAGER,
                        AuthUtils.ROLE_ADMIN)) {
                    return;
                }
                deleteKnownError(request, response);
                break;
            case "bulkDelete":
                if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_TECHNICAL_EXPERT, AuthUtils.ROLE_MANAGER,
                        AuthUtils.ROLE_ADMIN)) {
                    return;
                }
                bulkDeleteKnownError(request, response);
                break;
            case "review":
                reviewKnownError(request, response);
                break;
            case "bulkReview":
                bulkReviewKnownError(request, response);
                break;
            case "toggleStatus":
                toggleKnownErrorStatus(request, response);
                break;
            case "bulkToggleStatus":
                bulkToggleKnownErrorStatus(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/known-error?action=list");
                break;
        }
    }

    private void listKnownErrors(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("searchQuery");
        String statusFilter = request.getParameter("statusFilter");

        int page = 1;
        int pageSize = 5;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        int offset = (page - 1) * pageSize;

        int totalRecords = knownErrorDAO.getTotalKnownErrors(keyword, statusFilter);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);

        List<Article> errors = knownErrorDAO.searchKnownErrors(keyword, statusFilter, offset, pageSize);

        request.setAttribute("knownErrors", errors);
        request.setAttribute("searchQuery", keyword);
        request.setAttribute("statusFilter", statusFilter != null ? statusFilter : "ALL");
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.getRequestDispatcher("/known-error/list.jsp").forward(request, response);
    }

    private void viewKnownErrorDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Article ke = knownErrorDAO.getKnownErrorById(id);
        request.setAttribute("knownError", ke);
        request.getRequestDispatcher("/known-error/detail.jsp").forward(request, response);
    }

    private void showKnownErrorForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/known-error/form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Article ke = knownErrorDAO.getKnownErrorById(id);
        User currentUser = AuthUtils.getCurrentUser(request);

        if (currentUser.getRoleId() == AuthUtils.ROLE_TECHNICAL_EXPERT && ke.getAuthorId() != currentUser.getUserId()) {
            response.sendRedirect(request.getContextPath() + "/auth?action=forbid");
            return;
        }

        request.setAttribute("knownError", ke);
        request.getRequestDispatcher("/known-error/form.jsp").forward(request, response);
    }

    private void insertKnownError(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String title = request.getParameter("title");
        String summary = request.getParameter("summary");
        String content = request.getParameter("content");
        String symptom = request.getParameter("symptom");
        String cause = request.getParameter("cause");
        String solution = request.getParameter("solution");

        if (title == null || title.trim().isEmpty() || summary == null || summary.trim().isEmpty() ||
            symptom == null || symptom.trim().isEmpty() || solution == null || solution.trim().isEmpty()) {
            request.getSession().setAttribute("errorMsg", "Vui lòng nhập đầy đủ các trường bắt buộc (Title, Summary, Symptom, Solution) và không chỉ nhập khoảng trắng.");
            response.sendRedirect(request.getContextPath() + "/known-error?action=add");
            return;
        }
        
        if (title.length() > 255 || summary.length() > 500) {
            request.getSession().setAttribute("errorMsg", "Độ dài tiêu đề tối đa 255 ký tự và tóm tắt tối đa 500 ký tự.");
            response.sendRedirect(request.getContextPath() + "/known-error?action=add");
            return;
        }

        Article ke = new Article();
        ke.setTitle(title.trim());
        ke.setSummary(summary.trim());
        ke.setContent(content != null ? content.trim() : "");
        ke.setSymptom(symptom.trim());
        ke.setCause(cause != null ? cause.trim() : "");
        ke.setSolution(solution.trim());

        User user = AuthUtils.getCurrentUser(request);
        ke.setAuthorId(user.getUserId());

        boolean success = knownErrorDAO.createKnownError(ke);
        if (success) {
            request.getSession().setAttribute("message", "Article successfully published.");
        } else {
            request.getSession().setAttribute("errorMsg", "Failed to publish article. Please make sure Title (< 255 chars) and Summary (< 500 chars) are not too long.");
        }
        response.sendRedirect(request.getContextPath() + "/known-error?action=list");
    }

    private void updateKnownError(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String title = request.getParameter("title");
        String summary = request.getParameter("summary");
        String content = request.getParameter("content");
        String symptom = request.getParameter("symptom");
        String cause = request.getParameter("cause");
        String solution = request.getParameter("solution");

        if (title == null || title.trim().isEmpty() || summary == null || summary.trim().isEmpty() ||
            symptom == null || symptom.trim().isEmpty() || solution == null || solution.trim().isEmpty()) {
            request.getSession().setAttribute("errorMsg", "Vui lòng nhập đầy đủ các trường bắt buộc (Title, Summary, Symptom, Solution) và không chỉ nhập khoảng trắng.");
            response.sendRedirect(request.getContextPath() + "/known-error?action=edit&id=" + id);
            return;
        }
        
        if (title.length() > 255 || summary.length() > 500) {
            request.getSession().setAttribute("errorMsg", "Độ dài tiêu đề tối đa 255 ký tự và tóm tắt tối đa 500 ký tự.");
            response.sendRedirect(request.getContextPath() + "/known-error?action=edit&id=" + id);
            return;
        }

        Article ke = new Article();
        ke.setArticleId(id);
        ke.setTitle(title.trim());
        ke.setSummary(summary.trim());
        ke.setContent(content != null ? content.trim() : "");
        ke.setSymptom(symptom.trim());
        ke.setCause(cause != null ? cause.trim() : "");
        ke.setSolution(solution.trim());

        User currentUser = AuthUtils.getCurrentUser(request);
        Article original = knownErrorDAO.getKnownErrorById(id);

        if (currentUser.getRoleId() == AuthUtils.ROLE_TECHNICAL_EXPERT && original.getAuthorId() != currentUser.getUserId()) {
            response.sendRedirect(request.getContextPath() + "/auth?action=forbid");
            return;
        }

        boolean success = knownErrorDAO.updateKnownError(ke);
        if (success) {
            request.getSession().setAttribute("message", "Article successfully updated.");
            response.sendRedirect(request.getContextPath() + "/known-error?action=detail&id=" + id);
        } else {
            request.getSession().setAttribute("errorMsg", "Failed to update article. Please make sure Title (< 255 chars) and Summary (< 500 chars) are not too long.");
            response.sendRedirect(request.getContextPath() + "/known-error?action=edit&id=" + id);
        }
    }

    private void deleteKnownError(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Article ke = knownErrorDAO.getKnownErrorById(id);
        User user = AuthUtils.getCurrentUser(request);
        if (ke != null && ("PENDING".equals(ke.getStatus()) || "REJECTED".equals(ke.getStatus()))) {
            if (ke.getAuthorId() == user.getUserId() || user.getRoleId() == AuthUtils.ROLE_ADMIN || user.getRoleId() == AuthUtils.ROLE_MANAGER) {
                knownErrorDAO.deleteKnownError(id);
            }
        }
        response.sendRedirect(request.getContextPath() + "/known-error?action=list");
    }

    private void bulkDeleteKnownError(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String[] ids = request.getParameterValues("selectedIds");
        User user = AuthUtils.getCurrentUser(request);
        int successCount = 0;
        int failCount = 0;

        if (ids != null) {
            for (String idStr : ids) {
                try {
                    int id = Integer.parseInt(idStr);
                    Article ke = knownErrorDAO.getKnownErrorById(id);
                    if (ke != null && ("PENDING".equals(ke.getStatus()) || "REJECTED".equals(ke.getStatus()))) {
                        if (ke.getAuthorId() == user.getUserId() || user.getRoleId() == AuthUtils.ROLE_ADMIN || user.getRoleId() == AuthUtils.ROLE_MANAGER) {
                            boolean deleted = knownErrorDAO.deleteKnownError(id);
                            if (deleted) {
                                successCount++;
                            } else {
                                failCount++;
                            }
                        } else {
                            failCount++;
                        }
                    } else {
                        failCount++;
                    }
                } catch (NumberFormatException ignored) {
                }
            }
        }
        request.getSession().setAttribute("message", "Bulk Delete execution complete. Success: " + successCount + ". Skipped: " + failCount + " (Rule: Must be PENDING/REJECTED and owned by you, or you must be Admin/Manager).");
        response.sendRedirect(request.getContextPath() + "/known-error?action=list");
    }

    private void reviewKnownError(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_ADMIN, AuthUtils.ROLE_MANAGER)) {
            return;
        }

        int id = Integer.parseInt(request.getParameter("id"));
        String status = request.getParameter("status");
        String rejectionReason = request.getParameter("rejectionReason");

        User user = AuthUtils.getCurrentUser(request);
        Article ke = knownErrorDAO.getKnownErrorById(id);

        if (ke != null && "PENDING".equals(ke.getStatus())) {
            knownErrorDAO.reviewKnownError(id, status, user.getUserId(), rejectionReason);
            request.getSession().setAttribute("message", "Successfully reviewed Known Error document.");
        } else {
            request.getSession().setAttribute("errorMsg", "Can only review PENDING documents.");
        }

        response.sendRedirect(request.getContextPath() + "/known-error?action=detail&id=" + id);
    }

    private void bulkReviewKnownError(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_ADMIN, AuthUtils.ROLE_MANAGER)) {
            return;
        }

        String[] ids = request.getParameterValues("selectedIds");
        String status = request.getParameter("status");
        String rejectionReason = "Bulk reviewed";
        User user = AuthUtils.getCurrentUser(request);
        int successCount = 0;
        int failCount = 0;

        if (ids != null && status != null) {
            for (String idStr : ids) {
                try {
                    int id = Integer.parseInt(idStr);
                    Article ke = knownErrorDAO.getKnownErrorById(id);
                    if (ke != null && "PENDING".equals(ke.getStatus())) {
                        boolean reviewed = knownErrorDAO.reviewKnownError(id, status, user.getUserId(), rejectionReason);
                        if (reviewed) {
                            successCount++;
                        } else {
                            failCount++;
                        }
                    } else {
                        failCount++;
                    }
                } catch (NumberFormatException ignored) {
                }
            }
        }
        request.getSession().setAttribute("message", "Bulk Review execution complete. Success: " + successCount + ". Skipped: " + failCount + " (Rule: Document must be in PENDING state).");
        response.sendRedirect(request.getContextPath() + "/known-error?action=list");
    }

    private void toggleKnownErrorStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_ADMIN, AuthUtils.ROLE_MANAGER)) {
            return;
        }
        int id = Integer.parseInt(request.getParameter("id"));
        String currentStatus = request.getParameter("currentStatus");
        Article ke = knownErrorDAO.getKnownErrorById(id);
        if (ke != null && ("APPROVED".equals(ke.getStatus()) || "INACTIVE".equals(ke.getStatus()))) {
            knownErrorDAO.toggleKnownErrorStatus(id, currentStatus);
        }
        response.sendRedirect(request.getContextPath() + "/known-error?action=list");
    }

    private void bulkToggleKnownErrorStatus(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_ADMIN, AuthUtils.ROLE_MANAGER)) {
            return;
        }

        String[] ids = request.getParameterValues("selectedIds");
        String toggleTo = request.getParameter("toggleTo");
        int successCount = 0;
        int failCount = 0;

        if (ids != null && toggleTo != null) {
            for (String idStr : ids) {
                try {
                    int id = Integer.parseInt(idStr);
                    Article ke = knownErrorDAO.getKnownErrorById(id);
                    if (ke != null && ("APPROVED".equals(ke.getStatus()) || "INACTIVE".equals(ke.getStatus()))) {
                        String mockCurrentStatus = toggleTo.equals("INACTIVE") ? "APPROVED" : "INACTIVE";
                        boolean toggled = knownErrorDAO.toggleKnownErrorStatus(id, mockCurrentStatus);
                        if (toggled) {
                            successCount++;
                        } else {
                            failCount++;
                        }
                    } else {
                        failCount++;
                    }
                } catch (NumberFormatException ignored) {
                }
            }
        }
        request.getSession().setAttribute("message", "Bulk Status Update execution complete. Successfully updated: " + successCount + ". Skipped: " + failCount + " (Rule: Can only toggle APPROVED and INACTIVE articles).");
        response.sendRedirect(request.getContextPath() + "/known-error?action=list");
    }
}
