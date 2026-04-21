DROP DATABASE IF EXISTS itserviceflow_db;
CREATE DATABASE IF NOT EXISTS itserviceflow_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
USE itserviceflow_db;

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

CREATE TABLE ci_type (
    type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    CONSTRAINT chk_citype_status CHECK (status IN ('ACTIVE', 'INACTIVE'))
);

CREATE TABLE configuration_item (
    ci_id INT AUTO_INCREMENT PRIMARY KEY,
    ci_name VARCHAR(255) NOT NULL,
    ci_type_id INT NOT NULL,
    ci_code VARCHAR(100) UNIQUE,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    location VARCHAR(255),
    owner_id INT,
    manufacturer VARCHAR(100),
    model VARCHAR(100),
    serial_number VARCHAR(100),
    purchase_date DATE,
    warranty_expiry DATE,
    ip_address VARCHAR(45),
    mac_address VARCHAR(17),
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_ci_status CHECK (
        status IN ('ACTIVE', 'INACTIVE', 'RETIRED', 'UNDER_MAINTENANCE')
    ),
    FOREIGN KEY (ci_type_id) REFERENCES ci_type(type_id),
    FOREIGN KEY (owner_id) REFERENCES `user`(user_id)
);

CREATE TABLE ci_relationship (
    relationship_id INT AUTO_INCREMENT PRIMARY KEY,
    parent_ci_id INT NOT NULL,
    child_ci_id INT NOT NULL,
    relationship_type VARCHAR(20) NOT NULL,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_rel_type CHECK (
        relationship_type IN ('DEPENDS_ON', 'CONNECTED_TO', 'RUNS_ON', 'HOSTED_BY', 'PART_OF')
    ),
    CONSTRAINT chk_ci_not_self CHECK (parent_ci_id <> child_ci_id),
    FOREIGN KEY (parent_ci_id) REFERENCES configuration_item(ci_id) ON DELETE CASCADE,
    FOREIGN KEY (child_ci_id) REFERENCES configuration_item(ci_id) ON DELETE CASCADE
);

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
    FOREIGN KEY (category_id) REFERENCES ticket_category(category_id),
    FOREIGN KEY (reported_by) REFERENCES `user`(user_id),
    FOREIGN KEY (assigned_to) REFERENCES `user`(user_id),
    FOREIGN KEY (department_id) REFERENCES department(department_id),
    FOREIGN KEY (approved_by) REFERENCES `user`(user_id),
    FOREIGN KEY (ci_id) REFERENCES configuration_item(ci_id),
    FOREIGN KEY (service_id) REFERENCES service(service_id),
    FOREIGN KEY (cab_member_id) REFERENCES `user`(user_id)
);

CREATE TABLE ticket_relation (
    relation_id INT AUTO_INCREMENT PRIMARY KEY,
    source_ticket_id INT NOT NULL,
    target_ticket_id INT NOT NULL,
    relation_type VARCHAR(20) NOT NULL,
    created_by INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_rel_ticket CHECK (
        relation_type IN ('PARENT_CHILD', 'RELATED', 'DUPLICATE', 'BLOCKS', 'CAUSED_BY')
    ),
    CONSTRAINT chk_ticket_not_self CHECK (source_ticket_id <> target_ticket_id),
    FOREIGN KEY (source_ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (target_ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES `user`(user_id)
);

CREATE TABLE change_ci (
    link_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    ci_id INT NOT NULL,
    impact_type VARCHAR(20) DEFAULT 'DIRECT',
    CONSTRAINT chk_impact_type CHECK (impact_type IN ('DIRECT', 'INDIRECT')),
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (ci_id) REFERENCES configuration_item(ci_id) ON DELETE CASCADE
);

CREATE TABLE ticket_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    changed_by INT NOT NULL,
    field_name VARCHAR(100),
    old_value TEXT,
    new_value TEXT,
    change_type VARCHAR(20) NOT NULL,
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by) REFERENCES `user`(user_id)
);

