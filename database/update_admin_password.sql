-- Update Admin Password
-- This script updates the admin password to a correct bcrypt hash for "admin123"

USE civicore;

-- Generate a fresh bcrypt hash for "admin123"
-- This hash was generated and verified by test_login.php
-- Hash: $2y$10$PQFpkqDDQtJNj6MB7T7zYuT.r6awATxL1HY1ZGrhxfOaiEFskvXGe
-- This is a valid bcrypt hash for password "admin123"

UPDATE users 
SET password = '$2y$10$PQFpkqDDQtJNj6MB7T7zYuT.r6awATxL1HY1ZGrhxfOaiEFskvXGe'
WHERE email = 'admin@civicore.gov';

-- Verify the update
SELECT email, full_name, role_id, is_active FROM users WHERE email = 'admin@civicore.gov';
