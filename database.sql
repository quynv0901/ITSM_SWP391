-- ============================================================
-- MERGED DATABASE: itserviceflow_db
-- Chiến lược: Giữ itserviceflow_db làm nền,
--   thay configuration_item bằng schema kedb,
--   thêm vendor + maintenance_log,
--   cập nhật CHECK article.
-- ============================================================
DROP DATABASE IF EXISTS itserviceflow_db;
CREATE DATABASE IF NOT EXISTS itserviceflow_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE itserviceflow_db;

-- 1. ROLE
CREATE TABLE role (
    role_id   INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    permission  TEXT,
    status      VARCHAR(20) DEFAULT 'ACTIVE'
);

-- 2. DEPARTMENT
CREATE TABLE department (
    department_id        INT AUTO_INCREMENT PRIMARY KEY,
    department_name      VARCHAR(100) NOT NULL,
    department_code      VARCHAR(20)  UNIQUE,
    manager_id           INT          NULL,
    parent_department_id INT          NULL,
    status               VARCHAR(20)  DEFAULT 'ACTIVE',
    FOREIGN KEY (parent_department_id) REFERENCES department(department_id)
);

-- 3. USER
CREATE TABLE `user` (
    user_id             INT AUTO_INCREMENT PRIMARY KEY,
    username            VARCHAR(100) UNIQUE NOT NULL,
    email               VARCHAR(255) UNIQUE NOT NULL,
    password_hash       VARCHAR(255) NOT NULL,
    full_name           VARCHAR(255) NOT NULL,
    phone               VARCHAR(20),
    department_id       INT,
    role_id             INT NOT NULL,
    is_active           TINYINT(1)  DEFAULT 1,
    reset_token         VARCHAR(255),
    reset_token_expires DATETIME    NULL,
    reset_token_used    TINYINT(1)  DEFAULT 0,
    created_at          DATETIME    DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login          DATETIME    NULL,
    FOREIGN KEY (department_id) REFERENCES department(department_id),
    FOREIGN KEY (role_id)       REFERENCES role(role_id)
);

ALTER TABLE department
    ADD CONSTRAINT fk_dept_manager FOREIGN KEY (manager_id) REFERENCES `user`(user_id);

-- 4. TICKET CATEGORY
CREATE TABLE ticket_category (
    category_id        INT AUTO_INCREMENT PRIMARY KEY,
    category_name      VARCHAR(100) NOT NULL,
    category_code      VARCHAR(50)  UNIQUE,
    category_type      VARCHAR(20)  NOT NULL,
    difficulty_level   VARCHAR(10),
    description        TEXT,
    parent_category_id INT          NULL,
    is_active          TINYINT(1)   DEFAULT 1,
    created_at         DATETIME     DEFAULT CURRENT_TIMESTAMP,
    updated_at         DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_cat_type CHECK (category_type IN ('INCIDENT','SERVICE_REQUEST','PROBLEM','CHANGE','KNOWLEDGE')),
    FOREIGN KEY (parent_category_id) REFERENCES ticket_category(category_id)
);

-- 5. SLA POLICY
CREATE TABLE sla_policy (
    sla_id               INT AUTO_INCREMENT PRIMARY KEY,
    policy_name          VARCHAR(255) NOT NULL,
    category_id          INT NOT NULL,
    priority             VARCHAR(10),
    response_time_hour   INT NOT NULL,
    resolution_time_hour INT NOT NULL,
    is_active            TINYINT(1)  DEFAULT 1,
    created_at           DATETIME    DEFAULT CURRENT_TIMESTAMP,
    updated_at           DATETIME    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES ticket_category(category_id)
);

