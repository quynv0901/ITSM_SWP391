package com.itserviceflow.controllers;

import com.itserviceflow.daos.ConfigurationItemDAO;
import com.itserviceflow.models.ConfigurationItem;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "ConfigurationItemController", urlPatterns = {"/configuration-item"})
public class ConfigurationItemController extends HttpServlet {

    private ConfigurationItemDAO ciDAO = new ConfigurationItemDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "add":
                request.getRequestDispatcher("/cmdb/form.jsp").forward(request, response);
                break;
            case "edit":
                int editId = Integer.parseInt(request.getParameter("id"));
                ConfigurationItem ciToEdit = ciDAO.getConfigurationItemById(editId);
                request.setAttribute("ci", ciToEdit);
                request.getRequestDispatcher("/cmdb/form.jsp").forward(request, response);
                break;
            case "list":
            default:
                String keyword = request.getParameter("q");
                String status = request.getParameter("status");
                List<ConfigurationItem> list = ciDAO.getAllConfigurationItems(keyword, status);
                request.setAttribute("ciList", list);
                request.setAttribute("q", keyword);
                request.setAttribute("status", status);
                request.getRequestDispatcher("/cmdb/list.jsp").forward(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if (action == null) {
            action = "add"; 
        }

        switch (action) {
            case "add":
                ConfigurationItem newCi = new ConfigurationItem();
                newCi.setName(request.getParameter("name"));
                newCi.setType(request.getParameter("type"));
                newCi.setVersion(request.getParameter("version"));
                newCi.setDescription(request.getParameter("description"));
                newCi.setStatus(request.getParameter("status"));
                boolean addSuccess = ciDAO.createConfigurationItem(newCi);
                if (addSuccess) {
                    request.getSession().setAttribute("successMessage", "Configuration Item added successfully!");
                } else {
                    request.getSession().setAttribute("errorMessage", "Failed to add Configuration Item.");
                }
                response.sendRedirect(request.getContextPath() + "/configuration-item");
                break;
                
            case "edit":
                int idToUpdate = Integer.parseInt(request.getParameter("id"));
                ConfigurationItem updateCi = new ConfigurationItem();
                updateCi.setCiId(idToUpdate);
                updateCi.setName(request.getParameter("name"));
                updateCi.setType(request.getParameter("type"));
                updateCi.setVersion(request.getParameter("version"));
                updateCi.setDescription(request.getParameter("description"));
                updateCi.setStatus(request.getParameter("status"));
                boolean updateSuccess = ciDAO.updateConfigurationItem(updateCi);
                if (updateSuccess) {
                    request.getSession().setAttribute("successMessage", "Configuration Item updated successfully!");
                } else {
                    request.getSession().setAttribute("errorMessage", "Failed to update Configuration Item.");
                }
                response.sendRedirect(request.getContextPath() + "/configuration-item");
                break;
                
            case "delete":
                int idToDelete = Integer.parseInt(request.getParameter("id"));
                boolean deleteSuccess = ciDAO.deleteConfigurationItem(idToDelete);
                if (deleteSuccess) {
                    request.getSession().setAttribute("successMessage", "Configuration Item deleted successfully!");
                } else {
                    request.getSession().setAttribute("errorMessage", "Failed to delete Configuration Item.");
                }
                response.sendRedirect(request.getContextPath() + "/configuration-item");
                break;
        }
    }
}
