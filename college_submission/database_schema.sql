-- ====================================================
-- CiviCore E-Governance System - Complete Database Schema
-- ====================================================
-- Project: CiviCore - E-Governance Platform
-- Database: MySQL 5.7+ / MariaDB 10.3+
-- Character Set: UTF-8 (utf8mb4) for full Unicode support
-- Engine: InnoDB for ACID compliance and foreign key support
-- ====================================================
-- This schema implements:
-- 1. Role-Based Access Control (RBAC)
-- 2. Complete application workflow management
-- 3. Document management system
-- 4. Complaint/grievance tracking
-- 5. Comprehensive audit logging
-- 6. Transparent and accountable governance
-- ====================================================

-- Create Database
CREATE DATABASE IF NOT EXISTS civicore 
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

USE civicore;

-- ====================================================
-- TABLE 1: ROLES
-- ====================================================
-- Purpose: Defines user roles for Role-Based Access Control
-- Supports: Citizen, Officer, Admin roles
-- ====================================================
CREATE TABLE roles (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique role identifier',
    name VARCHAR(50) NOT NULL UNIQUE COMMENT 'Role name (citizen, officer, admin)',
    description TEXT COMMENT 'Role description and permissions',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
    INDEX idx_name (name) COMMENT 'Index for role name lookups'
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='User roles for RBAC system';

-- ====================================================
-- TABLE 2: DEPARTMENTS
-- ====================================================
-- Purpose: Government departments offering services
-- Examples: Health, Education, Revenue, Civil Registration
-- ====================================================
CREATE TABLE departments (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique department identifier',
    name VARCHAR(100) NOT NULL COMMENT 'Department name',
    code VARCHAR(20) UNIQUE COMMENT 'Department code (short identifier)',
    description TEXT COMMENT 'Department description and responsibilities',
    is_active BOOLEAN DEFAULT TRUE COMMENT 'Whether department is active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
    INDEX idx_code (code) COMMENT 'Index for department code lookups',
    INDEX idx_active (is_active) COMMENT 'Index for filtering active departments'
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Government departments';

-- ====================================================
-- TABLE 3: USERS
-- ====================================================
-- Purpose: All system users (Citizens, Officers, Admins)
-- Security: Passwords stored as bcrypt hashes
-- ====================================================
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique user identifier',
    role_id INT NOT NULL COMMENT 'User role (FK to roles.id)',
    department_id INT NULL COMMENT 'Department assignment for officers (FK to departments.id)',
    email VARCHAR(100) NOT NULL UNIQUE COMMENT 'User email address (unique)',
    password VARCHAR(255) NOT NULL COMMENT 'Bcrypt hashed password (60 chars)',
    full_name VARCHAR(100) NOT NULL COMMENT 'User full name',
    phone VARCHAR(20) COMMENT 'Contact phone number',
    aadhaar_number VARCHAR(12) UNIQUE COMMENT 'Aadhaar card number (for citizens, unique)',
    address TEXT COMMENT 'User address',
    date_of_birth DATE COMMENT 'Date of birth',
    is_active BOOLEAN DEFAULT TRUE COMMENT 'Account active status',
    email_verified BOOLEAN DEFAULT FALSE COMMENT 'Email verification status',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Account creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
    
    -- Foreign Keys
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE RESTRICT COMMENT 'Cannot delete role if users exist',
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL COMMENT 'Set to NULL if department deleted',
    
    -- Indexes
    INDEX idx_email (email) COMMENT 'Index for email lookups (login)',
    INDEX idx_role (role_id) COMMENT 'Index for role-based queries',
    INDEX idx_department (department_id) COMMENT 'Index for department-based queries',
    INDEX idx_active (is_active) COMMENT 'Index for filtering active users',
    INDEX idx_aadhaar (aadhaar_number) COMMENT 'Index for Aadhaar lookups'
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='All system users (citizens, officers, admins)';

-- ====================================================
-- TABLE 4: SERVICES
-- ====================================================
-- Purpose: Government services available for application
-- Examples: Birth Certificate, Income Certificate, etc.
-- ====================================================
CREATE TABLE services (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique service identifier',
    department_id INT NOT NULL COMMENT 'Department offering service (FK to departments.id)',
    name VARCHAR(100) NOT NULL COMMENT 'Service name',
    code VARCHAR(50) UNIQUE COMMENT 'Service code (short identifier)',
    description TEXT COMMENT 'Service description',
    required_documents TEXT COMMENT 'List of required documents',
    processing_days INT DEFAULT 7 COMMENT 'Expected processing time in days',
    fee DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Service fee amount',
    is_active BOOLEAN DEFAULT TRUE COMMENT 'Whether service is active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
    
    -- Foreign Keys
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE RESTRICT COMMENT 'Cannot delete department if services exist',
    
    -- Indexes
    INDEX idx_department (department_id) COMMENT 'Index for department-based queries',
    INDEX idx_code (code) COMMENT 'Index for service code lookups',
    INDEX idx_active (is_active) COMMENT 'Index for filtering active services'
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Government services available for application';

-- ====================================================
-- TABLE 5: APPLICATIONS
-- ====================================================
-- Purpose: Citizen applications for government services
-- Workflow: pending → under_review → approved/rejected
-- ====================================================
CREATE TABLE applications (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique application identifier',
    application_number VARCHAR(50) UNIQUE NOT NULL COMMENT 'Unique application tracking number (APP{YYYY}{NNNN})',
    citizen_id INT NOT NULL COMMENT 'Citizen who submitted (FK to users.id)',
    service_id INT NOT NULL COMMENT 'Service being applied for (FK to services.id)',
    officer_id INT NULL COMMENT 'Officer assigned to review (FK to users.id)',
    status ENUM('pending', 'under_review', 'approved', 'rejected') DEFAULT 'pending' COMMENT 'Application status',
    remarks TEXT COMMENT 'Officer remarks and notes',
    rejection_reason TEXT COMMENT 'Reason for rejection (if rejected)',
    applied_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Application submission date',
    reviewed_date TIMESTAMP NULL COMMENT 'Date when officer started review',
    approved_date TIMESTAMP NULL COMMENT 'Date when application was approved',
    certificate_path VARCHAR(255) NULL COMMENT 'Path to generated certificate PDF',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
    
    -- Foreign Keys
    FOREIGN KEY (citizen_id) REFERENCES users(id) ON DELETE RESTRICT COMMENT 'Cannot delete citizen if applications exist',
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE RESTRICT COMMENT 'Cannot delete service if applications exist',
    FOREIGN KEY (officer_id) REFERENCES users(id) ON DELETE SET NULL COMMENT 'Set to NULL if officer deleted',
    
    -- Indexes
    INDEX idx_citizen (citizen_id) COMMENT 'Index for citizen-based queries',
    INDEX idx_service (service_id) COMMENT 'Index for service-based queries',
    INDEX idx_officer (officer_id) COMMENT 'Index for officer-based queries',
    INDEX idx_status (status) COMMENT 'Index for status filtering',
    INDEX idx_application_number (application_number) COMMENT 'Index for application number lookups',
    INDEX idx_applied_date (applied_date) COMMENT 'Index for date-based sorting and filtering'
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Citizen applications for government services';

-- ====================================================
-- TABLE 6: APPLICATION_DOCUMENTS
-- ====================================================
-- Purpose: Documents uploaded by citizens for applications
-- Supports: PDF, JPG, PNG file formats
-- ====================================================
CREATE TABLE application_documents (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique document identifier',
    application_id INT NOT NULL COMMENT 'Associated application (FK to applications.id)',
    document_name VARCHAR(255) NOT NULL COMMENT 'Original document name',
    file_path VARCHAR(255) NOT NULL COMMENT 'Server file path',
    file_type VARCHAR(50) COMMENT 'File MIME type',
    file_size INT COMMENT 'File size in bytes',
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Upload timestamp',
    
    -- Foreign Keys
    FOREIGN KEY (application_id) REFERENCES applications(id) ON DELETE CASCADE COMMENT 'Delete documents when application deleted',
    
    -- Indexes
    INDEX idx_application (application_id) COMMENT 'Index for application-based queries'
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Documents uploaded for applications';

-- ====================================================
-- TABLE 7: APPLICATION_LOGS
-- ====================================================
-- Purpose: Audit trail for application status changes
-- Ensures: Transparency and accountability
-- ====================================================
CREATE TABLE application_logs (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique log identifier',
    application_id INT NOT NULL COMMENT 'Associated application (FK to applications.id)',
    user_id INT NULL COMMENT 'User who performed action (FK to users.id)',
    action VARCHAR(100) NOT NULL COMMENT 'Action performed (e.g., Application Approved)',
    old_status VARCHAR(50) COMMENT 'Previous status',
    new_status VARCHAR(50) COMMENT 'New status',
    remarks TEXT COMMENT 'Additional remarks',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Action timestamp',
    
    -- Foreign Keys
    FOREIGN KEY (application_id) REFERENCES applications(id) ON DELETE CASCADE COMMENT 'Delete logs when application deleted',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL COMMENT 'Set to NULL if user deleted',
    
    -- Indexes
    INDEX idx_application (application_id) COMMENT 'Index for application-based queries',
    INDEX idx_user (user_id) COMMENT 'Index for user-based queries',
    INDEX idx_created_at (created_at) COMMENT 'Index for chronological sorting'
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Audit trail for application status changes';

-- ====================================================
-- TABLE 8: COMPLAINTS
-- ====================================================
-- Purpose: Grievance/Complaint system for citizens
-- Workflow: open → in_progress → resolved → closed
-- ====================================================
CREATE TABLE complaints (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique complaint identifier',
    complaint_number VARCHAR(50) UNIQUE NOT NULL COMMENT 'Unique complaint tracking number (COMP{YYYY}{NNNN})',
    citizen_id INT NOT NULL COMMENT 'Citizen who submitted (FK to users.id)',
    subject VARCHAR(255) NOT NULL COMMENT 'Complaint subject/title',
    description TEXT NOT NULL COMMENT 'Complaint description',
    status ENUM('open', 'in_progress', 'resolved', 'closed') DEFAULT 'open' COMMENT 'Complaint status',
    assigned_to INT NULL COMMENT 'Officer assigned to handle (FK to users.id)',
    resolution TEXT COMMENT 'Resolution details',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Complaint submission date',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
    resolved_at TIMESTAMP NULL COMMENT 'Resolution date',
    photo_path VARCHAR(255) NULL COMMENT 'Path to attached photo (if any)',
    
    -- Foreign Keys
    FOREIGN KEY (citizen_id) REFERENCES users(id) ON DELETE RESTRICT COMMENT 'Cannot delete citizen if complaints exist',
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL COMMENT 'Set to NULL if officer deleted',
    
    -- Indexes
    INDEX idx_citizen (citizen_id) COMMENT 'Index for citizen-based queries',
    INDEX idx_status (status) COMMENT 'Index for status filtering',
    INDEX idx_assigned (assigned_to) COMMENT 'Index for officer-based queries',
    INDEX idx_complaint_number (complaint_number) COMMENT 'Index for complaint number lookups'
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Citizen complaints and grievances';

-- ====================================================
-- TABLE 9: AUDIT_LOGS
-- ====================================================
-- Purpose: System-wide audit logging for governance compliance
-- Tracks: All critical actions for accountability
-- ====================================================
CREATE TABLE audit_logs (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique log identifier',
    user_id INT NULL COMMENT 'User who performed action (FK to users.id)',
    action VARCHAR(100) NOT NULL COMMENT 'Action performed (e.g., LOGIN, CREATE_USER)',
    entity_type VARCHAR(50) COMMENT 'Type of entity affected (user, application, service)',
    entity_id INT COMMENT 'ID of affected entity',
    details TEXT COMMENT 'Additional action details',
    ip_address VARCHAR(45) COMMENT 'User IP address (supports IPv6)',
    user_agent TEXT COMMENT 'User browser/client information',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Action timestamp',
    
    -- Foreign Keys
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL COMMENT 'Set to NULL if user deleted',
    
    -- Indexes
    INDEX idx_user (user_id) COMMENT 'Index for user-based queries',
    INDEX idx_action (action) COMMENT 'Index for action-based queries',
    INDEX idx_entity (entity_type, entity_id) COMMENT 'Composite index for entity lookups',
    INDEX idx_created_at (created_at) COMMENT 'Index for chronological sorting'
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='System-wide audit logging for accountability';

-- ====================================================
-- INSERT DEFAULT DATA
-- ====================================================

-- Insert Roles
INSERT INTO roles (name, description) VALUES
('citizen', 'Citizen - Can apply for government services'),
('officer', 'Government Officer - Can review and approve applications'),
('admin', 'Administrator - Full system access');

-- Insert Default Departments
INSERT INTO departments (name, code, description) VALUES
('General Administration', 'GEN', 'General administrative services'),
('Health Department', 'HLTH', 'Health and medical services'),
('Education Department', 'EDU', 'Educational services and certificates'),
('Revenue Department', 'REV', 'Revenue and income certificates'),
('Civil Registration', 'CIV', 'Birth, death, and marriage certificates');

-- Insert Default Admin User
-- Password: admin123 (bcrypt hash)
-- Default credentials for initial system access
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
-- DATABASE CONSTRAINTS AND RULES
-- ====================================================

-- Business Rules (enforced at application level):
-- 1. Application status flow: pending → under_review → approved/rejected
-- 2. Only pending applications can be assigned to officers
-- 3. Only officers can be assigned to applications
-- 4. Citizens cannot be assigned to departments
-- 5. Officers must be assigned to departments
-- 6. Application numbers must be unique and follow format: APP{YYYY}{NNNN}
-- 7. Complaint numbers must be unique and follow format: COMP{YYYY}{NNNN}

-- ====================================================
-- PERFORMANCE OPTIMIZATION NOTES
-- ====================================================
-- 1. All foreign key columns are indexed for fast joins
-- 2. Status fields are indexed for efficient filtering
-- 3. Date fields are indexed for chronological sorting
-- 4. Unique fields (email, application_number) are indexed
-- 5. Composite index on audit_logs (entity_type, entity_id) for entity lookups
-- 6. InnoDB engine provides row-level locking and ACID compliance

-- ====================================================
-- SECURITY CONSIDERATIONS
-- ====================================================
-- 1. Passwords stored as bcrypt hashes (one-way encryption)
-- 2. Prepared statements used for all queries (SQL injection prevention)
-- 3. Foreign key constraints ensure referential integrity
-- 4. ON DELETE RESTRICT prevents accidental data loss
-- 5. Audit logging tracks all critical actions
-- 6. Email addresses are unique to prevent duplicate accounts

-- ====================================================
-- END OF SCHEMA
-- ====================================================
-- Schema Version: 1.0
-- Last Updated: 2024
-- Project: CiviCore E-Governance Platform
-- ====================================================
