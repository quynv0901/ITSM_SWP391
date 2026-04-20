package com.itserviceflow.controllers;

import com.itserviceflow.daos.VendorDAO;
import com.itserviceflow.models.Vendor;
import com.itserviceflow.utils.AuthUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "VendorController", urlPatterns = {"/vendor"})
public class VendorController extends HttpServlet {

    private VendorDAO vendorDAO;

    @Override
    public void init() throws ServletException {
        vendorDAO = new VendorDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Optionally check authentication/authorization here using AuthUtils
        // if (!AuthUtils.isLoggedIn(request)) { response.sendRedirect("auth?action=login"); return; }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        try {
            switch (action) {
                case "add":
                    showForm(request, response, null);
                    break;
                case "edit":
                    showEditForm(request, response);
                    break;
                case "delete":
                    deleteVendor(request, response);
                    break;
                case "toggle":
                    toggleVendorStatus(request, response);
                    break;
                case "list":
                default:
                    listVendors(request, response);
                    break;
            }
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if ("save".equals(action)) {
            saveVendor(request, response);
        } else {
            doGet(request, response);
        }
    }

    private void listVendors(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");

        List<Vendor> vendors = vendorDAO.getAllVendors(keyword, status);
        request.setAttribute("vendors", vendors);
        request.setAttribute("keyword", keyword);
        request.setAttribute("status", status);

        request.getRequestDispatcher("/vendor/list.jsp").forward(request, response);
    }

    private void showForm(HttpServletRequest request, HttpServletResponse response, Vendor vendor)
            throws ServletException, IOException {
        if (vendor != null) {
            request.setAttribute("vendor", vendor);
        }
        request.getRequestDispatcher("/vendor/form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Vendor existingVendor = vendorDAO.getVendorById(id);
            request.setAttribute("vendor", existingVendor);
            request.getRequestDispatcher("/vendor/form.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/vendor?error=" + java.net.URLEncoder.encode("ID không hợp lệ", "UTF-8"));
        }
    }

    private void saveVendor(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("vendorId");
        String name = request.getParameter("name");
        String email = request.getParameter("contactEmail");
        String phone = request.getParameter("contactPhone");
        String address = request.getParameter("address");
        String status = request.getParameter("status");

        if (name == null || name.trim().isEmpty()) {
            Vendor v = new Vendor();
            v.setContactEmail(email);
            v.setContactPhone(phone);
            v.setAddress(address);
            v.setStatus(status);
            request.setAttribute("errorMessage", "Tên nhà cung cấp không được để trống!");
            showForm(request, response, v);
            return;
        }

        Vendor vendor = new Vendor();
        vendor.setName(name);
        vendor.setContactEmail(email);
        vendor.setContactPhone(phone);
        vendor.setAddress(address);
        vendor.setStatus(status != null ? status : "ACTIVE");

        boolean success = false;
        if (idStr != null && !idStr.isEmpty()) {
            vendor.setVendorId(Integer.parseInt(idStr));
            success = vendorDAO.updateVendor(vendor);
        } else {
            success = vendorDAO.createVendor(vendor);
        }

        if (success) {
            response.sendRedirect(request.getContextPath() + "/vendor?success=" + java.net.URLEncoder.encode("Lưu nhà cung cấp thành công!", "UTF-8"));
        } else {
            request.setAttribute("errorMessage", "Đã có lỗi xảy ra khi lưu dữ liệu.");
            showForm(request, response, vendor);
        }
    }

    private void deleteVendor(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            boolean success = vendorDAO.deleteVendor(id);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/vendor?success=" + java.net.URLEncoder.encode("Đã xóa nhà cung cấp!", "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/vendor?error=" + java.net.URLEncoder.encode("Lỗi khi xóa nhà cung cấp", "UTF-8"));
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/vendor");
        }
    }
    
    private void toggleVendorStatus(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            boolean success = vendorDAO.toggleVendorStatus(id);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/vendor?success=" + java.net.URLEncoder.encode("Đã đổi trạng thái nhà cung cấp!", "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/vendor?error=" + java.net.URLEncoder.encode("Lỗi khi đổi trạng thái", "UTF-8"));
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/vendor");
        }
    }
}
