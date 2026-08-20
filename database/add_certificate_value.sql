-- ====================================================
-- Add certificate_value field to applications table
-- ====================================================
-- This allows officers to enter specific values when approving
-- For example: Income amount (300000), Age, etc.
-- ====================================================

USE civicore;

ALTER TABLE applications 
ADD COLUMN certificate_value VARCHAR(255) NULL 
COMMENT 'Specific value entered by officer (e.g., income amount, age, etc.)'
AFTER certificate_type;

-- Add index for filtering
CREATE INDEX idx_certificate_value ON applications(certificate_value);
