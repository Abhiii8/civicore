-- ====================================================
-- CiviCore - Sample Data for Testing
-- ====================================================

USE civicore;

-- Insert Sample Citizens
INSERT INTO users (role_id, email, password, full_name, phone, aadhaar_number, address, date_of_birth, is_active, email_verified) VALUES
(1, 'citizen1@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Rajesh Kumar', '9876543210', '123456789012', '123 Main Street, City', '1990-05-15', TRUE, TRUE),
(1, 'citizen2@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Priya Sharma', '9876543211', '123456789013', '456 Park Avenue, City', '1992-08-20', TRUE, TRUE),
(1, 'citizen3@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Amit Patel', '9876543212', '123456789014', '789 Market Road, City', '1988-12-10', TRUE, TRUE);

-- Insert Sample Officers
INSERT INTO users (role_id, department_id, email, password, full_name, phone, is_active, email_verified) VALUES
(2, 5, 'officer1@civicore.gov', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Officer John Doe', '9876543220', TRUE, TRUE),
(2, 4, 'officer2@civicore.gov', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Officer Jane Smith', '9876543221', TRUE, TRUE),
(2, 1, 'officer3@civicore.gov', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Officer Mike Johnson', '9876543222', TRUE, TRUE);

-- Insert Sample Applications
INSERT INTO applications (application_number, citizen_id, service_id, officer_id, status, applied_date) VALUES
('APP2024001', 2, 1, 4, 'approved', '2024-01-15 10:00:00'),
('APP2024002', 2, 2, 5, 'under_review', '2024-01-20 11:00:00'),
('APP2024003', 3, 3, NULL, 'pending', '2024-01-25 12:00:00'),
('APP2024004', 4, 1, 4, 'rejected', '2024-01-10 09:00:00');

-- Insert Sample Application Logs
INSERT INTO application_logs (application_id, user_id, action, old_status, new_status, remarks) VALUES
(1, 2, 'Application Submitted', NULL, 'pending', 'Citizen submitted application'),
(1, 4, 'Application Assigned', 'pending', 'under_review', 'Assigned to officer'),
(1, 4, 'Application Approved', 'under_review', 'approved', 'All documents verified and approved'),
(2, 2, 'Application Submitted', NULL, 'pending', 'Citizen submitted application'),
(2, 5, 'Application Assigned', 'pending', 'under_review', 'Under review by officer'),
(4, 2, 'Application Submitted', NULL, 'pending', 'Citizen submitted application'),
(4, 4, 'Application Rejected', 'under_review', 'rejected', 'Incomplete documents');

-- Insert Sample Complaints
INSERT INTO complaints (complaint_number, citizen_id, subject, description, status, created_at) VALUES
('COMP2024001', 2, 'Delayed Certificate', 'Birth certificate application is taking longer than expected', 'in_progress', '2024-01-18 14:00:00'),
('COMP2024002', 3, 'Service Issue', 'Unable to upload documents on the portal', 'open', '2024-01-22 15:00:00');

-- Insert Sample Audit Logs
INSERT INTO audit_logs (user_id, action, entity_type, entity_id, details, ip_address) VALUES
(1, 'LOGIN', 'user', 1, 'Admin logged in', '192.168.1.1'),
(2, 'CREATE_APPLICATION', 'application', 1, 'Created new application APP2024001', '192.168.1.2'),
(4, 'APPROVE_APPLICATION', 'application', 1, 'Approved application APP2024001', '192.168.1.3');
