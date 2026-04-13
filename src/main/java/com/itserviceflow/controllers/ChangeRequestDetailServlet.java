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

@WebServlet("/change-request/detail")
public class ChangeRequestDetailServlet extends HttpServlet {
    private TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null || currentUser.getRoleId() == 1) { 
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền xem chi tiết Change Request.");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/change-request/list");
            return;
        }

        int ticketId = Integer.parseInt(idParam);
        Ticket ticket = ticketDAO.getChangeRequestDetail(ticketId);

        if (ticket == null) {
            session.setAttribute("error", "Change Request không tồn tại.");
            response.sendRedirect(request.getContextPath() + "/change-request/list");
            return;
        }

        request.setAttribute("ticket", ticket);
        if (currentUser.getRoleId() == 3) {
            java.util.List<User> engineerList = ticketDAO.getSystemEngineers();
            request.setAttribute("engineerList", engineerList);
        }
        
        // UC73: Load danh sách bình luận (Comments)
        java.util.List<com.itserviceflow.models.Comment> comments = ticketDAO.getCommentsByTicketId(ticketId);
        request.setAttribute("comments", comments);
        
        request.getRequestDispatcher("/ticket/change-request-detail.jsp").forward(request, response);
    }
}