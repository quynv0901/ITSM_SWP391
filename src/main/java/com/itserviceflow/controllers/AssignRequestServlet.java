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

@WebServlet("/ticket/assign-request")
public class AssignRequestServlet extends HttpServlet {
    private TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Kiểm tra đăng nhập
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        // 2. Lấy dữ liệu từ Form Assign
        String ticketIdStr = request.getParameter("ticketId");
        String assignToStr = request.getParameter("assignedTo");

        if (ticketIdStr != null && assignToStr != null && !assignToStr.isEmpty()) {
            try {
                int ticketId = Integer.parseInt(ticketIdStr);
                int assignedTo = Integer.parseInt(assignToStr);

                // 3. Gọi DAO để Assign
                boolean isAssigned = ticketDAO.assignServiceRequest(ticketId, assignedTo);
                
                if (isAssigned) {
                    session.setAttribute("message", "Đã phân công Request #SR-" + ticketId + " thành công!");
                } else {
                    session.setAttribute("error", "Lỗi: Không thể phân công Request này.");
                }
                
                // Quay lại trang Detail để xem kết quả
                response.sendRedirect(request.getContextPath() + "/request-detail?id=" + ticketId);
                return;

            } catch (NumberFormatException e) {
                session.setAttribute("error", "Lỗi dữ liệu ID.");
            }
        } else {
            session.setAttribute("error", "Vui lòng chọn một Agent để phân công.");
        }
        
        // Trở về trang trước đó nếu có lỗi
        response.sendRedirect(request.getContextPath() + "/request-detail?id=" + request.getParameter("ticketId"));
    }
}