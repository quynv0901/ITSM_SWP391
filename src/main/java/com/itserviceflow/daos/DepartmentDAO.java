package com.itserviceflow.daos;

import com.itserviceflow.models.Department;
import com.itserviceflow.models.User;
import com.itserviceflow.utils.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class DepartmentDAO {

    private Connection conn;

    public DepartmentDAO() {
        conn = DBConnection.getConnection();
    }

    private Department mapDepartment(ResultSet rs) throws Exception {
        Department d = new Department();
        d.setDepartmentId(rs.getInt("department_id"));
        d.setDepartmentName(rs.getString("department_name"));
        d.setDepartmentCode(rs.getString("department_code"));
        d.setManagerId((Integer) rs.getObject("manager_id"));
        d.setParentDepartmentId((Integer) rs.getObject("parent_department_id"));
        d.setStatus(rs.getString("status"));
        try {
            d.setManagerName(rs.getString("manager_name"));
        } catch (Exception ignored) {
        }
        try {
            d.setParentDepartmentName(rs.getString("parent_department_name"));
        } catch (Exception ignored) {
        }
        try {
            d.setTotalUsers(rs.getInt("total_users"));
        } catch (Exception ignored) {
        }
        return d;
    }

    public List<Department> listAll() {
        List<Department> list = new ArrayList<>();
        String sql = "SELECT d.* FROM department d WHERE d.status = 'ACTIVE' ORDER BY d.department_name DESC";
        try (PreparedStatement st = conn.prepareStatement(sql); ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                list.add(mapDepartment(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Department> listDepartments(String keyword, String managerFilter, String statusFilter, int offset, int limit) {
        List<Department> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT d.*, m.full_name AS manager_name, pd.department_name AS parent_department_name, "
                + "COUNT(u.user_id) AS total_users "
                + "FROM department d "
                + "LEFT JOIN `user` m ON d.manager_id = m.user_id "
                + "LEFT JOIN department pd ON d.parent_department_id = pd.department_id "
                + "LEFT JOIN `user` u ON u.department_id = d.department_id "
                + "WHERE 1=1 ");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (d.department_name LIKE ? OR d.department_code LIKE ?) ");
        }
        if ("HAS_MANAGER".equals(managerFilter)) {
            sql.append("AND m.user_id IS NOT NULL ");
        } else if ("NO_MANAGER".equals(managerFilter)) {
            sql.append("AND m.user_id IS NULL ");
        }
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append("AND d.status = ? ");
        }
        sql.append("GROUP BY d.department_id, d.department_name, d.department_code, d.manager_id, d.parent_department_id, d.status, m.full_name, pd.department_name ");
        sql.append("ORDER BY d.department_name ASC ");
        sql.append("LIMIT ? OFFSET ?");

        try (PreparedStatement st = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String key = "%" + keyword.trim() + "%";
                st.setString(paramIndex++, key);
                st.setString(paramIndex++, key);
            }
            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                st.setString(paramIndex++, statusFilter.trim());
            }
            st.setInt(paramIndex++, limit);
            st.setInt(paramIndex++, offset);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    list.add(mapDepartment(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countDepartments(String keyword, String managerFilter, String statusFilter) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM department d LEFT JOIN `user` m ON d.manager_id = m.user_id WHERE 1=1 ");
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (d.department_name LIKE ? OR d.department_code LIKE ?) ");
        }
        if ("HAS_MANAGER".equals(managerFilter)) {
            sql.append("AND m.user_id IS NOT NULL ");
        } else if ("NO_MANAGER".equals(managerFilter)) {
            sql.append("AND m.user_id IS NULL ");
        }
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append("AND d.status = ? ");
        }

        try (PreparedStatement st = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String key = "%" + keyword.trim() + "%";
                st.setString(paramIndex++, key);
                st.setString(paramIndex++, key);
            }
            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                st.setString(paramIndex++, statusFilter.trim());
            }
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public Department findById(int id) {
        String sql = "SELECT d.*, m.full_name AS manager_name, pd.department_name AS parent_department_name, "
                + "COUNT(u.user_id) AS total_users "
                + "FROM department d "
                + "LEFT JOIN `user` m ON d.manager_id = m.user_id "
                + "LEFT JOIN department pd ON d.parent_department_id = pd.department_id "
                + "LEFT JOIN `user` u ON u.department_id = d.department_id "
                + "WHERE d.department_id = ? "
                + "GROUP BY d.department_id, d.department_name, d.department_code, d.manager_id, d.parent_department_id, d.status, m.full_name, pd.department_name";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, id);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return mapDepartment(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<User> listUsersByDepartment(int departmentId) {
        List<User> users = new ArrayList<>();
        String sql = "SELECT u.* FROM `user` u WHERE u.department_id = ? ORDER BY u.full_name ASC";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, departmentId);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setFullName(rs.getString("full_name"));
                    user.setEmail(rs.getString("email"));
                    user.setPhone(rs.getString("phone"));
                    user.setIsActive(rs.getBoolean("is_active"));
                    users.add(user);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return users;
    }

    public boolean createDepartment(Department department) {
        String sql = "INSERT INTO department (department_name, department_code, manager_id, parent_department_id, status) "
                + "VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setString(1, department.getDepartmentName());
            st.setString(2, department.getDepartmentCode());
            if (department.getManagerId() != null && department.getManagerId() > 0) {
                st.setInt(3, department.getManagerId());
            } else {
                st.setNull(3, java.sql.Types.INTEGER);
            }
            if (department.getParentDepartmentId() != null && department.getParentDepartmentId() > 0) {
                st.setInt(4, department.getParentDepartmentId());
            } else {
                st.setNull(4, java.sql.Types.INTEGER);
            }
            st.setString(5, department.getStatus() == null ? "ACTIVE" : department.getStatus());
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateDepartment(Department department) {
        String sql = "UPDATE department SET department_name = ?, department_code = ?, manager_id = ?, "
                + "parent_department_id = ?, status = ? WHERE department_id = ?";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setString(1, department.getDepartmentName());
            st.setString(2, department.getDepartmentCode());
            if (department.getManagerId() != null && department.getManagerId() > 0) {
                st.setInt(3, department.getManagerId());
            } else {
                st.setNull(3, java.sql.Types.INTEGER);
            }
            if (department.getParentDepartmentId() != null && department.getParentDepartmentId() > 0) {
                st.setInt(4, department.getParentDepartmentId());
            } else {
                st.setNull(4, java.sql.Types.INTEGER);
            }
            st.setString(5, department.getStatus() == null ? "ACTIVE" : department.getStatus());
            st.setInt(6, department.getDepartmentId());
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateStatus(int departmentId, String status) {
        String sql = "UPDATE department SET status = ? WHERE department_id = ?";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setString(1, status);
            st.setInt(2, departmentId);
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteDepartment(int departmentId) {
        String sql = "DELETE FROM department WHERE department_id = ?";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, departmentId);
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
