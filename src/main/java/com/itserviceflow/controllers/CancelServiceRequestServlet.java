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

@WebServlet("/ticket/cancel-request")
public class CancelServiceRequestServlet extends HttpServlet {
    private TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Kiểm tra bảo mật (Bắt buộc phải đăng nhập)
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        // 2. Lấy ID của Ticket cần Hủy
        String ticketIdStr = request.getParameter("ticketId");
        
        if (ticketIdStr != null && !ticketIdStr.isEmpty()) {
            try {
                int ticketId = Integer.parseInt(ticketIdStr);
                
                // Gọi DAO để cập nhật trạng thái
                boolean isCancelled = ticketDAO.cancelServiceRequest(ticketId);
                
                if (isCancelled) {
                    session.setAttribute("message", "Đã hủy (Cancel) Request #SR-" + ticketId + " thành công!");
                } else {
                    session.setAttribute("error", "Không thể hủy Request này. Vui lòng thử lại.");
                }
                
                // 3. Hủy xong thì quay lại chính trang Detail đó để xem kết quả
                response.sendRedirect(request.getContextPath() + "/request-detail?id=" + ticketId);
                return;
                
            } catch (NumberFormatException e) {
                session.setAttribute("error", "Lỗi dữ liệu ID.");
            }
        }
        
        // Trở về danh sách nếu có lỗi ID
        response.sendRedirect(request.getContextPath() + "/ticket/service-request-list");
    }
}