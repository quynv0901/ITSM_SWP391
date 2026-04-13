package com.itserviceflow.controllers;

import com.itserviceflow.daos.ServiceDAO;
import com.itserviceflow.daos.TicketDAO;
import com.itserviceflow.models.Service;
import com.itserviceflow.models.Ticket;
import com.itserviceflow.models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/create-request")
public class CreateRequestServlet extends HttpServlet {
    private TicketDAO ticketDAO = new TicketDAO();
    private ServiceDAO serviceDAO = new ServiceDAO();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String serviceIdStr = request.getParameter("serviceId");
        if (serviceIdStr != null && !serviceIdStr.isEmpty()) {
            int serviceId = Integer.parseInt(serviceIdStr);
            
            Service service = serviceDAO.getServiceById(serviceId);
            request.setAttribute("service", service);
        }
        
        request.getRequestDispatcher("/ticket/create-request.jsp").forward(request, response);
    }
    
    @Override
protected void doPost(HttpServletRequest request, HttpServletResponse response) 
        throws ServletException, IOException {
    
    Ticket ticket = new Ticket();
    String serviceIdParam = request.getParameter("serviceId");

    if (serviceIdParam != null && !serviceIdParam.isEmpty()) {
        int serviceId = Integer.parseInt(serviceIdParam);
        ticket.setServiceId(serviceId);
        
        Service service = serviceDAO.getServiceById(serviceId);
        if (service != null) {
            ticket.setTitle("Request for " + service.getServiceName());
        } else {
            ticket.setTitle("Service Request (ID: " + serviceId + ")");
        }
        
    } else {
        response.sendRedirect(request.getContextPath() + "/service-catalog?error=missing_id");
        return;
    }

    ticket.setTicketType("SERVICE_REQUEST"); 
    ticket.setStatus("NEW");
    ticket.setDescription(request.getParameter("description"));
    ticket.setJustification(request.getParameter("justification"));
    ticket.setPriority(request.getParameter("priority"));
    
    // Tạm thời hardcode người tạo (sau này thay bằng Session currentUser)
    // Lấy thông tin User đang đăng nhập từ Session
    jakarta.servlet.http.HttpSession session = request.getSession();
    User currentUser = (User) session.getAttribute("user"); // Đảm bảo dùng đúng chữ "user" như bên màn List
    
    if (currentUser != null) {
        ticket.setReportedBy(currentUser.getUserId());
        // Nếu User model của bạn có getDepartmentId() thì gài vào luôn, không thì tạm để 1
        ticket.setDepartmentId(1); 
    } else {
        // Nếu phiên đăng nhập hết hạn thì đuổi ra màn hình login
        response.sendRedirect(request.getContextPath() + "/auth?action=login");
        return;
    }

    // Lưu vào DB
    if (ticketDAO.createServiceRequest(ticket)) {
       
        Ticket created = ticketDAO.getTicketWithDetails(ticket.getTicketId());
        
        response.sendRedirect(request.getContextPath() + "/ticket/service-request-list?msg=success");
    } else {
       
        if (serviceIdParam != null && !serviceIdParam.isEmpty()) {
            Service service = serviceDAO.getServiceById(Integer.parseInt(serviceIdParam));
            request.setAttribute("service", service);
        }
        request.setAttribute("error", "Database Error: Vui lòng kiểm tra lại log Console.");
        request.getRequestDispatcher("/ticket/create-request.jsp").forward(request, response);
    }
}
}