CREATE TABLE comment (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    user_id INT NOT NULL,
    comment_text TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES `user`(user_id)
);

CREATE TABLE attachment (
    attachment_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    uploaded_by INT NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    uploaded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (uploaded_by) REFERENCES `user`(user_id)
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
    FOREIGN KEY (user_id) REFERENCES `user`(user_id)
);

CREATE TABLE feedback (
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    user_id INT NOT NULL,
    rating INT NOT NULL,
    feedback_text TEXT,
    agent_id INT,
    submitted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5),
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES `user`(user_id),
    FOREIGN KEY (agent_id) REFERENCES `user`(user_id)
);

CREATE TABLE sla_breach (
    breach_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    sla_id INT NOT NULL,
    breach_type VARCHAR(20) NOT NULL,
    due_at DATETIME NOT NULL,
    breached_at DATETIME NOT NULL,
    breach_duration_minutes INT,
    notified TINYINT(1) DEFAULT 0,
    CONSTRAINT chk_breach_type CHECK (breach_type IN ('RESPONSE', 'RESOLUTION')),
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (sla_id) REFERENCES sla_policy(sla_id)
);

CREATE TABLE article (
    article_id INT AUTO_INCREMENT PRIMARY KEY,
    article_number VARCHAR(50) UNIQUE NOT NULL,
    article_type VARCHAR(20) NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    summary VARCHAR(500),
    category_id INT,
    tag TEXT,
    status VARCHAR(20) NOT NULL,
    author_id INT NOT NULL,
    approved_by INT,
    approved_at DATETIME NULL,
    rejection_reason TEXT,
    published_at DATETIME NULL,
    error_code VARCHAR(50),
    symptom TEXT,
    cause TEXT,
    solution TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_art_type CHECK (
        article_type IN ('KNOWLEDGE_BASE', 'KNOWLEDGE_ARTICLE', 'KNOWN_ERROR')
    ),
    CONSTRAINT chk_art_status CHECK (
        status IN ('DRAFT', 'PENDING', 'APPROVED', 'PUBLISHED', 'REJECTED', 'ARCHIVED')
    ),
    FOREIGN KEY (category_id) REFERENCES ticket_category(category_id),
    FOREIGN KEY (author_id) REFERENCES `user`(user_id),
    FOREIGN KEY (approved_by) REFERENCES `user`(user_id)
);

CREATE TABLE article_ticket (
    link_id INT AUTO_INCREMENT PRIMARY KEY,
    article_id INT NOT NULL,
    ticket_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (article_id) REFERENCES article(article_id) ON DELETE CASCADE,
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE
);

CREATE TABLE notification (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    notification_type VARCHAR(20) NOT NULL,
    title VARCHAR(255),
    message TEXT,
    related_ticket_id INT,
    related_article_id INT,
    is_seen TINYINT(1) DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_noti_type CHECK (
        notification_type IN ('TICKET', 'ARTICLE', 'SYSTEM', 'SLA', 'APPROVAL')
    ),
    FOREIGN KEY (user_id) REFERENCES `user`(user_id) ON DELETE CASCADE,
    FOREIGN KEY (related_ticket_id) REFERENCES ticket(ticket_id) ON DELETE SET NULL,
    FOREIGN KEY (related_article_id) REFERENCES article(article_id) ON DELETE SET NULL
);

CREATE INDEX idx_user_role ON `user`(role_id);
CREATE INDEX idx_user_department ON `user`(department_id);
CREATE INDEX idx_ticket_type_status ON ticket(ticket_type, status);
CREATE INDEX idx_ticket_assigned_to ON ticket(assigned_to);
CREATE INDEX idx_ticket_reported_by ON ticket(reported_by);
CREATE INDEX idx_ticket_category ON ticket(category_id);
CREATE INDEX idx_ticket_department ON ticket(department_id);
CREATE INDEX idx_ticket_created_at ON ticket(created_at);
CREATE INDEX idx_comment_ticket ON comment(ticket_id);
CREATE INDEX idx_history_ticket ON ticket_history(ticket_id);
CREATE INDEX idx_notification_user_seen ON notification(user_id, is_seen);
CREATE INDEX idx_article_category_status ON article(category_id, status);

