package com.itserviceflow.daos;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.itserviceflow.models.Vendor;
import static com.itserviceflow.utils.DBConnection.getConnection;

public class VendorDAO {

    public List<Vendor> getAllVendors(String keyword, String status) {
        List<Vendor> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM vendor WHERE 1=1");
        
        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        boolean hasStatus = status != null && !status.trim().isEmpty();

        if (hasKeyword) {
            sql.append(" AND (name LIKE ? OR contact_email LIKE ? OR contact_phone LIKE ?)");
        }
        if (hasStatus) {
            sql.append(" AND status = ?");
        }
        sql.append(" ORDER BY vendor_id DESC");

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            
            if (hasKeyword) {
                String searchParam = "%" + keyword.trim() + "%";
                ps.setString(paramIndex++, searchParam);
                ps.setString(paramIndex++, searchParam);
                ps.setString(paramIndex++, searchParam);
            }
            if (hasStatus) {
                ps.setString(paramIndex++, status.trim());
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Vendor v = new Vendor();
                v.setVendorId(rs.getInt("vendor_id"));
                v.setName(rs.getString("name"));
                v.setContactEmail(rs.getString("contact_email"));
                v.setContactPhone(rs.getString("contact_phone"));
                v.setAddress(rs.getString("address"));
                v.setStatus(rs.getString("status"));
                v.setCreatedAt(rs.getTimestamp("created_at"));
                v.setUpdatedAt(rs.getTimestamp("updated_at"));
                list.add(v);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Vendor getVendorById(int id) {
        String sql = "SELECT * FROM vendor WHERE vendor_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Vendor v = new Vendor();
                v.setVendorId(rs.getInt("vendor_id"));
                v.setName(rs.getString("name"));
                v.setContactEmail(rs.getString("contact_email"));
                v.setContactPhone(rs.getString("contact_phone"));
                v.setAddress(rs.getString("address"));
                v.setStatus(rs.getString("status"));
                v.setCreatedAt(rs.getTimestamp("created_at"));
                v.setUpdatedAt(rs.getTimestamp("updated_at"));
                return v;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean createVendor(Vendor v) {
        String sql = "INSERT INTO vendor (name, contact_email, contact_phone, address, status) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, v.getName());
            ps.setString(2, v.getContactEmail());
            ps.setString(3, v.getContactPhone());
            ps.setString(4, v.getAddress());
            ps.setString(5, v.getStatus() != null ? v.getStatus() : "ACTIVE");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateVendor(Vendor v) {
        String sql = "UPDATE vendor SET name = ?, contact_email = ?, contact_phone = ?, address = ?, status = ? WHERE vendor_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, v.getName());
            ps.setString(2, v.getContactEmail());
            ps.setString(3, v.getContactPhone());
            ps.setString(4, v.getAddress());
            ps.setString(5, v.getStatus());
            ps.setInt(6, v.getVendorId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteVendor(int id) {
        // Soft delete
        String sql = "UPDATE vendor SET status = 'INACTIVE' WHERE vendor_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean toggleVendorStatus(int id) {
        String sql = "UPDATE vendor SET status = IF(status='ACTIVE', 'INACTIVE', 'ACTIVE') WHERE vendor_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
