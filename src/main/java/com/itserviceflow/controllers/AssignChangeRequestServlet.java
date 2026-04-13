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

@WebServlet("/change-request/assign")
public class AssignChangeRequestServlet extends HttpServlet {
    private TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        // Phân quyền: Manager (3), System Engineer (6) hoặc Admin (10)
        if (currentUser == null || (currentUser.getRoleId() != 3 && currentUser.getRoleId() != 6 && currentUser.getRoleId() != 10)) { 
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền phân công Change Request.");
            return;
        }

        try {
            int ticketId = Integer.parseInt(request.getParameter("ticketId"));
            int assignedTo = Integer.parseInt(request.getParameter("assignedTo"));

            // Logic bảo mật: Nếu là System Engineer (6), bắt buộc ID người nhận phải là ID của chính họ
            if (currentUser.getRoleId() == 6 && assignedTo != currentUser.getUserId()) {
                session.setAttribute("error", "System Engineer chỉ được phép tự nhận việc, không được giao cho người khác.");
                response.sendRedirect(request.getContextPath() + "/change-request/detail?id=" + ticketId);
                return;
            }

            boolean success = ticketDAO.assignChangeRequest(ticketId, assignedTo);

            if (success) {
                session.setAttribute("message", "Đã nhận xử lý Change Request thành công!");
            } else {
                session.setAttribute("error", "Lỗi: Không thể nhận phiếu này.");
            }
            response.sendRedirect(request.getContextPath() + "/change-request/detail?id=" + ticketId);
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Lỗi dữ liệu đầu vào.");
            response.sendRedirect(request.getContextPath() + "/change-request/list");
        }
    }
}