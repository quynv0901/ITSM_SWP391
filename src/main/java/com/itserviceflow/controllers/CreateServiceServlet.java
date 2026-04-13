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
@WebServlet("/admin/create-service")
public class CreateServiceServlet extends HttpServlet {
    private ServiceDAO serviceDAO = new ServiceDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
       
        request.getRequestDispatcher("/admin/create-service.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String name = request.getParameter("serviceName");
        String code = request.getParameter("serviceCode");
        String desc = request.getParameter("description");
        int delivery = Integer.parseInt(request.getParameter("deliveryDay"));

        Service newSvc = new Service();
        newSvc.setServiceName(name);
        newSvc.setServiceCode(code);
        newSvc.setDescription(desc);
        newSvc.setEstimatedDeliveryDay(delivery);

        if (serviceDAO.createService(newSvc)) {
            response.sendRedirect(request.getContextPath() + "/admin/service-management?status=success");
        } else {
            request.setAttribute("error", "Could not create service. Please check Duplicate Code.");
            request.getRequestDispatcher("/admin/create-service.jsp").forward(request, response);
        }
    }
}