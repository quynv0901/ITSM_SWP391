package com.itserviceflow.controllers;

import com.itserviceflow.daos.MyAssignedTicketDAO;
import com.itserviceflow.dtos.MyAssignedTicketDTO;
import com.itserviceflow.models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "MyAssignServlet", urlPatterns = {"/my-assign"})
public class MyAssignServlet extends HttpServlet {

    private static final int ROLE_SUPPORT_AGENT = 2;
    private static final int ROLE_SYSTEM_ENGINEER = 6;
    private MyAssignedTicketDAO myAssignedTicketDAO;

    @Override
    public void init() throws ServletException {
        myAssignedTicketDAO = new MyAssignedTicketDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User loginUser = getLoggedInUser(request);
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (loginUser.getRoleId() != ROLE_SUPPORT_AGENT && loginUser.getRoleId() != ROLE_SYSTEM_ENGINEER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập màn hình này.");
            return;
        }

        List<MyAssignedTicketDTO> myTickets = myAssignedTicketDAO.getAssignedTicketsByUser(loginUser.getUserId());
        request.setAttribute("myTickets", myTickets);
        request.getRequestDispatcher("/ticket/my-assign.jsp").forward(request, response);
    }

    private User getLoggedInUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session == null ? null : (User) session.getAttribute("user");
    }
}
