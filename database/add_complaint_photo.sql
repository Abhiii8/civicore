-- Add photo_path column to complaints table
-- Run this in phpMyAdmin if you want to store complaint photos

USE civicore;

ALTER TABLE complaints 
ADD COLUMN photo_path VARCHAR(255) NULL AFTER description;

-- Create index for photo_path if needed
-- CREATE INDEX idx_photo_path ON complaints(photo_path);