-- 6. VENDOR (NEW - từ kedb_standalone)
CREATE TABLE vendor (
    vendor_id     INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(150) NOT NULL UNIQUE,
    contact_email VARCHAR(255),
    contact_phone VARCHAR(50),
    address       VARCHAR(255),
    vendor_type   VARCHAR(50)  DEFAULT 'TIER_1',
    status        VARCHAR(20)  DEFAULT 'ACTIVE',
    created_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 7. CONFIGURATION ITEM (schema từ kedb - code Java dùng: name, type, version, vendor_id)
CREATE TABLE configuration_item (
    ci_id         INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    type          VARCHAR(50)  NOT NULL,
    version       VARCHAR(50),
    description   TEXT,
    managed_by    INT          NULL,
    department_id INT          NULL,
    vendor_id     INT          NULL,
    status        VARCHAR(20)  DEFAULT 'ACTIVE',
    created_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_ci_status CHECK (status IN ('ACTIVE','INACTIVE','RETIRED','UNDER_MAINTENANCE')),
    FOREIGN KEY (managed_by)    REFERENCES `user`(user_id)           ON DELETE SET NULL,
    FOREIGN KEY (department_id) REFERENCES department(department_id) ON DELETE SET NULL,
    FOREIGN KEY (vendor_id)     REFERENCES vendor(vendor_id)         ON DELETE SET NULL
);

-- 8. CI RELATIONSHIP
CREATE TABLE ci_relationship (
    relationship_id   INT AUTO_INCREMENT PRIMARY KEY,
    parent_ci_id      INT         NOT NULL,
    child_ci_id       INT         NOT NULL,
    relationship_type VARCHAR(50) NOT NULL,
    description       TEXT,
    created_at        TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_rel (parent_ci_id, child_ci_id, relationship_type),
    CONSTRAINT chk_rel_not_self CHECK (parent_ci_id <> child_ci_id),
    CONSTRAINT chk_rel_type     CHECK (relationship_type IN ('DEPENDS_ON','CONNECTED_TO','RUNS_ON','HOSTED_BY','PART_OF')),
    FOREIGN KEY (parent_ci_id) REFERENCES configuration_item(ci_id) ON DELETE CASCADE,
    FOREIGN KEY (child_ci_id)  REFERENCES configuration_item(ci_id) ON DELETE CASCADE
);

-- 9. MAINTENANCE LOG (NEW - từ kedb_standalone)
CREATE TABLE maintenance_log (
    log_id           INT AUTO_INCREMENT PRIMARY KEY,
    ci_id            INT          NOT NULL,
    maintenance_type VARCHAR(200) NOT NULL,
    maintenance_date DATE         NOT NULL,
    started_at       TIMESTAMP    NULL,
    completed_at     TIMESTAMP    NULL,
    description      TEXT         NOT NULL,
    performed_by     INT          NULL,
    created_by       INT          NULL,
    status           VARCHAR(30)  DEFAULT 'PENDING',
    is_deleted       TINYINT(1)   DEFAULT 0,
    created_at       TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ci_id)        REFERENCES configuration_item(ci_id) ON DELETE CASCADE,
    FOREIGN KEY (performed_by) REFERENCES `user`(user_id)           ON DELETE SET NULL,
    FOREIGN KEY (created_by)   REFERENCES `user`(user_id)           ON DELETE SET NULL
);

-- 10. WORKFLOW
CREATE TABLE workflow (
    workflow_id   INT AUTO_INCREMENT PRIMARY KEY,
    workflow_name VARCHAR(255) NOT NULL,
    description   TEXT,
    status        VARCHAR(20)  DEFAULT 'DRAFT',
    workflow_config TEXT,
    created_by    INT,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES `user`(user_id)
);

-- 11. SERVICE
CREATE TABLE service (
    service_id            INT AUTO_INCREMENT PRIMARY KEY,
    service_name          VARCHAR(255) NOT NULL,
    service_code          VARCHAR(50)  UNIQUE,
    description           TEXT,
    estimated_delivery_day INT,
    status                VARCHAR(20)  DEFAULT 'ACTIVE',
    created_at            DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at            DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 12. TICKET
CREATE TABLE ticket (
    ticket_id            INT AUTO_INCREMENT PRIMARY KEY,
    ticket_number        VARCHAR(50)  UNIQUE NOT NULL,
    ticket_type          VARCHAR(20)  NOT NULL,
    title                VARCHAR(255) NOT NULL,
    description          TEXT         NOT NULL,
    status               VARCHAR(20)  NOT NULL,
    priority             VARCHAR(10),
    difficulty_level     VARCHAR(10),
    category_id          INT,
    reported_by          INT          NOT NULL,
    assigned_to          INT,
    department_id        INT,
    approval_status      VARCHAR(20)  DEFAULT 'PENDING',
    approved_by          INT,
    approved_at          DATETIME     NULL,
    rejection_reason     TEXT,
    response_due         DATETIME     NULL,
    resolution_due       DATETIME     NULL,
    responded_at         DATETIME     NULL,
    resolved_at          DATETIME     NULL,
    closed_at            DATETIME     NULL,
    cancelled_at         DATETIME     NULL,
    completed_at         DATETIME     NULL,
    impact               VARCHAR(10),
    urgency              VARCHAR(10),
    ci_id                INT,
    service_id           INT,
    justification        TEXT,
    cause                TEXT,
    solution             TEXT,
    change_type          VARCHAR(20),
    risk_level           VARCHAR(20),
    impact_assessment    TEXT,
    rollback_plan        TEXT,
    implementation_plan  TEXT,
    test_plan            TEXT,
    cab_decision         VARCHAR(20),
    cab_member_id        INT,
    cab_risk_assessment  TEXT,
    cab_comment          TEXT,
    cab_decided_at       DATETIME     NULL,
    scheduled_start      DATETIME     NULL,
    scheduled_end        DATETIME     NULL,
    actual_start         DATETIME     NULL,
    actual_end           DATETIME     NULL,
    downtime_required    TINYINT(1)   DEFAULT 0,
    estimated_downtime_hour DECIMAL(5,2),
    created_at           DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at           DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_t_type   CHECK (ticket_type IN ('INCIDENT','SERVICE_REQUEST','PROBLEM','CHANGE')),
    CONSTRAINT chk_t_status CHECK (status IN ('NEW','ASSIGNED','IN_PROGRESS','INVESTIGATING','PENDING','RESOLVED','CLOSED','CANCELLED')),
    CONSTRAINT chk_t_appr   CHECK (approval_status IN ('PENDING','APPROVED','REJECTED')),
    FOREIGN KEY (category_id)  REFERENCES ticket_category(category_id),
    FOREIGN KEY (reported_by)  REFERENCES `user`(user_id),
    FOREIGN KEY (assigned_to)  REFERENCES `user`(user_id),
    FOREIGN KEY (department_id) REFERENCES department(department_id),
    FOREIGN KEY (approved_by)  REFERENCES `user`(user_id),
    FOREIGN KEY (ci_id)        REFERENCES configuration_item(ci_id),
    FOREIGN KEY (service_id)   REFERENCES service(service_id),
    FOREIGN KEY (cab_member_id) REFERENCES `user`(user_id)
);

-- 13. CÁC BẢNG PHỤ
CREATE TABLE ticket_relation (
    relation_id      INT AUTO_INCREMENT PRIMARY KEY,
    source_ticket_id INT NOT NULL,
    target_ticket_id INT NOT NULL,
    relation_type    VARCHAR(20) NOT NULL,
    created_by       INT NOT NULL,
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_ticket_not_self CHECK (source_ticket_id <> target_ticket_id),
    FOREIGN KEY (source_ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (target_ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES `user`(user_id)
);

CREATE TABLE change_ci (
    link_id     INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id   INT NOT NULL,
    ci_id       INT NOT NULL,
    impact_type VARCHAR(20) DEFAULT 'DIRECT',
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (ci_id)     REFERENCES configuration_item(ci_id) ON DELETE CASCADE
);

CREATE TABLE ticket_history (
    history_id  INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id   INT NOT NULL,
    changed_by  INT NOT NULL,
    field_name  VARCHAR(100),
    old_value   TEXT,
    new_value   TEXT,
    change_type VARCHAR(20) NOT NULL,
    changed_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id)  REFERENCES ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by) REFERENCES `user`(user_id)
);

CREATE TABLE comment (
    comment_id   INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id    INT NOT NULL,
    user_id      INT NOT NULL,
    comment_text TEXT NOT NULL,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id)   REFERENCES `user`(user_id)
);

