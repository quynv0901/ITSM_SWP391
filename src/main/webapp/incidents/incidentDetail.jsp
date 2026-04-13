<%@page import="com.itserviceflow.models.Ticket"%>
<%
    // L?y ??i t??ng ticket t? Request Attribute do Servlet g?i sang
    Ticket t = (Ticket) request.getAttribute("ticket");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Incident Detail</title>

    <style>
        body {
            margin: 0;
            font-family: "Segoe UI", Arial, sans-serif;
            background-color: #f5f7fa;
        }

        /* HEADER */
        .header {
            background-color: #1f2937;
            color: white;
            padding: 15px 30px;
            font-size: 20px;
            font-weight: bold;
        }

        /* CONTAINER */
        .container {
            padding: 30px;
        }

        /* CARD */
        .card {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.08);
        }

        .title {
            font-size: 22px;
            font-weight: bold;
            margin-bottom: 10px;
        }

        /* BADGE */
        .badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
            color: white;
            display: inline-block;
        }

        .NEW { background-color: #3b82f6; }
        .IN_PROGRESS { background-color: #f59e0b; }
        .RESOLVED { background-color: #10b981; }
        .CLOSED { background-color: #6b7280; }

        /* PRIORITY COLORS */
        .HIGH { color: #dc2626; font-weight: bold; }
        .CRITICAL { color: red; font-weight: bold; }

        /* GRID INFO */
        .info-grid {
            display: grid;
            grid-template-columns: 150px 1fr;
            row-gap: 15px;
            margin-top: 20px;
        }

        .label {
            font-weight: bold;
            color: #374151;
        }

        .value {
            color: #111827;
        }

        .section {
            margin-top: 25px;
        }

        .description-box {
            background: #f9fafb;
            padding: 15px;
            border-radius: 6px;
            border: 1px solid #e5e7eb;
            white-space: pre-wrap; /* Gi? nguyên ??nh d?ng xu?ng dòng c?a mô t? */
            margin-top: 10px;
        }

        /* BUTTON */
        .back-btn {
            margin-top: 25px;
            display: inline-block;
            padding: 8px 15px;
            background-color: #2563eb;
            color: white;
            text-decoration: none;
            border-radius: 6px;
            font-size: 14px;
            transition: background 0.2s;
        }

        .back-btn:hover {
            background-color: #1d4ed8;
        }
    </style>
</head>

<body>

    <div class="header">
        ITServiceFlow - Incident Detail
    </div>

    <div class="container">
        <div class="card">
            <% if (t != null) { %>
                
                <div class="title">
                    <%= t.getTicketNumber() %> - <%= t.getTitle() %>
                </div>

                <span class="badge <%= t.getStatus() %>">
                    <%= t.getStatus() %>
                </span>

                <div class="section info-grid">
                    <div class="label">Priority:</div>
                    <div class="value <%= t.getPriority() %>">
                        <%= t.getPriority() %>
                    </div>

                    <div class="label">Reported By:</div>
                    <div class="value">
                        <%= t.getReportedBy() %>
                    </div>

                    <div class="label">Created At:</div>
                    <div class="value">
                        <%= t.getCreatedAt() %>
                    </div>
                </div>

                <div class="section">
                    <div class="label">Description</div>
                    <div class="description-box">
                        <%= (t.getDescription() != null && !t.getDescription().isEmpty()) 
                            ? t.getDescription() : "No description provided." %>
                    </div>
                </div>

                <a href="incident-list" class="back-btn">
                    &larr; Back to Incident List
                </a>

            <% } else { %>
                
                <div style="text-align: center; padding: 20px;">
                    <h3 style="color: #dc2626;">Incident not found</h3>
                    <p>S? c? b?n ?ang tìm ki?m không t?n t?i ho?c ?ã b? xóa.</p>
                    <a href="incident-list" class="back-btn">Return to List</a>
                </div>

            <% } %>
        </div>
    </div>

</body>
</html>