INSERT INTO role (role_name, description, permission) VALUES
('End User', 'Standard end user', '{"create_incident": true, "create_service_request": true}'),
('Support Agent', 'Support agent', '{"manage_tickets": true, "create_knowledge_article": true}'),
('Manager', 'Manager', '{"approve_service_requests": true, "view_reports": true}'),
('General Manager', 'General Manager', '{"approve_incidents": true, "view_sla_breaches": true}'),
('Technical Expert', 'Technical expert', '{"manage_problems": true, "create_known_errors": true}'),
('System Engineer', 'System engineer', '{"create_change": true, "implement_changes": true}'),
('CAB Member', 'CAB member', '{"review_changes": true, "approve_changes": true}'),
('Asset Manager', 'Asset manager', '{"manage_cmdb": true, "manage_assets": true}'),
('IT Director', 'IT Director', '{"view_all_reports": true, "view_dashboards": true}'),
('Admin', 'Administrator', '{"full_access": true, "manage_users": true}');

INSERT INTO department (department_name, department_code) VALUES
('IT Support', 'IT-SUP'),
('Network Operations', 'NET-OPS'),
('Infrastructure', 'INFRA'),
('Security', 'SEC');

INSERT INTO `user` (username, email, password_hash, full_name, role_id, department_id) VALUES
('admin_user', 'admin@itsm.com', 'hash', 'System Administrator', 10, 1),
('enduser_demo', 'user@itsm.com', 'hash', 'Demo End User', 1, 2),
('agent_01', 'agent01@itsm.com', 'hash', 'Support Agent One', 2, 1);

INSERT INTO ticket_category (category_name, category_code, category_type, difficulty_level, description) VALUES
('Hardware Issues', 'INC-HW', 'INCIDENT', 'LEVEL_1', 'Incidents related to hardware devices'),
('Software Issues', 'INC-SW', 'INCIDENT', 'LEVEL_1', 'Incidents related to software applications'),
('Network Connectivity', 'INC-NET', 'INCIDENT', 'LEVEL_2', 'Network and connectivity incidents'),
('Access Request', 'SR-ACC', 'SERVICE_REQUEST', NULL, 'Requests for account or system access'),
('Equipment Request', 'SR-EQP', 'SERVICE_REQUEST', NULL, 'Requests for IT equipment');

INSERT INTO ci_type (type_name) VALUES
('Desktop Computer'),
('Laptop'),
('Server'),
('Network Switch'),
('Router'),
('Firewall'),
('Database'),
('Application');