CREATE TABLE attachment (
    attachment_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id     INT NOT NULL,
    uploaded_by   INT NOT NULL,
    file_name     VARCHAR(255) NOT NULL,
    file_path     VARCHAR(500) NOT NULL,
    uploaded_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id)   REFERENCES ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (uploaded_by) REFERENCES `user`(user_id)
);

CREATE TABLE time_log (
    log_id        INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id     INT NOT NULL,
    user_id       INT NOT NULL,
    activity_type VARCHAR(20)    NOT NULL,
    time_spent    DECIMAL(5,2)   NOT NULL,
    description   TEXT,
    logged_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id)   REFERENCES `user`(user_id)
);

CREATE TABLE feedback (
    feedback_id   INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id     INT NOT NULL,
    user_id       INT NOT NULL,
    rating        INT NOT NULL,
    feedback_text TEXT,
    agent_id      INT,
    submitted_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5),
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id)   REFERENCES `user`(user_id),
    FOREIGN KEY (agent_id)  REFERENCES `user`(user_id)
);

CREATE TABLE sla_breach (
    breach_id              INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id              INT NOT NULL,
    sla_id                 INT NOT NULL,
    breach_type            VARCHAR(20) NOT NULL,
    due_at                 DATETIME NOT NULL,
    breached_at            DATETIME NOT NULL,
    breach_duration_minutes INT,
    notified               TINYINT(1) DEFAULT 0,
    CONSTRAINT chk_breach_type CHECK (breach_type IN ('RESPONSE','RESOLUTION')),
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (sla_id)    REFERENCES sla_policy(sla_id)
);

-- 14. ARTICLE (thêm INACTIVE vào CHECK status)
CREATE TABLE article (
    article_id       INT AUTO_INCREMENT PRIMARY KEY,
    article_number   VARCHAR(50)  UNIQUE NOT NULL,
    article_type     VARCHAR(20)  NOT NULL,
    title            VARCHAR(255) NOT NULL,
    content          TEXT         NOT NULL,
    summary          VARCHAR(500),
    category_id      INT          NULL,
    tag              TEXT,
    status           VARCHAR(20)  NOT NULL,
    author_id        INT          NOT NULL,
    approved_by      INT          NULL,
    approved_at      DATETIME     NULL,
    rejection_reason TEXT,
    published_at     DATETIME     NULL,
    error_code       VARCHAR(50),
    symptom          TEXT,
    cause            TEXT,
    solution         TEXT,
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_art_type   CHECK (article_type IN ('KNOWLEDGE_BASE','KNOWLEDGE_ARTICLE','KNOWN_ERROR')),
    CONSTRAINT chk_art_status CHECK (status IN ('DRAFT','PENDING','APPROVED','PUBLISHED','REJECTED','ARCHIVED','INACTIVE')),
    FOREIGN KEY (category_id) REFERENCES ticket_category(category_id),
    FOREIGN KEY (author_id)   REFERENCES `user`(user_id),
    FOREIGN KEY (approved_by) REFERENCES `user`(user_id)
);

CREATE TABLE article_ticket (
    link_id    INT AUTO_INCREMENT PRIMARY KEY,
    article_id INT NOT NULL,
    ticket_id  INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (article_id) REFERENCES article(article_id)  ON DELETE CASCADE,
    FOREIGN KEY (ticket_id)  REFERENCES ticket(ticket_id)    ON DELETE CASCADE
);

