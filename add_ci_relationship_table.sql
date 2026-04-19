-- ============================================================
-- Thêm bảng ci_relationship vào schema hiện tại
-- Chạy script này trong MySQL Workbench hoặc phpMyAdmin
-- ============================================================

CREATE TABLE IF NOT EXISTS ci_relationship (
    relationship_id  INT AUTO_INCREMENT PRIMARY KEY,
    parent_ci_id     INT         NOT NULL,
    child_ci_id      INT         NOT NULL,
    relationship_type VARCHAR(50) NOT NULL,
    description      TEXT,
    created_at       TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,

    -- Không cho phép trùng lặp cùng cặp + cùng kiểu
    UNIQUE KEY uq_rel (parent_ci_id, child_ci_id, relationship_type),

    -- Tự động xóa quan hệ khi CI bị xóa
    CONSTRAINT fk_rel_parent FOREIGN KEY (parent_ci_id)
        REFERENCES configuration_item(ci_id) ON DELETE CASCADE,
    CONSTRAINT fk_rel_child  FOREIGN KEY (child_ci_id)
        REFERENCES configuration_item(ci_id) ON DELETE CASCADE
);
