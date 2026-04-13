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
import java.util.List;

@WebServlet("/ticket/service-request-list")
public class ServiceRequestListServlet extends HttpServlet {
    private TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
    // =========================================================
        // 1. KIỂM TRA ĐĂNG NHẬP (DÙNG DỮ LIỆU THẬT)
        // =========================================================
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user"); // Đảm bảo tên biến này khớp với lúc Login
        
        // Bật bảo mật: Nếu chưa đăng nhập thì đuổi ra trang login
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        // Lấy ID và Quyền từ tài khoản đang đăng nhập
        int currentUserId = currentUser.getUserId();
        int roleId = currentUser.getRoleId();

        // =========================================================
        // 2. CHUẨN HÓA QUYỀN THEO ĐÚNG DATABASE ĐỂ ĐẨY XUỐNG DAO
        // =========================================================
        String roleString = "END_USER"; // Mặc định an toàn nhất là End-user

        if (roleId == 1) { 
            roleString = "END_USER";   // Role 1: End-user
        } else if (roleId == 2) {
            roleString = "SUPPORT";    // Role 2: Support Agent
        } else if (roleId == 3 || roleId == 10) {
            roleString = "ADMIN";      // Role 3 (Manager) hoặc cao hơn: Được xem full danh sách
        }

        // =========================================================
        // 3. XỬ LÝ TÌM KIẾM & LỌC DỮ LIỆU
        // =========================================================
        String search = request.getParameter("search");
        String statusFilter = request.getParameter("statusFilter");
        
    // Gọi DAO lấy danh sách Ticket là Service Request
    List<Ticket> requests = ticketDAO.getRequestsByRole(
        currentUserId, // Truyền ID giả lập
        roleString,    // Truyền quyền giả lập
        search, 
        statusFilter
    );

    request.setAttribute("requestList", requests);
    request.setAttribute("search", search);
    request.setAttribute("statusFilter", statusFilter);
    
    request.getRequestDispatcher("/ticket/service-request-list.jsp").forward(request, response);
    }
}