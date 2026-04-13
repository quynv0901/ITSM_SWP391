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

@WebServlet("/change-request/review")
public class ReviewChangeRequestServlet extends HttpServlet {
    private TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        // Phân quyền: CAB Member (Role 7) hoặc Admin (10)
        if (currentUser == null || (currentUser.getRoleId() != 7 && currentUser.getRoleId() != 10)) { 
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ CAB Member mới có quyền ra Quyết định.");
            return;
        }

        String actionType = request.getParameter("actionType");
        String decision = request.getParameter("decision"); // Nhận giá trị APPROVED hoặc REJECTED

        if ("single".equals(actionType)) {
            String idStr = request.getParameter("ticketId");
            try {
                int ticketId = Integer.parseInt(idStr);
                boolean success = ticketDAO.reviewChangeRequest(ticketId, currentUser.getUserId(), decision);
                if (success) {
                    session.setAttribute("message", "Đã " + decision + " phiếu Change Request #CR-" + ticketId);
                } else {
                    session.setAttribute("error", "Lỗi: Không thể thực hiện đánh giá.");
                }
                response.sendRedirect(request.getContextPath() + "/change-request/detail?id=" + ticketId);
                return;
            } catch (NumberFormatException e) {
                session.setAttribute("error", "Lỗi ID dữ liệu.");
            }
        } 
        else if ("bulk".equals(actionType)) {
            String[] ticketIds = request.getParameterValues("ticketIds");
            if (ticketIds != null && ticketIds.length > 0) {
                int count = ticketDAO.bulkReviewChangeRequests(ticketIds, currentUser.getUserId(), decision);
                session.setAttribute("message", "Đã " + decision + " thành công " + count + " Change Request!");
            } else {
                session.setAttribute("error", "Vui lòng chọn ít nhất 1 Change Request hợp lệ.");
            }
        }
        
        response.sendRedirect(request.getContextPath() + "/change-request/list");
    }
}