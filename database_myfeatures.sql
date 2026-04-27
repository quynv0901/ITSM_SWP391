-- ================================================================================
-- MY FEATURES DATABASE - ITServiceFlow Platform
-- Author: vumin
-- Chức năng: Ticket Category, Workflow, TimeLog, Dashboard
--
-- Nguyên tắc:
--   - Các bảng có trong DB tổng (itserviceflow_db) được copy Y CHANG cấu trúc,
--     không thêm / bớt cột nào.
--   - Chỉ lấy các bảng liên quan đến 4 chức năng của tác giả.
--   - Dashboard là chức năng mới hoàn toàn → thêm bảng mới là hợp lệ.
--
-- Cách dùng:
--   Trong DBConnection.java đổi URL sang:
--     jdbc:mysql://localhost:3306/itserviceflow_myfeatures_db
--   hoặc giữ itserviceflow_db để dùng DB tổng.
-- ================================================================================

DROP DATABASE IF EXISTS itserviceflow_myfeatures_db;
CREATE DATABASE IF NOT EXISTS itserviceflow_myfeatures_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE itserviceflow_myfeatures_db;


-- ================================================================================
-- PHẦN 1: BẢNG NỀN TẢNG
-- Copy y chang từ DB tổng - cần thiết để các FK hoạt động
-- ================================================================================

CREATE TABLE role (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    permission TEXT,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    CONSTRAINT chk_role_status CHECK (status IN ('ACTIVE', 'INACTIVE'))
);

CREATE TABLE department (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    department_code VARCHAR(20) UNIQUE,
    manager_id INT,
    parent_department_id INT,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    CONSTRAINT chk_dept_status CHECK (status IN ('ACTIVE', 'INACTIVE')),
    FOREIGN KEY (parent_department_id) REFERENCES department(department_id)
);

CREATE TABLE `user` (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    department_id INT,
    role_id INT NOT NULL,
    is_active TINYINT(1) DEFAULT 1,
    reset_token VARCHAR(255),
    reset_token_expires DATETIME NULL,
    reset_token_used TINYINT(1) DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login DATETIME NULL,
    FOREIGN KEY (department_id) REFERENCES department(department_id),
    FOREIGN KEY (role_id) REFERENCES role(role_id)
);

ALTER TABLE department
ADD CONSTRAINT fk_department_manager
FOREIGN KEY (manager_id) REFERENCES `user`(user_id);

CREATE TABLE service (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    service_name VARCHAR(255) NOT NULL,
    service_code VARCHAR(50) UNIQUE,
    description TEXT,
    estimated_delivery_day INT,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_svc_status CHECK (status IN ('ACTIVE', 'INACTIVE'))
);


-- ================================================================================
-- PHẦN 2: TICKET CATEGORY
-- Copy y chang từ DB tổng
-- ================================================================================

CREATE TABLE ticket_category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    category_code VARCHAR(50) UNIQUE,
    category_type VARCHAR(20) NOT NULL,
    difficulty_level VARCHAR(10),
    description TEXT,
    parent_category_id INT,
    is_active TINYINT(1) DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_cat_type CHECK (
        category_type IN ('INCIDENT', 'SERVICE_REQUEST', 'PROBLEM', 'CHANGE', 'KNOWLEDGE')
    ),
    CONSTRAINT chk_cat_diff CHECK (
        difficulty_level IN ('LEVEL_1', 'LEVEL_2', 'LEVEL_3') OR difficulty_level IS NULL
    ),
    FOREIGN KEY (parent_category_id) REFERENCES ticket_category(category_id)
);

CREATE TABLE sla_policy (
    sla_id INT AUTO_INCREMENT PRIMARY KEY,
    policy_name VARCHAR(255) NOT NULL,
    category_id INT NOT NULL,
    priority VARCHAR(10),
    response_time_hour INT NOT NULL,
    resolution_time_hour INT NOT NULL,
    is_active TINYINT(1) DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_sla_priority CHECK (
        priority IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') OR priority IS NULL
    ),
    FOREIGN KEY (category_id) REFERENCES ticket_category(category_id)
);


-- ================================================================================
-- PHẦN 3: WORKFLOW
-- Copy y chang từ DB tổng
-- ================================================================================

