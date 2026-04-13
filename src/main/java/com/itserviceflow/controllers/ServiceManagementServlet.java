/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.itserviceflow.controllers;

import com.itserviceflow.daos.ServiceDAO;
import com.itserviceflow.models.Service;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 *
 * @author ADMIN
 */
// Trong Controller xử lý cho Admin
@WebServlet("/admin/service-management")
public class ServiceManagementServlet extends HttpServlet {
    private ServiceDAO serviceDAO = new ServiceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String searchQuery = request.getParameter("search");
        if (searchQuery == null) searchQuery = "";
        
        String statusFilter = request.getParameter("statusFilter");
        if (statusFilter == null) statusFilter = "";
        
        List<Service> allServices = serviceDAO.getAllServices(searchQuery, statusFilter); 
        
        // 4. Đẩy dữ liệu lên JSP
        request.setAttribute("allServices", allServices);
        request.setAttribute("lastSearch", searchQuery);
        
        request.getRequestDispatcher("/admin/service-management.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}