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

@WebServlet("/change-request/delete")
public class DeleteChangeRequestServlet extends HttpServlet {
    private TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        // Chỉ System Engineer (Role 6) hoặc Admin/Manager mới được phép xóa
        if (currentUser == null || currentUser.getRoleId() == 1 || currentUser.getRoleId() == 2) { 
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền xóa Change Request.");
            return;
        }

        String actionType = request.getParameter("actionType");

        // XÓA 1 RECORD (Từ trang Detail)
        if ("single".equals(actionType)) {
            String idStr = request.getParameter("ticketId");
            try {
                int ticketId = Integer.parseInt(idStr);
                boolean success = ticketDAO.deleteChangeRequest(ticketId);
                if (success) {
                    session.setAttribute("message", "Đã xóa Change Request #CR-" + ticketId + " thành công!");
                } else {
                    session.setAttribute("error", "Không thể xóa. Phiếu này không còn ở trạng thái NEW hoặc đã được CAB đánh giá.");
                }
            } catch (NumberFormatException e) {
                session.setAttribute("error", "Lỗi dữ liệu đầu vào.");
            }
        } 
        // XÓA HÀNG LOẠT (Từ trang List)
        else if ("bulk".equals(actionType)) {
            String[] ticketIds = request.getParameterValues("ticketIds");
            if (ticketIds != null && ticketIds.length > 0) {
                int count = ticketDAO.bulkDeleteChangeRequests(ticketIds);
                session.setAttribute("message", "Đã xóa vĩnh viễn " + count + " Change Request thành công!");
            } else {
                session.setAttribute("error", "Vui lòng chọn ít nhất 1 Change Request hợp lệ để xóa.");
            }
        }

        // Xóa xong thì quay về trang List
        response.sendRedirect(request.getContextPath() + "/change-request/list");
    }
}