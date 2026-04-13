-- ================================================================================
-- ITServiceFlow ITSM Platform - MySQL Database Creation
-- Full Version with Fixes for Constraints and Seeding Order
-- ================================================================================

CREATE DATABASE IF NOT EXISTS ITSM_db;
USE ITSM_db;

-- ================================================================================
-- 1. USER MANAGEMENT (Bản gốc đầy đủ)
-- ================================================================================

CREATE TABLE role (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    permission TEXT,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    CONSTRAINT chk_role_status CHECK (status IN ('ACTIVE' , 'INACTIVE'))
);

CREATE TABLE department (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    department_code VARCHAR(20) UNIQUE,
    manager_id INT,
    parent_department_id INT,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    CONSTRAINT chk_dept_status CHECK (status IN ('ACTIVE' , 'INACTIVE')),
    FOREIGN KEY (parent_department_id) REFERENCES department (department_id)
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
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login DATETIME NULL,
    FOREIGN KEY (department_id) REFERENCES department (department_id),
    FOREIGN KEY (role_id) REFERENCES role (role_id)
);

-- Thêm khóa ngoại manager sau khi bảng user đã được tạo
ALTER TABLE department ADD FOREIGN KEY (manager_id) REFERENCES `user`(user_id);

-- ================================================================================
-- 2. TICKET CATEGORY & SLA
-- ================================================================================

CREATE TABLE ticket_category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    category_code VARCHAR(50) UNIQUE,
    category_type VARCHAR(20) NOT NULL,
    difficulty_level VARCHAR(10), -- Đã thêm cột này từ bản 1
    description TEXT,
    parent_category_id INT,
    is_active TINYINT(1) DEFAULT 1,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_cat_type CHECK (category_type IN ('INCIDENT', 'SERVICE_REQUEST', 'PROBLEM', 'CHANGE', 'KNOWLEDGE')),
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
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_sla_priority CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    FOREIGN KEY (category_id) REFERENCES ticket_category(category_id)
);

-- ================================================================================
-- 3. CMDB
-- ================================================================================

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
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_ci_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'RETIRED', 'UNDER_MAINTENANCE')),
    FOREIGN KEY (ci_type_id) REFERENCES ci_type(type_id),
    FOREIGN KEY (owner_id) REFERENCES `user`(user_id)
);

CREATE TABLE ci_relationship (
    relationship_id INT AUTO_INCREMENT PRIMARY KEY,
    parent_ci_id INT NOT NULL,
    child_ci_id INT NOT NULL,
    relationship_type VARCHAR(20) NOT NULL,
    description TEXT,
    CONSTRAINT chk_rel_type CHECK (relationship_type IN ('DEPENDS_ON', 'CONNECTED_TO', 'RUNS_ON', 'HOSTED_BY', 'PART_OF')),
    FOREIGN KEY (parent_ci_id) REFERENCES configuration_item(ci_id) ON DELETE CASCADE,
    FOREIGN KEY (child_ci_id) REFERENCES configuration_item(ci_id)
);

-- ================================================================================
-- 4. WORKFLOW & SERVICE & TICKET
-- ================================================================================

