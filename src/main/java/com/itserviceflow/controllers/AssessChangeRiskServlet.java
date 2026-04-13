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

@WebServlet("/change-request/assess")
public class AssessChangeRiskServlet extends HttpServlet {
    private TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        // Phân quyền: Chỉ CAB Member (Role 7) mới được đánh giá rủi ro
        if (currentUser == null || currentUser.getRoleId() != 7) { 
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ CAB Member mới có quyền Đánh giá Rủi ro.");
            return;
        }

        try {
            int ticketId = Integer.parseInt(request.getParameter("ticketId"));
            String riskAssessment = request.getParameter("cabRiskAssessment");
            String comment = request.getParameter("cabComment");

            boolean success = ticketDAO.assessChangeRisk(ticketId, currentUser.getUserId(), riskAssessment, comment);

            if (success) {
                session.setAttribute("message", "Đã lưu Đánh giá Rủi ro thành công!");
            } else {
                session.setAttribute("error", "Lỗi: Không thể lưu đánh giá.");
            }
            response.sendRedirect(request.getContextPath() + "/change-request/detail?id=" + ticketId);
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Lỗi ID dữ liệu.");
            response.sendRedirect(request.getContextPath() + "/change-request/list");
        }
    }
}