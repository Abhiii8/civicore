-- ====================================================
-- CiviCore E-Governance System - MySQL Database Schema
-- ====================================================
-- This database supports transparency, accountability, and efficiency
-- in government service delivery (Paperless Governance)
-- ====================================================

CREATE DATABASE IF NOT EXISTS civicore CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE civicore;

-- ====================================================
-- ROLES TABLE
-- ====================================================
-- Stores user roles: Citizen, Officer, Admin
-- Supports Role-Based Access Control (RBAC)
CREATE TABLE roles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- DEPARTMENTS TABLE
-- ====================================================
-- Government departments (e.g., Health, Education, Revenue)
CREATE TABLE departments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20) UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_code (code),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- USERS TABLE
-- ====================================================
-- All users: Citizens, Officers, Admins
-- Password stored as bcrypt hash for security
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    role_id INT NOT NULL,
    department_id INT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    aadhaar_number VARCHAR(12) UNIQUE,
    address TEXT,
    date_of_birth DATE,
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE RESTRICT,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL,
    INDEX idx_email (email),
    INDEX idx_role (role_id),
    INDEX idx_department (department_id),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- SERVICES TABLE
-- ====================================================
-- Government services available for application
-- (Birth Certificate, Income Certificate, etc.)
CREATE TABLE services (
    id INT PRIMARY KEY AUTO_INCREMENT,
    department_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(50) UNIQUE,
    description TEXT,
    required_documents TEXT,
    processing_days INT DEFAULT 7,
    fee DECIMAL(10,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE RESTRICT,
    INDEX idx_department (department_id),
    INDEX idx_code (code),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- APPLICATIONS TABLE
-- ====================================================
-- Citizen applications for government services
-- Status: pending, under_review, approved, rejected
CREATE TABLE applications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    application_number VARCHAR(50) UNIQUE NOT NULL,
    citizen_id INT NOT NULL,
    service_id INT NOT NULL,
    officer_id INT NULL,
    status ENUM('pending', 'under_review', 'approved', 'rejected') DEFAULT 'pending',
    remarks TEXT,
    rejection_reason TEXT,
    applied_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_date TIMESTAMP NULL,
    approved_date TIMESTAMP NULL,
    certificate_path VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (citizen_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE RESTRICT,
    FOREIGN KEY (officer_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_citizen (citizen_id),
    INDEX idx_service (service_id),
    INDEX idx_officer (officer_id),
    INDEX idx_status (status),
    INDEX idx_application_number (application_number),
    INDEX idx_applied_date (applied_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- APPLICATION_DOCUMENTS TABLE
-- ====================================================
-- Documents uploaded by citizens for applications
CREATE TABLE application_documents (
    id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    document_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    file_type VARCHAR(50),
    file_size INT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (application_id) REFERENCES applications(id) ON DELETE CASCADE,
    INDEX idx_application (application_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- APPLICATION_LOGS TABLE
-- ====================================================
-- Audit trail for application status changes
-- Ensures transparency and accountability
CREATE TABLE application_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    user_id INT NULL,
    action VARCHAR(100) NOT NULL,
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (application_id) REFERENCES applications(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_application (application_id),
    INDEX idx_user (user_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- COMPLAINTS TABLE
-- ====================================================
-- Grievance/Complaint system for citizens
CREATE TABLE complaints (
    id INT PRIMARY KEY AUTO_INCREMENT,
    complaint_number VARCHAR(50) UNIQUE NOT NULL,
    citizen_id INT NOT NULL,
    subject VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    status ENUM('open', 'in_progress', 'resolved', 'closed') DEFAULT 'open',
    assigned_to INT NULL,
    resolution TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL,
    FOREIGN KEY (citizen_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_citizen (citizen_id),
    INDEX idx_status (status),
    INDEX idx_assigned (assigned_to),
    INDEX idx_complaint_number (complaint_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- AUDIT_LOGS TABLE
-- ====================================================
-- System-wide audit logging for governance compliance
-- Tracks all critical actions for accountability
CREATE TABLE audit_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id INT,
    details TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user (user_id),
    INDEX idx_action (action),
    INDEX idx_entity (entity_type, entity_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- INSERT DEFAULT DATA
-- ====================================================

-- Insert Roles
INSERT INTO roles (name, description) VALUES
('citizen', 'Citizen - Can apply for government services'),
('officer', 'Government Officer - Can review and approve applications'),
('admin', 'Administrator - Full system access');

-- Insert Default Department
INSERT INTO departments (name, code, description) VALUES
('General Administration', 'GEN', 'General administrative services'),
('Health Department', 'HLTH', 'Health and medical services'),
('Education Department', 'EDU', 'Educational services and certificates'),
('Revenue Department', 'REV', 'Revenue and income certificates'),
('Civil Registration', 'CIV', 'Birth, death, and marriage certificates');

-- Insert Default Admin User
-- Password: admin123 (bcrypt hash)
INSERT INTO users (role_id, email, password, full_name, phone, is_active, email_verified) VALUES
(3, 'admin@civicore.gov', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'System Administrator', '1234567890', TRUE, TRUE);

-- Insert Sample Services
INSERT INTO services (department_id, name, code, description, required_documents, processing_days, fee) VALUES
(5, 'Birth Certificate', 'BC001', 'Official birth certificate issuance', 'Aadhaar Card, Hospital Certificate', 5, 0.00),
(4, 'Income Certificate', 'IC001', 'Income certificate for various purposes', 'Aadhaar Card, Bank Statements, Salary Slips', 7, 0.00),
(1, 'Residence Certificate', 'RC001', 'Proof of residence certificate', 'Aadhaar Card, Utility Bills', 3, 0.00),
(3, 'Scholarship Application', 'SA001', 'Educational scholarship application', 'Income Certificate, Mark Sheets, Bank Details', 14, 0.00),
(1, 'Grievance Request', 'GR001', 'Submit complaints and grievances', 'Supporting Documents (if any)', 10, 0.00);

-- ====================================================
-- END OF SCHEMA
-- ====================================================
