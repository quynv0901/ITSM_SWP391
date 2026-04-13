package com.itserviceflow.controllers;

import com.itserviceflow.daos.ServiceDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/admin/toggle-service")
public class ToggleServiceServlet extends HttpServlet {
    private ServiceDAO serviceDAO = new ServiceDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Lấy danh sách ID các dịch vụ được chọn và Hành động (ACTIVE/INACTIVE)
        String[] ids = request.getParameterValues("serviceIds");
        String action = request.getParameter("statusAction"); 
        
        // 2. Nếu có dữ liệu, tiến hành gọi DAO để cập nhật
        if (ids != null && action != null && !action.isEmpty()) {
            int count = serviceDAO.bulkToggleStatus(ids, action);
            request.getSession().setAttribute("message", "Đã cập nhật thành công " + count + " dịch vụ thành " + action);
        } else {
            request.getSession().setAttribute("message", "Lỗi: Không có dịch vụ nào được chọn hoặc thiếu thao tác.");
        }
        
        // 3. Load lại trang quản lý
        response.sendRedirect(request.getContextPath() + "/admin/service-management");
    }
}