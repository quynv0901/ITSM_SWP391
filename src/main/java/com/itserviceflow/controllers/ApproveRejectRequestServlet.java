package com.itserviceflow.controllers;

import com.itserviceflow.daos.TicketDAO;
import com.itserviceflow.models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/ticket/approve-reject")
public class ApproveRejectRequestServlet extends HttpServlet {
    private TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null || currentUser.getRoleId() != 3) { 
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ Manager mới được duyệt.");
            return;
        }

        String actionType = request.getParameter("actionType"); 
        String newStatus = request.getParameter("newStatus"); 

        if ("single".equals(actionType)) {
            // Xử lý duyệt 1 cái (từ màn Detail)
            String ticketIdStr = request.getParameter("ticketId");
            try {
                int ticketId = Integer.parseInt(ticketIdStr);
                boolean success = ticketDAO.updateTicketStatus(ticketId, newStatus);
                if (success) {
                    session.setAttribute("message", "Đã " + newStatus + " Request #SR-" + ticketId + " thành công!");
                } else {
                    session.setAttribute("error", "Có lỗi xảy ra, không thể cập nhật.");
                }
                response.sendRedirect(request.getContextPath() + "/request-detail?id=" + ticketId);
                return;
            } catch (NumberFormatException e) {
                session.setAttribute("error", "Lỗi ID.");
            }
            
        } else if ("bulk".equals(actionType)) {
            // Xử lý duyệt hàng loạt (từ màn List)
            String[] ticketIds = request.getParameterValues("ticketIds");
            if (ticketIds != null && ticketIds.length > 0) {
                int count = ticketDAO.bulkUpdateTicketStatus(ticketIds, newStatus);
                session.setAttribute("message", "Đã " + newStatus + " thành công " + count + " Request!");
            } else {
                session.setAttribute("error", "Vui lòng chọn ít nhất 1 Request để thực hiện.");
            }
            response.sendRedirect(request.getContextPath() + "/ticket/service-request-list");
            return;
        }
        
        response.sendRedirect(request.getContextPath() + "/ticket/service-request-list");
    }
}