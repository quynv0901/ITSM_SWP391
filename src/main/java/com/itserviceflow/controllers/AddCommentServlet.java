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

@WebServlet("/ticket/add-comment")
public class AddCommentServlet extends HttpServlet {
    private TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        String ticketIdStr = request.getParameter("ticketId");
        String commentText = request.getParameter("commentText");

        if (ticketIdStr != null && commentText != null && !commentText.trim().isEmpty()) {
            try {
                int ticketId = Integer.parseInt(ticketIdStr);
                
                // Gọi DAO để thêm bình luận
                ticketDAO.addComment(ticketId, currentUser.getUserId(), commentText.trim());
                
                // ĐÃ SỬA: Đọc biến ticketType gửi từ Form để rẽ nhánh Redirect
                String ticketType = request.getParameter("ticketType");
                String redirectUrl = "/request-detail?id=" + ticketId; // Mặc định
                
                if ("CHANGE".equals(ticketType)) {
                    redirectUrl = "/change-request/detail?id=" + ticketId;
                }
                
                response.sendRedirect(request.getContextPath() + redirectUrl);
                return;
            } catch (NumberFormatException e) {
                session.setAttribute("error", "Lỗi dữ liệu.");
            }
        } else {
            session.setAttribute("error", "Bình luận không được để trống.");
        }
        
        response.sendRedirect(request.getContextPath() + "/request-detail?id=" + request.getParameter("ticketId"));
    }
}