CREATE TABLE notification (
    notification_id    INT AUTO_INCREMENT PRIMARY KEY,
    user_id            INT NOT NULL,
    notification_type  VARCHAR(20) NOT NULL,
    title              VARCHAR(255),
    message            TEXT,
    related_ticket_id  INT,
    related_article_id INT,
    is_seen            TINYINT(1)  DEFAULT 0,
    created_at         DATETIME    DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_noti_type CHECK (notification_type IN ('TICKET','ARTICLE','SYSTEM','SLA','APPROVAL')),
    FOREIGN KEY (user_id)            REFERENCES `user`(user_id)    ON DELETE CASCADE,
    FOREIGN KEY (related_ticket_id)  REFERENCES ticket(ticket_id)  ON DELETE SET NULL,
    FOREIGN KEY (related_article_id) REFERENCES article(article_id) ON DELETE SET NULL
);

-- INDEXES
CREATE INDEX idx_user_role         ON `user`(role_id);
CREATE INDEX idx_user_department   ON `user`(department_id);
CREATE INDEX idx_ticket_type_status ON ticket(ticket_type, status);
CREATE INDEX idx_ticket_assigned   ON ticket(assigned_to);
CREATE INDEX idx_ticket_reported   ON ticket(reported_by);
CREATE INDEX idx_ticket_category   ON ticket(category_id);
CREATE INDEX idx_ticket_created    ON ticket(created_at);
CREATE INDEX idx_comment_ticket    ON comment(ticket_id);
CREATE INDEX idx_history_ticket    ON ticket_history(ticket_id);
CREATE INDEX idx_notif_user_seen   ON notification(user_id, is_seen);
CREATE INDEX idx_article_cat_stat  ON article(category_id, status);

-- ============================================================
-- DATA
-- ============================================================

INSERT INTO role (role_name, description, permission) VALUES
('Người dùng cuối',     'Nhân viên thông thường',          '{"create_incident":true}'),
('Nhân viên hỗ trợ',   'Tiếp nhận và xử lý sự cố',        '{"manage_tickets":true}'),
('Quản lý',             'Giám sát vận hành',               '{"approve_service_requests":true}'),
('Tổng quản lý',        'Quản lý cấp cao',                 '{"view_sla_breaches":true}'),
('Chuyên gia kỹ thuật', 'Phân tích nguyên nhân gốc rễ',   '{"manage_problems":true}'),
('Kỹ sư hệ thống',      'Quản trị hạ tầng và mạng',       '{"create_change":true}'),
('Thành viên CAB',      'Hội đồng Tư vấn Thay đổi',       '{"approve_changes":true}'),
('Quản lý tài sản',     'Quản lý CMDB và kho tài sản',    '{"manage_cmdb":true}'),
('Giám đốc IT',         'Lãnh đạo bộ phận IT',            '{"view_dashboards":true}'),
('Quản trị hệ thống',   'Quyền đầy đủ nền tảng',          '{"full_access":true}');

INSERT INTO department (department_name, department_code) VALUES
('Bộ phận Hỗ trợ IT',  'IT-SUP'),
('Vận hành Mạng',       'NET-OPS'),
('Phát triển Phần mềm', 'DEV'),
('Vận hành Bảo mật',    'SEC-OPS'),
('Hạ tầng & Máy chủ',   'INFRA'),
('Bàn trợ giúp',        'HD');

INSERT INTO `user` (username, email, password_hash, full_name, role_id, department_id) VALUES
('admin',     'admin@itsm.com',     '123123', 'Nguyễn Quản Trị',  10, 1),
('manager',   'manager@itsm.com',   '123123', 'Trần Văn Quản',     3, 1),
('tech',      'tech@itsm.com',      '123123', 'Lê Chuyên Gia',     5, 2),
('agent1',    'agent1@itsm.com',    '123123', 'Phạm Thị Hỗ Trợ',  2, 1),
('agent2',    'agent2@itsm.com',    '123123', 'Hoàng Văn Minh',    2, 1),
('tech2',     'tech2@itsm.com',     '123123', 'Ngô Thị Kỹ Thuật', 5, 2),
('tech3',     'tech3@itsm.com',     '123123', 'Đặng Quốc Hùng',   5, 2),
('engineer1', 'engineer1@itsm.com', '123123', 'Vũ Hệ Thống',      6, 2),
('asset',     'assetmgr@itsm.com',  '123123', 'Bùi Tài Sản',      8, 5),
('director',  'director@itsm.com',  '123123', 'Phan Giám Đốc',    9, 1),
('enduser1',  'enduser1@itsm.com',  '123123', 'Đinh Văn An',      1, 3),
('enduser2',  'enduser2@itsm.com',  '123123', 'Trịnh Thị Bình',   1, 4);