CREATE TABLE workflow (
    workflow_id INT AUTO_INCREMENT PRIMARY KEY,
    workflow_name VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'DRAFT',
    workflow_config TEXT,
    created_by INT,
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
    CONSTRAINT chk_t_type CHECK (ticket_type IN ('INCIDENT', 'SERVICE_REQUEST', 'PROBLEM', 'CHANGE')),
    CONSTRAINT chk_t_priority CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    CONSTRAINT chk_t_diff CHECK (difficulty_level IN ('LEVEL_1', 'LEVEL_2', 'LEVEL_3')),
    CONSTRAINT chk_t_appr CHECK (approval_status IN ('PENDING', 'APPROVED', 'REJECTED')),
    CONSTRAINT chk_t_impact CHECK (impact IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    CONSTRAINT chk_t_urgency CHECK (urgency IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    CONSTRAINT chk_t_ch_type CHECK (change_type IN ('STANDARD', 'NORMAL', 'EMERGENCY')),
    CONSTRAINT chk_t_risk CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    CONSTRAINT chk_t_cab CHECK (cab_decision IN ('PENDING', 'APPROVED', 'REJECTED')),
    FOREIGN KEY (category_id) REFERENCES ticket_category(category_id),
    FOREIGN KEY (reported_by) REFERENCES `user`(user_id),
    FOREIGN KEY (assigned_to) REFERENCES `user`(user_id),
    FOREIGN KEY (department_id) REFERENCES department(department_id),
    FOREIGN KEY (approved_by) REFERENCES `user`(user_id),
    FOREIGN KEY (ci_id) REFERENCES configuration_item(ci_id),
    FOREIGN KEY (service_id) REFERENCES service(service_id),
    FOREIGN KEY (cab_member_id) REFERENCES `user`(user_id)
);

-- ================================================================================
-- 5. PHẦN CÒN LẠI (History, Comment, Attachment, Article...)
-- ================================================================================

CREATE TABLE ticket_relation (
    relation_id INT AUTO_INCREMENT PRIMARY KEY,
    source_ticket_id INT NOT NULL,
    target_ticket_id INT NOT NULL,
    relation_type VARCHAR(20) NOT NULL,
    created_by INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_rel_ticket CHECK (relation_type IN ('PARENT_CHILD', 'RELATED', 'DUPLICATE', 'BLOCKS', 'CAUSED_BY')),
    FOREIGN KEY (source_ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (target_ticket_id) REFERENCES ticket(ticket_id),
    FOREIGN KEY (created_by) REFERENCES `user`(user_id)
);

CREATE TABLE change_ci (
    link_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    ci_id INT NOT NULL,
    impact_type VARCHAR(20) DEFAULT 'DIRECT',
    CONSTRAINT chk_impact_type CHECK (impact_type IN ('DIRECT', 'INDIRECT')),
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (ci_id) REFERENCES configuration_item(ci_id)
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
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_art_type CHECK (article_type IN ('KNOWLEDGE_BASE', 'KNOWLEDGE_ARTICLE', 'KNOWN_ERROR')),
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
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id)
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
    FOREIGN KEY (user_id) REFERENCES `user`(user_id) ON DELETE CASCADE,
    FOREIGN KEY (related_ticket_id) REFERENCES ticket(ticket_id),
    FOREIGN KEY (related_article_id) REFERENCES article(article_id)
);

-- ================================================================================
-- INITIAL DATA (Seeding)
-- ================================================================================

-- 1. Roles
INSERT INTO role (role_name, description, permission) VALUES
('End-user', 'Standard end user', '{"create_incident": true, "create_service_request": true}'),
('Support Agent', 'Support agent', '{"manage_tickets": true, "create_knowledge_article": true}'),
('Manager', 'Manager', '{"approve_service_requests": true, "view_reports": true}'),
('General Manager', 'General Manager', '{"approve_incidents": true, "view_sla_breaches": true}'),
('Technical Expert', 'Technical expert', '{"manage_problems": true, "create_known_errors": true}'),
('System Engineer', 'System engineer', '{"create_change": true, "implement_changes": true}'),
('CAB Member', 'CAB member', '{"review_changes": true, "approve_changes": true}'),
('Asset Manager', 'Asset manager', '{"manage_cmdb": true, "manage_assets": true}'),
('IT Director', 'IT Director', '{"view_all_reports": true, "view_dashboards": true}'),
('Admin', 'Administrator', '{"full_access": true, "manage_users": true}');

-- 2. Department
INSERT INTO department (department_name, department_code) VALUES
('IT Support', 'IT-SUP'),
('Network Operations', 'IT-NET'),
('Infrastructure', 'IT-INF'),
('Security', 'IT-SEC');

INSERT INTO `user` (username, email, password_hash, full_name, role_id, department_id) VALUES
('quy_admin', 'quy@itsm.com', 'hash', 'Quy Admin', 3, 1),
('nhanvien_test', 'nv@itsm.com', 'hash', 'Nguyen Van A', 1, 2);

ALTER TABLE ticket_category ADD COLUMN difficulty_level VARCHAR(10);

INSERT INTO ticket_category (category_name, category_code, category_type, difficulty_level) VALUES
('Hardware Issues', 'INC-HW', 'INCIDENT', 'LEVEL_1'),
('Software Issues', 'INC-SW', 'INCIDENT', 'LEVEL_1'),
('Network Connectivity', 'INC-NET', 'INCIDENT', 'LEVEL_2'),
('Access Request', 'SR-ACC', 'SERVICE_REQUEST', NULL),
('Equipment Request', 'SR-EQP', 'SERVICE_REQUEST', NULL);

-- 5. CI Type
INSERT INTO ci_type (type_name) VALUES
('Desktop Computer'),
('Laptop'),
('Server'),
('Network Switch'),
('Router'),
('Firewall'),
('Database'),
('Application');


-- 6. Ticket (Sử dụng ID 1 và 2 của User đã nạp ở trên)
INSERT INTO ticket (ticket_number, ticket_type, title, description, status, priority, category_id, reported_by) VALUES
('INC-20261000', 'INCIDENT', 'Mất kết nối mạng nội bộ', 'Không thể kết nối vào mạng LAN ở tầng 3', 'NEW', 'HIGH', 1, 1),
('INC-20261001', 'INCIDENT', 'Máy in phòng họp hết mực', 'Báo lỗi Toner Empty không in được tài liệu', 'NEW', 'LOW', 2, 2),
('INC-20261002', 'INCIDENT', 'Phần mềm kế toán báo lỗi 500', 'Khi xuất báo cáo cuối tháng thì bị văng', 'IN_PROGRESS', 'CRITICAL', 3, 1),
('INC-20261003', 'INCIDENT', 'Không gửi được email Outlook', 'Email có đính kèm file > 20MB bị kẹt trong Outbox', 'RESOLVED', 'HIGH', 1, 2),
('INC-20261004', 'INCIDENT', 'Tài khoản WiFi bị khóa', 'Do nhập sai pass 5 lần liên tiếp', 'NEW', 'MEDIUM', 1, 1),
('INC-20261005', 'INCIDENT', 'Máy chiếu nhòe màu', 'Máy chiếu ở phòng họp lớn bị sọc ngang', 'NEW', 'LOW', 2, 2),
('INC-20261006', 'INCIDENT', 'Website nội bộ load chậm', 'Cần 30s mới load xong trang chủ', 'INVESTIGATING', 'HIGH', 3, 1),
('INC-20261007', 'INCIDENT', 'Lỗi cài đặt phần mềm thiết kế', 'Adobe báo lỗi bản quyền trên máy P204', 'RESOLVED', 'MEDIUM', 3, 2),
('INC-20261008', 'INCIDENT', 'Hỏng chuột không dây', 'Chuột chập chờn lúc nhận lúc không', 'NEW', 'LOW', 2, 1),
('INC-20261009', 'INCIDENT', 'Quên mật khẩu hệ thống', 'Cần reset password tài khoản HR', 'NEW', 'HIGH', 1, 2);
/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Other/SQLTemplate.sql to edit this template
 */
/**
 * Author:  vumin
 * Created: Feb 28, 2026
 */

