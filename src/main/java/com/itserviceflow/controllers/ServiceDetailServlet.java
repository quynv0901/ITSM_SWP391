/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.itserviceflow.controllers;

import com.itserviceflow.daos.ServiceDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import com.itserviceflow.models.Service;

/**
 *
 * @author ADMIN
 */
@WebServlet("/service/service-detail")
public class ServiceDetailServlet extends HttpServlet {
    private ServiceDAO serviceDAO = new ServiceDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam != null) {
            int serviceId = Integer.parseInt(idParam);
            Service service = serviceDAO.getServiceById(serviceId);
            
            if (service != null) {
                request.setAttribute("service", service);
                request.getRequestDispatcher("/service/service-detail.jsp").forward(request, response);
                return;
            }
        }
        response.sendRedirect("service-catalog");
    }
}
