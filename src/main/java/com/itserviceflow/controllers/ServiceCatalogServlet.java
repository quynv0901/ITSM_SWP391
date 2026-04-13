package com.itserviceflow.controllers;

import com.itserviceflow.daos.ServiceDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import com.itserviceflow.models.Service;

@WebServlet("/service-catalog")
public class ServiceCatalogServlet extends HttpServlet {
    private ServiceDAO serviceDAO = new ServiceDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String searchQuery = request.getParameter("search");
        if (searchQuery == null) searchQuery = "";

        List<Service> listService = serviceDAO.searchServices(searchQuery);
        
        request.setAttribute("listService", listService);
        request.setAttribute("lastSearch", searchQuery);
        request.getRequestDispatcher("/service/service-list.jsp").forward(request, response);
    }
}