INSERT INTO ticket_category (category_name, category_code, category_type, difficulty_level, description) VALUES
('Kết nối mạng',        'INC-NET',  'INCIDENT',       'LEVEL_2', 'Sự cố WiFi và mạng LAN'),
('Hỏng phần cứng',      'INC-HW',   'INCIDENT',       'LEVEL_1', 'Thiết bị phần cứng hỏng'),
('Lỗi phần mềm',        'INC-SW',   'INCIDENT',       'LEVEL_1', 'Lỗi ứng dụng'),
('Sự cố bảo mật',       'INC-SEC',  'INCIDENT',       'LEVEL_3', 'Vi phạm bảo mật'),
('Email & Liên lạc',    'INC-MAIL', 'INCIDENT',       'LEVEL_1', 'Lỗi email'),
('Quyền truy cập',      'INC-ACC',  'INCIDENT',       'LEVEL_1', 'Khóa tài khoản'),
('Giảm hiệu năng',      'INC-PERF', 'INCIDENT',       'LEVEL_2', 'Hệ thống chậm'),
('Sao lưu & Phục hồi',  'PRB-BCK',  'PROBLEM',        NULL,      'Lỗi sao lưu'),
('Hạ tầng mạng',        'PRB-NET',  'PROBLEM',        NULL,      'Vấn đề thiết kế mạng'),
('Yêu cầu truy cập',    'SR-ACC',   'SERVICE_REQUEST', NULL,     'Tài khoản, quyền truy cập'),
('Yêu cầu thiết bị',    'SR-EQP',   'SERVICE_REQUEST', NULL,     'Thiết bị IT');

INSERT INTO sla_policy (policy_name, category_id, priority, response_time_hour, resolution_time_hour) VALUES
('Phần cứng - Ưu tiên thấp',  2, 'LOW',      8,  48),
('Phần cứng - Ưu tiên cao',   2, 'HIGH',     2,   8),
('Phần mềm - Trung bình',     3, 'MEDIUM',   4,  24),
('Mạng - Khẩn cấp',           1, 'CRITICAL', 1,   4),
('Yêu cầu truy cập',         10, 'MEDIUM',   4,  16),
('Yêu cầu thiết bị',         11, 'LOW',      8,  72);

INSERT INTO vendor (name, contact_email, contact_phone, address, vendor_type, status) VALUES
('Dell Technologies',       'support.vn@dell.com',      '1800 545455',      'TP. Hồ Chí Minh',  'TIER_1', 'ACTIVE'),
('FPT Information System',  'fis.support@fpt.com',      '1900 6600',        'Cầu Giấy, Hà Nội', 'TIER_1', 'ACTIVE'),
('Cisco Vietnam',           'vietnam_support@cisco.com', '+84 28 3824 0200', 'Quận 1, TP.HCM',   'TIER_1', 'ACTIVE'),
('Microsoft Vietnam',       'contact@microsoft.vn',     '1900 1234',        'Quận 1, TP.HCM',   'TIER_2', 'ACTIVE'),
('Oracle Asia',             'support@oracle.com',       '+65 6333 1234',    'Singapore',         'TIER_2', 'ACTIVE'),
('VMware Corp',             'info@vmware.com',           '+1 800 555 1234', 'California, USA',   'TIER_3', 'ACTIVE');

INSERT INTO configuration_item (name, type, version, description, managed_by, department_id, vendor_id, status) VALUES
('Máy chủ Web Ứng dụng 01',        'Hardware', 'Ubuntu 22.04 LTS',   'Máy chủ web chính chạy ITSM',          9, 5, 1, 'ACTIVE'),
('Máy chủ Cơ sở dữ liệu chính',    'Hardware', 'Ubuntu 20.04 LTS',   'Máy chủ MySQL chính',                  9, 5, 5, 'ACTIVE'),
('Tường lửa (Vành đai)',            'Hardware', 'Fortinet FortiOS',   'Tường lửa bảo vệ hệ thống',            9, 2, 3, 'ACTIVE'),
('Switch Lõi - Tầng 1',            'Network',  'Cisco IOS 15.2',     'Switch 48 cổng quản lý',               9, 2, 3, 'ACTIVE'),
('Điểm truy cập WiFi - Văn phòng', 'Network',  'Cisco Aironet 2800', 'Access point phủ sóng văn phòng',     9, 2, 3, 'ACTIVE'),
('Ứng dụng Web ITSM',              'Software', 'v2.4.1',             'Nền tảng quản lý ITSM',                9, 1, 2, 'ACTIVE'),
('MySQL Database (Chính)',          'Software', '8.0.36',             'Cơ sở dữ liệu chính',                  9, 5, 5, 'ACTIVE'),
('Microsoft 365 (Exchange)',        'Service',  'N/A',                'Dịch vụ mail đám mây',                 9, 1, 4, 'ACTIVE'),
('Cổng VPN cũ (OpenVPN)',           'Software', 'v2.4.9',             'Đã thay bằng Cisco AnyConnect',        9, 2, 6, 'RETIRED');

INSERT INTO ci_relationship (parent_ci_id, child_ci_id, relationship_type, description) VALUES
(1, 6, 'RUNS_ON',      'Ứng dụng ITSM chạy trên Máy chủ Web 01'),
(2, 7, 'RUNS_ON',      'MySQL chạy trên Máy chủ CSDL vật lý'),
(7, 6, 'DEPENDS_ON',   'Ứng dụng ITSM phụ thuộc vào MySQL'),
(4, 1, 'CONNECTED_TO', 'Máy chủ Web 01 kết nối qua Switch Tầng 1'),
(4, 2, 'CONNECTED_TO', 'Máy chủ CSDL kết nối qua Switch Tầng 1'),
(3, 4, 'CONNECTED_TO', 'Tường lửa kiểm soát lưu lượng vào Switch');