INSERT INTO service (service_name, service_code, description, estimated_delivery_day, status) VALUES
('Cấp tài khoản email', 'SRV-EMAIL-001', 'Tạo và cấu hình tài khoản email cho nhân viên mới.', 1, 'ACTIVE'),
('Đặt lại mật khẩu', 'SRV-ACC-001', 'Đặt lại mật khẩu cho hệ thống nội bộ, email hoặc domain.', 0, 'ACTIVE'),
('Cài đặt phần mềm', 'SRV-SW-001', 'Cài đặt phần mềm được phê duyệt trên máy tính người dùng.', 2, 'ACTIVE'),
('Yêu cầu thiết bị phần cứng', 'SRV-HW-001', 'Cấp phát thiết bị IT như chuột, bàn phím, màn hình hoặc laptop.', 5, 'ACTIVE'),
('Yêu cầu truy cập VPN', 'SRV-NET-001', 'Cấp quyền truy cập VPN để kết nối từ xa an toàn.', 2, 'ACTIVE'),
('Cấp quyền thư mục dùng chung', 'SRV-FILE-001', 'Cấp quyền đọc/ghi thư mục nội bộ theo phòng ban.', 1, 'ACTIVE'),
('Cài đặt máy in', 'SRV-PRN-001', 'Cài đặt và cấu hình máy in mạng cho người dùng.', 1, 'ACTIVE'),
('Khởi tạo nhân viên mới', 'SRV-HRIT-001', 'Chuẩn bị tài khoản, thiết bị và quyền truy cập cho nhân viên mới.', 3, 'ACTIVE'),
('Kết thúc nhân viên', 'SRV-HRIT-002', 'Thu hồi tài khoản và tài sản IT của nhân viên nghỉ việc.', 1, 'ACTIVE'),
('Yêu cầu truy cập server', 'SRV-INF-001', 'Cấp quyền truy cập server cho nhân sự kỹ thuật.', 2, 'ACTIVE'),
('Yêu cầu truy cập cơ sở dữ liệu', 'SRV-DB-001', 'Cấp quyền truy cập database cho người dùng được phê duyệt.', 2, 'ACTIVE'),
('Yêu cầu truy cập ứng dụng', 'SRV-APP-001', 'Cấp quyền truy cập các ứng dụng nội bộ.', 1, 'ACTIVE'),
('Thay thế laptop', 'SRV-HW-002', 'Thay thế laptop cũ hoặc bị hỏng.', 7, 'ACTIVE'),
('Kích hoạt cổng mạng', 'SRV-NET-002', 'Kích hoạt hoặc cấu hình lại cổng mạng tại văn phòng.', 1, 'ACTIVE'),
('Rà soát quyền truy cập bảo mật', 'SRV-SEC-001', 'Kiểm tra và cập nhật quyền truy cập để đảm bảo an toàn.', 3, 'ACTIVE');

INSERT INTO ticket (
    ticket_number,
    ticket_type,
    title,
    description,
    status,
    priority,
    category_id,
    reported_by,
    assigned_to,
    department_id
) VALUES
('INC-20261000', 'INCIDENT', 'Mất kết nối mạng nội bộ', 'Người dùng tầng 3 không thể kết nối mạng LAN.', 'NEW', 'HIGH', 1, 1, 3, 1),
('INC-20261001', 'INCIDENT', 'Máy in phòng họp hết mực', 'Máy in hiển thị hết mực và không thể in tài liệu.', 'NEW', 'LOW', 2, 2, 3, 1),
('INC-20261002', 'INCIDENT', 'Phần mềm kế toán lỗi 500', 'Ứng dụng bị crash khi xuất báo cáo tháng.', 'IN_PROGRESS', 'CRITICAL', 3, 1, 3, 1),
('INC-20261003', 'INCIDENT', 'Outlook không gửi được email', 'Email có file đính kèm >20MB bị kẹt.', 'RESOLVED', 'HIGH', 1, 2, 3, 1),
('INC-20261004', 'INCIDENT', 'Tài khoản wifi bị khóa', 'Bị khóa sau nhiều lần nhập sai mật khẩu.', 'NEW', 'MEDIUM', 1, 1, 3, 1),
('INC-20261005', 'INCIDENT', 'Máy chiếu bị mờ', 'Hình ảnh bị nhiễu và sai màu.', 'NEW', 'LOW', 2, 2, 3, 1),
('INC-20261006', 'INCIDENT', 'Website nội bộ tải chậm', 'Trang chủ mất 30 giây để tải.', 'INVESTIGATING', 'HIGH', 3, 1, 3, 1),
('INC-20261007', 'INCIDENT', 'Lỗi cài phần mềm thiết kế', 'Không kích hoạt được license.', 'RESOLVED', 'MEDIUM', 3, 2, 3, 1),
('INC-20261008', 'INCIDENT', 'Chuột không ổn định', 'Chuột bị ngắt kết nối liên tục.', 'NEW', 'LOW', 2, 1, 3, 1),
('INC-20261009', 'INCIDENT', 'Quên mật khẩu hệ thống', 'Người dùng HR cần reset mật khẩu.', 'NEW', 'HIGH', 1, 2, 3, 1);

