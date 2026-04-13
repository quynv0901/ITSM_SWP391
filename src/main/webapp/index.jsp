<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ITServiceFlow Platform</title>
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background-color: #f8f9fa;
                margin: 0;
                padding: 0;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                min-height: 100vh;
            }

            .header {
                text-align: center;
                margin-bottom: 40px;
            }

            .header h1 {
                color: #0056b3;
                font-size: 36px;
                margin-bottom: 10px;
            }

            .header p {
                color: #6c757d;
                font-size: 18px;
            }

            .cards-container {
                display: flex;
                gap: 30px;
                flex-wrap: wrap;
                justify-content: center;
                max-width: 1000px;
                padding: 20px;
            }

            .card {
                background: white;
                width: 280px;
                padding: 30px;
                border-radius: 12px;
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
                text-align: center;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
                transition: transform 0.3s ease, box-shadow 0.3s ease;
            }

            .card:hover {
                transform: translateY(-5px);
                box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
            }

            .card-icon {
                font-size: 48px;
                margin-bottom: 15px;
            }

            .card-title {
                font-size: 22px;
                color: #343a40;
                font-weight: bold;
                margin-bottom: 15px;
            }

            .card-desc {
                color: #6c757d;
                font-size: 14px;
                margin-bottom: 25px;
                line-height: 1.5;
            }

            .btn {
                padding: 12px 20px;
                background-color: #007bff;
                color: white;
                text-decoration: none;
                border-radius: 6px;
                font-weight: bold;
                transition: background-color 0.2s;
            }

            .btn:hover {
                background-color: #0056b3;
            }

            .btn-purple {
                background-color: #6f42c1;
            }

            .btn-purple:hover {
                background-color: #5a32a3;
            }

            .btn-green {
                background-color: #20c997;
            }

            .btn-green:hover {
                background-color: #17a589;
            }
        </style>
    </head>

    <body>

        <div class="header">
            <h1>ITServiceFlow Platform</h1>
            <p>ITIL-Compliant IT Service Management</p>
        </div>

        <div class="cards-container">
            <!-- Problem Management -->
            <div class="card">
                <div class="card-icon">🧠</div>
                <div class="card-title">Problem Management</div>
                <div class="card-desc">Investigate root causes of recurring incidents. Link multiple incidents,
                    establish workarounds, and track RCA progress.</div>
                <a href="${pageContext.request.contextPath}/problem?action=list" class="btn btn-purple">Go to Problem
                    Tickets</a>
            </div>

            <!-- Known Error DB -->
            <div class="card">
                <div class="card-icon">📚</div>
                <div class="card-title">Known Error DB</div>
                <div class="card-desc">Knowledge repository for recurring technical bugs. Document symptoms, causes, and
                    standardized solutions to help agents.</div>
                <a href="${pageContext.request.contextPath}/known-error?action=list" class="btn">Browse Known Errors</a>
            </div>

            <!-- CMDB -->
            <div class="card">
                <div class="card-icon">🖥️</div>
                <div class="card-title">CMDB</div>
                <div class="card-desc">Configuration Management Database. Map infrastructure relationships, track CIs,
                    and assess the impact of failures.</div>
                <a href="${pageContext.request.contextPath}/cmdb?action=list" class="btn btn-green">Access CMDB
                    Records</a>
            </div>
        </div>

    </body>

</html>