INSERT INTO maintenance_log (ci_id, maintenance_type, maintenance_date, description, performed_by, created_by, status) VALUES
(1, 'Cập nhật Firmware',   '2026-03-10', 'Cập nhật Ubuntu lên 22.04.3 LTS và khởi động lại dịch vụ.',           9, 9, 'COMPLETED'),
(2, 'Bảo dưỡng định kỳ',  '2026-03-15', 'Kiểm tra ổ cứng và dọn dẹp dung lượng trống hàng tháng.',             9, 9, 'COMPLETED'),
(3, 'Vá lỗi bảo mật',     '2026-04-01', 'Vá lỗ hổng CVE-2026-1234 trên Tường lửa cứng. Yêu cầu restart nhẹ.',  9, 9, 'COMPLETED'),
(4, 'Thay thế linh kiện', '2026-04-10', 'Thay module quang (SFP) lỗi port 2 và cấu hình lại VLAN.',             9, 9, 'PENDING'),
(5, 'Kiểm tra tín hiệu',  '2026-04-12', 'Kiểm tra suy hao tín hiệu cáp quang tầng 3. Đường truyền chập chờn.', 9, 9, 'COMPLETED'),
(6, 'Nâng cấp RAM',       '2026-04-14', 'Nâng RAM máy chủ ảo hóa từ 64GB lên 128GB - liên hệ nhà cung cấp.',   9, 9, 'CONTACTED_VENDOR');

INSERT INTO service (service_name, service_code, description, estimated_delivery_day, status) VALUES
('Cấp tài khoản email',          'SRV-EMAIL-001', 'Tạo email cho nhân viên mới.',                    1, 'ACTIVE'),
('Đặt lại mật khẩu',             'SRV-ACC-001',   'Reset mật khẩu hệ thống nội bộ.',                0, 'ACTIVE'),
('Cài đặt phần mềm',             'SRV-SW-001',    'Cài phần mềm được phê duyệt.',                   2, 'ACTIVE'),
('Yêu cầu thiết bị phần cứng',   'SRV-HW-001',    'Cấp phát chuột, bàn phím, màn hình, laptop.',    5, 'ACTIVE'),
('Yêu cầu truy cập VPN',         'SRV-NET-001',   'Cấp quyền VPN kết nối từ xa.',                   2, 'ACTIVE'),
('Cấp quyền thư mục dùng chung', 'SRV-FILE-001',  'Cấp quyền thư mục nội bộ theo phòng ban.',       1, 'ACTIVE'),
('Cài đặt máy in',               'SRV-PRN-001',   'Cấu hình máy in mạng.',                          1, 'ACTIVE'),
('Khởi tạo nhân viên mới',       'SRV-HRIT-001',  'Tài khoản, thiết bị, quyền cho nhân viên mới.',  3, 'ACTIVE'),
('Kết thúc nhân viên',           'SRV-HRIT-002',  'Thu hồi tài khoản và tài sản IT.',               1, 'ACTIVE'),
('Yêu cầu truy cập server',      'SRV-INF-001',   'Cấp quyền truy cập server kỹ thuật.',            2, 'ACTIVE'),
('Yêu cầu truy cập CSDL',        'SRV-DB-001',    'Cấp quyền database được phê duyệt.',             2, 'ACTIVE'),
('Yêu cầu truy cập ứng dụng',    'SRV-APP-001',   'Cấp quyền ứng dụng nội bộ.',                    1, 'ACTIVE'),
('Thay thế laptop',              'SRV-HW-002',    'Thay laptop cũ hoặc hỏng.',                      7, 'ACTIVE'),
('Kích hoạt cổng mạng',          'SRV-NET-002',   'Kích hoạt cổng mạng tại văn phòng.',             1, 'ACTIVE'),
('Rà soát quyền truy cập',       'SRV-SEC-001',   'Kiểm tra và cập nhật quyền bảo mật.',            3, 'ACTIVE');

INSERT INTO ticket (ticket_number, ticket_type, title, description, status, priority, category_id, reported_by, assigned_to, department_id) VALUES
('INC-20261000','INCIDENT','Mất kết nối mạng nội bộ',    'Tầng 3 không kết nối mạng LAN.', 'NEW',         'HIGH',     1, 1, 4, 1),
('INC-20261001','INCIDENT','Máy in phòng họp hết mực',   'Máy in không in được tài liệu.', 'NEW',         'LOW',      2, 2, 4, 1),
('INC-20261002','INCIDENT','Phần mềm kế toán lỗi 500',   'Crash khi xuất báo cáo tháng.', 'IN_PROGRESS', 'CRITICAL', 3, 1, 4, 1),
('INC-20261003','INCIDENT','Outlook không gửi được mail', 'Email trên 20MB bị kẹt.',       'RESOLVED',    'HIGH',     5, 2, 4, 1),
('INC-20261004','INCIDENT','Tài khoản wifi bị khóa',     'Khóa sau nhiều lần nhập sai.',   'NEW',         'MEDIUM',   6, 1, 4, 1);

