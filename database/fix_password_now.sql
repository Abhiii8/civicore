-- QUICK FIX: Update Admin Password
-- Run this in phpMyAdmin SQL tab

USE civicore;

UPDATE users 
SET password = '$2y$10$PQFpkqDDQtJNj6MB7T7zYuT.r6awATxL1HY1ZGrhxfOaiEFskvXGe'
WHERE email = 'admin@civicore.gov';

-- Verify
SELECT email, full_name, role_id, is_active FROM users WHERE email = 'admin@civicore.gov';