CREATE TABLE workflow (
    workflow_id INT AUTO_INCREMENT PRIMARY KEY,
    workflow_name VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'DRAFT',
    workflow_config TEXT,
    created_by INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_wf_status CHECK (status IN ('DRAFT', 'ACTIVE', 'INACTIVE')),
    FOREIGN KEY (created_by) REFERENCES `user`(user_id)
);


-- ================================================================================
-- PHẦN 4: TIME LOG
-- Copy y chang từ DB tổng
-- Cần bảng ticket làm FK tham chiếu -> copy y chang từ DB tổng
-- ================================================================================

CREATE TABLE ticket (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_number VARCHAR(50) UNIQUE NOT NULL,
    ticket_type VARCHAR(20) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(20) NOT NULL,
    priority VARCHAR(10),
    difficulty_level VARCHAR(10),
    category_id INT,
    reported_by INT NOT NULL,
    assigned_to INT,
    department_id INT,
    approval_status VARCHAR(20) DEFAULT 'PENDING',
    approved_by INT,
    approved_at DATETIME NULL,
    rejection_reason TEXT,
    response_due DATETIME NULL,
    resolution_due DATETIME NULL,
    responded_at DATETIME NULL,
    resolved_at DATETIME NULL,
    closed_at DATETIME NULL,
    cancelled_at DATETIME NULL,
    completed_at DATETIME NULL,
    impact VARCHAR(10),
    urgency VARCHAR(10),
    ci_id INT,
    service_id INT,
    justification TEXT,
    cause TEXT,
    solution TEXT,
    change_type VARCHAR(20),
    risk_level VARCHAR(20),
    impact_assessment TEXT,
    rollback_plan TEXT,
    implementation_plan TEXT,
    test_plan TEXT,
    cab_decision VARCHAR(20),
    cab_member_id INT,
    cab_risk_assessment TEXT,
    cab_comment TEXT,
    cab_decided_at DATETIME NULL,
    scheduled_start DATETIME NULL,
    scheduled_end DATETIME NULL,
    actual_start DATETIME NULL,
    actual_end DATETIME NULL,
    downtime_required TINYINT(1) DEFAULT 0,
    estimated_downtime_hour DECIMAL(5,2),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_t_type CHECK (
        ticket_type IN ('INCIDENT', 'SERVICE_REQUEST', 'PROBLEM', 'CHANGE')
    ),
    CONSTRAINT chk_t_status CHECK (
        status IN ('NEW', 'ASSIGNED', 'IN_PROGRESS', 'INVESTIGATING', 'PENDING', 'RESOLVED', 'CLOSED', 'CANCELLED')
    ),
    CONSTRAINT chk_t_priority CHECK (
        priority IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') OR priority IS NULL
    ),
    CONSTRAINT chk_t_diff CHECK (
        difficulty_level IN ('LEVEL_1', 'LEVEL_2', 'LEVEL_3') OR difficulty_level IS NULL
    ),
    CONSTRAINT chk_t_appr CHECK (
        approval_status IN ('PENDING', 'APPROVED', 'REJECTED')
    ),
    CONSTRAINT chk_t_impact CHECK (
        impact IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') OR impact IS NULL
    ),
    CONSTRAINT chk_t_urgency CHECK (
        urgency IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') OR urgency IS NULL
    ),
    CONSTRAINT chk_t_ch_type CHECK (
        change_type IN ('STANDARD', 'NORMAL', 'EMERGENCY') OR change_type IS NULL
    ),
    CONSTRAINT chk_t_risk CHECK (
        risk_level IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') OR risk_level IS NULL
    ),
    CONSTRAINT chk_t_cab CHECK (
        cab_decision IN ('PENDING', 'APPROVED', 'REJECTED') OR cab_decision IS NULL
    ),
    FOREIGN KEY (category_id)   REFERENCES ticket_category(category_id),
    FOREIGN KEY (reported_by)   REFERENCES `user`(user_id),
    FOREIGN KEY (assigned_to)   REFERENCES `user`(user_id),
    FOREIGN KEY (department_id) REFERENCES department(department_id),
    FOREIGN KEY (approved_by)   REFERENCES `user`(user_id),
    FOREIGN KEY (service_id)    REFERENCES service(service_id),
    FOREIGN KEY (cab_member_id) REFERENCES `user`(user_id)
);

