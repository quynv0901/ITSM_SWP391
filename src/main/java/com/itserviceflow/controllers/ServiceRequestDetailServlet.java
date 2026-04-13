package com.itserviceflow.controllers;

import com.itserviceflow.daos.TicketDAO;
import com.itserviceflow.models.Ticket;
import com.itserviceflow.models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/request-detail")
public class ServiceRequestDetailServlet extends HttpServlet {
    private TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }
        
      
        
        int currentUserId = currentUser.getUserId();
        int currentUserRoleId = currentUser.getRoleId();

        // 2. Lấy ID của Request cần xem
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/ticket/service-request-list");
            return;
        }

        int ticketId = Integer.parseInt(idParam);
        Ticket ticket = ticketDAO.getTicketWithDetailss(ticketId);

        if (ticket == null) {
            request.setAttribute("error", "Request không tồn tại hoặc đã bị xóa.");
            request.getRequestDispatcher("/ticket/service-request-list.jsp").forward(request, response);
            return;
        }

       
//        if (currentUserRoleId == 1 && ticket.getReportedBy() != currentUserId) {
//            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền xem Request này.");
//            return;
//        }

        // 4. Đẩy dữ liệu ra màn hình
        request.setAttribute("ticket", ticket);
        // === UC63: LẤY DANH SÁCH COMMENT ===
        java.util.List<com.itserviceflow.models.Comment> commentList = ticketDAO.getCommentsByTicketId(ticketId);
        request.setAttribute("commentList", commentList);
        
        System.out.println("========== DEBUG QUYỀN ==========");
        System.out.println("Role ID đang chạy là: " + currentUserRoleId);

        if (currentUserRoleId == 1) {
            System.out.println("=> ĐÃ VÀO NHÁNH 1: Mở trang USER (Không form)");
            request.getRequestDispatcher("/ticket/service-request-detail-user.jsp").forward(request, response);
        } else {
            System.out.println("=> ĐÃ VÀO NHÁNH 2: Mở trang MANAGER (Có form)");
            
                com.itserviceflow.daos.UserDAO userDAO = new com.itserviceflow.daos.UserDAO();
                java.util.List<com.itserviceflow.models.User> supportList = userDAO.getUsersByRoleId(2);
                request.setAttribute("supportList", supportList);
            request.getRequestDispatcher("/ticket/service-request-detail-manager.jsp").forward(request, response);
        }
        System.out.println("=================================");
    }
}