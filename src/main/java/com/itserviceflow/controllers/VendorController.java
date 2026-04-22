package com.itserviceflow.controllers;

import com.itserviceflow.daos.VendorDAO;
import com.itserviceflow.models.Vendor;
import com.itserviceflow.utils.AuthUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.itserviceflow.daos.ConfigurationItemDAO;
import com.itserviceflow.models.ConfigurationItem;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "VendorController", urlPatterns = {"/vendor"})
public class VendorController extends HttpServlet {

    private VendorDAO vendorDAO;
    private ConfigurationItemDAO configurationItemDAO;

    @Override
    public void init() throws ServletException {
        vendorDAO = new VendorDAO();
        configurationItemDAO = new ConfigurationItemDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Validate: only Admin(10) and Asset Manager(8) are allowed to access Vendor Management
        if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_ASSET_MANAGER)) {
            return;
        }

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
                case "toggle":
                    toggleVendorStatus(request, response);
                    break;
                case "detail":
                    showVendorDetail(request, response);
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

        if (!AuthUtils.hasRole(request, response, AuthUtils.ROLE_ASSET_MANAGER)) {
            return;
        }

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

    private void showVendorDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Vendor vendor = vendorDAO.getVendorById(id);
            if (vendor == null) {
                response.sendRedirect(request.getContextPath() + "/vendor?error=" + java.net.URLEncoder.encode("Không tìm thấy Nhà cung cấp", "UTF-8"));
                return;
            }
            List<ConfigurationItem> vendorCIs = configurationItemDAO.getCIsByVendorId(id);
            request.setAttribute("vendor", vendor);
            request.setAttribute("vendorCIs", vendorCIs);
            request.getRequestDispatcher("/vendor/detail.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/vendor");
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

        int id = 0;
        if (idStr != null && !idStr.isEmpty()) {
            try { id = Integer.parseInt(idStr); } catch (NumberFormatException ignored) {}
        }

        Vendor vendor = new Vendor();
        vendor.setVendorId(id);
        vendor.setName(name != null ? name.trim() : "");
        vendor.setContactEmail(email != null ? email.trim() : "");
        vendor.setContactPhone(phone != null ? phone.trim() : "");
        vendor.setAddress(address != null ? address.trim() : "");
        vendor.setStatus(status != null ? status : "ACTIVE");

        String error = validateVendor(vendor.getName(), vendor.getContactEmail(), vendor.getContactPhone(), vendor.getAddress());
        if (error != null) {
            request.setAttribute("errorMessage", error);
            showForm(request, response, vendor);
            return;
        }

        if (vendorDAO.isDuplicateVendorName(vendor.getName(), vendor.getVendorId())) {
            request.setAttribute("errorMessage", "Tên Nhà cung cấp đã tồn tại trong hệ thống. Vui lòng chọn tên khác!");
            showForm(request, response, vendor);
            return;
        }

        if (vendorDAO.isDuplicateVendorEmail(vendor.getContactEmail(), vendor.getVendorId())) {
            request.setAttribute("errorMessage", "Email liên hệ này đã được sử dụng bởi một Nhà cung cấp khác. Vui lòng kiểm tra lại!");
            showForm(request, response, vendor);
            return;
        }

        if (vendorDAO.isDuplicateVendorPhone(vendor.getContactPhone(), vendor.getVendorId())) {
            request.setAttribute("errorMessage", "Số điện thoại này đã được đăng ký cho một Nhà cung cấp khác. Vui lòng kiểm tra lại!");
            showForm(request, response, vendor);
            return;
        }

        boolean success = false;
        if (id > 0) {
            success = vendorDAO.updateVendor(vendor);
        } else {
            success = vendorDAO.createVendor(vendor);
        }

        if (success) {
            response.sendRedirect(request.getContextPath() + "/vendor?success=" + java.net.URLEncoder.encode("Lưu nhà cung cấp thành công!", "UTF-8"));
        } else {
            request.setAttribute("errorMessage", "Đã có lỗi xảy ra khi lưu dữ liệu vào cơ sở dữ liệu.");
            showForm(request, response, vendor);
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

    private String validateVendor(String name, String contactEmail, String contactPhone, String address) {
        if (name == null || name.isEmpty()) return "Tên Nhà cung cấp là bắt buộc.";
        if (name.length() > 150) return "Tên Nhà cung cấp không được vượt quá 150 ký tự.";
        if (!name.matches("^[\\p{L}0-9 .\\-_()&]+$")) return "Tên chứa ký tự không hợp lệ. Chỉ chấp nhận chữ cái, số và khoảng trắng, ., -, _, (, ), &.";
        
        if (contactEmail == null || contactEmail.isEmpty())
            return "Email liên hệ là bắt buộc.";
        if (contactEmail.length() > 255)
            return "Email liên hệ không được vượt quá 255 ký tự.";
        if (!contactEmail.matches("^[A-Za-z0-9+_.-]+@(.+)$"))
            return "Email liên hệ không hợp lệ.";

        if (contactPhone == null || contactPhone.isEmpty())
            return "Số điện thoại là bắt buộc.";
        if (contactPhone.length() > 50)
            return "Số điện thoại không được vượt quá 50 ký tự.";
        if (!contactPhone.matches("^[0-9 .+\\-()]+$"))
            return "Số điện thoại chứa ký tự không hợp lệ.";

        if (address == null || address.isEmpty())
            return "Địa chỉ là bắt buộc.";
        if (address.length() > 255)
            return "Địa chỉ không được vượt quá 255 ký tự.";

        return null;
    }
}
