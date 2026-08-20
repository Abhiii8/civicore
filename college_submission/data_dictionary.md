# CiviCore - Data Dictionary
## Complete Database Schema Documentation

---

## Table of Contents

1. [Roles Table](#1-roles-table)
2. [Departments Table](#2-departments-table)
3. [Users Table](#3-users-table)
4. [Services Table](#4-services-table)
5. [Applications Table](#5-applications-table)
6. [Application Documents Table](#6-application-documents-table)
7. [Application Logs Table](#7-application-logs-table)
8. [Complaints Table](#8-complaints-table)
9. [Audit Logs Table](#9-audit-logs-table)

---

## 1. Roles Table

**Table Name**: `roles`  
**Purpose**: Stores user roles for role-based access control (RBAC)  
**Engine**: InnoDB  
**Character Set**: utf8mb4

| Field Name | Data Type | Constraints | Description | Primary Key | Foreign Key | Example Value |
|------------|-----------|-------------|-------------|-------------|-------------|---------------|
| id | INT | AUTO_INCREMENT, NOT NULL | Unique role identifier | ✅ Yes | - | 1 |
| name | VARCHAR(50) | NOT NULL, UNIQUE | Role name (citizen, officer, admin) | - | - | "citizen" |
| description | TEXT | NULL | Role description | - | - | "Citizen - Can apply for government services" |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp | - | - | 2024-01-01 10:00:00 |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | Last update timestamp | - | - | 2024-01-01 10:00:00 |

**Indexes**:
- PRIMARY KEY: `id`
- UNIQUE INDEX: `name` (idx_name)

**Relationships**:
- One-to-Many with `users` table (users.role_id → roles.id)

**Default Data**:
- id=1, name='citizen', description='Citizen - Can apply for government services'
- id=2, name='officer', description='Government Officer - Can review and approve applications'
- id=3, name='admin', description='Administrator - Full system access'

---

## 2. Departments Table

**Table Name**: `departments`  
**Purpose**: Stores government departments that offer services  
**Engine**: InnoDB  
**Character Set**: utf8mb4

| Field Name | Data Type | Constraints | Description | Primary Key | Foreign Key | Example Value |
|------------|-----------|-------------|-------------|-------------|-------------|---------------|
| id | INT | AUTO_INCREMENT, NOT NULL | Unique department identifier | ✅ Yes | - | 1 |
| name | VARCHAR(100) | NOT NULL | Department name | - | - | "Health Department" |
| code | VARCHAR(20) | UNIQUE, NULL | Department code (short identifier) | - | - | "HLTH" |
| description | TEXT | NULL | Department description | - | - | "Health and medical services" |
| is_active | BOOLEAN | DEFAULT TRUE | Whether department is active | - | - | TRUE |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp | - | - | 2024-01-01 10:00:00 |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | Last update timestamp | - | - | 2024-01-01 10:00:00 |

**Indexes**:
- PRIMARY KEY: `id`
- UNIQUE INDEX: `code` (idx_code)
- INDEX: `is_active` (idx_active)

**Relationships**:
- One-to-Many with `users` table (users.department_id → departments.id)
- One-to-Many with `services` table (services.department_id → departments.id)

**Default Data**:
- General Administration (GEN)
- Health Department (HLTH)
- Education Department (EDU)
- Revenue Department (REV)
- Civil Registration (CIV)

---

## 3. Users Table

**Table Name**: `users`  
**Purpose**: Stores all system users (citizens, officers, admins)  
**Engine**: InnoDB  
**Character Set**: utf8mb4

| Field Name | Data Type | Constraints | Description | Primary Key | Foreign Key | Example Value |
|------------|-----------|-------------|-------------|-------------|-------------|---------------|
| id | INT | AUTO_INCREMENT, NOT NULL | Unique user identifier | ✅ Yes | - | 1 |
| role_id | INT | NOT NULL | User role (references roles.id) | - | ✅ Yes → roles.id | 1 |
| department_id | INT | NULL | Department assignment (for officers) | - | ✅ Yes → departments.id | 5 |
| email | VARCHAR(100) | NOT NULL, UNIQUE | User email address | - | - | "user@example.com" |
| password | VARCHAR(255) | NOT NULL | Bcrypt hashed password | - | - | "$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi" |
| full_name | VARCHAR(100) | NOT NULL | User's full name | - | - | "John Doe" |
| phone | VARCHAR(20) | NULL | Contact phone number | - | - | "9876543210" |
| aadhaar_number | VARCHAR(12) | UNIQUE, NULL | Aadhaar card number (for citizens) | - | - | "123456789012" |
| address | TEXT | NULL | User address | - | - | "123 Main Street, City" |
| date_of_birth | DATE | NULL | Date of birth | - | - | 1990-05-15 |
| is_active | BOOLEAN | DEFAULT TRUE | Account active status | - | - | TRUE |
| email_verified | BOOLEAN | DEFAULT FALSE | Email verification status | - | - | FALSE |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Account creation timestamp | - | - | 2024-01-01 10:00:00 |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | Last update timestamp | - | - | 2024-01-01 10:00:00 |

**Indexes**:
- PRIMARY KEY: `id`
- UNIQUE INDEX: `email` (idx_email)
- UNIQUE INDEX: `aadhaar_number` (idx_aadhaar)
- INDEX: `role_id` (idx_role)
- INDEX: `department_id` (idx_department)
- INDEX: `is_active` (idx_active)

**Relationships**:
- Many-to-One with `roles` table (users.role_id → roles.id)
- Many-to-One with `departments` table (users.department_id → departments.id)
- One-to-Many with `applications` table (applications.citizen_id → users.id)
- One-to-Many with `applications` table (applications.officer_id → users.id)
- One-to-Many with `complaints` table (complaints.citizen_id → users.id)
- One-to-Many with `complaints` table (complaints.assigned_to → users.id)
- One-to-Many with `audit_logs` table (audit_logs.user_id → users.id)

**Foreign Key Constraints**:
- `role_id`: ON DELETE RESTRICT (cannot delete role if users exist)
- `department_id`: ON DELETE SET NULL (if department deleted, set to NULL)

**Security Notes**:
- Passwords stored as bcrypt hashes (60 characters)
- Email must be unique across all users
- Aadhaar number must be unique (if provided)

---

## 4. Services Table

**Table Name**: `services`  
**Purpose**: Stores available government services that citizens can apply for  
**Engine**: InnoDB  
**Character Set**: utf8mb4

| Field Name | Data Type | Constraints | Description | Primary Key | Foreign Key | Example Value |
|------------|-----------|-------------|-------------|-------------|-------------|---------------|
| id | INT | AUTO_INCREMENT, NOT NULL | Unique service identifier | ✅ Yes | - | 1 |
| department_id | INT | NOT NULL | Department offering the service | - | ✅ Yes → departments.id | 5 |
| name | VARCHAR(100) | NOT NULL | Service name | - | - | "Birth Certificate" |
| code | VARCHAR(50) | UNIQUE, NULL | Service code (short identifier) | - | - | "BC001" |
| description | TEXT | NULL | Service description | - | - | "Official birth certificate issuance" |
| required_documents | TEXT | NULL | List of required documents | - | - | "Aadhaar Card, Hospital Certificate" |
| processing_days | INT | DEFAULT 7 | Expected processing time in days | - | - | 5 |
| fee | DECIMAL(10,2) | DEFAULT 0.00 | Service fee amount | - | - | 0.00 |
| is_active | BOOLEAN | DEFAULT TRUE | Whether service is active | - | - | TRUE |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp | - | - | 2024-01-01 10:00:00 |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | Last update timestamp | - | - | 2024-01-01 10:00:00 |

**Indexes**:
- PRIMARY KEY: `id`
- INDEX: `department_id` (idx_department)
- UNIQUE INDEX: `code` (idx_code)
- INDEX: `is_active` (idx_active)

**Relationships**:
- Many-to-One with `departments` table (services.department_id → departments.id)
- One-to-Many with `applications` table (applications.service_id → services.id)

**Foreign Key Constraints**:
- `department_id`: ON DELETE RESTRICT (cannot delete department if services exist)

**Default Services**:
- Birth Certificate (BC001)
- Income Certificate (IC001)
- Residence Certificate (RC001)
- Scholarship Application (SA001)
- Grievance Request (GR001)

---

## 5. Applications Table

**Table Name**: `applications`  
**Purpose**: Stores citizen applications for government services  
**Engine**: InnoDB  
**Character Set**: utf8mb4

| Field Name | Data Type | Constraints | Description | Primary Key | Foreign Key | Example Value |
|------------|-----------|-------------|-------------|-------------|-------------|---------------|
| id | INT | AUTO_INCREMENT, NOT NULL | Unique application identifier | ✅ Yes | - | 1 |
| application_number | VARCHAR(50) | UNIQUE, NOT NULL | Unique application tracking number | - | - | "APP2024001" |
| citizen_id | INT | NOT NULL | Citizen who submitted application | - | ✅ Yes → users.id | 2 |
| service_id | INT | NOT NULL | Service being applied for | - | ✅ Yes → services.id | 1 |
| officer_id | INT | NULL | Officer assigned to review | - | ✅ Yes → users.id | 4 |
| status | ENUM | DEFAULT 'pending' | Application status | - | - | "pending" |
| remarks | TEXT | NULL | Officer remarks/notes | - | - | "All documents verified" |
| rejection_reason | TEXT | NULL | Reason for rejection (if rejected) | - | - | "Incomplete documents" |
| applied_date | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Application submission date | - | - | 2024-01-15 10:00:00 |
| reviewed_date | TIMESTAMP | NULL | Date when officer started review | - | - | 2024-01-16 11:00:00 |
| approved_date | TIMESTAMP | NULL | Date when application was approved | - | - | 2024-01-17 14:00:00 |
| certificate_path | VARCHAR(255) | NULL | Path to generated certificate PDF | - | - | "certificates/1_1234567890.pdf" |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp | - | - | 2024-01-15 10:00:00 |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | Last update timestamp | - | - | 2024-01-17 14:00:00 |

**Status Values**:
- `pending`: Application submitted, awaiting assignment
- `under_review`: Assigned to officer, under review
- `approved`: Application approved, certificate generated
- `rejected`: Application rejected

**Indexes**:
- PRIMARY KEY: `id`
- UNIQUE INDEX: `application_number` (idx_application_number)
- INDEX: `citizen_id` (idx_citizen)
- INDEX: `service_id` (idx_service)
- INDEX: `officer_id` (idx_officer)
- INDEX: `status` (idx_status)
- INDEX: `applied_date` (idx_applied_date)

**Relationships**:
- Many-to-One with `users` table (applications.citizen_id → users.id)
- Many-to-One with `users` table (applications.officer_id → users.id)
- Many-to-One with `services` table (applications.service_id → services.id)
- One-to-Many with `application_documents` table
- One-to-Many with `application_logs` table

**Foreign Key Constraints**:
- `citizen_id`: ON DELETE RESTRICT
- `service_id`: ON DELETE RESTRICT
- `officer_id`: ON DELETE SET NULL

**Application Number Format**:
- Format: `APP{YYYY}{NNNN}`
- Example: APP2024001 (APP + Year + Sequential Number)

---

## 6. Application Documents Table

**Table Name**: `application_documents`  
**Purpose**: Stores documents uploaded by citizens for applications  
**Engine**: InnoDB  
**Character Set**: utf8mb4

| Field Name | Data Type | Constraints | Description | Primary Key | Foreign Key | Example Value |
|------------|-----------|-------------|-------------|-------------|-------------|---------------|
| id | INT | AUTO_INCREMENT, NOT NULL | Unique document identifier | ✅ Yes | - | 1 |
| application_id | INT | NOT NULL | Associated application | - | ✅ Yes → applications.id | 1 |
| document_name | VARCHAR(255) | NOT NULL | Original document name | - | - | "Aadhaar_Card.pdf" |
| file_path | VARCHAR(255) | NOT NULL | Server file path | - | - | "uploads/doc_1_1234567890.pdf" |
| file_type | VARCHAR(50) | NULL | File MIME type | - | - | "application/pdf" |
| file_size | INT | NULL | File size in bytes | - | - | 245760 |
| uploaded_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Upload timestamp | - | - | 2024-01-15 10:05:00 |

**Indexes**:
- PRIMARY KEY: `id`
- INDEX: `application_id` (idx_application)

**Relationships**:
- Many-to-One with `applications` table (application_documents.application_id → applications.id)

**Foreign Key Constraints**:
- `application_id`: ON DELETE CASCADE (documents deleted when application deleted)

**Supported File Types**:
- PDF (application/pdf)
- JPEG (image/jpeg)
- PNG (image/png)

**File Storage**:
- Base path: `backend/uploads/`
- Naming convention: `doc_{application_id}_{timestamp}_{random}.{ext}`

---

## 7. Application Logs Table

**Table Name**: `application_logs`  
**Purpose**: Audit trail for application status changes and actions  
**Engine**: InnoDB  
**Character Set**: utf8mb4

| Field Name | Data Type | Constraints | Description | Primary Key | Foreign Key | Example Value |
|------------|-----------|-------------|-------------|-------------|-------------|---------------|
| id | INT | AUTO_INCREMENT, NOT NULL | Unique log identifier | ✅ Yes | - | 1 |
| application_id | INT | NOT NULL | Associated application | - | ✅ Yes → applications.id | 1 |
| user_id | INT | NULL | User who performed action | - | ✅ Yes → users.id | 4 |
| action | VARCHAR(100) | NOT NULL | Action performed | - | - | "Application Approved" |
| old_status | VARCHAR(50) | NULL | Previous status | - | - | "under_review" |
| new_status | VARCHAR(50) | NULL | New status | - | - | "approved" |
| remarks | TEXT | NULL | Additional remarks | - | - | "All documents verified and approved" |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Action timestamp | - | - | 2024-01-17 14:00:00 |

**Indexes**:
- PRIMARY KEY: `id`
- INDEX: `application_id` (idx_application)
- INDEX: `user_id` (idx_user)
- INDEX: `created_at` (idx_created_at)

**Relationships**:
- Many-to-One with `applications` table (application_logs.application_id → applications.id)
- Many-to-One with `users` table (application_logs.user_id → users.id)

**Foreign Key Constraints**:
- `application_id`: ON DELETE CASCADE
- `user_id`: ON DELETE SET NULL

**Common Actions**:
- "Application Submitted"
- "Application Assigned"
- "Application Approved"
- "Application Rejected"
- "Status Changed"

---

## 8. Complaints Table

**Table Name**: `complaints`  
**Purpose**: Stores citizen complaints and grievances  
**Engine**: InnoDB  
**Character Set**: utf8mb4

| Field Name | Data Type | Constraints | Description | Primary Key | Foreign Key | Example Value |
|------------|-----------|-------------|-------------|-------------|-------------|---------------|
| id | INT | AUTO_INCREMENT, NOT NULL | Unique complaint identifier | ✅ Yes | - | 1 |
| complaint_number | VARCHAR(50) | UNIQUE, NOT NULL | Unique complaint tracking number | - | - | "COMP2024001" |
| citizen_id | INT | NOT NULL | Citizen who submitted complaint | - | ✅ Yes → users.id | 2 |
| subject | VARCHAR(255) | NOT NULL | Complaint subject/title | - | - | "Delayed Certificate" |
| description | TEXT | NOT NULL | Complaint description | - | - | "Birth certificate application is taking longer than expected" |
| status | ENUM | DEFAULT 'open' | Complaint status | - | - | "open" |
| assigned_to | INT | NULL | Officer assigned to handle | - | ✅ Yes → users.id | 4 |
| resolution | TEXT | NULL | Resolution details | - | - | "Certificate issued and delivered" |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Complaint submission date | - | - | 2024-01-18 14:00:00 |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | Last update timestamp | - | - | 2024-01-20 16:00:00 |
| resolved_at | TIMESTAMP | NULL | Resolution date | - | - | 2024-01-20 16:00:00 |
| photo_path | VARCHAR(255) | NULL | Path to attached photo (if any) | - | - | "uploads/complaints/complaint_1_1234567890.jpg" |

**Status Values**:
- `open`: Complaint submitted, not yet assigned
- `in_progress`: Complaint assigned, being processed
- `resolved`: Complaint resolved
- `closed`: Complaint closed

**Indexes**:
- PRIMARY KEY: `id`
- UNIQUE INDEX: `complaint_number` (idx_complaint_number)
- INDEX: `citizen_id` (idx_citizen)
- INDEX: `status` (idx_status)
- INDEX: `assigned_to` (idx_assigned)

**Relationships**:
- Many-to-One with `users` table (complaints.citizen_id → users.id)
- Many-to-One with `users` table (complaints.assigned_to → users.id)

**Foreign Key Constraints**:
- `citizen_id`: ON DELETE RESTRICT
- `assigned_to`: ON DELETE SET NULL

**Complaint Number Format**:
- Format: `COMP{YYYY}{NNNN}`
- Example: COMP2024001

---

## 9. Audit Logs Table

**Table Name**: `audit_logs`  
**Purpose**: System-wide audit trail for accountability and compliance  
**Engine**: InnoDB  
**Character Set**: utf8mb4

| Field Name | Data Type | Constraints | Description | Primary Key | Foreign Key | Example Value |
|------------|-----------|-------------|-------------|-------------|-------------|---------------|
| id | INT | AUTO_INCREMENT, NOT NULL | Unique log identifier | ✅ Yes | - | 1 |
| user_id | INT | NULL | User who performed action | - | ✅ Yes → users.id | 1 |
| action | VARCHAR(100) | NOT NULL | Action performed | - | - | "LOGIN" |
| entity_type | VARCHAR(50) | NULL | Type of entity affected | - | - | "user" |
| entity_id | INT | NULL | ID of affected entity | - | - | 1 |
| details | TEXT | NULL | Additional action details | - | - | "Admin logged in" |
| ip_address | VARCHAR(45) | NULL | User's IP address | - | - | "192.168.1.1" |
| user_agent | TEXT | NULL | User's browser/client info | - | - | "Mozilla/5.0..." |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Action timestamp | - | - | 2024-01-01 10:00:00 |

**Indexes**:
- PRIMARY KEY: `id`
- INDEX: `user_id` (idx_user)
- INDEX: `action` (idx_action)
- INDEX: `entity_type, entity_id` (idx_entity)
- INDEX: `created_at` (idx_created_at)

**Relationships**:
- Many-to-One with `users` table (audit_logs.user_id → users.id)

**Foreign Key Constraints**:
- `user_id`: ON DELETE SET NULL

**Common Actions Logged**:
- LOGIN, LOGOUT
- CREATE_APPLICATION, APPROVE_APPLICATION, REJECT_APPLICATION
- CREATE_USER, UPDATE_USER
- CREATE_DEPARTMENT, CREATE_SERVICE
- ASSIGN_APPLICATION
- REGISTER

**Entity Types**:
- user
- application
- service
- department
- complaint

---

## Database Relationships Summary

### Entity Relationship Diagram Overview

```
roles (1) ────< (M) users
                │
                ├───< (M) applications (citizen_id)
                ├───< (M) applications (officer_id)
                ├───< (M) complaints (citizen_id)
                ├───< (M) complaints (assigned_to)
                └───< (M) audit_logs

departments (1) ────< (M) users
                │
                └───< (M) services

services (1) ────< (M) applications

applications (1) ────< (M) application_documents
                │
                └───< (M) application_logs
```

### Key Relationships

1. **Users → Roles**: Many users belong to one role
2. **Users → Departments**: Many users (officers) belong to one department
3. **Services → Departments**: Many services belong to one department
4. **Applications → Users**: Many applications belong to one citizen and one officer
5. **Applications → Services**: Many applications belong to one service
6. **Documents → Applications**: Many documents belong to one application
7. **Logs → Applications**: Many logs belong to one application
8. **Complaints → Users**: Many complaints belong to one citizen and one officer

---

## Data Integrity Rules

### Referential Integrity
- All foreign keys enforce referential integrity
- ON DELETE RESTRICT: Prevents deletion of parent records with children
- ON DELETE CASCADE: Automatically deletes child records when parent deleted
- ON DELETE SET NULL: Sets foreign key to NULL when parent deleted

### Business Rules
1. **Application Status Flow**: 
   - pending → under_review → approved/rejected
   - Cannot skip statuses
   - Cannot revert from approved/rejected

2. **User Roles**:
   - Citizens cannot be assigned to departments
   - Officers must be assigned to departments
   - Admins can access all departments

3. **Application Assignment**:
   - Only pending applications can be assigned
   - Only officers can be assigned
   - Applications must have service

4. **Document Upload**:
   - Documents only for existing applications
   - File size limits enforced
   - File type validation

---

## Indexing Strategy

### Primary Indexes
- All tables have auto-incrementing primary keys
- Ensures fast record lookup

### Foreign Key Indexes
- All foreign key columns indexed
- Improves join performance

### Search Indexes
- Email addresses (unique lookup)
- Application numbers (unique lookup)
- Status fields (filtering)
- Date fields (sorting and filtering)

### Composite Indexes
- `entity_type, entity_id` in audit_logs (efficient entity lookup)

---

**Document Version**: 1.0  
**Last Updated**: 2024  
**Database**: CiviCore MySQL Database
