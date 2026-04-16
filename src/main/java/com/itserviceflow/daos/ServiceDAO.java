package com.itserviceflow.daos;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import com.itserviceflow.models.Service;
import com.itserviceflow.utils.DBConnection;

public class ServiceDAO {

    private Service mapService(ResultSet rs) throws SQLException {
        Service service = new Service();
        service.setServiceId(rs.getInt("service_id"));
        service.setServiceName(rs.getString("service_name"));
        service.setServiceCode(rs.getString("service_code"));
        service.setDescription(rs.getString("description"));
        service.setEstimatedDeliveryDay(rs.getInt("estimated_delivery_day"));
        service.setStatus(rs.getString("status"));

        service.setCreatedAt(rs.getTimestamp("created_at"));
        service.setUpdatedAt(rs.getTimestamp("updated_at"));

        return service;
    }

    private String normalizeKeyword(String keyword) {
        return keyword == null ? "" : keyword.trim();
    }

    private boolean isValidStatus(String status) {
        return "ACTIVE".equalsIgnoreCase(status) || "INACTIVE".equalsIgnoreCase(status);
    }

    public boolean existsByServiceCode(String serviceCode) {
        String sql = "SELECT COUNT(*) FROM service WHERE service_code = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, serviceCode);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean existsByServiceCode(String serviceCode, int excludeServiceId) {
        String sql = "SELECT COUNT(*) FROM service WHERE service_code = ? AND service_id <> ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, serviceCode);
            ps.setInt(2, excludeServiceId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean hasRelatedTickets(int serviceId) {
        String sql = "SELECT COUNT(*) FROM ticket WHERE service_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, serviceId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // 1) End-user: Search & Filter chỉ lấy service ACTIVE
    public List<Service> searchActiveServices(String keyword) {
        List<Service> services = new ArrayList<>();
        keyword = normalizeKeyword(keyword);

        String sql = "SELECT * FROM service " +
                     "WHERE status = 'ACTIVE' " +
                     "AND (service_name LIKE ? OR service_code LIKE ? OR description LIKE ?) " +
                     "ORDER BY service_name ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            String searchValue = "%" + keyword + "%";
            ps.setString(1, searchValue);
            ps.setString(2, searchValue);
            ps.setString(3, searchValue);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                services.add(mapService(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return services;
    }

    // 2) End-user/Admin: View detail theo ID
    public Service getServiceById(int serviceId) {
        String sql = "SELECT * FROM service WHERE service_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, serviceId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapService(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // End-user: chỉ xem detail service ACTIVE
    public Service getActiveServiceById(int serviceId) {
        String sql = "SELECT * FROM service WHERE service_id = ? AND status = 'ACTIVE'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, serviceId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapService(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // 3) Admin: list toàn bộ service + search + filter status
    public List<Service> getAllServices(String keyword, String statusFilter) {
        List<Service> services = new ArrayList<>();
        keyword = normalizeKeyword(keyword);

        StringBuilder sql = new StringBuilder(
            "SELECT * FROM service " +
            "WHERE (service_name LIKE ? OR service_code LIKE ? OR description LIKE ?)"
        );

        boolean hasStatusFilter = statusFilter != null && !statusFilter.trim().isEmpty();
        if (hasStatusFilter) {
            sql.append(" AND status = ?");
        }

        sql.append(" ORDER BY service_id DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            String searchValue = "%" + keyword + "%";
            ps.setString(1, searchValue);
            ps.setString(2, searchValue);
            ps.setString(3, searchValue);

            if (hasStatusFilter) {
                ps.setString(4, statusFilter.trim().toUpperCase());
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                services.add(mapService(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return services;
    }

    // 4) Admin: Create service
    public boolean createService(Service service) {
        if (service == null) {
            return false;
        }

        if (existsByServiceCode(service.getServiceCode())) {
            return false;
        }

        String sql = "INSERT INTO service " +
                     "(service_name, service_code, description, estimated_delivery_day, status) " +
                     "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, service.getServiceName());
            ps.setString(2, service.getServiceCode());
            ps.setString(3, service.getDescription());
            ps.setInt(4, service.getEstimatedDeliveryDay());

            String status = service.getStatus();
            if (!isValidStatus(status)) {
                status = "ACTIVE";
            }
            ps.setString(5, status.toUpperCase());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // 5) Admin: Update service
    public boolean updateService(Service service) {
        if (service == null) {
            return false;
        }

        if (existsByServiceCode(service.getServiceCode(), service.getServiceId())) {
            return false;
        }

        String sql = "UPDATE service " +
                     "SET service_name = ?, service_code = ?, description = ?, " +
                     "    estimated_delivery_day = ?, status = ?, updated_at = CURRENT_TIMESTAMP " +
                     "WHERE service_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, service.getServiceName());
            ps.setString(2, service.getServiceCode());
            ps.setString(3, service.getDescription());
            ps.setInt(4, service.getEstimatedDeliveryDay());

            String status = service.getStatus();
            if (!isValidStatus(status)) {
                status = "ACTIVE";
            }
            ps.setString(5, status.toUpperCase());

            ps.setInt(6, service.getServiceId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // 6) Admin: Delete service
    // chỉ xóa khi chưa có request nào sử dụng
    public String deleteService(int serviceId) {
        if (hasRelatedTickets(serviceId)) {
            return "cannot_delete";
        }

        String sql = "DELETE FROM service WHERE service_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, serviceId);
            int rows = ps.executeUpdate();

            return rows > 0 ? "success" : "not_found";
        } catch (SQLException e) {
            e.printStackTrace();
            return "error";
        }
    }

    // 7) Admin: Enable / Disable 1 service
    public boolean updateServiceStatus(int serviceId, String newStatus) {
        if (!isValidStatus(newStatus)) {
            return false;
        }

        String sql = "UPDATE service " +
                     "SET status = ?, updated_at = CURRENT_TIMESTAMP " +
                     "WHERE service_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, newStatus.toUpperCase());
            ps.setInt(2, serviceId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // Toggle ACTIVE <-> INACTIVE cho 1 service
    public boolean toggleServiceStatus(int serviceId) {
        String sql = "UPDATE service " +
                     "SET status = CASE " +
                     "    WHEN status = 'ACTIVE' THEN 'INACTIVE' " +
                     "    WHEN status = 'INACTIVE' THEN 'ACTIVE' " +
                     "    ELSE status END, " +
                     "updated_at = CURRENT_TIMESTAMP " +
                     "WHERE service_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, serviceId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // 8) Admin: bulk enable / disable
    public int bulkUpdateStatus(String[] ids, String newStatus) {
        if (ids == null || ids.length == 0 || !isValidStatus(newStatus)) {
            return 0;
        }

        String sql = "UPDATE service " +
                     "SET status = ?, updated_at = CURRENT_TIMESTAMP " +
                     "WHERE service_id = ?";

        int updatedCount = 0;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            for (String id : ids) {
                ps.setString(1, newStatus.toUpperCase());
                ps.setInt(2, Integer.parseInt(id));
                ps.addBatch();
            }

            int[] results = ps.executeBatch();
            for (int result : results) {
                if (result > 0) {
                    updatedCount++;
                }
            }
        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
        }

        return updatedCount;
    }
}