INSERT INTO ticket (ticket_number, ticket_type, title, description, status, priority, category_id, reported_by, assigned_to, department_id, service_id) VALUES
('SR-20261010','SERVICE_REQUEST','Tạo email nhân viên mới','Cần tạo email nhân viên mới.',         'NEW',       'HIGH',   10, 1, 4, 1, 1),
('SR-20261011','SERVICE_REQUEST','Yêu cầu cấp VPN',       'Cần VPN để làm việc từ xa.',            'ASSIGNED',  'MEDIUM', 10, 2, 4, 1, 5),
('SR-20261012','SERVICE_REQUEST','Cài phần mềm thiết kế', 'Cài phần mềm thiết kế trên laptop.',   'IN_PROGRESS','MEDIUM', 11, 1, 4, 1, 3),
('SR-20261013','SERVICE_REQUEST','Cấp quyền thư mục',     'Cần quyền ghi thư mục tài chính.',     'NEW',       'LOW',    10, 2, 4, 1, 6),
('SR-20261014','SERVICE_REQUEST','Yêu cầu laptop mới',    'Laptop hiện tại đã cũ và chậm.',       'PENDING',   'HIGH',   11, 1, 4, 1, 13);

INSERT INTO article (article_number, article_type, title, content, summary, category_id, status, author_id, symptom, cause, solution) VALUES
('KE-0001','KNOWN_ERROR','Cạn kiệt pool kết nối database gây sập Tomcat',
 'Pool kết nối bị cạn kiệt khi tải cao, Tomcat ngừng phục vụ yêu cầu.',
 'Rò rỉ kết nối JDBC do không đóng đúng cách.',1,'APPROVED',3,
 'Lỗi AbandonedConnectionCleanupThread; HTTP 500.',
 'Kết nối không đóng sau sử dụng.',
 '1. Dùng try-with-resources.\n2. Tăng pool size.\n3. Restart Tomcat.'),
('KE-0002','KNOWN_ERROR','Tài khoản AD bị khóa tự động sau giờ làm việc',
 'Tài khoản bị khóa qua đêm do phiên Kerberos hết hạn từ ổ đĩa mạng.',
 'Phiên Kerberos hết hạn gây xác thực thất bại.',6,'APPROVED',3,
 'Tài khoản bị khóa mỗi sáng. Event ID 4740 lúc 02:00-03:00.',
 'Ổ đĩa mạng thử xác thực lại với mật khẩu cũ.',
 '1. Xóa Credential Manager.\n2. Ánh xạ lại ổ đĩa.\n3. Bật Fine-Grained Password Policy.'),
('KE-0003','KNOWN_ERROR','Chứng chỉ SSL hết hạn gây gián đoạn dịch vụ',
 'Dịch vụ nội bộ không truy cập khi SSL hết hạn.',
 'Chứng chỉ hết hạn, không có gia hạn tự động.',4,'APPROVED',9,
 'Lỗi NET::ERR_CERT_DATE_INVALID.',
 'Chứng chỉ cấp thủ công, không tự gia hạn.',
 '1. Gia hạn chứng chỉ.\n2. Triển khai Certbot.\n3. Cảnh báo 30 ngày trước hết hạn.'),
('KE-0004','KNOWN_ERROR','Email gửi chậm trong giờ cao điểm',
 'Email trễ 15-45 phút do SMTP relay giới hạn tốc độ.',
 'Hàng đợi SMTP tắc nghẽn.',5,'APPROVED',3,
 '"421 Too many connections" từ relay.',
 'Relay giới hạn 100 email/phút, hệ thống vượt ngưỡng.',
 '1. Giới hạn 80 email/phút.\n2. Batch ngoài giờ cao điểm.\n3. Dùng SendGrid.'),
('KE-0005','KNOWN_ERROR','VPN tự ngắt khi máy tính ngủ',
 'VPN ngắt khi sleep, không tự kết nối lại.',
 'Phiên VPN không duy trì qua trạng thái ngủ.',1,'APPROVED',9,
 'Sau gập laptop, VPN hiển thị Connection Terminated.',
 'AnyConnect chưa bật Always-On.',
 '1. Bật Always-On.\n2. Tắt power management NIC.\n3. Cập nhật AnyConnect v4.10+.'),
('KE-0006','KNOWN_ERROR','Độ trễ sao chép MySQL vượt SLA',
 'Bản sao đọc MySQL tụt hậu hơn 60 giây khi ETL.',
 'ETL batch lớn chặn luồng SQL bản sao.',9,'PENDING',3,
 'Seconds_Behind_Master tăng 60-300s lúc 01:00-03:00.',
 'INSERT/UPDATE hàng loạt gây nút thắt.',
 '1. Chia ETL batch 1000 dòng.\n2. replica_parallel_workers=4.\n3. Cảnh báo khi lag > 30s.'),
