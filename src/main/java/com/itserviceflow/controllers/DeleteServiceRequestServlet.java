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

@WebServlet("/ticket/delete-request")
public class DeleteServiceRequestServlet extends HttpServlet {
    private TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Lấy user đăng nhập
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }
        int currentUserId = currentUser.getUserId();

        // 2. Lấy dữ liệu gửi lên
        String action = request.getParameter("action"); // 'single' hoặc 'bulk'
        
        if ("single".equals(action)) {
            // XÓA 1 TICKET (Từ màn hình Detail)
            String ticketIdStr = request.getParameter("ticketId");
            try {
                int ticketId = Integer.parseInt(ticketIdStr);
                boolean isDeleted = ticketDAO.deleteNewServiceRequest(ticketId, currentUserId);
                if (isDeleted) {
                    session.setAttribute("message", "Đã xóa Request #SR-" + ticketId + " thành công!");
                } else {
                    session.setAttribute("error", "Không thể xóa. Request đã được xử lý hoặc không hợp lệ.");
                }
            } catch (NumberFormatException e) {
                session.setAttribute("error", "Lỗi dữ liệu ID.");
            }
        } 
        else if ("bulk".equals(action)) {
            // XÓA NHIỀU TICKET (Từ màn hình List)
            String[] ticketIds = request.getParameterValues("ticketIds");
            if (ticketIds != null && ticketIds.length > 0) {
                int deletedCount = ticketDAO.bulkDeleteNewServiceRequests(ticketIds, currentUserId);
                session.setAttribute("message", "Đã xóa thành công " + deletedCount + " Request!");
            } else {
                session.setAttribute("error", "Vui lòng chọn ít nhất 1 Request để xóa.");
            }
        }

        // 3. Xóa xong luôn luôn quay về trang List
        response.sendRedirect(request.getContextPath() + "/ticket/service-request-list");
    }
}