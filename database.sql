DROP DATABASE IF EXISTS admin_service_db;
CREATE DATABASE admin_service_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE admin_service_db;

-- =========================
-- TABLE: role
-- =========================
CREATE TABLE role (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'ACTIVE'
);

-- =========================
-- TABLE: user
-- =========================
CREATE TABLE user (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role_id INT NOT NULL,
    is_active TINYINT(1) DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES role(role_id)
);

-- =========================
-- TABLE: service
-- =========================
CREATE TABLE service (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    service_name VARCHAR(255) NOT NULL,
    service_code VARCHAR(50) UNIQUE,
    description TEXT,
    estimated_delivery_day INT,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =========================
-- TABLE: ticket
-- =========================
CREATE TABLE ticket (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_number VARCHAR(50) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(20) NOT NULL,
    service_id INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (service_id) REFERENCES service(service_id)
        ON DELETE RESTRICT
);

-- =========================
-- ROLE DATA
-- =========================
INSERT INTO role (role_name, description) VALUES
('End User', 'Standard end user'),
('Support Agent', 'Support agent'),
('Admin', 'Administrator');

-- =========================
-- USER DATA
-- =========================
INSERT INTO user (
    username,
    email,
    password_hash,
    full_name,
    role_id
) VALUES
('admin', 'admin@itsm.com', '123456', 'System Administrator', 3),
('agent01', 'agent@itsm.com', '123456', 'Support Agent One', 2),
('user01', 'user@itsm.com', '123456', 'Demo End User', 1);

-- =========================
-- SERVICE DATA
-- =========================
INSERT INTO service (service_name, service_code, description, estimated_delivery_day, status) VALUES
('Email Account Provisioning', 'SRV-EMAIL-001', 'Create and configure a corporate email account for a new user.', 1, 'ACTIVE'),
('Password Reset Service', 'SRV-ACC-001', 'Reset password for internal systems.', 0, 'ACTIVE'),
('Software Installation', 'SRV-SW-001', 'Install approved software.', 2, 'ACTIVE'),
('VPN Access Request', 'SRV-NET-001', 'Grant VPN access.', 2, 'ACTIVE'),
('Printer Setup Service', 'SRV-PRN-001', 'Install printer.', 1, 'ACTIVE');

-- =========================
-- TICKET DATA
-- =========================
INSERT INTO ticket (
    ticket_number,
    title,
    description,
    status,
    service_id
) VALUES
('SR-20261010', 'Request new email account', 'Need a new email account.', 'NEW', 1),
('SR-20261011', 'Request VPN access', 'Need VPN access.', 'ASSIGNED', 4);