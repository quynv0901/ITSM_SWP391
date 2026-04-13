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
import java.text.SimpleDateFormat;

@WebServlet("/change-request/edit")
public class UpdateChangeRequestServlet extends HttpServlet {
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

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/change-request/list");
            return;
        }

        int ticketId = Integer.parseInt(idParam);
        Ticket ticket = ticketDAO.getChangeRequestDetail(ticketId);

        // UC67: Kiểm tra xem người đang đăng nhập có phải là người tạo phiếu không?
        if (ticket == null || ticket.getReportedBy() != currentUser.getUserId()) {
            session.setAttribute("error", "Bạn không có quyền chỉnh sửa phiếu Change Request này.");
            response.sendRedirect(request.getContextPath() + "/change-request/detail?id=" + ticketId);
            return;
        }
        
        // Thêm một rule nhỏ: Chỉ cho sửa khi status là NEW hoặc PENDING
        if (!"NEW".equals(ticket.getStatus()) && !"PENDING".equals(ticket.getStatus())) {
            session.setAttribute("error", "Không thể chỉnh sửa phiếu đã được duyệt hoặc đang triển khai.");
            response.sendRedirect(request.getContextPath() + "/change-request/detail?id=" + ticketId);
            return;
        }

        request.setAttribute("ticket", ticket);
        request.getRequestDispatcher("/ticket/update-change-request.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) return;

        int ticketId = Integer.parseInt(request.getParameter("ticketId"));

        try {
            Ticket cr = new Ticket();
            cr.setTicketId(ticketId);
            cr.setTitle(request.getParameter("title"));
            cr.setDescription(request.getParameter("description"));
            cr.setPriority(request.getParameter("priority"));
            cr.setChangeType(request.getParameter("changeType"));
            cr.setRiskLevel(request.getParameter("riskLevel"));
            cr.setImpactAssessment(request.getParameter("impactAssessment"));
            cr.setImplementationPlan(request.getParameter("implementationPlan"));
            cr.setRollbackPlan(request.getParameter("rollbackPlan"));
            cr.setTestPlan(request.getParameter("testPlan"));
            cr.setReportedBy(currentUser.getUserId()); // Gắn cứng người sửa phải là người tạo

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            String startStr = request.getParameter("scheduledStart");
            if (startStr != null && !startStr.isEmpty()) cr.setScheduledStart(sdf.parse(startStr));
            
            String endStr = request.getParameter("scheduledEnd");
            if (endStr != null && !endStr.isEmpty()) cr.setScheduledEnd(sdf.parse(endStr));

            cr.setDowntimeRequired("true".equals(request.getParameter("downtimeRequired")));

            String estStr = request.getParameter("estimatedDowntimeHour");
            if (estStr != null && !estStr.isEmpty()) cr.setEstimatedDowntimeHour(Double.parseDouble(estStr));

            boolean success = ticketDAO.updateChangeRequest(cr);

            if (success) {
                session.setAttribute("message", "Cập nhật Change Request thành công!");
            } else {
                session.setAttribute("error", "Cập nhật thất bại hoặc bạn không có quyền.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Lỗi dữ liệu: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/change-request/detail?id=" + ticketId);
    }
}