-- ====================================================
-- Add certificate_type field to applications table
-- ====================================================
-- This allows officers to select specific types when approving
-- For example: Income type for Income Certificate
-- ====================================================

USE civicore;

ALTER TABLE applications 
ADD COLUMN certificate_type VARCHAR(100) NULL 
COMMENT 'Selected type/category for the certificate (e.g., income type, birth type)'
AFTER certificate_path;

-- Add index for filtering
CREATE INDEX idx_certificate_type ON applications(certificate_type);
