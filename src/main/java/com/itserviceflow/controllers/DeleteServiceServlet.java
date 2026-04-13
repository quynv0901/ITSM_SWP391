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

/**
 *
 * @author ADMIN
 */
@WebServlet("/admin/delete-service")
public class DeleteServiceServlet extends HttpServlet {
    private ServiceDAO serviceDAO = new ServiceDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String[] ids = request.getParameterValues("serviceIds");
        int successCount = 0;
        int failCount = 0;

        if (ids != null) {
            for (String id : ids) {
                String result = serviceDAO.deleteService(Integer.parseInt(id));
                if (result.equals("success")) successCount++;
                else failCount++;
            }
        }

        // Chuyển hướng về catalog kèm thông báo
        String msg = "Deleted " + successCount + " services.";
        if (failCount > 0) msg += " " + failCount + " items failed due to existing requests.";
        
        request.getSession().setAttribute("message", msg);
        response.sendRedirect(request.getContextPath() + "/admin/service-management?msg=success");
    }
}