INSERT INTO ticket (
    ticket_number,
    ticket_type,
    title,
    description,
    status,
    priority,
    category_id,
    reported_by,
    assigned_to,
    department_id,
    service_id
) VALUES
('SR-20261010', 'SERVICE_REQUEST', 'Yêu cầu tạo email mới', 'Cần tạo email cho nhân viên mới.', 'NEW', 'HIGH', 4, 1, 3, 1, 1),
('SR-20261011', 'SERVICE_REQUEST', 'Yêu cầu cấp VPN', 'Cần VPN để làm việc từ xa.', 'ASSIGNED', 'MEDIUM', 4, 2, 3, 1, 5),
('SR-20261012', 'SERVICE_REQUEST', 'Cài phần mềm thiết kế', 'Cài phần mềm thiết kế trên laptop.', 'IN_PROGRESS', 'MEDIUM', 5, 1, 3, 1, 3),
('SR-20261013', 'SERVICE_REQUEST', 'Cấp quyền thư mục', 'Cần quyền ghi thư mục tài chính.', 'NEW', 'LOW', 4, 2, 3, 1, 6),
('SR-20261014', 'SERVICE_REQUEST', 'Yêu cầu laptop mới', 'Laptop hiện tại đã cũ.', 'PENDING', 'HIGH', 5, 1, 3, 1, 13);

INSERT INTO sla_policy (policy_name, category_id, priority, response_time_hour, resolution_time_hour, is_active) VALUES
('Hardware Low Priority SLA', 1, 'LOW', 8, 48, 1),
('Hardware High Priority SLA', 1, 'HIGH', 2, 8, 1),
('Software Medium Priority SLA', 2, 'MEDIUM', 4, 24, 1),
('Network Critical SLA', 3, 'CRITICAL', 1, 4, 1),
('Access Request SLA', 4, 'MEDIUM', 4, 16, 1),
('Equipment Request SLA', 5, 'LOW', 8, 72, 1);

INSERT INTO article (
    article_number,
    article_type,
    title,
    content,
    summary,
    category_id,
    tag,
    status,
    author_id,
    published_at
) VALUES
('KB-20261001', 'KNOWLEDGE_ARTICLE', 'How to reset an internal system password', 'This article explains the standard process for resetting internal system passwords for end users.', 'Password reset guide for internal users.', 4, 'password,account,access', 'PUBLISHED', 3, NOW()),
('KB-20261002', 'KNOWLEDGE_ARTICLE', 'Troubleshooting Outlook send issues', 'Check attachment size, network connection, and mailbox quota when Outlook cannot send emails.', 'Basic troubleshooting for Outlook send failures.', 2, 'outlook,email,troubleshooting', 'PUBLISHED', 3, NOW()),
('KB-20261003', 'KNOWN_ERROR', 'Accounting application error 500 during export', 'A known issue may occur during monthly report export because of incomplete service configuration.', 'Known error for export failure in accounting application.', 2, 'accounting,error500,known-error', 'PUBLISHED', 3, NOW());

INSERT INTO notification (
    user_id,
    notification_type,
    title,
    message,
    related_ticket_id,
    is_seen
) VALUES
(1, 'TICKET', 'New incident created', 'A new incident has been created and assigned for review.', 1, 0),
(2, 'TICKET', 'Your request has been submitted', 'Your service request was submitted successfully.', 11, 0),
(3, 'SLA', 'SLA warning', 'Ticket INC-20261002 is approaching its resolution deadline.', 3, 0),
(1, 'APPROVAL', 'Approval required', 'A pending service request requires manager approval.', 15, 0),
(3, 'ARTICLE', 'Knowledge article published', 'A new knowledge article has been published and is available to agents.', NULL, 0);

INSERT INTO article_ticket (article_id, ticket_id) VALUES
(1, 10),
(2, 4),
(3, 3);