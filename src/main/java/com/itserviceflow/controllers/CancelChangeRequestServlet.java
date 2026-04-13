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

@WebServlet("/change-request/cancel")
public class CancelChangeRequestServlet extends HttpServlet {
    private TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        // Phân quyền: Chỉ Manager (Role 3), System Engineer (Role 6) hoặc Admin (10) mới được Hủy
        if (currentUser == null || (currentUser.getRoleId() != 3 && currentUser.getRoleId() != 6 && currentUser.getRoleId() != 10)) { 
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền Hủy Change Request này.");
            return;
        }

        String idStr = request.getParameter("ticketId");
        if (idStr != null && !idStr.isEmpty()) {
            try {
                int ticketId = Integer.parseInt(idStr);
                
                // Gọi DAO để update status
                boolean success = ticketDAO.cancelChangeRequest(ticketId);
                
                if (success) {
                    session.setAttribute("message", "Đã HỦY Change Request #CR-" + ticketId + " thành công!");
                } else {
                    session.setAttribute("error", "Lỗi: Không thể hủy phiếu này.");
                }
            } catch (NumberFormatException e) {
                session.setAttribute("error", "Lỗi ID không hợp lệ.");
            }
        }
        
        // Trở về trang chi tiết để xem sự thay đổi (Status sẽ chuyển thành màu xám nhạt)
        response.sendRedirect(request.getContextPath() + "/change-request/detail?id=" + idStr);
    }
}