CREATE TABLE time_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    user_id INT NOT NULL,
    activity_type VARCHAR(20) NOT NULL,
    time_spent DECIMAL(5,2) NOT NULL,
    description TEXT,
    logged_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id)   REFERENCES `user`(user_id)
);


-- ================================================================================
-- PHẦN 4.5: NOTIFICATION
-- Bảng thông báo từ cơ sở dữ liệu hệ thống (áp dụng cho workflow & các chức năng).
-- ================================================================================

CREATE TABLE notification (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    notification_type VARCHAR(20) NOT NULL,
    title VARCHAR(255),
    message TEXT,
    related_ticket_id INT,
    related_article_id INT, /* Có thể null nếu không link tới bài viết */
    is_seen TINYINT(1) DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_noti_type CHECK (
        notification_type IN ('TICKET', 'ARTICLE', 'SYSTEM', 'SLA', 'APPROVAL', 'WORKFLOW')
    ),
    FOREIGN KEY (user_id) REFERENCES `user`(user_id) ON DELETE CASCADE,
    FOREIGN KEY (related_ticket_id) REFERENCES ticket(ticket_id) ON DELETE SET NULL
);


-- ================================================================================
-- PHẦN 5: DASHBOARD
-- Chức năng mới hoàn toàn của tác giả, không có trong DB tổng
-- ================================================================================

-- Cấu hình dashboard cá nhân theo từng user
CREATE TABLE dashboard_config (
    config_id   INT         AUTO_INCREMENT PRIMARY KEY,
    user_id     INT         NOT NULL UNIQUE,
    layout_json TEXT,
    theme       VARCHAR(20) DEFAULT 'dark',
    refresh_sec INT         DEFAULT 300,
    updated_at  DATETIME    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES `user`(user_id)
);

-- Danh mục các widget có thể hiển thị
CREATE TABLE dashboard_widget (
    widget_id    INT          AUTO_INCREMENT PRIMARY KEY,
    widget_key   VARCHAR(50)  UNIQUE NOT NULL,
    widget_name  VARCHAR(100) NOT NULL,
    description  TEXT,
    default_size VARCHAR(10)  DEFAULT 'medium',
    is_active    TINYINT(1)   DEFAULT 1,
    created_at   DATETIME     DEFAULT CURRENT_TIMESTAMP
);

-- Snapshot KPI theo ngày
CREATE TABLE dashboard_kpi_snapshot (
    snapshot_id        INT           AUTO_INCREMENT PRIMARY KEY,
    snapshot_date      DATE          NOT NULL UNIQUE,
    total_tickets      INT           DEFAULT 0,
    open_tickets       INT           DEFAULT 0,
    resolved_tickets   INT           DEFAULT 0,
    closed_tickets     INT           DEFAULT 0,
    cancelled_tickets  INT           DEFAULT 0,
    avg_resolution_h   DECIMAL(8,2)  DEFAULT 0,
    sla_breach_count   INT           DEFAULT 0,
    total_hours_logged DECIMAL(10,2) DEFAULT 0,
    active_workflows   INT           DEFAULT 0,
    incident_count     INT           DEFAULT 0,
    service_req_count  INT           DEFAULT 0,
    problem_count      INT           DEFAULT 0,
    change_count       INT           DEFAULT 0,
    critical_count     INT           DEFAULT 0,
    high_count         INT           DEFAULT 0,
    medium_count       INT           DEFAULT 0,
    low_count          INT           DEFAULT 0,
    generated_at       DATETIME      DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_kpi_date (snapshot_date)
);

-- Trend theo tuần
CREATE TABLE dashboard_weekly_trend (
    trend_id         INT           AUTO_INCREMENT PRIMARY KEY,
    year_number      SMALLINT      NOT NULL,
    week_number      TINYINT       NOT NULL,
    week_start_date  DATE          NOT NULL,
    tickets_created  INT           DEFAULT 0,
    tickets_resolved INT           DEFAULT 0,
    tickets_breached INT           DEFAULT 0,
    hours_logged     DECIMAL(10,2) DEFAULT 0,
    workflows_fired  INT           DEFAULT 0,
    generated_at     DATETIME      DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_year_week (year_number, week_number)
);

