package com.itserviceflow.daos;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.itserviceflow.daos.ServiceDAO;
import com.itserviceflow.models.Service;
import com.itserviceflow.utils.DBConnection;
import static com.itserviceflow.utils.DBConnection.getConnection;

public class ServiceDAO {

//    private String jdbcURL = "jdbc:mysql://localhost:3306/itserviceflow_db";
//    private String jdbcUsername = "root";
//    private String jdbcPassword = "root";
//
//    protected Connection getConnection() {
//        Connection connection = null;
//        try {
//            Class.forName("com.mysql.cj.jdbc.Driver");
//            connection = DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//        return connection;
//    }
    public List<Service> searchServices(String query) {
        List<Service> services = new ArrayList<>();

        String sql = "SELECT * FROM service WHERE status = 'ACTIVE' AND (service_name LIKE ? OR description LIKE ?)";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + query + "%");
            ps.setString(2, "%" + query + "%");
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Service s = new Service();
                s.setServiceId(rs.getInt("service_id"));
                s.setServiceName(rs.getString("service_name"));
                s.setServiceCode(rs.getString("service_code"));
                s.setDescription(rs.getString("description"));
                s.setEstimatedDeliveryDay(rs.getInt("estimated_delivery_day"));
                s.setStatus(rs.getString("status"));
                services.add(s);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return services;
    }

    public Service getServiceById(int id) {
        Service service = null;

        String sql = "SELECT * FROM service WHERE service_id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                service = new Service();
                service.setServiceId(rs.getInt("service_id"));
                service.setServiceName(rs.getString("service_name"));
                service.setServiceCode(rs.getString("service_code"));
                service.setDescription(rs.getString("description"));
                service.setEstimatedDeliveryDay(rs.getInt("estimated_delivery_day"));
                service.setStatus(rs.getString("status"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return service;
    }

    public boolean createService(Service service) {
        String sql = "INSERT INTO service (service_name, service_code, description, estimated_delivery_day, status) VALUES (?, ?, ?, ?, 'ACTIVE')";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, service.getServiceName());
            ps.setString(2, service.getServiceCode());
            ps.setString(3, service.getDescription());
            ps.setInt(4, service.getEstimatedDeliveryDay());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public String deleteService(int serviceId) {
        String checkSql = "SELECT COUNT(*) FROM ticket WHERE service_id = ?";
        String deleteSql = "DELETE FROM service WHERE service_id = ?";

        try (Connection conn = getConnection()) {
            try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                psCheck.setInt(1, serviceId);
                ResultSet rs = psCheck.executeQuery();
                if (rs.next() && rs.getInt(1) > 0) {
                    return "cannot_delete";
                }
            }

            // Thực hiện xóa
            try (PreparedStatement psDelete = conn.prepareStatement(deleteSql)) {
                psDelete.setInt(1, serviceId);
                int rows = psDelete.executeUpdate();
                return rows > 0 ? "success" : "fail";
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return "error";
        }
    }

//    public void toggleServiceStatusById(int serviceId) {
//        // SQL tự động đảo ngược trạng thái ngay trong Database
//        String sql = "UPDATE service SET status = IF(status='ACTIVE', 'INACTIVE', 'ACTIVE'), "
//                + "updated_at = CURRENT_TIMESTAMP WHERE service_id = ?";
//
//        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
//            ps.setInt(1, serviceId);
//            ps.executeUpdate();
//        } catch (SQLException e) {
//            e.printStackTrace();
//        }
//    }
    // Hàm xử lý đổi trạng thái (ACTIVE/INACTIVE) cho nhiều dịch vụ cùng lúc
    public int bulkToggleStatus(String[] ids, String newStatus) {
        String sql = "UPDATE service SET status = ? WHERE service_id = ?";
        int count = 0;
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            for (String id : ids) {
                ps.setString(1, newStatus);
                ps.setInt(2, Integer.parseInt(id));
                ps.addBatch();
            }

            int[] results = ps.executeBatch();
            for (int r : results) {
                if (r > 0) {
                    count++;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return count;
    }

    public List<Service> getAllServices(String query, String statusFilter) {
        List<Service> services = new ArrayList<>();
        String sql = "SELECT * FROM service WHERE (service_name LIKE ? OR description LIKE ?)";

        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql += " AND status = ?";
        }

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + query + "%");
            ps.setString(2, "%" + query + "%");
            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                ps.setString(3, statusFilter);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Service s = new Service();
                s.setServiceId(rs.getInt("service_id"));
                s.setServiceName(rs.getString("service_name"));
                s.setServiceCode(rs.getString("service_code"));
                s.setDescription(rs.getString("description"));
                s.setEstimatedDeliveryDay(rs.getInt("estimated_delivery_day"));
                s.setStatus(rs.getString("status"));
                services.add(s);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return services;
    }

    public boolean updateService(Service service) {
        String sql = "UPDATE service SET service_name = ?, description = ?, service_code = ?, "
                + "estimated_delivery_day = ?, status = ? WHERE service_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, service.getServiceName());
            ps.setString(2, service.getDescription());
            ps.setString(3, service.getServiceCode());
            ps.setInt(4, service.getEstimatedDeliveryDay());
            ps.setString(5, service.getStatus());
            ps.setInt(6, service.getServiceId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Hàm kiểm tra xem service_code đã tồn tại chưa (loại trừ chính dịch vụ đang sửa)
    public boolean checkDuplicateServiceCode(String serviceCode, int currentServiceId) {
        String sql = "SELECT COUNT(*) FROM service WHERE service_code = ? AND service_id != ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, serviceCode);
            ps.setInt(2, currentServiceId); // Không tính ID của chính nó đang sửa

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0; // Trả về true nếu count > 0 (bị trùng)
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false; // Không trùng
    }
}
