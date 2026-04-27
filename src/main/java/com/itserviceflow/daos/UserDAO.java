/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.itserviceflow.daos;

import com.itserviceflow.models.User;
import com.itserviceflow.utils.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.mindrot.jbcrypt.BCrypt;

/**
 *
 * @author Lo Pc
 */
public class UserDAO {

    private Connection conn;

    public UserDAO() {
        try {
            conn = DBConnection.getConnection();
        } catch (Exception e) {
            System.err.println("error!" + e.getMessage());
        }
    }

    private User mapUser(ResultSet rs) throws Exception {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setUsername(rs.getString("username"));
        u.setEmail(rs.getString("email"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setFullName(rs.getString("full_name"));
        u.setPhone(rs.getString("phone"));
        u.setDepartmentId(rs.getInt("department_id"));
        u.setRoleId(rs.getInt("role_id"));
        u.setIsActive(rs.getBoolean("is_active"));
        u.setResetToken(rs.getString("reset_token"));
        Timestamp expires = rs.getTimestamp("reset_token_expires");
        if (expires != null) {
            u.setResetTokenExpires(expires.toLocalDateTime());
        }
        u.setResetTokenUsed(rs.getBoolean("reset_token_used"));
        Timestamp updated = rs.getTimestamp("updated_at");
        if (updated != null) {
            u.setUpdatedAt(updated.toLocalDateTime());
        }
        Timestamp lastLogin = rs.getTimestamp("last_login");
        if (lastLogin != null) {
            u.setLastLogin(lastLogin.toLocalDateTime());
        }

        // Joined field mapping
        try {
            u.setRoleName(rs.getString("role_name"));
        } catch (Exception e) {
        }
        try {
            u.setDepartmentName(rs.getString("department_name"));
        } catch (Exception e) {
        }

        return u;
    }

    public List<User> getUsersByRoleId(int roleId) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT u.*, r.role_name, d.department_name "
                + "FROM `user` u "
                + "LEFT JOIN role r ON u.role_id = r.role_id "
                + "LEFT JOIN department d ON u.department_id = d.department_id "
                + "WHERE u.role_id = ? AND u.is_active = 1";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, roleId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapUser(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<User> listUsers(String search, Integer roleId, Integer deptId, String sortBy, String order, int offset,
            int limit) {
        List<User> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT u.*, r.role_name, d.department_name "
                + "FROM `user` u "
                + "LEFT JOIN role r ON u.role_id = r.role_id "
                + "LEFT JOIN department d ON u.department_id = d.department_id WHERE 1=1 ");

        if (search != null && !search.isEmpty()) {
            sql.append(" AND (u.full_name LIKE ? OR u.email LIKE ? OR u.username LIKE ?) ");
        }
        if (roleId != null && roleId > 0) {
            sql.append(" AND u.role_id = ? ");
        }
        if (deptId != null && deptId > 0) {
            sql.append(" AND u.department_id = ? ");
        }

        // Validate sortBy to prevent SQL Injection
        String validSort = (sortBy != null && (sortBy.equals("user_id") || sortBy.equals("full_name")
                || sortBy.equals("username") || sortBy.equals("email")
                || sortBy.equals("updated_at"))) ? sortBy : "updated_at";
        String validOrder = (order != null && order.equalsIgnoreCase("ASC")) ? "ASC" : "DESC";

        sql.append(" ORDER BY ").append(validSort).append(" ").append(validOrder);
        sql.append(" LIMIT ? OFFSET ?");

        try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (search != null && !search.isEmpty()) {
                String searchPattern = "%" + search + "%";
                stmt.setString(paramIndex++, searchPattern);
                stmt.setString(paramIndex++, searchPattern);
                stmt.setString(paramIndex++, searchPattern);
            }
            if (roleId != null && roleId > 0) {
                stmt.setInt(paramIndex++, roleId);
            }
            if (deptId != null && deptId > 0) {
                stmt.setInt(paramIndex++, deptId);
            }
            stmt.setInt(paramIndex++, limit);
            stmt.setInt(paramIndex++, offset);

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapUser(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countUsers(String search, Integer roleId, Integer deptId) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM `user` WHERE 1=1 ");
        if (search != null && !search.isEmpty()) {
            sql.append(" AND (full_name LIKE ? OR email LIKE ? OR username LIKE ?) ");
        }
        if (roleId != null && roleId > 0) {
            sql.append(" AND role_id = ? ");
        }
        if (deptId != null && deptId > 0) {
            sql.append(" AND department_id = ? ");
        }

        try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (search != null && !search.isEmpty()) {
                String searchPattern = "%" + search + "%";
                stmt.setString(paramIndex++, searchPattern);
                stmt.setString(paramIndex++, searchPattern);
                stmt.setString(paramIndex++, searchPattern);
            }
            if (roleId != null && roleId > 0) {
                stmt.setInt(paramIndex++, roleId);
            }
            if (deptId != null && deptId > 0) {
                stmt.setInt(paramIndex++, deptId);
            }
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public User login(String usernameOrEmail, String password) {
        String sql = "SELECT u.*, r.role_name, d.department_name FROM `user` u "
                + "LEFT JOIN role r ON u.role_id = r.role_id "
                + "LEFT JOIN department d ON u.department_id = d.department_id "
                + "WHERE (u.username = ? OR u.email = ?) AND u.is_active = 1";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setString(1, usernameOrEmail);
            st.setString(2, usernameOrEmail);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    User u = mapUser(rs);
                    String stored = u.getPasswordHash();
                    boolean valid;
                    if (stored.startsWith("$2a$")) {
                        valid = BCrypt.checkpw(password, stored);
                    } else {
                        // Plain text password, compare directly
                        valid = password.equals(stored);
                        // If valid, hash it for future logins
                        if (valid) {
                            updatePassword(u.getUserId(), password);
                        }
                    }
                    if (valid) {
                        updateLastLogin(u.getUserId());
                        return u;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static void main(String[] args) {
        UserDAO userDao = new UserDAO();
        System.out.println(userDao.login("admin@test.com", "Admin123"));
    }

    private void updateLastLogin(int userId) {
        String sql = "UPDATE `user` SET last_login = NOW() WHERE user_id = ?";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, userId);
            st.executeUpdate();
        } catch (Exception e) {
        }
    }

    public User findByEmail(String email) {
        String sql = "SELECT * FROM `user` WHERE email = ?";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setString(1, email);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public User findByResetToken(String token) {
        String sql = "SELECT * FROM `user` WHERE reset_token = ? AND reset_token_expires > ? AND reset_token_used = 0";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setString(1, token);
            st.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateResetToken(String email, String token, LocalDateTime expiry) {
        String sql = "UPDATE `user` SET reset_token = ?, reset_token_expires = ?, reset_token_used = 0 WHERE email = ?";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setString(1, token);
            st.setTimestamp(2, Timestamp.valueOf(expiry));
            st.setString(3, email);
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updatePassword(int userId, String newPassword) {
        String sql = "UPDATE `user` SET password_hash = ?, reset_token_used = 1 WHERE user_id = ?";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setString(1, BCrypt.hashpw(newPassword, BCrypt.gensalt()));
            st.setInt(2, userId);
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateProfile(User u) {
        String sql = "UPDATE `user` SET full_name = ?, phone = ? WHERE user_id = ?";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setString(1, u.getFullName());
            st.setString(2, u.getPhone());
            st.setInt(3, u.getUserId());
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateUserByAdmin(User u) {
        String sql = "UPDATE `user` SET full_name = ?, email = ?, role_id = ?, department_id = ? WHERE user_id = ?";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setString(1, u.getFullName());
            st.setString(2, u.getEmail());
            st.setInt(3, u.getRoleId());
            if (u.getDepartmentId() != null) {
                st.setInt(4, u.getDepartmentId());
            } else {
                st.setNull(4, java.sql.Types.INTEGER);
            }
            st.setInt(5, u.getUserId());
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean addUser(User u) {
        String sql = "INSERT INTO `user` (username, email, password_hash, full_name, phone, department_id, role_id, is_active) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setString(1, u.getUsername());
            st.setString(2, u.getEmail());
            st.setString(3, BCrypt.hashpw(u.getPasswordHash(), BCrypt.gensalt()));
            st.setString(4, u.getFullName());
            st.setString(5, u.getPhone());
            if (u.getDepartmentId() != null && u.getDepartmentId() > 0) {
                st.setInt(6, u.getDepartmentId());
            } else {
                st.setNull(6, java.sql.Types.INTEGER);
            }
            st.setInt(7, u.getRoleId());
            st.setBoolean(8, u.getIsActive());
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteUser(int id) {
        String sql = "DELETE FROM `user` WHERE user_id = ?";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, id);
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean toggleStatus(int id, boolean status) {
        String sql = "UPDATE `user` SET is_active = ? WHERE user_id = ?";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setBoolean(1, status);
            st.setInt(2, id);
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public User findById(int id) {
        String sql = "SELECT u.*, r.role_name, d.department_name FROM `user` u "
                + "LEFT JOIN role r ON u.role_id = r.role_id "
                + "LEFT JOIN department d ON u.department_id = d.department_id "
                + "WHERE u.user_id = ?";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, id);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean isUsernameTaken(String username, Integer excludeUserId) {
        String sql = "SELECT COUNT(*) FROM `user` WHERE username = ?"
                + (excludeUserId != null ? " AND user_id != ?" : "");
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setString(1, username);
            if (excludeUserId != null) {
                st.setInt(2, excludeUserId);
            }
            ResultSet rs = st.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean isEmailTaken(String email, Integer excludeUserId) {
        String sql = "SELECT COUNT(*) FROM `user` WHERE email = ?"
                + (excludeUserId != null ? " AND user_id != ?" : "");
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setString(1, email);
            if (excludeUserId != null) {
                st.setInt(2, excludeUserId);
            }
            ResultSet rs = st.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