-- Cảnh báo hiển thị trên dashboard
CREATE TABLE dashboard_alert (
    alert_id     INT          AUTO_INCREMENT PRIMARY KEY,
    alert_type   VARCHAR(30)  NOT NULL,
    severity     VARCHAR(10)  DEFAULT 'INFO',
    title        VARCHAR(255) NOT NULL,
    message      TEXT,
    related_id   INT,
    is_dismissed TINYINT(1)   DEFAULT 0,
    dismissed_by INT,
    dismissed_at DATETIME     NULL,
    created_at   DATETIME     DEFAULT CURRENT_TIMESTAMP,
    expires_at   DATETIME     NULL,
    CONSTRAINT chk_alert_sev  CHECK (severity   IN ('INFO','WARNING','ERROR','CRITICAL')),
    CONSTRAINT chk_alert_type CHECK (alert_type IN ('SLA_BREACH','TICKET_SPIKE','UNASSIGNED','WORKFLOW_FAIL','CATEGORY_INACTIVE','TIMELOG_OVERDUE')),
    FOREIGN KEY (dismissed_by) REFERENCES `user`(user_id),
    INDEX idx_alert_type    (alert_type),
    INDEX idx_alert_dismiss (is_dismissed)
);


-- ================================================================================
-- INDEX (copy y chang từ DB tổng cho các bảng liên quan)
-- ================================================================================

CREATE INDEX idx_user_role         ON `user`(role_id);
CREATE INDEX idx_user_department   ON `user`(department_id);
CREATE INDEX idx_ticket_type_status ON ticket(ticket_type, status);
CREATE INDEX idx_ticket_assigned_to ON ticket(assigned_to);
CREATE INDEX idx_ticket_reported_by ON ticket(reported_by);
CREATE INDEX idx_ticket_category   ON ticket(category_id);
CREATE INDEX idx_ticket_department  ON ticket(department_id);
CREATE INDEX idx_ticket_created_at  ON ticket(created_at);


-- ================================================================================
-- DỮ LIỆU MẪU (copy y chang từ DB tổng)
-- ================================================================================

INSERT INTO role (role_name, description, permission) VALUES
('End User',         'Standard end user',    '{"create_incident": true, "create_service_request": true}'),
('Support Agent',    'Support agent',         '{"manage_tickets": true, "create_knowledge_article": true}'),
('Manager',          'Manager',               '{"approve_service_requests": true, "view_reports": true}'),
('General Manager',  'General Manager',       '{"approve_incidents": true, "view_sla_breaches": true}'),
('Technical Expert', 'Technical expert',      '{"manage_problems": true, "create_known_errors": true}'),
('System Engineer',  'System engineer',       '{"create_change": true, "implement_changes": true}'),
('CAB Member',       'CAB member',            '{"review_changes": true, "approve_changes": true}'),
('Asset Manager',    'Asset manager',         '{"manage_cmdb": true, "manage_assets": true}'),
('IT Director',      'IT Director',           '{"view_all_reports": true, "view_dashboards": true}'),
('Admin',            'Administrator',         '{"full_access": true, "manage_users": true}');

INSERT INTO department (department_name, department_code) VALUES
('IT Support',         'IT-SUP'),
('Network Operations', 'NET-OPS'),
('Infrastructure',     'INFRA'),
('Security',           'SEC');

INSERT INTO `user` (username, email, password_hash, full_name, role_id, department_id) VALUES
('admin_user',   'admin@itsm.com',   'hash', 'System Administrator', 10, 1),
('enduser_demo', 'user@itsm.com',    'hash', 'Demo End User',         1, 2),
('agent_01',     'agent01@itsm.com', 'hash', 'Support Agent One',     2, 1);

INSERT INTO ticket_category (category_name, category_code, category_type, difficulty_level, description) VALUES
('Hardware Issues',      'INC-HW',  'INCIDENT',        'LEVEL_1', 'Incidents related to hardware devices'),
('Software Issues',      'INC-SW',  'INCIDENT',        'LEVEL_1', 'Incidents related to software applications'),
('Network Connectivity', 'INC-NET', 'INCIDENT',        'LEVEL_2', 'Network and connectivity incidents'),
('Access Request',       'SR-ACC',  'SERVICE_REQUEST',  NULL,     'Requests for account or system access'),
('Equipment Request',    'SR-EQP',  'SERVICE_REQUEST',  NULL,     'Requests for IT equipment');

