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

/**
 *
 * @author ADMIN
 */
@WebServlet("/admin/update-service")
public class UpdateServiceServlet extends HttpServlet {
    private ServiceDAO serviceDAO = new ServiceDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Service service = serviceDAO.getServiceById(id);
        request.setAttribute("service", service);
        request.getRequestDispatcher("/admin/update-service.jsp").forward(request, response);
    }

    @Override
protected void doPost(HttpServletRequest request, HttpServletResponse response) 
        throws ServletException, IOException {
    try {
        Service service = new Service();
        
        String idParam = request.getParameter("serviceId");
        if (idParam == null || idParam.trim().isEmpty()) {
            idParam = request.getParameter("id");
        }
        service.setServiceId(Integer.parseInt(idParam));
        
        service.setServiceName(request.getParameter("serviceName"));
        service.setServiceCode(request.getParameter("serviceCode"));
        service.setDescription(request.getParameter("description"));
        
        String deliveryParam = request.getParameter("estimatedDeliveryDay");
        service.setEstimatedDeliveryDay(Integer.parseInt(deliveryParam));
        service.setStatus(request.getParameter("status"));

        // --- BƯỚC KIỂM TRA TRÙNG MÃ DỊCH VỤ Ở ĐÂY ---
        if (serviceDAO.checkDuplicateServiceCode(service.getServiceCode(), service.getServiceId())) {
            // Ném thông báo lỗi ra màn hình
            request.setAttribute("error", "Lỗi: Mã dịch vụ '" + service.getServiceCode() + "' đã tồn tại. Vui lòng nhập mã khác!");
            
            // Giữ lại các dữ liệu người dùng vừa nhập để họ không phải gõ lại từ đầu
            request.setAttribute("service", service); 
            request.getRequestDispatcher("/admin/update-service.jsp").forward(request, response);
            return; // DỪNG LẠI, KHÔNG CHẠY LỆNH UPDATE BÊN DƯỚI NỮA
        }
        // -------------------------------------------

        // Nếu qua được vòng kiểm tra trên thì mới Update
        if (serviceDAO.updateService(service)) {
            request.getSession().setAttribute("message", "Update service success!");
            response.sendRedirect(request.getContextPath() + "/admin/service-management");
        } else {
            request.setAttribute("error", "Database Error: Không thể cập nhật dịch vụ này.");
            request.setAttribute("service", service); 
            request.getRequestDispatcher("/admin/update-service.jsp").forward(request, response);
        }
        
    } catch (NumberFormatException e) {
        e.printStackTrace();
        request.setAttribute("error", "Data Error: Thiếu thông tin bắt buộc hoặc định dạng số không hợp lệ.");
        request.getRequestDispatcher("/admin/update-service.jsp").forward(request, response);
    }
}
}
