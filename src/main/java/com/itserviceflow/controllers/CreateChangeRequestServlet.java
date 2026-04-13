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

@WebServlet("/change-request/create")
public class CreateChangeRequestServlet extends HttpServlet {
    private TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        // Phân quyền: System Engineer (Role 6) hoặc Manager/Admin mới được tạo CR
        if (currentUser == null || currentUser.getRoleId() == 1 || currentUser.getRoleId() == 2) { 
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ System Engineer hoặc cấp quản lý mới được tạo Change Request.");
            return;
        }
        
        request.getRequestDispatcher("/ticket/create-change-request.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        try {
            Ticket cr = new Ticket();
            cr.setTitle(request.getParameter("title"));
            cr.setDescription(request.getParameter("description"));
            cr.setPriority(request.getParameter("priority"));
            cr.setChangeType(request.getParameter("changeType"));
            cr.setRiskLevel(request.getParameter("riskLevel"));
            cr.setImpactAssessment(request.getParameter("impactAssessment"));
            cr.setImplementationPlan(request.getParameter("implementationPlan"));
            cr.setRollbackPlan(request.getParameter("rollbackPlan"));
            cr.setTestPlan(request.getParameter("testPlan"));
            cr.setReportedBy(currentUser.getUserId());
            cr.setDepartmentId(currentUser.getDepartmentId());

            // Xử lý ngày tháng từ input type="datetime-local"
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            String startStr = request.getParameter("scheduledStart");
            if (startStr != null && !startStr.isEmpty()) cr.setScheduledStart(sdf.parse(startStr));
            
            String endStr = request.getParameter("scheduledEnd");
            if (endStr != null && !endStr.isEmpty()) cr.setScheduledEnd(sdf.parse(endStr));

            String downtimeStr = request.getParameter("downtimeRequired");
            cr.setDowntimeRequired("true".equals(downtimeStr));

            String estStr = request.getParameter("estimatedDowntimeHour");
            if (estStr != null && !estStr.isEmpty()) cr.setEstimatedDowntimeHour(Double.parseDouble(estStr));

            // Lưu vào DB
            boolean success = ticketDAO.createChangeRequest(cr);

            if (success) {
                session.setAttribute("message", "Tạo Change Request thành công!");
                response.sendRedirect(request.getContextPath() + "/change-request/list");
            } else {
                session.setAttribute("error", "Lỗi: Không thể lưu vào cơ sở dữ liệu.");
                request.getRequestDispatcher("/ticket/create-change-request.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Dữ liệu nhập không hợp lệ: " + e.getMessage());
            request.getRequestDispatcher("/ticket/create-change-request.jsp").forward(request, response);
        }
    }
}