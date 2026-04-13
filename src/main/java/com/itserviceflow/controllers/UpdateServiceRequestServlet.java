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

@WebServlet("/update-request")
public class UpdateServiceRequestServlet extends HttpServlet {
    private TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        //Kiểm tra session đăng nhập 
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null || currentUser.getRoleId() == 1) { 
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thực hiện thao tác này.");
            return;
        }
        int currentUserId = currentUser.getUserId();

        //Lấy dữ liệu từ Form
        String ticketIdStr = request.getParameter("ticketId");
        String status = request.getParameter("status");
        String solution = request.getParameter("solution");
        String action = request.getParameter("action"); 

        try {
            int ticketId = Integer.parseInt(ticketIdStr);
            Integer assignedTo = null;

            // Nếu Support bấm nút "Take Ticket" 
            if ("take".equals(action)) {
                assignedTo = currentUserId;
                status = "IN_PROGRESS"; // Tự động chuyển sang Đang xử lý
            } else {
                // Nếu update bình thường, giữ nguyên assignedTo cũ 
                String assignedToStr = request.getParameter("assignedTo");
                if (assignedToStr != null && !assignedToStr.isEmpty()) {
                    assignedTo = Integer.parseInt(assignedToStr);
                }
            }

            //Thực thi update
            boolean isUpdated = ticketDAO.updateServiceRequestProgress(ticketId, status, solution, assignedTo);

            if (isUpdated) {
                request.getSession().setAttribute("message", "Cập nhật tiến trình thành công!");
            } else {
                request.getSession().setAttribute("error", "Lỗi: Không thể cập nhật Request.");
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Lỗi dữ liệu đầu vào.");
        }

        //Load lại trang Chi tiết Request để xem kết quả
        response.sendRedirect(request.getContextPath() + "/request-detail?id=" + ticketIdStr);
    }
}