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

@WebServlet(name = "ServiceCatalogServlet", urlPatterns = {"/service-catalog"})
public class ServiceCatalogServlet extends HttpServlet {

    private static final int ROLE_END_USER = 1;

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

        if (loginUser.getRoleId() != ROLE_END_USER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "list";
        }

        switch (action) {
            case "detail":
                showDetailPopup(request, response, loginUser);
                break;
            case "list":
            default:
                listActiveServices(request, response, loginUser);
                break;
        }
    }

    private static final int PAGE_SIZE = 8;

    private void listActiveServices(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws ServletException, IOException {

        String keyword = request.getParameter("q");
        if (keyword == null) {
            keyword = "";
        }

        List<Service> fullList = serviceDAO.searchActiveServices(keyword);

        // ===== PAGINATION =====
        int currentPage = 1;
        try {
            currentPage = Integer.parseInt(request.getParameter("page"));
            if (currentPage < 1) {
                currentPage = 1;
            }
        } catch (Exception e) {
            currentPage = 1;
        }

        int totalItems = fullList.size();
        int totalPages = (int) Math.ceil((double) totalItems / PAGE_SIZE);
        if (totalPages == 0) {
            totalPages = 1;
        }

        if (currentPage > totalPages) {
            currentPage = totalPages;
        }

        int fromIndex = (currentPage - 1) * PAGE_SIZE;
        int toIndex = Math.min(fromIndex + PAGE_SIZE, totalItems);

        List<Service> pagedList = fullList.subList(fromIndex, toIndex);

        // ===== SET ATTRIBUTE =====
        request.setAttribute("services", pagedList);
        request.setAttribute("keyword", keyword);
        request.setAttribute("roleId", loginUser.getRoleId());

        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);

        request.getRequestDispatcher("/admin/service-management.jsp").forward(request, response);
    }

    private void showDetailPopup(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws ServletException, IOException {

        String keyword = request.getParameter("q");
        String idRaw = request.getParameter("id");

        if (keyword == null) {
            keyword = "";
        }

        List<Service> services = serviceDAO.searchActiveServices(keyword);
        request.setAttribute("services", services);
        request.setAttribute("keyword", keyword);
        request.setAttribute("roleId", loginUser.getRoleId());

        if (idRaw == null || idRaw.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Invalid service id.");
            request.getRequestDispatcher("/admin/service-management.jsp").forward(request, response);
            return;
        }

        try {
            int serviceId = Integer.parseInt(idRaw);
            Service service = serviceDAO.getActiveServiceById(serviceId);

            if (service == null) {
                request.setAttribute("errorMessage", "Service not found or inactive.");
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

    private User getLoggedInUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        return (User) session.getAttribute("user");
    }
}
