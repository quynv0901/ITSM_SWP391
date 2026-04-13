package com.itserviceflow.utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Utility class for obtaining a JDBC connection to the MySQL database.
 *
 * Configuration:
 *   - URL:      jdbc:mysql://localhost:3306/itserviceflow_db
 *   - Username: root
 *   - Password: (configured below)
 *
 * NOTE: For production, externalize credentials via JNDI DataSource or
 *       environment variables instead of hardcoding here.
 */
public class DBConnection {
    private static final String URL = "jdbc:mysql://localhost:3306/ITSM_db";
    private static final String USER = "root";
    private static final String PASSWORD = "123456";


    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError(
                "MySQL JDBC Driver not found. Add mysql-connector-j to pom.xml\n" + e.getMessage()
            );
        }
    }

    /**
     * Returns a new JDBC connection. Caller is responsible for closing it
     * (use try-with-resources).
     *
     * @return Connection or null if connection fails
     */
    public static Connection getConnection() {
        try {
            return DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Database connection failed!");
            return null;
        }
    }
    
    public static void main(String[] args) {
        System.out.println(DBConnection.getConnection());   
    }

}