INSERT INTO sla_policy (policy_name, category_id, priority, response_time_hour, resolution_time_hour, is_active) VALUES
('Hardware Low Priority SLA',    1, 'LOW',      8, 48, 1),
('Hardware High Priority SLA',   1, 'HIGH',     2,  8, 1),
('Software Medium Priority SLA', 2, 'MEDIUM',   4, 24, 1),
('Network Critical SLA',         3, 'CRITICAL', 1,  4, 1),
('Access Request SLA',           4, 'MEDIUM',   4, 16, 1),
('Equipment Request SLA',        5, 'LOW',      8, 72, 1);

INSERT INTO service (service_name, service_code, description, estimated_delivery_day, status) VALUES
('Email Account Provisioning', 'SRV-EMAIL-001', 'Create and configure a corporate email account for a new user.', 1, 'ACTIVE'),
('Password Reset Service',     'SRV-ACC-001',   'Reset password for internal systems, email, or domain accounts.', 0, 'ACTIVE'),
('Software Installation',      'SRV-SW-001',    'Install approved software on user desktop or laptop devices.', 2, 'ACTIVE'),
('Hardware Request Service',   'SRV-HW-001',    'Provide standard IT hardware such as mouse, keyboard, monitor, or laptop.', 5, 'ACTIVE'),
('VPN Access Request',         'SRV-NET-001',   'Grant VPN access for secure remote connection to internal resources.', 2, 'ACTIVE'),
('Shared Folder Access',       'SRV-FILE-001',  'Grant read or write access to department shared folders.', 1, 'ACTIVE'),
('Printer Setup Service',      'SRV-PRN-001',   'Install and configure network printer access for end users.', 1, 'ACTIVE'),
('New Employee Onboarding',    'SRV-HRIT-001',  'Prepare IT accounts, devices, and access permissions for new employees.', 3, 'ACTIVE'),
('Employee Offboarding',       'SRV-HRIT-002',  'Disable accounts, revoke access, and collect IT assets for departing employees.', 1, 'ACTIVE'),
('Server Access Request',      'SRV-INF-001',   'Grant controlled access to servers for authorized technical staff.', 2, 'ACTIVE'),
('Database Access Request',    'SRV-DB-001',    'Grant database login or schema access for approved users.', 2, 'ACTIVE'),
('Application Access Request', 'SRV-APP-001',   'Provide access to internal business applications based on approval.', 1, 'ACTIVE'),
('Laptop Replacement Service', 'SRV-HW-002',    'Replace old or damaged laptop devices for eligible employees.', 7, 'ACTIVE'),
('Network Port Activation',    'SRV-NET-002',   'Activate or reconfigure office network ports for desktops or IP phones.', 1, 'ACTIVE'),
('Security Access Review',     'SRV-SEC-001',   'Review and update user access permissions for security compliance.', 3, 'ACTIVE');

INSERT INTO ticket (
    ticket_number, ticket_type, title, description, status, priority,
    category_id, reported_by, assigned_to, department_id
) VALUES
('INC-20261000', 'INCIDENT', 'Internal network connection lost',        'Users on the third floor cannot connect to the LAN network.',                        'NEW',          'HIGH',     1, 1, 3, 1),
('INC-20261001', 'INCIDENT', 'Meeting room printer is out of toner',    'The printer shows a toner empty message and cannot print documents.',                 'NEW',          'LOW',      2, 2, 3, 1),
('INC-20261002', 'INCIDENT', 'Accounting software returns error 500',   'The application crashes when exporting the monthly report.',                          'IN_PROGRESS',  'CRITICAL', 3, 1, 3, 1),
('INC-20261003', 'INCIDENT', 'Outlook cannot send email',               'Emails with attachments larger than 20MB remain stuck in the outbox.',                'RESOLVED',     'HIGH',     1, 2, 3, 1),
('INC-20261004', 'INCIDENT', 'WiFi account is locked',                  'The wireless account was locked after multiple failed password attempts.',             'NEW',          'MEDIUM',   1, 1, 3, 1),
('INC-20261005', 'INCIDENT', 'Projector display is blurry',             'The projector in the main meeting room shows color distortion and horizontal lines.', 'NEW',          'LOW',      2, 2, 3, 1),
('INC-20261006', 'INCIDENT', 'Internal website loads slowly',           'The home page takes around 30 seconds to load completely.',                           'INVESTIGATING','HIGH',     3, 1, 3, 1),
('INC-20261007', 'INCIDENT', 'Design software installation error',      'The software reports a license activation problem on workstation P204.',               'RESOLVED',     'MEDIUM',   3, 2, 3, 1),
('INC-20261008', 'INCIDENT', 'Wireless mouse not working properly',     'The mouse disconnects intermittently and input becomes unstable.',                    'NEW',          'LOW',      2, 1, 3, 1),
('INC-20261009', 'INCIDENT', 'Forgot system password',                  'The HR user needs a password reset for the internal system account.',                 'NEW',          'HIGH',     1, 2, 3, 1);