('KE-0007','KNOWN_ERROR','Cập nhật Windows 11 24H2 làm hỏng driver máy in',
 'Sau cài KB5043145, máy in IPP không hoạt động.',
 'KB5043145 gây hồi quy driver IPP.',3,'APPROVED',9,
 'Lệnh in vào hàng đợi nhưng không xử lý. Lỗi 0x00000bc4.',
 'KB5043145 phá vỡ IPP print class driver.',
 '1. Cài lại driver nhà sản xuất.\n2. Gỡ KB5043145.\n3. Chặn update qua WSUS.'),
('KE-0008','KNOWN_ERROR','Grafana không hiển thị dữ liệu sau restart Prometheus',
 'Dashboard hiển thị No data sau khi khởi động lại Prometheus.',
 'WAL TSDB không xả đúng cách khi tắt.',7,'INACTIVE',3,
 'Khoảng trắng trên panel. Log báo "incomplete block".',
 'Prometheus bị tắt bằng SIGKILL thay vì SIGTERM.',
 '1. Dùng systemctl stop prometheus.\n2. Cấu hình remote_write.\n3. Bật WAL compression.');

INSERT INTO notification (user_id, notification_type, title, message, related_ticket_id, is_seen) VALUES
(1, 'TICKET',   'Sự cố mới được tạo',       'INC-20261000 đang chờ xử lý.',                  1,  0),
(2, 'TICKET',   'Yêu cầu gửi thành công',   'SR-20261010 đã được ghi nhận.',                 6,  0),
(4, 'SLA',      'Cảnh báo SLA',             'INC-20261002 sắp vượt thời hạn xử lý.',         3,  0),
(1, 'APPROVAL', 'Cần phê duyệt',            'SR-20261014 đang chờ phê duyệt quản lý.',       10, 0),
(4, 'ARTICLE',  'Bài viết mới được duyệt',  'KE-0001 vừa được duyệt, có thể tra cứu.',       NULL, 0);

-- Problem tickets (6 bản ghi)
INSERT INTO ticket (ticket_number, ticket_type, title, description, status, priority, category_id, reported_by, assigned_to, department_id, cause, solution) VALUES
('PRB-20261001', 'PROBLEM',
 'Mạng nội bộ mất kết nối lặp lại nhiều lần',
 'Trong 2 tuần qua, mạng LAN tầng 3 bị gián đoạn ít nhất 3 lần/tuần vào giờ cao điểm. Các sự cố INC lặp đi lặp lại nhưng chưa tìm ra nguyên nhân gốc.',
 'INVESTIGATING', 'HIGH', 9, 3, 3, 2, NULL, NULL),

('PRB-20261002', 'PROBLEM',
 'Máy chủ web phản hồi chậm bất thường sau 22:00',
 'Từ sau bản cập nhật v2.4.0, máy chủ web có thời gian phản hồi tăng gấp 3-5 lần sau 22:00. Ảnh hưởng đến batch job ban đêm.',
 'IN_PROGRESS', 'CRITICAL', 9, 3, 3, 2,
 'Tác vụ dọn dẹp log cạnh tranh tài nguyên với batch job đêm.', NULL),

('PRB-20261003', 'PROBLEM',
 'Tài khoản người dùng bị khóa hàng loạt sau giờ làm việc',
 'Hệ thống ghi nhận 15-20 tài khoản bị khóa mỗi sáng thứ Hai. Active Directory ghi Event ID 4740 lúc 02:00-03:00.',
 'RESOLVED', 'HIGH', 6, 3, 3, 1,
 'Ổ đĩa mạng ánh xạ dùng thông tin đăng nhập cũ sau khi chính sách mật khẩu thay đổi.',
 'Xóa Credential Manager toàn bộ máy trạm. Cập nhật Group Policy áp dụng fine-grained password policy.'),

('PRB-20261004', 'PROBLEM',
 'Dịch vụ email gửi bị trễ trong giờ cao điểm',
 'Người dùng báo email gửi đi bị trễ 15-45 phút trong khung 08:00-10:00 và 13:00-15:00. Vấn đề tái diễn, liên quan INC-20261003.',
 'CLOSED', 'MEDIUM', 5, 3, 3, 1,
 'SMTP relay giới hạn 100 email/phút, hệ thống vượt ngưỡng khi có thông báo hàng loạt.',
 'Giới hạn batch xuống 80 email/phút. Chuyển thông báo không khẩn sang lịch gửi 06:00 sáng.'),

('PRB-20261005', 'PROBLEM',
 'Hiệu năng ứng dụng kế toán giảm khi xuất báo cáo lớn',
 'Ứng dụng kế toán crash hoặc timeout khi xuất báo cáo tháng với hơn 10.000 dòng. Liên quan INC-20261002.',
 'IN_PROGRESS', 'CRITICAL', 8, 3, 3, 1,
 'Query không tối ưu, thiếu index trên bảng transaction. Heap JVM không đủ cho tập dữ liệu lớn.', NULL),

('PRB-20261006', 'PROBLEM',
 'Job backup hàng đêm thất bại không nhất quán',
 'Job backup lúc 02:00 thất bại 2-3 lần/tuần mà không có cảnh báo rõ ràng. Chỉ phát hiện khi kiểm tra thủ công.',
 'ASSIGNED', 'HIGH', 8, 3, 3, 2, NULL, NULL);
