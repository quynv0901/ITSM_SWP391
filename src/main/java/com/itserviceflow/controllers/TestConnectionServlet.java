package com.itserviceflow.controllers;

import com.itserviceflow.utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;

@WebServlet("/test-connection")
public class TestConnectionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        Connection con = DBConnection.getConnection();

        if (con != null) {
            out.println("<h1 style='color:green'>Database Connected OK</h1>");
        } else {
            out.println("<h1 style='color:red'>Database Connection Failed</h1>");
        }
    }
}