DROP DATABASE IF EXISTS kedb_standalone;
CREATE DATABASE IF NOT EXISTS kedb_standalone
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE kedb_standalone;

-- ==========================================
-- 1. BẢNG VAI TRÒ
-- ==========================================
CREATE TABLE role (
    role_id     INT AUTO_INCREMENT PRIMARY KEY,
    role_name   VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    permission  TEXT,
    status      VARCHAR(20) DEFAULT 'ACTIVE'
);

-- ==========================================
-- 2. BẢNG PHÒNG BAN
-- Bỏ manager_id: quản lý xác định qua role của user
-- ==========================================
CREATE TABLE department (
    department_id        INT AUTO_INCREMENT PRIMARY KEY,
    department_name      VARCHAR(100) NOT NULL,
    department_code      VARCHAR(20)  UNIQUE,
    parent_department_id INT          NULL,
    status               VARCHAR(20)  DEFAULT 'ACTIVE'
);

-- ==========================================
-- 3. BẢNG NGƯỜI DÙNG
-- department_id NOT NULL → bắt buộc
-- role_id       NOT NULL → bắt buộc
-- ==========================================
CREATE TABLE `user` (
    user_id             INT AUTO_INCREMENT PRIMARY KEY,
    username            VARCHAR(100) UNIQUE NOT NULL,
    email               VARCHAR(255) UNIQUE NOT NULL,
    password_hash       VARCHAR(255) NOT NULL,
    full_name           VARCHAR(255) NOT NULL,
    phone               VARCHAR(20),
    department_id       INT NOT NULL,
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

-- ==========================================
-- 4. BẢNG DANH MỤC PHIẾU
-- ==========================================
CREATE TABLE ticket_category (
    category_id        INT AUTO_INCREMENT PRIMARY KEY,
    category_name      VARCHAR(100) NOT NULL,
    category_code      VARCHAR(50)  UNIQUE,
    category_type      VARCHAR(20)  NOT NULL,
    difficulty_level   VARCHAR(10),
    description        TEXT,
    parent_category_id INT          NULL,
    is_active          TINYINT(1)  DEFAULT 1,
    created_at         DATETIME    DEFAULT CURRENT_TIMESTAMP,
    updated_at         DATETIME    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ==========================================
-- 5. BẢNG BÀI VIẾT (Lỗi đã xác định / Cơ sở tri thức)
-- author_id   NOT NULL → bắt buộc (bài phải có tác giả)
-- approved_by NULL     → tùy chọn (bài mới chưa được duyệt)
-- category_id NULL     → tùy chọn (có thể chưa phân loại)
-- ==========================================
CREATE TABLE article (
    article_id       INT AUTO_INCREMENT PRIMARY KEY,
    article_number   VARCHAR(50)  UNIQUE NOT NULL,
    article_type     VARCHAR(20)  NOT NULL,
    title            VARCHAR(255) NOT NULL,
    content          TEXT         NOT NULL,
    summary          VARCHAR(500),
    category_id      INT          NULL,
    status           VARCHAR(20)  NOT NULL,
    author_id        INT          NOT NULL,
    approved_by      INT          NULL,
    approved_at      DATETIME     NULL,
    rejection_reason TEXT,
    published_at     DATETIME     NULL,
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

-- ==========================================
-- 6. BẢNG QUẢN LÝ NHÀ CUNG CẤP (Vendor) 
-- Bảng cấp thấp, thường được tham chiếu bởi CMDB/Asset.
-- ==========================================
CREATE TABLE vendor (
    vendor_id     INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(150) NOT NULL UNIQUE,
    contact_email VARCHAR(255),
    contact_phone VARCHAR(50),
    address       VARCHAR(255),
    status        VARCHAR(20) DEFAULT 'ACTIVE',
    created_at    TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP   DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ==========================================
-- 7. BẢNG MỤC CẤU HÌNH (CMDB)
-- managed_by    NULL → tùy chọn (chưa gán người quản lý)
-- department_id NULL → tùy chọn (chưa gán phòng ban)
-- ==========================================
CREATE TABLE configuration_item (
    ci_id         INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    type          VARCHAR(50)  NOT NULL,
    version       VARCHAR(50),
    description   TEXT,
    managed_by    INT NULL,
    department_id INT NULL,
    vendor_id     INT NOT NULL,
    status        VARCHAR(20) DEFAULT 'ACTIVE',
    created_at    TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP   DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (managed_by)    REFERENCES `user`(user_id)           ON DELETE SET NULL,
    FOREIGN KEY (department_id) REFERENCES department(department_id) ON DELETE SET NULL,
    FOREIGN KEY (vendor_id)     REFERENCES vendor(vendor_id)
);

-- ==========================================
-- 8. BẢNG QUAN HỆ MỤC CẤU HÌNH (CI Relationship)
-- Mô tả sự phụ thuộc / liên kết giữa các CI trong CMDB.
-- parent_ci_id → CI cung cấp tài nguyên / hạ tầng
-- child_ci_id  → CI phụ thuộc / sử dụng CI cha
-- ON DELETE CASCADE: xóa CI → tự động xóa quan hệ liên quan
-- ==========================================
CREATE TABLE ci_relationship (
    relationship_id   INT AUTO_INCREMENT PRIMARY KEY,
    parent_ci_id      INT          NOT NULL,
    child_ci_id       INT          NOT NULL,
    relationship_type VARCHAR(50)  NOT NULL,
    description       TEXT,
    created_at        TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,

    -- Không cho trùng cùng cặp CI + cùng kiểu quan hệ
    UNIQUE KEY uq_rel (parent_ci_id, child_ci_id, relationship_type),

    CONSTRAINT chk_rel_type CHECK (relationship_type IN (
        'DEPENDS_ON', 'CONNECTED_TO', 'RUNS_ON', 'HOSTED_BY', 'PART_OF'
    )),
    CONSTRAINT fk_rel_parent FOREIGN KEY (parent_ci_id)
        REFERENCES configuration_item(ci_id) ON DELETE CASCADE,
    CONSTRAINT fk_rel_child  FOREIGN KEY (child_ci_id)
        REFERENCES configuration_item(ci_id) ON DELETE CASCADE
);

-- ============================================================
-- DỮ LIỆU MẪU
-- ============================================================

-- ── Vai trò (ID 1–10) ────────────────────────────────────────
INSERT INTO role (role_name, description) VALUES
('Người dùng cuối',      'Nhân viên thông thường, tạo phiếu yêu cầu hỗ trợ IT'),
('Nhân viên hỗ trợ',     'Nhân viên hỗ trợ cấp 1, tiếp nhận và xử lý sự cố'),
('Quản lý',              'Quản lý IT, giám sát vận hành và phê duyệt bài viết'),
('Tổng quản lý',         'Quản lý cấp cao, giám sát và điều phối liên phòng ban'),
('Chuyên gia kỹ thuật',  'Kỹ sư chuyên môn, thực hiện phân tích nguyên nhân gốc rễ'),
('Kỹ sư hệ thống',       'Quản trị hạ tầng, máy chủ và hệ thống mạng'),
('Thành viên CAB',       'Thành viên Hội đồng Tư vấn Thay đổi (Change Advisory Board)'),
('Quản lý tài sản',      'Quản lý kho tài sản phần cứng và phần mềm (CMDB)'),
('Giám đốc IT',          'Lãnh đạo cấp cao giám sát toàn bộ bộ phận IT'),
('Quản trị hệ thống',    'Quản trị viên hệ thống với quyền truy cập đầy đủ nền tảng');

-- ── Phòng ban ────────────────────────────────────────────────
INSERT INTO department (department_name, department_code) VALUES
('Bộ phận Hỗ trợ IT',       'IT-SUP'),
('Vận hành Mạng',            'NET-OPS'),
('Phát triển Phần mềm',      'DEV'),
('Vận hành Bảo mật',         'SEC-OPS'),
('Hạ tầng & Máy chủ',        'INFRA'),
('Bàn trợ giúp',             'HD');

-- ── Tài khoản người dùng (mật khẩu mặc định: 123123) ────────
INSERT INTO `user` (username, email, password_hash, full_name, role_id, department_id) VALUES
('admin',     'admin@itsm.com',     '123123', 'Nguyễn Quản Trị',    10, 1),
('manager',   'manager@itsm.com',   '123123', 'Trần Văn Quản',       3, 1),
('tech',      'tech@itsm.com',      '123123', 'Lê Chuyên Gia',       5, 2),
('agent1',    'agent1@itsm.com',    '123123', 'Phạm Thị Hỗ Trợ',    2, 1),
('agent2',    'agent2@itsm.com',    '123123', 'Hoàng Văn Minh',      2, 1),
('tech2',     'tech2@itsm.com',     '123123', 'Ngô Thị Kỹ Thuật',   5, 2),
('tech3',     'tech3@itsm.com',     '123123', 'Đặng Quốc Hùng',     5, 2),
('engineer1', 'engineer1@itsm.com', '123123', 'Vũ Hệ Thống',        6, 2),
('asset',     'assetmgr@itsm.com',  '123123', 'Bùi Tài Sản',        8, 5),
('director',  'director@itsm.com',  '123123', 'Phan Giám Đốc',      9, 1),
('enduser1',  'enduser1@itsm.com',  '123123', 'Đinh Văn An',        1, 3),
('enduser2',  'enduser2@itsm.com',  '123123', 'Trịnh Thị Bình',     1, 4);

-- ── Danh mục phiếu ───────────────────────────────────────────
INSERT INTO ticket_category (category_name, category_code, category_type, description) VALUES
('Kết nối mạng',        'INC-NET',  'INCIDENT', 'Các sự cố liên quan đến WiFi và kết nối mạng LAN'),
('Hỏng phần cứng',      'INC-HW',   'INCIDENT', 'Thiết bị phần cứng bị hỏng hoặc không hoạt động'),
('Lỗi phần mềm',        'INC-SW',   'INCIDENT', 'Lỗi ứng dụng hoặc hành vi bất thường của phần mềm'),
('Sự cố bảo mật',       'INC-SEC',  'INCIDENT', 'Truy cập trái phép, vi phạm bảo mật hoặc xâm nhập hệ thống'),
('Email & Liên lạc',    'INC-MAIL', 'INCIDENT', 'Lỗi gửi/nhận email hoặc sự cố dịch vụ liên lạc'),
('Quyền truy cập',      'INC-ACC',  'INCIDENT', 'Không thể đăng nhập, bị từ chối quyền hoặc khóa tài khoản'),
('Giảm hiệu năng',      'INC-PERF', 'INCIDENT', 'Hệ thống chậm, CPU hoặc bộ nhớ sử dụng quá cao'),
('Sao lưu & Phục hồi',  'PRB-BCK',  'PROBLEM',  'Lỗi sao lưu lặp đi lặp lại hoặc sự cố phục hồi dữ liệu'),
('Hạ tầng mạng',        'PRB-NET',  'PROBLEM',  'Vấn đề thiết kế mạng hoặc kết nối mạng kéo dài dai dẳng');

-- ── Bài viết Lỗi đã xác định ─────────────────────────────────
INSERT INTO article (article_number, article_type, title, content, summary, category_id, status, author_id, symptom, cause, solution) VALUES

('KE-0001', 'KNOWN_ERROR',
 'Cạn kiệt pool kết nối database gây sập máy chủ Tomcat',
 'Pool kết nối cơ sở dữ liệu bị cạn kiệt khi tải cao, khiến Tomcat ngừng phục vụ các yêu cầu.',
 'Rò rỉ bộ nhớ do các kết nối JDBC không được đóng sau khi sử dụng.',
 1, 'APPROVED', 3,
 'Tomcat ghi lỗi AbandonedConnectionCleanupThread; ứng dụng trả về HTTP 500 hoặc timeout kết nối.',
 'Pool kết nối bị cạn kiệt vì các kết nối không được đóng đúng cách, dẫn đến rò rỉ tài nguyên và bộ nhớ.',
 '1. Đóng toàn bộ kết nối JDBC bằng try-with-resources.\n2. Tăng kích thước pool kết nối trong context.xml.\n3. Khởi động lại Tomcat và chạy lại script SQL khởi tạo tối giản để phục hồi trạng thái DB.'
),

('KE-0002', 'KNOWN_ERROR',
 'Tài khoản Active Directory bị khóa tự động sau giờ làm việc',
 'Tài khoản người dùng liên tục bị khóa qua đêm mà không có hoạt động đăng nhập, khiến nhân viên không thể vào làm việc vào buổi sáng.',
 'Phiên Kerberos hết hạn từ ổ đĩa mạng đã ánh xạ gây xác thực thất bại liên tục với Active Directory.',
 6, 'APPROVED', 3,
 'Người dùng báo tài khoản bị khóa mỗi sáng. Event ID 4740 xuất hiện trong Security log của Domain Controller vào khoảng 02:00–03:00 sáng.',
 'Ổ đĩa mạng xác thực bằng thông tin đăng nhập đã lưu đệm. Khi mật khẩu thay đổi, phiên Kerberos cũ tiếp tục thử xác thực lại liên tục, gây ra khóa tài khoản.',
 '1. Xác định máy nguồn qua Event ID 4771/4740 trong AD log.\n2. Mở Credential Manager và xóa thông tin đăng nhập Windows đã lưu cũ.\n3. Ánh xạ lại ổ đĩa mạng với thông tin đăng nhập mới.\n4. Bật Fine-Grained Password Policy với ngưỡng quan sát trước khi khóa.'
),

('KE-0003', 'KNOWN_ERROR',
 'Chứng chỉ SSL hết hạn gây gián đoạn dịch vụ nội bộ',
 'Các dịch vụ nội bộ trở nên không thể truy cập khi chứng chỉ SSL hết hạn mà không có cảnh báo.',
 'Chứng chỉ SSL nội bộ hết hạn mà không có gia hạn tự động hoặc cảnh báo, gây lỗi HTTPS.',
 4, 'APPROVED', 8,
 'Trình duyệt hiển thị lỗi NET::ERR_CERT_DATE_INVALID. Các lời gọi API nội bộ trả về lỗi SSL handshake.',
 'Chứng chỉ được cấp thủ công và theo dõi qua bảng tính. Không có gia hạn tự động hoặc cảnh báo hết hạn được cấu hình.',
 '1. Gia hạn chứng chỉ hết hạn qua CA nội bộ hoặc Let''s Encrypt.\n2. Khởi động lại dịch vụ web sau khi triển khai chứng chỉ mới.\n3. Triển khai cert-manager hoặc Certbot với cron tự gia hạn.\n4. Cài đặt cảnh báo giám sát kích hoạt 30 ngày trước khi hết hạn.'
),

('KE-0004', 'KNOWN_ERROR',
 'Email gửi bị chậm trễ trong giờ cao điểm',
 'Email gửi đi bị trễ 15–45 phút trong các khung giờ sử dụng cao.',
 'Hàng đợi gửi mail bị tắc nghẽn do SMTP relay giới hạn tốc độ gửi.',
 5, 'APPROVED', 3,
 'Người dùng báo email gửi đến chậm. Log hiển thị "421 Too many connections" từ máy chủ relay.',
 'Nhà cung cấp relay SMTP giới hạn 100 email/phút. Trong giờ cao điểm, hệ thống phiếu gửi thông báo hàng loạt vượt ngưỡng này liên tục.',
 '1. Giới hạn tốc độ gửi email hàng loạt tối đa 80 email/phút.\n2. Chuyển các thông báo không khẩn sang lịch gửi ngoài giờ cao điểm (ví dụ: 06:00 sáng).\n3. Liên hệ nhà cung cấp relay SMTP để tăng hạn mức gửi.\n4. Cân nhắc sử dụng dịch vụ email giao dịch chuyên dụng (SendGrid / Amazon SES).'
),

('KE-0005', 'KNOWN_ERROR',
 'VPN tự ngắt kết nối khi máy tính vào chế độ ngủ/ngủ đông',
 'VPN của công ty tự ngắt kết nối khi máy tính ngủ và không tự kết nối lại khi thức dậy.',
 'Phiên VPN không được duy trì qua trạng thái ngủ của hệ thống.',
 1, 'APPROVED', 8,
 'Sau khi gập màn hình laptop, VPN hiển thị "Connection Terminated". Người dùng phải xác thực lại thủ công bằng MFA.',
 'Cấu hình AnyConnect chưa bật chế độ Always-On. Quản lý nguồn điện Windows tắt card mạng khi ngủ, ngắt đường hầm VPN.',
 '1. Bật chế độ Always-On trong cấu hình VPN AnyConnect trên ASA/FTD.\n2. Windows: Device Manager → NIC → Power Management → bỏ chọn "Allow computer to turn off this device".\n3. macOS: System Settings → Battery → bỏ chọn "Enable Power Nap".\n4. Cài lại AnyConnect phiên bản v4.10+ nếu vẫn còn lỗi.'
),

('KE-0006', 'KNOWN_ERROR',
 'Độ trễ sao chép MySQL vượt ngưỡng SLA',
 'Bản sao đọc MySQL bị tụt hậu so với máy chủ chính hơn 60 giây trong quá trình chạy ETL hàng loạt.',
 'Các giao dịch ghi dài trong ETL chặn luồng SQL của bản sao, gây ra đột biến độ trễ.',
 9, 'PENDING', 3,
 'Grafana hiển thị Seconds_Behind_Master tăng đột biến lên 60–300 giây trong khung 01:00–03:00 sáng.',
 'Các giao dịch INSERT/UPDATE hàng loạt trên máy chủ chính phải được áp dụng hoàn toàn trên bản sao trước khi tiếp tục, gây nút thắt cổ chai tuần tự.',
 '1. Chia nhỏ ETL thành các batch nhỏ hơn (1.000 dòng/lần commit).\n2. Đặt replica_parallel_workers=4 và replica_parallel_type=LOGICAL_CLOCK.\n3. Lên lịch ETL ngoài giờ làm việc và cửa sổ sao lưu.\n4. Cài đặt cảnh báo khi Seconds_Behind_Source > 30.'
),

('KE-0007', 'KNOWN_ERROR',
 'Bản cập nhật Windows 11 24H2 làm hỏng driver máy in mạng',
 'Sau khi cài Windows 11 24H2, máy in mạng dùng Microsoft IPP Class Driver không in được.',
 'KB5043145 gây ra lỗi hồi quy ảnh hưởng đến driver máy in dựa trên IPP.',
 3, 'APPROVED', 8,
 'Lệnh in được đưa vào hàng đợi nhưng không xử lý. Máy in hiển thị Offline dù đang bật. Mã lỗi 0x00000bc4 trong Print Management.',
 'KB5043145 làm hỏng IPP print class driver cho máy in giao tiếp qua cổng TCP/IP 9100 không có driver từ nhà sản xuất.',
 '1. Gỡ cài đặt máy in, thêm lại bằng driver từ nhà sản xuất (không dùng driver IPP chung).\n2. Gỡ KB5043145 qua Settings → Windows Update → Update History → Uninstall.\n3. Chặn bản cập nhật qua WSUS/Intune đến khi Microsoft phát bản vá.'
),

('KE-0008', 'KNOWN_ERROR',
 'Grafana không hiển thị dữ liệu sau khi khởi động lại Prometheus',
 'Sau khi khởi động lại Prometheus, toàn bộ dashboard Grafana hiển thị "No data" cho các chỉ số trước lúc khởi động lại.',
 'WAL (Write-Ahead Log) của TSDB Prometheus không được xả đúng cách khi tắt, gây mất dữ liệu chỉ số gần đây.',
 7, 'INACTIVE', 3,
 'Các panel Grafana hiển thị khoảng trắng trước thời điểm khởi động lại. Log Prometheus báo cảnh báo "incomplete block" khi khởi động.',
 'Prometheus bị tắt bằng SIGKILL thay vì SIGTERM, khiến WAL ở trạng thái không nhất quán.',
 '1. Luôn dừng Prometheus bằng: sudo systemctl stop prometheus (gửi SIGTERM để tắt an toàn).\n2. Cấu hình remote_write tới Thanos hoặc VictoriaMetrics để lưu trữ chỉ số bên ngoài.\n3. Bật --storage.tsdb.wal-compression=true để giảm kích thước WAL.'
);

-- ── Dữ liệu khởi tạo bảng Vendor ─────────────────────────────
INSERT INTO vendor (name, contact_email, contact_phone, address, status) VALUES
('Dell Technologies', 'support.vn@dell.com', '1800 545455', 'TP. Hồ Chí Minh, Việt Nam', 'ACTIVE'),
('FPT Information System', 'fis.support@fpt.com', '1900 6600', 'Quận Cầu Giấy, Hà Nội', 'ACTIVE'),
('Cisco Vietnam', 'vietnam_support@cisco.com', '+84 28 3824 0200', 'Quận 1, TP. Hồ Chí Minh', 'ACTIVE');


-- ── Mục cấu hình (CMDB) — managed_by = 9 (Bùi Tài Sản) ──────
INSERT INTO configuration_item (name, type, version, description, managed_by, department_id, vendor_id, status) VALUES
-- Máy chủ & Tường lửa (ci_id 1–3)
('Máy chủ Web Ứng dụng 01',        'Hardware', 'Ubuntu 22.04 LTS',     'Máy chủ web chính chạy hệ thống ITSM',  9, 5, 1, 'ACTIVE'),
('Máy chủ Cơ sở dữ liệu chính',    'Hardware', 'Ubuntu 20.04 LTS',     'Máy chủ MySQL chính',                   9, 5, 1, 'ACTIVE'),
('Tường lửa (Vành đai)',            'Hardware', 'Fortinet FortiOS',     'Tường lửa bảo vệ hệ thống',             9, 2, 3, 'ACTIVE'),
-- Thiết bị mạng (ci_id 4–5)
('Switch Lõi - Tầng 1',            'Network',  'Cisco IOS 15.2',       'Switch 48 cổng quản lý',                9, 2, 3, 'ACTIVE'),
('Điểm truy cập WiFi - Văn phòng', 'Network',  'Cisco Aironet 2800',   'Access point phủ sóng',                 9, 2, 3, 'ACTIVE'),
-- Phần mềm / Dịch vụ (ci_id 6–8)
('Ứng dụng Web ITSM',              'Software', 'v2.4.1',               'Nền tảng quản lý',                      9, 1, 2, 'ACTIVE'),
('MySQL Database (Chính)',          'Software', '8.0.36',               'Cơ sở dữ liệu chính',                   9, 5, 2, 'ACTIVE'),
('Microsoft 365 (Exchange)',        'Service',  'N/A',                  'Dịch vụ mail đám mây',                  9, 1, 1, 'ACTIVE'),
-- Đã ngưng / Loại bỏ (ci_id 9)
('Cổng VPN cũ (OpenVPN)',           'Software', 'v2.4.9',               'Đã được thay thế',                      9, 2, 3, 'RETIRED');

-- ── Quan hệ CI (ci_relationship) ─────────────────────────────
-- Mô tả sơ đồ phụ thuộc hạ tầng thực tế
INSERT INTO ci_relationship (parent_ci_id, child_ci_id, relationship_type, description) VALUES

-- Ứng dụng Web chạy TRÊN máy chủ vật lý
(1,  6, 'RUNS_ON',      'Ứng dụng Web ITSM chạy trên Máy chủ Web 01'),

-- Database chính và phần mềm
(2,  7, 'RUNS_ON',      'MySQL Database chạy trên Máy chủ CSDL vật lý'),

-- Web app PHỤ THUỘC vào database
(7,  6, 'DEPENDS_ON',   'Ứng dụng ITSM phụ thuộc vào MySQL Database'),

-- Mạng: máy chủ và thiết bị kết nối đến switch
(4,  1, 'CONNECTED_TO', 'Máy chủ Web 01 kết nối qua Switch Tầng 1'),
(4,  2, 'CONNECTED_TO', 'Máy chủ CSDL kết nối qua Switch Tầng 1'),
(3,  4, 'CONNECTED_TO', 'Tường lửa kiểm soát lưu lượng vào Switch');
