-- Add profile_picture column to users table
-- Run this in phpMyAdmin to enable profile picture functionality

USE civicore;

ALTER TABLE users 
ADD COLUMN profile_picture VARCHAR(255) NULL AFTER phone;

-- Create index for profile_picture if needed
-- CREATE INDEX idx_profile_picture ON users(profile_picture);