INSERT INTO ticket (
    ticket_number, ticket_type, title, description, status, priority,
    category_id, reported_by, assigned_to, department_id, service_id
) VALUES
('SR-20261010', 'SERVICE_REQUEST', 'Request new email account',     'Need a new email account for a newly hired employee.',            'NEW',        'HIGH',   4, 1, 3, 1,  1),
('SR-20261011', 'SERVICE_REQUEST', 'Request VPN access',            'Need VPN access for remote work during business travel.',         'ASSIGNED',   'MEDIUM', 4, 2, 3, 1,  5),
('SR-20261012', 'SERVICE_REQUEST', 'Install design software',       'Please install approved design software on laptop device.',       'IN_PROGRESS','MEDIUM', 5, 1, 3, 1,  3),
('SR-20261013', 'SERVICE_REQUEST', 'Request shared folder access',  'Need write access to the finance shared folder.',                 'NEW',        'LOW',    4, 2, 3, 1,  6),
('SR-20261014', 'SERVICE_REQUEST', 'Request new laptop',            'Current laptop is outdated and needs replacement.',               'PENDING',    'HIGH',   5, 1, 3, 1, 13);

INSERT INTO workflow (workflow_name, description, status, created_by, workflow_config) VALUES
(
    'Auto-Assign Incident Critical',
    'Tự động assign incident CRITICAL cho Support Agent',
    'ACTIVE', 1,
    '{"trigger":"TICKET_CREATED","conditions":{"logic":"AND","criteria":[{"field":"ticket_type","operator":"EQUALS","value":"INCIDENT"},{"field":"priority","operator":"EQUALS","value":"CRITICAL"}]},"steps":[{"name":"Auto Assign","action":"ASSIGN_AGENT","role":"Support Agent"},{"name":"Set Status","action":"SET_STATUS","value":"IN_PROGRESS"},{"name":"Notify Mgr","action":"NOTIFY","role":"Manager"}]}'
),
(
    'SLA Breach Escalate',
    'Cảnh báo Manager khi ticket vượt SLA',
    'ACTIVE', 1,
    '{"trigger":"SLA_BREACH","sla_hours":4,"conditions":{"logic":"AND","criteria":[]},"steps":[{"name":"Notify Manager","action":"NOTIFY","role":"Manager"}]}'
);

INSERT INTO dashboard_widget (widget_key, widget_name, description, default_size) VALUES
('kpi_summary',         'KPI tổng quan',                'Tổng ticket, open, resolved, giờ công',      'large'),
('ticket_by_status',    'Ticket theo trạng thái',        'Pie/donut chart theo status',                'medium'),
('ticket_by_type',      'Ticket theo loại',              'Bar chart INCIDENT/SR/PROBLEM/CHANGE',       'medium'),
('ticket_by_priority',  'Ticket theo độ ưu tiên',        'Bar chart CRITICAL/HIGH/MEDIUM/LOW',         'medium'),
('timelog_top_agents',  'Agent làm việc nhiều nhất',     'Top 5 agent theo giờ công',                  'medium'),
('timelog_daily_trend', 'Xu hướng giờ công theo ngày',   'Line chart 30 ngày gần nhất',                'large'),
('workflow_status',     'Trạng thái Workflow',            'Số workflow ACTIVE/DRAFT/INACTIVE',          'small'),
('category_dist',       'Phân bố Ticket Category',       'Số ticket theo từng category',               'large'),
('sla_breach_rate',     'Tỷ lệ vi phạm SLA',             'Gauge/line chart breach rate theo tuần',     'medium'),
('alert_panel',         'Cảnh báo hệ thống',              'Danh sách alert chưa dismiss',              'medium');

INSERT INTO dashboard_kpi_snapshot (snapshot_date, active_workflows)
VALUES (CURDATE(), 2);
