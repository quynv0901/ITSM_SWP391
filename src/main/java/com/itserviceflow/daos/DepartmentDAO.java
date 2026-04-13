package com.itserviceflow.daos;

import com.itserviceflow.models.Department;
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

    public List<Department> listAll() {
        List<Department> list = new ArrayList<>();
        String sql = "SELECT * FROM department WHERE status = 'ACTIVE'";
        try (PreparedStatement st = conn.prepareStatement(sql); ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                Department d = new Department();
                d.setDepartmentId(rs.getInt("department_id"));
                d.setDepartmentName(rs.getString("department_name"));
                d.setDepartmentCode(rs.getString("department_code"));
                d.setManagerId(rs.getInt("manager_id"));
                d.setParentDepartmentId(rs.getInt("parent_department_id"));
                d.setStatus(rs.getString("status"));
                list.add(d);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Department findById(int id) {
        String sql = "SELECT * FROM department WHERE department_id = ?";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, id);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    Department d = new Department();
                    d.setDepartmentId(rs.getInt("department_id"));
                    d.setDepartmentName(rs.getString("department_name"));
                    d.setDepartmentCode(rs.getString("department_code"));
                    d.setManagerId(rs.getInt("manager_id"));
                    d.setParentDepartmentId(rs.getInt("parent_department_id"));
                    d.setStatus(rs.getString("status"));
                    return d;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
