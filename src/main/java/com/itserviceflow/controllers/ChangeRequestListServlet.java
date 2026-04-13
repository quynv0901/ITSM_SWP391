package com.itserviceflow.controllers;

import com.itserviceflow.daos.TicketDAO;
import com.itserviceflow.models.Ticket;
import com.itserviceflow.models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/change-request/list")
public class ChangeRequestListServlet extends HttpServlet {
    private TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        // Phân quyền: End-user (Role 1) thường không xem Change Request
        if (currentUser == null || currentUser.getRoleId() == 1) { 
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập Change Management.");
            return;
        }

        String search = request.getParameter("search");
        String statusFilter = request.getParameter("statusFilter");

        // Gọi DAO lấy danh sách Change Request
        List<Ticket> crList = ticketDAO.getChangeRequestList(search, statusFilter);

        request.setAttribute("crList", crList);
        request.setAttribute("search", search);
        request.setAttribute("statusFilter", statusFilter);

        request.getRequestDispatcher("/ticket/change-request-list.jsp").forward(request, response);
    }
}